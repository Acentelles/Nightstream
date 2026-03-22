//! Stage 2: Twist read-write memory checking for registers and RAM.
//!
//! Owns the register subsystem (3 read ports + 1 write port) and
//! RAM subsystem (1 read + 1 write + RAF support).

use neo_math::{from_complex, KExtensions, F, K};
use neo_reductions::sumcheck::{run_sumcheck_prover, RoundOracle};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use super::kernel::{
    expect_equal_k, expect_equal_k_slice, verify_sumcheck_known, AddressCorrectnessProof, CycleProductProof,
    KernelStepAux, SimpleKernelError, Stage2LinkClaims, Stage2TwistProof, STAGE2_LANE_OPEN_COLS,
};
use super::spec::{
    COL_I_NEXT, COL_MEM_VALUE, COL_REG_X, COL_REG_X_NEXT, COL_WRITES_LOOKUP_TO_X, COL_WRITES_MEM_TO_X,
    COL_WRITES_NNN_TO_I,
};
use super::tables::{RAM_SINK_ADDR, REG_SINK_ADDR};
use super::{stage2_ram, stage2_reg};

// ---------------------------------------------------------------------------
// MLE helpers (inlined to avoid adding neo-memory dependency)
// ---------------------------------------------------------------------------

/// Build eq(r, .) table over the boolean hypercube of dimension r.len().
/// eq(r, x) = prod_i (r_i * x_i + (1-r_i)*(1-x_i))
pub(crate) fn build_eq_table(r: &[K]) -> Vec<K> {
    let ell = r.len();
    let n = 1usize << ell;
    let mut out = vec![K::ONE; n];
    for (i, &ri) in r.iter().enumerate() {
        let stride = 1usize << i;
        let block = 1usize << (ell - i - 1);
        let one_minus = K::ONE - ri;
        let mut idx = 0usize;
        for _ in 0..block {
            for j in 0..stride {
                let a = out[idx + j];
                out[idx + j] = a * one_minus;
            }
            for j in 0..stride {
                let a = out[idx + stride + j];
                out[idx + stride + j] = a * ri;
            }
            idx += 2 * stride;
        }
    }
    out
}

/// Evaluate MLE of a base-field vector at an extension-field point.
pub(crate) fn mle_eval_fk(v: &[F], r: &[K]) -> K {
    let chi = build_eq_table(r);
    assert_eq!(v.len(), chi.len(), "mle_eval: dimension mismatch");
    let mut acc = K::ZERO;
    for (&val, &weight) in v.iter().zip(chi.iter()) {
        acc += K::from(val) * weight;
    }
    acc
}

pub(crate) fn mle_eval_fk_be(v: &[F], point_be: &[K]) -> K {
    let point_le: Vec<K> = point_be.iter().rev().copied().collect();
    mle_eval_fk(v, &point_le)
}

pub(crate) fn partial_eval_flat_k_at_addr_be(flat: &[K], addr_point_be: &[K], trace_len: usize) -> Vec<K> {
    let domain = flat.len() / trace_len;
    let addr_point_le: Vec<K> = addr_point_be.iter().rev().copied().collect();
    let eq_addr = build_eq_table(&addr_point_le);
    assert_eq!(eq_addr.len(), domain, "address-point dimension mismatch");
    let mut out = vec![K::ZERO; trace_len];
    for (addr, &weight) in eq_addr.iter().enumerate() {
        let base = addr * trace_len;
        for cycle in 0..trace_len {
            out[cycle] += weight * flat[base + cycle];
        }
    }
    out
}

pub(crate) fn mle_eval_flat_k_at_point_be(flat: &[K], addr_point_be: &[K], cycle_point: &[K], trace_len: usize) -> K {
    let per_cycle = partial_eval_flat_k_at_addr_be(flat, addr_point_be, trace_len);
    let eq_cycle = build_eq_table(cycle_point);
    per_cycle
        .iter()
        .zip(eq_cycle.iter())
        .fold(K::ZERO, |acc, (&value, &weight)| acc + value * weight)
}

pub(crate) fn lane_values_at_cycle(trace_rows: &[[F; 24]], cycle_point: &[K]) -> Vec<K> {
    STAGE2_LANE_OPEN_COLS
        .iter()
        .map(|&col| {
            let values: Vec<F> = trace_rows.iter().map(|row| row[col]).collect();
            mle_eval_fk(&values, cycle_point)
        })
        .collect()
}

fn raw_address_coeffs(addr_bits: usize) -> Vec<F> {
    let domain = 1usize << addr_bits;
    (0..domain).map(|addr| F::from_u64(addr as u64)).collect()
}

pub(crate) fn handoff_values_at_cycle(aux: &[KernelStepAux], cycle_point: &[K]) -> Vec<K> {
    let uses_y: Vec<F> = aux
        .iter()
        .map(|step| if step.uses_y { F::ONE } else { F::ZERO })
        .collect();
    let reads_ram: Vec<F> = aux
        .iter()
        .map(|step| if step.reads_ram { F::ONE } else { F::ZERO })
        .collect();
    let writes_ram: Vec<F> = aux
        .iter()
        .map(|step| if step.writes_ram { F::ONE } else { F::ZERO })
        .collect();
    vec![
        mle_eval_fk(&uses_y, cycle_point),
        mle_eval_fk(&reads_ram, cycle_point),
        mle_eval_fk(&writes_ram, cycle_point),
    ]
}

pub(crate) fn stage2_address_claims(
    lane: &[K],
    handoff: &[K],
    reg_ra_y_mapped: K,
    reg_wa_mapped: K,
    ram_ra_mapped: K,
    ram_wa_mapped: K,
) -> ([K; 4], [K; 4], [K; 2], [K; 2]) {
    let sink_reg = K::from(F::from_u64(REG_SINK_ADDR as u64));
    let sink_ram = K::from(F::from_u64(RAM_SINK_ADDR as u64));
    let i_slot = K::from(F::from_u64(16u64));
    let mapped_reg_claims = [lane[11], reg_ra_y_mapped, i_slot, reg_wa_mapped];
    let raw_reg_claims = [
        lane[11],
        reg_ra_y_mapped + (K::ONE - handoff[0]) * sink_reg,
        i_slot,
        reg_wa_mapped + (K::ONE - lane[6] - lane[7] - lane[9]) * sink_reg,
    ];
    let mapped_ram_claims = [ram_ra_mapped, ram_wa_mapped];
    let raw_ram_claims = [
        ram_ra_mapped + (K::ONE - handoff[1]) * sink_ram,
        ram_wa_mapped + (K::ONE - handoff[2]) * sink_ram,
    ];
    (mapped_reg_claims, raw_reg_claims, mapped_ram_claims, raw_ram_claims)
}

pub(crate) fn col_values(trace_rows: &[[F; 24]], col: usize) -> Vec<K> {
    trace_rows.iter().map(|row| K::from(row[col])).collect()
}

pub(crate) fn bool_values_from_aux(aux: &[KernelStepAux], f: impl Fn(&KernelStepAux) -> bool) -> Vec<K> {
    aux.iter()
        .map(|row| if f(row) { K::ONE } else { K::ZERO })
        .collect()
}

/// Squeeze a K challenge from the transcript (two base-field squeezes).
pub(crate) fn squeeze_k<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}

/// Squeeze n base-field challenges from the transcript and lift to K.
pub(crate) fn squeeze_point<Tr: Transcript>(tr: &mut Tr, label: &'static [u8], n: usize) -> Vec<K> {
    (0..n)
        .map(|_| {
            let c0 = tr.challenge_field(label);
            let c1 = tr.challenge_field(label);
            from_complex(c0, c1)
        })
        .collect()
}

// ---------------------------------------------------------------------------
// One-hot witness construction
// ---------------------------------------------------------------------------

/// Build a one-hot witness flat array of size (domain_size * trace_len).
///
/// Layout: row-major with address as outer dimension, cycle as inner.
/// onehot[a * trace_len + j] = 1 if addresses[j] == a, else 0.
pub(crate) fn build_onehot(trace_len: usize, domain_size: usize, addresses: &[usize]) -> Vec<K> {
    assert_eq!(addresses.len(), trace_len);
    let total = domain_size * trace_len;
    let mut flat = vec![K::ZERO; total];
    for (j, &addr) in addresses.iter().enumerate() {
        debug_assert!(addr < domain_size, "address {addr} out of domain {domain_size}");
        flat[addr * trace_len + j] = K::ONE;
    }
    flat
}

// ---------------------------------------------------------------------------
// Register state replay
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Sumcheck oracle: batched read/write
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Address correctness oracle
// ---------------------------------------------------------------------------

/// Booleanity sumcheck: sum_{a,j} ra(a,j) * (ra(a,j) - 1) = 0
struct BooleanityOracle {
    ra_flat: Vec<K>,
    total_bits: usize,
}

impl RoundOracle for BooleanityOracle {
    fn num_rounds(&self) -> usize {
        self.total_bits
    }
    fn degree_bound(&self) -> usize {
        2
    }
    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let half = 1usize << (self.total_bits - 1);
        let mut ys = vec![K::ZERO; points.len()];
        for (pi, &x) in points.iter().enumerate() {
            let mut acc = K::ZERO;
            for pair in 0..half {
                let lo = 2 * pair;
                let hi = lo + 1;
                let ra_x = self.ra_flat[lo] + (self.ra_flat[hi] - self.ra_flat[lo]) * x;
                acc += ra_x * (ra_x - K::ONE);
            }
            ys[pi] = acc;
        }
        ys
    }
    fn fold(&mut self, r: K) {
        if self.total_bits == 0 {
            return;
        }
        let half = 1usize << (self.total_bits - 1);
        fold_vec(&mut self.ra_flat, half, r);
        self.total_bits -= 1;
    }
}

/// Hamming-weight-1 sumcheck: sum_a ra(a, r_cycle) = 1
/// Expressed as: sum_a eq(r_cycle, j_part) * ra(a, j_part) over just the
/// address dimension. Since r_cycle is already fixed, we pre-fold the cycle
/// dimension and run a sumcheck over address bits only.
struct HammingOracle {
    /// ra values after folding the cycle dimension with r_cycle.
    ra_addr: Vec<K>,
    addr_bits: usize,
}

impl RoundOracle for HammingOracle {
    fn num_rounds(&self) -> usize {
        self.addr_bits
    }
    fn degree_bound(&self) -> usize {
        1
    }
    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let half = 1usize << (self.addr_bits - 1);
        let mut ys = vec![K::ZERO; points.len()];
        for (pi, &x) in points.iter().enumerate() {
            let mut acc = K::ZERO;
            for pair in 0..half {
                let lo = 2 * pair;
                let hi = lo + 1;
                acc += self.ra_addr[lo] + (self.ra_addr[hi] - self.ra_addr[lo]) * x;
            }
            ys[pi] = acc;
        }
        ys
    }
    fn fold(&mut self, r: K) {
        if self.addr_bits == 0 {
            return;
        }
        let half = 1usize << (self.addr_bits - 1);
        fold_vec(&mut self.ra_addr, half, r);
        self.addr_bits -= 1;
    }
}

/// Linear address relation: sum_a ra(a, r_cycle) * coeff(a) = expected_addr
struct LinearAddressOracle {
    /// ra values after folding cycle dim with r_cycle.
    ra_addr: Vec<K>,
    /// coefficient polynomial values (lifted to K).
    coeffs: Vec<K>,
    addr_bits: usize,
}

impl RoundOracle for LinearAddressOracle {
    fn num_rounds(&self) -> usize {
        self.addr_bits
    }
    fn degree_bound(&self) -> usize {
        2
    }
    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let half = 1usize << (self.addr_bits - 1);
        let mut ys = vec![K::ZERO; points.len()];
        for (pi, &x) in points.iter().enumerate() {
            let mut acc = K::ZERO;
            for pair in 0..half {
                let lo = 2 * pair;
                let hi = lo + 1;
                let ra_x = self.ra_addr[lo] + (self.ra_addr[hi] - self.ra_addr[lo]) * x;
                let coeff_x = self.coeffs[lo] + (self.coeffs[hi] - self.coeffs[lo]) * x;
                acc += ra_x * coeff_x;
            }
            ys[pi] = acc;
        }
        ys
    }
    fn fold(&mut self, r: K) {
        if self.addr_bits == 0 {
            return;
        }
        let half = 1usize << (self.addr_bits - 1);
        fold_vec(&mut self.ra_addr, half, r);
        fold_vec(&mut self.coeffs, half, r);
        self.addr_bits -= 1;
    }
}

// ---------------------------------------------------------------------------
// Fold helper
// ---------------------------------------------------------------------------

/// Fold a vector in-place: v[i] = v[2i] + (v[2i+1] - v[2i]) * r, then truncate.
fn fold_vec(v: &mut Vec<K>, half: usize, r: K) {
    for i in 0..half {
        v[i] = v[2 * i] + (v[2 * i + 1] - v[2 * i]) * r;
    }
    v.truncate(half);
}

/// Fold the cycle dimension out of a flat (addr x cycle) one-hot witness,
/// evaluating sum_j eq(r_cycle, j) * onehot(a, j) for each address a.
pub(crate) fn fold_cycle_dim(flat: &[K], r_cycle: &[K], addr_count: usize, trace_len: usize) -> Vec<K> {
    let eq_cycle = build_eq_table(r_cycle);
    let mut result = vec![K::ZERO; addr_count];
    for a in 0..addr_count {
        let base = a * trace_len;
        let mut acc = K::ZERO;
        for j in 0..trace_len {
            acc += flat[base + j] * eq_cycle[j];
        }
        result[a] = acc;
    }
    result
}

pub(crate) fn read_port_claim(eq_cycle: &[K], selector_flat: &[K], val_flat: &[K], trace_len: usize) -> K {
    debug_assert_eq!(selector_flat.len(), val_flat.len());
    debug_assert_eq!(eq_cycle.len(), trace_len);
    selector_flat
        .chunks_exact(trace_len)
        .zip(val_flat.chunks_exact(trace_len))
        .fold(K::ZERO, |acc, (selector_chunk, val_chunk)| {
            acc + selector_chunk
                .iter()
                .zip(val_chunk.iter())
                .zip(eq_cycle.iter())
                .fold(K::ZERO, |inner, ((&selector, &value), &eq_j)| {
                    inner + eq_j * selector * value
                })
        })
}

pub(crate) fn write_port_claim(
    eq_cycle: &[K],
    selector_flat: &[K],
    inc_per_cycle: &[K],
    val_flat: &[K],
    trace_len: usize,
) -> K {
    debug_assert_eq!(selector_flat.len(), val_flat.len());
    debug_assert_eq!(eq_cycle.len(), trace_len);
    debug_assert_eq!(inc_per_cycle.len(), trace_len);
    selector_flat
        .chunks_exact(trace_len)
        .zip(val_flat.chunks_exact(trace_len))
        .fold(K::ZERO, |acc, (selector_chunk, val_chunk)| {
            acc + selector_chunk
                .iter()
                .zip(val_chunk.iter())
                .zip(eq_cycle.iter().zip(inc_per_cycle.iter()))
                .fold(K::ZERO, |inner, ((&selector, &value), (&eq_j, &inc_j))| {
                    inner + eq_j * selector * (inc_j + value)
                })
        })
}

// ---------------------------------------------------------------------------
// Address correctness prover
// ---------------------------------------------------------------------------

pub(crate) fn prove_address_correctness<Tr: Transcript>(
    ra_flat: &[K],
    r_cycle: &[K],
    addr_bits: usize,
    cycle_bits: usize,
    expected_mapped_addr: K,
    expected_raw_addr: K,
    mapped_coeffs_f: &[F],
    label: &str,
    transcript: &mut Tr,
) -> Result<AddressCorrectnessProof, SimpleKernelError> {
    let trace_len = 1usize << cycle_bits;
    let domain = 1usize << addr_bits;
    let total_bits = addr_bits + cycle_bits;

    // 1. Booleanity: sum ra(a,j)*(ra(a,j)-1) = 0
    let mut bool_oracle = BooleanityOracle {
        ra_flat: ra_flat.to_vec(),
        total_bits,
    };
    let bool_claim = K::ZERO;
    let (bool_rounds, _) = run_sumcheck_prover(transcript, &mut bool_oracle, bool_claim)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("{label} booleanity: {e}")))?;

    // 2. Hamming-weight-1: sum_a ra(a, r_cycle) = 1
    let ra_at_r_cycle = fold_cycle_dim(ra_flat, r_cycle, domain, trace_len);
    let mut hamming_oracle = HammingOracle {
        ra_addr: ra_at_r_cycle.clone(),
        addr_bits,
    };
    let hamming_claim = K::ONE;
    let (hamming_rounds, _) = run_sumcheck_prover(transcript, &mut hamming_oracle, hamming_claim)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("{label} hamming: {e}")))?;

    // 3. Mapped address consistency: sum_a ra(a, r_cycle) * mapped(a) = expected_mapped_addr
    let mapped_coeffs: Vec<K> = mapped_coeffs_f.iter().map(|&f| K::from(f)).collect();
    let mut decode_oracle = LinearAddressOracle {
        ra_addr: ra_at_r_cycle.clone(),
        coeffs: mapped_coeffs,
        addr_bits,
    };
    let (decode_rounds, _) = run_sumcheck_prover(transcript, &mut decode_oracle, expected_mapped_addr)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("{label} mapped address: {e}")))?;

    // 4. Raw sink-routing consistency: sum_a ra(a, r_cycle) * a = expected_raw_addr
    let raw_coeffs: Vec<K> = raw_address_coeffs(addr_bits)
        .into_iter()
        .map(K::from)
        .collect();
    let mut raw_oracle = LinearAddressOracle {
        ra_addr: ra_at_r_cycle.clone(),
        coeffs: raw_coeffs,
        addr_bits,
    };
    let (raw_rounds, _) = run_sumcheck_prover(transcript, &mut raw_oracle, expected_raw_addr)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("{label} raw address: {e}")))?;

    Ok(AddressCorrectnessProof {
        booleanity_rounds: bool_rounds,
        hamming_weight_rounds: hamming_rounds,
        decode_consistency_rounds: decode_rounds,
        raw_address_rounds: raw_rounds,
    })
}

// ---------------------------------------------------------------------------
// Product sumcheck oracle (local, avoids neo-memory dependency)
// ---------------------------------------------------------------------------

/// Sumcheck oracle for the product of N multilinear factors.
struct ProductOracle {
    factors: Vec<Vec<K>>,
    rounds_remaining: usize,
    degree_bound: usize,
}

impl ProductOracle {
    fn new(factors: Vec<Vec<K>>, degree_bound: usize) -> Self {
        let len = factors.first().map(|f| f.len()).unwrap_or(1);
        debug_assert!(len.is_power_of_two());
        let total_rounds = len.trailing_zeros() as usize;
        Self {
            factors,
            rounds_remaining: total_rounds,
            degree_bound,
        }
    }

    fn sum_over_hypercube(&self) -> K {
        let n = self.factors.first().map(|f| f.len()).unwrap_or(1);
        let mut sum = K::ZERO;
        for t in 0..n {
            let mut prod = K::ONE;
            for f in &self.factors {
                prod *= f[t];
            }
            sum += prod;
        }
        sum
    }
}

impl RoundOracle for ProductOracle {
    fn num_rounds(&self) -> usize {
        self.rounds_remaining
    }
    fn degree_bound(&self) -> usize {
        self.degree_bound
    }
    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        if self.rounds_remaining == 0 {
            let mut val = K::ONE;
            for f in &self.factors {
                val *= f[0];
            }
            return vec![val; points.len()];
        }
        let half = 1usize << (self.rounds_remaining - 1);
        let mut ys = vec![K::ZERO; points.len()];
        for (pi, &x) in points.iter().enumerate() {
            let mut acc = K::ZERO;
            for pair in 0..half {
                let mut prod = K::ONE;
                for factor in &self.factors {
                    let f0 = factor[2 * pair];
                    let f1 = factor[2 * pair + 1];
                    prod *= f0 + (f1 - f0) * x;
                }
                acc += prod;
            }
            ys[pi] = acc;
        }
        ys
    }
    fn fold(&mut self, r: K) {
        if self.rounds_remaining == 0 {
            return;
        }
        let half = 1usize << (self.rounds_remaining - 1);
        for f in &mut self.factors {
            fold_vec(f, half, r);
        }
        self.rounds_remaining -= 1;
    }
}

pub(crate) fn prove_cycle_product_relation<Tr: Transcript>(
    transcript: &mut Tr,
    factors: Vec<Vec<K>>,
    degree_bound: usize,
    claim_label: &'static [u8],
    label: &str,
) -> Result<CycleProductProof, SimpleKernelError> {
    let mut oracle = ProductOracle::new(factors, degree_bound);
    let claim = oracle.sum_over_hypercube();
    transcript.append_fields(claim_label, &claim.as_coeffs());
    let (rounds, _) = run_sumcheck_prover(transcript, &mut oracle, claim)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("{label}: {e}")))?;
    Ok(CycleProductProof { claim, rounds })
}

// ---------------------------------------------------------------------------
// Val-from-Inc oracle
// ---------------------------------------------------------------------------

/// Build the Val-from-Inc sumcheck factors.
///
/// RegVal(a, r_cycle) - init(a) = sum_j Inc(j) * Wa(a, j) * LT(j, r_cycle)
///
/// We build this as a product oracle over factors: inc, wa, lt_table.
/// For v1 we compute the LT table explicitly (O(T) per address, O(D*T) total).
pub(crate) fn build_val_from_inc_factors(
    cycle_bits: usize,
    r_cycle: &[K],
    inc_per_cycle: &[K],
    wa_at_addr: &[K],
) -> Vec<Vec<K>> {
    let trace_len = 1usize << cycle_bits;
    assert_eq!(inc_per_cycle.len(), trace_len, "inc trace length mismatch");
    assert_eq!(wa_at_addr.len(), trace_len, "wa(addr, cycle) length mismatch");

    // Build LT(j, r_cycle) for all j in the boolean hypercube.
    // LT(j, r) = sum_i (1-j_i)*r_i * prod_{k>i} eq(j_k, r_k)
    let lt_table = build_lt_table(cycle_bits, r_cycle);
    vec![inc_per_cycle.to_vec(), wa_at_addr.to_vec(), lt_table]
}

/// Build LT(j, r) for all j on the boolean hypercube.
/// LT(j, r) = 1{int(j) < int(r)} evaluated as a multilinear polynomial.
fn build_lt_table(cycle_bits: usize, r: &[K]) -> Vec<K> {
    let n = 1usize << cycle_bits;
    let mut lt = vec![K::ZERO; n];

    // suffix_eq[i] = prod_{k>=i} eq(j_k, r_k) for the current j
    // We iterate over all j and compute LT using the formula:
    // LT(j, r) = sum_{i=0}^{ell-1} (1 - j_i) * r_i * prod_{k>i} eq(j_k, r_k)
    for idx in 0..n {
        let mut suffix_eq = vec![K::ONE; cycle_bits + 1];
        for i in (0..cycle_bits).rev() {
            let j_i = if (idx >> i) & 1 == 1 { K::ONE } else { K::ZERO };
            let eq_i = (K::ONE - j_i) * (K::ONE - r[i]) + j_i * r[i];
            suffix_eq[i] = suffix_eq[i + 1] * eq_i;
        }
        let mut acc = K::ZERO;
        for i in 0..cycle_bits {
            let j_i = if (idx >> i) & 1 == 1 { K::ONE } else { K::ZERO };
            acc += (K::ONE - j_i) * r[i] * suffix_eq[i + 1];
        }
        lt[idx] = acc;
    }
    lt
}

// ---------------------------------------------------------------------------
// RAF oracle (RAM address filter)
// ---------------------------------------------------------------------------

/// RAF sumcheck: sum_a ra(a, r_cycle) * unmap_ram(a) = flag * ADDR
/// This is structurally identical to decode consistency.
pub(crate) fn prove_raf<Tr: Transcript>(
    ra_flat: &[K],
    r_cycle: &[K],
    addr_bits: usize,
    cycle_bits: usize,
    claim: K,
    unmap_f: &[F],
    transcript: &mut Tr,
) -> Result<Vec<Vec<K>>, SimpleKernelError> {
    let trace_len = 1usize << cycle_bits;
    let domain = 1usize << addr_bits;
    let ra_at_r = fold_cycle_dim(ra_flat, r_cycle, domain, trace_len);
    let unmap_k: Vec<K> = unmap_f.iter().map(|&f| K::from(f)).collect();

    let mut oracle = LinearAddressOracle {
        ra_addr: ra_at_r,
        coeffs: unmap_k,
        addr_bits,
    };
    let (rounds, _) = run_sumcheck_prover(transcript, &mut oracle, claim)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("raf: {e}")))?;
    Ok(rounds)
}

// ---------------------------------------------------------------------------
// Stage 2 prover entry point
// ---------------------------------------------------------------------------

/// Prove Stage 2 Twist memory checking.
pub fn prove_stage2<Tr: Transcript>(
    trace_rows: &[[F; 24]],
    aux: &[KernelStepAux],
    initial_registers: &[u8; 16],
    initial_i: u16,
    initial_ram: &[u8],
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<Stage2TwistProof, SimpleKernelError> {
    let trace_len = 1usize << cycle_bits;
    if aux.len() != trace_len {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "aux length {} != trace_len {}",
            aux.len(),
            trace_len
        )));
    }

    // --- Squeeze cycle challenge point ---
    let r_cycle = squeeze_point(transcript, b"stage2/r_cycle", cycle_bits);
    let eq_cycle = build_eq_table(&r_cycle);
    let lane_values_at_twist = lane_values_at_cycle(trace_rows, &r_cycle);
    let handoff_values_at_twist = handoff_values_at_cycle(aux, &r_cycle);

    let reg_proof = stage2_reg::prove_register_subsystem(
        trace_rows,
        aux,
        initial_registers,
        initial_i,
        cycle_bits,
        &r_cycle,
        &eq_cycle,
        &lane_values_at_twist,
        &handoff_values_at_twist,
        transcript,
    )?;

    // --- RAM subsystem ---
    let reg_wa_mapped_claim =
        reg_proof.reg_wa_addr_target_proof.claim + lane_values_at_twist[9] * K::from(F::from_u64(16u64));
    let ram_proof = stage2_ram::prove_ram_subsystem(
        trace_rows,
        aux,
        initial_ram,
        cycle_bits,
        &r_cycle,
        &eq_cycle,
        &lane_values_at_twist,
        &handoff_values_at_twist,
        reg_proof.reg_ra_y_target_proof.claim,
        reg_wa_mapped_claim,
        transcript,
    )?;

    let reg_x_next_vals = col_values(trace_rows, COL_REG_X_NEXT);
    let i_next_vals = col_values(trace_rows, COL_I_NEXT);
    let mem_value_vals = col_values(trace_rows, COL_MEM_VALUE);
    let reg_x_vals = col_values(trace_rows, COL_REG_X);
    let writes_lookup_to_x = col_values(trace_rows, COL_WRITES_LOOKUP_TO_X);
    let writes_mem_to_x = col_values(trace_rows, COL_WRITES_MEM_TO_X);
    let writes_nnn_to_i = col_values(trace_rows, COL_WRITES_NNN_TO_I);
    let write_x_target_flag: Vec<K> = writes_lookup_to_x
        .iter()
        .zip(writes_mem_to_x.iter())
        .map(|(&lookup, &mem)| lookup + mem)
        .collect();
    let reads_ram_vals = bool_values_from_aux(aux, |row| row.reads_ram);
    let writes_ram_vals = bool_values_from_aux(aux, |row| row.writes_ram);
    let idle_ram_flag: Vec<K> = reads_ram_vals
        .iter()
        .zip(writes_ram_vals.iter())
        .map(|(&reads, &writes)| K::ONE - reads - writes)
        .collect();
    let mem_minus_reg_x: Vec<K> = mem_value_vals
        .iter()
        .zip(reg_x_vals.iter())
        .map(|(&mem, &reg_x)| mem - reg_x)
        .collect();

    let reg_write_x_target_proof = prove_cycle_product_relation(
        transcript,
        vec![eq_cycle.clone(), write_x_target_flag, reg_x_next_vals],
        3,
        b"stage2/reg_write_x_target/claim",
        "reg_write_x_target",
    )?;
    let reg_write_i_target_proof = prove_cycle_product_relation(
        transcript,
        vec![eq_cycle.clone(), writes_nnn_to_i, i_next_vals],
        3,
        b"stage2/reg_write_i_target/claim",
        "reg_write_i_target",
    )?;
    let ram_read_target_proof = prove_cycle_product_relation(
        transcript,
        vec![eq_cycle.clone(), reads_ram_vals.clone(), mem_value_vals.clone()],
        3,
        b"stage2/ram_read_target/claim",
        "ram_read_target",
    )?;
    let ram_write_target_proof = prove_cycle_product_relation(
        transcript,
        vec![eq_cycle.clone(), writes_ram_vals.clone(), mem_value_vals.clone()],
        3,
        b"stage2/ram_write_target/claim",
        "ram_write_target",
    )?;
    let ram_write_matches_x_zero_proof = prove_cycle_product_relation(
        transcript,
        vec![eq_cycle.clone(), writes_ram_vals.clone(), mem_minus_reg_x],
        3,
        b"stage2/ram_write_matches_x_zero/claim",
        "ram_write_matches_x_zero",
    )?;
    if ram_write_matches_x_zero_proof.claim != K::ZERO {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 write-RAM MEM_VALUE must equal REG_X on active write rows".into(),
        ));
    }
    let ram_idle_mem_zero_proof = prove_cycle_product_relation(
        transcript,
        vec![eq_cycle.clone(), idle_ram_flag, mem_value_vals],
        3,
        b"stage2/ram_idle_mem_zero/claim",
        "ram_idle_mem_zero",
    )?;
    if ram_idle_mem_zero_proof.claim != K::ZERO {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 MEM_VALUE must be zero on non-RAM rows".into(),
        ));
    }
    let gamma_twist_link = squeeze_k(transcript, b"stage2/gamma_twist_link");

    let reg_x = lane_values_at_twist[0];
    let reg_y = lane_values_at_twist[1];
    let i_reg = lane_values_at_twist[3];

    let linkage_terms = [
        reg_proof.rv_x_claim - reg_x,
        reg_proof.rv_y_claim - reg_y,
        reg_proof.rv_i_claim - i_reg,
        reg_proof.wv_reg_claim - (reg_write_x_target_proof.claim + reg_write_i_target_proof.claim),
        ram_proof.rv_ram_claim - ram_read_target_proof.claim,
        ram_proof.wv_ram_claim - ram_write_target_proof.claim,
        ram_write_matches_x_zero_proof.claim,
        ram_idle_mem_zero_proof.claim,
    ];
    let mut linkage_batch_value = K::ZERO;
    let mut gamma_power = K::ONE;
    for term in linkage_terms {
        linkage_batch_value += gamma_power * term;
        gamma_power *= gamma_twist_link;
    }
    if linkage_batch_value != K::ZERO {
        let failing_terms: Vec<usize> = linkage_terms
            .iter()
            .enumerate()
            .filter_map(|(idx, term)| if *term != K::ZERO { Some(idx) } else { None })
            .collect();
        return Err(SimpleKernelError::SumcheckFailed(format!(
            "stage2 linkage batch failed at r_twist_cycle (nonzero terms: {failing_terms:?})"
        )));
    }

    Ok(Stage2TwistProof {
        cycle_point: r_cycle,
        reg_addr_point: reg_proof.reg_addr_point,
        reg_val_at_point: reg_proof.reg_val_at_point,
        ram_addr_point: ram_proof.ram_addr_point,
        ram_val_at_point: ram_proof.ram_val_at_point,
        gamma_reg: reg_proof.gamma_reg,
        reg_rw_batched_rounds: reg_proof.reg_rw_batched_rounds,
        reg_val_from_inc_claim: reg_proof.reg_val_from_inc_claim,
        reg_val_from_inc_rounds: reg_proof.reg_val_from_inc_rounds,
        reg_addr_correctness: reg_proof.reg_addr_correctness,
        gamma_ram: ram_proof.gamma_ram,
        ram_rw_batched_rounds: ram_proof.ram_rw_batched_rounds,
        ram_val_from_inc_claim: ram_proof.ram_val_from_inc_claim,
        ram_val_from_inc_rounds: ram_proof.ram_val_from_inc_rounds,
        ram_raf_read_claim: ram_proof.ram_raf_read_claim,
        ram_raf_read_rounds: ram_proof.ram_raf_read_rounds,
        ram_raf_write_claim: ram_proof.ram_raf_write_claim,
        ram_raf_write_rounds: ram_proof.ram_raf_write_rounds,
        reg_ra_y_target_proof: reg_proof.reg_ra_y_target_proof,
        reg_wa_addr_target_proof: reg_proof.reg_wa_addr_target_proof,
        reg_write_x_target_proof,
        reg_write_i_target_proof,
        ram_read_target_proof,
        ram_write_target_proof,
        ram_write_matches_x_zero_proof,
        ram_idle_mem_zero_proof,
        ram_addr_correctness: ram_proof.ram_addr_correctness,
        link_claims: Stage2LinkClaims {
            rv_x: reg_proof.rv_x_claim,
            rv_y: reg_proof.rv_y_claim,
            rv_i: reg_proof.rv_i_claim,
            wv_reg: reg_proof.wv_reg_claim,
            rv_ram: ram_proof.rv_ram_claim,
            wv_ram: ram_proof.wv_ram_claim,
        },
        gamma_twist_link,
        linkage_batch_value,
        lane_values_at_twist,
        handoff_values_at_twist,
    })
}

// ---------------------------------------------------------------------------
// Verifier
// ---------------------------------------------------------------------------

/// Verify Stage 2 Twist memory checking.
pub fn verify_stage2<Tr: Transcript>(
    proof: &Stage2TwistProof,
    initial_registers: &[u8; 16],
    initial_i: u16,
    initial_ram: &[u8],
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<(), SimpleKernelError> {
    if proof.handoff_values_at_twist.len() != 3 || proof.lane_values_at_twist.len() != 14 {
        return Err(SimpleKernelError::OpeningFailed(
            "stage2 opening surface has the wrong shape".into(),
        ));
    }

    let lane = &proof.lane_values_at_twist;
    let expected_cycle_point = squeeze_point(transcript, b"stage2/r_cycle", cycle_bits);
    expect_equal_k_slice(&proof.cycle_point, &expected_cycle_point, "stage2 cycle point")?;

    stage2_reg::verify_register_subsystem(proof, initial_registers, initial_i, cycle_bits, transcript)?;
    stage2_ram::verify_ram_subsystem(proof, initial_ram, cycle_bits, transcript)?;

    transcript.append_fields(
        b"stage2/reg_write_x_target/claim",
        &proof.reg_write_x_target_proof.claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        proof.reg_write_x_target_proof.claim,
        &proof.reg_write_x_target_proof.rounds,
        "stage2 register write-to-x target",
    )?;
    transcript.append_fields(
        b"stage2/reg_write_i_target/claim",
        &proof.reg_write_i_target_proof.claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        proof.reg_write_i_target_proof.claim,
        &proof.reg_write_i_target_proof.rounds,
        "stage2 register write-to-i target",
    )?;
    transcript.append_fields(
        b"stage2/ram_read_target/claim",
        &proof.ram_read_target_proof.claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        proof.ram_read_target_proof.claim,
        &proof.ram_read_target_proof.rounds,
        "stage2 RAM read target",
    )?;
    transcript.append_fields(
        b"stage2/ram_write_target/claim",
        &proof.ram_write_target_proof.claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        proof.ram_write_target_proof.claim,
        &proof.ram_write_target_proof.rounds,
        "stage2 RAM write target",
    )?;
    expect_equal_k(
        proof.ram_write_matches_x_zero_proof.claim,
        K::ZERO,
        "stage2 write-RAM MEM_VALUE/REG_X zero claim",
    )?;
    transcript.append_fields(
        b"stage2/ram_write_matches_x_zero/claim",
        &proof.ram_write_matches_x_zero_proof.claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        proof.ram_write_matches_x_zero_proof.claim,
        &proof.ram_write_matches_x_zero_proof.rounds,
        "stage2 RAM write matches REG_X",
    )?;
    expect_equal_k(
        proof.ram_idle_mem_zero_proof.claim,
        K::ZERO,
        "stage2 idle MEM_VALUE zero claim",
    )?;
    transcript.append_fields(
        b"stage2/ram_idle_mem_zero/claim",
        &proof.ram_idle_mem_zero_proof.claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        proof.ram_idle_mem_zero_proof.claim,
        &proof.ram_idle_mem_zero_proof.rounds,
        "stage2 idle MEM_VALUE",
    )?;

    let expected_gamma_twist_link = squeeze_k(transcript, b"stage2/gamma_twist_link");
    expect_equal_k(
        proof.gamma_twist_link,
        expected_gamma_twist_link,
        "stage2 gamma_twist_link",
    )?;

    let linkage_terms = [
        proof.link_claims.rv_x - lane[0],
        proof.link_claims.rv_y - lane[1],
        proof.link_claims.rv_i - lane[3],
        proof.link_claims.wv_reg - (proof.reg_write_x_target_proof.claim + proof.reg_write_i_target_proof.claim),
        proof.link_claims.rv_ram - proof.ram_read_target_proof.claim,
        proof.link_claims.wv_ram - proof.ram_write_target_proof.claim,
        proof.ram_write_matches_x_zero_proof.claim,
        proof.ram_idle_mem_zero_proof.claim,
    ];
    let mut linkage_batch_value = K::ZERO;
    let mut gamma_power = K::ONE;
    for term in linkage_terms {
        linkage_batch_value += gamma_power * term;
        gamma_power *= proof.gamma_twist_link;
    }
    expect_equal_k(
        proof.linkage_batch_value,
        linkage_batch_value,
        "stage2 linkage batch value",
    )?;
    if linkage_batch_value != K::ZERO {
        let failing_terms: Vec<usize> = linkage_terms
            .iter()
            .enumerate()
            .filter_map(|(idx, term)| if *term != K::ZERO { Some(idx) } else { None })
            .collect();
        return Err(SimpleKernelError::SumcheckFailed(format!(
            "stage2 linkage batch failed at r_twist_cycle (nonzero terms: {failing_terms:?})"
        )));
    }

    Ok(())
}

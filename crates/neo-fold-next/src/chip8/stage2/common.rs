//! Owns the Stage 2 shared oracles and helper evaluations.
//! It does not own the final Stage 2 linkage batch or subsystem-specific state replay.

use neo_math::{from_complex, KExtensions, F, K};
use neo_reductions::sumcheck::{run_sumcheck_prover, RoundOracle};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::kernel::{KernelStepAux, SimpleKernelError};
use crate::chip8::poly::build_eq_table;
use crate::chip8::tables::{RAM_SINK_ADDR, REG_SINK_ADDR};

use super::proof::{AddressCorrectnessProof, CycleProductProof, STAGE2_LANE_OPEN_COLS};

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

pub(crate) fn squeeze_k<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}

pub(crate) fn squeeze_point<Tr: Transcript>(tr: &mut Tr, label: &'static [u8], n: usize) -> Vec<K> {
    (0..n)
        .map(|_| {
            let c0 = tr.challenge_field(label);
            let c1 = tr.challenge_field(label);
            from_complex(c0, c1)
        })
        .collect()
}

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

struct HammingOracle {
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

struct LinearAddressOracle {
    ra_addr: Vec<K>,
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

fn fold_vec(v: &mut Vec<K>, half: usize, r: K) {
    for i in 0..half {
        v[i] = v[2 * i] + (v[2 * i + 1] - v[2 * i]) * r;
    }
    v.truncate(half);
}

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

    let mut bool_oracle = BooleanityOracle {
        ra_flat: ra_flat.to_vec(),
        total_bits,
    };
    let bool_claim = K::ZERO;
    let (bool_rounds, _) = run_sumcheck_prover(transcript, &mut bool_oracle, bool_claim)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("{label} booleanity: {e}")))?;

    let ra_at_r_cycle = fold_cycle_dim(ra_flat, r_cycle, domain, trace_len);
    let mut hamming_oracle = HammingOracle {
        ra_addr: ra_at_r_cycle.clone(),
        addr_bits,
    };
    let hamming_claim = K::ONE;
    let (hamming_rounds, _) = run_sumcheck_prover(transcript, &mut hamming_oracle, hamming_claim)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("{label} hamming: {e}")))?;

    let mapped_coeffs: Vec<K> = mapped_coeffs_f.iter().map(|&f| K::from(f)).collect();
    let mut decode_oracle = LinearAddressOracle {
        ra_addr: ra_at_r_cycle.clone(),
        coeffs: mapped_coeffs,
        addr_bits,
    };
    let (decode_rounds, _) = run_sumcheck_prover(transcript, &mut decode_oracle, expected_mapped_addr)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("{label} mapped address: {e}")))?;

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

pub(crate) fn build_val_from_inc_factors(
    cycle_bits: usize,
    r_cycle: &[K],
    inc_per_cycle: &[K],
    wa_at_addr: &[K],
) -> Vec<Vec<K>> {
    let trace_len = 1usize << cycle_bits;
    assert_eq!(inc_per_cycle.len(), trace_len, "inc trace length mismatch");
    assert_eq!(wa_at_addr.len(), trace_len, "wa(addr, cycle) length mismatch");
    let lt_table = build_lt_table(cycle_bits, r_cycle);
    vec![inc_per_cycle.to_vec(), wa_at_addr.to_vec(), lt_table]
}

fn build_lt_table(cycle_bits: usize, r: &[K]) -> Vec<K> {
    let n = 1usize << cycle_bits;
    let mut lt = vec![K::ZERO; n];
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

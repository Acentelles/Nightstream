//! Stage 2: Twist read-write memory checking for registers and RAM.
//!
//! Owns the register subsystem (3 read ports + 1 write port) and
//! RAM subsystem (1 read + 1 write + RAF support).

use neo_math::{from_complex, KExtensions, F, K};
use neo_reductions::sumcheck::{run_sumcheck_prover, RoundOracle};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use super::kernel::{
    expect_equal_k, expect_equal_k_slice, replay_sumcheck_unchecked, verify_stage2_address_correctness_transcript,
    verify_sumcheck_known, AddressCorrectnessProof, KernelStepAux, SimpleKernelError, Stage2LinkClaims,
    Stage2TwistProof, STAGE2_LANE_OPEN_COLS,
};
use super::tables::{build_unmap_ram, build_unmap_reg, ADDR_RAM_BITS, ADDR_REG_BITS, RAM_SINK_ADDR, REG_SINK_ADDR};

// ---------------------------------------------------------------------------
// MLE helpers (inlined to avoid adding neo-memory dependency)
// ---------------------------------------------------------------------------

/// Build eq(r, .) table over the boolean hypercube of dimension r.len().
/// eq(r, x) = prod_i (r_i * x_i + (1-r_i)*(1-x_i))
fn build_eq_table(r: &[K]) -> Vec<K> {
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
fn mle_eval_fk(v: &[F], r: &[K]) -> K {
    let chi = build_eq_table(r);
    assert_eq!(v.len(), chi.len(), "mle_eval: dimension mismatch");
    let mut acc = K::ZERO;
    for (&val, &weight) in v.iter().zip(chi.iter()) {
        acc += K::from(val) * weight;
    }
    acc
}

fn lane_values_at_cycle(trace_rows: &[[F; 24]], cycle_point: &[K]) -> Vec<K> {
    STAGE2_LANE_OPEN_COLS
        .iter()
        .map(|&col| {
            let values: Vec<F> = trace_rows.iter().map(|row| row[col]).collect();
            mle_eval_fk(&values, cycle_point)
        })
        .collect()
}

fn mapped_address_trace(addresses: &[usize], unmap: &[F]) -> Vec<F> {
    addresses.iter().map(|&addr| unmap[addr]).collect()
}

fn handoff_values_at_cycle(aux: &[KernelStepAux], cycle_point: &[K]) -> Vec<K> {
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

/// Squeeze a K challenge from the transcript (two base-field squeezes).
fn squeeze_k<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}

/// Squeeze n base-field challenges from the transcript and lift to K.
fn squeeze_point<Tr: Transcript>(tr: &mut Tr, label: &'static [u8], n: usize) -> Vec<K> {
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
fn build_onehot(trace_len: usize, domain_size: usize, addresses: &[usize]) -> Vec<K> {
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

/// Compute register Val from trace data.
///
/// Returns val[addr][cycle] for addr in 0..reg_domain_size.
fn compute_reg_val(
    trace_len: usize,
    aux: &[KernelStepAux],
    initial_registers: &[u8; 16],
    initial_i: u16,
) -> Vec<Vec<F>> {
    let reg_domain = 1usize << ADDR_REG_BITS; // 32
    let mut val = vec![vec![F::ZERO; trace_len]; reg_domain];

    // Initialize: V[0..15] from initial_registers, I from initial_i, rest zero.
    let mut current = vec![F::ZERO; reg_domain];
    for i in 0..16 {
        current[i] = F::from_u64(initial_registers[i] as u64);
    }
    current[16] = F::from_u64(initial_i as u64);
    // Slots 17..31 (including sink) stay zero.

    for j in 0..trace_len {
        // Record current state as Val at cycle j.
        for a in 0..reg_domain {
            val[a][j] = current[a];
        }
        // Apply the write for this cycle.
        if j < aux.len() {
            let wa = aux[j].reg_wa_addr;
            if wa < reg_domain && wa != REG_SINK_ADDR {
                current[wa] += aux[j].reg_inc;
            }
        }
    }
    val
}

/// Compute RAM Val from trace data.
///
/// Returns val[addr][cycle] for addr in 0..ram_domain_size.
fn compute_ram_val(trace_len: usize, aux: &[KernelStepAux], initial_ram: &[u8]) -> Vec<Vec<F>> {
    let ram_domain = 1usize << ADDR_RAM_BITS; // 8192
    let mut val = vec![vec![F::ZERO; trace_len]; ram_domain];

    let mut current = vec![F::ZERO; ram_domain];
    for (i, &byte) in initial_ram.iter().enumerate() {
        if i < 4096 {
            current[i] = F::from_u64(byte as u64);
        }
    }

    for j in 0..trace_len {
        for a in 0..ram_domain {
            val[a][j] = current[a];
        }
        if j < aux.len() {
            let wa = aux[j].ram_wa_addr;
            if wa < ram_domain && wa != RAM_SINK_ADDR {
                current[wa] += aux[j].ram_inc;
            }
        }
    }
    val
}

// ---------------------------------------------------------------------------
// Sumcheck oracle: batched read/write
// ---------------------------------------------------------------------------

/// Oracle for the batched register read/write sumcheck.
///
/// Computes:
///   S = sum_{a,j} eq(r_cycle, j) * [
///       wa(a,j) * (inc(j) + val(a,j))
///     + gamma * ra_x(a,j) * val(a,j)
///     + gamma^2 * ra_y(a,j) * val(a,j)
///     + gamma^3 * ra_i(a,j) * val(a,j)
///   ]
///
/// Flattened over (a, j) with address as the high-order bits.
struct RegRwOracle {
    /// eq(r_cycle, j) lifted to flat domain, repeated for each address slot.
    eq_flat: Vec<K>,
    wa_flat: Vec<K>,
    ra_x_flat: Vec<K>,
    ra_y_flat: Vec<K>,
    ra_i_flat: Vec<K>,
    inc_flat: Vec<K>,
    val_flat: Vec<K>,
    gamma: K,
    total_bits: usize,
}

impl RegRwOracle {
    fn new(
        cycle_bits: usize,
        r_cycle: &[K],
        gamma: K,
        wa: &[K],
        ra_x: &[K],
        ra_y: &[K],
        ra_i: &[K],
        inc_per_cycle: &[K],
        val_flat: &[K],
    ) -> Self {
        let trace_len = 1usize << cycle_bits;
        let addr_bits = ADDR_REG_BITS;
        let domain = 1usize << addr_bits;
        let flat_size = domain * trace_len;
        let total_bits = addr_bits + cycle_bits;

        // Build eq(r_cycle, j) and tile it across address slots.
        let eq_cycle = build_eq_table(r_cycle);
        let mut eq_flat = vec![K::ZERO; flat_size];
        for a in 0..domain {
            for j in 0..trace_len {
                eq_flat[a * trace_len + j] = eq_cycle[j];
            }
        }

        // Tile inc across address slots: inc_flat[a*T + j] = inc[j].
        let mut inc_flat = vec![K::ZERO; flat_size];
        for a in 0..domain {
            for j in 0..trace_len {
                inc_flat[a * trace_len + j] = inc_per_cycle[j];
            }
        }

        Self {
            eq_flat,
            wa_flat: wa.to_vec(),
            ra_x_flat: ra_x.to_vec(),
            ra_y_flat: ra_y.to_vec(),
            ra_i_flat: ra_i.to_vec(),
            inc_flat,
            val_flat: val_flat.to_vec(),
            gamma,
            total_bits,
        }
    }

    fn compute_claim(&self) -> K {
        let n = self.eq_flat.len();
        let g = self.gamma;
        let g2 = g * g;
        let g3 = g2 * g;
        let mut sum = K::ZERO;
        for i in 0..n {
            let eq_i = self.eq_flat[i];
            let v = self.val_flat[i];
            let term = self.wa_flat[i] * (self.inc_flat[i] + v)
                + g * self.ra_x_flat[i] * v
                + g2 * self.ra_y_flat[i] * v
                + g3 * self.ra_i_flat[i] * v;
            sum += eq_i * term;
        }
        sum
    }
}

impl RoundOracle for RegRwOracle {
    fn num_rounds(&self) -> usize {
        self.total_bits
    }

    fn degree_bound(&self) -> usize {
        // eq * (wa * (inc + val)) => degree 3 in each variable.
        3
    }

    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let half = 1usize << (self.total_bits - 1);
        let g = self.gamma;
        let g2 = g * g;
        let g3 = g2 * g;
        let mut ys = vec![K::ZERO; points.len()];

        for (pi, &x) in points.iter().enumerate() {
            let mut acc = K::ZERO;
            for pair in 0..half {
                let lo = 2 * pair;
                let hi = lo + 1;

                let eq_x = self.eq_flat[lo] + (self.eq_flat[hi] - self.eq_flat[lo]) * x;
                let wa_x = self.wa_flat[lo] + (self.wa_flat[hi] - self.wa_flat[lo]) * x;
                let rax_x = self.ra_x_flat[lo] + (self.ra_x_flat[hi] - self.ra_x_flat[lo]) * x;
                let ray_x = self.ra_y_flat[lo] + (self.ra_y_flat[hi] - self.ra_y_flat[lo]) * x;
                let rai_x = self.ra_i_flat[lo] + (self.ra_i_flat[hi] - self.ra_i_flat[lo]) * x;
                let inc_x = self.inc_flat[lo] + (self.inc_flat[hi] - self.inc_flat[lo]) * x;
                let v_x = self.val_flat[lo] + (self.val_flat[hi] - self.val_flat[lo]) * x;

                let term = wa_x * (inc_x + v_x) + g * rax_x * v_x + g2 * ray_x * v_x + g3 * rai_x * v_x;
                acc += eq_x * term;
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
        fold_vec(&mut self.eq_flat, half, r);
        fold_vec(&mut self.wa_flat, half, r);
        fold_vec(&mut self.ra_x_flat, half, r);
        fold_vec(&mut self.ra_y_flat, half, r);
        fold_vec(&mut self.ra_i_flat, half, r);
        fold_vec(&mut self.inc_flat, half, r);
        fold_vec(&mut self.val_flat, half, r);
        self.total_bits -= 1;
    }
}

/// Oracle for the batched RAM read/write sumcheck.
///
/// S = sum_{a,j} eq(r_cycle, j) * [
///     ra(a,j) * val(a,j)
///   + gamma * wa(a,j) * (inc(j) + val(a,j))
/// ]
struct RamRwOracle {
    eq_flat: Vec<K>,
    ra_flat: Vec<K>,
    wa_flat: Vec<K>,
    inc_flat: Vec<K>,
    val_flat: Vec<K>,
    gamma: K,
    total_bits: usize,
}

impl RamRwOracle {
    fn new(
        cycle_bits: usize,
        r_cycle: &[K],
        gamma: K,
        ra: &[K],
        wa: &[K],
        inc_per_cycle: &[K],
        val_flat: &[K],
    ) -> Self {
        let trace_len = 1usize << cycle_bits;
        let addr_bits = ADDR_RAM_BITS;
        let domain = 1usize << addr_bits;
        let flat_size = domain * trace_len;
        let total_bits = addr_bits + cycle_bits;

        let eq_cycle = build_eq_table(r_cycle);
        let mut eq_flat = vec![K::ZERO; flat_size];
        let mut inc_flat = vec![K::ZERO; flat_size];
        for a in 0..domain {
            for j in 0..trace_len {
                eq_flat[a * trace_len + j] = eq_cycle[j];
                inc_flat[a * trace_len + j] = inc_per_cycle[j];
            }
        }

        Self {
            eq_flat,
            ra_flat: ra.to_vec(),
            wa_flat: wa.to_vec(),
            inc_flat,
            val_flat: val_flat.to_vec(),
            gamma,
            total_bits,
        }
    }

    fn compute_claim(&self) -> K {
        let n = self.eq_flat.len();
        let g = self.gamma;
        let mut sum = K::ZERO;
        for i in 0..n {
            let eq_i = self.eq_flat[i];
            let v = self.val_flat[i];
            let term = self.ra_flat[i] * v + g * self.wa_flat[i] * (self.inc_flat[i] + v);
            sum += eq_i * term;
        }
        sum
    }
}

impl RoundOracle for RamRwOracle {
    fn num_rounds(&self) -> usize {
        self.total_bits
    }

    fn degree_bound(&self) -> usize {
        3
    }

    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let half = 1usize << (self.total_bits - 1);
        let g = self.gamma;
        let mut ys = vec![K::ZERO; points.len()];

        for (pi, &x) in points.iter().enumerate() {
            let mut acc = K::ZERO;
            for pair in 0..half {
                let lo = 2 * pair;
                let hi = lo + 1;

                let eq_x = self.eq_flat[lo] + (self.eq_flat[hi] - self.eq_flat[lo]) * x;
                let ra_x = self.ra_flat[lo] + (self.ra_flat[hi] - self.ra_flat[lo]) * x;
                let wa_x = self.wa_flat[lo] + (self.wa_flat[hi] - self.wa_flat[lo]) * x;
                let inc_x = self.inc_flat[lo] + (self.inc_flat[hi] - self.inc_flat[lo]) * x;
                let v_x = self.val_flat[lo] + (self.val_flat[hi] - self.val_flat[lo]) * x;

                let term = ra_x * v_x + g * wa_x * (inc_x + v_x);
                acc += eq_x * term;
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
        fold_vec(&mut self.eq_flat, half, r);
        fold_vec(&mut self.ra_flat, half, r);
        fold_vec(&mut self.wa_flat, half, r);
        fold_vec(&mut self.inc_flat, half, r);
        fold_vec(&mut self.val_flat, half, r);
        self.total_bits -= 1;
    }
}

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

/// Decode consistency: sum_a ra(a, r_cycle) * unmap(a) = expected_addr
struct DecodeConsistencyOracle {
    /// ra values after folding cycle dim with r_cycle.
    ra_addr: Vec<K>,
    /// unmap polynomial values (lifted to K).
    unmap: Vec<K>,
    addr_bits: usize,
}

impl RoundOracle for DecodeConsistencyOracle {
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
                let um_x = self.unmap[lo] + (self.unmap[hi] - self.unmap[lo]) * x;
                acc += ra_x * um_x;
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
        fold_vec(&mut self.unmap, half, r);
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
fn fold_cycle_dim(flat: &[K], r_cycle: &[K], addr_count: usize, trace_len: usize) -> Vec<K> {
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

fn read_port_claim(eq_cycle: &[K], selector_flat: &[K], val_flat: &[K], trace_len: usize) -> K {
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

fn write_port_claim(eq_cycle: &[K], selector_flat: &[K], inc_per_cycle: &[K], val_flat: &[K], trace_len: usize) -> K {
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

fn prove_address_correctness<Tr: Transcript>(
    ra_flat: &[K],
    r_cycle: &[K],
    addr_bits: usize,
    cycle_bits: usize,
    expected_addr: K,
    unmap_f: &[F],
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
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("booleanity: {e}")))?;

    // 2. Hamming-weight-1: sum_a ra(a, r_cycle) = 1
    let ra_at_r_cycle = fold_cycle_dim(ra_flat, r_cycle, domain, trace_len);
    let mut hamming_oracle = HammingOracle {
        ra_addr: ra_at_r_cycle.clone(),
        addr_bits,
    };
    let hamming_claim = K::ONE;
    let (hamming_rounds, _) = run_sumcheck_prover(transcript, &mut hamming_oracle, hamming_claim)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("hamming: {e}")))?;

    // 3. Decode consistency: sum_a ra(a, r_cycle) * unmap(a) = expected_addr
    let unmap_k: Vec<K> = unmap_f.iter().map(|&f| K::from(f)).collect();
    let mut decode_oracle = DecodeConsistencyOracle {
        ra_addr: ra_at_r_cycle,
        unmap: unmap_k,
        addr_bits,
    };
    let (decode_rounds, _) = run_sumcheck_prover(transcript, &mut decode_oracle, expected_addr)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("decode consistency: {e}")))?;

    Ok(AddressCorrectnessProof {
        booleanity_rounds: bool_rounds,
        hamming_weight_rounds: hamming_rounds,
        decode_consistency_rounds: decode_rounds,
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

// ---------------------------------------------------------------------------
// Val-from-Inc oracle
// ---------------------------------------------------------------------------

/// Build the Val-from-Inc sumcheck factors.
///
/// RegVal(a, r_cycle) - init(a) = sum_j Inc(j) * Wa(a, j) * LT(j, r_cycle)
///
/// We build this as a product oracle over factors: inc, wa, lt_table.
/// For v1 we compute the LT table explicitly (O(T) per address, O(D*T) total).
fn build_val_from_inc_factors(
    cycle_bits: usize,
    r_cycle: &[K],
    inc_per_cycle: &[K],
    wa_flat: &[K],
    addr_bits: usize,
) -> Vec<Vec<K>> {
    let trace_len = 1usize << cycle_bits;
    let domain = 1usize << addr_bits;
    let flat_size = domain * trace_len;

    // Build LT(j, r_cycle) for all j in the boolean hypercube.
    // LT(j, r) = sum_i (1-j_i)*r_i * prod_{k>i} eq(j_k, r_k)
    let lt_table = build_lt_table(cycle_bits, r_cycle);

    // Tile lt across address dimension.
    let mut lt_flat = vec![K::ZERO; flat_size];
    for a in 0..domain {
        for j in 0..trace_len {
            lt_flat[a * trace_len + j] = lt_table[j];
        }
    }

    // Tile inc across address dimension.
    let mut inc_flat = vec![K::ZERO; flat_size];
    for a in 0..domain {
        for j in 0..trace_len {
            inc_flat[a * trace_len + j] = inc_per_cycle[j];
        }
    }

    vec![inc_flat, wa_flat.to_vec(), lt_flat]
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
fn prove_raf<Tr: Transcript>(
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

    let mut oracle = DecodeConsistencyOracle {
        ra_addr: ra_at_r,
        unmap: unmap_k,
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

    let reg_domain = 1usize << ADDR_REG_BITS;
    let ram_domain = 1usize << ADDR_RAM_BITS;

    // --- Squeeze cycle challenge point ---
    let r_cycle = squeeze_point(transcript, b"stage2/r_cycle", cycle_bits);
    let eq_cycle = build_eq_table(&r_cycle);

    // --- Register subsystem ---
    let gamma_reg = squeeze_k(transcript, b"stage2/gamma_reg");

    // Build one-hot witnesses.
    let reg_ra_x_addrs: Vec<usize> = aux.iter().map(|a| a.reg_ra_x_addr).collect();
    let reg_ra_y_addrs: Vec<usize> = aux.iter().map(|a| a.reg_ra_y_addr).collect();
    let reg_ra_i_addrs: Vec<usize> = aux.iter().map(|a| a.reg_ra_i_addr).collect();
    let reg_wa_addrs: Vec<usize> = aux.iter().map(|a| a.reg_wa_addr).collect();

    let reg_ra_x = build_onehot(trace_len, reg_domain, &reg_ra_x_addrs);
    let reg_ra_y = build_onehot(trace_len, reg_domain, &reg_ra_y_addrs);
    let reg_ra_i = build_onehot(trace_len, reg_domain, &reg_ra_i_addrs);
    let reg_wa = build_onehot(trace_len, reg_domain, &reg_wa_addrs);

    // Build Inc vector (per cycle).
    let reg_inc_k: Vec<K> = aux.iter().map(|a| K::from(a.reg_inc)).collect();

    // Compute Val and flatten.
    let reg_val = compute_reg_val(trace_len, aux, initial_registers, initial_i);
    let mut reg_val_flat = vec![K::ZERO; reg_domain * trace_len];
    for a in 0..reg_domain {
        for j in 0..trace_len {
            reg_val_flat[a * trace_len + j] = K::from(reg_val[a][j]);
        }
    }

    // Batched register read/write sumcheck.
    let mut reg_rw_oracle = RegRwOracle::new(
        cycle_bits,
        &r_cycle,
        gamma_reg,
        &reg_wa,
        &reg_ra_x,
        &reg_ra_y,
        &reg_ra_i,
        &reg_inc_k,
        &reg_val_flat,
    );
    let reg_rw_claim = reg_rw_oracle.compute_claim();
    let rv_x_claim = read_port_claim(&eq_cycle, &reg_ra_x, &reg_val_flat, trace_len);
    let rv_y_claim = read_port_claim(&eq_cycle, &reg_ra_y, &reg_val_flat, trace_len);
    let rv_i_claim = read_port_claim(&eq_cycle, &reg_ra_i, &reg_val_flat, trace_len);
    let wv_reg_claim = write_port_claim(&eq_cycle, &reg_wa, &reg_inc_k, &reg_val_flat, trace_len);
    let reg_rw_expected = wv_reg_claim
        + gamma_reg * rv_x_claim
        + gamma_reg * gamma_reg * rv_y_claim
        + gamma_reg * gamma_reg * gamma_reg * rv_i_claim;
    if reg_rw_claim != reg_rw_expected {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 reg read/write claim decomposition failed".into(),
        ));
    }

    transcript.append_fields(b"stage2/reg_rw_claim", &reg_rw_claim.as_coeffs());
    let (reg_rw_rounds, _reg_rw_challenges) = run_sumcheck_prover(transcript, &mut reg_rw_oracle, reg_rw_claim)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("reg_rw: {e}")))?;

    // Val-from-Inc sumcheck: sum_{a,j} Inc(j) * Wa(a,j) * LT(j, r_cycle).
    let val_inc_factors = build_val_from_inc_factors(cycle_bits, &r_cycle, &reg_inc_k, &reg_wa, ADDR_REG_BITS);
    let deg = val_inc_factors.len();
    let mut val_inc_oracle = ProductOracle::new(val_inc_factors, deg);
    let val_inc_sum = val_inc_oracle.sum_over_hypercube();

    transcript.append_fields(b"stage2/reg_val_inc_claim", &val_inc_sum.as_coeffs());
    let (reg_val_rounds, _) = run_sumcheck_prover(transcript, &mut val_inc_oracle, val_inc_sum)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("reg_val_inc: {e}")))?;

    // Address correctness for all 4 register families.
    let unmap_reg = build_unmap_reg();

    // Expected addresses at r_cycle for each family.
    let expected_ra_x = mle_eval_fk(&mapped_address_trace(&reg_ra_x_addrs, &unmap_reg), &r_cycle);
    let expected_ra_y = mle_eval_fk(&mapped_address_trace(&reg_ra_y_addrs, &unmap_reg), &r_cycle);
    let expected_ra_i = mle_eval_fk(&mapped_address_trace(&reg_ra_i_addrs, &unmap_reg), &r_cycle);
    let expected_wa = mle_eval_fk(&mapped_address_trace(&reg_wa_addrs, &unmap_reg), &r_cycle);

    let reg_addr_correctness = vec![
        prove_address_correctness(
            &reg_ra_x,
            &r_cycle,
            ADDR_REG_BITS,
            cycle_bits,
            expected_ra_x,
            &unmap_reg,
            transcript,
        )?,
        prove_address_correctness(
            &reg_ra_y,
            &r_cycle,
            ADDR_REG_BITS,
            cycle_bits,
            expected_ra_y,
            &unmap_reg,
            transcript,
        )?,
        prove_address_correctness(
            &reg_ra_i,
            &r_cycle,
            ADDR_REG_BITS,
            cycle_bits,
            expected_ra_i,
            &unmap_reg,
            transcript,
        )?,
        prove_address_correctness(
            &reg_wa,
            &r_cycle,
            ADDR_REG_BITS,
            cycle_bits,
            expected_wa,
            &unmap_reg,
            transcript,
        )?,
    ];

    // Squeeze register address point.
    let reg_addr_point = squeeze_point(transcript, b"stage2/r_addr_reg", ADDR_REG_BITS);

    // --- RAM subsystem ---
    let gamma_ram = squeeze_k(transcript, b"stage2/gamma_ram");

    let ram_ra_addrs: Vec<usize> = aux.iter().map(|a| a.ram_ra_addr).collect();
    let ram_wa_addrs: Vec<usize> = aux.iter().map(|a| a.ram_wa_addr).collect();

    let ram_ra = build_onehot(trace_len, ram_domain, &ram_ra_addrs);
    let ram_wa = build_onehot(trace_len, ram_domain, &ram_wa_addrs);

    let ram_inc_k: Vec<K> = aux.iter().map(|a| K::from(a.ram_inc)).collect();

    let ram_val = compute_ram_val(trace_len, aux, initial_ram);
    let mut ram_val_flat = vec![K::ZERO; ram_domain * trace_len];
    for a in 0..ram_domain {
        for j in 0..trace_len {
            ram_val_flat[a * trace_len + j] = K::from(ram_val[a][j]);
        }
    }

    // Batched RAM read/write sumcheck.
    let mut ram_rw_oracle = RamRwOracle::new(
        cycle_bits,
        &r_cycle,
        gamma_ram,
        &ram_ra,
        &ram_wa,
        &ram_inc_k,
        &ram_val_flat,
    );
    let ram_rw_claim = ram_rw_oracle.compute_claim();
    let rv_ram_claim = read_port_claim(&eq_cycle, &ram_ra, &ram_val_flat, trace_len);
    let wv_ram_claim = write_port_claim(&eq_cycle, &ram_wa, &ram_inc_k, &ram_val_flat, trace_len);
    let ram_rw_expected = rv_ram_claim + gamma_ram * wv_ram_claim;
    if ram_rw_claim != ram_rw_expected {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 ram read/write claim decomposition failed".into(),
        ));
    }

    transcript.append_fields(b"stage2/ram_rw_claim", &ram_rw_claim.as_coeffs());
    let (ram_rw_rounds, _) = run_sumcheck_prover(transcript, &mut ram_rw_oracle, ram_rw_claim)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("ram_rw: {e}")))?;

    // Val-from-Inc for RAM.
    let ram_val_inc_factors = build_val_from_inc_factors(cycle_bits, &r_cycle, &ram_inc_k, &ram_wa, ADDR_RAM_BITS);
    let factor_count = ram_val_inc_factors.len();
    let mut ram_val_inc_oracle = ProductOracle::new(ram_val_inc_factors, factor_count);
    let ram_val_inc_sum = ram_val_inc_oracle.sum_over_hypercube();

    transcript.append_fields(b"stage2/ram_val_inc_claim", &ram_val_inc_sum.as_coeffs());
    let (ram_val_rounds, _) = run_sumcheck_prover(transcript, &mut ram_val_inc_oracle, ram_val_inc_sum)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("ram_val_inc: {e}")))?;

    // RAM RAF sumchecks.
    let unmap_ram = build_unmap_ram();

    // RAF read claim: sum_a ra_read(a, r_cycle) * unmap(a) = reads_ram_mle(r_cycle) * RAM_ADDR_mle(r_cycle)
    // For v1, compute the claim directly.
    let reads_ram_vals: Vec<F> = aux
        .iter()
        .map(|a| if a.reads_ram { F::ONE } else { F::ZERO })
        .collect();
    let ram_addr_vals: Vec<F> = aux
        .iter()
        .map(|a| F::from_u64(a.ram_ra_addr as u64))
        .collect();
    let reads_at_r = mle_eval_fk(&reads_ram_vals, &r_cycle);
    let addr_read_at_r = mle_eval_fk(&ram_addr_vals, &r_cycle);
    let raf_read_claim = reads_at_r * addr_read_at_r;

    let ram_raf_read_rounds = prove_raf(
        &ram_ra,
        &r_cycle,
        ADDR_RAM_BITS,
        cycle_bits,
        raf_read_claim,
        &unmap_ram,
        transcript,
    )?;

    // RAF write.
    let writes_ram_vals: Vec<F> = aux
        .iter()
        .map(|a| if a.writes_ram { F::ONE } else { F::ZERO })
        .collect();
    let ram_wa_addr_vals: Vec<F> = aux
        .iter()
        .map(|a| F::from_u64(a.ram_wa_addr as u64))
        .collect();
    let writes_at_r = mle_eval_fk(&writes_ram_vals, &r_cycle);
    let addr_write_at_r = mle_eval_fk(&ram_wa_addr_vals, &r_cycle);
    let raf_write_claim = writes_at_r * addr_write_at_r;

    let ram_raf_write_rounds = prove_raf(
        &ram_wa,
        &r_cycle,
        ADDR_RAM_BITS,
        cycle_bits,
        raf_write_claim,
        &unmap_ram,
        transcript,
    )?;

    // Address correctness for RAM (2 families: read, write).
    let expected_ram_ra = mle_eval_fk(&mapped_address_trace(&ram_ra_addrs, &unmap_ram), &r_cycle);
    let expected_ram_wa = mle_eval_fk(&mapped_address_trace(&ram_wa_addrs, &unmap_ram), &r_cycle);

    let ram_addr_correctness = vec![
        prove_address_correctness(
            &ram_ra,
            &r_cycle,
            ADDR_RAM_BITS,
            cycle_bits,
            expected_ram_ra,
            &unmap_ram,
            transcript,
        )?,
        prove_address_correctness(
            &ram_wa,
            &r_cycle,
            ADDR_RAM_BITS,
            cycle_bits,
            expected_ram_wa,
            &unmap_ram,
            transcript,
        )?,
    ];

    let ram_addr_point = squeeze_point(transcript, b"stage2/r_addr_ram", ADDR_RAM_BITS);

    let lane_values_at_twist = lane_values_at_cycle(trace_rows, &r_cycle);
    let handoff_values_at_twist = handoff_values_at_cycle(aux, &r_cycle);
    let gamma_twist_link = squeeze_k(transcript, b"stage2/gamma_twist_link");

    let reg_x = lane_values_at_twist[0];
    let reg_y = lane_values_at_twist[1];
    let reg_x_next = lane_values_at_twist[2];
    let i_reg = lane_values_at_twist[3];
    let i_next = lane_values_at_twist[4];
    let mem_value = lane_values_at_twist[5];
    let writes_lookup_to_x = lane_values_at_twist[6];
    let writes_mem_to_x = lane_values_at_twist[7];
    let writes_nnn_to_i = lane_values_at_twist[9];
    let handoff_reads_ram = handoff_values_at_twist[1];
    let handoff_writes_ram = handoff_values_at_twist[2];

    let linkage_terms = [
        rv_x_claim - reg_x,
        rv_y_claim - reg_y,
        rv_i_claim - i_reg,
        wv_reg_claim - ((writes_lookup_to_x + writes_mem_to_x) * reg_x_next + writes_nnn_to_i * i_next),
        rv_ram_claim - handoff_reads_ram * mem_value,
        wv_ram_claim - handoff_writes_ram * mem_value,
        handoff_writes_ram * (mem_value - reg_x),
        (K::ONE - handoff_reads_ram - handoff_writes_ram) * mem_value,
    ];
    let mut linkage_batch_value = K::ZERO;
    let mut gamma_power = K::ONE;
    for term in linkage_terms {
        linkage_batch_value += gamma_power * term;
        gamma_power *= gamma_twist_link;
    }
    if linkage_batch_value != K::ZERO {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 linkage batch failed at r_twist_cycle".into(),
        ));
    }

    Ok(Stage2TwistProof {
        cycle_point: r_cycle,
        reg_addr_point,
        ram_addr_point,
        gamma_reg,
        reg_rw_batched_rounds: reg_rw_rounds,
        reg_val_from_inc_claim: val_inc_sum,
        reg_val_from_inc_rounds: reg_val_rounds,
        reg_addr_correctness,
        gamma_ram,
        ram_rw_batched_rounds: ram_rw_rounds,
        ram_val_from_inc_claim: ram_val_inc_sum,
        ram_val_from_inc_rounds: ram_val_rounds,
        ram_raf_read_rounds,
        ram_raf_write_rounds,
        ram_addr_correctness,
        link_claims: Stage2LinkClaims {
            rv_x: rv_x_claim,
            rv_y: rv_y_claim,
            rv_i: rv_i_claim,
            wv_reg: wv_reg_claim,
            rv_ram: rv_ram_claim,
            wv_ram: wv_ram_claim,
        },
        gamma_twist_link,
        linkage_batch_value,
        lane_values_at_twist,
        handoff_values_at_twist,
    })
}

// ---------------------------------------------------------------------------
// Verifier stub
// ---------------------------------------------------------------------------

/// Verify Stage 2 Twist memory checking (stub).
pub fn verify_stage2<Tr: Transcript>(
    proof: &Stage2TwistProof,
    _initial_registers: &[u8; 16],
    _initial_i: u16,
    _initial_ram: &[u8],
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<(), SimpleKernelError> {
    let expected_cycle_point = squeeze_point(transcript, b"stage2/r_cycle", cycle_bits);
    expect_equal_k_slice(&proof.cycle_point, &expected_cycle_point, "stage2 cycle point")?;

    let expected_gamma_reg = squeeze_k(transcript, b"stage2/gamma_reg");
    expect_equal_k(proof.gamma_reg, expected_gamma_reg, "stage2 gamma_reg")?;
    let reg_rw_claim = proof.link_claims.wv_reg
        + proof.gamma_reg * proof.link_claims.rv_x
        + proof.gamma_reg * proof.gamma_reg * proof.link_claims.rv_y
        + proof.gamma_reg * proof.gamma_reg * proof.gamma_reg * proof.link_claims.rv_i;
    transcript.append_fields(b"stage2/reg_rw_claim", &reg_rw_claim.as_coeffs());
    verify_sumcheck_known(
        transcript,
        3,
        reg_rw_claim,
        &proof.reg_rw_batched_rounds,
        "stage2 register read/write",
    )?;
    transcript.append_fields(b"stage2/reg_val_inc_claim", &proof.reg_val_from_inc_claim.as_coeffs());
    replay_sumcheck_unchecked(
        transcript,
        3,
        &proof.reg_val_from_inc_rounds,
        "stage2 register val-from-inc",
    )?;
    if proof.reg_addr_correctness.len() != 4 {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 register address correctness proof count must be 4".into(),
        ));
    }
    for (idx, addr_proof) in proof.reg_addr_correctness.iter().enumerate() {
        verify_stage2_address_correctness_transcript(
            transcript,
            addr_proof,
            ADDR_REG_BITS,
            cycle_bits,
            &format!("stage2 register address family {idx}"),
        )?;
    }
    let expected_reg_addr_point = squeeze_point(transcript, b"stage2/r_addr_reg", ADDR_REG_BITS);
    expect_equal_k_slice(&proof.reg_addr_point, &expected_reg_addr_point, "stage2 reg addr point")?;

    let expected_gamma_ram = squeeze_k(transcript, b"stage2/gamma_ram");
    expect_equal_k(proof.gamma_ram, expected_gamma_ram, "stage2 gamma_ram")?;
    let ram_rw_claim = proof.link_claims.rv_ram + proof.gamma_ram * proof.link_claims.wv_ram;
    transcript.append_fields(b"stage2/ram_rw_claim", &ram_rw_claim.as_coeffs());
    verify_sumcheck_known(
        transcript,
        3,
        ram_rw_claim,
        &proof.ram_rw_batched_rounds,
        "stage2 RAM read/write",
    )?;
    transcript.append_fields(b"stage2/ram_val_inc_claim", &proof.ram_val_from_inc_claim.as_coeffs());
    replay_sumcheck_unchecked(transcript, 3, &proof.ram_val_from_inc_rounds, "stage2 RAM val-from-inc")?;

    if proof.handoff_values_at_twist.len() != 3 || proof.lane_values_at_twist.len() != 14 {
        return Err(SimpleKernelError::OpeningFailed(
            "stage2 opening surface has the wrong shape".into(),
        ));
    }
    let raf_read_claim = proof.handoff_values_at_twist[1] * proof.lane_values_at_twist[13];
    verify_sumcheck_known(
        transcript,
        2,
        raf_read_claim,
        &proof.ram_raf_read_rounds,
        "stage2 RAM raf-read",
    )?;
    let raf_write_claim = proof.handoff_values_at_twist[2] * proof.lane_values_at_twist[13];
    verify_sumcheck_known(
        transcript,
        2,
        raf_write_claim,
        &proof.ram_raf_write_rounds,
        "stage2 RAM raf-write",
    )?;
    if proof.ram_addr_correctness.len() != 2 {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 RAM address correctness proof count must be 2".into(),
        ));
    }
    for (idx, addr_proof) in proof.ram_addr_correctness.iter().enumerate() {
        verify_stage2_address_correctness_transcript(
            transcript,
            addr_proof,
            ADDR_RAM_BITS,
            cycle_bits,
            &format!("stage2 RAM address family {idx}"),
        )?;
    }
    let expected_ram_addr_point = squeeze_point(transcript, b"stage2/r_addr_ram", ADDR_RAM_BITS);
    expect_equal_k_slice(&proof.ram_addr_point, &expected_ram_addr_point, "stage2 RAM addr point")?;

    let expected_gamma_twist_link = squeeze_k(transcript, b"stage2/gamma_twist_link");
    expect_equal_k(
        proof.gamma_twist_link,
        expected_gamma_twist_link,
        "stage2 gamma_twist_link",
    )?;

    let lane = &proof.lane_values_at_twist;
    let handoff = &proof.handoff_values_at_twist;
    let linkage_terms = [
        proof.link_claims.rv_x - lane[0],
        proof.link_claims.rv_y - lane[1],
        proof.link_claims.rv_i - lane[3],
        proof.link_claims.wv_reg - ((lane[6] + lane[7]) * lane[2] + lane[9] * lane[4]),
        proof.link_claims.rv_ram - handoff[1] * lane[5],
        proof.link_claims.wv_ram - handoff[2] * lane[5],
        handoff[2] * (lane[5] - lane[0]),
        (K::ONE - handoff[1] - handoff[2]) * lane[5],
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
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 linkage batch failed at r_twist_cycle".into(),
        ));
    }

    Ok(())
}

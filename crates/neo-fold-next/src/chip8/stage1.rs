//! Stage 1: Shout read-only lookup proofs for fetch, decode, ALU, and Eq4 channels.
//!
//! Owns: per-channel one-hot witness construction, ShoutCoreOracle (sumcheck over
//! address dimension), address-correctness sub-proofs (booleanity, Hamming-weight-1,
//! decode-consistency). Does not own table construction (see `tables.rs`).

use neo_math::{from_complex, F, K};
use neo_reductions::sumcheck::{run_sumcheck_prover, RoundOracle};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use super::kernel::{
    batch_values, verify_stage1_channel_transcript, KernelStepAux, ShoutChannelProof, Stage1ShoutProof,
    STAGE1_LANE_OPEN_COLS,
};
use super::tables::{DECODE_TABLE_COLUMNS, ROM_ADDR_BITS};

// ---------------------------------------------------------------------------
// One-hot witness builder
// ---------------------------------------------------------------------------

/// Build a one-hot witness for one channel across all cycles.
///
/// Returns a flat vector of length `table_size * trace_len` where
/// `onehot[addr * trace_len + cycle] = 1` if that cycle selected `addr`, else `0`.
fn build_onehot_witness(trace_len: usize, table_size: usize, addresses: &[usize]) -> Vec<F> {
    debug_assert_eq!(addresses.len(), trace_len);
    let mut v = vec![F::ZERO; table_size * trace_len];
    for (cycle, &addr) in addresses.iter().enumerate() {
        debug_assert!(
            addr < table_size,
            "address {addr} out of range for table size {table_size}"
        );
        v[addr * trace_len + cycle] = F::ONE;
    }
    v
}

// ---------------------------------------------------------------------------
// Chi-table (local helper, avoids neo-memory dependency)
// ---------------------------------------------------------------------------

/// Build the chi table for point `r` of length `ell`, returning `2^ell` entries.
///
/// chi_r[i] = prod_{bit} (r[bit] if (i>>bit)&1 else (1-r[bit])), little-endian.
fn build_chi_table(r: &[K]) -> Vec<K> {
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

// ---------------------------------------------------------------------------
// MLE partial evaluation helpers
// ---------------------------------------------------------------------------

/// Partially evaluate a 2D MLE `f[addr, cycle]` at `r_cycle`, yielding `f(addr, r_cycle)`
/// as a vector of length `table_size` over K.
///
/// `flat[addr * trace_len + cycle]` is the (addr, cycle) entry.
fn partial_eval_at_cycle(flat: &[F], table_size: usize, trace_len: usize, r_cycle: &[K]) -> Vec<K> {
    let chi_cycle = build_chi_table(r_cycle);
    debug_assert_eq!(chi_cycle.len(), trace_len);
    let mut out = vec![K::ZERO; table_size];
    for addr in 0..table_size {
        let base = addr * trace_len;
        let mut acc = K::ZERO;
        for j in 0..trace_len {
            let val = flat[base + j];
            if val != F::ZERO {
                acc += K::from(val) * chi_cycle[j];
            }
        }
        out[addr] = acc;
    }
    out
}

/// Evaluate MLE of a 1D vector at a point in K^ell.
fn mle_eval_k(v: &[F], r: &[K]) -> K {
    let chi = build_chi_table(r);
    debug_assert_eq!(v.len(), chi.len());
    let mut acc = K::ZERO;
    for (&val, &weight) in v.iter().zip(chi.iter()) {
        acc += K::from(val) * weight;
    }
    acc
}

fn mle_eval_many_k(cols: &[Vec<F>], point: &[K]) -> Vec<K> {
    let chi = build_chi_table(point);
    cols.iter()
        .map(|col| {
            debug_assert_eq!(col.len(), chi.len());
            col.iter()
                .zip(chi.iter())
                .fold(K::ZERO, |acc, (&val, &weight)| acc + K::from(val) * weight)
        })
        .collect()
}

fn mle_eval_k_be(v: &[F], point_be: &[K]) -> K {
    let point_le: Vec<K> = point_be.iter().rev().copied().collect();
    mle_eval_k(v, &point_le)
}

fn mle_eval_many_k_be(cols: &[Vec<F>], point_be: &[K]) -> Vec<K> {
    let point_le: Vec<K> = point_be.iter().rev().copied().collect();
    mle_eval_many_k(cols, &point_le)
}

fn open_onehot_at_point_be(addresses: &[usize], addr_point_be: &[K], cycle_point: &[K]) -> K {
    let addr_point_le: Vec<K> = addr_point_be.iter().rev().copied().collect();
    let chi_addr = build_chi_table(&addr_point_le);
    let chi_cycle = build_chi_table(cycle_point);
    addresses
        .iter()
        .enumerate()
        .fold(K::ZERO, |acc, (cycle, &addr)| acc + chi_cycle[cycle] * chi_addr[addr])
}

fn lane_values_at_cycle(trace_rows: &[[F; 24]], cycle_point: &[K]) -> Vec<K> {
    STAGE1_LANE_OPEN_COLS
        .iter()
        .map(|&col| {
            let values: Vec<F> = trace_rows.iter().map(|row| row[col]).collect();
            mle_eval_k(&values, cycle_point)
        })
        .collect()
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
        mle_eval_k(&uses_y, cycle_point),
        mle_eval_k(&reads_ram, cycle_point),
        mle_eval_k(&writes_ram, cycle_point),
    ]
}

// ---------------------------------------------------------------------------
// ShoutCoreOracle
// ---------------------------------------------------------------------------

/// Sumcheck oracle for Shout core identity: sum_k ra(k, r_cycle) * table(k) = rv(r_cycle).
///
/// After binding r_cycle, both `ra_at_r` and `table` are 1D vectors of length `table_size`.
/// The sumcheck runs over `addr_bits` rounds, folding both vectors in tandem.
struct ShoutCoreOracle {
    /// ra polynomial partially evaluated at r_cycle: ra(k, r_cycle) for each k.
    ra_at_r: Vec<K>,
    /// Table MLE values (lifted to K).
    table: Vec<K>,
    /// Number of address bits (rounds).
    addr_bits: usize,
}

impl ShoutCoreOracle {
    fn new(ra_at_r: Vec<K>, table_f: &[F], addr_bits: usize) -> Self {
        debug_assert_eq!(ra_at_r.len(), 1 << addr_bits);
        debug_assert_eq!(table_f.len(), 1 << addr_bits);
        let table: Vec<K> = table_f.iter().map(|&v| K::from(v)).collect();
        Self {
            ra_at_r,
            table,
            addr_bits,
        }
    }
}

impl RoundOracle for ShoutCoreOracle {
    fn num_rounds(&self) -> usize {
        self.addr_bits
    }

    fn degree_bound(&self) -> usize {
        2 // product of two linear terms
    }

    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let half = self.ra_at_r.len() / 2;
        points
            .iter()
            .map(|&x| {
                let one_minus_x = K::ONE - x;
                let mut acc = K::ZERO;
                for k in 0..half {
                    let ra_lo = self.ra_at_r[k];
                    let ra_hi = self.ra_at_r[half + k];
                    let t_lo = self.table[k];
                    let t_hi = self.table[half + k];
                    let ra_x = ra_lo * one_minus_x + ra_hi * x;
                    let t_x = t_lo * one_minus_x + t_hi * x;
                    acc += ra_x * t_x;
                }
                acc
            })
            .collect()
    }

    fn fold(&mut self, r: K) {
        let half = self.ra_at_r.len() / 2;
        let one_minus_r = K::ONE - r;
        for k in 0..half {
            self.ra_at_r[k] = self.ra_at_r[k] * one_minus_r + self.ra_at_r[half + k] * r;
            self.table[k] = self.table[k] * one_minus_r + self.table[half + k] * r;
        }
        self.ra_at_r.truncate(half);
        self.table.truncate(half);
    }
}

// ---------------------------------------------------------------------------
// BooleanityOracle: sum_{k,j} ra(k,j) * (ra(k,j) - 1) = 0
// ---------------------------------------------------------------------------

/// Sumcheck oracle for booleanity: sum over all (addr, cycle) of ra * (ra - 1) = 0.
///
/// The polynomial is degree 2 in each variable. We fold the combined (addr || cycle)
/// dimension jointly over `addr_bits + cycle_bits` rounds.
struct BooleanityOracle {
    /// Flat one-hot witness (may contain intermediate folded values).
    vals: Vec<K>,
    total_bits: usize,
}

impl BooleanityOracle {
    fn new(onehot: &[F], total_bits: usize) -> Self {
        debug_assert_eq!(onehot.len(), 1 << total_bits);
        let vals: Vec<K> = onehot.iter().map(|&v| K::from(v)).collect();
        Self { vals, total_bits }
    }
}

impl RoundOracle for BooleanityOracle {
    fn num_rounds(&self) -> usize {
        self.total_bits
    }

    fn degree_bound(&self) -> usize {
        2 // ra * (ra - 1) is degree 2
    }

    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let half = self.vals.len() / 2;
        points
            .iter()
            .map(|&x| {
                let one_minus_x = K::ONE - x;
                let mut acc = K::ZERO;
                for i in 0..half {
                    let lo = self.vals[i];
                    let hi = self.vals[half + i];
                    let v = lo * one_minus_x + hi * x;
                    acc += v * (v - K::ONE);
                }
                acc
            })
            .collect()
    }

    fn fold(&mut self, r: K) {
        let half = self.vals.len() / 2;
        let one_minus_r = K::ONE - r;
        for i in 0..half {
            self.vals[i] = self.vals[i] * one_minus_r + self.vals[half + i] * r;
        }
        self.vals.truncate(half);
    }
}

// ---------------------------------------------------------------------------
// HammingWeightOracle: sum_k ra(k, r_cycle) = 1
// ---------------------------------------------------------------------------

/// Sumcheck oracle for Hamming-weight-1: after binding cycle to r_cycle,
/// prove sum_k ra(k, r_cycle) = 1.
struct HammingWeightOracle {
    /// ra(k, r_cycle) for each k.
    ra_at_r: Vec<K>,
    addr_bits: usize,
}

impl RoundOracle for HammingWeightOracle {
    fn num_rounds(&self) -> usize {
        self.addr_bits
    }

    fn degree_bound(&self) -> usize {
        1 // linear in each variable
    }

    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let half = self.ra_at_r.len() / 2;
        points
            .iter()
            .map(|&x| {
                let one_minus_x = K::ONE - x;
                let mut acc = K::ZERO;
                for k in 0..half {
                    acc += self.ra_at_r[k] * one_minus_x + self.ra_at_r[half + k] * x;
                }
                acc
            })
            .collect()
    }

    fn fold(&mut self, r: K) {
        let half = self.ra_at_r.len() / 2;
        let one_minus_r = K::ONE - r;
        for k in 0..half {
            self.ra_at_r[k] = self.ra_at_r[k] * one_minus_r + self.ra_at_r[half + k] * r;
        }
        self.ra_at_r.truncate(half);
    }
}

// ---------------------------------------------------------------------------
// DecodeConsistencyOracle: sum_k ra(k, r_cycle) * k = expected_addr(r_cycle)
// ---------------------------------------------------------------------------

/// Sumcheck oracle for address decode consistency.
///
/// After binding cycle to r_cycle, proves:
///   sum_k ra(k, r_cycle) * index_poly(k) = expected_addr(r_cycle)
/// where index_poly(k) = k (the identity polynomial over the address domain).
struct DecodeConsistencyOracle {
    /// ra(k, r_cycle) for each k.
    ra_at_r: Vec<K>,
    /// Identity polynomial: index_poly[k] = K::from(k).
    index_poly: Vec<K>,
    addr_bits: usize,
}

impl DecodeConsistencyOracle {
    fn new(ra_at_r: Vec<K>, addr_bits: usize) -> Self {
        let table_size = ra_at_r.len();
        let index_poly: Vec<K> = (0..table_size)
            .map(|k| K::from(F::from_u64(k as u64)))
            .collect();
        Self {
            ra_at_r,
            index_poly,
            addr_bits,
        }
    }
}

impl RoundOracle for DecodeConsistencyOracle {
    fn num_rounds(&self) -> usize {
        self.addr_bits
    }

    fn degree_bound(&self) -> usize {
        2 // product of two linear terms
    }

    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let half = self.ra_at_r.len() / 2;
        points
            .iter()
            .map(|&x| {
                let one_minus_x = K::ONE - x;
                let mut acc = K::ZERO;
                for k in 0..half {
                    let ra_lo = self.ra_at_r[k];
                    let ra_hi = self.ra_at_r[half + k];
                    let idx_lo = self.index_poly[k];
                    let idx_hi = self.index_poly[half + k];
                    let ra_x = ra_lo * one_minus_x + ra_hi * x;
                    let idx_x = idx_lo * one_minus_x + idx_hi * x;
                    acc += ra_x * idx_x;
                }
                acc
            })
            .collect()
    }

    fn fold(&mut self, r: K) {
        let half = self.ra_at_r.len() / 2;
        let one_minus_r = K::ONE - r;
        for k in 0..half {
            self.ra_at_r[k] = self.ra_at_r[k] * one_minus_r + self.ra_at_r[half + k] * r;
            self.index_poly[k] = self.index_poly[k] * one_minus_r + self.index_poly[half + k] * r;
        }
        self.ra_at_r.truncate(half);
        self.index_poly.truncate(half);
    }
}

// ---------------------------------------------------------------------------
// Transcript helpers
// ---------------------------------------------------------------------------

/// Sample a K challenge from the transcript (two base-field challenges combined).
fn sample_challenge<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}

/// Sample a vector of K challenges from the transcript.
fn sample_challenge_vec<Tr: Transcript>(tr: &mut Tr, label: &'static [u8], n: usize) -> Vec<K> {
    (0..n).map(|_| sample_challenge(tr, label)).collect()
}

// ---------------------------------------------------------------------------
// Per-channel prover
// ---------------------------------------------------------------------------

/// Prove a single Shout channel: core lookup + address correctness.
///
/// The core sumcheck proves `rv(r_cycle) = sum_k ra(k, r_cycle) * table(k)`.
/// Address correctness proves booleanity, Hamming-weight-1, and decode consistency.
fn prove_shout_channel<Tr: Transcript>(
    onehot: &[F],
    table: &[F],
    read_values: &[F],
    expected_addrs: &[F],
    addr_bits: usize,
    cycle_point: &[K],
    transcript: &mut Tr,
) -> Result<ShoutChannelProof, String> {
    let cycle_bits = cycle_point.len();
    let table_size = 1usize << addr_bits;
    let trace_len = 1usize << cycle_bits;
    debug_assert_eq!(onehot.len(), table_size * trace_len);
    debug_assert_eq!(table.len(), table_size);
    debug_assert_eq!(read_values.len(), trace_len);
    debug_assert_eq!(expected_addrs.len(), trace_len);

    // 1. Compute rv(r_cycle) = MLE of read_values at the shared stage point.
    let rv_at_r = mle_eval_k(read_values, cycle_point);

    // 2. Partially evaluate onehot at r_cycle -> ra_at_r[k] for each k.
    let ra_at_r = partial_eval_at_cycle(onehot, table_size, trace_len, cycle_point);

    // 3. Core sumcheck: sum_k ra_at_r[k] * table[k] = rv_at_r.
    let mut core_oracle = ShoutCoreOracle::new(ra_at_r.clone(), table, addr_bits);
    let (core_rounds, addr_point) =
        run_sumcheck_prover(transcript, &mut core_oracle, rv_at_r).map_err(|e| format!("core sumcheck: {e}"))?;

    // 4. Address correctness sub-proofs.
    let mut addr_rounds = Vec::new();

    // 4a. Booleanity: sum_{k,j} ra(k,j) * (ra(k,j) - 1) = 0
    let total_bits = addr_bits + cycle_bits;
    let mut bool_oracle = BooleanityOracle::new(onehot, total_bits);
    let (bool_rounds, _) =
        run_sumcheck_prover(transcript, &mut bool_oracle, K::ZERO).map_err(|e| format!("booleanity: {e}"))?;
    addr_rounds.extend(bool_rounds);

    // 4b. Hamming-weight-1: sum_k ra(k, r_cycle) = 1
    let mut hw_oracle = HammingWeightOracle {
        ra_at_r: ra_at_r.clone(),
        addr_bits,
    };
    let (hw_rounds, _) =
        run_sumcheck_prover(transcript, &mut hw_oracle, K::ONE).map_err(|e| format!("hamming weight: {e}"))?;
    addr_rounds.extend(hw_rounds);

    // 4c. Decode consistency: sum_k ra(k, r_cycle) * k = expected_addr(r_cycle)
    let expected_at_r = mle_eval_k(expected_addrs, cycle_point);
    let mut dc_oracle = DecodeConsistencyOracle::new(ra_at_r, addr_bits);
    let (dc_rounds, _) = run_sumcheck_prover(transcript, &mut dc_oracle, expected_at_r)
        .map_err(|e| format!("decode consistency: {e}"))?;
    addr_rounds.extend(dc_rounds);

    Ok(ShoutChannelProof {
        addr_point,
        sumcheck_rounds: core_rounds,
        addr_correctness_rounds: addr_rounds,
        address_opening_value: K::ZERO,
        read_values_at_cycle: vec![rv_at_r],
        table_opening_values: Vec::new(),
    })
}

// ---------------------------------------------------------------------------
// ALU mixed table builder
// ---------------------------------------------------------------------------

/// Build the full 2^18 ALU mixed table from the 2^16 Add8Lo subtable.
///
/// The ALU key is `(kind << 16) | (lhs << 8) | rhs` (18 bits).
/// kind 0 (NoLookup): output = 0
/// kind 1 (Identity): output = lhs
/// kind 2 (Equal8):   output = (lhs == rhs) ? 1 : 0
/// kind 3 (Add8Lo):   output = (lhs + rhs) mod 256
fn build_alu_mixed_table(alu_add8lo: &[F]) -> Vec<F> {
    debug_assert_eq!(alu_add8lo.len(), 1 << 16);
    let size = 1usize << 18;
    let mut table = vec![F::ZERO; size];

    for lhs in 0u64..256 {
        for rhs in 0u64..256 {
            let base = (lhs << 8) | rhs;
            // kind 0: NoLookup -> 0 (already zero)
            // kind 1: Identity -> lhs
            table[(1u64 << 16 | base) as usize] = F::from_u64(lhs);
            // kind 2: Equal8 -> (lhs == rhs) ? 1 : 0
            table[(2u64 << 16 | base) as usize] = if lhs == rhs { F::ONE } else { F::ZERO };
            // kind 3: Add8Lo -> from subtable
            table[(3u64 << 16 | base) as usize] = alu_add8lo[(lhs * 256 + rhs) as usize];
        }
    }
    table
}

// ---------------------------------------------------------------------------
// K-valued ShoutCoreOracle for batched decode
// ---------------------------------------------------------------------------

/// Variant of ShoutCoreOracle where the table is already in K (for batched decode).
struct ShoutCoreOracleK {
    ra_at_r: Vec<K>,
    table: Vec<K>,
    addr_bits: usize,
}

impl RoundOracle for ShoutCoreOracleK {
    fn num_rounds(&self) -> usize {
        self.addr_bits
    }

    fn degree_bound(&self) -> usize {
        2
    }

    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let half = self.ra_at_r.len() / 2;
        points
            .iter()
            .map(|&x| {
                let one_minus_x = K::ONE - x;
                let mut acc = K::ZERO;
                for k in 0..half {
                    let ra_lo = self.ra_at_r[k];
                    let ra_hi = self.ra_at_r[half + k];
                    let t_lo = self.table[k];
                    let t_hi = self.table[half + k];
                    let ra_x = ra_lo * one_minus_x + ra_hi * x;
                    let t_x = t_lo * one_minus_x + t_hi * x;
                    acc += ra_x * t_x;
                }
                acc
            })
            .collect()
    }

    fn fold(&mut self, r: K) {
        let half = self.ra_at_r.len() / 2;
        let one_minus_r = K::ONE - r;
        for k in 0..half {
            self.ra_at_r[k] = self.ra_at_r[k] * one_minus_r + self.ra_at_r[half + k] * r;
            self.table[k] = self.table[k] * one_minus_r + self.table[half + k] * r;
        }
        self.ra_at_r.truncate(half);
        self.table.truncate(half);
    }
}

// ---------------------------------------------------------------------------
// Decode channel prover (batched multi-output)
// ---------------------------------------------------------------------------

/// Prove the decode channel with 22 output columns batched via random challenge.
fn prove_decode_channel<Tr: Transcript>(
    onehot: &[F],
    decode_cols: &[Vec<F>],
    read_values_per_col: &[Vec<F>],
    expected_addrs: &[F],
    addr_bits: usize,
    cycle_point: &[K],
    transcript: &mut Tr,
) -> Result<ShoutChannelProof, String> {
    let cycle_bits = cycle_point.len();
    let table_size = 1usize << addr_bits;
    let trace_len = 1usize << cycle_bits;
    debug_assert_eq!(onehot.len(), table_size * trace_len);
    debug_assert_eq!(decode_cols.len(), DECODE_TABLE_COLUMNS);

    // 1. Sample batching challenge alpha.
    let alpha = sample_challenge(transcript, b"shout/decode_alpha");

    // 2. Build batched table in K.
    let n = decode_cols[0].len();
    let mut batched_table = vec![K::ZERO; n];
    let mut alpha_pow = K::ONE;
    for col in decode_cols {
        for (i, &val) in col.iter().enumerate() {
            batched_table[i] += alpha_pow * K::from(val);
        }
        alpha_pow *= alpha;
    }

    // 3. Build batched read values: rv_batched[j] = sum_col alpha^col * rv_col[j]
    let mut rv_batched = vec![K::ZERO; trace_len];
    let mut alpha_pow = K::ONE;
    for col_rv in read_values_per_col {
        for (j, &val) in col_rv.iter().enumerate() {
            rv_batched[j] += alpha_pow * K::from(val);
        }
        alpha_pow *= alpha;
    }

    // 4. Compute rv_batched(r_cycle) at the shared stage point.
    let chi_cycle = build_chi_table(cycle_point);
    let mut rv_at_r = K::ZERO;
    for (j, &chi_j) in chi_cycle.iter().enumerate() {
        rv_at_r += rv_batched[j] * chi_j;
    }

    // 5. Partially evaluate onehot at r_cycle.
    let ra_at_r = partial_eval_at_cycle(onehot, table_size, trace_len, cycle_point);

    // 6. Core sumcheck with K-valued table.
    let mut core_oracle = ShoutCoreOracleK {
        ra_at_r: ra_at_r.clone(),
        table: batched_table,
        addr_bits,
    };
    let (core_rounds, addr_point) =
        run_sumcheck_prover(transcript, &mut core_oracle, rv_at_r).map_err(|e| format!("decode core: {e}"))?;

    // 7. Address correctness (same structure as other channels).
    let mut addr_rounds = Vec::new();

    let total_bits = addr_bits + cycle_bits;
    let mut bool_oracle = BooleanityOracle::new(onehot, total_bits);
    let (bool_rounds, _) =
        run_sumcheck_prover(transcript, &mut bool_oracle, K::ZERO).map_err(|e| format!("decode booleanity: {e}"))?;
    addr_rounds.extend(bool_rounds);

    let mut hw_oracle = HammingWeightOracle {
        ra_at_r: ra_at_r.clone(),
        addr_bits,
    };
    let (hw_rounds, _) =
        run_sumcheck_prover(transcript, &mut hw_oracle, K::ONE).map_err(|e| format!("decode hamming weight: {e}"))?;
    addr_rounds.extend(hw_rounds);

    let expected_at_r = mle_eval_k(expected_addrs, cycle_point);
    let mut dc_oracle = DecodeConsistencyOracle::new(ra_at_r, addr_bits);
    let (dc_rounds, _) = run_sumcheck_prover(transcript, &mut dc_oracle, expected_at_r)
        .map_err(|e| format!("decode consistency: {e}"))?;
    addr_rounds.extend(dc_rounds);

    Ok(ShoutChannelProof {
        addr_point,
        sumcheck_rounds: core_rounds,
        addr_correctness_rounds: addr_rounds,
        address_opening_value: K::ZERO,
        read_values_at_cycle: mle_eval_many_k(read_values_per_col, cycle_point),
        table_opening_values: Vec::new(),
    })
}

// ---------------------------------------------------------------------------
// Stage 1 entry point
// ---------------------------------------------------------------------------

/// Prove Stage 1: four Shout read-only lookup channels.
///
/// Builds one-hot witnesses from `aux`, constructs read-value arrays, and runs
/// the Shout prover for fetch, decode, ALU, and Eq4 channels.
pub fn prove_stage1<Tr: Transcript>(
    trace_rows: &[[F; 24]],
    aux: &[KernelStepAux],
    rom_table: &[F],
    decode_table: &[Vec<F>],
    alu_table: &[F],
    eq4_table: &[F],
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<Stage1ShoutProof, String> {
    let trace_len = 1usize << cycle_bits;
    if aux.len() != trace_len {
        return Err(format!("aux length {} != expected trace_len {}", aux.len(), trace_len));
    }

    // Domain sizes
    let rom_size = rom_table.len(); // 2^11 = 2048
    let rom_addr_bits = ROM_ADDR_BITS; // 11
    let decode_size = decode_table[0].len(); // 2^16 = 65536
    let decode_addr_bits = 16usize;
    let alu_addr_bits = 18usize; // 2^18 ALU mixed table
    let eq4_size = eq4_table.len(); // 2^8 = 256
    let eq4_addr_bits = 8usize;

    debug_assert_eq!(rom_size, 1 << rom_addr_bits);
    debug_assert_eq!(decode_size, 1 << decode_addr_bits);
    debug_assert_eq!(eq4_size, 1 << eq4_addr_bits);

    // -- Build address arrays per channel --
    let fetch_addrs: Vec<usize> = aux.iter().map(|a| a.fetch_addr).collect();
    let decode_addrs: Vec<usize> = aux.iter().map(|a| a.decode_addr as usize).collect();
    let alu_addrs: Vec<usize> = aux.iter().map(|a| a.alu_key as usize).collect();
    let eq4_addrs: Vec<usize> = aux.iter().map(|a| a.eq4_key as usize).collect();

    let cycle_point = sample_challenge_vec(transcript, b"stage1/r_lookup", cycle_bits);

    // -- Build one-hot witnesses --
    let fetch_onehot = build_onehot_witness(trace_len, rom_size, &fetch_addrs);
    let decode_onehot = build_onehot_witness(trace_len, decode_size, &decode_addrs);
    let alu_mixed_table = build_alu_mixed_table(alu_table);
    let alu_onehot = build_onehot_witness(trace_len, 1 << alu_addr_bits, &alu_addrs);
    let eq4_onehot = build_onehot_witness(trace_len, eq4_size, &eq4_addrs);

    // -- Build read-value arrays --

    // Fetch: rv[j] = rom_table[fetch_addr[j]] (the opcode word)
    let fetch_rv: Vec<F> = aux.iter().map(|a| rom_table[a.fetch_addr]).collect();

    // Fetch expected addresses (as field elements)
    let fetch_expected: Vec<F> = aux
        .iter()
        .map(|a| F::from_u64(a.fetch_addr as u64))
        .collect();

    // Decode: 22 read-value columns, rv_col[col][j] = decode_table[col][decode_addr[j]]
    let decode_rv_per_col: Vec<Vec<F>> = (0..DECODE_TABLE_COLUMNS)
        .map(|col| {
            aux.iter()
                .map(|a| decode_table[col][a.decode_addr as usize])
                .collect()
        })
        .collect();

    // Decode expected addresses
    let decode_expected: Vec<F> = aux
        .iter()
        .map(|a| F::from_u64(a.decode_addr as u64))
        .collect();

    // ALU: rv[j] = alu_mixed_table[alu_key[j]]
    let alu_rv: Vec<F> = aux
        .iter()
        .map(|a| alu_mixed_table[a.alu_key as usize])
        .collect();
    let alu_expected: Vec<F> = aux.iter().map(|a| F::from_u64(a.alu_key as u64)).collect();

    // Eq4: rv[j] = eq4_table[eq4_key[j]]
    let eq4_rv: Vec<F> = aux.iter().map(|a| eq4_table[a.eq4_key as usize]).collect();
    let eq4_expected: Vec<F> = aux.iter().map(|a| F::from_u64(a.eq4_key as u64)).collect();

    // -- Prove each channel --

    // Fetch channel
    let mut fetch_proof = prove_shout_channel(
        &fetch_onehot,
        rom_table,
        &fetch_rv,
        &fetch_expected,
        rom_addr_bits,
        &cycle_point,
        transcript,
    )
    .map_err(|e| format!("fetch: {e}"))?;
    fetch_proof.address_opening_value = open_onehot_at_point_be(&fetch_addrs, &fetch_proof.addr_point, &cycle_point);
    fetch_proof.table_opening_values = vec![mle_eval_k_be(rom_table, &fetch_proof.addr_point)];

    // Decode channel (batched multi-output)
    let mut decode_proof = prove_decode_channel(
        &decode_onehot,
        decode_table,
        &decode_rv_per_col,
        &decode_expected,
        decode_addr_bits,
        &cycle_point,
        transcript,
    )
    .map_err(|e| format!("decode: {e}"))?;
    decode_proof.address_opening_value = open_onehot_at_point_be(&decode_addrs, &decode_proof.addr_point, &cycle_point);
    decode_proof.table_opening_values = mle_eval_many_k_be(decode_table, &decode_proof.addr_point);

    // ALU channel
    let mut alu_proof = prove_shout_channel(
        &alu_onehot,
        &alu_mixed_table,
        &alu_rv,
        &alu_expected,
        alu_addr_bits,
        &cycle_point,
        transcript,
    )
    .map_err(|e| format!("alu: {e}"))?;
    alu_proof.address_opening_value = open_onehot_at_point_be(&alu_addrs, &alu_proof.addr_point, &cycle_point);
    alu_proof.table_opening_values = vec![mle_eval_k_be(alu_table, &alu_proof.addr_point[2..])];

    // Eq4 channel
    let mut eq4_proof = prove_shout_channel(
        &eq4_onehot,
        eq4_table,
        &eq4_rv,
        &eq4_expected,
        eq4_addr_bits,
        &cycle_point,
        transcript,
    )
    .map_err(|e| format!("eq4: {e}"))?;
    eq4_proof.address_opening_value = open_onehot_at_point_be(&eq4_addrs, &eq4_proof.addr_point, &cycle_point);
    eq4_proof.table_opening_values = vec![mle_eval_k_be(eq4_table, &eq4_proof.addr_point)];

    let decode_handoff_values = handoff_values_at_cycle(aux, &cycle_point);
    let lane_values_at_lookup = lane_values_at_cycle(trace_rows, &cycle_point);
    let gamma_lookup_link = sample_challenge(transcript, b"stage1/gamma_lookup_link");

    let decode = &decode_proof.read_values_at_cycle;
    if decode[0] != K::ONE {
        return Err("stage1 linkage: decode valid column must equal 1 at r_lookup".into());
    }

    let is_memop = lane_values_at_lookup[13];
    let burst_last = lane_values_at_lookup[16];
    let x_idx = lane_values_at_lookup[14];
    let y_idx = lane_values_at_lookup[15];
    let uses_y_dec = decode[17];
    let burst_eq = eq4_proof.read_values_at_cycle[0];
    let alu_output = alu_proof.read_values_at_cycle[0];
    let linkage_terms = [
        lane_values_at_lookup[1] - decode[3],
        lane_values_at_lookup[2] - decode[4],
        lane_values_at_lookup[3] - decode[5],
        lane_values_at_lookup[7] - decode[6],
        lane_values_at_lookup[8] - decode[7],
        lane_values_at_lookup[9] - decode[8],
        lane_values_at_lookup[10] - decode[9],
        lane_values_at_lookup[11] - decode[10],
        lane_values_at_lookup[12] - decode[11],
        lane_values_at_lookup[13] - decode[12],
        lane_values_at_lookup[6] - alu_output,
        burst_last - is_memop * burst_eq,
        (K::ONE - is_memop) * (x_idx - decode[1]),
        uses_y_dec * (y_idx - decode[2]) + (K::ONE - uses_y_dec) * y_idx,
        decode_handoff_values[0] - decode[17],
        decode_handoff_values[1] - decode[15],
        decode_handoff_values[2] - decode[16],
    ];

    let mut batched_linkage = K::ZERO;
    let mut gamma_power = K::ONE;
    for term in linkage_terms {
        batched_linkage += gamma_power * term;
        gamma_power *= gamma_lookup_link;
    }
    if batched_linkage != K::ZERO {
        return Err("stage1 linkage batch failed at r_lookup".into());
    }

    Ok(Stage1ShoutProof {
        cycle_point,
        fetch_proof,
        decode_proof,
        alu_proof,
        eq4_proof,
        decode_handoff_values,
        lane_values_at_lookup,
    })
}

// ---------------------------------------------------------------------------
// Verifier stub
// ---------------------------------------------------------------------------

/// Verify Stage 1 Shout proofs. Fail closed until the verifier lands.
pub fn verify_stage1<Tr: Transcript>(
    proof: &Stage1ShoutProof,
    rom_table: &[F],
    decode_table: &[Vec<F>],
    alu_table: &[F],
    eq4_table: &[F],
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<(), String> {
    let expected_cycle_point = sample_challenge_vec(transcript, b"stage1/r_lookup", cycle_bits);
    if proof.cycle_point != expected_cycle_point {
        return Err("stage1 cycle point mismatch".into());
    }

    verify_stage1_channel_transcript(
        transcript,
        &proof.fetch_proof,
        *proof
            .fetch_proof
            .read_values_at_cycle
            .first()
            .ok_or_else(|| "stage1 fetch read value missing".to_string())?,
        ROM_ADDR_BITS,
        cycle_bits,
        "stage1 fetch",
    )
    .map_err(|err| err.to_string())?;

    let decode_alpha = sample_challenge(transcript, b"shout/decode_alpha");
    verify_stage1_channel_transcript(
        transcript,
        &proof.decode_proof,
        batch_values(&proof.decode_proof.read_values_at_cycle, decode_alpha),
        16,
        cycle_bits,
        "stage1 decode",
    )
    .map_err(|err| err.to_string())?;

    verify_stage1_channel_transcript(
        transcript,
        &proof.alu_proof,
        *proof
            .alu_proof
            .read_values_at_cycle
            .first()
            .ok_or_else(|| "stage1 ALU read value missing".to_string())?,
        18,
        cycle_bits,
        "stage1 alu",
    )
    .map_err(|err| err.to_string())?;

    verify_stage1_channel_transcript(
        transcript,
        &proof.eq4_proof,
        *proof
            .eq4_proof
            .read_values_at_cycle
            .first()
            .ok_or_else(|| "stage1 Eq4 read value missing".to_string())?,
        8,
        cycle_bits,
        "stage1 eq4",
    )
    .map_err(|err| err.to_string())?;

    if proof.decode_handoff_values.len() != 3 || proof.lane_values_at_lookup.len() != 17 {
        return Err("stage1 opening surface has the wrong shape".into());
    }
    if proof.fetch_proof.table_opening_values != vec![mle_eval_k_be(rom_table, &proof.fetch_proof.addr_point)] {
        return Err("stage1 ROM table opening mismatch".into());
    }
    if proof.decode_proof.table_opening_values != mle_eval_many_k_be(decode_table, &proof.decode_proof.addr_point) {
        return Err("stage1 decode table opening mismatch".into());
    }
    if proof.alu_proof.table_opening_values != vec![mle_eval_k_be(alu_table, &proof.alu_proof.addr_point[2..])] {
        return Err("stage1 ALU table opening mismatch".into());
    }
    if proof.eq4_proof.table_opening_values != vec![mle_eval_k_be(eq4_table, &proof.eq4_proof.addr_point)] {
        return Err("stage1 Eq4 table opening mismatch".into());
    }
    if proof.decode_proof.read_values_at_cycle.len() <= 17 {
        return Err("stage1 decode proof is missing required output columns".into());
    }
    if proof.decode_proof.read_values_at_cycle[0] != K::ONE {
        return Err("stage1 decode valid column must equal 1 at r_lookup".into());
    }

    let gamma_lookup_link = sample_challenge(transcript, b"stage1/gamma_lookup_link");
    let decode = &proof.decode_proof.read_values_at_cycle;
    let lane = &proof.lane_values_at_lookup;
    let handoff = &proof.decode_handoff_values;
    let linkage_terms = [
        lane[1] - decode[3],
        lane[2] - decode[4],
        lane[3] - decode[5],
        lane[7] - decode[6],
        lane[8] - decode[7],
        lane[9] - decode[8],
        lane[10] - decode[9],
        lane[11] - decode[10],
        lane[12] - decode[11],
        lane[13] - decode[12],
        lane[6] - proof.alu_proof.read_values_at_cycle[0],
        lane[16] - lane[13] * proof.eq4_proof.read_values_at_cycle[0],
        (K::ONE - lane[13]) * (lane[14] - decode[1]),
        decode[17] * (lane[15] - decode[2]) + (K::ONE - decode[17]) * lane[15],
        handoff[0] - decode[17],
        handoff[1] - decode[15],
        handoff[2] - decode[16],
    ];
    if batch_values(&linkage_terms, gamma_lookup_link) != K::ZERO {
        return Err("stage1 linkage batch failed at r_lookup".into());
    }

    Ok(())
}

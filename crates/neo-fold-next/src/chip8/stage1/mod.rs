//! Stage 1: Shout read-only lookup proofs for fetch, decode, ALU, and Eq4 channels.
//!
//! Owns: per-channel one-hot witness construction, ShoutCoreOracle (sumcheck over
//! address dimension), address-correctness sub-proofs (booleanity, Hamming-weight-1,
//! decode-consistency). Does not own table construction (see `tables.rs`).

mod proof;
mod prove;
mod transcript;
mod verify;

use neo_math::{from_complex, F, K};
use neo_reductions::sumcheck::RoundOracle;
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use super::kernel::KernelStepAux;
use super::poly::{build_eq_table, mle_eval_f_be, mle_eval_f_le};
use super::tables::DECODE_TABLE_COLUMNS;
pub use proof::{ShoutChannelProof, Stage1ShoutProof, DECODE_HANDOFF_POLY_IDS, STAGE1_LANE_OPEN_COLS};
pub use prove::{prove_stage1, stage1_alu_expected_claim};
pub use verify::verify_stage1;

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
// MLE partial evaluation helpers
// ---------------------------------------------------------------------------

/// Partially evaluate a 2D MLE `f[addr, cycle]` at `r_cycle`, yielding `f(addr, r_cycle)`
/// as a vector of length `table_size` over K.
///
/// `flat[addr * trace_len + cycle]` is the (addr, cycle) entry.
fn partial_eval_at_cycle(flat: &[F], table_size: usize, trace_len: usize, r_cycle: &[K]) -> Vec<K> {
    let chi_cycle = build_eq_table(r_cycle);
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
    mle_eval_f_le(v, r)
}

fn mle_eval_many_k(cols: &[Vec<F>], point: &[K]) -> Vec<K> {
    let chi = build_eq_table(point);
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
    mle_eval_f_be(v, point_be)
}

fn mle_eval_many_k_be(cols: &[Vec<F>], point_be: &[K]) -> Vec<K> {
    let point_le: Vec<K> = point_be.iter().rev().copied().collect();
    mle_eval_many_k(cols, &point_le)
}

fn stage1_linkage_terms(
    lane_values_at_lookup: &[K],
    decode_values: &[K],
    decode_handoff_values: &[K],
    alu_output: K,
    burst_eq: K,
) -> [K; 17] {
    let lane_kk = lane_values_at_lookup[1];
    let lane_nnn_addr = lane_values_at_lookup[2];
    let lane_nnn_word = lane_values_at_lookup[3];
    let lane_lookup_output = lane_values_at_lookup[6];
    let lane_writes_lookup_to_x = lane_values_at_lookup[7];
    let lane_writes_mem_to_x = lane_values_at_lookup[8];
    let lane_preserves_x = lane_values_at_lookup[9];
    let lane_writes_nnn_to_i = lane_values_at_lookup[10];
    let lane_is_jump = lane_values_at_lookup[11];
    let lane_is_branch = lane_values_at_lookup[12];
    let lane_is_memop = lane_values_at_lookup[13];
    let lane_x_idx = lane_values_at_lookup[14];
    let lane_y_idx = lane_values_at_lookup[15];
    let lane_burst_last = lane_values_at_lookup[16];

    let decode_x = decode_values[1];
    let decode_y = decode_values[2];
    let decode_kk = decode_values[3];
    let decode_nnn_addr = decode_values[4];
    let decode_nnn_word = decode_values[5];
    let decode_writes_lookup_to_x = decode_values[6];
    let decode_writes_mem_to_x = decode_values[7];
    let decode_preserves_x = decode_values[8];
    let decode_writes_nnn_to_i = decode_values[9];
    let decode_is_jump = decode_values[10];
    let decode_is_branch = decode_values[11];
    let decode_is_memop = decode_values[12];
    let decode_reads_ram = decode_values[15];
    let decode_writes_ram = decode_values[16];
    let decode_uses_y = decode_values[17];

    [
        lane_kk - decode_kk,
        lane_nnn_addr - decode_nnn_addr,
        lane_nnn_word - decode_nnn_word,
        lane_writes_lookup_to_x - decode_writes_lookup_to_x,
        lane_writes_mem_to_x - decode_writes_mem_to_x,
        lane_preserves_x - decode_preserves_x,
        lane_writes_nnn_to_i - decode_writes_nnn_to_i,
        lane_is_jump - decode_is_jump,
        lane_is_branch - decode_is_branch,
        lane_is_memop - decode_is_memop,
        lane_lookup_output - alu_output,
        lane_burst_last - lane_is_memop * burst_eq,
        (K::ONE - lane_is_memop) * (lane_x_idx - decode_x),
        decode_uses_y * (lane_y_idx - decode_y) + (K::ONE - decode_uses_y) * lane_y_idx,
        decode_handoff_values[0] - decode_uses_y,
        decode_handoff_values[1] - decode_reads_ram,
        decode_handoff_values[2] - decode_writes_ram,
    ]
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

fn stage1_fetch_claim(lane_values_at_lookup: &[K]) -> K {
    lane_values_at_lookup[0]
}

fn stage1_decode_claim(fetch_opcode_at_lookup: K) -> K {
    fetch_opcode_at_lookup
}

fn stage1_eq4_claim(lane_values_at_lookup: &[K], decode_values: &[K]) -> K {
    let sixteen = K::from(F::from_u64(16));
    sixteen * lane_values_at_lookup[14] + decode_values[21]
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

fn sample_challenge<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}

fn sample_challenge_vec<Tr: Transcript>(tr: &mut Tr, label: &'static [u8], n: usize) -> Vec<K> {
    (0..n).map(|_| sample_challenge(tr, label)).collect()
}

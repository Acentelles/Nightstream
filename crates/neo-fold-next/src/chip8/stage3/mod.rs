//! Stage 3: Continuity support relation and bridge binding.
//!
//! Owns: LaneShift reduction, ContinuityCheck, start-boundary rule,
//! and row-binding claims for the bridge into the SuperNeo root prover.

mod proof;
mod prove;
mod verify;

use neo_math::{from_complex, F, K};
use neo_reductions::sumcheck::RoundOracle;
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use super::kernel::SimpleKernelError;
use super::poly::{build_eq_table, mle_eval_f_le};
use super::spec::{build_pad_row, COL_IS_MEMOP, COL_PC, COL_X_IDX, WITNESS_WIDTH};
pub use proof::{
    LaneShiftProof, RowBindingClaim, Stage3Proof, STAGE3_FINAL_BOUNDARY_COLS, STAGE3_SHIFT_OPEN_COLS,
    STAGE3_START_BOUNDARY_COLS,
};
pub use prove::prove_stage3;
pub use verify::verify_stage3;

/// Squeeze a K challenge from the transcript.
fn squeeze_k<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}

/// Squeeze a vector of K challenges from the transcript.
fn squeeze_point<Tr: Transcript>(tr: &mut Tr, label: &'static [u8], n: usize) -> Vec<K> {
    (0..n).map(|_| squeeze_k(tr, label)).collect()
}

fn mle_eval_fk(v: &[F], r: &[K]) -> K {
    mle_eval_f_le(v, r)
}

/// Sumcheck oracle for the batched LaneShift reduction.
///
/// Proves: claimed = sum_{j=0}^{T-1} eq(r, j) * shifted_col(j)
/// where shifted_col(j) is the batched next-row value and shifted_col(T-1) = 0.
struct LaneShiftOracle {
    eq: Vec<K>,
    shifted_col: Vec<K>,
    rounds_remaining: usize,
}

impl RoundOracle for LaneShiftOracle {
    fn num_rounds(&self) -> usize {
        self.rounds_remaining
    }

    fn degree_bound(&self) -> usize {
        2
    }

    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let half = self.eq.len() / 2;
        points
            .iter()
            .map(|&x| {
                let one_minus_x = K::ONE - x;
                let mut acc = K::ZERO;
                for k in 0..half {
                    let eq_lo = self.eq[k];
                    let eq_hi = self.eq[half + k];
                    let c_lo = self.shifted_col[k];
                    let c_hi = self.shifted_col[half + k];
                    let eq_x = eq_lo * one_minus_x + eq_hi * x;
                    let c_x = c_lo * one_minus_x + c_hi * x;
                    acc += eq_x * c_x;
                }
                acc
            })
            .collect()
    }

    fn fold(&mut self, r: K) {
        let half = self.eq.len() / 2;
        let one_minus_r = K::ONE - r;
        for k in 0..half {
            self.eq[k] = self.eq[k] * one_minus_r + self.eq[half + k] * r;
            self.shifted_col[k] = self.shifted_col[k] * one_minus_r + self.shifted_col[half + k] * r;
        }
        self.eq.truncate(half);
        self.shifted_col.truncate(half);
    }
}

// ---------------------------------------------------------------------------
// PairMask_N evaluator
// ---------------------------------------------------------------------------

/// Evaluate `PairMask_N(X)` at `r`, where `PairMask_N(j) = 1` iff `0 <= j < N-1`.
///
/// Since `PairMask_N` is the indicator of real row pairs, its MLE is
/// `sum_{j=0}^{N-2} eq(X, j)`.
fn eval_pair_mask(r: &[K], active_rows: usize) -> K {
    let eq = build_eq_table(r);
    let mut acc = K::ZERO;
    let last_active = active_rows.saturating_sub(1);
    for j in 0..last_active {
        acc += eq[j];
    }
    acc
}

// ---------------------------------------------------------------------------
// Shift value computation
// ---------------------------------------------------------------------------

/// Compute Shift[col](r) = sum_{j=0}^{T-2} eq(r, j) * col(j+1).
fn compute_shift_value(trace_rows: &[[F; WITNESS_WIDTH]], col_idx: usize, eq: &[K], t: usize) -> K {
    let mut acc = K::ZERO;
    for j in 0..t.saturating_sub(1) {
        acc += eq[j] * K::from(trace_rows[j + 1][col_idx]);
    }
    acc
}

fn excluded_current_tail(trace_rows: &[[F; WITNESS_WIDTH]], col_idx: usize, eq: &[K], active_rows: usize) -> K {
    let mut acc = K::ZERO;
    for j in active_rows.saturating_sub(1)..trace_rows.len() {
        acc += eq[j] * K::from(trace_rows[j][col_idx]);
    }
    acc
}

fn excluded_shift_tail(trace_rows: &[[F; WITNESS_WIDTH]], col_idx: usize, eq: &[K], active_rows: usize) -> K {
    let mut acc = K::ZERO;
    for j in active_rows.saturating_sub(1)..trace_rows.len().saturating_sub(1) {
        acc += eq[j] * K::from(trace_rows[j + 1][col_idx]);
    }
    acc
}

fn build_shifted_batched_col(trace_rows: &[[F; WITNESS_WIDTH]], gamma_shift: K, t: usize) -> Vec<K> {
    let gamma2 = gamma_shift * gamma_shift;
    let mut out = Vec::with_capacity(t);
    for j in 0..t.saturating_sub(1) {
        out.push(
            K::from(trace_rows[j + 1][COL_PC])
                + gamma_shift * K::from(trace_rows[j + 1][COL_X_IDX])
                + gamma2 * K::from(trace_rows[j + 1][COL_IS_MEMOP]),
        );
    }
    if t > 0 {
        out.push(K::ZERO);
    }
    out
}

// ---------------------------------------------------------------------------
// Row-index to little-endian bits
// ---------------------------------------------------------------------------

fn index_to_bits_le(index: usize, num_bits: usize) -> Vec<bool> {
    (0..num_bits).map(|b| (index >> b) & 1 == 1).collect()
}

fn row_index_matches_bits(row_index: usize, row_bits: &[bool]) -> bool {
    row_bits
        .iter()
        .enumerate()
        .all(|(bit, &is_one)| ((row_index >> bit) & 1 == 1) == is_one)
}

fn row_binding_opened_value(row_binding: &RowBindingClaim, col_idx: usize) -> Result<K, SimpleKernelError> {
    row_binding
        .opened_values
        .get(col_idx.saturating_sub(1))
        .copied()
        .ok_or_else(|| {
            SimpleKernelError::ContinuityFailed(format!(
                "row {} missing opened lane value for column {col_idx}",
                row_binding.row_index
            ))
        })
}

fn excluded_current_tail_from_proof(
    proof: &Stage3Proof,
    eq: &[K],
    col_idx: usize,
    active_rows: usize,
    padded_trace_length: usize,
    pad_pc_word: u16,
) -> Result<K, SimpleKernelError> {
    let pad_row = build_pad_row(pad_pc_word);
    let mut acc = K::ZERO;
    let last_semantic = proof.row_bindings.last().ok_or_else(|| {
        SimpleKernelError::ContinuityFailed("stage3 proof must contain at least one row binding".into())
    })?;
    for j in active_rows.saturating_sub(1)..padded_trace_length {
        let value = if j == active_rows - 1 {
            row_binding_opened_value(last_semantic, col_idx)?
        } else {
            K::from(pad_row[col_idx])
        };
        acc += eq[j] * value;
    }
    Ok(acc)
}

fn excluded_shift_tail_from_proof(
    eq: &[K],
    col_idx: usize,
    active_rows: usize,
    padded_trace_length: usize,
    pad_pc_word: u16,
) -> K {
    let pad_row = build_pad_row(pad_pc_word);
    let pad_value = K::from(pad_row[col_idx]);
    let mut acc = K::ZERO;
    for j in active_rows.saturating_sub(1)..padded_trace_length.saturating_sub(1) {
        acc += eq[j] * pad_value;
    }
    acc
}

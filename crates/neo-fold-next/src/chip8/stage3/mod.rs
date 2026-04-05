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
use super::spec::{build_pad_row, COL_BURST_LAST, COL_IS_MEMOP, COL_PC, COL_PC_NEXT, COL_X_IDX, WITNESS_WIDTH};
pub use proof::{
    LaneShiftProof, RowBindingClaim, Stage3Proof, STAGE3_FINAL_BOUNDARY_COLS, STAGE3_SHIFT_OPEN_COLS,
    STAGE3_START_BOUNDARY_COLS,
};
pub use prove::prove_stage3;
pub use verify::verify_stage3;
pub(crate) use verify::verify_stage3_execution;

#[derive(Clone, Debug, PartialEq)]
pub(crate) struct Stage3Challenges {
    pub beta1: K,
    pub beta2: K,
    pub shift_point: Vec<K>,
}

#[derive(Clone, Debug)]
pub(crate) struct Stage3DerivedExecutionSurface {
    pub source_point: Vec<K>,
    pub claimed_shift_values: [K; 3],
    pub shift_opening_values: [K; 5],
    pub continuity_check_value: K,
    pub start_boundary_values: [K; 2],
    pub final_boundary_values: [K; 2],
}

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

pub(crate) fn sample_stage3_challenges<Tr: Transcript>(tr: &mut Tr, cycle_bits: usize) -> Stage3Challenges {
    Stage3Challenges {
        beta1: squeeze_k(tr, b"stage3/beta1"),
        beta2: squeeze_k(tr, b"stage3/beta2"),
        shift_point: squeeze_point(tr, b"stage3/r_shift", cycle_bits),
    }
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

fn row_value_from_bindings(
    row_bindings: &[RowBindingClaim],
    row_index: usize,
    col_idx: usize,
    pad_row: &[F; WITNESS_WIDTH],
) -> Result<K, SimpleKernelError> {
    if let Some(row_binding) = row_bindings.get(row_index) {
        if row_binding.row_index != row_index {
            return Err(SimpleKernelError::ContinuityFailed(format!(
                "stage3 row binding {} has row_index {}, expected {}",
                row_index, row_binding.row_index, row_index
            )));
        }
        return row_binding_opened_value(row_binding, col_idx);
    }
    Ok(K::from(pad_row[col_idx]))
}

fn mle_eval_rows_from_bindings(
    eq: &[K],
    row_bindings: &[RowBindingClaim],
    col_idx: usize,
    padded_trace_length: usize,
    pad_row: &[F; WITNESS_WIDTH],
) -> Result<K, SimpleKernelError> {
    let mut acc = K::ZERO;
    for (row_index, eq_value) in eq.iter().take(padded_trace_length).enumerate() {
        acc += *eq_value * row_value_from_bindings(row_bindings, row_index, col_idx, pad_row)?;
    }
    Ok(acc)
}

fn shifted_eval_rows_from_bindings(
    eq: &[K],
    row_bindings: &[RowBindingClaim],
    col_idx: usize,
    padded_trace_length: usize,
    pad_row: &[F; WITNESS_WIDTH],
) -> Result<K, SimpleKernelError> {
    let mut acc = K::ZERO;
    for (row_index, eq_value) in eq
        .iter()
        .take(padded_trace_length.saturating_sub(1))
        .enumerate()
    {
        acc += *eq_value * row_value_from_bindings(row_bindings, row_index + 1, col_idx, pad_row)?;
    }
    Ok(acc)
}

fn mle_eval_pair_rows_from_bindings(
    eq: &[K],
    row_bindings: &[RowBindingClaim],
    col_idx: usize,
) -> Result<K, SimpleKernelError> {
    let mut acc = K::ZERO;
    for (row_index, row_binding) in row_bindings
        .iter()
        .take(row_bindings.len().saturating_sub(1))
        .enumerate()
    {
        if row_binding.row_index != row_index {
            return Err(SimpleKernelError::ContinuityFailed(format!(
                "stage3 row binding {} has row_index {}, expected {}",
                row_index, row_binding.row_index, row_index
            )));
        }
        acc += eq[row_index] * row_binding_opened_value(row_binding, col_idx)?;
    }
    Ok(acc)
}

fn shifted_eval_active_rows_from_bindings(
    eq: &[K],
    row_bindings: &[RowBindingClaim],
    col_idx: usize,
) -> Result<K, SimpleKernelError> {
    let mut acc = K::ZERO;
    for row_index in 0..row_bindings.len().saturating_sub(1) {
        acc += eq[row_index] * row_binding_opened_value(&row_bindings[row_index + 1], col_idx)?;
    }
    Ok(acc)
}

pub(crate) fn rebuild_stage3_proof_from_execution(
    reduction_rounds: &[Vec<K>],
    row_bindings: &[RowBindingClaim],
    challenges: &Stage3Challenges,
    pad_pc_word: u16,
) -> Result<Stage3Proof, SimpleKernelError> {
    let derived = derive_stage3_execution_surface(row_bindings, challenges, pad_pc_word)?;
    Ok(Stage3Proof {
        shift_proof: LaneShiftProof {
            source_point: derived.source_point,
            claimed_shift_values: derived.claimed_shift_values,
            reduction_rounds: reduction_rounds.to_vec(),
        },
        shift_opening_values: derived.shift_opening_values,
        continuity_check_value: derived.continuity_check_value,
        start_boundary_values: derived.start_boundary_values,
        final_boundary_values: derived.final_boundary_values,
        row_bindings: row_bindings.to_vec(),
    })
}

pub(crate) fn derive_stage3_execution_surface(
    row_bindings: &[RowBindingClaim],
    challenges: &Stage3Challenges,
    pad_pc_word: u16,
) -> Result<Stage3DerivedExecutionSurface, SimpleKernelError> {
    if row_bindings.is_empty() {
        return Err(SimpleKernelError::ContinuityFailed(
            "stage3 relation witness must contain at least one row binding".into(),
        ));
    }
    let padded_trace_length = 1usize << challenges.shift_point.len();
    let pad_row = build_pad_row(pad_pc_word);
    let eq = build_eq_table(&challenges.shift_point);
    let claimed_shift_values = [
        shifted_eval_rows_from_bindings(&eq, row_bindings, COL_PC, padded_trace_length, &pad_row)?,
        shifted_eval_rows_from_bindings(&eq, row_bindings, COL_X_IDX, padded_trace_length, &pad_row)?,
        shifted_eval_rows_from_bindings(&eq, row_bindings, COL_IS_MEMOP, padded_trace_length, &pad_row)?,
    ];
    let shift_opening_values = [
        mle_eval_rows_from_bindings(&eq, row_bindings, COL_PC, padded_trace_length, &pad_row)?,
        mle_eval_rows_from_bindings(&eq, row_bindings, COL_PC_NEXT, padded_trace_length, &pad_row)?,
        mle_eval_rows_from_bindings(&eq, row_bindings, COL_X_IDX, padded_trace_length, &pad_row)?,
        mle_eval_rows_from_bindings(&eq, row_bindings, COL_IS_MEMOP, padded_trace_length, &pad_row)?,
        mle_eval_rows_from_bindings(&eq, row_bindings, COL_BURST_LAST, padded_trace_length, &pad_row)?,
    ];
    let active_shift_pc = shifted_eval_active_rows_from_bindings(&eq, row_bindings, COL_PC)?;
    let active_shift_x_idx = shifted_eval_active_rows_from_bindings(&eq, row_bindings, COL_X_IDX)?;
    let active_shift_is_memop = shifted_eval_active_rows_from_bindings(&eq, row_bindings, COL_IS_MEMOP)?;
    let active_pc_next_at_r = mle_eval_pair_rows_from_bindings(&eq, row_bindings, COL_PC_NEXT)?;
    let active_x_idx_at_r = mle_eval_pair_rows_from_bindings(&eq, row_bindings, COL_X_IDX)?;
    let active_is_memop_at_r = mle_eval_pair_rows_from_bindings(&eq, row_bindings, COL_IS_MEMOP)?;
    let active_burst_last_at_r = mle_eval_pair_rows_from_bindings(&eq, row_bindings, COL_BURST_LAST)?;
    let delta_pc = active_shift_pc - active_pc_next_at_r;
    let delta_burst_step =
        active_is_memop_at_r * (K::ONE - active_burst_last_at_r) * (active_shift_x_idx - active_x_idx_at_r - K::ONE);
    let delta_burst_reset =
        active_shift_is_memop * (K::ONE - active_is_memop_at_r + active_burst_last_at_r) * active_shift_x_idx;
    let continuity_check_value = eval_pair_mask(&challenges.shift_point, row_bindings.len())
        * (delta_pc + challenges.beta1 * delta_burst_step + challenges.beta2 * delta_burst_reset);
    let start_boundary_values = [
        row_binding_opened_value(&row_bindings[0], COL_IS_MEMOP)?,
        row_binding_opened_value(&row_bindings[0], COL_X_IDX)?,
    ];
    let final_boundary_values = [
        row_binding_opened_value(row_bindings.last().expect("nonempty checked"), COL_IS_MEMOP)?,
        row_binding_opened_value(row_bindings.last().expect("nonempty checked"), COL_BURST_LAST)?,
    ];

    Ok(Stage3DerivedExecutionSurface {
        source_point: challenges.shift_point.clone(),
        claimed_shift_values,
        shift_opening_values,
        continuity_check_value,
        start_boundary_values,
        final_boundary_values,
    })
}

fn excluded_current_tail_from_bindings(
    row_bindings: &[RowBindingClaim],
    eq: &[K],
    col_idx: usize,
    active_rows: usize,
    padded_trace_length: usize,
    pad_pc_word: u16,
) -> Result<K, SimpleKernelError> {
    let pad_row = build_pad_row(pad_pc_word);
    let mut acc = K::ZERO;
    let last_semantic = row_bindings.last().ok_or_else(|| {
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

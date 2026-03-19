//! Stage 3: Continuity support relation and bridge binding.
//!
//! Owns: LaneShift reduction, ContinuityCheck, start-boundary rule,
//! and row-binding claims for the bridge into the SuperNeo root prover.

use neo_math::{from_complex, F, K};
use neo_reductions::sumcheck::{run_sumcheck_prover, RoundOracle};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use super::kernel::{
    expect_equal_k, expect_equal_k_slice, verify_sumcheck_known, LaneShiftProof, RowBindingClaim, SimpleKernelError,
    Stage3Proof,
};
use super::spec::{build_pad_row, COL_BURST_LAST, COL_IS_MEMOP, COL_PC, COL_PC_NEXT, COL_X_IDX, WITNESS_WIDTH};

// ---------------------------------------------------------------------------
// MLE helpers (local, mirrors stage1/stage2 pattern)
// ---------------------------------------------------------------------------

/// Build eq(r, .) table over the boolean hypercube {0,1}^ell.
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
    let eq = build_eq_table(r);
    debug_assert_eq!(v.len(), eq.len());
    let mut acc = K::ZERO;
    for (&val, &w) in v.iter().zip(eq.iter()) {
        acc += K::from(val) * w;
    }
    acc
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
// ActivePrev_N evaluator
// ---------------------------------------------------------------------------

/// Evaluate the MLE of the indicator {0 <= j < N-1} at point r in K^{cycle_bits}.
///
/// ActivePrev_N(r) = sum_{j=0}^{N-2} eq(r, j).
fn eval_active_prev(r: &[K], active_rows: usize) -> K {
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

// ---------------------------------------------------------------------------
// Stage 3 prover
// ---------------------------------------------------------------------------

/// Prove Stage 3: LaneShift reduction, continuity check, start-boundary, row-binding.
pub fn prove_stage3<Tr: Transcript>(
    trace_rows: &[[F; WITNESS_WIDTH]],
    active_rows: usize,
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<Stage3Proof, SimpleKernelError> {
    let t = 1usize << cycle_bits;
    if trace_rows.len() != t {
        return Err(SimpleKernelError::ContinuityFailed(format!(
            "trace length {} != expected 2^{cycle_bits} = {t}",
            trace_rows.len()
        )));
    }
    if active_rows == 0 || active_rows > t {
        return Err(SimpleKernelError::ContinuityFailed(format!(
            "active_rows {active_rows} out of range [1, {t}]"
        )));
    }

    // -----------------------------------------------------------------------
    // 1. Sample continuity batching challenges
    // -----------------------------------------------------------------------
    let beta1 = squeeze_k(transcript, b"stage3/beta1");
    let beta2 = squeeze_k(transcript, b"stage3/beta2");

    // -----------------------------------------------------------------------
    // 2. Sample r_shift point
    // -----------------------------------------------------------------------
    let r_shift = squeeze_point(transcript, b"stage3/r_shift", cycle_bits);

    // -----------------------------------------------------------------------
    // 3. Build eqplus1 table and compute per-column shift values
    // -----------------------------------------------------------------------
    let eq = build_eq_table(&r_shift);

    let shift_pc = compute_shift_value(trace_rows, COL_PC, &eq, t);
    let shift_x_idx = compute_shift_value(trace_rows, COL_X_IDX, &eq, t);
    let shift_is_memop = compute_shift_value(trace_rows, COL_IS_MEMOP, &eq, t);

    // -----------------------------------------------------------------------
    // 4. Batch the three columns with gamma_shift and run LaneShift sumcheck
    // -----------------------------------------------------------------------
    let gamma_shift = squeeze_k(transcript, b"stage3/gamma_shift");

    // batched_claim = shift_pc + gamma * shift_x_idx + gamma^2 * shift_is_memop
    let batched_claim = shift_pc + gamma_shift * shift_x_idx + gamma_shift * gamma_shift * shift_is_memop;

    let shifted_col = build_shifted_batched_col(trace_rows, gamma_shift, t);

    let mut oracle = LaneShiftOracle {
        eq: eq.clone(),
        shifted_col,
        rounds_remaining: cycle_bits,
    };

    let (reduction_rounds, _challenges) = run_sumcheck_prover(transcript, &mut oracle, batched_claim)
        .map_err(|e| SimpleKernelError::SumcheckFailed(format!("LaneShift: {e}")))?;

    let shift_proof = LaneShiftProof {
        source_point: r_shift.clone(),
        claimed_shift_values: [shift_pc, shift_x_idx, shift_is_memop],
        reduction_rounds,
    };

    // -----------------------------------------------------------------------
    // 5. Continuity check scalars at r_shift
    // -----------------------------------------------------------------------
    // Open lane columns at r_shift for the continuity identity.
    let pc_next_at_r = mle_eval_fk(
        &trace_rows
            .iter()
            .map(|r| r[COL_PC_NEXT])
            .collect::<Vec<_>>(),
        &r_shift,
    );
    let x_idx_at_r = mle_eval_fk(&trace_rows.iter().map(|r| r[COL_X_IDX]).collect::<Vec<_>>(), &r_shift);
    let is_memop_at_r = mle_eval_fk(
        &trace_rows
            .iter()
            .map(|r| r[COL_IS_MEMOP])
            .collect::<Vec<_>>(),
        &r_shift,
    );
    let burst_last_at_r = mle_eval_fk(
        &trace_rows
            .iter()
            .map(|r| r[COL_BURST_LAST])
            .collect::<Vec<_>>(),
        &r_shift,
    );
    let shift_opening_values = [
        mle_eval_fk(&trace_rows.iter().map(|r| r[COL_PC]).collect::<Vec<_>>(), &r_shift),
        pc_next_at_r,
        x_idx_at_r,
        is_memop_at_r,
        burst_last_at_r,
    ];

    let active_shift_pc = shift_pc - excluded_shift_tail(trace_rows, COL_PC, &eq, active_rows);
    let active_shift_x_idx = shift_x_idx - excluded_shift_tail(trace_rows, COL_X_IDX, &eq, active_rows);
    let active_shift_is_memop = shift_is_memop - excluded_shift_tail(trace_rows, COL_IS_MEMOP, &eq, active_rows);
    let active_pc_next_at_r = pc_next_at_r - excluded_current_tail(trace_rows, COL_PC_NEXT, &eq, active_rows);
    let active_x_idx_at_r = x_idx_at_r - excluded_current_tail(trace_rows, COL_X_IDX, &eq, active_rows);
    let active_is_memop_at_r = is_memop_at_r - excluded_current_tail(trace_rows, COL_IS_MEMOP, &eq, active_rows);
    let active_burst_last_at_r = burst_last_at_r - excluded_current_tail(trace_rows, COL_BURST_LAST, &eq, active_rows);

    // delta_pc = ShiftActive[PC](r_shift) - PC_NEXT_active(r_shift)
    let delta_pc = active_shift_pc - active_pc_next_at_r;

    // delta_burst_step = IsMemOp(r) * (1 - BURST_LAST(r)) * (shift_x_idx - X_IDX(r) - 1)
    let delta_burst_step =
        active_is_memop_at_r * (K::ONE - active_burst_last_at_r) * (active_shift_x_idx - active_x_idx_at_r - K::ONE);

    // delta_burst_reset = shift_is_memop * (1 - IsMemOp(r) + BURST_LAST(r)) * shift_x_idx
    let delta_burst_reset =
        active_shift_is_memop * (K::ONE - active_is_memop_at_r + active_burst_last_at_r) * active_shift_x_idx;

    let active_prev = eval_active_prev(&r_shift, active_rows);

    // Full continuity identity value (should be zero for a valid trace):
    // ActivePrev_N(r) * (delta_pc + beta1 * delta_burst_step + beta2 * delta_burst_reset)
    let continuity_check_value = active_prev * (delta_pc + beta1 * delta_burst_step + beta2 * delta_burst_reset);

    // -----------------------------------------------------------------------
    // 6. Start-boundary: open IsMemOp(0) and X_IDX(0)
    // -----------------------------------------------------------------------
    let is_memop_0 = K::from(trace_rows[0][COL_IS_MEMOP]);
    let x_idx_0 = K::from(trace_rows[0][COL_X_IDX]);
    let start_boundary_values = [is_memop_0, x_idx_0];
    if is_memop_0 * x_idx_0 != K::ZERO {
        return Err(SimpleKernelError::ContinuityFailed(
            "stage3 start boundary failed".into(),
        ));
    }

    let last_row = active_rows - 1;
    let is_memop_last = K::from(trace_rows[last_row][COL_IS_MEMOP]);
    let burst_last_last = K::from(trace_rows[last_row][COL_BURST_LAST]);
    let final_boundary_values = [is_memop_last, burst_last_last];
    if is_memop_last * (K::ONE - burst_last_last) != K::ZERO {
        return Err(SimpleKernelError::ContinuityFailed(
            "stage3 final boundary failed".into(),
        ));
    }
    if continuity_check_value != K::ZERO {
        return Err(SimpleKernelError::ContinuityFailed(
            "stage3 continuity check failed".into(),
        ));
    }

    // -----------------------------------------------------------------------
    // 7. Build row-binding claims
    // -----------------------------------------------------------------------
    let mut row_bindings = Vec::with_capacity(active_rows);
    for j in 0..active_rows {
        let row_bits = index_to_bits_le(j, cycle_bits);
        // Open 23 non-fixed lane columns (skip COL_ONE = column 0).
        let opened_values: Vec<K> = (1..WITNESS_WIDTH)
            .map(|col| K::from(trace_rows[j][col]))
            .collect();
        row_bindings.push(RowBindingClaim {
            row_index: j,
            row_bits,
            opened_values,
        });
    }

    Ok(Stage3Proof {
        shift_proof,
        shift_opening_values,
        continuity_check_value,
        start_boundary_values,
        final_boundary_values,
        row_bindings,
    })
}

// ---------------------------------------------------------------------------
// Verifier stub
// ---------------------------------------------------------------------------

/// Verify Stage 3: transcript-faithful shift reduction, continuity, boundaries,
/// and row-binding shape. Opening authentication remains at the kernel manifest layer.
pub fn verify_stage3<Tr: Transcript>(
    proof: &Stage3Proof,
    active_rows: usize,
    padded_trace_length: usize,
    pad_pc_word: u16,
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<(), SimpleKernelError> {
    if active_rows == 0 || active_rows > padded_trace_length {
        return Err(SimpleKernelError::ContinuityFailed(format!(
            "active_rows {active_rows} out of range [1, {padded_trace_length}]"
        )));
    }
    if padded_trace_length != (1usize << cycle_bits) {
        return Err(SimpleKernelError::ContinuityFailed(format!(
            "padded trace length {padded_trace_length} != 2^{cycle_bits}"
        )));
    }
    if proof.row_bindings.len() != active_rows {
        return Err(SimpleKernelError::ContinuityFailed(format!(
            "stage3 exported {} row bindings for {active_rows} active rows",
            proof.row_bindings.len()
        )));
    }

    let beta1 = squeeze_k(transcript, b"stage3/beta1");
    let beta2 = squeeze_k(transcript, b"stage3/beta2");
    let expected_r_shift = squeeze_point(transcript, b"stage3/r_shift", cycle_bits);
    expect_equal_k_slice(
        &proof.shift_proof.source_point,
        &expected_r_shift,
        "stage3 shift source point",
    )?;

    let gamma_shift = squeeze_k(transcript, b"stage3/gamma_shift");
    let batched_shift_claim = proof.shift_proof.claimed_shift_values[0]
        + gamma_shift * proof.shift_proof.claimed_shift_values[1]
        + gamma_shift * gamma_shift * proof.shift_proof.claimed_shift_values[2];
    verify_sumcheck_known(
        transcript,
        2,
        batched_shift_claim,
        &proof.shift_proof.reduction_rounds,
        "stage3 lane shift",
    )?;

    let eq_shift = build_eq_table(&proof.shift_proof.source_point);
    let active_shift_pc = proof.shift_proof.claimed_shift_values[0]
        - excluded_shift_tail_from_proof(&eq_shift, COL_PC, active_rows, padded_trace_length, pad_pc_word);
    let active_shift_x_idx = proof.shift_proof.claimed_shift_values[1]
        - excluded_shift_tail_from_proof(&eq_shift, COL_X_IDX, active_rows, padded_trace_length, pad_pc_word);
    let active_shift_is_memop = proof.shift_proof.claimed_shift_values[2]
        - excluded_shift_tail_from_proof(&eq_shift, COL_IS_MEMOP, active_rows, padded_trace_length, pad_pc_word);
    let active_pc_next_at_r = proof.shift_opening_values[1]
        - excluded_current_tail_from_proof(
            proof,
            &eq_shift,
            COL_PC_NEXT,
            active_rows,
            padded_trace_length,
            pad_pc_word,
        )?;
    let active_x_idx_at_r = proof.shift_opening_values[2]
        - excluded_current_tail_from_proof(
            proof,
            &eq_shift,
            COL_X_IDX,
            active_rows,
            padded_trace_length,
            pad_pc_word,
        )?;
    let active_is_memop_at_r = proof.shift_opening_values[3]
        - excluded_current_tail_from_proof(
            proof,
            &eq_shift,
            COL_IS_MEMOP,
            active_rows,
            padded_trace_length,
            pad_pc_word,
        )?;
    let active_burst_last_at_r = proof.shift_opening_values[4]
        - excluded_current_tail_from_proof(
            proof,
            &eq_shift,
            COL_BURST_LAST,
            active_rows,
            padded_trace_length,
            pad_pc_word,
        )?;
    let delta_pc = active_shift_pc - active_pc_next_at_r;
    let delta_burst_step =
        active_is_memop_at_r * (K::ONE - active_burst_last_at_r) * (active_shift_x_idx - active_x_idx_at_r - K::ONE);
    let delta_burst_reset =
        active_shift_is_memop * (K::ONE - active_is_memop_at_r + active_burst_last_at_r) * active_shift_x_idx;
    let continuity_check_value = eval_active_prev(&proof.shift_proof.source_point, active_rows)
        * (delta_pc + beta1 * delta_burst_step + beta2 * delta_burst_reset);
    expect_equal_k(
        proof.continuity_check_value,
        continuity_check_value,
        "stage3 continuity check value",
    )?;
    if continuity_check_value != K::ZERO {
        return Err(SimpleKernelError::ContinuityFailed(
            "stage3 continuity check failed".into(),
        ));
    }

    if proof.start_boundary_values[0] * proof.start_boundary_values[1] != K::ZERO {
        return Err(SimpleKernelError::ContinuityFailed(
            "stage3 start boundary failed".into(),
        ));
    }
    if proof.final_boundary_values[0] * (K::ONE - proof.final_boundary_values[1]) != K::ZERO {
        return Err(SimpleKernelError::ContinuityFailed(
            "stage3 final boundary failed".into(),
        ));
    }

    for (expected_index, row_binding) in proof.row_bindings.iter().enumerate() {
        if row_binding.row_index != expected_index {
            return Err(SimpleKernelError::ContinuityFailed(format!(
                "stage3 row binding {} has row_index {}, expected {expected_index}",
                expected_index, row_binding.row_index
            )));
        }
        if row_binding.row_bits.len() != cycle_bits {
            return Err(SimpleKernelError::ContinuityFailed(format!(
                "stage3 row {} has {} row bits, expected {}",
                row_binding.row_index,
                row_binding.row_bits.len(),
                cycle_bits
            )));
        }
        if !row_index_matches_bits(row_binding.row_index, &row_binding.row_bits) {
            return Err(SimpleKernelError::ContinuityFailed(format!(
                "stage3 row {} bits do not match its row index",
                row_binding.row_index
            )));
        }
        if row_binding.opened_values.len() != WITNESS_WIDTH - 1 {
            return Err(SimpleKernelError::ContinuityFailed(format!(
                "stage3 row {} has {} opened values, expected {}",
                row_binding.row_index,
                row_binding.opened_values.len(),
                WITNESS_WIDTH - 1
            )));
        }
    }

    Ok(())
}

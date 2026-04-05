//! Owns the Stage 3 proving entrypoint.

use neo_math::K;
use neo_reductions::sumcheck::run_sumcheck_prover;
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::kernel::SimpleKernelError;
use crate::chip8::spec::{COL_BURST_LAST, COL_IS_MEMOP, COL_PC, COL_PC_NEXT, COL_X_IDX, WITNESS_WIDTH};

use super::{
    build_shifted_batched_col, compute_shift_value, eval_pair_mask, excluded_current_tail, excluded_shift_tail,
    index_to_bits_le, mle_eval_fk, sample_stage3_challenges, squeeze_k, LaneShiftOracle, LaneShiftProof,
    RowBindingClaim, Stage3Proof,
};

/// Prove Stage 3: LaneShift reduction, continuity check, start-boundary, row-binding.
pub fn prove_stage3<Tr: Transcript>(
    trace_rows: &[[neo_math::F; WITNESS_WIDTH]],
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

    let challenges = sample_stage3_challenges(transcript, cycle_bits);
    let beta1 = challenges.beta1;
    let beta2 = challenges.beta2;
    let r_shift = challenges.shift_point;
    let eq = crate::chip8::poly::build_eq_table(&r_shift);

    let shift_pc = compute_shift_value(trace_rows, COL_PC, &eq, t);
    let shift_x_idx = compute_shift_value(trace_rows, COL_X_IDX, &eq, t);
    let shift_is_memop = compute_shift_value(trace_rows, COL_IS_MEMOP, &eq, t);

    let gamma_shift = squeeze_k(transcript, b"stage3/gamma_shift");
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

    let delta_pc = active_shift_pc - active_pc_next_at_r;
    let delta_burst_step =
        active_is_memop_at_r * (K::ONE - active_burst_last_at_r) * (active_shift_x_idx - active_x_idx_at_r - K::ONE);
    let delta_burst_reset =
        active_shift_is_memop * (K::ONE - active_is_memop_at_r + active_burst_last_at_r) * active_shift_x_idx;
    let pair_mask_at_r = eval_pair_mask(&r_shift, active_rows);
    let continuity_check_value = pair_mask_at_r * (delta_pc + beta1 * delta_burst_step + beta2 * delta_burst_reset);

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

    let mut row_bindings = Vec::with_capacity(active_rows);
    for j in 0..active_rows {
        let row_bits = index_to_bits_le(j, cycle_bits);
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

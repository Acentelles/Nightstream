//! Owns the Stage 3 verifier entrypoint.

use neo_math::K;
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::kernel::{expect_equal_k, expect_equal_k_slice, verify_sumcheck_known, SimpleKernelError};
use crate::chip8::spec::{COL_BURST_LAST, COL_IS_MEMOP, COL_PC, COL_PC_NEXT, COL_X_IDX, WITNESS_WIDTH};

use super::{
    eval_pair_mask, excluded_current_tail_from_bindings, excluded_shift_tail_from_proof, row_index_matches_bits,
    sample_stage3_challenges, squeeze_k, RowBindingClaim, Stage3DerivedExecutionSurface, Stage3Proof,
};

fn verify_stage3_surface<Tr: Transcript>(
    reduction_rounds: &[Vec<K>],
    surface: &Stage3DerivedExecutionSurface,
    row_bindings: &[RowBindingClaim],
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
    if row_bindings.len() != active_rows {
        return Err(SimpleKernelError::ContinuityFailed(format!(
            "stage3 exported {} row bindings for {active_rows} active rows",
            row_bindings.len()
        )));
    }

    let challenges = sample_stage3_challenges(transcript, cycle_bits);
    let beta1 = challenges.beta1;
    let beta2 = challenges.beta2;
    let expected_r_shift = challenges.shift_point;
    expect_equal_k_slice(&surface.source_point, &expected_r_shift, "stage3 shift source point")?;

    let gamma_shift = squeeze_k(transcript, b"stage3/gamma_shift");
    let batched_shift_claim = surface.claimed_shift_values[0]
        + gamma_shift * surface.claimed_shift_values[1]
        + gamma_shift * gamma_shift * surface.claimed_shift_values[2];
    verify_sumcheck_known(
        transcript,
        2,
        batched_shift_claim,
        reduction_rounds,
        "stage3 lane shift",
    )?;

    let eq_shift = crate::chip8::poly::build_eq_table(&surface.source_point);
    let active_shift_pc = surface.claimed_shift_values[0]
        - excluded_shift_tail_from_proof(&eq_shift, COL_PC, active_rows, padded_trace_length, pad_pc_word);
    let active_shift_x_idx = surface.claimed_shift_values[1]
        - excluded_shift_tail_from_proof(&eq_shift, COL_X_IDX, active_rows, padded_trace_length, pad_pc_word);
    let active_shift_is_memop = surface.claimed_shift_values[2]
        - excluded_shift_tail_from_proof(&eq_shift, COL_IS_MEMOP, active_rows, padded_trace_length, pad_pc_word);
    let active_pc_next_at_r = surface.shift_opening_values[1]
        - excluded_current_tail_from_bindings(
            row_bindings,
            &eq_shift,
            COL_PC_NEXT,
            active_rows,
            padded_trace_length,
            pad_pc_word,
        )?;
    let active_x_idx_at_r = surface.shift_opening_values[2]
        - excluded_current_tail_from_bindings(
            row_bindings,
            &eq_shift,
            COL_X_IDX,
            active_rows,
            padded_trace_length,
            pad_pc_word,
        )?;
    let active_is_memop_at_r = surface.shift_opening_values[3]
        - excluded_current_tail_from_bindings(
            row_bindings,
            &eq_shift,
            COL_IS_MEMOP,
            active_rows,
            padded_trace_length,
            pad_pc_word,
        )?;
    let active_burst_last_at_r = surface.shift_opening_values[4]
        - excluded_current_tail_from_bindings(
            row_bindings,
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
    let continuity_check_value = eval_pair_mask(&surface.source_point, active_rows)
        * (delta_pc + beta1 * delta_burst_step + beta2 * delta_burst_reset);
    expect_equal_k(
        surface.continuity_check_value,
        continuity_check_value,
        "stage3 continuity check value",
    )?;
    if continuity_check_value != K::ZERO {
        return Err(SimpleKernelError::ContinuityFailed(
            "stage3 continuity check failed".into(),
        ));
    }

    if surface.start_boundary_values[0] * surface.start_boundary_values[1] != K::ZERO {
        return Err(SimpleKernelError::ContinuityFailed(
            "stage3 start boundary failed".into(),
        ));
    }
    if surface.final_boundary_values[0] * (K::ONE - surface.final_boundary_values[1]) != K::ZERO {
        return Err(SimpleKernelError::ContinuityFailed(
            "stage3 final boundary failed".into(),
        ));
    }

    for (expected_index, row_binding) in row_bindings.iter().enumerate() {
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
    let derived = Stage3DerivedExecutionSurface {
        source_point: proof.shift_proof.source_point.clone(),
        claimed_shift_values: proof.shift_proof.claimed_shift_values,
        shift_opening_values: proof.shift_opening_values,
        continuity_check_value: proof.continuity_check_value,
        start_boundary_values: proof.start_boundary_values,
        final_boundary_values: proof.final_boundary_values,
    };
    verify_stage3_surface(
        &proof.shift_proof.reduction_rounds,
        &derived,
        &proof.row_bindings,
        active_rows,
        padded_trace_length,
        pad_pc_word,
        cycle_bits,
        transcript,
    )
}

pub(crate) fn verify_stage3_execution<Tr: Transcript>(
    reduction_rounds: &[Vec<K>],
    derived: &Stage3DerivedExecutionSurface,
    row_bindings: &[RowBindingClaim],
    active_rows: usize,
    padded_trace_length: usize,
    pad_pc_word: u16,
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<(), SimpleKernelError> {
    verify_stage3_surface(
        reduction_rounds,
        derived,
        row_bindings,
        active_rows,
        padded_trace_length,
        pad_pc_word,
        cycle_bits,
        transcript,
    )
}

use neo_math::K;
use neo_transcript::Poseidon2Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::poly::{build_eq_table, mle_eval_k_be};
use crate::chip8::spec::{COL_IS_MEMOP, COL_PC, COL_X_IDX};
use crate::chip8::stage3::Stage3Proof;

use super::super::{expect_equal_k, SimpleKernelError};
use super::{sample_k, sample_point};

pub(crate) fn verify_kernel_stage3_sumcheck_terminal_from_execution(
    reduction_rounds: &[Vec<K>],
    source_point: &[K],
    claimed_shift_values: &[K; 3],
    trace_rows: &[[neo_math::F; 24]],
    transcript: &mut Poseidon2Transcript,
) -> Result<(), SimpleKernelError> {
    let cycle_bits = source_point.len();
    let _ = sample_k(transcript, b"stage3/beta1");
    let _ = sample_k(transcript, b"stage3/beta2");
    let _ = sample_point(transcript, b"stage3/r_shift", cycle_bits);
    let gamma_shift = sample_k(transcript, b"stage3/gamma_shift");

    let batched_shift_claim = claimed_shift_values[0]
        + gamma_shift * claimed_shift_values[1]
        + gamma_shift * gamma_shift * claimed_shift_values[2];
    let (shift_point, shift_terminal) = super::super::verify_common::verify_sumcheck_known_with_terminal(
        transcript,
        2,
        batched_shift_claim,
        reduction_rounds,
        "stage3 lane shift",
    )?;
    let eq_shift = build_eq_table(source_point);
    let mut shifted_batched_col = Vec::with_capacity(trace_rows.len());
    for row in trace_rows.iter().skip(1) {
        shifted_batched_col.push(
            K::from(row[COL_PC])
                + gamma_shift * K::from(row[COL_X_IDX])
                + gamma_shift * gamma_shift * K::from(row[COL_IS_MEMOP]),
        );
    }
    shifted_batched_col.push(K::ZERO);
    let expected_terminal = mle_eval_k_be(&eq_shift, &shift_point) * mle_eval_k_be(&shifted_batched_col, &shift_point);
    expect_equal_k(shift_terminal, expected_terminal, "stage3 lane shift terminal")
}

pub(crate) fn verify_kernel_stage3_sumcheck_terminal(
    proof: &Stage3Proof,
    trace_rows: &[[neo_math::F; 24]],
    transcript: &mut Poseidon2Transcript,
) -> Result<(), SimpleKernelError> {
    verify_kernel_stage3_sumcheck_terminal_from_execution(
        &proof.shift_proof.reduction_rounds,
        &proof.shift_proof.source_point,
        &proof.shift_proof.claimed_shift_values,
        trace_rows,
        transcript,
    )
}

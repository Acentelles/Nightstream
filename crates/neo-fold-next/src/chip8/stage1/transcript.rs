//! Owns verifier-side replay of the Stage 1 transcript schedule.

use neo_math::K;
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::kernel::{replay_sumcheck_unchecked, split_round_groups, verify_sumcheck_known, SimpleKernelError};

use super::proof::ShoutChannelExecutionProof;

pub(crate) fn replay_stage1_channel_transcript<Tr: Transcript>(
    transcript: &mut Tr,
    proof: &ShoutChannelExecutionProof,
    initial_sum: K,
    addr_bits: usize,
    cycle_bits: usize,
    decode_consistency_claim: Option<K>,
    label: &str,
) -> Result<Vec<K>, SimpleKernelError> {
    let core_point = verify_sumcheck_known(
        transcript,
        2,
        initial_sum,
        &proof.sumcheck_rounds,
        &format!("{label} core"),
    )?;

    let total_bits = addr_bits + cycle_bits;
    let (bool_rounds, hamming_rounds, decode_rounds) = split_round_groups(
        &proof.addr_correctness_rounds,
        total_bits,
        addr_bits,
        addr_bits,
        &format!("{label} address correctness"),
    )?;
    verify_sumcheck_known(transcript, 2, K::ZERO, bool_rounds, &format!("{label} booleanity"))?;
    verify_sumcheck_known(
        transcript,
        1,
        K::ONE,
        hamming_rounds,
        &format!("{label} hamming weight"),
    )?;
    if let Some(claim) = decode_consistency_claim {
        verify_sumcheck_known(
            transcript,
            2,
            claim,
            decode_rounds,
            &format!("{label} decode consistency"),
        )?;
    } else {
        replay_sumcheck_unchecked(transcript, 2, decode_rounds, &format!("{label} decode consistency"))?;
    }
    Ok(core_point)
}

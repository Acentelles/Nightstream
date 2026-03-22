//! Owns verifier-side replay of Stage 1 and Stage 2 transcript schedules.

use neo_math::K;
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use super::verify_common::{
    expect_equal_k_slice, replay_sumcheck_unchecked, split_round_groups, verify_sumcheck_known,
};
use super::{AddressCorrectnessProof, ShoutChannelProof, SimpleKernelError};

pub(crate) fn verify_stage1_channel_transcript<Tr: Transcript>(
    transcript: &mut Tr,
    proof: &ShoutChannelProof,
    initial_sum: K,
    addr_bits: usize,
    cycle_bits: usize,
    decode_consistency_claim: Option<K>,
    label: &str,
) -> Result<(), SimpleKernelError> {
    let core_point = verify_sumcheck_known(
        transcript,
        2,
        initial_sum,
        &proof.sumcheck_rounds,
        &format!("{label} core"),
    )?;
    expect_equal_k_slice(&proof.addr_point, &core_point, &format!("{label} addr point"))?;

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
    Ok(())
}

pub(crate) fn verify_stage2_address_correctness_transcript<Tr: Transcript>(
    transcript: &mut Tr,
    proof: &AddressCorrectnessProof,
    addr_bits: usize,
    cycle_bits: usize,
    mapped_claim: K,
    raw_claim: K,
    label: &str,
) -> Result<(), SimpleKernelError> {
    let total_bits = addr_bits + cycle_bits;
    verify_sumcheck_known(
        transcript,
        2,
        K::ZERO,
        &proof.booleanity_rounds,
        &format!("{label} booleanity"),
    )?;
    if proof.booleanity_rounds.len() != total_bits {
        return Err(SimpleKernelError::SumcheckFailed(format!(
            "{label} booleanity round count {} != expected {total_bits}",
            proof.booleanity_rounds.len()
        )));
    }
    verify_sumcheck_known(
        transcript,
        1,
        K::ONE,
        &proof.hamming_weight_rounds,
        &format!("{label} hamming weight"),
    )?;
    if proof.hamming_weight_rounds.len() != addr_bits {
        return Err(SimpleKernelError::SumcheckFailed(format!(
            "{label} hamming round count {} != expected {addr_bits}",
            proof.hamming_weight_rounds.len()
        )));
    }
    verify_sumcheck_known(
        transcript,
        2,
        mapped_claim,
        &proof.decode_consistency_rounds,
        &format!("{label} decode consistency"),
    )?;
    if proof.decode_consistency_rounds.len() != addr_bits {
        return Err(SimpleKernelError::SumcheckFailed(format!(
            "{label} decode-consistency round count {} != expected {addr_bits}",
            proof.decode_consistency_rounds.len()
        )));
    }
    verify_sumcheck_known(
        transcript,
        2,
        raw_claim,
        &proof.raw_address_rounds,
        &format!("{label} raw address"),
    )?;
    if proof.raw_address_rounds.len() != addr_bits {
        return Err(SimpleKernelError::SumcheckFailed(format!(
            "{label} raw-address round count {} != expected {addr_bits}",
            proof.raw_address_rounds.len()
        )));
    }
    Ok(())
}

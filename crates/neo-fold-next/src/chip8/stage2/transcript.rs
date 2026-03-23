//! Owns verifier-side replay of the Stage 2 address-correctness transcript schedule.

use neo_math::K;
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::kernel::{verify_sumcheck_known, SimpleKernelError};

use super::proof::AddressCorrectnessProof;

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

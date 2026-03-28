//! Owns the Stage 2 verifier entrypoint.

use neo_math::{KExtensions, K};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::kernel::{expect_equal_k, expect_equal_k_slice, verify_sumcheck_known, SimpleKernelError};

use super::common::{squeeze_k, squeeze_point};
use super::proof::Stage2TwistProof;
use super::{ram, reg};

/// Verify Stage 2 Twist memory checking.
pub fn verify_stage2<Tr: Transcript>(
    proof: &Stage2TwistProof,
    initial_registers: &[u8; 16],
    initial_i: u16,
    initial_ram: &[u8],
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<(), SimpleKernelError> {
    if proof.handoff_values_at_twist.len() != 3 || proof.lane_values_at_twist.len() != 14 {
        return Err(SimpleKernelError::OpeningFailed(
            "stage2 opening surface has the wrong shape".into(),
        ));
    }

    let lane = &proof.lane_values_at_twist;
    let expected_cycle_point = squeeze_point(transcript, b"stage2/r_cycle", cycle_bits);
    expect_equal_k_slice(&proof.cycle_point, &expected_cycle_point, "stage2 cycle point")?;

    reg::verify_register_subsystem(proof, initial_registers, initial_i, cycle_bits, transcript)?;
    ram::verify_ram_subsystem(proof, initial_ram, cycle_bits, transcript)?;

    transcript.append_fields(
        b"stage2/reg_write_x_target/claim",
        &proof.reg_write_x_target_proof.claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        proof.reg_write_x_target_proof.claim,
        &proof.reg_write_x_target_proof.rounds,
        "stage2 register write-to-x target",
    )?;
    transcript.append_fields(
        b"stage2/reg_write_i_target/claim",
        &proof.reg_write_i_target_proof.claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        proof.reg_write_i_target_proof.claim,
        &proof.reg_write_i_target_proof.rounds,
        "stage2 register write-to-i target",
    )?;
    transcript.append_fields(
        b"stage2/ram_read_target/claim",
        &proof.ram_read_target_proof.claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        proof.ram_read_target_proof.claim,
        &proof.ram_read_target_proof.rounds,
        "stage2 RAM read target",
    )?;
    transcript.append_fields(
        b"stage2/ram_write_target/claim",
        &proof.ram_write_target_proof.claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        proof.ram_write_target_proof.claim,
        &proof.ram_write_target_proof.rounds,
        "stage2 RAM write target",
    )?;
    expect_equal_k(
        proof.ram_write_matches_x_zero_proof.claim,
        K::ZERO,
        "stage2 write-RAM MEM_VALUE/REG_X zero claim",
    )?;
    transcript.append_fields(
        b"stage2/ram_write_matches_x_zero/claim",
        &proof.ram_write_matches_x_zero_proof.claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        proof.ram_write_matches_x_zero_proof.claim,
        &proof.ram_write_matches_x_zero_proof.rounds,
        "stage2 RAM write matches REG_X",
    )?;
    expect_equal_k(
        proof.ram_idle_mem_zero_proof.claim,
        K::ZERO,
        "stage2 idle MEM_VALUE zero claim",
    )?;
    transcript.append_fields(
        b"stage2/ram_idle_mem_zero/claim",
        &proof.ram_idle_mem_zero_proof.claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        proof.ram_idle_mem_zero_proof.claim,
        &proof.ram_idle_mem_zero_proof.rounds,
        "stage2 idle MEM_VALUE",
    )?;

    let expected_gamma_twist_link = squeeze_k(transcript, b"stage2/gamma_twist_link");
    expect_equal_k(
        proof.gamma_twist_link,
        expected_gamma_twist_link,
        "stage2 gamma_twist_link",
    )?;

    let linkage_terms = [
        proof.link_claims.rv_x - lane[0],
        proof.link_claims.rv_y - lane[1],
        proof.link_claims.rv_i - lane[3],
        proof.link_claims.wv_reg - (proof.reg_write_x_target_proof.claim + proof.reg_write_i_target_proof.claim),
        proof.link_claims.rv_ram - proof.ram_read_target_proof.claim,
        proof.link_claims.wv_ram - proof.ram_write_target_proof.claim,
        proof.ram_write_matches_x_zero_proof.claim,
        proof.ram_idle_mem_zero_proof.claim,
    ];
    let mut linkage_batch_value = K::ZERO;
    let mut gamma_power = K::ONE;
    for term in linkage_terms {
        linkage_batch_value += gamma_power * term;
        gamma_power *= proof.gamma_twist_link;
    }
    expect_equal_k(
        proof.linkage_batch_value,
        linkage_batch_value,
        "stage2 linkage batch value",
    )?;
    if linkage_batch_value != K::ZERO {
        let failing_terms: Vec<usize> = linkage_terms
            .iter()
            .enumerate()
            .filter_map(|(idx, term)| if *term != K::ZERO { Some(idx) } else { None })
            .collect();
        return Err(SimpleKernelError::SumcheckFailed(format!(
            "stage2 linkage batch failed at r_twist_cycle (nonzero terms: {failing_terms:?})"
        )));
    }

    Ok(())
}

//! Owns the Stage 2 verifier entrypoint.

use neo_math::{KExtensions, K};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::kernel::{expect_equal_k, expect_equal_k_slice, verify_sumcheck_known, SimpleKernelError};

use super::common::{squeeze_k, squeeze_point};
use super::proof::{Stage2RamExecutionProof, Stage2RegisterExecutionProof, Stage2TwistProof};
use super::{
    compute_linkage_batch_value_from_claims, ram, reg, stage2_execution_surface_from_proof,
    Stage2DerivedExecutionSurface,
};

fn verify_stage2_surface<Tr: Transcript>(
    register: &Stage2RegisterExecutionProof,
    memory: &Stage2RamExecutionProof,
    surface: &Stage2DerivedExecutionSurface,
    initial_registers: &[u8; 16],
    initial_i: u16,
    initial_ram: &[u8],
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<(), SimpleKernelError> {
    if surface.handoff_values_at_twist.len() != 3 || surface.lane_values_at_twist.len() != 14 {
        return Err(SimpleKernelError::OpeningFailed(
            "stage2 opening surface has the wrong shape".into(),
        ));
    }

    let lane = &surface.lane_values_at_twist;
    let expected_cycle_point = squeeze_point(transcript, b"stage2/r_cycle", cycle_bits);
    expect_equal_k_slice(&surface.cycle_point, &expected_cycle_point, "stage2 cycle point")?;

    reg::verify_register_execution(register, surface, initial_registers, initial_i, cycle_bits, transcript)?;
    ram::verify_ram_execution(memory, surface, initial_ram, cycle_bits, transcript)?;

    transcript.append_fields(
        b"stage2/reg_write_x_target/claim",
        &surface.reg_write_x_target_claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        surface.reg_write_x_target_claim,
        &register.reg_write_x_target_rounds,
        "stage2 register write-to-x target",
    )?;
    transcript.append_fields(
        b"stage2/reg_write_i_target/claim",
        &surface.reg_write_i_target_claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        surface.reg_write_i_target_claim,
        &register.reg_write_i_target_rounds,
        "stage2 register write-to-i target",
    )?;
    transcript.append_fields(
        b"stage2/ram_read_target/claim",
        &surface.ram_read_target_claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        surface.ram_read_target_claim,
        &memory.ram_read_target_rounds,
        "stage2 RAM read target",
    )?;
    transcript.append_fields(
        b"stage2/ram_write_target/claim",
        &surface.ram_write_target_claim.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        surface.ram_write_target_claim,
        &memory.ram_write_target_rounds,
        "stage2 RAM write target",
    )?;
    transcript.append_fields(b"stage2/ram_write_matches_x_zero/claim", &K::ZERO.as_coeffs());
    verify_sumcheck_known(
        transcript,
        3,
        K::ZERO,
        &memory.ram_write_matches_x_zero_rounds,
        "stage2 RAM write matches REG_X",
    )?;
    transcript.append_fields(b"stage2/ram_idle_mem_zero/claim", &K::ZERO.as_coeffs());
    verify_sumcheck_known(
        transcript,
        3,
        K::ZERO,
        &memory.ram_idle_mem_zero_rounds,
        "stage2 idle MEM_VALUE",
    )?;

    let expected_gamma_twist_link = squeeze_k(transcript, b"stage2/gamma_twist_link");
    expect_equal_k(
        surface.gamma_twist_link,
        expected_gamma_twist_link,
        "stage2 gamma_twist_link",
    )?;

    let linkage_batch_value = compute_linkage_batch_value_from_claims(
        &surface.link_claims,
        surface.gamma_twist_link,
        surface.reg_write_x_target_claim,
        surface.reg_write_i_target_claim,
        surface.ram_read_target_claim,
        surface.ram_write_target_claim,
        lane,
    );
    expect_equal_k(
        surface.linkage_batch_value,
        linkage_batch_value,
        "stage2 linkage batch value",
    )?;
    if linkage_batch_value != K::ZERO {
        let linkage_terms = [
            surface.link_claims.rv_x - lane[0],
            surface.link_claims.rv_y - lane[1],
            surface.link_claims.rv_i - lane[3],
            surface.link_claims.wv_reg - (surface.reg_write_x_target_claim + surface.reg_write_i_target_claim),
            surface.link_claims.rv_ram - surface.ram_read_target_claim,
            surface.link_claims.wv_ram - surface.ram_write_target_claim,
            K::ZERO,
            K::ZERO,
        ];
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

pub(crate) fn verify_stage2_execution<Tr: Transcript>(
    register: &Stage2RegisterExecutionProof,
    memory: &Stage2RamExecutionProof,
    surface: &Stage2DerivedExecutionSurface,
    initial_registers: &[u8; 16],
    initial_i: u16,
    initial_ram: &[u8],
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<(), SimpleKernelError> {
    verify_stage2_surface(
        register,
        memory,
        surface,
        initial_registers,
        initial_i,
        initial_ram,
        cycle_bits,
        transcript,
    )
}

/// Verify Stage 2 Twist memory checking.
pub fn verify_stage2<Tr: Transcript>(
    proof: &Stage2TwistProof,
    initial_registers: &[u8; 16],
    initial_i: u16,
    initial_ram: &[u8],
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<(), SimpleKernelError> {
    let register = Stage2RegisterExecutionProof {
        reg_rw_batched_rounds: proof.reg_rw_batched_rounds.clone(),
        reg_val_from_inc_rounds: proof.reg_val_from_inc_rounds.clone(),
        reg_addr_correctness: proof.reg_addr_correctness.clone(),
        reg_ra_y_target_rounds: proof.reg_ra_y_target_proof.rounds.clone(),
        reg_wa_addr_target_rounds: proof.reg_wa_addr_target_proof.rounds.clone(),
        reg_write_x_target_rounds: proof.reg_write_x_target_proof.rounds.clone(),
        reg_write_i_target_rounds: proof.reg_write_i_target_proof.rounds.clone(),
    };
    let memory = Stage2RamExecutionProof {
        ram_rw_batched_rounds: proof.ram_rw_batched_rounds.clone(),
        ram_val_from_inc_rounds: proof.ram_val_from_inc_rounds.clone(),
        ram_raf_read_rounds: proof.ram_raf_read_rounds.clone(),
        ram_raf_write_rounds: proof.ram_raf_write_rounds.clone(),
        ram_read_target_rounds: proof.ram_read_target_proof.rounds.clone(),
        ram_write_target_rounds: proof.ram_write_target_proof.rounds.clone(),
        ram_write_matches_x_zero_rounds: proof.ram_write_matches_x_zero_proof.rounds.clone(),
        ram_idle_mem_zero_rounds: proof.ram_idle_mem_zero_proof.rounds.clone(),
        ram_addr_correctness: proof.ram_addr_correctness.clone(),
    };
    let surface = stage2_execution_surface_from_proof(proof);
    verify_stage2_surface(
        &register,
        &memory,
        &surface,
        initial_registers,
        initial_i,
        initial_ram,
        cycle_bits,
        transcript,
    )
}

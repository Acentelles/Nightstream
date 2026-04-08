//! Owns verifier-side replay of the Stage 2 address-correctness transcript schedule.

use neo_math::{KExtensions, F, K};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::kernel::KernelStepAux;
use crate::chip8::kernel::{verify_sumcheck_known, SimpleKernelError};
use crate::chip8::tables::{ADDR_RAM_BITS, ADDR_REG_BITS};

use super::common::{mle_eval_fk_be, squeeze_k, squeeze_point, stage2_address_claims};
use super::proof::{AddressCorrectnessProof, Stage2RamExecutionProof, Stage2RegisterExecutionProof};
use super::Stage2ExecutionRegisterTargetClaims;

pub(crate) struct Stage2TranscriptChallenges {
    pub gamma_reg: K,
    pub reg_addr_point: Vec<K>,
    pub reg_val_at_point: K,
    pub reg_val_from_inc_claim: K,
    pub gamma_ram: K,
    pub ram_addr_point: Vec<K>,
    pub ram_val_at_point: K,
    pub ram_val_from_inc_claim: K,
    pub gamma_twist_link: K,
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

pub(crate) fn replay_stage2_execution_transcript<Tr: Transcript>(
    transcript: &mut Tr,
    register: &Stage2RegisterExecutionProof,
    memory: &Stage2RamExecutionProof,
    initial_registers: &[u8; 16],
    initial_i: u16,
    initial_ram: &[u8],
    aux: &[KernelStepAux],
    cycle_point: &[K],
    lane: &[K],
    handoff: &[K],
    register_target_claims: &Stage2ExecutionRegisterTargetClaims,
    ram_read_target_claim: K,
    ram_write_target_claim: K,
    ram_raf_read_claim: K,
    ram_raf_write_claim: K,
    cycle_bits: usize,
) -> Result<Stage2TranscriptChallenges, SimpleKernelError> {
    let reconstructed_link_claims = super::reconstruct_link_claims_from_execution(
        lane,
        register_target_claims.reg_write_x,
        register_target_claims.reg_write_i,
        ram_read_target_claim,
        ram_write_target_claim,
    );
    let gamma_reg = squeeze_k(transcript, b"stage2/gamma_reg");
    let reg_rw_claim = reconstructed_link_claims.wv_reg
        + gamma_reg * reconstructed_link_claims.rv_x
        + gamma_reg * gamma_reg * reconstructed_link_claims.rv_y
        + gamma_reg * gamma_reg * gamma_reg * reconstructed_link_claims.rv_i;
    transcript.append_fields(b"stage2/reg_rw_claim", &reg_rw_claim.as_coeffs());
    verify_sumcheck_known(
        transcript,
        3,
        reg_rw_claim,
        &register.reg_rw_batched_rounds,
        "stage2 register read/write",
    )?;
    let reg_addr_point = squeeze_point(transcript, b"stage2/r_addr_reg", ADDR_REG_BITS);
    let reg_val_at_point = super::reconstruct_reg_value_at_point(
        aux,
        initial_registers,
        initial_i,
        cycle_bits,
        cycle_point,
        &reg_addr_point,
    );
    let reg_init_at_point = mle_eval_fk_be(&initial_reg_values(initial_registers, initial_i), &reg_addr_point);
    let reg_val_from_inc_claim = reg_val_at_point - reg_init_at_point;
    transcript.append_fields(b"stage2/reg_val_inc_claim", &reg_val_from_inc_claim.as_coeffs());
    verify_sumcheck_known(
        transcript,
        3,
        reg_val_from_inc_claim,
        &register.reg_val_from_inc_rounds,
        "stage2 register val-from-inc",
    )?;
    transcript.append_fields(
        b"stage2/reg_ra_y_target/claim",
        &register_target_claims.reg_ra_y.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        register_target_claims.reg_ra_y,
        &register.reg_ra_y_target_rounds,
        "stage2 register ra_y target",
    )?;
    transcript.append_fields(
        b"stage2/reg_wa_x_addr_target/claim",
        &register_target_claims.reg_wa_addr.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        register_target_claims.reg_wa_addr,
        &register.reg_wa_addr_target_rounds,
        "stage2 register wa-address target",
    )?;
    let reg_wa_mapped_claim = register_target_claims.reg_wa_addr + lane[9] * K::from(F::from_u64(16u64));
    let (mapped_reg_claims, raw_reg_claims, _, _) = stage2_address_claims(
        lane,
        handoff,
        register_target_claims.reg_ra_y,
        reg_wa_mapped_claim,
        K::ZERO,
        K::ZERO,
    );
    if register.reg_addr_correctness.len() != 4 {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 register address correctness proof count must be 4".into(),
        ));
    }
    for (idx, addr_proof) in register.reg_addr_correctness.iter().enumerate() {
        verify_stage2_address_correctness_transcript(
            transcript,
            addr_proof,
            ADDR_REG_BITS,
            cycle_bits,
            mapped_reg_claims[idx],
            raw_reg_claims[idx],
            &format!("stage2 register address family {idx}"),
        )?;
    }

    let gamma_ram = squeeze_k(transcript, b"stage2/gamma_ram");
    let ram_rw_claim = ram_read_target_claim + gamma_ram * ram_write_target_claim;
    transcript.append_fields(b"stage2/ram_rw_claim", &ram_rw_claim.as_coeffs());
    verify_sumcheck_known(
        transcript,
        3,
        ram_rw_claim,
        &memory.ram_rw_batched_rounds,
        "stage2 RAM read/write",
    )?;
    let ram_addr_point = squeeze_point(transcript, b"stage2/r_addr_ram", ADDR_RAM_BITS);
    let ram_val_at_point =
        super::reconstruct_ram_value_at_point(aux, initial_ram, cycle_bits, cycle_point, &ram_addr_point);
    let ram_init_at_point = mle_eval_fk_be(&initial_ram_values(initial_ram), &ram_addr_point);
    let ram_val_from_inc_claim = ram_val_at_point - ram_init_at_point;
    transcript.append_fields(b"stage2/ram_val_inc_claim", &ram_val_from_inc_claim.as_coeffs());
    verify_sumcheck_known(
        transcript,
        3,
        ram_val_from_inc_claim,
        &memory.ram_val_from_inc_rounds,
        "stage2 RAM val-from-inc",
    )?;
    verify_sumcheck_known(
        transcript,
        2,
        ram_raf_read_claim,
        &memory.ram_raf_read_rounds,
        "stage2 RAM raf-read",
    )?;
    verify_sumcheck_known(
        transcript,
        2,
        ram_raf_write_claim,
        &memory.ram_raf_write_rounds,
        "stage2 RAM raf-write",
    )?;
    let (_, _, mapped_ram_claims, raw_ram_claims) =
        stage2_address_claims(lane, handoff, K::ZERO, K::ZERO, ram_raf_read_claim, ram_raf_write_claim);
    if memory.ram_addr_correctness.len() != 2 {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 RAM address correctness proof count must be 2".into(),
        ));
    }
    for (idx, addr_proof) in memory.ram_addr_correctness.iter().enumerate() {
        verify_stage2_address_correctness_transcript(
            transcript,
            addr_proof,
            ADDR_RAM_BITS,
            cycle_bits,
            mapped_ram_claims[idx],
            raw_ram_claims[idx],
            &format!("stage2 RAM address family {idx}"),
        )?;
    }

    transcript.append_fields(
        b"stage2/reg_write_x_target/claim",
        &register_target_claims.reg_write_x.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        register_target_claims.reg_write_x,
        &register.reg_write_x_target_rounds,
        "stage2 register write-to-x target",
    )?;
    transcript.append_fields(
        b"stage2/reg_write_i_target/claim",
        &register_target_claims.reg_write_i.as_coeffs(),
    );
    verify_sumcheck_known(
        transcript,
        3,
        register_target_claims.reg_write_i,
        &register.reg_write_i_target_rounds,
        "stage2 register write-to-i target",
    )?;
    transcript.append_fields(b"stage2/ram_read_target/claim", &ram_read_target_claim.as_coeffs());
    verify_sumcheck_known(
        transcript,
        3,
        ram_read_target_claim,
        &memory.ram_read_target_rounds,
        "stage2 RAM read target",
    )?;
    transcript.append_fields(b"stage2/ram_write_target/claim", &ram_write_target_claim.as_coeffs());
    verify_sumcheck_known(
        transcript,
        3,
        ram_write_target_claim,
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

    let gamma_twist_link = squeeze_k(transcript, b"stage2/gamma_twist_link");
    Ok(Stage2TranscriptChallenges {
        gamma_reg,
        reg_addr_point,
        reg_val_at_point,
        reg_val_from_inc_claim,
        gamma_ram,
        ram_addr_point,
        ram_val_at_point,
        ram_val_from_inc_claim,
        gamma_twist_link,
    })
}

fn initial_reg_values(initial_registers: &[u8; 16], initial_i: u16) -> Vec<F> {
    let mut values = vec![F::ZERO; 1usize << ADDR_REG_BITS];
    for i in 0..16 {
        values[i] = F::from_u64(initial_registers[i] as u64);
    }
    values[16] = F::from_u64(initial_i as u64);
    values
}

fn initial_ram_values(initial_ram: &[u8]) -> Vec<F> {
    let mut values = vec![F::ZERO; 1usize << ADDR_RAM_BITS];
    for (idx, &byte) in initial_ram.iter().enumerate().take(1usize << ADDR_RAM_BITS) {
        values[idx] = F::from_u64(byte as u64);
    }
    values
}

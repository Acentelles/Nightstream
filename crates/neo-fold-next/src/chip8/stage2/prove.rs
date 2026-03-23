//! Owns the Stage 2 proving entrypoint and final linkage batch construction.

use neo_math::{F, K};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::kernel::{KernelStepAux, SimpleKernelError};
use crate::chip8::poly::build_eq_table;
use crate::chip8::spec::{
    COL_I_NEXT, COL_MEM_VALUE, COL_REG_X, COL_REG_X_NEXT, COL_WRITES_LOOKUP_TO_X, COL_WRITES_MEM_TO_X,
    COL_WRITES_NNN_TO_I,
};

use super::common::{
    bool_values_from_aux, col_values, handoff_values_at_cycle, lane_values_at_cycle, prove_cycle_product_relation,
    squeeze_k, squeeze_point,
};
use super::proof::{Stage2LinkClaims, Stage2TwistProof};
use super::ram::prove_ram_subsystem;
use super::reg::prove_register_subsystem;

/// Prove Stage 2 Twist memory checking.
pub fn prove_stage2<Tr: Transcript>(
    trace_rows: &[[F; 24]],
    aux: &[KernelStepAux],
    initial_registers: &[u8; 16],
    initial_i: u16,
    initial_ram: &[u8],
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<Stage2TwistProof, SimpleKernelError> {
    let trace_len = 1usize << cycle_bits;
    if aux.len() != trace_len {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "aux length {} != trace_len {}",
            aux.len(),
            trace_len
        )));
    }

    let r_cycle = squeeze_point(transcript, b"stage2/r_cycle", cycle_bits);
    let eq_cycle = build_eq_table(&r_cycle);
    let lane_values_at_twist = lane_values_at_cycle(trace_rows, &r_cycle);
    let handoff_values_at_twist = handoff_values_at_cycle(aux, &r_cycle);

    let reg_proof = prove_register_subsystem(
        trace_rows,
        aux,
        initial_registers,
        initial_i,
        cycle_bits,
        &r_cycle,
        &eq_cycle,
        &lane_values_at_twist,
        &handoff_values_at_twist,
        transcript,
    )?;

    let reg_wa_mapped_claim =
        reg_proof.reg_wa_addr_target_proof.claim + lane_values_at_twist[9] * K::from(F::from_u64(16u64));
    let ram_proof = prove_ram_subsystem(
        trace_rows,
        aux,
        initial_ram,
        cycle_bits,
        &r_cycle,
        &eq_cycle,
        &lane_values_at_twist,
        &handoff_values_at_twist,
        reg_proof.reg_ra_y_target_proof.claim,
        reg_wa_mapped_claim,
        transcript,
    )?;

    let reg_x_next_vals = col_values(trace_rows, COL_REG_X_NEXT);
    let i_next_vals = col_values(trace_rows, COL_I_NEXT);
    let mem_value_vals = col_values(trace_rows, COL_MEM_VALUE);
    let reg_x_vals = col_values(trace_rows, COL_REG_X);
    let writes_lookup_to_x = col_values(trace_rows, COL_WRITES_LOOKUP_TO_X);
    let writes_mem_to_x = col_values(trace_rows, COL_WRITES_MEM_TO_X);
    let writes_nnn_to_i = col_values(trace_rows, COL_WRITES_NNN_TO_I);
    let write_x_target_flag: Vec<K> = writes_lookup_to_x
        .iter()
        .zip(writes_mem_to_x.iter())
        .map(|(&lookup, &mem)| lookup + mem)
        .collect();
    let reads_ram_vals = bool_values_from_aux(aux, |row| row.reads_ram);
    let writes_ram_vals = bool_values_from_aux(aux, |row| row.writes_ram);
    let idle_ram_flag: Vec<K> = reads_ram_vals
        .iter()
        .zip(writes_ram_vals.iter())
        .map(|(&reads, &writes)| K::ONE - reads - writes)
        .collect();
    let mem_minus_reg_x: Vec<K> = mem_value_vals
        .iter()
        .zip(reg_x_vals.iter())
        .map(|(&mem, &reg_x)| mem - reg_x)
        .collect();

    let reg_write_x_target_proof = prove_cycle_product_relation(
        transcript,
        vec![eq_cycle.clone(), write_x_target_flag, reg_x_next_vals],
        3,
        b"stage2/reg_write_x_target/claim",
        "reg_write_x_target",
    )?;
    let reg_write_i_target_proof = prove_cycle_product_relation(
        transcript,
        vec![eq_cycle.clone(), writes_nnn_to_i, i_next_vals],
        3,
        b"stage2/reg_write_i_target/claim",
        "reg_write_i_target",
    )?;
    let ram_read_target_proof = prove_cycle_product_relation(
        transcript,
        vec![eq_cycle.clone(), reads_ram_vals.clone(), mem_value_vals.clone()],
        3,
        b"stage2/ram_read_target/claim",
        "ram_read_target",
    )?;
    let ram_write_target_proof = prove_cycle_product_relation(
        transcript,
        vec![eq_cycle.clone(), writes_ram_vals.clone(), mem_value_vals.clone()],
        3,
        b"stage2/ram_write_target/claim",
        "ram_write_target",
    )?;
    let ram_write_matches_x_zero_proof = prove_cycle_product_relation(
        transcript,
        vec![eq_cycle.clone(), writes_ram_vals.clone(), mem_minus_reg_x],
        3,
        b"stage2/ram_write_matches_x_zero/claim",
        "ram_write_matches_x_zero",
    )?;
    if ram_write_matches_x_zero_proof.claim != K::ZERO {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 write-RAM MEM_VALUE must equal REG_X on active write rows".into(),
        ));
    }
    let ram_idle_mem_zero_proof = prove_cycle_product_relation(
        transcript,
        vec![eq_cycle.clone(), idle_ram_flag, mem_value_vals],
        3,
        b"stage2/ram_idle_mem_zero/claim",
        "ram_idle_mem_zero",
    )?;
    if ram_idle_mem_zero_proof.claim != K::ZERO {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage2 MEM_VALUE must be zero on non-RAM rows".into(),
        ));
    }
    let gamma_twist_link = squeeze_k(transcript, b"stage2/gamma_twist_link");

    let reg_x = lane_values_at_twist[0];
    let reg_y = lane_values_at_twist[1];
    let i_reg = lane_values_at_twist[3];

    let linkage_terms = [
        reg_proof.rv_x_claim - reg_x,
        reg_proof.rv_y_claim - reg_y,
        reg_proof.rv_i_claim - i_reg,
        reg_proof.wv_reg_claim - (reg_write_x_target_proof.claim + reg_write_i_target_proof.claim),
        ram_proof.rv_ram_claim - ram_read_target_proof.claim,
        ram_proof.wv_ram_claim - ram_write_target_proof.claim,
        ram_write_matches_x_zero_proof.claim,
        ram_idle_mem_zero_proof.claim,
    ];
    let mut linkage_batch_value = K::ZERO;
    let mut gamma_power = K::ONE;
    for term in linkage_terms {
        linkage_batch_value += gamma_power * term;
        gamma_power *= gamma_twist_link;
    }
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

    Ok(Stage2TwistProof {
        cycle_point: r_cycle,
        reg_addr_point: reg_proof.reg_addr_point,
        reg_val_at_point: reg_proof.reg_val_at_point,
        ram_addr_point: ram_proof.ram_addr_point,
        ram_val_at_point: ram_proof.ram_val_at_point,
        gamma_reg: reg_proof.gamma_reg,
        reg_rw_batched_rounds: reg_proof.reg_rw_batched_rounds,
        reg_val_from_inc_claim: reg_proof.reg_val_from_inc_claim,
        reg_val_from_inc_rounds: reg_proof.reg_val_from_inc_rounds,
        reg_addr_correctness: reg_proof.reg_addr_correctness,
        gamma_ram: ram_proof.gamma_ram,
        ram_rw_batched_rounds: ram_proof.ram_rw_batched_rounds,
        ram_val_from_inc_claim: ram_proof.ram_val_from_inc_claim,
        ram_val_from_inc_rounds: ram_proof.ram_val_from_inc_rounds,
        ram_raf_read_claim: ram_proof.ram_raf_read_claim,
        ram_raf_read_rounds: ram_proof.ram_raf_read_rounds,
        ram_raf_write_claim: ram_proof.ram_raf_write_claim,
        ram_raf_write_rounds: ram_proof.ram_raf_write_rounds,
        reg_ra_y_target_proof: reg_proof.reg_ra_y_target_proof,
        reg_wa_addr_target_proof: reg_proof.reg_wa_addr_target_proof,
        reg_write_x_target_proof,
        reg_write_i_target_proof,
        ram_read_target_proof,
        ram_write_target_proof,
        ram_write_matches_x_zero_proof,
        ram_idle_mem_zero_proof,
        ram_addr_correctness: ram_proof.ram_addr_correctness,
        link_claims: Stage2LinkClaims {
            rv_x: reg_proof.rv_x_claim,
            rv_y: reg_proof.rv_y_claim,
            rv_i: reg_proof.rv_i_claim,
            wv_reg: reg_proof.wv_reg_claim,
            rv_ram: ram_proof.rv_ram_claim,
            wv_ram: ram_proof.wv_ram_claim,
        },
        gamma_twist_link,
        linkage_batch_value,
        lane_values_at_twist,
        handoff_values_at_twist,
    })
}

use neo_math::{KExtensions, F, K};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use crate::chip8::poly::{
    eq_eval_le, mle_eval_f_be, mle_eval_f_le, mle_eval_k_be, open_onehot_at_point_be_be, open_onehot_at_point_le,
};
use crate::chip8::spec::{
    COL_I_NEXT, COL_MEM_VALUE, COL_REG_X, COL_REG_X_NEXT, COL_WRITES_LOOKUP_TO_X, COL_WRITES_MEM_TO_X,
    COL_WRITES_NNN_TO_I, COL_X_IDX, COL_Y_IDX, WITNESS_WIDTH,
};
use crate::chip8::stage2::{
    stage2_execution_surface_from_proof, AddressCorrectnessProof, Stage2DerivedExecutionSurface,
    Stage2RamExecutionProof, Stage2RegisterExecutionProof, Stage2TwistProof,
};
use crate::chip8::tables::{build_unmap_ram, build_unmap_reg, RAM_SINK_ADDR, REG_SINK_ADDR};

use super::super::verify_common::verify_sumcheck_known_with_terminal;
use super::super::{expect_equal_k, expect_equal_k_slice, KernelStepAux, SimpleKernelError};
use super::{
    build_lt_table, initial_ram_domain, initial_reg_domain, lane_col, lifted_bools, raw_index_mle_le, sample_k,
    sample_point, split_stage2_total_point, value_surface_at_point_le, ADDR_RAM_BITS, ADDR_REG_BITS,
};

fn verify_stage2_address_terminals<Tr: Transcript>(
    transcript: &mut Tr,
    proof: &AddressCorrectnessProof,
    cycle_bits: usize,
    addr_bits: usize,
    selector_addrs: &[usize],
    cycle_point: &[K],
    mapped_claim: K,
    raw_claim: K,
    mapped_coeffs: &[F],
    label: &str,
) -> Result<(), SimpleKernelError> {
    let (bool_point, bool_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        2,
        K::ZERO,
        &proof.booleanity_rounds,
        &format!("{label} booleanity"),
    )?;
    let (bool_cycle_point, bool_addr_point) = split_stage2_total_point(&bool_point, cycle_bits, addr_bits)?;
    let bool_selector = open_onehot_at_point_le(selector_addrs, bool_addr_point, bool_cycle_point);
    expect_equal_k(
        bool_terminal,
        bool_selector * (bool_selector - K::ONE),
        &format!("{label} booleanity terminal"),
    )?;

    let (hamming_point, hamming_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        1,
        K::ONE,
        &proof.hamming_weight_rounds,
        &format!("{label} hamming weight"),
    )?;
    let hamming_selector = open_onehot_at_point_le(selector_addrs, &hamming_point, cycle_point);
    expect_equal_k(hamming_terminal, hamming_selector, &format!("{label} hamming terminal"))?;

    let (mapped_point, mapped_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        2,
        mapped_claim,
        &proof.decode_consistency_rounds,
        &format!("{label} decode consistency"),
    )?;
    let mapped_selector = open_onehot_at_point_le(selector_addrs, &mapped_point, cycle_point);
    expect_equal_k(
        mapped_terminal,
        mapped_selector * mle_eval_f_le(mapped_coeffs, &mapped_point),
        &format!("{label} mapped terminal"),
    )?;

    let (raw_point, raw_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        2,
        raw_claim,
        &proof.raw_address_rounds,
        &format!("{label} raw address"),
    )?;
    let raw_selector = open_onehot_at_point_le(selector_addrs, &raw_point, cycle_point);
    expect_equal_k(
        raw_terminal,
        raw_selector * raw_index_mle_le(&raw_point),
        &format!("{label} raw terminal"),
    )?;
    Ok(())
}

pub(crate) fn verify_kernel_stage2_sumcheck_terminals_from_execution(
    register: &Stage2RegisterExecutionProof,
    memory: &Stage2RamExecutionProof,
    surface: &Stage2DerivedExecutionSurface,
    trace_rows: &[[F; WITNESS_WIDTH]],
    aux: &[KernelStepAux],
    initial_registers: &[u8; 16],
    initial_i: u16,
    initial_ram: &[u8],
    transcript: &mut Poseidon2Transcript,
) -> Result<(), SimpleKernelError> {
    let cycle_bits = surface.cycle_point.len();
    let trace_len = 1usize << cycle_bits;
    if aux.len() != trace_len {
        return Err(SimpleKernelError::SumcheckFailed(format!(
            "stage2 aux length {} != expected trace length {trace_len}",
            aux.len()
        )));
    }

    let reg_initial = initial_reg_domain(initial_registers, initial_i);
    let ram_initial = initial_ram_domain(initial_ram);
    let reg_inc: Vec<F> = aux.iter().map(|step| step.reg_inc).collect();
    let ram_inc: Vec<F> = aux.iter().map(|step| step.ram_inc).collect();
    let reg_ra_x_addrs: Vec<_> = aux.iter().map(|step| step.reg_ra_x_addr).collect();
    let reg_ra_y_addrs: Vec<_> = aux.iter().map(|step| step.reg_ra_y_addr).collect();
    let reg_ra_i_addrs: Vec<_> = aux.iter().map(|step| step.reg_ra_i_addr).collect();
    let reg_wa_addrs: Vec<_> = aux.iter().map(|step| step.reg_wa_addr).collect();
    let ram_ra_addrs: Vec<_> = aux.iter().map(|step| step.ram_ra_addr).collect();
    let ram_wa_addrs: Vec<_> = aux.iter().map(|step| step.ram_wa_addr).collect();

    let writes_lookup_to_x = lane_col(trace_rows, COL_WRITES_LOOKUP_TO_X);
    let writes_mem_to_x = lane_col(trace_rows, COL_WRITES_MEM_TO_X);
    let writes_nnn_to_i = lane_col(trace_rows, COL_WRITES_NNN_TO_I);
    let x_idx_vals = lane_col(trace_rows, COL_X_IDX);
    let y_idx_vals = lane_col(trace_rows, COL_Y_IDX);
    let reg_x_next_vals = lane_col(trace_rows, COL_REG_X_NEXT);
    let i_next_vals = lane_col(trace_rows, COL_I_NEXT);
    let mem_value_vals = lane_col(trace_rows, COL_MEM_VALUE);
    let reg_x_vals = lane_col(trace_rows, COL_REG_X);
    let uses_y_vals = lifted_bools(aux, |row| row.uses_y);
    let reads_ram_vals = lifted_bools(aux, |row| row.reads_ram);
    let writes_ram_vals = lifted_bools(aux, |row| row.writes_ram);
    let write_x_target_flag: Vec<F> = writes_lookup_to_x
        .iter()
        .zip(writes_mem_to_x.iter())
        .map(|(&lookup, &mem)| lookup + mem)
        .collect();
    let idle_ram_flag: Vec<F> = reads_ram_vals
        .iter()
        .zip(writes_ram_vals.iter())
        .map(|(&reads, &writes)| F::ONE - reads - writes)
        .collect();
    let mem_minus_reg_x: Vec<F> = mem_value_vals
        .iter()
        .zip(reg_x_vals.iter())
        .map(|(&mem, &reg_x)| mem - reg_x)
        .collect();
    let unmap_reg = build_unmap_reg();
    let unmap_ram = build_unmap_ram();

    let cycle_point = sample_point(transcript, b"stage2/r_cycle", cycle_bits);
    expect_equal_k_slice(&surface.cycle_point, &cycle_point, "stage2 cycle point")?;
    let _ = sample_k(transcript, b"stage2/gamma_reg");

    let reg_rw_claim = surface.link_claims.wv_reg
        + surface.gamma_reg * surface.link_claims.rv_x
        + surface.gamma_reg * surface.gamma_reg * surface.link_claims.rv_y
        + surface.gamma_reg * surface.gamma_reg * surface.gamma_reg * surface.link_claims.rv_i;
    transcript.append_fields(b"stage2/reg_rw_claim", &reg_rw_claim.as_coeffs());
    let (reg_rw_point, reg_rw_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        reg_rw_claim,
        &register.reg_rw_batched_rounds,
        "stage2 register read/write",
    )?;
    let (reg_rw_cycle_point, reg_rw_addr_point) = split_stage2_total_point(&reg_rw_point, cycle_bits, ADDR_REG_BITS)?;
    let reg_val_terminal = value_surface_at_point_le(
        reg_rw_addr_point,
        reg_rw_cycle_point,
        &reg_initial,
        &reg_wa_addrs,
        &reg_inc,
    );
    let reg_inc_terminal = mle_eval_f_le(&reg_inc, reg_rw_cycle_point);
    let reg_wa_terminal = open_onehot_at_point_le(&reg_wa_addrs, reg_rw_addr_point, reg_rw_cycle_point);
    let reg_ra_x_terminal = open_onehot_at_point_le(&reg_ra_x_addrs, reg_rw_addr_point, reg_rw_cycle_point);
    let reg_ra_y_terminal = open_onehot_at_point_le(&reg_ra_y_addrs, reg_rw_addr_point, reg_rw_cycle_point);
    let reg_ra_i_terminal = open_onehot_at_point_le(&reg_ra_i_addrs, reg_rw_addr_point, reg_rw_cycle_point);
    let reg_rw_expected = eq_eval_le(&surface.cycle_point, reg_rw_cycle_point)
        * (reg_wa_terminal * (reg_inc_terminal + reg_val_terminal)
            + surface.gamma_reg * reg_ra_x_terminal * reg_val_terminal
            + surface.gamma_reg * surface.gamma_reg * reg_ra_y_terminal * reg_val_terminal
            + surface.gamma_reg * surface.gamma_reg * surface.gamma_reg * reg_ra_i_terminal * reg_val_terminal);
    expect_equal_k(reg_rw_terminal, reg_rw_expected, "stage2 register read/write terminal")?;

    let _ = sample_point(transcript, b"stage2/r_addr_reg", ADDR_REG_BITS);
    transcript.append_fields(b"stage2/reg_val_inc_claim", &surface.reg_val_from_inc_claim.as_coeffs());
    let (reg_val_point, reg_val_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        surface.reg_val_from_inc_claim,
        &register.reg_val_from_inc_rounds,
        "stage2 register val-from-inc",
    )?;
    let reg_lt = build_lt_table(cycle_bits, &surface.cycle_point);
    let reg_val_expected = mle_eval_f_be(&reg_inc, &reg_val_point)
        * open_onehot_at_point_be_be(&reg_wa_addrs, &surface.reg_addr_point, &reg_val_point)
        * mle_eval_k_be(&reg_lt, &reg_val_point);
    expect_equal_k(
        reg_val_terminal,
        reg_val_expected,
        "stage2 register val-from-inc terminal",
    )?;

    transcript.append_fields(
        b"stage2/reg_ra_y_target/claim",
        &surface.reg_ra_y_target_claim.as_coeffs(),
    );
    let (reg_ra_y_target_point, reg_ra_y_target_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        surface.reg_ra_y_target_claim,
        &register.reg_ra_y_target_rounds,
        "stage2 register ra_y target",
    )?;
    let reg_ra_y_target_expected = eq_eval_le(&surface.cycle_point, &reg_ra_y_target_point)
        * mle_eval_f_le(&uses_y_vals, &reg_ra_y_target_point)
        * mle_eval_f_le(&y_idx_vals, &reg_ra_y_target_point);
    expect_equal_k(
        reg_ra_y_target_terminal,
        reg_ra_y_target_expected,
        "stage2 register ra_y target terminal",
    )?;

    transcript.append_fields(
        b"stage2/reg_wa_x_addr_target/claim",
        &surface.reg_wa_addr_target_claim.as_coeffs(),
    );
    let (reg_wa_target_point, reg_wa_target_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        surface.reg_wa_addr_target_claim,
        &register.reg_wa_addr_target_rounds,
        "stage2 register wa-address target",
    )?;
    let reg_wa_target_expected = eq_eval_le(&surface.cycle_point, &reg_wa_target_point)
        * mle_eval_f_le(&write_x_target_flag, &reg_wa_target_point)
        * mle_eval_f_le(&x_idx_vals, &reg_wa_target_point);
    expect_equal_k(
        reg_wa_target_terminal,
        reg_wa_target_expected,
        "stage2 register wa-address target terminal",
    )?;

    let reg_wa_mapped_claim =
        surface.reg_wa_addr_target_claim + surface.lane_values_at_twist[9] * K::from(F::from_u64(16u64));
    let mapped_reg_claims = [
        surface.lane_values_at_twist[11],
        surface.reg_ra_y_target_claim,
        K::from(F::from_u64(16u64)),
        reg_wa_mapped_claim,
    ];
    let raw_reg_claims = [
        mapped_reg_claims[0],
        mapped_reg_claims[1]
            + (K::ONE - surface.handoff_values_at_twist[0]) * K::from(F::from_u64(REG_SINK_ADDR as u64)),
        mapped_reg_claims[2],
        mapped_reg_claims[3]
            + (K::ONE
                - surface.lane_values_at_twist[6]
                - surface.lane_values_at_twist[7]
                - surface.lane_values_at_twist[9])
                * K::from(F::from_u64(REG_SINK_ADDR as u64)),
    ];
    verify_stage2_address_terminals(
        transcript,
        &register.reg_addr_correctness[0],
        cycle_bits,
        ADDR_REG_BITS,
        &reg_ra_x_addrs,
        &surface.cycle_point,
        mapped_reg_claims[0],
        raw_reg_claims[0],
        &unmap_reg,
        "stage2 register address family 0",
    )?;
    verify_stage2_address_terminals(
        transcript,
        &register.reg_addr_correctness[1],
        cycle_bits,
        ADDR_REG_BITS,
        &reg_ra_y_addrs,
        &surface.cycle_point,
        mapped_reg_claims[1],
        raw_reg_claims[1],
        &unmap_reg,
        "stage2 register address family 1",
    )?;
    verify_stage2_address_terminals(
        transcript,
        &register.reg_addr_correctness[2],
        cycle_bits,
        ADDR_REG_BITS,
        &reg_ra_i_addrs,
        &surface.cycle_point,
        mapped_reg_claims[2],
        raw_reg_claims[2],
        &unmap_reg,
        "stage2 register address family 2",
    )?;
    verify_stage2_address_terminals(
        transcript,
        &register.reg_addr_correctness[3],
        cycle_bits,
        ADDR_REG_BITS,
        &reg_wa_addrs,
        &surface.cycle_point,
        mapped_reg_claims[3],
        raw_reg_claims[3],
        &unmap_reg,
        "stage2 register address family 3",
    )?;

    let _ = sample_k(transcript, b"stage2/gamma_ram");
    let ram_rw_claim = surface.link_claims.rv_ram + surface.gamma_ram * surface.link_claims.wv_ram;
    transcript.append_fields(b"stage2/ram_rw_claim", &ram_rw_claim.as_coeffs());
    let (ram_rw_point, ram_rw_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        ram_rw_claim,
        &memory.ram_rw_batched_rounds,
        "stage2 RAM read/write",
    )?;
    let (ram_rw_cycle_point, ram_rw_addr_point) = split_stage2_total_point(&ram_rw_point, cycle_bits, ADDR_RAM_BITS)?;
    let ram_val_terminal = value_surface_at_point_le(
        ram_rw_addr_point,
        ram_rw_cycle_point,
        &ram_initial,
        &ram_wa_addrs,
        &ram_inc,
    );
    let ram_inc_terminal = mle_eval_f_le(&ram_inc, ram_rw_cycle_point);
    let ram_ra_terminal = open_onehot_at_point_le(&ram_ra_addrs, ram_rw_addr_point, ram_rw_cycle_point);
    let ram_wa_terminal = open_onehot_at_point_le(&ram_wa_addrs, ram_rw_addr_point, ram_rw_cycle_point);
    let ram_rw_expected = eq_eval_le(&surface.cycle_point, ram_rw_cycle_point)
        * (ram_ra_terminal * ram_val_terminal
            + surface.gamma_ram * ram_wa_terminal * (ram_inc_terminal + ram_val_terminal));
    expect_equal_k(ram_rw_terminal, ram_rw_expected, "stage2 RAM read/write terminal")?;

    let _ = sample_point(transcript, b"stage2/r_addr_ram", ADDR_RAM_BITS);
    transcript.append_fields(b"stage2/ram_val_inc_claim", &surface.ram_val_from_inc_claim.as_coeffs());
    let (ram_val_point, ram_val_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        surface.ram_val_from_inc_claim,
        &memory.ram_val_from_inc_rounds,
        "stage2 RAM val-from-inc",
    )?;
    let ram_lt = build_lt_table(cycle_bits, &surface.cycle_point);
    let ram_val_expected = mle_eval_f_be(&ram_inc, &ram_val_point)
        * open_onehot_at_point_be_be(&ram_wa_addrs, &surface.ram_addr_point, &ram_val_point)
        * mle_eval_k_be(&ram_lt, &ram_val_point);
    expect_equal_k(ram_val_terminal, ram_val_expected, "stage2 RAM val-from-inc terminal")?;

    let (ram_raf_read_point, ram_raf_read_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        2,
        surface.ram_raf_read_claim,
        &memory.ram_raf_read_rounds,
        "stage2 RAM raf-read",
    )?;
    let ram_raf_read_expected = open_onehot_at_point_le(&ram_ra_addrs, &ram_raf_read_point, &surface.cycle_point)
        * mle_eval_f_le(&unmap_ram, &ram_raf_read_point);
    expect_equal_k(
        ram_raf_read_terminal,
        ram_raf_read_expected,
        "stage2 RAM raf-read terminal",
    )?;

    let (ram_raf_write_point, ram_raf_write_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        2,
        surface.ram_raf_write_claim,
        &memory.ram_raf_write_rounds,
        "stage2 RAM raf-write",
    )?;
    let ram_raf_write_expected = open_onehot_at_point_le(&ram_wa_addrs, &ram_raf_write_point, &surface.cycle_point)
        * mle_eval_f_le(&unmap_ram, &ram_raf_write_point);
    expect_equal_k(
        ram_raf_write_terminal,
        ram_raf_write_expected,
        "stage2 RAM raf-write terminal",
    )?;

    let mapped_ram_claims = [surface.ram_raf_read_claim, surface.ram_raf_write_claim];
    let raw_ram_claims = [
        mapped_ram_claims[0]
            + (K::ONE - surface.handoff_values_at_twist[1]) * K::from(F::from_u64(RAM_SINK_ADDR as u64)),
        mapped_ram_claims[1]
            + (K::ONE - surface.handoff_values_at_twist[2]) * K::from(F::from_u64(RAM_SINK_ADDR as u64)),
    ];
    verify_stage2_address_terminals(
        transcript,
        &memory.ram_addr_correctness[0],
        cycle_bits,
        ADDR_RAM_BITS,
        &ram_ra_addrs,
        &surface.cycle_point,
        mapped_ram_claims[0],
        raw_ram_claims[0],
        &unmap_ram,
        "stage2 RAM address family 0",
    )?;
    verify_stage2_address_terminals(
        transcript,
        &memory.ram_addr_correctness[1],
        cycle_bits,
        ADDR_RAM_BITS,
        &ram_wa_addrs,
        &surface.cycle_point,
        mapped_ram_claims[1],
        raw_ram_claims[1],
        &unmap_ram,
        "stage2 RAM address family 1",
    )?;

    transcript.append_fields(
        b"stage2/reg_write_x_target/claim",
        &surface.reg_write_x_target_claim.as_coeffs(),
    );
    let (reg_write_x_point, reg_write_x_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        surface.reg_write_x_target_claim,
        &register.reg_write_x_target_rounds,
        "stage2 register write-to-x target",
    )?;
    let reg_write_x_expected = eq_eval_le(&surface.cycle_point, &reg_write_x_point)
        * mle_eval_f_le(&write_x_target_flag, &reg_write_x_point)
        * mle_eval_f_le(&reg_x_next_vals, &reg_write_x_point);
    expect_equal_k(
        reg_write_x_terminal,
        reg_write_x_expected,
        "stage2 register write-to-x target terminal",
    )?;

    transcript.append_fields(
        b"stage2/reg_write_i_target/claim",
        &surface.reg_write_i_target_claim.as_coeffs(),
    );
    let (reg_write_i_point, reg_write_i_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        surface.reg_write_i_target_claim,
        &register.reg_write_i_target_rounds,
        "stage2 register write-to-i target",
    )?;
    let reg_write_i_expected = eq_eval_le(&surface.cycle_point, &reg_write_i_point)
        * mle_eval_f_le(&writes_nnn_to_i, &reg_write_i_point)
        * mle_eval_f_le(&i_next_vals, &reg_write_i_point);
    expect_equal_k(
        reg_write_i_terminal,
        reg_write_i_expected,
        "stage2 register write-to-i target terminal",
    )?;

    transcript.append_fields(
        b"stage2/ram_read_target/claim",
        &surface.ram_read_target_claim.as_coeffs(),
    );
    let (ram_read_point, ram_read_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        surface.ram_read_target_claim,
        &memory.ram_read_target_rounds,
        "stage2 RAM read target",
    )?;
    let ram_read_expected = eq_eval_le(&surface.cycle_point, &ram_read_point)
        * mle_eval_f_le(&reads_ram_vals, &ram_read_point)
        * mle_eval_f_le(&mem_value_vals, &ram_read_point);
    expect_equal_k(ram_read_terminal, ram_read_expected, "stage2 RAM read target terminal")?;

    transcript.append_fields(
        b"stage2/ram_write_target/claim",
        &surface.ram_write_target_claim.as_coeffs(),
    );
    let (ram_write_point, ram_write_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        surface.ram_write_target_claim,
        &memory.ram_write_target_rounds,
        "stage2 RAM write target",
    )?;
    let ram_write_expected = eq_eval_le(&surface.cycle_point, &ram_write_point)
        * mle_eval_f_le(&writes_ram_vals, &ram_write_point)
        * mle_eval_f_le(&mem_value_vals, &ram_write_point);
    expect_equal_k(
        ram_write_terminal,
        ram_write_expected,
        "stage2 RAM write target terminal",
    )?;

    transcript.append_fields(b"stage2/ram_write_matches_x_zero/claim", &K::ZERO.as_coeffs());
    let (ram_write_x_point, ram_write_x_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        K::ZERO,
        &memory.ram_write_matches_x_zero_rounds,
        "stage2 RAM write matches REG_X",
    )?;
    let ram_write_x_expected = eq_eval_le(&surface.cycle_point, &ram_write_x_point)
        * mle_eval_f_le(&writes_ram_vals, &ram_write_x_point)
        * mle_eval_f_le(&mem_minus_reg_x, &ram_write_x_point);
    expect_equal_k(
        ram_write_x_terminal,
        ram_write_x_expected,
        "stage2 RAM write matches REG_X terminal",
    )?;

    transcript.append_fields(b"stage2/ram_idle_mem_zero/claim", &K::ZERO.as_coeffs());
    let (ram_idle_point, ram_idle_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        K::ZERO,
        &memory.ram_idle_mem_zero_rounds,
        "stage2 MEM_VALUE zero on idle rows",
    )?;
    let ram_idle_expected = eq_eval_le(&surface.cycle_point, &ram_idle_point)
        * mle_eval_f_le(&idle_ram_flag, &ram_idle_point)
        * mle_eval_f_le(&mem_value_vals, &ram_idle_point);
    expect_equal_k(
        ram_idle_terminal,
        ram_idle_expected,
        "stage2 MEM_VALUE zero on idle rows terminal",
    )?;

    Ok(())
}

pub(crate) fn verify_kernel_stage2_sumcheck_terminals(
    proof: &Stage2TwistProof,
    trace_rows: &[[F; WITNESS_WIDTH]],
    aux: &[KernelStepAux],
    initial_registers: &[u8; 16],
    initial_i: u16,
    initial_ram: &[u8],
    transcript: &mut Poseidon2Transcript,
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
    verify_kernel_stage2_sumcheck_terminals_from_execution(
        &register,
        &memory,
        &surface,
        trace_rows,
        aux,
        initial_registers,
        initial_i,
        initial_ram,
        transcript,
    )
}

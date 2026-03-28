//! Owns verifier-side row reconstruction and manifest-backed opening authentication.

use neo_math::{F, K};
use p3_field::{PrimeCharacteristicRing, PrimeField64};

use crate::chip8::spec::{
    build_pad_row, CommitmentId, COL_BURST_LAST, COL_IS_BRANCH, COL_IS_JUMP, COL_IS_MEMOP, COL_I_NEXT, COL_I_REG,
    COL_KK, COL_LOOKUP_OUTPUT, COL_MEM_VALUE, COL_NNN_ADDR, COL_NNN_WORD, COL_PC, COL_PC_NEXT, COL_PRESERVES_X,
    COL_RAM_ADDR, COL_REG_X, COL_REG_X_NEXT, COL_REG_Y, COL_WRITES_LOOKUP_TO_X, COL_WRITES_MEM_TO_X,
    COL_WRITES_NNN_TO_I, COL_X_IDX, COL_Y_IDX, WITNESS_WIDTH,
};
use crate::chip8::tables::{
    decode_to_output, flatten_alu_key, flatten_eq4_key, LookupKind, OperandSelector, ADDR_REG_BITS, RAM_SINK_ADDR,
    REG_SINK_ADDR,
};
use crate::chip8::{
    stage1::{DECODE_HANDOFF_POLY_IDS, STAGE1_LANE_OPEN_COLS},
    stage2::{RAM_TWIST_POLY_IDS, REG_TWIST_POLY_IDS, STAGE2_LANE_OPEN_COLS},
    stage3::{RowBindingClaim, STAGE3_FINAL_BOUNDARY_COLS, STAGE3_SHIFT_OPEN_COLS, STAGE3_START_BOUNDARY_COLS},
};

use super::artifacts::build_semantic_row_from_row_binding;
use super::openings::{bits_point, lane_poly_ids, mle_eval_vec, open_onehot_at_point_be};
use super::verify_common::{expect_equal_k, expect_equal_k_slice, find_manifest_claim};
use super::{normalize_opening_pairs, KernelOpeningManifest, KernelStepAux, SimpleKernelError, SimpleKernelProof};

pub(crate) fn build_pad_aux(pad_pc_word: u16) -> KernelStepAux {
    KernelStepAux {
        fetch_addr: pad_pc_word as usize,
        decode_addr: 0x1000 | (2 * pad_pc_word),
        alu_key: flatten_alu_key(LookupKind::NoLookup, 0, 0),
        eq4_key: flatten_eq4_key(0, 0),
        reg_ra_x_addr: 0,
        reg_ra_y_addr: REG_SINK_ADDR,
        reg_ra_i_addr: 16,
        reg_wa_addr: REG_SINK_ADDR,
        ram_ra_addr: RAM_SINK_ADDR,
        ram_wa_addr: RAM_SINK_ADDR,
        reg_inc: F::ZERO,
        ram_inc: F::ZERO,
        uses_y: false,
        reads_ram: false,
        writes_ram: false,
    }
}

fn final_register_domain(
    initial_registers: &[u8; 16],
    initial_i: u16,
    aux: &[KernelStepAux],
) -> Result<Vec<F>, SimpleKernelError> {
    let mut state = vec![F::ZERO; 1usize << ADDR_REG_BITS];
    for (idx, &value) in initial_registers.iter().enumerate() {
        state[idx] = F::from_u64(value as u64);
    }
    state[16] = F::from_u64(initial_i as u64);
    for (row_index, step) in aux.iter().enumerate() {
        if step.reg_wa_addr >= state.len() {
            return Err(SimpleKernelError::InvalidWitness(format!(
                "row {row_index} reg_wa_addr {} escapes register domain {}",
                step.reg_wa_addr,
                state.len()
            )));
        }
        state[step.reg_wa_addr] += step.reg_inc;
    }
    Ok(state)
}

fn build_kernel_pad_row(pad_pc_word: u16, final_reg_state: &[F]) -> [F; WITNESS_WIDTH] {
    let mut row = build_pad_row(pad_pc_word);
    row[COL_REG_X] = final_reg_state[0];
    row[COL_REG_X_NEXT] = final_reg_state[0];
    row[COL_I_REG] = final_reg_state[16];
    row[COL_I_NEXT] = final_reg_state[16];
    row
}

pub(crate) fn pad_semantic_witness(
    semantic_trace_rows: &[[F; WITNESS_WIDTH]],
    semantic_aux_data: &[KernelStepAux],
    initial_registers: &[u8; 16],
    initial_i: u16,
    pad_pc_word: u16,
) -> Result<(Vec<[F; WITNESS_WIDTH]>, Vec<KernelStepAux>), SimpleKernelError> {
    if semantic_trace_rows.is_empty() {
        return Err(SimpleKernelError::InvalidWitness(
            "semantic trace must contain at least one row".into(),
        ));
    }
    if semantic_trace_rows.len() != semantic_aux_data.len() {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "semantic trace row count {} does not match aux row count {}",
            semantic_trace_rows.len(),
            semantic_aux_data.len()
        )));
    }

    let padded_len = semantic_trace_rows.len().next_power_of_two();
    let mut trace_rows = semantic_trace_rows.to_vec();
    let mut aux_data = semantic_aux_data.to_vec();
    let final_reg_state = final_register_domain(initial_registers, initial_i, semantic_aux_data)?;
    let pad_row = build_kernel_pad_row(pad_pc_word, &final_reg_state);
    let pad_aux = build_pad_aux(pad_pc_word);

    while trace_rows.len() < padded_len {
        trace_rows.push(pad_row);
        aux_data.push(pad_aux.clone());
    }

    Ok((trace_rows, aux_data))
}

pub(crate) fn reconstruct_trace_rows_and_aux(
    row_bindings: &[RowBindingClaim],
    semantic_rows: usize,
    padded_trace_length: usize,
    cycle_bits: usize,
    pad_pc_word: u16,
    rom_table: &[F],
    initial_registers: &[u8; 16],
    initial_i: u16,
    initial_ram: &[u8],
) -> Result<(Vec<[F; WITNESS_WIDTH]>, Vec<KernelStepAux>), SimpleKernelError> {
    if row_bindings.len() != semantic_rows {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "row-binding count {} != semantic row count {semantic_rows}",
            row_bindings.len()
        )));
    }
    if initial_ram.len() != RAM_SINK_ADDR {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "initial RAM length {} != expected {}",
            initial_ram.len(),
            RAM_SINK_ADDR
        )));
    }

    let semantic_trace_rows: Vec<_> = row_bindings
        .iter()
        .map(|row_binding| reconstruct_opened_row(row_binding, cycle_bits))
        .collect::<Result<_, _>>()?;
    let semantic_aux = derive_semantic_aux(&semantic_trace_rows, rom_table, initial_ram)?;
    let final_reg_state = final_register_domain(initial_registers, initial_i, &semantic_aux)?;

    let mut trace_rows = semantic_trace_rows;
    let mut aux = semantic_aux;
    while trace_rows.len() < padded_trace_length {
        trace_rows.push(build_kernel_pad_row(pad_pc_word, &final_reg_state));
        aux.push(build_pad_aux(pad_pc_word));
    }
    Ok((trace_rows, aux))
}

pub(crate) fn authenticate_kernel_openings(
    proof: &SimpleKernelProof,
    trace_rows: &[[F; WITNESS_WIDTH]],
    aux: &[KernelStepAux],
    rom_table: &[F],
    decode_table: &[Vec<F>],
    alu_table: &[F],
    eq4_table: &[F],
) -> Result<(), SimpleKernelError> {
    let manifest = &proof.kernel_opening_manifest;

    let stage1_lane = lane_values_at_point(trace_rows, &STAGE1_LANE_OPEN_COLS, &proof.stage1.cycle_point);
    expect_equal_k_slice(
        &proof.stage1.lane_values_at_lookup,
        &stage1_lane,
        "stage1 lane opening values",
    )?;
    authenticate_manifest_values(
        manifest,
        CommitmentId::Lane,
        &proof.stage1.cycle_point,
        &lane_poly_ids(&STAGE1_LANE_OPEN_COLS),
        &stage1_lane,
        "stage1 lane opening",
    )?;

    let stage1_handoff = decode_handoff_values_at_point(aux, &proof.stage1.cycle_point);
    expect_equal_k_slice(
        &proof.stage1.decode_handoff_values,
        &stage1_handoff,
        "stage1 decode handoff values",
    )?;
    authenticate_manifest_values(
        manifest,
        CommitmentId::DecodeHandoff,
        &proof.stage1.cycle_point,
        &DECODE_HANDOFF_POLY_IDS,
        &stage1_handoff,
        "stage1 decode handoff opening",
    )?;

    let fetch_addrs: Vec<_> = aux.iter().map(|step| step.fetch_addr).collect();
    let decode_addrs: Vec<_> = aux.iter().map(|step| step.decode_addr as usize).collect();
    let alu_addrs: Vec<_> = aux.iter().map(|step| step.alu_key as usize).collect();
    let eq4_addrs: Vec<_> = aux.iter().map(|step| step.eq4_key as usize).collect();
    let reg_ra_x_addrs: Vec<_> = aux.iter().map(|step| step.reg_ra_x_addr).collect();
    let reg_ra_y_addrs: Vec<_> = aux.iter().map(|step| step.reg_ra_y_addr).collect();
    let reg_ra_i_addrs: Vec<_> = aux.iter().map(|step| step.reg_ra_i_addr).collect();
    let reg_wa_addrs: Vec<_> = aux.iter().map(|step| step.reg_wa_addr).collect();
    let ram_ra_addrs: Vec<_> = aux.iter().map(|step| step.ram_ra_addr).collect();
    let ram_wa_addrs: Vec<_> = aux.iter().map(|step| step.ram_wa_addr).collect();

    let fetch_ra = open_onehot_at_point_be(
        &fetch_addrs,
        &proof.stage1.fetch_proof.addr_point,
        &proof.stage1.cycle_point,
    );
    expect_equal_k(
        proof.stage1.fetch_proof.address_opening_value,
        fetch_ra,
        "stage1 fetch address opening value",
    )?;
    authenticate_manifest_values(
        manifest,
        CommitmentId::FetchRa,
        &concat_points(&proof.stage1.fetch_proof.addr_point, &proof.stage1.cycle_point),
        &[0],
        &[fetch_ra],
        "stage1 fetch address opening",
    )?;

    let decode_ra = open_onehot_at_point_be(
        &decode_addrs,
        &proof.stage1.decode_proof.addr_point,
        &proof.stage1.cycle_point,
    );
    expect_equal_k(
        proof.stage1.decode_proof.address_opening_value,
        decode_ra,
        "stage1 decode address opening value",
    )?;
    authenticate_manifest_values(
        manifest,
        CommitmentId::DecodeRa,
        &concat_points(&proof.stage1.decode_proof.addr_point, &proof.stage1.cycle_point),
        &[0],
        &[decode_ra],
        "stage1 decode address opening",
    )?;

    let alu_ra = open_onehot_at_point_be(
        &alu_addrs,
        &proof.stage1.alu_proof.addr_point,
        &proof.stage1.cycle_point,
    );
    expect_equal_k(
        proof.stage1.alu_proof.address_opening_value,
        alu_ra,
        "stage1 ALU address opening value",
    )?;
    authenticate_manifest_values(
        manifest,
        CommitmentId::AluRa,
        &concat_points(&proof.stage1.alu_proof.addr_point, &proof.stage1.cycle_point),
        &[0],
        &[alu_ra],
        "stage1 ALU address opening",
    )?;

    let eq4_ra = open_onehot_at_point_be(
        &eq4_addrs,
        &proof.stage1.eq4_proof.addr_point,
        &proof.stage1.cycle_point,
    );
    expect_equal_k(
        proof.stage1.eq4_proof.address_opening_value,
        eq4_ra,
        "stage1 Eq4 address opening value",
    )?;
    authenticate_manifest_values(
        manifest,
        CommitmentId::Eq4Ra,
        &concat_points(&proof.stage1.eq4_proof.addr_point, &proof.stage1.cycle_point),
        &[0],
        &[eq4_ra],
        "stage1 Eq4 address opening",
    )?;

    let rom_open = vec![mle_eval_vec_be(rom_table, &proof.stage1.fetch_proof.addr_point)];
    expect_equal_k_slice(
        &proof.stage1.fetch_proof.table_opening_values,
        &rom_open,
        "stage1 ROM table opening values",
    )?;
    authenticate_manifest_values(
        manifest,
        CommitmentId::RomTable,
        &proof.stage1.fetch_proof.addr_point,
        &[0],
        &rom_open,
        "stage1 ROM table opening",
    )?;

    let decode_open: Vec<_> = decode_table
        .iter()
        .map(|column| mle_eval_vec_be(column, &proof.stage1.decode_proof.addr_point))
        .collect();
    expect_equal_k_slice(
        &proof.stage1.decode_proof.table_opening_values,
        &decode_open,
        "stage1 decode table opening values",
    )?;
    let decode_poly_ids: Vec<usize> = (0..decode_open.len()).collect();
    authenticate_manifest_values(
        manifest,
        CommitmentId::DecodeTable,
        &proof.stage1.decode_proof.addr_point,
        &decode_poly_ids,
        &decode_open,
        "stage1 decode table opening",
    )?;

    let alu_table_open = vec![mle_eval_vec_be(alu_table, &proof.stage1.alu_proof.addr_point[2..])];
    expect_equal_k_slice(
        &proof.stage1.alu_proof.table_opening_values,
        &alu_table_open,
        "stage1 ALU table opening values",
    )?;
    authenticate_manifest_values(
        manifest,
        CommitmentId::AluTable,
        &proof.stage1.alu_proof.addr_point[2..],
        &[0],
        &alu_table_open,
        "stage1 ALU table opening",
    )?;

    let eq4_table_open = vec![mle_eval_vec_be(eq4_table, &proof.stage1.eq4_proof.addr_point)];
    expect_equal_k_slice(
        &proof.stage1.eq4_proof.table_opening_values,
        &eq4_table_open,
        "stage1 Eq4 table opening values",
    )?;
    authenticate_manifest_values(
        manifest,
        CommitmentId::Eq4Table,
        &proof.stage1.eq4_proof.addr_point,
        &[0],
        &eq4_table_open,
        "stage1 Eq4 table opening",
    )?;

    let stage2_lane = lane_values_at_point(trace_rows, &STAGE2_LANE_OPEN_COLS, &proof.stage2.cycle_point);
    expect_equal_k_slice(
        &proof.stage2.lane_values_at_twist,
        &stage2_lane,
        "stage2 lane opening values",
    )?;
    authenticate_manifest_values(
        manifest,
        CommitmentId::Lane,
        &proof.stage2.cycle_point,
        &lane_poly_ids(&STAGE2_LANE_OPEN_COLS),
        &stage2_lane,
        "stage2 lane opening",
    )?;

    let stage2_handoff = decode_handoff_values_at_point(aux, &proof.stage2.cycle_point);
    expect_equal_k_slice(
        &proof.stage2.handoff_values_at_twist,
        &stage2_handoff,
        "stage2 decode handoff values",
    )?;
    authenticate_manifest_values(
        manifest,
        CommitmentId::DecodeHandoff,
        &proof.stage2.cycle_point,
        &DECODE_HANDOFF_POLY_IDS,
        &stage2_handoff,
        "stage2 decode handoff opening",
    )?;

    let reg_open = vec![
        mle_eval_vec(
            &aux.iter().map(|step| step.reg_inc).collect::<Vec<_>>(),
            &proof.stage2.cycle_point,
        ),
        open_onehot_at_point_be(&reg_ra_x_addrs, &proof.stage2.reg_addr_point, &proof.stage2.cycle_point),
        open_onehot_at_point_be(&reg_ra_y_addrs, &proof.stage2.reg_addr_point, &proof.stage2.cycle_point),
        open_onehot_at_point_be(&reg_ra_i_addrs, &proof.stage2.reg_addr_point, &proof.stage2.cycle_point),
        open_onehot_at_point_be(&reg_wa_addrs, &proof.stage2.reg_addr_point, &proof.stage2.cycle_point),
    ];
    authenticate_manifest_values(
        manifest,
        CommitmentId::RegTwist,
        &concat_points(&proof.stage2.reg_addr_point, &proof.stage2.cycle_point),
        &REG_TWIST_POLY_IDS,
        &reg_open,
        "stage2 register twist opening",
    )?;

    let ram_open = vec![
        mle_eval_vec(
            &aux.iter().map(|step| step.ram_inc).collect::<Vec<_>>(),
            &proof.stage2.cycle_point,
        ),
        open_onehot_at_point_be(&ram_ra_addrs, &proof.stage2.ram_addr_point, &proof.stage2.cycle_point),
        open_onehot_at_point_be(&ram_wa_addrs, &proof.stage2.ram_addr_point, &proof.stage2.cycle_point),
    ];
    authenticate_manifest_values(
        manifest,
        CommitmentId::RamTwist,
        &concat_points(&proof.stage2.ram_addr_point, &proof.stage2.cycle_point),
        &RAM_TWIST_POLY_IDS,
        &ram_open,
        "stage2 RAM twist opening",
    )?;

    let stage3_shift = lane_values_at_point(
        trace_rows,
        &STAGE3_SHIFT_OPEN_COLS,
        &proof.stage3.shift_proof.source_point,
    );
    expect_equal_k_slice(
        &proof.stage3.shift_opening_values,
        &stage3_shift,
        "stage3 shift opening values",
    )?;
    authenticate_manifest_values(
        manifest,
        CommitmentId::Lane,
        &proof.stage3.shift_proof.source_point,
        &lane_poly_ids(&STAGE3_SHIFT_OPEN_COLS),
        &stage3_shift,
        "stage3 shift opening",
    )?;

    let cycle_bits = proof.stage3.shift_proof.source_point.len();
    let start_point = vec![K::ZERO; cycle_bits];
    let stage3_start = lane_values_at_point(trace_rows, &STAGE3_START_BOUNDARY_COLS, &start_point);
    expect_equal_k_slice(
        &proof.stage3.start_boundary_values,
        &stage3_start,
        "stage3 start-boundary values",
    )?;
    authenticate_manifest_values(
        manifest,
        CommitmentId::Lane,
        &start_point,
        &lane_poly_ids(&STAGE3_START_BOUNDARY_COLS),
        &stage3_start,
        "stage3 start-boundary opening",
    )?;

    let final_point = bits_point(proof.stage3.row_bindings.len() - 1, cycle_bits);
    let stage3_final = lane_values_at_point(trace_rows, &STAGE3_FINAL_BOUNDARY_COLS, &final_point);
    expect_equal_k_slice(
        &proof.stage3.final_boundary_values,
        &stage3_final,
        "stage3 final-boundary values",
    )?;
    authenticate_manifest_values(
        manifest,
        CommitmentId::Lane,
        &final_point,
        &lane_poly_ids(&STAGE3_FINAL_BOUNDARY_COLS),
        &stage3_final,
        "stage3 final-boundary opening",
    )?;

    Ok(())
}

fn reconstruct_opened_row(
    row_binding: &RowBindingClaim,
    cycle_bits: usize,
) -> Result<[F; WITNESS_WIDTH], SimpleKernelError> {
    build_semantic_row_from_row_binding(row_binding, cycle_bits)
}

fn derive_semantic_aux(
    semantic_trace_rows: &[[F; WITNESS_WIDTH]],
    rom_table: &[F],
    initial_ram: &[u8],
) -> Result<Vec<KernelStepAux>, SimpleKernelError> {
    let mut memory = initial_ram.to_vec();
    let mut out = Vec::with_capacity(semantic_trace_rows.len());

    for (row_index, row) in semantic_trace_rows.iter().enumerate() {
        expect_row_value(row[0], 1, &format!("row {row_index} ONE"))?;
        let fetch_addr = decode_row_usize(row[COL_PC], &format!("row {row_index} PC"))?;
        let opcode = rom_table
            .get(fetch_addr)
            .ok_or_else(|| {
                SimpleKernelError::InvalidWitness(format!(
                    "row {row_index} PC {fetch_addr} escapes ROM table of length {}",
                    rom_table.len()
                ))
            })
            .and_then(|&value| decode_row_u16(value, &format!("row {row_index} ROM opcode")))?;
        let dec = decode_to_output(opcode);

        expect_row_value(row[COL_KK], dec.kk_dec as u64, &format!("row {row_index} KK"))?;
        expect_row_value(
            row[COL_NNN_ADDR],
            dec.nnn_addr_dec as u64,
            &format!("row {row_index} NNN_ADDR"),
        )?;
        expect_row_value(
            row[COL_NNN_WORD],
            dec.nnn_word_dec as u64,
            &format!("row {row_index} NNN_WORD"),
        )?;
        expect_row_bool(
            row[COL_WRITES_LOOKUP_TO_X],
            dec.writes_lookup_to_x,
            &format!("row {row_index} WritesLookupToX"),
        )?;
        expect_row_bool(
            row[COL_WRITES_MEM_TO_X],
            dec.writes_mem_to_x,
            &format!("row {row_index} WritesMemToX"),
        )?;
        expect_row_bool(
            row[COL_PRESERVES_X],
            dec.preserves_x,
            &format!("row {row_index} PreservesX"),
        )?;
        expect_row_bool(
            row[COL_WRITES_NNN_TO_I],
            dec.writes_nnn_to_i,
            &format!("row {row_index} WritesNnnToI"),
        )?;
        expect_row_bool(row[COL_IS_JUMP], dec.is_jump, &format!("row {row_index} IsJump"))?;
        expect_row_bool(row[COL_IS_BRANCH], dec.is_branch, &format!("row {row_index} IsBranch"))?;
        expect_row_bool(row[COL_IS_MEMOP], dec.is_memop, &format!("row {row_index} IsMemOp"))?;

        if !dec.uses_y {
            expect_row_value(row[COL_REG_Y], 0, &format!("row {row_index} REG_Y"))?;
        }

        let x_idx = decode_row_u8(row[COL_X_IDX], &format!("row {row_index} X_IDX"))?;
        let y_idx = decode_row_u8(row[COL_Y_IDX], &format!("row {row_index} Y_IDX"))?;
        let burst_last = decode_row_bool(row[COL_BURST_LAST], &format!("row {row_index} BURST_LAST"))?;
        let ram_addr = decode_row_usize(row[COL_RAM_ADDR], &format!("row {row_index} RAM_ADDR"))?;
        let mem_value = decode_row_u8(row[COL_MEM_VALUE], &format!("row {row_index} MEM_VALUE"))?;
        let reg_x = decode_row_u8(row[COL_REG_X], &format!("row {row_index} REG_X"))?;
        let reg_x_next = decode_row_u8(row[COL_REG_X_NEXT], &format!("row {row_index} REG_X_NEXT"))?;
        let i_reg = decode_row_u16(row[COL_I_REG], &format!("row {row_index} I_REG"))?;
        let i_next = decode_row_u16(row[COL_I_NEXT], &format!("row {row_index} I_NEXT"))?;
        let pc_word = decode_row_u16(row[COL_PC], &format!("row {row_index} PC"))?;
        let pc_next = decode_row_u16(row[COL_PC_NEXT], &format!("row {row_index} PC_NEXT"))?;

        if dec.is_memop {
            if x_idx > dec.x_bound {
                return Err(SimpleKernelError::InvalidWitness(format!(
                    "row {row_index} X_IDX {x_idx} exceeds burst bound {}",
                    dec.x_bound
                )));
            }
            expect_row_value(row[COL_Y_IDX], 0, &format!("row {row_index} Y_IDX"))?;
            expect_row_bool(
                row[COL_BURST_LAST],
                x_idx == dec.x_bound,
                &format!("row {row_index} BURST_LAST"),
            )?;
            let expected_ram_addr = i_reg as usize + x_idx as usize;
            if expected_ram_addr >= initial_ram.len() {
                return Err(SimpleKernelError::InvalidWitness(format!(
                    "row {row_index} RAM addr {expected_ram_addr} escapes initial RAM"
                )));
            }
            expect_row_value(
                row[COL_RAM_ADDR],
                expected_ram_addr as u64,
                &format!("row {row_index} RAM_ADDR"),
            )?;
            let expected_mem = if dec.is_store { reg_x } else { memory[expected_ram_addr] };
            if mem_value != expected_mem {
                return Err(SimpleKernelError::InvalidWitness(format!(
                    "row {row_index} MEM_VALUE {mem_value} != expected {expected_mem}"
                )));
            }
        } else {
            let expected_x = if dec.writes_lookup_to_x || dec.writes_mem_to_x || dec.is_branch {
                dec.x_dec
            } else {
                0
            };
            expect_row_value(row[COL_X_IDX], expected_x as u64, &format!("row {row_index} X_IDX"))?;
            let expected_y = if dec.uses_y { dec.y_dec } else { 0 };
            expect_row_value(row[COL_Y_IDX], expected_y as u64, &format!("row {row_index} Y_IDX"))?;
            expect_row_bool(row[COL_BURST_LAST], false, &format!("row {row_index} BURST_LAST"))?;
            expect_row_value(row[COL_RAM_ADDR], 0, &format!("row {row_index} RAM_ADDR"))?;
            expect_row_value(row[COL_MEM_VALUE], 0, &format!("row {row_index} MEM_VALUE"))?;
        }

        let lookup_output = compute_lookup_output(dec.lookup_kind, dec.lhs_selector, dec.rhs_selector, row, row_index)?;
        expect_row_value(
            row[COL_LOOKUP_OUTPUT],
            lookup_output as u64,
            &format!("row {row_index} LOOKUP_OUTPUT"),
        )?;

        let expected_reg_x_next = if dec.is_memop {
            if dec.is_load {
                mem_value
            } else {
                reg_x
            }
        } else if dec.writes_lookup_to_x {
            lookup_output as u8
        } else {
            reg_x
        };
        if reg_x_next != expected_reg_x_next {
            return Err(SimpleKernelError::InvalidWitness(format!(
                "row {row_index} REG_X_NEXT {reg_x_next} != expected {expected_reg_x_next}"
            )));
        }

        let expected_i_next = if dec.writes_nnn_to_i { dec.nnn_addr_dec } else { i_reg };
        if i_next != expected_i_next {
            return Err(SimpleKernelError::InvalidWitness(format!(
                "row {row_index} I_NEXT {i_next} != expected {expected_i_next}"
            )));
        }

        let expected_pc_next = if dec.is_memop {
            if burst_last {
                pc_word.checked_add(1).ok_or_else(|| {
                    SimpleKernelError::InvalidWitness(format!("row {row_index} PC overflows on final burst step"))
                })?
            } else {
                pc_word
            }
        } else if dec.is_jump {
            dec.nnn_word_dec
        } else if dec.is_branch {
            pc_word
                .checked_add(if lookup_output == 1 { 2 } else { 1 })
                .ok_or_else(|| {
                    SimpleKernelError::InvalidWitness(format!("row {row_index} PC overflows on branch step"))
                })?
        } else {
            pc_word.checked_add(1).ok_or_else(|| {
                SimpleKernelError::InvalidWitness(format!("row {row_index} PC overflows on sequential step"))
            })?
        };
        if pc_next != expected_pc_next {
            return Err(SimpleKernelError::InvalidWitness(format!(
                "row {row_index} PC_NEXT {pc_next} != expected {expected_pc_next}"
            )));
        }

        let lhs = operand_from_row(dec.lhs_selector, row, row_index)?;
        let rhs = operand_from_row(dec.rhs_selector, row, row_index)?;
        let reg_ra_x_addr = x_idx as usize;
        let reg_ra_y_addr = if dec.is_memop {
            REG_SINK_ADDR
        } else if dec.uses_y {
            y_idx as usize
        } else {
            REG_SINK_ADDR
        };
        let reg_wa_addr = if dec.is_memop {
            if dec.is_load {
                x_idx as usize
            } else {
                REG_SINK_ADDR
            }
        } else if dec.writes_lookup_to_x || dec.writes_mem_to_x {
            x_idx as usize
        } else if dec.writes_nnn_to_i {
            16
        } else {
            REG_SINK_ADDR
        };
        let (ram_ra_addr, ram_wa_addr) = if dec.is_memop {
            if dec.reads_ram {
                (ram_addr, RAM_SINK_ADDR)
            } else {
                (RAM_SINK_ADDR, ram_addr)
            }
        } else {
            (RAM_SINK_ADDR, RAM_SINK_ADDR)
        };
        let reg_inc = if dec.is_memop {
            if dec.is_load {
                row[COL_REG_X_NEXT] - row[COL_REG_X]
            } else {
                F::ZERO
            }
        } else if dec.writes_lookup_to_x || dec.writes_mem_to_x {
            row[COL_REG_X_NEXT] - row[COL_REG_X]
        } else if dec.writes_nnn_to_i {
            row[COL_I_NEXT] - row[COL_I_REG]
        } else {
            F::ZERO
        };
        let ram_inc = if dec.is_memop && dec.is_store {
            F::from_u64(mem_value as u64) - F::from_u64(memory[ram_addr] as u64)
        } else {
            F::ZERO
        };

        if dec.is_memop && dec.is_store {
            memory[ram_addr] = mem_value;
        }

        out.push(KernelStepAux {
            fetch_addr,
            decode_addr: opcode,
            alu_key: flatten_alu_key(dec.lookup_kind, lhs, rhs),
            eq4_key: flatten_eq4_key(x_idx, dec.x_bound),
            reg_ra_x_addr,
            reg_ra_y_addr,
            reg_ra_i_addr: 16,
            reg_wa_addr,
            ram_ra_addr,
            ram_wa_addr,
            reg_inc,
            ram_inc,
            uses_y: dec.uses_y,
            reads_ram: dec.reads_ram,
            writes_ram: dec.writes_ram,
        });
    }

    Ok(out)
}

fn lane_values_at_point(trace_rows: &[[F; WITNESS_WIDTH]], cols: &[usize], point: &[K]) -> Vec<K> {
    cols.iter()
        .map(|&col| mle_eval_vec(&trace_rows.iter().map(|row| row[col]).collect::<Vec<_>>(), point))
        .collect()
}

fn mle_eval_vec_be(values: &[F], point_be: &[K]) -> K {
    let point_le: Vec<K> = point_be.iter().rev().copied().collect();
    mle_eval_vec(values, &point_le)
}

fn decode_handoff_values_at_point(aux: &[KernelStepAux], point: &[K]) -> Vec<K> {
    vec![
        mle_eval_vec(
            &aux.iter()
                .map(|step| if step.uses_y { F::ONE } else { F::ZERO })
                .collect::<Vec<_>>(),
            point,
        ),
        mle_eval_vec(
            &aux.iter()
                .map(|step| if step.reads_ram { F::ONE } else { F::ZERO })
                .collect::<Vec<_>>(),
            point,
        ),
        mle_eval_vec(
            &aux.iter()
                .map(|step| if step.writes_ram { F::ONE } else { F::ZERO })
                .collect::<Vec<_>>(),
            point,
        ),
    ]
}

fn authenticate_manifest_values(
    manifest: &KernelOpeningManifest,
    commitment_id: CommitmentId,
    point: &[K],
    polynomial_ids: &[usize],
    expected: &[K],
    label: &str,
) -> Result<(), SimpleKernelError> {
    let (normalized_polynomial_ids, normalized_expected) = normalize_opening_pairs(polynomial_ids, expected);
    expect_equal_k_slice(
        &find_manifest_claim(manifest, commitment_id, point, &normalized_polynomial_ids, label)?.claimed_values,
        &normalized_expected,
        &format!("{label} values"),
    )
}

fn concat_points(prefix: &[K], suffix: &[K]) -> Vec<K> {
    prefix
        .iter()
        .copied()
        .chain(suffix.iter().copied())
        .collect()
}

fn compute_lookup_output(
    kind: LookupKind,
    lhs_sel: OperandSelector,
    rhs_sel: OperandSelector,
    row: &[F; WITNESS_WIDTH],
    row_index: usize,
) -> Result<u16, SimpleKernelError> {
    let lhs = operand_from_row(lhs_sel, row, row_index)?;
    let rhs = operand_from_row(rhs_sel, row, row_index)?;
    Ok(match kind {
        LookupKind::Identity => lhs as u16,
        LookupKind::Add8Lo => (lhs as u16 + rhs as u16) % 256,
        LookupKind::Equal8 => {
            if lhs == rhs {
                1
            } else {
                0
            }
        }
        LookupKind::NoLookup => 0,
    })
}

fn operand_from_row(
    selector: OperandSelector,
    row: &[F; WITNESS_WIDTH],
    row_index: usize,
) -> Result<u8, SimpleKernelError> {
    match selector {
        OperandSelector::RegX => decode_row_u8(row[COL_REG_X], &format!("row {row_index} REG_X")),
        OperandSelector::RegY => decode_row_u8(row[COL_REG_Y], &format!("row {row_index} REG_Y")),
        OperandSelector::Kk => decode_row_u8(row[COL_KK], &format!("row {row_index} KK")),
        OperandSelector::Zero => Ok(0),
    }
}

fn expect_row_bool(actual: F, expected: bool, label: &str) -> Result<(), SimpleKernelError> {
    expect_row_value(actual, u64::from(expected), label)
}

fn expect_row_value(actual: F, expected: u64, label: &str) -> Result<(), SimpleKernelError> {
    if actual == F::from_u64(expected) {
        Ok(())
    } else {
        Err(SimpleKernelError::InvalidWitness(format!(
            "{label} mismatch: got {}, expected {expected}",
            actual.as_canonical_u64()
        )))
    }
}

fn decode_row_bool(value: F, label: &str) -> Result<bool, SimpleKernelError> {
    match decode_row_u64(value, label)? {
        0 => Ok(false),
        1 => Ok(true),
        other => Err(SimpleKernelError::InvalidWitness(format!(
            "{label} has invalid boolean value {other}"
        ))),
    }
}

fn decode_row_usize(value: F, label: &str) -> Result<usize, SimpleKernelError> {
    usize::try_from(decode_row_u64(value, label)?)
        .map_err(|_| SimpleKernelError::InvalidWitness(format!("{label} does not fit in usize")))
}

fn decode_row_u16(value: F, label: &str) -> Result<u16, SimpleKernelError> {
    u16::try_from(decode_row_u64(value, label)?)
        .map_err(|_| SimpleKernelError::InvalidWitness(format!("{label} does not fit in u16")))
}

fn decode_row_u8(value: F, label: &str) -> Result<u8, SimpleKernelError> {
    u8::try_from(decode_row_u64(value, label)?)
        .map_err(|_| SimpleKernelError::InvalidWitness(format!("{label} does not fit in u8")))
}

fn decode_row_u64(value: F, _label: &str) -> Result<u64, SimpleKernelError> {
    Ok(value.as_canonical_u64())
}

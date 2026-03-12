use super::*;

pub(crate) fn decode_lookup_open_map_from_committed_openings(
    step: &StepInstanceBundle<Cmt, F, K>,
    cpu_bus: &BusLayout,
    point: &[K],
    step_time_openings: &[crate::shard_proof_types::TimePointOpening],
    label: &str,
) -> Result<BTreeMap<usize, K>, PiCcsError> {
    let decode_layout = Rv32DecodeSidecarLayout::new();
    let decode_open_cols = riscv_decode_lookup_transport_cols(&decode_layout);
    let bus_logical_cols = bus_logical_col_ids_for_step_instance(step, cpu_bus, label)?;
    let mut decode_col_to_logical = Vec::with_capacity(decode_open_cols.len());
    for &col_id in decode_open_cols.iter() {
        let table_id = riscv_decode_lookup_table_id_for_col(col_id);
        let val_slot = riscv_decode_lookup_val_slot_for_col(col_id).ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "{label}: decode col_id={col_id} is not part of decode lookup transport slot map"
            ))
        })?;
        let lut_idx = step
            .lut_insts
            .iter()
            .position(|inst| inst.table_id == table_id)
            .ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "{label}: missing decode lookup table_id={table_id} for col_id={col_id}"
                ))
            })?;
        let inst_cols = cpu_bus
            .shout_cols
            .get(lut_idx)
            .ok_or_else(|| PiCcsError::ProtocolError(format!("{label}: missing shout cols for lut_idx={lut_idx}")))?;
        let lane0 = inst_cols.lanes.first().ok_or_else(|| {
            PiCcsError::ProtocolError(format!("{label}: expected one shout lane for lut_idx={lut_idx}"))
        })?;
        let mem_local_col = lane0.vals.get(val_slot).copied().ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "{label}: decode val_slot={} out of range for lut_idx={} (n_vals={})",
                val_slot,
                lut_idx,
                lane0.vals.len()
            ))
        })?;
        let logical_col = bus_logical_cols
            .get(mem_local_col)
            .copied()
            .ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "{label}: bus local col {} out of range (bus_cols={})",
                    mem_local_col,
                    bus_logical_cols.len()
                ))
            })?;
        decode_col_to_logical.push((col_id, logical_col));
    }
    let mut required_logical: Vec<usize> = decode_col_to_logical
        .iter()
        .map(|(_, logical)| *logical)
        .collect();
    required_logical.sort_unstable();
    required_logical.dedup();
    let (_entry, logical_map) =
        require_time_openings_covering_point(step_time_openings, point, &required_logical, label)?;

    let mut decode_open_map = BTreeMap::new();
    for (col_id, logical_col) in decode_col_to_logical {
        let v = logical_map.get(&logical_col).copied().ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "{label}: missing logical opening value for logical_col_id={logical_col}"
            ))
        })?;
        decode_open_map.insert(col_id, v);
    }
    Ok(decode_open_map)
}

pub(crate) fn verify_route_a_decode_terminals(
    cpu_bus: &BusLayout,
    step: &StepInstanceBundle<Cmt, F, K>,
    r_time: &[K],
    r_cycle: &[K],
    batched_final_values: &[K],
    claim_plan: &RouteATimeClaimPlan,
    mem_proof: &MemSidecarProof<Cmt, F, K>,
    step_time_openings: &[crate::shard_proof_types::TimePointOpening],
) -> Result<(), PiCcsError> {
    if claim_plan.decode_fields.is_none() && claim_plan.decode_immediates.is_none() {
        return Ok(());
    }

    if mem_proof.booleanity_me_claims.len() != 1 {
        return Err(PiCcsError::ProtocolError(
            "decode requires booleanity ME openings for shared active/bit terminals".into(),
        ));
    }

    let decode_layout = Rv32DecodeSidecarLayout::new();
    if mem_proof.trace_opening_me_claims.len() != 1 {
        return Err(PiCcsError::ProtocolError(
            "decode requires trace-opening ME openings for shared main-trace/decode terminals".into(),
        ));
    }
    let trace_opening_me = &mem_proof.trace_opening_me_claims[0];
    if trace_opening_me.r.as_slice() != r_time {
        return Err(PiCcsError::ProtocolError(
            "decode trace-opening ME claim r mismatch (expected r_time)".into(),
        ));
    }
    if trace_opening_me.c != step.mcs_inst.c {
        return Err(PiCcsError::ProtocolError(
            "decode trace-opening ME claim commitment mismatch".into(),
        ));
    }
    if trace_opening_me.m_in != step.mcs_inst.m_in {
        return Err(PiCcsError::ProtocolError(
            "decode trace-opening ME claim m_in mismatch".into(),
        ));
    }
    let trace = Rv32TraceLayout::new();
    let booleanity_me = &mem_proof.booleanity_me_claims[0];
    let booleanity_cols = riscv_trace_booleanity_columns(&trace);
    let booleanity_opening_map = require_time_openings_for_point(
        step_time_openings,
        booleanity_me.r.as_slice(),
        &booleanity_cols,
        "decode booleanity",
    )?;
    let booleanity_opening_col = |col_id: usize| -> Result<K, PiCcsError> {
        named_opening(&booleanity_opening_map, col_id, "decode booleanity")
    };

    let trace_opening_cols = riscv_trace_opening_columns(&trace);
    let (_trace_opening_entry, trace_opening_map) = require_time_openings_covering_point(
        step_time_openings,
        trace_opening_me.r.as_slice(),
        &trace_opening_cols,
        "decode trace-opening",
    )?;
    let trace_opening_col =
        |col_id: usize| -> Result<K, PiCcsError> { named_opening(&trace_opening_map, col_id, "decode trace-opening") };
    let decode_open_map =
        decode_lookup_open_map_from_committed_openings(step, cpu_bus, r_time, step_time_openings, "decode decode")?;
    let decode_open_col =
        |col_id: usize| -> Result<K, PiCcsError> { named_opening(&decode_open_map, col_id, "decode decode") };

    if let Some(claim_idx) = claim_plan.decode_fields {
        if claim_idx >= batched_final_values.len() {
            return Err(PiCcsError::ProtocolError(
                "decode/fields claim index out of range".into(),
            ));
        }
        let opcode_flags = [
            decode_open_col(decode_layout.op_lui)?,
            decode_open_col(decode_layout.op_auipc)?,
            decode_open_col(decode_layout.op_jal)?,
            decode_open_col(decode_layout.op_jalr)?,
            decode_open_col(decode_layout.op_branch)?,
            decode_open_col(decode_layout.op_load)?,
            decode_open_col(decode_layout.op_store)?,
            decode_open_col(decode_layout.op_alu_imm)?,
            decode_open_col(decode_layout.op_alu_reg)?,
            decode_open_col(decode_layout.op_misc_mem)?,
            decode_open_col(decode_layout.op_system)?,
            decode_open_col(decode_layout.op_amo)?,
        ];
        let op_custom = decode_open_col(decode_layout.op_custom)?;
        let funct3_is = [
            decode_open_col(decode_layout.funct3_is[0])?,
            decode_open_col(decode_layout.funct3_is[1])?,
            decode_open_col(decode_layout.funct3_is[2])?,
            decode_open_col(decode_layout.funct3_is[3])?,
            decode_open_col(decode_layout.funct3_is[4])?,
            decode_open_col(decode_layout.funct3_is[5])?,
            decode_open_col(decode_layout.funct3_is[6])?,
            decode_open_col(decode_layout.funct3_is[7])?,
        ];
        let funct3_bits = [
            decode_open_col(decode_layout.funct3_bit[0])?,
            decode_open_col(decode_layout.funct3_bit[1])?,
            decode_open_col(decode_layout.funct3_bit[2])?,
        ];
        let funct7_bits = [
            decode_open_col(decode_layout.funct7_bit[0])?,
            decode_open_col(decode_layout.funct7_bit[1])?,
            decode_open_col(decode_layout.funct7_bit[2])?,
            decode_open_col(decode_layout.funct7_bit[3])?,
            decode_open_col(decode_layout.funct7_bit[4])?,
            decode_open_col(decode_layout.funct7_bit[5])?,
            decode_open_col(decode_layout.funct7_bit[6])?,
        ];
        let rs1_bits = [
            decode_open_col(decode_layout.rs1_bit[0])?,
            decode_open_col(decode_layout.rs1_bit[1])?,
            decode_open_col(decode_layout.rs1_bit[2])?,
            decode_open_col(decode_layout.rs1_bit[3])?,
            decode_open_col(decode_layout.rs1_bit[4])?,
        ];
        let rd_bits = [
            decode_open_col(decode_layout.rd_bit[0])?,
            decode_open_col(decode_layout.rd_bit[1])?,
            decode_open_col(decode_layout.rd_bit[2])?,
            decode_open_col(decode_layout.rd_bit[3])?,
            decode_open_col(decode_layout.rd_bit[4])?,
        ];
        let decode_rs1_addr = decode_reg_addr_from_bits(rs1_bits);
        let decode_rs2_addr = decode_open_col(decode_layout.rs2)?;
        let decode_rd_addr = decode_reg_addr_from_bits(rd_bits);
        let rd_is_zero = decode_open_col(decode_layout.rd_is_zero)?;
        let decode_rd_has_write = decode_open_col(decode_layout.rd_has_write)?;
        let imm_i = decode_open_col(decode_layout.imm_i)?;
        let rv64_exact_words = false;
        let mut decode_inputs = DecodeFieldsOpenings {
            rv64_exact_words,
            active: trace_opening_col(trace.active)?,
            halted: booleanity_opening_col(trace.halted)?,
            is_virtual: trace_opening_col(trace.is_virtual)?,
            virtual_sequence_remaining: trace_opening_col(trace.virtual_sequence_remaining)?,
            virtual_commit_from_prev: trace_opening_col(trace.virtual_commit_from_prev)?,
            trace_rs1_addr: trace_opening_col(trace.rs1_addr)?,
            trace_rs2_addr: trace_opening_col(trace.rs2_addr)?,
            trace_rd_addr: trace_opening_col(trace.rd_addr)?,
            rs1_val: trace_opening_col(trace.rs1_val)?,
            rs2_val: trace_opening_col(trace.rs2_val)?,
            rd_val: trace_opening_col(trace.rd_val)?,
            rs1_word: K::ZERO,
            rs2_word: K::ZERO,
            rd_word: K::ZERO,
            shout_lhs_word: K::ZERO,
            shout_lhs_hi: K::ZERO,
            shout_rhs_word: K::ZERO,
            shout_rhs_hi: K::ZERO,
            shout_add_sub_key_word: K::ZERO,
            shout_add_sub_key_hi: K::ZERO,
            trace_rd_has_write: trace_opening_col(trace.rd_has_write)?,
            ram_addr: trace_opening_col(trace.ram_addr)?,
            shout_has_lookup: trace_opening_col(trace.shout_has_lookup)?,
            shout_table_id: trace_opening_col(trace.shout_table_id)?,
            shout_val: trace_opening_col(trace.shout_val)?,
            shout_lhs: trace_opening_col(trace.shout_lhs)?,
            shout_rhs: trace_opening_col(trace.shout_rhs)?,
            shout_add_sub_key: trace_opening_col(trace.shout_add_sub_key)?,
            decode_opcode: decode_open_col(decode_layout.opcode)?,
            decode_rs1_addr,
            decode_rs2_addr,
            decode_rd_addr,
            rd_is_zero,
            decode_rd_has_write,
            ram_has_read: decode_open_col(decode_layout.ram_has_read)?,
            ram_has_write: decode_open_col(decode_layout.ram_has_write)?,
            opcode_flags,
            op_custom,
            funct3_is,
            funct3_bits,
            funct7_bits,
            imm_i,
            imm_s: decode_open_col(decode_layout.imm_s)?,
        };
        decode_inputs.rs1_word = decode_inputs.rs1_val;
        decode_inputs.rs2_word = decode_inputs.rs2_val;
        decode_inputs.rd_word = decode_inputs.rd_val;
        decode_inputs.shout_lhs_word = decode_inputs.shout_lhs;
        decode_inputs.shout_rhs_word = decode_inputs.shout_rhs;
        decode_inputs.shout_add_sub_key_word = decode_inputs.shout_add_sub_key;
        let weights = decode_pack_weight_vector(r_cycle, DECODE_FIELDS_RESIDUAL_COUNT);
        let weighted = decode_fields_weighted_residual(&decode_inputs, &weights);
        let expected = eq_points(r_time, r_cycle) * weighted;
        if batched_final_values[claim_idx] != expected {
            return Err(PiCcsError::ProtocolError(
                "decode/fields terminal value mismatch".into(),
            ));
        }
    }

    if let Some(claim_idx) = claim_plan.decode_immediates {
        if claim_idx >= batched_final_values.len() {
            return Err(PiCcsError::ProtocolError(
                "decode/immediates claim index out of range".into(),
            ));
        }
        let residuals = decode_immediate_residuals(
            decode_open_col(decode_layout.imm_i)?,
            decode_open_col(decode_layout.imm_s)?,
            decode_open_col(decode_layout.imm_b)?,
            decode_open_col(decode_layout.imm_j)?,
            [
                decode_open_col(decode_layout.rd_bit[0])?,
                decode_open_col(decode_layout.rd_bit[1])?,
                decode_open_col(decode_layout.rd_bit[2])?,
                decode_open_col(decode_layout.rd_bit[3])?,
                decode_open_col(decode_layout.rd_bit[4])?,
            ],
            [
                decode_open_col(decode_layout.funct3_bit[0])?,
                decode_open_col(decode_layout.funct3_bit[1])?,
                decode_open_col(decode_layout.funct3_bit[2])?,
            ],
            [
                decode_open_col(decode_layout.rs1_bit[0])?,
                decode_open_col(decode_layout.rs1_bit[1])?,
                decode_open_col(decode_layout.rs1_bit[2])?,
                decode_open_col(decode_layout.rs1_bit[3])?,
                decode_open_col(decode_layout.rs1_bit[4])?,
            ],
            [
                decode_open_col(decode_layout.rs2_bit[0])?,
                decode_open_col(decode_layout.rs2_bit[1])?,
                decode_open_col(decode_layout.rs2_bit[2])?,
                decode_open_col(decode_layout.rs2_bit[3])?,
                decode_open_col(decode_layout.rs2_bit[4])?,
            ],
            [
                decode_open_col(decode_layout.funct7_bit[0])?,
                decode_open_col(decode_layout.funct7_bit[1])?,
                decode_open_col(decode_layout.funct7_bit[2])?,
                decode_open_col(decode_layout.funct7_bit[3])?,
                decode_open_col(decode_layout.funct7_bit[4])?,
                decode_open_col(decode_layout.funct7_bit[5])?,
                decode_open_col(decode_layout.funct7_bit[6])?,
            ],
        );
        let mut weighted = K::ZERO;
        let weights = decode_imm_weight_vector(r_cycle, residuals.len());
        for (r, w) in residuals.iter().zip(weights.iter()) {
            weighted += *w * *r;
        }
        let expected = eq_points(r_time, r_cycle) * weighted;
        if batched_final_values[claim_idx] != expected {
            return Err(PiCcsError::ProtocolError(
                "decode/immediates terminal value mismatch".into(),
            ));
        }
    }

    Ok(())
}

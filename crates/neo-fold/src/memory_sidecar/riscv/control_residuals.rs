use super::*;

pub(crate) type Rv64ControlResidualTimeClaims = (
    Option<(Box<dyn RoundOracle + Send>, K)>,
    Option<(Box<dyn RoundOracle + Send>, K)>,
    Option<(Box<dyn RoundOracle + Send>, K)>,
    Option<(Box<dyn RoundOracle + Send>, K)>,
);

pub(crate) fn rv64_control_trace_metadata_columns(trace: &neo_memory::riscv::trace::Rv64TraceLayout) -> Vec<usize> {
    let mut cols = vec![
        trace.op_lui,
        trace.op_auipc,
        trace.op_jal,
        trace.op_jalr,
        trace.op_branch,
        trace.op_load,
        trace.op_store,
        trace.op_alu_imm,
        trace.op_alu_reg,
        trace.op_misc_mem,
        trace.op_system,
        trace.op_amo,
        trace.op_custom,
        trace.write_lui,
        trace.write_auipc,
        trace.write_jal,
        trace.write_jalr,
        trace.rd_is_zero,
        trace.opcode_u32ext,
        trace.ram_has_read,
        trace.ram_has_write,
        trace.imm_i_u32ext,
        trace.imm_s_u32ext,
        trace.imm_b_u32ext,
        trace.imm_j_u32ext,
    ];
    cols.extend(trace.rd_bit);
    cols.extend(trace.funct3_bit);
    cols.extend(trace.funct3_is);
    cols.extend(trace.rs1_bit);
    cols.extend(trace.rs2_bit);
    cols.extend(trace.funct7_bit);
    cols
}

fn rv64_control_decode_col_from_trace(
    trace: &neo_memory::riscv::trace::Rv64TraceLayout,
    decode: &Rv32DecodeSidecarLayout,
    col_id: usize,
) -> Result<usize, PiCcsError> {
    if col_id == decode.op_lui {
        Ok(trace.op_lui)
    } else if col_id == decode.op_auipc {
        Ok(trace.op_auipc)
    } else if col_id == decode.op_jal {
        Ok(trace.op_jal)
    } else if col_id == decode.op_jalr {
        Ok(trace.op_jalr)
    } else if col_id == decode.op_branch {
        Ok(trace.op_branch)
    } else if col_id == decode.op_load {
        Ok(trace.op_load)
    } else if col_id == decode.op_store {
        Ok(trace.op_store)
    } else if col_id == decode.op_alu_imm {
        Ok(trace.op_alu_imm)
    } else if col_id == decode.op_alu_reg {
        Ok(trace.op_alu_reg)
    } else if col_id == decode.op_misc_mem {
        Ok(trace.op_misc_mem)
    } else if col_id == decode.op_system {
        Ok(trace.op_system)
    } else if col_id == decode.op_amo {
        Ok(trace.op_amo)
    } else if col_id == decode.op_custom {
        Ok(trace.op_custom)
    } else if col_id == decode.op_lui_write {
        Ok(trace.write_lui)
    } else if col_id == decode.op_auipc_write {
        Ok(trace.write_auipc)
    } else if col_id == decode.op_jal_write {
        Ok(trace.write_jal)
    } else if col_id == decode.op_jalr_write {
        Ok(trace.write_jalr)
    } else if col_id == decode.rd_is_zero {
        Ok(trace.rd_is_zero)
    } else if col_id == decode.imm_i {
        Ok(trace.imm_i_u32ext)
    } else if col_id == decode.imm_b {
        Ok(trace.imm_b_u32ext)
    } else if col_id == decode.imm_j {
        Ok(trace.imm_j_u32ext)
    } else if let Some(idx) = decode.funct3_bit.iter().position(|&id| id == col_id) {
        Ok(trace.funct3_bit[idx])
    } else if let Some(idx) = decode.funct3_is.iter().position(|&id| id == col_id) {
        Ok(trace.funct3_is[idx])
    } else if let Some(idx) = decode.rs1_bit.iter().position(|&id| id == col_id) {
        Ok(trace.rs1_bit[idx])
    } else if let Some(idx) = decode.rs2_bit.iter().position(|&id| id == col_id) {
        Ok(trace.rs2_bit[idx])
    } else if let Some(idx) = decode.funct7_bit.iter().position(|&id| id == col_id) {
        Ok(trace.funct7_bit[idx])
    } else {
        Err(PiCcsError::ProtocolError(format!(
            "control(shared): unsupported RV64 trace metadata mapping for decode col_id={col_id}"
        )))
    }
}

fn rv64_control_decode_cols_from_trace(
    trace: &neo_memory::riscv::trace::Rv64TraceLayout,
    decode: &Rv32DecodeSidecarLayout,
    main_decoded: &BTreeMap<usize, Vec<K>>,
    decode_col_ids: &[usize],
) -> Result<BTreeMap<usize, Vec<K>>, PiCcsError> {
    let mut decoded = BTreeMap::<usize, Vec<K>>::new();
    for &col_id in decode_col_ids {
        let trace_col = rv64_control_decode_col_from_trace(trace, decode, col_id)?;
        let vals = main_decoded.get(&trace_col).ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "control(shared): missing RV64 trace metadata column {trace_col} for decode col_id={col_id}"
            ))
        })?;
        decoded.insert(col_id, vals.clone());
    }
    Ok(decoded)
}

pub(crate) fn build_route_a_control_time_claims(
    params: &NeoParams,
    step: &StepWitnessBundle<Cmt, F, K>,
    r_cycle: &[K],
) -> Result<Rv64ControlResidualTimeClaims, PiCcsError> {
    if !control_stage_required_for_step_witness(step) {
        return Ok((None, None, None, None));
    }
    let trace = neo_memory::riscv::trace::Rv64TraceLayout::new();
    let trace_cols = trace.cols;
    let trace_active = trace.active;
    let trace_is_virtual = trace.is_virtual;
    let trace_instr_word = trace.instr_word;
    let trace_pc_before = trace.pc_before;
    let trace_pc_after = trace.pc_after;
    let trace_rs1_val = trace.rs1_val;
    let trace_rd_val = trace.rd_val;
    let trace_shout_val = trace.shout_val;
    let trace_jalr_drop_bit = trace.jalr_drop_bit;
    let decode = Rv32DecodeSidecarLayout::new();
    let m_in = step.mcs.0.m_in;
    let ell_n = r_cycle.len();
    let t_len = step.time_columns.t;
    if t_len == 0 {
        return Err(PiCcsError::InvalidInput(
            "booleanity/trace-opening requires canonical time columns with t >= 1".into(),
        ));
    }
    if step.time_columns.cpu_cols.len() < trace_cols {
        return Err(PiCcsError::InvalidInput(format!(
            "booleanity/trace-opening requires canonical RV64 time cpu prefix columns (got {}, expected at least {})",
            step.time_columns.cpu_cols.len(),
            trace_cols
        )));
    }
    if t_len == 0 {
        return Err(PiCcsError::InvalidInput("control stage: t_len must be >= 1".into()));
    }

    let mut main_col_ids = vec![
        trace_active,
        trace_is_virtual,
        trace_instr_word,
        trace_pc_before,
        trace_pc_after,
        trace_rs1_val,
        trace_rd_val,
        trace_shout_val,
        trace_jalr_drop_bit,
    ];
    main_col_ids.extend(rv64_control_trace_metadata_columns(&trace));
    let decode_col_ids = vec![
        decode.op_lui,
        decode.op_auipc,
        decode.op_jal,
        decode.op_jalr,
        decode.op_branch,
        decode.op_load,
        decode.op_store,
        decode.op_alu_imm,
        decode.op_alu_reg,
        decode.op_misc_mem,
        decode.op_system,
        decode.op_amo,
        decode.op_custom,
        decode.op_lui_write,
        decode.op_auipc_write,
        decode.op_jal_write,
        decode.op_jalr_write,
        decode.rd_is_zero,
        decode.imm_i,
        decode.imm_b,
        decode.imm_j,
        decode.funct3_is[6],
        decode.funct3_is[7],
        decode.funct3_bit[0],
        decode.funct3_bit[1],
        decode.funct3_bit[2],
        decode.rs1_bit[0],
        decode.rs1_bit[1],
        decode.rs1_bit[2],
        decode.rs1_bit[3],
        decode.rs1_bit[4],
        decode.rs2_bit[0],
        decode.rs2_bit[1],
        decode.rs2_bit[2],
        decode.rs2_bit[3],
        decode.rs2_bit[4],
        decode.funct7_bit[0],
        decode.funct7_bit[1],
        decode.funct7_bit[2],
        decode.funct7_bit[3],
        decode.funct7_bit[4],
        decode.funct7_bit[5],
        decode.funct7_bit[6],
    ];

    let main_decoded = decode_trace_col_values_batch(params, step, t_len, &main_col_ids)?;
    let decode_decoded = rv64_control_decode_cols_from_trace(&trace, &decode, &main_decoded, &decode_col_ids)?;

    #[cfg(debug_assertions)]
    for j in 0..t_len {
        let is_virtual = *main_decoded
            .get(&trace_is_virtual)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing is_virtual row while validating".into())
            })?;
        let pc_before = *main_decoded
            .get(&trace_pc_before)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing pc_before row while validating".into())
            })?;
        let pc_after = *main_decoded
            .get(&trace_pc_after)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing pc_after row while validating".into())
            })?;
        let op_lui = *decode_decoded
            .get(&decode.op_lui)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing op_lui row while validating".into()))?;
        let op_auipc = *decode_decoded
            .get(&decode.op_auipc)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing op_auipc row while validating".into())
            })?;
        let op_load = *decode_decoded
            .get(&decode.op_load)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing op_load row while validating".into()))?;
        let op_store = *decode_decoded
            .get(&decode.op_store)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing op_store row while validating".into())
            })?;
        let op_alu_imm = *decode_decoded
            .get(&decode.op_alu_imm)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing op_alu_imm row while validating".into())
            })?;
        let op_alu_reg = *decode_decoded
            .get(&decode.op_alu_reg)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing op_alu_reg row while validating".into())
            })?;
        let op_misc_mem = *decode_decoded
            .get(&decode.op_misc_mem)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing op_misc_mem row while validating".into())
            })?;
        let op_system = *decode_decoded
            .get(&decode.op_system)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing op_system row while validating".into())
            })?;
        let op_amo = *decode_decoded
            .get(&decode.op_amo)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing op_amo row while validating".into()))?;
        let op_custom = *decode_decoded
            .get(&decode.op_custom)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing op_custom row while validating".into())
            })?;
        let residual = control_next_pc_linear_residual(
            pc_before,
            pc_after,
            is_virtual,
            op_lui,
            op_auipc,
            op_load,
            op_store,
            op_alu_imm,
            op_alu_reg,
            op_misc_mem,
            op_system,
            op_amo,
            op_custom,
        );
        if residual != K::ZERO {
            return Err(PiCcsError::ProtocolError(format!(
                "control/next_pc_linear residual non-zero at row={j}, residual={residual}, is_virtual={is_virtual}, pc_before={pc_before}, pc_after={pc_after}, op_lui={op_lui}, op_auipc={op_auipc}, op_load={op_load}, op_store={op_store}, op_alu_imm={op_alu_imm}, op_alu_reg={op_alu_reg}, op_misc_mem={op_misc_mem}, op_system={op_system}, op_amo={op_amo}, op_custom={op_custom}"
            )));
        }
    }

    for j in 0..t_len {
        let active = *main_decoded
            .get(&trace_active)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing active row while validating".into()))?;
        let pc_before = *main_decoded
            .get(&trace_pc_before)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing pc_before row while validating".into())
            })?;
        let pc_after = *main_decoded
            .get(&trace_pc_after)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing pc_after row while validating".into())
            })?;
        let rs1_val = *main_decoded
            .get(&trace_rs1_val)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing rs1_val row while validating".into()))?;
        let jalr_drop_bit = *main_decoded
            .get(&trace_jalr_drop_bit)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing jalr_drop_bit row while validating".into())
            })?;
        let shout_val = *main_decoded
            .get(&trace_shout_val)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing shout_val row while validating".into())
            })?;
        let imm_i = *decode_decoded
            .get(&decode.imm_i)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing imm_i row while validating".into()))?;
        let imm_b = *decode_decoded
            .get(&decode.imm_b)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing imm_b row while validating".into()))?;
        let imm_j = *decode_decoded
            .get(&decode.imm_j)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing imm_j row while validating".into()))?;
        let imm_sign_bit = *decode_decoded
            .get(&decode.funct7_bit[6])
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing funct7_bit[6] row while validating".into())
            })?;
        let op_jal = *decode_decoded
            .get(&decode.op_jal)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing op_jal row while validating".into()))?;
        let op_jalr = *decode_decoded
            .get(&decode.op_jalr)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing op_jalr row while validating".into()))?;
        let op_branch = *decode_decoded
            .get(&decode.op_branch)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing op_branch row while validating".into())
            })?;
        let funct3_bit0 = *decode_decoded
            .get(&decode.funct3_bit[0])
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing funct3_bit[0] row while validating".into())
            })?;
        let residuals = control_next_pc_control_residuals(
            active,
            pc_before,
            pc_after,
            rs1_val,
            jalr_drop_bit,
            imm_i,
            imm_b,
            imm_j,
            imm_sign_bit,
            op_jal,
            op_jalr,
            op_branch,
            shout_val,
            funct3_bit0,
        );
        if let Some((idx, _)) = residuals.iter().enumerate().find(|(_, r)| **r != K::ZERO) {
            return Err(PiCcsError::ProtocolError(format!(
                "control/next_pc_control residual non-zero at row={j}, idx={idx}, active={active}, op_jal={op_jal}, op_jalr={op_jalr}, op_branch={op_branch}, jalr_drop_bit={jalr_drop_bit}, pc_before={pc_before}, pc_after={pc_after}, rs1_val={rs1_val}, imm_i={imm_i}, imm_b={imm_b}, imm_j={imm_j}, imm_sign_bit={imm_sign_bit}, shout_val={shout_val}, funct3_bit0={funct3_bit0}"
            )));
        }
    }

    #[cfg(debug_assertions)]
    for j in 0..t_len {
        let rd_val = *main_decoded
            .get(&trace_rd_val)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing rd_val row while validating".into()))?;
        let pc_before = *main_decoded
            .get(&trace_pc_before)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing pc_before row while validating".into())
            })?;
        let op_lui = *decode_decoded
            .get(&decode.op_lui)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing op_lui row while validating".into()))?;
        let op_auipc = *decode_decoded
            .get(&decode.op_auipc)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing op_auipc row while validating".into())
            })?;
        let op_jal = *decode_decoded
            .get(&decode.op_jal)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing op_jal row while validating".into()))?;
        let op_jalr = *decode_decoded
            .get(&decode.op_jalr)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing op_jalr row while validating".into()))?;
        let rd_is_zero = *decode_decoded
            .get(&decode.rd_is_zero)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("control(shared): missing rd_is_zero row while validating".into())
            })?;
        let funct3_bits = [
            *decode_decoded
                .get(&decode.funct3_bit[0])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing funct3_bit[0] row".into()))?,
            *decode_decoded
                .get(&decode.funct3_bit[1])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing funct3_bit[1] row".into()))?,
            *decode_decoded
                .get(&decode.funct3_bit[2])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing funct3_bit[2] row".into()))?,
        ];
        let rs1_bits = [
            *decode_decoded
                .get(&decode.rs1_bit[0])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing rs1_bit[0] row".into()))?,
            *decode_decoded
                .get(&decode.rs1_bit[1])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing rs1_bit[1] row".into()))?,
            *decode_decoded
                .get(&decode.rs1_bit[2])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing rs1_bit[2] row".into()))?,
            *decode_decoded
                .get(&decode.rs1_bit[3])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing rs1_bit[3] row".into()))?,
            *decode_decoded
                .get(&decode.rs1_bit[4])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing rs1_bit[4] row".into()))?,
        ];
        let rs2_bits = [
            *decode_decoded
                .get(&decode.rs2_bit[0])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing rs2_bit[0] row".into()))?,
            *decode_decoded
                .get(&decode.rs2_bit[1])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing rs2_bit[1] row".into()))?,
            *decode_decoded
                .get(&decode.rs2_bit[2])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing rs2_bit[2] row".into()))?,
            *decode_decoded
                .get(&decode.rs2_bit[3])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing rs2_bit[3] row".into()))?,
            *decode_decoded
                .get(&decode.rs2_bit[4])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing rs2_bit[4] row".into()))?,
        ];
        let funct7_bits = [
            *decode_decoded
                .get(&decode.funct7_bit[0])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing funct7_bit[0] row".into()))?,
            *decode_decoded
                .get(&decode.funct7_bit[1])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing funct7_bit[1] row".into()))?,
            *decode_decoded
                .get(&decode.funct7_bit[2])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing funct7_bit[2] row".into()))?,
            *decode_decoded
                .get(&decode.funct7_bit[3])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing funct7_bit[3] row".into()))?,
            *decode_decoded
                .get(&decode.funct7_bit[4])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing funct7_bit[4] row".into()))?,
            *decode_decoded
                .get(&decode.funct7_bit[5])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing funct7_bit[5] row".into()))?,
            *decode_decoded
                .get(&decode.funct7_bit[6])
                .and_then(|v| v.get(j))
                .ok_or_else(|| PiCcsError::ProtocolError("control(shared): missing funct7_bit[6] row".into()))?,
        ];
        let imm_u = control_imm_u_value_from_bits(funct3_bits, rs1_bits, rs2_bits, funct7_bits, 64);
        let op_lui_write = op_lui * (K::ONE - rd_is_zero);
        let op_auipc_write = op_auipc * (K::ONE - rd_is_zero);
        let op_jal_write = op_jal * (K::ONE - rd_is_zero);
        let op_jalr_write = op_jalr * (K::ONE - rd_is_zero);
        let residuals = control_writeback_residuals(
            rd_val,
            pc_before,
            imm_u,
            op_lui_write,
            op_auipc_write,
            op_jal_write,
            op_jalr_write,
        );
        if let Some((idx, _)) = residuals.iter().enumerate().find(|(_, r)| **r != K::ZERO) {
            return Err(PiCcsError::ProtocolError(format!(
                "control/writeback residual non-zero at row={j}, idx={idx}, rd_val={rd_val}, pc_before={pc_before}, imm_u={imm_u}, op_lui={op_lui}, op_auipc={op_auipc}, op_jal={op_jal}, op_jalr={op_jalr}, rd_is_zero={rd_is_zero}"
            )));
        }
    }

    let mut main_sparse = BTreeMap::<usize, SparseIdxVec<K>>::new();
    for &col_id in main_col_ids.iter() {
        let vals = main_decoded
            .get(&col_id)
            .ok_or_else(|| PiCcsError::ProtocolError(format!("control stage missing main decoded column {col_id}")))?;
        main_sparse.insert(col_id, sparse_trace_col_from_values(m_in, ell_n, vals)?);
    }
    let mut decode_sparse = BTreeMap::<usize, SparseIdxVec<K>>::new();
    for &col_id in decode_col_ids.iter() {
        let vals = decode_decoded.get(&col_id).ok_or_else(|| {
            PiCcsError::ProtocolError(format!("control stage missing decode decoded column {col_id}"))
        })?;
        decode_sparse.insert(col_id, sparse_trace_col_from_values(m_in, ell_n, vals)?);
    }

    let main_col = |col_id: usize| -> Result<SparseIdxVec<K>, PiCcsError> {
        main_sparse
            .get(&col_id)
            .cloned()
            .ok_or_else(|| PiCcsError::ProtocolError(format!("control stage missing main sparse col {col_id}")))
    };
    let decode_col = |col_id: usize| -> Result<SparseIdxVec<K>, PiCcsError> {
        decode_sparse
            .get(&col_id)
            .cloned()
            .ok_or_else(|| PiCcsError::ProtocolError(format!("control stage missing decode sparse col {col_id}")))
    };

    let linear_sparse = vec![
        main_col(trace_pc_before)?,
        main_col(trace_pc_after)?,
        main_col(trace_is_virtual)?,
        decode_col(decode.op_lui)?,
        decode_col(decode.op_auipc)?,
        decode_col(decode.op_load)?,
        decode_col(decode.op_store)?,
        decode_col(decode.op_alu_imm)?,
        decode_col(decode.op_alu_reg)?,
        decode_col(decode.op_misc_mem)?,
        decode_col(decode.op_system)?,
        decode_col(decode.op_amo)?,
        decode_col(decode.op_custom)?,
    ];
    let linear_weights = control_next_pc_linear_weight_vector(r_cycle, 1);
    let linear_oracle = FormulaOracleSparseTime::new(linear_sparse, 4, r_cycle, move |vals: &[K]| {
        let residual = control_next_pc_linear_residual(
            vals[0], vals[1], vals[2], vals[3], vals[4], vals[5], vals[6], vals[7], vals[8], vals[9], vals[10],
            vals[11], vals[12],
        );
        linear_weights[0] * residual
    });

    let control_sparse = vec![
        main_col(trace_active)?,
        main_col(trace_pc_before)?,
        main_col(trace_pc_after)?,
        main_col(trace_rs1_val)?,
        main_col(trace_jalr_drop_bit)?,
        main_col(trace_shout_val)?,
        decode_col(decode.funct3_bit[0])?,
        decode_col(decode.op_jal)?,
        decode_col(decode.op_jalr)?,
        decode_col(decode.op_branch)?,
        decode_col(decode.imm_i)?,
        decode_col(decode.imm_b)?,
        decode_col(decode.imm_j)?,
        decode_col(decode.funct7_bit[6])?,
    ];
    let control_weights = control_next_pc_control_weight_vector(r_cycle, 5);
    let control_oracle = FormulaOracleSparseTime::new(control_sparse, 5, r_cycle, move |vals: &[K]| {
        let residuals = control_next_pc_control_residuals(
            vals[0], vals[1], vals[2], vals[3], vals[4], vals[10], vals[11], vals[12], vals[13], vals[7], vals[8],
            vals[9], vals[5], vals[6],
        );
        let mut weighted = K::ZERO;
        for (r, w) in residuals.iter().zip(control_weights.iter()) {
            weighted += *w * *r;
        }
        weighted
    });

    let branch_sparse = vec![
        decode_col(decode.op_branch)?,
        main_col(trace_shout_val)?,
        decode_col(decode.funct3_bit[0])?,
        decode_col(decode.funct3_bit[1])?,
        decode_col(decode.funct3_bit[2])?,
        decode_col(decode.funct3_is[6])?,
        decode_col(decode.funct3_is[7])?,
    ];
    let branch_weights = control_branch_semantics_weight_vector(r_cycle, 3);
    let branch_oracle = FormulaOracleSparseTime::new(branch_sparse, 4, r_cycle, move |vals: &[K]| {
        let residuals =
            control_branch_semantics_residuals(vals[0], vals[1], vals[2], vals[3], vals[4], vals[5], vals[6]);
        let mut weighted = K::ZERO;
        for (r, w) in residuals.iter().zip(branch_weights.iter()) {
            weighted += *w * *r;
        }
        weighted
    });

    let mut write_sparse = vec![
        main_col(trace_rd_val)?,
        main_col(trace_pc_before)?,
        decode_col(decode.op_lui)?,
        decode_col(decode.op_auipc)?,
        decode_col(decode.op_jal)?,
        decode_col(decode.op_jalr)?,
        decode_col(decode.rd_is_zero)?,
        decode_col(decode.funct3_bit[0])?,
        decode_col(decode.funct3_bit[1])?,
        decode_col(decode.funct3_bit[2])?,
    ];
    for &col_id in decode.rs1_bit.iter() {
        write_sparse.push(decode_col(col_id)?);
    }
    for &col_id in decode.rs2_bit.iter() {
        write_sparse.push(decode_col(col_id)?);
    }
    for &col_id in decode.funct7_bit.iter() {
        write_sparse.push(decode_col(col_id)?);
    }
    let write_weights = control_writeback_weight_vector(r_cycle, 4);
    let write_oracle = FormulaOracleSparseTime::new(write_sparse, 5, r_cycle, move |vals: &[K]| {
        let rd_val = vals[0];
        let pc_before = vals[1];
        let op_lui = vals[2];
        let op_auipc = vals[3];
        let op_jal = vals[4];
        let op_jalr = vals[5];
        let rd_is_zero = vals[6];
        let op_lui_write = op_lui * (K::ONE - rd_is_zero);
        let op_auipc_write = op_auipc * (K::ONE - rd_is_zero);
        let op_jal_write = op_jal * (K::ONE - rd_is_zero);
        let op_jalr_write = op_jalr * (K::ONE - rd_is_zero);
        let funct3_bits = [vals[7], vals[8], vals[9]];
        let rs1_bits = [vals[10], vals[11], vals[12], vals[13], vals[14]];
        let rs2_bits = [vals[15], vals[16], vals[17], vals[18], vals[19]];
        let funct7_bits = [vals[20], vals[21], vals[22], vals[23], vals[24], vals[25], vals[26]];
        let imm_u = control_imm_u_value_from_bits(funct3_bits, rs1_bits, rs2_bits, funct7_bits, 64);
        let residuals = control_writeback_residuals(
            rd_val,
            pc_before,
            imm_u,
            op_lui_write,
            op_auipc_write,
            op_jal_write,
            op_jalr_write,
        );
        let mut weighted = K::ZERO;
        for (r, w) in residuals.iter().zip(write_weights.iter()) {
            weighted += *w * *r;
        }
        weighted
    });

    Ok((
        Some((Box::new(linear_oracle), K::ZERO)),
        Some((Box::new(control_oracle), K::ZERO)),
        Some((Box::new(branch_oracle), K::ZERO)),
        Some((Box::new(write_oracle), K::ZERO)),
    ))
}

pub(crate) fn verify_route_a_control_terminals(
    _cpu_bus: &BusLayout,
    step: &StepInstanceBundle<Cmt, F, K>,
    r_time: &[K],
    r_cycle: &[K],
    batched_final_values: &[K],
    claim_plan: &RouteATimeClaimPlan,
    mem_proof: &MemSidecarProof<Cmt, F, K>,
    step_time_openings: &[crate::shard_proof_types::TimePointOpening],
) -> Result<(), PiCcsError> {
    let any_control_claim = claim_plan.control_next_pc_linear.is_some()
        || claim_plan.control_next_pc_control.is_some()
        || claim_plan.control_branch_semantics.is_some()
        || claim_plan.control_writeback.is_some();
    if !any_control_claim {
        return Ok(());
    }

    if mem_proof.trace_opening_me_claims.len() != 1 {
        return Err(PiCcsError::ProtocolError(
            "control stage requires trace-opening ME openings for main-trace terminals".into(),
        ));
    }
    let rv64_trace = neo_memory::riscv::trace::Rv64TraceLayout::new();
    let decode = Rv32DecodeSidecarLayout::new();

    let trace_opening_me = &mem_proof.trace_opening_me_claims[0];
    if trace_opening_me.r.as_slice() != r_time {
        return Err(PiCcsError::ProtocolError(
            "control stage trace-opening ME claim r mismatch (expected r_time)".into(),
        ));
    }
    if trace_opening_me.c != step.mcs_inst.c {
        return Err(PiCcsError::ProtocolError(
            "control stage trace-opening ME claim commitment mismatch".into(),
        ));
    }
    if trace_opening_me.m_in != step.mcs_inst.m_in {
        return Err(PiCcsError::ProtocolError(
            "control stage trace-opening ME claim m_in mismatch".into(),
        ));
    }
    let (
        trace_active,
        trace_is_virtual,
        trace_pc_before,
        trace_pc_after,
        trace_rs1_val,
        trace_rd_val,
        trace_jalr_drop_bit,
        trace_shout_val,
        mut trace_opening_all_cols,
    ) = (
        rv64_trace.active,
        rv64_trace.is_virtual,
        rv64_trace.pc_before,
        rv64_trace.pc_after,
        rv64_trace.rs1_val,
        rv64_trace.rd_val,
        rv64_trace.jalr_drop_bit,
        rv64_trace.shout_val,
        {
            let mut cols = vec![
                rv64_trace.active,
                rv64_trace.is_virtual,
                rv64_trace.pc_before,
                rv64_trace.pc_after,
                rv64_trace.rs1_val,
                rv64_trace.rd_val,
                rv64_trace.shout_val,
                rv64_trace.jalr_drop_bit,
            ];
            cols.extend(rv64_control_trace_metadata_columns(&rv64_trace));
            cols
        },
    );
    let mut seen_trace_opening_cols = std::collections::BTreeSet::new();
    trace_opening_all_cols.retain(|col_id| seen_trace_opening_cols.insert(*col_id));
    let (_trace_opening_entry, trace_opening_map) = require_time_openings_covering_point(
        step_time_openings,
        trace_opening_me.r.as_slice(),
        &trace_opening_all_cols,
        "control stage trace-opening",
    )?;
    let trace_opening_col = |col_id: usize| -> Result<K, PiCcsError> {
        named_opening(&trace_opening_map, col_id, "control stage trace-opening")
    };
    let decode_open_col = |col_id: usize| -> Result<K, PiCcsError> {
        let trace_col = rv64_control_decode_col_from_trace(&rv64_trace, &decode, col_id)?;
        trace_opening_col(trace_col)
    };

    let active = trace_opening_col(trace_active)?;
    let is_virtual = trace_opening_col(trace_is_virtual)?;
    let pc_before = trace_opening_col(trace_pc_before)?;
    let pc_after = trace_opening_col(trace_pc_after)?;
    let rs1_val = trace_opening_col(trace_rs1_val)?;
    let rd_val = trace_opening_col(trace_rd_val)?;
    let jalr_drop_bit = trace_opening_col(trace_jalr_drop_bit)?;
    let shout_val = trace_opening_col(trace_shout_val)?;
    let funct3_bits = [
        decode_open_col(decode.funct3_bit[0])?,
        decode_open_col(decode.funct3_bit[1])?,
        decode_open_col(decode.funct3_bit[2])?,
    ];
    let rs1_bits = [
        decode_open_col(decode.rs1_bit[0])?,
        decode_open_col(decode.rs1_bit[1])?,
        decode_open_col(decode.rs1_bit[2])?,
        decode_open_col(decode.rs1_bit[3])?,
        decode_open_col(decode.rs1_bit[4])?,
    ];
    let rs2_bits = [
        decode_open_col(decode.rs2_bit[0])?,
        decode_open_col(decode.rs2_bit[1])?,
        decode_open_col(decode.rs2_bit[2])?,
        decode_open_col(decode.rs2_bit[3])?,
        decode_open_col(decode.rs2_bit[4])?,
    ];
    let funct7_bits = [
        decode_open_col(decode.funct7_bit[0])?,
        decode_open_col(decode.funct7_bit[1])?,
        decode_open_col(decode.funct7_bit[2])?,
        decode_open_col(decode.funct7_bit[3])?,
        decode_open_col(decode.funct7_bit[4])?,
        decode_open_col(decode.funct7_bit[5])?,
        decode_open_col(decode.funct7_bit[6])?,
    ];

    let op_lui = decode_open_col(decode.op_lui)?;
    let op_auipc = decode_open_col(decode.op_auipc)?;
    let op_jal = decode_open_col(decode.op_jal)?;
    let op_jalr = decode_open_col(decode.op_jalr)?;
    let op_branch = decode_open_col(decode.op_branch)?;
    let op_load = decode_open_col(decode.op_load)?;
    let op_store = decode_open_col(decode.op_store)?;
    let op_alu_imm = decode_open_col(decode.op_alu_imm)?;
    let op_alu_reg = decode_open_col(decode.op_alu_reg)?;
    let op_misc_mem = decode_open_col(decode.op_misc_mem)?;
    let op_system = decode_open_col(decode.op_system)?;
    let op_amo = decode_open_col(decode.op_amo)?;
    let op_custom = decode_open_col(decode.op_custom)?;
    let rd_is_zero = decode_open_col(decode.rd_is_zero)?;
    let op_lui_write = op_lui * (K::ONE - rd_is_zero);
    let op_auipc_write = op_auipc * (K::ONE - rd_is_zero);
    let op_jal_write = op_jal * (K::ONE - rd_is_zero);
    let op_jalr_write = op_jalr * (K::ONE - rd_is_zero);
    let imm_i = decode_open_col(decode.imm_i)?;
    let imm_b = decode_open_col(decode.imm_b)?;
    let imm_j = decode_open_col(decode.imm_j)?;
    let funct3_is6 = decode_open_col(decode.funct3_is[6])?;
    let funct3_is7 = decode_open_col(decode.funct3_is[7])?;

    if let Some(claim_idx) = claim_plan.control_next_pc_linear {
        if claim_idx >= batched_final_values.len() {
            return Err(PiCcsError::ProtocolError(
                "control/next_pc_linear claim index out of range".into(),
            ));
        }
        let residual = control_next_pc_linear_residual(
            pc_before,
            pc_after,
            is_virtual,
            op_lui,
            op_auipc,
            op_load,
            op_store,
            op_alu_imm,
            op_alu_reg,
            op_misc_mem,
            op_system,
            op_amo,
            op_custom,
        );
        let weights = control_next_pc_linear_weight_vector(r_cycle, 1);
        let expected = eq_points(r_time, r_cycle) * weights[0] * residual;
        if batched_final_values[claim_idx] != expected {
            return Err(PiCcsError::ProtocolError(
                "control/next_pc_linear terminal value mismatch".into(),
            ));
        }
    }

    if let Some(claim_idx) = claim_plan.control_next_pc_control {
        if claim_idx >= batched_final_values.len() {
            return Err(PiCcsError::ProtocolError(
                "control/next_pc_control claim index out of range".into(),
            ));
        }
        let residuals = control_next_pc_control_residuals(
            active,
            pc_before,
            pc_after,
            rs1_val,
            jalr_drop_bit,
            imm_i,
            imm_b,
            imm_j,
            funct7_bits[6],
            op_jal,
            op_jalr,
            op_branch,
            shout_val,
            funct3_bits[0],
        );
        let weights = control_next_pc_control_weight_vector(r_cycle, residuals.len());
        let mut weighted = K::ZERO;
        for (r, w) in residuals.iter().zip(weights.iter()) {
            weighted += *w * *r;
        }
        let expected = eq_points(r_time, r_cycle) * weighted;
        if batched_final_values[claim_idx] != expected {
            return Err(PiCcsError::ProtocolError(
                "control/next_pc_control terminal value mismatch".into(),
            ));
        }
    }

    if let Some(claim_idx) = claim_plan.control_branch_semantics {
        if claim_idx >= batched_final_values.len() {
            return Err(PiCcsError::ProtocolError(
                "control/branch_semantics claim index out of range".into(),
            ));
        }
        let residuals = control_branch_semantics_residuals(
            op_branch,
            shout_val,
            funct3_bits[0],
            funct3_bits[1],
            funct3_bits[2],
            funct3_is6,
            funct3_is7,
        );
        let weights = control_branch_semantics_weight_vector(r_cycle, residuals.len());
        let mut weighted = K::ZERO;
        for (r, w) in residuals.iter().zip(weights.iter()) {
            weighted += *w * *r;
        }
        let expected = eq_points(r_time, r_cycle) * weighted;
        if batched_final_values[claim_idx] != expected {
            return Err(PiCcsError::ProtocolError(
                "control/branch_semantics terminal value mismatch".into(),
            ));
        }
    }

    if let Some(claim_idx) = claim_plan.control_writeback {
        if claim_idx >= batched_final_values.len() {
            return Err(PiCcsError::ProtocolError(
                "control/writeback claim index out of range".into(),
            ));
        }
        let imm_u = control_imm_u_value_from_bits(funct3_bits, rs1_bits, rs2_bits, funct7_bits, 64);
        let residuals = control_writeback_residuals(
            rd_val,
            pc_before,
            imm_u,
            op_lui_write,
            op_auipc_write,
            op_jal_write,
            op_jalr_write,
        );
        let weights = control_writeback_weight_vector(r_cycle, residuals.len());
        let mut weighted = K::ZERO;
        for (r, w) in residuals.iter().zip(weights.iter()) {
            weighted += *w * *r;
        }
        let expected = eq_points(r_time, r_cycle) * weighted;
        if batched_final_values[claim_idx] != expected {
            return Err(PiCcsError::ProtocolError(
                "control/writeback terminal value mismatch".into(),
            ));
        }
    }

    Ok(())
}

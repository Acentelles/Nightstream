use super::*;

struct ValueCursor<'a> {
    vals: &'a [K],
    idx: usize,
}

impl<'a> ValueCursor<'a> {
    fn new(vals: &'a [K]) -> Self {
        Self { vals, idx: 0 }
    }

    fn take(&mut self) -> K {
        let v = self.vals[self.idx];
        self.idx += 1;
        v
    }

    fn take_arr<const N: usize>(&mut self) -> [K; N] {
        core::array::from_fn(|_| self.take())
    }

    fn consumed(&self) -> usize {
        self.idx
    }
}

struct DenseCols<T> {
    cols: Vec<Option<Vec<T>>>,
}

impl<T> DenseCols<T> {
    fn from_cols(cols: Vec<Vec<T>>) -> Self {
        Self {
            cols: cols.into_iter().map(Some).collect(),
        }
    }

    fn get(&self, col_id: &usize) -> Option<&Vec<T>> {
        self.cols.get(*col_id).and_then(|v| v.as_ref())
    }

    fn insert(&mut self, col_id: usize, vals: Vec<T>) {
        if col_id >= self.cols.len() {
            self.cols.resize_with(col_id + 1, || None);
        }
        self.cols[col_id] = Some(vals);
    }
}

#[inline]
fn ensure_column_len<T>(ctx: &'static str, col_id: usize, vals: &[T], expected: usize) -> Result<(), PiCcsError> {
    if vals.len() != expected {
        return Err(PiCcsError::ProtocolError(format!(
            "{ctx}: column {col_id} length mismatch: expected {expected}, got {}",
            vals.len()
        )));
    }
    Ok(())
}

pub(crate) fn build_route_a_decode_time_claims(
    params: &NeoParams,
    step: &StepWitnessBundle<Cmt, F, K>,
    r_cycle: &[K],
) -> Result<
    (
        Option<(Box<dyn RoundOracle + Send>, K)>,
        Option<(Box<dyn RoundOracle + Send>, K)>,
    ),
    PiCcsError,
> {
    if !decode_stage_required_for_step_witness(step) {
        return Ok((None, None));
    }

    let trace = Rv32TraceLayout::new();
    let rv64_exact_words = trace_uses_rv64_exact_words(step.time_columns.cpu_cols.len());
    let _rv64_trace = if rv64_exact_words {
        Some(neo_memory::riscv::trace::Rv64TraceLayout::new())
    } else {
        None
    };
    let decode = Rv32DecodeSidecarLayout::new();
    let t_len = infer_rv32_trace_t_len_for_trace_openings(step, &trace)?;
    let m_in = step.mcs.0.m_in;
    let ell_n = r_cycle.len();

    let mut cpu_cols = vec![
        trace.active,
        trace.halted,
        trace.is_virtual,
        trace.virtual_sequence_remaining,
        trace.virtual_commit_from_prev,
        trace.instr_word,
        trace.rs1_addr,
        trace.rs2_addr,
        trace.rd_addr,
        trace.rs1_val,
        trace.rs2_val,
        trace.rd_val,
        trace.rd_has_write,
        trace.ram_addr,
        trace.shout_has_lookup,
        trace.shout_table_id,
        trace.shout_val,
        trace.shout_lhs,
        trace.shout_rhs,
        trace.shout_add_sub_key,
    ];
    if rv64_exact_words {
        cpu_cols.extend(rv64_trace_exact_word_opening_columns());
    }
    let cpu_decoded = decode_trace_col_values_batch(params, step, t_len, &cpu_cols)?;

    let decode_decoded = {
        let instr_vals = cpu_decoded
            .get(&trace.instr_word)
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing instr_word decode column".into()))?;
        let active_vals = cpu_decoded
            .get(&trace.active)
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing active decode column".into()))?;
        if instr_vals.len() != t_len || active_vals.len() != t_len {
            return Err(PiCcsError::ProtocolError(format!(
                "decode(shared): decoded CPU column lengths drift (instr={}, active={}, t_len={t_len})",
                instr_vals.len(),
                active_vals.len()
            )));
        }
        let mut decoded_cols: Vec<Vec<K>> = (0..decode.cols)
            .map(|_| Vec::with_capacity(t_len))
            .collect();
        for j in 0..t_len {
            let instr_word = decode_k_to_u32(instr_vals[j], "decode(shared)/instr_word")?;
            let active = active_vals[j] != K::ZERO;
            let mut row = riscv_decode_lookup_backed_row_from_instr_word(&decode, instr_word, active);
            if !active {
                row.fill(F::ZERO);
            }
            for (col_id, value) in row.into_iter().enumerate() {
                decoded_cols[col_id].push(K::from(value));
            }
        }
        let mut decoded = DenseCols::from_cols(decoded_cols);

        // In shared lookup-backed mode, overwrite lookup-backed decode columns with the values
        // actually committed on the shared Shout bus so prover oracles and verifier terminals
        // are sourced from identical openings.
        let (decode_open_cols, decode_lut_slots) = resolve_shared_decode_lookup_lut_indices(step, &decode)?;
        let bus = build_bus_layout_for_step_witness(step, t_len)?;
        if bus.shout_cols.len() != step.lut_instances.len() {
            return Err(PiCcsError::ProtocolError(
                "decode(shared): bus layout shout lane count drift".into(),
            ));
        }
        let mut bus_val_cols = Vec::with_capacity(decode_open_cols.len());
        for &(lut_idx, val_slot) in decode_lut_slots.iter() {
            let inst_cols = bus.shout_cols.get(lut_idx).ok_or_else(|| {
                PiCcsError::ProtocolError("decode(shared): missing shout cols for decode lookup table".into())
            })?;
            let lane0 = inst_cols.lanes.get(0).ok_or_else(|| {
                PiCcsError::ProtocolError("decode(shared): expected one shout lane for decode lookup table".into())
            })?;
            let val_col = lane0.vals.get(val_slot).copied().ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "decode(shared): decode val_slot={} out of range for lut_idx={} (n_vals={})",
                    val_slot,
                    lut_idx,
                    lane0.vals.len()
                ))
            })?;
            bus_val_cols.push(val_col);
        }
        let lookup_vals = decode_lookup_backed_col_values_batch(
            t_len,
            bus.bus_cols,
            Some(&step.time_columns.mem_cols),
            &bus_val_cols,
        )?;
        for (open_idx, &decode_col_id) in decode_open_cols.iter().enumerate() {
            let bus_col_id = bus_val_cols[open_idx];
            let values = lookup_vals.get(&bus_col_id).ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "decode(shared): missing decoded lookup values for bus_col={bus_col_id}"
                ))
            })?;
            decoded.insert(decode_col_id, values.clone());
        }

        // Recompute derived decode helper columns from opened lookup-backed decode columns.
        let rd_is_zero_vals = decoded
            .get(&decode.rd_is_zero)
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing rd_is_zero decode column".into()))?;
        let funct7_b0_vals = decoded
            .get(&decode.funct7_bit[0])
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing funct7_bit[0] decode column".into()))?;
        let funct7_b1_vals = decoded
            .get(&decode.funct7_bit[1])
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing funct7_bit[1] decode column".into()))?;
        let funct7_b2_vals = decoded
            .get(&decode.funct7_bit[2])
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing funct7_bit[2] decode column".into()))?;
        let funct7_b3_vals = decoded
            .get(&decode.funct7_bit[3])
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing funct7_bit[3] decode column".into()))?;
        let funct7_b4_vals = decoded
            .get(&decode.funct7_bit[4])
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing funct7_bit[4] decode column".into()))?;
        let funct7_b5_vals = decoded
            .get(&decode.funct7_bit[5])
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing funct7_bit[5] decode column".into()))?;
        let funct7_b6_vals = decoded
            .get(&decode.funct7_bit[6])
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing funct7_bit[6] decode column".into()))?;
        let op_lui_vals = decoded
            .get(&decode.op_lui)
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing op_lui decode column".into()))?;
        let op_auipc_vals = decoded
            .get(&decode.op_auipc)
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing op_auipc decode column".into()))?;
        let op_jal_vals = decoded
            .get(&decode.op_jal)
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing op_jal decode column".into()))?;
        let op_jalr_vals = decoded
            .get(&decode.op_jalr)
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing op_jalr decode column".into()))?;
        let op_alu_imm_vals = decoded
            .get(&decode.op_alu_imm)
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing op_alu_imm decode column".into()))?;
        let op_alu_reg_vals = decoded
            .get(&decode.op_alu_reg)
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing op_alu_reg decode column".into()))?;
        let funct3_is0_vals = decoded
            .get(&decode.funct3_is[0])
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing funct3_is[0] decode column".into()))?;
        let funct3_is1_vals = decoded
            .get(&decode.funct3_is[1])
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing funct3_is[1] decode column".into()))?;
        let funct3_is2_vals = decoded
            .get(&decode.funct3_is[2])
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing funct3_is[2] decode column".into()))?;
        let funct3_is3_vals = decoded
            .get(&decode.funct3_is[3])
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing funct3_is[3] decode column".into()))?;
        let funct3_is4_vals = decoded
            .get(&decode.funct3_is[4])
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing funct3_is[4] decode column".into()))?;
        let funct3_is5_vals = decoded
            .get(&decode.funct3_is[5])
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing funct3_is[5] decode column".into()))?;
        let funct3_is6_vals = decoded
            .get(&decode.funct3_is[6])
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing funct3_is[6] decode column".into()))?;
        let funct3_is7_vals = decoded
            .get(&decode.funct3_is[7])
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing funct3_is[7] decode column".into()))?;
        let rs2_vals = decoded
            .get(&decode.rs2)
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing rs2 decode column".into()))?;
        let imm_i_vals = decoded
            .get(&decode.imm_i)
            .ok_or_else(|| PiCcsError::ProtocolError("decode(shared): missing imm_i decode column".into()))?;
        for (col_id, vals) in [
            (decode.rd_is_zero, rd_is_zero_vals.as_slice()),
            (decode.funct7_bit[0], funct7_b0_vals.as_slice()),
            (decode.funct7_bit[1], funct7_b1_vals.as_slice()),
            (decode.funct7_bit[2], funct7_b2_vals.as_slice()),
            (decode.funct7_bit[3], funct7_b3_vals.as_slice()),
            (decode.funct7_bit[4], funct7_b4_vals.as_slice()),
            (decode.funct7_bit[5], funct7_b5_vals.as_slice()),
            (decode.funct7_bit[6], funct7_b6_vals.as_slice()),
            (decode.op_lui, op_lui_vals.as_slice()),
            (decode.op_auipc, op_auipc_vals.as_slice()),
            (decode.op_jal, op_jal_vals.as_slice()),
            (decode.op_jalr, op_jalr_vals.as_slice()),
            (decode.op_alu_imm, op_alu_imm_vals.as_slice()),
            (decode.op_alu_reg, op_alu_reg_vals.as_slice()),
            (decode.funct3_is[0], funct3_is0_vals.as_slice()),
            (decode.funct3_is[1], funct3_is1_vals.as_slice()),
            (decode.funct3_is[2], funct3_is2_vals.as_slice()),
            (decode.funct3_is[3], funct3_is3_vals.as_slice()),
            (decode.funct3_is[4], funct3_is4_vals.as_slice()),
            (decode.funct3_is[5], funct3_is5_vals.as_slice()),
            (decode.funct3_is[6], funct3_is6_vals.as_slice()),
            (decode.funct3_is[7], funct3_is7_vals.as_slice()),
            (decode.rs2, rs2_vals.as_slice()),
            (decode.imm_i, imm_i_vals.as_slice()),
        ] {
            ensure_column_len("decode(shared)", col_id, vals, t_len)?;
        }

        let mut op_lui_write = Vec::with_capacity(t_len);
        let mut op_auipc_write = Vec::with_capacity(t_len);
        let mut op_jal_write = Vec::with_capacity(t_len);
        let mut op_jalr_write = Vec::with_capacity(t_len);
        let mut op_alu_imm_write = Vec::with_capacity(t_len);
        let mut op_alu_reg_write = Vec::with_capacity(t_len);
        let mut alu_reg_delta = Vec::with_capacity(t_len);
        let mut alu_imm_delta = Vec::with_capacity(t_len);
        let mut alu_imm_shift_rhs_delta = Vec::with_capacity(t_len);
        for j in 0..t_len {
            let rd_keep = K::ONE - rd_is_zero_vals[j];
            op_lui_write.push(op_lui_vals[j] * rd_keep);
            op_auipc_write.push(op_auipc_vals[j] * rd_keep);
            op_jal_write.push(op_jal_vals[j] * rd_keep);
            op_jalr_write.push(op_jalr_vals[j] * rd_keep);
            op_alu_imm_write.push(op_alu_imm_vals[j] * rd_keep);
            op_alu_reg_write.push(op_alu_reg_vals[j] * rd_keep);
            let funct7_bits = [
                funct7_b0_vals[j],
                funct7_b1_vals[j],
                funct7_b2_vals[j],
                funct7_b3_vals[j],
                funct7_b4_vals[j],
                funct7_b5_vals[j],
                funct7_b6_vals[j],
            ];
            let funct3_is = [
                funct3_is0_vals[j],
                funct3_is1_vals[j],
                funct3_is2_vals[j],
                funct3_is3_vals[j],
                funct3_is4_vals[j],
                funct3_is5_vals[j],
                funct3_is6_vals[j],
                funct3_is7_vals[j],
            ];
            alu_reg_delta.push(decode_alu_reg_table_delta_from_bits(funct7_bits, funct3_is));
            alu_imm_delta.push(funct7_bits[5] * funct3_is[5]);
            alu_imm_shift_rhs_delta.push((funct3_is1_vals[j] + funct3_is5_vals[j]) * (rs2_vals[j] - imm_i_vals[j]));
        }
        decoded.insert(decode.op_lui_write, op_lui_write);
        decoded.insert(decode.op_auipc_write, op_auipc_write);
        decoded.insert(decode.op_jal_write, op_jal_write);
        decoded.insert(decode.op_jalr_write, op_jalr_write);
        decoded.insert(decode.op_alu_imm_write, op_alu_imm_write);
        decoded.insert(decode.op_alu_reg_write, op_alu_reg_write);
        decoded.insert(decode.alu_reg_table_delta, alu_reg_delta);
        decoded.insert(decode.alu_imm_table_delta, alu_imm_delta);
        decoded.insert(decode.alu_imm_shift_rhs_delta, alu_imm_shift_rhs_delta);

        decoded
    };

    let imm_i_vals = decode_decoded.get(&decode.imm_i).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing decode lookup-backed column {}", decode.imm_i))
    })?;
    let imm_s_vals = decode_decoded.get(&decode.imm_s).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing decode lookup-backed column {}", decode.imm_s))
    })?;
    let imm_b_vals = decode_decoded.get(&decode.imm_b).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing decode lookup-backed column {}", decode.imm_b))
    })?;
    let imm_j_vals = decode_decoded.get(&decode.imm_j).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing decode lookup-backed column {}", decode.imm_j))
    })?;
    let funct3_bit0_vals = decode_decoded.get(&decode.funct3_bit[0]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct3_bit[0]
        ))
    })?;
    let funct3_bit1_vals = decode_decoded.get(&decode.funct3_bit[1]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct3_bit[1]
        ))
    })?;
    let funct3_bit2_vals = decode_decoded.get(&decode.funct3_bit[2]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct3_bit[2]
        ))
    })?;
    let funct7_bit0_vals = decode_decoded.get(&decode.funct7_bit[0]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct7_bit[0]
        ))
    })?;
    let funct7_bit1_vals = decode_decoded.get(&decode.funct7_bit[1]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct7_bit[1]
        ))
    })?;
    let funct7_bit2_vals = decode_decoded.get(&decode.funct7_bit[2]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct7_bit[2]
        ))
    })?;
    let funct7_bit3_vals = decode_decoded.get(&decode.funct7_bit[3]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct7_bit[3]
        ))
    })?;
    let funct7_bit4_vals = decode_decoded.get(&decode.funct7_bit[4]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct7_bit[4]
        ))
    })?;
    let funct7_bit5_vals = decode_decoded.get(&decode.funct7_bit[5]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct7_bit[5]
        ))
    })?;
    let funct7_bit6_vals = decode_decoded.get(&decode.funct7_bit[6]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct7_bit[6]
        ))
    })?;
    let rd_bit0_vals = decode_decoded.get(&decode.rd_bit[0]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rd_bit[0]
        ))
    })?;
    let rd_bit1_vals = decode_decoded.get(&decode.rd_bit[1]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rd_bit[1]
        ))
    })?;
    let rd_bit2_vals = decode_decoded.get(&decode.rd_bit[2]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rd_bit[2]
        ))
    })?;
    let rd_bit3_vals = decode_decoded.get(&decode.rd_bit[3]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rd_bit[3]
        ))
    })?;
    let rd_bit4_vals = decode_decoded.get(&decode.rd_bit[4]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rd_bit[4]
        ))
    })?;
    let rs1_bit0_vals = decode_decoded.get(&decode.rs1_bit[0]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rs1_bit[0]
        ))
    })?;
    let rs1_bit1_vals = decode_decoded.get(&decode.rs1_bit[1]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rs1_bit[1]
        ))
    })?;
    let rs1_bit2_vals = decode_decoded.get(&decode.rs1_bit[2]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rs1_bit[2]
        ))
    })?;
    let rs1_bit3_vals = decode_decoded.get(&decode.rs1_bit[3]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rs1_bit[3]
        ))
    })?;
    let rs1_bit4_vals = decode_decoded.get(&decode.rs1_bit[4]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rs1_bit[4]
        ))
    })?;
    let rs2_bit0_vals = decode_decoded.get(&decode.rs2_bit[0]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rs2_bit[0]
        ))
    })?;
    let rs2_bit1_vals = decode_decoded.get(&decode.rs2_bit[1]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rs2_bit[1]
        ))
    })?;
    let rs2_bit2_vals = decode_decoded.get(&decode.rs2_bit[2]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rs2_bit[2]
        ))
    })?;
    let rs2_bit3_vals = decode_decoded.get(&decode.rs2_bit[3]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rs2_bit[3]
        ))
    })?;
    let rs2_bit4_vals = decode_decoded.get(&decode.rs2_bit[4]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rs2_bit[4]
        ))
    })?;
    for (col_id, vals) in [
        (decode.imm_i, imm_i_vals.as_slice()),
        (decode.imm_s, imm_s_vals.as_slice()),
        (decode.imm_b, imm_b_vals.as_slice()),
        (decode.imm_j, imm_j_vals.as_slice()),
        (decode.funct3_bit[0], funct3_bit0_vals.as_slice()),
        (decode.funct3_bit[1], funct3_bit1_vals.as_slice()),
        (decode.funct3_bit[2], funct3_bit2_vals.as_slice()),
        (decode.funct7_bit[0], funct7_bit0_vals.as_slice()),
        (decode.funct7_bit[1], funct7_bit1_vals.as_slice()),
        (decode.funct7_bit[2], funct7_bit2_vals.as_slice()),
        (decode.funct7_bit[3], funct7_bit3_vals.as_slice()),
        (decode.funct7_bit[4], funct7_bit4_vals.as_slice()),
        (decode.funct7_bit[5], funct7_bit5_vals.as_slice()),
        (decode.funct7_bit[6], funct7_bit6_vals.as_slice()),
        (decode.rd_bit[0], rd_bit0_vals.as_slice()),
        (decode.rd_bit[1], rd_bit1_vals.as_slice()),
        (decode.rd_bit[2], rd_bit2_vals.as_slice()),
        (decode.rd_bit[3], rd_bit3_vals.as_slice()),
        (decode.rd_bit[4], rd_bit4_vals.as_slice()),
        (decode.rs1_bit[0], rs1_bit0_vals.as_slice()),
        (decode.rs1_bit[1], rs1_bit1_vals.as_slice()),
        (decode.rs1_bit[2], rs1_bit2_vals.as_slice()),
        (decode.rs1_bit[3], rs1_bit3_vals.as_slice()),
        (decode.rs1_bit[4], rs1_bit4_vals.as_slice()),
        (decode.rs2_bit[0], rs2_bit0_vals.as_slice()),
        (decode.rs2_bit[1], rs2_bit1_vals.as_slice()),
        (decode.rs2_bit[2], rs2_bit2_vals.as_slice()),
        (decode.rs2_bit[3], rs2_bit3_vals.as_slice()),
        (decode.rs2_bit[4], rs2_bit4_vals.as_slice()),
    ] {
        ensure_column_len("decode(shared)", col_id, vals, t_len)?;
    }

    #[cfg(debug_assertions)]
    let cpu_active_vals = cpu_decoded
        .get(&trace.active)
        .ok_or_else(|| PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.active)))?;
    #[cfg(debug_assertions)]
    let cpu_halted_vals = cpu_decoded
        .get(&trace.halted)
        .ok_or_else(|| PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.halted)))?;
    #[cfg(debug_assertions)]
    let cpu_is_virtual_vals = cpu_decoded
        .get(&trace.is_virtual)
        .ok_or_else(|| PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.is_virtual)))?;
    #[cfg(debug_assertions)]
    let cpu_virtual_sequence_remaining_vals = cpu_decoded
        .get(&trace.virtual_sequence_remaining)
        .ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "decode missing CPU decoded column {}",
                trace.virtual_sequence_remaining
            ))
        })?;
    #[cfg(debug_assertions)]
    let cpu_virtual_commit_from_prev_vals = cpu_decoded
        .get(&trace.virtual_commit_from_prev)
        .ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "decode missing CPU decoded column {}",
                trace.virtual_commit_from_prev
            ))
        })?;
    #[cfg(debug_assertions)]
    let cpu_rs1_addr_vals = cpu_decoded
        .get(&trace.rs1_addr)
        .ok_or_else(|| PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.rs1_addr)))?;
    #[cfg(debug_assertions)]
    let cpu_rs2_addr_vals = cpu_decoded
        .get(&trace.rs2_addr)
        .ok_or_else(|| PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.rs2_addr)))?;
    #[cfg(debug_assertions)]
    let cpu_rd_addr_vals = cpu_decoded
        .get(&trace.rd_addr)
        .ok_or_else(|| PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.rd_addr)))?;
    #[cfg(debug_assertions)]
    let cpu_rs1_val_vals = cpu_decoded
        .get(&trace.rs1_val)
        .ok_or_else(|| PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.rs1_val)))?;
    #[cfg(debug_assertions)]
    let cpu_rs2_val_vals = cpu_decoded
        .get(&trace.rs2_val)
        .ok_or_else(|| PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.rs2_val)))?;
    #[cfg(debug_assertions)]
    let cpu_rd_val_vals = cpu_decoded
        .get(&trace.rd_val)
        .ok_or_else(|| PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.rd_val)))?;
    #[cfg(debug_assertions)]
    let cpu_rd_has_write_vals = cpu_decoded.get(&trace.rd_has_write).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.rd_has_write))
    })?;
    #[cfg(debug_assertions)]
    let cpu_ram_addr_vals = cpu_decoded
        .get(&trace.ram_addr)
        .ok_or_else(|| PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.ram_addr)))?;
    #[cfg(debug_assertions)]
    let cpu_shout_has_lookup_vals = cpu_decoded.get(&trace.shout_has_lookup).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.shout_has_lookup))
    })?;
    #[cfg(debug_assertions)]
    let cpu_shout_table_id_vals = cpu_decoded.get(&trace.shout_table_id).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.shout_table_id))
    })?;
    #[cfg(debug_assertions)]
    let cpu_shout_val_vals = cpu_decoded
        .get(&trace.shout_val)
        .ok_or_else(|| PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.shout_val)))?;
    #[cfg(debug_assertions)]
    let cpu_shout_lhs_vals = cpu_decoded
        .get(&trace.shout_lhs)
        .ok_or_else(|| PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.shout_lhs)))?;
    #[cfg(debug_assertions)]
    let cpu_shout_rhs_vals = cpu_decoded
        .get(&trace.shout_rhs)
        .ok_or_else(|| PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.shout_rhs)))?;
    #[cfg(debug_assertions)]
    let cpu_shout_add_sub_key_vals = cpu_decoded.get(&trace.shout_add_sub_key).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", trace.shout_add_sub_key))
    })?;
    #[cfg(debug_assertions)]
    let decode_opcode_vals = decode_decoded.get(&decode.opcode).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing decode lookup-backed column {}", decode.opcode))
    })?;
    #[cfg(debug_assertions)]
    let decode_rs1_addr_vals = decode_decoded.get(&decode.rs1).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing decode lookup-backed column {}", decode.rs1))
    })?;
    #[cfg(debug_assertions)]
    let decode_rs2_addr_vals = decode_decoded.get(&decode.rs2).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing decode lookup-backed column {}", decode.rs2))
    })?;
    #[cfg(debug_assertions)]
    let decode_rd_addr_vals = decode_decoded.get(&decode.rd).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing decode lookup-backed column {}", decode.rd))
    })?;
    #[cfg(debug_assertions)]
    let decode_rd_is_zero_vals = decode_decoded.get(&decode.rd_is_zero).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rd_is_zero
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_rd_has_write_vals = decode_decoded.get(&decode.rd_has_write).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.rd_has_write
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_ram_has_read_vals = decode_decoded.get(&decode.ram_has_read).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.ram_has_read
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_ram_has_write_vals = decode_decoded.get(&decode.ram_has_write).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.ram_has_write
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_op_lui_vals = decode_decoded.get(&decode.op_lui).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing decode lookup-backed column {}", decode.op_lui))
    })?;
    #[cfg(debug_assertions)]
    let decode_op_auipc_vals = decode_decoded.get(&decode.op_auipc).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.op_auipc
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_op_jal_vals = decode_decoded.get(&decode.op_jal).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing decode lookup-backed column {}", decode.op_jal))
    })?;
    #[cfg(debug_assertions)]
    let decode_op_jalr_vals = decode_decoded.get(&decode.op_jalr).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing decode lookup-backed column {}", decode.op_jalr))
    })?;
    #[cfg(debug_assertions)]
    let decode_op_branch_vals = decode_decoded.get(&decode.op_branch).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.op_branch
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_op_load_vals = decode_decoded.get(&decode.op_load).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing decode lookup-backed column {}", decode.op_load))
    })?;
    #[cfg(debug_assertions)]
    let decode_op_store_vals = decode_decoded.get(&decode.op_store).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.op_store
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_op_alu_imm_vals = decode_decoded.get(&decode.op_alu_imm).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.op_alu_imm
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_op_alu_reg_vals = decode_decoded.get(&decode.op_alu_reg).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.op_alu_reg
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_op_misc_mem_vals = decode_decoded.get(&decode.op_misc_mem).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.op_misc_mem
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_op_system_vals = decode_decoded.get(&decode.op_system).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.op_system
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_op_amo_vals = decode_decoded.get(&decode.op_amo).ok_or_else(|| {
        PiCcsError::ProtocolError(format!("decode missing decode lookup-backed column {}", decode.op_amo))
    })?;
    #[cfg(debug_assertions)]
    let decode_op_custom_vals = decode_decoded.get(&decode.op_custom).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.op_custom
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_funct3_is0_vals = decode_decoded.get(&decode.funct3_is[0]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct3_is[0]
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_funct3_is1_vals = decode_decoded.get(&decode.funct3_is[1]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct3_is[1]
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_funct3_is2_vals = decode_decoded.get(&decode.funct3_is[2]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct3_is[2]
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_funct3_is3_vals = decode_decoded.get(&decode.funct3_is[3]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct3_is[3]
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_funct3_is4_vals = decode_decoded.get(&decode.funct3_is[4]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct3_is[4]
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_funct3_is5_vals = decode_decoded.get(&decode.funct3_is[5]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct3_is[5]
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_funct3_is6_vals = decode_decoded.get(&decode.funct3_is[6]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct3_is[6]
        ))
    })?;
    #[cfg(debug_assertions)]
    let decode_funct3_is7_vals = decode_decoded.get(&decode.funct3_is[7]).ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "decode missing decode lookup-backed column {}",
            decode.funct3_is[7]
        ))
    })?;

    let mut imm_residual_vals: Vec<Vec<K>> = (0..DECODE_IMM_RESIDUAL_COUNT)
        .map(|_| Vec::with_capacity(t_len))
        .collect();
    for j in 0..t_len {
        let funct3_bits = [funct3_bit0_vals[j], funct3_bit1_vals[j], funct3_bit2_vals[j]];
        let funct7_bits = [
            funct7_bit0_vals[j],
            funct7_bit1_vals[j],
            funct7_bit2_vals[j],
            funct7_bit3_vals[j],
            funct7_bit4_vals[j],
            funct7_bit5_vals[j],
            funct7_bit6_vals[j],
        ];
        let imm = decode_immediate_residuals(
            imm_i_vals[j],
            imm_s_vals[j],
            imm_b_vals[j],
            imm_j_vals[j],
            [
                rd_bit0_vals[j],
                rd_bit1_vals[j],
                rd_bit2_vals[j],
                rd_bit3_vals[j],
                rd_bit4_vals[j],
            ],
            funct3_bits,
            [
                rs1_bit0_vals[j],
                rs1_bit1_vals[j],
                rs1_bit2_vals[j],
                rs1_bit3_vals[j],
                rs1_bit4_vals[j],
            ],
            [
                rs2_bit0_vals[j],
                rs2_bit1_vals[j],
                rs2_bit2_vals[j],
                rs2_bit3_vals[j],
                rs2_bit4_vals[j],
            ],
            funct7_bits,
        );

        #[cfg(debug_assertions)]
        {
            let active = cpu_active_vals[j];
            let halted = cpu_halted_vals[j];
            let is_virtual = cpu_is_virtual_vals[j];
            let virtual_sequence_remaining = cpu_virtual_sequence_remaining_vals[j];
            let virtual_commit_from_prev = cpu_virtual_commit_from_prev_vals[j];
            let trace_rs1_addr = cpu_rs1_addr_vals[j];
            let trace_rs2_addr = cpu_rs2_addr_vals[j];
            let trace_rd_addr = cpu_rd_addr_vals[j];
            let trace_rd_has_write = cpu_rd_has_write_vals[j];
            let decode_opcode = decode_opcode_vals[j];
            let decode_rd_has_write = decode_rd_has_write_vals[j];
            let decode_rs1_addr = decode_rs1_addr_vals[j];
            let decode_rs2_addr = decode_rs2_addr_vals[j];
            let decode_rd_addr = decode_rd_addr_vals[j];
            let rd_is_zero = decode_rd_is_zero_vals[j];
            let rs1_val = cpu_rs1_val_vals[j];
            let rs2_val = cpu_rs2_val_vals[j];
            let rd_val = cpu_rd_val_vals[j];
            let shout_has_lookup = cpu_shout_has_lookup_vals[j];
            let shout_table_id = cpu_shout_table_id_vals[j];
            let shout_val = cpu_shout_val_vals[j];
            let shout_lhs = cpu_shout_lhs_vals[j];
            let shout_rhs = cpu_shout_rhs_vals[j];
            let shout_add_sub_key = cpu_shout_add_sub_key_vals[j];
            let rs1_word = if let Some(rv64_trace) = _rv64_trace.as_ref() {
                cpu_decoded.get(&rv64_trace.rs1_val_lo32).ok_or_else(|| {
                    PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", rv64_trace.rs1_val_lo32))
                })?[j]
            } else {
                rs1_val
            };
            let rs2_word = if let Some(rv64_trace) = _rv64_trace.as_ref() {
                cpu_decoded.get(&rv64_trace.rs2_val_lo32).ok_or_else(|| {
                    PiCcsError::ProtocolError(format!("decode missing CPU decoded column {}", rv64_trace.rs2_val_lo32))
                })?[j]
            } else {
                rs2_val
            };
            let shout_lhs_word = if let Some(rv64_trace) = _rv64_trace.as_ref() {
                cpu_decoded.get(&rv64_trace.shout_lhs_lo32).ok_or_else(|| {
                    PiCcsError::ProtocolError(format!(
                        "decode missing CPU decoded column {}",
                        rv64_trace.shout_lhs_lo32
                    ))
                })?[j]
            } else {
                shout_lhs
            };
            let shout_lhs_hi = if let Some(rv64_trace) = _rv64_trace.as_ref() {
                cpu_decoded.get(&rv64_trace.shout_lhs_hi32).ok_or_else(|| {
                    PiCcsError::ProtocolError(format!(
                        "decode missing CPU decoded column {}",
                        rv64_trace.shout_lhs_hi32
                    ))
                })?[j]
            } else {
                K::ZERO
            };
            let shout_rhs_word = if let Some(rv64_trace) = _rv64_trace.as_ref() {
                cpu_decoded.get(&rv64_trace.shout_rhs_lo32).ok_or_else(|| {
                    PiCcsError::ProtocolError(format!(
                        "decode missing CPU decoded column {}",
                        rv64_trace.shout_rhs_lo32
                    ))
                })?[j]
            } else {
                shout_rhs
            };
            let shout_rhs_hi = if let Some(rv64_trace) = _rv64_trace.as_ref() {
                cpu_decoded.get(&rv64_trace.shout_rhs_hi32).ok_or_else(|| {
                    PiCcsError::ProtocolError(format!(
                        "decode missing CPU decoded column {}",
                        rv64_trace.shout_rhs_hi32
                    ))
                })?[j]
            } else {
                K::ZERO
            };
            let shout_add_sub_key_word = if let Some(rv64_trace) = _rv64_trace.as_ref() {
                cpu_decoded
                    .get(&rv64_trace.shout_add_sub_key_lo32)
                    .ok_or_else(|| {
                        PiCcsError::ProtocolError(format!(
                            "decode missing CPU decoded column {}",
                            rv64_trace.shout_add_sub_key_lo32
                        ))
                    })?[j]
            } else {
                shout_add_sub_key
            };
            let shout_add_sub_key_hi = if let Some(rv64_trace) = _rv64_trace.as_ref() {
                cpu_decoded
                    .get(&rv64_trace.shout_add_sub_key_hi32)
                    .ok_or_else(|| {
                        PiCcsError::ProtocolError(format!(
                            "decode missing CPU decoded column {}",
                            rv64_trace.shout_add_sub_key_hi32
                        ))
                    })?[j]
            } else {
                K::ZERO
            };
            let ram_has_read = decode_ram_has_read_vals[j];
            let ram_has_write = decode_ram_has_write_vals[j];
            let ram_addr = cpu_ram_addr_vals[j];
            let opcode_flags = [
                decode_op_lui_vals[j],
                decode_op_auipc_vals[j],
                decode_op_jal_vals[j],
                decode_op_jalr_vals[j],
                decode_op_branch_vals[j],
                decode_op_load_vals[j],
                decode_op_store_vals[j],
                decode_op_alu_imm_vals[j],
                decode_op_alu_reg_vals[j],
                decode_op_misc_mem_vals[j],
                decode_op_system_vals[j],
                decode_op_amo_vals[j],
            ];
            let op_custom = decode_op_custom_vals[j];
            let funct3_is = [
                decode_funct3_is0_vals[j],
                decode_funct3_is1_vals[j],
                decode_funct3_is2_vals[j],
                decode_funct3_is3_vals[j],
                decode_funct3_is4_vals[j],
                decode_funct3_is5_vals[j],
                decode_funct3_is6_vals[j],
                decode_funct3_is7_vals[j],
            ];

            let op_write_flags = [
                opcode_flags[0] * (K::ONE - rd_is_zero),
                opcode_flags[1] * (K::ONE - rd_is_zero),
                opcode_flags[2] * (K::ONE - rd_is_zero),
                opcode_flags[3] * (K::ONE - rd_is_zero),
                opcode_flags[7] * (K::ONE - rd_is_zero),
                opcode_flags[8] * (K::ONE - rd_is_zero),
            ];
            let alu_reg_table_delta = decode_alu_reg_table_delta_from_bits(funct7_bits, funct3_is);
            let alu_imm_table_delta = funct7_bits[5] * funct3_is[5];
            let alu_imm_shift_rhs_delta = (funct3_is[1] + funct3_is[5]) * (decode_rs2_addr - imm_i_vals[j]);
            let selector_residuals = decode_selector_residuals(
                active,
                decode_opcode,
                opcode_flags,
                op_custom,
                funct3_is,
                funct3_bits,
                opcode_flags[11],
            );
            let bitness_residuals = decode_bitness_residuals(opcode_flags, funct3_is);
            let alu_branch_residuals = decode_alu_branch_lookup_residuals(
                rv64_exact_words,
                active,
                is_virtual,
                virtual_sequence_remaining,
                virtual_commit_from_prev,
                halted,
                shout_has_lookup,
                shout_lhs,
                shout_rhs,
                shout_add_sub_key,
                shout_table_id,
                decode_opcode,
                trace_rs1_addr,
                trace_rs2_addr,
                trace_rd_addr,
                decode_rs1_addr,
                decode_rs2_addr,
                decode_rd_addr,
                rs1_val,
                rs2_val,
                rs1_word,
                rs2_word,
                shout_lhs_word,
                shout_lhs_hi,
                shout_rhs_word,
                shout_rhs_hi,
                shout_add_sub_key_word,
                shout_add_sub_key_hi,
                trace_rd_has_write,
                decode_rd_has_write,
                rd_is_zero,
                rd_val,
                ram_has_read,
                ram_has_write,
                ram_addr,
                shout_val,
                funct3_bits,
                funct7_bits,
                opcode_flags,
                op_write_flags,
                funct3_is,
                alu_reg_table_delta,
                alu_imm_table_delta,
                alu_imm_shift_rhs_delta,
                decode_rs2_addr,
                imm_i_vals[j],
                imm_s_vals[j],
            );
            if let Some((idx, _)) = selector_residuals
                .iter()
                .enumerate()
                .find(|(_, r)| **r != K::ZERO)
            {
                return Err(PiCcsError::ProtocolError(format!(
                    "decode/fields selector residual non-zero at row={j}, idx={idx}"
                )));
            }
            if let Some((idx, _)) = bitness_residuals
                .iter()
                .enumerate()
                .find(|(_, r)| **r != K::ZERO)
            {
                return Err(PiCcsError::ProtocolError(format!(
                    "decode/fields bitness residual non-zero at row={j}, idx={idx}"
                )));
            }
            if let Some((idx, _)) = alu_branch_residuals
                .iter()
                .enumerate()
                .find(|(_, r)| **r != K::ZERO)
            {
                return Err(PiCcsError::ProtocolError(format!(
                    "decode/fields alu_branch residual non-zero at row={j}, idx={idx}"
                )));
            }
        }

        for (k, r) in imm.iter().enumerate() {
            imm_residual_vals[k].push(*r);
        }
    }

    let mut main_field_cols = vec![
        trace.active,
        trace.halted,
        trace.is_virtual,
        trace.virtual_sequence_remaining,
        trace.virtual_commit_from_prev,
        trace.rs1_addr,
        trace.rs2_addr,
        trace.rd_addr,
        trace.rs1_val,
        trace.rs2_val,
        trace.rd_val,
    ];
    if rv64_exact_words {
        main_field_cols.extend(rv64_trace_exact_word_opening_columns());
    }
    main_field_cols.extend([
        trace.rd_has_write,
        trace.ram_addr,
        trace.shout_has_lookup,
        trace.shout_table_id,
        trace.shout_val,
        trace.shout_lhs,
        trace.shout_rhs,
        trace.shout_add_sub_key,
    ]);
    let decode_field_cols = vec![
        decode.opcode,
        decode.rs1,
        decode.rs2,
        decode.rd,
        decode.rd_is_zero,
        decode.rd_has_write,
        decode.ram_has_read,
        decode.ram_has_write,
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
        decode.funct3_is[0],
        decode.funct3_is[1],
        decode.funct3_is[2],
        decode.funct3_is[3],
        decode.funct3_is[4],
        decode.funct3_is[5],
        decode.funct3_is[6],
        decode.funct3_is[7],
        decode.funct3_bit[0],
        decode.funct3_bit[1],
        decode.funct3_bit[2],
        decode.funct7_bit[0],
        decode.funct7_bit[1],
        decode.funct7_bit[2],
        decode.funct7_bit[3],
        decode.funct7_bit[4],
        decode.funct7_bit[5],
        decode.funct7_bit[6],
        decode.imm_i,
        decode.imm_s,
    ];
    let mut fields_sparse_cols = Vec::with_capacity(main_field_cols.len() + decode_field_cols.len());
    for &col_id in main_field_cols.iter() {
        let vals = cpu_decoded
            .get(&col_id)
            .ok_or_else(|| PiCcsError::ProtocolError(format!("decode missing CPU decoded column {col_id}")))?;
        fields_sparse_cols.push(sparse_trace_col_from_values(m_in, ell_n, vals)?);
    }
    for &col_id in decode_field_cols.iter() {
        let vals = decode_decoded
            .get(&col_id)
            .ok_or_else(|| PiCcsError::ProtocolError(format!("decode missing decode lookup-backed column {col_id}")))?;
        fields_sparse_cols.push(sparse_trace_col_from_values(m_in, ell_n, vals)?);
    }

    let mut imm_sparse_cols = Vec::with_capacity(imm_residual_vals.len());
    for vals in imm_residual_vals.iter() {
        imm_sparse_cols.push(sparse_trace_col_from_values(m_in, ell_n, vals)?);
    }

    let pow2_cycle = 1usize
        .checked_shl(ell_n as u32)
        .ok_or_else(|| PiCcsError::InvalidInput("decode: 2^ell_n overflow".into()))?;
    let active_zero = SparseIdxVec::from_entries(pow2_cycle, Vec::new());
    let fields_weights = decode_pack_weight_vector(r_cycle, DECODE_FIELDS_RESIDUAL_COUNT);
    let eval_fields_openings = move |vals: &[K]| {
        let mut cursor = ValueCursor::new(vals);
        let mut decode_inputs = DecodeFieldsOpenings {
            rv64_exact_words,
            active: cursor.take(),
            halted: cursor.take(),
            is_virtual: cursor.take(),
            virtual_sequence_remaining: cursor.take(),
            virtual_commit_from_prev: cursor.take(),
            trace_rs1_addr: cursor.take(),
            trace_rs2_addr: cursor.take(),
            trace_rd_addr: cursor.take(),
            rs1_val: cursor.take(),
            rs2_val: cursor.take(),
            rd_val: cursor.take(),
            rs1_word: if rv64_exact_words { cursor.take() } else { K::ZERO },
            rs2_word: if rv64_exact_words { cursor.take() } else { K::ZERO },
            rd_word: if rv64_exact_words { cursor.take() } else { K::ZERO },
            shout_lhs_word: if rv64_exact_words { cursor.take() } else { K::ZERO },
            shout_lhs_hi: if rv64_exact_words { cursor.take() } else { K::ZERO },
            shout_rhs_word: if rv64_exact_words { cursor.take() } else { K::ZERO },
            shout_rhs_hi: if rv64_exact_words { cursor.take() } else { K::ZERO },
            shout_add_sub_key_word: if rv64_exact_words { cursor.take() } else { K::ZERO },
            shout_add_sub_key_hi: if rv64_exact_words { cursor.take() } else { K::ZERO },
            trace_rd_has_write: cursor.take(),
            ram_addr: cursor.take(),
            shout_has_lookup: cursor.take(),
            shout_table_id: cursor.take(),
            shout_val: cursor.take(),
            shout_lhs: cursor.take(),
            shout_rhs: cursor.take(),
            shout_add_sub_key: cursor.take(),
            decode_opcode: cursor.take(),
            decode_rs1_addr: cursor.take(),
            decode_rs2_addr: cursor.take(),
            decode_rd_addr: cursor.take(),
            rd_is_zero: cursor.take(),
            decode_rd_has_write: cursor.take(),
            ram_has_read: cursor.take(),
            ram_has_write: cursor.take(),
            opcode_flags: cursor.take_arr::<12>(),
            op_custom: cursor.take(),
            funct3_is: cursor.take_arr::<8>(),
            funct3_bits: cursor.take_arr::<3>(),
            funct7_bits: cursor.take_arr::<7>(),
            imm_i: cursor.take(),
            imm_s: cursor.take(),
        };
        if !rv64_exact_words {
            decode_inputs.rs1_word = decode_inputs.rs1_val;
            decode_inputs.rs2_word = decode_inputs.rs2_val;
            decode_inputs.rd_word = decode_inputs.rd_val;
            decode_inputs.shout_lhs_word = decode_inputs.shout_lhs;
            decode_inputs.shout_rhs_word = decode_inputs.shout_rhs;
            decode_inputs.shout_add_sub_key_word = decode_inputs.shout_add_sub_key;
        }
        let consumed = cursor.consumed();
        if consumed != vals.len() {
            panic!(
                "decode/fields cursor length mismatch: consumed={}, vals={}",
                consumed,
                vals.len()
            );
        }
        decode_inputs
    };
    let eval_fields = move |vals: &[K]| {
        let decode_inputs = eval_fields_openings(vals);
        decode_fields_weighted_residual_with_scratch(&decode_inputs, &fields_weights)
    };
    let pair_domain = pow2_cycle >> 1;
    let mut pair_vals0 = vec![K::ZERO; fields_sparse_cols.len()];
    let mut pair_vals1 = vec![K::ZERO; fields_sparse_cols.len()];
    for pair in 0..pair_domain {
        let child0 = 2 * pair;
        let child1 = child0 + 1;
        for (col_idx, col) in fields_sparse_cols.iter().enumerate() {
            pair_vals0[col_idx] = col.get(child0);
            pair_vals1[col_idx] = col.get(child1);
        }
        let pair_sum = eval_fields(&pair_vals0) + eval_fields(&pair_vals1);
        if pair_sum != K::ZERO {
            let row0 = eval_fields_openings(&pair_vals0);
            let row1 = eval_fields_openings(&pair_vals1);
            let row0_selector = decode_selector_residuals(
                row0.active,
                row0.decode_opcode,
                row0.opcode_flags,
                row0.op_custom,
                row0.funct3_is,
                row0.funct3_bits,
                row0.opcode_flags[11],
            );
            let row1_selector = decode_selector_residuals(
                row1.active,
                row1.decode_opcode,
                row1.opcode_flags,
                row1.op_custom,
                row1.funct3_is,
                row1.funct3_bits,
                row1.opcode_flags[11],
            );
            let row0_bitness = decode_bitness_residuals(row0.opcode_flags, row0.funct3_is);
            let row1_bitness = decode_bitness_residuals(row1.opcode_flags, row1.funct3_is);
            let row0_op_write_flags = [
                row0.opcode_flags[0] * (K::ONE - row0.rd_is_zero),
                row0.opcode_flags[1] * (K::ONE - row0.rd_is_zero),
                row0.opcode_flags[2] * (K::ONE - row0.rd_is_zero),
                row0.opcode_flags[3] * (K::ONE - row0.rd_is_zero),
                row0.opcode_flags[7] * (K::ONE - row0.rd_is_zero),
                row0.opcode_flags[8] * (K::ONE - row0.rd_is_zero),
            ];
            let row1_op_write_flags = [
                row1.opcode_flags[0] * (K::ONE - row1.rd_is_zero),
                row1.opcode_flags[1] * (K::ONE - row1.rd_is_zero),
                row1.opcode_flags[2] * (K::ONE - row1.rd_is_zero),
                row1.opcode_flags[3] * (K::ONE - row1.rd_is_zero),
                row1.opcode_flags[7] * (K::ONE - row1.rd_is_zero),
                row1.opcode_flags[8] * (K::ONE - row1.rd_is_zero),
            ];
            let mut row0_alu = Vec::with_capacity(DECODE_FIELDS_RESIDUAL_COUNT);
            decode_alu_branch_lookup_residuals_into(
                row0.rv64_exact_words,
                row0.active,
                row0.is_virtual,
                row0.virtual_sequence_remaining,
                row0.virtual_commit_from_prev,
                row0.halted,
                row0.shout_has_lookup,
                row0.shout_lhs,
                row0.shout_rhs,
                row0.shout_add_sub_key,
                row0.shout_table_id,
                row0.decode_opcode,
                row0.trace_rs1_addr,
                row0.trace_rs2_addr,
                row0.trace_rd_addr,
                row0.decode_rs1_addr,
                row0.decode_rs2_addr,
                row0.decode_rd_addr,
                row0.rs1_val,
                row0.rs2_val,
                row0.rs1_word,
                row0.rs2_word,
                row0.shout_lhs_word,
                row0.shout_lhs_hi,
                row0.shout_rhs_word,
                row0.shout_rhs_hi,
                row0.shout_add_sub_key_word,
                row0.shout_add_sub_key_hi,
                row0.trace_rd_has_write,
                row0.decode_rd_has_write,
                row0.rd_is_zero,
                row0.rd_val,
                row0.ram_has_read,
                row0.ram_has_write,
                row0.ram_addr,
                row0.shout_val,
                row0.funct3_bits,
                row0.funct7_bits,
                row0.opcode_flags,
                row0_op_write_flags,
                row0.funct3_is,
                decode_alu_reg_table_delta_from_bits(row0.funct7_bits, row0.funct3_is),
                row0.funct7_bits[5] * row0.funct3_is[5],
                (row0.funct3_is[1] + row0.funct3_is[5]) * (row0.decode_rs2_addr - row0.imm_i),
                row0.decode_rs2_addr,
                row0.imm_i,
                row0.imm_s,
                &mut row0_alu,
            );
            let mut row1_alu = Vec::with_capacity(DECODE_FIELDS_RESIDUAL_COUNT);
            decode_alu_branch_lookup_residuals_into(
                row1.rv64_exact_words,
                row1.active,
                row1.is_virtual,
                row1.virtual_sequence_remaining,
                row1.virtual_commit_from_prev,
                row1.halted,
                row1.shout_has_lookup,
                row1.shout_lhs,
                row1.shout_rhs,
                row1.shout_add_sub_key,
                row1.shout_table_id,
                row1.decode_opcode,
                row1.trace_rs1_addr,
                row1.trace_rs2_addr,
                row1.trace_rd_addr,
                row1.decode_rs1_addr,
                row1.decode_rs2_addr,
                row1.decode_rd_addr,
                row1.rs1_val,
                row1.rs2_val,
                row1.rs1_word,
                row1.rs2_word,
                row1.shout_lhs_word,
                row1.shout_lhs_hi,
                row1.shout_rhs_word,
                row1.shout_rhs_hi,
                row1.shout_add_sub_key_word,
                row1.shout_add_sub_key_hi,
                row1.trace_rd_has_write,
                row1.decode_rd_has_write,
                row1.rd_is_zero,
                row1.rd_val,
                row1.ram_has_read,
                row1.ram_has_write,
                row1.ram_addr,
                row1.shout_val,
                row1.funct3_bits,
                row1.funct7_bits,
                row1.opcode_flags,
                row1_op_write_flags,
                row1.funct3_is,
                decode_alu_reg_table_delta_from_bits(row1.funct7_bits, row1.funct3_is),
                row1.funct7_bits[5] * row1.funct3_is[5],
                (row1.funct3_is[1] + row1.funct3_is[5]) * (row1.decode_rs2_addr - row1.imm_i),
                row1.decode_rs2_addr,
                row1.imm_i,
                row1.imm_s,
                &mut row1_alu,
            );
            let row0_selector_nz: Vec<_> = row0_selector
                .iter()
                .copied()
                .enumerate()
                .filter(|(_, v)| *v != K::ZERO)
                .collect();
            let row1_selector_nz: Vec<_> = row1_selector
                .iter()
                .copied()
                .enumerate()
                .filter(|(_, v)| *v != K::ZERO)
                .collect();
            let row0_bitness_nz: Vec<_> = row0_bitness
                .iter()
                .copied()
                .enumerate()
                .filter(|(_, v)| *v != K::ZERO)
                .collect();
            let row1_bitness_nz: Vec<_> = row1_bitness
                .iter()
                .copied()
                .enumerate()
                .filter(|(_, v)| *v != K::ZERO)
                .collect();
            let row0_alu_nz: Vec<_> = row0_alu
                .iter()
                .copied()
                .enumerate()
                .filter(|(_, v)| *v != K::ZERO)
                .collect();
            let row1_alu_nz: Vec<_> = row1_alu
                .iter()
                .copied()
                .enumerate()
                .filter(|(_, v)| *v != K::ZERO)
                .collect();
            return Err(PiCcsError::ProtocolError(format!(
                "decode/fields round0 local invariant mismatch at pair={pair}, rows=({child0},{child1}), \
                active=({:?}, {:?}), rs1_addr=({:?}, {:?}), rs2_addr=({:?}, {:?}), rd_addr=({:?}, {:?}), \
                decode_rs1_addr=({:?}, {:?}), decode_rs2_addr=({:?}, {:?}), decode_rd_addr=({:?}, {:?}), trace_rd_has_write=({:?}, {:?}), decode_rd_has_write=({:?}, {:?}), \
                rs1_val=({:?}, {:?}), rs2_val=({:?}, {:?}), rd_val=({:?}, {:?}), \
                decode_opcode=({:?}, {:?}), shout_has_lookup=({:?}, {:?}), shout_table_id=({:?}, {:?}), \
                shout_val=({:?}, {:?}), shout_lhs=({:?}, {:?}), shout_rhs=({:?}, {:?}), shout_add_sub_key=({:?}, {:?}), \
                imm_i=({:?}, {:?}), imm_s=({:?}, {:?}), \
                row0_selector_nz={:?}, row1_selector_nz={:?}, row0_bitness_nz={:?}, row1_bitness_nz={:?}, row0_alu_nz={:?}, row1_alu_nz={:?}, \
                is_virtual=({:?}, {:?}), remaining=({:?}, {:?})",
                row0.active, row1.active,
                row0.trace_rs1_addr, row1.trace_rs1_addr,
                row0.trace_rs2_addr, row1.trace_rs2_addr,
                row0.trace_rd_addr, row1.trace_rd_addr,
                row0.decode_rs1_addr, row1.decode_rs1_addr,
                row0.decode_rs2_addr, row1.decode_rs2_addr,
                row0.decode_rd_addr, row1.decode_rd_addr,
                row0.trace_rd_has_write, row1.trace_rd_has_write,
                row0.decode_rd_has_write, row1.decode_rd_has_write,
                row0.rs1_val, row1.rs1_val,
                row0.rs2_val, row1.rs2_val,
                row0.rd_val, row1.rd_val,
                row0.decode_opcode, row1.decode_opcode,
                row0.shout_has_lookup, row1.shout_has_lookup,
                row0.shout_table_id, row1.shout_table_id,
                row0.shout_val, row1.shout_val,
                row0.shout_lhs, row1.shout_lhs,
                row0.shout_rhs, row1.shout_rhs,
                row0.shout_add_sub_key, row1.shout_add_sub_key,
                row0.imm_i, row1.imm_i,
                row0.imm_s, row1.imm_s,
                row0_selector_nz,
                row1_selector_nz,
                row0_bitness_nz,
                row1_bitness_nz,
                row0_alu_nz,
                row1_alu_nz,
                row0.is_virtual, row1.is_virtual,
                row0.virtual_sequence_remaining, row1.virtual_sequence_remaining,
            )));
        }
    }
    let fields_oracle =
        FormulaOracleSparseTime::new(fields_sparse_cols, DECODE_FIELDS_DEGREE_BOUND, r_cycle, eval_fields);
    let imm_oracle = WeightedMaskOracleSparseTime::new(
        active_zero,
        imm_sparse_cols,
        decode_imm_weight_vector(r_cycle, 4),
        r_cycle,
    );

    Ok((
        Some((Box::new(fields_oracle), K::ZERO)),
        Some((Box::new(imm_oracle), K::ZERO)),
    ))
}

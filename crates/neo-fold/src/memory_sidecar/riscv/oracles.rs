use super::*;
use neo_memory::riscv::lookups::RiscvOpcode;
use neo_memory::twist_oracle::{
    Rv64PackedDivOracleSparseTime, Rv64PackedDivRemAdapterOracleSparseTime, Rv64PackedDivRemuAdapterOracleSparseTime,
    Rv64PackedDivuOracleSparseTime, Rv64PackedMulHiOracleSparseTime, Rv64PackedMulOracleSparseTime,
    Rv64PackedMulhAdapterOracleSparseTime, Rv64PackedMulhsuAdapterOracleSparseTime, Rv64PackedMulhuOracleSparseTime,
    Rv64PackedRemOracleSparseTime, Rv64PackedRemuOracleSparseTime,
};

pub(crate) fn build_route_a_memory_oracles(
    params: &NeoParams,
    step: &StepWitnessBundle<Cmt, F, K>,
    ell_n: usize,
    r_cycle: &[K],
    shout_pre: &ShoutAddrPreBatchProverData,
    twist_pre: &[TwistAddrPreProverData],
) -> Result<RouteAMemoryOracles, PiCcsError> {
    if ell_n != r_cycle.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "Route A: ell_n mismatch (ell_n={ell_n}, r_cycle.len()={})",
            r_cycle.len()
        )));
    }
    if shout_pre.decoded.len() != step.lut_instances.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "shout pre-time count mismatch (expected {}, got {})",
            step.lut_instances.len(),
            shout_pre.decoded.len()
        )));
    }
    if twist_pre.len() != step.mem_instances.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "twist pre-time decoded count mismatch (expected {}, got {})",
            step.mem_instances.len(),
            twist_pre.len()
        )));
    }
    let trace_is_virtual_sparse = if control_stage_required_for_step_witness(step) {
        let trace = neo_memory::riscv::trace::Rv64TraceLayout::new();
        let t_len = step.time_columns.t;
        let decoded = decode_trace_col_values_batch(params, step, t_len, &[trace.is_virtual])?;
        let is_virtual_vals = decoded.get(&trace.is_virtual).ok_or_else(|| {
            PiCcsError::ProtocolError("virtual-domain oracle: missing is_virtual trace column".into())
        })?;
        Some(sparse_trace_col_from_values(step.mcs.0.m_in, ell_n, is_virtual_vals)?)
    } else {
        None
    };

    let mut shout_oracles = Vec::with_capacity(step.lut_instances.len());
    let shout_gamma_specs =
        RouteATimeClaimPlan::derive_shout_gamma_groups_for_instances(step.lut_instances.iter().map(|(inst, _)| inst));
    let mut shout_lane_to_gamma: std::collections::HashMap<(usize, usize), usize> = std::collections::HashMap::new();
    for (g_idx, g) in shout_gamma_specs.iter().enumerate() {
        for lane in g.lanes.iter() {
            shout_lane_to_gamma.insert((lane.inst_idx, lane.lane_idx), g_idx);
        }
    }
    let mut r_addr_by_ell: std::collections::BTreeMap<u32, &[K]> = std::collections::BTreeMap::new();
    for g in shout_pre.addr_pre.groups.iter() {
        r_addr_by_ell.insert(g.ell_addr, g.r_addr.as_slice());
    }
    for (lut_idx, ((lut_inst, _lut_wit), decoded)) in step
        .lut_instances
        .iter()
        .zip(shout_pre.decoded.iter())
        .enumerate()
    {
        let ell_addr = lut_inst.d * lut_inst.ell;
        let ell_addr_u32 = u32::try_from(ell_addr)
            .map_err(|_| PiCcsError::InvalidInput("Shout(Route A): ell_addr overflows u32".into()))?;
        let r_addr = *r_addr_by_ell
            .get(&ell_addr_u32)
            .ok_or_else(|| PiCcsError::ProtocolError("missing shout addr-pre group r_addr".into()))?;
        if r_addr.len() != ell_addr {
            return Err(PiCcsError::InvalidInput(format!(
                "Shout(Route A): r_addr.len()={} != ell_addr={}",
                r_addr.len(),
                ell_addr
            )));
        }

        if decoded.lanes.is_empty() {
            return Err(PiCcsError::InvalidInput(format!(
                "Shout(Route A): decoded lanes empty at lut_idx={lut_idx}"
            )));
        }

        let lane_count = decoded.lanes.len();
        let mut lanes: Vec<RouteAShoutTimeLaneOracles> = Vec::with_capacity(lane_count);

        let packed_layout = packed_opcode_layout(&lut_inst.table_spec)?;
        let packed_op = packed_layout.map(|(op, _xlen)| op);
        let packed_xlen = packed_layout.map(|(_op, xlen)| xlen).unwrap_or(0);
        let is_packed = packed_op.is_some();

        for (lane_idx, lane) in decoded.lanes.iter().enumerate() {
            let gamma_group = shout_lane_to_gamma.get(&(lut_idx, lane_idx)).copied();
            if let Some(op) = packed_op {
                let packed_cols: &[SparseIdxVec<K>] = &lane.addr_bits;
                let lhs = packed_cols
                    .get(0)
                    .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V: missing lhs column".into()))?
                    .clone();
                let rhs = packed_cols
                    .get(1)
                    .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V: missing rhs column".into()))?
                    .clone();

                // Packed bitwise (AND/OR/XOR): base-4 digit decomposition.
                let (bitwise_lhs_digits, bitwise_rhs_digits) = match op {
                    PackedOpcodeKind::And | PackedOpcodeKind::Andn | PackedOpcodeKind::Or | PackedOpcodeKind::Xor => {
                        if packed_cols.len() != 34 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V bitwise: expected ell_addr=34, got {}",
                                packed_cols.len()
                            )));
                        }
                        let lhs_digits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(2).take(16).cloned().collect();
                        let rhs_digits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(18).take(16).cloned().collect();
                        if lhs_digits.len() != 16 || rhs_digits.len() != 16 {
                            return Err(PiCcsError::ProtocolError(
                                "packed RISC-V bitwise: digit slice length mismatch".into(),
                            ));
                        }
                        (lhs_digits, rhs_digits)
                    }
                    _ => (Vec::new(), Vec::new()),
                };

                let value_oracle: Box<dyn RoundOracle + Send> = match op {
                    PackedOpcodeKind::And => Box::new(Rv32PackedAndOracleSparseTime::new(
                        r_cycle,
                        lane.has_lookup.clone(),
                        bitwise_lhs_digits.clone(),
                        bitwise_rhs_digits.clone(),
                        lane.val.clone(),
                    )),
                    PackedOpcodeKind::Andn => Box::new(Rv32PackedAndnOracleSparseTime::new(
                        r_cycle,
                        lane.has_lookup.clone(),
                        bitwise_lhs_digits.clone(),
                        bitwise_rhs_digits.clone(),
                        lane.val.clone(),
                    )),
                    PackedOpcodeKind::Add => Box::new(Rv32PackedAddOracleSparseTime::new(
                        r_cycle,
                        lane.has_lookup.clone(),
                        lhs.clone(),
                        rhs.clone(),
                        packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V ADD: missing carry column".into()))?
                            .clone(),
                        lane.val.clone(),
                    )),
                    PackedOpcodeKind::Or => Box::new(Rv32PackedOrOracleSparseTime::new(
                        r_cycle,
                        lane.has_lookup.clone(),
                        bitwise_lhs_digits.clone(),
                        bitwise_rhs_digits.clone(),
                        lane.val.clone(),
                    )),
                    PackedOpcodeKind::Sub => Box::new(Rv32PackedSubOracleSparseTime::new(
                        r_cycle,
                        lane.has_lookup.clone(),
                        lhs.clone(),
                        rhs.clone(),
                        packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V SUB: missing borrow column".into()))?
                            .clone(),
                        lane.val.clone(),
                    )),
                    PackedOpcodeKind::Xor => Box::new(Rv32PackedXorOracleSparseTime::new(
                        r_cycle,
                        lane.has_lookup.clone(),
                        bitwise_lhs_digits.clone(),
                        bitwise_rhs_digits.clone(),
                        lane.val.clone(),
                    )),
                    PackedOpcodeKind::Eq => Box::new(Rv32PackedEqOracleSparseTime::new(
                        r_cycle,
                        lane.has_lookup.clone(),
                        {
                            let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(3).cloned().collect();
                            if diff_bits.len() != 32 {
                                return Err(PiCcsError::InvalidInput(format!(
                                    "packed RISC-V EQ: expected 32 diff bits, got {}",
                                    diff_bits.len()
                                )));
                            }
                            diff_bits
                        },
                        lane.val.clone(),
                    )),
                    PackedOpcodeKind::Neq => Box::new(Rv32PackedNeqOracleSparseTime::new(
                        r_cycle,
                        lane.has_lookup.clone(),
                        {
                            let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(3).cloned().collect();
                            if diff_bits.len() != 32 {
                                return Err(PiCcsError::InvalidInput(format!(
                                    "packed RISC-V NEQ: expected 32 diff bits, got {}",
                                    diff_bits.len()
                                )));
                            }
                            diff_bits
                        },
                        lane.val.clone(),
                    )),
                    PackedOpcodeKind::Mul => {
                        let carry_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(2).cloned().collect();
                        let expected_bits = if packed_xlen == 64 { 64 } else { 32 };
                        if carry_bits.len() != expected_bits {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V MUL: expected {expected_bits} carry bits, got {}",
                                carry_bits.len()
                            )));
                        }
                        if packed_xlen == 64 {
                            Box::new(Rv64PackedMulOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs.clone(),
                                rhs.clone(),
                                carry_bits,
                                lane.val.clone(),
                            ))
                        } else {
                            Box::new(Rv32PackedMulOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs.clone(),
                                rhs.clone(),
                                carry_bits,
                                lane.val.clone(),
                            ))
                        }
                    }
                    PackedOpcodeKind::Mulhu => {
                        let lo_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(2).cloned().collect();
                        let expected_bits = if packed_xlen == 64 { 64 } else { 32 };
                        if lo_bits.len() != expected_bits {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V MULHU: expected {expected_bits} lo bits, got {}",
                                lo_bits.len()
                            )));
                        }
                        if packed_xlen == 64 {
                            Box::new(Rv64PackedMulhuOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs.clone(),
                                rhs.clone(),
                                lo_bits,
                                lane.val.clone(),
                            ))
                        } else {
                            Box::new(Rv32PackedMulhuOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs.clone(),
                                rhs.clone(),
                                lo_bits,
                                lane.val.clone(),
                            ))
                        }
                    }
                    PackedOpcodeKind::Mulh => {
                        let hi = packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V MULH: missing hi opening".into()))?
                            .clone();
                        let lo_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(6).cloned().collect();
                        let expected_bits = if packed_xlen == 64 { 64 } else { 32 };
                        if lo_bits.len() != expected_bits {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V MULH: expected {expected_bits} lo bits, got {}",
                                lo_bits.len()
                            )));
                        }
                        if packed_xlen == 64 {
                            Box::new(Rv64PackedMulHiOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs.clone(),
                                rhs.clone(),
                                lo_bits,
                                hi,
                            ))
                        } else {
                            Box::new(Rv32PackedMulHiOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs.clone(),
                                rhs.clone(),
                                lo_bits,
                                hi,
                            ))
                        }
                    }
                    PackedOpcodeKind::Mulhsu => {
                        let hi = packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V MULHSU: missing hi opening".into()))?
                            .clone();
                        let lo_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(5).cloned().collect();
                        let expected_bits = if packed_xlen == 64 { 64 } else { 32 };
                        if lo_bits.len() != expected_bits {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V MULHSU: expected {expected_bits} lo bits, got {}",
                                lo_bits.len()
                            )));
                        }
                        if packed_xlen == 64 {
                            Box::new(Rv64PackedMulHiOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs.clone(),
                                rhs.clone(),
                                lo_bits,
                                hi,
                            ))
                        } else {
                            Box::new(Rv32PackedMulHiOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs.clone(),
                                rhs.clone(),
                                lo_bits,
                                hi,
                            ))
                        }
                    }
                    PackedOpcodeKind::Slt => {
                        let lhs_sign = packed_cols
                            .get(3)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V SLT: missing lhs_sign bit".into()))?
                            .clone();
                        let rhs_sign = packed_cols
                            .get(4)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V SLT: missing rhs_sign bit".into()))?
                            .clone();
                        let diff = packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V SLT: missing diff opening".into()))?
                            .clone();
                        Box::new(Rv32PackedSltOracleSparseTime::new(
                            r_cycle,
                            lane.has_lookup.clone(),
                            lhs.clone(),
                            rhs.clone(),
                            lhs_sign,
                            rhs_sign,
                            diff,
                            lane.val.clone(),
                        ))
                    }
                    PackedOpcodeKind::Divu => {
                        let rem = packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIVU: missing rem opening".into()))?
                            .clone();
                        let rhs_is_zero = packed_cols
                            .get(3)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIVU: missing rhs_is_zero".into()))?
                            .clone();
                        if packed_xlen == 64 {
                            Box::new(Rv64PackedDivuOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs.clone(),
                                rhs.clone(),
                                rem,
                                rhs_is_zero,
                                lane.val.clone(),
                            ))
                        } else {
                            Box::new(Rv32PackedDivuOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs.clone(),
                                rhs.clone(),
                                rem,
                                rhs_is_zero,
                                lane.val.clone(),
                            ))
                        }
                    }
                    PackedOpcodeKind::Remu => {
                        let quot = packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REMU: missing quot opening".into()))?
                            .clone();
                        let rhs_is_zero = packed_cols
                            .get(3)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REMU: missing rhs_is_zero".into()))?
                            .clone();
                        if packed_xlen == 64 {
                            Box::new(Rv64PackedRemuOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs.clone(),
                                rhs.clone(),
                                quot,
                                rhs_is_zero,
                                lane.val.clone(),
                            ))
                        } else {
                            Box::new(Rv32PackedRemuOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs.clone(),
                                rhs.clone(),
                                quot,
                                rhs_is_zero,
                                lane.val.clone(),
                            ))
                        }
                    }
                    PackedOpcodeKind::Div => {
                        let rhs_is_zero = packed_cols
                            .get(4)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing rhs_is_zero".into()))?
                            .clone();
                        let lhs_sign = packed_cols
                            .get(5)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing lhs_sign".into()))?
                            .clone();
                        let rhs_sign = packed_cols
                            .get(6)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing rhs_sign".into()))?
                            .clone();
                        let q_abs = packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing q_abs".into()))?
                            .clone();
                        let q_is_zero = packed_cols
                            .get(7)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing q_is_zero".into()))?
                            .clone();
                        if packed_xlen == 64 {
                            Box::new(Rv64PackedDivOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs_sign,
                                rhs_sign,
                                rhs_is_zero,
                                q_abs,
                                q_is_zero,
                                lane.val.clone(),
                            ))
                        } else {
                            Box::new(Rv32PackedDivOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs_sign,
                                rhs_sign,
                                rhs_is_zero,
                                q_abs,
                                q_is_zero,
                                lane.val.clone(),
                            ))
                        }
                    }
                    PackedOpcodeKind::Rem => {
                        let rhs_is_zero = packed_cols
                            .get(4)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REM: missing rhs_is_zero".into()))?
                            .clone();
                        let lhs_sign = packed_cols
                            .get(5)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REM: missing lhs_sign".into()))?
                            .clone();
                        let r_abs = packed_cols
                            .get(3)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REM: missing r_abs".into()))?
                            .clone();
                        let r_is_zero = packed_cols
                            .get(7)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REM: missing r_is_zero".into()))?
                            .clone();
                        if packed_xlen == 64 {
                            Box::new(Rv64PackedRemOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs.clone(),
                                lhs_sign,
                                rhs_is_zero,
                                r_abs,
                                r_is_zero,
                                lane.val.clone(),
                            ))
                        } else {
                            Box::new(Rv32PackedRemOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs.clone(),
                                lhs_sign,
                                rhs_is_zero,
                                r_abs,
                                r_is_zero,
                                lane.val.clone(),
                            ))
                        }
                    }
                    PackedOpcodeKind::Sll => {
                        let shamt_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(1).take(5).cloned().collect();
                        if shamt_bits.len() != 5 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SLL: expected 5 shamt bits, got {}",
                                shamt_bits.len()
                            )));
                        }
                        let carry_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(6).cloned().collect();
                        if carry_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SLL: expected 32 carry bits, got {}",
                                carry_bits.len()
                            )));
                        }
                        Box::new(Rv32PackedSllOracleSparseTime::new(
                            r_cycle,
                            lane.has_lookup.clone(),
                            lhs.clone(),
                            shamt_bits,
                            carry_bits,
                            lane.val.clone(),
                        ))
                    }
                    PackedOpcodeKind::Srl => {
                        let shamt_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(1).take(5).cloned().collect();
                        if shamt_bits.len() != 5 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SRL: expected 5 shamt bits, got {}",
                                shamt_bits.len()
                            )));
                        }
                        let rem_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(6).cloned().collect();
                        if rem_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SRL: expected 32 rem bits, got {}",
                                rem_bits.len()
                            )));
                        }
                        Box::new(Rv32PackedSrlOracleSparseTime::new(
                            r_cycle,
                            lane.has_lookup.clone(),
                            lhs.clone(),
                            shamt_bits,
                            rem_bits,
                            lane.val.clone(),
                        ))
                    }
                    PackedOpcodeKind::Sra => {
                        let shamt_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(1).take(5).cloned().collect();
                        if shamt_bits.len() != 5 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SRA: expected 5 shamt bits, got {}",
                                shamt_bits.len()
                            )));
                        }
                        let sign = packed_cols
                            .get(6)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V SRA: missing sign bit".into()))?
                            .clone();
                        let rem_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(7).cloned().collect();
                        if rem_bits.len() != 31 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SRA: expected 31 rem bits, got {}",
                                rem_bits.len()
                            )));
                        }
                        Box::new(Rv32PackedSraOracleSparseTime::new(
                            r_cycle,
                            lane.has_lookup.clone(),
                            lhs.clone(),
                            shamt_bits,
                            sign,
                            rem_bits,
                            lane.val.clone(),
                        ))
                    }
                    PackedOpcodeKind::Sltu => Box::new(Rv32PackedSltuOracleSparseTime::new(
                        r_cycle,
                        lane.has_lookup.clone(),
                        lhs.clone(),
                        rhs.clone(),
                        packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V SLTU: missing diff opening".into()))?
                            .clone(),
                        lane.val.clone(),
                    )),
                };
                let adapter_oracle: Box<dyn RoundOracle + Send> = match op {
                    PackedOpcodeKind::And | PackedOpcodeKind::Andn | PackedOpcodeKind::Or | PackedOpcodeKind::Xor => {
                        let weights = bitness_weights(r_cycle, 34, 0x4249_5457_4F50u64 + lut_idx as u64);
                        Box::new(Rv32PackedBitwiseAdapterOracleSparseTime::new(
                            r_cycle,
                            lane.has_lookup.clone(),
                            lhs,
                            rhs,
                            bitwise_lhs_digits,
                            bitwise_rhs_digits,
                            weights,
                        ))
                    }
                    PackedOpcodeKind::Add
                    | PackedOpcodeKind::Sub
                    | PackedOpcodeKind::Sll
                    | PackedOpcodeKind::Mul
                    | PackedOpcodeKind::Mulhu => Box::new(ZeroOracleSparseTime::new(r_cycle.len(), 2)),
                    PackedOpcodeKind::Mulh => {
                        let hi = packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V MULH: missing hi opening".into()))?
                            .clone();
                        let lhs_sign = packed_cols
                            .get(3)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V MULH: missing lhs_sign".into()))?
                            .clone();
                        let rhs_sign = packed_cols
                            .get(4)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V MULH: missing rhs_sign".into()))?
                            .clone();
                        let k = packed_cols
                            .get(5)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V MULH: missing k opening".into()))?
                            .clone();
                        let weights = bitness_weights(r_cycle, 2, 0x4D55_4C48_4144_5054u64 + lut_idx as u64);
                        let w = [weights[0], weights[1]];
                        if packed_xlen == 64 {
                            Box::new(Rv64PackedMulhAdapterOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs,
                                rhs,
                                lhs_sign,
                                rhs_sign,
                                hi,
                                k,
                                lane.val.clone(),
                                w,
                            ))
                        } else {
                            Box::new(Rv32PackedMulhAdapterOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs,
                                rhs,
                                lhs_sign,
                                rhs_sign,
                                hi,
                                k,
                                lane.val.clone(),
                                w,
                            ))
                        }
                    }
                    PackedOpcodeKind::Mulhsu => {
                        let hi = packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V MULHSU: missing hi opening".into()))?
                            .clone();
                        let lhs_sign = packed_cols
                            .get(3)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V MULHSU: missing lhs_sign".into()))?
                            .clone();
                        let borrow = packed_cols
                            .get(4)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V MULHSU: missing borrow".into()))?
                            .clone();
                        if packed_xlen == 64 {
                            Box::new(Rv64PackedMulhsuAdapterOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs,
                                rhs,
                                lhs_sign,
                                hi,
                                borrow,
                                lane.val.clone(),
                            ))
                        } else {
                            Box::new(Rv32PackedMulhsuAdapterOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs,
                                rhs,
                                lhs_sign,
                                hi,
                                borrow,
                                lane.val.clone(),
                            ))
                        }
                    }
                    PackedOpcodeKind::Divu => {
                        let rem = packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIVU: missing rem opening".into()))?
                            .clone();
                        let rhs_is_zero = packed_cols
                            .get(3)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIVU: missing rhs_is_zero".into()))?
                            .clone();
                        let diff = packed_cols
                            .get(4)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIVU: missing diff".into()))?
                            .clone();
                        let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(5).cloned().collect();
                        let expected_bits = if packed_xlen == 64 { 64 } else { 32 };
                        if diff_bits.len() != expected_bits {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V DIVU: expected {expected_bits} diff bits, got {}",
                                diff_bits.len()
                            )));
                        }
                        let weights = bitness_weights(r_cycle, 4, 0x4449_5655_4144_5054u64 + lut_idx as u64);
                        let w = [weights[0], weights[1], weights[2], weights[3]];
                        if packed_xlen == 64 {
                            Box::new(Rv64PackedDivRemuAdapterOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                rhs,
                                rhs_is_zero,
                                rem,
                                diff,
                                diff_bits,
                                w,
                            ))
                        } else {
                            Box::new(Rv32PackedDivRemuAdapterOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                rhs,
                                rhs_is_zero,
                                rem,
                                diff,
                                diff_bits,
                                w,
                            ))
                        }
                    }
                    PackedOpcodeKind::Remu => {
                        let rhs_is_zero = packed_cols
                            .get(3)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REMU: missing rhs_is_zero".into()))?
                            .clone();
                        let diff = packed_cols
                            .get(4)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REMU: missing diff".into()))?
                            .clone();
                        let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(5).cloned().collect();
                        let expected_bits = if packed_xlen == 64 { 64 } else { 32 };
                        if diff_bits.len() != expected_bits {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V REMU: expected {expected_bits} diff bits, got {}",
                                diff_bits.len()
                            )));
                        }
                        let weights = bitness_weights(r_cycle, 4, 0x4449_5655_4144_5054u64 + lut_idx as u64);
                        let w = [weights[0], weights[1], weights[2], weights[3]];
                        if packed_xlen == 64 {
                            Box::new(Rv64PackedDivRemuAdapterOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                rhs,
                                rhs_is_zero,
                                lane.val.clone(),
                                diff,
                                diff_bits,
                                w,
                            ))
                        } else {
                            Box::new(Rv32PackedDivRemuAdapterOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                rhs,
                                rhs_is_zero,
                                lane.val.clone(),
                                diff,
                                diff_bits,
                                w,
                            ))
                        }
                    }
                    PackedOpcodeKind::Div => {
                        let rhs_is_zero = packed_cols
                            .get(4)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing rhs_is_zero".into()))?
                            .clone();
                        let lhs_sign = packed_cols
                            .get(5)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing lhs_sign".into()))?
                            .clone();
                        let rhs_sign = packed_cols
                            .get(6)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing rhs_sign".into()))?
                            .clone();
                        let q_abs = packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing q_abs".into()))?
                            .clone();
                        let r_abs = packed_cols
                            .get(3)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing r_abs".into()))?
                            .clone();
                        let q_is_zero = packed_cols
                            .get(7)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing q_is_zero".into()))?
                            .clone();
                        let diff = packed_cols
                            .get(8)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing diff".into()))?
                            .clone();
                        let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(9).cloned().collect();
                        let expected_bits = if packed_xlen == 64 { 64 } else { 32 };
                        if diff_bits.len() != expected_bits {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V DIV: expected {expected_bits} diff bits, got {}",
                                diff_bits.len()
                            )));
                        }
                        let weights = bitness_weights(r_cycle, 7, 0x4449_565F_4144_5054u64 + lut_idx as u64);
                        let w = [
                            weights[0], weights[1], weights[2], weights[3], weights[4], weights[5], weights[6],
                        ];
                        if packed_xlen == 64 {
                            Box::new(Rv64PackedDivRemAdapterOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs,
                                rhs,
                                rhs_is_zero,
                                lhs_sign,
                                rhs_sign,
                                q_abs.clone(),
                                r_abs,
                                q_abs,
                                q_is_zero,
                                diff,
                                diff_bits,
                                w,
                            ))
                        } else {
                            Box::new(Rv32PackedDivRemAdapterOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs,
                                rhs,
                                rhs_is_zero,
                                lhs_sign,
                                rhs_sign,
                                q_abs.clone(),
                                r_abs,
                                q_abs,
                                q_is_zero,
                                diff,
                                diff_bits,
                                w,
                            ))
                        }
                    }
                    PackedOpcodeKind::Rem => {
                        let rhs_is_zero = packed_cols
                            .get(4)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REM: missing rhs_is_zero".into()))?
                            .clone();
                        let lhs_sign = packed_cols
                            .get(5)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REM: missing lhs_sign".into()))?
                            .clone();
                        let rhs_sign = packed_cols
                            .get(6)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REM: missing rhs_sign".into()))?
                            .clone();
                        let q_abs = packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REM: missing q_abs".into()))?
                            .clone();
                        let r_abs = packed_cols
                            .get(3)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REM: missing r_abs".into()))?
                            .clone();
                        let r_is_zero = packed_cols
                            .get(7)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REM: missing r_is_zero".into()))?
                            .clone();
                        let diff = packed_cols
                            .get(8)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REM: missing diff".into()))?
                            .clone();
                        let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(9).cloned().collect();
                        let expected_bits = if packed_xlen == 64 { 64 } else { 32 };
                        if diff_bits.len() != expected_bits {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V REM: expected {expected_bits} diff bits, got {}",
                                diff_bits.len()
                            )));
                        }
                        let weights = bitness_weights(r_cycle, 7, 0x4449_565F_4144_5054u64 + lut_idx as u64);
                        let w = [
                            weights[0], weights[1], weights[2], weights[3], weights[4], weights[5], weights[6],
                        ];
                        if packed_xlen == 64 {
                            Box::new(Rv64PackedDivRemAdapterOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs,
                                rhs,
                                rhs_is_zero,
                                lhs_sign,
                                rhs_sign,
                                q_abs,
                                r_abs.clone(),
                                r_abs,
                                r_is_zero,
                                diff,
                                diff_bits,
                                w,
                            ))
                        } else {
                            Box::new(Rv32PackedDivRemAdapterOracleSparseTime::new(
                                r_cycle,
                                lane.has_lookup.clone(),
                                lhs,
                                rhs,
                                rhs_is_zero,
                                lhs_sign,
                                rhs_sign,
                                q_abs,
                                r_abs.clone(),
                                r_abs,
                                r_is_zero,
                                diff,
                                diff_bits,
                                w,
                            ))
                        }
                    }
                    PackedOpcodeKind::Slt => {
                        let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(5).cloned().collect();
                        if diff_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SLT: expected 32 diff bits, got {}",
                                diff_bits.len()
                            )));
                        }
                        Box::new(U32DecompOracleSparseTime::new(
                            r_cycle,
                            lane.has_lookup.clone(),
                            packed_cols
                                .get(2)
                                .ok_or_else(|| {
                                    PiCcsError::InvalidInput("packed RISC-V SLT: missing diff opening".into())
                                })?
                                .clone(),
                            diff_bits,
                        ))
                    }
                    PackedOpcodeKind::Srl => {
                        let shamt_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(1).take(5).cloned().collect();
                        if shamt_bits.len() != 5 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SRL: expected 5 shamt bits, got {}",
                                shamt_bits.len()
                            )));
                        }
                        let rem_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(6).cloned().collect();
                        if rem_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SRL: expected 32 rem bits, got {}",
                                rem_bits.len()
                            )));
                        }
                        Box::new(Rv32PackedSrlAdapterOracleSparseTime::new(
                            r_cycle,
                            lane.has_lookup.clone(),
                            shamt_bits,
                            rem_bits,
                        ))
                    }
                    PackedOpcodeKind::Sra => {
                        let shamt_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(1).take(5).cloned().collect();
                        if shamt_bits.len() != 5 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SRA: expected 5 shamt bits, got {}",
                                shamt_bits.len()
                            )));
                        }
                        let rem_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(7).cloned().collect();
                        if rem_bits.len() != 31 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SRA: expected 31 rem bits, got {}",
                                rem_bits.len()
                            )));
                        }
                        Box::new(Rv32PackedSraAdapterOracleSparseTime::new(
                            r_cycle,
                            lane.has_lookup.clone(),
                            shamt_bits,
                            rem_bits,
                        ))
                    }
                    PackedOpcodeKind::Eq => Box::new(Rv32PackedEqAdapterOracleSparseTime::new(
                        r_cycle,
                        lane.has_lookup.clone(),
                        lhs,
                        rhs,
                        packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V EQ: missing borrow bit".into()))?
                            .clone(),
                        {
                            let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(3).cloned().collect();
                            if diff_bits.len() != 32 {
                                return Err(PiCcsError::InvalidInput(format!(
                                    "packed RISC-V EQ: expected 32 diff bits, got {}",
                                    diff_bits.len()
                                )));
                            }
                            diff_bits
                        },
                    )),
                    PackedOpcodeKind::Neq => Box::new(Rv32PackedNeqAdapterOracleSparseTime::new(
                        r_cycle,
                        lane.has_lookup.clone(),
                        lhs,
                        rhs,
                        packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V NEQ: missing borrow bit".into()))?
                            .clone(),
                        {
                            let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(3).cloned().collect();
                            if diff_bits.len() != 32 {
                                return Err(PiCcsError::InvalidInput(format!(
                                    "packed RISC-V NEQ: expected 32 diff bits, got {}",
                                    diff_bits.len()
                                )));
                            }
                            diff_bits
                        },
                    )),
                    PackedOpcodeKind::Sltu => {
                        let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(3).cloned().collect();
                        if diff_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SLTU: expected 32 diff bits, got {}",
                                diff_bits.len()
                            )));
                        }
                        Box::new(U32DecompOracleSparseTime::new(
                            r_cycle,
                            lane.has_lookup.clone(),
                            packed_cols
                                .get(2)
                                .ok_or_else(|| {
                                    PiCcsError::InvalidInput("packed RISC-V SLTU: missing diff opening".into())
                                })?
                                .clone(),
                            diff_bits,
                        ))
                    }
                };

                lanes.push(RouteAShoutTimeLaneOracles {
                    value: value_oracle,
                    // Enforce correctness: claim must be 0.
                    value_claim: K::ZERO,
                    adapter: adapter_oracle,
                    adapter_claim: K::ZERO,
                    gamma_group: None,
                });
            } else {
                let (value_oracle, value_claim) =
                    ShoutValueOracleSparse::new(r_cycle, lane.has_lookup.clone(), lane.val.clone());

                let (adapter_oracle, adapter_claim) = IndexAdapterOracleSparseTime::new_with_gate(
                    r_cycle,
                    lane.has_lookup.clone(),
                    lane.addr_bits.clone(),
                    r_addr,
                );

                lanes.push(RouteAShoutTimeLaneOracles {
                    value: Box::new(value_oracle),
                    value_claim,
                    adapter: Box::new(adapter_oracle),
                    adapter_claim,
                    gamma_group,
                });
            }
        }

        let bitness: Vec<Box<dyn RoundOracle + Send>> = if is_packed {
            // Packed Shout: boolean columns depend on the packed op.
            let mut bit_cols: Vec<SparseIdxVec<K>> = Vec::new();
            for lane in decoded.lanes.iter() {
                let packed_cols: &[SparseIdxVec<K>] = &lane.addr_bits;
                if packed_xlen == 64
                    && matches!(
                        packed_op,
                        Some(
                            PackedOpcodeKind::Mul
                                | PackedOpcodeKind::Mulh
                                | PackedOpcodeKind::Mulhu
                                | PackedOpcodeKind::Mulhsu
                                | PackedOpcodeKind::Div
                                | PackedOpcodeKind::Divu
                                | PackedOpcodeKind::Rem
                                | PackedOpcodeKind::Remu
                        )
                    )
                {
                    let opcode = match packed_op.expect("packed_op present when is_packed=true") {
                        PackedOpcodeKind::Mul => RiscvOpcode::Mul,
                        PackedOpcodeKind::Mulh => RiscvOpcode::Mulh,
                        PackedOpcodeKind::Mulhu => RiscvOpcode::Mulhu,
                        PackedOpcodeKind::Mulhsu => RiscvOpcode::Mulhsu,
                        PackedOpcodeKind::Div => RiscvOpcode::Div,
                        PackedOpcodeKind::Divu => RiscvOpcode::Divu,
                        PackedOpcodeKind::Rem => RiscvOpcode::Rem,
                        PackedOpcodeKind::Remu => RiscvOpcode::Remu,
                        _ => unreachable!(),
                    };
                    let mut lane_terms = neo_memory::riscv::packed::rv_collect_packed_bitness_terms(
                        opcode,
                        64,
                        packed_cols,
                        lane.has_lookup.clone(),
                        lane.val.clone(),
                    )?;
                    bit_cols.append(&mut lane_terms);
                    continue;
                }
                match packed_op {
                    Some(
                        PackedOpcodeKind::And | PackedOpcodeKind::Andn | PackedOpcodeKind::Or | PackedOpcodeKind::Xor,
                    ) => {
                        bit_cols.push(lane.has_lookup.clone());
                    }
                    Some(PackedOpcodeKind::Add | PackedOpcodeKind::Sub) => {
                        let aux = packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V: missing aux column".into()))?
                            .clone();
                        bit_cols.push(aux);
                        bit_cols.push(lane.has_lookup.clone());
                    }
                    Some(PackedOpcodeKind::Eq | PackedOpcodeKind::Neq) => {
                        let borrow = packed_cols
                            .get(2)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V EQ/NEQ: missing borrow bit".into()))?
                            .clone();
                        let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(3).cloned().collect();
                        if diff_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V EQ/NEQ: expected 32 diff bits, got {}",
                                diff_bits.len()
                            )));
                        }
                        bit_cols.push(lane.has_lookup.clone());
                        bit_cols.push(lane.val.clone());
                        bit_cols.push(borrow);
                        bit_cols.extend(diff_bits);
                    }
                    Some(PackedOpcodeKind::Mul) => {
                        let carry_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(2).cloned().collect();
                        if carry_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V MUL: expected 32 carry bits, got {}",
                                carry_bits.len()
                            )));
                        }
                        bit_cols.push(lane.has_lookup.clone());
                        bit_cols.extend(carry_bits);
                    }
                    Some(PackedOpcodeKind::Mulhu) => {
                        let lo_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(2).cloned().collect();
                        if lo_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V MULHU: expected 32 lo bits, got {}",
                                lo_bits.len()
                            )));
                        }
                        bit_cols.push(lane.has_lookup.clone());
                        bit_cols.extend(lo_bits);
                    }
                    Some(PackedOpcodeKind::Mulh) => {
                        let lhs_sign = packed_cols
                            .get(3)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V MULH: missing lhs_sign bit".into()))?
                            .clone();
                        let rhs_sign = packed_cols
                            .get(4)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V MULH: missing rhs_sign bit".into()))?
                            .clone();
                        let lo_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(6).cloned().collect();
                        if lo_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V MULH: expected 32 lo bits, got {}",
                                lo_bits.len()
                            )));
                        }
                        bit_cols.push(lane.has_lookup.clone());
                        bit_cols.push(lhs_sign);
                        bit_cols.push(rhs_sign);
                        bit_cols.extend(lo_bits);
                    }
                    Some(PackedOpcodeKind::Mulhsu) => {
                        let lhs_sign = packed_cols
                            .get(3)
                            .ok_or_else(|| {
                                PiCcsError::InvalidInput("packed RISC-V MULHSU: missing lhs_sign bit".into())
                            })?
                            .clone();
                        let borrow = packed_cols
                            .get(4)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V MULHSU: missing borrow bit".into()))?
                            .clone();
                        let lo_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(5).cloned().collect();
                        if lo_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V MULHSU: expected 32 lo bits, got {}",
                                lo_bits.len()
                            )));
                        }
                        bit_cols.push(lane.has_lookup.clone());
                        bit_cols.push(lhs_sign);
                        bit_cols.push(borrow);
                        bit_cols.extend(lo_bits);
                    }
                    Some(PackedOpcodeKind::Slt) => {
                        let lhs_sign = packed_cols
                            .get(3)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V SLT: missing lhs_sign bit".into()))?
                            .clone();
                        let rhs_sign = packed_cols
                            .get(4)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V SLT: missing rhs_sign bit".into()))?
                            .clone();
                        let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(5).cloned().collect();
                        if diff_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SLT: expected 32 diff bits, got {}",
                                diff_bits.len()
                            )));
                        }
                        bit_cols.push(lane.val.clone());
                        bit_cols.push(lane.has_lookup.clone());
                        bit_cols.push(lhs_sign);
                        bit_cols.push(rhs_sign);
                        bit_cols.extend(diff_bits);
                    }
                    Some(PackedOpcodeKind::Sll) => {
                        let shamt_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(1).take(5).cloned().collect();
                        if shamt_bits.len() != 5 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SLL: expected 5 shamt bits, got {}",
                                shamt_bits.len()
                            )));
                        }
                        let carry_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(6).cloned().collect();
                        if carry_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SLL: expected 32 carry bits, got {}",
                                carry_bits.len()
                            )));
                        }
                        bit_cols.push(lane.has_lookup.clone());
                        bit_cols.extend(shamt_bits);
                        bit_cols.extend(carry_bits);
                    }
                    Some(PackedOpcodeKind::Srl) => {
                        let shamt_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(1).take(5).cloned().collect();
                        if shamt_bits.len() != 5 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SRL: expected 5 shamt bits, got {}",
                                shamt_bits.len()
                            )));
                        }
                        let rem_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(6).cloned().collect();
                        if rem_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SRL: expected 32 rem bits, got {}",
                                rem_bits.len()
                            )));
                        }
                        bit_cols.push(lane.has_lookup.clone());
                        bit_cols.extend(shamt_bits);
                        bit_cols.extend(rem_bits);
                    }
                    Some(PackedOpcodeKind::Sra) => {
                        let shamt_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(1).take(5).cloned().collect();
                        if shamt_bits.len() != 5 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SRA: expected 5 shamt bits, got {}",
                                shamt_bits.len()
                            )));
                        }
                        let sign = packed_cols
                            .get(6)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V SRA: missing sign bit".into()))?
                            .clone();
                        let rem_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(7).cloned().collect();
                        if rem_bits.len() != 31 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SRA: expected 31 rem bits, got {}",
                                rem_bits.len()
                            )));
                        }
                        bit_cols.push(lane.has_lookup.clone());
                        bit_cols.extend(shamt_bits);
                        bit_cols.push(sign);
                        bit_cols.extend(rem_bits);
                    }
                    Some(PackedOpcodeKind::Sltu) => {
                        let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(3).cloned().collect();
                        if diff_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V SLTU: expected 32 diff bits, got {}",
                                diff_bits.len()
                            )));
                        }
                        bit_cols.push(lane.val.clone());
                        bit_cols.push(lane.has_lookup.clone());
                        bit_cols.extend(diff_bits);
                    }
                    Some(PackedOpcodeKind::Divu | PackedOpcodeKind::Remu) => {
                        let rhs_is_zero = packed_cols
                            .get(3)
                            .ok_or_else(|| {
                                PiCcsError::InvalidInput("packed RISC-V DIVU/REMU: missing rhs_is_zero".into())
                            })?
                            .clone();
                        let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(5).cloned().collect();
                        if diff_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V DIVU/REMU: expected 32 diff bits, got {}",
                                diff_bits.len()
                            )));
                        }
                        bit_cols.push(lane.has_lookup.clone());
                        bit_cols.push(rhs_is_zero);
                        bit_cols.extend(diff_bits);
                    }
                    Some(PackedOpcodeKind::Div) => {
                        let rhs_is_zero = packed_cols
                            .get(4)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing rhs_is_zero".into()))?
                            .clone();
                        let lhs_sign = packed_cols
                            .get(5)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing lhs_sign".into()))?
                            .clone();
                        let rhs_sign = packed_cols
                            .get(6)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing rhs_sign".into()))?
                            .clone();
                        let q_is_zero = packed_cols
                            .get(7)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V DIV: missing q_is_zero".into()))?
                            .clone();
                        let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(9).cloned().collect();
                        if diff_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V DIV: expected 32 diff bits, got {}",
                                diff_bits.len()
                            )));
                        }
                        bit_cols.push(lane.has_lookup.clone());
                        bit_cols.push(rhs_is_zero);
                        bit_cols.push(lhs_sign);
                        bit_cols.push(rhs_sign);
                        bit_cols.push(q_is_zero);
                        bit_cols.extend(diff_bits);
                    }
                    Some(PackedOpcodeKind::Rem) => {
                        let rhs_is_zero = packed_cols
                            .get(4)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REM: missing rhs_is_zero".into()))?
                            .clone();
                        let lhs_sign = packed_cols
                            .get(5)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REM: missing lhs_sign".into()))?
                            .clone();
                        let rhs_sign = packed_cols
                            .get(6)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REM: missing rhs_sign".into()))?
                            .clone();
                        let r_is_zero = packed_cols
                            .get(7)
                            .ok_or_else(|| PiCcsError::InvalidInput("packed RISC-V REM: missing r_is_zero".into()))?
                            .clone();
                        let diff_bits: Vec<SparseIdxVec<K>> = packed_cols.iter().skip(9).cloned().collect();
                        if diff_bits.len() != 32 {
                            return Err(PiCcsError::InvalidInput(format!(
                                "packed RISC-V REM: expected 32 diff bits, got {}",
                                diff_bits.len()
                            )));
                        }
                        bit_cols.push(lane.has_lookup.clone());
                        bit_cols.push(rhs_is_zero);
                        bit_cols.push(lhs_sign);
                        bit_cols.push(rhs_sign);
                        bit_cols.push(r_is_zero);
                        bit_cols.extend(diff_bits);
                    }
                    None => {
                        return Err(PiCcsError::ProtocolError(
                            "packed_op drift: is_packed=true but packed_op=None".into(),
                        ));
                    }
                }
            }
            let weights = bitness_weights(r_cycle, bit_cols.len(), 0x5348_4F55_54u64 + lut_idx as u64);
            let bitness_oracle = LazyWeightedBitnessOracleSparseTime::new_with_cycle(r_cycle, bit_cols, weights);
            vec![Box::new(bitness_oracle)]
        } else {
            let mut bit_cols: Vec<SparseIdxVec<K>> = Vec::with_capacity(lane_count * (ell_addr + 1));
            for (lane_idx, lane) in decoded.lanes.iter().enumerate() {
                // Gamma-grouped lanes emit bitness through grouped claims, so the
                // per-instance bitness claim only covers ungrouped lanes.
                if shout_lane_to_gamma.contains_key(&(lut_idx, lane_idx)) {
                    continue;
                }
                bit_cols.extend(lane.addr_bits.iter().cloned());
                bit_cols.push(lane.has_lookup.clone());
            }
            if bit_cols.is_empty() {
                Vec::new()
            } else {
                let weights = bitness_weights(r_cycle, bit_cols.len(), 0x5348_4F55_54u64 + lut_idx as u64);
                let bitness_oracle = LazyWeightedBitnessOracleSparseTime::new_with_cycle(r_cycle, bit_cols, weights);
                vec![Box::new(bitness_oracle)]
            }
        };

        shout_oracles.push(RouteAShoutTimeOracles { lanes, bitness });
    }

    let mut shout_gamma_groups = Vec::with_capacity(shout_gamma_specs.len());
    for (g_idx, g) in shout_gamma_specs.iter().enumerate() {
        let mut value_has_cols: Vec<SparseIdxVec<K>> = Vec::with_capacity(g.lanes.len());
        let mut value_val_cols: Vec<SparseIdxVec<K>> = Vec::with_capacity(g.lanes.len());
        let weights = bitness_weights(r_cycle, g.lanes.len(), 0x5348_5F47_414D_4Du64 ^ g.key);
        let mut weighted_table: Vec<K> = Vec::with_capacity(g.lanes.len());
        let mut group_r_addr: Option<Vec<K>> = None;
        let mut value_claim = K::ZERO;
        let mut adapter_claim = K::ZERO;
        let mut shared_addr_cols: Option<Vec<SparseIdxVec<K>>> = None;
        let mut shared_selector_group: Option<Option<u64>> = None;
        let mut shared_has_col: Option<SparseIdxVec<K>> = None;
        let mut all_has_cols_equal = true;

        for (slot, lane_ref) in g.lanes.iter().enumerate() {
            let (lut_inst, _lut_wit) = step
                .lut_instances
                .get(lane_ref.inst_idx)
                .ok_or_else(|| PiCcsError::ProtocolError("shout gamma group inst idx drift".into()))?;
            let decoded = shout_pre
                .decoded
                .get(lane_ref.inst_idx)
                .ok_or_else(|| PiCcsError::ProtocolError("shout gamma decoded inst idx drift".into()))?;
            let lane = decoded
                .lanes
                .get(lane_ref.lane_idx)
                .ok_or_else(|| PiCcsError::ProtocolError("shout gamma decoded lane idx drift".into()))?;
            let lane_oracles = shout_oracles
                .get(lane_ref.inst_idx)
                .and_then(|o| o.lanes.get(lane_ref.lane_idx))
                .ok_or_else(|| PiCcsError::ProtocolError("shout gamma lane oracle idx drift".into()))?;
            if lane_oracles.gamma_group != Some(g_idx) {
                return Err(PiCcsError::ProtocolError(
                    "shout gamma grouping mismatch between plan and oracle wiring".into(),
                ));
            }
            let ell_addr = lut_inst.d * lut_inst.ell;
            if ell_addr != g.ell_addr {
                return Err(PiCcsError::ProtocolError("shout gamma group ell_addr mismatch".into()));
            }
            match shared_selector_group {
                None => {
                    shared_selector_group = Some(lut_inst.selector_group);
                }
                Some(prev) => {
                    if prev != lut_inst.selector_group {
                        shared_selector_group = Some(None);
                        all_has_cols_equal = false;
                    }
                }
            }
            let ell_addr_u32 = u32::try_from(ell_addr)
                .map_err(|_| PiCcsError::InvalidInput("shout gamma ell_addr overflows u32".into()))?;
            let r_addr = *r_addr_by_ell
                .get(&ell_addr_u32)
                .ok_or_else(|| PiCcsError::ProtocolError("missing shout gamma group r_addr".into()))?;
            if let Some(prev) = group_r_addr.as_ref() {
                if prev.as_slice() != r_addr {
                    return Err(PiCcsError::ProtocolError(
                        "shout gamma group r_addr mismatch across lanes".into(),
                    ));
                }
            } else {
                group_r_addr = Some(r_addr.to_vec());
            }
            if let Some(prev_addr_cols) = shared_addr_cols.as_ref() {
                if prev_addr_cols.len() != lane.addr_bits.len() {
                    return Err(PiCcsError::ProtocolError(
                        "shout gamma group addr_bits width mismatch across lanes".into(),
                    ));
                }
                for (bit_idx, (prev, cur)) in prev_addr_cols.iter().zip(lane.addr_bits.iter()).enumerate() {
                    if prev.len() != cur.len() || prev.entries() != cur.entries() {
                        return Err(PiCcsError::ProtocolError(format!(
                            "shout gamma group addr_bits mismatch across lanes at bit_idx={bit_idx}"
                        )));
                    }
                }
            } else {
                shared_addr_cols = Some(lane.addr_bits.clone());
            }
            if let Some(prev_has) = shared_has_col.as_ref() {
                if prev_has.len() != lane.has_lookup.len() || prev_has.entries() != lane.has_lookup.entries() {
                    all_has_cols_equal = false;
                }
            } else {
                shared_has_col = Some(lane.has_lookup.clone());
            }

            let table_eval_at_r_addr = match &lut_inst.table_spec {
                Some(spec) => spec.eval_table_mle(r_addr)?,
                None => {
                    let pow2 = 1usize
                        .checked_shl(r_addr.len() as u32)
                        .ok_or_else(|| PiCcsError::InvalidInput("shout gamma 2^ell overflow".into()))?;
                    if lut_inst.table.len() < pow2 {
                        return Err(PiCcsError::InvalidInput(format!(
                            "shout gamma table too short: len={} < 2^ell={pow2}",
                            lut_inst.table.len()
                        )));
                    }
                    let mut acc = K::ZERO;
                    for (i, &v) in lut_inst.table.iter().enumerate().take(pow2) {
                        let w = neo_memory::mle::chi_at_index(r_addr, i);
                        acc += K::from(v) * w;
                    }
                    acc
                }
            };

            let w = weights[slot];
            value_claim += w * lane_oracles.value_claim;
            adapter_claim += w * table_eval_at_r_addr * lane_oracles.adapter_claim;
            weighted_table.push(w * table_eval_at_r_addr);

            value_has_cols.push(lane.has_lookup.clone());
            value_val_cols.push(lane.val.clone());
        }

        let selector_group = shared_selector_group.flatten();
        if selector_group.is_some() && !all_has_cols_equal {
            return Err(PiCcsError::ProtocolError(
                "shout gamma group selector-sharing mismatch across lanes".into(),
            ));
        }
        let has_shared = selector_group.is_some() && all_has_cols_equal;
        let shared_has_col =
            shared_has_col.ok_or_else(|| PiCcsError::ProtocolError("empty shout gamma group".into()))?;
        let shared_addr_cols =
            shared_addr_cols.ok_or_else(|| PiCcsError::ProtocolError("empty shout gamma group".into()))?;

        let value_oracle: Box<dyn RoundOracle + Send> = if has_shared {
            Box::new(ShoutGammaValueSharedOracleSparseTime::new(
                shared_has_col.clone(),
                value_val_cols.clone(),
                weights.clone(),
                r_cycle,
            ))
        } else {
            Box::new(ShoutGammaValueOracleSparseTime::new(
                value_has_cols.clone(),
                value_val_cols.clone(),
                weights.clone(),
                r_cycle,
            ))
        };

        let adapter_coeffs = weighted_table;
        let adapter_r_addr = group_r_addr.ok_or_else(|| PiCcsError::ProtocolError("empty shout gamma group".into()))?;
        let ell_addr = g.ell_addr;
        let adapter_eq_alpha: Vec<K> = adapter_r_addr.iter().map(|&u| u + u - K::ONE).collect();
        let adapter_eq_beta: Vec<K> = adapter_r_addr.iter().map(|&u| K::ONE - u).collect();
        let adapter_oracle: Box<dyn RoundOracle + Send> = if has_shared {
            let coeff_sum = adapter_coeffs
                .iter()
                .copied()
                .fold(K::ZERO, |acc, c| acc + c);
            Box::new(ShoutGammaAdapterSharedOracleSparseTime::new(
                shared_has_col.clone(),
                shared_addr_cols.clone(),
                coeff_sum,
                adapter_eq_alpha.clone(),
                adapter_eq_beta.clone(),
                r_cycle,
            ))
        } else {
            Box::new(ShoutGammaAdapterOracleSparseTime::new(
                shared_addr_cols.clone(),
                value_has_cols.clone(),
                adapter_coeffs.clone(),
                adapter_eq_alpha.clone(),
                adapter_eq_beta.clone(),
                r_cycle,
            ))
        };
        let mut bitness_cols: Vec<SparseIdxVec<K>> = Vec::with_capacity(ell_addr + value_has_cols.len());
        let mut bitness_weights_expanded: Vec<K> = Vec::with_capacity(ell_addr + value_has_cols.len());
        let addr_weight_sum = weights.iter().copied().fold(K::ZERO, |acc, w| acc + w);
        for bit_col in shared_addr_cols.iter() {
            bitness_cols.push(bit_col.clone());
            bitness_weights_expanded.push(addr_weight_sum);
        }
        if has_shared {
            bitness_cols.push(shared_has_col.clone());
            bitness_weights_expanded.push(addr_weight_sum);
        } else {
            for (lane_weight, has_col) in weights.iter().copied().zip(value_has_cols.iter()) {
                bitness_cols.push(has_col.clone());
                bitness_weights_expanded.push(lane_weight);
            }
        }
        let bitness_oracle =
            LazyWeightedBitnessOracleSparseTime::new_with_cycle(r_cycle, bitness_cols, bitness_weights_expanded);

        shout_gamma_groups.push(RouteAShoutGammaGroupOracles {
            value: value_oracle,
            value_claim,
            adapter: adapter_oracle,
            adapter_claim,
            bitness: Box::new(bitness_oracle),
        });
    }

    let mut twist_oracles = Vec::with_capacity(step.mem_instances.len());
    for (mem_idx, ((mem_inst, _mem_wit), pre)) in step.mem_instances.iter().zip(twist_pre.iter()).enumerate() {
        let init_at_r_addr = eval_init_at_r_addr(&mem_inst.init, mem_inst.k, &pre.addr_pre.r_addr)?;
        let ell_addr = mem_inst.d * mem_inst.ell;
        if pre.addr_pre.r_addr.len() != ell_addr {
            return Err(PiCcsError::InvalidInput(format!(
                "Twist(Route A): r_addr.len()={} != ell_addr={}",
                pre.addr_pre.r_addr.len(),
                ell_addr
            )));
        }

        if pre.decoded.lanes.is_empty() {
            return Err(PiCcsError::InvalidInput(format!(
                "Twist(Route A): decoded lanes empty at mem_idx={mem_idx}"
            )));
        }

        let inc_terms_at_r_addr = std::sync::Arc::new(build_twist_inc_terms_at_r_addr(
            &pre.decoded.lanes,
            &pre.addr_pre.r_addr,
        ));

        let mut read_oracles: Vec<Box<dyn RoundOracle + Send>> = Vec::with_capacity(pre.decoded.lanes.len());
        let mut write_oracles: Vec<Box<dyn RoundOracle + Send>> = Vec::with_capacity(pre.decoded.lanes.len());
        for lane in pre.decoded.lanes.iter() {
            read_oracles.push(Box::new(TwistReadCheckOracleSparseTime::new_with_inc_terms_shared(
                r_cycle,
                lane.has_read.clone(),
                lane.rv.clone(),
                lane.ra_bits.clone(),
                &pre.addr_pre.r_addr,
                init_at_r_addr,
                inc_terms_at_r_addr.clone(),
            )));
            write_oracles.push(Box::new(TwistWriteCheckOracleSparseTime::new_with_inc_terms_shared(
                r_cycle,
                lane.has_write.clone(),
                lane.wv.clone(),
                lane.inc_at_write_addr.clone(),
                lane.wa_bits.clone(),
                &pre.addr_pre.r_addr,
                init_at_r_addr,
                inc_terms_at_r_addr.clone(),
            )));
        }
        let read_check: Box<dyn RoundOracle + Send> = Box::new(SumRoundOracle::new(read_oracles)?);
        let write_check: Box<dyn RoundOracle + Send> = Box::new(SumRoundOracle::new(write_oracles)?);

        let lane_count = pre.decoded.lanes.len();
        let mut bit_cols: Vec<SparseIdxVec<K>> = Vec::with_capacity(lane_count * (2 * ell_addr + 2));
        for lane in pre.decoded.lanes.iter() {
            bit_cols.extend(lane.ra_bits.iter().cloned());
            bit_cols.extend(lane.wa_bits.iter().cloned());
            bit_cols.push(lane.has_read.clone());
            bit_cols.push(lane.has_write.clone());
        }
        let weights = bitness_weights(r_cycle, bit_cols.len(), 0x5457_4953_54u64 + mem_idx as u64);
        let bitness_oracle = LazyWeightedBitnessOracleSparseTime::new_with_cycle(r_cycle, bit_cols, weights);
        let bitness: Vec<Box<dyn RoundOracle + Send>> = vec![Box::new(bitness_oracle)];
        let (virtual_write_domain, nonvirtual_arch_domain) = if mem_inst.mem_id == neo_memory::riscv::lookups::REG_ID.0
        {
            if let Some(is_virtual) = trace_is_virtual_sparse.as_ref() {
                let mut vd_oracles: Vec<Box<dyn RoundOracle + Send>> = Vec::with_capacity(pre.decoded.lanes.len());
                let mut nvd_oracles: Vec<Box<dyn RoundOracle + Send>> = Vec::with_capacity(pre.decoded.lanes.len() * 2);
                for lane in pre.decoded.lanes.iter() {
                    let wa_bit5 = lane
                        .wa_bits
                        .get(5)
                        .cloned()
                        .unwrap_or_else(|| SparseIdxVec::new(lane.has_write.len()));
                    let ra_bit5 = lane
                        .ra_bits
                        .get(5)
                        .cloned()
                        .unwrap_or_else(|| SparseIdxVec::new(lane.has_read.len()));
                    vd_oracles.push(Box::new(Rv32VirtualWriteDomainOracleSparseTime::new(
                        r_cycle,
                        is_virtual.clone(),
                        lane.has_write.clone(),
                        wa_bit5.clone(),
                    )));
                    nvd_oracles.push(Box::new(Rv32NonVirtualArchDomainOracleSparseTime::new(
                        r_cycle,
                        lane.has_read.clone(),
                        is_virtual.clone(),
                        ra_bit5,
                    )));
                    nvd_oracles.push(Box::new(Rv32NonVirtualArchDomainOracleSparseTime::new(
                        r_cycle,
                        lane.has_write.clone(),
                        is_virtual.clone(),
                        wa_bit5,
                    )));
                }
                let vd_sum = SumRoundOracle::new(vd_oracles)?;
                let nvd_sum = SumRoundOracle::new(nvd_oracles)?;
                (
                    Some(Box::new(vd_sum) as Box<dyn RoundOracle + Send>),
                    Some(Box::new(nvd_sum) as Box<dyn RoundOracle + Send>),
                )
            } else {
                (None, None)
            }
        } else {
            (None, None)
        };

        twist_oracles.push(RouteATwistTimeOracles {
            read_check,
            write_check,
            bitness,
            virtual_write_domain,
            nonvirtual_arch_domain,
        });
    }

    Ok(RouteAMemoryOracles {
        shout: shout_oracles,
        shout_gamma_groups,
        twist: twist_oracles,
    })
}

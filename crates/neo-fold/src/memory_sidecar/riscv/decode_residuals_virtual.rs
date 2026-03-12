use super::*;

#[inline]
pub(super) fn push_virtual_decode_residuals<S: DecodeResidualSink>(
    inputs: &DecodeVirtualResidualInputs,
    residuals: &mut S,
) {
    let DecodeVirtualResidualInputs {
        base,
        op_alu_reg,
        op_alu_reg_wide,
        op_alu_reg_base_only,
        add_table_id,
        add_sub_combined_key_mode,
        mul_combined_key_mode,
        add_key_delta,
        add_key_delta_lo,
        add_key_delta_hi,
        sub_key_delta,
        sub_key_delta_lo,
        sub_key_delta_hi,
        mul_key_delta,
        two_pow_32,
    } = *inputs;
    let DecodeAluBranchResidualInputs {
        rv64_exact_words,
        is_virtual,
        virtual_sequence_remaining,
        trace_rs1_addr,
        trace_rs2_addr,
        trace_rd_addr,
        decode_rs1_addr,
        decode_rs2_addr,
        rs1_val,
        rs2_val,
        trace_rd_has_write,
        rd_val,
        shout_has_lookup,
        shout_table_id,
        shout_val,
        shout_lhs,
        shout_rhs,
        funct3_is,
        funct7_bits,
        ..
    } = base;

    let is_rv32m = op_alu_reg * funct7_bits[0];
    let op_mul = is_rv32m * funct3_is[0];
    let op_mulh = is_rv32m * funct3_is[1];
    let op_mulhsu = is_rv32m * funct3_is[2];
    let op_mulhu = is_rv32m * funct3_is[3];
    let op_div = is_rv32m * funct3_is[4];
    let op_divu = is_rv32m * funct3_is[5];
    let op_rem = is_rv32m * funct3_is[6];
    let op_remu = is_rv32m * funct3_is[7];
    let op_virtual_decomp = op_mul + op_mulh + op_mulhu + op_mulhsu + op_div + op_divu + op_rem + op_remu;
    let rem = virtual_sequence_remaining;
    let k_consts = decode_virtual_constants_k();
    let v0 = k_consts.v0;
    let v1 = k_consts.v1;
    let v2 = k_consts.v2;
    let movsign_rhs_word = k_consts.movsign_rhs_word;
    let movsign_rhs_exact = if rv64_exact_words {
        k_consts.movsign_rhs_exact
    } else {
        k_consts.movsign_rhs_word
    };
    let sra_table_id = k_consts.sra_table_id;
    let mul_table_id = k_consts.mul_table_id;
    let mulh_table_id = k_consts.mulh_table_id;
    let mulhu_table_id = k_consts.mulhu_table_id;
    let vdivw_table_id = k_consts.vdivw_table_id;
    let vdivuw_table_id = k_consts.vdivuw_table_id;
    let vremw_table_id = k_consts.vremw_table_id;
    let vremuw_table_id = k_consts.vremuw_table_id;
    let vmovsignw_table_id = k_consts.vmovsignw_table_id;
    let vmulw_table_id = k_consts.vmulw_table_id;
    let xor_table_id = k_consts.xor_table_id;
    let sub_table_id = k_consts.sub_table_id;
    let sltu_table_id = k_consts.sltu_table_id;
    let eq_table_id = k_consts.eq_table_id;
    let div_table_id = k_consts.div_table_id;
    let divu_table_id = k_consts.divu_table_id;
    let word_all_ones = if rv64_exact_words {
        k_consts.rv64_all_ones
    } else {
        k_u64(u32::MAX as u64)
    };

    let virtual_mulh = is_virtual * op_mulh;
    let virtual_mulhsu = is_virtual * op_mulhsu;
    let virtual_mulw = is_virtual * op_mul * op_alu_reg_wide;
    let virtual_divw = is_virtual * op_div * op_alu_reg_wide;
    let virtual_divuw = is_virtual * op_divu * op_alu_reg_wide;
    let virtual_remw = is_virtual * op_rem * op_alu_reg_wide;
    let virtual_remuw = is_virtual * op_remu * op_alu_reg_wide;
    let virtual_div = is_virtual * op_div * op_alu_reg_base_only;
    let virtual_divu = is_virtual * op_divu * op_alu_reg_base_only;
    let virtual_rem = is_virtual * op_rem * op_alu_reg_base_only;
    let virtual_remu = is_virtual * op_remu * op_alu_reg_base_only;
    residuals.push(is_virtual * (K::ONE - op_virtual_decomp));

    let mut stage_gate_2 = [K::ZERO; DECODE_STAGE_GATE_TABLE_CAP];
    let mut stage_gate_3 = [K::ZERO; DECODE_STAGE_GATE_TABLE_CAP];
    let mut stage_gate_7 = [K::ZERO; DECODE_STAGE_GATE_TABLE_CAP];
    let mut stage_gate_8 = [K::ZERO; DECODE_STAGE_GATE_TABLE_CAP];
    let mut stage_gate_11 = [K::ZERO; DECODE_STAGE_GATE_TABLE_CAP];
    let mut stage_gate_18 = [K::ZERO; DECODE_STAGE_GATE_TABLE_CAP];
    let mut stage_gate_19 = [K::ZERO; DECODE_STAGE_GATE_TABLE_CAP];
    let _ = decode_build_stage_gate_table(rem, 2, &mut stage_gate_2);
    let rem_poly_3 = decode_build_stage_gate_table(rem, 3, &mut stage_gate_3);
    let rem_poly_7 = decode_build_stage_gate_table(rem, 7, &mut stage_gate_7);
    let rem_poly_8 = decode_build_stage_gate_table(rem, 8, &mut stage_gate_8);
    let rem_poly_11 = decode_build_stage_gate_table(rem, 11, &mut stage_gate_11);
    let rem_poly_18 = decode_build_stage_gate_table(rem, 18, &mut stage_gate_18);
    let rem_poly_19 = decode_build_stage_gate_table(rem, 19, &mut stage_gate_19);

    residuals.push(virtual_mulw * rem_poly_3);
    residuals.push(virtual_divw * rem_poly_3);
    residuals.push(virtual_divuw * rem_poly_3);
    residuals.push(virtual_remw * rem_poly_3);
    residuals.push(virtual_remuw * rem_poly_3);
    residuals.push(virtual_mulh * rem_poly_7);
    residuals.push(virtual_mulhsu * rem_poly_11);

    let add_stage_key = if rv64_exact_words {
        add_sub_combined_key_mode
            * (add_key_delta_lo * (add_key_delta_lo - two_pow_32) + add_key_delta_hi * (add_key_delta_hi - two_pow_32))
    } else {
        add_sub_combined_key_mode * add_key_delta * (add_key_delta - two_pow_32)
    };
    let sub_stage_key = if rv64_exact_words {
        add_sub_combined_key_mode
            * (sub_key_delta_lo * (sub_key_delta_lo + two_pow_32) + sub_key_delta_hi * (sub_key_delta_hi + two_pow_32))
    } else {
        add_sub_combined_key_mode * sub_key_delta * (sub_key_delta + two_pow_32)
    };
    let mul_stage_key = mul_combined_key_mode * mul_key_delta;

    let mulw_rows = [
        VirtualStageRow {
            remaining: 3,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v0,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - vmulw_table_id,
            lhs: shout_lhs - base.rs1_word,
            rhs: shout_rhs - base.rs2_word,
            rd_val: rd_val - shout_val,
            extra: Some(mul_stage_key),
        },
        VirtualStageRow {
            remaining: 2,
            rs1: trace_rs1_addr - v0,
            rs2: trace_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v1,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - vmovsignw_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - movsign_rhs_word,
            rd_val: rd_val - shout_val,
            extra: None,
        },
        VirtualStageRow {
            remaining: 1,
            rs1: trace_rs1_addr - v0,
            rs2: trace_rs2_addr - v1,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v0,
            has_lookup: shout_has_lookup,
            table_id: K::ZERO,
            lhs: K::ZERO,
            rhs: K::ZERO,
            rd_val: rd_val - rs1_val - two_pow_32 * rs2_val,
            extra: None,
        },
    ];
    for row in mulw_rows {
        let gate = virtual_mulw * stage_gate_3[row.remaining as usize];
        push_virtual_stage_row(residuals, gate, row);
    }

    let three_stage_rows = [
        (virtual_divw, vdivw_table_id),
        (virtual_divuw, vdivuw_table_id),
        (virtual_remw, vremw_table_id),
        (virtual_remuw, vremuw_table_id),
    ];
    for (gate_selector, table_id) in three_stage_rows {
        let rows = [
            VirtualStageRow {
                remaining: 3,
                rs1: trace_rs1_addr - decode_rs1_addr,
                rs2: trace_rs2_addr - decode_rs2_addr,
                rd_has_write: trace_rd_has_write - K::ONE,
                rd_addr: trace_rd_addr - v0,
                has_lookup: shout_has_lookup - K::ONE,
                table_id: shout_table_id - table_id,
                lhs: shout_lhs - base.rs1_word,
                rhs: shout_rhs - base.rs2_word,
                rd_val: rd_val - shout_val,
                extra: None,
            },
            VirtualStageRow {
                remaining: 2,
                rs1: trace_rs1_addr - v0,
                rs2: trace_rs2_addr,
                rd_has_write: trace_rd_has_write - K::ONE,
                rd_addr: trace_rd_addr - v1,
                has_lookup: shout_has_lookup - K::ONE,
                table_id: shout_table_id - vmovsignw_table_id,
                lhs: shout_lhs - rs1_val,
                rhs: shout_rhs - movsign_rhs_word,
                rd_val: rd_val - shout_val,
                extra: None,
            },
            VirtualStageRow {
                remaining: 1,
                rs1: trace_rs1_addr - v0,
                rs2: trace_rs2_addr - v1,
                rd_has_write: trace_rd_has_write - K::ONE,
                rd_addr: trace_rd_addr - v0,
                has_lookup: shout_has_lookup,
                table_id: K::ZERO,
                lhs: K::ZERO,
                rhs: K::ZERO,
                rd_val: rd_val - rs1_val - two_pow_32 * rs2_val,
                extra: None,
            },
        ];
        for row in rows {
            let gate = gate_selector * stage_gate_3[row.remaining as usize];
            push_virtual_stage_row(residuals, gate, row);
        }
    }

    let mulh_rows = [
        VirtualStageRow {
            remaining: 7,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v0,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - sra_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - movsign_rhs_exact,
            rd_val: rd_val - shout_val,
            extra: None,
        },
        VirtualStageRow {
            remaining: 6,
            rs1: trace_rs1_addr - decode_rs2_addr,
            rs2: trace_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v1,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - sra_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - movsign_rhs_exact,
            rd_val: rd_val - shout_val,
            extra: None,
        },
        VirtualStageRow {
            remaining: 5,
            rs1: trace_rs1_addr - v0,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v0,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - mul_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: Some(mul_stage_key),
        },
        VirtualStageRow {
            remaining: 4,
            rs1: trace_rs1_addr - v1,
            rs2: trace_rs2_addr - decode_rs1_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v1,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - mul_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: Some(mul_stage_key),
        },
        VirtualStageRow {
            remaining: 3,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v2,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - mulhu_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: Some(mul_stage_key),
        },
        VirtualStageRow {
            remaining: 2,
            rs1: trace_rs1_addr - v2,
            rs2: trace_rs2_addr - v0,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v2,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - add_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: Some(add_stage_key),
        },
        VirtualStageRow {
            remaining: 1,
            rs1: trace_rs1_addr - v2,
            rs2: trace_rs2_addr - v1,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v2,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - add_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: Some(add_stage_key),
        },
    ];
    for row in mulh_rows {
        let gate = virtual_mulh * stage_gate_7[row.remaining as usize];
        push_virtual_stage_row(residuals, gate, row);
    }

    let v3_mulhsu = K::from(F::from_u64(35));
    let mulhsu_rows = [
        VirtualStageRow {
            remaining: 11,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v0,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - sra_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - movsign_rhs_exact,
            rd_val: rd_val - shout_val,
            extra: None,
        },
        VirtualStageRow {
            remaining: 10,
            rs1: trace_rs1_addr,
            rs2: trace_rs2_addr - v0,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v1,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - sub_table_id,
            lhs: shout_lhs,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: Some(sub_stage_key),
        },
        VirtualStageRow {
            remaining: 9,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr - v0,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v2,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - xor_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: None,
        },
        VirtualStageRow {
            remaining: 8,
            rs1: trace_rs1_addr - v2,
            rs2: trace_rs2_addr - v1,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v2,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - add_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: Some(add_stage_key),
        },
        VirtualStageRow {
            remaining: 7,
            rs1: trace_rs1_addr - v2,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v3_mulhsu,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - mulhu_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: Some(mul_stage_key),
        },
        VirtualStageRow {
            remaining: 6,
            rs1: trace_rs1_addr - v2,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v2,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - mul_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: Some(mul_stage_key),
        },
        VirtualStageRow {
            remaining: 5,
            rs1: trace_rs1_addr - v3_mulhsu,
            rs2: trace_rs2_addr - v0,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v3_mulhsu,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - xor_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: None,
        },
        VirtualStageRow {
            remaining: 4,
            rs1: trace_rs1_addr - v2,
            rs2: trace_rs2_addr - v0,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v2,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - xor_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: None,
        },
        VirtualStageRow {
            remaining: 3,
            rs1: trace_rs1_addr - v2,
            rs2: trace_rs2_addr - v1,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v0,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - add_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: Some(add_stage_key),
        },
        VirtualStageRow {
            remaining: 2,
            rs1: trace_rs1_addr - v0,
            rs2: trace_rs2_addr - v2,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v0,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - sltu_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: None,
        },
        VirtualStageRow {
            remaining: 1,
            rs1: trace_rs1_addr - v3_mulhsu,
            rs2: trace_rs2_addr - v0,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v3_mulhsu,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - add_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: Some(add_stage_key),
        },
    ];
    for row in mulhsu_rows {
        let gate = virtual_mulhsu * stage_gate_11[row.remaining as usize];
        push_virtual_stage_row(residuals, gate, row);
    }

    let v3 = K::from(F::from_u64(35));
    let v4 = K::from(F::from_u64(36));
    let v5 = K::from(F::from_u64(37));
    let v6 = K::from(F::from_u64(38));
    let v7 = K::from(F::from_u64(39));

    residuals.push(virtual_div * rem_poly_18);
    residuals.push(virtual_divu * rem_poly_8);
    residuals.push(virtual_rem * rem_poly_19);
    residuals.push(virtual_remu * rem_poly_7);

    let div_rows = [
        VirtualStageSparseRow {
            remaining: 18,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v0),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - div_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 17,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v1),
            has_lookup: shout_has_lookup,
            table_id: None,
            lhs: None,
            rhs: None,
            rd_val: None,
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 16,
            rs1: trace_rs1_addr - decode_rs2_addr,
            rs2: trace_rs2_addr - v0,
            rd_has_write: trace_rd_has_write,
            rd_addr: None,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - eq_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs),
            rd_val: Some(shout_val * (rs2_val - word_all_ones)),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 15,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v2),
            has_lookup: shout_has_lookup,
            table_id: None,
            lhs: None,
            rhs: None,
            rd_val: Some((rd_val - rs2_val) * (rs2_val - word_all_ones)),
            extra: Some((rd_val - rs2_val) * (rd_val - K::ONE)),
        },
        VirtualStageSparseRow {
            remaining: 14,
            rs1: trace_rs1_addr - v0,
            rs2: trace_rs2_addr - v2,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v3),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - mulh_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 13,
            rs1: trace_rs1_addr - v0,
            rs2: trace_rs2_addr - v2,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v4),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - mul_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: Some(mul_combined_key_mode * mul_key_delta),
        },
        VirtualStageSparseRow {
            remaining: 12,
            rs1: trace_rs1_addr - v4,
            rs2: trace_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v5),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - sra_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - movsign_rhs_exact),
            rd_val: Some(rd_val - shout_val),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 11,
            rs1: trace_rs1_addr - v3,
            rs2: trace_rs2_addr - v5,
            rd_has_write: trace_rd_has_write,
            rd_addr: None,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - eq_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(shout_val - K::ONE),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 10,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v5),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - sra_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - movsign_rhs_exact),
            rd_val: Some(rd_val - shout_val),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 9,
            rs1: trace_rs1_addr - v1,
            rs2: trace_rs2_addr - v5,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v6),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - xor_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 8,
            rs1: trace_rs1_addr - v6,
            rs2: trace_rs2_addr - v5,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v6),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - sub_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: Some(sub_stage_key),
        },
        VirtualStageSparseRow {
            remaining: 7,
            rs1: trace_rs1_addr - v4,
            rs2: trace_rs2_addr - v6,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v4),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - add_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: Some(add_stage_key),
        },
        VirtualStageSparseRow {
            remaining: 6,
            rs1: trace_rs1_addr - v4,
            rs2: trace_rs2_addr - decode_rs1_addr,
            rd_has_write: trace_rd_has_write,
            rd_addr: None,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - eq_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(shout_val - K::ONE),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 5,
            rs1: trace_rs1_addr - v2,
            rs2: trace_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v5),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - sra_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - movsign_rhs_exact),
            rd_val: Some(rd_val - shout_val),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 4,
            rs1: trace_rs1_addr - v2,
            rs2: trace_rs2_addr - v5,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v7),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - xor_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 3,
            rs1: trace_rs1_addr - v7,
            rs2: trace_rs2_addr - v5,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v7),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - sub_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: Some(sub_stage_key),
        },
        VirtualStageSparseRow {
            remaining: 2,
            rs1: trace_rs1_addr - v1,
            rs2: trace_rs2_addr - v7,
            rd_has_write: trace_rd_has_write,
            rd_addr: None,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - sltu_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rs2_val * (K::ONE - shout_val)),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 1,
            rs1: trace_rs1_addr - v0,
            rs2: trace_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v0),
            has_lookup: shout_has_lookup,
            table_id: None,
            lhs: None,
            rhs: None,
            rd_val: Some(rd_val - rs1_val),
            extra: None,
        },
    ];
    for row in div_rows {
        let gate = virtual_div * stage_gate_18[row.remaining as usize];
        push_virtual_stage_sparse_row(residuals, gate, row);
    }

    let rem_rows = [
        VirtualStageSparseRow {
            remaining: 19,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v0),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - div_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 18,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v1),
            has_lookup: shout_has_lookup,
            table_id: None,
            lhs: None,
            rhs: None,
            rd_val: None,
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 17,
            rs1: trace_rs1_addr - decode_rs2_addr,
            rs2: trace_rs2_addr - v0,
            rd_has_write: trace_rd_has_write,
            rd_addr: None,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - eq_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs),
            rd_val: Some(shout_val * (rs2_val - word_all_ones)),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 16,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v2),
            has_lookup: shout_has_lookup,
            table_id: None,
            lhs: None,
            rhs: None,
            rd_val: Some((rd_val - rs2_val) * (rs2_val - word_all_ones)),
            extra: Some((rd_val - rs2_val) * (rd_val - K::ONE)),
        },
        VirtualStageSparseRow {
            remaining: 15,
            rs1: trace_rs1_addr - v0,
            rs2: trace_rs2_addr - v2,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v3),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - mulh_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 14,
            rs1: trace_rs1_addr - v0,
            rs2: trace_rs2_addr - v2,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v4),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - mul_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: Some(mul_combined_key_mode * mul_key_delta),
        },
        VirtualStageSparseRow {
            remaining: 13,
            rs1: trace_rs1_addr - v4,
            rs2: trace_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v5),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - sra_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - movsign_rhs_exact),
            rd_val: Some(rd_val - shout_val),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 12,
            rs1: trace_rs1_addr - v3,
            rs2: trace_rs2_addr - v5,
            rd_has_write: trace_rd_has_write,
            rd_addr: None,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - eq_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(shout_val - K::ONE),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 11,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v5),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - sra_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - movsign_rhs_exact),
            rd_val: Some(rd_val - shout_val),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 10,
            rs1: trace_rs1_addr - v1,
            rs2: trace_rs2_addr - v5,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v6),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - xor_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 9,
            rs1: trace_rs1_addr - v6,
            rs2: trace_rs2_addr - v5,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v6),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - sub_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: Some(sub_stage_key),
        },
        VirtualStageSparseRow {
            remaining: 8,
            rs1: trace_rs1_addr - v4,
            rs2: trace_rs2_addr - v6,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v4),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - add_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: Some(add_stage_key),
        },
        VirtualStageSparseRow {
            remaining: 7,
            rs1: trace_rs1_addr - v4,
            rs2: trace_rs2_addr - decode_rs1_addr,
            rd_has_write: trace_rd_has_write,
            rd_addr: None,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - eq_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(shout_val - K::ONE),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 6,
            rs1: trace_rs1_addr - v2,
            rs2: trace_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v5),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - sra_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - movsign_rhs_exact),
            rd_val: Some(rd_val - shout_val),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 5,
            rs1: trace_rs1_addr - v2,
            rs2: trace_rs2_addr - v5,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v7),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - xor_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 4,
            rs1: trace_rs1_addr - v7,
            rs2: trace_rs2_addr - v5,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v7),
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - sub_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rd_val - shout_val),
            extra: Some(sub_stage_key),
        },
        VirtualStageSparseRow {
            remaining: 3,
            rs1: trace_rs1_addr - v1,
            rs2: trace_rs2_addr - v7,
            rd_has_write: trace_rd_has_write,
            rd_addr: None,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: Some(shout_table_id - sltu_table_id),
            lhs: Some(shout_lhs - rs1_val),
            rhs: Some(shout_rhs - rs2_val),
            rd_val: Some(rs2_val * (K::ONE - shout_val)),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 2,
            rs1: trace_rs1_addr - v6,
            rs2: trace_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v6),
            has_lookup: shout_has_lookup,
            table_id: None,
            lhs: None,
            rhs: None,
            rd_val: Some(rd_val - rs1_val),
            extra: None,
        },
        VirtualStageSparseRow {
            remaining: 1,
            rs1: trace_rs1_addr - v6,
            rs2: trace_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: Some(trace_rd_addr - v6),
            has_lookup: shout_has_lookup,
            table_id: None,
            lhs: None,
            rhs: None,
            rd_val: Some(rd_val - rs1_val),
            extra: None,
        },
    ];
    for row in rem_rows {
        let gate = virtual_rem * stage_gate_19[row.remaining as usize];
        push_virtual_stage_sparse_row(residuals, gate, row);
    }

    let divu_rows = [
        VirtualStageRow {
            remaining: 8,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v0,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - divu_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: None,
        },
        VirtualStageRow {
            remaining: 7,
            rs1: trace_rs1_addr - decode_rs2_addr,
            rs2: trace_rs2_addr - v0,
            rd_has_write: trace_rd_has_write,
            rd_addr: K::ZERO,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - eq_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs,
            rd_val: shout_val * (rs2_val - word_all_ones),
            extra: None,
        },
        VirtualStageRow {
            remaining: 6,
            rs1: trace_rs1_addr - v0,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write,
            rd_addr: K::ZERO,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - mulhu_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: shout_val,
            extra: Some(mul_stage_key),
        },
        VirtualStageRow {
            remaining: 5,
            rs1: trace_rs1_addr - v0,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v1,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - mul_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: Some(mul_stage_key),
        },
        VirtualStageRow {
            remaining: 4,
            rs1: trace_rs1_addr - v1,
            rs2: trace_rs2_addr - decode_rs1_addr,
            rd_has_write: trace_rd_has_write,
            rd_addr: K::ZERO,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - sltu_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: (rs2_val - rs1_val) * (K::ONE - shout_val),
            extra: None,
        },
        VirtualStageRow {
            remaining: 3,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr - v1,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v2,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - sub_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: Some(sub_stage_key),
        },
        VirtualStageRow {
            remaining: 2,
            rs1: trace_rs1_addr - v2,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write,
            rd_addr: K::ZERO,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - sltu_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rs2_val * (K::ONE - shout_val),
            extra: None,
        },
        VirtualStageRow {
            remaining: 1,
            rs1: trace_rs1_addr - v0,
            rs2: trace_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v0,
            has_lookup: shout_has_lookup,
            table_id: K::ZERO,
            lhs: K::ZERO,
            rhs: K::ZERO,
            rd_val: rd_val - rs1_val,
            extra: None,
        },
    ];
    for row in divu_rows {
        let gate = virtual_divu * stage_gate_8[row.remaining as usize];
        push_virtual_stage_row(residuals, gate, row);
    }

    let remu_rows = [
        VirtualStageRow {
            remaining: 7,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v0,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - divu_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: None,
        },
        VirtualStageRow {
            remaining: 6,
            rs1: trace_rs1_addr - v0,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write,
            rd_addr: K::ZERO,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - mulhu_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: shout_val,
            extra: Some(mul_stage_key),
        },
        VirtualStageRow {
            remaining: 5,
            rs1: trace_rs1_addr - v0,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v1,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - mul_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: Some(mul_stage_key),
        },
        VirtualStageRow {
            remaining: 4,
            rs1: trace_rs1_addr - v1,
            rs2: trace_rs2_addr - decode_rs1_addr,
            rd_has_write: trace_rd_has_write,
            rd_addr: K::ZERO,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - sltu_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: (rs2_val - rs1_val) * (K::ONE - shout_val),
            extra: None,
        },
        VirtualStageRow {
            remaining: 3,
            rs1: trace_rs1_addr - decode_rs1_addr,
            rs2: trace_rs2_addr - v1,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v2,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - sub_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rd_val - shout_val,
            extra: Some(sub_stage_key),
        },
        VirtualStageRow {
            remaining: 2,
            rs1: trace_rs1_addr - v2,
            rs2: trace_rs2_addr - decode_rs2_addr,
            rd_has_write: trace_rd_has_write,
            rd_addr: K::ZERO,
            has_lookup: shout_has_lookup - K::ONE,
            table_id: shout_table_id - sltu_table_id,
            lhs: shout_lhs - rs1_val,
            rhs: shout_rhs - rs2_val,
            rd_val: rs2_val * (K::ONE - shout_val),
            extra: None,
        },
        VirtualStageRow {
            remaining: 1,
            rs1: trace_rs1_addr - v2,
            rs2: trace_rs2_addr,
            rd_has_write: trace_rd_has_write - K::ONE,
            rd_addr: trace_rd_addr - v2,
            has_lookup: shout_has_lookup,
            table_id: K::ZERO,
            lhs: K::ZERO,
            rhs: K::ZERO,
            rd_val: rd_val - rs1_val,
            extra: None,
        },
    ];
    for row in remu_rows {
        let gate = virtual_remu * stage_gate_7[row.remaining as usize];
        push_virtual_stage_row(residuals, gate, row);
    }
}

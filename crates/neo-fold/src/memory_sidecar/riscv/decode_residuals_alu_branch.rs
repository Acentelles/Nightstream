use super::*;

#[inline]
#[cfg(debug_assertions)]
pub(crate) fn decode_alu_branch_lookup_residuals(
    rv64_exact_words: bool,
    active: K,
    is_virtual: K,
    virtual_sequence_remaining: K,
    virtual_commit_from_prev: K,
    halted: K,
    shout_has_lookup: K,
    shout_lhs: K,
    shout_rhs: K,
    shout_add_sub_key: K,
    shout_table_id: K,
    decode_opcode: K,
    trace_rs1_addr: K,
    trace_rs2_addr: K,
    trace_rd_addr: K,
    decode_rs1_addr: K,
    decode_rs2_addr: K,
    decode_rd_addr: K,
    rs1_val: K,
    rs2_val: K,
    rs1_word: K,
    rs2_word: K,
    shout_lhs_word: K,
    shout_lhs_hi: K,
    shout_rhs_word: K,
    shout_rhs_hi: K,
    shout_add_sub_key_word: K,
    shout_add_sub_key_hi: K,
    trace_rd_has_write: K,
    decode_rd_has_write: K,
    rd_is_zero: K,
    rd_val: K,
    ram_has_read: K,
    ram_has_write: K,
    ram_addr: K,
    shout_val: K,
    funct3_bits: [K; 3],
    funct7_bits: [K; 7],
    opcode_flags: [K; 12],
    op_write_flags: [K; 6],
    funct3_is: [K; 8],
    alu_reg_table_delta: K,
    alu_imm_table_delta: K,
    alu_imm_shift_rhs_delta: K,
    rs2_decode_addr: K,
    imm_i: K,
    imm_s: K,
) -> Vec<K> {
    let inputs = DecodeAluBranchResidualInputs {
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
        rs2_decode_addr,
        imm_i,
        imm_s,
    };
    let mut residuals = Vec::with_capacity(DECODE_ALU_BRANCH_RESIDUAL_COUNT);
    decode_alu_branch_lookup_residuals_sink(&inputs, &mut residuals);
    residuals
}

#[inline]
pub(crate) fn decode_alu_branch_lookup_residuals_into(
    rv64_exact_words: bool,
    active: K,
    is_virtual: K,
    virtual_sequence_remaining: K,
    virtual_commit_from_prev: K,
    halted: K,
    shout_has_lookup: K,
    shout_lhs: K,
    shout_rhs: K,
    shout_add_sub_key: K,
    shout_table_id: K,
    decode_opcode: K,
    trace_rs1_addr: K,
    trace_rs2_addr: K,
    trace_rd_addr: K,
    decode_rs1_addr: K,
    decode_rs2_addr: K,
    decode_rd_addr: K,
    rs1_val: K,
    rs2_val: K,
    rs1_word: K,
    rs2_word: K,
    shout_lhs_word: K,
    shout_lhs_hi: K,
    shout_rhs_word: K,
    shout_rhs_hi: K,
    shout_add_sub_key_word: K,
    shout_add_sub_key_hi: K,
    trace_rd_has_write: K,
    decode_rd_has_write: K,
    rd_is_zero: K,
    rd_val: K,
    ram_has_read: K,
    ram_has_write: K,
    ram_addr: K,
    shout_val: K,
    funct3_bits: [K; 3],
    funct7_bits: [K; 7],
    opcode_flags: [K; 12],
    op_write_flags: [K; 6],
    funct3_is: [K; 8],
    alu_reg_table_delta: K,
    alu_imm_table_delta: K,
    alu_imm_shift_rhs_delta: K,
    rs2_decode_addr: K,
    imm_i: K,
    imm_s: K,
    residuals: &mut Vec<K>,
) {
    residuals.clear();
    if residuals.capacity() < DECODE_ALU_BRANCH_RESIDUAL_COUNT {
        residuals.reserve(DECODE_ALU_BRANCH_RESIDUAL_COUNT - residuals.capacity());
    }
    let inputs = DecodeAluBranchResidualInputs {
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
        rs2_decode_addr,
        imm_i,
        imm_s,
    };
    decode_alu_branch_lookup_residuals_sink(&inputs, residuals);
}

#[inline]
pub(super) fn decode_alu_branch_lookup_residuals_sink<S: DecodeResidualSink>(
    inputs: &DecodeAluBranchResidualInputs,
    residuals: &mut S,
) {
    let DecodeAluBranchResidualInputs {
        rv64_exact_words,
        active,
        is_virtual,
        virtual_sequence_remaining: _,
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
        rs1_word: _,
        rs2_word: _,
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
        rs2_decode_addr,
        imm_i,
        imm_s,
    } = *inputs;

    let op_lui = opcode_flags[0];
    let op_auipc = opcode_flags[1];
    let op_jal = opcode_flags[2];
    let op_jalr = opcode_flags[3];
    let op_branch = opcode_flags[4];
    let op_load = opcode_flags[5];
    let op_store = opcode_flags[6];
    let op_alu_imm = opcode_flags[7];
    let op_alu_reg = opcode_flags[8];
    let op_misc_mem = opcode_flags[9];
    let op_system = opcode_flags[10];

    let op_lui_write = op_write_flags[0];
    let op_auipc_write = op_write_flags[1];
    let op_jal_write = op_write_flags[2];
    let op_jalr_write = op_write_flags[3];
    let op_alu_imm_write = op_write_flags[4];
    let op_alu_reg_write = op_write_flags[5];

    let non_mem_ops =
        op_lui + op_auipc + op_jal + op_jalr + op_branch + op_alu_imm + op_alu_reg + op_misc_mem + op_system;
    let mem_lookup_ops = op_load + op_store;
    let add_lookup_ops = op_load + op_store + op_jalr;
    let k_consts = decode_virtual_constants_k();
    let add_table_id = k_consts.add_table_id;
    let addw_table_id = k_consts.addw_table_id;
    let opcode_alu_imm_base = K::from(F::from_u64(0x13));
    let opcode_alu_reg_base = K::from(F::from_u64(0x33));
    let inv8 = K::from_u64(8).inverse();
    let op_alu_imm_wide = op_alu_imm * (decode_opcode - opcode_alu_imm_base) * inv8;
    let op_alu_imm_base_only = op_alu_imm - op_alu_imm_wide;
    let op_alu_reg_wide = op_alu_reg * (decode_opcode - opcode_alu_reg_base) * inv8;
    let op_alu_reg_base_only = op_alu_reg - op_alu_reg_wide;

    let alu_table_base = k_consts.alu_table_weights[0] * funct3_is[0]
        + k_consts.alu_table_weights[1] * funct3_is[1]
        + k_consts.alu_table_weights[2] * funct3_is[2]
        + k_consts.alu_table_weights[3] * funct3_is[3]
        + k_consts.alu_table_weights[4] * funct3_is[4]
        + k_consts.alu_table_weights[5] * funct3_is[5]
        + k_consts.alu_table_weights[6] * funct3_is[6];
    let alu_w_table_base =
        addw_table_id * funct3_is[0] + k_consts.sllw_table_id * funct3_is[1] + k_consts.srlw_table_id * funct3_is[5];
    let branch_table_expected =
        k_consts.branch_base_10 - k_consts.branch_sub_5 * funct3_bits[2] + (funct3_bits[1] * funct3_bits[2]);
    let shift_selector = funct3_is[1] + funct3_is[5];
    let funct7_m_tail =
        funct7_bits[1] + funct7_bits[2] + funct7_bits[3] + funct7_bits[4] + funct7_bits[5] + funct7_bits[6];
    let alu_reg_table_delta_expected = decode_alu_reg_table_delta_from_bits(funct7_bits, funct3_is);

    let op_add_imm = op_alu_imm_base_only * funct3_is[0];
    let op_add_reg = op_alu_reg_base_only * funct3_is[0] * (K::ONE - funct7_bits[0]) * (K::ONE - funct7_bits[5]);
    let op_sub_reg = op_alu_reg_base_only * funct3_is[0] * (K::ONE - funct7_bits[0]) * funct7_bits[5];
    let op_mul_reg = op_alu_reg * funct3_is[0] * funct7_bits[0];
    let op_mulhu_reg = op_alu_reg * funct3_is[3] * funct7_bits[0];
    let helper_mulw_commit = virtual_commit_from_prev * op_mul_reg * op_alu_reg_wide;
    let helper_divw_commit = virtual_commit_from_prev * op_alu_reg_wide * op_alu_reg * funct7_bits[0] * funct3_is[4];
    let helper_divuw_commit = virtual_commit_from_prev * op_alu_reg_wide * op_alu_reg * funct7_bits[0] * funct3_is[5];
    let helper_remw_commit = virtual_commit_from_prev * op_alu_reg_wide * op_alu_reg * funct7_bits[0] * funct3_is[6];
    let helper_remuw_commit = virtual_commit_from_prev * op_alu_reg_wide * op_alu_reg * funct7_bits[0] * funct3_is[7];
    let helper_mulh_commit = virtual_commit_from_prev * op_alu_reg_base_only * funct7_bits[0] * funct3_is[1];
    let helper_mulhsu_commit = virtual_commit_from_prev * op_alu_reg_base_only * funct7_bits[0] * funct3_is[2];
    let helper_div_commit = virtual_commit_from_prev * op_alu_reg_base_only * funct7_bits[0] * funct3_is[4];
    let helper_divu_commit = virtual_commit_from_prev * op_alu_reg_base_only * funct7_bits[0] * funct3_is[5];
    let helper_rem_commit = virtual_commit_from_prev * op_alu_reg_base_only * funct7_bits[0] * funct3_is[6];
    let helper_remu_commit = virtual_commit_from_prev * op_alu_reg_base_only * funct7_bits[0] * funct3_is[7];
    let helper_rv32m_commit = helper_mulh_commit
        + helper_mulhsu_commit
        + helper_div_commit
        + helper_divu_commit
        + helper_rem_commit
        + helper_remu_commit;
    let helper_rv64w_commit =
        helper_mulw_commit + helper_divw_commit + helper_divuw_commit + helper_remw_commit + helper_remuw_commit;
    let helper_lookup_free_commit = helper_rv32m_commit + helper_rv64w_commit;
    let op_alu_reg_lookup = op_alu_reg - helper_lookup_free_commit;
    let op_alu_reg_write_lookup = op_alu_reg_write - helper_lookup_free_commit;
    let op_alu_reg_base_only_lookup = op_alu_reg_base_only - helper_rv32m_commit;
    let op_alu_reg_wide_lookup = op_alu_reg_wide - helper_rv64w_commit;
    let op_mul_reg_lookup = op_mul_reg - helper_mulw_commit;
    let nonvirtual = K::ONE - is_virtual;
    let op_alu_reg_lookup_nonvirtual = op_alu_reg_lookup * nonvirtual;
    let op_alu_reg_write_lookup_nonvirtual = op_alu_reg_write_lookup * nonvirtual;
    let op_alu_reg_base_only_lookup_nonvirtual = op_alu_reg_base_only_lookup * nonvirtual;
    let op_alu_reg_wide_lookup_nonvirtual = op_alu_reg_wide_lookup * nonvirtual;
    let op_mul_reg_lookup_nonvirtual = op_mul_reg_lookup * nonvirtual;
    let op_add_total = add_lookup_ops + op_add_imm + op_add_reg;
    let two_pow_32 = k_consts.two_pow_32;
    let inv_two_pow_32 = two_pow_32.inverse();
    let add_key_delta = shout_lhs + shout_rhs - shout_add_sub_key;
    let sub_key_delta = shout_lhs - shout_rhs - shout_add_sub_key;
    let add_key_delta_lo = shout_lhs_word + shout_rhs_word - shout_add_sub_key_word;
    let add_key_carry_lo = add_key_delta_lo * inv_two_pow_32;
    let add_key_delta_hi = shout_lhs_hi + shout_rhs_hi + add_key_carry_lo - shout_add_sub_key_hi;
    let sub_key_delta_lo = shout_lhs_word - shout_rhs_word - shout_add_sub_key_word;
    let sub_key_borrow_lo = -sub_key_delta_lo * inv_two_pow_32;
    let sub_key_delta_hi = shout_lhs_hi - shout_rhs_hi - sub_key_borrow_lo - shout_add_sub_key_hi;
    let mul_key_delta = shout_lhs * shout_rhs - shout_add_sub_key;
    let add_sub_combined_key_mode = if neo_memory::riscv::instruction::opcode_uses_combined_lookup_key(RiscvOpcode::Add)
    {
        K::ONE
    } else {
        K::ZERO
    };
    let mul_combined_key_mode = if neo_memory::riscv::instruction::opcode_uses_combined_lookup_key(RiscvOpcode::Mul) {
        K::ONE
    } else {
        K::ZERO
    };
    let rv64_shift_imm_bit5 = if rv64_exact_words {
        op_alu_imm_base_only * shift_selector * K::from_u64(32) * funct7_bits[0]
    } else {
        K::ZERO
    };

    let raw = [
        (op_alu_imm + op_load + op_jalr) * (shout_has_lookup - K::ONE),
        (op_alu_reg_lookup_nonvirtual + op_store) * (shout_has_lookup - K::ONE)
            + helper_lookup_free_commit * shout_has_lookup,
        op_branch * (shout_has_lookup - K::ONE),
        (K::ONE - shout_has_lookup) * shout_table_id,
        (op_alu_imm + op_alu_reg_lookup_nonvirtual + op_branch + mem_lookup_ops + op_jalr) * (shout_lhs - rs1_val)
            + helper_lookup_free_commit * shout_lhs,
        alu_imm_shift_rhs_delta - shift_selector * (rs2_decode_addr - imm_i),
        op_alu_imm
            * ((if rv64_exact_words { shout_rhs_word } else { shout_rhs })
                - imm_i
                - alu_imm_shift_rhs_delta
                - rv64_shift_imm_bit5)
            + (op_load + op_jalr) * ((if rv64_exact_words { shout_rhs_word } else { shout_rhs }) - imm_i),
        op_alu_reg_lookup_nonvirtual * (shout_rhs - rs2_val)
            + op_store * ((if rv64_exact_words { shout_rhs_word } else { shout_rhs }) - imm_s)
            + helper_lookup_free_commit * shout_rhs,
        op_branch * (shout_rhs - rs2_val),
        op_alu_imm_write * (rd_val - shout_val),
        op_alu_reg_write_lookup_nonvirtual * (rd_val - shout_val) + helper_lookup_free_commit * shout_val,
        op_alu_reg_base_only_lookup_nonvirtual * (shout_table_id - alu_table_base - alu_reg_table_delta)
            + op_alu_reg_wide_lookup_nonvirtual * (shout_table_id - alu_w_table_base - alu_reg_table_delta)
            + op_store * (shout_table_id - add_table_id),
        op_alu_imm_base_only * (shout_table_id - alu_table_base - alu_imm_table_delta)
            + op_alu_imm_wide * (shout_table_id - alu_w_table_base - alu_imm_table_delta)
            + add_lookup_ops * (shout_table_id - add_table_id),
        op_branch * (shout_table_id - branch_table_expected),
        op_alu_reg * funct7_bits[0] * funct7_m_tail,
        alu_reg_table_delta - alu_reg_table_delta_expected,
        alu_imm_table_delta - funct7_bits[5] * funct3_is[5],
        if rv64_exact_words {
            add_sub_combined_key_mode
                * op_add_total
                * (add_key_delta_lo * (add_key_delta_lo - two_pow_32)
                    + add_key_delta_hi * (add_key_delta_hi - two_pow_32))
        } else {
            add_sub_combined_key_mode * op_add_total * add_key_delta * (add_key_delta - two_pow_32)
        },
        if rv64_exact_words {
            add_sub_combined_key_mode
                * op_sub_reg
                * (sub_key_delta_lo * (sub_key_delta_lo + two_pow_32)
                    + sub_key_delta_hi * (sub_key_delta_hi + two_pow_32))
        } else {
            add_sub_combined_key_mode * op_sub_reg * sub_key_delta * (sub_key_delta + two_pow_32)
        },
        mul_combined_key_mode * (op_mul_reg_lookup_nonvirtual + op_mulhu_reg * nonvirtual) * mul_key_delta,
        helper_lookup_free_commit * shout_add_sub_key,
        trace_rs1_addr - decode_rs1_addr,
        trace_rs2_addr - decode_rs2_addr,
        decode_rd_has_write * (trace_rd_addr - decode_rd_addr),
        trace_rd_has_write - decode_rd_has_write,
        op_lui * decode_rd_has_write - op_lui_write,
        op_auipc * decode_rd_has_write - op_auipc_write,
        op_jal * decode_rd_has_write - op_jal_write,
        op_jalr * decode_rd_has_write - op_jalr_write,
        op_alu_imm * decode_rd_has_write - op_alu_imm_write,
        op_alu_reg * decode_rd_has_write - op_alu_reg_write,
        op_lui * (decode_rd_has_write + rd_is_zero - K::ONE),
        op_auipc * (decode_rd_has_write + rd_is_zero - K::ONE),
        op_jal * (decode_rd_has_write + rd_is_zero - K::ONE),
        op_jalr * (decode_rd_has_write + rd_is_zero - K::ONE),
        opcode_flags[5] * (decode_rd_has_write + rd_is_zero - K::ONE),
        op_alu_imm * (decode_rd_has_write + rd_is_zero - K::ONE),
        op_alu_reg * (decode_rd_has_write + rd_is_zero - K::ONE),
        op_branch * decode_rd_has_write,
        opcode_flags[6] * decode_rd_has_write,
        op_misc_mem * decode_rd_has_write,
        op_system * decode_rd_has_write,
        active * (halted - op_system),
        opcode_flags[5] * (ram_has_read - K::ONE),
        opcode_flags[6] * (ram_has_write - K::ONE),
        non_mem_ops * ram_has_read,
        non_mem_ops * ram_has_write,
        non_mem_ops * ram_addr,
        op_load * (ram_addr - shout_val),
        op_store * (ram_addr - shout_val),
    ];
    for r in raw {
        residuals.push(nonvirtual * r);
    }

    let virtual_inputs = DecodeVirtualResidualInputs {
        base: *inputs,
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
    };
    super::decode_residuals_virtual::push_virtual_decode_residuals(&virtual_inputs, residuals);

    debug_assert_eq!(
        residuals.len(),
        DECODE_ALU_BRANCH_RESIDUAL_COUNT,
        "decode/fields alu_branch residual count mismatch: expected {}, got {}",
        DECODE_ALU_BRANCH_RESIDUAL_COUNT,
        residuals.len()
    );
}

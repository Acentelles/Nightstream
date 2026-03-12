//! Route-A trace linkage, opening extraction, and residual arithmetic helpers.
//!
//! This module owns the semantic checks and arithmetic identities that tie the
//! concrete CPU trace columns to Route-A / Stage-8 claim verification. It keeps
//! trace-linkage and residual formulas together instead of hiding them inside a
//! broader "common" utility bucket.

use super::*;

pub(crate) struct TraceCpuLinkOpenings {
    pub(crate) shout_has_lookup: K,
    pub(crate) shout_val: K,
    pub(crate) shout_link_lhs: K,
    pub(crate) shout_link_rhs: K,
    pub(crate) shout_add_sub_key: K,
}

#[derive(Clone, Copy, Debug, Default)]
pub(crate) struct ShoutTraceLinkSums {
    pub(crate) has_lookup: K,
    pub(crate) val: K,
    pub(crate) link_lhs: K,
    pub(crate) link_rhs: K,
    pub(crate) add_sub_key: K,
    pub(crate) table_id: K,
}

#[inline]
pub(crate) fn verify_non_event_trace_shout_linkage(
    cpu: TraceCpuLinkOpenings,
    sums: ShoutTraceLinkSums,
    expected_table_id: Option<K>,
) -> Result<(), PiCcsError> {
    if sums.has_lookup != cpu.shout_has_lookup {
        return Err(PiCcsError::ProtocolError(
            "trace linkage failed: Shout has_lookup mismatch".into(),
        ));
    }
    if sums.val != cpu.shout_val {
        return Err(PiCcsError::ProtocolError(
            "trace linkage failed: Shout val mismatch".into(),
        ));
    }
    if sums.link_lhs != cpu.shout_link_lhs {
        return Err(PiCcsError::ProtocolError(format!(
            "trace linkage failed: Shout lhs mismatch (sums={}, cpu={})",
            sums.link_lhs, cpu.shout_link_lhs
        )));
    }
    if sums.link_rhs != cpu.shout_link_rhs {
        return Err(PiCcsError::ProtocolError(format!(
            "trace linkage failed: Shout rhs mismatch (sums={}, cpu={})",
            sums.link_rhs, cpu.shout_link_rhs
        )));
    }
    if sums.add_sub_key != cpu.shout_add_sub_key {
        return Err(PiCcsError::ProtocolError(format!(
            "trace linkage failed: Shout add/sub key mismatch (sums={}, cpu={})",
            sums.add_sub_key, cpu.shout_add_sub_key
        )));
    }
    if let Some(expected_table_id) = expected_table_id {
        if sums.table_id != expected_table_id {
            return Err(PiCcsError::ProtocolError(
                "trace linkage failed: Shout table_id mismatch".into(),
            ));
        }
    }
    Ok(())
}

#[inline]
pub(crate) fn eq_single_k(a: K, b: K) -> K {
    a * b + (K::ONE - a) * (K::ONE - b)
}

pub(crate) fn chi_cycle_children(r_cycle: &[K], bit_idx: usize, prefix_eq: K, pair_idx: usize) -> (K, K) {
    let mut suffix = K::ONE;
    let mut shift = 0usize;
    for b in (bit_idx + 1)..r_cycle.len() {
        let bit = (pair_idx >> shift) & 1;
        suffix *= if bit == 1 { r_cycle[b] } else { K::ONE - r_cycle[b] };
        shift += 1;
    }

    let r = r_cycle[bit_idx];
    let child0 = prefix_eq * (K::ONE - r) * suffix;
    let child1 = prefix_eq * r * suffix;
    (child0, child1)
}

#[inline]
pub(crate) fn wb_weight_vector(r_cycle: &[K], len: usize) -> Vec<K> {
    bitness_weights(r_cycle, len, 0x5742_5F42_4F4F_4Cu64)
}

#[inline]
pub(crate) fn w2_decode_pack_weight_vector(r_cycle: &[K], len: usize) -> Vec<K> {
    bitness_weights(r_cycle, len, 0x5732_5F50_4143_4Bu64)
}

#[inline]
pub(crate) fn w2_decode_imm_weight_vector(r_cycle: &[K], len: usize) -> Vec<K> {
    bitness_weights(r_cycle, len, 0x5732_5F49_4D4D_214Du64)
}

#[inline]
pub(crate) fn w3_bitness_weight_vector(r_cycle: &[K], len: usize) -> Vec<K> {
    bitness_weights(r_cycle, len, 0x5733_5F42_4954_2144u64)
}

#[inline]
pub(crate) fn w3_quiescence_weight_vector(r_cycle: &[K], len: usize) -> Vec<K> {
    bitness_weights(r_cycle, len, 0x5733_5F51_5549_4553u64)
}

#[inline]
pub(crate) fn w3_load_weight_vector(r_cycle: &[K], len: usize) -> Vec<K> {
    bitness_weights(r_cycle, len, 0x5733_5F4C_4F41_4421u64)
}

#[inline]
pub(crate) fn w3_store_weight_vector(r_cycle: &[K], len: usize) -> Vec<K> {
    bitness_weights(r_cycle, len, 0x5733_5F53_544F_5245u64)
}

#[inline]
pub(crate) fn control_next_pc_linear_weight_vector(r_cycle: &[K], len: usize) -> Vec<K> {
    bitness_weights(r_cycle, len, 0x4354_524C_4E50_434Cu64)
}

#[inline]
pub(crate) fn control_next_pc_control_weight_vector(r_cycle: &[K], len: usize) -> Vec<K> {
    bitness_weights(r_cycle, len, 0x4354_524C_4E50_4343u64)
}

#[inline]
pub(crate) fn control_branch_semantics_weight_vector(r_cycle: &[K], len: usize) -> Vec<K> {
    bitness_weights(r_cycle, len, 0x4354_524C_4252_534Du64)
}

#[inline]
pub(crate) fn control_writeback_weight_vector(r_cycle: &[K], len: usize) -> Vec<K> {
    bitness_weights(r_cycle, len, 0x4354_524C_5752_4255u64)
}

#[inline]
pub(crate) fn wp_weight_vector(r_cycle: &[K], len: usize) -> Vec<K> {
    bitness_weights(r_cycle, len, 0x5750_5F51_5549_4553u64)
}

pub(crate) fn rv32_trace_wb_columns(layout: &Rv32TraceLayout) -> Vec<usize> {
    vec![layout.active, layout.halted, layout.shout_has_lookup]
}

#[inline]
pub(crate) fn riscv_trace_wb_columns(layout: &Rv32TraceLayout) -> Vec<usize> {
    rv32_trace_wb_columns(layout)
}

// Selector(8) + bitness(20) + ALU/branch/decomposition(824).
pub(crate) const W2_FIELDS_RESIDUAL_COUNT: usize = 852;
// Virtual DIV/REM stage selectors (up to rem=19) raise decode/fields multiplicative degree.
pub(crate) const W2_FIELDS_DEGREE_BOUND: usize = 64;
pub(crate) const W2_IMM_RESIDUAL_COUNT: usize = 4;

#[inline]
pub(crate) fn w2_bool01(v: K) -> K {
    v * (v - K::ONE)
}

#[inline]
pub(crate) fn w2_reg_addr_from_bits(bits: [K; 5]) -> K {
    bits[0]
        + K::from(F::from_u64(2)) * bits[1]
        + K::from(F::from_u64(4)) * bits[2]
        + K::from(F::from_u64(8)) * bits[3]
        + K::from(F::from_u64(16)) * bits[4]
}

#[inline]
pub(crate) fn w2_decode_selector_residuals(
    active: K,
    decode_opcode: K,
    opcode_flags: [K; 12],
    op_custom: K,
    funct3_is: [K; 8],
    funct3_bits: [K; 3],
    op_amo: K,
) -> [K; 8] {
    let opcode_one_hot = opcode_flags.into_iter().fold(K::ZERO, |acc, v| acc + v) + op_custom - active;
    let funct3_one_hot = funct3_is.into_iter().fold(K::ZERO, |acc, v| acc + v) - active;
    let funct3_bit0_link = (funct3_is[1] + funct3_is[3] + funct3_is[5] + funct3_is[7]) - funct3_bits[0];
    let funct3_bit1_link = (funct3_is[2] + funct3_is[3] + funct3_is[6] + funct3_is[7]) - funct3_bits[1];
    let funct3_bit2_link = (funct3_is[4] + funct3_is[5] + funct3_is[6] + funct3_is[7]) - funct3_bits[2];
    let branch_f3b1_link = (funct3_is[6] + funct3_is[7]) - (funct3_bits[1] * funct3_bits[2]);
    // Tier-2.1 trace mode lock: op_amo must be zero on every row.
    let amo_forbidden = op_amo;
    let opcode_value_link = opcode_flags[0] * (decode_opcode - K::from(F::from_u64(0x37)))
        + opcode_flags[1] * (decode_opcode - K::from(F::from_u64(0x17)))
        + opcode_flags[2] * (decode_opcode - K::from(F::from_u64(0x6f)))
        + opcode_flags[3] * (decode_opcode - K::from(F::from_u64(0x67)))
        + opcode_flags[4] * (decode_opcode - K::from(F::from_u64(0x63)))
        + opcode_flags[5] * (decode_opcode - K::from(F::from_u64(0x03)))
        + opcode_flags[6] * (decode_opcode - K::from(F::from_u64(0x23)))
        + opcode_flags[7] * (decode_opcode - K::from(F::from_u64(0x13))) * (decode_opcode - K::from(F::from_u64(0x1b)))
        + opcode_flags[8] * (decode_opcode - K::from(F::from_u64(0x33))) * (decode_opcode - K::from(F::from_u64(0x3b)))
        + opcode_flags[9] * (decode_opcode - K::from(F::from_u64(0x0f)))
        + opcode_flags[10] * (decode_opcode - K::from(F::from_u64(0x73)))
        + opcode_flags[11] * (decode_opcode - K::from(F::from_u64(0x2f)))
        + op_custom * (decode_opcode - K::from(F::from_u64(0x0b)));

    [
        opcode_one_hot,
        funct3_one_hot,
        funct3_bit0_link,
        funct3_bit1_link,
        funct3_bit2_link,
        branch_f3b1_link,
        amo_forbidden,
        opcode_value_link,
    ]
}

#[inline]
pub(crate) fn w2_decode_bitness_residuals(opcode_flags: [K; 12], funct3_is: [K; 8]) -> [K; 20] {
    [
        w2_bool01(opcode_flags[0]),
        w2_bool01(opcode_flags[1]),
        w2_bool01(opcode_flags[2]),
        w2_bool01(opcode_flags[3]),
        w2_bool01(opcode_flags[4]),
        w2_bool01(opcode_flags[5]),
        w2_bool01(opcode_flags[6]),
        w2_bool01(opcode_flags[7]),
        w2_bool01(opcode_flags[8]),
        w2_bool01(opcode_flags[9]),
        w2_bool01(opcode_flags[10]),
        w2_bool01(opcode_flags[11]),
        w2_bool01(funct3_is[0]),
        w2_bool01(funct3_is[1]),
        w2_bool01(funct3_is[2]),
        w2_bool01(funct3_is[3]),
        w2_bool01(funct3_is[4]),
        w2_bool01(funct3_is[5]),
        w2_bool01(funct3_is[6]),
        w2_bool01(funct3_is[7]),
    ]
}

#[inline]
pub(crate) fn w2_alu_reg_table_delta_from_bits(funct7_bits: [K; 7], funct3_is: [K; 8]) -> K {
    let is_rv32m = funct7_bits[0];

    let base_delta = funct7_bits[5] * (funct3_is[0] + funct3_is[5]);
    let rv32m_delta = K::from(F::from_u64(9)) * funct3_is[0]
        + K::from(F::from_u64(6)) * funct3_is[1]
        + K::from(F::from_u64(10)) * funct3_is[2]
        + K::from(F::from_u64(8)) * funct3_is[3]
        + K::from(F::from_u64(15)) * funct3_is[4]
        + K::from(F::from_u64(9)) * funct3_is[5]
        + K::from(F::from_u64(16)) * funct3_is[6]
        + K::from(F::from_u64(19)) * funct3_is[7];

    (K::ONE - is_rv32m) * base_delta + is_rv32m * rv32m_delta
}

#[inline]
pub(crate) fn w2_decode_immediate_residuals(
    imm_i: K,
    imm_s: K,
    imm_b: K,
    imm_j: K,
    rd_bits: [K; 5],
    funct3_bits: [K; 3],
    rs1_bits: [K; 5],
    rs2_bits: [K; 5],
    funct7_bits: [K; 7],
) -> [K; 4] {
    let signext_imm12 = K::from(F::from_u64((1u64 << 32) - (1u64 << 11)));
    let signext_imm13 = K::from(F::from_u64((1u64 << 32) - (1u64 << 12)));
    let signext_imm21 = K::from(F::from_u64((1u64 << 32) - (1u64 << 20)));

    let imm_i_res = imm_i
        - rs2_bits[0]
        - K::from(F::from_u64(2)) * rs2_bits[1]
        - K::from(F::from_u64(4)) * rs2_bits[2]
        - K::from(F::from_u64(8)) * rs2_bits[3]
        - K::from(F::from_u64(16)) * rs2_bits[4]
        - K::from(F::from_u64(32)) * funct7_bits[0]
        - K::from(F::from_u64(64)) * funct7_bits[1]
        - K::from(F::from_u64(128)) * funct7_bits[2]
        - K::from(F::from_u64(256)) * funct7_bits[3]
        - K::from(F::from_u64(512)) * funct7_bits[4]
        - K::from(F::from_u64(1024)) * funct7_bits[5]
        - signext_imm12 * funct7_bits[6];

    let imm_s_res = imm_s
        - rd_bits[0]
        - K::from(F::from_u64(2)) * rd_bits[1]
        - K::from(F::from_u64(4)) * rd_bits[2]
        - K::from(F::from_u64(8)) * rd_bits[3]
        - K::from(F::from_u64(16)) * rd_bits[4]
        - K::from(F::from_u64(32)) * funct7_bits[0]
        - K::from(F::from_u64(64)) * funct7_bits[1]
        - K::from(F::from_u64(128)) * funct7_bits[2]
        - K::from(F::from_u64(256)) * funct7_bits[3]
        - K::from(F::from_u64(512)) * funct7_bits[4]
        - K::from(F::from_u64(1024)) * funct7_bits[5]
        - signext_imm12 * funct7_bits[6];

    let imm_b_res = imm_b
        - K::from(F::from_u64(2)) * rd_bits[1]
        - K::from(F::from_u64(4)) * rd_bits[2]
        - K::from(F::from_u64(8)) * rd_bits[3]
        - K::from(F::from_u64(16)) * rd_bits[4]
        - K::from(F::from_u64(32)) * funct7_bits[0]
        - K::from(F::from_u64(64)) * funct7_bits[1]
        - K::from(F::from_u64(128)) * funct7_bits[2]
        - K::from(F::from_u64(256)) * funct7_bits[3]
        - K::from(F::from_u64(512)) * funct7_bits[4]
        - K::from(F::from_u64(1024)) * funct7_bits[5]
        - K::from(F::from_u64(2048)) * rd_bits[0]
        - signext_imm13 * funct7_bits[6];

    let imm_j_res = imm_j
        - K::from(F::from_u64(2)) * rs2_bits[1]
        - K::from(F::from_u64(4)) * rs2_bits[2]
        - K::from(F::from_u64(8)) * rs2_bits[3]
        - K::from(F::from_u64(16)) * rs2_bits[4]
        - K::from(F::from_u64(32)) * funct7_bits[0]
        - K::from(F::from_u64(64)) * funct7_bits[1]
        - K::from(F::from_u64(128)) * funct7_bits[2]
        - K::from(F::from_u64(256)) * funct7_bits[3]
        - K::from(F::from_u64(512)) * funct7_bits[4]
        - K::from(F::from_u64(1024)) * funct7_bits[5]
        - K::from(F::from_u64(2048)) * rs2_bits[0]
        - K::from(F::from_u64(4096)) * funct3_bits[0]
        - K::from(F::from_u64(8192)) * funct3_bits[1]
        - K::from(F::from_u64(16384)) * funct3_bits[2]
        - K::from(F::from_u64(32768)) * rs1_bits[0]
        - K::from(F::from_u64(65536)) * rs1_bits[1]
        - K::from(F::from_u64(131072)) * rs1_bits[2]
        - K::from(F::from_u64(262144)) * rs1_bits[3]
        - K::from(F::from_u64(524288)) * rs1_bits[4]
        - signext_imm21 * funct7_bits[6];

    [imm_i_res, imm_s_res, imm_b_res, imm_j_res]
}

#[inline]
pub(crate) fn w3_load_semantics_residuals(
    rd_val: K,
    ram_rv: K,
    rd_has_write: K,
    ram_has_read: K,
    load_flags: [K; 5],
    ram_rv_q16: K,
    ram_rv_low_bits: [K; 16],
) -> [K; 16] {
    let pow2 = |k: usize| K::from(F::from_u64(1u64 << k));
    let two16 = K::from(F::from_u64(1u64 << 16));
    let lb_sign_coeff = K::from(F::from_u64((1u64 << 32) - (1u64 << 7)));
    let lh_sign_coeff = K::from(F::from_u64((1u64 << 32) - (1u64 << 15)));

    let mut ram_rv_low8 = K::ZERO;
    for (k, b) in ram_rv_low_bits.iter().copied().enumerate().take(8) {
        ram_rv_low8 += pow2(k) * b;
    }
    let mut ram_rv_low16 = K::ZERO;
    for (k, b) in ram_rv_low_bits.iter().copied().enumerate() {
        ram_rv_low16 += pow2(k) * b;
    }

    let lb_val = {
        let mut acc = K::ZERO;
        for (k, b) in ram_rv_low_bits.iter().copied().enumerate().take(8) {
            acc += if k == 7 { lb_sign_coeff } else { pow2(k) } * b;
        }
        acc
    };
    let lh_val = {
        let mut acc = K::ZERO;
        for (k, b) in ram_rv_low_bits.iter().copied().enumerate() {
            if k >= 16 {
                break;
            }
            acc += if k == 15 { lh_sign_coeff } else { pow2(k) } * b;
        }
        acc
    };
    let rd_write_gate = rd_has_write;

    [
        load_flags[4] * rd_write_gate * (rd_val - ram_rv),
        load_flags[0] * rd_write_gate * (rd_val - lb_val),
        load_flags[1] * rd_write_gate * (rd_val - ram_rv_low8),
        load_flags[2] * rd_write_gate * (rd_val - lh_val),
        load_flags[3] * rd_write_gate * (rd_val - ram_rv_low16),
        load_flags[0] * rd_has_write * (rd_has_write - K::ONE),
        load_flags[1] * rd_has_write * (rd_has_write - K::ONE),
        load_flags[2] * rd_has_write * (rd_has_write - K::ONE),
        load_flags[3] * rd_has_write * (rd_has_write - K::ONE),
        load_flags[4] * rd_has_write * (rd_has_write - K::ONE),
        load_flags[0] * (ram_has_read - K::ONE),
        load_flags[1] * (ram_has_read - K::ONE),
        load_flags[2] * (ram_has_read - K::ONE),
        load_flags[3] * (ram_has_read - K::ONE),
        load_flags[4] * (ram_has_read - K::ONE),
        ram_has_read * (ram_rv - two16 * ram_rv_q16 - ram_rv_low16),
    ]
}

#[inline]
pub(crate) fn w3_store_semantics_residuals(
    ram_wv: K,
    ram_rv: K,
    rs2_val: K,
    rd_has_write: K,
    ram_has_read: K,
    ram_has_write: K,
    store_flags: [K; 3],
    rs2_q16: K,
    ram_rv_low_bits: [K; 16],
    rs2_low_bits: [K; 16],
) -> [K; 12] {
    let pow2 = |k: usize| K::from(F::from_u64(1u64 << k));
    let two16 = K::from(F::from_u64(1u64 << 16));
    let mut rs2_low16 = K::ZERO;
    let mut sb_patch = K::ZERO;
    let mut sh_patch = K::ZERO;
    for k in 0..16 {
        let coeff = pow2(k);
        rs2_low16 += coeff * rs2_low_bits[k];
        if k < 8 {
            sb_patch += coeff * (ram_rv_low_bits[k] - rs2_low_bits[k]);
        }
        sh_patch += coeff * (ram_rv_low_bits[k] - rs2_low_bits[k]);
    }
    [
        store_flags[2] * (ram_wv - rs2_val),
        store_flags[0] * (ram_wv - ram_rv + sb_patch),
        store_flags[1] * (ram_wv - ram_rv + sh_patch),
        store_flags[0] * rd_has_write,
        store_flags[1] * rd_has_write,
        store_flags[2] * rd_has_write,
        store_flags[0] * (ram_has_read - K::ONE),
        store_flags[1] * (ram_has_read - K::ONE),
        store_flags[0] * (ram_has_write - K::ONE),
        store_flags[1] * (ram_has_write - K::ONE),
        store_flags[2] * (ram_has_write - K::ONE),
        rs2_val - two16 * rs2_q16 - rs2_low16,
    ]
}

#[inline]
pub(crate) fn control_branch_taken_from_bits(shout_val: K, funct3_bit0: K) -> K {
    shout_val + funct3_bit0 - K::from(F::from_u64(2)) * funct3_bit0 * shout_val
}

#[inline]
pub(crate) fn control_imm_u_from_bits(
    funct3_bits: [K; 3],
    rs1_bits: [K; 5],
    rs2_bits: [K; 5],
    funct7_bits: [K; 7],
) -> K {
    let pow2 = |k: u64| K::from(F::from_u64(1u64 << k));
    let mut out = K::ZERO;
    out += pow2(12) * funct3_bits[0];
    out += pow2(13) * funct3_bits[1];
    out += pow2(14) * funct3_bits[2];
    out += pow2(15) * rs1_bits[0];
    out += pow2(16) * rs1_bits[1];
    out += pow2(17) * rs1_bits[2];
    out += pow2(18) * rs1_bits[3];
    out += pow2(19) * rs1_bits[4];
    out += pow2(20) * rs2_bits[0];
    out += pow2(21) * rs2_bits[1];
    out += pow2(22) * rs2_bits[2];
    out += pow2(23) * rs2_bits[3];
    out += pow2(24) * rs2_bits[4];
    out += pow2(25) * funct7_bits[0];
    out += pow2(26) * funct7_bits[1];
    out += pow2(27) * funct7_bits[2];
    out += pow2(28) * funct7_bits[3];
    out += pow2(29) * funct7_bits[4];
    out += pow2(30) * funct7_bits[5];
    out += pow2(31) * funct7_bits[6];
    out
}

#[inline]
pub(crate) fn control_imm_u_value_from_bits(
    funct3_bits: [K; 3],
    rs1_bits: [K; 5],
    rs2_bits: [K; 5],
    funct7_bits: [K; 7],
    machine_xlen: usize,
) -> K {
    let imm_u = control_imm_u_from_bits(funct3_bits, rs1_bits, rs2_bits, funct7_bits);
    if machine_xlen != 64 {
        return imm_u;
    }
    let two32 = K::from(F::from_u64(1u64 << 32));
    let sign_fill_hi32 = (two32 - K::ONE) * funct7_bits[6];
    imm_u + sign_fill_hi32 * two32
}

#[inline]
pub(crate) fn control_next_pc_linear_residual(
    pc_before: K,
    pc_after: K,
    is_virtual: K,
    op_lui: K,
    op_auipc: K,
    op_load: K,
    op_store: K,
    op_alu_imm: K,
    op_alu_reg: K,
    op_misc_mem: K,
    op_system: K,
    op_amo: K,
    op_custom: K,
) -> K {
    let op_linear =
        op_lui + op_auipc + op_load + op_store + op_alu_imm + op_alu_reg + op_misc_mem + op_system + op_amo + op_custom;
    let non_virtual = K::ONE - is_virtual;
    non_virtual * op_linear * (pc_after - pc_before - K::from(F::from_u64(4)))
}

#[inline]
pub(crate) fn control_next_pc_control_residuals(
    active: K,
    pc_before: K,
    pc_after: K,
    _rs1_val: K,
    jalr_drop_bit: K,
    _imm_i: K,
    imm_b: K,
    imm_j: K,
    imm_sign_bit: K,
    op_jal: K,
    op_jalr: K,
    op_branch: K,
    shout_val: K,
    funct3_bit0: K,
) -> [K; 5] {
    let four = K::from(F::from_u64(4));
    let two32 = K::from(F::from_u64(1u64 << 32));
    let imm_b_signed = imm_b - two32 * imm_sign_bit;
    let imm_j_signed = imm_j - two32 * imm_sign_bit;
    let taken = control_branch_taken_from_bits(shout_val, funct3_bit0);
    [
        op_jal * (pc_after - pc_before - imm_j_signed),
        op_jalr * (pc_after - shout_val + jalr_drop_bit),
        op_branch * (pc_after - pc_before - four - taken * (imm_b_signed - four)),
        op_jalr * jalr_drop_bit * (jalr_drop_bit - K::ONE),
        (active - op_jalr) * jalr_drop_bit,
    ]
}

#[inline]
pub(crate) fn control_branch_semantics_residuals(
    op_branch: K,
    shout_val: K,
    _funct3_bit0: K,
    funct3_bit1: K,
    funct3_bit2: K,
    funct3_is6: K,
    funct3_is7: K,
) -> [K; 2] {
    [
        op_branch * ((funct3_is6 + funct3_is7) - funct3_bit1 * funct3_bit2),
        op_branch * shout_val * (shout_val - K::ONE),
    ]
}

#[inline]
pub(crate) fn control_writeback_residuals(
    rd_val: K,
    pc_before: K,
    imm_u: K,
    op_lui_write: K,
    op_auipc_write: K,
    op_jal_write: K,
    op_jalr_write: K,
) -> [K; 4] {
    let four = K::from(F::from_u64(4));
    let two32 = K::from(F::from_u64(1u64 << 32));
    let auipc_delta = rd_val - pc_before - imm_u;
    let jal_delta = rd_val - pc_before - four;
    [
        op_lui_write * (rd_val - imm_u),
        op_auipc_write * auipc_delta * (auipc_delta + two32),
        op_jal_write * jal_delta * (jal_delta + two32),
        op_jalr_write * jal_delta * (jal_delta + two32),
    ]
}

pub(crate) fn rv32_trace_wp_columns(layout: &Rv32TraceLayout) -> Vec<usize> {
    vec![
        layout.is_virtual,
        layout.virtual_sequence_remaining,
        layout.virtual_commit_from_prev,
        layout.instr_word,
        layout.rs1_addr,
        layout.rs1_val,
        layout.rs2_addr,
        layout.rs2_val,
        layout.rd_addr,
        layout.rd_val,
        layout.rd_has_write,
        layout.ram_addr,
        layout.ram_rv,
        layout.ram_wv,
        layout.shout_has_lookup,
        layout.shout_table_id,
        layout.shout_val,
        layout.shout_lhs,
        layout.shout_rhs,
        layout.shout_add_sub_key,
        layout.jalr_drop_bit,
    ]
}

#[inline]
pub(crate) fn riscv_trace_wp_columns(layout: &Rv32TraceLayout) -> Vec<usize> {
    rv32_trace_wp_columns(layout)
}

#[inline]
pub(crate) fn trace_uses_rv64_exact_words(cpu_cols_len: usize) -> bool {
    neo_memory::riscv::trace::infer_riscv_trace_machine_xlen(cpu_cols_len) == Some(64)
}

pub(crate) fn rv64_trace_exact_word_opening_columns() -> Vec<usize> {
    let layout = neo_memory::riscv::trace::Rv64TraceLayout::new();
    vec![
        layout.rs1_val_lo32,
        layout.rs2_val_lo32,
        layout.rd_val_lo32,
        layout.shout_lhs_lo32,
        layout.shout_lhs_hi32,
        layout.shout_rhs_lo32,
        layout.shout_rhs_hi32,
        layout.shout_add_sub_key_lo32,
        layout.shout_add_sub_key_hi32,
    ]
}

pub(crate) fn rv32_trace_wp_opening_columns(layout: &Rv32TraceLayout) -> Vec<usize> {
    let mut out = Vec::with_capacity(1 + layout.cols);
    out.push(layout.active);
    out.extend(rv32_trace_wp_columns(layout));
    out
}

#[inline]
pub(crate) fn riscv_trace_wp_opening_columns(layout: &Rv32TraceLayout) -> Vec<usize> {
    rv32_trace_wp_opening_columns(layout)
}

pub(crate) fn rv32_trace_control_extra_opening_columns(layout: &Rv32TraceLayout) -> Vec<usize> {
    vec![layout.pc_before, layout.pc_after]
}

#[inline]
pub(crate) fn riscv_trace_control_extra_opening_columns(layout: &Rv32TraceLayout) -> Vec<usize> {
    rv32_trace_control_extra_opening_columns(layout)
}

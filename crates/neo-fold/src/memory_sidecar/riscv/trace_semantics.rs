//! Route-A trace linkage, opening extraction, and residual arithmetic helpers.
//!
//! This module owns the semantic checks and arithmetic identities that tie the
//! concrete CPU trace columns to Route-A / joint-opening claim verification. It keeps
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
        return Err(PiCcsError::ProtocolError(format!(
            "trace linkage failed: Shout has_lookup mismatch (sums={}, cpu={})",
            sums.has_lookup, cpu.shout_has_lookup
        )));
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
pub(crate) fn booleanity_weight_vector(r_cycle: &[K], len: usize) -> Vec<K> {
    bitness_weights(r_cycle, len, 0x5742_5F42_4F4F_4Cu64)
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
pub(crate) fn trace_opening_weight_vector(r_cycle: &[K], len: usize) -> Vec<K> {
    bitness_weights(r_cycle, len, 0x5750_5F51_5549_4553u64)
}

pub(crate) fn rv64_trace_booleanity_columns(layout: &neo_memory::riscv::trace::Rv64TraceLayout) -> Vec<usize> {
    vec![layout.active, layout.halted, layout.shout_has_lookup]
}

#[inline]
pub(crate) fn decode_bool01(v: K) -> K {
    v * (v - K::ONE)
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

pub(crate) fn rv64_trace_quiescence_columns(layout: &neo_memory::riscv::trace::Rv64TraceLayout) -> Vec<usize> {
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

pub(crate) fn rv64_trace_opening_columns(layout: &neo_memory::riscv::trace::Rv64TraceLayout) -> Vec<usize> {
    let mut out = Vec::with_capacity(22);
    out.push(layout.active);
    out.extend(rv64_trace_quiescence_columns(layout));
    out
}

pub(crate) fn rv64_trace_control_extra_opening_columns(
    layout: &neo_memory::riscv::trace::Rv64TraceLayout,
) -> Vec<usize> {
    vec![layout.pc_before, layout.pc_after]
}

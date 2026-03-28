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
pub(crate) fn trace_opening_weight_vector(r_cycle: &[K], len: usize) -> Vec<K> {
    bitness_weights(r_cycle, len, 0x5750_5F51_5549_4553u64)
}

pub(crate) fn rv64_trace_booleanity_columns(
    layout: &deprecated_neo_memory::riscv::trace::Rv64TraceLayout,
) -> Vec<usize> {
    vec![layout.active, layout.halted, layout.shout_has_lookup]
}

#[inline]
pub(crate) fn decode_bool01(v: K) -> K {
    v * (v - K::ONE)
}

pub(crate) fn rv64_trace_quiescence_columns(
    layout: &deprecated_neo_memory::riscv::trace::Rv64TraceLayout,
) -> Vec<usize> {
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
    deprecated_neo_memory::riscv::trace::infer_riscv_trace_machine_xlen(cpu_cols_len) == Some(64)
}

pub(crate) fn rv64_trace_exact_word_opening_columns() -> Vec<usize> {
    let layout = deprecated_neo_memory::riscv::trace::Rv64TraceLayout::new();
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

pub(crate) fn rv64_trace_opening_columns(layout: &deprecated_neo_memory::riscv::trace::Rv64TraceLayout) -> Vec<usize> {
    let mut out = Vec::with_capacity(22);
    out.push(layout.active);
    out.extend(rv64_trace_quiescence_columns(layout));
    out
}

use neo_ccs::relations::CcsStructure;
use p3_field::PrimeCharacteristicRing;
use p3_goldilocks::Goldilocks as F;

use crate::riscv::exec_table::Rv32ExecTable;
use crate::riscv::trace::{Rv32TraceLayout, Rv32TraceWitness};

use super::constraint_builder::{build_r1cs_ccs, Constraint};

/// Fixed-width, time-in-rows trace CCS layout.
///
/// This is a Tier 2.1 trace CCS with fixed columns over time (`t` rows),
/// AIR-like wiring invariants, and a compact subset of ISA semantics guards.
///
/// Witness layout (column-major trace region):
/// `cell(trace_col, row) = trace_base + trace_col * t + row`.
#[derive(Clone, Debug)]
pub struct Rv32TraceCcsLayout {
    pub t: usize,
    pub m_in: usize,
    pub m: usize,

    // Public scalars.
    pub const_one: usize,
    pub pc0: usize,
    pub pc_final: usize,
    pub halted_in: usize,
    pub halted_out: usize,

    pub trace_base: usize,
    pub trace: Rv32TraceLayout,
}

impl Rv32TraceCcsLayout {
    pub fn new(t: usize) -> Result<Self, String> {
        if t == 0 {
            return Err("Rv32TraceCcsLayout: t must be >= 1".into());
        }

        let const_one: usize = 0;
        let pc0: usize = 1;
        let pc_final: usize = 2;
        let halted_in: usize = 3;
        let halted_out: usize = 4;
        let m_in: usize = 5;

        let trace = Rv32TraceLayout::new();
        let trace_base = m_in;
        let trace_len = trace
            .cols
            .checked_mul(t)
            .ok_or_else(|| "Rv32TraceCcsLayout: trace_len overflow".to_string())?;
        let m = trace_base
            .checked_add(trace_len)
            .ok_or_else(|| "Rv32TraceCcsLayout: m overflow".to_string())?;

        Ok(Self {
            t,
            m_in,
            m,
            const_one,
            pc0,
            pc_final,
            halted_in,
            halted_out,
            trace_base,
            trace,
        })
    }

    /// Full witness index for a trace cell.
    #[inline]
    pub fn cell(&self, trace_col: usize, row: usize) -> usize {
        debug_assert!(trace_col < self.trace.cols);
        debug_assert!(row < self.t);
        self.trace_base + trace_col * self.t + row
    }
}

/// Build the public inputs `x` and witness `w` for the trace CCS from an exec table.
pub fn rv32_trace_ccs_witness_from_exec_table(
    layout: &Rv32TraceCcsLayout,
    exec: &Rv32ExecTable,
) -> Result<(Vec<F>, Vec<F>), String> {
    let wit = Rv32TraceWitness::from_exec_table(&layout.trace, exec)?;
    rv32_trace_ccs_witness_from_trace_witness(layout, &wit)
}

/// Build the public inputs `x` and witness `w` for the trace CCS from a trace witness.
pub fn rv32_trace_ccs_witness_from_trace_witness(
    layout: &Rv32TraceCcsLayout,
    wit: &Rv32TraceWitness,
) -> Result<(Vec<F>, Vec<F>), String> {
    if wit.t != layout.t {
        return Err(format!(
            "trace CCS witness: t mismatch (wit.t={} layout.t={})",
            wit.t, layout.t
        ));
    }
    if wit.cols.len() != layout.trace.cols {
        return Err(format!(
            "trace CCS witness: width mismatch (wit.cols={} trace.cols={})",
            wit.cols.len(),
            layout.trace.cols
        ));
    }

    let mut x = vec![F::ZERO; layout.m_in];
    x[layout.const_one] = F::ONE;
    x[layout.pc0] = wit.cols[layout.trace.pc_before][0];
    x[layout.pc_final] = wit.cols[layout.trace.pc_after][layout.t - 1];
    x[layout.halted_in] = wit.cols[layout.trace.halted][0];
    x[layout.halted_out] = wit.cols[layout.trace.halted][layout.t - 1];

    let mut w = vec![F::ZERO; layout.m - layout.m_in];
    for trace_col in 0..layout.trace.cols {
        let col = &wit.cols[trace_col];
        for row in 0..layout.t {
            let idx = layout.cell(trace_col, row);
            w[idx - layout.m_in] = col[row];
        }
    }

    Ok((x, w))
}

/// Build the base trace CCS (wiring invariants + partial ISA semantics guards).
pub fn build_rv32_trace_wiring_ccs(layout: &Rv32TraceCcsLayout) -> Result<CcsStructure<F>, String> {
    build_rv32_trace_wiring_ccs_with_reserved_rows(layout, 0)
}

pub fn build_rv32_trace_wiring_ccs_with_reserved_rows(
    layout: &Rv32TraceCcsLayout,
    reserved_rows: usize,
) -> Result<CcsStructure<F>, String> {
    let one = layout.const_one;
    let t = layout.t;
    let tr = |c: usize, i: usize| -> usize { layout.cell(c, i) };
    let l = &layout.trace;

    let mut cons: Vec<Constraint<F>> = Vec::new();

    // Public bindings.
    cons.push(Constraint::terms(
        one,
        false,
        vec![(layout.pc0, F::ONE), (tr(l.pc_before, 0), -F::ONE)],
    ));
    cons.push(Constraint::terms(
        one,
        false,
        vec![(layout.pc_final, F::ONE), (tr(l.pc_after, t - 1), -F::ONE)],
    ));
    cons.push(Constraint::terms(
        one,
        false,
        vec![(layout.halted_in, F::ONE), (tr(l.halted, 0), -F::ONE)],
    ));
    cons.push(Constraint::terms(
        one,
        false,
        vec![(layout.halted_out, F::ONE), (tr(l.halted, t - 1), -F::ONE)],
    ));
    // Execution anchor: the first trace row must be active.
    cons.push(Constraint::terms(
        one,
        false,
        vec![(tr(l.active, 0), F::ONE), (one, -F::ONE)],
    ));

    for i in 0..t {
        let _halted = tr(l.halted, i);
        let active = tr(l.active, i);
        let is_virtual = tr(l.is_virtual, i);
        let virtual_transition = tr(l.virtual_transition, i);
        let virtual_commit_link = tr(l.virtual_commit_link, i);
        let rd_has_write = tr(l.rd_has_write, i);
        let shout_has_lookup = tr(l.shout_has_lookup, i);

        // Canonical AIR-style one-column.
        cons.push(Constraint::terms(
            one,
            false,
            vec![(tr(l.one, i), F::ONE), (one, -F::ONE)],
        ));

        // Booleanity for trace control columns.
        cons.push(Constraint::terms(
            is_virtual,
            false,
            vec![(is_virtual, F::ONE), (one, -F::ONE)],
        ));
        cons.push(Constraint::terms(
            virtual_transition,
            false,
            vec![(virtual_transition, F::ONE), (one, -F::ONE)],
        ));
        cons.push(Constraint::terms(
            virtual_commit_link,
            false,
            vec![(virtual_commit_link, F::ONE), (one, -F::ONE)],
        ));
        cons.push(Constraint::terms(
            rd_has_write,
            false,
            vec![(rd_has_write, F::ONE), (one, -F::ONE)],
        ));
        cons.push(Constraint::terms(
            shout_has_lookup,
            false,
            vec![(shout_has_lookup, F::ONE), (one, -F::ONE)],
        ));
        // Non-virtual rows must have zero virtual sequence metadata.
        cons.push(Constraint::terms(
            is_virtual,
            true,
            vec![(tr(l.virtual_sequence_remaining, i), F::ONE)],
        ));
        // Virtual rows do not advance architectural PC.
        cons.push(Constraint::terms(
            is_virtual,
            false,
            vec![(tr(l.pc_after, i), F::ONE), (tr(l.pc_before, i), -F::ONE)],
        ));
        // Virtual rows cannot claim halted.
        cons.push(Constraint::terms(is_virtual, false, vec![(tr(l.halted, i), F::ONE)]));
        // Inactive rows must carry zero virtual metadata.
        cons.push(Constraint::terms(active, true, vec![(is_virtual, F::ONE)]));
        cons.push(Constraint::terms(active, true, vec![(virtual_transition, F::ONE)]));
        cons.push(Constraint::terms(active, true, vec![(virtual_commit_link, F::ONE)]));
        cons.push(Constraint::terms(
            active,
            true,
            vec![(tr(l.virtual_sequence_remaining, i), F::ONE)],
        ));
        cons.push(Constraint::terms(active, true, vec![(rd_has_write, F::ONE)]));
        cons.push(Constraint::terms(active, true, vec![(shout_has_lookup, F::ONE)]));
        // REG write lane must stay quiescent when no write is declared.
        cons.push(Constraint::terms(rd_has_write, true, vec![(tr(l.rd_addr, i), F::ONE)]));
        cons.push(Constraint::terms(rd_has_write, true, vec![(tr(l.rd_val, i), F::ONE)]));

        // Shout padding: (1 - has_lookup) * val == 0.
        cons.push(Constraint::terms(
            shout_has_lookup,
            true,
            vec![(tr(l.shout_table_id, i), F::ONE)],
        ));
        cons.push(Constraint::terms(
            shout_has_lookup,
            true,
            vec![(tr(l.shout_val, i), F::ONE)],
        ));
        cons.push(Constraint::terms(
            shout_has_lookup,
            true,
            vec![(tr(l.shout_lhs, i), F::ONE)],
        ));
        cons.push(Constraint::terms(
            shout_has_lookup,
            true,
            vec![(tr(l.shout_rhs, i), F::ONE)],
        ));
        cons.push(Constraint::terms(
            shout_has_lookup,
            true,
            vec![(tr(l.shout_link_lhs, i), F::ONE)],
        ));
        cons.push(Constraint::terms(
            shout_has_lookup,
            true,
            vec![(tr(l.shout_link_rhs, i), F::ONE)],
        ));
        cons.push(Constraint::terms(
            shout_has_lookup,
            true,
            vec![(tr(l.shout_add_sub_key, i), F::ONE)],
        ));
    }

    for i in 0..t.saturating_sub(1) {
        // pc_after[i] == pc_before[i+1]
        cons.push(Constraint::terms(
            one,
            false,
            vec![(tr(l.pc_after, i), F::ONE), (tr(l.pc_before, i + 1), -F::ONE)],
        ));
        // Virtual rows must stay inside the active architectural sequence.
        cons.push(Constraint::terms(
            tr(l.is_virtual, i),
            false,
            vec![(tr(l.active, i + 1), F::ONE), (one, -F::ONE)],
        ));
        // Decomposition micro-rows must stay attached to the same instruction word.
        cons.push(Constraint::terms(
            tr(l.is_virtual, i),
            false,
            vec![(tr(l.instr_word, i + 1), F::ONE), (tr(l.instr_word, i), -F::ONE)],
        ));

        // Virtual sequence metadata must countdown by exactly one row-to-row.
        // With the row-wise invariant `(1 - is_virtual) * remaining = 0`,
        // this also forces the last virtual row before commit to have remaining=1.
        cons.push(Constraint::terms(
            tr(l.is_virtual, i),
            false,
            vec![
                (tr(l.virtual_sequence_remaining, i), F::ONE),
                (tr(l.virtual_sequence_remaining, i + 1), -F::ONE),
                (one, -F::ONE),
            ],
        ));
        // virtual_transition[i] == is_virtual[i] * active[i+1] * (1 - is_virtual[i+1])
        cons.push(Constraint::terms(
            tr(l.is_virtual, i),
            false,
            vec![
                (tr(l.active, i + 1), F::ONE),
                (tr(l.is_virtual, i + 1), -F::ONE),
                (tr(l.virtual_transition, i), -F::ONE),
            ],
        ));
        cons.push(Constraint::terms(
            tr(l.is_virtual, i),
            true,
            vec![(tr(l.virtual_transition, i), F::ONE)],
        ));
        // Virtual transition rows must carry a final virtual write for commit linkage.
        cons.push(Constraint::terms(
            tr(l.virtual_transition, i),
            false,
            vec![(tr(l.rd_has_write, i), F::ONE), (one, -F::ONE)],
        ));
        // virtual_commit_link[i] == virtual_transition[i] * rd_has_write[i+1]
        cons.push(Constraint::terms(
            tr(l.virtual_transition, i),
            false,
            vec![
                (tr(l.virtual_commit_link, i), F::ONE),
                (tr(l.rd_has_write, i + 1), -F::ONE),
            ],
        ));
        cons.push(Constraint::terms(
            tr(l.virtual_transition, i),
            true,
            vec![(tr(l.virtual_commit_link, i), F::ONE)],
        ));
        // If virtual_commit_link is set, the next row must carry a write.
        cons.push(Constraint::terms(
            tr(l.virtual_commit_link, i),
            false,
            vec![(one, F::ONE), (tr(l.rd_has_write, i + 1), -F::ONE)],
        ));
        // Constrained virtual commit: last virtual write value must equal next-row write value.
        cons.push(Constraint::terms(
            tr(l.virtual_commit_link, i),
            false,
            vec![(tr(l.rd_val, i + 1), F::ONE), (tr(l.rd_val, i), -F::ONE)],
        ));

        // cycle[i+1] == cycle[i] + 1
        cons.push(Constraint::terms(
            one,
            false,
            vec![(tr(l.cycle, i + 1), F::ONE), (tr(l.cycle, i), -F::ONE), (one, -F::ONE)],
        ));

        // Once inactive, remain inactive: active[i+1] * (1 - active[i]) == 0
        cons.push(Constraint::terms(
            tr(l.active, i + 1),
            false,
            vec![(one, F::ONE), (tr(l.active, i), -F::ONE)],
        ));

        // Once halted, remain halted: halted[i] * (1 - halted[i+1]) == 0
        cons.push(Constraint::terms(
            tr(l.halted, i),
            false,
            vec![(one, F::ONE), (tr(l.halted, i + 1), -F::ONE)],
        ));

        // Halted tail quiescence:
        // once halted, the next row must be inactive and keep the same pc_after.
        cons.push(Constraint::terms(
            tr(l.halted, i),
            false,
            vec![(tr(l.active, i + 1), F::ONE)],
        ));
        cons.push(Constraint::terms(
            tr(l.halted, i),
            false,
            vec![(tr(l.pc_after, i), F::ONE), (tr(l.pc_after, i + 1), -F::ONE)],
        ));
    }

    if t > 0 {
        let i = t - 1;
        cons.push(Constraint::terms(
            one,
            false,
            vec![(tr(l.virtual_transition, i), F::ONE)],
        ));
        cons.push(Constraint::terms(
            one,
            false,
            vec![(tr(l.virtual_commit_link, i), F::ONE)],
        ));
    }

    let n = cons
        .len()
        .checked_add(reserved_rows)
        .ok_or_else(|| "RV32 trace CCS: n overflow".to_string())?;
    build_r1cs_ccs(&cons, n, layout.m, layout.const_one)
}

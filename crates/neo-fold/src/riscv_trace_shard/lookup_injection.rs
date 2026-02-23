use super::*;
use neo_memory::plain::LutTable;
use neo_memory::riscv::trace::{
    rv32_decode_lookup_backed_row_from_instr_word, rv32_decode_lookup_table_id_for_col, Rv32DecodeSidecarLayout,
};
use p3_field::{PrimeCharacteristicRing, PrimeField64};

pub(super) fn infer_required_trace_shout_opcodes(program: &[RiscvInstruction]) -> HashSet<RiscvOpcode> {
    let mut ops = HashSet::new();
    // Required for shared wiring (address/PC arithmetic).
    ops.insert(RiscvOpcode::Add);
    for instr in program {
        match instr {
            RiscvInstruction::RAlu { op, .. } => {
                ops.insert(*op);
            }
            RiscvInstruction::IAlu { op, .. } => {
                ops.insert(*op);
            }
            RiscvInstruction::Branch { cond, .. } => {
                ops.insert(cond.to_shout_opcode());
            }
            // Address arithmetic in these classes uses ADD shout semantics.
            RiscvInstruction::Load { .. }
            | RiscvInstruction::Store { .. }
            | RiscvInstruction::Jalr { .. }
            | RiscvInstruction::Auipc { .. } => {
                ops.insert(RiscvOpcode::Add);
            }
            _ => {}
        }
    }
    ops
}

pub(super) fn program_requires_ram_sidecar(program: &[RiscvInstruction]) -> bool {
    program.iter().any(|instr| {
        matches!(
            instr,
            RiscvInstruction::Load { .. }
                | RiscvInstruction::Store { .. }
                | RiscvInstruction::LoadReserved { .. }
                | RiscvInstruction::StoreConditional { .. }
                | RiscvInstruction::Amo { .. }
        )
    })
}

pub(super) fn rv32_trace_table_specs(
    shout_ops: &HashSet<RiscvOpcode>,
) -> Result<HashMap<u32, LutTableSpec>, PiCcsError> {
    let shout = RiscvShoutTables::new(32);
    let mut table_specs = HashMap::new();
    for &op in shout_ops {
        let table_id = shout.opcode_to_id(op).0;
        if rv32_packed_rollout_opcode(op) {
            table_specs.insert(table_id, LutTableSpec::RiscvOpcodePacked { opcode: op, xlen: 32 });
        } else {
            table_specs.insert(table_id, LutTableSpec::RiscvOpcode { opcode: op, xlen: 32 });
        }
    }
    Ok(table_specs)
}

pub(super) fn decode_selector_specs_for_prog_layout(
    prog_layout: &PlainMemLayout,
) -> Result<Vec<TraceShoutBusSpec>, PiCcsError> {
    if prog_layout.n_side == 0 || !prog_layout.n_side.is_power_of_two() {
        return Err(PiCcsError::InvalidInput(format!(
            "decode selector lookup requires power-of-two n_side (got {})",
            prog_layout.n_side
        )));
    }
    let ell = prog_layout.n_side.trailing_zeros() as usize;
    let ell_addr = prog_layout
        .d
        .checked_mul(ell)
        .ok_or_else(|| PiCcsError::InvalidInput("decode selector ell_addr overflow".into()))?;
    let decode = Rv32DecodeSidecarLayout::new();
    let selector_cols = [decode.rd_has_write, decode.ram_has_read, decode.ram_has_write];
    Ok(selector_cols
        .iter()
        .map(|&col| TraceShoutBusSpec {
            table_id: rv32_decode_lookup_table_id_for_col(col),
            ell_addr,
            n_vals: 1usize,
        })
        .collect())
}

pub(super) fn build_rv32_decode_selector_lookup_tables(
    prog_layout: &PlainMemLayout,
    prog_init_words: &HashMap<(u32, u64), F>,
) -> HashMap<u32, LutTable<F>> {
    let decode = Rv32DecodeSidecarLayout::new();
    let selector_cols = [decode.rd_has_write, decode.ram_has_read, decode.ram_has_write];
    let mut tables = HashMap::new();

    for &col_id in &selector_cols {
        let table_id = rv32_decode_lookup_table_id_for_col(col_id);
        let mut content = vec![F::ZERO; prog_layout.k];
        for addr in 0..prog_layout.k {
            let instr_word = prog_init_words
                .get(&(PROG_ID.0, addr as u64))
                .copied()
                .unwrap_or(F::ZERO)
                .as_canonical_u64() as u32;
            let row = rv32_decode_lookup_backed_row_from_instr_word(&decode, instr_word, true);
            content[addr] = row[col_id];
        }
        tables.insert(
            table_id,
            LutTable {
                table_id,
                k: prog_layout.k,
                d: prog_layout.d,
                n_side: prog_layout.n_side,
                content,
            },
        );
    }

    tables
}

pub(super) fn inject_rv32_decode_selector_lookup_events_into_trace(
    trace: &mut neo_vm_trace::VmTrace<u64, u64>,
    prog_layout: &PlainMemLayout,
    prog_init_words: &HashMap<(u32, u64), F>,
) -> Result<(), PiCcsError> {
    let decode = Rv32DecodeSidecarLayout::new();
    let selector_cols = [decode.rd_has_write, decode.ram_has_read, decode.ram_has_write];

    for (step_idx, step) in trace.steps.iter_mut().enumerate() {
        let prog_read = step
            .twist_events
            .iter()
            .find(|ev| ev.twist_id == PROG_ID && ev.kind == TwistOpKind::Read)
            .ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "missing PROG read event while injecting decode-selector lookup events at step {step_idx}"
                ))
            })?;
        let addr = prog_read.addr;
        if (addr as usize) >= prog_layout.k {
            return Err(PiCcsError::ProtocolError(format!(
                "decode-selector lookup addr out of range at step {step_idx}: addr={addr}, k={}",
                prog_layout.k
            )));
        }
        let instr_word = prog_init_words
            .get(&(PROG_ID.0, addr))
            .copied()
            .unwrap_or_else(|| F::from_u64(prog_read.value))
            .as_canonical_u64() as u32;
        let row = rv32_decode_lookup_backed_row_from_instr_word(&decode, instr_word, true);
        for &col_id in &selector_cols {
            step.shout_events.push(neo_vm_trace::ShoutEvent {
                shout_id: neo_vm_trace::ShoutId(rv32_decode_lookup_table_id_for_col(col_id)),
                key: addr,
                value: row[col_id].as_canonical_u64(),
            });
        }
    }

    Ok(())
}

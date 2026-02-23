use super::*;
pub(super) fn max_ram_addr_from_exec(exec: &Rv32ExecTable) -> Option<u64> {
    exec.rows
        .iter()
        .filter(|r| r.active)
        .flat_map(|r| r.ram_events.iter().map(|e| e.addr))
        .max()
}

pub(super) fn required_bits_for_max_addr(max_addr: u64) -> usize {
    if max_addr == 0 {
        1
    } else {
        (u64::BITS - max_addr.leading_zeros()) as usize
    }
}

pub(super) fn final_reg_state_dense(exec: &Rv32ExecTable, reg_init: &HashMap<u64, u64>) -> Result<Vec<F>, PiCcsError> {
    let mut regs = [0u64; 32];
    for (&reg, &value) in reg_init {
        if reg >= 32 {
            return Err(PiCcsError::InvalidInput(format!(
                "reg_init_u32: register index out of range: reg={reg} (expected 0..32)"
            )));
        }
        if reg == 0 && value != 0 {
            return Err(PiCcsError::InvalidInput(
                "reg_init_u32: x0 must be 0 (non-zero init is forbidden)".into(),
            ));
        }
        regs[reg as usize] = value as u32 as u64;
    }
    regs[0] = 0;

    for r in exec.rows.iter().filter(|r| r.active) {
        if let Some(w) = &r.reg_write_lane0 {
            if w.addr >= 32 {
                return Err(PiCcsError::InvalidInput(format!(
                    "trace register write addr out of range at cycle {}: addr={}",
                    r.cycle, w.addr
                )));
            }
            if w.addr == 0 {
                return Err(PiCcsError::InvalidInput(format!(
                    "trace writes x0 at cycle {} which is invalid",
                    r.cycle
                )));
            }
            regs[w.addr as usize] = w.value as u32 as u64;
            regs[0] = 0;
        }
    }

    Ok(regs.iter().map(|&v| F::from_u64(v)).collect())
}

pub(super) fn final_ram_state_dense(
    exec: &Rv32ExecTable,
    ram_init: &HashMap<u64, u64>,
    k: usize,
) -> Result<Vec<F>, PiCcsError> {
    let mut out = vec![F::ZERO; k];
    for (&addr, &value) in ram_init {
        let addr_usize = usize::try_from(addr)
            .map_err(|_| PiCcsError::InvalidInput(format!("ram_init_u32: addr does not fit usize: addr={addr}")))?;
        if addr_usize >= k {
            return Err(PiCcsError::InvalidInput(format!(
                "ram_init_u32: addr out of range for output binding domain: addr={addr} >= k={k}"
            )));
        }
        out[addr_usize] = F::from_u64(value as u32 as u64);
    }

    for r in exec.rows.iter().filter(|r| r.active) {
        for e in &r.ram_events {
            if e.kind != TwistOpKind::Write {
                continue;
            }
            let addr_usize = usize::try_from(e.addr).map_err(|_| {
                PiCcsError::InvalidInput(format!(
                    "trace RAM write addr does not fit usize at cycle {}: addr={}",
                    r.cycle, e.addr
                ))
            })?;
            if addr_usize >= k {
                return Err(PiCcsError::InvalidInput(format!(
                    "trace RAM write addr out of range for output binding domain at cycle {}: addr={} >= k={k}",
                    r.cycle, e.addr
                )));
            }
            out[addr_usize] = F::from_u64(e.value as u32 as u64);
        }
    }

    Ok(out)
}

pub(super) fn split_exec_into_fixed_chunks(
    exec: &Rv32ExecTable,
    chunk_rows: usize,
) -> Result<Vec<Rv32ExecTable>, PiCcsError> {
    if chunk_rows == 0 {
        return Err(PiCcsError::InvalidInput("trace chunk_rows must be non-zero".into()));
    }
    if !chunk_rows.is_power_of_two() {
        return Err(PiCcsError::InvalidInput(format!(
            "trace chunk_rows must be a power of two (got {chunk_rows})"
        )));
    }
    if exec.rows.is_empty() {
        return Err(PiCcsError::InvalidInput("trace execution table is empty".into()));
    }

    let mut out = Vec::<Rv32ExecTable>::new();
    let total = exec.rows.len();
    let mut start = 0usize;
    while start < total {
        let end = (start + chunk_rows).min(total);
        let mut rows = exec.rows[start..end].to_vec();
        if rows.len() < chunk_rows {
            let last = rows
                .last()
                .ok_or_else(|| PiCcsError::InvalidInput("trace chunk unexpectedly empty".into()))?
                .clone();
            let mut cycle = last.cycle;
            let pad_pc = last.pc_after;
            let pad_halted = last.halted;
            while rows.len() < chunk_rows {
                cycle = cycle
                    .checked_add(1)
                    .ok_or_else(|| PiCcsError::InvalidInput("cycle overflow while chunk-padding trace".into()))?;
                rows.push(neo_memory::riscv::exec_table::Rv32ExecRow::inactive(
                    cycle, pad_pc, pad_halted,
                ));
            }
        }
        out.push(Rv32ExecTable { rows });
        start = end;
    }

    Ok(out)
}

pub(super) fn rv32_trace_chunk_to_boundary_witness(
    layout: Rv32TraceCcsLayout,
) -> Box<dyn Fn(&[StepTrace<u64, u64>]) -> Vec<F> + Send + Sync> {
    Box::new(move |chunk: &[StepTrace<u64, u64>]| {
        rv32_trace_chunk_to_boundary_witness_checked(&layout, chunk).unwrap_or_else(|e| {
            panic!(
                "rv32_trace_chunk_to_boundary_witness failed for chunk_len={}: {e}",
                chunk.len()
            )
        })
    })
}

fn rv32_trace_chunk_rows_padded(
    layout: &Rv32TraceCcsLayout,
    chunk: &[StepTrace<u64, u64>],
) -> Result<Vec<Rv32ExecRow>, String> {
    if chunk.is_empty() {
        return Err("trace chunk witness: chunk must contain at least one step".into());
    }
    if chunk.len() > layout.t {
        return Err(format!(
            "trace chunk witness: chunk.len()={} exceeds layout.t={}",
            chunk.len(),
            layout.t
        ));
    }

    let mut rows = Vec::with_capacity(layout.t);
    for step in chunk {
        rows.push(Rv32ExecRow::from_step(step)?);
    }

    let mut cycle = rows
        .last()
        .ok_or_else(|| "trace chunk witness: empty rows after conversion".to_string())?
        .cycle;
    let pad_pc = rows.last().expect("rows non-empty").pc_after;
    let pad_halted = rows.last().expect("rows non-empty").halted;
    while rows.len() < layout.t {
        cycle = cycle
            .checked_add(1)
            .ok_or_else(|| "trace chunk witness: cycle overflow while padding".to_string())?;
        rows.push(Rv32ExecRow::inactive(cycle, pad_pc, pad_halted));
    }

    Ok(rows)
}

pub(super) fn rv32_trace_chunk_to_boundary_witness_checked(
    layout: &Rv32TraceCcsLayout,
    chunk: &[StepTrace<u64, u64>],
) -> Result<Vec<F>, String> {
    let rows = rv32_trace_chunk_rows_padded(layout, chunk)?;
    let exec = Rv32ExecTable { rows };
    let wit = neo_memory::riscv::trace::Rv32TraceWitness::from_exec_table(&layout.trace, &exec)?;

    let mut x = vec![F::ZERO; layout.m_in];
    x[layout.const_one] = F::ONE;
    x[layout.pc0] = wit.cols[layout.trace.pc_before][0];
    x[layout.pc_final] = wit.cols[layout.trace.pc_after][layout.t - 1];
    x[layout.halted_in] = wit.cols[layout.trace.halted][0];
    x[layout.halted_out] = wit.cols[layout.trace.halted][layout.t - 1];
    Ok(x)
}

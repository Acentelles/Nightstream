use super::*;

pub(crate) fn build_event_table_shout_context(
    params: &NeoParams,
    step: &StepWitnessBundle<Cmt, F, K>,
    ell_n: usize,
    r_cycle: &[K],
) -> Result<(K, K, K, Option<RouteAShoutEventTraceHashOracle>), PiCcsError> {
    let any_event_table_shout = step
        .lut_instances
        .iter()
        .any(|(inst, _wit)| matches!(inst.table_spec, Some(LutTableSpec::RiscvOpcodeEventTablePacked { .. })));
    if any_event_table_shout {
        for (idx, (inst, _wit)) in step.lut_instances.iter().enumerate() {
            if !matches!(inst.table_spec, Some(LutTableSpec::RiscvOpcodeEventTablePacked { .. })) {
                return Err(PiCcsError::InvalidInput(format!(
                    "event-table Shout mode requires all Shout instances to use RiscvOpcodeEventTablePacked (lut_idx={idx})"
                )));
            }
        }
    }

    let (event_alpha, event_beta, event_gamma) = if any_event_table_shout {
        if r_cycle.len() < 3 {
            return Err(PiCcsError::InvalidInput("event-table Shout requires ell_n >= 3".into()));
        }
        (r_cycle[0], r_cycle[1], r_cycle[2])
    } else {
        (K::ZERO, K::ZERO, K::ZERO)
    };

    let shout_event_trace_hash: Option<RouteAShoutEventTraceHashOracle> = if any_event_table_shout {
        let m_in = step.mcs.0.m_in;
        if m_in != 5 {
            return Err(PiCcsError::InvalidInput(format!(
                "event-table Shout trace linkage expects m_in=5 (got {m_in})"
            )));
        }
        let trace = Rv32TraceLayout::new();
        let trace_source = TraceColumnSourceWitness::from_step(step, &trace, "event-table Shout trace linkage")?;
        let t_len = trace_source.t_len();
        if t_len == 0 {
            return Err(PiCcsError::InvalidInput(
                "event-table Shout trace linkage requires t_len >= 1".into(),
            ));
        }
        let pow2_cycle = 1usize
            .checked_shl(ell_n as u32)
            .ok_or_else(|| PiCcsError::InvalidInput("event-table Shout: 2^ell_n overflow".into()))?;
        if m_in
            .checked_add(t_len)
            .ok_or_else(|| PiCcsError::InvalidInput("event-table Shout: m_in + t_len overflow".into()))?
            > pow2_cycle
        {
            return Err(PiCcsError::InvalidInput(format!(
                "event-table Shout: trace time rows out of range: m_in({m_in}) + t_len({t_len}) > 2^ell_n({pow2_cycle})"
            )));
        }
        let shout_cols = [
            trace.shout_has_lookup,
            trace.shout_val,
            trace.shout_lhs,
            trace.shout_rhs,
        ];
        let decoded = trace_source.decode_cols(params, &shout_cols, "event-table Shout trace linkage")?;
        let gate_vals = decoded.get(&trace.shout_has_lookup).ok_or_else(|| {
            PiCcsError::ProtocolError("event-table Shout: missing shout_has_lookup trace column".into())
        })?;
        let val_vals = decoded
            .get(&trace.shout_val)
            .ok_or_else(|| PiCcsError::ProtocolError("event-table Shout: missing shout_val trace column".into()))?;
        let lhs_vals = decoded
            .get(&trace.shout_lhs)
            .ok_or_else(|| PiCcsError::ProtocolError("event-table Shout: missing shout_lhs trace column".into()))?;
        let rhs_vals = decoded
            .get(&trace.shout_rhs)
            .ok_or_else(|| PiCcsError::ProtocolError("event-table Shout: missing shout_rhs trace column".into()))?;
        if gate_vals.len() != t_len || val_vals.len() != t_len || lhs_vals.len() != t_len || rhs_vals.len() != t_len {
            return Err(PiCcsError::ProtocolError(format!(
                "event-table Shout: trace column length mismatch (gate={}, val={}, lhs={}, rhs={}, expected t_len={t_len})",
                gate_vals.len(),
                val_vals.len(),
                lhs_vals.len(),
                rhs_vals.len()
            )));
        }

        let mut gate_entries: Vec<(usize, K)> = Vec::new();
        let mut hash_entries: Vec<(usize, K)> = Vec::new();
        for j in 0..t_len {
            let t = m_in + j;
            let gate = gate_vals[j];
            if gate == K::ZERO {
                continue;
            }
            gate_entries.push((t, gate));

            let val = val_vals[j];
            let lhs = lhs_vals[j];
            let rhs = rhs_vals[j];
            let hash = K::ONE + event_alpha * val + event_beta * lhs + event_gamma * rhs;
            if hash != K::ZERO {
                hash_entries.push((t, hash));
            }
        }

        let gate = SparseIdxVec::from_entries(pow2_cycle, gate_entries);
        let hash = SparseIdxVec::from_entries(pow2_cycle, hash_entries);
        let (oracle, claim) = ShoutValueOracleSparse::new(r_cycle, gate, hash);
        Some(RouteAShoutEventTraceHashOracle {
            oracle: Box::new(oracle),
            claim,
        })
    } else {
        None
    };

    Ok((event_alpha, event_beta, event_gamma, shout_event_trace_hash))
}

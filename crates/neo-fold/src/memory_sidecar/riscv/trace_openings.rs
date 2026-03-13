use super::*;

#[inline]
pub(crate) fn trace_opening_path_required_for_step_instance(step: &StepInstanceBundle<Cmt, F, K>) -> bool {
    trace_uses_rv64_exact_words(step.time_columns.cpu_cols.len())
}

#[inline]
pub(crate) fn trace_opening_path_required_for_step_witness(step: &StepWitnessBundle<Cmt, F, K>) -> bool {
    trace_uses_rv64_exact_words(step.time_columns.cpu_cols.len())
}

pub(crate) fn build_bus_layout_for_step_witness(
    step: &StepWitnessBundle<Cmt, F, K>,
    t_len: usize,
) -> Result<BusLayout, PiCcsError> {
    let m_in = step.mcs.0.m_in;
    if step.time_columns.t != t_len || step.time_columns.cpu_cols.is_empty() {
        return Err(PiCcsError::InvalidInput(format!(
            "step bus layout requires canonical time columns (time_t={}, cpu_cols={}, expected_t={t_len})",
            step.time_columns.t,
            step.time_columns.cpu_cols.len()
        )));
    }
    let cpu_region_len = step
        .time_columns
        .cpu_cols
        .len()
        .checked_mul(t_len)
        .ok_or_else(|| PiCcsError::InvalidInput("step bus layout: cpu_cols*t_len overflow".into()))?;
    let bus_region_len = step
        .time_columns
        .mem_cols
        .len()
        .checked_mul(t_len)
        .ok_or_else(|| PiCcsError::InvalidInput("step bus layout: mem_cols*t_len overflow".into()))?;
    let m = m_in
        .checked_add(cpu_region_len)
        .and_then(|v| v.checked_add(bus_region_len))
        .ok_or_else(|| PiCcsError::InvalidInput("step bus layout: virtual m overflow".into()))?;
    let shout_shapes: Vec<ShoutInstanceShape> = step
        .lut_instances
        .iter()
        .map(|(inst, _)| ShoutInstanceShape {
            ell_addr: inst.d * inst.ell,
            lanes: inst.lanes.max(1),
            n_vals: neo_memory::riscv::trace::riscv_trace_lookup_n_vals_for_table_id(inst.table_id),
            addr_group: inst.addr_group,
            selector_group: inst.selector_group,
        })
        .collect();
    let grouped_shout_instances = shout_shapes
        .iter()
        .filter(|shape| shape.addr_group.is_some())
        .count();
    let twist = step
        .mem_instances
        .iter()
        .map(|(inst, _)| (inst.d * inst.ell, inst.lanes.max(1)));
    let layout =
        build_bus_layout_for_instances_with_shout_shapes_and_twist_lanes(m, m_in, t_len, shout_shapes, twist).map_err(
            |e| {
                PiCcsError::InvalidInput(format!(
                    "step bus layout failed: m={m}, m_in={m_in}, t_len={t_len}, lut_insts={}, grouped_lut_insts={grouped_shout_instances}: {e}",
                    step.lut_instances.len()
                ))
            },
        )?;
    if layout.bus_cols != step.time_columns.mem_cols.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "step bus layout mismatch: layout.bus_cols={} != time_columns.mem_cols.len()={}",
            layout.bus_cols,
            step.time_columns.mem_cols.len()
        )));
    }
    Ok(layout)
}

pub(crate) fn build_route_a_trace_opening_time_claims(
    params: &NeoParams,
    step: &StepWitnessBundle<Cmt, F, K>,
    r_cycle: &[K],
) -> Result<
    (
        Option<(Box<dyn RoundOracle + Send>, K)>,
        Option<(Box<dyn RoundOracle + Send>, K)>,
    ),
    PiCcsError,
> {
    if !trace_opening_path_required_for_step_witness(step) {
        return Ok((None, None));
    }

    let trace = neo_memory::riscv::trace::Rv64TraceLayout::new();
    let t_len = step.time_columns.t;
    let m_in = step.mcs.0.m_in;
    let ell_n = r_cycle.len();
    let booleanity_cols = rv64_trace_booleanity_columns(&trace);
    let trace_opening_cols = rv64_trace_quiescence_columns(&trace);

    let mut decode_cols = Vec::with_capacity(1 + booleanity_cols.len() + trace_opening_cols.len());
    decode_cols.push(trace.active);
    decode_cols.extend(booleanity_cols.iter().copied());
    decode_cols.extend(trace_opening_cols.iter().copied());
    let decoded = decode_trace_col_values_batch(params, step, t_len, &decode_cols)?;

    let booleanity_weights = booleanity_weight_vector(r_cycle, booleanity_cols.len());
    let mut booleanity_sparse_cols: Vec<SparseIdxVec<K>> = Vec::with_capacity(booleanity_cols.len());
    for &col_id in &booleanity_cols {
        let vals = decoded
            .get(&col_id)
            .ok_or_else(|| PiCcsError::ProtocolError(format!("booleanity: missing decoded bool column {col_id}")))?;
        booleanity_sparse_cols.push(sparse_trace_col_from_values(m_in, ell_n, vals)?);
    }
    let booleanity_oracle =
        LazyWeightedBitnessOracleSparseTime::new_with_cycle(r_cycle, booleanity_sparse_cols, booleanity_weights);

    let weights = trace_opening_weight_vector(r_cycle, trace_opening_cols.len());
    let active_vals = decoded
        .get(&trace.active)
        .ok_or_else(|| PiCcsError::ProtocolError("trace-opening: missing decoded active column".into()))?;
    let active = sparse_trace_col_from_values(m_in, ell_n, active_vals)?;

    let mut sparse_cols: Vec<SparseIdxVec<K>> = Vec::with_capacity(trace_opening_cols.len());
    for &col_id in &trace_opening_cols {
        let vals = decoded
            .get(&col_id)
            .ok_or_else(|| PiCcsError::ProtocolError(format!("trace-opening: missing decoded column {col_id}")))?;
        sparse_cols.push(sparse_trace_col_from_values(m_in, ell_n, vals)?);
    }
    let oracle = WeightedMaskOracleSparseTime::new(active, sparse_cols, weights, r_cycle);

    Ok((
        Some((Box::new(booleanity_oracle), K::ZERO)),
        Some((Box::new(oracle), K::ZERO)),
    ))
}

pub(crate) fn emit_route_a_trace_opening_me_claims(
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    s: &CcsStructure<F>,
    step: &StepWitnessBundle<Cmt, F, K>,
    r_time: &[K],
) -> Result<(Vec<CeClaim<Cmt, F, K>>, Vec<CeClaim<Cmt, F, K>>), PiCcsError> {
    if !trace_opening_path_required_for_step_witness(step) {
        return Ok((Vec::new(), Vec::new()));
    }

    let trace = neo_memory::riscv::trace::Rv64TraceLayout::new();
    let t_len = step.time_columns.t;
    let m_in = step.mcs.0.m_in;
    let core_t = s.t();
    let (mcs_inst, mcs_wit) = &step.mcs;

    let booleanity_cols = rv64_trace_booleanity_columns(&trace);
    let mut booleanity_claims = ts::emit_me_claims_for_mats(
        tr,
        b"cpu/me_digest_wb_time",
        params,
        s,
        core::slice::from_ref(&mcs_inst.c),
        core::slice::from_ref(&mcs_wit.Z),
        r_time,
        m_in,
    )?;
    if booleanity_claims.len() != 1 {
        return Err(PiCcsError::ProtocolError(format!(
            "booleanity expects exactly one CPU ME claim at r_time, got {}",
            booleanity_claims.len()
        )));
    }

    let mut trace_opening_claims = booleanity_claims.clone();
    if trace_opening_claims.len() != 1 {
        return Err(PiCcsError::ProtocolError(format!(
            "trace-opening expects exactly one CPU ME claim at r_time, got {}",
            trace_opening_claims.len()
        )));
    }
    trace_opening_claims[0].fold_digest = {
        let mut fork = tr.fork(b"cpu/me_digest_wp_time");
        fork.digest32()
    };

    let booleanity_use_time_cols = step.time_columns.t == t_len
        && !step.time_columns.cpu_cols.is_empty()
        && booleanity_cols
            .iter()
            .all(|&col_id| col_id < step.time_columns.cpu_cols.len());
    if !booleanity_use_time_cols {
        return Err(PiCcsError::ProtocolError(format!(
            "booleanity(shared): canonical time CPU columns are required (time_t={}, cpu_cols={}, expected_t={t_len})",
            step.time_columns.t,
            step.time_columns.cpu_cols.len()
        )));
    }
    crate::memory_sidecar::cpu_bus::append_time_columns_openings_to_me_instance(
        params,
        m_in,
        t_len,
        &step.time_columns.cpu_cols,
        &booleanity_cols,
        core_t,
        &mut booleanity_claims[0],
    )?;

    let mut trace_opening_cols = rv64_trace_opening_columns(&trace);
    trace_opening_cols.extend(rv64_trace_exact_word_opening_columns());
    let trace_opening_use_time_cols = step.time_columns.t == t_len
        && !step.time_columns.cpu_cols.is_empty()
        && !step.time_columns.mem_cols.is_empty();
    if !trace_opening_use_time_cols {
        return Err(PiCcsError::ProtocolError(format!(
            "trace-opening(shared): canonical time CPU/MEM columns are required (time_t={}, cpu_cols={}, mem_cols={}, expected_t={t_len})",
            step.time_columns.t,
            step.time_columns.cpu_cols.len(),
            step.time_columns.mem_cols.len()
        )));
    }
    crate::memory_sidecar::cpu_bus::append_mixed_time_columns_openings_to_me_instance(
        params,
        m_in,
        t_len,
        &step.time_columns.cpu_cols,
        &step.time_columns.mem_cols,
        &step.time_columns.col_ids,
        &trace_opening_cols,
        core_t,
        &mut trace_opening_claims[0],
    )?;
    Ok((booleanity_claims, trace_opening_claims))
}

pub(crate) fn verify_route_a_trace_opening_terminals(
    step: &StepInstanceBundle<Cmt, F, K>,
    r_time: &[K],
    r_cycle: &[K],
    batched_final_values: &[K],
    claim_plan: &RouteATimeClaimPlan,
    mem_proof: &MemSidecarProof<Cmt, F, K>,
    step_time_openings: &[crate::shard_proof_types::TimePointOpening],
) -> Result<(), PiCcsError> {
    if step.mcs_inst.m_in != 5 {
        return Ok(());
    }

    let trace = neo_memory::riscv::trace::Rv64TraceLayout::new();
    let requires_trace_openings = claim_plan.booleanity_claim.is_some()
        || claim_plan.trace_opening_quiescence.is_some()
        || !mem_proof.booleanity_me_claims.is_empty()
        || !mem_proof.trace_opening_me_claims.is_empty();
    if !requires_trace_openings {
        return Ok(());
    }

    let cpu_cols_len = step.time_columns.cpu_cols.len();
    let mem_cols_len = step.time_columns.mem_cols.len();
    let expected_logical_cols = cpu_cols_len.saturating_add(mem_cols_len);
    let strict_committed_mode = step.mcs_inst.m_in == 5
        && step.time_columns.t > 0
        && cpu_cols_len > 0
        && step.time_columns.col_ids.len() == expected_logical_cols;
    if !strict_committed_mode {
        return Err(PiCcsError::ProtocolError(
            "booleanity/trace-opening terminals require canonical committed time-column mode".into(),
        ));
    }

    if let Some(claim_idx) = claim_plan.booleanity_claim {
        if claim_idx >= batched_final_values.len() {
            return Err(PiCcsError::ProtocolError("booleanity claim index out of range".into()));
        }
        if mem_proof.booleanity_me_claims.len() != 1 {
            return Err(PiCcsError::ProtocolError(format!(
                "booleanity expects exactly one ME claim at r_time (got {})",
                mem_proof.booleanity_me_claims.len()
            )));
        }
        let me = &mem_proof.booleanity_me_claims[0];
        if me.r.as_slice() != r_time {
            return Err(PiCcsError::ProtocolError(
                "booleanity ME claim r mismatch (expected r_time)".into(),
            ));
        }
        if me.c != step.mcs_inst.c {
            return Err(PiCcsError::ProtocolError(
                "booleanity ME claim commitment mismatch".into(),
            ));
        }
        if me.m_in != step.mcs_inst.m_in {
            return Err(PiCcsError::ProtocolError("booleanity ME claim m_in mismatch".into()));
        }

        let booleanity_cols = rv64_trace_booleanity_columns(&trace);
        let (booleanity_opening_entry, booleanity_opening_map) =
            require_time_openings_covering_point(step_time_openings, r_time, &booleanity_cols, "booleanity")?;
        if booleanity_opening_entry.source != crate::shard_proof_types::TimeOpeningSource::CommittedOpening {
            return Err(PiCcsError::ProtocolError(format!(
                "booleanity requires CommittedOpening source (got {:?})",
                booleanity_opening_entry.source
            )));
        }
        let booleanity_weights = booleanity_weight_vector(r_cycle, booleanity_cols.len());
        let mut booleanity_weighted_sum = K::ZERO;
        for (&col_id, &w) in booleanity_cols.iter().zip(booleanity_weights.iter()) {
            let b = named_opening(&booleanity_opening_map, col_id, "booleanity")?;
            booleanity_weighted_sum += w * b * (b - K::ONE);
        }
        let expected_terminal = eq_points(r_time, r_cycle) * booleanity_weighted_sum;
        if batched_final_values[claim_idx] != expected_terminal {
            return Err(PiCcsError::ProtocolError("booleanity terminal value mismatch".into()));
        }
    } else if !mem_proof.booleanity_me_claims.is_empty() {
        return Err(PiCcsError::ProtocolError(
            "unexpected booleanity ME claims: booleanity stage is not enabled".into(),
        ));
    }

    if let Some(claim_idx) = claim_plan.trace_opening_quiescence {
        if claim_idx >= batched_final_values.len() {
            return Err(PiCcsError::ProtocolError(
                "trace-opening/quiescence claim index out of range".into(),
            ));
        }
        if mem_proof.trace_opening_me_claims.len() != 1 {
            return Err(PiCcsError::ProtocolError(format!(
                "trace-opening expects exactly one ME claim at r_time (got {})",
                mem_proof.trace_opening_me_claims.len()
            )));
        }
        let me = &mem_proof.trace_opening_me_claims[0];
        if me.r.as_slice() != r_time {
            return Err(PiCcsError::ProtocolError(
                "trace-opening ME claim r mismatch (expected r_time)".into(),
            ));
        }
        if me.c != step.mcs_inst.c {
            return Err(PiCcsError::ProtocolError(
                "trace-opening ME claim commitment mismatch".into(),
            ));
        }
        if me.m_in != step.mcs_inst.m_in {
            return Err(PiCcsError::ProtocolError("trace-opening ME claim m_in mismatch".into()));
        }

        let mut trace_opening_cols = rv64_trace_opening_columns(&trace);
        trace_opening_cols.extend(rv64_trace_exact_word_opening_columns());
        let (trace_opening_entry, trace_opening_map) =
            require_time_openings_covering_point(step_time_openings, r_time, &trace_opening_cols, "trace-opening")?;
        if trace_opening_entry.source != crate::shard_proof_types::TimeOpeningSource::CommittedOpening {
            return Err(PiCcsError::ProtocolError(format!(
                "trace-opening requires CommittedOpening source (got {:?})",
                trace_opening_entry.source
            )));
        }
        let active_open = named_opening(&trace_opening_map, trace.active, "trace-opening")?;
        let trace_opening_cols_no_active = rv64_trace_quiescence_columns(&trace);
        let trace_opening_weights = trace_opening_weight_vector(r_cycle, trace_opening_cols_no_active.len());
        let mut trace_opening_weighted_sum = K::ZERO;
        for (&col_id, &w) in trace_opening_cols_no_active
            .iter()
            .zip(trace_opening_weights.iter())
        {
            let v = named_opening(&trace_opening_map, col_id, "trace-opening")?;
            trace_opening_weighted_sum += w * v;
        }
        let expected_terminal = eq_points(r_time, r_cycle) * (K::ONE - active_open) * trace_opening_weighted_sum;
        if batched_final_values[claim_idx] != expected_terminal {
            return Err(PiCcsError::ProtocolError(
                "trace-opening/quiescence terminal value mismatch".into(),
            ));
        }
    } else if !mem_proof.trace_opening_me_claims.is_empty() {
        return Err(PiCcsError::ProtocolError(
            "unexpected trace-opening ME claims: trace-opening/quiescence stage is not enabled".into(),
        ));
    }

    Ok(())
}

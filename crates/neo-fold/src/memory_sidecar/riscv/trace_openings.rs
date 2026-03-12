use super::*;

#[inline]
pub(crate) fn has_trace_lookup_families_instance(step: &StepInstanceBundle<Cmt, F, K>) -> bool {
    step.lut_insts.iter().any(|inst| {
        riscv_is_decode_lookup_table_id(inst.table_id) || riscv_trace_is_width_lookup_table_id(inst.table_id)
    })
}

#[inline]
pub(crate) fn has_trace_lookup_families_witness(step: &StepWitnessBundle<Cmt, F, K>) -> bool {
    step.lut_instances.iter().any(|(inst, _)| {
        riscv_is_decode_lookup_table_id(inst.table_id) || riscv_trace_is_width_lookup_table_id(inst.table_id)
    })
}

#[inline]
pub(crate) fn wb_wp_required_for_step_instance(step: &StepInstanceBundle<Cmt, F, K>) -> bool {
    has_trace_lookup_families_instance(step)
}

#[inline]
pub(crate) fn wb_wp_required_for_step_witness(step: &StepWitnessBundle<Cmt, F, K>) -> bool {
    has_trace_lookup_families_witness(step)
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

pub(crate) fn resolve_shared_decode_lookup_lut_indices(
    step: &StepWitnessBundle<Cmt, F, K>,
    decode_layout: &Rv32DecodeSidecarLayout,
) -> Result<(Vec<usize>, Vec<(usize, usize)>), PiCcsError> {
    let decode_open_cols = riscv_decode_lookup_transport_cols(decode_layout);
    let mut decode_lut_slots = Vec::with_capacity(decode_open_cols.len());
    for &col_id in decode_open_cols.iter() {
        let table_id = riscv_decode_lookup_table_id_for_col(col_id);
        let lut_idx = step
            .lut_instances
            .iter()
            .position(|(inst, _)| inst.table_id == table_id)
            .ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "W2(shared): missing decode lookup table_id={table_id} for col_id={col_id}"
                ))
            })?;
        let val_slot = riscv_decode_lookup_val_slot_for_col(col_id).ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "W2(shared): decode col_id={col_id} is not part of decode lookup transport slot map"
            ))
        })?;
        decode_lut_slots.push((lut_idx, val_slot));
    }

    Ok((decode_open_cols, decode_lut_slots))
}

pub(crate) fn resolve_shared_width_lookup_lut_indices(
    step: &StepWitnessBundle<Cmt, F, K>,
    width_layout: &Rv32WidthSidecarLayout,
) -> Result<(Vec<usize>, Vec<(usize, usize)>), PiCcsError> {
    let width_open_cols = riscv_trace_shared_width_lookup_backed_cols(width_layout);
    let mut width_lut_slots = Vec::with_capacity(width_open_cols.len());
    for &col_id in width_open_cols.iter() {
        let table_id = riscv_trace_shared_width_lookup_table_id_for_col(col_id);
        let lut_idx = step
            .lut_instances
            .iter()
            .position(|(inst, _)| inst.table_id == table_id)
            .ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "W3(shared): missing width lookup table_id={table_id} for col_id={col_id}"
                ))
            })?;
        let val_slot = riscv_trace_shared_width_lookup_val_slot_for_col(col_id).ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "W3(shared): width col_id={col_id} is not part of width lookup transport slot map"
            ))
        })?;
        width_lut_slots.push((lut_idx, val_slot));
    }

    Ok((width_open_cols, width_lut_slots))
}

#[inline]
pub(crate) fn decode_stage_required_for_step_instance(step: &StepInstanceBundle<Cmt, F, K>) -> bool {
    wb_wp_required_for_step_instance(step)
        && step
            .lut_insts
            .iter()
            .any(|inst| riscv_is_decode_lookup_table_id(inst.table_id))
}

#[inline]
pub(crate) fn decode_stage_required_for_step_witness(step: &StepWitnessBundle<Cmt, F, K>) -> bool {
    wb_wp_required_for_step_witness(step)
        && step
            .lut_instances
            .iter()
            .any(|(inst, _)| riscv_is_decode_lookup_table_id(inst.table_id))
}

#[inline]
pub(crate) fn width_stage_required_for_step_instance(step: &StepInstanceBundle<Cmt, F, K>) -> bool {
    wb_wp_required_for_step_instance(step)
        && (step
            .lut_insts
            .iter()
            .any(|inst| riscv_trace_uses_shared_width_lookup_table_id(inst.table_id))
            || rv64_fullword_width_stage_required_for_step_instance(step))
}

#[inline]
pub(crate) fn width_stage_required_for_step_witness(step: &StepWitnessBundle<Cmt, F, K>) -> bool {
    wb_wp_required_for_step_witness(step)
        && (step
            .lut_instances
            .iter()
            .any(|(inst, _)| riscv_trace_uses_shared_width_lookup_table_id(inst.table_id))
            || rv64_fullword_width_stage_required_for_step_witness(step))
}

#[inline]
pub(crate) fn control_stage_required_for_step_instance(step: &StepInstanceBundle<Cmt, F, K>) -> bool {
    decode_stage_required_for_step_instance(step)
}

#[inline]
pub(crate) fn control_stage_required_for_step_witness(step: &StepWitnessBundle<Cmt, F, K>) -> bool {
    decode_stage_required_for_step_witness(step)
}

#[inline]
pub(crate) fn time_mem_logical_col_id_for_step(
    step: &StepWitnessBundle<Cmt, F, K>,
    mem_local_col: usize,
    label: &str,
) -> Result<usize, PiCcsError> {
    let cpu_cols_len = step.time_columns.cpu_cols.len();
    let mem_cols_len = step.time_columns.mem_cols.len();
    let total_cols = cpu_cols_len
        .checked_add(mem_cols_len)
        .ok_or_else(|| PiCcsError::InvalidInput(format!("{label}: cpu_cols + mem_cols overflow")))?;
    if step.time_columns.col_ids.len() != total_cols {
        return Err(PiCcsError::ProtocolError(format!(
            "{label}: time column id table mismatch (col_ids={}, cpu_cols={}, mem_cols={})",
            step.time_columns.col_ids.len(),
            cpu_cols_len,
            mem_cols_len
        )));
    }
    let idx = cpu_cols_len
        .checked_add(mem_local_col)
        .ok_or_else(|| PiCcsError::InvalidInput(format!("{label}: cpu_cols + mem_local_col overflow")))?;
    step.time_columns.col_ids.get(idx).copied().ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "{label}: missing logical id for mem local col {} (cpu_cols={}, mem_cols={})",
            mem_local_col, cpu_cols_len, mem_cols_len
        ))
    })
}

#[inline]
pub(crate) fn time_mem_local_col_for_step(
    step: &StepWitnessBundle<Cmt, F, K>,
    logical_col_id: usize,
    label: &str,
) -> Result<usize, PiCcsError> {
    let cpu_cols_len = step.time_columns.cpu_cols.len();
    let mem_cols_len = step.time_columns.mem_cols.len();
    let total_cols = cpu_cols_len
        .checked_add(mem_cols_len)
        .ok_or_else(|| PiCcsError::InvalidInput(format!("{label}: cpu_cols + mem_cols overflow")))?;
    if step.time_columns.col_ids.len() != total_cols {
        return Err(PiCcsError::ProtocolError(format!(
            "{label}: time column id table mismatch (col_ids={}, cpu_cols={}, mem_cols={})",
            step.time_columns.col_ids.len(),
            cpu_cols_len,
            mem_cols_len
        )));
    }
    let abs_pos = step
        .time_columns
        .col_ids
        .iter()
        .position(|&id| id == logical_col_id)
        .ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "{label}: logical col_id={} is not present in step.time_columns.col_ids",
                logical_col_id
            ))
        })?;
    if abs_pos < cpu_cols_len {
        return Err(PiCcsError::ProtocolError(format!(
            "{label}: logical col_id={} resolved to CPU column position {} (expected mem column)",
            logical_col_id, abs_pos
        )));
    }
    let mem_local = abs_pos - cpu_cols_len;
    if mem_local >= mem_cols_len {
        return Err(PiCcsError::ProtocolError(format!(
            "{label}: logical col_id={} resolved out of mem column range (mem_local={}, mem_cols={})",
            logical_col_id, mem_local, mem_cols_len
        )));
    }
    Ok(mem_local)
}

pub(crate) fn build_route_a_wb_wp_time_claims(
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
    if !wb_wp_required_for_step_witness(step) {
        return Ok((None, None));
    }

    let trace = Rv32TraceLayout::new();
    let t_len = infer_rv32_trace_t_len_for_wb_wp(step, &trace)?;
    let m_in = step.mcs.0.m_in;
    let ell_n = r_cycle.len();
    let wb_bool_cols = riscv_trace_wb_columns(&trace);
    let wp_cols = riscv_trace_wp_columns(&trace);

    let mut decode_cols = Vec::with_capacity(1 + wb_bool_cols.len() + wp_cols.len());
    decode_cols.push(trace.active);
    decode_cols.extend(wb_bool_cols.iter().copied());
    decode_cols.extend(wp_cols.iter().copied());
    let decoded = decode_trace_col_values_batch(params, step, t_len, &decode_cols)?;

    let wb_weights = wb_weight_vector(r_cycle, wb_bool_cols.len());
    let mut wb_bool_sparse_cols: Vec<SparseIdxVec<K>> = Vec::with_capacity(wb_bool_cols.len());
    for &col_id in wb_bool_cols.iter() {
        let vals = decoded
            .get(&col_id)
            .ok_or_else(|| PiCcsError::ProtocolError(format!("WB: missing decoded bool column {col_id}")))?;
        wb_bool_sparse_cols.push(sparse_trace_col_from_values(m_in, ell_n, vals)?);
    }

    let wb_oracle = LazyWeightedBitnessOracleSparseTime::new_with_cycle(r_cycle, wb_bool_sparse_cols, wb_weights);

    let weights = wp_weight_vector(r_cycle, wp_cols.len());
    let active_vals = decoded
        .get(&trace.active)
        .ok_or_else(|| PiCcsError::ProtocolError(format!("WP: missing decoded active column {}", trace.active)))?;
    let active = sparse_trace_col_from_values(m_in, ell_n, &active_vals)?;

    let mut sparse_cols: Vec<SparseIdxVec<K>> = Vec::with_capacity(wp_cols.len());
    for &col_id in wp_cols.iter() {
        let vals = decoded
            .get(&col_id)
            .ok_or_else(|| PiCcsError::ProtocolError(format!("WP: missing decoded column {col_id}")))?;
        sparse_cols.push(sparse_trace_col_from_values(m_in, ell_n, &vals)?);
    }

    let oracle = WeightedMaskOracleSparseTime::new(active, sparse_cols, weights, r_cycle);
    Ok((Some((Box::new(wb_oracle), K::ZERO)), Some((Box::new(oracle), K::ZERO))))
}

pub(crate) fn emit_route_a_wb_wp_me_claims(
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    s: &CcsStructure<F>,
    step: &StepWitnessBundle<Cmt, F, K>,
    r_time: &[K],
) -> Result<(Vec<CeClaim<Cmt, F, K>>, Vec<CeClaim<Cmt, F, K>>), PiCcsError> {
    if !wb_wp_required_for_step_witness(step) {
        return Ok((Vec::new(), Vec::new()));
    }

    let trace = Rv32TraceLayout::new();
    let t_len = infer_rv32_trace_t_len_for_wb_wp(step, &trace)?;
    let m_in = step.mcs.0.m_in;
    let core_t = s.t();
    let (mcs_inst, mcs_wit) = &step.mcs;

    let wb_cols = riscv_trace_wb_columns(&trace);
    let mut wb_claims = ts::emit_me_claims_for_mats(
        tr,
        b"cpu/me_digest_wb_time",
        params,
        s,
        core::slice::from_ref(&mcs_inst.c),
        core::slice::from_ref(&mcs_wit.Z),
        r_time,
        m_in,
    )?;
    if wb_claims.len() != 1 {
        return Err(PiCcsError::ProtocolError(format!(
            "WB expects exactly one CPU ME claim at r_time, got {}",
            wb_claims.len()
        )));
    }
    let mut wp_claims = wb_claims.clone();
    if wp_claims.len() != 1 {
        return Err(PiCcsError::ProtocolError(format!(
            "WP expects exactly one CPU ME claim at r_time, got {}",
            wp_claims.len()
        )));
    }
    wp_claims[0].fold_digest = {
        let mut fork = tr.fork(b"cpu/me_digest_wp_time");
        fork.digest32()
    };

    let wb_use_time_cols = step.time_columns.t == t_len
        && !step.time_columns.cpu_cols.is_empty()
        && wb_cols
            .iter()
            .all(|&col_id| col_id < step.time_columns.cpu_cols.len());
    if !wb_use_time_cols {
        return Err(PiCcsError::ProtocolError(format!(
            "WB(shared): canonical time CPU columns are required (time_t={}, cpu_cols={}, expected_t={t_len})",
            step.time_columns.t,
            step.time_columns.cpu_cols.len()
        )));
    }
    crate::memory_sidecar::cpu_bus::append_time_columns_openings_to_me_instance(
        params,
        m_in,
        t_len,
        &step.time_columns.cpu_cols,
        &wb_cols,
        core_t,
        &mut wb_claims[0],
    )?;

    let rv64_exact_words = trace_uses_rv64_exact_words(step.time_columns.cpu_cols.len());
    let mut wp_cols = riscv_trace_wp_opening_columns(&trace);
    if rv64_exact_words {
        wp_cols.extend(rv64_trace_exact_word_opening_columns());
    }
    if control_stage_required_for_step_witness(step) {
        wp_cols.extend(riscv_trace_control_extra_opening_columns(&trace));
    }
    if decode_stage_required_for_step_witness(step) {
        let decode_layout = Rv32DecodeSidecarLayout::new();
        let (_decode_open_cols, decode_lut_slots) = resolve_shared_decode_lookup_lut_indices(step, &decode_layout)?;
        let bus = build_bus_layout_for_step_witness(step, t_len)?;
        if bus.shout_cols.len() != step.lut_instances.len() {
            return Err(PiCcsError::ProtocolError(
                "W2(shared): bus layout shout lane count drift".into(),
            ));
        }
        for &(lut_idx, val_slot) in decode_lut_slots.iter() {
            let inst_cols = bus.shout_cols.get(lut_idx).ok_or_else(|| {
                PiCcsError::ProtocolError("W2(shared): missing shout cols for decode lookup table".into())
            })?;
            let lane0 = inst_cols.lanes.get(0).ok_or_else(|| {
                PiCcsError::ProtocolError("W2(shared): expected one shout lane for decode lookup table".into())
            })?;
            let val_col = lane0.vals.get(val_slot).copied().ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "W2(shared): decode val_slot={} out of range for lut_idx={} (n_vals={})",
                    val_slot,
                    lut_idx,
                    lane0.vals.len()
                ))
            })?;
            let logical_bus_col = time_mem_logical_col_id_for_step(step, val_col, "W2(shared)")?;
            wp_cols.push(logical_bus_col);
        }
    }
    if width_stage_required_for_step_witness(step) && !rv64_fullword_width_stage_required_for_step_witness(step) {
        wp_cols.extend(width_lookup_bus_val_cols_witness(step, t_len)?);
    }
    if rv64_fullword_width_stage_required_for_step_witness(step) {
        wp_cols.extend(rv64_fullword_wp_opening_columns());
    }
    let wp_use_time_cols = step.time_columns.t == t_len
        && !step.time_columns.cpu_cols.is_empty()
        && !step.time_columns.mem_cols.is_empty();
    if !wp_use_time_cols {
        return Err(PiCcsError::ProtocolError(format!(
            "WP(shared): canonical time CPU/MEM columns are required (time_t={}, cpu_cols={}, mem_cols={}, expected_t={t_len})",
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
        &wp_cols,
        core_t,
        &mut wp_claims[0],
    )?;
    Ok((wb_claims, wp_claims))
}

pub(crate) fn verify_route_a_wb_wp_terminals(
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

    let trace = Rv32TraceLayout::new();
    let requires_wb_wp = claim_plan.wb_bool.is_some()
        || claim_plan.wp_quiescence.is_some()
        || !mem_proof.wb_me_claims.is_empty()
        || !mem_proof.wp_me_claims.is_empty();
    if !requires_wb_wp {
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
            "WB/WP terminals require canonical committed time-column mode".into(),
        ));
    }

    if let Some(claim_idx) = claim_plan.wb_bool {
        if claim_idx >= batched_final_values.len() {
            return Err(PiCcsError::ProtocolError(
                "wb/booleanity claim index out of range".into(),
            ));
        }
        if mem_proof.wb_me_claims.len() != 1 {
            return Err(PiCcsError::ProtocolError(format!(
                "WB expects exactly one ME claim at r_time (got {})",
                mem_proof.wb_me_claims.len()
            )));
        }
        let me = &mem_proof.wb_me_claims[0];
        if me.r.as_slice() != r_time {
            return Err(PiCcsError::ProtocolError(
                "WB ME claim r mismatch (expected r_time)".into(),
            ));
        }
        if me.c != step.mcs_inst.c {
            return Err(PiCcsError::ProtocolError("WB ME claim commitment mismatch".into()));
        }
        if me.m_in != step.mcs_inst.m_in {
            return Err(PiCcsError::ProtocolError("WB ME claim m_in mismatch".into()));
        }

        let wb_bool_cols = riscv_trace_wb_columns(&trace);
        let (wb_open_entry, wb_open_map) =
            require_time_openings_covering_point(step_time_openings, r_time, &wb_bool_cols, "WB")?;
        if wb_open_entry.source != crate::shard_proof_types::TimeOpeningSource::CommittedOpening {
            return Err(PiCcsError::ProtocolError(format!(
                "WB requires CommittedOpening source (got {:?})",
                wb_open_entry.source
            )));
        }
        let wb_weights = wb_weight_vector(r_cycle, wb_bool_cols.len());
        let mut wb_weighted_bitness = K::ZERO;
        for (&col_id, &w) in wb_bool_cols.iter().zip(wb_weights.iter()) {
            let b = named_opening(&wb_open_map, col_id, "WB")?;
            wb_weighted_bitness += w * b * (b - K::ONE);
        }

        let expected_terminal = eq_points(r_time, r_cycle) * wb_weighted_bitness;
        let observed_terminal = batched_final_values[claim_idx];
        if observed_terminal != expected_terminal {
            return Err(PiCcsError::ProtocolError(
                "wb/booleanity terminal value mismatch".into(),
            ));
        }
    } else if !mem_proof.wb_me_claims.is_empty() {
        return Err(PiCcsError::ProtocolError(
            "unexpected WB ME claims: wb/booleanity stage is not enabled".into(),
        ));
    }

    if let Some(claim_idx) = claim_plan.wp_quiescence {
        if claim_idx >= batched_final_values.len() {
            return Err(PiCcsError::ProtocolError(
                "wp/quiescence claim index out of range".into(),
            ));
        }
        if mem_proof.wp_me_claims.len() != 1 {
            return Err(PiCcsError::ProtocolError(format!(
                "WP expects exactly one ME claim at r_time (got {})",
                mem_proof.wp_me_claims.len()
            )));
        }
        let me = &mem_proof.wp_me_claims[0];
        if me.r.as_slice() != r_time {
            return Err(PiCcsError::ProtocolError(
                "WP ME claim r mismatch (expected r_time)".into(),
            ));
        }
        if me.c != step.mcs_inst.c {
            return Err(PiCcsError::ProtocolError("WP ME claim commitment mismatch".into()));
        }
        if me.m_in != step.mcs_inst.m_in {
            return Err(PiCcsError::ProtocolError("WP ME claim m_in mismatch".into()));
        }

        let rv64_exact_words = trace_uses_rv64_exact_words(step.time_columns.cpu_cols.len());
        let mut wp_open_cols = riscv_trace_wp_opening_columns(&trace);
        if rv64_exact_words {
            wp_open_cols.extend(rv64_trace_exact_word_opening_columns());
        }
        let (wp_open_entry, wp_open_map) =
            require_time_openings_covering_point(step_time_openings, r_time, &wp_open_cols, "WP")?;
        if wp_open_entry.source != crate::shard_proof_types::TimeOpeningSource::CommittedOpening {
            return Err(PiCcsError::ProtocolError(format!(
                "WP requires CommittedOpening source (got {:?})",
                wp_open_entry.source
            )));
        }
        let active_open = named_opening(&wp_open_map, trace.active, "WP")?;
        let wp_cols_no_active = riscv_trace_wp_columns(&trace);
        let wp_weights = wp_weight_vector(r_cycle, wp_cols_no_active.len());
        let mut wp_weighted_sum = K::ZERO;
        for (&col_id, &w) in wp_cols_no_active.iter().zip(wp_weights.iter()) {
            let v = named_opening(&wp_open_map, col_id, "WP")?;
            wp_weighted_sum += w * v;
        }
        let expected_terminal = eq_points(r_time, r_cycle) * (K::ONE - active_open) * wp_weighted_sum;
        let observed_terminal = batched_final_values[claim_idx];
        if observed_terminal != expected_terminal {
            return Err(PiCcsError::ProtocolError(
                "wp/quiescence terminal value mismatch".into(),
            ));
        }
    } else if !mem_proof.wp_me_claims.is_empty() {
        return Err(PiCcsError::ProtocolError(
            "unexpected WP ME claims: wp/quiescence stage is not enabled".into(),
        ));
    }

    Ok(())
}

use super::*;

pub fn verify_route_a_memory_step(
    tr: &mut Poseidon2Transcript,
    core_t: usize,
    step: &StepInstanceBundle<Cmt, F, K>,
    prev_step: Option<&StepInstanceBundle<Cmt, F, K>>,
    prev_mem_proof: Option<&MemSidecarProof<Cmt, F, K>>,
    ccs_out0: &MeInstance<Cmt, F, K>,
    r_time: &[K],
    r_cycle: &[K],
    batched_final_values: &[K],
    batched_claimed_sums: &[K],
    claim_idx_start: usize,
    mem_proof: &MemSidecarProof<Cmt, F, K>,
    shout_pre: &[ShoutAddrPreVerifyData],
    twist_pre: &[TwistAddrPreVerifyData],
    step_idx: usize,
) -> Result<RouteAMemoryVerifyOutput, PiCcsError> {
    let chi_cycle_at_r_time = eq_points(r_time, r_cycle);
    if ccs_out0.r.as_slice() != r_time {
        return Err(PiCcsError::ProtocolError(
            "CPU ME output r mismatch (expected shared r_time)".into(),
        ));
    }
    let trace_mode = wb_wp_required_for_step_instance(step);
    let cpu_link = if trace_mode {
        extract_trace_cpu_link_openings(core_t, step, mem_proof, r_time)?
    } else {
        None
    };
    let enforce_trace_shout_linkage = trace_mode && !step.lut_insts.is_empty();
    if enforce_trace_shout_linkage && cpu_link.is_none() {
        return Err(PiCcsError::ProtocolError(
            "missing CPU trace linkage openings in shared-bus mode".into(),
        ));
    }
    let has_prev = prev_step.is_some();
    if let Some(prev) = prev_step {
        if prev.mem_insts.len() != step.mem_insts.len() {
            return Err(PiCcsError::InvalidInput(format!(
                "Twist rollover requires stable mem instance count: prev has {}, current has {}",
                prev.mem_insts.len(),
                step.mem_insts.len()
            )));
        }
        for (idx, (prev_inst, inst)) in prev.mem_insts.iter().zip(step.mem_insts.iter()).enumerate() {
            if prev_inst.d != inst.d
                || prev_inst.ell != inst.ell
                || prev_inst.k != inst.k
                || prev_inst.lanes != inst.lanes
            {
                return Err(PiCcsError::InvalidInput(format!(
                    "Twist rollover requires stable geometry at mem_idx={}: prev (k={}, d={}, ell={}, lanes={}) vs cur (k={}, d={}, ell={}, lanes={})",
                    idx,
                    prev_inst.k,
                    prev_inst.d,
                    prev_inst.ell,
                    prev_inst.lanes,
                    inst.k,
                    inst.d,
                    inst.ell,
                    inst.lanes
                )));
            }
        }
    }

    for (idx, inst) in step.lut_insts.iter().enumerate() {
        if !inst.comms.is_empty() {
            return Err(PiCcsError::InvalidInput(format!(
                "shared CPU bus requires metadata-only Shout instances (comms must be empty, lut_idx={idx}, table_id={})",
                inst.table_id
            )));
        }
    }
    for (idx, inst) in step.mem_insts.iter().enumerate() {
        if !inst.comms.is_empty() {
            return Err(PiCcsError::InvalidInput(format!(
                "shared CPU bus requires metadata-only Twist instances (comms must be empty, mem_idx={idx})"
            )));
        }
    }
    if let Some(prev) = prev_step {
        for (idx, inst) in prev.lut_insts.iter().enumerate() {
            if !inst.comms.is_empty() {
                return Err(PiCcsError::InvalidInput(format!(
                    "shared CPU bus requires metadata-only Shout instances (comms must be empty, prev lut_idx={idx}, table_id={})",
                    inst.table_id
                )));
            }
        }
        for (idx, inst) in prev.mem_insts.iter().enumerate() {
            if !inst.comms.is_empty() {
                return Err(PiCcsError::InvalidInput(format!(
                    "shared CPU bus requires metadata-only Twist instances (comms must be empty, prev mem_idx={idx})"
                )));
            }
        }
    }

    let proofs_mem = &mem_proof.proofs;
    let wb_enabled = wb_wp_required_for_step_instance(step);
    let wp_enabled = wb_wp_required_for_step_instance(step);
    let w2_enabled = decode_stage_required_for_step_instance(step);
    let w3_enabled = width_stage_required_for_step_instance(step);
    let control_enabled = control_stage_required_for_step_instance(step);

    let base_sidecar_claims = step
        .lut_insts
        .len()
        .checked_add(step.mem_insts.len())
        .ok_or_else(|| PiCcsError::InvalidInput("sidecar claim count overflow".into()))?;
    let lookup_sidecar_claims = usize::from(route_a_lookup_sidecar_required_for_step_instance(step));
    let expected_sidecar_claims = base_sidecar_claims
        .checked_add(lookup_sidecar_claims)
        .ok_or_else(|| PiCcsError::InvalidInput("sidecar claim count overflow".into()))?;
    if mem_proof.sidecar_me_claims.len() != expected_sidecar_claims {
        return Err(PiCcsError::InvalidInput(format!(
            "Route-A sidecar ME claim count mismatch (expected {}, got {})",
            expected_sidecar_claims,
            mem_proof.sidecar_me_claims.len()
        )));
    }
    let claim_plan = RouteATimeClaimPlan::build(
        step,
        claim_idx_start,
        wb_enabled,
        wp_enabled,
        w2_enabled,
        w3_enabled,
        control_enabled,
    )?;
    if claim_plan.claim_idx_end > batched_final_values.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "batched_final_values too short (need at least {}, have {})",
            claim_plan.claim_idx_end,
            batched_final_values.len()
        )));
    }
    if claim_plan.claim_idx_end > batched_claimed_sums.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "batched_claimed_sums too short (need at least {}, have {})",
            claim_plan.claim_idx_end,
            batched_claimed_sums.len()
        )));
    }

    let expected_proofs = step.lut_insts.len() + step.mem_insts.len();
    if proofs_mem.len() != expected_proofs {
        return Err(PiCcsError::InvalidInput(format!(
            "mem proof count mismatch (expected {}, got {})",
            expected_proofs,
            proofs_mem.len()
        )));
    }
    let total_shout_lanes: usize = step.lut_insts.iter().map(|inst| inst.lanes.max(1)).sum();
    if shout_pre.len() != total_shout_lanes {
        return Err(PiCcsError::InvalidInput(format!(
            "shout pre-time count mismatch (expected total_lanes={}, got {})",
            total_shout_lanes,
            shout_pre.len()
        )));
    }
    if twist_pre.len() != step.mem_insts.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "twist pre-time count mismatch (expected {}, got {})",
            step.mem_insts.len(),
            twist_pre.len()
        )));
    }
    let decode_openings_at_r = trace_decode_openings_at_r_time(core_t, step, mem_proof, r_time)?;

    let mut twist_time_openings: Vec<TwistTimeLaneOpenings> = Vec::with_capacity(step.mem_insts.len());

    // Shout instances first.
    let mut shout_lane_base: usize = 0;
    let mut shout_trace_sums = ShoutTraceLinkSums::default();
    #[derive(Clone)]
    struct ShoutGammaLaneVerifyData {
        has_lookup: K,
        val: K,
        addr_bits: Vec<K>,
        pre: ShoutAddrPreVerifyData,
    }
    let mut shout_addr_group_counts = std::collections::HashMap::<(u64, usize), usize>::new();
    for inst in step.lut_insts.iter() {
        if let Some(group) = inst.addr_group {
            for lane_idx in 0..inst.lanes.max(1) {
                *shout_addr_group_counts
                    .entry((group, lane_idx))
                    .or_insert(0) += 1;
            }
        }
    }
    let mut shout_gamma_lane_data: Vec<Option<ShoutGammaLaneVerifyData>> = vec![None; total_shout_lanes];
    for (proof_idx, inst) in step.lut_insts.iter().enumerate() {
        match &proofs_mem[proof_idx] {
            MemOrLutProof::Shout(_proof) => {}
            _ => return Err(PiCcsError::InvalidInput("expected Shout proof".into())),
        }
        let packed_layout = rv32_packed_shout_layout(&inst.table_spec)?;
        if matches!(packed_layout, Some((_op, time_bits)) if time_bits != 0) {
            return Err(PiCcsError::InvalidInput(
                "RiscvOpcodeEventTablePacked is not supported in shared-bus Route-A verification".into(),
            ));
        }
        let packed_opcode = match &inst.table_spec {
            Some(LutTableSpec::RiscvOpcodePacked { opcode, xlen }) => {
                if *xlen != 32 {
                    return Err(PiCcsError::InvalidInput(format!(
                        "RiscvOpcodePacked requires xlen=32 in Route-A verification (got xlen={xlen})"
                    )));
                }
                Some(*opcode)
            }
            _ => None,
        };

        let ell_addr = inst.d * inst.ell;
        let expected_lanes = inst.lanes.max(1);
        if expected_lanes != 1 {
            return Err(PiCcsError::InvalidInput(format!(
                "Shout sidecar verification currently requires lanes=1 (lut_idx={proof_idx}, table_id={}, lanes={})",
                inst.table_id, inst.lanes
            )));
        }
        let lane_table_id = if enforce_trace_shout_linkage {
            rv32_trace_link_table_id_from_spec(&inst.table_spec)?.map(|table_id| K::from(F::from_u64(table_id as u64)))
        } else {
            None
        };

        let sidecar_me = mem_proof
            .sidecar_me_claims
            .get(proof_idx)
            .ok_or_else(|| PiCcsError::ProtocolError("missing Shout sidecar ME claim".into()))?;
        if sidecar_me.r.as_slice() != r_time {
            return Err(PiCcsError::ProtocolError(format!(
                "Shout sidecar ME r mismatch at lut_idx={proof_idx}"
            )));
        }
        if sidecar_me.m_in != step.mcs_inst.m_in {
            return Err(PiCcsError::ProtocolError(format!(
                "Shout sidecar ME m_in mismatch at lut_idx={proof_idx}: got {}, expected {}",
                sidecar_me.m_in, step.mcs_inst.m_in
            )));
        }

        struct ShoutLaneOpen {
            addr_bits: Vec<K>,
            has_lookup: K,
            val: K,
            shared_addr_group: bool,
            shared_addr_group_size: usize,
        }
        let mut lane_opens: Vec<ShoutLaneOpen> = Vec::with_capacity(expected_lanes);
        let sidecar_open_base = core_t;
        let sidecar_open_end = sidecar_open_base
            .checked_add(ell_addr + 2)
            .ok_or_else(|| PiCcsError::ProtocolError("Shout sidecar opening range overflow".into()))?;
        if sidecar_me.y_scalars.len() < sidecar_open_end {
            return Err(PiCcsError::ProtocolError(format!(
                "Shout sidecar y_scalars too short at lut_idx={proof_idx}: need at least {}, have {}",
                sidecar_open_end,
                sidecar_me.y_scalars.len()
            )));
        }
        let mut addr_bits_open = Vec::with_capacity(ell_addr);
        addr_bits_open.extend_from_slice(&sidecar_me.y_scalars[sidecar_open_base..(sidecar_open_base + ell_addr)]);
        let has_lookup_open = sidecar_me.y_scalars[sidecar_open_base + ell_addr];
        let val_open = sidecar_me.y_scalars[sidecar_open_base + ell_addr + 1];
        let shared_addr_group_size = inst
            .addr_group
            .and_then(|group| shout_addr_group_counts.get(&(group, 0)).copied())
            .unwrap_or(0);
        let shared_addr_group = shared_addr_group_size > 1;

        lane_opens.push(ShoutLaneOpen {
            addr_bits: addr_bits_open,
            has_lookup: has_lookup_open,
            val: val_open,
            shared_addr_group,
            shared_addr_group_size,
        });

        let shout_claims = claim_plan
            .shout
            .get(proof_idx)
            .ok_or_else(|| PiCcsError::ProtocolError(format!("missing Shout claim schedule at index {}", proof_idx)))?;
        if shout_claims.lanes.len() != expected_lanes {
            return Err(PiCcsError::ProtocolError(format!(
                "Shout claim schedule lane count mismatch at lut_idx={proof_idx}: expected {expected_lanes}, got {}",
                shout_claims.lanes.len()
            )));
        }
        if shout_lane_base
            .checked_add(expected_lanes)
            .ok_or_else(|| PiCcsError::ProtocolError("shout lane index overflow".into()))?
            > shout_pre.len()
        {
            return Err(PiCcsError::ProtocolError("Shout pre-time lane indexing drift".into()));
        }

        // Route A Shout ordering in batched_time:
        // - value (time rounds only) per lane
        // - adapter (time rounds only) per lane
        // - aggregated bitness for (addr_bits, has_lookup)
        {
            let mut opens: Vec<K> = Vec::new();
            if let Some(op) = packed_opcode {
                for lane in lane_opens.iter() {
                    let mut lane_terms = neo_memory::riscv::packed::rv32_collect_packed_bitness_terms(
                        op,
                        lane.addr_bits.as_slice(),
                        lane.has_lookup,
                        lane.val,
                    )?;
                    opens.append(&mut lane_terms);
                }
            } else {
                opens.reserve(expected_lanes * (ell_addr + 1));
                for lane in lane_opens.iter() {
                    opens.extend_from_slice(&lane.addr_bits);
                    opens.push(lane.has_lookup);
                }
            }
            let weights = bitness_weights(r_cycle, opens.len(), 0x5348_4F55_54u64 + proof_idx as u64);
            let mut acc = K::ZERO;
            for (w, b) in weights.iter().zip(opens.iter()) {
                acc += *w * *b * (*b - K::ONE);
            }
            let expected = chi_cycle_at_r_time * acc;
            if expected != batched_final_values[shout_claims.bitness] {
                return Err(PiCcsError::ProtocolError(format!(
                    "shout/bitness terminal value mismatch at lut_idx={proof_idx} (expected={expected:?}, got={:?})",
                    batched_final_values[shout_claims.bitness]
                )));
            }
        }

        for (lane_idx, lane) in lane_opens.iter().enumerate() {
            if let Some(lane_table_id) = lane_table_id {
                shout_trace_sums.has_lookup += lane.has_lookup;
                shout_trace_sums.val += lane.val;
                shout_trace_sums.table_id += lane.has_lookup * lane_table_id;
                let (lhs, rhs) = if packed_opcode.is_some() {
                    let lhs = *lane.addr_bits.first().ok_or_else(|| {
                        PiCcsError::InvalidInput("packed Shout trace linkage requires lhs in addr_bits[0]".into())
                    })?;
                    let rhs = *lane.addr_bits.get(1).ok_or_else(|| {
                        PiCcsError::InvalidInput("packed Shout trace linkage requires rhs in addr_bits[1]".into())
                    })?;
                    (lhs, rhs)
                } else {
                    unpack_interleaved_halves_lsb(&lane.addr_bits)?
                };
                if lane.shared_addr_group {
                    let inv_count = K::from_u64(lane.shared_addr_group_size as u64).inverse();
                    shout_trace_sums.lhs += lhs * inv_count;
                    shout_trace_sums.rhs += rhs * inv_count;
                } else {
                    shout_trace_sums.lhs += lhs;
                    shout_trace_sums.rhs += rhs;
                }
            }

            let pre = shout_pre.get(shout_lane_base + lane_idx).ok_or_else(|| {
                PiCcsError::InvalidInput(format!(
                    "missing pre-time Shout lane data at index {}",
                    shout_lane_base + lane_idx
                ))
            })?;
            let lane_claims = shout_claims
                .lanes
                .get(lane_idx)
                .ok_or_else(|| PiCcsError::ProtocolError("shout claim schedule lane idx drift".into()))?;

            if lane_claims.gamma_group.is_some() {
                if packed_opcode.is_some() {
                    return Err(PiCcsError::ProtocolError(
                        "packed shout lane unexpectedly assigned to gamma group".into(),
                    ));
                }
                if !pre.is_active {
                    if pre.addr_claim_sum != K::ZERO || pre.addr_final != K::ZERO || lane.has_lookup != K::ZERO {
                        return Err(PiCcsError::ProtocolError(
                            "shout gamma lane inactive-row invariants violated".into(),
                        ));
                    }
                }
                shout_gamma_lane_data[shout_lane_base + lane_idx] = Some(ShoutGammaLaneVerifyData {
                    has_lookup: lane.has_lookup,
                    val: lane.val,
                    addr_bits: lane.addr_bits.clone(),
                    pre: pre.clone(),
                });
            } else {
                let value_idx = lane_claims
                    .value
                    .ok_or_else(|| PiCcsError::ProtocolError("missing shout value claim idx".into()))?;
                let adapter_idx = lane_claims
                    .adapter
                    .ok_or_else(|| PiCcsError::ProtocolError("missing shout adapter claim idx".into()))?;
                let value_claim = batched_claimed_sums[value_idx];
                let value_final = batched_final_values[value_idx];
                let adapter_claim = batched_claimed_sums[adapter_idx];
                let adapter_final = batched_final_values[adapter_idx];

                if packed_opcode.is_some() {
                    // Packed Route-A lanes are verified as zero-sum constraints. The claimed sums
                    // must be zero, but terminal evaluations at the sampled random point are not
                    // required to be zero in general.
                    if value_claim != K::ZERO || adapter_claim != K::ZERO {
                        return Err(PiCcsError::ProtocolError(format!(
                            "packed shout lane zero-claim invariant mismatch at lut_idx={proof_idx}, lane_idx={lane_idx}: value_claim={value_claim:?}, adapter_claim={adapter_claim:?}"
                        )));
                    }
                    if pre.is_active
                        || pre.addr_claim_sum != K::ZERO
                        || pre.addr_final != K::ZERO
                        || pre.table_eval_at_r_addr != K::ZERO
                    {
                        return Err(PiCcsError::ProtocolError(
                            "packed shout lane addr-pre invariants mismatch".into(),
                        ));
                    }
                    continue;
                }

                let expected_value_final = chi_cycle_at_r_time * lane.has_lookup * lane.val;
                if expected_value_final != value_final {
                    return Err(PiCcsError::ProtocolError("shout value terminal value mismatch".into()));
                }

                let eq_addr = eq_bits_prod(&lane.addr_bits, &pre.r_addr)?;
                let expected_adapter_final = chi_cycle_at_r_time * lane.has_lookup * eq_addr;
                if expected_adapter_final != adapter_final {
                    return Err(PiCcsError::ProtocolError(
                        "shout adapter terminal value mismatch".into(),
                    ));
                }

                if value_claim != pre.addr_claim_sum {
                    return Err(PiCcsError::ProtocolError(
                        "shout value claimed sum != addr claimed sum".into(),
                    ));
                }

                if pre.is_active {
                    let expected_addr_final = pre.table_eval_at_r_addr * adapter_claim;
                    if expected_addr_final != pre.addr_final {
                        return Err(PiCcsError::ProtocolError("shout addr terminal value mismatch".into()));
                    }
                } else {
                    // If we skipped the addr-pre sumcheck, the only sound case is "no lookups".
                    // Enforce this by requiring the addr claim + adapter claim to be zero.
                    if pre.addr_claim_sum != K::ZERO {
                        return Err(PiCcsError::ProtocolError(
                            "shout addr-pre skipped but addr claim is nonzero".into(),
                        ));
                    }
                    if adapter_claim != K::ZERO {
                        return Err(PiCcsError::ProtocolError(
                            "shout addr-pre skipped but adapter claim is nonzero".into(),
                        ));
                    }
                    if pre.addr_final != K::ZERO {
                        return Err(PiCcsError::ProtocolError(
                            "shout addr-pre skipped but addr_final is nonzero".into(),
                        ));
                    }
                }
            }
        }

        shout_lane_base += expected_lanes;
    }
    if shout_lane_base != shout_pre.len() {
        return Err(PiCcsError::ProtocolError(
            "shout pre-time lanes not fully consumed".into(),
        ));
    }
    if !step.lut_insts.is_empty() && enforce_trace_shout_linkage {
        let cpu = cpu_link
            .ok_or_else(|| PiCcsError::ProtocolError("missing CPU trace linkage openings in shared-bus mode".into()))?;
        let expected_table_id = if decode_stage_required_for_step_instance(step) {
            Some(expected_trace_shout_table_id_from_openings(
                core_t, step, mem_proof, r_time,
            )?)
        } else {
            None
        };
        verify_non_event_trace_shout_linkage(cpu, shout_trace_sums, expected_table_id)?;
    }

    for group in claim_plan.shout_gamma_groups.iter() {
        let weights = bitness_weights(r_cycle, group.lanes.len(), 0x5348_5F47_414D_4Du64 ^ group.key);
        let value_claim = batched_claimed_sums[group.value];
        let value_final = batched_final_values[group.value];
        let adapter_claim = batched_claimed_sums[group.adapter];
        let adapter_final = batched_final_values[group.adapter];

        let mut expected_value_claim = K::ZERO;
        let mut expected_value_final = K::ZERO;
        let mut expected_adapter_claim = K::ZERO;
        let mut expected_adapter_final = K::ZERO;
        for (slot, lane_ref) in group.lanes.iter().enumerate() {
            let lane = shout_gamma_lane_data
                .get(lane_ref.flat_lane_idx)
                .and_then(|x| x.as_ref())
                .ok_or_else(|| PiCcsError::ProtocolError("missing shout gamma lane verify data".into()))?;
            let w = weights[slot];
            let eq_addr = eq_bits_prod(&lane.addr_bits, &lane.pre.r_addr)?;
            expected_value_claim += w * lane.pre.addr_claim_sum;
            expected_value_final += w * lane.has_lookup * lane.val;
            expected_adapter_claim += w * lane.pre.addr_final;
            expected_adapter_final += w * lane.pre.table_eval_at_r_addr * lane.has_lookup * eq_addr;
        }
        expected_value_final *= chi_cycle_at_r_time;
        expected_adapter_final *= chi_cycle_at_r_time;

        if value_claim != expected_value_claim {
            return Err(PiCcsError::ProtocolError(
                "shout gamma value claimed sum mismatch".into(),
            ));
        }
        if value_final != expected_value_final {
            return Err(PiCcsError::ProtocolError("shout gamma value terminal mismatch".into()));
        }
        if adapter_claim != expected_adapter_claim {
            return Err(PiCcsError::ProtocolError(
                "shout gamma adapter claimed sum mismatch".into(),
            ));
        }
        if adapter_final != expected_adapter_final {
            return Err(PiCcsError::ProtocolError(
                "shout gamma adapter terminal mismatch".into(),
            ));
        }
    }

    // Twist instances next.
    let proof_mem_offset = step.lut_insts.len();

    // --------------------------------------------------------------------
    // Twist time checks at addr-pre `r_addr`.
    // --------------------------------------------------------------------
    for (i_mem, inst) in step.mem_insts.iter().enumerate() {
        let twist_proof = match &proofs_mem[proof_mem_offset + i_mem] {
            MemOrLutProof::Twist(proof) => proof,
            _ => return Err(PiCcsError::InvalidInput("expected Twist proof".into())),
        };
        let layout = inst.twist_layout();
        let ell_addr = layout
            .lanes
            .get(0)
            .ok_or_else(|| PiCcsError::InvalidInput("TwistWitnessLayout has no lanes".into()))?
            .ell_addr;

        let expected_lanes = inst.lanes.max(1);

        struct TwistLaneTimeOpen {
            ra_bits: Vec<K>,
            wa_bits: Vec<K>,
            has_read: K,
            has_write: K,
            wv: K,
            rv: K,
            inc: K,
        }

        let twist_sidecar_idx = step
            .lut_insts
            .len()
            .checked_add(i_mem)
            .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar claim index overflow".into()))?;
        let twist_sidecar_me = mem_proof
            .sidecar_me_claims
            .get(twist_sidecar_idx)
            .ok_or_else(|| PiCcsError::ProtocolError("missing Twist sidecar ME claim".into()))?;
        if twist_sidecar_me.r.as_slice() != r_time {
            return Err(PiCcsError::ProtocolError(format!(
                "Twist sidecar ME r mismatch at mem_idx={i_mem}"
            )));
        }
        if twist_sidecar_me.m_in != step.mcs_inst.m_in {
            return Err(PiCcsError::ProtocolError(format!(
                "Twist sidecar ME m_in mismatch at mem_idx={i_mem}: got {}, expected {}",
                twist_sidecar_me.m_in, step.mcs_inst.m_in
            )));
        }
        let lane_cols = ell_addr
            .checked_mul(2)
            .and_then(|v| v.checked_add(5))
            .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar lane width overflow".into()))?;
        let expected_sidecar_cols = expected_lanes
            .checked_mul(lane_cols)
            .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar col count overflow".into()))?;
        let sidecar_open_start = core_t;
        let sidecar_open_end = sidecar_open_start
            .checked_add(expected_sidecar_cols)
            .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar opening range overflow".into()))?;
        if twist_sidecar_me.y_scalars.len() < sidecar_open_end {
            return Err(PiCcsError::ProtocolError(format!(
                "Twist sidecar y_scalars too short at mem_idx={i_mem}: need at least {sidecar_open_end}, have {}",
                twist_sidecar_me.y_scalars.len()
            )));
        }
        let sidecar_open_col = |local_col: usize| -> Result<K, PiCcsError> {
            let idx = sidecar_open_start
                .checked_add(local_col)
                .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar opening index overflow".into()))?;
            twist_sidecar_me.y_scalars.get(idx).copied().ok_or_else(|| {
                PiCcsError::ProtocolError(format!("missing Twist sidecar opening local_col={local_col}"))
            })
        };

        let mut lane_opens: Vec<TwistLaneTimeOpen> = Vec::with_capacity(expected_lanes);
        for lane_idx in 0..expected_lanes {
            let lane_base = lane_idx
                .checked_mul(lane_cols)
                .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar lane offset overflow".into()))?;
            let mut ra_bits_open = Vec::with_capacity(ell_addr);
            for bit_idx in 0..ell_addr {
                let local_col = lane_base
                    .checked_add(bit_idx)
                    .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar ra_bits index overflow".into()))?;
                ra_bits_open.push(sidecar_open_col(local_col)?);
            }
            let mut wa_bits_open = Vec::with_capacity(ell_addr);
            for bit_idx in 0..ell_addr {
                let local_col = lane_base
                    .checked_add(ell_addr)
                    .and_then(|v| v.checked_add(bit_idx))
                    .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar wa_bits index overflow".into()))?;
                wa_bits_open.push(sidecar_open_col(local_col)?);
            }

            let has_read_open = sidecar_open_col(
                lane_base
                    .checked_add(2 * ell_addr)
                    .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar has_read index overflow".into()))?,
            )?;
            let has_write_open = sidecar_open_col(
                lane_base
                    .checked_add(2 * ell_addr + 1)
                    .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar has_write index overflow".into()))?,
            )?;
            if let Some(decode_open) = decode_openings_at_r {
                if inst.mem_id == RAM_ID.0 && lane_idx == 0 {
                    if has_read_open != decode_open.ram_has_read {
                        return Err(PiCcsError::ProtocolError(
                            "twist selector linkage mismatch: RAM has_read != decode.ram_has_read".into(),
                        ));
                    }
                    if has_write_open != decode_open.ram_has_write {
                        return Err(PiCcsError::ProtocolError(
                            "twist selector linkage mismatch: RAM has_write != decode.ram_has_write".into(),
                        ));
                    }
                } else if inst.mem_id == REG_ID.0 && lane_idx == 0 && has_write_open != decode_open.rd_has_write {
                    return Err(PiCcsError::ProtocolError(
                        "twist selector linkage mismatch: REG has_write != decode.rd_has_write".into(),
                    ));
                }
            }
            let wv_open = sidecar_open_col(
                lane_base
                    .checked_add(2 * ell_addr + 2)
                    .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar wv index overflow".into()))?,
            )?;
            let rv_open = sidecar_open_col(
                lane_base
                    .checked_add(2 * ell_addr + 3)
                    .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar rv index overflow".into()))?,
            )?;
            let inc_write_open = sidecar_open_col(
                lane_base
                    .checked_add(2 * ell_addr + 4)
                    .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar inc index overflow".into()))?,
            )?;

            lane_opens.push(TwistLaneTimeOpen {
                ra_bits: ra_bits_open,
                wa_bits: wa_bits_open,
                has_read: has_read_open,
                has_write: has_write_open,
                wv: wv_open,
                rv: rv_open,
                inc: inc_write_open,
            });
        }

        let pre = twist_pre
            .get(i_mem)
            .ok_or_else(|| PiCcsError::InvalidInput(format!("missing Twist pre-time data at index {}", i_mem)))?;
        let r_addr = &pre.r_addr;
        if r_addr.len() != ell_addr {
            return Err(PiCcsError::InvalidInput(format!(
                "Twist r_addr.len()={}, expected ell_addr={}",
                r_addr.len(),
                ell_addr
            )));
        }

        let twist_claims = claim_plan
            .twist
            .get(i_mem)
            .ok_or_else(|| PiCcsError::ProtocolError(format!("missing Twist claim schedule at index {}", i_mem)))?;

        // Route A Twist ordering in batched_time:
        // - read_check (time rounds only)
        // - write_check (time rounds only)
        // - bitness for ra_bits then wa_bits then has_read then has_write (time-only)
        let read_check_claim = batched_claimed_sums[twist_claims.read_check];
        let read_check_final = batched_final_values[twist_claims.read_check];
        let write_check_claim = batched_claimed_sums[twist_claims.write_check];
        let write_check_final = batched_final_values[twist_claims.write_check];

        if read_check_claim != pre.read_check_claim_sum {
            return Err(PiCcsError::ProtocolError(
                "twist read_check claimed sum != addr-pre final".into(),
            ));
        }
        if write_check_claim != pre.write_check_claim_sum {
            return Err(PiCcsError::ProtocolError(
                "twist write_check claimed sum != addr-pre final".into(),
            ));
        }

        // Aggregated bitness terminal check (ra_bits, wa_bits, has_read, has_write).
        {
            let mut opens: Vec<K> = Vec::with_capacity(expected_lanes * (2 * ell_addr + 2));
            for lane in lane_opens.iter() {
                opens.extend_from_slice(&lane.ra_bits);
                opens.extend_from_slice(&lane.wa_bits);
                opens.push(lane.has_read);
                opens.push(lane.has_write);
            }
            let weights = bitness_weights(r_cycle, opens.len(), 0x5457_4953_54u64 + i_mem as u64);
            let mut acc = K::ZERO;
            for (w, b) in weights.iter().zip(opens.iter()) {
                acc += *w * *b * (*b - K::ONE);
            }
            let expected = chi_cycle_at_r_time * acc;
            if expected != batched_final_values[twist_claims.bitness] {
                return Err(PiCcsError::ProtocolError(
                    "twist/bitness terminal value mismatch".into(),
                ));
            }
        }

        let val_eval = twist_proof
            .val_eval
            .as_ref()
            .ok_or_else(|| PiCcsError::InvalidInput("Twist(Route A): missing val_eval proof".into()))?;

        let init_at_r_addr = eval_init_at_r_addr(&inst.init, inst.k, r_addr)?;
        let claimed_val = init_at_r_addr + val_eval.claimed_inc_sum_lt;

        // Terminal checks for read_check / write_check at (r_time, r_addr).
        let mut expected_read_check_final = K::ZERO;
        let mut expected_write_check_final = K::ZERO;
        for lane in lane_opens.iter() {
            let read_eq_addr = eq_bits_prod(&lane.ra_bits, r_addr)?;
            expected_read_check_final += chi_cycle_at_r_time * lane.has_read * (claimed_val - lane.rv) * read_eq_addr;

            let write_eq_addr = eq_bits_prod(&lane.wa_bits, r_addr)?;
            expected_write_check_final +=
                chi_cycle_at_r_time * lane.has_write * (lane.wv - claimed_val - lane.inc) * write_eq_addr;
        }
        if expected_read_check_final != read_check_final {
            return Err(PiCcsError::ProtocolError(
                "twist/read_check terminal value mismatch".into(),
            ));
        }

        if expected_write_check_final != write_check_final {
            return Err(PiCcsError::ProtocolError(
                "twist/write_check terminal value mismatch".into(),
            ));
        }

        twist_time_openings.push(TwistTimeLaneOpenings {
            lanes: lane_opens
                .into_iter()
                .map(|lane| TwistTimeLaneOpeningsLane {
                    wa_bits: lane.wa_bits,
                    has_write: lane.has_write,
                    inc_at_write_addr: lane.inc,
                })
                .collect(),
        });
    }

    // --------------------------------------------------------------------
    // Phase 2: Verify batched Twist val-eval sum-check, deriving shared r_val.
    // --------------------------------------------------------------------
    let mut r_val: Vec<K> = Vec::new();
    let mut val_eval_finals: Vec<K> = Vec::new();
    if !step.mem_insts.is_empty() {
        let plan = crate::memory_sidecar::claim_plan::TwistValEvalClaimPlan::build(step.mem_insts.iter(), has_prev);
        let claim_count = plan.claim_count;

        let mut per_claim_rounds: Vec<Vec<Vec<K>>> = Vec::with_capacity(claim_count);
        let mut per_claim_sums: Vec<K> = Vec::with_capacity(claim_count);
        let mut bind_claims: Vec<(u8, K)> = Vec::with_capacity(claim_count);
        let mut claim_idx = 0usize;

        for (i_mem, _inst) in step.mem_insts.iter().enumerate() {
            let twist_proof = match &proofs_mem[proof_mem_offset + i_mem] {
                MemOrLutProof::Twist(proof) => proof,
                _ => return Err(PiCcsError::InvalidInput("expected Twist proof".into())),
            };
            let val = twist_proof
                .val_eval
                .as_ref()
                .ok_or_else(|| PiCcsError::InvalidInput("Twist(Route A): missing val_eval proof".into()))?;

            per_claim_rounds.push(val.rounds_lt.clone());
            per_claim_sums.push(val.claimed_inc_sum_lt);
            bind_claims.push((plan.bind_tags[claim_idx], val.claimed_inc_sum_lt));
            claim_idx += 1;

            per_claim_rounds.push(val.rounds_total.clone());
            per_claim_sums.push(val.claimed_inc_sum_total);
            bind_claims.push((plan.bind_tags[claim_idx], val.claimed_inc_sum_total));
            claim_idx += 1;

            if has_prev {
                let prev_total = val.claimed_prev_inc_sum_total.ok_or_else(|| {
                    PiCcsError::InvalidInput("Twist(Route A): missing claimed_prev_inc_sum_total".into())
                })?;
                let prev_rounds = val
                    .rounds_prev_total
                    .clone()
                    .ok_or_else(|| PiCcsError::InvalidInput("Twist(Route A): missing rounds_prev_total".into()))?;
                per_claim_rounds.push(prev_rounds);
                per_claim_sums.push(prev_total);
                bind_claims.push((plan.bind_tags[claim_idx], prev_total));
                claim_idx += 1;
            } else if val.claimed_prev_inc_sum_total.is_some() || val.rounds_prev_total.is_some() {
                return Err(PiCcsError::InvalidInput(
                    "Twist(Route A): rollover fields present but prev_step is None".into(),
                ));
            }
        }

        tr.append_message(
            b"twist/val_eval/batch_start",
            &(step.mem_insts.len() as u64).to_le_bytes(),
        );
        tr.append_message(b"twist/val_eval/step_idx", &(step_idx as u64).to_le_bytes());
        bind_twist_val_eval_claim_sums(tr, &bind_claims);

        let (r_val_out, finals_out, ok) = verify_batched_sumcheck_rounds_ds(
            tr,
            b"twist/val_eval_batch",
            step_idx,
            &per_claim_rounds,
            &per_claim_sums,
            &plan.labels,
            &plan.degree_bounds,
        );
        if !ok {
            return Err(PiCcsError::SumcheckError(
                "twist val-eval batched sumcheck invalid".into(),
            ));
        }
        if r_val_out.len() != r_time.len() {
            return Err(PiCcsError::ProtocolError(format!(
                "twist val-eval r_val.len()={}, expected ell_n={}",
                r_val_out.len(),
                r_time.len()
            )));
        }
        if finals_out.len() != claim_count {
            return Err(PiCcsError::ProtocolError(format!(
                "twist val-eval finals.len()={}, expected {}",
                finals_out.len(),
                claim_count
            )));
        }
        r_val = r_val_out;
        val_eval_finals = finals_out;

        tr.append_message(b"twist/val_eval/batch_done", &[]);
    }

    // Verify val-eval terminal identity against sidecar ME openings at r_val.
    let lt = if step.mem_insts.is_empty() {
        if !r_val.is_empty() {
            return Err(PiCcsError::ProtocolError(
                "twist val-eval produced r_val but no mem instances are present".into(),
            ));
        }
        K::ZERO
    } else {
        if r_val.len() != r_time.len() {
            return Err(PiCcsError::ProtocolError(format!(
                "twist val-eval r_val.len()={}, expected ell_n={}",
                r_val.len(),
                r_time.len()
            )));
        }
        lt_eval(&r_val, r_time)
    };

    let n_mem = step.mem_insts.len();
    let has_prev_usize = usize::from(has_prev);
    if has_prev && prev_mem_proof.is_none() {
        return Err(PiCcsError::ProtocolError(
            "prev_mem_proof missing with has_prev=true".into(),
        ));
    }
    if step.mem_insts.is_empty() {
        if !mem_proof.val_me_claims.is_empty() {
            return Err(PiCcsError::InvalidInput(
                "proof contains val-lane sidecar ME claims with no Twist instances".into(),
            ));
        }
    } else {
        let expected = n_mem
            .checked_mul(1 + has_prev_usize)
            .ok_or_else(|| PiCcsError::InvalidInput("twist val-lane claim count overflow".into()))?;
        if mem_proof.val_me_claims.len() != expected {
            return Err(PiCcsError::InvalidInput(format!(
                "shared bus expects {} sidecar ME claim(s) at r_val, got {}",
                expected,
                mem_proof.val_me_claims.len()
            )));
        }
    }

    for (i_mem, inst) in step.mem_insts.iter().enumerate() {
        let twist_proof = match &proofs_mem[proof_mem_offset + i_mem] {
            MemOrLutProof::Twist(proof) => proof,
            _ => return Err(PiCcsError::InvalidInput("expected Twist proof".into())),
        };
        let val_eval = twist_proof
            .val_eval
            .as_ref()
            .ok_or_else(|| PiCcsError::InvalidInput("Twist(Route A): missing val_eval proof".into()))?;
        let layout = inst.twist_layout();
        let ell_addr = layout
            .lanes
            .get(0)
            .ok_or_else(|| PiCcsError::InvalidInput("TwistWitnessLayout has no lanes".into()))?
            .ell_addr;
        let expected_lanes = inst.lanes.max(1);
        let lane_cols = ell_addr
            .checked_mul(2)
            .and_then(|v| v.checked_add(5))
            .ok_or_else(|| PiCcsError::ProtocolError("twist val sidecar lane width overflow".into()))?;
        let expected_sidecar_cols = expected_lanes
            .checked_mul(lane_cols)
            .ok_or_else(|| PiCcsError::ProtocolError("twist val sidecar col count overflow".into()))?;
        let sidecar_open_end = core_t
            .checked_add(expected_sidecar_cols)
            .ok_or_else(|| PiCcsError::ProtocolError("twist val sidecar opening range overflow".into()))?;

        let cur_val_idx = i_mem;
        let cur_val_me = mem_proof
            .val_me_claims
            .get(cur_val_idx)
            .ok_or_else(|| PiCcsError::ProtocolError("missing current sidecar ME claim at r_val".into()))?;
        if cur_val_me.r.as_slice() != r_val {
            return Err(PiCcsError::ProtocolError(format!(
                "Twist sidecar ME(val) r mismatch at mem_idx={i_mem}"
            )));
        }
        if cur_val_me.m_in != step.mcs_inst.m_in {
            return Err(PiCcsError::ProtocolError(format!(
                "Twist sidecar ME(val) m_in mismatch at mem_idx={i_mem}: got {}, expected {}",
                cur_val_me.m_in, step.mcs_inst.m_in
            )));
        }
        let cur_sidecar_idx = step
            .lut_insts
            .len()
            .checked_add(i_mem)
            .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar index overflow".into()))?;
        let cur_sidecar_ref = mem_proof
            .sidecar_me_claims
            .get(cur_sidecar_idx)
            .ok_or_else(|| PiCcsError::ProtocolError("missing current Twist sidecar ME claim at r_time".into()))?;
        if cur_val_me.c != cur_sidecar_ref.c {
            return Err(PiCcsError::ProtocolError(format!(
                "Twist sidecar ME(val) commitment mismatch at mem_idx={i_mem}"
            )));
        }
        if cur_val_me.y_scalars.len() < sidecar_open_end {
            return Err(PiCcsError::ProtocolError(format!(
                "Twist sidecar ME(val) y_scalars too short at mem_idx={i_mem}: need at least {sidecar_open_end}, have {}",
                cur_val_me.y_scalars.len()
            )));
        }

        let r_addr = twist_pre
            .get(i_mem)
            .ok_or_else(|| PiCcsError::InvalidInput(format!("missing Twist pre-time data at index {}", i_mem)))?
            .r_addr
            .as_slice();

        let mut inc_at_r_addr_val = K::ZERO;
        for lane_idx in 0..expected_lanes {
            let lane_base = lane_idx
                .checked_mul(lane_cols)
                .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar lane offset overflow".into()))?;
            let mut wa_bits_val_open = Vec::with_capacity(ell_addr);
            for bit_idx in 0..ell_addr {
                let local_col = lane_base
                    .checked_add(ell_addr)
                    .and_then(|v| v.checked_add(bit_idx))
                    .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar wa_bits index overflow".into()))?;
                let y_idx = core_t
                    .checked_add(local_col)
                    .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar y index overflow".into()))?;
                wa_bits_val_open.push(
                    cur_val_me.y_scalars.get(y_idx).copied().ok_or_else(|| {
                        PiCcsError::ProtocolError("Twist sidecar y_scalars missing wa_bits(val)".into())
                    })?,
                );
            }
            let has_write_y_idx = core_t
                .checked_add(lane_base + 2 * ell_addr + 1)
                .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar has_write index overflow".into()))?;
            let has_write_val_open = cur_val_me
                .y_scalars
                .get(has_write_y_idx)
                .copied()
                .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar y_scalars missing has_write(val)".into()))?;
            let inc_y_idx = core_t
                .checked_add(lane_base + 2 * ell_addr + 4)
                .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar inc index overflow".into()))?;
            let inc_at_write_addr_val_open = cur_val_me
                .y_scalars
                .get(inc_y_idx)
                .copied()
                .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar y_scalars missing inc(val)".into()))?;

            let eq_wa_val = eq_bits_prod(&wa_bits_val_open, r_addr)?;
            inc_at_r_addr_val += has_write_val_open * inc_at_write_addr_val_open * eq_wa_val;
        }

        let expected_lt_final = inc_at_r_addr_val * lt;
        let claims_per_mem = if has_prev { 3 } else { 2 };
        let base = claims_per_mem * i_mem;
        if expected_lt_final != val_eval_finals[base] {
            return Err(PiCcsError::ProtocolError(
                "twist/val_eval_lt terminal value mismatch".into(),
            ));
        }
        let expected_total_final = inc_at_r_addr_val;
        if expected_total_final != val_eval_finals[base + 1] {
            return Err(PiCcsError::ProtocolError(
                "twist/val_eval_total terminal value mismatch".into(),
            ));
        }

        if has_prev {
            let prev =
                prev_step.ok_or_else(|| PiCcsError::ProtocolError("prev_step missing with has_prev=true".into()))?;
            let prev_inst = prev
                .mem_insts
                .get(i_mem)
                .ok_or_else(|| PiCcsError::ProtocolError("missing prev mem instance".into()))?;
            let prev_mem_proof = prev_mem_proof
                .ok_or_else(|| PiCcsError::ProtocolError("prev_mem_proof missing with has_prev=true".into()))?;
            let prev_val_idx = n_mem
                .checked_add(i_mem)
                .ok_or_else(|| PiCcsError::ProtocolError("Twist prev val claim index overflow".into()))?;
            let prev_val_me = mem_proof
                .val_me_claims
                .get(prev_val_idx)
                .ok_or_else(|| PiCcsError::ProtocolError("missing prev sidecar ME claim at r_val".into()))?;
            if prev_val_me.r.as_slice() != r_val {
                return Err(PiCcsError::ProtocolError(format!(
                    "Twist sidecar ME(val/prev) r mismatch at mem_idx={i_mem}"
                )));
            }
            if prev_val_me.m_in != step.mcs_inst.m_in {
                return Err(PiCcsError::ProtocolError(format!(
                    "Twist sidecar ME(val/prev) m_in mismatch at mem_idx={i_mem}: got {}, expected {}",
                    prev_val_me.m_in, step.mcs_inst.m_in
                )));
            }
            let prev_sidecar_idx = prev
                .lut_insts
                .len()
                .checked_add(i_mem)
                .ok_or_else(|| PiCcsError::ProtocolError("Twist prev sidecar index overflow".into()))?;
            let prev_sidecar_ref = prev_mem_proof
                .sidecar_me_claims
                .get(prev_sidecar_idx)
                .ok_or_else(|| PiCcsError::ProtocolError("missing prev Twist sidecar ME claim at r_time".into()))?;
            if prev_val_me.c != prev_sidecar_ref.c {
                return Err(PiCcsError::ProtocolError(format!(
                    "Twist sidecar ME(val/prev) commitment mismatch at mem_idx={i_mem}"
                )));
            }
            if prev_val_me.y_scalars.len() < sidecar_open_end {
                return Err(PiCcsError::ProtocolError(format!(
                    "Twist sidecar ME(val/prev) y_scalars too short at mem_idx={i_mem}: need at least {sidecar_open_end}, have {}",
                    prev_val_me.y_scalars.len()
                )));
            }

            // Terminal check for prev-total: uses previous-step openings at current r_val.
            let mut inc_at_r_addr_prev = K::ZERO;
            for lane_idx in 0..expected_lanes {
                let lane_base = lane_idx
                    .checked_mul(lane_cols)
                    .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar prev lane offset overflow".into()))?;
                let mut wa_bits_prev_open = Vec::with_capacity(ell_addr);
                for bit_idx in 0..ell_addr {
                    let local_col = lane_base
                        .checked_add(ell_addr)
                        .and_then(|v| v.checked_add(bit_idx))
                        .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar prev wa_bits index overflow".into()))?;
                    let y_idx = core_t
                        .checked_add(local_col)
                        .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar prev y index overflow".into()))?;
                    wa_bits_prev_open.push(prev_val_me.y_scalars.get(y_idx).copied().ok_or_else(|| {
                        PiCcsError::ProtocolError("Twist sidecar y_scalars missing wa_bits(prev)".into())
                    })?);
                }
                let has_write_y_idx = core_t
                    .checked_add(lane_base + 2 * ell_addr + 1)
                    .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar prev has_write index overflow".into()))?;
                let has_write_prev_open = prev_val_me
                    .y_scalars
                    .get(has_write_y_idx)
                    .copied()
                    .ok_or_else(|| {
                        PiCcsError::ProtocolError("Twist sidecar y_scalars missing has_write(prev)".into())
                    })?;
                let inc_y_idx = core_t
                    .checked_add(lane_base + 2 * ell_addr + 4)
                    .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar prev inc index overflow".into()))?;
                let inc_prev_open = prev_val_me
                    .y_scalars
                    .get(inc_y_idx)
                    .copied()
                    .ok_or_else(|| PiCcsError::ProtocolError("Twist sidecar y_scalars missing inc(prev)".into()))?;

                let eq_wa_prev = eq_bits_prod(&wa_bits_prev_open, r_addr)?;
                inc_at_r_addr_prev += has_write_prev_open * inc_prev_open * eq_wa_prev;
            }
            if inc_at_r_addr_prev != val_eval_finals[base + 2] {
                return Err(PiCcsError::ProtocolError(
                    "twist/rollover_prev_total terminal value mismatch".into(),
                ));
            }

            // Enforce rollover equation: Init_i(r_addr) == Init_{i-1}(r_addr) + PrevTotal(i).
            let claimed_prev_total = val_eval
                .claimed_prev_inc_sum_total
                .ok_or_else(|| PiCcsError::ProtocolError("twist rollover missing claimed_prev_inc_sum_total".into()))?;
            let init_prev_at_r_addr = eval_init_at_r_addr(&prev_inst.init, prev_inst.k, r_addr)?;
            let init_cur_at_r_addr = eval_init_at_r_addr(&inst.init, inst.k, r_addr)?;
            if init_cur_at_r_addr != init_prev_at_r_addr + claimed_prev_total {
                return Err(PiCcsError::ProtocolError("twist rollover init check failed".into()));
            }
        }
    }

    verify_route_a_wb_wp_terminals(
        core_t,
        step,
        r_time,
        r_cycle,
        batched_final_values,
        &claim_plan,
        mem_proof,
    )?;
    verify_route_a_decode_terminals(
        core_t,
        step,
        r_time,
        r_cycle,
        batched_final_values,
        &claim_plan,
        mem_proof,
    )?;
    verify_route_a_width_terminals(
        core_t,
        step,
        r_time,
        r_cycle,
        batched_final_values,
        &claim_plan,
        mem_proof,
    )?;
    verify_route_a_control_terminals(
        core_t,
        step,
        r_time,
        r_cycle,
        batched_final_values,
        &claim_plan,
        mem_proof,
    )?;

    Ok(RouteAMemoryVerifyOutput {
        claim_idx_end: claim_plan.claim_idx_end,
        twist_time_openings,
    })
}

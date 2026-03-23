//! Per-step shard proving owner and run-state transitions.

use super::*;

pub(super) struct ShardRunState {
    accumulator: Vec<CeClaim<Cmt, F, K>>,
    accumulator_wit: Vec<Mat<F>>,
    step_proofs: Vec<StepProof>,
    val_lane_wits: Vec<Mat<F>>,
    prev_twist_decoded: Option<Vec<crate::memory_sidecar::memory::TwistDecodedColsSparse>>,
    poseidon_carry: crate::memory_sidecar::memory::PoseidonSidecarCarryState,
    output_proof: Option<neo_memory::output_check::OutputBindingProof>,
    audit_steps: Vec<StepWitnessAudit<F>>,
}

impl ShardRunState {
    pub(super) fn new(
        accumulator: Vec<CeClaim<Cmt, F, K>>,
        accumulator_wit: Vec<Mat<F>>,
        prev_twist_decoded: Option<Vec<crate::memory_sidecar::memory::TwistDecodedColsSparse>>,
        poseidon_carry: Option<crate::memory_sidecar::memory::PoseidonSidecarCarryState>,
        step_capacity: usize,
    ) -> Self {
        Self {
            accumulator,
            accumulator_wit,
            step_proofs: Vec::with_capacity(step_capacity),
            val_lane_wits: Vec::new(),
            prev_twist_decoded,
            poseidon_carry: poseidon_carry
                .unwrap_or_else(crate::memory_sidecar::memory::PoseidonSidecarCarryState::new),
            output_proof: None,
            audit_steps: Vec::with_capacity(step_capacity),
        }
    }

    pub(super) fn into_artifacts(self) -> ShardProveArtifacts {
        ShardProveArtifacts {
            proof: ShardProof {
                steps: self.step_proofs,
                output_proof: self.output_proof,
                riscv_profile: None,
                riscv_memory_layout: None,
                segment_meta: None,
            },
            final_main_wits: self.accumulator_wit,
            val_lane_wits: self.val_lane_wits,
            next_prev_twist_decoded: self.prev_twist_decoded,
            next_poseidon_carry: self.poseidon_carry,
            audit: ShardProofAudit {
                steps: self.audit_steps,
            },
        }
    }
}

pub(super) struct ShardStepEnvironment<'a, 'ctx, L, MR, MB>
where
    L: SModuleHomomorphism<F, Cmt> + Sync,
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
{
    pub tr: &'a mut Poseidon2Transcript,
    pub params: &'a NeoParams,
    pub prepared: &'a PreparedShardProveContext<'ctx>,
    pub mode: &'a FoldingMode,
    pub step: &'a StepWitnessBundle<Cmt, F, K>,
    pub step_idx: usize,
    pub is_last_step: bool,
    pub output_binding: Option<(&'a crate::output_binding::OutputBindingConfig, &'a [F])>,
    pub collect_val_lane_wits: bool,
    pub l: &'a L,
    pub mixers: CommitMixers<MR, MB>,
    pub prev_step: Option<&'a StepWitnessBundle<Cmt, F, K>>,
}

pub(super) fn prove_shard_step<L, MR, MB>(
    env: ShardStepEnvironment<'_, '_, L, MR, MB>,
    run_state: &mut ShardRunState,
) -> Result<(), PiCcsError>
where
    L: SModuleHomomorphism<F, Cmt> + Sync,
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
{
    let ShardStepEnvironment {
        tr,
        params,
        prepared,
        mode,
        step,
        step_idx,
        is_last_step,
        output_binding,
        collect_val_lane_wits,
        l,
        mixers,
        prev_step,
    } = env;

    let s = prepared.s;
    let cpu_bus = &prepared.cpu_bus;
    let dims = prepared.dims;
    let ell_d = prepared.ell_d;
    let ell_n = prepared.ell_n;
    let ell_m = prepared.ell_m;
    let ell = prepared.ell;
    let d_sc = prepared.d_sc;
    let k_dec = prepared.k_dec;
    let ring = &prepared.ring;
    let ccs_sparse_cache = prepared.ccs_sparse_cache.as_deref();

    crate::memory_sidecar::memory::absorb_step_memory_witness(tr, step);

    let include_output_binding = output_binding.is_some() && is_last_step;
    let PreparedRouteAStepMetadata {
        output_binding_proof,
        ell_t,
        time_declared_len,
        time_cpu_commitments,
        time_mem_commitments,
        has_committed_time_cpu,
        has_committed_time_mem,
        exact_reg_output_binding_active,
        ob_r_prime,
        ob_sparse_addr_weights,
    } = prepare_route_a_step_metadata(
        tr,
        params,
        step,
        step_idx,
        include_output_binding,
        output_binding,
        run_state.output_proof.is_some(),
    )?;
    if let Some(output_binding_proof) = output_binding_proof {
        run_state.output_proof = Some(output_binding_proof);
    }

    let (mcs_inst, mcs_wit) = &step.mcs;
    let k = run_state.accumulator.len() + 1;

    utils::bind_header_and_instances_with_digest(
        tr,
        params,
        s,
        core::slice::from_ref(mcs_inst),
        dims,
        &prepared.ccs_mat_digest,
    )?;
    utils::bind_me_inputs(tr, &run_state.accumulator)?;
    bind_time_column_commitments(
        tr,
        step_idx,
        step.time_columns.t,
        time_declared_len,
        &step.time_columns.col_ids,
        &time_cpu_commitments,
        &time_mem_commitments,
    );
    let mut ch = utils::sample_challenges(tr, ell_d, ell)?;
    ch.beta_m = utils::sample_beta_m(tr, ell_m)?;
    let ccs_initial_sum = claimed_initial_sum_from_inputs_with_k_mcs(s, &ch, 1, &run_state.accumulator);
    tr.append_fields(b"sumcheck/initial_sum", &ccs_initial_sum.as_coeffs());

    let poseidon_setup = build_poseidon_prover_setup(tr, params, step, step_idx, ell_n, &mut run_state.poseidon_carry)?;
    let poseidon_cycle_enabled = poseidon_setup.cycle_enabled;
    let poseidon_sidecar = poseidon_setup.sidecar;
    let mut poseidon_cycle_wit = poseidon_setup.cycle_wit;
    let poseidon_cycle_open_spec = poseidon_setup.cycle_open_spec;
    let mut poseidon_cycle_wits: Option<Vec<Mat<F>>> = None;
    let mut poseidon_cycle_open_specs: Option<Vec<(usize, usize, Vec<usize>)>> = None;
    let mut poseidon_local_wit_full = poseidon_setup.local_wit_full;
    let mut poseidon_local_wits = poseidon_setup.local_wits;
    let mut poseidon_local_open_specs = poseidon_setup.local_open_specs;
    let poseidon_local_t_len = poseidon_setup.local_t_len;
    let poseidon_local_layout = poseidon_setup.local_layout;
    let poseidon_local_ell = poseidon_setup.local_ell;
    let mut poseidon_link_chals: Option<crate::memory_sidecar::memory::PoseidonLinkChallenges> = None;
    let mut poseidon_cont_chals: Option<crate::memory_sidecar::memory::PoseidonContinuityChallenges> = None;
    if poseidon_cycle_enabled {
        let sidecar_ref = poseidon_sidecar
            .as_ref()
            .ok_or_else(|| PiCcsError::ProtocolError("missing poseidon sidecar table".into()))?;
        let cycle_open_spec = poseidon_cycle_open_spec
            .as_ref()
            .ok_or_else(|| PiCcsError::ProtocolError("missing poseidon cycle opening spec".into()))?;
        let local_t_len =
            poseidon_local_t_len.ok_or_else(|| PiCcsError::ProtocolError("missing poseidon local t_len".into()))?;
        let local_layout = poseidon_local_layout
            .as_ref()
            .ok_or_else(|| PiCcsError::ProtocolError("missing poseidon local layout".into()))?;
        let mcs_logical = neo_memory::ajtai::decode_vector_for_ccs_m(params, s.m, &mcs_wit.Z).map_err(|e| {
            PiCcsError::ProtocolError(format!(
                "failed to decode packed main witness for poseidon lane prefix (m={}): {e}",
                s.m
            ))
        })?;
        let link_chals = crate::memory_sidecar::memory::sample_poseidon_link_challenges(tr);
        let cont_chals = crate::memory_sidecar::memory::sample_poseidon_continuity_challenges(tr);

        let cycle_layout = crate::memory_sidecar::memory::PoseidonCycleTraceLayout::new();
        let cycle_wit = poseidon_cycle_wit
            .as_mut()
            .ok_or_else(|| PiCcsError::ProtocolError("missing poseidon cycle witness".into()))?;
        crate::memory_sidecar::memory::populate_poseidon_cycle_link_aux_columns(
            cycle_open_spec.1,
            cycle_wit,
            &cycle_layout,
            sidecar_ref,
            &link_chals,
            &cont_chals,
        )?;

        let local_wit = poseidon_local_wit_full
            .as_mut()
            .ok_or_else(|| PiCcsError::ProtocolError("missing poseidon local witness".into()))?;
        crate::memory_sidecar::memory::populate_poseidon_local_link_aux_column(
            local_t_len,
            local_wit,
            local_layout,
            sidecar_ref,
            &link_chals,
        )?;

        let cycle_wit_ro = poseidon_cycle_wit
            .as_ref()
            .ok_or_else(|| PiCcsError::ProtocolError("missing poseidon cycle witness".into()))?;
        let (cycle_wits_built, cycle_open_specs_built) = split_poseidon_lane_wit_by_time_cols(
            params,
            cycle_wit_ro,
            cycle_open_spec.2.as_slice(),
            cycle_open_spec.1,
            cycle_open_spec.0,
            Some(mcs_logical.as_slice()),
            s.m,
        )?;
        poseidon_cycle_wits = Some(cycle_wits_built);
        poseidon_cycle_open_specs = Some(cycle_open_specs_built);

        let local_open_cols = crate::memory_sidecar::memory::poseidon_local_open_col_ids(local_layout);
        let (local_wits_built, local_open_specs_built) = split_poseidon_lane_wit_by_time_cols(
            params,
            local_wit,
            local_open_cols.as_slice(),
            local_t_len,
            0,
            None,
            s.m,
        )?;
        poseidon_local_wits = Some(local_wits_built);
        poseidon_local_open_specs = Some(local_open_specs_built);
        poseidon_link_chals = Some(link_chals);
        poseidon_cont_chals = Some(cont_chals);
    }

    let (poseidon_cycle_commits, poseidon_local_commits) = if poseidon_cycle_enabled {
        let cycle_wits_ref = poseidon_cycle_wits
            .as_ref()
            .ok_or_else(|| PiCcsError::ProtocolError("missing poseidon cycle witness chunks".into()))?;
        let local_wits_ref = poseidon_local_wits
            .as_ref()
            .ok_or_else(|| PiCcsError::ProtocolError("missing poseidon local witness chunks".into()))?;
        let cycle_cs = commit_poseidon_lane_wits_batched(params, cycle_wits_ref, "poseidon cycle commit")?;
        let local_cs = commit_poseidon_lane_wits_batched(params, local_wits_ref, "poseidon local commit")?;
        absorb_poseidon_lane_commitments_prover(tr, &cycle_cs, &local_cs);
        (Some(cycle_cs), Some(local_cs))
    } else {
        (None, None)
    };

    let PreparedRouteATimePhase {
        mut mem_oracles,
        instruction_lookup_pre,
        twist_pre,
        r_time,
        batched_time,
    } = prove_route_a_time_phase(
        tr,
        params,
        cpu_bus,
        step,
        step_idx,
        ell_t,
        ell_n,
        include_output_binding,
        output_binding.map(|(cfg, _)| cfg),
        exact_reg_output_binding_active,
        ob_r_prime,
        ob_sparse_addr_weights,
        poseidon_cycle_enabled,
        poseidon_sidecar.as_ref(),
        poseidon_cycle_wit.as_ref(),
        poseidon_cycle_open_spec.as_ref(),
        poseidon_link_chals.as_ref(),
        poseidon_cont_chals.as_ref(),
    )?;

    let mut ccs_oracle: CcsOracleDispatch<'_> = match mode.clone() {
        FoldingMode::Optimized => {
            let sparse = prepared
                .ccs_sparse_cache
                .as_ref()
                .ok_or_else(|| PiCcsError::ProtocolError("missing SparseCache for optimized mode".into()))?;
            CcsOracleDispatch::Optimized(
                neo_reductions::engines::optimized_engine::oracle::OptimizedOracle::new_with_sparse(
                    s,
                    params,
                    core::slice::from_ref(mcs_wit),
                    &run_state.accumulator_wit,
                    ch.clone(),
                    ell_d,
                    ell_n,
                    d_sc,
                    run_state.accumulator.first().map(|mi| mi.r.as_slice()),
                    sparse.clone(),
                ),
            )
        }
        #[cfg(feature = "paper-exact")]
        FoldingMode::PaperExact => CcsOracleDispatch::PaperExact(
            neo_reductions::engines::paper_exact_engine::oracle::PaperExactOracle::new(
                s,
                params,
                core::slice::from_ref(mcs_wit),
                &run_state.accumulator_wit,
                ch.clone(),
                ell_d,
                ell_n,
                d_sc,
                run_state.accumulator.first().map(|mi| mi.r.as_slice()),
            ),
        ),
        #[cfg(feature = "paper-exact")]
        FoldingMode::OptimizedWithCrosscheck(_) => {
            let sparse = prepared
                .ccs_sparse_cache
                .as_ref()
                .ok_or_else(|| PiCcsError::ProtocolError("missing SparseCache for optimized mode".into()))?;
            CcsOracleDispatch::Optimized(
                neo_reductions::engines::optimized_engine::oracle::OptimizedOracle::new_with_sparse(
                    s,
                    params,
                    core::slice::from_ref(mcs_wit),
                    &run_state.accumulator_wit,
                    ch.clone(),
                    ell_d,
                    ell_n,
                    d_sc,
                    run_state.accumulator.first().map(|mi| mi.r.as_slice()),
                    sparse.clone(),
                ),
            )
        }
    };

    let poseidon_local_artifacts = prove_poseidon_local_time_artifacts(
        tr,
        step_idx,
        poseidon_cycle_enabled,
        poseidon_local_ell,
        poseidon_local_open_specs.as_ref(),
        poseidon_local_t_len,
        poseidon_local_layout,
        poseidon_local_wit_full.as_ref(),
        poseidon_link_chals.as_ref(),
    )?;
    let poseidon_local_time = poseidon_local_artifacts.local_time;
    let poseidon_r_local = poseidon_local_artifacts.r_local;
    ensure_poseidon_link_sums_match(poseidon_cycle_enabled, &batched_time, poseidon_local_time.as_ref())?;

    let mut ccs_time = RoundOraclePrefix::new(&mut ccs_oracle, ell_n);
    let (ccs_time_rounds, ccs_time_chals) =
        run_sumcheck_prover_ds(tr, b"ccs/time", step_idx, &mut ccs_time, ccs_initial_sum)?;
    let mut ajtai_initial_sum = ccs_initial_sum;
    for (round_poly, &r_i) in ccs_time_rounds.iter().zip(ccs_time_chals.iter()) {
        ajtai_initial_sum = poly_eval_k(round_poly, r_i);
    }
    let ccs_time_rounds_meta = ccs_time_rounds.clone();
    let ccs_time_chals_meta = ccs_time_chals.clone();
    let mut sumcheck_rounds = ccs_time_rounds;
    let mut sumcheck_chals = ccs_time_chals;

    let mut ccs_ajtai = RoundOraclePrefix::new(&mut ccs_oracle, ell_d);
    let (ajtai_rounds, ajtai_chals) =
        run_sumcheck_prover_ds(tr, b"ccs/ajtai", step_idx, &mut ccs_ajtai, ajtai_initial_sum)?;
    let mut running_sum = ajtai_initial_sum;
    for (round_poly, &r_i) in ajtai_rounds.iter().zip(ajtai_chals.iter()) {
        running_sum = poly_eval_k(round_poly, r_i);
    }
    sumcheck_rounds.extend_from_slice(&ajtai_rounds);
    sumcheck_chals.extend_from_slice(&ajtai_chals);

    let mut ccs_nc_oracle = neo_reductions::engines::optimized_engine::oracle::NcOracle::new(
        s,
        params,
        core::slice::from_ref(mcs_wit),
        &run_state.accumulator_wit,
        ch.clone(),
        ell_d,
        ell_m,
        d_sc,
    );
    let (sumcheck_rounds_nc, sumcheck_chals_nc) =
        run_sumcheck_prover_ds(tr, b"ccs/nc", step_idx, &mut ccs_nc_oracle, K::ZERO)?;
    let mut running_sum_nc = K::ZERO;
    for (round_poly, &r_i) in sumcheck_rounds_nc.iter().zip(sumcheck_chals_nc.iter()) {
        running_sum_nc = poly_eval_k(round_poly, r_i);
    }
    let (s_col, _alpha_prime_nc) = sumcheck_chals_nc.split_at(ell_m);

    let fold_digest = tr.digest32();
    let mut ccs_out = match &mut ccs_oracle {
        CcsOracleDispatch::Optimized(oracle) => oracle.build_me_outputs_from_ajtai_precomp(
            core::slice::from_ref(mcs_inst),
            &run_state.accumulator,
            s_col,
            fold_digest,
            l,
        ),
        #[cfg(feature = "paper-exact")]
        CcsOracleDispatch::PaperExact(_) => build_me_outputs_paper_exact(
            s,
            params,
            core::slice::from_ref(mcs_inst),
            core::slice::from_ref(mcs_wit),
            &run_state.accumulator,
            &run_state.accumulator_wit,
            &ccs_time_chals_meta,
            s_col,
            ell_d,
            fold_digest,
            l,
        ),
    };
    drop(ccs_oracle);

    let mut trace_linkage_t_len: Option<usize> = None;
    let mut named_trace_col_ids: Vec<usize> = Vec::new();
    let core_t = s.t();

    if cpu_bus.bus_cols > 0 {
        if ccs_out.len() != 1 + run_state.accumulator_wit.len() {
            return Err(PiCcsError::ProtocolError(format!(
                "CCS output count mismatch for bus openings (ccs_out.len()={}, expected {})",
                ccs_out.len(),
                1 + run_state.accumulator_wit.len()
            )));
        }

        let can_use_time_mem_cols =
            step.time_columns.t == cpu_bus.chunk_size && step.time_columns.mem_cols.len() == cpu_bus.bus_cols;
        if !can_use_time_mem_cols {
            return Err(PiCcsError::ProtocolError(format!(
                "shared bus openings require canonical time mem columns (time_t={}, mem_cols={}, chunk_size={}, bus_cols={})",
                step.time_columns.t,
                step.time_columns.mem_cols.len(),
                cpu_bus.chunk_size,
                cpu_bus.bus_cols
            )));
        }
        let out0_supports_bus_point =
            crate::memory_sidecar::cpu_bus::point_covers_bus_time_rows(cpu_bus, ccs_out[0].r.as_slice())?;
        if out0_supports_bus_point {
            crate::memory_sidecar::cpu_bus::append_bus_openings_to_me_instance_from_time_columns(
                params,
                cpu_bus,
                core_t,
                &step.time_columns.mem_cols,
                &mut ccs_out[0],
            )?;
        } else {
            crate::memory_sidecar::cpu_bus::append_zero_bus_openings_to_me_instance(
                params,
                cpu_bus,
                core_t,
                &mut ccs_out[0],
            )?;
        }
        for (out, z) in ccs_out
            .iter_mut()
            .skip(1)
            .zip(run_state.accumulator_wit.iter())
        {
            let out_supports_bus_point =
                crate::memory_sidecar::cpu_bus::point_covers_bus_time_rows(cpu_bus, out.r.as_slice())?;
            if z.cols() == cpu_bus.m && out_supports_bus_point {
                crate::memory_sidecar::cpu_bus::append_bus_openings_to_me_instance(params, cpu_bus, core_t, z, out)?;
            } else {
                crate::memory_sidecar::cpu_bus::append_zero_bus_openings_to_me_instance(params, cpu_bus, core_t, out)?;
            }
        }
    }

    if crate::memory_sidecar::memory::trace_opening_path_required_for_step_witness(step) && mcs_inst.m_in == 5 {
        let m_in = mcs_inst.m_in;
        let t_len = (step.time_columns.t > 0 && !step.time_columns.cpu_cols.is_empty())
            .then_some(step.time_columns.t)
            .or_else(|| step.mem_instances.first().map(|(inst, _)| inst.steps))
            .or_else(|| step.lut_instances.first().map(|(inst, _)| inst.steps))
            .or_else(|| Some(step.time_columns.t))
            .ok_or_else(|| PiCcsError::InvalidInput("missing mem/lut instances".into()))?;
        if t_len == 0 {
            return Err(PiCcsError::InvalidInput("trace linkage requires steps>=1".into()));
        }
        for (i, (inst, _)) in step.mem_instances.iter().enumerate() {
            if inst.steps != t_len {
                return Err(PiCcsError::InvalidInput(format!(
                    "trace linkage requires stable steps across mem instances (mem_idx={i} has steps={}, expected {t_len})",
                    inst.steps
                )));
            }
        }

        let trace = neo_memory::riscv::trace::Rv64TraceLayout::new();
        let (trace_cols_to_open_dense, trace_cols_to_open_shout): (Vec<usize>, Vec<usize>) = (
            vec![
                trace.active,
                trace.cycle,
                trace.pc_before,
                trace.instr_word,
                trace.rs1_addr,
                trace.rs1_val,
                trace.rs2_addr,
                trace.rs2_val,
                trace.rd_addr,
                trace.rd_val,
                trace.ram_addr,
                trace.ram_rv,
                trace.ram_wv,
            ],
            vec![
                trace.shout_has_lookup,
                trace.shout_val,
                trace.shout_link_lhs,
                trace.shout_link_rhs,
                trace.shout_add_sub_key,
            ],
        );
        let trace_cols_to_open_all: Vec<usize> = trace_cols_to_open_dense
            .iter()
            .chain(trace_cols_to_open_shout.iter())
            .copied()
            .collect();
        let shout_has_lookup_col = *trace_cols_to_open_shout
            .first()
            .ok_or_else(|| PiCcsError::ProtocolError("trace linkage requires shout opening columns".into()))?;
        let trace_open_base = core_t + cpu_bus.bus_cols;
        let can_use_time_cpu_cols = step.time_columns.t == t_len
            && !step.time_columns.cpu_cols.is_empty()
            && trace_cols_to_open_all
                .iter()
                .all(|&col_id| col_id < step.time_columns.cpu_cols.len());
        if !can_use_time_cpu_cols {
            return Err(PiCcsError::ProtocolError(format!(
                "route-a trace openings require canonical time CPU columns (time_t={}, cpu_cols={}, expected_t={t_len}, max_trace_col={})",
                step.time_columns.t,
                step.time_columns.cpu_cols.len(),
                trace_cols_to_open_all.iter().copied().max().unwrap_or(0)
            )));
        }

        let active_shout_js: Vec<usize> = step.time_columns.cpu_cols[shout_has_lookup_col]
            .iter()
            .enumerate()
            .filter_map(|(j, v)| (*v != F::ZERO).then_some(j))
            .collect();

        crate::memory_sidecar::cpu_bus::append_time_columns_openings_to_me_instance(
            params,
            m_in,
            t_len,
            &step.time_columns.cpu_cols,
            &trace_cols_to_open_dense,
            trace_open_base,
            &mut ccs_out[0],
        )?;
        crate::memory_sidecar::cpu_bus::append_time_columns_openings_to_me_instance_at_js(
            params,
            m_in,
            t_len,
            &step.time_columns.cpu_cols,
            &trace_cols_to_open_shout,
            trace_open_base + trace_cols_to_open_dense.len(),
            &mut ccs_out[0],
            &active_shout_js,
        )?;

        for out in ccs_out.iter_mut().skip(1) {
            crate::memory_sidecar::cpu_bus::append_zero_time_openings_to_me_instance(
                params,
                trace_cols_to_open_all.len(),
                trace_open_base,
                out,
            )?;
        }
        named_trace_col_ids.extend(trace_cols_to_open_all.iter().copied());
        trace_linkage_t_len = Some(t_len);
    }

    if ccs_out.len() != k {
        return Err(PiCcsError::ProtocolError(format!(
            "Π_CCS returned {} outputs; expected k={k}",
            ccs_out.len()
        )));
    }

    let mut ccs_proof = crate::PiCcsProof::new(sumcheck_rounds, Some(ccs_initial_sum));
    ccs_proof.variant = crate::optimized_engine::PiCcsProofVariant::SplitNcV1;
    ccs_proof.sumcheck_challenges = sumcheck_chals;
    ccs_proof.sumcheck_rounds_nc = sumcheck_rounds_nc;
    ccs_proof.sc_initial_sum_nc = Some(K::ZERO);
    ccs_proof.sumcheck_challenges_nc = sumcheck_chals_nc;
    ccs_proof.challenges_public = ch;
    ccs_proof.sumcheck_final = running_sum;
    ccs_proof.sumcheck_final_nc = running_sum_nc;
    ccs_proof.header_digest = fold_digest.to_vec();

    #[cfg(feature = "paper-exact")]
    if let FoldingMode::OptimizedWithCrosscheck(cfg) = mode {
        crosscheck_route_a_ccs_step(
            cfg,
            step_idx,
            params,
            s,
            cpu_bus,
            mcs_inst,
            mcs_wit,
            &run_state.accumulator,
            &run_state.accumulator_wit,
            &ccs_out,
            &ccs_proof,
            ell_d,
            ell_n,
            ell_m,
            d_sc,
            fold_digest,
            l,
        )?;
    }

    let mut outs_z: Vec<&Mat<F>> = Vec::with_capacity(k);
    outs_z.push(&mcs_wit.Z);
    outs_z.extend(run_state.accumulator_wit.iter());

    let mut mem_proof = crate::memory_sidecar::memory::finalize_route_a_memory_prover(
        tr,
        params,
        cpu_bus,
        s,
        step,
        prev_step,
        run_state.prev_twist_decoded.as_deref(),
        &mut mem_oracles,
        &instruction_lookup_pre.addr_pre,
        &twist_pre,
        &r_time,
        mcs_inst.m_in,
        step_idx,
    )?;
    run_state.prev_twist_decoded = Some(twist_pre.into_iter().map(|p| p.decoded).collect());

    for me in mem_proof.val_me_claims.iter_mut() {
        let t = me.y_ring.len();
        normalize_me_claims(core::slice::from_mut(me), ell_t, ell_d, t)?;
    }
    for me in mem_proof.booleanity_me_claims.iter_mut() {
        let t = me.y_ring.len();
        normalize_me_claims(core::slice::from_mut(me), ell_t, ell_d, t)?;
    }
    for me in mem_proof.trace_opening_me_claims.iter_mut() {
        let t = me.y_ring.len();
        normalize_me_claims(core::slice::from_mut(me), ell_t, ell_d, t)?;
    }
    emit_poseidon_me_claims(
        tr,
        params,
        s,
        &r_time,
        ell_t,
        ell_d,
        &mut mem_proof,
        PoseidonMeClaimsInputs {
            poseidon_cycle_enabled,
            poseidon_cycle_wits: poseidon_cycle_wits.as_ref(),
            poseidon_cycle_commits: poseidon_cycle_commits.as_ref(),
            poseidon_cycle_open_specs: poseidon_cycle_open_specs.as_ref(),
            poseidon_local_wits: poseidon_local_wits.as_ref(),
            poseidon_local_commits: poseidon_local_commits.as_ref(),
            poseidon_local_open_specs: poseidon_local_open_specs.as_ref(),
            poseidon_local_t_len,
            poseidon_local_layout,
            poseidon_r_local: poseidon_r_local.as_ref(),
        },
    )?;
    validate_me_batch_invariants(&ccs_out, "prove step ccs outputs")?;

    let want_main_wits = collect_val_lane_wits || !is_last_step;
    let (main_fold, main_child_wits, main_parent_wit) = prove_rlc_dec_lane(
        mode,
        RlcLane::Main,
        tr,
        params,
        s,
        ccs_sparse_cache,
        Some(cpu_bus),
        ring,
        ell_d,
        k_dec,
        step_idx,
        trace_linkage_t_len,
        &ccs_out,
        &outs_z,
        want_main_wits,
        l,
        mixers,
    )?;
    let RlcDecProof {
        rlc_rhos: rhos,
        rlc_parent: parent_pub,
        dec_children: children,
    } = main_fold;
    let main_lane_audit = LaneWitnessAudit::new(
        outs_z.iter().map(|wit| (*wit).clone()).collect(),
        main_parent_wit,
        main_child_wits.clone(),
    );

    let val_lane = prove_val_lane(
        tr,
        params,
        s,
        mode,
        ccs_sparse_cache,
        cpu_bus,
        ring,
        ell_d,
        k_dec,
        step_idx,
        mem_proof.val_me_claims.as_slice(),
        &mcs_wit.Z,
        prev_step,
        collect_val_lane_wits,
        &mut run_state.val_lane_wits,
        l,
        mixers,
    )?;

    let mut booleanity_fold = Vec::new();
    let mut booleanity_lane_audits = Vec::new();
    if !mem_proof.booleanity_me_claims.is_empty() {
        let trace = neo_memory::riscv::trace::Rv64TraceLayout::new();
        let booleanity_cols = crate::memory_sidecar::memory::rv64_trace_booleanity_columns(&trace);
        let booleanity_lane = prove_aux_cpu_me_lane(
            AuxCpuLaneConfig {
                start_label: b"fold/booleanity_lane_start",
                claim_idx_label: b"fold/booleanity_lane_claim_idx",
                lane_name: "booleanity",
                opening_cols: booleanity_cols.as_slice(),
                claims: mem_proof.booleanity_me_claims.as_slice(),
            },
            tr,
            params,
            s,
            mode,
            ccs_sparse_cache,
            ring,
            ell_d,
            k_dec,
            step_idx,
            core_t,
            &mcs_wit.Z,
            (mcs_inst.c.d, mcs_inst.c.kappa),
            collect_val_lane_wits,
            &mut run_state.val_lane_wits,
            l,
            mixers,
        )?;
        booleanity_fold = booleanity_lane.proofs;
        booleanity_lane_audits = booleanity_lane.audits;
    }

    let mut trace_opening_fold = Vec::new();
    let mut trace_opening_lane_audits = Vec::new();
    if !mem_proof.trace_opening_me_claims.is_empty() {
        let mut trace_opening_cols = crate::memory_sidecar::memory::rv64_trace_opening_columns(
            &neo_memory::riscv::trace::Rv64TraceLayout::new(),
        );
        trace_opening_cols.extend(crate::memory_sidecar::memory::rv64_trace_exact_word_opening_columns());

        let trace_opening_lane = prove_aux_cpu_me_lane(
            AuxCpuLaneConfig {
                start_label: b"fold/trace_opening_lane_start",
                claim_idx_label: b"fold/trace_opening_lane_claim_idx",
                lane_name: "trace_opening",
                opening_cols: trace_opening_cols.as_slice(),
                claims: mem_proof.trace_opening_me_claims.as_slice(),
            },
            tr,
            params,
            s,
            mode,
            ccs_sparse_cache,
            ring,
            ell_d,
            k_dec,
            step_idx,
            core_t,
            &mcs_wit.Z,
            (mcs_inst.c.d, mcs_inst.c.kappa),
            collect_val_lane_wits,
            &mut run_state.val_lane_wits,
            l,
            mixers,
        )?;
        trace_opening_fold = trace_opening_lane.proofs;
        trace_opening_lane_audits = trace_opening_lane.audits;
    }

    let poseidon_fold_lanes = prove_poseidon_fold_lanes(
        mode,
        tr,
        params,
        s,
        ccs_sparse_cache,
        ring,
        ell_d,
        step_idx,
        &mem_proof,
        poseidon_cycle_wits.as_ref(),
        poseidon_cycle_open_specs.as_ref(),
        poseidon_local_wits.as_ref(),
        poseidon_local_open_specs.as_ref(),
        l,
        mixers,
    )?;
    let poseidon_cycle_fold = poseidon_fold_lanes.cycle_fold;
    let poseidon_local_fold = poseidon_fold_lanes.local_fold;

    run_state.accumulator = children.clone();
    run_state.accumulator_wit = if want_main_wits { main_child_wits } else { Vec::new() };

    let openings_phase = prove_openings_phase(
        tr,
        OpeningsPhaseContext {
            params,
            mode,
            cpu_bus,
            ring,
            ell_d,
            k_dec,
            step_idx,
            r_time: &r_time,
            named_trace_col_ids: named_trace_col_ids.as_slice(),
            time_cpu_commitments: time_cpu_commitments.as_slice(),
            time_mem_commitments: time_mem_commitments.as_slice(),
            has_committed_time_cpu,
            has_committed_time_mem,
            exact_reg_output_binding_active,
            mixers,
        },
        step,
        &mem_proof,
    )?;

    let cpu_sumcheck = cpu_sumcheck_from_ccs(ccs_initial_sum, ccs_time_rounds_meta, &ccs_time_chals_meta);
    run_state.step_proofs.push(StepProof {
        fold: FoldStep {
            ccs_out,
            ccs_proof,
            rlc_rhos: rhos,
            rlc_parent: parent_pub,
            dec_children: children,
            cpu_sumcheck,
            time_cpu_commitments,
            time_mem_commitments,
            time_t: step.time_columns.t,
            time_declared_len,
            time_col_ids: step.time_columns.col_ids.clone(),
            memory_time_proofs: batched_time.labels.clone(),
            openings: openings_phase.fold_openings,
            opening_proofs: openings_phase.opening_proofs,
            opening_manifest: openings_phase.opening_manifest,
            opening_reduction: openings_phase.opening_reduction,
            opening_unification: openings_phase.opening_unification,
            joint_opening_lane: openings_phase.joint_opening_lane,
            folding_lanes: crate::shard_proof_types::FoldingLanes {
                main_children: run_state.accumulator.len(),
                val_children: val_lane.proofs.iter().map(|p| p.dec_children.len()).sum(),
                booleanity_children: booleanity_fold.iter().map(|p| p.dec_children.len()).sum(),
                trace_opening_children: trace_opening_fold
                    .iter()
                    .map(|p| p.dec_children.len())
                    .sum(),
                joint_opening_children: openings_phase
                    .joint_opening_fold
                    .iter()
                    .map(|p| p.dec_children.len())
                    .sum(),
            },
        },
        mem: mem_proof,
        batched_time,
        poseidon_local_time,
        poseidon_cycle_fold,
        poseidon_local_fold,
        val_fold: val_lane.proofs,
        booleanity_fold,
        trace_opening_fold,
        compressed_substeps: None,
        joint_opening_fold: openings_phase.joint_opening_fold,
    });
    run_state.audit_steps.push(StepWitnessAudit::new(
        main_lane_audit,
        val_lane.audits,
        booleanity_lane_audits,
        trace_opening_lane_audits,
    ));

    tr.append_message(b"fold/step_done", &(step_idx as u64).to_le_bytes());
    Ok(())
}

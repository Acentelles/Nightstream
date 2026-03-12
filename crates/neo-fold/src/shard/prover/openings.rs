//! Named-opening and stage-8 proving phase for shard folding.

use super::*;

pub(super) struct OpeningsPhaseContext<'a, MR, MB>
where
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt,
    MB: Fn(&[Cmt], u32) -> Cmt,
{
    pub params: &'a NeoParams,
    pub mode: &'a FoldingMode,
    pub cpu_bus: &'a neo_memory::cpu::BusLayout,
    pub ring: &'a ccs::RotRing,
    pub ell_d: usize,
    pub k_dec: usize,
    pub step_idx: usize,
    pub r_time: &'a [K],
    pub named_trace_col_ids: &'a [usize],
    pub time_cpu_commitments: &'a [Cmt],
    pub time_mem_commitments: &'a [Cmt],
    pub has_committed_time_cpu: bool,
    pub has_committed_time_mem: bool,
    pub control_required: bool,
    pub exact_reg_output_binding_active: bool,
    pub mixers: CommitMixers<MR, MB>,
}

pub(super) struct OpeningsPhaseResult {
    pub fold_openings: Vec<crate::shard_proof_types::TimePointOpening>,
    pub opening_proofs: Vec<crate::shard_proof_types::TimeOpeningProof>,
    pub opening_manifest: crate::shard_proof_types::OpeningClaimManifest,
    pub opening_reduction: crate::shard_proof_types::OpeningReductionProof,
    pub opening_unification: crate::shard_proof_types::OpeningUnificationProof,
    pub joint_opening_lane: crate::shard_proof_types::JointOpeningLaneProof,
    pub stage8_fold: Vec<RlcDecProof>,
}

#[allow(clippy::too_many_arguments)]
pub(super) fn prove_openings_phase<MR, MB>(
    tr: &mut Poseidon2Transcript,
    ctx: OpeningsPhaseContext<'_, MR, MB>,
    step: &StepWitnessBundle<Cmt, F, K>,
    mem_proof: &MemSidecarProof<Cmt, F, K>,
) -> Result<OpeningsPhaseResult, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
{
    let OpeningsPhaseContext {
        params,
        mode,
        cpu_bus,
        ring,
        ell_d,
        k_dec,
        step_idx,
        r_time,
        named_trace_col_ids,
        time_cpu_commitments,
        time_mem_commitments,
        has_committed_time_cpu,
        has_committed_time_mem,
        control_required,
        exact_reg_output_binding_active,
        mixers,
    } = ctx;
    let mcs_inst = &step.mcs.0;

    let fold_openings = {
        let mut out = Vec::new();
        if cpu_bus.bus_cols > 0 {
            let cpu_cols_len = step.time_columns.cpu_cols.len();
            let mem_cols_len = step.time_columns.mem_cols.len();
            let expected_logical_cols = cpu_cols_len
                .checked_add(mem_cols_len)
                .ok_or_else(|| PiCcsError::InvalidInput("named openings bus: cpu_cols + mem_cols overflow".into()))?;
            let has_logical_bus_ids =
                mem_cols_len == cpu_bus.bus_cols && step.time_columns.col_ids.len() == expected_logical_cols;
            if !has_logical_bus_ids {
                return Err(PiCcsError::ProtocolError(format!(
                    "named openings bus: canonical committed mode requires logical bus ids (col_ids={}, cpu_cols={}, mem_cols={}, bus_cols={})",
                    step.time_columns.col_ids.len(),
                    cpu_cols_len,
                    mem_cols_len,
                    cpu_bus.bus_cols
                )));
            }
            let col_ids: Vec<usize> = step.time_columns.col_ids[cpu_cols_len..].to_vec();
            let can_use_time_mem_cols =
                step.time_columns.t == cpu_bus.chunk_size && step.time_columns.mem_cols.len() == cpu_bus.bus_cols;
            if !can_use_time_mem_cols {
                return Err(PiCcsError::ProtocolError(format!(
                    "named openings bus: canonical time mem columns are required (time_t={}, mem_cols={}, expected chunk_size={}, bus_cols={})",
                    step.time_columns.t,
                    step.time_columns.mem_cols.len(),
                    cpu_bus.chunk_size,
                    cpu_bus.bus_cols
                )));
            }
            if !has_committed_time_mem {
                return Err(PiCcsError::ProtocolError(
                    "named openings bus: canonical time-column path requires committed time mem columns".into(),
                ));
            }
            let open_map = crate::memory_sidecar::cpu_bus::shared_bus_openings_from_time_columns_at_point(
                cpu_bus,
                &step.time_columns.mem_cols,
                r_time,
                "named openings bus",
            )?;
            let mut evals = Vec::with_capacity(col_ids.len());
            for (mem_local_col, _) in col_ids.iter().enumerate() {
                let v = open_map.get(&mem_local_col).copied().ok_or_else(|| {
                    PiCcsError::ProtocolError(format!("named openings bus: missing mem local col_id={mem_local_col}"))
                })?;
                evals.push(v);
            }
            out.push(crate::shard_proof_types::TimePointOpening {
                point: r_time.to_vec(),
                col_ids: col_ids.clone(),
                evals,
                source: crate::shard_proof_types::TimeOpeningSource::CommittedOpening,
            });

            if let Some(cpu_me_val_cur) = mem_proof.val_me_claims.first() {
                if cpu_me_val_cur.r.as_slice() != r_time {
                    let open_map = crate::memory_sidecar::cpu_bus::shared_bus_openings_from_time_columns_at_point(
                        cpu_bus,
                        &step.time_columns.mem_cols,
                        cpu_me_val_cur.r.as_slice(),
                        "named openings bus/val",
                    )?;
                    let mut evals = Vec::with_capacity(col_ids.len());
                    for (mem_local_col, _) in col_ids.iter().enumerate() {
                        let v = open_map.get(&mem_local_col).copied().ok_or_else(|| {
                            PiCcsError::ProtocolError(format!(
                                "named openings bus/val: missing mem local col_id={mem_local_col}"
                            ))
                        })?;
                        evals.push(v);
                    }
                    out.push(crate::shard_proof_types::TimePointOpening {
                        point: cpu_me_val_cur.r.clone(),
                        col_ids,
                        evals,
                        source: crate::shard_proof_types::TimeOpeningSource::CommittedOpening,
                    });
                }
            }
        }
        if !named_trace_col_ids.is_empty() {
            let can_use_time_cpu_cols = step.time_columns.t > 0
                && !step.time_columns.cpu_cols.is_empty()
                && named_trace_col_ids
                    .iter()
                    .all(|&col_id| col_id < step.time_columns.cpu_cols.len());
            if !can_use_time_cpu_cols {
                return Err(PiCcsError::ProtocolError(format!(
                    "named openings trace: canonical time cpu columns are required (time_t={}, cpu_cols={}, trace_cols={})",
                    step.time_columns.t,
                    step.time_columns.cpu_cols.len(),
                    named_trace_col_ids.len()
                )));
            }
            if !has_committed_time_cpu {
                return Err(PiCcsError::ProtocolError(
                    "named openings trace: canonical time-column path requires committed time cpu columns".into(),
                ));
            }
            let trace_map = crate::memory_sidecar::cpu_bus::time_columns_openings_from_time_columns_at_point(
                mcs_inst.m_in,
                step.time_columns.t,
                &step.time_columns.cpu_cols,
                named_trace_col_ids,
                r_time,
                "named openings trace",
            )?;
            let mut evals = Vec::with_capacity(named_trace_col_ids.len());
            for &col_id in named_trace_col_ids.iter() {
                let v = trace_map.get(&col_id).copied().ok_or_else(|| {
                    PiCcsError::ProtocolError(format!("named openings trace: missing col_id={col_id}"))
                })?;
                evals.push(v);
            }
            out.push(crate::shard_proof_types::TimePointOpening {
                point: r_time.to_vec(),
                col_ids: named_trace_col_ids.to_vec(),
                evals,
                source: crate::shard_proof_types::TimeOpeningSource::CommittedOpening,
            });
        }
        if let Some(wb_me) = mem_proof.wb_me_claims.first() {
            let trace = Rv32TraceLayout::new();
            let wb_cols = crate::memory_sidecar::memory::riscv_trace_wb_columns(&trace);
            let can_use_time_cpu_cols = step.time_columns.t > 0
                && !step.time_columns.cpu_cols.is_empty()
                && wb_cols
                    .iter()
                    .all(|&col_id| col_id < step.time_columns.cpu_cols.len());
            if !can_use_time_cpu_cols {
                return Err(PiCcsError::ProtocolError(format!(
                    "named openings wb: canonical time cpu columns are required (time_t={}, cpu_cols={}, wb_cols={})",
                    step.time_columns.t,
                    step.time_columns.cpu_cols.len(),
                    wb_cols.len()
                )));
            }
            if !has_committed_time_cpu {
                return Err(PiCcsError::ProtocolError(
                    "named openings wb: canonical time-column path requires committed time cpu columns".into(),
                ));
            }
            let trace_map = crate::memory_sidecar::cpu_bus::time_columns_openings_from_time_columns_at_point(
                mcs_inst.m_in,
                step.time_columns.t,
                &step.time_columns.cpu_cols,
                &wb_cols,
                wb_me.r.as_slice(),
                "named openings wb",
            )?;
            let mut evals = Vec::with_capacity(wb_cols.len());
            for &col_id in wb_cols.iter() {
                let v = trace_map
                    .get(&col_id)
                    .copied()
                    .ok_or_else(|| PiCcsError::ProtocolError(format!("named openings wb: missing col_id={col_id}")))?;
                evals.push(v);
            }
            out.push(crate::shard_proof_types::TimePointOpening {
                point: wb_me.r.clone(),
                col_ids: wb_cols,
                evals,
                source: crate::shard_proof_types::TimeOpeningSource::CommittedOpening,
            });
        }
        if let Some(wp_me) = mem_proof.wp_me_claims.first() {
            let trace = Rv32TraceLayout::new();
            let rv64_exact_words =
                crate::memory_sidecar::memory::trace_uses_rv64_exact_words(step.time_columns.cpu_cols.len());
            let mut wp_cols = crate::memory_sidecar::memory::riscv_trace_wp_opening_columns(&trace);
            if rv64_exact_words {
                wp_cols.extend(crate::memory_sidecar::memory::rv64_trace_exact_word_opening_columns());
            }
            if control_required {
                wp_cols.extend(crate::memory_sidecar::memory::riscv_trace_control_extra_opening_columns(&trace));
            }
            if crate::memory_sidecar::memory::rv64_fullword_width_stage_required_for_step_witness(step) {
                wp_cols.extend(crate::memory_sidecar::memory::rv64_fullword_wp_opening_columns());
            }
            let mut seen_wp_cols = std::collections::BTreeSet::new();
            wp_cols.retain(|col_id| seen_wp_cols.insert(*col_id));
            let can_use_time_cpu_cols = step.time_columns.t > 0
                && !step.time_columns.cpu_cols.is_empty()
                && wp_cols
                    .iter()
                    .all(|&col_id| col_id < step.time_columns.cpu_cols.len());
            if !can_use_time_cpu_cols {
                return Err(PiCcsError::ProtocolError(format!(
                    "named openings wp: canonical time cpu columns are required (time_t={}, cpu_cols={}, wp_cols={})",
                    step.time_columns.t,
                    step.time_columns.cpu_cols.len(),
                    wp_cols.len()
                )));
            }
            if !has_committed_time_cpu {
                return Err(PiCcsError::ProtocolError(
                    "named openings wp: canonical time-column path requires committed time cpu columns".into(),
                ));
            }
            let trace_map = crate::memory_sidecar::cpu_bus::time_columns_openings_from_time_columns_at_point(
                mcs_inst.m_in,
                step.time_columns.t,
                &step.time_columns.cpu_cols,
                &wp_cols,
                wp_me.r.as_slice(),
                "named openings wp",
            )?;
            let mut evals = Vec::with_capacity(wp_cols.len());
            for &col_id in wp_cols.iter() {
                let v = trace_map
                    .get(&col_id)
                    .copied()
                    .ok_or_else(|| PiCcsError::ProtocolError(format!("named openings wp: missing col_id={col_id}")))?;
                evals.push(v);
            }
            out.push(crate::shard_proof_types::TimePointOpening {
                point: wp_me.r.clone(),
                col_ids: wp_cols,
                evals,
                source: crate::shard_proof_types::TimeOpeningSource::CommittedOpening,
            });
        }
        if exact_reg_output_binding_active {
            let trace = neo_memory::riscv::trace::Rv64TraceLayout::new();
            let reg_exact_cols = vec![
                trace.rd_addr,
                trace.rd_has_write,
                trace.is_virtual,
                trace.rd_val_lo32,
                trace.rd_val_hi32,
            ];
            let can_use_time_cpu_cols = step.time_columns.t > 0
                && !step.time_columns.cpu_cols.is_empty()
                && reg_exact_cols
                    .iter()
                    .all(|&col_id| col_id < step.time_columns.cpu_cols.len());
            if !can_use_time_cpu_cols {
                return Err(PiCcsError::ProtocolError(format!(
                    "named openings reg_exact: canonical time cpu columns are required (time_t={}, cpu_cols={}, reg_exact_cols={})",
                    step.time_columns.t,
                    step.time_columns.cpu_cols.len(),
                    reg_exact_cols.len()
                )));
            }
            if !has_committed_time_cpu {
                return Err(PiCcsError::ProtocolError(
                    "named openings reg_exact: canonical time-column path requires committed time cpu columns".into(),
                ));
            }
            let trace_map = crate::memory_sidecar::cpu_bus::time_columns_openings_from_time_columns_at_point(
                mcs_inst.m_in,
                step.time_columns.t,
                &step.time_columns.cpu_cols,
                &reg_exact_cols,
                r_time,
                "named openings reg_exact",
            )?;
            let mut evals = Vec::with_capacity(reg_exact_cols.len());
            for &col_id in reg_exact_cols.iter() {
                let v = trace_map.get(&col_id).copied().ok_or_else(|| {
                    PiCcsError::ProtocolError(format!("named openings reg_exact: missing col_id={col_id}"))
                })?;
                evals.push(v);
            }
            out.push(crate::shard_proof_types::TimePointOpening {
                point: r_time.to_vec(),
                col_ids: reg_exact_cols,
                evals,
                source: crate::shard_proof_types::TimeOpeningSource::CommittedOpening,
            });
        }
        out
    };

    let opening_proofs = {
        let mut out = Vec::new();
        let logical_col_pos = crate::time_opening::me_adapter::build_logical_col_pos(&step.time_columns.col_ids)?;
        let cpu_cols_len = time_cpu_commitments.len();
        struct EncodedTimeColCache {
            z_col: neo_ccs::Mat<F>,
            row_nz: Vec<Vec<(usize, F)>>,
        }
        let mut z_col_cache = std::collections::BTreeMap::<usize, EncodedTimeColCache>::new();
        let mut point_weight_cache: Vec<(crate::shard_proof_types::OpeningDomain, Vec<K>, Vec<F>, Vec<F>)> = Vec::new();
        for opening in fold_openings.iter() {
            if opening.source != crate::shard_proof_types::TimeOpeningSource::CommittedOpening {
                continue;
            }
            if opening.col_ids.len() != opening.evals.len() {
                return Err(PiCcsError::ProtocolError(
                    "time/opening proof build: malformed opening col_ids/evals length mismatch".into(),
                ));
            }
            let mut pairs: Vec<(usize, K)> = opening
                .col_ids
                .iter()
                .copied()
                .zip(opening.evals.iter().copied())
                .collect();
            pairs.sort_unstable_by_key(|(col_id, _)| *col_id);
            if pairs.windows(2).any(|w| w[0].0 == w[1].0) {
                return Err(PiCcsError::ProtocolError(
                    "time/opening proof build: duplicate col_ids in committed opening".into(),
                ));
            }
            let mut col_ids = Vec::with_capacity(pairs.len());
            let mut evals = Vec::with_capacity(pairs.len());
            let sorted_col_ids: Vec<usize> = pairs.iter().map(|(col_id, _)| *col_id).collect();
            let domain = crate::time_opening::me_adapter::domain_for_col_ids(
                sorted_col_ids.as_slice(),
                &logical_col_pos,
                cpu_cols_len,
            )?;
            let cache_idx = if let Some(idx) = point_weight_cache
                .iter()
                .position(|(d, p, _, _)| *d == domain && p.as_slice() == opening.point.as_slice())
            {
                idx
            } else {
                let point_chi = crate::time_opening::me_adapter::build_small_chi_table(opening.point.as_slice())?;
                let point_row_weights = match domain {
                    crate::shard_proof_types::OpeningDomain::Cpu => {
                        crate::time_opening::me_adapter::cpu_time_row_weights(
                            opening.point.as_slice(),
                            step.mcs.0.m_in,
                            step.time_columns.t,
                            point_chi.as_deref(),
                        )?
                    }
                    crate::shard_proof_types::OpeningDomain::Mem => {
                        crate::time_opening::me_adapter::mem_time_row_weights(
                            opening.point.as_slice(),
                            cpu_bus,
                            point_chi.as_deref(),
                        )?
                    }
                };
                let (point_row_weights_re, point_row_weights_im) =
                    crate::time_opening::me_adapter::split_row_weight_coeffs(point_row_weights.as_slice());
                point_weight_cache.push((
                    domain,
                    opening.point.clone(),
                    point_row_weights_re,
                    point_row_weights_im,
                ));
                point_weight_cache.len() - 1
            };
            let (_, _, point_row_weights_re, point_row_weights_im) = &point_weight_cache[cache_idx];
            let mut digit_evals = Vec::with_capacity(pairs.len());
            for (col_id, eval) in pairs.into_iter() {
                col_ids.push(col_id);
                evals.push(eval);
                if !z_col_cache.contains_key(&col_id) {
                    let abs_pos = logical_col_pos.get(&col_id).copied().ok_or_else(|| {
                        PiCcsError::ProtocolError(format!(
                            "time/opening proof build: logical col_id={} missing",
                            col_id
                        ))
                    })?;
                    let col = if abs_pos < cpu_cols_len {
                        step.time_columns.cpu_cols.get(abs_pos).ok_or_else(|| {
                            PiCcsError::ProtocolError(format!(
                                "time/opening proof build: cpu column index {} out of range",
                                abs_pos
                            ))
                        })?
                    } else {
                        let mem_idx = abs_pos - cpu_cols_len;
                        step.time_columns.mem_cols.get(mem_idx).ok_or_else(|| {
                            PiCcsError::ProtocolError(format!(
                                "time/opening proof build: mem column index {} out of range",
                                mem_idx
                            ))
                        })?
                    };
                    let z_col = neo_memory::ajtai::encode_vector_balanced_to_mat_with_base(
                        params,
                        col,
                        crate::time_opening::STAGE8_TIME_DECOMP_BASE,
                    );
                    let row_nz = crate::time_opening::me_adapter::mat_row_nonzero_entries(&z_col);
                    z_col_cache.insert(col_id, EncodedTimeColCache { z_col, row_nz });
                }
                let z_col = z_col_cache.get(&col_id).ok_or_else(|| {
                    PiCcsError::ProtocolError(format!(
                        "time/opening proof build: cached column missing for col_id={col_id}",
                    ))
                })?;
                let digits = crate::time_opening::me_adapter::eval_mat_digits_from_sparse_row_weight_coeffs(
                    point_row_weights_re.as_slice(),
                    point_row_weights_im.as_slice(),
                    z_col.row_nz.as_slice(),
                    z_col.z_col.cols(),
                )?;
                let recomposed = crate::time_opening::me_adapter::recompose_digits_to_scalar(
                    digits.as_slice(),
                    crate::time_opening::STAGE8_TIME_DECOMP_BASE,
                );
                if recomposed != eval {
                    return Err(PiCcsError::ProtocolError(format!(
                        "time/opening proof build: digit recomposition mismatch for col_id={col_id} (domain={domain:?}, eval={eval:?}, recomposed={recomposed:?})"
                    )));
                }
                digit_evals.push(digits);
            }
            out.push(crate::shard_proof_types::TimeOpeningProof {
                point: opening.point.clone(),
                col_ids,
                evals,
                digit_evals,
            });
        }
        out
    };

    let (opening_manifest, opening_reduction, opening_unification, joint_opening_lane, stage8_fold) = if opening_proofs
        .is_empty()
    {
        if !fold_openings.is_empty() {
            return Err(PiCcsError::ProtocolError(
                "time/opening: missing opening proofs for non-empty named openings".into(),
            ));
        }
        (
            crate::shard_proof_types::OpeningClaimManifest::default(),
            crate::shard_proof_types::OpeningReductionProof::default(),
            crate::shard_proof_types::OpeningUnificationProof::default(),
            crate::shard_proof_types::JointOpeningLaneProof::default(),
            Vec::new(),
        )
    } else {
        let opening_manifest = crate::time_opening::manifest::build_opening_claim_manifest(
            &fold_openings,
            &opening_proofs,
            &step.time_columns.col_ids,
            time_cpu_commitments.len(),
        )?;
        crate::time_opening::manifest::bind_opening_claim_manifest(tr, step_idx, &opening_manifest);
        let opening_batch_coeffs = bind_time_opening_batches_and_sample_coeffs(tr, params, step_idx, &opening_proofs)?;
        let opening_reduction = crate::time_opening::reduction::build_opening_reduction(&opening_manifest)?;
        let opening_unification =
            crate::time_opening::reduction::prove_opening_unification_sumcheck(tr, step_idx, &opening_reduction)?;
        let (joint_opening_lane, stage8_joint_wits) =
            crate::time_opening::joint_lane::prove_joint_opening_lane_with_witnesses(
                tr,
                params,
                step_idx,
                step,
                cpu_bus,
                time_cpu_commitments,
                time_mem_commitments,
                &step.time_columns.col_ids,
                &opening_proofs,
                &opening_manifest.digest,
                &opening_reduction,
                &opening_unification,
                &opening_batch_coeffs,
            )?;
        let mut stage8_fold: Vec<RlcDecProof> = Vec::with_capacity(1);
        let stage8_params = stage8_time_decomp_params(params)?;
        let stage8_plan = crate::time_opening::joint_lane::build_stage8_fold_lane_plan(
            &joint_opening_lane,
            &opening_unification,
            step.time_columns.t,
        )?;
        if let Some(plan) = stage8_plan {
            if stage8_joint_wits.len() != plan.claims.len() {
                return Err(PiCcsError::ProtocolError(format!(
                    "stage8 fold: witness/claim count mismatch (wits={}, claims={})",
                    stage8_joint_wits.len(),
                    plan.claims.len()
                )));
            }
            if !has_global_pp_for_dims(D, plan.ccs.m) {
                return Err(PiCcsError::InvalidInput(format!(
                    "stage8 fold: missing global PP for (D,m)=({D},{}); PP must be pre-registered with canonical seed",
                    plan.ccs.m
                )));
            }
            let stage8_committer = neo_ajtai::AjtaiSModule::from_global_for_dims(D, plan.ccs.m).map_err(|e| {
                PiCcsError::InvalidInput(format!(
                    "stage8 fold: missing global committer for (D,m)=({D},{}): {e}",
                    plan.ccs.m
                ))
            })?;
            tr.append_message(b"fold/stage8_lane_start", &(step_idx as u64).to_le_bytes());
            tr.append_message(b"fold/stage8_lane_group_idx", &0u64.to_le_bytes());
            let wit_refs: Vec<&Mat<F>> = stage8_joint_wits.iter().collect();
            let (stage8_proof, _stage8_wits, _stage8_parent_wit) = prove_rlc_dec_lane(
                mode,
                RlcLane::Val,
                tr,
                &stage8_params,
                &plan.ccs,
                None,
                None,
                ring,
                ell_d,
                k_dec,
                step_idx,
                None,
                plan.claims.as_slice(),
                wit_refs.as_slice(),
                false,
                &stage8_committer,
                mixers,
            )?;
            stage8_fold.push(stage8_proof);
        } else if !stage8_joint_wits.is_empty() {
            return Err(PiCcsError::ProtocolError(
                "stage8 fold: missing lane plan for non-empty stage8 witnesses".into(),
            ));
        }
        (
            opening_manifest,
            opening_reduction,
            opening_unification,
            joint_opening_lane,
            stage8_fold,
        )
    };

    Ok(OpeningsPhaseResult {
        fold_openings,
        opening_proofs,
        opening_manifest,
        opening_reduction,
        opening_unification,
        joint_opening_lane,
        stage8_fold,
    })
}

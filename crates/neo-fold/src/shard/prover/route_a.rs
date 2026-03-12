//! Route-A metadata preparation and shared time-phase proving.

use super::*;

pub(super) struct PreparedRouteAStepMetadata {
    pub output_binding_proof: Option<neo_memory::output_check::OutputBindingProof>,
    pub ell_t: usize,
    pub time_declared_len: usize,
    pub time_cpu_commitments: Vec<Cmt>,
    pub time_mem_commitments: Vec<Cmt>,
    pub has_committed_time_cpu: bool,
    pub has_committed_time_mem: bool,
    pub exact_reg_output_binding_active: bool,
    pub ob_r_prime: Option<Vec<K>>,
    pub ob_sparse_addr_weights: Option<Vec<(Vec<K>, K)>>,
}

pub(super) struct PreparedRouteATimePhase {
    pub control_required: bool,
    pub mem_oracles: crate::memory_sidecar::memory::RouteAMemoryOracles,
    pub shout_pre: crate::memory_sidecar::memory::ShoutAddrPreBatchProverData,
    pub twist_pre: Vec<crate::memory_sidecar::memory::TwistAddrPreProverData>,
    pub r_time: Vec<K>,
    pub batched_time: crate::shard_proof_types::BatchedTimeProof,
}

pub(super) fn prepare_route_a_step_metadata(
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    step: &StepWitnessBundle<Cmt, F, K>,
    step_idx: usize,
    include_output_binding: bool,
    output_binding: Option<(&crate::output_binding::OutputBindingConfig, &[F])>,
    output_proof_already_attached: bool,
) -> Result<PreparedRouteAStepMetadata, PiCcsError> {
    let mut output_binding_proof = None;
    let mut ob_r_prime = None;
    let mut ob_sparse_addr_weights = None;
    let exact_reg_output_binding_active = include_output_binding
        && output_binding
            .as_ref()
            .map(|(cfg, _)| step.mem_instances[cfg.mem_idx].0.mem_id == neo_memory::riscv::lookups::REG_EXACT_ID.0)
            .unwrap_or(false);

    if include_output_binding {
        let (cfg, final_memory_state) = output_binding
            .ok_or_else(|| PiCcsError::InvalidInput("output binding enabled but config missing".into()))?;

        if output_proof_already_attached {
            return Err(PiCcsError::ProtocolError(
                "output binding already attached (internal error)".into(),
            ));
        }

        if cfg.mem_idx >= step.mem_instances.len() {
            return Err(PiCcsError::InvalidInput("output binding mem_idx out of range".into()));
        }
        let expected_k = 1usize
            .checked_shl(cfg.num_bits as u32)
            .ok_or_else(|| PiCcsError::InvalidInput("output binding: 2^num_bits overflow".into()))?;
        let mem_inst = &step.mem_instances[cfg.mem_idx].0;
        if mem_inst.k != expected_k {
            return Err(PiCcsError::InvalidInput(format!(
                "output binding: cfg.num_bits implies k={}, but mem_inst.k={}",
                expected_k, mem_inst.k
            )));
        }
        let ell_addr = mem_inst.twist_layout().lanes[0].ell_addr;
        if ell_addr != cfg.num_bits {
            return Err(PiCcsError::InvalidInput(format!(
                "output binding: cfg.num_bits={}, but twist_layout.ell_addr={}",
                cfg.num_bits, ell_addr
            )));
        }

        tr.append_message(b"shard/output_binding_start", &(step_idx as u64).to_le_bytes());
        tr.append_u64s(b"output_binding/mem_idx", &[cfg.mem_idx as u64]);
        tr.append_u64s(b"output_binding/num_bits", &[cfg.num_bits as u64]);

        let use_dense_output_sumcheck = cfg.num_bits <= neo_memory::output_check::OUTPUT_SUMCHECK_MAX_NUM_BITS;
        if use_dense_output_sumcheck {
            if final_memory_state.len() != expected_k {
                return Err(PiCcsError::InvalidInput(format!(
                    "output binding: final_memory_state.len()={} != 2^num_bits={}",
                    final_memory_state.len(),
                    expected_k
                )));
            }
            let (output_sc, r_prime) = neo_memory::output_check::generate_output_sumcheck_proof_and_challenges(
                tr,
                cfg.num_bits,
                cfg.program_io.clone(),
                final_memory_state,
            )
            .map_err(|e| PiCcsError::ProtocolError(format!("output sumcheck failed: {e:?}")))?;
            output_binding_proof = Some(neo_memory::output_check::OutputBindingProof { output_sc });
            ob_r_prime = Some(r_prime);
        } else {
            let sampled = crate::output_binding::sample_output_lincomb_weights(tr, &cfg.program_io);
            let addr_weights = sampled
                .into_iter()
                .map(|(addr, _claim_value, alpha)| (crate::output_binding::addr_bits_as_k(addr, cfg.num_bits), alpha))
                .collect::<Vec<_>>();
            output_binding_proof = Some(neo_memory::output_check::OutputBindingProof {
                output_sc: neo_memory::output_check::OutputSumcheckProof::default(),
            });
            ob_sparse_addr_weights = Some(addr_weights);
        }
    }

    let route_steps = {
        let inst_steps = step
            .lut_instances
            .iter()
            .map(|(inst, _)| inst.steps)
            .chain(step.mem_instances.iter().map(|(inst, _)| inst.steps))
            .max()
            .unwrap_or(0);
        core::cmp::max(step.time_columns.t, inst_steps)
    };
    let route_domain = step
        .mcs
        .0
        .m_in
        .checked_add(route_steps)
        .ok_or_else(|| PiCcsError::InvalidInput("prove/route_a: route domain overflow".into()))?;
    let route_pow2 = route_domain.max(2).next_power_of_two();
    let ell_t = route_pow2.trailing_zeros() as usize;
    let time_declared_len = validate_time_active_mask_and_count(
        step.time_columns.active_col.as_slice(),
        step.time_columns.t,
        "prove/time_columns",
    )?;
    let (time_cpu_commitments, time_mem_commitments) = commit_time_column_sets(
        params,
        step.time_columns.t,
        &step.time_columns.cpu_cols,
        &step.time_columns.mem_cols,
        "prove/time_columns",
    )?;
    let expected_time_col_ids = time_cpu_commitments
        .len()
        .checked_add(time_mem_commitments.len())
        .ok_or_else(|| PiCcsError::InvalidInput("time commitment count overflow".into()))?;
    if step.time_columns.col_ids.len() != expected_time_col_ids {
        return Err(PiCcsError::ProtocolError(format!(
            "time column metadata mismatch: col_ids.len()={} != cpu_commitments+mem_commitments={expected_time_col_ids}",
            step.time_columns.col_ids.len()
        )));
    }
    for (idx, &col_id) in step.time_columns.col_ids.iter().enumerate() {
        if col_id != idx {
            return Err(PiCcsError::ProtocolError(format!(
                "time column metadata mismatch: col_ids must be canonical contiguous ids (col_ids[{idx}]={col_id}, expected {idx})"
            )));
        }
    }
    let has_committed_time_cpu = step.time_columns.t > 0 && !time_cpu_commitments.is_empty();
    let has_committed_time_mem = step.time_columns.t > 0 && !time_mem_commitments.is_empty();

    Ok(PreparedRouteAStepMetadata {
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
    })
}

#[allow(clippy::too_many_arguments)]
pub(super) fn prove_route_a_time_phase(
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    cpu_bus: &neo_memory::cpu::BusLayout,
    step: &StepWitnessBundle<Cmt, F, K>,
    step_idx: usize,
    ell_t: usize,
    ell_n: usize,
    include_output_binding: bool,
    output_binding: Option<&crate::output_binding::OutputBindingConfig>,
    exact_reg_output_binding_active: bool,
    ob_r_prime: Option<Vec<K>>,
    ob_sparse_addr_weights: Option<Vec<(Vec<K>, K)>>,
    poseidon_cycle_enabled: bool,
    poseidon_sidecar: Option<&neo_memory::riscv::exec_table::RiscvPoseidonSidecarTable>,
    poseidon_cycle_wit: Option<&Mat<F>>,
    poseidon_cycle_open_spec: Option<&(usize, usize, Vec<usize>)>,
    poseidon_link_chals: Option<&crate::memory_sidecar::memory::PoseidonLinkChallenges>,
    poseidon_cont_chals: Option<&crate::memory_sidecar::memory::PoseidonContinuityChallenges>,
) -> Result<PreparedRouteATimePhase, PiCcsError> {
    let r_cycle: Vec<K> = ts::sample_ext_point(tr, b"route_a/r_cycle", b"route_a/cycle/0", b"route_a/cycle/1", ell_t);

    let shout_pre =
        crate::memory_sidecar::memory::prove_shout_addr_pre_time(tr, params, step, cpu_bus, ell_t, &r_cycle, step_idx)?;

    let twist_pre =
        crate::memory_sidecar::memory::prove_twist_addr_pre_time(tr, params, step, cpu_bus, ell_t, &r_cycle)
            .map_err(|e| PiCcsError::ProtocolError(format!("twist addr-pre failed at step_idx={step_idx}: {e}")))?;
    let twist_read_claims: Vec<K> = twist_pre.iter().map(|p| p.read_check_claim_sum).collect();
    let twist_write_claims: Vec<K> = twist_pre.iter().map(|p| p.write_check_claim_sum).collect();
    let mut mem_oracles = crate::memory_sidecar::memory::build_route_a_memory_oracles(
        params, step, ell_t, &r_cycle, &shout_pre, &twist_pre,
    )?;

    let (booleanity_time_claim_built, trace_opening_time_claim_built) =
        crate::memory_sidecar::memory::build_route_a_trace_opening_time_claims(params, step, &r_cycle)?;
    let trace_opening_path_required = crate::memory_sidecar::memory::trace_opening_path_required_for_step_witness(step);
    if trace_opening_path_required
        && (booleanity_time_claim_built.is_none() || trace_opening_time_claim_built.is_none())
    {
        return Err(PiCcsError::ProtocolError(
            "booleanity/trace-opening claims are required in RV32 trace mode but were not built".into(),
        ));
    }
    let booleanity_time_claim =
        booleanity_time_claim_built.map(
            |(oracle, _)| crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"booleanity/check",
            },
        );
    let trace_opening_time_claim =
        trace_opening_time_claim_built.map(
            |(oracle, _)| crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"trace_opening/quiescence",
            },
        );

    let (decode_fields_built, decode_immediates_built) =
        crate::memory_sidecar::memory::build_route_a_decode_time_claims(params, step, &r_cycle)?;
    let decode_required = crate::memory_sidecar::memory::decode_stage_required_for_step_witness(step);
    if decode_required && (decode_fields_built.is_none() || decode_immediates_built.is_none()) {
        return Err(PiCcsError::ProtocolError(
            "decode stage claims are required in RV32 trace mode but were not built".into(),
        ));
    }
    let decode_fields_claim =
        decode_fields_built.map(
            |(oracle, _)| crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"decode/fields",
            },
        );
    let decode_immediates_claim =
        decode_immediates_built.map(
            |(oracle, _)| crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"decode/immediates",
            },
        );

    let (
        width_bitness_built,
        width_quiescence_built,
        width_selector_linkage_built,
        width_load_semantics_built,
        width_store_semantics_built,
    ) = crate::memory_sidecar::memory::build_route_a_width_time_claims(params, step, &r_cycle)?;
    let width_required = crate::memory_sidecar::memory::width_stage_required_for_step_witness(step);
    if width_required
        && (width_bitness_built.is_none()
            || width_quiescence_built.is_none()
            || width_load_semantics_built.is_none()
            || width_store_semantics_built.is_none())
    {
        return Err(PiCcsError::ProtocolError(
            "width stage claims are required in RV32 trace mode but were not built".into(),
        ));
    }
    let width_bitness_claim =
        width_bitness_built.map(
            |(oracle, _)| crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"width/bitness",
            },
        );
    let width_quiescence_claim =
        width_quiescence_built.map(
            |(oracle, _)| crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"width/quiescence",
            },
        );
    let width_selector_linkage_claim =
        width_selector_linkage_built.map(
            |(oracle, _)| crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"width/selector_linkage",
            },
        );
    let width_load_semantics_claim =
        width_load_semantics_built.map(
            |(oracle, _)| crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"width/load_semantics",
            },
        );
    let width_store_semantics_claim =
        width_store_semantics_built.map(
            |(oracle, _)| crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"width/store_semantics",
            },
        );

    let (
        control_next_pc_linear_built,
        control_next_pc_control_built,
        control_branch_semantics_built,
        control_control_writeback_built,
    ) = crate::memory_sidecar::memory::build_route_a_control_time_claims(params, step, &r_cycle)?;
    let control_required = crate::memory_sidecar::memory::control_stage_required_for_step_witness(step);
    if control_required
        && (control_next_pc_linear_built.is_none()
            || control_next_pc_control_built.is_none()
            || control_branch_semantics_built.is_none()
            || control_control_writeback_built.is_none())
    {
        return Err(PiCcsError::ProtocolError(
            "control stage claims are required in RV32 trace mode but were not built".into(),
        ));
    }
    let control_next_pc_linear_claim =
        control_next_pc_linear_built.map(
            |(oracle, _)| crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"control/next_pc_linear",
            },
        );
    let control_next_pc_control_claim =
        control_next_pc_control_built.map(
            |(oracle, _)| crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"control/next_pc_control",
            },
        );
    let control_branch_semantics_claim =
        control_branch_semantics_built.map(
            |(oracle, _)| crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"control/branch_semantics",
            },
        );
    let control_writeback_claim =
        control_control_writeback_built.map(
            |(oracle, _)| crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"control/writeback",
            },
        );

    let poseidon_cycle_claims = build_poseidon_cycle_time_claims(
        params,
        step,
        &r_cycle,
        ell_n,
        poseidon_cycle_enabled,
        poseidon_sidecar,
        poseidon_cycle_wit,
        poseidon_cycle_open_spec,
        poseidon_link_chals,
        poseidon_cont_chals,
    )?;

    let mut ob_time_claim = None;
    let mut ob_reg_exact_linkage_claim = None;
    if include_output_binding {
        let cfg = output_binding
            .ok_or_else(|| PiCcsError::InvalidInput("output binding enabled but config missing".into()))?;
        let pre = twist_pre
            .get(cfg.mem_idx)
            .ok_or_else(|| PiCcsError::ProtocolError("output binding mem_idx out of range for twist_pre".into()))?;
        if pre.decoded.lanes.is_empty() {
            return Err(PiCcsError::ProtocolError(
                "output binding: Twist decoded lanes empty".into(),
            ));
        }

        let mut oracles: Vec<Box<dyn RoundOracle + Send>> = Vec::new();
        let mut claimed_sum = K::ZERO;
        let use_dense_output_sumcheck = cfg.num_bits <= neo_memory::output_check::OUTPUT_SUMCHECK_MAX_NUM_BITS;
        if use_dense_output_sumcheck {
            let r_prime = ob_r_prime
                .as_ref()
                .ok_or_else(|| PiCcsError::ProtocolError("output binding r_prime missing".into()))?;
            oracles.reserve(pre.decoded.lanes.len());
            for lane in &pre.decoded.lanes {
                let (oracle, claim) = neo_memory::twist_oracle::TwistTotalIncOracleSparseTime::new(
                    lane.wa_bits.clone(),
                    lane.has_write.clone(),
                    lane.inc_at_write_addr.clone(),
                    r_prime,
                );
                oracles.push(Box::new(oracle));
                claimed_sum += claim;
            }
        } else {
            let addr_weights = ob_sparse_addr_weights
                .as_ref()
                .ok_or_else(|| PiCcsError::ProtocolError("output binding sparse addr/weight set missing".into()))?;
            oracles.reserve(pre.decoded.lanes.len().saturating_mul(addr_weights.len()));
            for lane in &pre.decoded.lanes {
                for (r_addr, alpha) in addr_weights {
                    if *alpha == K::ZERO {
                        continue;
                    }
                    let scaled_inc = neo_memory::sparse_time::SparseIdxVec::from_entries(
                        lane.inc_at_write_addr.len(),
                        lane.inc_at_write_addr
                            .entries()
                            .iter()
                            .map(|(idx, val)| (*idx, *val * *alpha))
                            .collect(),
                    );
                    let (oracle, claim) = neo_memory::twist_oracle::TwistTotalIncOracleSparseTime::new(
                        lane.wa_bits.clone(),
                        lane.has_write.clone(),
                        scaled_inc,
                        r_addr,
                    );
                    oracles.push(Box::new(oracle));
                    claimed_sum += claim;
                }
            }
        }
        if oracles.is_empty() {
            return Err(PiCcsError::ProtocolError(
                "output binding produced zero active Twist increment oracles".into(),
            ));
        }
        let oracle = crate::memory_sidecar::memory::SumRoundOracle::new(oracles)?;
        ob_time_claim = Some(crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
            oracle: Box::new(oracle),
            claimed_sum,
            label: crate::output_binding::OB_INC_TOTAL_LABEL,
        });
        if exact_reg_output_binding_active {
            let (oracle, claimed_sum) = crate::memory_sidecar::memory::build_rv64_reg_exact_output_linkage_claim(
                step, &r_cycle,
            )?
            .ok_or_else(|| {
                PiCcsError::ProtocolError("RV64 exact register output binding requires REG_EXACT linkage oracle".into())
            })?;
            ob_reg_exact_linkage_claim = Some(crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum,
                label: crate::output_binding::OB_REG_EXACT_LINKAGE_LABEL,
            });
        }
    }

    let crate::memory_sidecar::route_a_time::RouteABatchedTimeProverOutput {
        r_time,
        proof: batched_time,
    } = crate::memory_sidecar::route_a_time::prove_route_a_batched_time(
        tr,
        step_idx,
        ell_t,
        &mut mem_oracles,
        step,
        twist_read_claims,
        twist_write_claims,
        crate::memory_sidecar::route_a_time::RouteABatchedTimeClaims {
            booleanity: booleanity_time_claim,
            trace_opening: trace_opening_time_claim,
            decode: crate::memory_sidecar::route_a_time::DecodeTimeClaims {
                decode_fields: decode_fields_claim,
                decode_immediates: decode_immediates_claim,
            },
            width: crate::memory_sidecar::route_a_time::WidthTimeClaims {
                bitness: width_bitness_claim,
                quiescence: width_quiescence_claim,
                selector_linkage: width_selector_linkage_claim,
                load_semantics: width_load_semantics_claim,
                store_semantics: width_store_semantics_claim,
            },
            control: crate::memory_sidecar::route_a_time::ControlTimeClaims {
                next_pc_linear: control_next_pc_linear_claim,
                next_pc_control: control_next_pc_control_claim,
                branch_semantics: control_branch_semantics_claim,
                control_writeback: control_writeback_claim,
            },
            poseidon: crate::memory_sidecar::route_a_time::PoseidonCycleTimeClaims {
                io_link: poseidon_cycle_claims.io_link,
                bitness: poseidon_cycle_claims.bitness,
                canonical_u64: poseidon_cycle_claims.canonical_u64,
                sidecar_link: poseidon_cycle_claims.sidecar_link,
                mode: poseidon_cycle_claims.mode,
                link_cycle_inv: poseidon_cycle_claims.link_cycle_inv,
                link_cycle_sum: poseidon_cycle_claims.link_cycle_sum,
                cont_inv: poseidon_cycle_claims.cont_inv,
                cont_sum: poseidon_cycle_claims.cont_sum,
            },
            output_binding: crate::memory_sidecar::route_a_time::OutputBindingTimeClaims {
                reg_exact_linkage: ob_reg_exact_linkage_claim,
                inc_total: ob_time_claim,
            },
        },
    )?;

    Ok(PreparedRouteATimePhase {
        control_required,
        mem_oracles,
        shout_pre,
        twist_pre,
        r_time,
        batched_time,
    })
}

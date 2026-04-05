use std::path::PathBuf;

use p3_field::PrimeField64;

use super::*;

#[derive(Clone)]
pub(crate) struct AcceptedProofVectorCase {
    pub(crate) name: String,
    pub(crate) source: rv64::Rv64imParitySourceCase,
    pub(crate) derived: rv64::Rv64imParityDerivedCase,
    pub(crate) artifact: rv64::Rv64imAcceptedProofArtifact,
    pub(crate) proof: rv64::Rv64imProof,
}

pub(crate) fn accepted_proof_artifact_dir() -> PathBuf {
    generated_dir().join("AcceptedProofArtifactVectors")
}

pub(crate) fn accepted_proof_case_path(case_name: &str) -> PathBuf {
    accepted_proof_artifact_dir().join(format!("Case_{}.lean", lean_ident_fragment(case_name)))
}

pub(crate) fn build_accepted_proof_cases(
    cases: &[(rv64::Rv64imParitySourceCase, rv64::Rv64imParityDerivedCase)],
    proof_cases: &[PublicProofVectorCase],
) -> Vec<AcceptedProofVectorCase> {
    proof_cases
        .iter()
        .map(|proof_case| {
            let (source, derived) = cases
                .iter()
                .find(|(source, _)| source.manifest.name == proof_case.name)
                .cloned()
                .unwrap_or_else(|| panic!("accepted artifact vector source case missing for {}", proof_case.name));
            let artifact = rv64::build_rv64im_accepted_proof_artifact(&proof_case.proof).unwrap_or_else(|err| {
                panic!("build RV64IM accepted proof artifact vector {}: {err}", proof_case.name)
            });
            rv64::verify_rv64im_accepted_proof(&artifact).unwrap_or_else(|err| {
                panic!("verify RV64IM accepted proof artifact vector {}: {err}", proof_case.name)
            });
            AcceptedProofVectorCase {
                name: proof_case.name.clone(),
                source,
                derived,
                artifact,
                proof: proof_case.proof.clone(),
            }
        })
        .collect()
}

fn render_list<T>(values: &[T], mut render: impl FnMut(&T) -> String) -> String {
    let mut out = String::from("[");
    for (idx, value) in values.iter().enumerate() {
        if idx > 0 {
            out.push_str(", ");
        }
        out.push_str(&render(value));
    }
    out.push(']');
    out
}

fn render_string_list(values: &[String]) -> String {
    render_list(values, |value| render_string(value))
}

fn render_option_bool(value: Option<bool>) -> String {
    match value {
        Some(value) => format!("(some {})", render_bool(value)),
        None => "none".into(),
    }
}

fn render_packaged_proof_digest(statement_digest: &[u8], proof_digest: &[u8]) -> String {
    format!(
        "{{ statementDigest := {}, proofDigest := {} }}",
        render_u8_list(statement_digest),
        render_u8_list(proof_digest),
    )
}

fn render_stage1_row_binding(row: &rv64::stage1::Stage1RowBinding) -> String {
    format!(
        "{{ traceIndex := {}, stepIndex := {}, sequenceIndex := {}, fetchPc := {}, fetchedWord := {}, opcode := {}, traceOpcode := {}, traceVirtualOpcode := {}, family := {}, nextPc := {}, aluResult := {}, effectiveAddr := {}, writesRd := {}, rd := {}, rdAfter := {}, isFirstInSequence := {}, virtualSequenceRemaining := {}, isEffectRow := {}, isCommitRow := {}, isReal := {}, preservesX0 := {} }}",
        row.trace_index,
        row.step_index,
        row.sequence_index,
        row.fetch_pc,
        row.fetched_word,
        render_opcode(row.opcode),
        row.trace_opcode.map(|opcode| format!("(some {})", render_opcode(opcode))).unwrap_or_else(|| "none".into()),
        row.trace_virtual_opcode
            .map(|opcode| format!("(some {})", render_trace_virtual_opcode(opcode)))
            .unwrap_or_else(|| "none".into()),
        render_family_tag(row.family),
        row.next_pc,
        row.alu_result,
        render_option_nat(row.effective_addr),
        render_bool(row.writes_rd),
        row.rd,
        row.rd_after,
        render_bool(row.is_first_in_sequence),
        row.virtual_sequence_remaining
            .map(|remaining| format!("(some {remaining})"))
            .unwrap_or_else(|| "none".into()),
        render_bool(row.is_effect_row),
        render_bool(row.is_commit_row),
        render_bool(row.is_real),
        render_bool(row.preserves_x0),
    )
}

fn render_sem_in(input: &rv64::SemIn) -> String {
    format!(
        "{{ traceIndex := {}, stepIndex := {}, sequenceIndex := {}, pc := {}, opcode := {}, traceOpcode := {}, traceVirtualOpcode := {}, family := {}, archRs1 := {}, archRs1Value := {}, archRs2 := {}, archRs2Value := {}, archRd := {}, archRdBefore := {}, archImm := {}, rs1 := {}, rs1Value := {}, rs2 := {}, rs2Value := {}, rd := {}, rdBefore := {}, rdAfter := {}, imm := {}, effectiveAddr := {}, memoryBefore := {}, memoryAfter := {}, memWidthBytes := {}, memUnsigned := {}, writesRd := {}, writesRam := {}, isFirstInSequence := {}, virtualSequenceRemaining := {}, isEffectRow := {}, isCommitRow := {}, isReal := {} }}",
        input.trace_index,
        input.step_index,
        input.sequence_index,
        input.pc,
        render_opcode(input.opcode),
        input.trace_opcode.map(|opcode| format!("(some {})", render_opcode(opcode))).unwrap_or_else(|| "none".into()),
        input.trace_virtual_opcode
            .map(|opcode| format!("(some {})", render_trace_virtual_opcode(opcode)))
            .unwrap_or_else(|| "none".into()),
        render_family_tag(input.family),
        input.arch_rs1,
        input.arch_rs1_value,
        input.arch_rs2,
        input.arch_rs2_value,
        input.arch_rd,
        input.arch_rd_before,
        input.arch_imm,
        input.rs1,
        input.rs1_value,
        input.rs2,
        input.rs2_value,
        input.rd,
        input.rd_before,
        input.rd_after,
        input.imm,
        render_option_nat(input.effective_addr),
        render_option_nat(input.memory_before),
        render_option_nat(input.memory_after),
        input.mem_width_bytes.map(|width| format!("(some {width})")).unwrap_or_else(|| "none".into()),
        render_option_bool(input.mem_unsigned),
        render_bool(input.writes_rd),
        render_bool(input.writes_ram),
        render_bool(input.is_first_in_sequence),
        input.virtual_sequence_remaining
            .map(|remaining| format!("(some {remaining})"))
            .unwrap_or_else(|| "none".into()),
        render_bool(input.is_effect_row),
        render_bool(input.is_commit_row),
        render_bool(input.is_real),
    )
}

fn render_stage1_opening_points(points: &rv64::Stage1OpeningPoints) -> String {
    format!(
        "{{ first := {}, effect := {}, commit := {}, last := {} }}",
        render_selected_opening_ref(&points.first),
        render_selected_opening_ref(&points.effect),
        render_selected_opening_ref(&points.commit),
        render_selected_opening_ref(&points.last),
    )
}

fn render_stage2_opening_points(points: &rv64::Stage2OpeningPoints) -> String {
    format!(
        "{{ firstRead := {}, lastRead := {}, firstWrite := {}, lastWrite := {}, firstRam := {}, lastRam := {}, firstTwist := {}, lastTwist := {} }}",
        render_option_selected_opening_ref(points.first_read.as_ref()),
        render_option_selected_opening_ref(points.last_read.as_ref()),
        render_option_selected_opening_ref(points.first_write.as_ref()),
        render_option_selected_opening_ref(points.last_write.as_ref()),
        render_option_selected_opening_ref(points.first_ram.as_ref()),
        render_option_selected_opening_ref(points.last_ram.as_ref()),
        render_option_selected_opening_ref(points.first_twist.as_ref()),
        render_option_selected_opening_ref(points.last_twist.as_ref()),
    )
}

fn render_stage3_opening_points(points: &rv64::Stage3OpeningPoints) -> String {
    format!(
        "{{ firstContinuity := {}, lastContinuity := {} }}",
        render_option_selected_opening_ref(points.first_continuity.as_ref()),
        render_option_selected_opening_ref(points.last_continuity.as_ref()),
    )
}

fn render_stage1_selected_opening(claim: &rv64::Stage1SelectedOpeningClaim) -> String {
    format!(
        "{{ rowsFamilyDigest := {}, rowCount := {}, effectRowCount := {}, commitRowCount := {}, realRowCount := {}, preservesX0Count := {}, firstTraceIndex := {}, effectTraceIndex := {}, commitTraceIndex := {}, lastTraceIndex := {}, mix := {}, points := {}, digest := {} }}",
        render_u8_list(&claim.rows_family_digest),
        claim.row_count,
        claim.effect_row_count,
        claim.commit_row_count,
        claim.real_row_count,
        claim.preserves_x0_count,
        claim.first_trace_index,
        claim.effect_trace_index,
        claim.commit_trace_index,
        claim.last_trace_index,
        claim.mix,
        render_stage1_opening_points(&claim.points),
        render_u8_list(&claim.digest),
    )
}

fn render_stage2_selected_opening(claim: &rv64::Stage2SelectedOpeningClaim) -> String {
    format!(
        "{{ registerReadsFamilyDigest := {}, registerWritesFamilyDigest := {}, ramEventsFamilyDigest := {}, twistLinksFamilyDigest := {}, registerReadCount := {}, registerWriteCount := {}, ramEventCount := {}, twistLinkCount := {}, ramReadCount := {}, ramWriteCount := {}, regMix := {}, ramMix := {}, points := {}, digest := {} }}",
        render_u8_list(&claim.register_reads_family_digest),
        render_u8_list(&claim.register_writes_family_digest),
        render_u8_list(&claim.ram_events_family_digest),
        render_u8_list(&claim.twist_links_family_digest),
        claim.register_read_count,
        claim.register_write_count,
        claim.ram_event_count,
        claim.twist_link_count,
        claim.ram_read_count,
        claim.ram_write_count,
        claim.reg_mix,
        claim.ram_mix,
        render_stage2_opening_points(&claim.points),
        render_u8_list(&claim.digest),
    )
}

fn render_stage3_selected_opening(claim: &rv64::Stage3SelectedOpeningClaim) -> String {
    format!(
        "{{ continuityFamilyDigest := {}, continuityCount := {}, finalStepCount := {}, halted := {}, allContinuityHold := {}, continuityMix := {}, points := {}, digest := {} }}",
        render_u8_list(&claim.continuity_family_digest),
        claim.continuity_count,
        claim.final_step_count,
        render_bool(claim.halted),
        render_bool(claim.all_continuity_hold),
        claim.continuity_mix,
        render_stage3_opening_points(&claim.points),
        render_u8_list(&claim.digest),
    )
}

fn render_stage1_bundle_defs(name: &str, bundle: &rv64::Stage1ProofBundle) -> String {
    format!(
        "def {name}SemInputs : List SemInView :=\n  {}\n\n\
def {name}RowBindings : List Stage1RowBindingView :=\n  {}\n\n\
def {name} : Stage1ProofBundleView :=\n  {{\n    semInputs := {name}SemInputs\n    , rowBindings := {name}RowBindings\n    , bytecodeDigest := {}\n    , aluDigest := {}\n    , branchDigest := {}\n    , semantics := {{ semInputsDigest := {}, rowBindingsDigest := {}, sequenceCount := {}, helperRowCount := {}, digest := {} }}\n    , addressCorrectnessDigest := {}\n    , linkageDigest := {}\n    , selectedOpening := {{ claim := {}, packaged := {}, digest := {} }}\n    , digest := {}\n  }}\n",
        render_list(&bundle.sem_inputs, render_sem_in),
        render_list(&bundle.row_bindings, render_stage1_row_binding),
        render_u8_list(&bundle.bytecode.digest),
        render_u8_list(&bundle.alu.digest),
        render_u8_list(&bundle.branch.digest),
        render_u8_list(&bundle.semantics.sem_inputs_digest),
        render_u8_list(&bundle.semantics.row_bindings_digest),
        bundle.semantics.sequence_count,
        bundle.semantics.helper_row_count,
        render_u8_list(&bundle.semantics.digest),
        render_u8_list(&bundle.address_correctness.digest),
        render_u8_list(&bundle.linkage.digest),
        render_stage1_selected_opening(&bundle.selected_opening.claim),
        render_packaged_proof_digest(
            &bundle.selected_opening.packaged.statement.digest,
            &bundle.selected_opening.packaged.proof.proof_digest,
        ),
        render_u8_list(&bundle.selected_opening.digest),
        render_u8_list(&bundle.digest),
    )
}

fn render_stage2_bundle_defs(name: &str, bundle: &rv64::Stage2ProofBundle) -> String {
    format!(
        "def {name}RegisterReads : List RegisterReadEventView :=\n  {}\n\n\
def {name}RegisterWrites : List RegisterWriteEventView :=\n  {}\n\n\
def {name}RamEvents : List RamEventView :=\n  {}\n\n\
def {name}TwistLinks : List TwistLinkEventView :=\n  {}\n\n\
def {name} : Stage2ProofBundleView :=\n  {{\n    registerReads := {name}RegisterReads\n    , registerWrites := {name}RegisterWrites\n    , ramEvents := {name}RamEvents\n    , registerDigest := {}\n    , ramDigest := {}\n    , temporal := {{ twistLinks := {name}TwistLinks, registerTimelineDigest := {}, ramTimelineDigest := {}, twistLinksDigest := {}, digest := {} }}\n    , semantics := {{ registerReadsFamilyDigest := {}, registerWritesFamilyDigest := {}, ramEventsFamilyDigest := {}, twistLinksFamilyDigest := {}, rowCount := {}, registerEventCount := {}, ramEventCount := {}, digest := {} }}\n    , linkageDigest := {}\n    , selectedOpening := {{ claim := {}, packaged := {}, digest := {} }}\n    , digest := {}\n  }}\n",
        render_list(&bundle.register.reads, |event| format!("{{ traceIndex := {}, stepIndex := {}, role := {}, reg := {}, value := {} }}", event.trace_index, event.step_index, render_register_read_role(event.role), event.reg, event.value)),
        render_list(&bundle.register.writes, |event| format!("{{ traceIndex := {}, stepIndex := {}, reg := {}, previous := {}, next := {} }}", event.trace_index, event.step_index, event.reg, event.previous, event.next)),
        render_list(&bundle.ram.events, |event| format!("{{ traceIndex := {}, stepIndex := {}, kind := {}, addr := {}, previous := {}, next := {} }}", event.trace_index, event.step_index, render_ram_access_kind(event.kind), event.addr, event.previous, event.next)),
        render_list(&bundle.temporal.twist_links, |event| format!("{{ traceIndex := {}, stepIndex := {}, family := {}, routedWriteValue := {}, routedMemoryBefore := {}, routedMemoryAfter := {} }}", event.trace_index, event.step_index, render_family_tag(event.family), render_option_nat(event.routed_write_value), render_option_nat(event.routed_memory_before), render_option_nat(event.routed_memory_after))),
        render_u8_list(&bundle.register.digest),
        render_u8_list(&bundle.ram.digest),
        render_u8_list(&bundle.temporal.register_timeline_digest),
        render_u8_list(&bundle.temporal.ram_timeline_digest),
        render_u8_list(&bundle.temporal.twist_links_digest),
        render_u8_list(&bundle.temporal.digest),
        render_u8_list(&bundle.semantics.register_reads_family_digest),
        render_u8_list(&bundle.semantics.register_writes_family_digest),
        render_u8_list(&bundle.semantics.ram_events_family_digest),
        render_u8_list(&bundle.semantics.twist_links_family_digest),
        bundle.semantics.row_count,
        bundle.semantics.register_event_count,
        bundle.semantics.ram_event_count,
        render_u8_list(&bundle.semantics.digest),
        render_u8_list(&bundle.linkage.digest),
        render_stage2_selected_opening(&bundle.selected_opening.claim),
        render_packaged_proof_digest(
            &bundle.selected_opening.packaged.statement.digest,
            &bundle.selected_opening.packaged.proof.proof_digest,
        ),
        render_u8_list(&bundle.selected_opening.digest),
        render_u8_list(&bundle.digest),
    )
}

fn render_stage3_bundle_defs(name: &str, bundle: &rv64::Stage3ProofBundle) -> String {
    format!(
        "def {name}Continuity : List ContinuityEventView :=\n  {}\n\n\
def {name} : Stage3ProofBundleView :=\n  {{\n    continuity := {name}Continuity\n    , halted := {}\n    , bridgeDigest := {}\n    , semantics := {{ continuityDigest := {}, rootSemanticRowsDigest := {}, rowChunkRoutesDigest := {}, preparedStepBindingsDigest := {}, stage2TemporalDigest := {}, initialPc := {}, finalPc := {}, realRowCount := {}, firstRealStepIndex := {}, lastRealStepIndex := {}, digest := {} }}\n    , linkageDigest := {}\n    , selectedOpening := {{ claim := {}, packaged := {}, digest := {} }}\n    , digest := {}\n  }}\n",
        render_list(&bundle.bridge.continuity, |event| format!("{{ stepIndex := {}, pc := {}, nextPc := {}, successorPc := {}, finalStep := {}, continuityHolds := {} }}", event.step_index, event.pc, event.next_pc, render_option_nat(event.successor_pc), render_bool(event.final_step), render_bool(event.continuity_holds))),
        render_bool(bundle.bridge.halted),
        render_u8_list(&bundle.bridge.digest),
        render_u8_list(&bundle.semantics.continuity_digest),
        render_u8_list(&bundle.semantics.root_semantic_rows_digest),
        render_u8_list(&bundle.semantics.row_chunk_routes_digest),
        render_u8_list(&bundle.semantics.prepared_step_bindings_digest),
        render_u8_list(&bundle.semantics.stage2_temporal_digest),
        bundle.semantics.initial_pc,
        bundle.semantics.final_pc,
        bundle.semantics.real_row_count,
        bundle.semantics.first_real_step_index,
        bundle.semantics.last_real_step_index,
        render_u8_list(&bundle.semantics.digest),
        render_u8_list(&bundle.linkage.digest),
        render_stage3_selected_opening(&bundle.selected_opening.claim),
        render_packaged_proof_digest(
            &bundle.selected_opening.packaged.statement.digest,
            &bundle.selected_opening.packaged.proof.proof_digest,
        ),
        render_u8_list(&bundle.selected_opening.digest),
        render_u8_list(&bundle.digest),
    )
}

fn render_root_execution_defs(name: &str, bundle: &rv64::RootExecutionBundle) -> String {
    let semantic_rows = render_list(&bundle.semantic_rows, |row| {
        let values = row.values.iter().map(|value| value.as_canonical_u64()).collect::<Vec<_>>();
        format!(
            "{{ traceIndex := {}, values := {}, rowDigest := {}, digest := {} }}",
            row.trace_index,
            render_u64_list(&values),
            render_u8_list(&row.row_digest),
            render_u8_list(&row.digest),
        )
    });
    let prepared_bindings = render_list(&bundle.prepared_step_bindings.bindings, |binding| {
        format!(
            "{{ traceIndex := {}, rowDigest := {}, rowOpeningDigest := {}, digest := {} }}",
            binding.trace_index,
            render_u8_list(&binding.row_digest),
            render_u8_list(&binding.row_opening_digest),
            render_u8_list(&binding.digest),
        )
    });
    let row_chunk_routes = render_list(&bundle.row_chunk_routes, |route| {
        format!(
            "{{ logicalIndex := {}, chunkIndex := {}, chunkStartIndex := {}, chunkLocalIndex := {}, digest := {} }}",
            route.logical_index,
            route.chunk_index,
            route.chunk_start_index,
            route.chunk_local_index,
            render_u8_list(&route.digest),
        )
    });
    let row_local_ccs_acceptance = render_list(&bundle.row_local_ccs_acceptance.acceptances, |acceptance| {
        format!(
            "{{ traceIndex := {}, logicalIndex := {}, rowDigest := {}, rowOpeningDigest := {}, preparedStepBindingDigest := {}, rowChunkRouteDigest := {}, publicStepDigest := {}, digest := {} }}",
            acceptance.trace_index,
            acceptance.logical_index,
            render_u8_list(&acceptance.row_digest),
            render_u8_list(&acceptance.row_opening_digest),
            render_u8_list(&acceptance.prepared_step_binding_digest),
            render_u8_list(&acceptance.row_chunk_route_digest),
            render_u8_list(&acceptance.public_step_digest),
            render_u8_list(&acceptance.digest),
        )
    });
    let execution_semantics_refinement =
        render_list(&bundle.execution_semantics_refinement.refinements, |refinement| {
            format!(
                "{{ traceIndex := {}, logicalIndex := {}, semanticRowDigest := {}, rowLocalCcsAcceptanceDigest := {}, preparedStepBindingDigest := {}, publicStepDigest := {}, digest := {} }}",
                refinement.trace_index,
                refinement.logical_index,
                render_u8_list(&refinement.semantic_row_digest),
                render_u8_list(&refinement.row_local_ccs_acceptance_digest),
                render_u8_list(&refinement.prepared_step_binding_digest),
                render_u8_list(&refinement.public_step_digest),
                render_u8_list(&refinement.digest),
            )
        });
    format!(
        "def {name}ExecutionRows : List ExpandedRowView :=\n  {}\n\n\
def {name}SemanticRows : List RootSemanticRowView :=\n  {}\n\n\
def {name}PreparedBindings : List PreparedStepBindingView :=\n  {}\n\n\
def {name}RowChunkRoutes : List RowChunkRouteView :=\n  {}\n\n\
def {name}RowLocalCcsAcceptance : List RootRowLocalCcsAcceptanceView :=\n  {}\n\n\
def {name}ExecutionSemanticsRefinement : List RootExecutionSemanticsRefinementView :=\n  {}\n\n\
def {name} : RootExecutionBundleView :=\n  {{\n    executionRows := {name}ExecutionRows\n    , semanticRows := {name}SemanticRows\n    , semanticRowsDigest := {}\n    , preparedStepBindings := {{ bindings := {name}PreparedBindings, bindingCount := {}, firstBindingDigest := {}, lastBindingDigest := {}, digest := {} }}\n    , rowChunkRoutes := {name}RowChunkRoutes\n    , rowChunkRoutesDigest := {}\n    , rowLocalCcsAcceptance := {{ acceptances := {name}RowLocalCcsAcceptance, acceptanceCount := {}, firstAcceptanceDigest := {}, lastAcceptanceDigest := {}, digest := {} }}\n    , executionSemanticsRefinement := {{ refinements := {name}ExecutionSemanticsRefinement, refinementCount := {}, firstRefinementDigest := {}, lastRefinementDigest := {}, digest := {} }}\n    , familyDigest := {}\n    , digest := {}\n  }}\n",
        render_list(&bundle.execution_rows, super::render_expanded_row),
        semantic_rows,
        prepared_bindings,
        row_chunk_routes,
        row_local_ccs_acceptance,
        execution_semantics_refinement,
        render_u8_list(&bundle.semantic_rows_digest),
        bundle.prepared_step_bindings.binding_count,
        render_option_bytes(
            bundle
                .prepared_step_bindings
                .first_binding_digest
                .as_ref()
                .map(|digest| digest.as_slice()),
        ),
        render_option_bytes(
            bundle
                .prepared_step_bindings
                .last_binding_digest
                .as_ref()
                .map(|digest| digest.as_slice()),
        ),
        render_u8_list(&bundle.prepared_step_bindings.digest),
        render_u8_list(&bundle.row_chunk_routes_digest),
        bundle.row_local_ccs_acceptance.acceptance_count,
        render_option_bytes(
            bundle
                .row_local_ccs_acceptance
                .first_acceptance_digest
                .as_ref()
                .map(|digest| digest.as_slice()),
        ),
        render_option_bytes(
            bundle
                .row_local_ccs_acceptance
                .last_acceptance_digest
                .as_ref()
                .map(|digest| digest.as_slice()),
        ),
        render_u8_list(&bundle.row_local_ccs_acceptance.digest),
        bundle.execution_semantics_refinement.refinement_count,
        render_option_bytes(
            bundle
                .execution_semantics_refinement
                .first_refinement_digest
                .as_ref()
                .map(|digest| digest.as_slice()),
        ),
        render_option_bytes(
            bundle
                .execution_semantics_refinement
                .last_refinement_digest
                .as_ref()
                .map(|digest| digest.as_slice()),
        ),
        render_u8_list(&bundle.execution_semantics_refinement.digest),
        render_u8_list(&bundle.family_digest),
        render_u8_list(&bundle.digest),
    )
}

fn render_kernel_binding_opening_points(points: &rv64::KernelBindingOpeningPoints) -> String {
    format!(
        "{{ firstBinding := {}, lastBinding := {} }}",
        render_option_selected_opening_ref(points.first_binding.as_ref()),
        render_option_selected_opening_ref(points.last_binding.as_ref()),
    )
}

fn render_kernel_prepared_step_opening_points(
    points: &rv64::KernelPreparedStepOpeningPoints,
) -> String {
    format!(
        "{{ firstPreparedStep := {}, lastPreparedStep := {} }}",
        render_option_selected_opening_ref(points.first_prepared_step.as_ref()),
        render_option_selected_opening_ref(points.last_prepared_step.as_ref()),
    )
}

fn render_kernel_binding_opening_claim(claim: &rv64::KernelBindingOpeningClaim) -> String {
    format!(
        "{{ stageClaimBundleDigest := {}, stagePackageBundleDigest := {}, stage1PackageDigest := {}, stage2PackageDigest := {}, stage3PackageDigest := {}, preparedStepBindingsDigest := {}, bindingCount := {}, stage1RowCount := {}, stage2RegisterReadCount := {}, stage2RegisterWriteCount := {}, stage2RamEventCount := {}, stage3ContinuityCount := {}, points := {}, digest := {} }}",
        render_u8_list(&claim.stage_claim_bundle_digest),
        render_u8_list(&claim.stage_package_bundle_digest),
        render_u8_list(&claim.stage1_package_digest),
        render_u8_list(&claim.stage2_package_digest),
        render_u8_list(&claim.stage3_package_digest),
        render_u8_list(&claim.prepared_step_bindings_digest),
        claim.binding_count,
        claim.stage1_row_count,
        claim.stage2_register_read_count,
        claim.stage2_register_write_count,
        claim.stage2_ram_event_count,
        claim.stage3_continuity_count,
        render_kernel_binding_opening_points(&claim.points),
        render_u8_list(&claim.digest),
    )
}

fn render_kernel_prepared_step_opening_claim(claim: &rv64::KernelPreparedStepOpeningClaim) -> String {
    format!(
        "{{ executionDigest := {}, finalStateDigest := {}, transcriptFinalDigest := {}, preparedStepCount := {}, finalPc := {}, halted := {}, points := {}, digest := {} }}",
        render_u8_list(&claim.execution_digest),
        render_u8_list(&claim.final_state_digest),
        render_u8_list(&claim.transcript_final_digest),
        claim.prepared_step_count,
        claim.final_pc,
        render_bool(claim.halted),
        render_kernel_prepared_step_opening_points(&claim.points),
        render_u8_list(&claim.digest),
    )
}

fn render_kernel_opening_bundle_defs(name: &str, bundle: &rv64::SimpleKernelOpeningBundle) -> String {
    format!(
        "def {name} : SimpleKernelOpeningBundleView :=\n  {{\n    claim := {{ bindings := {}, preparedSteps := {}, digest := {} }}\n    , bindings := {{ claim := {}, packaged := {}, digest := {} }}\n    , preparedSteps := {{ claim := {}, packaged := {}, digest := {} }}\n    , digest := {}\n  }}\n",
        render_kernel_binding_opening_claim(&bundle.claim.bindings),
        render_kernel_prepared_step_opening_claim(&bundle.claim.prepared_steps),
        render_u8_list(&bundle.claim.digest),
        render_kernel_binding_opening_claim(&bundle.bindings.claim),
        render_packaged_proof_digest(
            &bundle.bindings.packaged.statement.digest,
            &bundle.bindings.packaged.proof.proof_digest,
        ),
        render_u8_list(&bundle.bindings.digest),
        render_kernel_prepared_step_opening_claim(&bundle.prepared_steps.claim),
        render_packaged_proof_digest(
            &bundle.prepared_steps.packaged.statement.digest,
            &bundle.prepared_steps.packaged.proof.proof_digest,
        ),
        render_u8_list(&bundle.prepared_steps.digest),
        render_u8_list(&bundle.digest),
    )
}

fn render_step_composition_surface(name: &str, surface: &rv64::StepCompositionSurface) -> String {
    format!(
        "def {name} : StepCompositionSurfaceView :=\n  {{\n    stage1SemanticsDigest := {}\n    , stage2SemanticsDigest := {}\n    , stage2TemporalDigest := {}\n    , stage3SemanticsDigest := {}\n    , rootExecutionDigest := {}\n    , preparedStepBindingsDigest := {}\n    , rowChunkRoutesDigest := {}\n    , realRowCount := {}\n    , preparedStepCount := {}\n    , firstRealStepIndex := {}\n    , lastRealStepIndex := {}\n    , initialPc := {}\n    , finalPc := {}\n    , halted := {}\n    , digest := {}\n  }}\n",
        render_u8_list(&surface.stage1_semantics_digest),
        render_u8_list(&surface.stage2_semantics_digest),
        render_u8_list(&surface.stage2_temporal_digest),
        render_u8_list(&surface.stage3_semantics_digest),
        render_u8_list(&surface.root_execution_digest),
        render_u8_list(&surface.prepared_step_bindings_digest),
        render_u8_list(&surface.row_chunk_routes_digest),
        surface.real_row_count,
        surface.prepared_step_count,
        surface.first_real_step_index,
        surface.last_real_step_index,
        surface.initial_pc,
        surface.final_pc,
        render_bool(surface.halted),
        render_u8_list(&surface.digest),
    )
}

fn render_soundness_accounting_surface(
    name: &str,
    surface: &rv64::KernelSoundnessAccountingSurface,
) -> String {
    format!(
        "def {name} : KernelSoundnessAccountingSurfaceView :=\n  {{\n    schemaVersion := {}\n    , stage1ShoutChannels := {}\n    , stage1AddressFamilies := {}\n    , stage2AddressFamilies := {}\n    , twistMemoryFamilies := {}\n    , scalarTerms := {}\n    , schemaDigest := {}\n    , digest := {}\n  }}\n",
        surface.schema_version,
        render_string_list(&surface.stage1_shout_channels),
        render_string_list(&surface.stage1_address_families),
        render_string_list(&surface.stage2_address_families),
        render_string_list(&surface.twist_memory_families),
        render_string_list(&surface.scalar_terms),
        render_u8_list(&surface.schema_digest),
        render_u8_list(&surface.digest),
    )
}

pub(crate) fn render_accepted_artifact_case_module(case: &AcceptedProofVectorCase) -> String {
    format!(
        "import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes\n\nset_option maxHeartbeats 0\nset_option maxRecDepth 65536\n\nnamespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_{}\n\nopen Nightstream.Rv64IM.Generated\n\n\
{}\n\
{}\n\
{}\n\
{}\n\
{}\n\
{}\n\
{}\n\
def artifact : AcceptedProofArtifactView :=\n  {{\n    name := {}\n    , source := {}\n    , derived := {}\n    , kernelProof := {}\n    , exportedProof := {}\n    , exportedStatement := {}\n    , exportedClaims := {}\n    , exportedKernelProof := {}\n    , transcript := {}\n    , stage1 := stage1\n    , stage2 := stage2\n    , stage3 := stage3\n    , rootExecution := rootExecution\n    , stepComposition := stepComposition\n    , soundnessAccounting := soundnessAccounting\n    , kernelOpeningBundle := kernelOpeningBundle\n    , digest := {}\n  }}\n\nend Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_{}\n",
        lean_ident_fragment(&case.name),
        render_stage1_bundle_defs("stage1", &case.artifact.stage1),
        render_stage2_bundle_defs("stage2", &case.artifact.stage2),
        render_stage3_bundle_defs("stage3", &case.artifact.stage3),
        render_root_execution_defs("rootExecution", &case.artifact.root_execution),
        render_kernel_opening_bundle_defs("kernelOpeningBundle", &case.artifact.kernel_opening.opening),
        render_step_composition_surface("stepComposition", &case.artifact.step_composition),
        render_soundness_accounting_surface("soundnessAccounting", &case.artifact.soundness_accounting),
        render_string(&case.name),
        render_source_case(&case.source),
        render_derived_case(&case.derived),
        render_kernel_proof_bundle(&case.proof.kernel),
        render_proof_view(&case.proof),
        render_proof_statement(&case.proof.statement),
        render_kernel_claim_bundle(&case.proof.claim),
        render_kernel_proof_bundle(&case.proof.kernel),
        render_transcript(&case.artifact.transcript),
        render_u8_list(&case.artifact.digest),
        lean_ident_fragment(&case.name),
    )
}

pub(crate) fn render_accepted_proof_corpus_module(cases: &[AcceptedProofVectorCase]) -> String {
    let mut imports = String::new();
    let mut artifacts = String::from("[");
    for (idx, case) in cases.iter().enumerate() {
        let ident = lean_ident_fragment(&case.name);
        imports.push_str(&format!(
            "import Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_{ident}\n"
        ));
        if idx > 0 {
            artifacts.push_str(", ");
        }
        artifacts.push_str(&format!(
            "Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Case_{ident}.artifact"
        ));
    }
    artifacts.push(']');
    format!(
        "{imports}\nnamespace Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors\n\nopen Nightstream.Rv64IM.Generated\n\ndef cases : List AcceptedProofArtifactView :=\n  {artifacts}\n\nend Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors\n"
    )
}

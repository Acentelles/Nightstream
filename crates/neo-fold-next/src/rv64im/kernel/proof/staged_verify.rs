//! Owns accepted-proof staged verification and transcript replay for RV64IM.

use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeField64;
use serde::{Deserialize, Serialize};

use crate::rv64im::ccs::{
    RV64IM_PARITY_INITIAL_MEMORY_LABEL, RV64IM_PARITY_INITIAL_REGS_LABEL, RV64IM_PARITY_KERNEL_FINAL_MIX_LABEL,
    RV64IM_PARITY_STAGE1_MIX_LABEL, RV64IM_PARITY_STAGE2_RAM_MIX_LABEL, RV64IM_PARITY_STAGE2_REG_MIX_LABEL,
    RV64IM_PARITY_STAGE3_CONTINUITY_MIX_LABEL, RV64IM_PARITY_TRANSCRIPT_APP_LABEL,
};
use crate::rv64im::isa::MemoryWord;
use crate::rv64im::kernel::root_lane_witness::{
    build_root_execution_row_chunk_routes, build_root_execution_semantic_rows,
    build_root_execution_semantics_refinement_summary, build_root_row_local_ccs_acceptance_summary,
    root_execution_public_step_digests, root_execution_row_chunk_routes_digest, root_execution_semantic_rows_digest,
};
use crate::rv64im::layout::RV64_REGISTER_COUNT;
use crate::rv64im::stage1::{
    build_sem_inputs, build_stage1_summary, sem_inputs_digest, stage1_row_bindings_digest, verify_stage1_semantics,
    Stage1Summary,
};
use crate::rv64im::stage2::{
    build_stage2_summary, ram_events_family_digest, ram_timeline_digest, register_reads_family_digest,
    register_timeline_digest, register_writes_family_digest, twist_links_family_digest, twist_links_timeline_digest,
    verify_stage2_semantics, Stage2Summary,
};
use crate::rv64im::stage3::{build_stage3_summary, verify_stage3_semantics, Stage3Summary};

use super::perf_diagnostics::Rv64imPublicProofVerifyPerf;
use super::proof_accepted::Rv64imAcceptedProofArtifact;
use super::proof_completeness::{build_step_composition_surface, canonical_kernel_soundness_accounting_surface};
use super::proof_witness::{verify_kernel_claim_packaged_proof, verify_stage_claim_packaged_proof};
use super::simple::{
    materialize_prepared_step_binding_summary, verify_root_main_lane_packaged_proof_with_perf, SimpleKernelError,
};
use super::stage1_canonical::build_stage1_selected_opening_claim;
use super::stage2_canonical::build_stage2_selected_opening_claim;
use super::stage3_canonical::build_stage3_selected_opening_claim;
use super::stage_artifacts::{
    verify_public_kernel_opening_bundle_with_perf, verify_stage1_packaged_opening_proof,
    verify_stage2_packaged_opening_proof, verify_stage3_packaged_opening_proof,
};
use super::{TranscriptEventKind, TranscriptRecord};
use std::time::Instant;

fn millis_since(started: Instant) -> f64 {
    started.elapsed().as_secs_f64() * 1_000.0
}

fn leak_label(bytes: &[u8]) -> &'static [u8] {
    Box::leak(bytes.to_vec().into_boxed_slice())
}

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq, Serialize, Deserialize)]
pub struct TranscriptChallenges {
    pub stage1_mix: u64,
    pub stage2_reg_mix: u64,
    pub stage2_ram_mix: u64,
    pub stage3_continuity_mix: u64,
    pub kernel_final_mix: u64,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage1VerifiedClaims {
    pub sem_inputs_digest: [u8; 32],
    pub rows_digest: [u8; 32],
    pub packaged_digest: [u8; 32],
    pub mix: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage2VerifiedClaims {
    pub register_timeline_digest: [u8; 32],
    pub ram_timeline_digest: [u8; 32],
    pub twist_links_digest: [u8; 32],
    pub packaged_digest: [u8; 32],
    pub reg_mix: u64,
    pub ram_mix: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage3VerifiedClaims {
    pub continuity_digest: [u8; 32],
    pub packaged_digest: [u8; 32],
    pub continuity_mix: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Default, Eq, PartialEq, Serialize, Deserialize)]
pub struct VerifierClaimAccumulator {
    pub transcript: TranscriptChallenges,
    pub stage1: Option<Stage1VerifiedClaims>,
    pub stage2: Option<Stage2VerifiedClaims>,
    pub stage3: Option<Stage3VerifiedClaims>,
    pub root_execution_digest: Option<[u8; 32]>,
}

impl Stage1VerifiedClaims {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage1_verified_claims");
        tr.append_message(b"rows_digest", &self.rows_digest);
        tr.append_message(b"sem_inputs_digest", &self.sem_inputs_digest);
        tr.append_message(b"packaged_digest", &self.packaged_digest);
        tr.append_u64s(b"meta", &[self.mix]);
        tr.digest32()
    }
}

impl Stage2VerifiedClaims {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage2_verified_claims");
        tr.append_message(b"register_timeline_digest", &self.register_timeline_digest);
        tr.append_message(b"ram_timeline_digest", &self.ram_timeline_digest);
        tr.append_message(b"twist_links_digest", &self.twist_links_digest);
        tr.append_message(b"packaged_digest", &self.packaged_digest);
        tr.append_u64s(b"meta", &[self.reg_mix, self.ram_mix]);
        tr.digest32()
    }
}

impl Stage3VerifiedClaims {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage3_verified_claims");
        tr.append_message(b"continuity_digest", &self.continuity_digest);
        tr.append_message(b"packaged_digest", &self.packaged_digest);
        tr.append_u64s(b"meta", &[self.continuity_mix]);
        tr.digest32()
    }
}

fn replay_transcript(record: &TranscriptRecord) -> Result<TranscriptChallenges, SimpleKernelError> {
    if record.app_label.as_slice() != RV64IM_PARITY_TRANSCRIPT_APP_LABEL {
        return Err(SimpleKernelError::Bridge(
            "RV64IM transcript replay saw an unexpected app label".into(),
        ));
    }
    let mut tr = Poseidon2Transcript::new(RV64IM_PARITY_TRANSCRIPT_APP_LABEL);
    let mut challenges = TranscriptChallenges::default();
    for event in &record.events {
        let cursor_before = super::TranscriptCursorSnapshot {
            state_words: tr.state().map(|value| value.as_canonical_u64()),
            absorbed: tr.absorbed(),
        };
        if cursor_before != event.cursor_before {
            return Err(SimpleKernelError::Bridge(
                "RV64IM transcript replay cursor-before mismatch".into(),
            ));
        }
        match event.kind {
            TranscriptEventKind::AppendMessage => tr.append_message(leak_label(&event.label), &event.message),
            TranscriptEventKind::AppendU64s => tr.append_u64s(leak_label(&event.label), &event.u64s),
            TranscriptEventKind::ChallengeField => {
                let output = tr
                    .challenge_field(leak_label(&event.label))
                    .as_canonical_u64();
                if event.challenge_output != Some(output) {
                    return Err(SimpleKernelError::Bridge(
                        "RV64IM transcript replay challenge mismatch".into(),
                    ));
                }
                if event.label.as_slice() == RV64IM_PARITY_STAGE1_MIX_LABEL {
                    challenges.stage1_mix = output;
                } else if event.label.as_slice() == RV64IM_PARITY_STAGE2_REG_MIX_LABEL {
                    challenges.stage2_reg_mix = output;
                } else if event.label.as_slice() == RV64IM_PARITY_STAGE2_RAM_MIX_LABEL {
                    challenges.stage2_ram_mix = output;
                } else if event.label.as_slice() == RV64IM_PARITY_STAGE3_CONTINUITY_MIX_LABEL {
                    challenges.stage3_continuity_mix = output;
                } else if event.label.as_slice() == RV64IM_PARITY_KERNEL_FINAL_MIX_LABEL {
                    challenges.kernel_final_mix = output;
                }
            }
            TranscriptEventKind::Digest32 => {
                let output = tr.digest32();
                if event.digest_output != Some(output) {
                    return Err(SimpleKernelError::Bridge(
                        "RV64IM transcript replay digest mismatch".into(),
                    ));
                }
            }
        }
        let cursor_after = super::TranscriptCursorSnapshot {
            state_words: tr.state().map(|value| value.as_canonical_u64()),
            absorbed: tr.absorbed(),
        };
        if cursor_after != event.cursor_after {
            return Err(SimpleKernelError::Bridge(
                "RV64IM transcript replay cursor-after mismatch".into(),
            ));
        }
    }
    Ok(challenges)
}

fn extract_public_initial_state(
    record: &TranscriptRecord,
) -> Result<([u64; RV64_REGISTER_COUNT], Vec<MemoryWord>), SimpleKernelError> {
    let registers = record
        .events
        .iter()
        .find(|event| {
            event.kind == TranscriptEventKind::AppendU64s && event.label.as_slice() == RV64IM_PARITY_INITIAL_REGS_LABEL
        })
        .ok_or_else(|| SimpleKernelError::Bridge("RV64IM transcript is missing the initial register event".into()))?;
    if registers.u64s.len() != RV64_REGISTER_COUNT {
        return Err(SimpleKernelError::Bridge(
            "RV64IM transcript carried an unexpected initial register length".into(),
        ));
    }
    let mut initial_registers = [0u64; RV64_REGISTER_COUNT];
    initial_registers.copy_from_slice(&registers.u64s);

    let memory = record
        .events
        .iter()
        .find(|event| {
            event.kind == TranscriptEventKind::AppendU64s
                && event.label.as_slice() == RV64IM_PARITY_INITIAL_MEMORY_LABEL
        })
        .ok_or_else(|| SimpleKernelError::Bridge("RV64IM transcript is missing the initial memory event".into()))?;
    if memory.u64s.len() % 2 != 0 {
        return Err(SimpleKernelError::Bridge(
            "RV64IM transcript carried a malformed initial memory payload".into(),
        ));
    }
    let initial_memory = memory
        .u64s
        .chunks_exact(2)
        .map(|chunk| MemoryWord {
            addr: chunk[0],
            value: chunk[1],
        })
        .collect::<Vec<_>>();
    Ok((initial_registers, initial_memory))
}

pub(crate) fn verify_stage1(
    artifact: &Rv64imAcceptedProofArtifact,
    accumulator: &mut VerifierClaimAccumulator,
) -> Result<Stage1VerifiedClaims, SimpleKernelError> {
    if artifact.stage1.digest != artifact.stage1.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage1 proof bundle digest mismatch".into(),
        ));
    }
    let summary = Stage1Summary {
        rows: artifact.stage1.row_bindings.clone(),
    };
    let expected_sem_inputs = build_sem_inputs(&artifact.root_execution.execution_rows);
    if artifact.stage1.sem_inputs != expected_sem_inputs {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage1 semantic inputs mismatch".into(),
        ));
    }
    let expected_summary = build_stage1_summary(&artifact.root_execution.execution_rows);
    if summary != expected_summary {
        return Err(SimpleKernelError::Bridge("RV64IM stage1 row bindings mismatch".into()));
    }
    if artifact.stage1.semantics.digest != artifact.stage1.semantics.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage1 semantics proof digest mismatch".into(),
        ));
    }
    let actual_sem_inputs_digest = sem_inputs_digest(&artifact.stage1.sem_inputs);
    let actual_rows_digest = stage1_row_bindings_digest(&artifact.stage1.row_bindings);
    if artifact.stage1.semantics.sem_inputs_digest != actual_sem_inputs_digest
        || artifact.stage1.semantics.row_bindings_digest != actual_rows_digest
        || actual_rows_digest != artifact.stage_claims.claims.stage1.rows.rows_digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage1 semantic surface digest mismatch".into(),
        ));
    }
    verify_stage1_semantics(&artifact.stage1.sem_inputs, &artifact.stage1.row_bindings)
        .map_err(SimpleKernelError::Bridge)?;
    let expected_claim = build_stage1_selected_opening_claim(
        &summary,
        &artifact.stage_claims.claims.stage1.claim,
        &artifact.stage_claims.claims.stage1.rows,
    )?;
    verify_stage1_packaged_opening_proof(&artifact.stage1.selected_opening, &expected_claim)?;
    if artifact.stage_packages.packages.stage1.digest != artifact.stage1.selected_opening.digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage1 selected opening does not match the carried stage package".into(),
        ));
    }
    if artifact.stage1.bytecode.digest != artifact.stage1.bytecode.expected_digest()
        || artifact.stage1.alu.digest != artifact.stage1.alu.expected_digest()
        || artifact.stage1.branch.digest != artifact.stage1.branch.expected_digest()
        || artifact.stage1.address_correctness.digest != artifact.stage1.address_correctness.expected_digest()
        || artifact.stage1.linkage.digest != artifact.stage1.linkage.expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage1 sub-proof digest mismatch".into(),
        ));
    }
    let claims = Stage1VerifiedClaims {
        sem_inputs_digest: actual_sem_inputs_digest,
        rows_digest: artifact.stage_claims.claims.stage1.rows.rows_digest,
        packaged_digest: artifact.stage1.selected_opening.digest,
        mix: accumulator.transcript.stage1_mix,
        digest: [0; 32],
    };
    let claims = Stage1VerifiedClaims {
        digest: claims.expected_digest(),
        ..claims
    };
    accumulator.stage1 = Some(claims.clone());
    Ok(claims)
}

pub(crate) fn verify_stage2(
    artifact: &Rv64imAcceptedProofArtifact,
    accumulator: &mut VerifierClaimAccumulator,
) -> Result<Stage2VerifiedClaims, SimpleKernelError> {
    if artifact.stage2.digest != artifact.stage2.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage2 proof bundle digest mismatch".into(),
        ));
    }
    let summary = Stage2Summary {
        register_reads: artifact.stage2.register.reads.clone(),
        register_writes: artifact.stage2.register.writes.clone(),
        ram_events: artifact.stage2.ram.events.clone(),
        twist_links: artifact.stage2.temporal.twist_links.clone(),
    };
    let expected_summary = build_stage2_summary(&artifact.root_execution.execution_rows);
    if summary != expected_summary {
        return Err(SimpleKernelError::Bridge("RV64IM stage2 event surface mismatch".into()));
    }
    if artifact.stage2.register.digest != artifact.stage2.register.expected_digest()
        || artifact.stage2.ram.digest != artifact.stage2.ram.expected_digest()
        || artifact.stage2.temporal.digest != artifact.stage2.temporal.expected_digest()
        || artifact.stage2.semantics.digest != artifact.stage2.semantics.expected_digest()
        || artifact.stage2.linkage.digest != artifact.stage2.linkage.expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage2 sub-proof digest mismatch".into(),
        ));
    }
    let (initial_registers, initial_memory) = extract_public_initial_state(&artifact.transcript)?;
    verify_stage2_semantics(
        &artifact.root_execution.execution_rows,
        &summary,
        &initial_registers,
        &initial_memory,
    )
    .map_err(SimpleKernelError::Bridge)?;
    let actual_register_timeline_digest = register_timeline_digest(&summary.register_reads, &summary.register_writes);
    let actual_ram_timeline_digest = ram_timeline_digest(&summary.ram_events);
    let actual_twist_links_digest = twist_links_timeline_digest(&summary.twist_links);
    let actual_register_reads_family_digest = register_reads_family_digest(&summary.register_reads);
    let actual_register_writes_family_digest = register_writes_family_digest(&summary.register_writes);
    let actual_ram_events_family_digest = ram_events_family_digest(&summary.ram_events);
    let actual_twist_links_family_digest = twist_links_family_digest(&summary.twist_links);
    if artifact.stage2.register.timeline_digest != actual_register_timeline_digest
        || artifact.stage2.ram.timeline_digest != actual_ram_timeline_digest
        || artifact.stage2.temporal.register_timeline_digest != actual_register_timeline_digest
        || artifact.stage2.temporal.ram_timeline_digest != actual_ram_timeline_digest
        || artifact.stage2.temporal.twist_links_digest != actual_twist_links_digest
        || artifact.stage2.semantics.register_reads_family_digest != actual_register_reads_family_digest
        || artifact.stage2.semantics.register_writes_family_digest != actual_register_writes_family_digest
        || artifact.stage2.semantics.ram_events_family_digest != actual_ram_events_family_digest
        || artifact.stage2.semantics.twist_links_family_digest != actual_twist_links_family_digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage2 semantic surface digest mismatch".into(),
        ));
    }
    if artifact.stage2.linkage.register_reads_family_digest != actual_register_reads_family_digest
        || artifact.stage2.linkage.register_writes_family_digest != actual_register_writes_family_digest
        || artifact.stage2.linkage.ram_events_family_digest != actual_ram_events_family_digest
        || artifact.stage2.linkage.twist_links_family_digest != actual_twist_links_family_digest
        || artifact
            .stage_claims
            .claims
            .stage2
            .families
            .register_reads_digest
            != actual_register_reads_family_digest
        || artifact
            .stage_claims
            .claims
            .stage2
            .families
            .register_writes_digest
            != actual_register_writes_family_digest
        || artifact
            .stage_claims
            .claims
            .stage2
            .families
            .ram_events_digest
            != actual_ram_events_family_digest
        || artifact
            .stage_claims
            .claims
            .stage2
            .families
            .twist_links_digest
            != actual_twist_links_family_digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage2 linkage digest mismatch".into(),
        ));
    }
    let expected_claim = build_stage2_selected_opening_claim(
        &summary,
        &artifact.stage_claims.claims.stage2.claim,
        &artifact.stage_claims.claims.stage2.families,
    );
    verify_stage2_packaged_opening_proof(&artifact.stage2.selected_opening, &expected_claim)?;
    if artifact.stage_packages.packages.stage2.digest != artifact.stage2.selected_opening.digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage2 selected opening does not match the carried stage package".into(),
        ));
    }
    let claims = Stage2VerifiedClaims {
        register_timeline_digest: actual_register_timeline_digest,
        ram_timeline_digest: actual_ram_timeline_digest,
        twist_links_digest: actual_twist_links_digest,
        packaged_digest: artifact.stage2.selected_opening.digest,
        reg_mix: accumulator.transcript.stage2_reg_mix,
        ram_mix: accumulator.transcript.stage2_ram_mix,
        digest: [0; 32],
    };
    let claims = Stage2VerifiedClaims {
        digest: claims.expected_digest(),
        ..claims
    };
    accumulator.stage2 = Some(claims.clone());
    Ok(claims)
}

pub(crate) fn verify_stage3(
    artifact: &Rv64imAcceptedProofArtifact,
    accumulator: &mut VerifierClaimAccumulator,
) -> Result<Stage3VerifiedClaims, SimpleKernelError> {
    if artifact.stage3.digest != artifact.stage3.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage3 proof bundle digest mismatch".into(),
        ));
    }
    let summary = Stage3Summary {
        continuity: artifact.stage3.bridge.continuity.clone(),
        halted: artifact.stage3.bridge.halted,
    };
    let expected_summary = build_stage3_summary(&artifact.root_execution.execution_rows);
    if summary != expected_summary {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage3 continuity surface mismatch".into(),
        ));
    }
    if artifact.stage3.bridge.digest != artifact.stage3.bridge.expected_digest()
        || artifact.stage3.semantics.digest != artifact.stage3.semantics.expected_digest()
        || artifact.stage3.linkage.digest != artifact.stage3.linkage.expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage3 sub-proof digest mismatch".into(),
        ));
    }
    verify_stage3_semantics(
        &summary.continuity,
        &artifact.root_execution.execution_rows,
        &artifact.root_execution,
        artifact.statement.initial_pc,
        artifact.statement.final_pc,
    )
    .map_err(SimpleKernelError::Bridge)?;
    let actual_root_semantic_rows_digest = root_execution_semantic_rows_digest(&artifact.root_execution.semantic_rows);
    let actual_row_chunk_routes_digest =
        root_execution_row_chunk_routes_digest(&artifact.root_execution.row_chunk_routes);
    if artifact.stage3.semantics.continuity_digest != artifact.stage3.bridge.continuity_digest
        || artifact.stage3.semantics.root_semantic_rows_digest != actual_root_semantic_rows_digest
        || artifact.stage3.semantics.row_chunk_routes_digest != actual_row_chunk_routes_digest
        || artifact.stage3.semantics.prepared_step_bindings_digest
            != artifact.root_execution.prepared_step_bindings.digest
        || artifact.stage3.semantics.stage2_temporal_digest != artifact.stage2.temporal.digest
        || artifact.stage3.semantics.initial_pc != artifact.statement.initial_pc
        || artifact.stage3.semantics.final_pc != artifact.statement.final_pc
        || artifact.stage3.semantics.real_row_count != summary.continuity.len() as u64
        || artifact.stage3.semantics.first_real_step_index
            != summary
                .continuity
                .first()
                .map(|event| event.step_index as u64)
                .unwrap_or(0)
        || artifact.stage3.semantics.last_real_step_index
            != summary
                .continuity
                .last()
                .map(|event| event.step_index as u64)
                .unwrap_or(0)
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage3 semantic bridge mismatch".into(),
        ));
    }
    if artifact.stage3.linkage.continuity_family_digest
        != artifact
            .stage_claims
            .claims
            .stage3
            .continuity
            .continuity_digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage3 linkage digest mismatch".into(),
        ));
    }
    let expected_claim = build_stage3_selected_opening_claim(
        &summary,
        &artifact.stage_claims.claims.stage3.claim,
        &artifact.stage_claims.claims.stage3.continuity,
    );
    verify_stage3_packaged_opening_proof(&artifact.stage3.selected_opening, &expected_claim)?;
    if artifact.stage_packages.packages.stage3.digest != artifact.stage3.selected_opening.digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage3 selected opening does not match the carried stage package".into(),
        ));
    }
    let claims = Stage3VerifiedClaims {
        continuity_digest: artifact.stage3.bridge.continuity_digest,
        packaged_digest: artifact.stage3.selected_opening.digest,
        continuity_mix: accumulator.transcript.stage3_continuity_mix,
        digest: [0; 32],
    };
    let claims = Stage3VerifiedClaims {
        digest: claims.expected_digest(),
        ..claims
    };
    accumulator.stage3 = Some(claims.clone());
    Ok(claims)
}

fn verify_root_execution(artifact: &Rv64imAcceptedProofArtifact) -> Result<(), SimpleKernelError> {
    if artifact.root_execution.digest != artifact.root_execution.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root execution bundle digest mismatch".into(),
        ));
    }
    let expected_semantic_rows = build_root_execution_semantic_rows(&artifact.root_execution.execution_rows);
    if artifact.root_execution.semantic_rows != expected_semantic_rows {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root execution semantic rows do not match the carried execution rows".into(),
        ));
    }
    let expected_semantic_rows_digest = root_execution_semantic_rows_digest(&expected_semantic_rows);
    if artifact.root_execution.semantic_rows_digest != expected_semantic_rows_digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root execution semantic-row digest mismatch".into(),
        ));
    }
    let expected_prepared_step_bindings = materialize_prepared_step_binding_summary(
        &artifact.root_execution.execution_rows,
        &artifact.root_lane_columns,
    )?;
    if artifact.root_execution.prepared_step_bindings != expected_prepared_step_bindings {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root execution prepared-step bindings mismatch".into(),
        ));
    }
    let prepared_step_bindings = &artifact.root_execution.prepared_step_bindings;
    let claimed_prepared_step_bindings = &artifact.kernel_claims.claims.prepared_step_bindings;
    if prepared_step_bindings.digest != claimed_prepared_step_bindings.digest
        || prepared_step_bindings.binding_count != claimed_prepared_step_bindings.binding_count
        || prepared_step_bindings.first_binding_digest != claimed_prepared_step_bindings.first_binding_digest
        || prepared_step_bindings.last_binding_digest != claimed_prepared_step_bindings.last_binding_digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root execution prepared-step binding summary mismatch".into(),
        ));
    }
    let public_step_digests = root_execution_public_step_digests(&artifact.main_lane.packaged.statement);
    let expected_routes = build_root_execution_row_chunk_routes(&artifact.main_lane.packaged.statement);
    if artifact.root_execution.row_chunk_routes != expected_routes {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root execution row-to-chunk routing mismatch".into(),
        ));
    }
    let expected_routes_digest = root_execution_row_chunk_routes_digest(&expected_routes);
    if artifact.root_execution.row_chunk_routes_digest != expected_routes_digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root execution row-to-chunk digest mismatch".into(),
        ));
    }
    let expected_row_local_ccs_acceptance = build_root_row_local_ccs_acceptance_summary(
        &expected_prepared_step_bindings,
        &expected_routes,
        &public_step_digests,
    )?;
    if artifact.root_execution.row_local_ccs_acceptance != expected_row_local_ccs_acceptance {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root execution row-local CCS acceptance mismatch".into(),
        ));
    }
    let expected_execution_semantics_refinement = build_root_execution_semantics_refinement_summary(
        &expected_semantic_rows,
        &expected_prepared_step_bindings,
        &expected_row_local_ccs_acceptance,
        &public_step_digests,
    )?;
    if artifact.root_execution.execution_semantics_refinement != expected_execution_semantics_refinement {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root execution semantics refinement mismatch".into(),
        ));
    }
    Ok(())
}

fn verify_step_composition_surface(artifact: &Rv64imAcceptedProofArtifact) -> Result<(), SimpleKernelError> {
    let expected = build_step_composition_surface(
        &artifact.stage1,
        &artifact.stage2,
        &artifact.stage3,
        &artifact.root_execution,
        artifact.statement.initial_pc,
        artifact.statement.final_pc,
    );
    if artifact.step_composition != expected {
        return Err(SimpleKernelError::Bridge(
            "RV64IM step composition surface mismatch".into(),
        ));
    }
    Ok(())
}

fn verify_soundness_accounting_surface(artifact: &Rv64imAcceptedProofArtifact) -> Result<(), SimpleKernelError> {
    let expected = canonical_kernel_soundness_accounting_surface();
    if artifact.soundness_accounting != expected {
        return Err(SimpleKernelError::Bridge(
            "RV64IM soundness accounting surface mismatch".into(),
        ));
    }
    Ok(())
}

pub(crate) fn verify_accepted_proof_artifact_with_perf(
    artifact: &Rv64imAcceptedProofArtifact,
) -> Result<Rv64imPublicProofVerifyPerf, SimpleKernelError> {
    let total_started = Instant::now();
    if artifact.digest != artifact.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM accepted proof artifact digest mismatch".into(),
        ));
    }
    let transcript_started = Instant::now();
    let transcript = replay_transcript(&artifact.transcript)?;
    let transcript_ms = millis_since(transcript_started);
    let mut accumulator = VerifierClaimAccumulator {
        transcript,
        ..VerifierClaimAccumulator::default()
    };

    let claim_digests_started = Instant::now();
    if artifact.claim.digest != artifact.claim.expected_digest()
        || artifact.statement.digest != artifact.statement.expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM accepted proof public claim digest mismatch".into(),
        ));
    }
    let public_claim_digests_ms = millis_since(claim_digests_started);

    let bundle_digests_started = Instant::now();
    if artifact.stage_claims.digest != artifact.stage_claims.expected_digest()
        || artifact.stage_packages.digest != artifact.stage_packages.expected_digest()
        || artifact.kernel_opening.digest != artifact.kernel_opening.expected_digest()
        || artifact.kernel_claims.digest != artifact.kernel_claims.expected_digest()
        || artifact.root_lane_columns.digest != artifact.root_lane_columns.expected_digest()
        || artifact.root_lane_commitment.digest != artifact.root_lane_commitment.expected_digest()
        || artifact.main_lane.digest != artifact.main_lane.expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM accepted proof bundle digest mismatch".into(),
        ));
    }
    let public_bundle_digests_ms = millis_since(bundle_digests_started);

    let stage_claims_started = Instant::now();
    verify_stage_claim_packaged_proof(&artifact.stage_claims.claims, &artifact.stage_claims.packaged)?;
    verify_kernel_claim_packaged_proof(&artifact.kernel_claims.claims, &artifact.kernel_claims.packaged)?;
    let stage_package_started = Instant::now();
    verify_stage1(artifact, &mut accumulator)?;
    verify_stage2(artifact, &mut accumulator)?;
    verify_stage3(artifact, &mut accumulator)?;
    let stage_package_verify_ms = millis_since(stage_package_started);

    let root_execution_started = Instant::now();
    verify_root_execution(artifact)?;
    verify_step_composition_surface(artifact)?;
    verify_soundness_accounting_surface(artifact)?;
    accumulator.root_execution_digest = Some(artifact.root_execution.digest);
    let root_execution_ms = millis_since(root_execution_started);

    let root_main_lane_started = Instant::now();
    let root_main_lane = verify_root_main_lane_packaged_proof_with_perf(
        &artifact.root_execution.execution_rows,
        &artifact.main_lane.packaged,
    )?;
    let root_main_lane_proof_ms = millis_since(root_main_lane_started);

    let kernel_opening_started = Instant::now();
    verify_public_kernel_opening_bundle_with_perf(
        &artifact.kernel_opening.opening,
        &artifact.stage_claims.claims,
        &artifact.stage_packages.packages,
        &artifact.kernel_claims.claims,
        &artifact.root_lane_commitment,
    )?;
    let kernel_opening_verify_ms = millis_since(kernel_opening_started);

    let public_bundle_bindings_ms = millis_since(stage_claims_started);
    Ok(Rv64imPublicProofVerifyPerf {
        public_claim_digests_ms,
        public_bundle_digests_ms,
        public_bundle_bindings_ms,
        public_kernel_build: Default::default(),
        root_main_lane_proof_ms,
        root_main_lane,
        stage_package_verify_ms,
        kernel_opening_verify_ms,
        summary_consistency_ms: transcript_ms + root_execution_ms,
        total_ms: millis_since(total_started),
    })
}

//! Owns the Rust export of the grouped `KernelExecutionDigest` boundary.
//! The group names track the Lean contract directly; remaining parity gaps
//! should be closed here instead of behind a second Rust-local artifact type.

use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::proof::StepInput;

use super::bridge_binding::prepared_step_digest;
use super::root_context::build_prepared_steps_from_frames;
use super::soundness_accounting::{build_kernel_error_surface, KernelErrorSurface};
use super::{
    build_kernel_exact_frames, opening_commitment_id_key, CommitmentId, KernelBridgeBindingSummary, KernelExactFrame,
    KernelOpeningManifest, KernelRowProjectionSummary, RootOpeningManifest, SimpleKernelError, SimpleKernelOutput,
    SimpleKernelProof, SimpleKernelPublicInput,
};

#[derive(Clone, Debug, PartialEq)]
pub struct KernelTraceSurface {
    pub frames: Vec<KernelExactFrame>,
    pub stage1_digest: [u8; 32],
    pub stage2_digest: [u8; 32],
    pub stage3_digest: [u8; 32],
    pub semantic_evidence_summary_digest: [u8; 32],
}

#[derive(Clone, Debug)]
pub struct KernelExportSurface {
    pub semantic_rows: usize,
    pub prepared_steps: Vec<StepInput>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelAuditSurface {
    pub row_projection_summary: KernelRowProjectionSummary,
    pub bridge_binding_summary: KernelBridgeBindingSummary,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelManifestSurface {
    pub root0_commitment_ids: Vec<CommitmentId>,
    pub kernel_manifest: KernelOpeningManifest,
    pub root_manifest: RootOpeningManifest,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelTranscriptSurface {
    pub events: Vec<KernelTranscriptEvent>,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum KernelTranscriptEvent {
    AbsorbCommitment(CommitmentId),
    AbsorbMetaPub,
    SampleStage1Cycle,
    Stage1FetchSumcheck,
    Stage1DecodeSumcheck,
    Stage1AluSumcheck,
    Stage1Eq4Sumcheck,
    Stage1AddrCheckFetch,
    Stage1AddrCheckDecode,
    Stage1AddrCheckAlu,
    Stage1AddrCheckEq4,
    RecordFetchAddr,
    RecordDecodeAddr,
    RecordAluAddr,
    DeriveAdd8LoAddr,
    RecordEq4Addr,
    SampleGammaLookupLink,
    Stage1LinkageBatch,
    SampleStage2Cycle,
    SampleGammaReg,
    Stage2RegRwBatched,
    Stage2RegValFromInc,
    SampleGammaRam,
    Stage2RamRwBatched,
    Stage2RamValFromInc,
    Stage2RamRafRead,
    Stage2RamRafWrite,
    Stage2AddrCheckRegRaX,
    Stage2AddrCheckRegRaY,
    Stage2AddrCheckRegRaI,
    Stage2AddrCheckRegWa,
    Stage2AddrCheckRamRa,
    Stage2AddrCheckRamWa,
    RecordRegAddr,
    RecordRamAddr,
    SampleGammaTwistLink,
    Stage2LinkageBatch,
    SampleBeta1,
    SampleBeta2,
    SampleStage3Cycle,
    LaneShiftReduction,
    Stage3Continuity,
    Stage3StartBoundaryOpening,
    Stage3FinalBoundaryOpening,
    RowBinding(usize),
    EmitKernelOpeningClaims,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelExecutionDigest {
    pub trace_surface: KernelTraceSurface,
    pub export_surface: KernelExportSurface,
    pub audit_surface: KernelAuditSurface,
    pub manifest_surface: KernelManifestSurface,
    pub transcript_surface: KernelTranscriptSurface,
    pub error_surface: KernelErrorSurface,
}

impl KernelTraceSurface {
    pub fn digest32(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_trace_surface");
        tr.append_u64s(
            b"neo.fold.next/chip8/kernel_trace_surface/frame_len",
            &[self.frames.len() as u64],
        );
        for frame in &self.frames {
            tr.append_message(b"neo.fold.next/chip8/kernel_trace_surface/frame", &frame.digest32());
        }
        tr.append_message(b"neo.fold.next/chip8/kernel_trace_surface/stage1", &self.stage1_digest);
        tr.append_message(b"neo.fold.next/chip8/kernel_trace_surface/stage2", &self.stage2_digest);
        tr.append_message(b"neo.fold.next/chip8/kernel_trace_surface/stage3", &self.stage3_digest);
        tr.append_message(
            b"neo.fold.next/chip8/kernel_trace_surface/semantic_evidence_summary",
            &self.semantic_evidence_summary_digest,
        );
        tr.digest32()
    }
}

impl KernelExportSurface {
    pub fn digest32(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_export_surface");
        tr.append_u64s(
            b"neo.fold.next/chip8/kernel_export_surface/meta",
            &[self.semantic_rows as u64, self.prepared_steps.len() as u64],
        );
        for step in &self.prepared_steps {
            tr.append_message(
                b"neo.fold.next/chip8/kernel_export_surface/prepared_step",
                &prepared_step_digest(step),
            );
        }
        tr.digest32()
    }
}

impl PartialEq for KernelExportSurface {
    fn eq(&self, other: &Self) -> bool {
        self.semantic_rows == other.semantic_rows
            && self.prepared_steps.len() == other.prepared_steps.len()
            && self
                .prepared_steps
                .iter()
                .map(prepared_step_digest)
                .eq(other.prepared_steps.iter().map(prepared_step_digest))
    }
}

impl KernelAuditSurface {
    pub fn digest32(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_audit_surface");
        tr.append_message(
            b"neo.fold.next/chip8/kernel_audit_surface/row_projection_summary",
            &self.row_projection_summary.digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/kernel_audit_surface/bridge_binding_summary",
            &self.bridge_binding_summary.digest,
        );
        tr.digest32()
    }
}

impl KernelManifestSurface {
    pub fn digest32(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_manifest_surface");
        append_commitment_ids(
            &mut tr,
            b"neo.fold.next/chip8/kernel_manifest_surface/root0_commitment_ids",
            &self.root0_commitment_ids,
        );
        tr.append_message(
            b"neo.fold.next/chip8/kernel_manifest_surface/kernel_manifest_digest",
            &self.kernel_manifest.digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/kernel_manifest_surface/root_manifest_digest",
            &self.root_manifest.digest,
        );
        tr.digest32()
    }
}

impl KernelTranscriptSurface {
    pub fn digest32(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_transcript_surface");
        tr.append_u64s(
            b"neo.fold.next/chip8/kernel_transcript_surface/event_len",
            &[self.events.len() as u64],
        );
        for event in &self.events {
            append_transcript_event(&mut tr, event);
        }
        tr.digest32()
    }
}

impl KernelExecutionDigest {
    pub fn digest32(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_execution_digest");
        tr.append_message(
            b"neo.fold.next/chip8/kernel_execution_digest/trace_surface",
            &self.trace_surface.digest32(),
        );
        tr.append_message(
            b"neo.fold.next/chip8/kernel_execution_digest/export_surface",
            &self.export_surface.digest32(),
        );
        tr.append_message(
            b"neo.fold.next/chip8/kernel_execution_digest/audit_surface",
            &self.audit_surface.digest32(),
        );
        tr.append_message(
            b"neo.fold.next/chip8/kernel_execution_digest/manifest_surface",
            &self.manifest_surface.digest32(),
        );
        tr.append_message(
            b"neo.fold.next/chip8/kernel_execution_digest/transcript_surface",
            &self.transcript_surface.digest32(),
        );
        tr.append_message(
            b"neo.fold.next/chip8/kernel_execution_digest/error_surface",
            &self.error_surface.digest,
        );
        tr.digest32()
    }
}

pub fn build_kernel_execution_digest(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
) -> Result<KernelExecutionDigest, SimpleKernelError> {
    let frames = build_kernel_exact_frames(public, proof)?;
    let prepared_steps = build_prepared_steps_from_frames(&frames)?;
    assert_prepared_steps_match_output(&prepared_steps, &output.prepared_steps)?;
    Ok(KernelExecutionDigest {
        trace_surface: build_kernel_trace_surface(&frames, proof),
        export_surface: build_kernel_export_surface(&frames, &prepared_steps),
        audit_surface: build_kernel_audit_surface(
            &frames,
            &output.row_projection_summary,
            &output.bridge_binding_summary,
            &prepared_steps,
        )?,
        manifest_surface: build_kernel_manifest_surface(&output.kernel_opening_manifest, &output.root_opening_manifest),
        transcript_surface: build_kernel_transcript_surface(proof)?,
        error_surface: build_kernel_error_surface(),
    })
}

pub fn verify_kernel_execution_digest(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
    digest: &KernelExecutionDigest,
) -> Result<(), String> {
    let expected = build_kernel_execution_digest(public, proof, output)
        .map_err(|err| format!("kernel execution digest build failed: {err}"))?;
    if digest != &expected {
        return Err("kernel execution digest mismatch".into());
    }
    Ok(())
}

pub fn build_kernel_transcript_surface(
    proof: &SimpleKernelProof,
) -> Result<KernelTranscriptSurface, SimpleKernelError> {
    let expected_rows: Vec<_> = (0..proof.meta_pub.semantic_rows).collect();
    let actual_rows: Vec<_> = proof
        .stage3
        .row_bindings
        .iter()
        .map(|row| row.row_index)
        .collect();
    if actual_rows != expected_rows {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "kernel transcript row bindings {:?} do not match expected {:?}",
            actual_rows, expected_rows
        )));
    }
    Ok(KernelTranscriptSurface {
        events: kernel_transcript_events(proof.meta_pub.semantic_rows),
    })
}

fn build_kernel_trace_surface(frames: &[KernelExactFrame], proof: &SimpleKernelProof) -> KernelTraceSurface {
    KernelTraceSurface {
        frames: frames.to_vec(),
        stage1_digest: proof.semantic_evidence_summary.stage1_digest,
        stage2_digest: proof.semantic_evidence_summary.stage2_digest,
        stage3_digest: proof.semantic_evidence_summary.stage3_digest,
        semantic_evidence_summary_digest: proof.semantic_evidence_summary.digest,
    }
}

fn kernel_transcript_events(semantic_rows: usize) -> Vec<KernelTranscriptEvent> {
    let mut events = Vec::with_capacity(root0_commitment_ids().len() + 1 + 16 + 19 + 8 + semantic_rows + 1);
    events.extend(
        root0_commitment_ids()
            .into_iter()
            .map(KernelTranscriptEvent::AbsorbCommitment),
    );
    events.push(KernelTranscriptEvent::AbsorbMetaPub);
    events.extend(stage1_transcript_events());
    events.extend(stage2_transcript_events());
    events.extend(stage3_prefix_transcript_events());
    events.extend((0..semantic_rows).map(KernelTranscriptEvent::RowBinding));
    events.push(KernelTranscriptEvent::EmitKernelOpeningClaims);
    events
}

fn stage1_transcript_events() -> [KernelTranscriptEvent; 16] {
    [
        KernelTranscriptEvent::SampleStage1Cycle,
        KernelTranscriptEvent::Stage1FetchSumcheck,
        KernelTranscriptEvent::Stage1DecodeSumcheck,
        KernelTranscriptEvent::Stage1AluSumcheck,
        KernelTranscriptEvent::Stage1Eq4Sumcheck,
        KernelTranscriptEvent::Stage1AddrCheckFetch,
        KernelTranscriptEvent::Stage1AddrCheckDecode,
        KernelTranscriptEvent::Stage1AddrCheckAlu,
        KernelTranscriptEvent::Stage1AddrCheckEq4,
        KernelTranscriptEvent::RecordFetchAddr,
        KernelTranscriptEvent::RecordDecodeAddr,
        KernelTranscriptEvent::RecordAluAddr,
        KernelTranscriptEvent::DeriveAdd8LoAddr,
        KernelTranscriptEvent::RecordEq4Addr,
        KernelTranscriptEvent::SampleGammaLookupLink,
        KernelTranscriptEvent::Stage1LinkageBatch,
    ]
}

fn stage2_transcript_events() -> [KernelTranscriptEvent; 19] {
    [
        KernelTranscriptEvent::SampleStage2Cycle,
        KernelTranscriptEvent::SampleGammaReg,
        KernelTranscriptEvent::Stage2RegRwBatched,
        KernelTranscriptEvent::Stage2RegValFromInc,
        KernelTranscriptEvent::SampleGammaRam,
        KernelTranscriptEvent::Stage2RamRwBatched,
        KernelTranscriptEvent::Stage2RamValFromInc,
        KernelTranscriptEvent::Stage2RamRafRead,
        KernelTranscriptEvent::Stage2RamRafWrite,
        KernelTranscriptEvent::Stage2AddrCheckRegRaX,
        KernelTranscriptEvent::Stage2AddrCheckRegRaY,
        KernelTranscriptEvent::Stage2AddrCheckRegRaI,
        KernelTranscriptEvent::Stage2AddrCheckRegWa,
        KernelTranscriptEvent::Stage2AddrCheckRamRa,
        KernelTranscriptEvent::Stage2AddrCheckRamWa,
        KernelTranscriptEvent::RecordRegAddr,
        KernelTranscriptEvent::RecordRamAddr,
        KernelTranscriptEvent::SampleGammaTwistLink,
        KernelTranscriptEvent::Stage2LinkageBatch,
    ]
}

fn stage3_prefix_transcript_events() -> [KernelTranscriptEvent; 7] {
    [
        KernelTranscriptEvent::SampleBeta1,
        KernelTranscriptEvent::SampleBeta2,
        KernelTranscriptEvent::SampleStage3Cycle,
        KernelTranscriptEvent::LaneShiftReduction,
        KernelTranscriptEvent::Stage3Continuity,
        KernelTranscriptEvent::Stage3StartBoundaryOpening,
        KernelTranscriptEvent::Stage3FinalBoundaryOpening,
    ]
}

fn build_kernel_export_surface(frames: &[KernelExactFrame], prepared_steps: &[StepInput]) -> KernelExportSurface {
    KernelExportSurface {
        semantic_rows: frames.len(),
        prepared_steps: prepared_steps.to_vec(),
    }
}

fn build_kernel_audit_surface(
    frames: &[KernelExactFrame],
    row_projection_summary: &KernelRowProjectionSummary,
    bridge_binding_summary: &KernelBridgeBindingSummary,
    prepared_steps: &[StepInput],
) -> Result<KernelAuditSurface, SimpleKernelError> {
    if row_projection_summary.projections.len() != frames.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "kernel audit row projection count {} != frame count {}",
            row_projection_summary.projections.len(),
            frames.len()
        )));
    }
    if bridge_binding_summary.claims.len() != frames.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "kernel audit bridge binding count {} != frame count {}",
            bridge_binding_summary.claims.len(),
            frames.len()
        )));
    }
    for (frame, projection) in frames.iter().zip(row_projection_summary.projections.iter()) {
        if projection.row_index != frame.step_idx {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "kernel audit row projection index {} != frame step {}",
                projection.row_index, frame.step_idx
            )));
        }
    }
    for ((frame, claim), prepared_step) in frames
        .iter()
        .zip(bridge_binding_summary.claims.iter())
        .zip(prepared_steps.iter())
    {
        if claim.row_index != frame.step_idx {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "kernel audit bridge binding index {} != frame step {}",
                claim.row_index, frame.step_idx
            )));
        }
        if claim.prepared_step_digest != prepared_step_digest(prepared_step) {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "kernel audit bridge binding prepared-step digest mismatch at row {}",
                frame.step_idx
            )));
        }
    }
    Ok(KernelAuditSurface {
        row_projection_summary: row_projection_summary.clone(),
        bridge_binding_summary: bridge_binding_summary.clone(),
    })
}

fn build_kernel_manifest_surface(
    kernel_opening_manifest: &KernelOpeningManifest,
    root_opening_manifest: &RootOpeningManifest,
) -> KernelManifestSurface {
    KernelManifestSurface {
        root0_commitment_ids: root0_commitment_ids().to_vec(),
        kernel_manifest: kernel_opening_manifest.clone(),
        root_manifest: root_opening_manifest.clone(),
    }
}

fn root0_commitment_ids() -> [CommitmentId; 12] {
    [
        CommitmentId::Lane,
        CommitmentId::FetchRa,
        CommitmentId::DecodeRa,
        CommitmentId::AluRa,
        CommitmentId::Eq4Ra,
        CommitmentId::DecodeHandoff,
        CommitmentId::RegTwist,
        CommitmentId::RamTwist,
        CommitmentId::RomTable,
        CommitmentId::DecodeTable,
        CommitmentId::AluTable,
        CommitmentId::Eq4Table,
    ]
}

fn assert_prepared_steps_match_output(expected: &[StepInput], actual: &[StepInput]) -> Result<(), SimpleKernelError> {
    if expected.len() != actual.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "kernel export prepared step count {} != expected {}",
            actual.len(),
            expected.len()
        )));
    }
    for (row_index, (expected_step, actual_step)) in expected.iter().zip(actual.iter()).enumerate() {
        if prepared_step_digest(expected_step) != prepared_step_digest(actual_step) {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "kernel export prepared step {row_index} does not match exact frame reconstruction"
            )));
        }
    }
    Ok(())
}

fn append_commitment_ids(tr: &mut Poseidon2Transcript, label: &'static [u8], ids: &[CommitmentId]) {
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_execution_digest/commitment_id_len",
        &[ids.len() as u64],
    );
    for id in ids {
        let (order, root_tag) = opening_commitment_id_key(*id);
        tr.append_u64s(label, &[order, root_tag]);
    }
}

fn append_transcript_event(tr: &mut Poseidon2Transcript, event: &KernelTranscriptEvent) {
    let (tag, row, commitment_id) = match event {
        KernelTranscriptEvent::AbsorbCommitment(id) => (0u64, None, Some(*id)),
        KernelTranscriptEvent::AbsorbMetaPub => (1, None, None),
        KernelTranscriptEvent::SampleStage1Cycle => (2, None, None),
        KernelTranscriptEvent::Stage1FetchSumcheck => (3, None, None),
        KernelTranscriptEvent::Stage1DecodeSumcheck => (4, None, None),
        KernelTranscriptEvent::Stage1AluSumcheck => (5, None, None),
        KernelTranscriptEvent::Stage1Eq4Sumcheck => (6, None, None),
        KernelTranscriptEvent::Stage1AddrCheckFetch => (7, None, None),
        KernelTranscriptEvent::Stage1AddrCheckDecode => (8, None, None),
        KernelTranscriptEvent::Stage1AddrCheckAlu => (9, None, None),
        KernelTranscriptEvent::Stage1AddrCheckEq4 => (10, None, None),
        KernelTranscriptEvent::RecordFetchAddr => (11, None, None),
        KernelTranscriptEvent::RecordDecodeAddr => (12, None, None),
        KernelTranscriptEvent::RecordAluAddr => (13, None, None),
        KernelTranscriptEvent::DeriveAdd8LoAddr => (14, None, None),
        KernelTranscriptEvent::RecordEq4Addr => (15, None, None),
        KernelTranscriptEvent::SampleGammaLookupLink => (16, None, None),
        KernelTranscriptEvent::Stage1LinkageBatch => (17, None, None),
        KernelTranscriptEvent::SampleStage2Cycle => (18, None, None),
        KernelTranscriptEvent::SampleGammaReg => (19, None, None),
        KernelTranscriptEvent::Stage2RegRwBatched => (20, None, None),
        KernelTranscriptEvent::Stage2RegValFromInc => (21, None, None),
        KernelTranscriptEvent::SampleGammaRam => (22, None, None),
        KernelTranscriptEvent::Stage2RamRwBatched => (23, None, None),
        KernelTranscriptEvent::Stage2RamValFromInc => (24, None, None),
        KernelTranscriptEvent::Stage2RamRafRead => (25, None, None),
        KernelTranscriptEvent::Stage2RamRafWrite => (26, None, None),
        KernelTranscriptEvent::Stage2AddrCheckRegRaX => (27, None, None),
        KernelTranscriptEvent::Stage2AddrCheckRegRaY => (28, None, None),
        KernelTranscriptEvent::Stage2AddrCheckRegRaI => (29, None, None),
        KernelTranscriptEvent::Stage2AddrCheckRegWa => (30, None, None),
        KernelTranscriptEvent::Stage2AddrCheckRamRa => (31, None, None),
        KernelTranscriptEvent::Stage2AddrCheckRamWa => (32, None, None),
        KernelTranscriptEvent::RecordRegAddr => (33, None, None),
        KernelTranscriptEvent::RecordRamAddr => (34, None, None),
        KernelTranscriptEvent::SampleGammaTwistLink => (35, None, None),
        KernelTranscriptEvent::Stage2LinkageBatch => (36, None, None),
        KernelTranscriptEvent::SampleBeta1 => (37, None, None),
        KernelTranscriptEvent::SampleBeta2 => (38, None, None),
        KernelTranscriptEvent::SampleStage3Cycle => (39, None, None),
        KernelTranscriptEvent::LaneShiftReduction => (40, None, None),
        KernelTranscriptEvent::Stage3Continuity => (41, None, None),
        KernelTranscriptEvent::Stage3StartBoundaryOpening => (42, None, None),
        KernelTranscriptEvent::Stage3FinalBoundaryOpening => (43, None, None),
        KernelTranscriptEvent::RowBinding(j) => (44, Some(*j as u64), None),
        KernelTranscriptEvent::EmitKernelOpeningClaims => (45, None, None),
    };
    tr.append_u64s(b"neo.fold.next/chip8/kernel_transcript_surface/event_tag", &[tag]);
    if let Some(id) = commitment_id {
        let (order, root_tag) = opening_commitment_id_key(id);
        tr.append_u64s(
            b"neo.fold.next/chip8/kernel_transcript_surface/event_commitment_id",
            &[order, root_tag],
        );
    }
    if let Some(j) = row {
        tr.append_u64s(b"neo.fold.next/chip8/kernel_transcript_surface/event_row", &[j]);
    }
}

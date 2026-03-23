//! Owns the CHIP-8 kernel transcript event schedule and transcript-facing artifact emission.
//! It does not own the transcript root binding itself; `public_meta.rs` still owns `root0`.

use neo_math::{KExtensions, K};
use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::chip8::spec::CommitmentId;
use crate::opening::TimeOpeningProofSummary;

use super::joint_opening::{KernelJointOpeningFoldBucketProof, KernelJointOpeningSummary};
use super::openings::{collect_exact_claim_witnesses, KernelExactOpeningArtifacts, KernelOpeningRefinementSummary};
use super::openings::{opening_commitment_id_key, KernelOpeningManifest, RootOpeningManifest};
use super::{SimpleKernelError, SimpleKernelProof};

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

pub(crate) fn root0_commitment_ids() -> [CommitmentId; 12] {
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

pub(crate) fn emit_kernel_opening_artifacts_to_transcript(
    transcript: &mut Poseidon2Transcript,
    manifest: &KernelOpeningManifest,
    root_manifest: &RootOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    time_opening_summary: &TimeOpeningProofSummary,
    joint_opening_summary: &KernelJointOpeningSummary,
    joint_opening_fold_bucket_proofs: &[KernelJointOpeningFoldBucketProof],
    artifacts: KernelExactOpeningArtifacts<'_>,
) -> Result<(), SimpleKernelError> {
    transcript.append_message(
        b"neo.fold.next/chip8/opening_transcript/kernel_manifest",
        &manifest.digest,
    );
    transcript.append_message(
        b"neo.fold.next/chip8/opening_transcript/root_manifest",
        &root_manifest.digest,
    );

    let exact_claims = collect_exact_claim_witnesses(manifest, artifacts)?;
    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/exact_opening_count",
        &[exact_claims.len() as u64],
    );
    for witness in exact_claims {
        transcript.append_message(
            b"neo.fold.next/chip8/opening_transcript/exact_opening_claim",
            &witness.claim.digest,
        );
        transcript.append_message(
            b"neo.fold.next/chip8/opening_transcript/exact_opening_witness",
            &witness.proof.expected_digest(),
        );
    }

    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/refinement_count",
        &[refinement_summary.refinements.len() as u64],
    );
    for refinement in &refinement_summary.refinements {
        transcript.append_message(b"neo.fold.next/chip8/opening_transcript/refinement", &refinement.digest);
    }

    transcript.append_message(
        b"neo.fold.next/chip8/opening_transcript/time_opening_manifest",
        &time_opening_summary.manifest_digest,
    );
    transcript.append_message(
        b"neo.fold.next/chip8/opening_transcript/time_opening_proof",
        &time_opening_summary.proof_digest,
    );
    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/time_opening_group_count",
        &[time_opening_summary.groups.len() as u64],
    );
    for group in &time_opening_summary.groups {
        transcript.append_message(
            b"neo.fold.next/chip8/opening_transcript/time_opening_group_digest",
            &group.group_digest,
        );
        transcript.append_message(
            b"neo.fold.next/chip8/opening_transcript/time_opening_group_reduced_digest",
            &group.reduced_digest,
        );
    }
    append_time_opening_unification(transcript, time_opening_summary);

    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/joint_claim_count",
        &[joint_opening_summary.claims.len() as u64],
    );
    for claim in &joint_opening_summary.claims {
        transcript.append_message(b"neo.fold.next/chip8/opening_transcript/joint_claim", &claim.digest);
    }
    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/joint_group_count",
        &[joint_opening_summary.groups.len() as u64],
    );
    for group in &joint_opening_summary.groups {
        transcript.append_message(b"neo.fold.next/chip8/opening_transcript/joint_group", &group.digest);
    }
    append_joint_opening_unification(transcript, joint_opening_summary);
    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/fold_bucket_count",
        &[joint_opening_fold_bucket_proofs.len() as u64],
    );
    for proof in joint_opening_fold_bucket_proofs {
        transcript.append_message(b"neo.fold.next/chip8/opening_transcript/fold_bucket", &proof.digest);
    }
    Ok(())
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

fn append_time_opening_unification(transcript: &mut Poseidon2Transcript, summary: &TimeOpeningProofSummary) {
    transcript.append_fields(
        b"neo.fold.next/chip8/opening_transcript/time_opening_unify_claimed_sum",
        &summary.unification.claimed_sum.as_coeffs(),
    );
    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/time_opening_unify_meta",
        &[
            summary.unification.round_polys.len() as u64,
            summary.unification.r_unify.len() as u64,
            summary.can_unify as u64,
            summary.unified_point.len() as u64,
        ],
    );
    for round in &summary.unification.round_polys {
        append_k_vec(
            transcript,
            b"neo.fold.next/chip8/opening_transcript/time_opening_unify_round",
            round,
        );
    }
    append_k_vec(
        transcript,
        b"neo.fold.next/chip8/opening_transcript/time_opening_unify_point",
        &summary.unification.r_unify,
    );
    append_k_vec(
        transcript,
        b"neo.fold.next/chip8/opening_transcript/time_opening_unified_point",
        &summary.unified_point,
    );
    transcript.append_message(
        b"neo.fold.next/chip8/opening_transcript/time_opening_unified_digest",
        &summary.unified_digest,
    );
}

fn append_joint_opening_unification(transcript: &mut Poseidon2Transcript, summary: &KernelJointOpeningSummary) {
    transcript.append_fields(
        b"neo.fold.next/chip8/opening_transcript/joint_opening_unify_claimed_sum",
        &summary.unification.claimed_sum.as_coeffs(),
    );
    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/joint_opening_unify_meta",
        &[
            summary.unification.round_polys.len() as u64,
            summary.unification.r_unify.len() as u64,
            summary.unified_fold.is_some() as u64,
        ],
    );
    for round in &summary.unification.round_polys {
        append_k_vec(
            transcript,
            b"neo.fold.next/chip8/opening_transcript/joint_opening_unify_round",
            round,
        );
    }
    append_k_vec(
        transcript,
        b"neo.fold.next/chip8/opening_transcript/joint_opening_unify_point",
        &summary.unification.r_unify,
    );
    if let Some(unified_fold) = &summary.unified_fold {
        transcript.append_message(
            b"neo.fold.next/chip8/opening_transcript/joint_opening_unified_fold",
            &unified_fold.digest,
        );
    }
}

fn append_k_vec(transcript: &mut Poseidon2Transcript, label: &'static [u8], values: &[K]) {
    transcript.append_u64s(b"neo.fold.next/chip8/opening_transcript/k_len", &[values.len() as u64]);
    for value in values {
        transcript.append_fields(label, &value.as_coeffs());
    }
}

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

#[derive(Clone, Debug, PartialEq)]
pub struct KernelExactOpeningTranscriptEntry {
    pub claim_digest: [u8; 32],
    pub witness_digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelTimeOpeningTranscriptGroup {
    pub group_digest: [u8; 32],
    pub reduced_digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelTimeOpeningTranscriptUnification {
    pub claimed_sum: K,
    pub round_polys: Vec<Vec<K>>,
    pub r_unify: Vec<K>,
    pub can_unify: bool,
    pub unified_point: Vec<K>,
    pub unified_digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelJointOpeningTranscriptUnification {
    pub claimed_sum: K,
    pub round_polys: Vec<Vec<K>>,
    pub r_unify: Vec<K>,
    pub unified_fold_digest: Option<[u8; 32]>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelOpeningTranscriptSource {
    pub exact_openings: Vec<KernelExactOpeningTranscriptEntry>,
    pub refinement_digests: Vec<[u8; 32]>,
    pub time_opening_manifest_digest: [u8; 32],
    pub time_opening_proof_digest: [u8; 32],
    pub time_opening_groups: Vec<KernelTimeOpeningTranscriptGroup>,
    pub time_opening_unification: KernelTimeOpeningTranscriptUnification,
    pub joint_claim_digests: Vec<[u8; 32]>,
    pub joint_group_digests: Vec<[u8; 32]>,
    pub joint_opening_unification: KernelJointOpeningTranscriptUnification,
    pub fold_bucket_digests: Vec<[u8; 32]>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelOpeningTranscriptSurface {
    pub kernel_manifest_digest: [u8; 32],
    pub root_manifest_digest: [u8; 32],
    pub source: KernelOpeningTranscriptSource,
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

impl KernelOpeningTranscriptSurface {
    pub fn digest32(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_opening_transcript_surface");
        append_kernel_opening_transcript_surface(&mut tr, self);
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
    let surface = build_kernel_opening_transcript_surface(
        manifest,
        root_manifest,
        refinement_summary,
        time_opening_summary,
        joint_opening_summary,
        joint_opening_fold_bucket_proofs,
        artifacts,
    )?;
    append_kernel_opening_transcript_surface(transcript, &surface);
    Ok(())
}

pub(crate) fn build_kernel_opening_transcript_source(
    manifest: &KernelOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    time_opening_summary: &TimeOpeningProofSummary,
    joint_opening_summary: &KernelJointOpeningSummary,
    joint_opening_fold_bucket_proofs: &[KernelJointOpeningFoldBucketProof],
    artifacts: KernelExactOpeningArtifacts<'_>,
) -> Result<KernelOpeningTranscriptSource, SimpleKernelError> {
    let exact_openings = collect_exact_claim_witnesses(manifest, artifacts)?
        .into_iter()
        .map(|witness| KernelExactOpeningTranscriptEntry {
            claim_digest: witness.claim.digest,
            witness_digest: witness.proof.expected_digest(),
        })
        .collect();
    Ok(KernelOpeningTranscriptSource {
        exact_openings,
        refinement_digests: refinement_summary
            .refinements
            .iter()
            .map(|refinement| refinement.digest)
            .collect(),
        time_opening_manifest_digest: time_opening_summary.manifest_digest,
        time_opening_proof_digest: time_opening_summary.proof_digest,
        time_opening_groups: time_opening_summary
            .groups
            .iter()
            .map(|group| KernelTimeOpeningTranscriptGroup {
                group_digest: group.group_digest,
                reduced_digest: group.reduced_digest,
            })
            .collect(),
        time_opening_unification: KernelTimeOpeningTranscriptUnification {
            claimed_sum: time_opening_summary.unification.claimed_sum,
            round_polys: time_opening_summary.unification.round_polys.clone(),
            r_unify: time_opening_summary.unification.r_unify.clone(),
            can_unify: time_opening_summary.can_unify,
            unified_point: time_opening_summary.unified_point.clone(),
            unified_digest: time_opening_summary.unified_digest,
        },
        joint_claim_digests: joint_opening_summary
            .claims
            .iter()
            .map(|claim| claim.digest)
            .collect(),
        joint_group_digests: joint_opening_summary
            .groups
            .iter()
            .map(|group| group.digest)
            .collect(),
        joint_opening_unification: KernelJointOpeningTranscriptUnification {
            claimed_sum: joint_opening_summary.unification.claimed_sum,
            round_polys: joint_opening_summary.unification.round_polys.clone(),
            r_unify: joint_opening_summary.unification.r_unify.clone(),
            unified_fold_digest: joint_opening_summary
                .unified_fold
                .as_ref()
                .map(|group| group.digest),
        },
        fold_bucket_digests: joint_opening_fold_bucket_proofs
            .iter()
            .map(|proof| proof.digest)
            .collect(),
    })
}

pub(crate) fn build_kernel_opening_transcript_surface(
    manifest: &KernelOpeningManifest,
    root_manifest: &RootOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    time_opening_summary: &TimeOpeningProofSummary,
    joint_opening_summary: &KernelJointOpeningSummary,
    joint_opening_fold_bucket_proofs: &[KernelJointOpeningFoldBucketProof],
    artifacts: KernelExactOpeningArtifacts<'_>,
) -> Result<KernelOpeningTranscriptSurface, SimpleKernelError> {
    Ok(KernelOpeningTranscriptSurface {
        kernel_manifest_digest: manifest.digest,
        root_manifest_digest: root_manifest.digest,
        source: build_kernel_opening_transcript_source(
            manifest,
            refinement_summary,
            time_opening_summary,
            joint_opening_summary,
            joint_opening_fold_bucket_proofs,
            artifacts,
        )?,
    })
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

fn append_kernel_opening_transcript_surface(
    transcript: &mut Poseidon2Transcript,
    surface: &KernelOpeningTranscriptSurface,
) {
    transcript.append_message(
        b"neo.fold.next/chip8/opening_transcript/kernel_manifest",
        &surface.kernel_manifest_digest,
    );
    transcript.append_message(
        b"neo.fold.next/chip8/opening_transcript/root_manifest",
        &surface.root_manifest_digest,
    );
    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/exact_opening_count",
        &[surface.source.exact_openings.len() as u64],
    );
    for witness in &surface.source.exact_openings {
        transcript.append_message(
            b"neo.fold.next/chip8/opening_transcript/exact_opening_claim",
            &witness.claim_digest,
        );
        transcript.append_message(
            b"neo.fold.next/chip8/opening_transcript/exact_opening_witness",
            &witness.witness_digest,
        );
    }
    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/refinement_count",
        &[surface.source.refinement_digests.len() as u64],
    );
    for digest in &surface.source.refinement_digests {
        transcript.append_message(b"neo.fold.next/chip8/opening_transcript/refinement", digest);
    }
    transcript.append_message(
        b"neo.fold.next/chip8/opening_transcript/time_opening_manifest",
        &surface.source.time_opening_manifest_digest,
    );
    transcript.append_message(
        b"neo.fold.next/chip8/opening_transcript/time_opening_proof",
        &surface.source.time_opening_proof_digest,
    );
    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/time_opening_group_count",
        &[surface.source.time_opening_groups.len() as u64],
    );
    for group in &surface.source.time_opening_groups {
        transcript.append_message(
            b"neo.fold.next/chip8/opening_transcript/time_opening_group_digest",
            &group.group_digest,
        );
        transcript.append_message(
            b"neo.fold.next/chip8/opening_transcript/time_opening_group_reduced_digest",
            &group.reduced_digest,
        );
    }
    append_time_opening_unification(transcript, &surface.source.time_opening_unification);
    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/joint_claim_count",
        &[surface.source.joint_claim_digests.len() as u64],
    );
    for digest in &surface.source.joint_claim_digests {
        transcript.append_message(b"neo.fold.next/chip8/opening_transcript/joint_claim", digest);
    }
    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/joint_group_count",
        &[surface.source.joint_group_digests.len() as u64],
    );
    for digest in &surface.source.joint_group_digests {
        transcript.append_message(b"neo.fold.next/chip8/opening_transcript/joint_group", digest);
    }
    append_joint_opening_unification(transcript, &surface.source.joint_opening_unification);
    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/fold_bucket_count",
        &[surface.source.fold_bucket_digests.len() as u64],
    );
    for digest in &surface.source.fold_bucket_digests {
        transcript.append_message(b"neo.fold.next/chip8/opening_transcript/fold_bucket", digest);
    }
}

fn append_time_opening_unification(
    transcript: &mut Poseidon2Transcript,
    summary: &KernelTimeOpeningTranscriptUnification,
) {
    transcript.append_fields(
        b"neo.fold.next/chip8/opening_transcript/time_opening_unify_claimed_sum",
        &summary.claimed_sum.as_coeffs(),
    );
    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/time_opening_unify_meta",
        &[
            summary.round_polys.len() as u64,
            summary.r_unify.len() as u64,
            summary.can_unify as u64,
            summary.unified_point.len() as u64,
        ],
    );
    for round in &summary.round_polys {
        append_k_vec(
            transcript,
            b"neo.fold.next/chip8/opening_transcript/time_opening_unify_round",
            round,
        );
    }
    append_k_vec(
        transcript,
        b"neo.fold.next/chip8/opening_transcript/time_opening_unify_point",
        &summary.r_unify,
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

fn append_joint_opening_unification(
    transcript: &mut Poseidon2Transcript,
    summary: &KernelJointOpeningTranscriptUnification,
) {
    transcript.append_fields(
        b"neo.fold.next/chip8/opening_transcript/joint_opening_unify_claimed_sum",
        &summary.claimed_sum.as_coeffs(),
    );
    transcript.append_u64s(
        b"neo.fold.next/chip8/opening_transcript/joint_opening_unify_meta",
        &[
            summary.round_polys.len() as u64,
            summary.r_unify.len() as u64,
            summary.unified_fold_digest.is_some() as u64,
        ],
    );
    for round in &summary.round_polys {
        append_k_vec(
            transcript,
            b"neo.fold.next/chip8/opening_transcript/joint_opening_unify_round",
            round,
        );
    }
    append_k_vec(
        transcript,
        b"neo.fold.next/chip8/opening_transcript/joint_opening_unify_point",
        &summary.r_unify,
    );
    if let Some(unified_fold_digest) = &summary.unified_fold_digest {
        transcript.append_message(
            b"neo.fold.next/chip8/opening_transcript/joint_opening_unified_fold",
            unified_fold_digest,
        );
    }
}

fn append_k_vec(transcript: &mut Poseidon2Transcript, label: &'static [u8], values: &[K]) {
    transcript.append_u64s(b"neo.fold.next/chip8/opening_transcript/k_len", &[values.len() as u64]);
    for value in values {
        transcript.append_fields(label, &value.as_coeffs());
    }
}

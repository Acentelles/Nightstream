//! Owns Stage-6 transcript binding for accepted kernel opening artifacts.

use neo_math::{KExtensions, K};
use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::proof::TimeOpeningProofSummary;

use super::joint_opening::KernelJointOpeningSummary;
use super::joint_opening_bucket_fold::KernelJointOpeningFoldBucketProof;
use super::opening_refinement::{
    collect_exact_claim_witnesses, KernelExactOpeningArtifacts, KernelOpeningRefinementSummary,
};
use super::{KernelOpeningManifest, RootOpeningManifest, SimpleKernelError};

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

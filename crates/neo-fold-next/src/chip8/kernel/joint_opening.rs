//! Owns the kernel-side joint-opening summary built from exact opening artifacts.

use neo_ajtai::{s_mul, Commitment};
use neo_ccs::Mat;
use neo_math::ring::{cf_inv, Rq as RqEl};
use neo_math::{KExtensions, D, F, K};
use neo_params::NeoParams;
use neo_reductions::api::{sample_rot_rhos_n, RotRing};
use neo_reductions::sumcheck::verify_sumcheck_rounds;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use crate::proof::{OpeningDomain, TimeOpeningGroupSummary, TimeOpeningProofSummary};
use crate::time_opening::canonical_claim_cmp;

use super::lane_commitment::encoded_time_width;
use super::openings::{
    collect_exact_claim_witnesses, KernelExactClaimWitness, KernelExactOpeningArtifacts, KernelOpeningRefinement,
    KernelOpeningRefinementSummary,
};
use super::{as_time_opening_claim, opening_commitment_id_key};
use super::{CommitmentId, KernelOpeningManifest, SimpleKernelError};

#[derive(Clone, Debug, PartialEq)]
pub struct KernelJointOpeningClaimSummary {
    pub commitment_id: CommitmentId,
    pub point: Vec<K>,
    pub polynomial_ids: Vec<usize>,
    pub refinement_digest: [u8; 32],
    pub joint_commitment: Commitment,
    pub joint_claim_digits: Vec<K>,
    pub joint_claim: K,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelJointOpeningGroupSummary {
    pub commitment_id: CommitmentId,
    pub domain: OpeningDomain,
    pub point: Vec<K>,
    pub claim_indices: Vec<usize>,
    pub reduction_group_digest: [u8; 32],
    pub joint_commitment: Commitment,
    pub joint_claim_digits: Vec<K>,
    pub joint_claim: K,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct KernelJointOpeningUnificationProof {
    pub claimed_sum: K,
    pub round_polys: Vec<Vec<K>>,
    pub r_unify: Vec<K>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelJointOpeningSummary {
    pub claims: Vec<KernelJointOpeningClaimSummary>,
    pub groups: Vec<KernelJointOpeningGroupSummary>,
    pub unification: KernelJointOpeningUnificationProof,
    pub unified_fold: Option<KernelJointOpeningGroupSummary>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelJointOpeningFoldShape {
    pub logical_t: usize,
    pub encoded_time_width: usize,
    pub selector_bits: usize,
    pub selector_domain_size: usize,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelJointOpeningFoldBucketProof {
    pub commitment_id: CommitmentId,
    pub shape: KernelJointOpeningFoldShape,
    pub group_digests: Vec<[u8; 32]>,
    pub r_fold: Vec<F>,
    pub folded_commitment: Commitment,
    pub folded_claim_digits: Vec<K>,
    pub folded_claim: K,
    pub digest: [u8; 32],
}

impl KernelJointOpeningClaimSummary {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/joint_opening/claim_digest");
        let (commitment_order, root_tag) = opening_commitment_id_key(self.commitment_id);
        tr.append_u64s(
            b"neo.fold.next/chip8/joint_opening/claim_meta",
            &[
                commitment_order,
                root_tag,
                self.point.len() as u64,
                self.polynomial_ids.len() as u64,
                self.joint_claim_digits.len() as u64,
            ],
        );
        append_point(&mut tr, b"neo.fold.next/chip8/joint_opening/claim_point", &self.point);
        let polynomial_ids_u64: Vec<u64> = self.polynomial_ids.iter().map(|&id| id as u64).collect();
        tr.append_u64s(
            b"neo.fold.next/chip8/joint_opening/claim_polynomial_ids",
            &polynomial_ids_u64,
        );
        tr.append_message(
            b"neo.fold.next/chip8/joint_opening/claim_refinement_digest",
            &self.refinement_digest,
        );
        append_commitment(
            &mut tr,
            b"neo.fold.next/chip8/joint_opening/claim_commitment",
            &self.joint_commitment,
        );
        append_k_vec(
            &mut tr,
            b"neo.fold.next/chip8/joint_opening/claim_digits",
            &self.joint_claim_digits,
        );
        tr.append_fields(
            b"neo.fold.next/chip8/joint_opening/claim_scalar",
            &self.joint_claim.as_coeffs(),
        );
        tr.digest32()
    }
}

impl KernelJointOpeningGroupSummary {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/joint_opening/group_digest");
        let (commitment_order, root_tag) = opening_commitment_id_key(self.commitment_id);
        tr.append_u64s(
            b"neo.fold.next/chip8/joint_opening/group_meta",
            &[
                commitment_order,
                root_tag,
                opening_domain_tag(self.domain),
                self.point.len() as u64,
                self.claim_indices.len() as u64,
                self.joint_claim_digits.len() as u64,
            ],
        );
        append_point(&mut tr, b"neo.fold.next/chip8/joint_opening/group_point", &self.point);
        let claim_indices_u64: Vec<u64> = self.claim_indices.iter().map(|&idx| idx as u64).collect();
        tr.append_u64s(
            b"neo.fold.next/chip8/joint_opening/group_claim_indices",
            &claim_indices_u64,
        );
        tr.append_message(
            b"neo.fold.next/chip8/joint_opening/group_reduction_digest",
            &self.reduction_group_digest,
        );
        append_commitment(
            &mut tr,
            b"neo.fold.next/chip8/joint_opening/group_commitment",
            &self.joint_commitment,
        );
        append_k_vec(
            &mut tr,
            b"neo.fold.next/chip8/joint_opening/group_joint_digits",
            &self.joint_claim_digits,
        );
        tr.append_fields(
            b"neo.fold.next/chip8/joint_opening/group_joint_claim",
            &self.joint_claim.as_coeffs(),
        );
        tr.digest32()
    }
}

impl KernelJointOpeningSummary {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/joint_opening/summary_digest");
        tr.append_u64s(
            b"neo.fold.next/chip8/joint_opening/summary_claim_count",
            &[self.claims.len() as u64],
        );
        for claim in &self.claims {
            tr.append_message(b"neo.fold.next/chip8/joint_opening/summary_claim_digest", &claim.digest);
        }
        tr.append_u64s(
            b"neo.fold.next/chip8/joint_opening/summary_group_count",
            &[self.groups.len() as u64],
        );
        for group in &self.groups {
            tr.append_message(b"neo.fold.next/chip8/joint_opening/summary_group_digest", &group.digest);
        }
        tr.append_fields(
            b"neo.fold.next/chip8/joint_opening/summary_unify_claimed_sum",
            &self.unification.claimed_sum.as_coeffs(),
        );
        tr.append_u64s(
            b"neo.fold.next/chip8/joint_opening/summary_unify_meta",
            &[
                self.unification.round_polys.len() as u64,
                self.unification.r_unify.len() as u64,
            ],
        );
        for round in &self.unification.round_polys {
            append_k_vec(&mut tr, b"neo.fold.next/chip8/joint_opening/summary_unify_round", round);
        }
        append_k_vec(
            &mut tr,
            b"neo.fold.next/chip8/joint_opening/summary_unify_point",
            &self.unification.r_unify,
        );
        match &self.unified_fold {
            Some(group) => {
                tr.append_message(b"neo.fold.next/chip8/joint_opening/summary_has_unified", &[1]);
                tr.append_message(
                    b"neo.fold.next/chip8/joint_opening/summary_unified_digest",
                    &group.digest,
                );
            }
            None => tr.append_message(b"neo.fold.next/chip8/joint_opening/summary_has_unified", &[0]),
        }
        tr.digest32()
    }
}

impl KernelJointOpeningFoldBucketProof {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/joint_opening/fold_bucket_digest");
        let (commitment_order, root_tag) = opening_commitment_id_key(self.commitment_id);
        tr.append_u64s(
            b"neo.fold.next/chip8/joint_opening/fold_bucket_meta",
            &[
                commitment_order,
                root_tag,
                self.group_digests.len() as u64,
                self.r_fold.len() as u64,
                self.folded_claim_digits.len() as u64,
            ],
        );
        append_fold_shape(
            &mut tr,
            b"neo.fold.next/chip8/joint_opening/fold_bucket_shape",
            &self.shape,
        );
        for digest in &self.group_digests {
            tr.append_message(b"neo.fold.next/chip8/joint_opening/fold_bucket_group_digest", digest);
        }
        append_f_vec(
            &mut tr,
            b"neo.fold.next/chip8/joint_opening/fold_bucket_point",
            &self.r_fold,
        );
        append_commitment(
            &mut tr,
            b"neo.fold.next/chip8/joint_opening/fold_bucket_commitment",
            &self.folded_commitment,
        );
        append_k_vec(
            &mut tr,
            b"neo.fold.next/chip8/joint_opening/fold_bucket_digits",
            &self.folded_claim_digits,
        );
        tr.append_fields(
            b"neo.fold.next/chip8/joint_opening/fold_bucket_scalar",
            &self.folded_claim.as_coeffs(),
        );
        tr.digest32()
    }
}

pub fn build_kernel_joint_opening_summary(
    params: &NeoParams,
    manifest: &KernelOpeningManifest,
    opening_refinement_summary: &KernelOpeningRefinementSummary,
    time_opening_summary: &TimeOpeningProofSummary,
    artifacts: KernelExactOpeningArtifacts<'_>,
) -> Result<KernelJointOpeningSummary, SimpleKernelError> {
    let exact_claims = collect_exact_claim_witnesses(manifest, artifacts)?;
    let claims = build_claim_summaries(params, &exact_claims, opening_refinement_summary)?;
    let canonical_claims = canonical_time_claims(manifest);
    let groups = time_opening_summary
        .groups
        .iter()
        .map(|group| build_group_summary(params, &canonical_claims, &claims, &exact_claims, group))
        .collect::<Result<Vec<_>, _>>()?;
    let unification = prove_joint_opening_unification(&groups)?;
    let unified_fold = build_unified_fold_summary(params, time_opening_summary, &groups, &unification)?;
    let summary = KernelJointOpeningSummary {
        claims,
        groups,
        unification,
        unified_fold,
        digest: [0; 32],
    };
    Ok(KernelJointOpeningSummary {
        digest: summary.expected_digest(),
        ..summary
    })
}

pub fn verify_kernel_joint_opening_summary(
    params: &NeoParams,
    manifest: &KernelOpeningManifest,
    opening_refinement_summary: &KernelOpeningRefinementSummary,
    time_opening_summary: &TimeOpeningProofSummary,
    artifacts: KernelExactOpeningArtifacts<'_>,
    summary: &KernelJointOpeningSummary,
) -> Result<(), SimpleKernelError> {
    let exact_claims = collect_exact_claim_witnesses(manifest, artifacts)?;
    let expected_claims = build_claim_summaries(params, &exact_claims, opening_refinement_summary)?;
    verify_claim_summaries(&expected_claims, &summary.claims)?;
    verify_group_summaries(
        params,
        manifest,
        time_opening_summary,
        &expected_claims,
        &exact_claims,
        &summary.groups,
    )?;
    verify_joint_opening_unification(&summary.groups, &summary.unification)?;
    verify_unified_fold_summary(
        params,
        time_opening_summary,
        &summary.groups,
        &summary.unification,
        &summary.unified_fold,
    )?;
    if summary.digest != summary.expected_digest() {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint-opening summary digest mismatch".into(),
        ));
    }
    if summary.claims.is_empty() != manifest.claims.is_empty() {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint-opening summary claim coverage mismatch".into(),
        ));
    }
    Ok(())
}

pub fn build_kernel_joint_opening_fold_bucket_proofs(
    logical_t: usize,
    summary: &KernelJointOpeningSummary,
) -> Result<Vec<KernelJointOpeningFoldBucketProof>, SimpleKernelError> {
    let mut buckets: Vec<(CommitmentId, Vec<&KernelJointOpeningGroupSummary>)> = Vec::new();
    for group in &summary.groups {
        match buckets
            .iter_mut()
            .find(|(commitment_id, _)| *commitment_id == group.commitment_id)
        {
            Some((_, groups)) => groups.push(group),
            None => buckets.push((group.commitment_id, vec![group])),
        }
    }
    buckets.sort_by_key(|(commitment_id, _)| opening_commitment_id_key(*commitment_id));

    buckets
        .into_iter()
        .map(|(commitment_id, groups)| build_fold_bucket_proof(logical_t, commitment_id, &groups))
        .collect()
}

pub fn verify_kernel_joint_opening_fold_bucket_proofs(
    logical_t: usize,
    summary: &KernelJointOpeningSummary,
    proofs: &[KernelJointOpeningFoldBucketProof],
) -> Result<(), SimpleKernelError> {
    let expected = build_kernel_joint_opening_fold_bucket_proofs(logical_t, summary)?;
    if proofs != expected {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint-opening fold bucket proofs mismatch".into(),
        ));
    }
    for (idx, proof) in proofs.iter().enumerate() {
        if proof.digest != proof.expected_digest() {
            return Err(SimpleKernelError::OpeningFailed(format!(
                "kernel joint-opening fold bucket digest mismatch at index {idx}"
            )));
        }
    }
    Ok(())
}

fn build_claim_summaries(
    params: &NeoParams,
    exact_claims: &[KernelExactClaimWitness],
    refinement_summary: &KernelOpeningRefinementSummary,
) -> Result<Vec<KernelJointOpeningClaimSummary>, SimpleKernelError> {
    if exact_claims.len() != refinement_summary.refinements.len() {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "kernel joint-opening refinement count {} != expected {}",
            refinement_summary.refinements.len(),
            exact_claims.len()
        )));
    }
    exact_claims
        .iter()
        .zip(refinement_summary.refinements.iter())
        .enumerate()
        .map(|(idx, (exact, refinement))| build_claim_summary(params, exact, refinement, idx))
        .collect()
}

fn build_fold_bucket_proof(
    logical_t: usize,
    commitment_id: CommitmentId,
    groups: &[&KernelJointOpeningGroupSummary],
) -> Result<KernelJointOpeningFoldBucketProof, SimpleKernelError> {
    if groups.is_empty() {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint-opening fold bucket cannot be empty".into(),
        ));
    }
    if groups
        .iter()
        .any(|group| group.commitment_id != commitment_id)
    {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint-opening fold bucket mixes commitment families".into(),
        ));
    }

    let r_fold = sample_fold_bucket_point(commitment_id, groups);
    let shape = build_joint_opening_fold_shape_for_commitment(logical_t, commitment_id, r_fold.len())?;
    let group_digests: Vec<[u8; 32]> = groups.iter().map(|group| group.digest).collect();
    let folded_commitment = fold_bucket_commitment(groups, &r_fold)?;
    let (folded_claim_digits, folded_claim) = fold_bucket_claim_values(groups, &r_fold)?;

    let proof = KernelJointOpeningFoldBucketProof {
        commitment_id,
        shape,
        group_digests,
        r_fold,
        folded_commitment,
        folded_claim_digits,
        folded_claim,
        digest: [0; 32],
    };
    Ok(KernelJointOpeningFoldBucketProof {
        digest: proof.expected_digest(),
        ..proof
    })
}

fn build_claim_summary(
    params: &NeoParams,
    exact: &KernelExactClaimWitness,
    refinement: &KernelOpeningRefinement,
    idx: usize,
) -> Result<KernelJointOpeningClaimSummary, SimpleKernelError> {
    if refinement != &exact.refinement {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "kernel joint-opening refinement mismatch at index {idx}"
        )));
    }
    let etas = sample_claim_mixers(params, refinement)?;
    let mut joint_commitment = None;
    let mut joint_digits = vec![K::ZERO; D];
    for ((eta, commitment), digits) in etas
        .iter()
        .zip(exact.claim_commitments.iter())
        .zip(exact.proof.digit_evals.iter())
    {
        add_rot_scaled_commitment(&mut joint_commitment, commitment, eta)?;
        let rotated_digits = apply_rot_to_digits(eta, digits)?;
        for (slot, rotated) in joint_digits.iter_mut().zip(rotated_digits) {
            *slot += rotated;
        }
    }
    let joint_commitment = joint_commitment.ok_or_else(|| {
        SimpleKernelError::OpeningFailed(format!(
            "kernel joint-opening claim {} produced no joint commitment",
            idx
        ))
    })?;
    let summary = KernelJointOpeningClaimSummary {
        commitment_id: exact.claim.commitment_id,
        point: exact.claim.point.clone(),
        polynomial_ids: exact.claim.polynomial_ids.clone(),
        refinement_digest: refinement.digest,
        joint_commitment,
        joint_claim_digits: joint_digits.clone(),
        joint_claim: recompose_digits_to_scalar(&joint_digits),
        digest: [0; 32],
    };
    Ok(KernelJointOpeningClaimSummary {
        digest: summary.expected_digest(),
        ..summary
    })
}

fn verify_claim_summaries(
    expected_claims: &[KernelJointOpeningClaimSummary],
    summaries: &[KernelJointOpeningClaimSummary],
) -> Result<(), SimpleKernelError> {
    if summaries.len() != expected_claims.len() {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "kernel joint-opening claim count {} != expected {}",
            summaries.len(),
            expected_claims.len()
        )));
    }
    for (idx, (expected, summary)) in expected_claims.iter().zip(summaries.iter()).enumerate() {
        if summary != expected {
            return Err(SimpleKernelError::OpeningFailed(format!(
                "kernel joint-opening claim summary mismatch at index {idx}"
            )));
        }
        if summary.digest != summary.expected_digest() {
            return Err(SimpleKernelError::OpeningFailed(format!(
                "kernel joint-opening claim summary digest mismatch at index {idx}"
            )));
        }
    }
    Ok(())
}

fn verify_group_summaries(
    params: &NeoParams,
    manifest: &KernelOpeningManifest,
    time_opening_summary: &TimeOpeningProofSummary,
    claim_summaries: &[KernelJointOpeningClaimSummary],
    exact_claims: &[KernelExactClaimWitness],
    summaries: &[KernelJointOpeningGroupSummary],
) -> Result<(), SimpleKernelError> {
    if summaries.len() != time_opening_summary.groups.len() {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "kernel joint-opening group count {} != expected {}",
            summaries.len(),
            time_opening_summary.groups.len()
        )));
    }
    let canonical_claims = canonical_time_claims(manifest);
    for (idx, (group, summary)) in time_opening_summary
        .groups
        .iter()
        .zip(summaries.iter())
        .enumerate()
    {
        let expected = build_group_summary(params, &canonical_claims, claim_summaries, exact_claims, group)?;
        if summary != &expected {
            return Err(SimpleKernelError::OpeningFailed(format!(
                "kernel joint-opening group summary mismatch at index {idx}"
            )));
        }
        if summary.digest != summary.expected_digest() {
            return Err(SimpleKernelError::OpeningFailed(format!(
                "kernel joint-opening group summary digest mismatch at index {idx}"
            )));
        }
    }
    Ok(())
}

fn verify_unified_fold_summary(
    params: &NeoParams,
    time_opening_summary: &TimeOpeningProofSummary,
    groups: &[KernelJointOpeningGroupSummary],
    unification: &KernelJointOpeningUnificationProof,
    unified_fold: &Option<KernelJointOpeningGroupSummary>,
) -> Result<(), SimpleKernelError> {
    let expected = build_unified_fold_summary(params, time_opening_summary, groups, unification)?;
    if unified_fold != &expected {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint-opening unified fold mismatch".into(),
        ));
    }
    if let Some(summary) = unified_fold {
        if summary.digest != summary.expected_digest() {
            return Err(SimpleKernelError::OpeningFailed(
                "kernel joint-opening unified fold digest mismatch".into(),
            ));
        }
    }
    Ok(())
}

fn build_group_summary(
    params: &NeoParams,
    canonical_claims: &[(usize, crate::proof::OpeningClaim)],
    claim_summaries: &[KernelJointOpeningClaimSummary],
    exact_claims: &[KernelExactClaimWitness],
    group: &TimeOpeningGroupSummary,
) -> Result<KernelJointOpeningGroupSummary, SimpleKernelError> {
    let claims = group_claim_summaries(canonical_claims, claim_summaries, exact_claims, group)?;
    let commitment_id = claims[0].commitment_id;
    if claims
        .iter()
        .any(|claim| claim.commitment_id != commitment_id)
    {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint-opening group mixes commitment families".into(),
        ));
    }
    let rhos = sample_group_mixers(params, group, &claims)?;
    let mut joint_commitment = None;
    let mut joint_digits = vec![K::ZERO; D];
    for (rho, claim) in rhos.iter().zip(claims.iter()) {
        add_rot_scaled_commitment(&mut joint_commitment, &claim.joint_commitment, rho)?;
        let rotated_digits = apply_rot_to_digits(rho, &claim.joint_claim_digits)?;
        for (slot, rotated) in joint_digits.iter_mut().zip(rotated_digits) {
            *slot += rotated;
        }
    }
    let joint_commitment = joint_commitment
        .ok_or_else(|| SimpleKernelError::OpeningFailed("kernel joint opening produced empty group".into()))?;
    let summary = KernelJointOpeningGroupSummary {
        commitment_id,
        domain: group.domain,
        point: group.point.clone(),
        claim_indices: group.claim_indices.clone(),
        reduction_group_digest: group.group_digest,
        joint_commitment,
        joint_claim: recompose_digits_to_scalar(&joint_digits),
        joint_claim_digits: joint_digits,
        digest: [0; 32],
    };
    Ok(KernelJointOpeningGroupSummary {
        digest: summary.expected_digest(),
        ..summary
    })
}

fn build_unified_fold_summary(
    params: &NeoParams,
    time_opening_summary: &TimeOpeningProofSummary,
    groups: &[KernelJointOpeningGroupSummary],
    unification: &KernelJointOpeningUnificationProof,
) -> Result<Option<KernelJointOpeningGroupSummary>, SimpleKernelError> {
    if groups.is_empty() {
        return Ok(None);
    }

    let rhos = sample_unified_fold_mixers(params, time_opening_summary, groups, unification)?;
    let mut joint_commitment = None;
    let mut joint_digits = vec![K::ZERO; D];
    for (rho, group) in rhos.iter().zip(groups.iter()) {
        add_rot_scaled_commitment(&mut joint_commitment, &group.joint_commitment, rho)?;
        let rotated_digits = apply_rot_to_digits(rho, &group.joint_claim_digits)?;
        for (slot, rotated) in joint_digits.iter_mut().zip(rotated_digits) {
            *slot += rotated;
        }
    }
    let joint_commitment = joint_commitment.ok_or_else(|| {
        SimpleKernelError::OpeningFailed("kernel joint opening unified fold produced no groups".into())
    })?;
    let commitment_id = groups[0].commitment_id;
    if groups
        .iter()
        .any(|group| group.commitment_id != commitment_id)
    {
        return Ok(None);
    }
    let summary = KernelJointOpeningGroupSummary {
        commitment_id,
        domain: time_opening_summary.unified_domain,
        point: time_opening_summary.unified_point.clone(),
        claim_indices: (0..groups.len()).collect(),
        reduction_group_digest: time_opening_summary.unified_digest,
        joint_commitment,
        joint_claim: recompose_digits_to_scalar(&joint_digits),
        joint_claim_digits: joint_digits,
        digest: [0; 32],
    };
    Ok(Some(KernelJointOpeningGroupSummary {
        digest: summary.expected_digest(),
        ..summary
    }))
}

fn canonical_time_claims(manifest: &KernelOpeningManifest) -> Vec<(usize, crate::proof::OpeningClaim)> {
    let mut claims: Vec<_> = manifest
        .claims
        .iter()
        .enumerate()
        .map(|(idx, claim)| (idx, as_time_opening_claim(claim)))
        .collect();
    claims.sort_by(|left, right| canonical_claim_cmp(&left.1, &right.1));
    claims
}

fn group_claim_summaries<'a>(
    canonical_claims: &[(usize, crate::proof::OpeningClaim)],
    claim_summaries: &'a [KernelJointOpeningClaimSummary],
    exact_claims: &'a [KernelExactClaimWitness],
    group: &TimeOpeningGroupSummary,
) -> Result<Vec<&'a KernelJointOpeningClaimSummary>, SimpleKernelError> {
    let mut claims = Vec::with_capacity(group.claim_indices.len());
    for &claim_idx in &group.claim_indices {
        let (kernel_idx, canonical_claim) = canonical_claims.get(claim_idx).ok_or_else(|| {
            SimpleKernelError::OpeningFailed(format!(
                "kernel joint opening references out-of-range canonical claim index {claim_idx}"
            ))
        })?;
        let exact = exact_claims.get(*kernel_idx).ok_or_else(|| {
            SimpleKernelError::OpeningFailed(format!(
                "kernel joint opening missing exact claim witness for kernel claim index {}",
                kernel_idx
            ))
        })?;
        if as_time_opening_claim(&exact.claim) != *canonical_claim {
            return Err(SimpleKernelError::OpeningFailed(
                "kernel joint opening exact-claim witness mismatch".into(),
            ));
        }
        let summary = claim_summaries.get(*kernel_idx).ok_or_else(|| {
            SimpleKernelError::OpeningFailed(format!(
                "kernel joint opening missing claim summary for kernel claim index {}",
                kernel_idx
            ))
        })?;
        claims.push(summary);
    }
    if claims.is_empty() {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint opening encountered empty reduction group".into(),
        ));
    }
    Ok(claims)
}

fn sample_group_mixers(
    params: &NeoParams,
    group: &TimeOpeningGroupSummary,
    claims: &[&KernelJointOpeningClaimSummary],
) -> Result<Vec<Mat<F>>, SimpleKernelError> {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/joint_opening/group_mixers");
    tr.append_u64s(
        b"neo.fold.next/chip8/joint_opening/group_mixers_meta",
        &[
            opening_domain_tag(group.domain),
            group.point.len() as u64,
            group.claim_indices.len() as u64,
            group.coefficients.len() as u64,
            claims.len() as u64,
        ],
    );
    append_point(
        &mut tr,
        b"neo.fold.next/chip8/joint_opening/group_mixers_point",
        &group.point,
    );
    let claim_indices_u64: Vec<u64> = group.claim_indices.iter().map(|&idx| idx as u64).collect();
    tr.append_u64s(
        b"neo.fold.next/chip8/joint_opening/group_mixers_claim_indices",
        &claim_indices_u64,
    );
    tr.append_message(
        b"neo.fold.next/chip8/joint_opening/group_mixers_reduction_digest",
        &group.group_digest,
    );
    tr.append_message(
        b"neo.fold.next/chip8/joint_opening/group_mixers_reduced_digest",
        &group.reduced_digest,
    );
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/joint_opening/group_mixers_coefficients",
        &group.coefficients,
    );
    for (claim_idx, claim) in claims.iter().enumerate() {
        tr.append_u64s(
            b"neo.fold.next/chip8/joint_opening/group_mixers_claim_meta",
            &[claim_idx as u64],
        );
        tr.append_message(
            b"neo.fold.next/chip8/joint_opening/group_mixers_claim_digest",
            &claim.digest,
        );
    }
    let ring = RotRing::goldilocks();
    sample_rot_rhos_n(&mut tr, params, &ring, claims.len())
        .map_err(|err| SimpleKernelError::OpeningFailed(format!("kernel joint opening mixer sampling failed: {err}")))
}

fn sample_claim_mixers(
    params: &NeoParams,
    refinement: &KernelOpeningRefinement,
) -> Result<Vec<Mat<F>>, SimpleKernelError> {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/joint_opening/claim_mixers");
    let (commitment_order, root_tag) = opening_commitment_id_key(refinement.commitment_id);
    tr.append_u64s(
        b"neo.fold.next/chip8/joint_opening/claim_mixers_meta",
        &[
            commitment_order,
            root_tag,
            refinement.point.len() as u64,
            refinement.polynomial_ids.len() as u64,
        ],
    );
    append_point(
        &mut tr,
        b"neo.fold.next/chip8/joint_opening/claim_mixers_point",
        &refinement.point,
    );
    let polynomial_ids_u64: Vec<u64> = refinement
        .polynomial_ids
        .iter()
        .map(|&id| id as u64)
        .collect();
    tr.append_u64s(
        b"neo.fold.next/chip8/joint_opening/claim_mixers_polynomial_ids",
        &polynomial_ids_u64,
    );
    tr.append_message(
        b"neo.fold.next/chip8/joint_opening/claim_mixers_claim_digest",
        &refinement.claim_digest,
    );
    tr.append_message(
        b"neo.fold.next/chip8/joint_opening/claim_mixers_opening_proof_digest",
        &refinement.opening_proof_digest,
    );
    tr.append_message(
        b"neo.fold.next/chip8/joint_opening/claim_mixers_refinement_digest",
        &refinement.digest,
    );
    let ring = RotRing::goldilocks();
    sample_rot_rhos_n(&mut tr, params, &ring, refinement.polynomial_ids.len()).map_err(|err| {
        SimpleKernelError::OpeningFailed(format!("kernel joint opening claim mixer sampling failed: {err}"))
    })
}

fn sample_unified_fold_mixers(
    params: &NeoParams,
    time_opening_summary: &TimeOpeningProofSummary,
    groups: &[KernelJointOpeningGroupSummary],
    unification: &KernelJointOpeningUnificationProof,
) -> Result<Vec<Mat<F>>, SimpleKernelError> {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/joint_opening/unified_mixers");
    tr.append_u64s(
        b"neo.fold.next/chip8/joint_opening/unified_mixers_meta",
        &[
            groups.len() as u64,
            time_opening_summary.can_unify as u64,
            opening_domain_tag(time_opening_summary.unified_domain),
            time_opening_summary.unified_point.len() as u64,
        ],
    );
    append_point(
        &mut tr,
        b"neo.fold.next/chip8/joint_opening/unified_mixers_point",
        &time_opening_summary.unified_point,
    );
    tr.append_message(
        b"neo.fold.next/chip8/joint_opening/unified_mixers_unified_digest",
        &time_opening_summary.unified_digest,
    );
    tr.append_fields(
        b"neo.fold.next/chip8/joint_opening/unified_mixers_unify_claimed_sum",
        &unification.claimed_sum.as_coeffs(),
    );
    tr.append_u64s(
        b"neo.fold.next/chip8/joint_opening/unified_mixers_unify_meta",
        &[unification.round_polys.len() as u64, unification.r_unify.len() as u64],
    );
    for round in &unification.round_polys {
        append_k_vec(
            &mut tr,
            b"neo.fold.next/chip8/joint_opening/unified_mixers_unify_round",
            round,
        );
    }
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/joint_opening/unified_mixers_unify_point",
        &unification.r_unify,
    );
    for (group_idx, group) in groups.iter().enumerate() {
        tr.append_u64s(
            b"neo.fold.next/chip8/joint_opening/unified_mixers_group_meta",
            &[
                group_idx as u64,
                opening_domain_tag(group.domain),
                group.point.len() as u64,
                group.claim_indices.len() as u64,
            ],
        );
        append_point(
            &mut tr,
            b"neo.fold.next/chip8/joint_opening/unified_mixers_group_point",
            &group.point,
        );
        let claim_indices_u64: Vec<u64> = group.claim_indices.iter().map(|&idx| idx as u64).collect();
        tr.append_u64s(
            b"neo.fold.next/chip8/joint_opening/unified_mixers_group_indices",
            &claim_indices_u64,
        );
        tr.append_message(
            b"neo.fold.next/chip8/joint_opening/unified_mixers_group_digest",
            &group.digest,
        );
    }
    let ring = RotRing::goldilocks();
    sample_rot_rhos_n(&mut tr, params, &ring, groups.len()).map_err(|err| {
        SimpleKernelError::OpeningFailed(format!("kernel joint opening unified mixer sampling failed: {err}"))
    })
}

#[inline]
fn ceil_log2_at_least_1(n: usize) -> usize {
    let need = n.max(1).next_power_of_two();
    (need.trailing_zeros() as usize).max(1)
}

fn joint_group_value(group: &KernelJointOpeningGroupSummary) -> K {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/joint_opening/unify_group_value");
    tr.append_u64s(
        b"neo.fold.next/chip8/joint_opening/unify_group_value_meta",
        &[
            opening_domain_tag(group.domain),
            group.point.len() as u64,
            group.claim_indices.len() as u64,
            group.joint_claim_digits.len() as u64,
        ],
    );
    append_point(
        &mut tr,
        b"neo.fold.next/chip8/joint_opening/unify_group_value_point",
        &group.point,
    );
    let claim_indices_u64: Vec<u64> = group.claim_indices.iter().map(|&idx| idx as u64).collect();
    tr.append_u64s(
        b"neo.fold.next/chip8/joint_opening/unify_group_value_indices",
        &claim_indices_u64,
    );
    tr.append_message(
        b"neo.fold.next/chip8/joint_opening/unify_group_value_reduction_digest",
        &group.reduction_group_digest,
    );
    append_commitment(
        &mut tr,
        b"neo.fold.next/chip8/joint_opening/unify_group_value_commitment",
        &group.joint_commitment,
    );
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/joint_opening/unify_group_value_digits",
        &group.joint_claim_digits,
    );
    tr.append_fields(
        b"neo.fold.next/chip8/joint_opening/unify_group_value_scalar",
        &group.joint_claim.as_coeffs(),
    );
    let re = tr.challenge_field(b"neo.fold.next/chip8/joint_opening/unify_group_value/re");
    let im = tr.challenge_field(b"neo.fold.next/chip8/joint_opening/unify_group_value/im");
    neo_math::from_complex(re, im)
}

fn bind_joint_opening_unification_statement(
    tr: &mut Poseidon2Transcript,
    groups: &[KernelJointOpeningGroupSummary],
    ell_sel: usize,
    values: &[K],
) {
    tr.append_message(b"neo.fold.next/chip8/joint_opening/unify_bind", &[]);
    tr.append_u64s(
        b"neo.fold.next/chip8/joint_opening/unify_bind_meta",
        &[groups.len() as u64, ell_sel as u64],
    );
    for (group_idx, (group, value)) in groups.iter().zip(values.iter()).enumerate() {
        tr.append_u64s(
            b"neo.fold.next/chip8/joint_opening/unify_bind_group_meta",
            &[
                group_idx as u64,
                opening_domain_tag(group.domain),
                group.point.len() as u64,
                group.claim_indices.len() as u64,
                group.joint_claim_digits.len() as u64,
            ],
        );
        append_point(
            tr,
            b"neo.fold.next/chip8/joint_opening/unify_bind_group_point",
            &group.point,
        );
        let claim_indices_u64: Vec<u64> = group.claim_indices.iter().map(|&idx| idx as u64).collect();
        tr.append_u64s(
            b"neo.fold.next/chip8/joint_opening/unify_bind_group_indices",
            &claim_indices_u64,
        );
        tr.append_message(
            b"neo.fold.next/chip8/joint_opening/unify_bind_group_digest",
            &group.digest,
        );
        tr.append_fields(
            b"neo.fold.next/chip8/joint_opening/unify_bind_group_value",
            &value.as_coeffs(),
        );
    }
}

struct JointGroupSelectorOracle {
    values: Vec<K>,
    ell_sel: usize,
    prefix: Vec<K>,
}

impl JointGroupSelectorOracle {
    fn new(values: Vec<K>, ell_sel: usize) -> Self {
        Self {
            values,
            ell_sel,
            prefix: Vec::with_capacity(ell_sel),
        }
    }

    #[inline]
    fn bit_at(index: usize, bit: usize) -> bool {
        ((index >> bit) & 1usize) == 1
    }

    #[inline]
    fn bit_weight(bit: bool, x: K) -> K {
        if bit {
            x
        } else {
            K::ONE - x
        }
    }

    fn eval_at_point(values: &[K], point: &[K]) -> K {
        values
            .iter()
            .enumerate()
            .fold(K::ZERO, |acc, (group_idx, value)| {
                let weight = point
                    .iter()
                    .enumerate()
                    .fold(K::ONE, |term, (bit_idx, &bound)| {
                        term * Self::bit_weight(Self::bit_at(group_idx, bit_idx), bound)
                    });
                acc + weight * *value
            })
    }
}

impl neo_reductions::sumcheck::RoundOracle for JointGroupSelectorOracle {
    fn num_rounds(&self) -> usize {
        self.ell_sel.saturating_sub(self.prefix.len())
    }

    fn degree_bound(&self) -> usize {
        1
    }

    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        if self.prefix.len() >= self.ell_sel {
            return vec![K::ZERO; points.len()];
        }
        let round_idx = self.prefix.len();
        let mut out = vec![K::ZERO; points.len()];
        for (group_idx, value) in self.values.iter().enumerate() {
            let mut prefix_weight = K::ONE;
            for (bit_idx, &bound) in self.prefix.iter().enumerate() {
                prefix_weight *= Self::bit_weight(Self::bit_at(group_idx, bit_idx), bound);
            }
            for (slot, &x) in out.iter_mut().zip(points.iter()) {
                *slot += prefix_weight * Self::bit_weight(Self::bit_at(group_idx, round_idx), x) * *value;
            }
        }
        out
    }

    fn fold(&mut self, r: K) {
        self.prefix.push(r);
    }
}

fn prove_joint_opening_unification(
    groups: &[KernelJointOpeningGroupSummary],
) -> Result<KernelJointOpeningUnificationProof, SimpleKernelError> {
    if groups.is_empty() {
        return Ok(KernelJointOpeningUnificationProof::default());
    }
    let values: Vec<K> = groups.iter().map(joint_group_value).collect();
    let ell_sel = ceil_log2_at_least_1(groups.len());
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/joint_opening/unify");
    bind_joint_opening_unification_statement(&mut tr, groups, ell_sel, &values);
    let claimed_sum = values
        .iter()
        .copied()
        .fold(K::ZERO, |acc, value| acc + value);
    let mut oracle = JointGroupSelectorOracle::new(values, ell_sel);
    let (round_polys, r_unify) = neo_reductions::sumcheck::run_sumcheck_prover(&mut tr, &mut oracle, claimed_sum)
        .map_err(|err| {
            SimpleKernelError::OpeningFailed(format!("kernel joint opening unification prove failed: {err}"))
        })?;
    Ok(KernelJointOpeningUnificationProof {
        claimed_sum,
        round_polys,
        r_unify,
    })
}

fn verify_joint_opening_unification(
    groups: &[KernelJointOpeningGroupSummary],
    proof: &KernelJointOpeningUnificationProof,
) -> Result<(), SimpleKernelError> {
    if groups.is_empty() {
        if proof.claimed_sum == K::ZERO && proof.round_polys.is_empty() && proof.r_unify.is_empty() {
            return Ok(());
        }
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint-opening unification proof must be empty when there are no groups".into(),
        ));
    }
    let values: Vec<K> = groups.iter().map(joint_group_value).collect();
    let ell_sel = ceil_log2_at_least_1(groups.len());
    if proof.round_polys.len() != ell_sel {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "kernel joint-opening unification round count {} != expected {ell_sel}",
            proof.round_polys.len()
        )));
    }
    let expected_sum = values
        .iter()
        .copied()
        .fold(K::ZERO, |acc, value| acc + value);
    if proof.claimed_sum != expected_sum {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint-opening unification claimed_sum mismatch".into(),
        ));
    }
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/joint_opening/unify");
    bind_joint_opening_unification_statement(&mut tr, groups, ell_sel, &values);
    let (r_unify, final_value, ok) = verify_sumcheck_rounds(&mut tr, 1, proof.claimed_sum, &proof.round_polys);
    if !ok {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint-opening unification sumcheck verification failed".into(),
        ));
    }
    if proof.r_unify != r_unify {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint-opening unification selector point mismatch".into(),
        ));
    }
    let expected_final = JointGroupSelectorOracle::eval_at_point(&values, &proof.r_unify);
    if final_value != expected_final {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint-opening unification final value mismatch".into(),
        ));
    }
    Ok(())
}

fn append_fold_shape(tr: &mut Poseidon2Transcript, label: &'static [u8], shape: &KernelJointOpeningFoldShape) {
    tr.append_message(label, b"fold_shape");
    tr.append_u64s(
        b"neo.fold.next/chip8/joint_opening/fold_shape_meta",
        &[
            shape.logical_t as u64,
            shape.encoded_time_width as u64,
            shape.selector_bits as u64,
            shape.selector_domain_size as u64,
        ],
    );
}

fn build_joint_opening_fold_shape_for_commitment(
    logical_t: usize,
    commitment_id: CommitmentId,
    selector_bits: usize,
) -> Result<KernelJointOpeningFoldShape, SimpleKernelError> {
    let family_logical_t = match commitment_id {
        CommitmentId::Lane | CommitmentId::DecodeHandoff => logical_t,
        CommitmentId::FetchRa => logical_t
            .checked_shl(11)
            .ok_or_else(|| SimpleKernelError::OpeningFailed("fetch-ra logical length overflow".into()))?,
        CommitmentId::DecodeRa => logical_t
            .checked_shl(16)
            .ok_or_else(|| SimpleKernelError::OpeningFailed("decode-ra logical length overflow".into()))?,
        CommitmentId::AluRa => logical_t
            .checked_shl(18)
            .ok_or_else(|| SimpleKernelError::OpeningFailed("alu-ra logical length overflow".into()))?,
        CommitmentId::Eq4Ra => logical_t
            .checked_shl(8)
            .ok_or_else(|| SimpleKernelError::OpeningFailed("eq4-ra logical length overflow".into()))?,
        CommitmentId::RegTwist => logical_t
            .checked_shl(5)
            .ok_or_else(|| SimpleKernelError::OpeningFailed("reg-twist logical length overflow".into()))?,
        CommitmentId::RamTwist => logical_t
            .checked_shl(13)
            .ok_or_else(|| SimpleKernelError::OpeningFailed("ram-twist logical length overflow".into()))?,
        CommitmentId::RomTable => 1usize << 11,
        CommitmentId::Eq4Table => 1usize << 8,
        CommitmentId::DecodeTable | CommitmentId::AluTable => 1usize << 16,
        CommitmentId::RootProver(_) => {
            return Err(SimpleKernelError::OpeningFailed(
                "kernel joint-opening fold shape does not support root-owned commitments".into(),
            ));
        }
    };

    let encoded_t = encoded_time_width(family_logical_t)?;
    if encoded_t == 0 {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint-opening fold lane requires logical_t > 0".into(),
        ));
    }
    let selector_domain_size = 1usize
        .checked_shl(selector_bits as u32)
        .ok_or_else(|| {
            SimpleKernelError::OpeningFailed("kernel joint-opening fold lane selector domain overflow".into())
        })?
        .max(1);
    Ok(KernelJointOpeningFoldShape {
        logical_t: family_logical_t,
        encoded_time_width: encoded_t,
        selector_bits,
        selector_domain_size,
    })
}

fn sample_fold_bucket_point(commitment_id: CommitmentId, groups: &[&KernelJointOpeningGroupSummary]) -> Vec<F> {
    let selector_bits = ceil_log2(groups.len());
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/joint_opening/fold_bucket_point");
    let (commitment_order, root_tag) = opening_commitment_id_key(commitment_id);
    tr.append_u64s(
        b"neo.fold.next/chip8/joint_opening/fold_bucket_point_meta",
        &[commitment_order, root_tag, groups.len() as u64, selector_bits as u64],
    );
    for group in groups {
        tr.append_message(
            b"neo.fold.next/chip8/joint_opening/fold_bucket_point_group_digest",
            &group.digest,
        );
    }
    (0..selector_bits)
        .map(|_| tr.challenge_field(b"neo.fold.next/chip8/joint_opening/fold_bucket_point/base"))
        .collect()
}

fn fold_bucket_commitment(
    groups: &[&KernelJointOpeningGroupSummary],
    r_fold: &[F],
) -> Result<Commitment, SimpleKernelError> {
    let first = groups
        .first()
        .ok_or_else(|| SimpleKernelError::OpeningFailed("fold bucket cannot be empty".into()))?;
    let mut acc = Commitment::zeros(first.joint_commitment.d, first.joint_commitment.kappa);
    for (group_idx, group) in groups.iter().enumerate() {
        let weight = eq_weight_at(r_fold, group_idx);
        add_scaled_commitment(&mut acc, &group.joint_commitment, weight)?;
    }
    Ok(acc)
}

fn fold_bucket_claim_values(
    groups: &[&KernelJointOpeningGroupSummary],
    r_fold: &[F],
) -> Result<(Vec<K>, K), SimpleKernelError> {
    let digit_len = groups
        .first()
        .map(|group| group.joint_claim_digits.len())
        .ok_or_else(|| SimpleKernelError::OpeningFailed("fold bucket cannot be empty".into()))?;
    let mut folded_digits = vec![K::ZERO; digit_len];
    let mut folded_claim = K::ZERO;
    for (group_idx, group) in groups.iter().enumerate() {
        if group.joint_claim_digits.len() != digit_len {
            return Err(SimpleKernelError::OpeningFailed(
                "kernel joint-opening fold bucket digit widths must match within a family".into(),
            ));
        }
        let weight_f = eq_weight_at(r_fold, group_idx);
        let weight_k = K::from(weight_f);
        for (slot, digit) in folded_digits
            .iter_mut()
            .zip(group.joint_claim_digits.iter())
        {
            *slot += *digit * weight_k;
        }
        folded_claim += group.joint_claim * weight_k;
    }
    Ok((folded_digits, folded_claim))
}

fn add_scaled_commitment(acc: &mut Commitment, commitment: &Commitment, weight: F) -> Result<(), SimpleKernelError> {
    if acc.d != commitment.d || acc.kappa != commitment.kappa {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel joint-opening fold bucket commitment shape mismatch".into(),
        ));
    }
    for (slot, value) in acc.data.iter_mut().zip(commitment.data.iter()) {
        *slot += *value * weight;
    }
    Ok(())
}

fn eq_weight_at(point: &[F], index: usize) -> F {
    point.iter().enumerate().fold(F::ONE, |acc, (bit, &ri)| {
        if (index >> bit) & 1 == 1 {
            acc * ri
        } else {
            acc * (F::ONE - ri)
        }
    })
}

#[inline]
fn ceil_log2(n: usize) -> usize {
    if n <= 1 {
        0
    } else {
        n.next_power_of_two().trailing_zeros() as usize
    }
}

fn append_f_vec(tr: &mut Poseidon2Transcript, label: &'static [u8], values: &[F]) {
    tr.append_u64s(b"neo.fold.next/chip8/joint_opening/f_len", &[values.len() as u64]);
    tr.append_fields_iter(label, values.len(), values.iter().copied());
}

fn append_point(tr: &mut Poseidon2Transcript, label: &'static [u8], point: &[K]) {
    tr.append_u64s(b"neo.fold.next/chip8/joint_opening/point_len", &[point.len() as u64]);
    let coeffs_per_elem = point
        .first()
        .map(|value| value.as_coeffs().len())
        .unwrap_or(0);
    tr.append_fields_iter(
        label,
        point.len().saturating_mul(coeffs_per_elem),
        point.iter().flat_map(|value| value.as_coeffs()),
    );
}

fn append_k_vec(tr: &mut Poseidon2Transcript, label: &'static [u8], values: &[K]) {
    tr.append_u64s(b"neo.fold.next/chip8/joint_opening/k_len", &[values.len() as u64]);
    let coeffs_per_elem = values
        .first()
        .map(|value| value.as_coeffs().len())
        .unwrap_or(0);
    tr.append_fields_iter(
        label,
        values.len().saturating_mul(coeffs_per_elem),
        values.iter().flat_map(|value| value.as_coeffs()),
    );
}

fn append_commitment(tr: &mut Poseidon2Transcript, label: &'static [u8], commitment: &Commitment) {
    tr.append_u64s(
        b"neo.fold.next/chip8/joint_opening/commitment_meta",
        &[
            commitment.d as u64,
            commitment.kappa as u64,
            commitment.data.len() as u64,
        ],
    );
    tr.append_fields_iter(label, commitment.data.len(), commitment.data.iter().copied());
}

fn opening_domain_tag(domain: OpeningDomain) -> u64 {
    match domain {
        OpeningDomain::Cpu => 1,
        OpeningDomain::Mem => 2,
    }
}

fn rot_matrix_to_rq(mat: &Mat<F>) -> Result<RqEl, SimpleKernelError> {
    if mat.rows() != D || mat.cols() != D {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "kernel joint opening mixer must be {D}x{D} (got {}x{})",
            mat.rows(),
            mat.cols()
        )));
    }
    let mut coeffs = [F::ZERO; D];
    for idx in 0..D {
        coeffs[idx] = mat[(idx, 0)];
    }
    Ok(cf_inv(coeffs))
}

fn add_rot_scaled_commitment(
    acc: &mut Option<Commitment>,
    commitment: &Commitment,
    rho: &Mat<F>,
) -> Result<(), SimpleKernelError> {
    let rho_rq = rot_matrix_to_rq(rho)?;
    let term = s_mul(&rho_rq, commitment);
    if let Some(out) = acc.as_mut() {
        out.add_inplace(&term);
    } else {
        *acc = Some(term);
    }
    Ok(())
}

fn apply_rot_to_digits(rho: &Mat<F>, digits: &[K]) -> Result<Vec<K>, SimpleKernelError> {
    if rho.rows() != D || rho.cols() != D {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "kernel joint opening mixer must be {D}x{D} (got {}x{})",
            rho.rows(),
            rho.cols()
        )));
    }
    if digits.len() != D {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "kernel joint opening digit width mismatch: {} != {D}",
            digits.len()
        )));
    }
    let mut out = vec![K::ZERO; D];
    for row in 0..D {
        let mut acc = K::ZERO;
        for col in 0..D {
            acc += digits[col].scale_base(rho[(row, col)]);
        }
        out[row] = acc;
    }
    Ok(out)
}

fn recompose_digits_to_scalar(digits: &[K]) -> K {
    let mut acc = K::ZERO;
    let mut scale = K::ONE;
    let radix = K::from(F::from_u64(2));
    for digit in digits {
        acc += scale * *digit;
        scale *= radix;
    }
    acc
}

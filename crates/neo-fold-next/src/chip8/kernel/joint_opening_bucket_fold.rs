//! Owns per-family folded proof objects for heterogeneous kernel joint-opening groups.

use neo_ajtai::Commitment;
use neo_math::{KExtensions, F, K};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use super::joint_opening::{KernelJointOpeningGroupSummary, KernelJointOpeningSummary};
use super::joint_opening_support::{
    append_fold_shape, build_joint_opening_fold_shape_for_commitment, KernelJointOpeningFoldShape,
};
use super::{opening_commitment_id_key, CommitmentId, SimpleKernelError};

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
        .map(|(commitment_id, groups)| build_bucket_proof(logical_t, commitment_id, &groups))
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

fn build_bucket_proof(
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

//! Owns the explicit refinement map from exact Ajtai opening witnesses to raw kernel scalar claims.

use neo_ajtai::Commitment;
use neo_math::{KExtensions, D, K};
use neo_transcript::{Poseidon2Transcript, Transcript};

use super::lane_commitment::{recompose_time_vector_digits_to_scalar, TimeVectorOpeningProof};
use super::opening_boundary::commitment_polynomial_slot;
use super::{
    AluRaCommitmentSet, AluRaOpeningProof, AluTableCommitmentSet, AluTableOpeningProof, CommitmentId,
    DecodeHandoffCommitmentSet, DecodeHandoffOpeningProof, DecodeRaCommitmentSet, DecodeRaOpeningProof,
    DecodeTableCommitmentSet, DecodeTableOpeningProof, Eq4RaCommitmentSet, Eq4RaOpeningProof, Eq4TableCommitmentSet,
    Eq4TableOpeningProof, FetchRaCommitmentSet, FetchRaOpeningProof, KernelOpeningClaim, KernelOpeningManifest,
    LaneCommitmentSet, LaneOpeningProof, RamTwistCommitmentSet, RamTwistOpeningProof, RegTwistCommitmentSet,
    RegTwistOpeningProof, RomTableCommitmentSet, RomTableOpeningProof, SimpleKernelError,
};

#[derive(Clone, Debug, PartialEq)]
pub struct KernelOpeningRefinement {
    pub commitment_id: CommitmentId,
    pub point: Vec<K>,
    pub polynomial_ids: Vec<usize>,
    pub claim_digest: [u8; 32],
    pub opening_proof_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelOpeningRefinementSummary {
    pub refinements: Vec<KernelOpeningRefinement>,
    pub digest: [u8; 32],
}

pub(crate) struct KernelExactOpeningArtifacts<'a> {
    pub lane_commitments: &'a LaneCommitmentSet,
    pub fetch_ra_commitments: &'a FetchRaCommitmentSet,
    pub decode_ra_commitments: &'a DecodeRaCommitmentSet,
    pub alu_ra_commitments: &'a AluRaCommitmentSet,
    pub eq4_ra_commitments: &'a Eq4RaCommitmentSet,
    pub rom_table_commitments: &'a RomTableCommitmentSet,
    pub decode_table_commitments: &'a DecodeTableCommitmentSet,
    pub alu_table_commitments: &'a AluTableCommitmentSet,
    pub eq4_table_commitments: &'a Eq4TableCommitmentSet,
    pub decode_handoff_commitments: &'a DecodeHandoffCommitmentSet,
    pub reg_twist_commitments: &'a RegTwistCommitmentSet,
    pub ram_twist_commitments: &'a RamTwistCommitmentSet,
    pub lane_opening_proofs: &'a [LaneOpeningProof],
    pub fetch_ra_opening_proofs: &'a [FetchRaOpeningProof],
    pub decode_ra_opening_proofs: &'a [DecodeRaOpeningProof],
    pub alu_ra_opening_proofs: &'a [AluRaOpeningProof],
    pub eq4_ra_opening_proofs: &'a [Eq4RaOpeningProof],
    pub rom_table_opening_proofs: &'a [RomTableOpeningProof],
    pub decode_table_opening_proofs: &'a [DecodeTableOpeningProof],
    pub alu_table_opening_proofs: &'a [AluTableOpeningProof],
    pub eq4_table_opening_proofs: &'a [Eq4TableOpeningProof],
    pub decode_handoff_opening_proofs: &'a [DecodeHandoffOpeningProof],
    pub reg_twist_opening_proofs: &'a [RegTwistOpeningProof],
    pub ram_twist_opening_proofs: &'a [RamTwistOpeningProof],
}

pub(crate) struct KernelExactClaimWitness {
    pub claim: KernelOpeningClaim,
    pub refinement: KernelOpeningRefinement,
    pub claim_commitments: Vec<Commitment>,
    pub proof: TimeVectorOpeningProof,
}

impl KernelOpeningRefinement {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/opening_refinement");
        let (commitment_order, root_tag) = super::opening_commitment_id_key(self.commitment_id);
        tr.append_u64s(
            b"neo.fold.next/chip8/opening_refinement/meta",
            &[
                commitment_order,
                root_tag,
                self.point.len() as u64,
                self.polynomial_ids.len() as u64,
            ],
        );
        append_point(&mut tr, b"neo.fold.next/chip8/opening_refinement/point", &self.point);
        let polynomial_ids_u64: Vec<u64> = self.polynomial_ids.iter().map(|&id| id as u64).collect();
        tr.append_u64s(
            b"neo.fold.next/chip8/opening_refinement/polynomial_ids",
            &polynomial_ids_u64,
        );
        tr.append_message(
            b"neo.fold.next/chip8/opening_refinement/claim_digest",
            &self.claim_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/opening_refinement/opening_proof_digest",
            &self.opening_proof_digest,
        );
        tr.digest32()
    }
}

impl KernelOpeningRefinementSummary {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/opening_refinement_summary");
        tr.append_u64s(
            b"neo.fold.next/chip8/opening_refinement_summary/len",
            &[self.refinements.len() as u64],
        );
        for refinement in &self.refinements {
            tr.append_message(
                b"neo.fold.next/chip8/opening_refinement_summary/refinement_digest",
                &refinement.digest,
            );
        }
        tr.digest32()
    }
}

pub(crate) fn collect_exact_claim_witnesses(
    manifest: &KernelOpeningManifest,
    artifacts: KernelExactOpeningArtifacts<'_>,
) -> Result<Vec<KernelExactClaimWitness>, SimpleKernelError> {
    let mut lane_idx = 0usize;
    let mut fetch_idx = 0usize;
    let mut decode_idx = 0usize;
    let mut alu_idx = 0usize;
    let mut eq4_idx = 0usize;
    let mut rom_idx = 0usize;
    let mut decode_table_idx = 0usize;
    let mut alu_table_idx = 0usize;
    let mut eq4_table_idx = 0usize;
    let mut handoff_idx = 0usize;
    let mut reg_idx = 0usize;
    let mut ram_idx = 0usize;
    let mut out = Vec::with_capacity(manifest.claims.len());

    for claim in &manifest.claims {
        let witness = match claim.commitment_id {
            CommitmentId::Lane => make_exact_claim_witness(
                claim,
                &artifacts.lane_commitments.commitments,
                take_proof(artifacts.lane_opening_proofs, &mut lane_idx, "lane")?,
            )?,
            CommitmentId::FetchRa => make_exact_claim_witness(
                claim,
                &artifacts.fetch_ra_commitments.commitments,
                take_proof(artifacts.fetch_ra_opening_proofs, &mut fetch_idx, "fetch-ra")?,
            )?,
            CommitmentId::DecodeRa => make_exact_claim_witness(
                claim,
                &artifacts.decode_ra_commitments.commitments,
                take_proof(artifacts.decode_ra_opening_proofs, &mut decode_idx, "decode-ra")?,
            )?,
            CommitmentId::AluRa => make_exact_claim_witness(
                claim,
                &artifacts.alu_ra_commitments.commitments,
                take_proof(artifacts.alu_ra_opening_proofs, &mut alu_idx, "alu-ra")?,
            )?,
            CommitmentId::Eq4Ra => make_exact_claim_witness(
                claim,
                &artifacts.eq4_ra_commitments.commitments,
                take_proof(artifacts.eq4_ra_opening_proofs, &mut eq4_idx, "eq4-ra")?,
            )?,
            CommitmentId::RomTable => make_exact_claim_witness(
                claim,
                &artifacts.rom_table_commitments.commitments,
                take_proof(artifacts.rom_table_opening_proofs, &mut rom_idx, "rom-table")?,
            )?,
            CommitmentId::DecodeTable => make_exact_claim_witness(
                claim,
                &artifacts.decode_table_commitments.commitments,
                take_proof(
                    artifacts.decode_table_opening_proofs,
                    &mut decode_table_idx,
                    "decode-table",
                )?,
            )?,
            CommitmentId::AluTable => make_exact_claim_witness(
                claim,
                &artifacts.alu_table_commitments.commitments,
                take_proof(artifacts.alu_table_opening_proofs, &mut alu_table_idx, "alu-table")?,
            )?,
            CommitmentId::Eq4Table => make_exact_claim_witness(
                claim,
                &artifacts.eq4_table_commitments.commitments,
                take_proof(artifacts.eq4_table_opening_proofs, &mut eq4_table_idx, "eq4-table")?,
            )?,
            CommitmentId::DecodeHandoff => make_exact_claim_witness(
                claim,
                &artifacts.decode_handoff_commitments.commitments,
                take_proof(
                    artifacts.decode_handoff_opening_proofs,
                    &mut handoff_idx,
                    "decode-handoff",
                )?,
            )?,
            CommitmentId::RegTwist => make_exact_claim_witness(
                claim,
                &artifacts.reg_twist_commitments.commitments,
                take_proof(artifacts.reg_twist_opening_proofs, &mut reg_idx, "reg-twist")?,
            )?,
            CommitmentId::RamTwist => make_exact_claim_witness(
                claim,
                &artifacts.ram_twist_commitments.commitments,
                take_proof(artifacts.ram_twist_opening_proofs, &mut ram_idx, "ram-twist")?,
            )?,
            CommitmentId::RootProver(_) => {
                return Err(SimpleKernelError::OpeningFailed(
                    "kernel opening refinements do not support root-owned claims".into(),
                ));
            }
        };
        out.push(witness);
    }

    expect_all_consumed(artifacts.lane_opening_proofs, lane_idx, "lane")?;
    expect_all_consumed(artifacts.fetch_ra_opening_proofs, fetch_idx, "fetch-ra")?;
    expect_all_consumed(artifacts.decode_ra_opening_proofs, decode_idx, "decode-ra")?;
    expect_all_consumed(artifacts.alu_ra_opening_proofs, alu_idx, "alu-ra")?;
    expect_all_consumed(artifacts.eq4_ra_opening_proofs, eq4_idx, "eq4-ra")?;
    expect_all_consumed(artifacts.rom_table_opening_proofs, rom_idx, "rom-table")?;
    expect_all_consumed(artifacts.decode_table_opening_proofs, decode_table_idx, "decode-table")?;
    expect_all_consumed(artifacts.alu_table_opening_proofs, alu_table_idx, "alu-table")?;
    expect_all_consumed(artifacts.eq4_table_opening_proofs, eq4_table_idx, "eq4-table")?;
    expect_all_consumed(artifacts.decode_handoff_opening_proofs, handoff_idx, "decode-handoff")?;
    expect_all_consumed(artifacts.reg_twist_opening_proofs, reg_idx, "reg-twist")?;
    expect_all_consumed(artifacts.ram_twist_opening_proofs, ram_idx, "ram-twist")?;
    Ok(out)
}

pub(crate) fn build_kernel_opening_refinement_summary(
    manifest: &KernelOpeningManifest,
    artifacts: KernelExactOpeningArtifacts<'_>,
) -> Result<KernelOpeningRefinementSummary, SimpleKernelError> {
    let refinements = collect_exact_claim_witnesses(manifest, artifacts)?
        .into_iter()
        .map(|witness| witness.refinement)
        .collect();
    let summary = KernelOpeningRefinementSummary {
        refinements,
        digest: [0; 32],
    };
    Ok(KernelOpeningRefinementSummary {
        digest: summary.expected_digest(),
        ..summary
    })
}

pub(crate) fn verify_kernel_opening_refinement_summary(
    manifest: &KernelOpeningManifest,
    artifacts: KernelExactOpeningArtifacts<'_>,
    summary: &KernelOpeningRefinementSummary,
) -> Result<(), SimpleKernelError> {
    let expected = build_kernel_opening_refinement_summary(manifest, artifacts)?;
    if summary.refinements != expected.refinements {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel opening refinement summary mismatch".into(),
        ));
    }
    if summary.digest != summary.expected_digest() {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel opening refinement summary digest mismatch".into(),
        ));
    }
    Ok(())
}

pub(crate) fn find_refinement_by_claim_digest<'a>(
    summary: &'a KernelOpeningRefinementSummary,
    claim_digest: [u8; 32],
    label: &str,
) -> Result<&'a KernelOpeningRefinement, SimpleKernelError> {
    let mut matches = summary
        .refinements
        .iter()
        .filter(|refinement| refinement.claim_digest == claim_digest);
    let refinement = matches.next().ok_or_else(|| {
        SimpleKernelError::OpeningFailed(format!(
            "{label} missing opening refinement for claim digest {:02x?}",
            claim_digest
        ))
    })?;
    if matches.next().is_some() {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{label} has non-unique opening refinement for claim digest {:02x?}",
            claim_digest
        )));
    }
    Ok(refinement)
}

fn make_exact_claim_witness(
    claim: &KernelOpeningClaim,
    commitments: &[Commitment],
    proof: &TimeVectorOpeningProof,
) -> Result<KernelExactClaimWitness, SimpleKernelError> {
    if proof.point != claim.point
        || proof.polynomial_ids != claim.polynomial_ids
        || proof.claimed_values != claim.claimed_values
    {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{} exact opening proof mismatch",
            opening_label(claim.commitment_id)
        )));
    }
    if proof.digit_evals.len() != claim.polynomial_ids.len() {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{} exact opening digit arity mismatch",
            opening_label(claim.commitment_id)
        )));
    }
    if claim.polynomial_ids.is_empty() {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{} exact opening claim is empty",
            opening_label(claim.commitment_id)
        )));
    }

    let mut claim_commitments = Vec::with_capacity(claim.polynomial_ids.len());
    for (position, (&poly_id, digits)) in claim
        .polynomial_ids
        .iter()
        .zip(proof.digit_evals.iter())
        .enumerate()
    {
        let slot = commitment_polynomial_slot(claim.commitment_id, poly_id)?;
        let commitment = commitments.get(slot).ok_or_else(|| {
            SimpleKernelError::OpeningFailed(format!(
                "{} opening references out-of-range polynomial id {poly_id}",
                opening_label(claim.commitment_id)
            ))
        })?;
        if digits.len() != D {
            return Err(SimpleKernelError::OpeningFailed(format!(
                "{} exact opening digit width mismatch at position {}",
                opening_label(claim.commitment_id),
                position
            )));
        }
        if recompose_time_vector_digits_to_scalar(digits) != claim.claimed_values[position] {
            return Err(SimpleKernelError::OpeningFailed(format!(
                "{} exact opening value mismatch at position {}",
                opening_label(claim.commitment_id),
                position
            )));
        }
        claim_commitments.push(commitment.clone());
    }

    let refinement = KernelOpeningRefinement {
        commitment_id: claim.commitment_id,
        point: claim.point.clone(),
        polynomial_ids: claim.polynomial_ids.clone(),
        claim_digest: claim.digest,
        opening_proof_digest: proof.expected_digest(),
        digest: [0; 32],
    };
    let refinement = KernelOpeningRefinement {
        digest: refinement.expected_digest(),
        ..refinement
    };
    Ok(KernelExactClaimWitness {
        claim: claim.clone(),
        refinement,
        claim_commitments,
        proof: proof.clone(),
    })
}

fn opening_label(commitment_id: CommitmentId) -> &'static str {
    match commitment_id {
        CommitmentId::Lane => "lane",
        CommitmentId::FetchRa => "fetch-ra",
        CommitmentId::DecodeRa => "decode-ra",
        CommitmentId::AluRa => "alu-ra",
        CommitmentId::Eq4Ra => "eq4-ra",
        CommitmentId::DecodeHandoff => "decode-handoff",
        CommitmentId::RegTwist => "reg-twist",
        CommitmentId::RamTwist => "ram-twist",
        CommitmentId::RomTable => "rom-table",
        CommitmentId::DecodeTable => "decode-table",
        CommitmentId::AluTable => "alu-table",
        CommitmentId::Eq4Table => "eq4-table",
        CommitmentId::RootProver(_) => "root-prover",
    }
}

fn take_proof<'a, T>(proofs: &'a [T], index: &mut usize, label: &str) -> Result<&'a T, SimpleKernelError> {
    let proof = proofs
        .get(*index)
        .ok_or_else(|| SimpleKernelError::OpeningFailed(format!("{label} exact opening proof count mismatch")))?;
    *index += 1;
    Ok(proof)
}

fn expect_all_consumed<T>(proofs: &[T], used: usize, label: &str) -> Result<(), SimpleKernelError> {
    if used == proofs.len() {
        Ok(())
    } else {
        Err(SimpleKernelError::OpeningFailed(format!(
            "{label} exact opening proof count mismatch"
        )))
    }
}

fn append_point(tr: &mut Poseidon2Transcript, label: &'static [u8], point: &[K]) {
    tr.append_u64s(
        b"neo.fold.next/chip8/opening_refinement/point_len",
        &[point.len() as u64],
    );
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

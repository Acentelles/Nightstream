//! Owns the explicit top-level semantic evidence summary for the CHIP-8 kernel.

use neo_math::{KExtensions, K};
use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::proof::TimeOpeningProofSummary;

use super::{
    AddressCorrectnessProof, CycleProductProof, KernelJointOpeningFoldBucketProof, KernelJointOpeningSummary,
    KernelOpeningManifest, KernelOpeningRefinementSummary, RootOpeningManifest, RowBindingClaim, ShoutChannelProof,
    SimpleKernelError, Stage1ShoutProof, Stage2TwistProof, Stage3Proof,
};
use super::{KernelBridgeBindingSummary, KernelRowProjectionSummary, LaneShiftProof};

#[derive(Clone, Debug, PartialEq)]
pub struct KernelSemanticEvidenceSummary {
    pub stage1_digest: [u8; 32],
    pub stage2_digest: [u8; 32],
    pub stage3_digest: [u8; 32],
    pub kernel_opening_manifest_digest: [u8; 32],
    pub root_opening_manifest_digest: [u8; 32],
    pub time_opening_summary_digest: [u8; 32],
    pub opening_refinement_summary_digest: [u8; 32],
    pub joint_opening_summary_digest: [u8; 32],
    pub joint_opening_fold_bucket_proof_digests: Vec<[u8; 32]>,
    pub row_projection_summary_digest: [u8; 32],
    pub bridge_binding_summary_digest: [u8; 32],
    pub digest: [u8; 32],
}

pub(crate) struct KernelSemanticEvidenceInputs<'a> {
    pub stage1: &'a Stage1ShoutProof,
    pub stage2: &'a Stage2TwistProof,
    pub stage3: &'a Stage3Proof,
    pub kernel_opening_manifest: &'a KernelOpeningManifest,
    pub root_opening_manifest: &'a RootOpeningManifest,
    pub time_opening_summary: &'a TimeOpeningProofSummary,
    pub opening_refinement_summary: &'a KernelOpeningRefinementSummary,
    pub joint_opening_summary: &'a KernelJointOpeningSummary,
    pub joint_opening_fold_bucket_proofs: &'a [KernelJointOpeningFoldBucketProof],
    pub row_projection_summary: &'a KernelRowProjectionSummary,
    pub bridge_binding_summary: &'a KernelBridgeBindingSummary,
}

impl KernelSemanticEvidenceSummary {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/semantic_evidence_summary");
        tr.append_message(
            b"neo.fold.next/chip8/semantic_evidence_summary/stage1",
            &self.stage1_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/semantic_evidence_summary/stage2",
            &self.stage2_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/semantic_evidence_summary/stage3",
            &self.stage3_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/semantic_evidence_summary/kernel_manifest",
            &self.kernel_opening_manifest_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/semantic_evidence_summary/root_manifest",
            &self.root_opening_manifest_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/semantic_evidence_summary/time_opening",
            &self.time_opening_summary_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/semantic_evidence_summary/opening_refinement",
            &self.opening_refinement_summary_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/semantic_evidence_summary/joint_opening_summary",
            &self.joint_opening_summary_digest,
        );
        tr.append_u64s(
            b"neo.fold.next/chip8/semantic_evidence_summary/fold_bucket_proof_count",
            &[self.joint_opening_fold_bucket_proof_digests.len() as u64],
        );
        for digest in &self.joint_opening_fold_bucket_proof_digests {
            tr.append_message(
                b"neo.fold.next/chip8/semantic_evidence_summary/fold_bucket_proof",
                digest,
            );
        }
        tr.append_message(
            b"neo.fold.next/chip8/semantic_evidence_summary/row_projection",
            &self.row_projection_summary_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/semantic_evidence_summary/bridge_binding",
            &self.bridge_binding_summary_digest,
        );
        tr.digest32()
    }
}

pub(crate) fn build_kernel_semantic_evidence_summary(
    inputs: KernelSemanticEvidenceInputs<'_>,
) -> Result<KernelSemanticEvidenceSummary, SimpleKernelError> {
    let summary = KernelSemanticEvidenceSummary {
        stage1_digest: digest_stage1(inputs.stage1),
        stage2_digest: digest_stage2(inputs.stage2),
        stage3_digest: digest_stage3(inputs.stage3),
        kernel_opening_manifest_digest: inputs.kernel_opening_manifest.digest,
        root_opening_manifest_digest: inputs.root_opening_manifest.digest,
        time_opening_summary_digest: digest_time_opening_summary(inputs.time_opening_summary),
        opening_refinement_summary_digest: inputs.opening_refinement_summary.digest,
        joint_opening_summary_digest: digest_joint_opening_summary(inputs.joint_opening_summary),
        joint_opening_fold_bucket_proof_digests: inputs
            .joint_opening_fold_bucket_proofs
            .iter()
            .map(digest_joint_opening_fold_bucket_proof)
            .collect(),
        row_projection_summary_digest: inputs.row_projection_summary.digest,
        bridge_binding_summary_digest: inputs.bridge_binding_summary.digest,
        digest: [0; 32],
    };
    Ok(KernelSemanticEvidenceSummary {
        digest: summary.expected_digest(),
        ..summary
    })
}

pub(crate) fn verify_kernel_semantic_evidence_summary(
    inputs: KernelSemanticEvidenceInputs<'_>,
    summary: &KernelSemanticEvidenceSummary,
) -> Result<(), SimpleKernelError> {
    let expected = build_kernel_semantic_evidence_summary(inputs)?;
    if summary != &expected {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel semantic evidence summary mismatch".into(),
        ));
    }
    if summary.digest != summary.expected_digest() {
        return Err(SimpleKernelError::OpeningFailed(
            "kernel semantic evidence summary digest mismatch".into(),
        ));
    }
    Ok(())
}

fn digest_stage1(proof: &Stage1ShoutProof) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/semantic_evidence/stage1");
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage1/cycle",
        &proof.cycle_point,
    );
    tr.append_message(
        b"neo.fold.next/chip8/semantic_evidence/stage1/fetch",
        &digest_shout_channel(&proof.fetch_proof),
    );
    tr.append_message(
        b"neo.fold.next/chip8/semantic_evidence/stage1/decode",
        &digest_shout_channel(&proof.decode_proof),
    );
    tr.append_message(
        b"neo.fold.next/chip8/semantic_evidence/stage1/alu",
        &digest_shout_channel(&proof.alu_proof),
    );
    tr.append_message(
        b"neo.fold.next/chip8/semantic_evidence/stage1/eq4",
        &digest_shout_channel(&proof.eq4_proof),
    );
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage1/handoff",
        &proof.decode_handoff_values,
    );
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage1/lane",
        &proof.lane_values_at_lookup,
    );
    tr.digest32()
}

fn digest_stage2(proof: &Stage2TwistProof) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/semantic_evidence/stage2");
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage2/cycle",
        &proof.cycle_point,
    );
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage2/reg_addr",
        &proof.reg_addr_point,
    );
    tr.append_fields(
        b"neo.fold.next/chip8/semantic_evidence/stage2/reg_val",
        &proof.reg_val_at_point.as_coeffs(),
    );
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage2/ram_addr",
        &proof.ram_addr_point,
    );
    tr.append_fields(
        b"neo.fold.next/chip8/semantic_evidence/stage2/ram_val",
        &proof.ram_val_at_point.as_coeffs(),
    );
    tr.append_fields(
        b"neo.fold.next/chip8/semantic_evidence/stage2/gamma_reg",
        &proof.gamma_reg.as_coeffs(),
    );
    append_rounds(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage2/reg_rw",
        &proof.reg_rw_batched_rounds,
    );
    tr.append_fields(
        b"neo.fold.next/chip8/semantic_evidence/stage2/reg_val_inc_claim",
        &proof.reg_val_from_inc_claim.as_coeffs(),
    );
    append_rounds(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage2/reg_val_inc_rounds",
        &proof.reg_val_from_inc_rounds,
    );
    for proof in &proof.reg_addr_correctness {
        tr.append_message(
            b"neo.fold.next/chip8/semantic_evidence/stage2/reg_addr_correctness",
            &digest_address_correctness(proof),
        );
    }
    tr.append_fields(
        b"neo.fold.next/chip8/semantic_evidence/stage2/gamma_ram",
        &proof.gamma_ram.as_coeffs(),
    );
    append_rounds(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage2/ram_rw",
        &proof.ram_rw_batched_rounds,
    );
    tr.append_fields(
        b"neo.fold.next/chip8/semantic_evidence/stage2/ram_val_inc_claim",
        &proof.ram_val_from_inc_claim.as_coeffs(),
    );
    append_rounds(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage2/ram_val_inc_rounds",
        &proof.ram_val_from_inc_rounds,
    );
    tr.append_fields(
        b"neo.fold.next/chip8/semantic_evidence/stage2/ram_raf_read_claim",
        &proof.ram_raf_read_claim.as_coeffs(),
    );
    append_rounds(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage2/ram_raf_read_rounds",
        &proof.ram_raf_read_rounds,
    );
    tr.append_fields(
        b"neo.fold.next/chip8/semantic_evidence/stage2/ram_raf_write_claim",
        &proof.ram_raf_write_claim.as_coeffs(),
    );
    append_rounds(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage2/ram_raf_write_rounds",
        &proof.ram_raf_write_rounds,
    );
    for product in [
        &proof.reg_ra_y_target_proof,
        &proof.reg_wa_addr_target_proof,
        &proof.reg_write_x_target_proof,
        &proof.reg_write_i_target_proof,
        &proof.ram_read_target_proof,
        &proof.ram_write_target_proof,
        &proof.ram_write_matches_x_zero_proof,
        &proof.ram_idle_mem_zero_proof,
    ] {
        tr.append_message(
            b"neo.fold.next/chip8/semantic_evidence/stage2/cycle_product",
            &digest_cycle_product(product),
        );
    }
    for proof in &proof.ram_addr_correctness {
        tr.append_message(
            b"neo.fold.next/chip8/semantic_evidence/stage2/ram_addr_correctness",
            &digest_address_correctness(proof),
        );
    }
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage2/link_claims",
        &[
            proof.link_claims.rv_x,
            proof.link_claims.rv_y,
            proof.link_claims.rv_i,
            proof.link_claims.wv_reg,
            proof.link_claims.rv_ram,
            proof.link_claims.wv_ram,
        ],
    );
    tr.append_fields(
        b"neo.fold.next/chip8/semantic_evidence/stage2/gamma_link",
        &proof.gamma_twist_link.as_coeffs(),
    );
    tr.append_fields(
        b"neo.fold.next/chip8/semantic_evidence/stage2/linkage_batch",
        &proof.linkage_batch_value.as_coeffs(),
    );
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage2/lane",
        &proof.lane_values_at_twist,
    );
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage2/handoff",
        &proof.handoff_values_at_twist,
    );
    tr.digest32()
}

fn digest_stage3(proof: &Stage3Proof) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/semantic_evidence/stage3");
    tr.append_message(
        b"neo.fold.next/chip8/semantic_evidence/stage3/shift",
        &digest_lane_shift(&proof.shift_proof),
    );
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage3/shift_opening",
        &proof.shift_opening_values,
    );
    tr.append_fields(
        b"neo.fold.next/chip8/semantic_evidence/stage3/continuity",
        &proof.continuity_check_value.as_coeffs(),
    );
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage3/start",
        &proof.start_boundary_values,
    );
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/stage3/final",
        &proof.final_boundary_values,
    );
    for row_binding in &proof.row_bindings {
        tr.append_message(
            b"neo.fold.next/chip8/semantic_evidence/stage3/row_binding",
            &digest_row_binding(row_binding),
        );
    }
    tr.digest32()
}

fn digest_shout_channel(proof: &ShoutChannelProof) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/semantic_evidence/shout_channel");
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/shout_channel/addr",
        &proof.addr_point,
    );
    append_rounds(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/shout_channel/sumcheck",
        &proof.sumcheck_rounds,
    );
    append_rounds(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/shout_channel/addr_correctness",
        &proof.addr_correctness_rounds,
    );
    tr.append_fields(
        b"neo.fold.next/chip8/semantic_evidence/shout_channel/address_opening",
        &proof.address_opening_value.as_coeffs(),
    );
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/shout_channel/read_values",
        &proof.read_values_at_cycle,
    );
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/shout_channel/table_values",
        &proof.table_opening_values,
    );
    tr.digest32()
}

fn digest_address_correctness(proof: &AddressCorrectnessProof) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/semantic_evidence/address_correctness");
    append_rounds(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/address_correctness/booleanity",
        &proof.booleanity_rounds,
    );
    append_rounds(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/address_correctness/hamming",
        &proof.hamming_weight_rounds,
    );
    append_rounds(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/address_correctness/decode",
        &proof.decode_consistency_rounds,
    );
    append_rounds(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/address_correctness/raw",
        &proof.raw_address_rounds,
    );
    tr.digest32()
}

fn digest_cycle_product(proof: &CycleProductProof) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/semantic_evidence/cycle_product");
    tr.append_fields(
        b"neo.fold.next/chip8/semantic_evidence/cycle_product/claim",
        &proof.claim.as_coeffs(),
    );
    append_rounds(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/cycle_product/rounds",
        &proof.rounds,
    );
    tr.digest32()
}

fn digest_lane_shift(proof: &LaneShiftProof) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/semantic_evidence/lane_shift");
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/lane_shift/source",
        &proof.source_point,
    );
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/lane_shift/claimed",
        &proof.claimed_shift_values,
    );
    append_rounds(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/lane_shift/reduction",
        &proof.reduction_rounds,
    );
    tr.digest32()
}

fn digest_row_binding(claim: &RowBindingClaim) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/semantic_evidence/row_binding");
    tr.append_u64s(
        b"neo.fold.next/chip8/semantic_evidence/row_binding/meta",
        &[
            claim.row_index as u64,
            claim.row_bits.len() as u64,
            claim.opened_values.len() as u64,
        ],
    );
    let row_bits: Vec<u64> = claim.row_bits.iter().map(|&bit| bit as u64).collect();
    tr.append_u64s(b"neo.fold.next/chip8/semantic_evidence/row_binding/row_bits", &row_bits);
    append_k_vec(
        &mut tr,
        b"neo.fold.next/chip8/semantic_evidence/row_binding/opened",
        &claim.opened_values,
    );
    tr.digest32()
}

fn digest_time_opening_summary(summary: &TimeOpeningProofSummary) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/semantic_evidence/time_opening");
    tr.append_message(
        b"neo.fold.next/chip8/semantic_evidence/time_opening/manifest",
        &summary.manifest_digest,
    );
    tr.append_message(
        b"neo.fold.next/chip8/semantic_evidence/time_opening/proof",
        &summary.proof_digest,
    );
    tr.append_message(
        b"neo.fold.next/chip8/semantic_evidence/time_opening/unified",
        &summary.unified_digest,
    );
    tr.digest32()
}

fn digest_joint_opening_summary(summary: &KernelJointOpeningSummary) -> [u8; 32] {
    summary.digest
}

fn digest_joint_opening_fold_bucket_proof(proof: &KernelJointOpeningFoldBucketProof) -> [u8; 32] {
    proof.digest
}

fn append_k_vec(tr: &mut Poseidon2Transcript, label: &'static [u8], values: &[K]) {
    tr.append_u64s(b"neo.fold.next/chip8/semantic_evidence/k_len", &[values.len() as u64]);
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

fn append_rounds(tr: &mut Poseidon2Transcript, label: &'static [u8], rounds: &[Vec<K>]) {
    tr.append_u64s(
        b"neo.fold.next/chip8/semantic_evidence/round_count",
        &[rounds.len() as u64],
    );
    for round in rounds {
        append_k_vec(tr, label, round);
    }
}

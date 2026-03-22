//! Owns the CHIP-8 evidence boundary: Stage 3 digest surfaces, semantic evidence summaries, and the grouped execution digest.

use neo_math::{from_complex, KExtensions, F, K};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use crate::chip8::spec::{Chip8Program, CHIP8_PROGRAM_START, COL_BURST_LAST, COL_IS_MEMOP, COL_PC_NEXT, COL_X_IDX};
use crate::chip8::tables::{build_alu_table, build_decode_table, build_eq4_table, build_rom_table};
use crate::chip8::{stage1, stage2};
use crate::proof::StepInput;

use super::artifacts::build_prepared_steps_from_frames;
use super::bridge::prepared_step_digest;
use super::public_meta::{absorb_root0, new_simple_kernel_transcript};
use super::{
    build_kernel_exact_frames, CommitmentId, KernelExactFrame, RowBindingClaim, SimpleKernelError, SimpleKernelOutput,
    SimpleKernelProof, SimpleKernelPublicInput,
};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum KernelStage3LaneColumn {
    Pc,
    XIdx,
    IsMemOp,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum KernelStage3ShiftedColumn {
    ShiftPc,
    ShiftXIdx,
    ShiftIsMemOp,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStage3ShiftClaim {
    pub source_commitment: CommitmentId,
    pub source_point: Vec<K>,
    pub source_columns: [KernelStage3LaneColumn; 3],
    pub shifted_columns: [KernelStage3ShiftedColumn; 3],
    pub claimed_shift_values: [K; 3],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStage3ShiftWitness {
    pub shift_pc: K,
    pub shift_x_idx: K,
    pub shift_is_memop: K,
    pub reduction_rounds: Vec<Vec<K>>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStage3CurrentRow {
    pub row_index: usize,
    pub pair_mask: F,
    pub pc_next: F,
    pub x_idx: F,
    pub is_memop: F,
    pub burst_last: F,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStage3RowClaim {
    pub row_index: usize,
    pub row_bits: Vec<bool>,
    pub opened_values: Vec<K>,
}

#[derive(Clone, Debug)]
pub struct KernelStage3DigestSurface {
    pub step_idx: usize,
    pub n: usize,
    pub beta1: K,
    pub beta2: K,
    pub shift_claim: KernelStage3ShiftClaim,
    pub shift_proof: KernelStage3ShiftWitness,
    pub current_row: KernelStage3CurrentRow,
    pub row_claim: KernelStage3RowClaim,
    pub prepared_step: StepInput,
}

impl PartialEq for KernelStage3DigestSurface {
    fn eq(&self, other: &Self) -> bool {
        self.step_idx == other.step_idx
            && self.n == other.n
            && self.beta1 == other.beta1
            && self.beta2 == other.beta2
            && self.shift_claim == other.shift_claim
            && self.shift_proof == other.shift_proof
            && self.current_row == other.current_row
            && self.row_claim == other.row_claim
            && prepared_step_digest(&self.prepared_step) == prepared_step_digest(&other.prepared_step)
    }
}

pub fn build_kernel_stage3_digest_surfaces(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
) -> Result<Vec<KernelStage3DigestSurface>, SimpleKernelError> {
    let frames = build_kernel_exact_frames(public, proof)?;
    build_kernel_stage3_digest_surfaces_from_frames(public, proof, output, &frames)
}

pub(crate) fn build_kernel_stage3_digest_surfaces_from_frames(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
    frames: &[KernelExactFrame],
) -> Result<Vec<KernelStage3DigestSurface>, SimpleKernelError> {
    let prepared_steps = build_prepared_steps_from_frames(&frames)?;
    assert_stage3_prepared_steps_match_output(&prepared_steps, &output.prepared_steps)?;
    let (beta1, beta2, expected_shift_point) = replay_stage3_challenges(public, proof)?;
    if proof.stage3.shift_proof.source_point != expected_shift_point {
        return Err(SimpleKernelError::ContinuityFailed(
            "stage3 digest shift point does not match canonical transcript replay".into(),
        ));
    }
    if proof.stage3.row_bindings.len() != frames.len() {
        return Err(SimpleKernelError::ContinuityFailed(format!(
            "stage3 digest row-binding count {} != frame count {}",
            proof.stage3.row_bindings.len(),
            frames.len()
        )));
    }

    let n = proof.meta_pub.semantic_rows;
    let shift_claim = build_shift_claim(proof);
    let shift_proof = build_shift_witness(proof);
    frames
        .iter()
        .zip(proof.stage3.row_bindings.iter())
        .zip(prepared_steps.into_iter())
        .map(|((frame, row_claim), prepared_step)| {
            build_stage3_digest_surface(
                frame,
                n,
                beta1,
                beta2,
                &shift_claim,
                &shift_proof,
                row_claim,
                prepared_step,
            )
        })
        .collect()
}

pub fn verify_kernel_stage3_digest_surfaces(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
    surfaces: &[KernelStage3DigestSurface],
) -> Result<(), String> {
    let expected = build_kernel_stage3_digest_surfaces(public, proof, output)
        .map_err(|err| format!("stage3 digest build failed: {err}"))?;
    if surfaces != expected.as_slice() {
        return Err("stage3 digest surface mismatch".into());
    }
    Ok(())
}

fn build_stage3_digest_surface(
    frame: &KernelExactFrame,
    n: usize,
    beta1: K,
    beta2: K,
    shift_claim: &KernelStage3ShiftClaim,
    shift_proof: &KernelStage3ShiftWitness,
    row_claim: &RowBindingClaim,
    prepared_step: StepInput,
) -> Result<KernelStage3DigestSurface, SimpleKernelError> {
    if row_claim.row_index != frame.step_idx {
        return Err(SimpleKernelError::ContinuityFailed(format!(
            "stage3 digest row claim index {} != frame step {}",
            row_claim.row_index, frame.step_idx
        )));
    }
    Ok(KernelStage3DigestSurface {
        step_idx: frame.step_idx,
        n,
        beta1,
        beta2,
        shift_claim: shift_claim.clone(),
        shift_proof: shift_proof.clone(),
        current_row: KernelStage3CurrentRow {
            row_index: frame.step_idx,
            pair_mask: pair_mask(n, frame.step_idx),
            pc_next: frame.row[COL_PC_NEXT],
            x_idx: frame.row[COL_X_IDX],
            is_memop: frame.row[COL_IS_MEMOP],
            burst_last: frame.row[COL_BURST_LAST],
        },
        row_claim: KernelStage3RowClaim {
            row_index: row_claim.row_index,
            row_bits: row_claim.row_bits.clone(),
            opened_values: row_claim.opened_values.clone(),
        },
        prepared_step,
    })
}

fn build_shift_claim(proof: &SimpleKernelProof) -> KernelStage3ShiftClaim {
    KernelStage3ShiftClaim {
        source_commitment: CommitmentId::Lane,
        source_point: proof.stage3.shift_proof.source_point.clone(),
        source_columns: [
            KernelStage3LaneColumn::Pc,
            KernelStage3LaneColumn::XIdx,
            KernelStage3LaneColumn::IsMemOp,
        ],
        shifted_columns: [
            KernelStage3ShiftedColumn::ShiftPc,
            KernelStage3ShiftedColumn::ShiftXIdx,
            KernelStage3ShiftedColumn::ShiftIsMemOp,
        ],
        claimed_shift_values: proof.stage3.shift_proof.claimed_shift_values,
    }
}

fn build_shift_witness(proof: &SimpleKernelProof) -> KernelStage3ShiftWitness {
    KernelStage3ShiftWitness {
        shift_pc: proof.stage3.shift_proof.claimed_shift_values[0],
        shift_x_idx: proof.stage3.shift_proof.claimed_shift_values[1],
        shift_is_memop: proof.stage3.shift_proof.claimed_shift_values[2],
        reduction_rounds: proof.stage3.shift_proof.reduction_rounds.clone(),
    }
}

fn replay_stage3_challenges(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
) -> Result<(K, K, Vec<K>), SimpleKernelError> {
    let program = Chip8Program {
        bytes: public.program_image.clone(),
        start_pc: CHIP8_PROGRAM_START,
    };
    let rom_table = build_rom_table(&program, proof.meta_pub.pad_pc_word);
    let decode_table = build_decode_table();
    let alu_table = build_alu_table();
    let eq4_table = build_eq4_table();

    let mut transcript = new_simple_kernel_transcript(&public.transcript_seed);
    absorb_root0(&mut transcript, &proof.commitments, &proof.meta_pub);
    stage1::verify_stage1(
        &proof.stage1,
        &rom_table,
        &decode_table,
        &alu_table,
        &eq4_table,
        proof.meta_pub.cycle_bits,
        None,
        &mut transcript,
    )
    .map_err(SimpleKernelError::ContinuityFailed)?;
    stage2::verify_stage2(
        &proof.stage2,
        &public.initial_registers,
        public.initial_i,
        &public.initial_ram,
        proof.meta_pub.cycle_bits,
        &mut transcript,
    )?;
    let beta1 = squeeze_k(&mut transcript, b"stage3/beta1");
    let beta2 = squeeze_k(&mut transcript, b"stage3/beta2");
    let shift_point = squeeze_point(&mut transcript, b"stage3/r_shift", proof.meta_pub.cycle_bits);
    Ok((beta1, beta2, shift_point))
}

fn pair_mask(n: usize, row_index: usize) -> F {
    if row_index + 1 < n {
        F::ONE
    } else {
        F::ZERO
    }
}

fn assert_stage3_prepared_steps_match_output(
    expected: &[StepInput],
    actual: &[StepInput],
) -> Result<(), SimpleKernelError> {
    if expected.len() != actual.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "stage3 digest prepared-step count {} != output {}",
            expected.len(),
            actual.len()
        )));
    }
    for (step_idx, (expected_step, actual_step)) in expected.iter().zip(actual.iter()).enumerate() {
        if prepared_step_digest(expected_step) != prepared_step_digest(actual_step) {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "stage3 digest prepared step {} mismatches output",
                step_idx
            )));
        }
    }
    Ok(())
}

fn squeeze_k<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}

fn squeeze_point<Tr: Transcript>(tr: &mut Tr, label: &'static [u8], n: usize) -> Vec<K> {
    (0..n).map(|_| squeeze_k(tr, label)).collect()
}

use crate::proof::TimeOpeningProofSummary;

use super::{
    AddressCorrectnessProof, CycleProductProof, KernelJointOpeningFoldBucketProof, KernelJointOpeningSummary,
    KernelOpeningManifest, KernelOpeningRefinementSummary, RootOpeningManifest, ShoutChannelProof, Stage1ShoutProof,
    Stage2TwistProof, Stage3Proof,
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

use super::opening_commitment_id_key;
use super::soundness_accounting::{build_kernel_error_surface, KernelErrorSurface};
use super::transcript::{build_kernel_transcript_surface, root0_commitment_ids, KernelTranscriptSurface};

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

fn build_kernel_trace_surface(frames: &[KernelExactFrame], proof: &SimpleKernelProof) -> KernelTraceSurface {
    KernelTraceSurface {
        frames: frames.to_vec(),
        stage1_digest: proof.semantic_evidence_summary.stage1_digest,
        stage2_digest: proof.semantic_evidence_summary.stage2_digest,
        stage3_digest: proof.semantic_evidence_summary.stage3_digest,
        semantic_evidence_summary_digest: proof.semantic_evidence_summary.digest,
    }
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

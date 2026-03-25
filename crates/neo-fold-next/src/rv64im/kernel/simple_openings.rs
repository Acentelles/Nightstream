//! Owns compact selected-opening and kernel-opening claim surfaces for the RV64IM simple kernel.

use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};

use crate::proof::PackagedProof;

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub enum OpeningPointLabel {
    Stage1First,
    Stage1Effect,
    Stage1Commit,
    Stage1Last,
    Stage2FirstRead,
    Stage2LastRead,
    Stage2FirstWrite,
    Stage2LastWrite,
    Stage2FirstRam,
    Stage2LastRam,
    Stage2FirstTwist,
    Stage2LastTwist,
    Stage3FirstContinuity,
    Stage3LastContinuity,
    KernelFirstBinding,
    KernelLastBinding,
    KernelFirstPreparedStep,
    KernelLastPreparedStep,
}

impl OpeningPointLabel {
    pub(crate) fn as_str(self) -> &'static str {
        match self {
            Self::Stage1First => "stage1_first",
            Self::Stage1Effect => "stage1_effect",
            Self::Stage1Commit => "stage1_commit",
            Self::Stage1Last => "stage1_last",
            Self::Stage2FirstRead => "stage2_first_read",
            Self::Stage2LastRead => "stage2_last_read",
            Self::Stage2FirstWrite => "stage2_first_write",
            Self::Stage2LastWrite => "stage2_last_write",
            Self::Stage2FirstRam => "stage2_first_ram",
            Self::Stage2LastRam => "stage2_last_ram",
            Self::Stage2FirstTwist => "stage2_first_twist",
            Self::Stage2LastTwist => "stage2_last_twist",
            Self::Stage3FirstContinuity => "stage3_first_continuity",
            Self::Stage3LastContinuity => "stage3_last_continuity",
            Self::KernelFirstBinding => "kernel_first_binding",
            Self::KernelLastBinding => "kernel_last_binding",
            Self::KernelFirstPreparedStep => "kernel_first_prepared_step",
            Self::KernelLastPreparedStep => "kernel_last_prepared_step",
        }
    }

    pub(crate) fn tag(self) -> u64 {
        match self {
            Self::Stage1First => 0,
            Self::Stage1Effect => 1,
            Self::Stage1Commit => 2,
            Self::Stage1Last => 3,
            Self::Stage2FirstRead => 4,
            Self::Stage2LastRead => 5,
            Self::Stage2FirstWrite => 6,
            Self::Stage2LastWrite => 7,
            Self::Stage2FirstRam => 8,
            Self::Stage2LastRam => 9,
            Self::Stage2FirstTwist => 10,
            Self::Stage2LastTwist => 11,
            Self::Stage3FirstContinuity => 12,
            Self::Stage3LastContinuity => 13,
            Self::KernelFirstBinding => 14,
            Self::KernelLastBinding => 15,
            Self::KernelFirstPreparedStep => 16,
            Self::KernelLastPreparedStep => 17,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct DigestPoint {
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage1OpeningPoints {
    pub first: DigestPoint,
    pub effect: DigestPoint,
    pub commit: DigestPoint,
    pub last: DigestPoint,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage2OpeningPoints {
    pub first_read: DigestPoint,
    pub last_read: DigestPoint,
    pub first_write: DigestPoint,
    pub last_write: DigestPoint,
    pub first_ram: DigestPoint,
    pub last_ram: DigestPoint,
    pub first_twist: DigestPoint,
    pub last_twist: DigestPoint,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage3OpeningPoints {
    pub first_continuity: DigestPoint,
    pub last_continuity: DigestPoint,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage1SelectedOpeningClaim {
    pub source_commitment_digest: [u8; 32],
    pub source_opening_manifest_digest: [u8; 32],
    pub source_opening_proof_digest: [u8; 32],
    pub row_count: u64,
    pub effect_row_count: u64,
    pub commit_row_count: u64,
    pub real_row_count: u64,
    pub preserves_x0_count: u64,
    pub first_trace_index: u64,
    pub effect_trace_index: u64,
    pub commit_trace_index: u64,
    pub last_trace_index: u64,
    pub mix: u64,
    pub points: Stage1OpeningPoints,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage2SelectedOpeningClaim {
    pub source_commitment_digest: [u8; 32],
    pub source_opening_manifest_digest: [u8; 32],
    pub source_opening_proof_digest: [u8; 32],
    pub register_read_count: u64,
    pub register_write_count: u64,
    pub ram_event_count: u64,
    pub twist_link_count: u64,
    pub ram_read_count: u64,
    pub ram_write_count: u64,
    pub reg_mix: u64,
    pub ram_mix: u64,
    pub points: Stage2OpeningPoints,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage3SelectedOpeningClaim {
    pub source_commitment_digest: [u8; 32],
    pub source_opening_manifest_digest: [u8; 32],
    pub source_opening_proof_digest: [u8; 32],
    pub continuity_count: u64,
    pub final_step_count: u64,
    pub halted: bool,
    pub all_continuity_hold: bool,
    pub continuity_mix: u64,
    pub points: Stage3OpeningPoints,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Stage1PackagedOpeningProof {
    pub claim: Stage1SelectedOpeningClaim,
    pub packaged: PackagedProof,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Stage2PackagedOpeningProof {
    pub claim: Stage2SelectedOpeningClaim,
    pub packaged: PackagedProof,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Stage3PackagedOpeningProof {
    pub claim: Stage3SelectedOpeningClaim,
    pub packaged: PackagedProof,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct SimpleKernelStagePackageBundle {
    pub stage1: Stage1PackagedOpeningProof,
    pub stage2: Stage2PackagedOpeningProof,
    pub stage3: Stage3PackagedOpeningProof,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct KernelBindingOpeningPoints {
    pub first_binding: DigestPoint,
    pub last_binding: DigestPoint,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct KernelPreparedStepOpeningPoints {
    pub first_prepared_step: DigestPoint,
    pub last_prepared_step: DigestPoint,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct KernelBindingOpeningClaim {
    pub stage_claim_bundle_digest: [u8; 32],
    pub stage_package_bundle_digest: [u8; 32],
    pub stage1_package_digest: [u8; 32],
    pub stage2_package_digest: [u8; 32],
    pub stage3_package_digest: [u8; 32],
    pub prepared_step_bindings_digest: [u8; 32],
    pub binding_count: u64,
    pub stage1_row_count: u64,
    pub stage2_register_read_count: u64,
    pub stage2_register_write_count: u64,
    pub stage2_ram_event_count: u64,
    pub stage3_continuity_count: u64,
    pub points: KernelBindingOpeningPoints,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct KernelPreparedStepOpeningClaim {
    pub execution_digest: [u8; 32],
    pub final_state_digest: [u8; 32],
    pub transcript_final_digest: [u8; 32],
    pub prepared_step_count: u64,
    pub final_pc: u64,
    pub halted: bool,
    pub points: KernelPreparedStepOpeningPoints,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct SimpleKernelOpeningClaim {
    pub bindings: KernelBindingOpeningClaim,
    pub prepared_steps: KernelPreparedStepOpeningClaim,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct KernelBindingPackagedOpeningProof {
    pub claim: KernelBindingOpeningClaim,
    pub packaged: PackagedProof,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct KernelPreparedStepPackagedOpeningProof {
    pub claim: KernelPreparedStepOpeningClaim,
    pub packaged: PackagedProof,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct SimpleKernelOpeningBundle {
    pub claim: SimpleKernelOpeningClaim,
    pub bindings: KernelBindingPackagedOpeningProof,
    pub prepared_steps: KernelPreparedStepPackagedOpeningProof,
    pub digest: [u8; 32],
}

fn digest_to_words(digest: [u8; 32]) -> [u64; 4] {
    let mut words = [0u64; 4];
    for (dst, chunk) in words.iter_mut().zip(digest.chunks_exact(8)) {
        let mut bytes = [0u8; 8];
        bytes.copy_from_slice(chunk);
        *dst = u64::from_le_bytes(bytes);
    }
    words
}

fn append_labeled_point(
    tr: &mut Poseidon2Transcript,
    tag_label: &'static [u8],
    point_label: &'static [u8],
    digest_label: &'static [u8],
    label: OpeningPointLabel,
    digest: [u8; 32],
) {
    tr.append_u64s(tag_label, &[label.tag()]);
    tr.append_message(point_label, label.as_str().as_bytes());
    tr.append_message(digest_label, &digest);
}

impl Stage1OpeningPoints {
    pub fn labels(&self) -> Vec<OpeningPointLabel> {
        vec![
            OpeningPointLabel::Stage1First,
            OpeningPointLabel::Stage1Effect,
            OpeningPointLabel::Stage1Commit,
            OpeningPointLabel::Stage1Last,
        ]
    }

    pub fn first_digest_mut(&mut self) -> &mut [u8; 32] {
        &mut self.first.digest
    }

    fn append_digest_material(&self, tr: &mut Poseidon2Transcript) {
        tr.append_u64s(b"rv64im/stage_opening_points/variant", &[0]);
        append_labeled_point(
            tr,
            b"rv64im/stage_opening_points/tag",
            b"rv64im/stage_opening_points/label",
            b"rv64im/stage_opening_points/digest",
            OpeningPointLabel::Stage1First,
            self.first.digest,
        );
        append_labeled_point(
            tr,
            b"rv64im/stage_opening_points/tag",
            b"rv64im/stage_opening_points/label",
            b"rv64im/stage_opening_points/digest",
            OpeningPointLabel::Stage1Effect,
            self.effect.digest,
        );
        append_labeled_point(
            tr,
            b"rv64im/stage_opening_points/tag",
            b"rv64im/stage_opening_points/label",
            b"rv64im/stage_opening_points/digest",
            OpeningPointLabel::Stage1Commit,
            self.commit.digest,
        );
        append_labeled_point(
            tr,
            b"rv64im/stage_opening_points/tag",
            b"rv64im/stage_opening_points/label",
            b"rv64im/stage_opening_points/digest",
            OpeningPointLabel::Stage1Last,
            self.last.digest,
        );
    }

    fn append_word_material(&self, out: &mut Vec<u64>) {
        out.push(0);
        out.extend(digest_to_words(self.first.digest));
        out.extend(digest_to_words(self.effect.digest));
        out.extend(digest_to_words(self.commit.digest));
        out.extend(digest_to_words(self.last.digest));
    }
}

impl Stage2OpeningPoints {
    pub fn labels(&self) -> Vec<OpeningPointLabel> {
        vec![
            OpeningPointLabel::Stage2FirstRead,
            OpeningPointLabel::Stage2LastRead,
            OpeningPointLabel::Stage2FirstWrite,
            OpeningPointLabel::Stage2LastWrite,
            OpeningPointLabel::Stage2FirstRam,
            OpeningPointLabel::Stage2LastRam,
            OpeningPointLabel::Stage2FirstTwist,
            OpeningPointLabel::Stage2LastTwist,
        ]
    }

    pub fn first_digest_mut(&mut self) -> &mut [u8; 32] {
        &mut self.first_read.digest
    }

    fn append_digest_material(&self, tr: &mut Poseidon2Transcript) {
        tr.append_u64s(b"rv64im/stage_opening_points/variant", &[1]);
        append_labeled_point(
            tr,
            b"rv64im/stage_opening_points/tag",
            b"rv64im/stage_opening_points/label",
            b"rv64im/stage_opening_points/digest",
            OpeningPointLabel::Stage2FirstRead,
            self.first_read.digest,
        );
        append_labeled_point(
            tr,
            b"rv64im/stage_opening_points/tag",
            b"rv64im/stage_opening_points/label",
            b"rv64im/stage_opening_points/digest",
            OpeningPointLabel::Stage2LastRead,
            self.last_read.digest,
        );
        append_labeled_point(
            tr,
            b"rv64im/stage_opening_points/tag",
            b"rv64im/stage_opening_points/label",
            b"rv64im/stage_opening_points/digest",
            OpeningPointLabel::Stage2FirstWrite,
            self.first_write.digest,
        );
        append_labeled_point(
            tr,
            b"rv64im/stage_opening_points/tag",
            b"rv64im/stage_opening_points/label",
            b"rv64im/stage_opening_points/digest",
            OpeningPointLabel::Stage2LastWrite,
            self.last_write.digest,
        );
        append_labeled_point(
            tr,
            b"rv64im/stage_opening_points/tag",
            b"rv64im/stage_opening_points/label",
            b"rv64im/stage_opening_points/digest",
            OpeningPointLabel::Stage2FirstRam,
            self.first_ram.digest,
        );
        append_labeled_point(
            tr,
            b"rv64im/stage_opening_points/tag",
            b"rv64im/stage_opening_points/label",
            b"rv64im/stage_opening_points/digest",
            OpeningPointLabel::Stage2LastRam,
            self.last_ram.digest,
        );
        append_labeled_point(
            tr,
            b"rv64im/stage_opening_points/tag",
            b"rv64im/stage_opening_points/label",
            b"rv64im/stage_opening_points/digest",
            OpeningPointLabel::Stage2FirstTwist,
            self.first_twist.digest,
        );
        append_labeled_point(
            tr,
            b"rv64im/stage_opening_points/tag",
            b"rv64im/stage_opening_points/label",
            b"rv64im/stage_opening_points/digest",
            OpeningPointLabel::Stage2LastTwist,
            self.last_twist.digest,
        );
    }

    fn append_word_material(&self, out: &mut Vec<u64>) {
        out.push(1);
        out.extend(digest_to_words(self.first_read.digest));
        out.extend(digest_to_words(self.last_read.digest));
        out.extend(digest_to_words(self.first_write.digest));
        out.extend(digest_to_words(self.last_write.digest));
        out.extend(digest_to_words(self.first_ram.digest));
        out.extend(digest_to_words(self.last_ram.digest));
        out.extend(digest_to_words(self.first_twist.digest));
        out.extend(digest_to_words(self.last_twist.digest));
    }
}

impl Stage3OpeningPoints {
    pub fn labels(&self) -> Vec<OpeningPointLabel> {
        vec![
            OpeningPointLabel::Stage3FirstContinuity,
            OpeningPointLabel::Stage3LastContinuity,
        ]
    }

    pub fn first_digest_mut(&mut self) -> &mut [u8; 32] {
        &mut self.first_continuity.digest
    }

    fn append_digest_material(&self, tr: &mut Poseidon2Transcript) {
        tr.append_u64s(b"rv64im/stage_opening_points/variant", &[2]);
        append_labeled_point(
            tr,
            b"rv64im/stage_opening_points/tag",
            b"rv64im/stage_opening_points/label",
            b"rv64im/stage_opening_points/digest",
            OpeningPointLabel::Stage3FirstContinuity,
            self.first_continuity.digest,
        );
        append_labeled_point(
            tr,
            b"rv64im/stage_opening_points/tag",
            b"rv64im/stage_opening_points/label",
            b"rv64im/stage_opening_points/digest",
            OpeningPointLabel::Stage3LastContinuity,
            self.last_continuity.digest,
        );
    }

    fn append_word_material(&self, out: &mut Vec<u64>) {
        out.push(2);
        out.extend(digest_to_words(self.first_continuity.digest));
        out.extend(digest_to_words(self.last_continuity.digest));
    }
}

impl KernelBindingOpeningPoints {
    pub fn labels(&self) -> Vec<OpeningPointLabel> {
        vec![
            OpeningPointLabel::KernelFirstBinding,
            OpeningPointLabel::KernelLastBinding,
        ]
    }

    pub fn first_digest_mut(&mut self) -> &mut [u8; 32] {
        &mut self.first_binding.digest
    }

    fn append_digest_material(&self, tr: &mut Poseidon2Transcript) {
        tr.append_u64s(b"rv64im/kernel_binding_opening_points/variant", &[0]);
        append_labeled_point(
            tr,
            b"rv64im/kernel_binding_opening_points/tag",
            b"rv64im/kernel_binding_opening_points/label",
            b"rv64im/kernel_binding_opening_points/digest",
            OpeningPointLabel::KernelFirstBinding,
            self.first_binding.digest,
        );
        append_labeled_point(
            tr,
            b"rv64im/kernel_binding_opening_points/tag",
            b"rv64im/kernel_binding_opening_points/label",
            b"rv64im/kernel_binding_opening_points/digest",
            OpeningPointLabel::KernelLastBinding,
            self.last_binding.digest,
        );
    }

    fn append_word_material(&self, out: &mut Vec<u64>) {
        out.push(0);
        out.extend(digest_to_words(self.first_binding.digest));
        out.extend(digest_to_words(self.last_binding.digest));
    }
}

impl KernelPreparedStepOpeningPoints {
    pub fn labels(&self) -> Vec<OpeningPointLabel> {
        vec![
            OpeningPointLabel::KernelFirstPreparedStep,
            OpeningPointLabel::KernelLastPreparedStep,
        ]
    }

    pub fn first_digest_mut(&mut self) -> &mut [u8; 32] {
        &mut self.first_prepared_step.digest
    }

    fn append_digest_material(&self, tr: &mut Poseidon2Transcript) {
        tr.append_u64s(b"rv64im/kernel_prepared_step_opening_points/variant", &[1]);
        append_labeled_point(
            tr,
            b"rv64im/kernel_prepared_step_opening_points/tag",
            b"rv64im/kernel_prepared_step_opening_points/label",
            b"rv64im/kernel_prepared_step_opening_points/digest",
            OpeningPointLabel::KernelFirstPreparedStep,
            self.first_prepared_step.digest,
        );
        append_labeled_point(
            tr,
            b"rv64im/kernel_prepared_step_opening_points/tag",
            b"rv64im/kernel_prepared_step_opening_points/label",
            b"rv64im/kernel_prepared_step_opening_points/digest",
            OpeningPointLabel::KernelLastPreparedStep,
            self.last_prepared_step.digest,
        );
    }

    fn append_word_material(&self, out: &mut Vec<u64>) {
        out.push(1);
        out.extend(digest_to_words(self.first_prepared_step.digest));
        out.extend(digest_to_words(self.last_prepared_step.digest));
    }
}

impl Stage1SelectedOpeningClaim {
    pub fn digest(&self) -> [u8; 32] {
        self.digest
    }

    pub fn labels(&self) -> Vec<OpeningPointLabel> {
        self.points.labels()
    }

    pub fn first_digest_mut(&mut self) -> &mut [u8; 32] {
        self.points.first_digest_mut()
    }

    pub(crate) fn claim_words(&self) -> Vec<u64> {
        let mut out = Vec::with_capacity(12 + 10 + 17);
        out.extend(digest_to_words(self.source_commitment_digest));
        out.extend(digest_to_words(self.source_opening_manifest_digest));
        out.extend(digest_to_words(self.source_opening_proof_digest));
        out.extend([
            self.row_count,
            self.effect_row_count,
            self.commit_row_count,
            self.real_row_count,
            self.preserves_x0_count,
            self.first_trace_index,
            self.effect_trace_index,
            self.commit_trace_index,
            self.last_trace_index,
            self.mix,
        ]);
        self.points.append_word_material(&mut out);
        out
    }

    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_selected_opening_claim");
        tr.append_message(b"rv64im/stage_selected_opening_claim/label", b"rv64im/stage1");
        tr.append_message(
            b"rv64im/stage_selected_opening_claim/source_commitment",
            &self.source_commitment_digest,
        );
        tr.append_message(
            b"rv64im/stage_selected_opening_claim/source_manifest",
            &self.source_opening_manifest_digest,
        );
        tr.append_message(
            b"rv64im/stage_selected_opening_claim/source_opening_proof",
            &self.source_opening_proof_digest,
        );
        tr.append_u64s(
            b"rv64im/stage_selected_opening_claim/meta_words",
            &[
                self.row_count,
                self.effect_row_count,
                self.commit_row_count,
                self.real_row_count,
                self.preserves_x0_count,
                self.first_trace_index,
                self.effect_trace_index,
                self.commit_trace_index,
                self.last_trace_index,
                self.mix,
            ],
        );
        self.points.append_digest_material(&mut tr);
        tr.digest32()
    }
}

impl Stage2SelectedOpeningClaim {
    pub fn digest(&self) -> [u8; 32] {
        self.digest
    }

    pub fn labels(&self) -> Vec<OpeningPointLabel> {
        self.points.labels()
    }

    pub fn first_digest_mut(&mut self) -> &mut [u8; 32] {
        self.points.first_digest_mut()
    }

    pub(crate) fn claim_words(&self) -> Vec<u64> {
        let mut out = Vec::with_capacity(12 + 8 + 33);
        out.extend(digest_to_words(self.source_commitment_digest));
        out.extend(digest_to_words(self.source_opening_manifest_digest));
        out.extend(digest_to_words(self.source_opening_proof_digest));
        out.extend([
            self.register_read_count,
            self.register_write_count,
            self.ram_event_count,
            self.twist_link_count,
            self.ram_read_count,
            self.ram_write_count,
            self.reg_mix,
            self.ram_mix,
        ]);
        self.points.append_word_material(&mut out);
        out
    }

    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_selected_opening_claim");
        tr.append_message(b"rv64im/stage_selected_opening_claim/label", b"rv64im/stage2");
        tr.append_message(
            b"rv64im/stage_selected_opening_claim/source_commitment",
            &self.source_commitment_digest,
        );
        tr.append_message(
            b"rv64im/stage_selected_opening_claim/source_manifest",
            &self.source_opening_manifest_digest,
        );
        tr.append_message(
            b"rv64im/stage_selected_opening_claim/source_opening_proof",
            &self.source_opening_proof_digest,
        );
        tr.append_u64s(
            b"rv64im/stage_selected_opening_claim/meta_words",
            &[
                self.register_read_count,
                self.register_write_count,
                self.ram_event_count,
                self.twist_link_count,
                self.ram_read_count,
                self.ram_write_count,
                self.reg_mix,
                self.ram_mix,
            ],
        );
        self.points.append_digest_material(&mut tr);
        tr.digest32()
    }
}

impl Stage3SelectedOpeningClaim {
    pub fn digest(&self) -> [u8; 32] {
        self.digest
    }

    pub fn labels(&self) -> Vec<OpeningPointLabel> {
        self.points.labels()
    }

    pub fn first_digest_mut(&mut self) -> &mut [u8; 32] {
        self.points.first_digest_mut()
    }

    pub(crate) fn claim_words(&self) -> Vec<u64> {
        let mut out = Vec::with_capacity(12 + 5 + 9);
        out.extend(digest_to_words(self.source_commitment_digest));
        out.extend(digest_to_words(self.source_opening_manifest_digest));
        out.extend(digest_to_words(self.source_opening_proof_digest));
        out.extend([
            self.continuity_count,
            self.final_step_count,
            self.halted as u64,
            self.all_continuity_hold as u64,
            self.continuity_mix,
        ]);
        self.points.append_word_material(&mut out);
        out
    }

    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_selected_opening_claim");
        tr.append_message(b"rv64im/stage_selected_opening_claim/label", b"rv64im/stage3");
        tr.append_message(
            b"rv64im/stage_selected_opening_claim/source_commitment",
            &self.source_commitment_digest,
        );
        tr.append_message(
            b"rv64im/stage_selected_opening_claim/source_manifest",
            &self.source_opening_manifest_digest,
        );
        tr.append_message(
            b"rv64im/stage_selected_opening_claim/source_opening_proof",
            &self.source_opening_proof_digest,
        );
        tr.append_u64s(
            b"rv64im/stage_selected_opening_claim/meta_words",
            &[
                self.continuity_count,
                self.final_step_count,
                self.halted as u64,
                self.all_continuity_hold as u64,
                self.continuity_mix,
            ],
        );
        self.points.append_digest_material(&mut tr);
        tr.digest32()
    }
}

fn packaged_opening_proof_digest(claim_digest: [u8; 32], packaged: &PackagedProof) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_packaged_opening_claim_proof");
    tr.append_message(b"rv64im/stage_packaged_opening_claim_proof/claim_digest", &claim_digest);
    tr.append_message(
        b"rv64im/stage_packaged_opening_claim_proof/statement_digest",
        &packaged.statement.digest,
    );
    tr.append_message(
        b"rv64im/stage_packaged_opening_claim_proof/proof_digest",
        &packaged.proof.proof_digest,
    );
    tr.digest32()
}

impl Stage1PackagedOpeningProof {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        packaged_opening_proof_digest(self.claim.digest, &self.packaged)
    }
}

impl Stage2PackagedOpeningProof {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        packaged_opening_proof_digest(self.claim.digest, &self.packaged)
    }
}

impl Stage3PackagedOpeningProof {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        packaged_opening_proof_digest(self.claim.digest, &self.packaged)
    }
}

impl KernelBindingPackagedOpeningProof {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        packaged_opening_proof_digest(self.claim.digest, &self.packaged)
    }
}

impl KernelPreparedStepPackagedOpeningProof {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        packaged_opening_proof_digest(self.claim.digest, &self.packaged)
    }
}

impl SimpleKernelStagePackageBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_package_bundle");
        tr.append_message(b"rv64im/stage_package_bundle/stage1", &self.stage1.digest);
        tr.append_message(b"rv64im/stage_package_bundle/stage2", &self.stage2.digest);
        tr.append_message(b"rv64im/stage_package_bundle/stage3", &self.stage3.digest);
        tr.digest32()
    }
}

impl KernelBindingOpeningClaim {
    pub fn digest(&self) -> [u8; 32] {
        self.digest
    }

    pub fn labels(&self) -> Vec<OpeningPointLabel> {
        self.points.labels()
    }

    pub fn first_digest_mut(&mut self) -> &mut [u8; 32] {
        self.points.first_digest_mut()
    }

    pub(crate) fn claim_words(&self) -> Vec<u64> {
        let mut out = Vec::with_capacity(11 * 4 + 6 + 9);
        out.extend(digest_to_words(self.stage_claim_bundle_digest));
        out.extend(digest_to_words(self.stage_package_bundle_digest));
        out.extend(digest_to_words(self.stage1_package_digest));
        out.extend(digest_to_words(self.stage2_package_digest));
        out.extend(digest_to_words(self.stage3_package_digest));
        out.extend(digest_to_words(self.prepared_step_bindings_digest));
        out.extend([
            self.binding_count,
            self.stage1_row_count,
            self.stage2_register_read_count,
            self.stage2_register_write_count,
            self.stage2_ram_event_count,
            self.stage3_continuity_count,
        ]);
        self.points.append_word_material(&mut out);
        out
    }

    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_binding_opening_claim");
        tr.append_message(
            b"rv64im/kernel_binding_opening_claim/stage_claim_bundle",
            &self.stage_claim_bundle_digest,
        );
        tr.append_message(
            b"rv64im/kernel_binding_opening_claim/stage_package_bundle",
            &self.stage_package_bundle_digest,
        );
        tr.append_message(
            b"rv64im/kernel_binding_opening_claim/stage1_package",
            &self.stage1_package_digest,
        );
        tr.append_message(
            b"rv64im/kernel_binding_opening_claim/stage2_package",
            &self.stage2_package_digest,
        );
        tr.append_message(
            b"rv64im/kernel_binding_opening_claim/stage3_package",
            &self.stage3_package_digest,
        );
        tr.append_message(
            b"rv64im/kernel_binding_opening_claim/prepared_step_bindings",
            &self.prepared_step_bindings_digest,
        );
        tr.append_u64s(
            b"rv64im/kernel_binding_opening_claim/meta_words",
            &[
                self.binding_count,
                self.stage1_row_count,
                self.stage2_register_read_count,
                self.stage2_register_write_count,
                self.stage2_ram_event_count,
                self.stage3_continuity_count,
            ],
        );
        self.points.append_digest_material(&mut tr);
        tr.digest32()
    }
}

impl KernelPreparedStepOpeningClaim {
    pub fn digest(&self) -> [u8; 32] {
        self.digest
    }

    pub fn labels(&self) -> Vec<OpeningPointLabel> {
        self.points.labels()
    }

    pub fn first_digest_mut(&mut self) -> &mut [u8; 32] {
        self.points.first_digest_mut()
    }

    pub(crate) fn claim_words(&self) -> Vec<u64> {
        let mut out = Vec::with_capacity(6 * 4 + 3 + 9);
        out.extend(digest_to_words(self.execution_digest));
        out.extend(digest_to_words(self.final_state_digest));
        out.extend(digest_to_words(self.transcript_final_digest));
        out.extend([self.prepared_step_count, self.final_pc, self.halted as u64]);
        self.points.append_word_material(&mut out);
        out
    }

    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_prepared_step_opening_claim");
        tr.append_message(
            b"rv64im/kernel_prepared_step_opening_claim/execution_digest",
            &self.execution_digest,
        );
        tr.append_message(
            b"rv64im/kernel_prepared_step_opening_claim/final_state_digest",
            &self.final_state_digest,
        );
        tr.append_message(
            b"rv64im/kernel_prepared_step_opening_claim/transcript_final_digest",
            &self.transcript_final_digest,
        );
        tr.append_u64s(
            b"rv64im/kernel_prepared_step_opening_claim/meta_words",
            &[self.prepared_step_count, self.final_pc, self.halted as u64],
        );
        self.points.append_digest_material(&mut tr);
        tr.digest32()
    }
}

impl SimpleKernelOpeningClaim {
    pub fn digest(&self) -> [u8; 32] {
        self.digest
    }

    pub fn labels(&self) -> Vec<OpeningPointLabel> {
        let mut labels = self.bindings.labels();
        labels.extend(self.prepared_steps.labels());
        labels
    }

    pub fn first_digest_mut(&mut self) -> &mut [u8; 32] {
        self.bindings.first_digest_mut()
    }

    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_opening_claim");
        tr.append_message(
            b"rv64im/kernel_opening_claim/bindings",
            &self.bindings.expected_digest(),
        );
        tr.append_message(
            b"rv64im/kernel_opening_claim/prepared_steps",
            &self.prepared_steps.expected_digest(),
        );
        tr.digest32()
    }
}

impl SimpleKernelOpeningBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_opening_bundle");
        tr.append_message(b"rv64im/kernel_opening_bundle/claim_digest", &self.claim.digest);
        tr.append_message(b"rv64im/kernel_opening_bundle/bindings", &self.bindings.digest);
        tr.append_message(
            b"rv64im/kernel_opening_bundle/prepared_steps",
            &self.prepared_steps.digest,
        );
        tr.digest32()
    }
}

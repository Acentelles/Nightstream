//! Owns the CHIP-8 simple-kernel proof boundary and root bridge.
//! It defines the proof/output types, binds `root0`, builds the opening manifest, and reconstructs the root bridge.

mod bridge_binding;
mod execution_digest;
mod frame_artifact;
mod joint_opening;
mod joint_opening_bucket_fold;
mod joint_opening_support;
mod lane_commitment;
mod opening_boundary;
mod opening_refinement;
mod opening_transcript;
mod public_meta;
mod release_artifact;
mod root_context;
mod row_projection;
mod semantic_evidence;
mod soundness_accounting;
mod stage3_digest;
mod stage_terminal;
mod staged_execution_digest;
mod verify_support;
use super::spec::{
    build_pad_row, Chip8Program, CommitmentId, CHIP8_PROGRAM_START, COL_BURST_LAST, COL_IS_BRANCH, COL_IS_JUMP,
    COL_IS_MEMOP, COL_I_NEXT, COL_I_REG, COL_KK, COL_LOOKUP_OUTPUT, COL_MEM_VALUE, COL_NNN_ADDR, COL_NNN_WORD, COL_PC,
    COL_PC_NEXT, COL_PRESERVES_X, COL_RAM_ADDR, COL_REG_X, COL_REG_X_NEXT, COL_REG_Y, COL_WRITES_LOOKUP_TO_X,
    COL_WRITES_MEM_TO_X, COL_WRITES_NNN_TO_I, COL_X_IDX, COL_Y_IDX, WITNESS_WIDTH,
};
use super::tables::{
    build_alu_table, build_decode_table, build_eq4_table, build_rom_table, flatten_alu_key, flatten_eq4_key,
    LookupKind, RAM_SINK_ADDR, REG_SINK_ADDR,
};
use super::{stage1, stage2, stage3};
use crate::proof::TimeOpeningProofSummary;
use crate::time_opening::{prove_time_opening, verify_time_opening};
pub use bridge_binding::prepared_step_digest;
use bridge_binding::{build_kernel_bridge_binding_summary, verify_kernel_bridge_binding_summary};
pub use bridge_binding::{KernelBridgeBindingClaim, KernelBridgeBindingSummary};
pub use execution_digest::{
    build_kernel_execution_digest, verify_kernel_execution_digest, KernelAuditSurface, KernelExecutionDigest,
    KernelExportSurface, KernelManifestSurface, KernelTraceSurface, KernelTranscriptEvent, KernelTranscriptSurface,
};
pub use frame_artifact::{build_kernel_exact_frames, KernelExactFrame, KernelFrameDecodeView};
use joint_opening::{build_kernel_joint_opening_summary, verify_kernel_joint_opening_summary};
pub use joint_opening::{KernelJointOpeningGroupSummary, KernelJointOpeningSummary};
pub use joint_opening_bucket_fold::KernelJointOpeningFoldBucketProof;
use joint_opening_bucket_fold::{
    build_kernel_joint_opening_fold_bucket_proofs, verify_kernel_joint_opening_fold_bucket_proofs,
};
pub use joint_opening_support::KernelJointOpeningFoldShape;
use lane_commitment::{
    build_alu_ra_commitment_set, build_alu_ra_opening_proofs, build_alu_table_commitment_set,
    build_alu_table_opening_proofs, build_decode_handoff_commitment_set, build_decode_handoff_opening_proofs,
    build_decode_ra_commitment_set, build_decode_ra_opening_proofs, build_decode_table_commitment_set,
    build_decode_table_opening_proofs, build_eq4_ra_commitment_set, build_eq4_ra_opening_proofs,
    build_eq4_table_commitment_set, build_eq4_table_opening_proofs, build_fetch_ra_commitment_set,
    build_fetch_ra_opening_proofs, build_lane_commitment_set, build_lane_opening_proofs,
    build_ram_twist_commitment_set, build_ram_twist_opening_proofs, build_reg_twist_commitment_set,
    build_reg_twist_opening_proofs, build_rom_table_commitment_set, build_rom_table_opening_proofs,
    verify_alu_ra_commitment_artifacts, verify_alu_table_commitment_artifacts,
    verify_decode_handoff_commitment_artifacts, verify_decode_ra_commitment_artifacts,
    verify_decode_table_commitment_artifacts, verify_eq4_ra_commitment_artifacts,
    verify_eq4_table_commitment_artifacts, verify_fetch_ra_commitment_artifacts, verify_lane_commitment_artifacts,
    verify_ram_twist_commitment_artifacts, verify_reg_twist_commitment_artifacts,
    verify_rom_table_commitment_artifacts,
};
pub use lane_commitment::{
    AluRaCommitmentSet, AluRaOpeningProof, AluTableCommitmentSet, AluTableOpeningProof, DecodeHandoffCommitmentSet,
    DecodeHandoffOpeningProof, DecodeRaCommitmentSet, DecodeRaOpeningProof, DecodeTableCommitmentSet,
    DecodeTableOpeningProof, Eq4RaCommitmentSet, Eq4RaOpeningProof, Eq4TableCommitmentSet, Eq4TableOpeningProof,
    FetchRaCommitmentSet, FetchRaOpeningProof, LaneCommitmentSet, LaneOpeningProof, RamTwistCommitmentSet,
    RamTwistOpeningProof, RegTwistCommitmentSet, RegTwistOpeningProof, RomTableCommitmentSet, RomTableOpeningProof,
};
use neo_math::{KExtensions, F, K};
pub(crate) use opening_boundary::{
    as_time_opening_claim, build_kernel_opening_manifest, is_kernel_commitment_id, is_root_commitment_id,
    kernel_opening_claim_cmp, normalize_opening_pairs, normalize_polynomial_ids, opening_commitment_id_key,
    time_opening_claims,
};
pub use opening_boundary::{KernelOpeningClaim, KernelOpeningManifest, KernelOpeningSource, RootOpeningManifest};
use opening_refinement::{
    build_kernel_opening_refinement_summary, verify_kernel_opening_refinement_summary, KernelExactOpeningArtifacts,
};
pub use opening_refinement::{KernelOpeningRefinement, KernelOpeningRefinementSummary};
use opening_transcript::emit_kernel_opening_artifacts_to_transcript;
use p3_field::{PrimeCharacteristicRing, PrimeField64};
use public_meta::validate_public_input;
pub use public_meta::{absorb_root0, build_kernel_meta_pub, new_simple_kernel_transcript, KernelMetaPub};
pub use release_artifact::{
    build_kernel_external_release_artifact, build_kernel_release_artifact, verify_kernel_external_release_artifact,
    verify_kernel_release_artifact, KernelExternalReleaseArtifact, KernelReleaseArtifact, KernelRoot0CommitmentBinding,
    KernelTraceDigestSource,
};
pub use root_context::chip8_simple_root_params;
use root_context::{build_prepared_step_from_semantic_row, SimpleKernelRootContext};
use row_projection::{build_kernel_row_projection_summary, verify_kernel_row_projection_summary};
pub use row_projection::{KernelRowProjection, KernelRowProjectionSummary};
pub use semantic_evidence::KernelSemanticEvidenceSummary;
use semantic_evidence::{
    build_kernel_semantic_evidence_summary, verify_kernel_semantic_evidence_summary, KernelSemanticEvidenceInputs,
};
pub use soundness_accounting::{
    AddressFamily, KernelErrorSurface, KernelErrorTerm, Stage1ShoutChannel, TwistMemoryFamily, TwistReadFamily,
};
pub use stage3_digest::{
    build_kernel_stage3_digest_surfaces, verify_kernel_stage3_digest_surfaces, KernelStage3CurrentRow,
    KernelStage3DigestSurface, KernelStage3LaneColumn, KernelStage3RowClaim, KernelStage3ShiftClaim,
    KernelStage3ShiftWitness, KernelStage3ShiftedColumn,
};
use stage_terminal::{
    verify_kernel_stage1_sumcheck_terminals, verify_kernel_stage2_sumcheck_terminals,
    verify_kernel_stage3_sumcheck_terminal,
};
pub use staged_execution_digest::{
    build_kernel_staged_execution_digest_bundle, verify_kernel_staged_execution_digest_bundle,
    KernelDigestPublicSurface, KernelExecutionResultSurface, KernelStage1DigestSurface, KernelStage2DigestSurface,
    KernelStagedExecutionDigest, KernelStagedExecutionDigestBundle,
};
pub(crate) use verify_support::{
    assert_manifest_canonical, assert_root_manifest_canonical, authenticate_kernel_openings, batch_values,
    expect_digest32, expect_equal_k, expect_equal_k_slice, find_manifest_claim, reconstruct_trace_rows_and_aux,
    verify_stage1_channel_transcript, verify_stage2_address_correctness_transcript, verify_sumcheck_known,
};
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct SimpleKernelPublicInput {
    pub program_image: Vec<u8>,
    pub initial_pc_word: u16,
    pub initial_registers: [u8; 16],
    pub initial_i: u16,
    pub initial_ram: Vec<u8>,
    pub transcript_seed: Vec<u8>,
}

pub struct SimpleKernelWitness {
    pub semantic_trace_rows: Vec<[F; 24]>,
    pub semantic_aux_data: Vec<KernelStepAux>,
}

pub struct SimpleKernelProverInput {
    pub public: SimpleKernelPublicInput,
    pub witness: SimpleKernelWitness,
}

pub struct SimpleKernelVerifierInput {
    pub public: SimpleKernelPublicInput,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStepAux {
    pub fetch_addr: usize,
    pub decode_addr: u16,
    pub alu_key: u32,
    pub eq4_key: u8,
    pub reg_ra_x_addr: usize,
    pub reg_ra_y_addr: usize,
    pub reg_ra_i_addr: usize,
    pub reg_wa_addr: usize,
    pub ram_ra_addr: usize,
    pub ram_wa_addr: usize,
    pub reg_inc: F,
    pub ram_inc: F,
    pub uses_y: bool,
    pub reads_ram: bool,
    pub writes_ram: bool,
}

// ---------------------------------------------------------------------------
// Stage proofs (§9.4)
// ---------------------------------------------------------------------------

pub struct ShoutChannelProof {
    pub addr_point: Vec<K>,
    pub sumcheck_rounds: Vec<Vec<K>>,
    pub addr_correctness_rounds: Vec<Vec<K>>,
    pub address_opening_value: K,
    pub read_values_at_cycle: Vec<K>,
    pub table_opening_values: Vec<K>,
}

pub struct Stage1ShoutProof {
    /// r_lookup
    pub cycle_point: Vec<K>,
    pub fetch_proof: ShoutChannelProof,
    pub decode_proof: ShoutChannelProof,
    pub alu_proof: ShoutChannelProof,
    pub eq4_proof: ShoutChannelProof,
    /// 3 values opened at r_lookup
    pub decode_handoff_values: Vec<K>,
    /// 17 lane columns opened at r_lookup
    pub lane_values_at_lookup: Vec<K>,
}

pub struct AddressCorrectnessProof {
    pub booleanity_rounds: Vec<Vec<K>>,
    pub hamming_weight_rounds: Vec<Vec<K>>,
    pub decode_consistency_rounds: Vec<Vec<K>>,
    pub raw_address_rounds: Vec<Vec<K>>,
}

pub struct Stage2LinkClaims {
    pub rv_x: K,
    pub rv_y: K,
    pub rv_i: K,
    pub wv_reg: K,
    pub rv_ram: K,
    pub wv_ram: K,
}

pub struct CycleProductProof {
    pub claim: K,
    pub rounds: Vec<Vec<K>>,
}

pub struct Stage2TwistProof {
    /// r_twist_cycle
    pub cycle_point: Vec<K>,
    /// r_addr_reg (K^5)
    pub reg_addr_point: Vec<K>,
    /// RegVal(r_addr_reg, r_twist_cycle)
    pub reg_val_at_point: K,
    /// r_addr_ram (K^13)
    pub ram_addr_point: Vec<K>,
    /// RamVal(r_addr_ram, r_twist_cycle)
    pub ram_val_at_point: K,
    pub gamma_reg: K,
    pub reg_rw_batched_rounds: Vec<Vec<K>>,
    pub reg_val_from_inc_claim: K,
    pub reg_val_from_inc_rounds: Vec<Vec<K>>,
    /// 4: RegRaX, RegRaY, RegRaI, RegWa
    pub reg_addr_correctness: Vec<AddressCorrectnessProof>,
    pub gamma_ram: K,
    pub ram_rw_batched_rounds: Vec<Vec<K>>,
    pub ram_val_from_inc_claim: K,
    pub ram_val_from_inc_rounds: Vec<Vec<K>>,
    pub ram_raf_read_claim: K,
    pub ram_raf_read_rounds: Vec<Vec<K>>,
    pub ram_raf_write_claim: K,
    pub ram_raf_write_rounds: Vec<Vec<K>>,
    pub reg_ra_y_target_proof: CycleProductProof,
    pub reg_wa_addr_target_proof: CycleProductProof,
    pub reg_write_x_target_proof: CycleProductProof,
    pub reg_write_i_target_proof: CycleProductProof,
    pub ram_read_target_proof: CycleProductProof,
    pub ram_write_target_proof: CycleProductProof,
    pub ram_write_matches_x_zero_proof: CycleProductProof,
    pub ram_idle_mem_zero_proof: CycleProductProof,
    /// 2: RamRa, RamWa
    pub ram_addr_correctness: Vec<AddressCorrectnessProof>,
    pub link_claims: Stage2LinkClaims,
    pub gamma_twist_link: K,
    pub linkage_batch_value: K,
    /// 14 deduplicated lane columns at r_twist_cycle
    pub lane_values_at_twist: Vec<K>,
    /// 3 decode-handoff at r_twist_cycle
    pub handoff_values_at_twist: Vec<K>,
}

pub struct LaneShiftProof {
    /// r_shift
    pub source_point: Vec<K>,
    /// [shift_pc, shift_x_idx, shift_is_memop]
    pub claimed_shift_values: [K; 3],
    pub reduction_rounds: Vec<Vec<K>>,
}

pub struct RowBindingClaim {
    pub row_index: usize,
    pub row_bits: Vec<bool>,
    /// 23 non-fixed lane column values
    pub opened_values: Vec<K>,
}

pub struct Stage3Proof {
    pub shift_proof: LaneShiftProof,
    /// [PC(r_shift), PC_NEXT(r_shift), X_IDX(r_shift), IsMemOp(r_shift), BURST_LAST(r_shift)]
    pub shift_opening_values: [K; 5],
    pub continuity_check_value: K,
    /// [IsMemOp(0), X_IDX(0)]
    pub start_boundary_values: [K; 2],
    /// [IsMemOp(N-1), BURST_LAST(N-1)]
    pub final_boundary_values: [K; 2],
    pub row_bindings: Vec<RowBindingClaim>,
}

pub const STAGE1_LANE_OPEN_COLS: [usize; 17] = [
    COL_PC,
    COL_KK,
    COL_NNN_ADDR,
    COL_NNN_WORD,
    COL_REG_X,
    COL_REG_Y,
    COL_LOOKUP_OUTPUT,
    COL_WRITES_LOOKUP_TO_X,
    COL_WRITES_MEM_TO_X,
    COL_PRESERVES_X,
    COL_WRITES_NNN_TO_I,
    COL_IS_JUMP,
    COL_IS_BRANCH,
    COL_IS_MEMOP,
    COL_X_IDX,
    COL_Y_IDX,
    COL_BURST_LAST,
];

pub const STAGE2_LANE_OPEN_COLS: [usize; 14] = [
    COL_REG_X,
    COL_REG_Y,
    COL_REG_X_NEXT,
    COL_I_REG,
    COL_I_NEXT,
    COL_MEM_VALUE,
    COL_WRITES_LOOKUP_TO_X,
    COL_WRITES_MEM_TO_X,
    COL_PRESERVES_X,
    COL_WRITES_NNN_TO_I,
    COL_IS_MEMOP,
    COL_X_IDX,
    COL_Y_IDX,
    COL_RAM_ADDR,
];

pub const STAGE3_SHIFT_OPEN_COLS: [usize; 5] = [COL_PC, COL_PC_NEXT, COL_X_IDX, COL_IS_MEMOP, COL_BURST_LAST];
pub const STAGE3_START_BOUNDARY_COLS: [usize; 2] = [COL_IS_MEMOP, COL_X_IDX];
pub const STAGE3_FINAL_BOUNDARY_COLS: [usize; 2] = [COL_IS_MEMOP, COL_BURST_LAST];
pub const DECODE_HANDOFF_POLY_IDS: [usize; 3] = [0, 1, 2];
pub const REG_TWIST_POLY_IDS: [usize; 5] = [0, 1, 2, 3, 4];
pub const RAM_TWIST_POLY_IDS: [usize; 3] = [0, 1, 2];

pub struct SimpleKernelProof {
    pub commitments: KernelCommitments,
    pub lane_commitments: LaneCommitmentSet,
    pub fetch_ra_commitments: FetchRaCommitmentSet,
    pub decode_ra_commitments: DecodeRaCommitmentSet,
    pub alu_ra_commitments: AluRaCommitmentSet,
    pub eq4_ra_commitments: Eq4RaCommitmentSet,
    pub rom_table_commitments: RomTableCommitmentSet,
    pub decode_table_commitments: DecodeTableCommitmentSet,
    pub alu_table_commitments: AluTableCommitmentSet,
    pub eq4_table_commitments: Eq4TableCommitmentSet,
    pub decode_handoff_commitments: DecodeHandoffCommitmentSet,
    pub reg_twist_commitments: RegTwistCommitmentSet,
    pub ram_twist_commitments: RamTwistCommitmentSet,
    pub meta_pub: KernelMetaPub,
    pub stage1: Stage1ShoutProof,
    pub stage2: Stage2TwistProof,
    pub stage3: Stage3Proof,
    pub kernel_opening_manifest: KernelOpeningManifest,
    pub root_opening_manifest: RootOpeningManifest,
    pub lane_opening_proofs: Vec<LaneOpeningProof>,
    pub fetch_ra_opening_proofs: Vec<FetchRaOpeningProof>,
    pub decode_ra_opening_proofs: Vec<DecodeRaOpeningProof>,
    pub alu_ra_opening_proofs: Vec<AluRaOpeningProof>,
    pub eq4_ra_opening_proofs: Vec<Eq4RaOpeningProof>,
    pub rom_table_opening_proofs: Vec<RomTableOpeningProof>,
    pub decode_table_opening_proofs: Vec<DecodeTableOpeningProof>,
    pub alu_table_opening_proofs: Vec<AluTableOpeningProof>,
    pub eq4_table_opening_proofs: Vec<Eq4TableOpeningProof>,
    pub decode_handoff_opening_proofs: Vec<DecodeHandoffOpeningProof>,
    pub reg_twist_opening_proofs: Vec<RegTwistOpeningProof>,
    pub ram_twist_opening_proofs: Vec<RamTwistOpeningProof>,
    pub opening_refinement_summary: KernelOpeningRefinementSummary,
    pub joint_opening_summary: KernelJointOpeningSummary,
    pub joint_opening_fold_bucket_proofs: Vec<KernelJointOpeningFoldBucketProof>,
    pub row_projection_summary: KernelRowProjectionSummary,
    pub bridge_binding_summary: KernelBridgeBindingSummary,
    pub semantic_evidence_summary: KernelSemanticEvidenceSummary,
    pub time_opening_summary: TimeOpeningProofSummary,
}

pub struct KernelCommitments {
    pub c_lane: [u8; 32],
    pub c_fetch_ra: [u8; 32],
    pub c_decode_ra: [u8; 32],
    pub c_alu_ra: [u8; 32],
    pub c_eq4_ra: [u8; 32],
    pub c_decode_handoff: [u8; 32],
    pub c_reg: [u8; 32],
    pub c_ram: [u8; 32],
    pub c_rom_table: [u8; 32],
    pub c_decode_table: [u8; 32],
    pub c_alu_table: [u8; 32],
    pub c_eq4_table: [u8; 32],
}

impl KernelCommitments {
    fn expect_matches(&self, expected: &Self) -> Result<(), SimpleKernelError> {
        expect_digest32(self.c_lane, expected.c_lane, "kernel commitment c_lane")?;
        expect_digest32(self.c_fetch_ra, expected.c_fetch_ra, "kernel commitment c_fetch_ra")?;
        expect_digest32(self.c_decode_ra, expected.c_decode_ra, "kernel commitment c_decode_ra")?;
        expect_digest32(self.c_alu_ra, expected.c_alu_ra, "kernel commitment c_alu_ra")?;
        expect_digest32(self.c_eq4_ra, expected.c_eq4_ra, "kernel commitment c_eq4_ra")?;
        expect_digest32(
            self.c_decode_handoff,
            expected.c_decode_handoff,
            "kernel commitment c_decode_handoff",
        )?;
        expect_digest32(self.c_reg, expected.c_reg, "kernel commitment c_reg")?;
        expect_digest32(self.c_ram, expected.c_ram, "kernel commitment c_ram")?;
        expect_digest32(self.c_rom_table, expected.c_rom_table, "kernel commitment c_rom_table")?;
        expect_digest32(
            self.c_decode_table,
            expected.c_decode_table,
            "kernel commitment c_decode_table",
        )?;
        expect_digest32(self.c_alu_table, expected.c_alu_table, "kernel commitment c_alu_table")?;
        expect_digest32(self.c_eq4_table, expected.c_eq4_table, "kernel commitment c_eq4_table")?;
        Ok(())
    }
}

pub struct SimpleKernelOutput {
    pub prepared_steps: Vec<crate::proof::StepInput>,
    pub public_steps: Vec<crate::proof::PublicStep>,
    pub kernel_opening_manifest: KernelOpeningManifest,
    pub root_opening_manifest: RootOpeningManifest,
    pub joint_opening_fold_bucket_proofs: Vec<KernelJointOpeningFoldBucketProof>,
    pub row_projection_summary: KernelRowProjectionSummary,
    pub bridge_binding_summary: KernelBridgeBindingSummary,
    pub semantic_evidence_summary: KernelSemanticEvidenceSummary,
}

#[derive(Debug)]
pub enum SimpleKernelError {
    InvalidProgram(String),
    InvalidWitness(String),
    SumcheckFailed(String),
    OpeningFailed(String),
    ContinuityFailed(String),
    BridgeFailed(String),
}

impl std::fmt::Display for SimpleKernelError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::InvalidProgram(s) => write!(f, "invalid program: {s}"),
            Self::InvalidWitness(s) => write!(f, "invalid witness: {s}"),
            Self::SumcheckFailed(s) => write!(f, "sumcheck failed: {s}"),
            Self::OpeningFailed(s) => write!(f, "opening failed: {s}"),
            Self::ContinuityFailed(s) => write!(f, "continuity failed: {s}"),
            Self::BridgeFailed(s) => write!(f, "bridge failed: {s}"),
        }
    }
}

impl std::error::Error for SimpleKernelError {}

fn build_kernel_commitments(
    lane_commitment_digest: [u8; 32],
    fetch_ra_commitment_digest: [u8; 32],
    decode_ra_commitment_digest: [u8; 32],
    alu_ra_commitment_digest: [u8; 32],
    eq4_ra_commitment_digest: [u8; 32],
    rom_table_commitment_digest: [u8; 32],
    decode_table_commitment_digest: [u8; 32],
    alu_table_commitment_digest: [u8; 32],
    eq4_table_commitment_digest: [u8; 32],
    decode_handoff_commitment_digest: [u8; 32],
    reg_twist_commitment_digest: [u8; 32],
    ram_twist_commitment_digest: [u8; 32],
) -> KernelCommitments {
    KernelCommitments {
        c_lane: lane_commitment_digest,
        c_fetch_ra: fetch_ra_commitment_digest,
        c_decode_ra: decode_ra_commitment_digest,
        c_alu_ra: alu_ra_commitment_digest,
        c_eq4_ra: eq4_ra_commitment_digest,
        c_decode_handoff: decode_handoff_commitment_digest,
        c_reg: reg_twist_commitment_digest,
        c_ram: ram_twist_commitment_digest,
        c_rom_table: rom_table_commitment_digest,
        c_decode_table: decode_table_commitment_digest,
        c_alu_table: alu_table_commitment_digest,
        c_eq4_table: eq4_table_commitment_digest,
    }
}

fn pad_opcode(pad_pc_word: u16) -> u16 {
    0x1000 | (2 * pad_pc_word)
}

fn build_pad_aux(pad_pc_word: u16) -> KernelStepAux {
    KernelStepAux {
        fetch_addr: pad_pc_word as usize,
        decode_addr: pad_opcode(pad_pc_word),
        alu_key: flatten_alu_key(LookupKind::NoLookup, 0, 0),
        eq4_key: flatten_eq4_key(0, 0),
        reg_ra_x_addr: 0,
        reg_ra_y_addr: REG_SINK_ADDR,
        reg_ra_i_addr: 16,
        reg_wa_addr: REG_SINK_ADDR,
        ram_ra_addr: RAM_SINK_ADDR,
        ram_wa_addr: RAM_SINK_ADDR,
        reg_inc: F::ZERO,
        ram_inc: F::ZERO,
        uses_y: false,
        reads_ram: false,
        writes_ram: false,
    }
}

fn pad_semantic_witness(
    semantic_trace_rows: &[[F; 24]],
    semantic_aux_data: &[KernelStepAux],
    pad_pc_word: u16,
) -> Result<(Vec<[F; 24]>, Vec<KernelStepAux>), SimpleKernelError> {
    if semantic_trace_rows.is_empty() {
        return Err(SimpleKernelError::InvalidWitness(
            "semantic trace must contain at least one row".into(),
        ));
    }
    if semantic_trace_rows.len() != semantic_aux_data.len() {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "semantic trace row count {} does not match aux row count {}",
            semantic_trace_rows.len(),
            semantic_aux_data.len()
        )));
    }

    let padded_len = semantic_trace_rows.len().next_power_of_two();
    let mut trace_rows = semantic_trace_rows.to_vec();
    let mut aux_data = semantic_aux_data.to_vec();
    let pad_row = build_pad_row(pad_pc_word);
    let pad_aux = build_pad_aux(pad_pc_word);

    while trace_rows.len() < padded_len {
        trace_rows.push(pad_row);
        aux_data.push(pad_aux.clone());
    }

    Ok((trace_rows, aux_data))
}

fn row_index_matches_bits(row_index: usize, row_bits: &[bool]) -> bool {
    row_bits
        .iter()
        .enumerate()
        .all(|(bit, &is_one)| ((row_index >> bit) & 1 == 1) == is_one)
}

fn base_value(value: K, label: &str) -> Result<F, SimpleKernelError> {
    let [real, imag] = value.as_coeffs();
    if imag != F::ZERO {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "{label} must be a base-field opening"
        )));
    }
    Ok(real)
}

fn build_root_step(
    row_binding: &RowBindingClaim,
    cycle_bits: usize,
    root_context: &SimpleKernelRootContext,
) -> Result<crate::proof::StepInput, SimpleKernelError> {
    if row_binding.row_bits.len() != cycle_bits {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "row {} has {} row bits, expected {}",
            row_binding.row_index,
            row_binding.row_bits.len(),
            cycle_bits
        )));
    }
    if !row_index_matches_bits(row_binding.row_index, &row_binding.row_bits) {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "row {} bits do not match its row index",
            row_binding.row_index
        )));
    }
    if row_binding.opened_values.len() != WITNESS_WIDTH - 1 {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "row {} has {} opened values, expected {}",
            row_binding.row_index,
            row_binding.opened_values.len(),
            WITNESS_WIDTH - 1
        )));
    }

    let mut z = [F::ZERO; WITNESS_WIDTH];
    z[0] = F::ONE;
    for (col, &value) in row_binding.opened_values.iter().enumerate() {
        z[col + 1] = base_value(value, &format!("row {} column {}", row_binding.row_index, col + 1))?;
    }
    build_prepared_step_from_semantic_row(root_context, row_binding.row_index, &z)
}

// ---------------------------------------------------------------------------
// Entry point stubs
// ---------------------------------------------------------------------------

pub fn prove_simple_kernel(
    input: &SimpleKernelProverInput,
) -> Result<(SimpleKernelOutput, SimpleKernelProof), SimpleKernelError> {
    let mut transcript = new_simple_kernel_transcript(&input.public.transcript_seed);
    let root_context = SimpleKernelRootContext::new()?;
    let root_params = root_context.params();
    let semantic_rows = input.witness.semantic_trace_rows.len();
    let word_count = validate_public_input(&input.public)?;
    if semantic_rows == 0 {
        return Err(SimpleKernelError::InvalidWitness(
            "semantic trace must contain at least one row".into(),
        ));
    }
    if input.witness.semantic_trace_rows[0][COL_PC] != F::from_u64(input.public.initial_pc_word as u64) {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "first semantic row PC {} != public initial_pc_word {}",
            input.witness.semantic_trace_rows[0][COL_PC].as_canonical_u64(),
            input.public.initial_pc_word
        )));
    }

    // Build program descriptor from public input.
    let program = Chip8Program {
        bytes: input.public.program_image.clone(),
        start_pc: CHIP8_PROGRAM_START,
    };
    let base_word = (program.start_pc / 2) as usize;
    if input.public.initial_pc_word as usize != base_word {
        return Err(SimpleKernelError::InvalidProgram(format!(
            "public initial_pc_word {} != standard loader base word {}",
            input.public.initial_pc_word, base_word
        )));
    }
    let pad_pc_word = (base_word + word_count) as u16;
    let (trace_rows, aux_data) = pad_semantic_witness(
        &input.witness.semantic_trace_rows,
        &input.witness.semantic_aux_data,
        pad_pc_word,
    )?;
    let padded_trace_length = trace_rows.len();
    let cycle_bits = padded_trace_length.trailing_zeros() as usize;

    // Build lookup tables.
    let rom_table = build_rom_table(&program, pad_pc_word);
    let decode_table = build_decode_table();
    let alu_table = build_alu_table();
    let eq4_table = build_eq4_table();

    let lane_commitments = build_lane_commitment_set(root_params, &trace_rows)?;
    let fetch_ra_commitments = build_fetch_ra_commitment_set(root_params, &aux_data)?;
    let decode_ra_commitments = build_decode_ra_commitment_set(root_params, &aux_data)?;
    let alu_ra_commitments = build_alu_ra_commitment_set(root_params, &aux_data)?;
    let eq4_ra_commitments = build_eq4_ra_commitment_set(root_params, &aux_data)?;
    let rom_table_commitments = build_rom_table_commitment_set(root_params, &rom_table)?;
    let decode_table_commitments = build_decode_table_commitment_set(root_params, &decode_table)?;
    let alu_table_commitments = build_alu_table_commitment_set(root_params, &alu_table)?;
    let eq4_table_commitments = build_eq4_table_commitment_set(root_params, &eq4_table)?;
    let decode_handoff_commitments = build_decode_handoff_commitment_set(root_params, &aux_data)?;
    let reg_twist_commitments = build_reg_twist_commitment_set(root_params, &aux_data)?;
    let ram_twist_commitments = build_ram_twist_commitment_set(root_params, &aux_data)?;
    let commitments = build_kernel_commitments(
        lane_commitments.expected_digest(),
        fetch_ra_commitments.expected_digest(),
        decode_ra_commitments.expected_digest(),
        alu_ra_commitments.expected_digest(),
        eq4_ra_commitments.expected_digest(),
        rom_table_commitments.expected_digest(),
        decode_table_commitments.expected_digest(),
        alu_table_commitments.expected_digest(),
        eq4_table_commitments.expected_digest(),
        decode_handoff_commitments.expected_digest(),
        reg_twist_commitments.expected_digest(),
        ram_twist_commitments.expected_digest(),
    );
    let meta_pub = build_kernel_meta_pub(
        &input.public,
        &rom_table,
        &decode_table,
        &alu_table,
        &eq4_table,
        word_count,
        semantic_rows,
        padded_trace_length,
        pad_pc_word,
        cycle_bits,
    );
    absorb_root0(&mut transcript, &commitments, &meta_pub);

    // Stage 1: Shout (read-only lookup proofs).
    let stage1_proof = stage1::prove_stage1(
        &trace_rows,
        &aux_data,
        &rom_table,
        &decode_table,
        &alu_table,
        &eq4_table,
        cycle_bits,
        &mut transcript,
    )
    .map_err(SimpleKernelError::SumcheckFailed)?;

    // Stage 2: Twist (read-write memory checking).
    let stage2_proof = stage2::prove_stage2(
        &trace_rows,
        &aux_data,
        &input.public.initial_registers,
        input.public.initial_i,
        &input.public.initial_ram,
        cycle_bits,
        &mut transcript,
    )?;

    // Stage 3: Continuity + bridge binding.
    let active_rows = semantic_rows;
    let stage3_proof = stage3::prove_stage3(&trace_rows, active_rows, cycle_bits, &mut transcript)?;

    let manifest = build_kernel_opening_manifest(
        &aux_data,
        active_rows,
        cycle_bits,
        &stage1_proof,
        &stage2_proof,
        &stage3_proof,
    );
    let root_opening_manifest = RootOpeningManifest::new();
    let lane_opening_proofs = build_lane_opening_proofs(root_params, &trace_rows, &manifest)?;
    let fetch_ra_opening_proofs = build_fetch_ra_opening_proofs(root_params, &aux_data, &manifest)?;
    let decode_ra_opening_proofs = build_decode_ra_opening_proofs(root_params, &aux_data, &manifest)?;
    let alu_ra_opening_proofs = build_alu_ra_opening_proofs(root_params, &aux_data, &manifest)?;
    let eq4_ra_opening_proofs = build_eq4_ra_opening_proofs(root_params, &aux_data, &manifest)?;
    let rom_table_opening_proofs = build_rom_table_opening_proofs(root_params, &rom_table, &manifest)?;
    let decode_table_opening_proofs = build_decode_table_opening_proofs(root_params, &decode_table, &manifest)?;
    let alu_table_opening_proofs = build_alu_table_opening_proofs(root_params, &alu_table, &manifest)?;
    let eq4_table_opening_proofs = build_eq4_table_opening_proofs(root_params, &eq4_table, &manifest)?;
    let decode_handoff_opening_proofs = build_decode_handoff_opening_proofs(root_params, &aux_data, &manifest)?;
    let reg_twist_opening_proofs = build_reg_twist_opening_proofs(root_params, &aux_data, &manifest)?;
    let ram_twist_opening_proofs = build_ram_twist_opening_proofs(root_params, &aux_data, &manifest)?;
    let opening_refinement_summary = build_kernel_opening_refinement_summary(
        &manifest,
        KernelExactOpeningArtifacts {
            lane_commitments: &lane_commitments,
            fetch_ra_commitments: &fetch_ra_commitments,
            decode_ra_commitments: &decode_ra_commitments,
            alu_ra_commitments: &alu_ra_commitments,
            eq4_ra_commitments: &eq4_ra_commitments,
            rom_table_commitments: &rom_table_commitments,
            decode_table_commitments: &decode_table_commitments,
            alu_table_commitments: &alu_table_commitments,
            eq4_table_commitments: &eq4_table_commitments,
            decode_handoff_commitments: &decode_handoff_commitments,
            reg_twist_commitments: &reg_twist_commitments,
            ram_twist_commitments: &ram_twist_commitments,
            lane_opening_proofs: &lane_opening_proofs,
            fetch_ra_opening_proofs: &fetch_ra_opening_proofs,
            decode_ra_opening_proofs: &decode_ra_opening_proofs,
            alu_ra_opening_proofs: &alu_ra_opening_proofs,
            eq4_ra_opening_proofs: &eq4_ra_opening_proofs,
            rom_table_opening_proofs: &rom_table_opening_proofs,
            decode_table_opening_proofs: &decode_table_opening_proofs,
            alu_table_opening_proofs: &alu_table_opening_proofs,
            eq4_table_opening_proofs: &eq4_table_opening_proofs,
            decode_handoff_opening_proofs: &decode_handoff_opening_proofs,
            reg_twist_opening_proofs: &reg_twist_opening_proofs,
            ram_twist_opening_proofs: &ram_twist_opening_proofs,
        },
    )?;
    let time_opening_claims = time_opening_claims(&manifest, &root_opening_manifest);
    let time_opening_summary = prove_time_opening(&[], &time_opening_claims)
        .map_err(|err| SimpleKernelError::OpeningFailed(format!("kernel time-opening failed: {err}")))?;
    let joint_opening_summary = build_kernel_joint_opening_summary(
        root_params,
        &manifest,
        &opening_refinement_summary,
        &time_opening_summary,
        KernelExactOpeningArtifacts {
            lane_commitments: &lane_commitments,
            fetch_ra_commitments: &fetch_ra_commitments,
            decode_ra_commitments: &decode_ra_commitments,
            alu_ra_commitments: &alu_ra_commitments,
            eq4_ra_commitments: &eq4_ra_commitments,
            rom_table_commitments: &rom_table_commitments,
            decode_table_commitments: &decode_table_commitments,
            alu_table_commitments: &alu_table_commitments,
            eq4_table_commitments: &eq4_table_commitments,
            decode_handoff_commitments: &decode_handoff_commitments,
            reg_twist_commitments: &reg_twist_commitments,
            ram_twist_commitments: &ram_twist_commitments,
            lane_opening_proofs: &lane_opening_proofs,
            fetch_ra_opening_proofs: &fetch_ra_opening_proofs,
            decode_ra_opening_proofs: &decode_ra_opening_proofs,
            alu_ra_opening_proofs: &alu_ra_opening_proofs,
            eq4_ra_opening_proofs: &eq4_ra_opening_proofs,
            rom_table_opening_proofs: &rom_table_opening_proofs,
            decode_table_opening_proofs: &decode_table_opening_proofs,
            alu_table_opening_proofs: &alu_table_opening_proofs,
            eq4_table_opening_proofs: &eq4_table_opening_proofs,
            decode_handoff_opening_proofs: &decode_handoff_opening_proofs,
            reg_twist_opening_proofs: &reg_twist_opening_proofs,
            ram_twist_opening_proofs: &ram_twist_opening_proofs,
        },
    )?;
    if stage3_proof.row_bindings.len() != semantic_rows {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "stage3 exported {} row bindings for {} semantic rows",
            stage3_proof.row_bindings.len(),
            semantic_rows
        )));
    }
    let row_projection_summary = build_kernel_row_projection_summary(
        &manifest,
        &opening_refinement_summary,
        &stage3_proof.row_bindings,
        &input.witness.semantic_trace_rows,
    )?;
    let prepared_steps: Vec<_> = stage3_proof
        .row_bindings
        .iter()
        .map(|row_binding| build_root_step(row_binding, cycle_bits, &root_context))
        .collect::<Result<_, _>>()?;
    let public_steps = prepared_steps
        .iter()
        .map(crate::proof::StepInput::instance)
        .collect();
    let bridge_binding_summary = build_kernel_bridge_binding_summary(
        &manifest,
        &opening_refinement_summary,
        &stage3_proof.row_bindings,
        &prepared_steps,
    )?;
    let joint_opening_fold_bucket_proofs =
        build_kernel_joint_opening_fold_bucket_proofs(meta_pub.padded_trace_length, &joint_opening_summary)?;
    emit_kernel_opening_artifacts_to_transcript(
        &mut transcript,
        &manifest,
        &root_opening_manifest,
        &opening_refinement_summary,
        &time_opening_summary,
        &joint_opening_summary,
        &joint_opening_fold_bucket_proofs,
        KernelExactOpeningArtifacts {
            lane_commitments: &lane_commitments,
            fetch_ra_commitments: &fetch_ra_commitments,
            decode_ra_commitments: &decode_ra_commitments,
            alu_ra_commitments: &alu_ra_commitments,
            eq4_ra_commitments: &eq4_ra_commitments,
            rom_table_commitments: &rom_table_commitments,
            decode_table_commitments: &decode_table_commitments,
            alu_table_commitments: &alu_table_commitments,
            eq4_table_commitments: &eq4_table_commitments,
            decode_handoff_commitments: &decode_handoff_commitments,
            reg_twist_commitments: &reg_twist_commitments,
            ram_twist_commitments: &ram_twist_commitments,
            lane_opening_proofs: &lane_opening_proofs,
            fetch_ra_opening_proofs: &fetch_ra_opening_proofs,
            decode_ra_opening_proofs: &decode_ra_opening_proofs,
            alu_ra_opening_proofs: &alu_ra_opening_proofs,
            eq4_ra_opening_proofs: &eq4_ra_opening_proofs,
            rom_table_opening_proofs: &rom_table_opening_proofs,
            decode_table_opening_proofs: &decode_table_opening_proofs,
            alu_table_opening_proofs: &alu_table_opening_proofs,
            eq4_table_opening_proofs: &eq4_table_opening_proofs,
            decode_handoff_opening_proofs: &decode_handoff_opening_proofs,
            reg_twist_opening_proofs: &reg_twist_opening_proofs,
            ram_twist_opening_proofs: &ram_twist_opening_proofs,
        },
    )?;
    let semantic_evidence_summary = build_kernel_semantic_evidence_summary(KernelSemanticEvidenceInputs {
        stage1: &stage1_proof,
        stage2: &stage2_proof,
        stage3: &stage3_proof,
        kernel_opening_manifest: &manifest,
        root_opening_manifest: &root_opening_manifest,
        time_opening_summary: &time_opening_summary,
        opening_refinement_summary: &opening_refinement_summary,
        joint_opening_summary: &joint_opening_summary,
        joint_opening_fold_bucket_proofs: &joint_opening_fold_bucket_proofs,
        row_projection_summary: &row_projection_summary,
        bridge_binding_summary: &bridge_binding_summary,
    })?;

    let output = SimpleKernelOutput {
        prepared_steps,
        public_steps,
        kernel_opening_manifest: manifest.clone(),
        root_opening_manifest: root_opening_manifest.clone(),
        joint_opening_fold_bucket_proofs: joint_opening_fold_bucket_proofs.clone(),
        row_projection_summary: row_projection_summary.clone(),
        bridge_binding_summary: bridge_binding_summary.clone(),
        semantic_evidence_summary: semantic_evidence_summary.clone(),
    };

    let proof = SimpleKernelProof {
        commitments,
        lane_commitments,
        fetch_ra_commitments,
        decode_ra_commitments,
        alu_ra_commitments,
        eq4_ra_commitments,
        rom_table_commitments,
        decode_table_commitments,
        alu_table_commitments,
        eq4_table_commitments,
        decode_handoff_commitments,
        reg_twist_commitments,
        ram_twist_commitments,
        meta_pub,
        stage1: stage1_proof,
        stage2: stage2_proof,
        stage3: stage3_proof,
        kernel_opening_manifest: manifest,
        root_opening_manifest,
        lane_opening_proofs,
        fetch_ra_opening_proofs,
        decode_ra_opening_proofs,
        alu_ra_opening_proofs,
        eq4_ra_opening_proofs,
        rom_table_opening_proofs,
        decode_table_opening_proofs,
        alu_table_opening_proofs,
        eq4_table_opening_proofs,
        decode_handoff_opening_proofs,
        reg_twist_opening_proofs,
        ram_twist_opening_proofs,
        opening_refinement_summary,
        joint_opening_summary,
        joint_opening_fold_bucket_proofs,
        row_projection_summary,
        bridge_binding_summary,
        semantic_evidence_summary,
        time_opening_summary,
    };

    Ok((output, proof))
}

pub fn verify_simple_kernel(
    input: &SimpleKernelVerifierInput,
    proof: &SimpleKernelProof,
) -> Result<SimpleKernelOutput, SimpleKernelError> {
    let mut transcript = new_simple_kernel_transcript(&input.public.transcript_seed);
    let root_context = SimpleKernelRootContext::new()?;
    let root_params = root_context.params();
    let word_count = validate_public_input(&input.public)?;
    let program = Chip8Program {
        bytes: input.public.program_image.clone(),
        start_pc: CHIP8_PROGRAM_START,
    };
    let base_word = (program.start_pc / 2) as usize;
    if input.public.initial_pc_word as usize != base_word {
        return Err(SimpleKernelError::InvalidProgram(format!(
            "public initial_pc_word {} != standard loader base word {}",
            input.public.initial_pc_word, base_word
        )));
    }
    let pad_pc_word = (base_word + word_count) as u16;
    let semantic_rows = proof.meta_pub.semantic_rows;
    let padded_trace_length = proof.meta_pub.padded_trace_length;
    let cycle_bits = proof.meta_pub.cycle_bits;

    if semantic_rows == 0 {
        return Err(SimpleKernelError::InvalidWitness(
            "kernel proof must contain at least one semantic row".into(),
        ));
    }
    if !padded_trace_length.is_power_of_two() {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "padded trace length {padded_trace_length} must be a power of two"
        )));
    }
    if padded_trace_length != (1usize << cycle_bits) {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "padded trace length {padded_trace_length} != 2^{cycle_bits}"
        )));
    }
    if semantic_rows > padded_trace_length {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "semantic row count {semantic_rows} exceeds padded trace length {padded_trace_length}"
        )));
    }
    if proof.stage3.row_bindings.len() != semantic_rows {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "stage3 exported {} row bindings for {} semantic rows",
            proof.stage3.row_bindings.len(),
            semantic_rows
        )));
    }
    let rom_table = build_rom_table(&program, pad_pc_word);
    let decode_table = build_decode_table();
    let alu_table = build_alu_table();
    let eq4_table = build_eq4_table();
    let expected_meta_pub = build_kernel_meta_pub(
        &input.public,
        &rom_table,
        &decode_table,
        &alu_table,
        &eq4_table,
        word_count,
        semantic_rows,
        padded_trace_length,
        pad_pc_word,
        cycle_bits,
    );
    proof.meta_pub.expect_matches(&expected_meta_pub)?;
    let (trace_rows, aux_data) = reconstruct_trace_rows_and_aux(
        &proof.stage3.row_bindings,
        semantic_rows,
        padded_trace_length,
        cycle_bits,
        pad_pc_word,
        &rom_table,
        &input.public.initial_ram,
    )?;
    if trace_rows[0][COL_PC] != F::from_u64(input.public.initial_pc_word as u64) {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "first semantic row PC {} != public initial_pc_word {}",
            trace_rows[0][COL_PC].as_canonical_u64(),
            input.public.initial_pc_word
        )));
    }
    assert_manifest_canonical(&proof.kernel_opening_manifest)?;
    assert_root_manifest_canonical(&proof.root_opening_manifest)?;
    if !proof.root_opening_manifest.claims.is_empty() {
        return Err(SimpleKernelError::OpeningFailed(
            "simple kernel proof may not carry root opening claims before root proving".into(),
        ));
    }
    let expected_lane_digest = verify_lane_commitment_artifacts(
        root_params,
        &trace_rows,
        &proof.kernel_opening_manifest,
        &proof.lane_commitments,
        &proof.lane_opening_proofs,
    )?;
    let expected_fetch_ra_digest = verify_fetch_ra_commitment_artifacts(
        root_params,
        &aux_data,
        &proof.kernel_opening_manifest,
        &proof.fetch_ra_commitments,
        &proof.fetch_ra_opening_proofs,
    )?;
    let expected_decode_ra_digest = verify_decode_ra_commitment_artifacts(
        root_params,
        &aux_data,
        &proof.kernel_opening_manifest,
        &proof.decode_ra_commitments,
        &proof.decode_ra_opening_proofs,
    )?;
    let expected_alu_ra_digest = verify_alu_ra_commitment_artifacts(
        root_params,
        &aux_data,
        &proof.kernel_opening_manifest,
        &proof.alu_ra_commitments,
        &proof.alu_ra_opening_proofs,
    )?;
    let expected_eq4_ra_digest = verify_eq4_ra_commitment_artifacts(
        root_params,
        &aux_data,
        &proof.kernel_opening_manifest,
        &proof.eq4_ra_commitments,
        &proof.eq4_ra_opening_proofs,
    )?;
    let expected_rom_table_digest = verify_rom_table_commitment_artifacts(
        root_params,
        &rom_table,
        &proof.kernel_opening_manifest,
        &proof.rom_table_commitments,
        &proof.rom_table_opening_proofs,
    )?;
    let expected_decode_table_digest = verify_decode_table_commitment_artifacts(
        root_params,
        &decode_table,
        &proof.kernel_opening_manifest,
        &proof.decode_table_commitments,
        &proof.decode_table_opening_proofs,
    )?;
    let expected_alu_table_digest = verify_alu_table_commitment_artifacts(
        root_params,
        &alu_table,
        &proof.kernel_opening_manifest,
        &proof.alu_table_commitments,
        &proof.alu_table_opening_proofs,
    )?;
    let expected_eq4_table_digest = verify_eq4_table_commitment_artifacts(
        root_params,
        &eq4_table,
        &proof.kernel_opening_manifest,
        &proof.eq4_table_commitments,
        &proof.eq4_table_opening_proofs,
    )?;
    let expected_decode_handoff_digest = verify_decode_handoff_commitment_artifacts(
        root_params,
        &aux_data,
        &proof.kernel_opening_manifest,
        &proof.decode_handoff_commitments,
        &proof.decode_handoff_opening_proofs,
    )?;
    let expected_reg_twist_digest = verify_reg_twist_commitment_artifacts(
        root_params,
        &aux_data,
        &proof.kernel_opening_manifest,
        &proof.reg_twist_commitments,
        &proof.reg_twist_opening_proofs,
    )?;
    let expected_ram_twist_digest = verify_ram_twist_commitment_artifacts(
        root_params,
        &aux_data,
        &proof.kernel_opening_manifest,
        &proof.ram_twist_commitments,
        &proof.ram_twist_opening_proofs,
    )?;

    let expected_commitments = build_kernel_commitments(
        expected_lane_digest,
        expected_fetch_ra_digest,
        expected_decode_ra_digest,
        expected_alu_ra_digest,
        expected_eq4_ra_digest,
        expected_rom_table_digest,
        expected_decode_table_digest,
        expected_alu_table_digest,
        expected_eq4_table_digest,
        expected_decode_handoff_digest,
        expected_reg_twist_digest,
        expected_ram_twist_digest,
    );

    let time_opening_claims = time_opening_claims(&proof.kernel_opening_manifest, &proof.root_opening_manifest);
    verify_time_opening(&[], &time_opening_claims, &Some(proof.time_opening_summary.clone()))
        .map_err(|err| SimpleKernelError::OpeningFailed(format!("kernel time-opening failed: {err}")))?;
    verify_kernel_opening_refinement_summary(
        &proof.kernel_opening_manifest,
        KernelExactOpeningArtifacts {
            lane_commitments: &proof.lane_commitments,
            fetch_ra_commitments: &proof.fetch_ra_commitments,
            decode_ra_commitments: &proof.decode_ra_commitments,
            alu_ra_commitments: &proof.alu_ra_commitments,
            eq4_ra_commitments: &proof.eq4_ra_commitments,
            rom_table_commitments: &proof.rom_table_commitments,
            decode_table_commitments: &proof.decode_table_commitments,
            alu_table_commitments: &proof.alu_table_commitments,
            eq4_table_commitments: &proof.eq4_table_commitments,
            decode_handoff_commitments: &proof.decode_handoff_commitments,
            reg_twist_commitments: &proof.reg_twist_commitments,
            ram_twist_commitments: &proof.ram_twist_commitments,
            lane_opening_proofs: &proof.lane_opening_proofs,
            fetch_ra_opening_proofs: &proof.fetch_ra_opening_proofs,
            decode_ra_opening_proofs: &proof.decode_ra_opening_proofs,
            alu_ra_opening_proofs: &proof.alu_ra_opening_proofs,
            eq4_ra_opening_proofs: &proof.eq4_ra_opening_proofs,
            rom_table_opening_proofs: &proof.rom_table_opening_proofs,
            decode_table_opening_proofs: &proof.decode_table_opening_proofs,
            alu_table_opening_proofs: &proof.alu_table_opening_proofs,
            eq4_table_opening_proofs: &proof.eq4_table_opening_proofs,
            decode_handoff_opening_proofs: &proof.decode_handoff_opening_proofs,
            reg_twist_opening_proofs: &proof.reg_twist_opening_proofs,
            ram_twist_opening_proofs: &proof.ram_twist_opening_proofs,
        },
        &proof.opening_refinement_summary,
    )?;
    verify_kernel_joint_opening_summary(
        root_params,
        &proof.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.time_opening_summary,
        KernelExactOpeningArtifacts {
            lane_commitments: &proof.lane_commitments,
            fetch_ra_commitments: &proof.fetch_ra_commitments,
            decode_ra_commitments: &proof.decode_ra_commitments,
            alu_ra_commitments: &proof.alu_ra_commitments,
            eq4_ra_commitments: &proof.eq4_ra_commitments,
            rom_table_commitments: &proof.rom_table_commitments,
            decode_table_commitments: &proof.decode_table_commitments,
            alu_table_commitments: &proof.alu_table_commitments,
            eq4_table_commitments: &proof.eq4_table_commitments,
            decode_handoff_commitments: &proof.decode_handoff_commitments,
            reg_twist_commitments: &proof.reg_twist_commitments,
            ram_twist_commitments: &proof.ram_twist_commitments,
            lane_opening_proofs: &proof.lane_opening_proofs,
            fetch_ra_opening_proofs: &proof.fetch_ra_opening_proofs,
            decode_ra_opening_proofs: &proof.decode_ra_opening_proofs,
            alu_ra_opening_proofs: &proof.alu_ra_opening_proofs,
            eq4_ra_opening_proofs: &proof.eq4_ra_opening_proofs,
            rom_table_opening_proofs: &proof.rom_table_opening_proofs,
            decode_table_opening_proofs: &proof.decode_table_opening_proofs,
            alu_table_opening_proofs: &proof.alu_table_opening_proofs,
            eq4_table_opening_proofs: &proof.eq4_table_opening_proofs,
            decode_handoff_opening_proofs: &proof.decode_handoff_opening_proofs,
            reg_twist_opening_proofs: &proof.reg_twist_opening_proofs,
            ram_twist_opening_proofs: &proof.ram_twist_opening_proofs,
        },
        &proof.joint_opening_summary,
    )?;
    verify_kernel_joint_opening_fold_bucket_proofs(
        proof.meta_pub.padded_trace_length,
        &proof.joint_opening_summary,
        &proof.joint_opening_fold_bucket_proofs,
    )?;
    proof.commitments.expect_matches(&expected_commitments)?;
    absorb_root0(&mut transcript, &expected_commitments, &proof.meta_pub);

    let mut stage1_terminal_transcript = transcript.clone();
    stage1::verify_stage1(
        &proof.stage1,
        &rom_table,
        &decode_table,
        &alu_table,
        &eq4_table,
        cycle_bits,
        &mut transcript,
    )
    .map_err(SimpleKernelError::SumcheckFailed)?;
    verify_kernel_stage1_sumcheck_terminals(
        &proof.stage1,
        &aux_data,
        &rom_table,
        &alu_table,
        &eq4_table,
        &mut stage1_terminal_transcript,
    )?;

    let mut stage2_terminal_transcript = transcript.clone();
    stage2::verify_stage2(
        &proof.stage2,
        &input.public.initial_registers,
        input.public.initial_i,
        &input.public.initial_ram,
        cycle_bits,
        &mut transcript,
    )?;
    verify_kernel_stage2_sumcheck_terminals(
        &proof.stage2,
        &trace_rows,
        &aux_data,
        &input.public.initial_registers,
        input.public.initial_i,
        &input.public.initial_ram,
        &mut stage2_terminal_transcript,
    )?;

    let mut stage3_terminal_transcript = transcript.clone();
    stage3::verify_stage3(
        &proof.stage3,
        semantic_rows,
        padded_trace_length,
        proof.meta_pub.pad_pc_word,
        cycle_bits,
        &mut transcript,
    )?;
    verify_kernel_stage3_sumcheck_terminal(&proof.stage3, &trace_rows, &mut stage3_terminal_transcript)?;

    authenticate_kernel_openings(
        proof,
        &trace_rows,
        &aux_data,
        &rom_table,
        &decode_table,
        &alu_table,
        &eq4_table,
    )?;
    let expected_kernel_manifest = build_kernel_opening_manifest(
        &aux_data,
        semantic_rows,
        cycle_bits,
        &proof.stage1,
        &proof.stage2,
        &proof.stage3,
    );
    expect_digest32(
        proof.kernel_opening_manifest.digest,
        expected_kernel_manifest.digest,
        "kernel opening manifest",
    )?;

    let row_binding_ids: Vec<usize> = (1..=23).collect();
    let prepared_steps: Vec<_> = proof
        .stage3
        .row_bindings
        .iter()
        .map(|row_binding| {
            let row_point: Vec<K> = row_binding
                .row_bits
                .iter()
                .map(|&bit| if bit { K::ONE } else { K::ZERO })
                .collect();
            expect_equal_k_slice(
                &find_manifest_claim(
                    &proof.kernel_opening_manifest,
                    CommitmentId::Lane,
                    &row_point,
                    &row_binding_ids,
                    &format!("stage3 row-binding opening {}", row_binding.row_index),
                )?
                .claimed_values,
                &row_binding.opened_values,
                &format!("stage3 row-binding values {}", row_binding.row_index),
            )?;
            build_root_step(row_binding, cycle_bits, &root_context)
        })
        .collect::<Result<_, _>>()?;
    let public_steps = prepared_steps
        .iter()
        .map(crate::proof::StepInput::instance)
        .collect();
    verify_kernel_row_projection_summary(
        &proof.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.stage3.row_bindings,
        &trace_rows[..semantic_rows],
        &proof.row_projection_summary,
    )?;
    verify_kernel_bridge_binding_summary(
        &proof.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.stage3.row_bindings,
        &prepared_steps,
        &proof.bridge_binding_summary,
    )?;
    emit_kernel_opening_artifacts_to_transcript(
        &mut transcript,
        &proof.kernel_opening_manifest,
        &proof.root_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.time_opening_summary,
        &proof.joint_opening_summary,
        &proof.joint_opening_fold_bucket_proofs,
        KernelExactOpeningArtifacts {
            lane_commitments: &proof.lane_commitments,
            fetch_ra_commitments: &proof.fetch_ra_commitments,
            decode_ra_commitments: &proof.decode_ra_commitments,
            alu_ra_commitments: &proof.alu_ra_commitments,
            eq4_ra_commitments: &proof.eq4_ra_commitments,
            rom_table_commitments: &proof.rom_table_commitments,
            decode_table_commitments: &proof.decode_table_commitments,
            alu_table_commitments: &proof.alu_table_commitments,
            eq4_table_commitments: &proof.eq4_table_commitments,
            decode_handoff_commitments: &proof.decode_handoff_commitments,
            reg_twist_commitments: &proof.reg_twist_commitments,
            ram_twist_commitments: &proof.ram_twist_commitments,
            lane_opening_proofs: &proof.lane_opening_proofs,
            fetch_ra_opening_proofs: &proof.fetch_ra_opening_proofs,
            decode_ra_opening_proofs: &proof.decode_ra_opening_proofs,
            alu_ra_opening_proofs: &proof.alu_ra_opening_proofs,
            eq4_ra_opening_proofs: &proof.eq4_ra_opening_proofs,
            rom_table_opening_proofs: &proof.rom_table_opening_proofs,
            decode_table_opening_proofs: &proof.decode_table_opening_proofs,
            alu_table_opening_proofs: &proof.alu_table_opening_proofs,
            eq4_table_opening_proofs: &proof.eq4_table_opening_proofs,
            decode_handoff_opening_proofs: &proof.decode_handoff_opening_proofs,
            reg_twist_opening_proofs: &proof.reg_twist_opening_proofs,
            ram_twist_opening_proofs: &proof.ram_twist_opening_proofs,
        },
    )?;
    verify_kernel_semantic_evidence_summary(
        KernelSemanticEvidenceInputs {
            stage1: &proof.stage1,
            stage2: &proof.stage2,
            stage3: &proof.stage3,
            kernel_opening_manifest: &proof.kernel_opening_manifest,
            root_opening_manifest: &proof.root_opening_manifest,
            time_opening_summary: &proof.time_opening_summary,
            opening_refinement_summary: &proof.opening_refinement_summary,
            joint_opening_summary: &proof.joint_opening_summary,
            joint_opening_fold_bucket_proofs: &proof.joint_opening_fold_bucket_proofs,
            row_projection_summary: &proof.row_projection_summary,
            bridge_binding_summary: &proof.bridge_binding_summary,
        },
        &proof.semantic_evidence_summary,
    )?;

    Ok(SimpleKernelOutput {
        prepared_steps,
        public_steps,
        kernel_opening_manifest: proof.kernel_opening_manifest.clone(),
        root_opening_manifest: proof.root_opening_manifest.clone(),
        joint_opening_fold_bucket_proofs: proof.joint_opening_fold_bucket_proofs.clone(),
        row_projection_summary: proof.row_projection_summary.clone(),
        bridge_binding_summary: proof.bridge_binding_summary.clone(),
        semantic_evidence_summary: proof.semantic_evidence_summary.clone(),
    })
}

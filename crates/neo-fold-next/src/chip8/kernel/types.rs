//! Owns the CHIP-8 simple-kernel proof, witness, and artifact surface types.
//! It does not own proving logic, transcript scheduling, or digest construction.

use neo_math::{F, K};

use crate::chip8::spec::{
    COL_BURST_LAST, COL_IS_BRANCH, COL_IS_JUMP, COL_IS_MEMOP, COL_I_NEXT, COL_I_REG, COL_KK, COL_LOOKUP_OUTPUT,
    COL_MEM_VALUE, COL_NNN_ADDR, COL_NNN_WORD, COL_PC, COL_PC_NEXT, COL_PRESERVES_X, COL_RAM_ADDR, COL_REG_X,
    COL_REG_X_NEXT, COL_REG_Y, COL_WRITES_LOOKUP_TO_X, COL_WRITES_MEM_TO_X, COL_WRITES_NNN_TO_I, COL_X_IDX, COL_Y_IDX,
};
use crate::proof::{PublicStep, StepInput, TimeOpeningProofSummary};

use super::bridge::KernelBridgeBindingSummary;
use super::bridge::KernelRowProjectionSummary;
use super::evidence::KernelSemanticEvidenceSummary;
use super::joint_opening::KernelJointOpeningFoldBucketProof;
use super::joint_opening::KernelJointOpeningSummary;
use super::lane_commitment::{
    AluRaCommitmentSet, AluRaOpeningProof, AluTableCommitmentSet, AluTableOpeningProof, DecodeHandoffCommitmentSet,
    DecodeHandoffOpeningProof, DecodeRaCommitmentSet, DecodeRaOpeningProof, DecodeTableCommitmentSet,
    DecodeTableOpeningProof, Eq4RaCommitmentSet, Eq4RaOpeningProof, Eq4TableCommitmentSet, Eq4TableOpeningProof,
    FetchRaCommitmentSet, FetchRaOpeningProof, LaneCommitmentSet, LaneOpeningProof, RamTwistCommitmentSet,
    RamTwistOpeningProof, RegTwistCommitmentSet, RegTwistOpeningProof, RomTableCommitmentSet, RomTableOpeningProof,
};
use super::openings::KernelOpeningRefinementSummary;
use super::openings::{KernelOpeningManifest, RootOpeningManifest};
use super::public_meta::KernelMetaPub;
use super::verify_common::expect_digest32;

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

pub struct ShoutChannelProof {
    pub addr_point: Vec<K>,
    pub sumcheck_rounds: Vec<Vec<K>>,
    pub addr_correctness_rounds: Vec<Vec<K>>,
    pub address_opening_value: K,
    pub read_values_at_cycle: Vec<K>,
    pub table_opening_values: Vec<K>,
}

pub struct Stage1ShoutProof {
    pub cycle_point: Vec<K>,
    pub fetch_proof: ShoutChannelProof,
    pub decode_proof: ShoutChannelProof,
    pub alu_proof: ShoutChannelProof,
    pub eq4_proof: ShoutChannelProof,
    pub decode_handoff_values: Vec<K>,
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
    pub cycle_point: Vec<K>,
    pub reg_addr_point: Vec<K>,
    pub reg_val_at_point: K,
    pub ram_addr_point: Vec<K>,
    pub ram_val_at_point: K,
    pub gamma_reg: K,
    pub reg_rw_batched_rounds: Vec<Vec<K>>,
    pub reg_val_from_inc_claim: K,
    pub reg_val_from_inc_rounds: Vec<Vec<K>>,
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
    pub ram_addr_correctness: Vec<AddressCorrectnessProof>,
    pub link_claims: Stage2LinkClaims,
    pub gamma_twist_link: K,
    pub linkage_batch_value: K,
    pub lane_values_at_twist: Vec<K>,
    pub handoff_values_at_twist: Vec<K>,
}

pub struct LaneShiftProof {
    pub source_point: Vec<K>,
    pub claimed_shift_values: [K; 3],
    pub reduction_rounds: Vec<Vec<K>>,
}

pub struct RowBindingClaim {
    pub row_index: usize,
    pub row_bits: Vec<bool>,
    pub opened_values: Vec<K>,
}

pub struct Stage3Proof {
    pub shift_proof: LaneShiftProof,
    pub shift_opening_values: [K; 5],
    pub continuity_check_value: K,
    pub start_boundary_values: [K; 2],
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
    pub(crate) fn expect_matches(&self, expected: &Self) -> Result<(), SimpleKernelError> {
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
    pub prepared_steps: Vec<StepInput>,
    pub public_steps: Vec<PublicStep>,
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

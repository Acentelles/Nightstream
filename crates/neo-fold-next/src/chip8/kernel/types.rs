//! Owns the CHIP-8 simple-kernel proof, witness, and artifact surface types.
//! It does not own proving logic, transcript scheduling, or digest construction.

use neo_math::{F, K};

use crate::chip8::{
    stage1::{ShoutChannelExecutionProof, Stage1ShoutProof},
    stage2::{Stage2RamExecutionProof, Stage2RegisterExecutionProof, Stage2TwistProof},
    stage3::Stage3Proof,
};
use crate::opening::TimeOpeningProofSummary;
use crate::proof::{PublicStep, StepInput};

use super::bridge::{Chip8BridgeChunkProofBundle, Chip8BridgeChunkRelationWitness};
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

#[derive(Clone)]
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
    pub bridge_chunk_proof: Chip8BridgeChunkProofBundle,
    pub time_opening_summary: TimeOpeningProofSummary,
}

#[derive(Clone)]
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
}

#[derive(Clone)]
struct KernelExecutionObligationWitnesses {
    reads: KernelReadWitness,
    twists: KernelTwistWitness,
    shift: KernelShiftWitness,
}

#[derive(Clone)]
struct KernelExecutionHandoffWitness {
    bridge_chunk_transitions: Vec<Chip8BridgeChunkRelationWitness>,
}

#[derive(Clone)]
pub struct KernelExecutionRelationWitness {
    obligations: KernelExecutionObligationWitnesses,
    handoff: KernelExecutionHandoffWitness,
}

#[derive(Clone, Debug)]
pub struct KernelReadWitness {
    fetch: ShoutChannelExecutionProof,
    decode: ShoutChannelExecutionProof,
    alu: ShoutChannelExecutionProof,
    eq4: ShoutChannelExecutionProof,
}

impl KernelReadWitness {
    pub fn new(
        fetch: ShoutChannelExecutionProof,
        decode: ShoutChannelExecutionProof,
        alu: ShoutChannelExecutionProof,
        eq4: ShoutChannelExecutionProof,
    ) -> Self {
        Self {
            fetch,
            decode,
            alu,
            eq4,
        }
    }

    pub fn fetch(&self) -> &ShoutChannelExecutionProof {
        &self.fetch
    }

    pub fn fetch_mut(&mut self) -> &mut ShoutChannelExecutionProof {
        &mut self.fetch
    }

    pub fn decode(&self) -> &ShoutChannelExecutionProof {
        &self.decode
    }

    pub fn decode_mut(&mut self) -> &mut ShoutChannelExecutionProof {
        &mut self.decode
    }

    pub fn alu(&self) -> &ShoutChannelExecutionProof {
        &self.alu
    }

    pub fn alu_mut(&mut self) -> &mut ShoutChannelExecutionProof {
        &mut self.alu
    }

    pub fn eq4(&self) -> &ShoutChannelExecutionProof {
        &self.eq4
    }

    pub fn eq4_mut(&mut self) -> &mut ShoutChannelExecutionProof {
        &mut self.eq4
    }
}

#[derive(Clone, Debug)]
pub struct KernelTwistWitness {
    register: Stage2RegisterExecutionProof,
    memory: Stage2RamExecutionProof,
}

impl KernelTwistWitness {
    pub fn new(register: Stage2RegisterExecutionProof, memory: Stage2RamExecutionProof) -> Self {
        Self { register, memory }
    }

    pub fn register(&self) -> &Stage2RegisterExecutionProof {
        &self.register
    }

    pub fn register_mut(&mut self) -> &mut Stage2RegisterExecutionProof {
        &mut self.register
    }

    pub fn memory(&self) -> &Stage2RamExecutionProof {
        &self.memory
    }

    pub fn memory_mut(&mut self) -> &mut Stage2RamExecutionProof {
        &mut self.memory
    }
}

#[derive(Clone, Debug)]
pub struct KernelShiftWitness {
    reduction_rounds: Vec<Vec<K>>,
}

impl KernelShiftWitness {
    pub fn new(reduction_rounds: Vec<Vec<K>>) -> Self {
        Self { reduction_rounds }
    }

    pub fn reduction_rounds(&self) -> &[Vec<K>] {
        &self.reduction_rounds
    }

    pub fn reduction_rounds_mut(&mut self) -> &mut [Vec<K>] {
        &mut self.reduction_rounds
    }
}

impl KernelExecutionRelationWitness {
    pub(crate) fn new(
        reads: KernelReadWitness,
        twists: KernelTwistWitness,
        shift: KernelShiftWitness,
        bridge_chunk_transitions: Vec<Chip8BridgeChunkRelationWitness>,
    ) -> Self {
        Self {
            obligations: KernelExecutionObligationWitnesses { reads, twists, shift },
            handoff: KernelExecutionHandoffWitness {
                bridge_chunk_transitions,
            },
        }
    }

    pub(crate) fn from_simple_kernel_proof(native_proof: SimpleKernelProof) -> Result<Self, SimpleKernelError> {
        let SimpleKernelProof {
            commitments: _,
            lane_commitments: _,
            fetch_ra_commitments: _,
            decode_ra_commitments: _,
            alu_ra_commitments: _,
            eq4_ra_commitments: _,
            rom_table_commitments: _,
            decode_table_commitments: _,
            alu_table_commitments: _,
            eq4_table_commitments: _,
            decode_handoff_commitments: _,
            reg_twist_commitments: _,
            ram_twist_commitments: _,
            meta_pub: _,
            stage1,
            stage2,
            stage3,
            kernel_opening_manifest: _,
            root_opening_manifest,
            lane_opening_proofs: _,
            fetch_ra_opening_proofs: _,
            decode_ra_opening_proofs: _,
            alu_ra_opening_proofs: _,
            eq4_ra_opening_proofs: _,
            rom_table_opening_proofs: _,
            decode_table_opening_proofs: _,
            alu_table_opening_proofs: _,
            eq4_table_opening_proofs: _,
            decode_handoff_opening_proofs: _,
            reg_twist_opening_proofs: _,
            ram_twist_opening_proofs: _,
            opening_refinement_summary: _,
            joint_opening_summary: _,
            joint_opening_fold_bucket_proofs: _,
            bridge_chunk_proof,
            time_opening_summary: _,
        } = native_proof;
        if root_opening_manifest != RootOpeningManifest::new() {
            return Err(SimpleKernelError::OpeningFailed(
                "simple kernel export requires a canonical empty root opening manifest".into(),
            ));
        }
        let reads = KernelReadWitness::new(
            ShoutChannelExecutionProof {
                sumcheck_rounds: stage1.fetch_proof.sumcheck_rounds,
                addr_correctness_rounds: stage1.fetch_proof.addr_correctness_rounds,
            },
            ShoutChannelExecutionProof {
                sumcheck_rounds: stage1.decode_proof.sumcheck_rounds,
                addr_correctness_rounds: stage1.decode_proof.addr_correctness_rounds,
            },
            ShoutChannelExecutionProof {
                sumcheck_rounds: stage1.alu_proof.sumcheck_rounds,
                addr_correctness_rounds: stage1.alu_proof.addr_correctness_rounds,
            },
            ShoutChannelExecutionProof {
                sumcheck_rounds: stage1.eq4_proof.sumcheck_rounds,
                addr_correctness_rounds: stage1.eq4_proof.addr_correctness_rounds,
            },
        );
        let twists = KernelTwistWitness::new(
            Stage2RegisterExecutionProof {
                reg_rw_batched_rounds: stage2.reg_rw_batched_rounds,
                reg_val_from_inc_rounds: stage2.reg_val_from_inc_rounds,
                reg_addr_correctness: stage2.reg_addr_correctness,
                reg_ra_y_target_rounds: stage2.reg_ra_y_target_proof.rounds,
                reg_wa_addr_target_rounds: stage2.reg_wa_addr_target_proof.rounds,
                reg_write_x_target_rounds: stage2.reg_write_x_target_proof.rounds,
                reg_write_i_target_rounds: stage2.reg_write_i_target_proof.rounds,
            },
            Stage2RamExecutionProof {
                ram_rw_batched_rounds: stage2.ram_rw_batched_rounds,
                ram_val_from_inc_rounds: stage2.ram_val_from_inc_rounds,
                ram_raf_read_rounds: stage2.ram_raf_read_rounds,
                ram_raf_write_rounds: stage2.ram_raf_write_rounds,
                ram_read_target_rounds: stage2.ram_read_target_proof.rounds,
                ram_write_target_rounds: stage2.ram_write_target_proof.rounds,
                ram_write_matches_x_zero_rounds: stage2.ram_write_matches_x_zero_proof.rounds,
                ram_idle_mem_zero_rounds: stage2.ram_idle_mem_zero_proof.rounds,
                ram_addr_correctness: stage2.ram_addr_correctness,
            },
        );
        let shift = KernelShiftWitness::new(stage3.shift_proof.reduction_rounds);
        Ok(Self::new(reads, twists, shift, bridge_chunk_proof.chunk_transitions))
    }

    pub fn reads(&self) -> &KernelReadWitness {
        &self.obligations.reads
    }

    pub fn reads_mut(&mut self) -> &mut KernelReadWitness {
        &mut self.obligations.reads
    }

    pub fn twists(&self) -> &KernelTwistWitness {
        &self.obligations.twists
    }

    pub fn twists_mut(&mut self) -> &mut KernelTwistWitness {
        &mut self.obligations.twists
    }

    pub fn shift(&self) -> &KernelShiftWitness {
        &self.obligations.shift
    }

    pub fn shift_mut(&mut self) -> &mut KernelShiftWitness {
        &mut self.obligations.shift
    }

    pub fn bridge_chunk_transitions(&self) -> &[Chip8BridgeChunkRelationWitness] {
        &self.handoff.bridge_chunk_transitions
    }

    pub fn bridge_chunk_transitions_mut(&mut self) -> &mut [Chip8BridgeChunkRelationWitness] {
        &mut self.handoff.bridge_chunk_transitions
    }
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

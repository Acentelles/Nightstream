//! Owns the WASM semantic kernel proof and IO surface types.

use crate::proof::{PublicStep, RunProof, StepInput};
use crate::wasm::ir::WasmStepTrace;
use crate::wasm::stage1::{Stage1BinaryProof, Stage1EqzProof};
use crate::wasm::stage2::Stage2StackProof;
use crate::wasm::stage3::Stage3BoundaryProof;

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct WasmKernelPublicInput {
    pub transcript_seed: Vec<u8>,
}

pub struct WasmKernelProverInput<'a> {
    pub public: WasmKernelPublicInput,
    pub trace: &'a [WasmStepTrace],
}

pub struct WasmKernelVerifierInput<'a> {
    pub public: WasmKernelPublicInput,
    pub trace: &'a [WasmStepTrace],
}

pub struct WasmKernelOutput {
    pub prepared_steps: Vec<StepInput>,
    pub public_steps: Vec<PublicStep>,
    pub opening_summary: WasmKernelOpeningSummary,
}

pub struct WasmStage1ProofSet {
    pub eqz: Stage1EqzProof,
    pub binary: Vec<Stage1BinaryProof>,
}

pub struct WasmKernelProof {
    pub stage1: WasmStage1ProofSet,
    pub stage2: Stage2StackProof,
    pub stage3: Stage3BoundaryProof,
    pub opening_summary: WasmKernelOpeningSummary,
}

pub struct WasmKernelRunProof {
    pub kernel: WasmKernelProof,
    pub main_run: RunProof,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct WasmKernelSelectedRowRef {
    pub logical_index: u64,
    pub value_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct WasmKernelStage1OpeningSummary {
    pub rows_digest: [u8; 32],
    pub eqz_row_count: u64,
    pub binary_channel_count: u64,
    pub row_count: u64,
    pub first_row: Option<WasmKernelSelectedRowRef>,
    pub last_row: Option<WasmKernelSelectedRowRef>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct WasmKernelStage2OpeningSummary {
    pub rows_digest: [u8; 32],
    pub family_claims_digest: [u8; 32],
    pub row_count: u64,
    pub family_count: u64,
    pub final_slot_count: u64,
    pub first_row: Option<WasmKernelSelectedRowRef>,
    pub last_row: Option<WasmKernelSelectedRowRef>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct WasmKernelStage3OpeningSummary {
    pub rows_digest: [u8; 32],
    pub row_count: u64,
    pub has_final_boundary: bool,
    pub first_row: Option<WasmKernelSelectedRowRef>,
    pub last_row: Option<WasmKernelSelectedRowRef>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct WasmKernelPreparedStepSummary {
    pub steps_digest: [u8; 32],
    pub step_count: u64,
    pub first_step: Option<WasmKernelSelectedRowRef>,
    pub last_step: Option<WasmKernelSelectedRowRef>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct WasmKernelOpeningSummary {
    pub stage1: WasmKernelStage1OpeningSummary,
    pub stage2: WasmKernelStage2OpeningSummary,
    pub stage3: WasmKernelStage3OpeningSummary,
    pub prepared_steps: WasmKernelPreparedStepSummary,
    pub digest: [u8; 32],
}

#[derive(Debug)]
pub enum WasmKernelError {
    InvalidWitness(String),
    Stage1(String),
    Stage2(String),
    Stage3(String),
    Bridge(String),
}

impl core::fmt::Display for WasmKernelError {
    fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
        match self {
            Self::InvalidWitness(msg) => write!(f, "invalid witness: {msg}"),
            Self::Stage1(msg) => write!(f, "stage1 failed: {msg}"),
            Self::Stage2(msg) => write!(f, "stage2 failed: {msg}"),
            Self::Stage3(msg) => write!(f, "stage3 failed: {msg}"),
            Self::Bridge(msg) => write!(f, "bridge failed: {msg}"),
        }
    }
}

impl std::error::Error for WasmKernelError {}

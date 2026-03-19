//! Owns the typed proof and frontend artifact boundary.
//!
//! Ownership:
//! - the active SuperNeo backend spine types (`StepInput`, `RunProof`, `PackagedProof`)
//! - multi-VM frontend outputs (`StepBuild`)
//! - per-step collected extension data and per-session extension accumulation
//! - future extension-proof and time-opening placeholders
//!
//! It does not own:
//! - the `Π_CCS -> Π_RLC -> Π_DEC` protocol logic
//! - VM-specific trace execution
//! - time-opening proof construction

use neo_ajtai::Commitment;
use neo_ccs::{CcsClaim, CcsWitness, CeClaim, Mat};
use neo_math::{F, K};
use neo_reductions::api::{PiCcsProof, RotRho};
use serde::{Deserialize, Serialize};

#[derive(Clone, Copy, Debug, Eq, PartialEq, Ord, PartialOrd, Hash, Serialize, Deserialize)]
pub enum ExtensionFamily {
    BytecodeFetch,
    InstructionSemanticsLookup,
    RegisterHistory,
    RamHistory,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct StepInput {
    pub label: String,
    pub mcs: CcsClaim<Commitment, F>,
    pub witness: CcsWitness<F>,
    pub deferred_extensions: Vec<ExtensionFamily>,
}

impl StepInput {
    pub fn instance(&self) -> PublicStep {
        PublicStep {
            label: self.label.clone(),
            mcs: self.mcs.clone(),
            deferred_extensions: self.deferred_extensions.clone(),
        }
    }

    pub fn public(&self) -> PublicStep {
        self.instance()
    }
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PublicStep {
    pub label: String,
    pub mcs: CcsClaim<Commitment, F>,
    pub deferred_extensions: Vec<ExtensionFamily>,
}

#[derive(Clone, Debug, Default, Serialize, Deserialize)]
pub struct Carry {
    pub claims: Vec<CeClaim<Commitment, F, K>>,
    pub witnesses: Vec<Mat<F>>,
}

impl Carry {
    pub fn is_empty(&self) -> bool {
        self.claims.is_empty() && self.witnesses.is_empty()
    }
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PiRlcArtifact {
    pub rhos: Vec<RotRho>,
    pub parent: CeClaim<Commitment, F, K>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PiDecArtifact {
    pub children: Vec<CeClaim<Commitment, F, K>>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct StepProof {
    pub step: PublicStep,
    pub ccs_outputs: Vec<CeClaim<Commitment, F, K>>,
    pub ccs_proof: PiCcsProof,
    pub rlc: PiRlcArtifact,
    pub dec: PiDecArtifact,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct StepResult {
    pub proof: StepProof,
    pub next_main: Carry,
}

#[derive(Clone, Debug, Default, Serialize, Deserialize)]
pub struct RunProof {
    pub steps: Vec<StepProof>,
    pub final_main_claims: Vec<CeClaim<Commitment, F, K>>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PublicStatement {
    pub steps: Vec<PublicStep>,
    pub final_main_claims: Vec<CeClaim<Commitment, F, K>>,
    pub digest: [u8; 32],
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Ord, PartialOrd, Hash, Serialize, Deserialize)]
pub enum OpeningSource {
    MainLane,
    BytecodeFetch,
    RegisterHistory,
    RamHistory,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Ord, PartialOrd, Hash, Serialize, Deserialize)]
pub enum OpeningDomain {
    Cpu,
    Mem,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct OpeningClaim {
    pub source: OpeningSource,
    pub domain: OpeningDomain,
    pub point: Vec<K>,
    pub ordinal: u64,
    pub column_ids: Vec<u32>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct BytecodeFetchRecord {
    pub pc: u16,
    pub opcode: u16,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub enum RegisterBank {
    V,
    I,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct RegisterAccessRecord {
    pub bank: RegisterBank,
    pub index: u8,
    pub value: u16,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct RamAccessRecord {
    pub addr: u16,
    pub value: u8,
}

#[derive(Clone, Debug, Default, Serialize, Deserialize)]
pub struct StepExtensionData {
    pub bytecode_fetch: Option<BytecodeFetchRecord>,
    pub register_reads: Vec<RegisterAccessRecord>,
    pub register_writes: Vec<RegisterAccessRecord>,
    pub ram_reads: Vec<RamAccessRecord>,
    pub ram_writes: Vec<RamAccessRecord>,
}

#[derive(Clone, Debug, Default, Serialize, Deserialize)]
pub struct SessionExtensionAccumulator {
    pub steps: Vec<StepExtensionData>,
}

impl SessionExtensionAccumulator {
    pub fn push(&mut self, step: StepExtensionData) {
        self.steps.push(step);
    }
}

#[derive(Clone, Debug, Default, Serialize, Deserialize)]
pub struct BytecodeFetchProof {
    pub record_count: usize,
    pub point: Vec<K>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Default, Serialize, Deserialize)]
pub struct RegisterHistoryProof {
    pub read_count: usize,
    pub write_count: usize,
    pub point: Vec<K>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Default, Serialize, Deserialize)]
pub struct RamHistoryProof {
    pub read_count: usize,
    pub write_count: usize,
    pub point: Vec<K>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Default, Serialize, Deserialize)]
pub struct SessionExtensionProofs {
    pub bytecode_fetch: Option<BytecodeFetchProof>,
    pub register_history: Option<RegisterHistoryProof>,
    pub ram_history: Option<RamHistoryProof>,
    pub opening_claims: Vec<OpeningClaim>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct TimeOpeningGroupSummary {
    pub sources: Vec<OpeningSource>,
    pub domain: OpeningDomain,
    pub point: Vec<K>,
    pub claim_indices: Vec<usize>,
    pub coefficients: Vec<K>,
    pub group_digest: [u8; 32],
    pub reduced_digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct TimeOpeningProofSummary {
    pub manifest_digest: [u8; 32],
    pub proof_digest: [u8; 32],
    pub groups: Vec<TimeOpeningGroupSummary>,
    pub can_unify: bool,
    pub unified_domain: OpeningDomain,
    pub unified_point: Vec<K>,
    pub unified_digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct FinalProof {
    pub session: RunProof,
    pub extensions: SessionExtensionProofs,
    pub time_opening: Option<TimeOpeningProofSummary>,
    pub statement_digest: [u8; 32],
    pub proof_digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PackagedProof {
    pub statement: PublicStatement,
    pub proof: FinalProof,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct StepBuild {
    pub prepared: StepInput,
    pub public_step: PublicStep,
    pub extension_data: StepExtensionData,
    #[serde(skip_serializing, skip_deserializing, default)]
    pub kernel_aux: Option<crate::chip8::kernel::KernelStepAux>,
}

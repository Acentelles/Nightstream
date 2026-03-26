//! Owns the final public RV64IM proof API above the simple-kernel path.

use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};

use super::proof_bridge::{
    kernel_claim_bundle_from_statement_and_kernel, kernel_proof_bundle_from_packaged, proof_statement_from_kernel,
};
use super::proof_verify::verify_kernel_output_from_public_proof;
use super::proof_witness::{
    proof_witness_bundle_from_kernel_output, Rv64imKernelClaimProofBundle, Rv64imKernelClaimSummaryBundle,
    Rv64imKernelOpeningProofBundle, Rv64imKernelOpeningSummaryBundle, Rv64imProofWitnessBundle,
    Rv64imStageClaimDigestBundle, Rv64imStageClaimProofBundle, Rv64imStagePackageDigestBundle,
    Rv64imStagePackageProofBundle, Rv64imStageWitnessProofBundle, Rv64imTraceProofBundle,
};
use super::{
    build_simple_kernel_witness, prove_packaged_simple_kernel, SimpleKernelError, SimpleKernelProverInput,
    SimpleKernelPublicInput,
};
use crate::proof::PackagedProof;

pub type Rv64imProofInput = SimpleKernelPublicInput;

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imProofStatement {
    pub root_params_id: [u8; 32],
    pub stage_claims_digest: [u8; 32],
    pub stage_packages_digest: [u8; 32],
    pub kernel_opening_digest: [u8; 32],
    pub prepared_step_bindings_digest: [u8; 32],
    pub execution_digest: [u8; 32],
    pub final_state_digest: [u8; 32],
    pub transcript_final_digest: [u8; 32],
    pub main_lane_statement_digest: [u8; 32],
    pub public_step_count: u64,
    pub final_pc: u64,
    pub halted: bool,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imAcceptedProofStatementBinding {
    pub proof_statement_digest: [u8; 32],
    pub kernel_opening_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imAcceptedProofMainLaneBinding {
    pub main_lane_statement_digest: [u8; 32],
    pub main_lane_proof_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imAcceptedProofTerminalBinding {
    pub final_state_digest: [u8; 32],
    pub public_step_count: u64,
    pub final_pc: u64,
    pub halted: bool,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imAcceptedProofClaim {
    pub root_params_id: [u8; 32],
    pub statement: Rv64imAcceptedProofStatementBinding,
    pub main_lane: Rv64imAcceptedProofMainLaneBinding,
    pub terminal: Rv64imAcceptedProofTerminalBinding,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imMainLaneClaimBinding {
    pub statement_digest: [u8; 32],
    pub proof_digest: [u8; 32],
    pub public_step_count: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imMainLaneClaim {
    pub root_params_id: [u8; 32],
    pub binding: Rv64imMainLaneClaimBinding,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imKernelOpeningStageClaimBinding {
    pub stage_claims_digest: [u8; 32],
    pub stage_packages_digest: [u8; 32],
    pub kernel_opening_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imKernelOpeningTerminalClaimBinding {
    pub prepared_step_bindings_digest: [u8; 32],
    pub execution_digest: [u8; 32],
    pub transcript_final_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imKernelOpeningClaim {
    pub root_params_id: [u8; 32],
    pub stages: Rv64imKernelOpeningStageClaimBinding,
    pub terminal: Rv64imKernelOpeningTerminalClaimBinding,
    pub public_step_count: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imJointOpeningClaimBinding {
    pub proof_statement_digest: [u8; 32],
    pub main_lane_claim_digest: [u8; 32],
    pub kernel_opening_claim_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imJointOpeningClaim {
    pub root_params_id: [u8; 32],
    pub binding: Rv64imJointOpeningClaimBinding,
    pub public_step_count: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imRoot0StageClaimBinding {
    pub stage1_digest: [u8; 32],
    pub stage2_digest: [u8; 32],
    pub stage3_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imRoot0TerminalClaimBinding {
    pub root0_digest: [u8; 32],
    pub execution_digest: [u8; 32],
    pub final_state_digest: [u8; 32],
    pub transcript_final_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imRoot0Claim {
    pub root_params_id: [u8; 32],
    pub stages: Rv64imRoot0StageClaimBinding,
    pub terminal: Rv64imRoot0TerminalClaimBinding,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imKernelClaimBundle {
    pub accepted: Rv64imAcceptedProofClaim,
    pub main_lane: Rv64imMainLaneClaim,
    pub opening: Rv64imKernelOpeningClaim,
    pub joint_opening: Rv64imJointOpeningClaim,
    pub root0: Rv64imRoot0Claim,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imMainLaneProofBinding {
    pub statement_digest: [u8; 32],
    pub proof_digest: [u8; 32],
    pub public_step_count: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imMainLaneProofBundle {
    pub binding: Rv64imMainLaneProofBinding,
    pub digest: [u8; 32],
    pub(super) packaged: PackagedProof,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imMainLaneProofSummaryBundle {
    pub binding: Rv64imMainLaneProofBinding,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imJointOpeningProofBundle {
    pub proof_statement_digest: [u8; 32],
    pub public_step_count: u64,
    pub main_lane: Rv64imMainLaneProofSummaryBundle,
    pub kernel_opening: Rv64imKernelOpeningSummaryBundle,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imRoot0CommitmentBundle {
    pub stage_claims: Rv64imStageClaimDigestBundle,
    pub stage_packages: Rv64imStagePackageDigestBundle,
    pub kernel_opening: Rv64imKernelOpeningSummaryBundle,
    pub kernel_claims: Rv64imKernelClaimSummaryBundle,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imKernelProofBundle {
    pub root_params_id: [u8; 32],
    pub trace: Rv64imTraceProofBundle,
    pub stages: Rv64imStageWitnessProofBundle,
    pub stage_claims: Rv64imStageClaimProofBundle,
    pub stage_packages: Rv64imStagePackageProofBundle,
    pub kernel_opening: Rv64imKernelOpeningProofBundle,
    pub kernel_claims: Rv64imKernelClaimProofBundle,
    pub main_lane: Rv64imMainLaneProofBundle,
    pub joint_opening: Rv64imJointOpeningProofBundle,
    pub root0_commitment: Rv64imRoot0CommitmentBundle,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imProof {
    pub claim: Rv64imKernelClaimBundle,
    pub statement: Rv64imProofStatement,
    pub kernel: Rv64imKernelProofBundle,
}

impl Rv64imProofStatement {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/proof_statement");
        tr.append_message(b"rv64im/proof_statement/root_params_id", &self.root_params_id);
        tr.append_message(b"rv64im/proof_statement/stage_claims_digest", &self.stage_claims_digest);
        tr.append_message(
            b"rv64im/proof_statement/stage_packages_digest",
            &self.stage_packages_digest,
        );
        tr.append_message(
            b"rv64im/proof_statement/kernel_opening_digest",
            &self.kernel_opening_digest,
        );
        tr.append_message(
            b"rv64im/proof_statement/prepared_step_bindings_digest",
            &self.prepared_step_bindings_digest,
        );
        tr.append_message(b"rv64im/proof_statement/execution_digest", &self.execution_digest);
        tr.append_message(b"rv64im/proof_statement/final_state_digest", &self.final_state_digest);
        tr.append_message(
            b"rv64im/proof_statement/transcript_final_digest",
            &self.transcript_final_digest,
        );
        tr.append_message(
            b"rv64im/proof_statement/main_lane_statement_digest",
            &self.main_lane_statement_digest,
        );
        tr.append_u64s(
            b"rv64im/proof_statement/meta",
            &[self.public_step_count, self.final_pc, self.halted as u64],
        );
        tr.digest32()
    }
}

impl Rv64imAcceptedProofClaim {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/accepted_proof_claim");
        tr.append_message(b"rv64im/accepted_proof/root_params_id", &self.root_params_id);
        tr.append_message(b"rv64im/accepted_proof/statement_digest", &self.statement.digest);
        tr.append_message(b"rv64im/accepted_proof/main_lane_digest", &self.main_lane.digest);
        tr.append_message(b"rv64im/accepted_proof/terminal_digest", &self.terminal.digest);
        tr.digest32()
    }
}

impl Rv64imAcceptedProofStatementBinding {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/accepted_proof_statement_binding");
        tr.append_message(
            b"rv64im/accepted_proof_statement_binding/proof_statement_digest",
            &self.proof_statement_digest,
        );
        tr.append_message(
            b"rv64im/accepted_proof_statement_binding/kernel_opening_digest",
            &self.kernel_opening_digest,
        );
        tr.digest32()
    }
}

impl Rv64imAcceptedProofMainLaneBinding {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/accepted_proof_main_lane_binding");
        tr.append_message(
            b"rv64im/accepted_proof_main_lane_binding/main_lane_statement_digest",
            &self.main_lane_statement_digest,
        );
        tr.append_message(
            b"rv64im/accepted_proof_main_lane_binding/main_lane_proof_digest",
            &self.main_lane_proof_digest,
        );
        tr.digest32()
    }
}

impl Rv64imAcceptedProofTerminalBinding {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/accepted_proof_terminal_binding");
        tr.append_message(
            b"rv64im/accepted_proof_terminal_binding/final_state_digest",
            &self.final_state_digest,
        );
        tr.append_u64s(
            b"rv64im/accepted_proof_terminal_binding/meta",
            &[self.public_step_count, self.final_pc, self.halted as u64],
        );
        tr.digest32()
    }
}

impl Rv64imMainLaneClaim {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/main_lane_claim");
        tr.append_message(b"rv64im/main_lane_claim/root_params_id", &self.root_params_id);
        tr.append_message(b"rv64im/main_lane_claim/binding_digest", &self.binding.digest);
        tr.digest32()
    }
}

impl Rv64imMainLaneClaimBinding {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/main_lane_claim_binding");
        tr.append_message(
            b"rv64im/main_lane_claim_binding/statement_digest",
            &self.statement_digest,
        );
        tr.append_message(b"rv64im/main_lane_claim_binding/proof_digest", &self.proof_digest);
        tr.append_u64s(b"rv64im/main_lane_claim_binding/meta", &[self.public_step_count]);
        tr.digest32()
    }
}

impl Rv64imKernelOpeningClaim {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_opening_claim");
        tr.append_message(b"rv64im/kernel_opening_claim/root_params_id", &self.root_params_id);
        tr.append_message(b"rv64im/kernel_opening_claim/stages_digest", &self.stages.digest);
        tr.append_message(b"rv64im/kernel_opening_claim/terminal_digest", &self.terminal.digest);
        tr.append_u64s(b"rv64im/kernel_opening_claim/meta", &[self.public_step_count]);
        tr.digest32()
    }
}

impl Rv64imKernelOpeningStageClaimBinding {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_opening_stage_claim_binding");
        tr.append_message(
            b"rv64im/kernel_opening_stage_claim_binding/stage_claims_digest",
            &self.stage_claims_digest,
        );
        tr.append_message(
            b"rv64im/kernel_opening_stage_claim_binding/stage_packages_digest",
            &self.stage_packages_digest,
        );
        tr.append_message(
            b"rv64im/kernel_opening_stage_claim_binding/kernel_opening_digest",
            &self.kernel_opening_digest,
        );
        tr.digest32()
    }
}

impl Rv64imKernelOpeningTerminalClaimBinding {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_opening_terminal_claim_binding");
        tr.append_message(
            b"rv64im/kernel_opening_terminal_claim_binding/prepared_step_bindings_digest",
            &self.prepared_step_bindings_digest,
        );
        tr.append_message(
            b"rv64im/kernel_opening_terminal_claim_binding/execution_digest",
            &self.execution_digest,
        );
        tr.append_message(
            b"rv64im/kernel_opening_terminal_claim_binding/transcript_final_digest",
            &self.transcript_final_digest,
        );
        tr.digest32()
    }
}

impl Rv64imJointOpeningClaim {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/joint_opening_claim");
        tr.append_message(b"rv64im/joint_opening_claim/root_params_id", &self.root_params_id);
        tr.append_message(b"rv64im/joint_opening_claim/binding_digest", &self.binding.digest);
        tr.append_u64s(b"rv64im/joint_opening_claim/meta", &[self.public_step_count]);
        tr.digest32()
    }
}

impl Rv64imJointOpeningClaimBinding {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/joint_opening_claim_binding");
        tr.append_message(
            b"rv64im/joint_opening_claim_binding/proof_statement_digest",
            &self.proof_statement_digest,
        );
        tr.append_message(
            b"rv64im/joint_opening_claim_binding/main_lane_claim_digest",
            &self.main_lane_claim_digest,
        );
        tr.append_message(
            b"rv64im/joint_opening_claim_binding/kernel_opening_claim_digest",
            &self.kernel_opening_claim_digest,
        );
        tr.digest32()
    }
}

impl Rv64imRoot0Claim {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root0_claim");
        tr.append_message(b"rv64im/root0_claim/root_params_id", &self.root_params_id);
        tr.append_message(b"rv64im/root0_claim/stages_digest", &self.stages.digest);
        tr.append_message(b"rv64im/root0_claim/terminal_digest", &self.terminal.digest);
        tr.digest32()
    }
}

impl Rv64imRoot0StageClaimBinding {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root0_stage_claim_binding");
        tr.append_message(b"rv64im/root0_stage_claim_binding/stage1_digest", &self.stage1_digest);
        tr.append_message(b"rv64im/root0_stage_claim_binding/stage2_digest", &self.stage2_digest);
        tr.append_message(b"rv64im/root0_stage_claim_binding/stage3_digest", &self.stage3_digest);
        tr.digest32()
    }
}

impl Rv64imRoot0TerminalClaimBinding {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root0_terminal_claim_binding");
        tr.append_message(b"rv64im/root0_terminal_claim_binding/root0_digest", &self.root0_digest);
        tr.append_message(
            b"rv64im/root0_terminal_claim_binding/execution_digest",
            &self.execution_digest,
        );
        tr.append_message(
            b"rv64im/root0_terminal_claim_binding/final_state_digest",
            &self.final_state_digest,
        );
        tr.append_message(
            b"rv64im/root0_terminal_claim_binding/transcript_final_digest",
            &self.transcript_final_digest,
        );
        tr.digest32()
    }
}

impl Rv64imKernelClaimBundle {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_claim_bundle");
        tr.append_message(b"rv64im/kernel_claim_bundle/accepted_digest", &self.accepted.digest);
        tr.append_message(b"rv64im/kernel_claim_bundle/main_lane_digest", &self.main_lane.digest);
        tr.append_message(b"rv64im/kernel_claim_bundle/opening_digest", &self.opening.digest);
        tr.append_message(
            b"rv64im/kernel_claim_bundle/joint_opening_digest",
            &self.joint_opening.digest,
        );
        tr.append_message(b"rv64im/kernel_claim_bundle/root0_digest", &self.root0.digest);
        tr.digest32()
    }
}

impl Rv64imMainLaneProofBinding {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/main_lane_proof_binding");
        tr.append_message(
            b"rv64im/main_lane_proof_binding/statement_digest",
            &self.statement_digest,
        );
        tr.append_message(b"rv64im/main_lane_proof_binding/proof_digest", &self.proof_digest);
        tr.append_u64s(b"rv64im/main_lane_proof_binding/meta", &[self.public_step_count]);
        tr.digest32()
    }
}

impl Rv64imMainLaneProofBundle {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/main_lane_proof_bundle");
        tr.append_message(b"rv64im/main_lane_proof_bundle/binding_digest", &self.binding.digest);
        tr.digest32()
    }

    pub fn statement_digest(&self) -> [u8; 32] {
        self.binding.statement_digest
    }

    pub fn proof_digest(&self) -> [u8; 32] {
        self.binding.proof_digest
    }

    pub fn public_step_count(&self) -> u64 {
        self.binding.public_step_count
    }

    pub fn summary(&self) -> Rv64imMainLaneProofSummaryBundle {
        let summary = Rv64imMainLaneProofSummaryBundle {
            binding: self.binding.clone(),
            digest: [0; 32],
        };
        Rv64imMainLaneProofSummaryBundle {
            digest: summary.expected_digest(),
            ..summary
        }
    }
}

impl Rv64imMainLaneProofSummaryBundle {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/main_lane_proof_summary_bundle");
        tr.append_message(
            b"rv64im/main_lane_proof_summary_bundle/binding_digest",
            &self.binding.digest,
        );
        tr.digest32()
    }
}

impl Rv64imJointOpeningProofBundle {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/joint_opening_proof_bundle");
        tr.append_message(
            b"rv64im/joint_opening_proof_bundle/proof_statement_digest",
            &self.proof_statement_digest,
        );
        tr.append_u64s(b"rv64im/joint_opening_proof_bundle/meta", &[self.public_step_count]);
        tr.append_message(
            b"rv64im/joint_opening_proof_bundle/main_lane_digest",
            &self.main_lane.digest,
        );
        tr.append_message(
            b"rv64im/joint_opening_proof_bundle/kernel_opening_digest",
            &self.kernel_opening.digest,
        );
        tr.digest32()
    }
}

impl Rv64imRoot0CommitmentBundle {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root0_commitment_bundle");
        tr.append_message(
            b"rv64im/root0_commitment_bundle/stage_claims_digest",
            &self.stage_claims.digest,
        );
        tr.append_message(
            b"rv64im/root0_commitment_bundle/stage_packages_digest",
            &self.stage_packages.digest,
        );
        tr.append_message(
            b"rv64im/root0_commitment_bundle/kernel_opening_digest",
            &self.kernel_opening.digest,
        );
        tr.append_message(
            b"rv64im/root0_commitment_bundle/kernel_claims_digest",
            &self.kernel_claims.digest,
        );
        tr.digest32()
    }
}

impl Rv64imKernelProofBundle {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_proof_bundle");
        tr.append_message(b"rv64im/kernel_proof_bundle/root_params_id", &self.root_params_id);
        tr.append_message(b"rv64im/kernel_proof_bundle/trace_digest", &self.trace.digest);
        tr.append_message(b"rv64im/kernel_proof_bundle/stages_digest", &self.stages.digest);
        tr.append_message(
            b"rv64im/kernel_proof_bundle/stage_claims_digest",
            &self.stage_claims.digest,
        );
        tr.append_message(
            b"rv64im/kernel_proof_bundle/stage_packages_digest",
            &self.stage_packages.digest,
        );
        tr.append_message(
            b"rv64im/kernel_proof_bundle/kernel_opening_digest",
            &self.kernel_opening.digest,
        );
        tr.append_message(
            b"rv64im/kernel_proof_bundle/root0_digest",
            &self.kernel_claims.root0_digest(),
        );
        tr.append_message(
            b"rv64im/kernel_proof_bundle/prepared_step_bindings_digest",
            &self.kernel_claims.prepared_step_bindings_digest(),
        );
        tr.append_message(b"rv64im/kernel_proof_bundle/main_lane_digest", &self.main_lane.digest);
        tr.append_message(
            b"rv64im/kernel_proof_bundle/joint_opening_bundle_digest",
            &self.joint_opening.digest,
        );
        tr.append_message(
            b"rv64im/kernel_proof_bundle/root0_commitment_bundle_digest",
            &self.root0_commitment.digest,
        );
        tr.digest32()
    }
}

pub fn build_rv64im_proof_witness(input: &Rv64imProofInput) -> Result<Rv64imProofWitnessBundle, SimpleKernelError> {
    Ok(proof_witness_bundle_from_kernel_output(&build_simple_kernel_witness(
        input,
    )?))
}

pub fn prove_rv64im_proof(
    input: &Rv64imProofInput,
) -> Result<(Rv64imProofWitnessBundle, Rv64imProof), SimpleKernelError> {
    let prover = SimpleKernelProverInput { public: input.clone() };
    let (kernel, packaged) = prove_packaged_simple_kernel(&prover)?;
    let statement = proof_statement_from_kernel(&kernel, &packaged);
    let claim = kernel_claim_bundle_from_statement_and_kernel(&statement, &packaged);
    Ok((
        proof_witness_bundle_from_kernel_output(&kernel),
        Rv64imProof {
            claim,
            statement,
            kernel: kernel_proof_bundle_from_packaged(&packaged),
        },
    ))
}

pub fn verify_rv64im_proof(
    input: &Rv64imProofInput,
    proof: &Rv64imProof,
) -> Result<Rv64imProofWitnessBundle, SimpleKernelError> {
    let kernel = verify_kernel_output_from_public_proof(input, proof)?;
    Ok(proof_witness_bundle_from_kernel_output(&kernel))
}

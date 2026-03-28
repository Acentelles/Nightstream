//! Owns the final public RV64IM proof API above the simple-kernel path.

use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};
use std::time::Instant;

use crate::proof::PackagedProof;

use super::main_lane_artifact::build_simple_kernel_main_lane_artifact_from_summary;
use super::proof_bridge::proof_from_public_kernel_and_artifact;
use super::proof_verify::{
    validate_public_proof_against_input_with_perf, verify_kernel_output_from_public_proof_with_perf,
    verify_public_kernel_output_from_public_proof_with_perf,
};
use super::proof_witness::{
    proof_witness_bundle_from_public_kernel_and_trace_stages, Rv64imKernelClaimProofBundle,
    Rv64imKernelOpeningProofBundle, Rv64imProofWitnessBundle, Rv64imStageClaimProofBundle,
    Rv64imStagePackageProofBundle, Rv64imStageWitnessProjectionBundle, Rv64imTraceProjectionBundle,
};
use super::simple::{build_public_simple_kernel_output_and_witness_with_perf, build_root_main_lane_packaged_proof};
use super::{
    RootLaneColumns, RootLaneCommitmentSummaryArtifact, Rv64imProofProvePerf, Rv64imPublicProofVerifyPerf,
    SimpleKernelError, SimpleKernelPublicInput,
};

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
    pub main_lane_surface_digest: [u8; 32],
    pub root_lane_columns_digest: [u8; 32],
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
    pub main_lane_bundle_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imAcceptedProofTerminalBinding {
    pub final_state_digest: [u8; 32],
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
    pub main_lane_bundle_digest: [u8; 32],
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

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imMainLaneProofBinding {
    pub root_lane_columns_digest: [u8; 32],
    pub root_lane_commitment_digest: [u8; 32],
    pub public_step_count: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imMainLaneProofBundle {
    pub binding: Rv64imMainLaneProofBinding,
    pub statement_digest: [u8; 32],
    pub proof_digest: [u8; 32],
    pub packaged: PackagedProof,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imMainLaneProofSummaryBundle {
    pub binding: Rv64imMainLaneProofBinding,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imKernelProofBundle {
    pub root_params_id: [u8; 32],
    pub trace: Rv64imTraceProjectionBundle,
    pub stages: Rv64imStageWitnessProjectionBundle,
    pub stage_claims: Rv64imStageClaimProofBundle,
    pub stage_packages: Rv64imStagePackageProofBundle,
    pub kernel_opening: Rv64imKernelOpeningProofBundle,
    pub kernel_claims: Rv64imKernelClaimProofBundle,
    pub root_lane_columns: RootLaneColumns,
    pub root_lane_commitment: RootLaneCommitmentSummaryArtifact,
    pub main_lane: Rv64imMainLaneProofBundle,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imProof {
    pub claim: Rv64imKernelClaimBundle,
    pub statement: Rv64imProofStatement,
    pub kernel: Rv64imKernelProofBundle,
    pub witness: Rv64imProofWitnessBundle,
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
            b"rv64im/proof_statement/main_lane_surface_digest",
            &self.main_lane_surface_digest,
        );
        tr.append_message(
            b"rv64im/proof_statement/root_lane_columns_digest",
            &self.root_lane_columns_digest,
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
            b"rv64im/accepted_proof_main_lane_binding/main_lane_bundle_digest",
            &self.main_lane_bundle_digest,
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
            &[self.final_pc, self.halted as u64],
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
            b"rv64im/main_lane_claim_binding/main_lane_bundle_digest",
            &self.main_lane_bundle_digest,
        );
        tr.digest32()
    }
}

impl Rv64imKernelOpeningClaim {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_opening_claim");
        tr.append_message(b"rv64im/kernel_opening_claim/root_params_id", &self.root_params_id);
        tr.append_message(b"rv64im/kernel_opening_claim/stages_digest", &self.stages.digest);
        tr.append_message(b"rv64im/kernel_opening_claim/terminal_digest", &self.terminal.digest);
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
            b"rv64im/main_lane_proof_binding/root_lane_columns_digest",
            &self.root_lane_columns_digest,
        );
        tr.append_message(
            b"rv64im/main_lane_proof_binding/root_lane_commitment_digest",
            &self.root_lane_commitment_digest,
        );
        tr.append_u64s(b"rv64im/main_lane_proof_binding/meta", &[self.public_step_count]);
        tr.digest32()
    }
}

impl Rv64imMainLaneProofBundle {
    pub(super) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/main_lane_proof_bundle");
        tr.append_message(b"rv64im/main_lane_proof_bundle/binding_digest", &self.binding.digest);
        tr.append_message(
            b"rv64im/main_lane_proof_bundle/statement_digest",
            &self.statement_digest,
        );
        tr.append_message(b"rv64im/main_lane_proof_bundle/proof_digest", &self.proof_digest);
        tr.digest32()
    }

    pub fn root_lane_columns_digest(&self) -> [u8; 32] {
        self.binding.root_lane_columns_digest
    }

    pub fn root_lane_commitment_digest(&self) -> [u8; 32] {
        self.binding.root_lane_commitment_digest
    }

    pub fn public_step_count(&self) -> u64 {
        self.binding.public_step_count
    }

    pub fn statement_digest(&self) -> [u8; 32] {
        self.statement_digest
    }

    pub fn proof_digest(&self) -> [u8; 32] {
        self.proof_digest
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
            b"rv64im/kernel_proof_bundle/kernel_claims_digest",
            &self.kernel_claims.digest,
        );
        tr.append_message(
            b"rv64im/kernel_proof_bundle/root_lane_columns_digest",
            &self.root_lane_columns.digest,
        );
        tr.append_message(
            b"rv64im/kernel_proof_bundle/root_lane_commitment_digest",
            &self.root_lane_commitment.digest,
        );
        tr.append_message(b"rv64im/kernel_proof_bundle/main_lane_digest", &self.main_lane.digest);
        tr.digest32()
    }
}

pub fn build_rv64im_audit_witness_bundle(
    input: &Rv64imProofInput,
) -> Result<Rv64imProofWitnessBundle, SimpleKernelError> {
    let ((public, sidecar), _) = build_public_simple_kernel_output_and_witness_with_perf(input)?;
    proof_witness_bundle_from_public_kernel_and_trace_stages(&public, &sidecar.trace, &sidecar.stages)
}

fn prove_rv64im_public_proof_and_sidecar_with_perf(
    input: &Rv64imProofInput,
) -> Result<
    (
        (
            super::simple::PublicSimpleKernelOutput,
            super::simple::PublicSimpleKernelWitnessSidecar,
        ),
        Rv64imProof,
        Rv64imProofProvePerf,
    ),
    SimpleKernelError,
> {
    let total_started = Instant::now();
    let ((kernel, sidecar), simple_kernel) = build_public_simple_kernel_output_and_witness_with_perf(input)?;
    let main_lane_started = Instant::now();
    let main_lane =
        build_simple_kernel_main_lane_artifact_from_summary(&kernel.root_lane_columns, &kernel.root_lane_commitment)?;
    let root_main_lane = build_root_main_lane_packaged_proof(&sidecar.trace.execution_rows)?;
    let main_lane_ms = main_lane_started.elapsed().as_secs_f64() * 1_000.0;
    let export_started = Instant::now();
    let witness = proof_witness_bundle_from_public_kernel_and_trace_stages(&kernel, &sidecar.trace, &sidecar.stages)?;
    let proof = proof_from_public_kernel_and_artifact(&kernel, &main_lane, root_main_lane, witness)?;
    let public_export_ms = export_started.elapsed().as_secs_f64() * 1_000.0;
    let perf = Rv64imProofProvePerf {
        simple_kernel,
        main_lane_ms,
        public_export_ms,
        total_ms: total_started.elapsed().as_secs_f64() * 1_000.0,
    };
    Ok(((kernel, sidecar), proof, perf))
}

pub fn prove_rv64im_public_proof(input: &Rv64imProofInput) -> Result<Rv64imProof, SimpleKernelError> {
    let (proof, _) = prove_rv64im_public_proof_with_perf(input)?;
    Ok(proof)
}

pub fn prove_rv64im_public_proof_with_perf(
    input: &Rv64imProofInput,
) -> Result<(Rv64imProof, Rv64imProofProvePerf), SimpleKernelError> {
    let ((_, _), proof, perf) = prove_rv64im_public_proof_and_sidecar_with_perf(input)?;
    Ok((proof, perf))
}

pub fn prove_rv64im_audit_proof(
    input: &Rv64imProofInput,
) -> Result<(Rv64imProofWitnessBundle, Rv64imProof), SimpleKernelError> {
    let (witness, proof, _) = prove_rv64im_audit_proof_with_perf(input)?;
    Ok((witness, proof))
}

pub fn prove_rv64im_audit_proof_with_perf(
    input: &Rv64imProofInput,
) -> Result<(Rv64imProofWitnessBundle, Rv64imProof, Rv64imProofProvePerf), SimpleKernelError> {
    let ((_, _), proof, perf) = prove_rv64im_public_proof_and_sidecar_with_perf(input)?;
    Ok((proof.witness.clone(), proof, perf))
}

pub fn verify_rv64im_public_proof(proof: &Rv64imProof) -> Result<(), SimpleKernelError> {
    verify_rv64im_public_proof_with_perf(proof).map(|_| ())
}

pub fn verify_rv64im_public_proof_with_perf(
    proof: &Rv64imProof,
) -> Result<Rv64imPublicProofVerifyPerf, SimpleKernelError> {
    let (_, perf) = verify_public_kernel_output_from_public_proof_with_perf(proof)?;
    Ok(perf)
}

pub fn validate_rv64im_public_proof_against_input(
    input: &Rv64imProofInput,
    proof: &Rv64imProof,
) -> Result<(), SimpleKernelError> {
    validate_rv64im_public_proof_against_input_with_perf(input, proof).map(|_| ())
}

pub fn validate_rv64im_public_proof_against_input_with_perf(
    input: &Rv64imProofInput,
    proof: &Rv64imProof,
) -> Result<Rv64imPublicProofVerifyPerf, SimpleKernelError> {
    validate_public_proof_against_input_with_perf(input, proof)
}

pub fn verify_rv64im_audit_proof(proof: &Rv64imProof) -> Result<Rv64imProofWitnessBundle, SimpleKernelError> {
    let (witness, _) = verify_rv64im_audit_proof_with_perf(proof)?;
    Ok(witness)
}

pub fn verify_rv64im_audit_proof_with_perf(
    proof: &Rv64imProof,
) -> Result<(Rv64imProofWitnessBundle, Rv64imPublicProofVerifyPerf), SimpleKernelError> {
    let (_, perf) = verify_kernel_output_from_public_proof_with_perf(proof)?;
    Ok((proof.witness.clone(), perf))
}

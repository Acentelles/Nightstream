//! Owns the final public RV64IM proof API above the simple-kernel path.

use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};

use super::{
    build_simple_kernel_witness, prove_packaged_simple_kernel, verify_packaged_simple_kernel, SimpleKernelError,
    SimpleKernelKernelClaimBundle, SimpleKernelOpeningBundle, SimpleKernelOutput, SimpleKernelPackagedProof,
    SimpleKernelProof, SimpleKernelProverInput, SimpleKernelPublicInput, SimpleKernelStageClaimBundle,
    SimpleKernelStagePackageBundle, SimpleKernelStageWitnessBundle, SimpleKernelTraceWitness,
    SimpleKernelVerifierInput,
};
use crate::proof::PackagedProof;

pub type Rv64imProofInput = SimpleKernelPublicInput;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imProofWitnessBundle {
    pub kernel: SimpleKernelOutput,
}

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
pub struct Rv64imAcceptedProofClaim {
    pub root_params_id: [u8; 32],
    pub proof_statement_digest: [u8; 32],
    pub kernel_opening_digest: [u8; 32],
    pub main_lane_statement_digest: [u8; 32],
    pub main_lane_proof_digest: [u8; 32],
    pub final_state_digest: [u8; 32],
    pub public_step_count: u64,
    pub final_pc: u64,
    pub halted: bool,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imMainLaneClaim {
    pub root_params_id: [u8; 32],
    pub statement_digest: [u8; 32],
    pub proof_digest: [u8; 32],
    pub public_step_count: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imKernelOpeningClaim {
    pub root_params_id: [u8; 32],
    pub stage_claims_digest: [u8; 32],
    pub stage_packages_digest: [u8; 32],
    pub kernel_opening_digest: [u8; 32],
    pub prepared_step_bindings_digest: [u8; 32],
    pub execution_digest: [u8; 32],
    pub transcript_final_digest: [u8; 32],
    pub public_step_count: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imJointOpeningClaim {
    pub root_params_id: [u8; 32],
    pub proof_statement_digest: [u8; 32],
    pub main_lane_claim_digest: [u8; 32],
    pub kernel_opening_claim_digest: [u8; 32],
    pub public_step_count: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imRoot0Claim {
    pub root_params_id: [u8; 32],
    pub root0_digest: [u8; 32],
    pub stage1_digest: [u8; 32],
    pub stage2_digest: [u8; 32],
    pub stage3_digest: [u8; 32],
    pub execution_digest: [u8; 32],
    pub final_state_digest: [u8; 32],
    pub transcript_final_digest: [u8; 32],
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
pub struct Rv64imMainLaneProofBundle {
    pub statement_digest: [u8; 32],
    pub proof_digest: [u8; 32],
    pub public_step_count: u64,
    pub digest: [u8; 32],
    packaged: PackagedProof,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imJointOpeningProofBundle {
    pub claim: Rv64imJointOpeningClaim,
    pub proof_statement_digest: [u8; 32],
    pub main_lane_bundle_digest: [u8; 32],
    pub kernel_opening_bundle_digest: [u8; 32],
    pub public_step_count: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imRoot0CommitmentBundle {
    pub claim: Rv64imRoot0Claim,
    pub stage_claim_bundle_digest: [u8; 32],
    pub stage_package_bundle_digest: [u8; 32],
    pub kernel_opening_bundle_digest: [u8; 32],
    pub kernel_claim_bundle_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imKernelOpeningProofBundle {
    pub claim_digest: [u8; 32],
    pub bindings_digest: [u8; 32],
    pub prepared_steps_digest: [u8; 32],
    pub digest: [u8; 32],
    opening: SimpleKernelOpeningBundle,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imKernelClaimProofBundle {
    pub prepared_step_bindings_digest: [u8; 32],
    pub root0_digest: [u8; 32],
    pub execution_digest: [u8; 32],
    pub final_state_digest: [u8; 32],
    pub transcript_final_digest: [u8; 32],
    pub final_pc: u64,
    pub halted: bool,
    pub digest: [u8; 32],
    claims: SimpleKernelKernelClaimBundle,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imStageClaimProofBundle {
    pub stage1_digest: [u8; 32],
    pub stage2_digest: [u8; 32],
    pub stage3_digest: [u8; 32],
    pub transcript_digest: [u8; 32],
    pub execution_digest: [u8; 32],
    pub digest: [u8; 32],
    claims: SimpleKernelStageClaimBundle,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imStagePackageProofBundle {
    pub stage1_digest: [u8; 32],
    pub stage2_digest: [u8; 32],
    pub stage3_digest: [u8; 32],
    pub digest: [u8; 32],
    packages: SimpleKernelStagePackageBundle,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imKernelProofBundle {
    pub root_params_id: [u8; 32],
    pub trace: SimpleKernelTraceWitness,
    pub stages: SimpleKernelStageWitnessBundle,
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
    fn expected_digest(&self) -> [u8; 32] {
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
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/accepted_proof_claim");
        tr.append_message(b"rv64im/accepted_proof/root_params_id", &self.root_params_id);
        tr.append_message(
            b"rv64im/accepted_proof/proof_statement_digest",
            &self.proof_statement_digest,
        );
        tr.append_message(
            b"rv64im/accepted_proof/kernel_opening_digest",
            &self.kernel_opening_digest,
        );
        tr.append_message(
            b"rv64im/accepted_proof/main_lane_statement_digest",
            &self.main_lane_statement_digest,
        );
        tr.append_message(
            b"rv64im/accepted_proof/main_lane_proof_digest",
            &self.main_lane_proof_digest,
        );
        tr.append_message(b"rv64im/accepted_proof/final_state_digest", &self.final_state_digest);
        tr.append_u64s(
            b"rv64im/accepted_proof/meta",
            &[self.public_step_count, self.final_pc, self.halted as u64],
        );
        tr.digest32()
    }
}

impl Rv64imMainLaneClaim {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/main_lane_claim");
        tr.append_message(b"rv64im/main_lane_claim/root_params_id", &self.root_params_id);
        tr.append_message(b"rv64im/main_lane_claim/statement_digest", &self.statement_digest);
        tr.append_message(b"rv64im/main_lane_claim/proof_digest", &self.proof_digest);
        tr.append_u64s(b"rv64im/main_lane_claim/meta", &[self.public_step_count]);
        tr.digest32()
    }
}

impl Rv64imKernelOpeningClaim {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_opening_claim");
        tr.append_message(b"rv64im/kernel_opening_claim/root_params_id", &self.root_params_id);
        tr.append_message(
            b"rv64im/kernel_opening_claim/stage_claims_digest",
            &self.stage_claims_digest,
        );
        tr.append_message(
            b"rv64im/kernel_opening_claim/stage_packages_digest",
            &self.stage_packages_digest,
        );
        tr.append_message(
            b"rv64im/kernel_opening_claim/kernel_opening_digest",
            &self.kernel_opening_digest,
        );
        tr.append_message(
            b"rv64im/kernel_opening_claim/prepared_step_bindings_digest",
            &self.prepared_step_bindings_digest,
        );
        tr.append_message(b"rv64im/kernel_opening_claim/execution_digest", &self.execution_digest);
        tr.append_message(
            b"rv64im/kernel_opening_claim/transcript_final_digest",
            &self.transcript_final_digest,
        );
        tr.append_u64s(b"rv64im/kernel_opening_claim/meta", &[self.public_step_count]);
        tr.digest32()
    }
}

impl Rv64imJointOpeningClaim {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/joint_opening_claim");
        tr.append_message(b"rv64im/joint_opening_claim/root_params_id", &self.root_params_id);
        tr.append_message(
            b"rv64im/joint_opening_claim/proof_statement_digest",
            &self.proof_statement_digest,
        );
        tr.append_message(
            b"rv64im/joint_opening_claim/main_lane_claim_digest",
            &self.main_lane_claim_digest,
        );
        tr.append_message(
            b"rv64im/joint_opening_claim/kernel_opening_claim_digest",
            &self.kernel_opening_claim_digest,
        );
        tr.append_u64s(b"rv64im/joint_opening_claim/meta", &[self.public_step_count]);
        tr.digest32()
    }
}

impl Rv64imRoot0Claim {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root0_claim");
        tr.append_message(b"rv64im/root0_claim/root_params_id", &self.root_params_id);
        tr.append_message(b"rv64im/root0_claim/root0_digest", &self.root0_digest);
        tr.append_message(b"rv64im/root0_claim/stage1_digest", &self.stage1_digest);
        tr.append_message(b"rv64im/root0_claim/stage2_digest", &self.stage2_digest);
        tr.append_message(b"rv64im/root0_claim/stage3_digest", &self.stage3_digest);
        tr.append_message(b"rv64im/root0_claim/execution_digest", &self.execution_digest);
        tr.append_message(b"rv64im/root0_claim/final_state_digest", &self.final_state_digest);
        tr.append_message(
            b"rv64im/root0_claim/transcript_final_digest",
            &self.transcript_final_digest,
        );
        tr.digest32()
    }
}

impl Rv64imKernelClaimBundle {
    fn expected_digest(&self) -> [u8; 32] {
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

impl Rv64imMainLaneProofBundle {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/main_lane_proof_bundle");
        tr.append_message(
            b"rv64im/main_lane_proof_bundle/statement_digest",
            &self.statement_digest,
        );
        tr.append_message(b"rv64im/main_lane_proof_bundle/proof_digest", &self.proof_digest);
        tr.append_u64s(b"rv64im/main_lane_proof_bundle/meta", &[self.public_step_count]);
        tr.digest32()
    }

    pub fn statement_digest(&self) -> [u8; 32] {
        self.statement_digest
    }

    pub fn proof_digest(&self) -> [u8; 32] {
        self.proof_digest
    }

    pub fn public_step_count(&self) -> u64 {
        self.public_step_count
    }
}

impl Rv64imJointOpeningProofBundle {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/joint_opening_proof_bundle");
        tr.append_message(b"rv64im/joint_opening_proof_bundle/claim_digest", &self.claim.digest);
        tr.append_message(
            b"rv64im/joint_opening_proof_bundle/proof_statement_digest",
            &self.proof_statement_digest,
        );
        tr.append_message(
            b"rv64im/joint_opening_proof_bundle/main_lane_bundle_digest",
            &self.main_lane_bundle_digest,
        );
        tr.append_message(
            b"rv64im/joint_opening_proof_bundle/kernel_opening_bundle_digest",
            &self.kernel_opening_bundle_digest,
        );
        tr.append_u64s(b"rv64im/joint_opening_proof_bundle/meta", &[self.public_step_count]);
        tr.digest32()
    }
}

impl Rv64imRoot0CommitmentBundle {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root0_commitment_bundle");
        tr.append_message(b"rv64im/root0_commitment_bundle/claim_digest", &self.claim.digest);
        tr.append_message(
            b"rv64im/root0_commitment_bundle/stage_claim_bundle_digest",
            &self.stage_claim_bundle_digest,
        );
        tr.append_message(
            b"rv64im/root0_commitment_bundle/stage_package_bundle_digest",
            &self.stage_package_bundle_digest,
        );
        tr.append_message(
            b"rv64im/root0_commitment_bundle/kernel_opening_bundle_digest",
            &self.kernel_opening_bundle_digest,
        );
        tr.append_message(
            b"rv64im/root0_commitment_bundle/kernel_claim_bundle_digest",
            &self.kernel_claim_bundle_digest,
        );
        tr.digest32()
    }
}

impl Rv64imKernelOpeningProofBundle {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_opening_proof_bundle");
        tr.append_message(b"rv64im/kernel_opening_proof_bundle/claim_digest", &self.claim_digest);
        tr.append_message(
            b"rv64im/kernel_opening_proof_bundle/bindings_digest",
            &self.bindings_digest,
        );
        tr.append_message(
            b"rv64im/kernel_opening_proof_bundle/prepared_steps_digest",
            &self.prepared_steps_digest,
        );
        tr.digest32()
    }

    pub fn claim_digest(&self) -> [u8; 32] {
        self.claim_digest
    }

    pub fn bindings_digest(&self) -> [u8; 32] {
        self.bindings_digest
    }

    pub fn prepared_steps_digest(&self) -> [u8; 32] {
        self.prepared_steps_digest
    }
}

impl Rv64imKernelClaimProofBundle {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_claim_proof_bundle");
        tr.append_message(
            b"rv64im/kernel_claim_proof_bundle/prepared_step_bindings_digest",
            &self.prepared_step_bindings_digest,
        );
        tr.append_message(b"rv64im/kernel_claim_proof_bundle/root0_digest", &self.root0_digest);
        tr.append_message(
            b"rv64im/kernel_claim_proof_bundle/execution_digest",
            &self.execution_digest,
        );
        tr.append_message(
            b"rv64im/kernel_claim_proof_bundle/final_state_digest",
            &self.final_state_digest,
        );
        tr.append_message(
            b"rv64im/kernel_claim_proof_bundle/transcript_final_digest",
            &self.transcript_final_digest,
        );
        tr.append_u64s(
            b"rv64im/kernel_claim_proof_bundle/meta",
            &[self.final_pc, self.halted as u64],
        );
        tr.digest32()
    }

    pub fn prepared_step_bindings_digest(&self) -> [u8; 32] {
        self.prepared_step_bindings_digest
    }

    pub fn root0_digest(&self) -> [u8; 32] {
        self.root0_digest
    }

    pub fn final_state_digest(&self) -> [u8; 32] {
        self.final_state_digest
    }
}

impl Rv64imStageClaimProofBundle {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_claim_proof_bundle");
        tr.append_message(b"rv64im/stage_claim_proof_bundle/stage1_digest", &self.stage1_digest);
        tr.append_message(b"rv64im/stage_claim_proof_bundle/stage2_digest", &self.stage2_digest);
        tr.append_message(b"rv64im/stage_claim_proof_bundle/stage3_digest", &self.stage3_digest);
        tr.append_message(
            b"rv64im/stage_claim_proof_bundle/transcript_digest",
            &self.transcript_digest,
        );
        tr.append_message(
            b"rv64im/stage_claim_proof_bundle/execution_digest",
            &self.execution_digest,
        );
        tr.digest32()
    }

    pub fn stage1_digest(&self) -> [u8; 32] {
        self.stage1_digest
    }

    pub fn stage2_digest(&self) -> [u8; 32] {
        self.stage2_digest
    }

    pub fn stage3_digest(&self) -> [u8; 32] {
        self.stage3_digest
    }
}

impl Rv64imStagePackageProofBundle {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_package_proof_bundle");
        tr.append_message(b"rv64im/stage_package_proof_bundle/stage1_digest", &self.stage1_digest);
        tr.append_message(b"rv64im/stage_package_proof_bundle/stage2_digest", &self.stage2_digest);
        tr.append_message(b"rv64im/stage_package_proof_bundle/stage3_digest", &self.stage3_digest);
        tr.digest32()
    }

    pub fn stage1_digest(&self) -> [u8; 32] {
        self.stage1_digest
    }

    pub fn stage2_digest(&self) -> [u8; 32] {
        self.stage2_digest
    }

    pub fn stage3_digest(&self) -> [u8; 32] {
        self.stage3_digest
    }
}

impl Rv64imKernelProofBundle {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_proof_bundle");
        tr.append_message(b"rv64im/kernel_proof_bundle/root_params_id", &self.root_params_id);
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
            &self.kernel_claims.root0_digest,
        );
        tr.append_message(
            b"rv64im/kernel_proof_bundle/prepared_step_bindings_digest",
            &self.kernel_claims.prepared_step_bindings_digest,
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

fn proof_statement_from_kernel(
    kernel: &SimpleKernelOutput,
    packaged: &SimpleKernelPackagedProof,
) -> Rv64imProofStatement {
    let statement = Rv64imProofStatement {
        root_params_id: packaged.kernel.root_params_id,
        stage_claims_digest: packaged.kernel.stage_claims.digest,
        stage_packages_digest: packaged.kernel.stage_packages.digest,
        kernel_opening_digest: packaged.kernel.kernel_opening.digest,
        prepared_step_bindings_digest: packaged.kernel.kernel_claims.prepared_step_bindings.digest,
        execution_digest: packaged.kernel.kernel_claims.kernel.execution_digest,
        final_state_digest: packaged.kernel.kernel_claims.kernel.final_state_digest,
        transcript_final_digest: packaged.kernel.kernel_claims.kernel.transcript_final_digest,
        main_lane_statement_digest: packaged.main_lane.statement.digest,
        public_step_count: kernel.public_steps.len() as u64,
        final_pc: packaged.kernel.kernel_claims.kernel.final_pc,
        halted: packaged.kernel.kernel_claims.kernel.halted,
        digest: [0; 32],
    };
    Rv64imProofStatement {
        digest: statement.expected_digest(),
        ..statement
    }
}

fn accepted_proof_claim_from_statement_and_kernel(
    statement: &Rv64imProofStatement,
    packaged: &SimpleKernelPackagedProof,
) -> Rv64imAcceptedProofClaim {
    let claim = Rv64imAcceptedProofClaim {
        root_params_id: packaged.kernel.root_params_id,
        proof_statement_digest: statement.digest,
        kernel_opening_digest: packaged.kernel.kernel_opening.digest,
        main_lane_statement_digest: packaged.main_lane.statement.digest,
        main_lane_proof_digest: packaged.main_lane.proof.proof_digest,
        final_state_digest: packaged.kernel.kernel_claims.kernel.final_state_digest,
        public_step_count: statement.public_step_count,
        final_pc: statement.final_pc,
        halted: statement.halted,
        digest: [0; 32],
    };
    Rv64imAcceptedProofClaim {
        digest: claim.expected_digest(),
        ..claim
    }
}

fn main_lane_claim_from_kernel(
    statement: &Rv64imProofStatement,
    packaged: &SimpleKernelPackagedProof,
) -> Rv64imMainLaneClaim {
    let claim = Rv64imMainLaneClaim {
        root_params_id: packaged.kernel.root_params_id,
        statement_digest: packaged.main_lane.statement.digest,
        proof_digest: packaged.main_lane.proof.proof_digest,
        public_step_count: statement.public_step_count,
        digest: [0; 32],
    };
    Rv64imMainLaneClaim {
        digest: claim.expected_digest(),
        ..claim
    }
}

fn kernel_opening_claim_from_kernel(
    statement: &Rv64imProofStatement,
    packaged: &SimpleKernelPackagedProof,
) -> Rv64imKernelOpeningClaim {
    let claim = Rv64imKernelOpeningClaim {
        root_params_id: packaged.kernel.root_params_id,
        stage_claims_digest: packaged.kernel.stage_claims.digest,
        stage_packages_digest: packaged.kernel.stage_packages.digest,
        kernel_opening_digest: packaged.kernel.kernel_opening.digest,
        prepared_step_bindings_digest: packaged.kernel.kernel_claims.prepared_step_bindings.digest,
        execution_digest: packaged.kernel.kernel_claims.kernel.execution_digest,
        transcript_final_digest: packaged.kernel.kernel_claims.kernel.transcript_final_digest,
        public_step_count: statement.public_step_count,
        digest: [0; 32],
    };
    Rv64imKernelOpeningClaim {
        digest: claim.expected_digest(),
        ..claim
    }
}

fn joint_opening_claim_from_claims(
    statement: &Rv64imProofStatement,
    packaged: &SimpleKernelPackagedProof,
    main_lane: &Rv64imMainLaneClaim,
    opening: &Rv64imKernelOpeningClaim,
) -> Rv64imJointOpeningClaim {
    let claim = Rv64imJointOpeningClaim {
        root_params_id: packaged.kernel.root_params_id,
        proof_statement_digest: statement.digest,
        main_lane_claim_digest: main_lane.digest,
        kernel_opening_claim_digest: opening.digest,
        public_step_count: statement.public_step_count,
        digest: [0; 32],
    };
    Rv64imJointOpeningClaim {
        digest: claim.expected_digest(),
        ..claim
    }
}

fn root0_claim_from_kernel(packaged: &SimpleKernelPackagedProof) -> Rv64imRoot0Claim {
    let summary = &packaged.kernel.kernel_claims.kernel;
    let claim = Rv64imRoot0Claim {
        root_params_id: packaged.kernel.root_params_id,
        root0_digest: summary.root0_digest,
        stage1_digest: summary.stage1_digest,
        stage2_digest: summary.stage2_digest,
        stage3_digest: summary.stage3_digest,
        execution_digest: summary.execution_digest,
        final_state_digest: summary.final_state_digest,
        transcript_final_digest: summary.transcript_final_digest,
        digest: [0; 32],
    };
    Rv64imRoot0Claim {
        digest: claim.expected_digest(),
        ..claim
    }
}

fn main_lane_proof_bundle_from_packaged(packaged: &SimpleKernelPackagedProof) -> Rv64imMainLaneProofBundle {
    let bundle = Rv64imMainLaneProofBundle {
        statement_digest: packaged.main_lane.statement.digest,
        proof_digest: packaged.main_lane.proof.proof_digest,
        public_step_count: packaged.main_lane.statement.steps.len() as u64,
        digest: [0; 32],
        packaged: packaged.main_lane.clone(),
    };
    Rv64imMainLaneProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

fn joint_opening_proof_bundle_from_components(
    statement: &Rv64imProofStatement,
    claim: &Rv64imJointOpeningClaim,
    main_lane: &Rv64imMainLaneProofBundle,
    kernel_opening: &Rv64imKernelOpeningProofBundle,
) -> Rv64imJointOpeningProofBundle {
    let bundle = Rv64imJointOpeningProofBundle {
        claim: claim.clone(),
        proof_statement_digest: statement.digest,
        main_lane_bundle_digest: main_lane.digest,
        kernel_opening_bundle_digest: kernel_opening.digest,
        public_step_count: main_lane.public_step_count,
        digest: [0; 32],
    };
    Rv64imJointOpeningProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

fn root0_commitment_bundle_from_components(
    claim: &Rv64imRoot0Claim,
    stage_claims: &Rv64imStageClaimProofBundle,
    stage_packages: &Rv64imStagePackageProofBundle,
    kernel_opening: &Rv64imKernelOpeningProofBundle,
    kernel_claims: &Rv64imKernelClaimProofBundle,
) -> Rv64imRoot0CommitmentBundle {
    let bundle = Rv64imRoot0CommitmentBundle {
        claim: claim.clone(),
        stage_claim_bundle_digest: stage_claims.digest,
        stage_package_bundle_digest: stage_packages.digest,
        kernel_opening_bundle_digest: kernel_opening.digest,
        kernel_claim_bundle_digest: kernel_claims.digest,
        digest: [0; 32],
    };
    Rv64imRoot0CommitmentBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

fn kernel_opening_proof_bundle_from_packaged(packaged: &SimpleKernelPackagedProof) -> Rv64imKernelOpeningProofBundle {
    let bundle = Rv64imKernelOpeningProofBundle {
        claim_digest: packaged.kernel.kernel_opening.claim.digest,
        bindings_digest: packaged.kernel.kernel_opening.bindings.digest,
        prepared_steps_digest: packaged.kernel.kernel_opening.prepared_steps.digest,
        digest: [0; 32],
        opening: packaged.kernel.kernel_opening.clone(),
    };
    Rv64imKernelOpeningProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

fn kernel_claim_proof_bundle_from_packaged(packaged: &SimpleKernelPackagedProof) -> Rv64imKernelClaimProofBundle {
    let summary = &packaged.kernel.kernel_claims.kernel;
    let bundle = Rv64imKernelClaimProofBundle {
        prepared_step_bindings_digest: packaged.kernel.kernel_claims.prepared_step_bindings.digest,
        root0_digest: summary.root0_digest,
        execution_digest: summary.execution_digest,
        final_state_digest: summary.final_state_digest,
        transcript_final_digest: summary.transcript_final_digest,
        final_pc: summary.final_pc,
        halted: summary.halted,
        digest: [0; 32],
        claims: packaged.kernel.kernel_claims.clone(),
    };
    Rv64imKernelClaimProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

fn stage_claim_proof_bundle_from_packaged(packaged: &SimpleKernelPackagedProof) -> Rv64imStageClaimProofBundle {
    let bundle = Rv64imStageClaimProofBundle {
        stage1_digest: packaged.kernel.stage_claims.stage1.commitment.digest,
        stage2_digest: packaged.kernel.stage_claims.stage2.commitment.digest,
        stage3_digest: packaged.kernel.stage_claims.stage3.commitment.digest,
        transcript_digest: packaged.kernel.stage_claims.transcript.commitment.digest,
        execution_digest: packaged.kernel.stage_claims.execution_digest,
        digest: [0; 32],
        claims: packaged.kernel.stage_claims.clone(),
    };
    Rv64imStageClaimProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

fn stage_package_proof_bundle_from_packaged(packaged: &SimpleKernelPackagedProof) -> Rv64imStagePackageProofBundle {
    let bundle = Rv64imStagePackageProofBundle {
        stage1_digest: packaged.kernel.stage_packages.stage1.digest,
        stage2_digest: packaged.kernel.stage_packages.stage2.digest,
        stage3_digest: packaged.kernel.stage_packages.stage3.digest,
        digest: [0; 32],
        packages: packaged.kernel.stage_packages.clone(),
    };
    Rv64imStagePackageProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

fn kernel_claim_bundle_from_statement_and_kernel(
    statement: &Rv64imProofStatement,
    packaged: &SimpleKernelPackagedProof,
) -> Rv64imKernelClaimBundle {
    let accepted = accepted_proof_claim_from_statement_and_kernel(statement, packaged);
    let main_lane = main_lane_claim_from_kernel(statement, packaged);
    let opening = kernel_opening_claim_from_kernel(statement, packaged);
    let claim = Rv64imKernelClaimBundle {
        accepted,
        main_lane: main_lane.clone(),
        opening: opening.clone(),
        joint_opening: joint_opening_claim_from_claims(statement, packaged, &main_lane, &opening),
        root0: root0_claim_from_kernel(packaged),
        digest: [0; 32],
    };
    Rv64imKernelClaimBundle {
        digest: claim.expected_digest(),
        ..claim
    }
}

fn kernel_proof_bundle_from_packaged(packaged: &SimpleKernelPackagedProof) -> Rv64imKernelProofBundle {
    let statement = Rv64imProofStatement {
        root_params_id: packaged.kernel.root_params_id,
        stage_claims_digest: packaged.kernel.stage_claims.digest,
        stage_packages_digest: packaged.kernel.stage_packages.digest,
        kernel_opening_digest: packaged.kernel.kernel_opening.digest,
        prepared_step_bindings_digest: packaged.kernel.kernel_claims.prepared_step_bindings.digest,
        execution_digest: packaged.kernel.kernel_claims.kernel.execution_digest,
        final_state_digest: packaged.kernel.kernel_claims.kernel.final_state_digest,
        transcript_final_digest: packaged.kernel.kernel_claims.kernel.transcript_final_digest,
        main_lane_statement_digest: packaged.main_lane.statement.digest,
        public_step_count: packaged.main_lane.statement.steps.len() as u64,
        final_pc: packaged.kernel.kernel_claims.kernel.final_pc,
        halted: packaged.kernel.kernel_claims.kernel.halted,
        digest: [0; 32],
    };
    let statement = Rv64imProofStatement {
        digest: statement.expected_digest(),
        ..statement
    };
    let stage_claims = stage_claim_proof_bundle_from_packaged(packaged);
    let stage_packages = stage_package_proof_bundle_from_packaged(packaged);
    let kernel_opening = kernel_opening_proof_bundle_from_packaged(packaged);
    let kernel_claims = kernel_claim_proof_bundle_from_packaged(packaged);
    let main_lane = main_lane_proof_bundle_from_packaged(packaged);
    let main_lane_claim = main_lane_claim_from_kernel(&statement, packaged);
    let opening_claim = kernel_opening_claim_from_kernel(&statement, packaged);
    let joint_opening_claim = joint_opening_claim_from_claims(&statement, packaged, &main_lane_claim, &opening_claim);
    let root0_claim = root0_claim_from_kernel(packaged);
    let bundle = Rv64imKernelProofBundle {
        root_params_id: packaged.kernel.root_params_id,
        trace: packaged.kernel.trace.clone(),
        stages: packaged.kernel.stages.clone(),
        stage_claims: stage_claims.clone(),
        stage_packages: stage_packages.clone(),
        kernel_opening: kernel_opening.clone(),
        kernel_claims: kernel_claims.clone(),
        main_lane: main_lane.clone(),
        joint_opening: joint_opening_proof_bundle_from_components(
            &statement,
            &joint_opening_claim,
            &main_lane,
            &kernel_opening,
        ),
        root0_commitment: root0_commitment_bundle_from_components(
            &root0_claim,
            &stage_claims,
            &stage_packages,
            &kernel_opening,
            &kernel_claims,
        ),
        digest: [0; 32],
    };
    Rv64imKernelProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

fn packaged_from_kernel_proof_bundle(bundle: &Rv64imKernelProofBundle) -> SimpleKernelPackagedProof {
    SimpleKernelPackagedProof {
        kernel: SimpleKernelProof {
            root_params_id: bundle.root_params_id,
            trace: bundle.trace.clone(),
            stages: bundle.stages.clone(),
            stage_claims: bundle.stage_claims.claims.clone(),
            stage_packages: bundle.stage_packages.packages.clone(),
            kernel_opening: bundle.kernel_opening.opening.clone(),
            kernel_claims: bundle.kernel_claims.claims.clone(),
        },
        main_lane: bundle.main_lane.packaged.clone(),
    }
}

pub fn build_rv64im_proof_witness(input: &Rv64imProofInput) -> Result<Rv64imProofWitnessBundle, SimpleKernelError> {
    Ok(Rv64imProofWitnessBundle {
        kernel: build_simple_kernel_witness(input)?,
    })
}

pub fn prove_rv64im_proof(
    input: &Rv64imProofInput,
) -> Result<(Rv64imProofWitnessBundle, Rv64imProof), SimpleKernelError> {
    let prover = SimpleKernelProverInput { public: input.clone() };
    let (kernel, packaged) = prove_packaged_simple_kernel(&prover)?;
    let statement = proof_statement_from_kernel(&kernel, &packaged);
    let claim = kernel_claim_bundle_from_statement_and_kernel(&statement, &packaged);
    Ok((
        Rv64imProofWitnessBundle { kernel },
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
    if proof.claim.accepted.digest != proof.claim.accepted.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM accepted proof claim digest mismatch".into(),
        ));
    }
    if proof.claim.main_lane.digest != proof.claim.main_lane.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM main-lane claim digest mismatch".into(),
        ));
    }
    if proof.claim.opening.digest != proof.claim.opening.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel-opening claim digest mismatch".into(),
        ));
    }
    if proof.claim.joint_opening.digest != proof.claim.joint_opening.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening claim digest mismatch".into(),
        ));
    }
    if proof.claim.root0.digest != proof.claim.root0.expected_digest() {
        return Err(SimpleKernelError::Bridge("RV64IM root0 claim digest mismatch".into()));
    }
    if proof.kernel.joint_opening.claim.digest != proof.kernel.joint_opening.claim.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening proof claim digest mismatch".into(),
        ));
    }
    if proof.kernel.kernel_opening.claim_digest != proof.kernel.kernel_opening.opening.claim.digest
        || proof.kernel.kernel_opening.bindings_digest != proof.kernel.kernel_opening.opening.bindings.digest
        || proof.kernel.kernel_opening.prepared_steps_digest
            != proof.kernel.kernel_opening.opening.prepared_steps.digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel-opening proof bundle fields do not match opening bundle".into(),
        ));
    }
    if proof.kernel.kernel_opening.digest != proof.kernel.kernel_opening.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel-opening proof bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.stage_claims.stage1_digest != proof.kernel.stage_claims.claims.stage1.commitment.digest
        || proof.kernel.stage_claims.stage2_digest != proof.kernel.stage_claims.claims.stage2.commitment.digest
        || proof.kernel.stage_claims.stage3_digest != proof.kernel.stage_claims.claims.stage3.commitment.digest
        || proof.kernel.stage_claims.transcript_digest
            != proof
                .kernel
                .stage_claims
                .claims
                .transcript
                .commitment
                .digest
        || proof.kernel.stage_claims.execution_digest != proof.kernel.stage_claims.claims.execution_digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-claim proof bundle fields do not match stage claims".into(),
        ));
    }
    if proof.kernel.stage_claims.digest != proof.kernel.stage_claims.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-claim proof bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.stage_packages.stage1_digest != proof.kernel.stage_packages.packages.stage1.digest
        || proof.kernel.stage_packages.stage2_digest != proof.kernel.stage_packages.packages.stage2.digest
        || proof.kernel.stage_packages.stage3_digest != proof.kernel.stage_packages.packages.stage3.digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-package proof bundle fields do not match stage packages".into(),
        ));
    }
    if proof.kernel.stage_packages.digest != proof.kernel.stage_packages.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-package proof bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.kernel_claims.prepared_step_bindings_digest
        != proof
            .kernel
            .kernel_claims
            .claims
            .prepared_step_bindings
            .digest
        || proof.kernel.kernel_claims.root0_digest != proof.kernel.kernel_claims.claims.kernel.root0_digest
        || proof.kernel.kernel_claims.execution_digest != proof.kernel.kernel_claims.claims.kernel.execution_digest
        || proof.kernel.kernel_claims.final_state_digest != proof.kernel.kernel_claims.claims.kernel.final_state_digest
        || proof.kernel.kernel_claims.transcript_final_digest
            != proof
                .kernel
                .kernel_claims
                .claims
                .kernel
                .transcript_final_digest
        || proof.kernel.kernel_claims.final_pc != proof.kernel.kernel_claims.claims.kernel.final_pc
        || proof.kernel.kernel_claims.halted != proof.kernel.kernel_claims.claims.kernel.halted
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel-claim proof bundle fields do not match kernel claims".into(),
        ));
    }
    if proof.kernel.kernel_claims.digest != proof.kernel.kernel_claims.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel-claim proof bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.main_lane.digest != proof.kernel.main_lane.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM main-lane proof bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.joint_opening.proof_statement_digest != proof.statement.digest
        || proof.kernel.joint_opening.main_lane_bundle_digest != proof.kernel.main_lane.digest
        || proof.kernel.joint_opening.kernel_opening_bundle_digest != proof.kernel.kernel_opening.digest
        || proof.kernel.joint_opening.public_step_count != proof.kernel.main_lane.public_step_count
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening proof bundle fields do not match the proof statement and bound proof bundles".into(),
        ));
    }
    if proof.kernel.joint_opening.digest != proof.kernel.joint_opening.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening proof bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.root0_commitment.claim.digest != proof.kernel.root0_commitment.claim.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 commitment claim digest mismatch".into(),
        ));
    }
    if proof.kernel.root0_commitment.digest != proof.kernel.root0_commitment.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 commitment bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.root0_commitment.stage_claim_bundle_digest != proof.kernel.stage_claims.digest
        || proof.kernel.root0_commitment.stage_package_bundle_digest != proof.kernel.stage_packages.digest
        || proof.kernel.root0_commitment.kernel_opening_bundle_digest != proof.kernel.kernel_opening.digest
        || proof.kernel.root0_commitment.kernel_claim_bundle_digest != proof.kernel.kernel_claims.digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 commitment bundle does not bind the expected proof bundles".into(),
        ));
    }
    if proof.kernel.root0_commitment.claim.root0_digest != proof.kernel.kernel_claims.root0_digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 commitment claim does not match the kernel-claim proof bundle".into(),
        ));
    }
    if proof.claim.digest != proof.claim.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel claim bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.digest != proof.kernel.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel proof bundle digest mismatch".into(),
        ));
    }
    if proof.statement.digest != proof.statement.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM proof statement digest mismatch".into(),
        ));
    }
    let packaged = packaged_from_kernel_proof_bundle(&proof.kernel);
    let verifier = SimpleKernelVerifierInput { public: input.clone() };
    let kernel = verify_packaged_simple_kernel(&verifier, &packaged)?;
    let expected_statement = proof_statement_from_kernel(&kernel, &packaged);
    if proof.statement != expected_statement {
        return Err(SimpleKernelError::Bridge(
            "RV64IM proof statement does not match kernel export".into(),
        ));
    }
    let expected_claim = kernel_claim_bundle_from_statement_and_kernel(&proof.statement, &packaged);
    if proof.claim != expected_claim {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel claim bundle does not match packaged proof export".into(),
        ));
    }
    let expected_bundle = kernel_proof_bundle_from_packaged(&packaged);
    if proof.kernel.digest != expected_bundle.digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel proof bundle does not match packaged proof export".into(),
        ));
    }
    if proof.kernel.joint_opening.digest != expected_bundle.joint_opening.digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening proof bundle does not match packaged proof export".into(),
        ));
    }
    if proof.kernel.root0_commitment.digest != expected_bundle.root0_commitment.digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 commitment bundle does not match packaged proof export".into(),
        ));
    }
    Ok(Rv64imProofWitnessBundle { kernel })
}

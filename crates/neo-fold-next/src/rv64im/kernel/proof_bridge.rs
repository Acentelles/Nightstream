//! Owns internal conversion between simple-kernel exports and the public RV64IM proof surface.

use super::proof_api::{
    Rv64imAcceptedProofClaim, Rv64imAcceptedProofMainLaneBinding, Rv64imAcceptedProofStatementBinding,
    Rv64imAcceptedProofTerminalBinding, Rv64imJointOpeningClaim, Rv64imJointOpeningClaimBinding,
    Rv64imJointOpeningProofBundle, Rv64imKernelClaimBundle, Rv64imKernelOpeningClaim,
    Rv64imKernelOpeningStageClaimBinding, Rv64imKernelOpeningTerminalClaimBinding, Rv64imKernelProofBundle,
    Rv64imMainLaneClaim, Rv64imMainLaneClaimBinding, Rv64imMainLaneProofBinding, Rv64imMainLaneProofBundle,
    Rv64imMainLaneProofSummaryBundle, Rv64imProofStatement, Rv64imRoot0Claim, Rv64imRoot0CommitmentBundle,
    Rv64imRoot0StageClaimBinding, Rv64imRoot0TerminalClaimBinding,
};
use super::proof_witness::{
    kernel_claim_proof_bundle_from_claims, kernel_opening_proof_bundle_from_opening,
    stage_claim_proof_bundle_from_claims, stage_package_proof_bundle_from_packages,
    stage_witness_proof_bundle_from_stages, trace_proof_bundle_from_trace, Rv64imKernelOpeningSummaryBundle,
};
use super::{SimpleKernelOutput, SimpleKernelPackagedProof, SimpleKernelProof};

pub(super) fn proof_statement_from_kernel(
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
    let statement_binding = Rv64imAcceptedProofStatementBinding {
        proof_statement_digest: statement.digest,
        kernel_opening_digest: packaged.kernel.kernel_opening.digest,
        digest: [0; 32],
    };
    let statement_binding = Rv64imAcceptedProofStatementBinding {
        digest: statement_binding.expected_digest(),
        ..statement_binding
    };
    let main_lane = Rv64imAcceptedProofMainLaneBinding {
        main_lane_statement_digest: packaged.main_lane.statement.digest,
        main_lane_proof_digest: packaged.main_lane.proof.proof_digest,
        digest: [0; 32],
    };
    let main_lane = Rv64imAcceptedProofMainLaneBinding {
        digest: main_lane.expected_digest(),
        ..main_lane
    };
    let terminal = Rv64imAcceptedProofTerminalBinding {
        final_state_digest: packaged.kernel.kernel_claims.kernel.final_state_digest,
        public_step_count: statement.public_step_count,
        final_pc: statement.final_pc,
        halted: statement.halted,
        digest: [0; 32],
    };
    let terminal = Rv64imAcceptedProofTerminalBinding {
        digest: terminal.expected_digest(),
        ..terminal
    };
    let claim = Rv64imAcceptedProofClaim {
        root_params_id: packaged.kernel.root_params_id,
        statement: statement_binding,
        main_lane,
        terminal,
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
    let binding = Rv64imMainLaneClaimBinding {
        statement_digest: packaged.main_lane.statement.digest,
        proof_digest: packaged.main_lane.proof.proof_digest,
        public_step_count: statement.public_step_count,
        digest: [0; 32],
    };
    let binding = Rv64imMainLaneClaimBinding {
        digest: binding.expected_digest(),
        ..binding
    };
    let claim = Rv64imMainLaneClaim {
        root_params_id: packaged.kernel.root_params_id,
        binding,
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
    let stages = Rv64imKernelOpeningStageClaimBinding {
        stage_claims_digest: packaged.kernel.stage_claims.digest,
        stage_packages_digest: packaged.kernel.stage_packages.digest,
        kernel_opening_digest: packaged.kernel.kernel_opening.digest,
        digest: [0; 32],
    };
    let stages = Rv64imKernelOpeningStageClaimBinding {
        digest: stages.expected_digest(),
        ..stages
    };
    let terminal = Rv64imKernelOpeningTerminalClaimBinding {
        prepared_step_bindings_digest: packaged.kernel.kernel_claims.prepared_step_bindings.digest,
        execution_digest: packaged.kernel.kernel_claims.kernel.execution_digest,
        transcript_final_digest: packaged.kernel.kernel_claims.kernel.transcript_final_digest,
        digest: [0; 32],
    };
    let terminal = Rv64imKernelOpeningTerminalClaimBinding {
        digest: terminal.expected_digest(),
        ..terminal
    };
    let claim = Rv64imKernelOpeningClaim {
        root_params_id: packaged.kernel.root_params_id,
        stages,
        terminal,
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
    let binding = Rv64imJointOpeningClaimBinding {
        proof_statement_digest: statement.digest,
        main_lane_claim_digest: main_lane.digest,
        kernel_opening_claim_digest: opening.digest,
        digest: [0; 32],
    };
    let binding = Rv64imJointOpeningClaimBinding {
        digest: binding.expected_digest(),
        ..binding
    };
    let claim = Rv64imJointOpeningClaim {
        root_params_id: packaged.kernel.root_params_id,
        binding,
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
    let stages = Rv64imRoot0StageClaimBinding {
        stage1_digest: summary.stage1_digest,
        stage2_digest: summary.stage2_digest,
        stage3_digest: summary.stage3_digest,
        digest: [0; 32],
    };
    let stages = Rv64imRoot0StageClaimBinding {
        digest: stages.expected_digest(),
        ..stages
    };
    let terminal = Rv64imRoot0TerminalClaimBinding {
        root0_digest: summary.root0_digest,
        execution_digest: summary.execution_digest,
        final_state_digest: summary.final_state_digest,
        transcript_final_digest: summary.transcript_final_digest,
        digest: [0; 32],
    };
    let terminal = Rv64imRoot0TerminalClaimBinding {
        digest: terminal.expected_digest(),
        ..terminal
    };
    let claim = Rv64imRoot0Claim {
        root_params_id: packaged.kernel.root_params_id,
        stages,
        terminal,
        digest: [0; 32],
    };
    Rv64imRoot0Claim {
        digest: claim.expected_digest(),
        ..claim
    }
}

fn main_lane_proof_bundle_from_packaged(packaged: &SimpleKernelPackagedProof) -> Rv64imMainLaneProofBundle {
    let binding = Rv64imMainLaneProofBinding {
        statement_digest: packaged.main_lane.statement.digest,
        proof_digest: packaged.main_lane.proof.proof_digest,
        public_step_count: packaged.main_lane.statement.steps.len() as u64,
        digest: [0; 32],
    };
    let binding = Rv64imMainLaneProofBinding {
        digest: binding.expected_digest(),
        ..binding
    };
    let bundle = Rv64imMainLaneProofBundle {
        binding,
        digest: [0; 32],
        packaged: packaged.main_lane.clone(),
    };
    Rv64imMainLaneProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

fn main_lane_proof_summary_from_bundle(bundle: &Rv64imMainLaneProofBundle) -> Rv64imMainLaneProofSummaryBundle {
    bundle.summary()
}

fn kernel_opening_summary_from_bundle(
    bundle: &super::proof_witness::Rv64imKernelOpeningProofBundle,
) -> Rv64imKernelOpeningSummaryBundle {
    bundle.summary()
}

fn joint_opening_proof_bundle_from_components(
    statement: &Rv64imProofStatement,
    main_lane: &Rv64imMainLaneProofBundle,
    kernel_opening: &super::proof_witness::Rv64imKernelOpeningProofBundle,
) -> Rv64imJointOpeningProofBundle {
    let bundle = Rv64imJointOpeningProofBundle {
        proof_statement_digest: statement.digest,
        public_step_count: main_lane.public_step_count(),
        main_lane: main_lane_proof_summary_from_bundle(main_lane),
        kernel_opening: kernel_opening_summary_from_bundle(kernel_opening),
        digest: [0; 32],
    };
    Rv64imJointOpeningProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

fn root0_commitment_bundle_from_components(
    stage_claims: &super::proof_witness::Rv64imStageClaimProofBundle,
    stage_packages: &super::proof_witness::Rv64imStagePackageProofBundle,
    kernel_opening: &super::proof_witness::Rv64imKernelOpeningProofBundle,
    kernel_claims: &super::proof_witness::Rv64imKernelClaimProofBundle,
) -> Rv64imRoot0CommitmentBundle {
    let bundle = Rv64imRoot0CommitmentBundle {
        stage_claims: stage_claims.summary.clone(),
        stage_packages: stage_packages.summary.clone(),
        kernel_opening: kernel_opening_summary_from_bundle(kernel_opening),
        kernel_claims: kernel_claims.summary.clone(),
        digest: [0; 32],
    };
    Rv64imRoot0CommitmentBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

pub(super) fn kernel_claim_bundle_from_statement_and_kernel(
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

pub(super) fn kernel_proof_bundle_from_packaged(packaged: &SimpleKernelPackagedProof) -> Rv64imKernelProofBundle {
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
    let stage_claims = stage_claim_proof_bundle_from_claims(&packaged.kernel.stage_claims);
    let stage_packages = stage_package_proof_bundle_from_packages(&packaged.kernel.stage_packages);
    let kernel_opening = kernel_opening_proof_bundle_from_opening(&packaged.kernel.kernel_opening);
    let kernel_claims = kernel_claim_proof_bundle_from_claims(&packaged.kernel.kernel_claims);
    let main_lane = main_lane_proof_bundle_from_packaged(packaged);
    let trace = trace_proof_bundle_from_trace(&packaged.kernel.trace, kernel_claims.execution_digest());
    let stages = stage_witness_proof_bundle_from_stages(&packaged.kernel.stages);
    let bundle = Rv64imKernelProofBundle {
        root_params_id: packaged.kernel.root_params_id,
        trace: trace.clone(),
        stages: stages.clone(),
        stage_claims: stage_claims.clone(),
        stage_packages: stage_packages.clone(),
        kernel_opening: kernel_opening.clone(),
        kernel_claims: kernel_claims.clone(),
        main_lane: main_lane.clone(),
        joint_opening: joint_opening_proof_bundle_from_components(&statement, &main_lane, &kernel_opening),
        root0_commitment: root0_commitment_bundle_from_components(
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

pub(super) fn packaged_from_kernel_proof_bundle(bundle: &Rv64imKernelProofBundle) -> SimpleKernelPackagedProof {
    SimpleKernelPackagedProof {
        kernel: SimpleKernelProof {
            root_params_id: bundle.root_params_id,
            trace: bundle.trace.trace.clone(),
            stages: bundle.stages.stages.clone(),
            stage_claims: bundle.stage_claims.claims.clone(),
            stage_packages: bundle.stage_packages.packages.clone(),
            kernel_opening: bundle.kernel_opening.opening.clone(),
            kernel_claims: bundle.kernel_claims.claims.clone(),
        },
        main_lane: bundle.main_lane.packaged.clone(),
    }
}

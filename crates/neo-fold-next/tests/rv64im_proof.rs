//! Focused tests for the final public RV64IM proof API.

use neo_fold_next::rv64im::{parity_source_cases, prove_rv64im_proof, verify_rv64im_proof, Rv64imProofInput};

fn source_case(name: &str) -> neo_fold_next::rv64im::Rv64imParitySourceCase {
    parity_source_cases()
        .into_iter()
        .find(|case| case.manifest.name == name)
        .unwrap_or_else(|| panic!("missing parity source case {name}"))
}

fn proof_input(name: &str) -> Rv64imProofInput {
    let source = source_case(name);
    let max_steps = source.program_words.len();
    Rv64imProofInput { source, max_steps }
}

#[test]
fn rv64im_proof_roundtrip_matches_kernel_export() {
    let input = proof_input("control_flow_jal_skip_ecall");

    let (witness, proof) = prove_rv64im_proof(&input).expect("prove rv64im proof");
    let verified = verify_rv64im_proof(&input, &proof).expect("verify rv64im proof");

    assert_ne!(proof.claim.digest, [0; 32]);
    assert_ne!(proof.claim.main_lane.digest, [0; 32]);
    assert_ne!(proof.claim.opening.digest, [0; 32]);
    assert_ne!(proof.claim.joint_opening.digest, [0; 32]);
    assert_ne!(proof.claim.root0.digest, [0; 32]);
    assert_ne!(proof.kernel.joint_opening.digest, [0; 32]);
    assert_ne!(proof.kernel.root0_commitment.digest, [0; 32]);
    assert_ne!(proof.statement.digest, [0; 32]);
    assert_eq!(verified.digest, witness.digest);
    assert_eq!(verified.trace.digest, witness.trace.digest);
    assert_eq!(verified.stages.digest, witness.stages.digest);
    assert_eq!(
        proof.kernel.trace.execution_row_count(),
        witness.trace.execution_row_count()
    );
    assert_eq!(
        proof.kernel.trace.execution_digest(),
        witness.kernel_claims.execution_digest()
    );
    assert_eq!(
        proof.kernel.stages.stage1_row_count(),
        witness.stages.stage1_row_count()
    );
    assert_eq!(
        proof.kernel.stage_claims.stage1_digest(),
        witness.stage_claims.summary.stage1_digest
    );
    assert_eq!(
        proof.kernel.stage_packages.stage1_digest(),
        witness.stage_packages.summary.stage1_digest
    );
    assert_eq!(verified.kernel_opening.digest, witness.kernel_opening.digest);
    assert_eq!(
        proof.kernel.kernel_claims.root0_digest(),
        witness.kernel_claims.root0_digest()
    );
    assert_eq!(
        proof.claim.accepted.statement.proof_statement_digest,
        proof.statement.digest
    );
    assert_eq!(
        proof.claim.accepted.statement.kernel_opening_digest,
        witness.kernel_opening.opening_digest
    );
    assert_eq!(
        proof.claim.main_lane.binding.statement_digest,
        proof.kernel.main_lane.statement_digest()
    );
    assert_eq!(
        proof.claim.opening.stages.stage_claims_digest,
        witness.stage_claims.summary.claim_bundle_digest
    );
    assert_eq!(
        proof.claim.joint_opening.binding.proof_statement_digest,
        proof.statement.digest
    );
    assert_eq!(
        proof.claim.root0.terminal.root0_digest,
        witness.kernel_claims.root0_digest()
    );
    assert_eq!(
        proof.kernel.joint_opening.bindings.main_lane.bundle_digest,
        proof.kernel.main_lane.digest
    );
    assert_eq!(
        proof
            .kernel
            .joint_opening
            .bindings
            .main_lane
            .proof
            .statement_digest,
        proof.kernel.main_lane.statement_digest()
    );
    assert_eq!(
        proof
            .kernel
            .joint_opening
            .bindings
            .main_lane
            .proof
            .proof_digest,
        proof.kernel.main_lane.proof_digest()
    );
    assert_eq!(
        proof
            .kernel
            .joint_opening
            .bindings
            .kernel_opening
            .opening
            .claim_digest,
        proof.kernel.kernel_opening.claim_digest()
    );
    assert_eq!(
        proof
            .kernel
            .joint_opening
            .bindings
            .kernel_opening
            .opening
            .bindings_digest,
        proof.kernel.kernel_opening.bindings_digest()
    );
    assert_eq!(
        proof
            .kernel
            .joint_opening
            .bindings
            .kernel_opening
            .opening
            .prepared_steps_digest,
        proof.kernel.kernel_opening.prepared_steps_digest()
    );
    assert_eq!(
        proof
            .kernel
            .joint_opening
            .bindings
            .kernel_opening
            .bundle_digest,
        proof.kernel.kernel_opening.digest
    );
    assert_eq!(
        proof
            .kernel
            .root0_commitment
            .bindings
            .kernel
            .bundles
            .opening
            .digest,
        proof.kernel.kernel_opening.bindings.digest
    );
    assert_eq!(
        proof
            .kernel
            .root0_commitment
            .bindings
            .kernel
            .bundles
            .claims
            .digest,
        proof.kernel.kernel_claims.summary.digest
    );
    assert_eq!(
        proof.kernel.root0_commitment.bindings.stages.claims.digest,
        proof.kernel.stage_claims.summary.digest
    );
    assert_eq!(
        proof
            .kernel
            .root0_commitment
            .bindings
            .stages
            .packages
            .digest,
        proof.kernel.stage_packages.summary.digest
    );
    assert_eq!(
        proof
            .kernel
            .root0_commitment
            .bindings
            .kernel
            .bundles
            .claims
            .terminal
            .root0_digest,
        proof.kernel.kernel_claims.root0_digest()
    );
    assert_eq!(
        proof
            .kernel
            .root0_commitment
            .bindings
            .kernel
            .bundles
            .claims
            .terminal
            .final_state_digest,
        proof.kernel.kernel_claims.final_state_digest()
    );
    assert_eq!(
        proof.statement.kernel_opening_digest,
        witness.kernel_opening.opening_digest
    );
    assert_eq!(
        proof.statement.final_state_digest,
        witness.kernel_claims.final_state_digest()
    );
    assert_eq!(proof.kernel.main_lane.public_step_count(), witness.public_step_count);
}

#[test]
fn rv64im_proof_rejects_tampered_kernel_and_main_lane_surfaces() {
    let input = proof_input("native_add_chain_x0_ecall");

    let (_witness, proof) = prove_rv64im_proof(&input).expect("prove rv64im proof");

    let mut tampered_kernel = proof.clone();
    tampered_kernel
        .kernel
        .kernel_opening
        .bindings
        .bindings_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_kernel).is_err());

    let mut tampered_trace = proof.clone();
    tampered_trace.kernel.trace.execution_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_trace).is_err());

    let mut tampered_trace_shape = proof.clone();
    tampered_trace_shape.kernel.trace.shape.digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_trace_shape).is_err());

    let mut tampered_stages = proof.clone();
    tampered_stages
        .kernel
        .stages
        .summary
        .stage3_continuity_count ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_stages).is_err());

    let mut tampered_stage_summary = proof.clone();
    tampered_stage_summary.kernel.stages.summary.digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_stage_summary).is_err());

    let mut tampered_stage_claims = proof.clone();
    tampered_stage_claims
        .kernel
        .stage_claims
        .summary
        .stage1_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_stage_claims).is_err());

    let mut tampered_stage_packages = proof.clone();
    tampered_stage_packages
        .kernel
        .stage_packages
        .summary
        .stage1_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_stage_packages).is_err());

    let mut tampered_stage_claim_summary = proof.clone();
    tampered_stage_claim_summary
        .kernel
        .stage_claims
        .summary
        .digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_stage_claim_summary).is_err());

    let mut tampered_stage_package_summary = proof.clone();
    tampered_stage_package_summary
        .kernel
        .stage_packages
        .summary
        .digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_stage_package_summary).is_err());

    let mut tampered_statement = proof.clone();
    tampered_statement.statement.final_state_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_statement).is_err());

    let mut tampered_claim = proof.clone();
    tampered_claim.claim.accepted.terminal.final_state_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_claim).is_err());

    let mut tampered_accepted_statement_binding = proof.clone();
    tampered_accepted_statement_binding
        .claim
        .accepted
        .statement
        .digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_accepted_statement_binding).is_err());

    let mut tampered_main_lane_claim = proof.clone();
    tampered_main_lane_claim
        .claim
        .main_lane
        .binding
        .proof_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_main_lane_claim).is_err());

    let mut tampered_main_lane_claim_binding = proof.clone();
    tampered_main_lane_claim_binding
        .claim
        .main_lane
        .binding
        .digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_main_lane_claim_binding).is_err());

    let mut tampered_opening_claim = proof.clone();
    tampered_opening_claim
        .claim
        .opening
        .terminal
        .execution_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_opening_claim).is_err());

    let mut tampered_opening_stage_claim_binding = proof.clone();
    tampered_opening_stage_claim_binding
        .claim
        .opening
        .stages
        .digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_opening_stage_claim_binding).is_err());

    let mut tampered_opening_terminal_claim_binding = proof.clone();
    tampered_opening_terminal_claim_binding
        .claim
        .opening
        .terminal
        .digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_opening_terminal_claim_binding).is_err());

    let mut tampered_joint_opening_claim = proof.clone();
    tampered_joint_opening_claim
        .claim
        .joint_opening
        .binding
        .main_lane_claim_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_joint_opening_claim).is_err());

    let mut tampered_root0_claim = proof.clone();
    tampered_root0_claim.claim.root0.terminal.root0_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_root0_claim).is_err());

    let mut tampered_joint_opening_claim_binding = proof.clone();
    tampered_joint_opening_claim_binding
        .claim
        .joint_opening
        .binding
        .digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_joint_opening_claim_binding).is_err());

    let mut tampered_root0_stage_claim_binding = proof.clone();
    tampered_root0_stage_claim_binding.claim.root0.stages.digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_root0_stage_claim_binding).is_err());

    let mut tampered_root0_terminal_claim_binding = proof.clone();
    tampered_root0_terminal_claim_binding
        .claim
        .root0
        .terminal
        .digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_root0_terminal_claim_binding).is_err());

    let mut tampered_bundle = proof.clone();
    tampered_bundle.claim.digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_bundle).is_err());

    let mut tampered_main_lane = proof.clone();
    tampered_main_lane.kernel.main_lane.binding.statement_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_main_lane).is_err());

    let mut tampered_main_lane_binding = proof.clone();
    tampered_main_lane_binding.kernel.main_lane.binding.digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_main_lane_binding).is_err());

    let mut tampered_joint_opening_bundle = proof.clone();
    tampered_joint_opening_bundle.kernel.joint_opening.digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_joint_opening_bundle).is_err());

    let mut tampered_joint_opening_binding_bundle = proof.clone();
    tampered_joint_opening_binding_bundle
        .kernel
        .joint_opening
        .bindings
        .digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_joint_opening_binding_bundle).is_err());

    let mut tampered_joint_opening_binding = proof.clone();
    tampered_joint_opening_binding
        .kernel
        .joint_opening
        .bindings
        .main_lane
        .bundle_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_joint_opening_binding).is_err());

    let mut tampered_joint_opening_main_lane_surface = proof.clone();
    tampered_joint_opening_main_lane_surface
        .kernel
        .joint_opening
        .bindings
        .main_lane
        .proof
        .statement_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_joint_opening_main_lane_surface).is_err());

    let mut tampered_joint_opening_main_lane_binding_digest = proof.clone();
    tampered_joint_opening_main_lane_binding_digest
        .kernel
        .joint_opening
        .bindings
        .main_lane
        .proof
        .digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_joint_opening_main_lane_binding_digest).is_err());

    let mut tampered_joint_opening_statement_binding = proof.clone();
    tampered_joint_opening_statement_binding
        .kernel
        .joint_opening
        .bindings
        .statement
        .digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_joint_opening_statement_binding).is_err());

    let mut tampered_joint_opening_kernel_opening_binding = proof.clone();
    tampered_joint_opening_kernel_opening_binding
        .kernel
        .joint_opening
        .bindings
        .kernel_opening
        .opening
        .digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_joint_opening_kernel_opening_binding).is_err());

    let mut tampered_root0_bundle = proof.clone();
    tampered_root0_bundle.kernel.root0_commitment.digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_root0_bundle).is_err());

    let mut tampered_root0_binding_bundle = proof.clone();
    tampered_root0_binding_bundle
        .kernel
        .root0_commitment
        .bindings
        .digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_root0_binding_bundle).is_err());

    let mut tampered_root0_binding = proof.clone();
    tampered_root0_binding
        .kernel
        .root0_commitment
        .bindings
        .stages
        .claims
        .digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_root0_binding).is_err());

    let mut tampered_root0_surface = proof.clone();
    tampered_root0_surface
        .kernel
        .root0_commitment
        .bindings
        .kernel
        .bundles
        .claims
        .terminal
        .final_state_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_root0_surface).is_err());

    let mut tampered_root0_terminal_binding = proof.clone();
    tampered_root0_terminal_binding
        .kernel
        .root0_commitment
        .bindings
        .kernel
        .bundles
        .claims
        .digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_root0_terminal_binding).is_err());

    let mut tampered_kernel_claim_bundle = proof.clone();
    tampered_kernel_claim_bundle
        .kernel
        .kernel_claims
        .summary
        .terminal
        .final_state_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_kernel_claim_bundle).is_err());
}

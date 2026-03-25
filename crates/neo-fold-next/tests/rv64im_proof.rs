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
    assert_eq!(verified.kernel.trace, witness.kernel.trace);
    assert_eq!(verified.kernel.stages, witness.kernel.stages);
    assert_eq!(
        proof.kernel.stage_claims.stage1_digest(),
        witness.kernel.stage_claims.stage1.commitment.digest
    );
    assert_eq!(
        proof.kernel.stage_packages.stage1_digest(),
        witness.kernel.stage_packages.stage1.digest
    );
    assert_eq!(
        verified.kernel.kernel_opening.digest,
        witness.kernel.kernel_opening.digest
    );
    assert_eq!(
        proof.kernel.kernel_claims.root0_digest(),
        witness.kernel.kernel_claims.kernel.root0_digest
    );
    assert_eq!(proof.claim.accepted.proof_statement_digest, proof.statement.digest);
    assert_eq!(
        proof.claim.accepted.kernel_opening_digest,
        witness.kernel.kernel_opening.digest
    );
    assert_eq!(
        proof.claim.main_lane.statement_digest,
        proof.kernel.main_lane.statement_digest()
    );
    assert_eq!(
        proof.claim.opening.stage_claims_digest,
        witness.kernel.stage_claims.digest
    );
    assert_eq!(proof.claim.joint_opening.proof_statement_digest, proof.statement.digest);
    assert_eq!(
        proof.claim.root0.root0_digest,
        witness.kernel.kernel_claims.kernel.root0_digest
    );
    assert_eq!(
        proof.kernel.joint_opening.main_lane_bundle_digest,
        proof.kernel.main_lane.digest
    );
    assert_eq!(
        proof.kernel.joint_opening.kernel_opening_bundle_digest,
        proof.kernel.kernel_opening.digest
    );
    assert_eq!(
        proof.kernel.root0_commitment.kernel_claim_bundle_digest,
        proof.kernel.kernel_claims.digest
    );
    assert_eq!(
        proof.statement.kernel_opening_digest,
        witness.kernel.kernel_opening.digest
    );
    assert_eq!(
        proof.statement.final_state_digest,
        witness.kernel.kernel_claims.kernel.final_state_digest
    );
    assert_eq!(
        proof.kernel.main_lane.public_step_count() as usize,
        witness.kernel.public_steps.len(),
    );
}

#[test]
fn rv64im_proof_rejects_tampered_kernel_and_main_lane_surfaces() {
    let input = proof_input("native_add_chain_x0_ecall");

    let (_witness, proof) = prove_rv64im_proof(&input).expect("prove rv64im proof");

    let mut tampered_kernel = proof.clone();
    tampered_kernel.kernel.kernel_opening.bindings_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_kernel).is_err());

    let mut tampered_stage_claims = proof.clone();
    tampered_stage_claims.kernel.stage_claims.stage1_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_stage_claims).is_err());

    let mut tampered_stage_packages = proof.clone();
    tampered_stage_packages.kernel.stage_packages.stage1_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_stage_packages).is_err());

    let mut tampered_statement = proof.clone();
    tampered_statement.statement.final_state_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_statement).is_err());

    let mut tampered_claim = proof.clone();
    tampered_claim.claim.accepted.final_state_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_claim).is_err());

    let mut tampered_main_lane_claim = proof.clone();
    tampered_main_lane_claim.claim.main_lane.proof_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_main_lane_claim).is_err());

    let mut tampered_opening_claim = proof.clone();
    tampered_opening_claim.claim.opening.execution_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_opening_claim).is_err());

    let mut tampered_joint_opening_claim = proof.clone();
    tampered_joint_opening_claim
        .claim
        .joint_opening
        .main_lane_claim_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_joint_opening_claim).is_err());

    let mut tampered_root0_claim = proof.clone();
    tampered_root0_claim.claim.root0.root0_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_root0_claim).is_err());

    let mut tampered_bundle = proof.clone();
    tampered_bundle.claim.digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_bundle).is_err());

    let mut tampered_main_lane = proof.clone();
    tampered_main_lane.kernel.main_lane.statement_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_main_lane).is_err());

    let mut tampered_joint_opening_bundle = proof.clone();
    tampered_joint_opening_bundle.kernel.joint_opening.digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_joint_opening_bundle).is_err());

    let mut tampered_joint_opening_binding = proof.clone();
    tampered_joint_opening_binding
        .kernel
        .joint_opening
        .main_lane_bundle_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_joint_opening_binding).is_err());

    let mut tampered_root0_bundle = proof.clone();
    tampered_root0_bundle.kernel.root0_commitment.digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_root0_bundle).is_err());

    let mut tampered_root0_binding = proof.clone();
    tampered_root0_binding
        .kernel
        .root0_commitment
        .kernel_claim_bundle_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_root0_binding).is_err());

    let mut tampered_kernel_claim_bundle = proof.clone();
    tampered_kernel_claim_bundle
        .kernel
        .kernel_claims
        .final_state_digest[0] ^= 1;
    assert!(verify_rv64im_proof(&input, &tampered_kernel_claim_bundle).is_err());
}

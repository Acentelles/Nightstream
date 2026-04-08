//! Focused RV64IM round-trip over the stricter Spartan2 backend-binding shell.

use neo_fold_next::decider::spartan2::verify_spartan2_backend_binding_shell;
use neo_fold_next::nightstream::rv64im::{
    build_rv64im_nightstream_from_public_proof, build_rv64im_side_terminal_backend_binding_relation,
    build_rv64im_side_terminal_backend_binding_relation_from_public_proof,
    prove_rv64im_side_terminal_backend_binding_shell_from_public_proof,
    prove_rv64im_side_terminal_backend_proof_from_public_proof,
    setup_rv64im_side_terminal_backend_binding_shell_from_public_proof,
    setup_rv64im_side_terminal_backend_proof_from_public_proof,
    verify_rv64im_side_terminal_backend_binding_shell_from_public_proof,
    verify_rv64im_side_terminal_backend_proof_from_public_proof,
};
use neo_fold_next::rv64im::{parity_source_cases, prove_rv64im_public_proof, Rv64imProofInput};

fn rebind_tampered_public_statement(
    nightstream_statement: &mut neo_fold_next::nightstream::NightstreamStatement,
    nightstream_proof: &mut neo_fold_next::nightstream::rv64im::Rv64imNightstreamProof,
    public_statement: &neo_fold_next::rv64im::Rv64imProofStatement,
) {
    nightstream_statement.public_io_digest = public_statement.digest;
    nightstream_proof
        .side_proof_artifact
        .bundle
        .statement_core_digest = nightstream_statement.core_digest();
    nightstream_proof.side_proof_artifact.bundle.digest = nightstream_proof
        .side_proof_artifact
        .bundle
        .expected_digest();
}

fn rebind_tampered_side_bundle(nightstream_proof: &mut neo_fold_next::nightstream::rv64im::Rv64imNightstreamProof) {
    nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_claim_bridge
        .digest = nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_claim_bridge
        .expected_digest();
    nightstream_proof.side_proof_artifact.bundle.digest = nightstream_proof
        .side_proof_artifact
        .bundle
        .expected_digest();
}

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
fn rv64im_side_terminal_spartan2_backend_binding_shell_round_trip() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (pk, vk) = setup_rv64im_side_terminal_backend_binding_shell_from_public_proof(&proof)
        .expect("setup side-terminal backend-binding shell");
    let shell = prove_rv64im_side_terminal_backend_binding_shell_from_public_proof(&pk, &proof)
        .expect("prove side-terminal backend-binding shell");

    verify_rv64im_side_terminal_backend_binding_shell_from_public_proof(&vk, &proof, &shell)
        .expect("verify side-terminal backend-binding shell");
    assert!(shell.snark_bytes_len() > 0);
}

#[test]
fn rv64im_side_terminal_spartan2_backend_binding_shell_rejects_private_base_digest_tamper() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let relation = build_rv64im_side_terminal_backend_binding_relation_from_public_proof(&proof)
        .expect("build side-terminal backend-binding relation");
    let (pk, vk) = setup_rv64im_side_terminal_backend_binding_shell_from_public_proof(&proof)
        .expect("setup side-terminal backend-binding shell");
    let shell = prove_rv64im_side_terminal_backend_binding_shell_from_public_proof(&pk, &proof)
        .expect("prove side-terminal backend-binding shell");

    let mut tampered = relation;
    tampered.witness.base_component_digests[0][0] ^= 1;

    let err = verify_spartan2_backend_binding_shell(&vk, &tampered, &shell)
        .expect_err("tampered backend witness digest must fail");

    assert!(
        err.to_string()
            .contains("public final proof digest does not match the carried fixed-shape backend relation"),
        "unexpected error: {err}"
    );
}

#[test]
fn rv64im_side_terminal_backend_proof_round_trip() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (pk, vk) =
        setup_rv64im_side_terminal_backend_proof_from_public_proof(&proof).expect("setup side-terminal backend proof");
    let backend_proof = prove_rv64im_side_terminal_backend_proof_from_public_proof(&pk, &proof)
        .expect("prove side-terminal backend proof");

    verify_rv64im_side_terminal_backend_proof_from_public_proof(&vk, &proof, &backend_proof)
        .expect("verify side-terminal backend proof");
    assert!(backend_proof.snark_bytes_len() > 0);
    assert_ne!(backend_proof.digest(), [0; 32]);
}

#[test]
fn rv64im_side_terminal_backend_proof_rejects_shape_digest_tamper() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (pk, vk) =
        setup_rv64im_side_terminal_backend_proof_from_public_proof(&proof).expect("setup side-terminal backend proof");
    let mut backend_proof = prove_rv64im_side_terminal_backend_proof_from_public_proof(&pk, &proof)
        .expect("prove side-terminal backend proof");

    backend_proof.shape_digest[0] ^= 1;

    let err = verify_rv64im_side_terminal_backend_proof_from_public_proof(&vk, &proof, &backend_proof)
        .expect_err("tampered side-terminal backend proof shape digest must fail");

    assert!(
        err.to_string()
            .contains("RV64IM side-terminal backend proof shape digest does not match the carried backend relation"),
        "unexpected error: {err}"
    );
}

#[test]
fn rv64im_side_terminal_backend_relation_rejects_recomputed_public_statement_with_wrong_stage_package_digest() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (mut nightstream_statement, mut nightstream_proof) =
        build_rv64im_nightstream_from_public_proof(&proof).expect("build rv64im nightstream");
    let mut public_statement = proof.statement.clone();

    public_statement.stage_packages_digest[0] ^= 1;
    public_statement.digest = public_statement.recompute_digest();
    rebind_tampered_public_statement(&mut nightstream_statement, &mut nightstream_proof, &public_statement);

    let err = build_rv64im_side_terminal_backend_binding_relation(
        &nightstream_statement,
        &nightstream_proof,
        &public_statement,
    )
    .expect_err("recomputed public statement with wrong compact stage-package digest must fail");

    assert!(
        err.to_string().contains(
            "RV64IM side-terminal decider relation compact stage-package proof surface does not match the carried RV64IM public statement"
        ),
        "unexpected error: {err}"
    );
}

#[test]
fn rv64im_side_terminal_backend_relation_rejects_recomputed_public_statement_with_wrong_stage_claim_digest() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (mut nightstream_statement, mut nightstream_proof) =
        build_rv64im_nightstream_from_public_proof(&proof).expect("build rv64im nightstream");
    let mut public_statement = proof.statement.clone();

    public_statement.stage_claims_digest[0] ^= 1;
    public_statement.digest = public_statement.recompute_digest();
    rebind_tampered_public_statement(&mut nightstream_statement, &mut nightstream_proof, &public_statement);

    let err = build_rv64im_side_terminal_backend_binding_relation(
        &nightstream_statement,
        &nightstream_proof,
        &public_statement,
    )
    .expect_err("recomputed public statement with wrong compact stage-claim digest must fail");

    assert!(
        err.to_string().contains(
            "RV64IM side-terminal decider relation compact stage-claim proof surface does not match the carried RV64IM public statement"
        ),
        "unexpected error: {err}"
    );
}

#[test]
fn rv64im_side_terminal_backend_relation_rejects_rebound_side_bundle_with_wrong_root0_digest() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (nightstream_statement, mut nightstream_proof) =
        build_rv64im_nightstream_from_public_proof(&proof).expect("build rv64im nightstream");
    let public_statement = proof.statement.clone();

    nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_claim_bridge
        .root0_digest[0] ^= 1;
    rebind_tampered_side_bundle(&mut nightstream_proof);

    let err = build_rv64im_side_terminal_backend_binding_relation(
        &nightstream_statement,
        &nightstream_proof,
        &public_statement,
    )
    .expect_err("rebound side bundle with wrong root0 digest must fail");

    assert!(
        err.to_string().contains(
            "RV64IM side-terminal decider relation compact kernel-claim proof surface does not match the carried RV64IM public statement"
        ),
        "unexpected error: {err}"
    );
}

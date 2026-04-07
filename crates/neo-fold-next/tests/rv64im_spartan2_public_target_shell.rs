//! Focused RV64IM round-trip over the shared Spartan2 public-target shell.

use neo_fold_next::decider::spartan2::{
    prove_spartan2_public_target_shell, setup_spartan2_public_target_shell, verify_spartan2_public_target_shell,
};
use neo_fold_next::nightstream::rv64im::{
    build_rv64im_nightstream_from_public_proof, build_rv64im_side_terminal_decider_target,
    build_rv64im_side_terminal_relation_from_accepted_artifact,
    prove_rv64im_side_terminal_public_target_shell_from_public_proof,
    setup_rv64im_side_terminal_public_target_shell_from_public_proof,
    verify_rv64im_side_terminal_public_target_shell_from_public_proof,
};
use neo_fold_next::rv64im::final_relation::prove_rv64im_final_statement_from_accepted;
use neo_fold_next::rv64im::{
    build_rv64im_accepted_proof_artifact, build_rv64im_spartan2_decider_target, parity_source_cases,
    prove_rv64im_public_proof, Rv64imProofInput,
};

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
fn rv64im_spartan2_public_target_shell_round_trip() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, final_proof) =
        prove_rv64im_final_statement_from_accepted(&artifact).expect("prove rv64im final statement");
    let target = build_rv64im_spartan2_decider_target(&statement, &final_proof).expect("build rv64im decider target");

    let (pk, vk) = setup_spartan2_public_target_shell(&target.shape()).expect("setup public-target shell");
    let shell = prove_spartan2_public_target_shell(&pk, &target).expect("prove public-target shell");

    verify_spartan2_public_target_shell(&vk, &target, &shell).expect("verify public-target shell");
    assert!(shell.snark_bytes_len() > 0);
}

#[test]
fn rv64im_side_terminal_spartan2_public_target_shell_round_trip() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (pk, vk) =
        setup_rv64im_side_terminal_public_target_shell_from_public_proof(&proof).expect("setup side-terminal shell");
    let shell = prove_rv64im_side_terminal_public_target_shell_from_public_proof(&pk, &proof)
        .expect("prove side-terminal shell");

    verify_rv64im_side_terminal_public_target_shell_from_public_proof(&vk, &proof, &shell)
        .expect("verify side-terminal shell");
    assert!(shell.snark_bytes_len() > 0);
}

#[test]
fn rv64im_side_terminal_spartan2_public_target_shell_rejects_unbound_side_bundle() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (nightstream_statement, nightstream_proof) =
        build_rv64im_nightstream_from_public_proof(&proof).expect("build rv64im nightstream");
    let (unbound_statement, _) =
        build_rv64im_side_terminal_relation_from_accepted_artifact(&artifact).expect("build side-terminal relation");

    let err = build_rv64im_side_terminal_decider_target(
        &nightstream_statement,
        &unbound_statement,
        &nightstream_proof.main_residual_proof.bridge_handoff_digests,
    )
    .expect_err("accepted-artifact side bundle must not satisfy the Nightstream-bound side-terminal target");

    assert!(err.to_string().contains("statement core"), "unexpected error: {err}");
}

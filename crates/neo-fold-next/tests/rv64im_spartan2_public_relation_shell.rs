//! Focused RV64IM round-trip over the stricter Spartan2 public-relation shell.

use neo_fold_next::nightstream::rv64im::{
    build_rv64im_nightstream_from_public_proof, prove_rv64im_side_terminal_public_relation_shell_from_public_proof,
    setup_rv64im_side_terminal_public_relation_shell_from_public_proof,
    verify_rv64im_side_terminal_public_relation_shell_from_public_proof,
};
use neo_fold_next::rv64im::{parity_source_cases, prove_rv64im_public_proof, Rv64imProofInput};

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
fn rv64im_side_terminal_spartan2_public_relation_shell_round_trip() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (pk, vk) = setup_rv64im_side_terminal_public_relation_shell_from_public_proof(&proof)
        .expect("setup side-terminal public-relation shell");
    let shell = prove_rv64im_side_terminal_public_relation_shell_from_public_proof(&pk, &proof)
        .expect("prove side-terminal public-relation shell");

    verify_rv64im_side_terminal_public_relation_shell_from_public_proof(&vk, &proof, &shell)
        .expect("verify side-terminal public-relation shell");
    assert!(shell.snark_bytes_len() > 0);
}

#[test]
fn rv64im_side_terminal_spartan2_public_relation_shell_rejects_nightstream_side_tamper() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (nightstream_statement, mut nightstream_proof) =
        build_rv64im_nightstream_from_public_proof(&proof).expect("build rv64im nightstream");
    let public_statement = proof.statement.clone();
    let (pk, vk) = setup_rv64im_side_terminal_public_relation_shell_from_public_proof(&proof)
        .expect("setup side-terminal public-relation shell");
    let shell = prove_rv64im_side_terminal_public_relation_shell_from_public_proof(&pk, &proof)
        .expect("prove side-terminal public-relation shell");

    nightstream_proof
        .side_proof_artifact
        .bundle
        .statement_core_digest[0] ^= 1;

    let err = neo_fold_next::nightstream::rv64im::verify_rv64im_side_terminal_public_relation_shell(
        &vk,
        &nightstream_statement,
        &nightstream_proof,
        &public_statement,
        &shell,
    )
    .expect_err("tampered Nightstream side bundle must fail");

    assert!(
        err.to_string()
            .contains("side-proof bundle digest mismatch"),
        "unexpected error: {err}"
    );
}

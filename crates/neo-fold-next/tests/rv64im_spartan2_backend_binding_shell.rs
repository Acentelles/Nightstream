//! Focused RV64IM round-trip over the shared Spartan2 backend-binding shell.

use neo_fold_next::decider::spartan2::{prove_spartan2_decider, setup_spartan2_decider, verify_spartan2_decider};
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
fn rv64im_spartan2_decider_backend_round_trip() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, final_proof) =
        prove_rv64im_final_statement_from_accepted(&artifact).expect("prove rv64im final statement");
    let target = build_rv64im_spartan2_decider_target(&statement, &final_proof).expect("build rv64im decider target");

    let (pk, vk) = setup_spartan2_decider(&target.shape()).expect("setup decider backend");
    let shell = prove_spartan2_decider(&pk, &target).expect("prove decider backend");

    verify_spartan2_decider(&vk, &target, &shell).expect("verify decider backend");
    assert!(shell.snark_bytes_len() > 0);
}

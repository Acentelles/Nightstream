//! Focused tests for the witness-owned RV64IM kernel export seam.

use neo_fold_next::rv64im::{
    build_rv64im_kernel_export_relation, build_rv64im_kernel_export_witness, parity_source_cases,
    prove_rv64im_public_proof, verify_rv64im_kernel_export_witness, Rv64imProofInput,
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
fn rv64im_kernel_export_witness_round_trip() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let relation = build_rv64im_kernel_export_relation(&proof).expect("build kernel export relation");
    let witness = build_rv64im_kernel_export_witness(&proof).expect("build kernel export witness");

    assert_eq!(witness.chunk_handoffs.len(), relation.chunk_count as usize);
    assert_ne!(witness.digest, [0; 32]);
    assert!(witness
        .chunk_handoffs
        .iter()
        .all(|chunk| chunk.digest != [0; 32]));

    verify_rv64im_kernel_export_witness(&relation, &witness).expect("verify kernel export witness");
}

#[test]
fn rv64im_kernel_export_witness_rejects_tampered_chunk_input() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let relation = build_rv64im_kernel_export_relation(&proof).expect("build kernel export relation");
    let mut witness = build_rv64im_kernel_export_witness(&proof).expect("build kernel export witness");
    witness.chunk_handoffs[0].chunk_input.steps[0]
        .label
        .push_str("_tampered");

    let err = verify_rv64im_kernel_export_witness(&relation, &witness).expect_err("tampered chunk input must fail");
    assert!(format!("{err}").contains("kernel export witness") || format!("{err}").contains("digest"));
}

#[test]
fn rv64im_kernel_export_witness_rejects_tampered_bridge_witness() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let relation = build_rv64im_kernel_export_relation(&proof).expect("build kernel export relation");
    let mut witness = build_rv64im_kernel_export_witness(&proof).expect("build kernel export witness");
    witness.chunk_handoffs[0]
        .bridge_witness
        .row_chunk_route_digests[0][0] ^= 1;

    let err = verify_rv64im_kernel_export_witness(&relation, &witness).expect_err("tampered bridge witness must fail");
    assert!(format!("{err}").contains("bridge") || format!("{err}").contains("digest"));
}

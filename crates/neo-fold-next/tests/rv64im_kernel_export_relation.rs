//! Focused tests for the owned RV64IM kernel export relation seam.

use neo_fold_next::rv64im::{
    build_rv64im_kernel_export_relation, parity_source_cases, prove_rv64im_public_proof,
    verify_rv64im_kernel_export_relation, Rv64imProofInput,
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
fn rv64im_kernel_export_relation_round_trip() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");

    let relation = build_rv64im_kernel_export_relation(&proof).expect("build kernel export relation");

    assert_eq!(relation.fold_schedule, proof.statement.fold_schedule);
    assert_eq!(relation.chunk_count, proof.statement.chunk_count);
    assert_eq!(relation.public_step_count, proof.statement.public_step_count);
    assert_eq!(relation.final_state_digest, proof.statement.final_state_digest);
    assert_eq!(relation.final_pc, proof.statement.final_pc);
    assert_eq!(relation.halted, proof.statement.halted);
    assert_eq!(relation.chunk_surfaces.len(), proof.statement.chunk_count as usize);
    assert_ne!(relation.digest, [0; 32]);

    verify_rv64im_kernel_export_relation(&relation, &proof).expect("verify kernel export relation");
}

#[test]
fn rv64im_kernel_export_relation_rejects_tampered_chunk_surface() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let mut relation = build_rv64im_kernel_export_relation(&proof).expect("build kernel export relation");
    relation.chunk_surfaces[0].bridge_digest[0] ^= 1;

    let err = verify_rv64im_kernel_export_relation(&relation, &proof).expect_err("tampered chunk surface must fail");
    assert!(format!("{err}").contains("kernel export relation") || format!("{err}").contains("digest"));
}

#[test]
fn rv64im_kernel_export_relation_rejects_tampered_terminal_binding() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let mut relation = build_rv64im_kernel_export_relation(&proof).expect("build kernel export relation");
    relation.final_state_digest[0] ^= 1;

    let err = verify_rv64im_kernel_export_relation(&relation, &proof).expect_err("tampered terminal binding must fail");
    assert!(format!("{err}").contains("kernel export relation") || format!("{err}").contains("digest"));
}

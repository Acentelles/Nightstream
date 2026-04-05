//! Focused tests for the RV64IM folded/final relation seam above the accepted artifact.

use neo_fold_next::proof::FoldSchedule;
use neo_fold_next::rv64im::final_relation::{
    prove_rv64im_final_statement_from_accepted, prove_rv64im_folded_statement_from_accepted,
    verify_rv64im_final_statement, verify_rv64im_folded_statement,
};
use neo_fold_next::rv64im::{
    parity_source_cases, prove_rv64im_accepted_proof, prove_rv64im_accepted_proof_with_options, Rv64imProofInput,
    Rv64imPublicProofOptions,
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
fn rv64im_folded_statement_round_trip() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let (artifact, _audit) = prove_rv64im_accepted_proof(&input).expect("prove accepted rv64im proof");
    let (folded, proof) =
        prove_rv64im_folded_statement_from_accepted(&artifact).expect("prove rv64im folded statement");

    assert_eq!(folded.chunk_count, artifact.statement.chunk_count);
    assert_eq!(folded.fold_schedule, artifact.statement.fold_schedule);
    assert_ne!(folded.kernel_relation_digest, [0; 32]);
    assert_eq!(proof.steps.len(), folded.chunk_count as usize);

    verify_rv64im_folded_statement(&folded, &proof).expect("verify rv64im folded statement");
}

#[test]
fn rv64im_final_statement_round_trip() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let (artifact, _audit) = prove_rv64im_accepted_proof(&input).expect("prove accepted rv64im proof");
    let (statement, proof) =
        prove_rv64im_final_statement_from_accepted(&artifact).expect("prove rv64im final statement");

    assert_eq!(statement.public_statement_digest, artifact.statement.digest);
    assert_eq!(proof.steps.len(), statement.folded.chunk_count as usize);
    assert_ne!(proof.proof_digest, [0; 32]);
    assert_ne!(statement.digest, [0; 32]);

    verify_rv64im_final_statement(&statement, &proof).expect("verify rv64im final statement");
}

#[test]
fn rv64im_final_statement_rejects_tampered_accepted_artifact() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let (artifact, _audit) = prove_rv64im_accepted_proof(&input).expect("prove accepted rv64im proof");
    let (statement, mut proof) =
        prove_rv64im_final_statement_from_accepted(&artifact).expect("prove rv64im final statement");
    proof.accepted_artifact.root_execution.digest[0] ^= 1;

    let err = verify_rv64im_final_statement(&statement, &proof)
        .expect_err("tampered accepted artifact must fail final verification");
    assert!(format!("{err}").contains("accepted proof artifact") || format!("{err}").contains("digest"));
}

#[test]
fn rv64im_final_statement_rejects_tampered_chunk_replay_witness() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let (artifact, _audit) = prove_rv64im_accepted_proof(&input).expect("prove accepted rv64im proof");
    let (statement, mut proof) =
        prove_rv64im_final_statement_from_accepted(&artifact).expect("prove rv64im final statement");
    proof.steps[0].replay_witness.ccs_replay_proof.header_digest[0] ^= 1;

    let err = verify_rv64im_final_statement(&statement, &proof)
        .expect_err("tampered replay witness must fail final verification");
    assert!(format!("{err}").contains("final proof digest") || format!("{err}").contains("chunk"));
}

#[test]
fn rv64im_final_statement_rejects_reordered_chunk_witnesses() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let (artifact, _audit) = prove_rv64im_accepted_proof_with_options(
        &input,
        Rv64imPublicProofOptions {
            root_fold_schedule: FoldSchedule::RowsPerChunk(1),
        },
    )
    .expect("prove chunked accepted rv64im proof");
    let (statement, mut proof) =
        prove_rv64im_final_statement_from_accepted(&artifact).expect("prove rv64im final statement");

    assert!(proof.steps.len() > 1, "expected multi-chunk final proof");
    proof.steps.swap(0, 1);

    let err = verify_rv64im_final_statement(&statement, &proof)
        .expect_err("reordered chunk witnesses must fail final verification");
    assert!(
        format!("{err}").contains("final proof digest")
            || format!("{err}").contains("transition")
            || format!("{err}").contains("verify failed")
    );
}

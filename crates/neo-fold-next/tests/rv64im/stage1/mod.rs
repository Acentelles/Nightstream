use crate::common::proof_cases::{
    alu_input, branch_input, divu_input, expect_accepted_verify_failure, parity_input, prove_accepted,
};
use neo_fold_next::rv64im::verify_rv64im_accepted_proof;

#[test]
fn accepted_stage1_bundle_tracks_sem_inputs_and_selected_opening() {
    let input = alu_input();
    let (artifact, _) = prove_accepted(&input);
    verify_rv64im_accepted_proof(&artifact).expect("accepted proof verifies");
    assert_eq!(
        artifact.stage1.sem_inputs.len(),
        artifact.root_execution.execution_rows.len()
    );
    assert_eq!(
        artifact.stage1.selected_opening.digest,
        artifact.stage_packages.packages.stage1.digest
    );
}

#[test]
fn accepted_stage1_rejects_tampered_sem_inputs() {
    let input = alu_input();
    let (mut artifact, _) = prove_accepted(&input);
    artifact.stage1.sem_inputs[0].rs1_value += 1;
    expect_accepted_verify_failure(&artifact, "stage1 semantic inputs mismatch");
}

#[test]
fn accepted_stage1_rejects_tampered_branch_binding() {
    let input = branch_input();
    let (mut artifact, _) = prove_accepted(&input);
    let effect_row = artifact
        .stage1
        .row_bindings
        .iter_mut()
        .find(|row| row.is_effect_row)
        .expect("effect row");
    effect_row.next_pc += 4;
    expect_accepted_verify_failure(&artifact, "stage1");
}

#[test]
fn accepted_stage1_rejects_tampered_nonselected_divu_helper_row() {
    let input = divu_input();
    let (mut artifact, _) = prove_accepted(&input);
    let helper_row = artifact
        .stage1
        .row_bindings
        .iter_mut()
        .find(|row| row.trace_virtual_opcode.is_none() && !row.is_effect_row && !row.is_commit_row)
        .expect("non-selected divu helper row");
    helper_row.alu_result ^= 1;
    expect_accepted_verify_failure(&artifact, "stage1 row bindings mismatch");
}

#[test]
fn accepted_stage1_accepts_multiply_high_parity_case() {
    let input = parity_input("multiply_high_mulh_mulhu_mulhsu_ecall");
    let (artifact, _) = prove_accepted(&input);
    verify_rv64im_accepted_proof(&artifact).expect("accepted proof verifies");
}

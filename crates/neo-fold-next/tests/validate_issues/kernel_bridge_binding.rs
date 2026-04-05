use neo_fold_next::chip8::proof::{prove_audit, verify_audit};

use super::kernel_progress::{build_jump_kernel_input, verifier_input_from_public};

#[test]
fn simple_kernel_populates_bridge_binding_summary() {
    let input = build_jump_kernel_input(2);
    let (audit, proof) = prove_audit(&input).expect("prove audit");

    assert_eq!(
        audit.bridge_binding_summary.claims.len(),
        proof.stage3.row_bindings.len()
    );
    assert!(audit
        .bridge_binding_summary
        .digest
        .iter()
        .any(|&byte| byte != 0));
    assert_eq!(
        audit.bridge_binding_summary.claims[0].row_index,
        proof.stage3.row_bindings[0].row_index
    );
    assert!(audit.bridge_binding_summary.claims[0]
        .row_binding_refinement_digest
        .iter()
        .any(|&byte| byte != 0));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_bridge_binding_claim_digest() {
    let input = build_jump_kernel_input(2);
    let (mut audit, proof) = prove_audit(&input).expect("prove audit");
    audit.bridge_binding_summary.claims[0].prepared_step_digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let err = verify_audit(&verifier_input, &proof, &audit).expect_err("tampered bridge binding claim must fail");
    assert!(format!("{err}").contains("bridge binding"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_bridge_binding_summary_digest() {
    let input = build_jump_kernel_input(2);
    let (mut audit, proof) = prove_audit(&input).expect("prove audit");
    audit.bridge_binding_summary.digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let err = verify_audit(&verifier_input, &proof, &audit).expect_err("tampered bridge binding summary must fail");
    assert!(format!("{err}").contains("bridge binding"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_bridge_binding_refinement_digest() {
    let input = build_jump_kernel_input(2);
    let (mut audit, proof) = prove_audit(&input).expect("prove audit");
    audit.bridge_binding_summary.claims[0].row_binding_refinement_digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let err = verify_audit(&verifier_input, &proof, &audit).expect_err("tampered bridge binding refinement must fail");
    assert!(format!("{err}").contains("bridge binding"));
}

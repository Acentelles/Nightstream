#[path = "support/chip8.rs"]
mod chip8_support;

use neo_fold_next::chip8::proof::{prove_audit, verify_audit};

#[test]
fn chip8_audit_bundle_reproduces_row_projection_digest() {
    let input = chip8_support::build_jump_kernel_input(2);
    let (audit, proof) = prove_audit(&input).expect("prove audit");

    assert_eq!(
        audit
            .semantic_evidence_summary
            .row_projection_summary_digest,
        audit.row_projection_summary.digest
    );

    let verifier_input = chip8_support::verifier_input_from_public(&input.public);
    verify_audit(&verifier_input, &proof, &audit).expect("verify audit");
}

#[test]
fn chip8_audit_bundle_reproduces_bridge_binding_digest() {
    let input = chip8_support::build_jump_kernel_input(2);
    let (audit, proof) = prove_audit(&input).expect("prove audit");

    assert_eq!(
        audit
            .semantic_evidence_summary
            .bridge_binding_summary_digest,
        audit.bridge_binding_summary.digest
    );

    let verifier_input = chip8_support::verifier_input_from_public(&input.public);
    verify_audit(&verifier_input, &proof, &audit).expect("verify audit");
}

#[test]
fn chip8_audit_bundle_reproduces_semantic_evidence_digest() {
    let input = chip8_support::build_jump_kernel_input(2);
    let (audit, proof) = prove_audit(&input).expect("prove audit");

    assert_eq!(
        audit.semantic_evidence_summary.digest,
        audit.semantic_evidence_summary.expected_digest()
    );

    let verifier_input = chip8_support::verifier_input_from_public(&input.public);
    verify_audit(&verifier_input, &proof, &audit).expect("verify audit");
}

#[test]
fn chip8_audit_bundle_verifier_rejects_tampered_audit_digest() {
    let input = chip8_support::build_jump_kernel_input(2);
    let (mut audit, proof) = prove_audit(&input).expect("prove audit");
    audit.semantic_evidence_summary.digest[0] ^= 1;

    let verifier_input = chip8_support::verifier_input_from_public(&input.public);
    let err = verify_audit(&verifier_input, &proof, &audit).expect_err("tampered audit digest must fail");
    assert!(format!("{err}").contains("audit") || format!("{err}").contains("semantic evidence"));
}

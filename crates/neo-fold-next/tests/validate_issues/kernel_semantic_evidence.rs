use neo_fold_next::chip8::proof::{prove_audit, verify_audit};

use super::kernel_progress::{build_jump_kernel_input, verifier_input_from_public};

#[test]
fn simple_kernel_populates_semantic_evidence_summary() {
    let input = build_jump_kernel_input(2);
    let (audit, proof) = prove_audit(&input).expect("prove audit");

    assert_eq!(
        audit
            .semantic_evidence_summary
            .kernel_opening_manifest_digest,
        proof.kernel_opening_manifest.digest
    );
    assert_eq!(
        audit.semantic_evidence_summary.root_opening_manifest_digest,
        proof.root_opening_manifest.digest
    );
    assert_eq!(
        audit
            .semantic_evidence_summary
            .opening_refinement_summary_digest,
        proof.opening_refinement_summary.digest
    );
    assert_eq!(
        audit.semantic_evidence_summary.joint_opening_summary_digest,
        proof.joint_opening_summary.digest
    );
    assert_eq!(
        audit
            .semantic_evidence_summary
            .joint_opening_fold_bucket_proof_digests,
        proof
            .joint_opening_fold_bucket_proofs
            .iter()
            .map(|proof| proof.digest)
            .collect::<Vec<_>>()
    );
    assert_eq!(
        audit
            .semantic_evidence_summary
            .row_projection_summary_digest,
        audit.row_projection_summary.digest
    );
    assert_eq!(
        audit
            .semantic_evidence_summary
            .bridge_binding_summary_digest,
        audit.bridge_binding_summary.digest
    );
    assert_eq!(
        audit.semantic_evidence_summary.digest,
        audit.semantic_evidence_summary.expected_digest()
    );
    assert!(audit
        .semantic_evidence_summary
        .digest
        .iter()
        .any(|&byte| byte != 0));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_semantic_evidence_stage_digest() {
    let input = build_jump_kernel_input(2);
    let (mut audit, proof) = prove_audit(&input).expect("prove audit");
    audit.semantic_evidence_summary.stage2_digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let err = verify_audit(&verifier_input, &proof, &audit).expect_err("tampered semantic evidence stage must fail");
    assert!(format!("{err}").contains("semantic evidence"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_semantic_evidence_digest() {
    let input = build_jump_kernel_input(2);
    let (mut audit, proof) = prove_audit(&input).expect("prove audit");
    audit.semantic_evidence_summary.digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let err = verify_audit(&verifier_input, &proof, &audit).expect_err("tampered semantic evidence digest must fail");
    assert!(format!("{err}").contains("semantic evidence"));
}

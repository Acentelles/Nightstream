use neo_transcript::{Poseidon2Transcript, Transcript};

use super::kernel_progress::{
    build_jump_kernel_input, chip8_root_params, make_ajtai_module, prove_simple_kernel, verifier_input_from_public,
    verify_simple_kernel,
};

#[test]
fn simple_kernel_populates_semantic_evidence_summary() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_semantic_evidence");
    let (output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");

    assert_eq!(
        proof
            .semantic_evidence_summary
            .kernel_opening_manifest_digest,
        proof.kernel_opening_manifest.digest
    );
    assert_eq!(
        proof.semantic_evidence_summary.root_opening_manifest_digest,
        proof.root_opening_manifest.digest
    );
    assert_eq!(
        proof
            .semantic_evidence_summary
            .opening_refinement_summary_digest,
        proof.opening_refinement_summary.digest
    );
    assert_eq!(
        proof.semantic_evidence_summary.joint_opening_summary_digest,
        proof.joint_opening_summary.digest
    );
    assert_eq!(
        proof
            .semantic_evidence_summary
            .joint_opening_fold_bucket_proof_digests,
        proof
            .joint_opening_fold_bucket_proofs
            .iter()
            .map(|proof| proof.digest)
            .collect::<Vec<_>>()
    );
    assert_eq!(
        proof
            .semantic_evidence_summary
            .row_projection_summary_digest,
        proof.row_projection_summary.digest
    );
    assert_eq!(
        proof
            .semantic_evidence_summary
            .bridge_binding_summary_digest,
        proof.bridge_binding_summary.digest
    );
    assert_eq!(
        output.semantic_evidence_summary.digest,
        proof.semantic_evidence_summary.digest
    );
    assert!(proof
        .semantic_evidence_summary
        .digest
        .iter()
        .any(|&byte| byte != 0));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_semantic_evidence_stage_digest() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_semantic_evidence_stage");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.semantic_evidence_summary.stage2_digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_semantic_evidence_stage");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered semantic evidence stage digest must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("semantic evidence"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_semantic_evidence_digest() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_semantic_evidence_digest");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.semantic_evidence_summary.digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_semantic_evidence_digest");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered semantic evidence digest must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("semantic evidence"));
}

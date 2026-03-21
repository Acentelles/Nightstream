use neo_transcript::{Poseidon2Transcript, Transcript};

use super::kernel_progress::{
    build_jump_kernel_input, chip8_root_params, make_ajtai_module, prove_simple_kernel, verifier_input_from_public,
    verify_simple_kernel,
};

#[test]
fn simple_kernel_populates_opening_refinement_summary() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_opening_refinement_populates");
    let (_output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");

    assert_eq!(
        proof.opening_refinement_summary.refinements.len(),
        proof.kernel_opening_manifest.claims.len()
    );
    assert!(proof
        .opening_refinement_summary
        .digest
        .iter()
        .any(|&byte| byte != 0));
    assert_eq!(
        proof.opening_refinement_summary.refinements[0].claim_digest,
        proof.kernel_opening_manifest.claims[0].digest
    );
    assert_eq!(
        proof.joint_opening_summary.claims[0].refinement_digest,
        proof.opening_refinement_summary.refinements[0].digest
    );
}

#[test]
fn simple_kernel_verifier_rejects_tampered_opening_refinement_digest() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_opening_refinement_digest");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.opening_refinement_summary.refinements[0].digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_opening_refinement_digest");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered opening refinement digest must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("opening refinement"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_opening_refinement_summary_digest() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_opening_refinement_summary");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.opening_refinement_summary.digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_opening_refinement_summary");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered opening refinement summary digest must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("opening refinement"));
}

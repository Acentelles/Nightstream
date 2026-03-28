use neo_transcript::{Poseidon2Transcript, Transcript};

use super::kernel_progress::{
    build_jump_kernel_input, chip8_root_params, make_ajtai_module, prove_simple_kernel, verifier_input_from_public,
    verify_simple_kernel,
};

#[test]
fn simple_kernel_populates_row_projection_summary() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_row_projection_populates");
    let (output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");

    assert_eq!(
        proof.row_projection_summary.projections.len(),
        proof.stage3.row_bindings.len()
    );
    assert_eq!(
        output.row_projection_summary.projections.len(),
        output.prepared_steps.len()
    );
    assert!(proof
        .row_projection_summary
        .digest
        .iter()
        .any(|&byte| byte != 0));
    assert_eq!(
        proof.row_projection_summary.projections[0].row_index,
        proof.stage3.row_bindings[0].row_index
    );
    assert!(proof.row_projection_summary.projections[0]
        .row_binding_refinement_digest
        .iter()
        .any(|&byte| byte != 0));
    assert!(proof.row_projection_summary.projections[0]
        .semantic_view_digest
        .iter()
        .any(|&byte| byte != 0));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_row_projection_claim_digest() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_row_projection_claim");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.row_projection_summary.projections[0].semantic_view_digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_row_projection_claim");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered row projection claim must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("row projection"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_row_projection_refinement_digest() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_row_projection_refinement");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.row_projection_summary.projections[0].row_binding_refinement_digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_row_projection_refinement");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered row projection refinement must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("row projection"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_row_projection_summary_digest() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_row_projection_summary");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.row_projection_summary.digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_row_projection_summary");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered row projection summary digest must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("row projection"));
}

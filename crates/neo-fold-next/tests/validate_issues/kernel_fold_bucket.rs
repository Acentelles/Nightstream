use super::kernel_progress::{
    build_jump_kernel_input, chip8_root_params, make_ajtai_module, prove_simple_kernel, verifier_input_from_public,
    verify_simple_kernel,
};
use neo_fold_next::chip8::spec::CommitmentId;
use neo_math::{F, K};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

#[test]
fn simple_kernel_exports_joint_opening_fold_bucket_proofs() {
    let input = build_jump_kernel_input(1);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_fold_bucket");
    let (output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");

    assert!(!proof.joint_opening_fold_bucket_proofs.is_empty());
    assert_eq!(
        proof.joint_opening_fold_bucket_proofs,
        output.joint_opening_fold_bucket_proofs
    );
    assert!(proof
        .joint_opening_fold_bucket_proofs
        .iter()
        .any(|bucket| bucket.commitment_id == CommitmentId::Lane));
    assert!(proof
        .joint_opening_fold_bucket_proofs
        .iter()
        .any(|bucket| bucket.commitment_id == CommitmentId::FetchRa));
    assert!(proof
        .joint_opening_fold_bucket_proofs
        .iter()
        .all(|bucket| bucket.digest.iter().any(|&byte| byte != 0)));
}

#[test]
fn simple_kernel_verifier_rejects_forged_joint_opening_fold_bucket_proof() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening_fold_bucket_forged");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    assert!(!proof.joint_opening_fold_bucket_proofs.is_empty());
    proof.joint_opening_fold_bucket_proofs[0].digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening_fold_bucket_forged");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("forged kernel joint-opening fold bucket proof must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("fold bucket"));
}

#[test]
fn simple_kernel_verifier_rejects_forged_joint_opening_fold_bucket_commitment() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening_fold_bucket_commitment");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    assert!(!proof.joint_opening_fold_bucket_proofs.is_empty());
    proof.joint_opening_fold_bucket_proofs[0]
        .folded_commitment
        .data[0] += F::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening_fold_bucket_commitment");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("forged folded bucket commitment must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("fold bucket"));
}

#[test]
fn simple_kernel_verifier_rejects_forged_joint_opening_fold_bucket_digits() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening_fold_bucket_digits");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    assert!(!proof.joint_opening_fold_bucket_proofs.is_empty());
    assert!(!proof.joint_opening_fold_bucket_proofs[0]
        .folded_claim_digits
        .is_empty());
    proof.joint_opening_fold_bucket_proofs[0].folded_claim_digits[0] += K::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening_fold_bucket_digits");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("forged folded bucket digits must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("fold bucket"));
}

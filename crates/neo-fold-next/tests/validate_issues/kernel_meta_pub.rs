use neo_transcript::{Poseidon2Transcript, Transcript};

use super::kernel_progress::{
    build_jump_kernel_input, chip8_root_params, make_ajtai_module, prove_simple_kernel, verifier_input_from_public,
    verify_simple_kernel,
};

#[test]
fn simple_kernel_populates_expanded_meta_pub() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_meta_pub");
    let (_output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");

    assert!(proof
        .meta_pub
        .rom_table_digest
        .iter()
        .any(|&byte| byte != 0));
    assert!(proof
        .meta_pub
        .decode_table_digest
        .iter()
        .any(|&byte| byte != 0));
    assert!(proof
        .meta_pub
        .alu_table_digest
        .iter()
        .any(|&byte| byte != 0));
    assert!(proof
        .meta_pub
        .eq4_table_digest
        .iter()
        .any(|&byte| byte != 0));
    assert!(proof.meta_pub.root_params_id.iter().any(|&byte| byte != 0));
    assert_eq!(proof.meta_pub.protocol_version_id, 1);
    assert_eq!(proof.meta_pub.field_id, 1);
    assert_eq!(proof.meta_pub.extension_field_id, 1);
    assert_eq!(proof.meta_pub.variable_order_id, 1);
    assert_eq!(proof.meta_pub.domain_shape_id, 1);
    assert_eq!(proof.meta_pub.sink_convention_id, 1);
    assert_eq!(proof.meta_pub.init_mode_id, 1);
    assert_eq!(proof.meta_pub.lowering_convention_id, 1);
    assert_eq!(proof.meta_pub.padding_convention_id, 1);
    assert_eq!(proof.meta_pub.table_auth_mode_id, 1);
    assert_eq!(proof.meta_pub.opening_reduction_mode_id, 1);
}

#[test]
fn simple_kernel_verifier_rejects_tampered_meta_pub_root_params_id() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_meta_pub_root_params");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.meta_pub.root_params_id[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_meta_pub_root_params");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered root params id must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("root params id"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_meta_pub_rom_table_digest() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_meta_pub_rom_table");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.meta_pub.rom_table_digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_meta_pub_rom_table");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered rom table digest must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("rom table digest"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_meta_pub_field_id() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_meta_pub_field_id");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.meta_pub.field_id ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_meta_pub_field_id");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered field id must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("field_id"));
}

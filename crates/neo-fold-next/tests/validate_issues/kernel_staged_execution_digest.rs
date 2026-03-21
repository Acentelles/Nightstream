use neo_fold_next::chip8::kernel::{
    build_kernel_stage3_digest_surfaces, build_kernel_staged_execution_digest_bundle,
    verify_kernel_staged_execution_digest_bundle,
};
use neo_math::{F, K};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use super::kernel_progress::{build_jump_kernel_input, chip8_root_params, make_ajtai_module, prove_simple_kernel};

#[test]
fn simple_kernel_populates_staged_execution_digest_bundle() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);
    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_staged_digest");

    let (output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");
    let stage3 = build_kernel_stage3_digest_surfaces(&input.public, &proof, &output).expect("stage3 digest surfaces");
    let bundle =
        build_kernel_staged_execution_digest_bundle(&input.public, &proof, &output).expect("staged digest bundle");

    assert_eq!(bundle.public.public, input.public);
    assert_eq!(bundle.public.meta_pub, proof.meta_pub);
    assert_eq!(bundle.digests.len(), proof.meta_pub.semantic_rows);
    assert_eq!(bundle.digests[0].stage1.pre.pc, input.public.initial_pc_word * 2);
    assert_eq!(bundle.digests[0].stage1.dec, bundle.digests[0].stage2.dec);
    assert_eq!(bundle.digests[0].stage1.row, bundle.digests[0].stage2.row);
    assert_eq!(bundle.digests[0].stage3, stage3[0]);
    assert_eq!(bundle.digests[1].stage3, stage3[1]);
    assert_eq!(bundle.digests[0].result.step_idx, 0);
    assert_eq!(bundle.digests[1].result.step_idx, 1);
}

#[test]
fn simple_kernel_staged_execution_digest_bundle_rejects_tampered_stage3_beta() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);
    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_staged_digest_stage3_tamper");

    let (output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");
    let mut bundle =
        build_kernel_staged_execution_digest_bundle(&input.public, &proof, &output).expect("staged digest bundle");
    bundle.digests[0].stage3.beta2 += K::ONE;

    let err =
        verify_kernel_staged_execution_digest_bundle(&input.public, &proof, &output, &bundle).expect_err("tamper");
    assert!(err.contains("staged execution digest"));
}

#[test]
fn simple_kernel_staged_execution_digest_bundle_rejects_tampered_stage1_row() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);
    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_staged_digest_stage1_tamper");

    let (output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");
    let mut bundle =
        build_kernel_staged_execution_digest_bundle(&input.public, &proof, &output).expect("staged digest bundle");
    bundle.digests[0].stage1.row[1] += F::ONE;

    let err =
        verify_kernel_staged_execution_digest_bundle(&input.public, &proof, &output, &bundle).expect_err("tamper");
    assert!(err.contains("staged execution digest"));
}

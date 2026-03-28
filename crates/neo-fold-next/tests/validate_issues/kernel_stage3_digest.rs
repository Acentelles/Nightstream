use neo_fold_next::chip8::kernel::{
    build_kernel_stage3_digest_surfaces, verify_kernel_stage3_digest_surfaces, KernelStage3LaneColumn,
    KernelStage3ShiftedColumn,
};
use neo_fold_next::chip8::spec::CommitmentId;
use neo_math::{F, K};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use super::kernel_progress::{build_jump_kernel_input, chip8_root_params, make_ajtai_module, prove_simple_kernel};

#[test]
fn simple_kernel_populates_stage3_digest_surfaces() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);
    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_stage3_digest");

    let (output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");
    let surfaces = build_kernel_stage3_digest_surfaces(&input.public, &proof, &output).expect("stage3 digest surfaces");

    assert_eq!(surfaces.len(), proof.meta_pub.semantic_rows);
    assert_eq!(surfaces[0].n, proof.meta_pub.semantic_rows);
    assert_eq!(surfaces[0].step_idx, 0);
    assert_eq!(surfaces[1].step_idx, 1);
    assert_eq!(surfaces[0].beta1, surfaces[1].beta1);
    assert_eq!(surfaces[0].beta2, surfaces[1].beta2);
    assert_eq!(surfaces[0].current_row.pair_mask, F::ONE);
    assert_eq!(surfaces[1].current_row.pair_mask, F::ZERO);
    assert_eq!(surfaces[0].shift_claim.source_commitment, CommitmentId::Lane);
    assert_eq!(
        surfaces[0].shift_claim.source_columns,
        [
            KernelStage3LaneColumn::Pc,
            KernelStage3LaneColumn::XIdx,
            KernelStage3LaneColumn::IsMemOp
        ]
    );
    assert_eq!(
        surfaces[0].shift_claim.shifted_columns,
        [
            KernelStage3ShiftedColumn::ShiftPc,
            KernelStage3ShiftedColumn::ShiftXIdx,
            KernelStage3ShiftedColumn::ShiftIsMemOp
        ]
    );
    assert_eq!(
        surfaces[0].shift_claim.source_point,
        proof.stage3.shift_proof.source_point
    );
    assert_eq!(surfaces[0].row_claim.row_index, 0);
    assert_eq!(surfaces[1].row_claim.row_index, 1);
}

#[test]
fn simple_kernel_stage3_digest_surfaces_reject_tampered_beta() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);
    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_stage3_digest_beta_tamper");

    let (output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");
    let mut surfaces =
        build_kernel_stage3_digest_surfaces(&input.public, &proof, &output).expect("stage3 digest surfaces");
    surfaces[0].beta1 += K::ONE;

    let err = verify_kernel_stage3_digest_surfaces(&input.public, &proof, &output, &surfaces).expect_err("tamper");
    assert!(err.contains("stage3 digest"));
}

#[test]
fn simple_kernel_stage3_digest_surfaces_reject_tampered_prepared_step() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);
    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_stage3_digest_step_tamper");

    let (output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");
    let mut surfaces =
        build_kernel_stage3_digest_surfaces(&input.public, &proof, &output).expect("stage3 digest surfaces");
    surfaces[0].prepared_step.witness.w[0] += F::ONE;

    let err = verify_kernel_stage3_digest_surfaces(&input.public, &proof, &output, &surfaces).expect_err("tamper");
    assert!(err.contains("stage3 digest"));
}

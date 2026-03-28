use neo_fold_next::chip8::spec::{
    build_pad_row, COL_BURST_LAST, COL_IS_MEMOP, COL_PC, COL_PC_NEXT, COL_X_IDX, WITNESS_WIDTH,
};
use neo_fold_next::chip8::stage3::{prove_stage3, verify_stage3};
use neo_math::{F, K};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

fn make_row(pc: u64, pc_next: u64, x_idx: u64, is_memop: bool, burst_last: bool) -> [F; WITNESS_WIDTH] {
    let mut row = [F::ZERO; WITNESS_WIDTH];
    row[COL_PC] = F::from_u64(pc);
    row[COL_PC_NEXT] = F::from_u64(pc_next);
    row[COL_X_IDX] = F::from_u64(x_idx);
    row[COL_IS_MEMOP] = if is_memop { F::ONE } else { F::ZERO };
    row[COL_BURST_LAST] = if burst_last { F::ONE } else { F::ZERO };
    row
}

#[test]
fn stage3_verifier_accepts_valid_proof_with_padded_suffix() {
    let pad_pc_word = 0x101;
    let trace_rows = vec![
        make_row(10, 20, 0, false, false),
        make_row(20, 30, 0, false, false),
        make_row(30, 0, 0, false, false),
        build_pad_row(pad_pc_word),
    ];

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/stage3_verify_ok");
    let proof = prove_stage3(&trace_rows, 3, 2, &mut prove_transcript).expect("stage3 proof");

    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/stage3_verify_ok");
    verify_stage3(&proof, 3, 4, pad_pc_word, 2, &mut verify_transcript).expect("stage3 verify");
}

#[test]
fn stage3_verifier_rejects_tampered_row_bits() {
    let trace_rows = vec![make_row(10, 20, 0, false, false), make_row(20, 20, 0, false, false)];
    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/stage3_verify_row_bits");
    let mut proof = prove_stage3(&trace_rows, 2, 1, &mut prove_transcript).expect("stage3 proof");
    proof.row_bindings[0].row_bits[0] = true;

    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/stage3_verify_row_bits");
    let err = verify_stage3(&proof, 2, 2, 0, 1, &mut verify_transcript)
        .expect_err("tampered row bits must fail verification");
    assert!(format!("{err}").contains("bits do not match"));
}

#[test]
fn stage3_verifier_rejects_tampered_shift_opening() {
    let trace_rows = vec![make_row(10, 20, 0, false, false), make_row(20, 20, 0, false, false)];
    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/stage3_verify_shift_opening");
    let mut proof = prove_stage3(&trace_rows, 2, 1, &mut prove_transcript).expect("stage3 proof");
    proof.shift_opening_values[1] += K::ONE;

    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/stage3_verify_shift_opening");
    let err = verify_stage3(&proof, 2, 2, 0, 1, &mut verify_transcript)
        .expect_err("tampered shift opening must fail verification");
    let err_text = format!("{err}");
    assert!(err_text.contains("continuity") || err_text.contains("mismatch"));
}

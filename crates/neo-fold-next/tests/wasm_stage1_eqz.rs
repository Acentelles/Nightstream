use neo_fold_next::wasm::{
    build_stage1_summary, opcode_code, opcode_info_from_code, prove_stage1_eqz, verify_stage1_eqz, StackLaneAccess,
    WasmOpcode, WasmStepTrace,
};
use neo_math::K;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

fn step(cycle: u64, input: u32, output: u32) -> WasmStepTrace {
    let opcode = WasmOpcode::I32Eqz;
    let code = opcode_code(opcode);
    let info = opcode_info_from_code(code);
    WasmStepTrace {
        cycle,
        pc_before: cycle,
        pc_after: cycle + 1,
        opcode_code: code,
        opcode,
        info,
        sp_before: 1,
        sp_after: 1,
        stack_read0: Some(StackLaneAccess { addr: 0, value: input }),
        stack_read1: None,
        stack_read2: None,
        stack_write1: Some(StackLaneAccess { addr: 0, value: output }),
        halted: false,
        locals_fbp: 0,
        local_index: None,
        local_read_value: None,
        local_write_value: None,
    }
}

#[test]
fn stage1_eqz_prove_and_verify_roundtrip() {
    let summary = build_stage1_summary(&[step(0, 0, 1), step(1, 9, 0)]);

    let mut prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage1-test");
    let proof = prove_stage1_eqz(&summary, &mut prover_tr).expect("prove");

    let mut verifier_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage1-test");
    verify_stage1_eqz(&summary, &proof, &mut verifier_tr).expect("verify");
}

#[test]
fn stage1_eqz_prover_rejects_bad_semantics() {
    let summary = build_stage1_summary(&[step(0, 0, 0)]);
    let mut prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage1-test");
    assert!(prove_stage1_eqz(&summary, &mut prover_tr).is_err());
}

#[test]
fn stage1_eqz_verifier_rejects_tampered_claim() {
    let summary = build_stage1_summary(&[step(0, 0, 1), step(1, 9, 0)]);

    let mut prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage1-test");
    let mut proof = prove_stage1_eqz(&summary, &mut prover_tr).expect("prove");
    proof.batched_claim += K::ONE;

    let mut verifier_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage1-test");
    assert!(verify_stage1_eqz(&summary, &proof, &mut verifier_tr).is_err());
}

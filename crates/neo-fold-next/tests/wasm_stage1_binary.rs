use neo_fold_next::wasm::{
    build_stage1_summary, opcode_code, opcode_info_from_code, prove_stage1_binary, verify_stage1_binary,
    StackLaneAccess, WasmOpcode, WasmShoutOpcode, WasmStepTrace,
};
use neo_math::K;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

fn step(opcode: WasmOpcode, cycle: u64, lhs: u32, rhs: u32, output: u32) -> WasmStepTrace {
    let code = opcode_code(opcode);
    let info = opcode_info_from_code(code);
    WasmStepTrace {
        cycle,
        pc_before: cycle,
        pc_after: cycle + 1,
        opcode_code: code,
        opcode,
        info,
        sp_before: 2,
        sp_after: 1,
        stack_read0: Some(StackLaneAccess { addr: 0, value: lhs }),
        stack_read1: Some(StackLaneAccess { addr: 1, value: rhs }),
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
fn stage1_binary_prove_and_verify_roundtrip_for_xor() {
    let summary = build_stage1_summary(&[step(WasmOpcode::I32Xor, 0, 0xaa00, 0x0ff0, 0xa5f0)]);
    let mut prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage1-binary-test");
    let proof = prove_stage1_binary(&summary, WasmShoutOpcode::I32Xor, &mut prover_tr).expect("prove");

    let mut verifier_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage1-binary-test");
    verify_stage1_binary(&summary, &proof, &mut verifier_tr).expect("verify");
}

#[test]
fn stage1_binary_prove_and_verify_roundtrip_for_eq_and_lts() {
    let summary = build_stage1_summary(&[
        step(WasmOpcode::I32Eq, 0, 7, 7, 1),
        step(WasmOpcode::I32LtS, 1, u32::MAX, 0, 1),
    ]);

    let mut eq_prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage1-binary-test");
    let eq_proof = prove_stage1_binary(&summary, WasmShoutOpcode::I32Eq, &mut eq_prover_tr).expect("prove eq");
    let mut eq_verifier_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage1-binary-test");
    verify_stage1_binary(&summary, &eq_proof, &mut eq_verifier_tr).expect("verify eq");

    let mut lts_prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage1-binary-test");
    let lts_proof = prove_stage1_binary(&summary, WasmShoutOpcode::I32LtS, &mut lts_prover_tr).expect("prove lts");
    let mut lts_verifier_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage1-binary-test");
    verify_stage1_binary(&summary, &lts_proof, &mut lts_verifier_tr).expect("verify lts");
}

#[test]
fn stage1_binary_prover_rejects_bad_mul_semantics() {
    let summary = build_stage1_summary(&[step(WasmOpcode::I32Mul, 0, 7, 9, 62)]);
    let mut prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage1-binary-test");
    assert!(prove_stage1_binary(&summary, WasmShoutOpcode::I32Mul, &mut prover_tr).is_err());
}

#[test]
fn stage1_binary_verifier_rejects_tampered_claim() {
    let summary = build_stage1_summary(&[step(WasmOpcode::I32And, 0, 0xff00, 0x0ff0, 0x0f00)]);
    let mut prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage1-binary-test");
    let mut proof = prove_stage1_binary(&summary, WasmShoutOpcode::I32And, &mut prover_tr).expect("prove");
    proof.batched_claim += K::ONE;

    let mut verifier_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage1-binary-test");
    assert!(verify_stage1_binary(&summary, &proof, &mut verifier_tr).is_err());
}

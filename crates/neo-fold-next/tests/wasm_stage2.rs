use neo_fold_next::wasm::{
    build_stage2_summary, opcode_code, opcode_info_from_code, prove_stage2_stack, verify_stage2_stack, StackLaneAccess,
    WasmOpcode, WasmStepTrace,
};
use neo_math::K;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

fn step(
    opcode: WasmOpcode,
    cycle: u64,
    read0: Option<StackLaneAccess>,
    read1: Option<StackLaneAccess>,
    write1: Option<StackLaneAccess>,
) -> WasmStepTrace {
    let code = opcode_code(opcode);
    let info = opcode_info_from_code(code);
    WasmStepTrace {
        cycle,
        pc_before: cycle,
        pc_after: cycle + 1,
        opcode_code: code,
        opcode,
        info,
        sp_before: 0,
        sp_after: 0,
        stack_read0: read0,
        stack_read1: read1,
        stack_read2: None,
        stack_write1: write1,
        halted: false,
    }
}

#[test]
fn stage2_stack_prove_and_verify_roundtrip() {
    let summary = build_stage2_summary(&[
        step(
            WasmOpcode::I32Const,
            0,
            None,
            None,
            Some(StackLaneAccess { addr: 0, value: 7 }),
        ),
        step(
            WasmOpcode::I32Const,
            1,
            None,
            None,
            Some(StackLaneAccess { addr: 1, value: 9 }),
        ),
        step(
            WasmOpcode::I32Add,
            2,
            Some(StackLaneAccess { addr: 0, value: 7 }),
            Some(StackLaneAccess { addr: 1, value: 9 }),
            Some(StackLaneAccess { addr: 0, value: 16 }),
        ),
    ]);

    let mut prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-test");
    let proof = prove_stage2_stack(&summary, &mut prover_tr).expect("prove");

    let mut verifier_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-test");
    verify_stage2_stack(&summary, &proof, &mut verifier_tr).expect("verify");
}

#[test]
fn stage2_stack_prover_rejects_wrong_read_value() {
    let summary = build_stage2_summary(&[
        step(
            WasmOpcode::I32Const,
            0,
            None,
            None,
            Some(StackLaneAccess { addr: 0, value: 7 }),
        ),
        step(
            WasmOpcode::I32Eqz,
            1,
            Some(StackLaneAccess { addr: 0, value: 8 }),
            None,
            Some(StackLaneAccess { addr: 0, value: 0 }),
        ),
    ]);

    let mut prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-test");
    assert!(prove_stage2_stack(&summary, &mut prover_tr).is_err());
}

#[test]
fn stage2_stack_verifier_rejects_tampered_final_slots() {
    let summary = build_stage2_summary(&[step(
        WasmOpcode::I32Const,
        0,
        None,
        None,
        Some(StackLaneAccess { addr: 0, value: 7 }),
    )]);

    let mut prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-test");
    let mut proof = prove_stage2_stack(&summary, &mut prover_tr).expect("prove");
    proof.final_slots.push((9, 42));

    let mut verifier_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-test");
    assert!(verify_stage2_stack(&summary, &proof, &mut verifier_tr).is_err());
}

#[test]
fn stage2_stack_verifier_rejects_tampered_claim() {
    let summary = build_stage2_summary(&[step(
        WasmOpcode::I32Const,
        0,
        None,
        None,
        Some(StackLaneAccess { addr: 0, value: 7 }),
    )]);

    let mut prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-test");
    let mut proof = prove_stage2_stack(&summary, &mut prover_tr).expect("prove");
    proof.batched_read_claim += K::ONE;

    let mut verifier_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-test");
    assert!(verify_stage2_stack(&summary, &proof, &mut verifier_tr).is_err());
}

#[test]
fn stage2_stack_verifier_rejects_tampered_value_from_inc_claim() {
    let summary = build_stage2_summary(&[
        step(
            WasmOpcode::I32Const,
            0,
            None,
            None,
            Some(StackLaneAccess { addr: 0, value: 7 }),
        ),
        step(
            WasmOpcode::I32Const,
            1,
            None,
            None,
            Some(StackLaneAccess { addr: 1, value: 9 }),
        ),
    ]);

    let mut prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-test");
    let mut proof = prove_stage2_stack(&summary, &mut prover_tr).expect("prove");
    proof.value_from_inc_claim += K::ONE;

    let mut verifier_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-test");
    assert!(verify_stage2_stack(&summary, &proof, &mut verifier_tr).is_err());
}

#[test]
fn stage2_stack_verifier_rejects_tampered_family_claim() {
    let summary = build_stage2_summary(&[
        step(
            WasmOpcode::I32Const,
            0,
            None,
            None,
            Some(StackLaneAccess { addr: 0, value: 7 }),
        ),
        step(
            WasmOpcode::I32Eqz,
            1,
            Some(StackLaneAccess { addr: 0, value: 7 }),
            None,
            Some(StackLaneAccess { addr: 0, value: 0 }),
        ),
    ]);

    let mut prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-test");
    let mut proof = prove_stage2_stack(&summary, &mut prover_tr).expect("prove");
    proof.family_claims[0].claim += K::ONE;

    let mut verifier_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-test");
    assert!(verify_stage2_stack(&summary, &proof, &mut verifier_tr).is_err());
}

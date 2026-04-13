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
        locals_fbp: 0,
        local_index: None,
        local_read_value: None,
        local_write_value: None,
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

fn local_step(
    opcode: WasmOpcode,
    cycle: u64,
    local_index: u32,
    local_read_value: Option<u32>,
    local_write_value: Option<u32>,
    stack_read0: Option<StackLaneAccess>,
    stack_write1: Option<StackLaneAccess>,
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
        stack_read0,
        stack_read1: None,
        stack_read2: None,
        stack_write1,
        halted: false,
        locals_fbp: 0,
        local_index: Some(local_index),
        local_read_value,
        local_write_value,
    }
}

#[test]
fn stage2_locals_prove_and_verify_roundtrip() {
    // Full trace: push 7, local.set 0, push 9, local.set 1, local.get 0, local.get 1
    // Stack slot 0 is reused after each pop (sp bounces between 0 and 1).
    let summary = build_stage2_summary(&[
        // i32.const 7: write 7 to stack slot 0
        step(
            WasmOpcode::I32Const,
            0,
            None,
            None,
            Some(StackLaneAccess { addr: 0, value: 7 }),
        ),
        // local.set 0: pop stack slot 0 (value=7), write local[0]=7
        local_step(
            WasmOpcode::LocalSet,
            1,
            0,
            None,
            Some(7),
            Some(StackLaneAccess { addr: 0, value: 7 }),
            None,
        ),
        // i32.const 9: write 9 to stack slot 0 (sp is back to 0)
        step(
            WasmOpcode::I32Const,
            2,
            None,
            None,
            Some(StackLaneAccess { addr: 0, value: 9 }),
        ),
        // local.set 1: pop stack slot 0 (value=9), write local[1]=9
        local_step(
            WasmOpcode::LocalSet,
            3,
            1,
            None,
            Some(9),
            Some(StackLaneAccess { addr: 0, value: 9 }),
            None,
        ),
        // local.get 0: read local[0]=7, push 7 to stack slot 0
        local_step(
            WasmOpcode::LocalGet,
            4,
            0,
            Some(7),
            None,
            None,
            Some(StackLaneAccess { addr: 0, value: 7 }),
        ),
        // local.get 1: read local[1]=9, push 9 to stack slot 1
        local_step(
            WasmOpcode::LocalGet,
            5,
            1,
            Some(9),
            None,
            None,
            Some(StackLaneAccess { addr: 1, value: 9 }),
        ),
    ]);

    let mut prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-locals-test");
    let proof = prove_stage2_stack(&summary, &mut prover_tr).expect("prove locals");

    assert_eq!(proof.locals_final_slots, vec![(0, 7), (1, 9)]);

    let mut verifier_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-locals-test");
    verify_stage2_stack(&summary, &proof, &mut verifier_tr).expect("verify locals");
}

#[test]
fn stage2_locals_prover_rejects_wrong_local_read_value() {
    // Push 7, local.set 0, then local.get 0 claiming value=8 (wrong — was stored as 7).
    let summary = build_stage2_summary(&[
        step(
            WasmOpcode::I32Const,
            0,
            None,
            None,
            Some(StackLaneAccess { addr: 0, value: 7 }),
        ),
        local_step(
            WasmOpcode::LocalSet,
            1,
            0,
            None,
            Some(7),
            Some(StackLaneAccess { addr: 0, value: 7 }),
            None,
        ),
        local_step(
            WasmOpcode::LocalGet,
            2,
            0,
            Some(8),
            None,
            None,
            Some(StackLaneAccess { addr: 0, value: 8 }),
        ),
    ]);

    let mut prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-locals-test");
    assert!(prove_stage2_stack(&summary, &mut prover_tr).is_err());
}

#[test]
fn stage2_locals_verifier_rejects_tampered_locals_final_slots() {
    // Push 42, local.set 0.
    let summary = build_stage2_summary(&[
        step(
            WasmOpcode::I32Const,
            0,
            None,
            None,
            Some(StackLaneAccess { addr: 0, value: 42 }),
        ),
        local_step(
            WasmOpcode::LocalSet,
            1,
            0,
            None,
            Some(42),
            Some(StackLaneAccess { addr: 0, value: 42 }),
            None,
        ),
    ]);

    let mut prover_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-locals-test");
    let mut proof = prove_stage2_stack(&summary, &mut prover_tr).expect("prove");
    proof.locals_final_slots.push((9, 99));

    let mut verifier_tr = Poseidon2Transcript::new(b"neo.fold.next/wasm/stage2-locals-test");
    assert!(verify_stage2_stack(&summary, &proof, &mut verifier_tr).is_err());
}

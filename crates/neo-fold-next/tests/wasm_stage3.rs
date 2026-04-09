use neo_fold_next::wasm::{
    build_stage3_summary, opcode_code, opcode_info_from_code, prove_stage3_boundaries, verify_stage3_boundaries,
    WasmOpcode, WasmStepTrace,
};
use neo_transcript::{Poseidon2Transcript, Transcript};

fn step(
    cycle: u64,
    pc_before: u64,
    pc_after: u64,
    opcode: WasmOpcode,
    sp_before: u64,
    sp_after: u64,
    halted: bool,
) -> WasmStepTrace {
    let opcode_code = opcode_code(opcode);
    WasmStepTrace {
        cycle,
        pc_before,
        pc_after,
        opcode_code,
        opcode,
        info: opcode_info_from_code(opcode_code),
        sp_before,
        sp_after,
        stack_read0: None,
        stack_read1: None,
        stack_read2: None,
        stack_write1: None,
        halted,
    }
}

#[test]
fn stage3_boundary_prove_and_verify_roundtrip() {
    let steps = vec![
        step(0, 0, 1, WasmOpcode::I32Const, 0, 1, false),
        step(1, 1, 2, WasmOpcode::I32Const, 1, 2, false),
        step(2, 2, 3, WasmOpcode::I32Add, 2, 1, false),
        step(3, 3, 4, WasmOpcode::Return, 1, 1, true),
    ];
    let summary = build_stage3_summary(&steps);
    let mut prove_tr = Poseidon2Transcript::new(b"wasm_stage3_roundtrip");
    let proof = prove_stage3_boundaries(&summary, &mut prove_tr).expect("prove");
    let mut verify_tr = Poseidon2Transcript::new(b"wasm_stage3_roundtrip");
    verify_stage3_boundaries(&summary, &proof, &mut verify_tr).expect("verify");
}

#[test]
fn stage3_prover_rejects_broken_pc_continuity() {
    let steps = vec![
        step(0, 0, 1, WasmOpcode::I32Const, 0, 1, false),
        step(1, 7, 8, WasmOpcode::Return, 1, 1, true),
    ];
    let summary = build_stage3_summary(&steps);
    let mut transcript = Poseidon2Transcript::new(b"wasm_stage3_bad_pc");
    let err = prove_stage3_boundaries(&summary, &mut transcript).expect_err("pc continuity must fail");
    assert!(err.contains("continuity"));
}

#[test]
fn stage3_prover_rejects_early_halt() {
    let steps = vec![
        step(0, 0, 1, WasmOpcode::Return, 0, 0, true),
        step(1, 1, 2, WasmOpcode::I32Const, 0, 1, false),
    ];
    let summary = build_stage3_summary(&steps);
    let mut transcript = Poseidon2Transcript::new(b"wasm_stage3_early_halt");
    let err = prove_stage3_boundaries(&summary, &mut transcript).expect_err("early halt must fail");
    assert!(err.contains("halted"));
}

#[test]
fn stage3_verifier_rejects_tampered_final_boundary() {
    let steps = vec![
        step(0, 0, 1, WasmOpcode::I32Const, 0, 1, false),
        step(1, 1, 2, WasmOpcode::Return, 1, 1, true),
    ];
    let summary = build_stage3_summary(&steps);
    let mut prove_tr = Poseidon2Transcript::new(b"wasm_stage3_tamper");
    let mut proof = prove_stage3_boundaries(&summary, &mut prove_tr).expect("prove");
    proof.final_boundary = Some((99, 1, true));
    let mut verify_tr = Poseidon2Transcript::new(b"wasm_stage3_tamper");
    let err = verify_stage3_boundaries(&summary, &proof, &mut verify_tr).expect_err("tampered proof must fail");
    assert!(err.contains("final boundary"));
}

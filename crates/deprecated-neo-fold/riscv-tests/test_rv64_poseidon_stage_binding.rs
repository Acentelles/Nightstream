#![cfg(feature = "poseidon-precompile")]
#![allow(non_snake_case)]

use deprecated_neo_memory::riscv::lookups::{RiscvInstruction, RiscvOpcode};
use neo_fold::pi_ccs::FoldingMode;
use neo_fold::rv64_trace_shard::Rv64TraceWiring;

#[path = "support/rv64_elf.rs"]
mod rv64_elf;

use rv64_elf::build_text_elf64;

fn poseidon_binding_elf() -> Vec<u8> {
    build_text_elf64(
        0x2000,
        &[
            RiscvInstruction::IAlu {
                op: RiscvOpcode::Add,
                rd: 10,
                rs1: 0,
                imm: 1,
            },
            RiscvInstruction::IAlu {
                op: RiscvOpcode::Add,
                rd: 11,
                rs1: 0,
                imm: 0,
            },
            RiscvInstruction::Poseidon2AbsorbElem { rs1: 10, rs2: 11 },
            RiscvInstruction::Poseidon2Finalize,
            RiscvInstruction::Poseidon2SqueezeWord { rd: 12, idx: 0 },
            RiscvInstruction::IAlu {
                op: RiscvOpcode::Add,
                rd: 10,
                rs1: 0,
                imm: 0,
            },
            RiscvInstruction::IAlu {
                op: RiscvOpcode::Add,
                rd: 11,
                rs1: 0,
                imm: 0,
            },
            RiscvInstruction::Halt,
        ],
    )
}

fn poseidon_low32_transport_elf() -> Vec<u8> {
    build_text_elf64(
        0x2000,
        &[
            RiscvInstruction::Lui { rd: 10, imm: 0x80000 },
            RiscvInstruction::IAlu {
                op: RiscvOpcode::Add,
                rd: 10,
                rs1: 10,
                imm: 0x123,
            },
            RiscvInstruction::Lui { rd: 11, imm: 0x90000 },
            RiscvInstruction::IAlu {
                op: RiscvOpcode::Add,
                rd: 11,
                rs1: 11,
                imm: 0x456,
            },
            RiscvInstruction::Poseidon2AbsorbElem { rs1: 10, rs2: 11 },
            RiscvInstruction::Poseidon2Finalize,
            RiscvInstruction::Poseidon2SqueezeWord { rd: 12, idx: 0 },
            RiscvInstruction::Halt,
        ],
    )
}

#[test]
fn test_rv64_poseidon_stage_binding_prove_verify() {
    let elf = poseidon_binding_elf();
    let mut run = Rv64TraceWiring::from_elf(&elf)
        .expect("from_elf")
        .mode(FoldingMode::Optimized)
        .chunk_rows(8)
        .max_steps(32)
        .prove()
        .expect("poseidon prove");

    let step = &run.proof().steps[0];
    assert!(
        !step.mem.poseidon_cycle_me_claims.is_empty(),
        "RV64 poseidon path must emit cycle ME claims"
    );
    assert!(
        !step.mem.poseidon_local_me_claims.is_empty(),
        "RV64 poseidon path must emit local ME claims"
    );
    assert!(
        !step.poseidon_cycle_fold.is_empty(),
        "RV64 poseidon path must emit cycle fold claims"
    );
    assert!(
        step.poseidon_local_time.is_some(),
        "RV64 poseidon path must emit local time proof data"
    );
    assert!(
        !step.poseidon_local_fold.is_empty(),
        "RV64 poseidon path must emit local fold claims"
    );

    run.verify().expect("poseidon verify");
}

#[test]
fn test_rv64_poseidon_stage_binding_uses_low32_transport_words() {
    let elf = poseidon_low32_transport_elf();
    let mut run = Rv64TraceWiring::from_elf(&elf)
        .expect("from_elf")
        .mode(FoldingMode::Optimized)
        .chunk_rows(8)
        .max_steps(32)
        .prove()
        .expect("poseidon prove with dirty high halves");

    run.verify()
        .expect("poseidon verify with dirty high halves");
}

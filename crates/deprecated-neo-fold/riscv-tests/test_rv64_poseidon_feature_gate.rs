#![allow(non_snake_case)]

use neo_fold::pi_ccs::FoldingMode;
use neo_fold::rv64_trace_shard::Rv64TraceWiring;
use neo_memory::riscv::lookups::{RiscvInstruction, RiscvOpcode};

#[path = "support/rv64_elf.rs"]
mod rv64_elf;

use rv64_elf::build_text_elf64;

fn poseidon_precompile_elf() -> Vec<u8> {
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

#[cfg(not(feature = "poseidon-precompile"))]
#[test]
fn test_rv64_poseidon_feature_gate_rejects_disabled_precompile() {
    let elf = poseidon_precompile_elf();
    let result = Rv64TraceWiring::from_elf(&elf)
        .expect("from_elf")
        .mode(FoldingMode::Optimized)
        .chunk_rows(8)
        .max_steps(32)
        .prove();
    let err = match result {
        Ok(_) => panic!("poseidon precompile must be rejected when the feature is disabled"),
        Err(err) => err,
    };

    let msg = err.to_string();
    assert!(
        msg.contains("poseidon-precompile") || msg.contains("poseidon2 precompile"),
        "unexpected disabled-feature error: {msg}"
    );
}

#[cfg(feature = "poseidon-precompile")]
#[test]
fn test_rv64_poseidon_feature_gate_sets_profile_metadata() {
    let elf = poseidon_precompile_elf();
    let mut run = Rv64TraceWiring::from_elf(&elf)
        .expect("from_elf")
        .mode(FoldingMode::Optimized)
        .chunk_rows(8)
        .max_steps(32)
        .prove()
        .expect("poseidon prove");

    assert!(
        run.profile_config().poseidon_precompile,
        "maintained RV64 poseidon path must record the feature in the proof profile"
    );
    assert_eq!(
        run.proof().riscv_profile.as_ref(),
        Some(run.profile_config()),
        "proof metadata must preserve the exact validated RV64 profile config"
    );

    run.verify().expect("poseidon verify");
}

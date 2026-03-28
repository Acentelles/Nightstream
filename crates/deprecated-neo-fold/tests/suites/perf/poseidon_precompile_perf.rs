#![cfg(feature = "poseidon-precompile")]

use std::time::Instant;

use deprecated_neo_memory::riscv::lookups::{RiscvInstruction, RiscvOpcode};
use neo_fold::pi_ccs::FoldingMode;
use neo_fold::rv64_trace_shard::Rv64TraceWiring;

#[path = "../../../riscv-tests/support/rv64_elf.rs"]
mod rv64_elf;

use rv64_elf::build_text_elf64;

fn poseidon_perf_smoke_elf() -> Vec<u8> {
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
                rd: 13,
                rs1: 12,
                imm: 1,
            },
            RiscvInstruction::Halt,
        ],
    )
}

#[test]
#[ignore = "manual RV64 poseidon precompile perf smoke"]
fn poseidon_precompile_rv64_perf_smoke() {
    let elf = poseidon_perf_smoke_elf();
    let prove_start = Instant::now();
    let mut run = Rv64TraceWiring::from_elf(&elf)
        .expect("from_elf")
        .mode(FoldingMode::Optimized)
        .chunk_rows(8)
        .max_steps(32)
        .prove()
        .expect("poseidon prove");
    let prove_wall = prove_start.elapsed();

    let verify_start = Instant::now();
    run.verify().expect("poseidon verify");
    let verify_wall = verify_start.elapsed();

    println!(
        "rv64_poseidon_precompile_perf_smoke: trace_len={} folds={} prove_ms={:.1} verify_ms={:.1}",
        run.trace_len(),
        run.fold_count(),
        prove_wall.as_secs_f64() * 1000.0,
        verify_wall.as_secs_f64() * 1000.0
    );

    assert!(
        !run.proof().steps[0].poseidon_cycle_fold.is_empty(),
        "perf smoke must exercise the maintained RV64 Poseidon sidecar path"
    );
}

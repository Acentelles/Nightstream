//! Owns deterministic RV64IM perf/debug source cases reused across Rust-only benchmarks and Rust↔Lean compatibility checks.

use crate::rv64im::isa::{
    encode_add, encode_addi, encode_addiw, encode_and, encode_beq, encode_divu, encode_ecall, encode_ld, encode_mul,
    encode_remu, encode_sd, encode_slli, encode_xor, MemoryWord,
};
use crate::rv64im::kernel::{Rv64imParityCaseManifest, Rv64imParitySourceCase};
use crate::rv64im::layout::{
    RV64IM_PARITY_LOWERING_VERSION_ID, RV64IM_PARITY_PROTOCOL_VERSION_ID, RV64_REGISTER_COUNT,
};
use crate::rv64im::tables::Rv64FamilyTag;

pub const RV64IM_MIXED_OPCODE_PERF_DEFAULT_N: usize = 100;
pub const RV64IM_MIXED_OPCODE_PERF_BLOCK_LEN: usize = 13;

const START_PC: u64 = 0x1000;
const PERF_MEMORY_ADDR: u64 = 0x100;

pub fn mixed_opcode_perf_expected_x1(opcode_count: usize) -> usize {
    opcode_count.div_ceil(RV64IM_MIXED_OPCODE_PERF_BLOCK_LEN)
}

pub fn build_mixed_opcode_perf_source_case(opcode_count: usize) -> Rv64imParitySourceCase {
    let mixed_block = [
        encode_addi(1, 1, 1),
        encode_addi(2, 2, 3),
        encode_add(3, 1, 2),
        encode_slli(4, 3, 1),
        encode_xor(5, 4, 2),
        encode_mul(6, 5, 1),
        encode_divu(7, 6, 1),
        encode_remu(8, 6, 1),
        encode_beq(1, 0, 8),
        encode_sd(7, 0, PERF_MEMORY_ADDR as i16),
        encode_ld(9, 0, PERF_MEMORY_ADDR as i16),
        encode_and(11, 9, 5),
        encode_addiw(12, 11, 7),
    ];

    let mut program_words = Vec::with_capacity(opcode_count + 1);
    while program_words.len() < opcode_count {
        for word in mixed_block {
            if program_words.len() == opcode_count {
                break;
            }
            program_words.push(word);
        }
    }
    program_words.push(encode_ecall());

    let mut transcript_seed = b"rv64im-mixed-opcode-perf-snapshot-v1".to_vec();
    transcript_seed.extend_from_slice(&(opcode_count as u64).to_le_bytes());

    Rv64imParitySourceCase {
        manifest: Rv64imParityCaseManifest {
            name: "mixed_opcode_perf_snapshot".into(),
            fixture_id: "mixed_opcode_perf_snapshot_v1".into(),
            protocol_version_id: RV64IM_PARITY_PROTOCOL_VERSION_ID,
            lowering_version_id: RV64IM_PARITY_LOWERING_VERSION_ID,
            family_tags: vec![
                Rv64FamilyTag::NativeAlu,
                Rv64FamilyTag::Multiply,
                Rv64FamilyTag::UnsignedDivRem,
                Rv64FamilyTag::AlignedMemory,
                Rv64FamilyTag::ControlFlow,
            ],
        },
        start_pc: START_PC,
        program_words,
        initial_registers: [0; RV64_REGISTER_COUNT],
        initial_memory: vec![MemoryWord {
            addr: PERF_MEMORY_ADDR,
            value: 0,
        }],
        transcript_seed,
    }
}

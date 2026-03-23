//! Owns the RV64IM frontend parity slice: machine layer, staged summaries, and kernel artifacts.

pub mod builder;
pub mod ccs;
pub mod execute;
pub mod isa;
pub mod kernel;
pub mod layout;
pub mod lower;
pub mod stage1;
pub mod stage2;
pub mod stage3;
pub mod tables;

pub use builder::{build_program, Rv64ProgramBuild};
pub use isa::{
    decode_instruction, encode_add, encode_addi, encode_ecall, encode_ld, encode_sd, MemoryWord, Rv64BuildError,
    Rv64DecodedInstruction, Rv64Opcode, Rv64Program, Rv64State,
};
pub use kernel::{
    aligned_memory_focus_manifest, build_aligned_memory_focus_parity_case, build_all_parity_cases,
    build_control_flow_focus_parity_case, build_native_alu_focus_parity_case, build_vertical_slice_parity_case,
    control_flow_focus_manifest, native_alu_focus_manifest, parity_source_cases, vertical_slice_manifest,
    Rv64imKernelSummary, Rv64imParityCaseManifest, Rv64imParityDerivedCase, Rv64imParitySourceCase,
    TranscriptCursorSnapshot, TranscriptEventKind, TranscriptEventRecord, TranscriptRecord,
};

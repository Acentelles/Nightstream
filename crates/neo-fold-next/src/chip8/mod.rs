//! Owns the CHIP-8 frontend: machine layer, runtime builder, and staged kernel.

pub mod builder;
pub mod ccs;
pub(crate) mod chunk_relation;
pub mod decider;
pub mod execute;
pub(crate) mod final_relation;
pub mod isa;
pub mod kernel;
pub mod layout;
pub mod lower;
pub(crate) mod poly;
pub mod proof;
pub mod spec;
pub mod stage1;
pub mod stage2;
pub mod stage3;
pub mod tables;
pub mod trace;

pub use ccs::Chip8VmSpec;
pub use chunk_relation::{
    CHIP8_CCS_ELL_D, CHIP8_CCS_ELL_M, CHIP8_CCS_ELL_N, CHIP8_CCS_FE_ROUNDS, CHIP8_CCS_NC_ROUNDS,
    CHIP8_CCS_OUTPUT_SLOTS, CHIP8_CCS_ROUND_COEFFS, CHIP8_CCS_SUMCHECK_DEGREE_BOUND,
};
pub use isa::{Chip8Opcode, Chip8Program, Chip8State};
pub use layout::{CHIP8_MEMORY_BYTES, CHIP8_PROGRAM_START};
pub use tables::{DecodeOutput, LookupKind, OperandSelector};
pub use trace::{build_extension_trace, build_row_extension_trace, execute_step, Chip8BuildError, Chip8TraceBuilder};

//! Owns the CHIP-8 frontend: machine layer, runtime builder, and staged kernel.

pub mod builder;
pub mod ccs;
pub mod execute;
pub mod isa;
pub mod kernel;
pub mod layout;
pub mod lower;
pub(crate) mod poly;
pub mod spec;
pub mod stage1;
pub mod stage2;
pub mod stage3;
pub mod tables;
pub mod trace;

pub use ccs::Chip8VmSpec;
pub use isa::{Chip8Opcode, Chip8Program, Chip8State};
pub use layout::{CHIP8_MEMORY_BYTES, CHIP8_PROGRAM_START};
pub use tables::{DecodeOutput, LookupKind, OperandSelector};
pub use trace::{build_extension_trace, build_row_extension_trace, execute_step, Chip8BuildError, Chip8TraceBuilder};

//! Compatibility barrel for the split CHIP-8 runtime builder.

pub use super::builder::Chip8TraceBuilder;
pub use super::execute::{execute_step, Chip8BuildError};
pub use super::lower::{
    build_extension_trace, build_row_extension_trace, execute_program, Chip8ExecutionStep, Chip8RowTrace,
};

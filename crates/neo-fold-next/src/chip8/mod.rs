//! Owns the complete CHIP-8 VM: static spec, runtime trace builder, and execution.

pub mod kernel;
pub(crate) mod poly;
pub mod spec;
pub mod stage1;
pub mod stage2;
pub(crate) mod stage2_ram;
pub(crate) mod stage2_reg;
pub mod stage3;
pub mod tables;
pub mod trace;

pub use spec::*;
pub use tables::{
    decode_to_output, flatten_alu_key, flatten_eq4_key, DecodeOutput, LookupKind, OperandSelector, ADDR_RAM_BITS,
    ADDR_REG_BITS, RAM_SINK_ADDR, REG_SINK_ADDR, ROM_ADDR_BITS,
};
pub use trace::*;

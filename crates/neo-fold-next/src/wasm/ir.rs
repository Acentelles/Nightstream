//! Owns the normalized WASM execution IR consumed by the proving layers.

use super::isa::{WasmOpcode, WasmOpcodeInfo};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct StackLaneAccess {
    pub addr: u64,
    pub value: u32,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct WasmBoundaryState {
    pub pc: u64,
    pub sp: u64,
    pub halted: bool,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct WasmStepTrace {
    pub cycle: u64,
    pub pc_before: u64,
    pub pc_after: u64,
    pub opcode_code: u16,
    pub opcode: WasmOpcode,
    pub info: WasmOpcodeInfo,
    pub sp_before: u64,
    pub sp_after: u64,
    pub stack_read0: Option<StackLaneAccess>,
    pub stack_read1: Option<StackLaneAccess>,
    pub stack_read2: Option<StackLaneAccess>,
    pub stack_write1: Option<StackLaneAccess>,
    pub halted: bool,
    /// Frame base pointer for the locals address space. Absolute local address
    /// is `locals_fbp + local_index`. Always 0 in single-function scope; advances
    /// by the callee's local count on each call.
    pub locals_fbp: u64,
    /// Index of the local variable accessed (for local.get / local.set / local.tee).
    pub local_index: Option<u32>,
    /// Value of the local before this step (populated for local.get: the value pushed).
    pub local_read_value: Option<u32>,
    /// Value written into the local this step (populated for local.set / local.tee).
    pub local_write_value: Option<u32>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum WasmBuildError {
    Trace(String),
    Unsupported(String),
    StateMismatch(String),
}

impl core::fmt::Display for WasmBuildError {
    fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
        match self {
            Self::Trace(msg) | Self::Unsupported(msg) | Self::StateMismatch(msg) => f.write_str(msg),
        }
    }
}

impl std::error::Error for WasmBuildError {}

pub fn boundary_states(trace: &[WasmStepTrace]) -> Vec<(WasmBoundaryState, WasmBoundaryState)> {
    trace
        .iter()
        .map(|row| {
            (
                WasmBoundaryState {
                    pc: row.pc_before,
                    sp: row.sp_before,
                    halted: false,
                },
                WasmBoundaryState {
                    pc: row.pc_after,
                    sp: row.sp_after,
                    halted: row.halted,
                },
            )
        })
        .collect()
}

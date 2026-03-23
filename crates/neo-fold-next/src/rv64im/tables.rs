//! Owns RV64IM parity-slice opcode family tags and lowering metadata.

use serde::{Deserialize, Serialize};

use super::isa::Rv64Opcode;

pub const RV64IM_VERTICAL_SLICE_FIXTURE_ID: &str = "vertical_add_sd_ld_ecall_v1";
pub const RV64IM_NATIVE_ALU_FOCUS_FIXTURE_ID: &str = "native_add_chain_x0_ecall_v1";
pub const RV64IM_ALIGNED_MEMORY_FOCUS_FIXTURE_ID: &str = "aligned_negative_offset_roundtrip_v1";
pub const RV64IM_CONTROL_FLOW_FOCUS_FIXTURE_ID: &str = "control_flow_ecall_only_v1";

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub enum Rv64FamilyTag {
    NativeAlu,
    AlignedMemory,
    ControlFlow,
}

pub fn opcode_family(opcode: Rv64Opcode) -> Rv64FamilyTag {
    match opcode {
        Rv64Opcode::Addi | Rv64Opcode::Add => Rv64FamilyTag::NativeAlu,
        Rv64Opcode::Ld | Rv64Opcode::Sd => Rv64FamilyTag::AlignedMemory,
        Rv64Opcode::Ecall => Rv64FamilyTag::ControlFlow,
    }
}

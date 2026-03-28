//! Owns RV64IM parity-slice opcode family tags and lowering metadata.

use serde::{Deserialize, Serialize};

use super::isa::Rv64Opcode;

pub const RV64IM_VERTICAL_SLICE_FIXTURE_ID: &str = "vertical_add_sd_ld_ecall_v1";
pub const RV64IM_NATIVE_ALU_FOCUS_FIXTURE_ID: &str = "native_add_chain_x0_ecall_v1";
pub const RV64IM_ALIGNED_MEMORY_FOCUS_FIXTURE_ID: &str = "aligned_negative_offset_roundtrip_v1";
pub const RV64IM_CONTROL_FLOW_FOCUS_FIXTURE_ID: &str = "control_flow_ecall_only_v1";
pub const RV64IM_CONTROL_FLOW_JAL_FIXTURE_ID: &str = "control_flow_jal_skip_ecall_v1";
pub const RV64IM_CONTROL_FLOW_JALR_FIXTURE_ID: &str = "control_flow_jalr_skip_ecall_v1";
pub const RV64IM_CONTROL_FLOW_BEQ_FIXTURE_ID: &str = "control_flow_beq_taken_skip_ecall_v1";
pub const RV64IM_CONTROL_FLOW_BNE_FIXTURE_ID: &str = "control_flow_bne_taken_skip_ecall_v1";
pub const RV64IM_NATIVE_LOGIC_COMPARE_FIXTURE_ID: &str = "native_logic_compare_chain_ecall_v1";
pub const RV64IM_NATIVE_SHIFT_FIXTURE_ID: &str = "native_shift_chain_ecall_v1";
pub const RV64IM_NATIVE_WORD_ARITH_FIXTURE_ID: &str = "native_word_arith_chain_ecall_v1";
pub const RV64IM_NATIVE_WORD_SHIFT_FIXTURE_ID: &str = "native_word_shift_chain_ecall_v1";
pub const RV64IM_NATIVE_UPPER_FIXTURE_ID: &str = "native_sub_lui_auipc_fence_ecall_v1";
pub const RV64IM_NARROW_MEMORY_LOAD_FIXTURE_ID: &str = "narrow_memory_load_extract_extend_ecall_v1";
pub const RV64IM_NARROW_MEMORY_STORE_FIXTURE_ID: &str = "narrow_memory_store_blend_ecall_v1";
pub const RV64IM_MULTIPLY_LOW_FIXTURE_ID: &str = "multiply_low_mul_mulw_ecall_v1";
pub const RV64IM_MULTIPLY_HIGH_FIXTURE_ID: &str = "multiply_high_mulh_mulhu_mulhsu_ecall_v1";
pub const RV64IM_UNSIGNED_DIVREM_FIXTURE_ID: &str = "unsigned_divrem_chain_ecall_v1";
pub const RV64IM_SIGNED_DIVREM_FIXTURE_ID: &str = "signed_divrem_chain_ecall_v1";
pub const RV64IM_CONTROL_FLOW_BLT_FIXTURE_ID: &str = "control_flow_blt_taken_skip_ecall_v1";
pub const RV64IM_CONTROL_FLOW_BGE_FIXTURE_ID: &str = "control_flow_bge_taken_skip_ecall_v1";
pub const RV64IM_CONTROL_FLOW_BLTU_FIXTURE_ID: &str = "control_flow_bltu_taken_skip_ecall_v1";
pub const RV64IM_CONTROL_FLOW_BGEU_FIXTURE_ID: &str = "control_flow_bgeu_taken_skip_ecall_v1";

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub enum Rv64FamilyTag {
    NativeAlu,
    AlignedMemory,
    NarrowMemory,
    Multiply,
    UnsignedDivRem,
    SignedDivRem,
    ControlFlow,
}

pub fn opcode_family(opcode: Rv64Opcode) -> Rv64FamilyTag {
    match opcode {
        Rv64Opcode::Addi
        | Rv64Opcode::Add
        | Rv64Opcode::Sub
        | Rv64Opcode::Addiw
        | Rv64Opcode::Addw
        | Rv64Opcode::Subw
        | Rv64Opcode::Andi
        | Rv64Opcode::And
        | Rv64Opcode::Ori
        | Rv64Opcode::Or
        | Rv64Opcode::Xori
        | Rv64Opcode::Xor
        | Rv64Opcode::Slti
        | Rv64Opcode::Slt
        | Rv64Opcode::Sltiu
        | Rv64Opcode::Sltu
        | Rv64Opcode::Slli
        | Rv64Opcode::Sll
        | Rv64Opcode::Srli
        | Rv64Opcode::Srl
        | Rv64Opcode::Srai
        | Rv64Opcode::Sra
        | Rv64Opcode::Slliw
        | Rv64Opcode::Sllw
        | Rv64Opcode::Srliw
        | Rv64Opcode::Srlw
        | Rv64Opcode::Sraiw
        | Rv64Opcode::Sraw
        | Rv64Opcode::Lui
        | Rv64Opcode::Auipc
        | Rv64Opcode::Fence => Rv64FamilyTag::NativeAlu,
        Rv64Opcode::Lb
        | Rv64Opcode::Lbu
        | Rv64Opcode::Lh
        | Rv64Opcode::Lhu
        | Rv64Opcode::Lw
        | Rv64Opcode::Lwu
        | Rv64Opcode::Sb
        | Rv64Opcode::Sh
        | Rv64Opcode::Sw => Rv64FamilyTag::NarrowMemory,
        Rv64Opcode::Mul | Rv64Opcode::Mulh | Rv64Opcode::Mulhsu | Rv64Opcode::Mulhu | Rv64Opcode::Mulw => {
            Rv64FamilyTag::Multiply
        }
        Rv64Opcode::Divu | Rv64Opcode::Remu | Rv64Opcode::Divuw | Rv64Opcode::Remuw => Rv64FamilyTag::UnsignedDivRem,
        Rv64Opcode::Div | Rv64Opcode::Rem | Rv64Opcode::Divw | Rv64Opcode::Remw => Rv64FamilyTag::SignedDivRem,
        Rv64Opcode::Ld | Rv64Opcode::Sd => Rv64FamilyTag::AlignedMemory,
        Rv64Opcode::Jal
        | Rv64Opcode::Jalr
        | Rv64Opcode::Beq
        | Rv64Opcode::Bne
        | Rv64Opcode::Blt
        | Rv64Opcode::Bge
        | Rv64Opcode::Bltu
        | Rv64Opcode::Bgeu
        | Rv64Opcode::Ecall => Rv64FamilyTag::ControlFlow,
    }
}

//! Owns the public RV64IM expanded-row surface and ordinary-step lowering.

use serde::{Deserialize, Serialize};

use super::execute::ExecutedStep;
use super::isa::Rv64Opcode;
use super::tables::Rv64FamilyTag;
use super::trace_expand::lower_inline_rows;

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub enum Rv64TraceVirtualOpcode {
    Movsign,
    Advice,
    ChangeDivisor,
    AssertValidDiv0,
    AssertMulNoOverflow,
    AssertLte,
    AssertValidUnsignedRemainder,
    AssertSignedDivIdentity,
    AssertSignedRemainderBounds,
    Move,
    SignExtendWord,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub enum Rv64TraceOpcode {
    Real(Rv64Opcode),
    Virtual(Rv64TraceVirtualOpcode),
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64ExpandedRow {
    pub trace_index: usize,
    pub step_index: usize,
    pub sequence_index: usize,
    pub pc: u64,
    pub next_pc: u64,
    pub word: u32,
    pub opcode: Rv64Opcode,
    pub trace_opcode: Option<Rv64Opcode>,
    pub trace_virtual_opcode: Option<Rv64TraceVirtualOpcode>,
    pub family: Rv64FamilyTag,
    pub rs1: u8,
    pub rs1_value: u64,
    pub rs2: u8,
    pub rs2_value: u64,
    pub rd: u8,
    pub rd_before: u64,
    pub rd_after: u64,
    pub imm: i64,
    pub alu_result: u64,
    pub effective_addr: Option<u64>,
    pub memory_before: Option<u64>,
    pub memory_after: Option<u64>,
    pub writes_rd: bool,
    pub writes_ram: bool,
    pub halted: bool,
    pub is_first_in_sequence: bool,
    pub virtual_sequence_remaining: Option<u16>,
    pub is_effect_row: bool,
    pub is_commit_row: bool,
    pub is_real: bool,
}

fn writes_rd_for_opcode(opcode: Rv64Opcode, rd: u8) -> bool {
    matches!(
        opcode,
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
            | Rv64Opcode::Mul
            | Rv64Opcode::Mulh
            | Rv64Opcode::Mulhsu
            | Rv64Opcode::Mulhu
            | Rv64Opcode::Mulw
            | Rv64Opcode::Div
            | Rv64Opcode::Divu
            | Rv64Opcode::Rem
            | Rv64Opcode::Remu
            | Rv64Opcode::Divw
            | Rv64Opcode::Divuw
            | Rv64Opcode::Remw
            | Rv64Opcode::Remuw
            | Rv64Opcode::Lb
            | Rv64Opcode::Lbu
            | Rv64Opcode::Lh
            | Rv64Opcode::Lhu
            | Rv64Opcode::Lw
            | Rv64Opcode::Lwu
            | Rv64Opcode::Ld
            | Rv64Opcode::Jal
            | Rv64Opcode::Jalr
    ) && rd != 0
}

fn ordinary_row(step: &ExecutedStep, trace_index: usize) -> Rv64ExpandedRow {
    Rv64ExpandedRow {
        trace_index,
        step_index: step.step_index,
        sequence_index: 0,
        pc: step.prev.pc,
        next_pc: step.next.pc,
        word: step.word,
        opcode: step.decoded.opcode,
        trace_opcode: Some(step.decoded.opcode),
        trace_virtual_opcode: None,
        family: step.family,
        rs1: step.decoded.rs1,
        rs1_value: step.rs1_value,
        rs2: step.decoded.rs2,
        rs2_value: step.rs2_value,
        rd: step.decoded.rd,
        rd_before: step.rd_before,
        rd_after: step.next.read_reg(step.decoded.rd),
        imm: step.decoded.imm,
        alu_result: step.alu_result,
        effective_addr: step.effective_addr,
        memory_before: step.memory_before,
        memory_after: step.memory_after,
        writes_rd: writes_rd_for_opcode(step.decoded.opcode, step.decoded.rd),
        writes_ram: matches!(
            step.decoded.opcode,
            Rv64Opcode::Sb | Rv64Opcode::Sh | Rv64Opcode::Sw | Rv64Opcode::Sd
        ),
        halted: step.next.halted,
        is_first_in_sequence: true,
        virtual_sequence_remaining: None,
        is_effect_row: true,
        is_commit_row: true,
        is_real: true,
    }
}

pub fn lower_step(step: &ExecutedStep, trace_index_start: usize) -> Vec<Rv64ExpandedRow> {
    lower_inline_rows(step, trace_index_start).unwrap_or_else(|| vec![ordinary_row(step, trace_index_start)])
}

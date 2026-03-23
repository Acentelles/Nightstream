//! Owns lowering executed RV64IM slice steps into explicit expanded-row summaries.

use serde::{Deserialize, Serialize};

use super::execute::ExecutedStep;
use super::isa::Rv64Opcode;
use super::tables::Rv64FamilyTag;

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64ExpandedRow {
    pub step_index: usize,
    pub pc: u64,
    pub next_pc: u64,
    pub word: u32,
    pub opcode: Rv64Opcode,
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
}

pub fn lower_step(step: &ExecutedStep) -> Rv64ExpandedRow {
    Rv64ExpandedRow {
        step_index: step.step_index,
        pc: step.prev.pc,
        next_pc: step.next.pc,
        word: step.word,
        opcode: step.decoded.opcode,
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
        writes_rd: matches!(step.decoded.opcode, Rv64Opcode::Addi | Rv64Opcode::Add | Rv64Opcode::Ld)
            && step.decoded.rd != 0,
        writes_ram: matches!(step.decoded.opcode, Rv64Opcode::Sd),
        halted: step.next.halted,
    }
}

//! Owns concrete RV64IM slice execution for `ADDI`, `ADD`, `LD`, `SD`, and terminating `ECALL`.

use super::isa::{decode_instruction, Rv64BuildError, Rv64DecodedInstruction, Rv64Opcode, Rv64Program, Rv64State};
use super::tables::{opcode_family, Rv64FamilyTag};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ExecutedStep {
    pub step_index: usize,
    pub word: u32,
    pub decoded: Rv64DecodedInstruction,
    pub family: Rv64FamilyTag,
    pub prev: Rv64State,
    pub next: Rv64State,
    pub rs1_value: u64,
    pub rs2_value: u64,
    pub rd_before: u64,
    pub alu_result: u64,
    pub effective_addr: Option<u64>,
    pub memory_before: Option<u64>,
    pub memory_after: Option<u64>,
    pub terminated: bool,
}

fn wrapping_add_signed(base: u64, offset: i64) -> u64 {
    base.wrapping_add(offset as u64)
}

pub fn execute_step(
    program: &Rv64Program,
    prev: &Rv64State,
    step_index: usize,
) -> Result<ExecutedStep, Rv64BuildError> {
    if prev.halted {
        return Err(Rv64BuildError::Program(
            "cannot execute another step from a halted RV64 state".into(),
        ));
    }

    let word = program.fetch_word(prev.pc)?;
    let decoded = decode_instruction(word)?;
    let family = opcode_family(decoded.opcode);
    let rs1_value = prev.read_reg(decoded.rs1);
    let rs2_value = prev.read_reg(decoded.rs2);
    let rd_before = prev.read_reg(decoded.rd);
    let mut next = prev.clone();
    next.pc = prev.pc + 4;

    let (alu_result, effective_addr, memory_before, memory_after, terminated) = match decoded.opcode {
        Rv64Opcode::Addi => {
            let result = rs1_value.wrapping_add(decoded.imm as u64);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Add => {
            let result = rs1_value.wrapping_add(rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Ld => {
            let addr = wrapping_add_signed(rs1_value, decoded.imm);
            if addr % 8 != 0 {
                return Err(Rv64BuildError::Memory(format!(
                    "LD effective address 0x{addr:016x} is not 8-byte aligned"
                )));
            }
            let value = prev.read_memory_word(addr);
            next.write_reg(decoded.rd, value);
            (value, Some(addr), Some(value), Some(value), false)
        }
        Rv64Opcode::Sd => {
            let addr = wrapping_add_signed(rs1_value, decoded.imm);
            if addr % 8 != 0 {
                return Err(Rv64BuildError::Memory(format!(
                    "SD effective address 0x{addr:016x} is not 8-byte aligned"
                )));
            }
            let before = prev.read_memory_word(addr);
            next.write_memory_word(addr, rs2_value);
            (rs2_value, Some(addr), Some(before), Some(rs2_value), false)
        }
        Rv64Opcode::Ecall => {
            next.halted = true;
            (0, None, None, None, true)
        }
    };

    Ok(ExecutedStep {
        step_index,
        word,
        decoded,
        family,
        prev: prev.clone(),
        next,
        rs1_value,
        rs2_value,
        rd_before,
        alu_result,
        effective_addr,
        memory_before,
        memory_after,
        terminated,
    })
}

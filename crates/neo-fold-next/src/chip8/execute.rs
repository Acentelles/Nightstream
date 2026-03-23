//! Owns concrete CHIP-8 instruction execution and execution errors.

use super::isa::{decode_opcode, Chip8Opcode, Chip8Program, Chip8State};
use super::layout::{CHIP8_MEMORY_BYTES, CHIP8_PROGRAM_START};

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum Chip8BuildError {
    Program(String),
    Unsupported(String),
    StateMismatch(String),
}

impl core::fmt::Display for Chip8BuildError {
    fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
        match self {
            Self::Program(msg) | Self::Unsupported(msg) | Self::StateMismatch(msg) => f.write_str(msg),
        }
    }
}

impl std::error::Error for Chip8BuildError {}

pub fn execute_step(program: &Chip8Program, prev: &Chip8State, opcode: u16) -> Result<Chip8State, Chip8BuildError> {
    let decoded = decode_opcode(opcode).map_err(Chip8BuildError::Unsupported)?;
    let mut next = prev.clone();
    match decoded.opcode_id {
        Chip8Opcode::LdImm => {
            next.v[decoded.x as usize] = decoded.kk;
            next.pc = prev.pc + 2;
        }
        Chip8Opcode::AddImm => {
            next.v[decoded.x as usize] = prev.v[decoded.x as usize].wrapping_add(decoded.kk);
            next.pc = prev.pc + 2;
        }
        Chip8Opcode::Mov => {
            next.v[decoded.x as usize] = prev.v[decoded.y as usize];
            next.pc = prev.pc + 2;
        }
        Chip8Opcode::AddReg => {
            next.v[decoded.x as usize] = prev.v[decoded.x as usize].wrapping_add(prev.v[decoded.y as usize]);
            next.pc = prev.pc + 2;
        }
        Chip8Opcode::SkipEqImm => {
            next.pc = prev.pc + if prev.v[decoded.x as usize] == decoded.kk { 4 } else { 2 };
        }
        Chip8Opcode::Jump => {
            next.pc = decoded.nnn;
        }
        Chip8Opcode::LdI => {
            next.i = decoded.nnn;
            next.pc = prev.pc + 2;
        }
        Chip8Opcode::StoreRegs => {
            let base = prev.i as usize;
            let count = decoded.x as usize + 1;
            if base + count > CHIP8_MEMORY_BYTES {
                return Err(Chip8BuildError::Program(format!(
                    "STORE exceeds RAM bounds at I=0x{:03x}, count={count}",
                    prev.i
                )));
            }
            for idx in 0..count {
                next.memory[base + idx] = prev.v[idx];
            }
            next.pc = prev.pc + 2;
        }
        Chip8Opcode::LoadRegs => {
            let base = prev.i as usize;
            let count = decoded.x as usize + 1;
            if base + count > CHIP8_MEMORY_BYTES {
                return Err(Chip8BuildError::Program(format!(
                    "LOAD exceeds RAM bounds at I=0x{:03x}, count={count}",
                    prev.i
                )));
            }
            for idx in 0..count {
                next.v[idx] = prev.memory[base + idx];
            }
            next.pc = prev.pc + 2;
        }
    }
    if next.pc < CHIP8_PROGRAM_START && next.pc as usize + 1 >= program.bytes.len() {
        return Err(Chip8BuildError::Program(format!(
            "next pc 0x{:03x} escapes loaded program",
            next.pc
        )));
    }
    Ok(next)
}

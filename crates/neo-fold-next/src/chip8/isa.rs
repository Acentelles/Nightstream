//! Owns CHIP-8 opcode, program, state, and decode semantics.

use super::layout::{CHIP8_MEMORY_BYTES, CHIP8_PROGRAM_START};

#[derive(Clone, Copy, Debug, Eq, PartialEq, Hash)]
pub enum Chip8Opcode {
    LdImm,
    AddImm,
    Mov,
    AddReg,
    SkipEqImm,
    Jump,
    LdI,
    StoreRegs,
    LoadRegs,
}

impl Chip8Opcode {
    pub fn all() -> [Self; 9] {
        [
            Self::LdImm,
            Self::AddImm,
            Self::Mov,
            Self::AddReg,
            Self::SkipEqImm,
            Self::Jump,
            Self::LdI,
            Self::StoreRegs,
            Self::LoadRegs,
        ]
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Chip8Program {
    pub bytes: Vec<u8>,
    pub start_pc: u16,
}

impl Chip8Program {
    pub fn from_opcodes(opcodes: &[u16]) -> Self {
        let mut bytes = Vec::with_capacity(opcodes.len() * 2);
        for opcode in opcodes {
            bytes.push((opcode >> 8) as u8);
            bytes.push(*opcode as u8);
        }
        Self {
            bytes,
            start_pc: CHIP8_PROGRAM_START,
        }
    }

    pub fn opcode_at(&self, pc: u16) -> Option<u16> {
        let offset = pc.checked_sub(self.start_pc)? as usize;
        let hi = *self.bytes.get(offset)? as u16;
        let lo = *self.bytes.get(offset + 1)? as u16;
        Some((hi << 8) | lo)
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Chip8State {
    pub pc: u16,
    pub i: u16,
    pub v: [u8; 16],
    pub memory: [u8; CHIP8_MEMORY_BYTES],
}

impl Default for Chip8State {
    fn default() -> Self {
        Self {
            pc: CHIP8_PROGRAM_START,
            i: 0,
            v: [0; 16],
            memory: [0; CHIP8_MEMORY_BYTES],
        }
    }
}

impl Chip8State {
    pub fn with_program(program: &Chip8Program) -> Result<Self, String> {
        let mut state = Self::default();
        let start = program.start_pc as usize;
        let end = start
            .checked_add(program.bytes.len())
            .ok_or_else(|| "program length overflow".to_string())?;
        if end > CHIP8_MEMORY_BYTES {
            return Err("program does not fit in CHIP-8 memory".into());
        }
        state.memory[start..end].copy_from_slice(&program.bytes);
        state.pc = program.start_pc;
        Ok(state)
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct Chip8StepTrace {
    pub opcode: u16,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct Chip8DecodedStep {
    pub opcode_id: Chip8Opcode,
    pub x: u8,
    pub y: u8,
    pub kk: u8,
    pub nnn: u16,
}

pub fn decode_opcode(opcode: u16) -> Result<Chip8DecodedStep, String> {
    let top = (opcode & 0xF000) >> 12;
    let x = ((opcode & 0x0F00) >> 8) as u8;
    let y = ((opcode & 0x00F0) >> 4) as u8;
    let n = (opcode & 0x000F) as u8;
    let kk = (opcode & 0x00FF) as u8;
    let nnn = opcode & 0x0FFF;
    let opcode_id = match (top, n) {
        (0x6, _) => Chip8Opcode::LdImm,
        (0x7, _) => Chip8Opcode::AddImm,
        (0x8, 0x0) => Chip8Opcode::Mov,
        (0x8, 0x4) => Chip8Opcode::AddReg,
        (0x3, _) => Chip8Opcode::SkipEqImm,
        (0x1, _) => Chip8Opcode::Jump,
        (0xA, _) => Chip8Opcode::LdI,
        (0xF, 0x5) if kk == 0x55 => Chip8Opcode::StoreRegs,
        (0xF, 0x5) if kk == 0x65 => Chip8Opcode::LoadRegs,
        (0xF, 0x5) => return Err(format!("unsupported 0xF? opcode 0x{opcode:04x}")),
        _ => return Err(format!("unsupported CHIP-8 opcode 0x{opcode:04x}")),
    };
    Ok(Chip8DecodedStep {
        opcode_id,
        x,
        y,
        kk,
        nnn,
    })
}

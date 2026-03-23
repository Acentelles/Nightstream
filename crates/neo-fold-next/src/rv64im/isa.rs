//! Owns the compact RV64IM parity-slice machine types, instruction encoding, and decode.

use std::collections::BTreeMap;

use serde::{Deserialize, Serialize};

use super::layout::RV64_REGISTER_COUNT;

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum Rv64BuildError {
    Decode(String),
    Program(String),
    Memory(String),
}

impl core::fmt::Display for Rv64BuildError {
    fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
        match self {
            Self::Decode(msg) | Self::Program(msg) | Self::Memory(msg) => f.write_str(msg),
        }
    }
}

impl std::error::Error for Rv64BuildError {}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub enum Rv64Opcode {
    Addi,
    Add,
    Ld,
    Sd,
    Ecall,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64DecodedInstruction {
    pub opcode: Rv64Opcode,
    pub rd: u8,
    pub rs1: u8,
    pub rs2: u8,
    pub imm: i64,
    pub word: u32,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct MemoryWord {
    pub addr: u64,
    pub value: u64,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64Program {
    pub start_pc: u64,
    pub words: Vec<u32>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Rv64State {
    pub pc: u64,
    pub regs: [u64; RV64_REGISTER_COUNT],
    pub memory: BTreeMap<u64, u64>,
    pub halted: bool,
}

impl Rv64Program {
    pub fn new(start_pc: u64, words: Vec<u32>) -> Self {
        Self { start_pc, words }
    }

    pub fn fetch_word(&self, pc: u64) -> Result<u32, Rv64BuildError> {
        if pc < self.start_pc {
            return Err(Rv64BuildError::Program(format!(
                "pc 0x{pc:016x} is below program base 0x{:016x}",
                self.start_pc
            )));
        }
        if (pc - self.start_pc) % 4 != 0 {
            return Err(Rv64BuildError::Program(format!("pc 0x{pc:016x} is not 4-byte aligned")));
        }
        let idx = ((pc - self.start_pc) / 4) as usize;
        self.words
            .get(idx)
            .copied()
            .ok_or_else(|| Rv64BuildError::Program(format!("no instruction at pc 0x{pc:016x}")))
    }
}

impl Rv64State {
    pub fn new(pc: u64, regs: [u64; RV64_REGISTER_COUNT], memory_words: &[MemoryWord]) -> Self {
        let mut state = Self {
            pc,
            regs,
            memory: memory_words
                .iter()
                .map(|word| (word.addr, word.value))
                .collect(),
            halted: false,
        };
        state.regs[0] = 0;
        state
    }

    pub fn read_reg(&self, idx: u8) -> u64 {
        self.regs[idx as usize]
    }

    pub fn write_reg(&mut self, idx: u8, value: u64) {
        if idx != 0 {
            self.regs[idx as usize] = value;
        }
        self.regs[0] = 0;
    }

    pub fn read_memory_word(&self, addr: u64) -> u64 {
        self.memory.get(&addr).copied().unwrap_or(0)
    }

    pub fn write_memory_word(&mut self, addr: u64, value: u64) {
        self.memory.insert(addr, value);
    }

    pub fn memory_words(&self) -> Vec<MemoryWord> {
        self.memory
            .iter()
            .map(|(&addr, &value)| MemoryWord { addr, value })
            .collect()
    }
}

fn field(word: u32, shift: u32, width: u32) -> u32 {
    (word >> shift) & ((1u32 << width) - 1)
}

fn sign_extend(value: u32, bits: u32) -> i64 {
    let shift = 64 - bits;
    ((value as i64) << shift) >> shift
}

pub fn decode_instruction(word: u32) -> Result<Rv64DecodedInstruction, Rv64BuildError> {
    if word == 0x0000_0073 {
        return Ok(Rv64DecodedInstruction {
            opcode: Rv64Opcode::Ecall,
            rd: 0,
            rs1: 0,
            rs2: 0,
            imm: 0,
            word,
        });
    }

    let opcode = field(word, 0, 7);
    let rd = field(word, 7, 5) as u8;
    let funct3 = field(word, 12, 3);
    let rs1 = field(word, 15, 5) as u8;
    let rs2 = field(word, 20, 5) as u8;
    let funct7 = field(word, 25, 7);

    match opcode {
        0x13 if funct3 == 0 => Ok(Rv64DecodedInstruction {
            opcode: Rv64Opcode::Addi,
            rd,
            rs1,
            rs2: 0,
            imm: sign_extend(field(word, 20, 12), 12),
            word,
        }),
        0x33 if funct3 == 0 && funct7 == 0 => Ok(Rv64DecodedInstruction {
            opcode: Rv64Opcode::Add,
            rd,
            rs1,
            rs2,
            imm: 0,
            word,
        }),
        0x03 if funct3 == 3 => Ok(Rv64DecodedInstruction {
            opcode: Rv64Opcode::Ld,
            rd,
            rs1,
            rs2: 0,
            imm: sign_extend(field(word, 20, 12), 12),
            word,
        }),
        0x23 if funct3 == 3 => {
            let imm_lo = field(word, 7, 5);
            let imm_hi = field(word, 25, 7);
            let imm = (imm_hi << 5) | imm_lo;
            Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Sd,
                rd: 0,
                rs1,
                rs2,
                imm: sign_extend(imm, 12),
                word,
            })
        }
        _ => Err(Rv64BuildError::Decode(format!(
            "unsupported RV64 parity-slice instruction 0x{word:08x}"
        ))),
    }
}

pub fn encode_addi(rd: u8, rs1: u8, imm: i16) -> u32 {
    let imm12 = (imm as i32 as u32) & 0x0fff;
    (imm12 << 20) | ((rs1 as u32) << 15) | ((rd as u32) << 7) | 0x13
}

pub fn encode_add(rd: u8, rs1: u8, rs2: u8) -> u32 {
    ((rs2 as u32) << 20) | ((rs1 as u32) << 15) | ((rd as u32) << 7) | 0x33
}

pub fn encode_ld(rd: u8, rs1: u8, imm: i16) -> u32 {
    let imm12 = (imm as i32 as u32) & 0x0fff;
    (imm12 << 20) | ((rs1 as u32) << 15) | (0b011 << 12) | ((rd as u32) << 7) | 0x03
}

pub fn encode_sd(rs2: u8, rs1: u8, imm: i16) -> u32 {
    let imm12 = (imm as i32 as u32) & 0x0fff;
    let imm_lo = imm12 & 0x1f;
    let imm_hi = (imm12 >> 5) & 0x7f;
    (imm_hi << 25) | ((rs2 as u32) << 20) | ((rs1 as u32) << 15) | (0b011 << 12) | (imm_lo << 7) | 0x23
}

pub fn encode_ecall() -> u32 {
    0x0000_0073
}

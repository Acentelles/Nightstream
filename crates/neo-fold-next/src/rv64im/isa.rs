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
    Sub,
    Addiw,
    Addw,
    Subw,
    Andi,
    And,
    Ori,
    Or,
    Xori,
    Xor,
    Slti,
    Slt,
    Sltiu,
    Sltu,
    Slli,
    Sll,
    Srli,
    Srl,
    Srai,
    Sra,
    Slliw,
    Sllw,
    Srliw,
    Srlw,
    Sraiw,
    Sraw,
    Lui,
    Auipc,
    Fence,
    Mul,
    Mulh,
    Mulhsu,
    Mulhu,
    Mulw,
    Div,
    Divu,
    Rem,
    Remu,
    Divw,
    Divuw,
    Remw,
    Remuw,
    Lb,
    Lbu,
    Lh,
    Lhu,
    Lw,
    Lwu,
    Ld,
    Sb,
    Sh,
    Sw,
    Sd,
    Jal,
    Jalr,
    Beq,
    Bne,
    Blt,
    Bge,
    Bltu,
    Bgeu,
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

fn decode_i_imm(word: u32) -> i64 {
    sign_extend(field(word, 20, 12), 12)
}

fn decode_b_imm(word: u32) -> i64 {
    let imm11 = field(word, 7, 1);
    let imm4_1 = field(word, 8, 4);
    let imm10_5 = field(word, 25, 6);
    let imm12 = field(word, 31, 1);
    let imm = (imm12 << 12) | (imm11 << 11) | (imm10_5 << 5) | (imm4_1 << 1);
    sign_extend(imm, 13)
}

fn decode_u_imm(word: u32) -> i64 {
    sign_extend(word & 0xffff_f000, 32)
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
    let funct6 = field(word, 26, 6);
    let shamt6 = field(word, 20, 6) as i64;
    let shamt5 = field(word, 20, 5) as i64;

    match opcode {
        0x13 => match funct3 {
            0b000 => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Addi,
                rd,
                rs1,
                rs2: 0,
                imm: decode_i_imm(word),
                word,
            }),
            0b010 => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Slti,
                rd,
                rs1,
                rs2: 0,
                imm: decode_i_imm(word),
                word,
            }),
            0b011 => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Sltiu,
                rd,
                rs1,
                rs2: 0,
                imm: decode_i_imm(word),
                word,
            }),
            0b100 => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Xori,
                rd,
                rs1,
                rs2: 0,
                imm: decode_i_imm(word),
                word,
            }),
            0b110 => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Ori,
                rd,
                rs1,
                rs2: 0,
                imm: decode_i_imm(word),
                word,
            }),
            0b111 => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Andi,
                rd,
                rs1,
                rs2: 0,
                imm: decode_i_imm(word),
                word,
            }),
            0b001 if funct6 == 0 => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Slli,
                rd,
                rs1,
                rs2: 0,
                imm: shamt6,
                word,
            }),
            0b101 if funct6 == 0 => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Srli,
                rd,
                rs1,
                rs2: 0,
                imm: shamt6,
                word,
            }),
            0b101 if funct6 == 0b010000 => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Srai,
                rd,
                rs1,
                rs2: 0,
                imm: shamt6,
                word,
            }),
            _ => Err(Rv64BuildError::Decode(format!(
                "unsupported RV64 parity-slice instruction 0x{word:08x}"
            ))),
        },
        0x1b => match (funct3, funct7) {
            (0b000, _) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Addiw,
                rd,
                rs1,
                rs2: 0,
                imm: decode_i_imm(word),
                word,
            }),
            (0b001, 0b0000000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Slliw,
                rd,
                rs1,
                rs2: 0,
                imm: shamt5,
                word,
            }),
            (0b101, 0b0000000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Srliw,
                rd,
                rs1,
                rs2: 0,
                imm: shamt5,
                word,
            }),
            (0b101, 0b0100000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Sraiw,
                rd,
                rs1,
                rs2: 0,
                imm: shamt5,
                word,
            }),
            _ => Err(Rv64BuildError::Decode(format!(
                "unsupported RV64 parity-slice instruction 0x{word:08x}"
            ))),
        },
        0x33 => match (funct3, funct7) {
            (0b000, 0b0000000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Add,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b000, 0b0100000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Sub,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b001, 0b0000000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Sll,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b010, 0b0000000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Slt,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b011, 0b0000000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Sltu,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b100, 0b0000000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Xor,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b101, 0b0000000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Srl,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b101, 0b0100000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Sra,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b110, 0b0000000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Or,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b111, 0b0000000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::And,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b000, 0b0000001) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Mul,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b001, 0b0000001) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Mulh,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b010, 0b0000001) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Mulhsu,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b011, 0b0000001) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Mulhu,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b100, 0b0000001) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Div,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b101, 0b0000001) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Divu,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b110, 0b0000001) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Rem,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b111, 0b0000001) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Remu,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            _ => Err(Rv64BuildError::Decode(format!(
                "unsupported RV64 parity-slice instruction 0x{word:08x}"
            ))),
        },
        0x3b => match (funct3, funct7) {
            (0b000, 0b0000000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Addw,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b000, 0b0100000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Subw,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b001, 0b0000000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Sllw,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b101, 0b0000000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Srlw,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b101, 0b0100000) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Sraw,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b000, 0b0000001) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Mulw,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b100, 0b0000001) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Divw,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b101, 0b0000001) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Divuw,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b110, 0b0000001) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Remw,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            (0b111, 0b0000001) => Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Remuw,
                rd,
                rs1,
                rs2,
                imm: 0,
                word,
            }),
            _ => Err(Rv64BuildError::Decode(format!(
                "unsupported RV64 parity-slice instruction 0x{word:08x}"
            ))),
        },
        0x17 => Ok(Rv64DecodedInstruction {
            opcode: Rv64Opcode::Auipc,
            rd,
            rs1: 0,
            rs2: 0,
            imm: decode_u_imm(word),
            word,
        }),
        0x37 => Ok(Rv64DecodedInstruction {
            opcode: Rv64Opcode::Lui,
            rd,
            rs1: 0,
            rs2: 0,
            imm: decode_u_imm(word),
            word,
        }),
        0x0f if funct3 == 0 => Ok(Rv64DecodedInstruction {
            opcode: Rv64Opcode::Fence,
            rd: 0,
            rs1: 0,
            rs2: 0,
            imm: 0,
            word,
        }),
        0x03 if matches!(funct3, 0 | 1 | 2 | 3 | 4 | 5 | 6) => Ok(Rv64DecodedInstruction {
            opcode: match funct3 {
                0 => Rv64Opcode::Lb,
                1 => Rv64Opcode::Lh,
                2 => Rv64Opcode::Lw,
                3 => Rv64Opcode::Ld,
                4 => Rv64Opcode::Lbu,
                5 => Rv64Opcode::Lhu,
                6 => Rv64Opcode::Lwu,
                _ => unreachable!(),
            },
            rd,
            rs1,
            rs2: 0,
            imm: decode_i_imm(word),
            word,
        }),
        0x23 if matches!(funct3, 0 | 1 | 2 | 3) => {
            let imm_lo = field(word, 7, 5);
            let imm_hi = field(word, 25, 7);
            let imm = (imm_hi << 5) | imm_lo;
            Ok(Rv64DecodedInstruction {
                opcode: match funct3 {
                    0 => Rv64Opcode::Sb,
                    1 => Rv64Opcode::Sh,
                    2 => Rv64Opcode::Sw,
                    3 => Rv64Opcode::Sd,
                    _ => unreachable!(),
                },
                rd: 0,
                rs1,
                rs2,
                imm: sign_extend(imm, 12),
                word,
            })
        }
        0x6f => {
            let imm20 = field(word, 31, 1);
            let imm10_1 = field(word, 21, 10);
            let imm11 = field(word, 20, 1);
            let imm19_12 = field(word, 12, 8);
            let imm = (imm20 << 20) | (imm19_12 << 12) | (imm11 << 11) | (imm10_1 << 1);
            Ok(Rv64DecodedInstruction {
                opcode: Rv64Opcode::Jal,
                rd,
                rs1: 0,
                rs2: 0,
                imm: sign_extend(imm, 21),
                word,
            })
        }
        0x67 if funct3 == 0 => Ok(Rv64DecodedInstruction {
            opcode: Rv64Opcode::Jalr,
            rd,
            rs1,
            rs2: 0,
            imm: decode_i_imm(word),
            word,
        }),
        0x63 if matches!(funct3, 0 | 1 | 4 | 5 | 6 | 7) => Ok(Rv64DecodedInstruction {
            opcode: match funct3 {
                0 => Rv64Opcode::Beq,
                1 => Rv64Opcode::Bne,
                4 => Rv64Opcode::Blt,
                5 => Rv64Opcode::Bge,
                6 => Rv64Opcode::Bltu,
                7 => Rv64Opcode::Bgeu,
                _ => unreachable!(),
            },
            rd: 0,
            rs1,
            rs2,
            imm: decode_b_imm(word),
            word,
        }),
        _ => Err(Rv64BuildError::Decode(format!(
            "unsupported RV64 parity-slice instruction 0x{word:08x}"
        ))),
    }
}

fn encode_i_op(rd: u8, rs1: u8, imm: i16, funct3: u32) -> u32 {
    let imm12 = (imm as i32 as u32) & 0x0fff;
    (imm12 << 20) | ((rs1 as u32) << 15) | (funct3 << 12) | ((rd as u32) << 7) | 0x13
}

fn encode_shift_i_op(rd: u8, rs1: u8, shamt: u8, funct3: u32, funct6: u32) -> u32 {
    let shamt6 = (shamt as u32) & 0x3f;
    (funct6 << 26) | (shamt6 << 20) | ((rs1 as u32) << 15) | (funct3 << 12) | ((rd as u32) << 7) | 0x13
}

fn encode_i_word_op(rd: u8, rs1: u8, imm: i16, funct3: u32) -> u32 {
    let imm12 = (imm as i32 as u32) & 0x0fff;
    (imm12 << 20) | ((rs1 as u32) << 15) | (funct3 << 12) | ((rd as u32) << 7) | 0x1b
}

fn encode_shift_i_word_op(rd: u8, rs1: u8, shamt: u8, funct3: u32, funct7: u32) -> u32 {
    let shamt5 = (shamt as u32) & 0x1f;
    (funct7 << 25) | (shamt5 << 20) | ((rs1 as u32) << 15) | (funct3 << 12) | ((rd as u32) << 7) | 0x1b
}

fn encode_r_op(rd: u8, rs1: u8, rs2: u8, funct3: u32, funct7: u32) -> u32 {
    (funct7 << 25) | ((rs2 as u32) << 20) | ((rs1 as u32) << 15) | (funct3 << 12) | ((rd as u32) << 7) | 0x33
}

fn encode_r_word_op(rd: u8, rs1: u8, rs2: u8, funct3: u32, funct7: u32) -> u32 {
    (funct7 << 25) | ((rs2 as u32) << 20) | ((rs1 as u32) << 15) | (funct3 << 12) | ((rd as u32) << 7) | 0x3b
}

fn encode_u_op(rd: u8, imm: i32, opcode: u32) -> u32 {
    let imm32 = imm as u32;
    (imm32 & 0xffff_f000) | ((rd as u32) << 7) | opcode
}

pub fn encode_addi(rd: u8, rs1: u8, imm: i16) -> u32 {
    encode_i_op(rd, rs1, imm, 0b000)
}

pub fn encode_add(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b000, 0b0000000)
}

pub fn encode_sub(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b000, 0b0100000)
}

pub fn encode_addiw(rd: u8, rs1: u8, imm: i16) -> u32 {
    encode_i_word_op(rd, rs1, imm, 0b000)
}

pub fn encode_addw(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_word_op(rd, rs1, rs2, 0b000, 0b0000000)
}

pub fn encode_subw(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_word_op(rd, rs1, rs2, 0b000, 0b0100000)
}

pub fn encode_andi(rd: u8, rs1: u8, imm: i16) -> u32 {
    encode_i_op(rd, rs1, imm, 0b111)
}

pub fn encode_and(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b111, 0b0000000)
}

pub fn encode_ori(rd: u8, rs1: u8, imm: i16) -> u32 {
    encode_i_op(rd, rs1, imm, 0b110)
}

pub fn encode_or(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b110, 0b0000000)
}

pub fn encode_xori(rd: u8, rs1: u8, imm: i16) -> u32 {
    encode_i_op(rd, rs1, imm, 0b100)
}

pub fn encode_xor(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b100, 0b0000000)
}

pub fn encode_slti(rd: u8, rs1: u8, imm: i16) -> u32 {
    encode_i_op(rd, rs1, imm, 0b010)
}

pub fn encode_slt(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b010, 0b0000000)
}

pub fn encode_sltiu(rd: u8, rs1: u8, imm: i16) -> u32 {
    encode_i_op(rd, rs1, imm, 0b011)
}

pub fn encode_sltu(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b011, 0b0000000)
}

pub fn encode_slli(rd: u8, rs1: u8, shamt: u8) -> u32 {
    encode_shift_i_op(rd, rs1, shamt, 0b001, 0b000000)
}

pub fn encode_sll(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b001, 0b0000000)
}

pub fn encode_srli(rd: u8, rs1: u8, shamt: u8) -> u32 {
    encode_shift_i_op(rd, rs1, shamt, 0b101, 0b000000)
}

pub fn encode_srl(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b101, 0b0000000)
}

pub fn encode_srai(rd: u8, rs1: u8, shamt: u8) -> u32 {
    encode_shift_i_op(rd, rs1, shamt, 0b101, 0b010000)
}

pub fn encode_sra(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b101, 0b0100000)
}

pub fn encode_slliw(rd: u8, rs1: u8, shamt: u8) -> u32 {
    encode_shift_i_word_op(rd, rs1, shamt, 0b001, 0b0000000)
}

pub fn encode_sllw(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_word_op(rd, rs1, rs2, 0b001, 0b0000000)
}

pub fn encode_srliw(rd: u8, rs1: u8, shamt: u8) -> u32 {
    encode_shift_i_word_op(rd, rs1, shamt, 0b101, 0b0000000)
}

pub fn encode_srlw(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_word_op(rd, rs1, rs2, 0b101, 0b0000000)
}

pub fn encode_sraiw(rd: u8, rs1: u8, shamt: u8) -> u32 {
    encode_shift_i_word_op(rd, rs1, shamt, 0b101, 0b0100000)
}

pub fn encode_sraw(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_word_op(rd, rs1, rs2, 0b101, 0b0100000)
}

pub fn encode_lui(rd: u8, imm: i32) -> u32 {
    encode_u_op(rd, imm, 0x37)
}

pub fn encode_auipc(rd: u8, imm: i32) -> u32 {
    encode_u_op(rd, imm, 0x17)
}

pub fn encode_fence() -> u32 {
    0x0000_000f
}

pub fn encode_mul(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b000, 0b0000001)
}

pub fn encode_mulh(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b001, 0b0000001)
}

pub fn encode_mulhsu(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b010, 0b0000001)
}

pub fn encode_mulhu(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b011, 0b0000001)
}

pub fn encode_mulw(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_word_op(rd, rs1, rs2, 0b000, 0b0000001)
}

pub fn encode_div(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b100, 0b0000001)
}

pub fn encode_divu(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b101, 0b0000001)
}

pub fn encode_rem(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b110, 0b0000001)
}

pub fn encode_remu(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_op(rd, rs1, rs2, 0b111, 0b0000001)
}

pub fn encode_divw(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_word_op(rd, rs1, rs2, 0b100, 0b0000001)
}

pub fn encode_divuw(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_word_op(rd, rs1, rs2, 0b101, 0b0000001)
}

pub fn encode_remw(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_word_op(rd, rs1, rs2, 0b110, 0b0000001)
}

pub fn encode_remuw(rd: u8, rs1: u8, rs2: u8) -> u32 {
    encode_r_word_op(rd, rs1, rs2, 0b111, 0b0000001)
}

fn encode_load(rd: u8, rs1: u8, imm: i16, funct3: u32) -> u32 {
    let imm12 = (imm as i32 as u32) & 0x0fff;
    (imm12 << 20) | ((rs1 as u32) << 15) | (funct3 << 12) | ((rd as u32) << 7) | 0x03
}

fn encode_store(rs2: u8, rs1: u8, imm: i16, funct3: u32) -> u32 {
    let imm12 = (imm as i32 as u32) & 0x0fff;
    let imm_lo = imm12 & 0x1f;
    let imm_hi = (imm12 >> 5) & 0x7f;
    (imm_hi << 25) | ((rs2 as u32) << 20) | ((rs1 as u32) << 15) | (funct3 << 12) | (imm_lo << 7) | 0x23
}

pub fn encode_lb(rd: u8, rs1: u8, imm: i16) -> u32 {
    encode_load(rd, rs1, imm, 0b000)
}

pub fn encode_lh(rd: u8, rs1: u8, imm: i16) -> u32 {
    encode_load(rd, rs1, imm, 0b001)
}

pub fn encode_lw(rd: u8, rs1: u8, imm: i16) -> u32 {
    encode_load(rd, rs1, imm, 0b010)
}

pub fn encode_lbu(rd: u8, rs1: u8, imm: i16) -> u32 {
    encode_load(rd, rs1, imm, 0b100)
}

pub fn encode_lhu(rd: u8, rs1: u8, imm: i16) -> u32 {
    encode_load(rd, rs1, imm, 0b101)
}

pub fn encode_lwu(rd: u8, rs1: u8, imm: i16) -> u32 {
    encode_load(rd, rs1, imm, 0b110)
}

pub fn encode_ld(rd: u8, rs1: u8, imm: i16) -> u32 {
    encode_load(rd, rs1, imm, 0b011)
}

pub fn encode_sb(rs2: u8, rs1: u8, imm: i16) -> u32 {
    encode_store(rs2, rs1, imm, 0b000)
}

pub fn encode_sh(rs2: u8, rs1: u8, imm: i16) -> u32 {
    encode_store(rs2, rs1, imm, 0b001)
}

pub fn encode_sw(rs2: u8, rs1: u8, imm: i16) -> u32 {
    encode_store(rs2, rs1, imm, 0b010)
}

pub fn encode_sd(rs2: u8, rs1: u8, imm: i16) -> u32 {
    encode_store(rs2, rs1, imm, 0b011)
}

pub fn encode_jal(rd: u8, imm: i32) -> u32 {
    let imm21 = (imm as u32) & 0x1f_ffff;
    let imm20 = (imm21 >> 20) & 0x1;
    let imm10_1 = (imm21 >> 1) & 0x03ff;
    let imm11 = (imm21 >> 11) & 0x1;
    let imm19_12 = (imm21 >> 12) & 0xff;
    (imm20 << 31) | (imm10_1 << 21) | (imm11 << 20) | (imm19_12 << 12) | ((rd as u32) << 7) | 0x6f
}

pub fn encode_jalr(rd: u8, rs1: u8, imm: i16) -> u32 {
    let imm12 = (imm as i32 as u32) & 0x0fff;
    (imm12 << 20) | ((rs1 as u32) << 15) | ((rd as u32) << 7) | 0x67
}

pub fn encode_beq(rs1: u8, rs2: u8, imm: i16) -> u32 {
    encode_b_branch(rs1, rs2, imm, 0)
}

pub fn encode_bne(rs1: u8, rs2: u8, imm: i16) -> u32 {
    encode_b_branch(rs1, rs2, imm, 0b001)
}

pub fn encode_blt(rs1: u8, rs2: u8, imm: i16) -> u32 {
    encode_b_branch(rs1, rs2, imm, 0b100)
}

pub fn encode_bge(rs1: u8, rs2: u8, imm: i16) -> u32 {
    encode_b_branch(rs1, rs2, imm, 0b101)
}

pub fn encode_bltu(rs1: u8, rs2: u8, imm: i16) -> u32 {
    encode_b_branch(rs1, rs2, imm, 0b110)
}

pub fn encode_bgeu(rs1: u8, rs2: u8, imm: i16) -> u32 {
    encode_b_branch(rs1, rs2, imm, 0b111)
}

fn encode_b_branch(rs1: u8, rs2: u8, imm: i16, funct3: u32) -> u32 {
    let imm13 = (imm as i32 as u32) & 0x1fff;
    let imm11 = (imm13 >> 11) & 0x1;
    let imm4_1 = (imm13 >> 1) & 0x0f;
    let imm10_5 = (imm13 >> 5) & 0x3f;
    let imm12 = (imm13 >> 12) & 0x1;
    (imm12 << 31)
        | (imm10_5 << 25)
        | ((rs2 as u32) << 20)
        | ((rs1 as u32) << 15)
        | (funct3 << 12)
        | (imm4_1 << 8)
        | (imm11 << 7)
        | 0x63
}

pub fn encode_ecall() -> u32 {
    0x0000_0073
}

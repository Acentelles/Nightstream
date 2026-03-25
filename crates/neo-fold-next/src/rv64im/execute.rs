//! Owns concrete RV64IM slice execution for the current parity corpus opcodes.

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

fn signed_lt(lhs: u64, rhs: u64) -> bool {
    (lhs as i64) < (rhs as i64)
}

fn signed_ge(lhs: u64, rhs: u64) -> bool {
    (lhs as i64) >= (rhs as i64)
}

fn shift_imm(decoded: Rv64DecodedInstruction) -> u32 {
    (decoded.imm as u64 & 0x3f) as u32
}

fn shift_imm_word(decoded: Rv64DecodedInstruction) -> u32 {
    (decoded.imm as u64 & 0x1f) as u32
}

fn shift_reg(rs2_value: u64) -> u32 {
    (rs2_value & 0x3f) as u32
}

fn shift_reg_word(rs2_value: u64) -> u32 {
    (rs2_value & 0x1f) as u32
}

fn narrow_access_spec(opcode: Rv64Opcode) -> Option<(u32, bool, bool)> {
    match opcode {
        Rv64Opcode::Lb => Some((1, true, false)),
        Rv64Opcode::Lbu => Some((1, false, false)),
        Rv64Opcode::Lh => Some((2, true, false)),
        Rv64Opcode::Lhu => Some((2, false, false)),
        Rv64Opcode::Lw => Some((4, true, false)),
        Rv64Opcode::Lwu => Some((4, false, false)),
        Rv64Opcode::Sb => Some((1, false, true)),
        Rv64Opcode::Sh => Some((2, false, true)),
        Rv64Opcode::Sw => Some((4, false, true)),
        _ => None,
    }
}

fn narrow_backing_addr(addr: u64, size_bytes: u32, opcode: Rv64Opcode) -> Result<(u64, u32), Rv64BuildError> {
    if addr % size_bytes as u64 != 0 {
        return Err(Rv64BuildError::Memory(format!(
            "{opcode:?} effective address 0x{addr:016x} is not naturally aligned for {size_bytes} bytes"
        )));
    }
    let byte_offset = (addr & 0x7) as u32;
    if byte_offset + size_bytes > 8 {
        return Err(Rv64BuildError::Memory(format!(
            "{opcode:?} effective address 0x{addr:016x} crosses an 8-byte backing word"
        )));
    }
    Ok((addr & !0x7, byte_offset))
}

fn sign_extend_bits(raw: u64, bits: u32) -> u64 {
    (((raw << (64 - bits)) as i64) >> (64 - bits)) as u64
}

pub(crate) fn sign_extend_word32(value: u64) -> u64 {
    (value as u32 as i32 as i64) as u64
}

fn addiw_result(lhs: u64, imm: i64) -> u64 {
    sign_extend_word32(lhs.wrapping_add(imm as u64))
}

fn addw_result(lhs: u64, rhs: u64) -> u64 {
    sign_extend_word32(lhs.wrapping_add(rhs))
}

fn subw_result(lhs: u64, rhs: u64) -> u64 {
    sign_extend_word32(lhs.wrapping_sub(rhs))
}

fn slliw_result(lhs: u64, shamt: u32) -> u64 {
    sign_extend_word32(((lhs as u32) << shamt) as u64)
}

fn srliw_result(lhs: u64, shamt: u32) -> u64 {
    sign_extend_word32(((lhs as u32) >> shamt) as u64)
}

fn sraiw_result(lhs: u64, shamt: u32) -> u64 {
    sign_extend_word32(((lhs as u32 as i32) >> shamt) as u64)
}

fn sllw_result(lhs: u64, rhs: u64) -> u64 {
    slliw_result(lhs, shift_reg_word(rhs))
}

fn srlw_result(lhs: u64, rhs: u64) -> u64 {
    srliw_result(lhs, shift_reg_word(rhs))
}

fn sraw_result(lhs: u64, rhs: u64) -> u64 {
    sraiw_result(lhs, shift_reg_word(rhs))
}

pub(crate) fn mul_low(lhs: u64, rhs: u64) -> u64 {
    lhs.wrapping_mul(rhs)
}

pub(crate) fn mul_high_signed(lhs: u64, rhs: u64) -> u64 {
    let product = (lhs as i64 as i128) * (rhs as i64 as i128);
    ((product as u128) >> 64) as u64
}

pub(crate) fn mul_high_signed_unsigned(lhs: u64, rhs: u64) -> u64 {
    let product = (lhs as i64 as i128) * (rhs as i128);
    ((product as u128) >> 64) as u64
}

pub(crate) fn mul_high_unsigned(lhs: u64, rhs: u64) -> u64 {
    (((lhs as u128) * (rhs as u128)) >> 64) as u64
}

pub(crate) fn mulw_result(lhs: u64, rhs: u64) -> u64 {
    let lhs_word = lhs as u32 as i32 as i64;
    let rhs_word = rhs as u32 as i32 as i64;
    sign_extend_word32(lhs_word.wrapping_mul(rhs_word) as u64)
}

fn div_signed_result(lhs: u64, rhs: u64) -> u64 {
    let lhs_signed = lhs as i64;
    let rhs_signed = rhs as i64;
    if rhs_signed == 0 {
        u64::MAX
    } else if lhs_signed == i64::MIN && rhs_signed == -1 {
        lhs_signed as u64
    } else {
        (lhs_signed / rhs_signed) as u64
    }
}

fn div_unsigned_result(lhs: u64, rhs: u64) -> u64 {
    if rhs == 0 {
        u64::MAX
    } else {
        lhs / rhs
    }
}

fn rem_signed_result(lhs: u64, rhs: u64) -> u64 {
    let lhs_signed = lhs as i64;
    let rhs_signed = rhs as i64;
    if rhs_signed == 0 {
        lhs
    } else if lhs_signed == i64::MIN && rhs_signed == -1 {
        0
    } else {
        (lhs_signed % rhs_signed) as u64
    }
}

fn rem_unsigned_result(lhs: u64, rhs: u64) -> u64 {
    if rhs == 0 {
        lhs
    } else {
        lhs % rhs
    }
}

fn divw_signed_result(lhs: u64, rhs: u64) -> u64 {
    let lhs_word = lhs as u32 as i32;
    let rhs_word = rhs as u32 as i32;
    if rhs_word == 0 {
        u64::MAX
    } else if lhs_word == i32::MIN && rhs_word == -1 {
        sign_extend_word32(lhs_word as u32 as u64)
    } else {
        sign_extend_word32((lhs_word / rhs_word) as u32 as u64)
    }
}

fn divw_unsigned_result(lhs: u64, rhs: u64) -> u64 {
    let lhs_word = lhs as u32 as u64;
    let rhs_word = rhs as u32 as u64;
    if rhs_word == 0 {
        u64::MAX
    } else {
        sign_extend_word32(lhs_word / rhs_word)
    }
}

fn remw_signed_result(lhs: u64, rhs: u64) -> u64 {
    let lhs_word = lhs as u32 as i32;
    let rhs_word = rhs as u32 as i32;
    if rhs_word == 0 {
        sign_extend_word32(lhs_word as u32 as u64)
    } else if lhs_word == i32::MIN && rhs_word == -1 {
        0
    } else {
        sign_extend_word32((lhs_word % rhs_word) as u32 as u64)
    }
}

fn remw_unsigned_result(lhs: u64, rhs: u64) -> u64 {
    let lhs_word = lhs as u32 as u64;
    let rhs_word = rhs as u32 as u64;
    if rhs_word == 0 {
        sign_extend_word32(lhs_word)
    } else {
        sign_extend_word32(lhs_word % rhs_word)
    }
}

fn extract_narrow(word: u64, byte_offset: u32, size_bytes: u32, signed: bool) -> u64 {
    let bits = size_bytes * 8;
    let mask = if bits == 64 { u64::MAX } else { (1u64 << bits) - 1 };
    let raw = (word >> (byte_offset * 8)) & mask;
    if signed {
        sign_extend_bits(raw, bits)
    } else {
        raw
    }
}

fn blend_narrow(word: u64, byte_offset: u32, size_bytes: u32, value: u64) -> u64 {
    let bits = size_bytes * 8;
    let field_mask = if bits == 64 { u64::MAX } else { (1u64 << bits) - 1 };
    let shifted_mask = field_mask << (byte_offset * 8);
    let shifted_value = (value & field_mask) << (byte_offset * 8);
    (word & !shifted_mask) | shifted_value
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
        Rv64Opcode::Addiw => {
            let result = addiw_result(rs1_value, decoded.imm);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Add => {
            let result = rs1_value.wrapping_add(rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Addw => {
            let result = addw_result(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Sub => {
            let result = rs1_value.wrapping_sub(rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Subw => {
            let result = subw_result(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Andi => {
            let result = rs1_value & decoded.imm as u64;
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::And => {
            let result = rs1_value & rs2_value;
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Ori => {
            let result = rs1_value | decoded.imm as u64;
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Or => {
            let result = rs1_value | rs2_value;
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Xori => {
            let result = rs1_value ^ decoded.imm as u64;
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Xor => {
            let result = rs1_value ^ rs2_value;
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Slti => {
            let result = signed_lt(rs1_value, decoded.imm as u64) as u64;
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Slt => {
            let result = signed_lt(rs1_value, rs2_value) as u64;
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Sltiu => {
            let result = (rs1_value < decoded.imm as u64) as u64;
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Sltu => {
            let result = (rs1_value < rs2_value) as u64;
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Slli => {
            let result = rs1_value << shift_imm(decoded);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Slliw => {
            let result = slliw_result(rs1_value, shift_imm_word(decoded));
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Sll => {
            let result = rs1_value << shift_reg(rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Sllw => {
            let result = sllw_result(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Srli => {
            let result = rs1_value >> shift_imm(decoded);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Srliw => {
            let result = srliw_result(rs1_value, shift_imm_word(decoded));
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Srl => {
            let result = rs1_value >> shift_reg(rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Srlw => {
            let result = srlw_result(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Srai => {
            let result = ((rs1_value as i64) >> shift_imm(decoded)) as u64;
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Sraiw => {
            let result = sraiw_result(rs1_value, shift_imm_word(decoded));
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Sra => {
            let result = ((rs1_value as i64) >> shift_reg(rs2_value)) as u64;
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Sraw => {
            let result = sraw_result(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Lui => {
            let result = decoded.imm as u64;
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Auipc => {
            let result = wrapping_add_signed(prev.pc, decoded.imm);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Fence => (0, None, None, None, false),
        Rv64Opcode::Mul => {
            let result = mul_low(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Mulh => {
            let result = mul_high_signed(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Mulhsu => {
            let result = mul_high_signed_unsigned(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Mulhu => {
            let result = mul_high_unsigned(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Mulw => {
            let result = mulw_result(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Div => {
            let result = div_signed_result(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Divu => {
            let result = div_unsigned_result(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Rem => {
            let result = rem_signed_result(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Remu => {
            let result = rem_unsigned_result(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Divw => {
            let result = divw_signed_result(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Divuw => {
            let result = divw_unsigned_result(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Remw => {
            let result = remw_signed_result(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Remuw => {
            let result = remw_unsigned_result(rs1_value, rs2_value);
            next.write_reg(decoded.rd, result);
            (result, None, None, None, false)
        }
        Rv64Opcode::Lb
        | Rv64Opcode::Lbu
        | Rv64Opcode::Lh
        | Rv64Opcode::Lhu
        | Rv64Opcode::Lw
        | Rv64Opcode::Lwu
        | Rv64Opcode::Sb
        | Rv64Opcode::Sh
        | Rv64Opcode::Sw => {
            let (size_bytes, signed, writes_ram) = narrow_access_spec(decoded.opcode).expect("narrow-memory opcode");
            let addr = wrapping_add_signed(rs1_value, decoded.imm);
            let (backing_addr, byte_offset) = narrow_backing_addr(addr, size_bytes, decoded.opcode)?;
            let backing_word = prev.read_memory_word(backing_addr);
            if writes_ram {
                let blended = blend_narrow(backing_word, byte_offset, size_bytes, rs2_value);
                next.write_memory_word(backing_addr, blended);
                (blended, Some(addr), Some(backing_word), Some(blended), false)
            } else {
                let value = extract_narrow(backing_word, byte_offset, size_bytes, signed);
                next.write_reg(decoded.rd, value);
                (value, Some(addr), Some(backing_word), Some(backing_word), false)
            }
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
        Rv64Opcode::Jal => {
            let link = prev.pc + 4;
            next.pc = wrapping_add_signed(prev.pc, decoded.imm);
            next.write_reg(decoded.rd, link);
            (link, None, None, None, false)
        }
        Rv64Opcode::Jalr => {
            let link = prev.pc + 4;
            let target = wrapping_add_signed(rs1_value, decoded.imm) & !1;
            if target % 4 != 0 {
                return Err(Rv64BuildError::Program(format!(
                    "JALR target 0x{target:016x} is not 4-byte aligned"
                )));
            }
            next.pc = target;
            next.write_reg(decoded.rd, link);
            (link, None, None, None, false)
        }
        Rv64Opcode::Beq => {
            let taken = rs1_value == rs2_value;
            if taken {
                let target = wrapping_add_signed(prev.pc, decoded.imm);
                if target % 4 != 0 {
                    return Err(Rv64BuildError::Program(format!(
                        "BEQ target 0x{target:016x} is not 4-byte aligned"
                    )));
                }
                next.pc = target;
            }
            (taken as u64, None, None, None, false)
        }
        Rv64Opcode::Bne => {
            let taken = rs1_value != rs2_value;
            if taken {
                let target = wrapping_add_signed(prev.pc, decoded.imm);
                if target % 4 != 0 {
                    return Err(Rv64BuildError::Program(format!(
                        "BNE target 0x{target:016x} is not 4-byte aligned"
                    )));
                }
                next.pc = target;
            }
            (taken as u64, None, None, None, false)
        }
        Rv64Opcode::Blt => {
            let taken = signed_lt(rs1_value, rs2_value);
            if taken {
                let target = wrapping_add_signed(prev.pc, decoded.imm);
                if target % 4 != 0 {
                    return Err(Rv64BuildError::Program(format!(
                        "BLT target 0x{target:016x} is not 4-byte aligned"
                    )));
                }
                next.pc = target;
            }
            (taken as u64, None, None, None, false)
        }
        Rv64Opcode::Bge => {
            let taken = signed_ge(rs1_value, rs2_value);
            if taken {
                let target = wrapping_add_signed(prev.pc, decoded.imm);
                if target % 4 != 0 {
                    return Err(Rv64BuildError::Program(format!(
                        "BGE target 0x{target:016x} is not 4-byte aligned"
                    )));
                }
                next.pc = target;
            }
            (taken as u64, None, None, None, false)
        }
        Rv64Opcode::Bltu => {
            let taken = rs1_value < rs2_value;
            if taken {
                let target = wrapping_add_signed(prev.pc, decoded.imm);
                if target % 4 != 0 {
                    return Err(Rv64BuildError::Program(format!(
                        "BLTU target 0x{target:016x} is not 4-byte aligned"
                    )));
                }
                next.pc = target;
            }
            (taken as u64, None, None, None, false)
        }
        Rv64Opcode::Bgeu => {
            let taken = rs1_value >= rs2_value;
            if taken {
                let target = wrapping_add_signed(prev.pc, decoded.imm);
                if target % 4 != 0 {
                    return Err(Rv64BuildError::Program(format!(
                        "BGEU target 0x{target:016x} is not 4-byte aligned"
                    )));
                }
                next.pc = target;
            }
            (taken as u64, None, None, None, false)
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

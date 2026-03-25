//! Owns div/rem opcode dispatch and shared arithmetic helpers for trace expansion.

mod div;
mod divu;
mod divuw;
mod divw;
mod rem;
mod remu;
mod remuw;
mod remw;

use crate::rv64im::execute::{sign_extend_word32, ExecutedStep};
use crate::rv64im::isa::Rv64Opcode;

use super::{InlineTracePlan, WORD_MASK32};

fn divrem_unsigned_values(lhs: u64, rhs: u64, word_op: bool, remainder_result: bool) -> (u64, u64, u64, u64, u64) {
    let dividend = if word_op { lhs & WORD_MASK32 } else { lhs };
    let divisor = if word_op { rhs & WORD_MASK32 } else { rhs };
    let max_quotient = if word_op { WORD_MASK32 } else { u64::MAX };
    let quotient = if divisor == 0 { max_quotient } else { dividend / divisor };
    let product = quotient.wrapping_mul(divisor);
    let remainder = if divisor == 0 {
        dividend
    } else {
        dividend.wrapping_sub(product)
    };
    let raw_result = if remainder_result { remainder } else { quotient };
    let final_result = if word_op {
        sign_extend_word32(raw_result)
    } else {
        raw_result
    };
    (quotient, product, remainder, raw_result, final_result)
}

fn divrem_signed64_values(lhs: u64, rhs: u64, remainder_result: bool) -> (u64, u64, u64, u64) {
    let dividend = lhs as i64;
    let divisor = rhs as i64;
    let overflow = dividend == i64::MIN && divisor == -1;
    let effective_divisor = if overflow { 1 } else { divisor };
    let quotient = if divisor == 0 {
        -1
    } else if overflow {
        dividend
    } else {
        dividend / divisor
    };
    let remainder = if divisor == 0 {
        dividend
    } else if overflow {
        0
    } else {
        dividend % divisor
    };
    let final_result = if remainder_result {
        remainder as u64
    } else {
        quotient as u64
    };
    (
        effective_divisor as u64,
        quotient as u64,
        remainder as u64,
        final_result,
    )
}

fn divrem_signed32_values(lhs: u64, rhs: u64, remainder_result: bool) -> (u64, u64, u64, u64, u64) {
    let dividend = lhs as u32 as i32;
    let divisor = rhs as u32 as i32;
    let overflow = dividend == i32::MIN && divisor == -1;
    let effective_divisor = if overflow { 1 } else { divisor };
    let quotient = if divisor == 0 {
        -1
    } else if overflow {
        dividend
    } else {
        dividend / divisor
    };
    let remainder = if divisor == 0 {
        dividend
    } else if overflow {
        0
    } else {
        dividend % divisor
    };
    let raw_result = if remainder_result {
        remainder as u32 as u64
    } else {
        quotient as u32 as u64
    };
    let final_result = sign_extend_word32(raw_result);
    (
        effective_divisor as i64 as u64,
        quotient as i64 as u64,
        remainder as i64 as u64,
        raw_result,
        final_result,
    )
}

pub(super) fn divrem_sequence(step: &ExecutedStep) -> Option<InlineTracePlan> {
    let rs1 = step.decoded.rs1;
    let rs2 = step.decoded.rs2;
    let rd = step.decoded.rd;
    match step.decoded.opcode {
        Rv64Opcode::Div => Some(div::sequence(step.rs1_value, step.rs2_value, rs1, rs2, rd)),
        Rv64Opcode::Rem => Some(rem::sequence(step.rs1_value, step.rs2_value, rs1, rs2, rd)),
        Rv64Opcode::Divw => Some(divw::sequence(step.rs1_value, step.rs2_value, rs1, rs2, rd)),
        Rv64Opcode::Remw => Some(remw::sequence(step.rs1_value, step.rs2_value, rs1, rs2, rd)),
        Rv64Opcode::Divu => Some(divu::sequence(step.rs1_value, step.rs2_value, rs1, rs2, rd)),
        Rv64Opcode::Remu => Some(remu::sequence(step.rs1_value, step.rs2_value, rs1, rs2, rd)),
        Rv64Opcode::Divuw => Some(divuw::sequence(step.rs1_value, step.rs2_value, rs1, rs2, rd)),
        Rv64Opcode::Remuw => Some(remuw::sequence(step.rs1_value, step.rs2_value, rs1, rs2, rd)),
        _ => None,
    }
}

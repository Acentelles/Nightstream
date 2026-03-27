//! Owns `REMW` trace expansion.

use super::super::InlineInstrAssembler;
use super::divrem_signed32_values;

pub(super) fn sequence(rs1_value: u64, rs2_value: u64, rs1: u8, rs2: u8, rd: u8) -> super::super::InlineTracePlan {
    let (effective_divisor, quotient, _, _, final_result) = divrem_signed32_values(rs1_value, rs2_value, true);
    let mut asm = InlineInstrAssembler::new();
    let v0 = asm.scratch();
    let v1 = asm.scratch();
    let v2 = asm.scratch();
    asm.change_divisor(v0, rs1, rs2, effective_divisor);
    asm.advice(v1, rs1, rs2, quotient);
    asm.mul(v2, v1, v0);
    asm.sub(rd, rs1, v2);
    asm.sign_extend_word(rd, rd, Some(final_result));
    asm.finalize_inline()
}

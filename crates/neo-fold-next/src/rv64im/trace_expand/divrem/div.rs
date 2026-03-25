//! Owns `DIV` trace expansion.

use super::super::InlineInstrAssembler;
use super::divrem_signed64_values;

pub(super) fn sequence(rs1_value: u64, rs2_value: u64, rs1: u8, rs2: u8, rd: u8) -> super::super::InlineTracePlan {
    let (effective_divisor, quotient, remainder, final_result) = divrem_signed64_values(rs1_value, rs2_value, false);
    let mut asm = InlineInstrAssembler::new();
    let v0 = asm.scratch();
    let v1 = asm.scratch();
    let v2 = asm.scratch();
    let v3 = asm.scratch();
    asm.change_divisor(v0, rs1, rs2, effective_divisor);
    asm.advice(v1, rs1, rs2, quotient);
    asm.mul(v2, v1, v0);
    asm.sub(v3, rs1, v2);
    asm.assert_signed_div_identity(v1, rs1, v0, quotient);
    asm.assert_signed_remainder_bounds(v3, v3, v0, remainder);
    asm.move_result(rd, v1, final_result);
    asm.finalize_inline()
}

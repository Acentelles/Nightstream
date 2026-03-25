//! Owns `DIVUW` trace expansion.

use super::super::InlineInstrAssembler;
use super::divrem_unsigned_values;

pub(super) fn sequence(rs1_value: u64, rs2_value: u64, rs1: u8, rs2: u8, rd: u8) -> super::super::InlineTracePlan {
    let (quotient, product, remainder, raw_result, final_result) =
        divrem_unsigned_values(rs1_value, rs2_value, true, false);
    let mut asm = InlineInstrAssembler::new();
    let v0 = asm.scratch();
    let v1 = asm.scratch();
    let v2 = asm.scratch();
    asm.advice(v0, rs1, rs2, quotient);
    asm.assert_valid_div0(v0, rs2, v0, quotient);
    asm.assert_mul_no_overflow(v1, v0, rs2, product);
    asm.mul(v1, v0, rs2);
    asm.assert_lte(v1, v1, rs1, product);
    asm.sub(v2, rs1, v1);
    asm.assert_valid_unsigned_remainder(v2, v2, rs2, remainder);
    asm.move_result(rd, v0, raw_result);
    asm.sign_extend_word(rd, rd, Some(final_result));
    asm.finalize_inline()
}

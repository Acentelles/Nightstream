//! Owns `REMUW` trace expansion.

use super::super::InlineInstrAssembler;
use super::divrem_unsigned_values;

pub(super) fn sequence(rs1_value: u64, rs2_value: u64, rs1: u8, rs2: u8, rd: u8) -> super::super::InlineTracePlan {
    let (quotient, _, _, _, final_result) = divrem_unsigned_values(rs1_value, rs2_value, true, true);
    let mut asm = InlineInstrAssembler::new();
    let v0 = asm.scratch();
    let v1 = asm.scratch();
    asm.advice(v0, rs1, rs2, quotient);
    asm.mul(v1, v0, rs2);
    asm.sub(rd, rs1, v1);
    asm.sign_extend_word(rd, rd, Some(final_result));
    asm.finalize_inline()
}

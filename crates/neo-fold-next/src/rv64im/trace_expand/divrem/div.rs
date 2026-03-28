//! Owns `DIV` trace expansion.

use super::super::{InlineInstrAssembler, InlineTracePlan};
use super::{divrem_signed64_values, rd_aliases_inputs};

pub(super) fn sequence(rs1_value: u64, rs2_value: u64, rs1: u8, rs2: u8, rd: u8) -> super::super::InlineTracePlan {
    let (effective_divisor, quotient, _, _) = divrem_signed64_values(rs1_value, rs2_value, false);
    let mut asm = InlineInstrAssembler::new();
    let v0 = asm.scratch();
    let v2 = asm.scratch();
    let v3 = asm.scratch();
    asm.change_divisor(v0, rs1, rs2, effective_divisor);
    if rd_aliases_inputs(rd, rs1, rs2) {
        let v1 = asm.scratch();
        asm.advice(v1, rs1, rs2, quotient);
        asm.mul(v2, v1, v0);
        asm.sub(v3, rs1, v2);
        asm.move_result(rd, v1);
        return asm.finalize_inline();
    }
    asm.advice(rd, rs1, rs2, quotient);
    asm.mul(v2, rd, v0);
    asm.sub(v3, rs1, v2);
    InlineTracePlan {
        steps: asm.finish(),
        effect_index: 1,
    }
}

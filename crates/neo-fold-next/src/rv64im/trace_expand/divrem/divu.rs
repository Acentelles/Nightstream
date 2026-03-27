//! Owns `DIVU` trace expansion.

use super::super::{InlineInstrAssembler, InlineTracePlan};
use super::{divrem_unsigned_values, rd_aliases_inputs};

pub(super) fn sequence(rs1_value: u64, rs2_value: u64, rs1: u8, rs2: u8, rd: u8) -> super::super::InlineTracePlan {
    let (quotient, _, _, _, _) = divrem_unsigned_values(rs1_value, rs2_value, false, false);
    let mut asm = InlineInstrAssembler::new();
    let v1 = asm.scratch();
    let v2 = asm.scratch();
    if rd_aliases_inputs(rd, rs1, rs2) {
        let v0 = asm.scratch();
        asm.advice(v0, rs1, rs2, quotient);
        asm.mul(v1, v0, rs2);
        asm.sub(v2, rs1, v1);
        asm.move_result(rd, v0);
        return asm.finalize_inline();
    }
    asm.advice(rd, rs1, rs2, quotient);
    asm.mul(v1, rd, rs2);
    asm.sub(v2, rs1, v1);
    InlineTracePlan {
        steps: asm.finish(),
        effect_index: 0,
    }
}

//! Owns `MULH` trace expansion.

use super::super::{InlineInstrAssembler, InlineTracePlan};

pub(super) fn sequence(rs1: u8, rs2: u8, rd: u8) -> InlineTracePlan {
    let mut asm = InlineInstrAssembler::new();
    let v0 = asm.scratch();
    let v1 = asm.scratch();
    let v2 = asm.scratch();
    asm.movsign(v0, rs1);
    asm.movsign(v1, rs2);
    asm.mul(v0, v0, rs2);
    asm.mul(v1, v1, rs1);
    asm.mulhu(v2, rs1, rs2);
    asm.add(v2, v2, v0);
    asm.add(rd, v2, v1);
    asm.finalize_inline()
}

//! Owns `MULHSU` trace expansion.

use super::super::InlineInstrAssembler;

pub(super) fn sequence(rs1: u8, rs2: u8, rd: u8) -> super::super::InlineTracePlan {
    let mut asm = InlineInstrAssembler::new();
    let v0 = asm.scratch();
    let v1 = asm.scratch();
    let v2 = asm.scratch();
    let v3 = asm.scratch();
    asm.movsign(v0, rs1);
    asm.andi(v1, v0, 1);
    asm.xor(v2, rs1, v0);
    asm.add(v2, v2, v1);
    asm.mulhu(v3, v2, rs2);
    asm.mul(v2, v2, rs2);
    asm.xor(v3, v3, v0);
    asm.xor(v2, v2, v0);
    asm.add(v0, v2, v1);
    asm.sltu(v0, v0, v2);
    asm.add(rd, v3, v0);
    asm.finalize_inline()
}

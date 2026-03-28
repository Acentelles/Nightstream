//! Owns `MULW` trace expansion.

use super::super::{InlineInstrAssembler, InlineTracePlan};

pub(super) fn sequence(rs1: u8, rs2: u8, rd: u8) -> InlineTracePlan {
    let mut asm = InlineInstrAssembler::new();
    asm.mul(rd, rs1, rs2);
    asm.sign_extend_word(rd, rd, None);
    InlineTracePlan {
        steps: asm.finish(),
        effect_index: 1,
    }
}

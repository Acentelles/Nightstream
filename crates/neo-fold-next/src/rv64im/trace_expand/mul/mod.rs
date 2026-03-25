//! Owns multiply-family opcode dispatch for trace expansion.

mod mulh;
mod mulhsu;
mod mulw;

use crate::rv64im::execute::ExecutedStep;
use crate::rv64im::isa::Rv64Opcode;

use super::InlineTracePlan;

pub(super) fn multiply_sequence(step: &ExecutedStep) -> Option<InlineTracePlan> {
    let rs1 = step.decoded.rs1;
    let rs2 = step.decoded.rs2;
    let rd = step.decoded.rd;
    match step.decoded.opcode {
        Rv64Opcode::Mul => None,
        Rv64Opcode::Mulhu => None,
        Rv64Opcode::Mulw => Some(mulw::sequence(rs1, rs2, rd)),
        Rv64Opcode::Mulh => Some(mulh::sequence(rs1, rs2, rd)),
        Rv64Opcode::Mulhsu => Some(mulhsu::sequence(rs1, rs2, rd)),
        _ => None,
    }
}

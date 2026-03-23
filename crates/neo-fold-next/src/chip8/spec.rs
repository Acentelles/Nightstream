//! Compatibility barrel for the split CHIP-8 machine layer.

pub use super::ccs::{Chip8VmSpec, CommitmentId};
pub use super::isa::{decode_opcode, Chip8DecodedStep, Chip8Opcode, Chip8Program, Chip8State, Chip8StepTrace};
pub use super::layout::{
    build_pad_row, CHIP8_MEMORY_BYTES, CHIP8_PROGRAM_START, COL_BURST_LAST, COL_IS_BRANCH, COL_IS_JUMP, COL_IS_MEMOP,
    COL_I_NEXT, COL_I_REG, COL_KK, COL_LOOKUP_OUTPUT, COL_MEM_VALUE, COL_NNN_ADDR, COL_NNN_WORD, COL_ONE, COL_PC,
    COL_PC_NEXT, COL_PRESERVES_X, COL_RAM_ADDR, COL_REG_X, COL_REG_X_NEXT, COL_REG_Y, COL_WRITES_LOOKUP_TO_X,
    COL_WRITES_MEM_TO_X, COL_WRITES_NNN_TO_I, COL_X_IDX, COL_Y_IDX, PUBLIC_INPUTS, WITNESS_WIDTH,
};

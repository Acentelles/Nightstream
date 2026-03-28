//! Owns the static CHIP-8 lane layout and pad-row shape.

use neo_math::F;
use p3_field::PrimeCharacteristicRing;

pub const CHIP8_PROGRAM_START: u16 = 0x200;
pub const CHIP8_MEMORY_BYTES: usize = 4096;

pub const WITNESS_WIDTH: usize = 24;
pub const PUBLIC_INPUTS: usize = 1;

pub const COL_ONE: usize = 0;
pub const COL_PC: usize = 1;
pub const COL_PC_NEXT: usize = 2;
pub const COL_REG_X: usize = 3;
pub const COL_REG_Y: usize = 4;
pub const COL_REG_X_NEXT: usize = 5;
pub const COL_I_REG: usize = 6;
pub const COL_I_NEXT: usize = 7;
pub const COL_KK: usize = 8;
pub const COL_NNN_ADDR: usize = 9;
pub const COL_NNN_WORD: usize = 10;
pub const COL_MEM_VALUE: usize = 11;
pub const COL_LOOKUP_OUTPUT: usize = 12;
pub const COL_WRITES_LOOKUP_TO_X: usize = 13;
pub const COL_WRITES_MEM_TO_X: usize = 14;
pub const COL_PRESERVES_X: usize = 15;
pub const COL_WRITES_NNN_TO_I: usize = 16;
pub const COL_IS_JUMP: usize = 17;
pub const COL_IS_BRANCH: usize = 18;
pub const COL_IS_MEMOP: usize = 19;
pub const COL_X_IDX: usize = 20;
pub const COL_Y_IDX: usize = 21;
pub const COL_BURST_LAST: usize = 22;
pub const COL_RAM_ADDR: usize = 23;

pub(crate) const BOOLEAN_COLS: [usize; 8] = [
    COL_WRITES_LOOKUP_TO_X,
    COL_WRITES_MEM_TO_X,
    COL_PRESERVES_X,
    COL_WRITES_NNN_TO_I,
    COL_IS_JUMP,
    COL_IS_BRANCH,
    COL_IS_MEMOP,
    COL_BURST_LAST,
];

pub fn build_pad_row(pad_pc_word: u16) -> [F; WITNESS_WIDTH] {
    let mut row = [F::ZERO; WITNESS_WIDTH];
    row[COL_ONE] = F::ONE;
    row[COL_PC] = F::from_u64(pad_pc_word as u64);
    row[COL_PC_NEXT] = F::from_u64(pad_pc_word as u64);
    row[COL_NNN_ADDR] = F::from_u64(2 * pad_pc_word as u64);
    row[COL_NNN_WORD] = F::from_u64(pad_pc_word as u64);
    row[COL_PRESERVES_X] = F::ONE;
    row[COL_IS_JUMP] = F::ONE;
    row
}

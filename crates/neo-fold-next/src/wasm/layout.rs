//! Owns the static WASM row layout.

use neo_math::F;
use p3_field::PrimeCharacteristicRing;

use super::isa::WasmOpcode;

pub const PUBLIC_INPUTS: usize = 1;
pub const WITNESS_WIDTH: usize = 38;

pub const COL_ONE: usize = 0;
pub const COL_OPCODE_CODE: usize = 1;
pub const COL_PC_BEFORE: usize = 2;
pub const COL_PC_AFTER: usize = 3;
pub const COL_SP_BEFORE: usize = 4;
pub const COL_SP_AFTER: usize = 5;
pub const COL_HALTED: usize = 6;
pub const COL_STACK_READS: usize = 7;
pub const COL_STACK_WRITES: usize = 8;
pub const COL_SHOUT_ENABLED: usize = 9;

pub const COL_SEL_I32_CONST: usize = 10;
pub const COL_SEL_I32_ADD: usize = 11;
pub const COL_SEL_I32_SUB: usize = 12;
pub const COL_SEL_I32_POPCNT: usize = 13;
pub const COL_SEL_I32_EQZ: usize = 14;
pub const COL_SEL_I32_EQ: usize = 15;
pub const COL_SEL_I32_NE: usize = 16;
pub const COL_SEL_I32_LTS: usize = 17;
pub const COL_SEL_I32_LTU: usize = 18;
pub const COL_SEL_I32_AND: usize = 19;
pub const COL_SEL_I32_OR: usize = 20;
pub const COL_SEL_I32_XOR: usize = 21;
pub const COL_SEL_I32_MUL: usize = 22;
pub const COL_SEL_SELECT: usize = 23;
pub const COL_SEL_BR_IF_EQZ: usize = 24;
pub const COL_SEL_RETURN: usize = 25;

pub const COL_READ0_ADDR: usize = 26;
pub const COL_READ0_VALUE: usize = 27;
pub const COL_READ1_ADDR: usize = 28;
pub const COL_READ1_VALUE: usize = 29;
pub const COL_READ2_ADDR: usize = 30;
pub const COL_READ2_VALUE: usize = 31;
pub const COL_WRITE1_ADDR: usize = 32;
pub const COL_WRITE1_VALUE: usize = 33;
pub const COL_SHOUT_ID: usize = 34;
pub const COL_SHOUT_VALUE: usize = 35;
pub const COL_AUX0: usize = 36;
pub const COL_AUX1: usize = 37;

pub const BOOLEAN_COLS: [usize; 18] = [
    COL_HALTED,
    COL_SHOUT_ENABLED,
    COL_SEL_I32_CONST,
    COL_SEL_I32_ADD,
    COL_SEL_I32_SUB,
    COL_SEL_I32_POPCNT,
    COL_SEL_I32_EQZ,
    COL_SEL_I32_EQ,
    COL_SEL_I32_NE,
    COL_SEL_I32_LTS,
    COL_SEL_I32_LTU,
    COL_SEL_I32_AND,
    COL_SEL_I32_OR,
    COL_SEL_I32_XOR,
    COL_SEL_I32_MUL,
    COL_SEL_SELECT,
    COL_SEL_BR_IF_EQZ,
    COL_SEL_RETURN,
];

pub const SELECTOR_COLS: [usize; 16] = [
    COL_SEL_I32_CONST,
    COL_SEL_I32_ADD,
    COL_SEL_I32_SUB,
    COL_SEL_I32_POPCNT,
    COL_SEL_I32_EQZ,
    COL_SEL_I32_EQ,
    COL_SEL_I32_NE,
    COL_SEL_I32_LTS,
    COL_SEL_I32_LTU,
    COL_SEL_I32_AND,
    COL_SEL_I32_OR,
    COL_SEL_I32_XOR,
    COL_SEL_I32_MUL,
    COL_SEL_SELECT,
    COL_SEL_BR_IF_EQZ,
    COL_SEL_RETURN,
];

pub fn selector_col(op: WasmOpcode) -> Option<usize> {
    match op {
        WasmOpcode::I32Const => Some(COL_SEL_I32_CONST),
        WasmOpcode::I32Add => Some(COL_SEL_I32_ADD),
        WasmOpcode::I32Sub => Some(COL_SEL_I32_SUB),
        WasmOpcode::I32Popcnt => Some(COL_SEL_I32_POPCNT),
        WasmOpcode::I32Eqz => Some(COL_SEL_I32_EQZ),
        WasmOpcode::I32Eq => Some(COL_SEL_I32_EQ),
        WasmOpcode::I32Ne => Some(COL_SEL_I32_NE),
        WasmOpcode::I32LtS => Some(COL_SEL_I32_LTS),
        WasmOpcode::I32LtU => Some(COL_SEL_I32_LTU),
        WasmOpcode::I32And => Some(COL_SEL_I32_AND),
        WasmOpcode::I32Or => Some(COL_SEL_I32_OR),
        WasmOpcode::I32Xor => Some(COL_SEL_I32_XOR),
        WasmOpcode::I32Mul => Some(COL_SEL_I32_MUL),
        WasmOpcode::Select => Some(COL_SEL_SELECT),
        WasmOpcode::BrIfEqz => Some(COL_SEL_BR_IF_EQZ),
        WasmOpcode::Return => Some(COL_SEL_RETURN),
        WasmOpcode::Trap | WasmOpcode::Unsupported => None,
    }
}

pub fn build_pad_row() -> [F; WITNESS_WIDTH] {
    let mut row = [F::ZERO; WITNESS_WIDTH];
    row[COL_ONE] = F::ONE;
    row[COL_HALTED] = F::ONE;
    row[COL_SEL_RETURN] = F::ONE;
    row
}

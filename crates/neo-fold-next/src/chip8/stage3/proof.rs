//! Owns the Stage 3 proof surface and lane-opening contract.

use neo_math::K;

use crate::chip8::spec::{COL_BURST_LAST, COL_IS_MEMOP, COL_PC, COL_PC_NEXT, COL_X_IDX};

#[derive(Clone, Debug)]
pub struct LaneShiftProof {
    pub source_point: Vec<K>,
    pub claimed_shift_values: [K; 3],
    pub reduction_rounds: Vec<Vec<K>>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct RowBindingClaim {
    pub row_index: usize,
    pub row_bits: Vec<bool>,
    pub opened_values: Vec<K>,
}

#[derive(Clone, Debug)]
pub struct Stage3Proof {
    pub shift_proof: LaneShiftProof,
    pub shift_opening_values: [K; 5],
    pub continuity_check_value: K,
    pub start_boundary_values: [K; 2],
    pub final_boundary_values: [K; 2],
    pub row_bindings: Vec<RowBindingClaim>,
}

pub const STAGE3_SHIFT_OPEN_COLS: [usize; 5] = [COL_PC, COL_PC_NEXT, COL_X_IDX, COL_IS_MEMOP, COL_BURST_LAST];
pub const STAGE3_START_BOUNDARY_COLS: [usize; 2] = [COL_IS_MEMOP, COL_X_IDX];
pub const STAGE3_FINAL_BOUNDARY_COLS: [usize; 2] = [COL_IS_MEMOP, COL_BURST_LAST];

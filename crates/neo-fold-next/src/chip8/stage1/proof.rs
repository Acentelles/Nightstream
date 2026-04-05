//! Owns the Stage 1 proof surface and lane-opening contract.

use neo_math::K;

use crate::chip8::spec::{
    COL_BURST_LAST, COL_IS_BRANCH, COL_IS_JUMP, COL_IS_MEMOP, COL_KK, COL_LOOKUP_OUTPUT, COL_NNN_ADDR, COL_NNN_WORD,
    COL_PC, COL_PRESERVES_X, COL_REG_X, COL_REG_Y, COL_WRITES_LOOKUP_TO_X, COL_WRITES_MEM_TO_X, COL_WRITES_NNN_TO_I,
    COL_X_IDX, COL_Y_IDX,
};

#[derive(Clone, Debug)]
pub struct ShoutChannelProof {
    pub addr_point: Vec<K>,
    pub sumcheck_rounds: Vec<Vec<K>>,
    pub addr_correctness_rounds: Vec<Vec<K>>,
    pub address_opening_value: K,
    pub read_values_at_cycle: Vec<K>,
    pub table_opening_values: Vec<K>,
}

#[derive(Clone, Debug)]
pub struct Stage1ShoutProof {
    pub cycle_point: Vec<K>,
    pub fetch_proof: ShoutChannelProof,
    pub decode_proof: ShoutChannelProof,
    pub alu_proof: ShoutChannelProof,
    pub eq4_proof: ShoutChannelProof,
    pub decode_handoff_values: Vec<K>,
    pub lane_values_at_lookup: Vec<K>,
}

#[derive(Clone, Debug)]
pub struct ShoutChannelExecutionProof {
    pub sumcheck_rounds: Vec<Vec<K>>,
    pub addr_correctness_rounds: Vec<Vec<K>>,
}

pub const STAGE1_LANE_OPEN_COLS: [usize; 17] = [
    COL_PC,
    COL_KK,
    COL_NNN_ADDR,
    COL_NNN_WORD,
    COL_REG_X,
    COL_REG_Y,
    COL_LOOKUP_OUTPUT,
    COL_WRITES_LOOKUP_TO_X,
    COL_WRITES_MEM_TO_X,
    COL_PRESERVES_X,
    COL_WRITES_NNN_TO_I,
    COL_IS_JUMP,
    COL_IS_BRANCH,
    COL_IS_MEMOP,
    COL_X_IDX,
    COL_Y_IDX,
    COL_BURST_LAST,
];

pub const DECODE_HANDOFF_POLY_IDS: [usize; 3] = [0, 1, 2];

//! Owns the Stage 2 proof surface and lane-opening contract.

use neo_math::K;

use crate::chip8::spec::{
    COL_IS_MEMOP, COL_I_NEXT, COL_I_REG, COL_MEM_VALUE, COL_PRESERVES_X, COL_RAM_ADDR, COL_REG_X, COL_REG_X_NEXT,
    COL_REG_Y, COL_WRITES_LOOKUP_TO_X, COL_WRITES_MEM_TO_X, COL_WRITES_NNN_TO_I, COL_X_IDX, COL_Y_IDX,
};

#[derive(Clone, Debug)]
pub struct AddressCorrectnessProof {
    pub booleanity_rounds: Vec<Vec<K>>,
    pub hamming_weight_rounds: Vec<Vec<K>>,
    pub decode_consistency_rounds: Vec<Vec<K>>,
    pub raw_address_rounds: Vec<Vec<K>>,
}

#[derive(Clone, Debug)]
pub struct Stage2LinkClaims {
    pub rv_x: K,
    pub rv_y: K,
    pub rv_i: K,
    pub wv_reg: K,
    pub rv_ram: K,
    pub wv_ram: K,
}

#[derive(Clone, Debug)]
pub struct CycleProductProof {
    pub claim: K,
    pub rounds: Vec<Vec<K>>,
}

#[derive(Clone, Debug)]
pub struct Stage2TwistProof {
    pub cycle_point: Vec<K>,
    pub reg_addr_point: Vec<K>,
    pub reg_val_at_point: K,
    pub ram_addr_point: Vec<K>,
    pub ram_val_at_point: K,
    pub gamma_reg: K,
    pub reg_rw_batched_rounds: Vec<Vec<K>>,
    pub reg_val_from_inc_claim: K,
    pub reg_val_from_inc_rounds: Vec<Vec<K>>,
    pub reg_addr_correctness: Vec<AddressCorrectnessProof>,
    pub gamma_ram: K,
    pub ram_rw_batched_rounds: Vec<Vec<K>>,
    pub ram_val_from_inc_claim: K,
    pub ram_val_from_inc_rounds: Vec<Vec<K>>,
    pub ram_raf_read_claim: K,
    pub ram_raf_read_rounds: Vec<Vec<K>>,
    pub ram_raf_write_claim: K,
    pub ram_raf_write_rounds: Vec<Vec<K>>,
    pub reg_ra_y_target_proof: CycleProductProof,
    pub reg_wa_addr_target_proof: CycleProductProof,
    pub reg_write_x_target_proof: CycleProductProof,
    pub reg_write_i_target_proof: CycleProductProof,
    pub ram_read_target_proof: CycleProductProof,
    pub ram_write_target_proof: CycleProductProof,
    pub ram_write_matches_x_zero_proof: CycleProductProof,
    pub ram_idle_mem_zero_proof: CycleProductProof,
    pub ram_addr_correctness: Vec<AddressCorrectnessProof>,
    pub link_claims: Stage2LinkClaims,
    pub gamma_twist_link: K,
    pub linkage_batch_value: K,
    pub lane_values_at_twist: Vec<K>,
    pub handoff_values_at_twist: Vec<K>,
}

#[derive(Clone, Debug)]
pub struct Stage2RegisterExecutionProof {
    pub reg_rw_batched_rounds: Vec<Vec<K>>,
    pub reg_val_from_inc_rounds: Vec<Vec<K>>,
    pub reg_addr_correctness: Vec<AddressCorrectnessProof>,
    pub reg_ra_y_target_rounds: Vec<Vec<K>>,
    pub reg_wa_addr_target_rounds: Vec<Vec<K>>,
    pub reg_write_x_target_rounds: Vec<Vec<K>>,
    pub reg_write_i_target_rounds: Vec<Vec<K>>,
}

#[derive(Clone, Debug)]
pub struct Stage2RamExecutionProof {
    pub ram_rw_batched_rounds: Vec<Vec<K>>,
    pub ram_val_from_inc_rounds: Vec<Vec<K>>,
    pub ram_raf_read_rounds: Vec<Vec<K>>,
    pub ram_raf_write_rounds: Vec<Vec<K>>,
    pub ram_read_target_rounds: Vec<Vec<K>>,
    pub ram_write_target_rounds: Vec<Vec<K>>,
    pub ram_write_matches_x_zero_rounds: Vec<Vec<K>>,
    pub ram_idle_mem_zero_rounds: Vec<Vec<K>>,
    pub ram_addr_correctness: Vec<AddressCorrectnessProof>,
}

pub const STAGE2_LANE_OPEN_COLS: [usize; 14] = [
    COL_REG_X,
    COL_REG_Y,
    COL_REG_X_NEXT,
    COL_I_REG,
    COL_I_NEXT,
    COL_MEM_VALUE,
    COL_WRITES_LOOKUP_TO_X,
    COL_WRITES_MEM_TO_X,
    COL_PRESERVES_X,
    COL_WRITES_NNN_TO_I,
    COL_IS_MEMOP,
    COL_X_IDX,
    COL_Y_IDX,
    COL_RAM_ADDR,
];

pub const REG_TWIST_POLY_IDS: [usize; 5] = [0, 1, 2, 3, 4];
pub const RAM_TWIST_POLY_IDS: [usize; 3] = [0, 1, 2];

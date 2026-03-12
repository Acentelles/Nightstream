pub(crate) use crate::memory_sidecar::claim_plan::RouteATimeClaimPlan;
pub(crate) use crate::memory_sidecar::sumcheck_ds::{
    run_batched_sumcheck_prover_ds, verify_batched_sumcheck_rounds_ds,
};
pub(crate) use crate::memory_sidecar::transcript::{
    bind_batched_claim_sums, bind_twist_val_eval_claim_sums, digest_fields,
};
pub(crate) use crate::memory_sidecar::utils::{bitness_weights, RoundOraclePrefix};
pub(crate) use crate::shard_proof_types::{
    MemOrLutProof, MemSidecarProof, ShoutAddrPreGroupProof, ShoutAddrPreProof, ShoutProofK, TwistProofK,
};
pub(crate) use crate::PiCcsError;
pub(crate) use neo_ajtai::Commitment as Cmt;
pub(crate) use neo_ccs::{CcsStructure, CeClaim};
pub(crate) use neo_math::{KExtensions, F, K};
pub(crate) use neo_memory::bit_ops::{eq_bit_affine, eq_bits_prod};
pub(crate) use neo_memory::cpu::{
    build_bus_layout_for_instances_with_shout_shapes_and_twist_lanes, BusLayout, ShoutInstanceShape,
};
pub(crate) use neo_memory::identity::shout_oracle::IdentityAddressLookupOracleSparse;
pub(crate) use neo_memory::mle::{eq_points, lt_eval};
pub(crate) use neo_memory::riscv::shout_oracle::RiscvAddressLookupOracleSparse;
pub(crate) use neo_memory::riscv::trace::{
    riscv_decode_lookup_backed_row_from_instr_word, riscv_decode_lookup_table_id_for_col,
    riscv_decode_lookup_transport_cols, riscv_decode_lookup_val_slot_for_col, riscv_is_decode_lookup_table_id,
    riscv_trace_is_width_lookup_table_id, riscv_trace_shared_width_lookup_backed_cols,
    riscv_trace_shared_width_lookup_table_id_for_col, riscv_trace_shared_width_lookup_val_slot_for_col,
    riscv_trace_uses_shared_width_lookup_table_id, Rv32DecodeSidecarLayout, Rv32TraceLayout, Rv32WidthSidecarLayout,
};
pub(crate) use neo_memory::sparse_time::SparseIdxVec;
pub(crate) use neo_memory::ts_common as ts;
pub(crate) use neo_memory::twist_oracle::{
    AddressLookupOracle, IndexAdapterOracleSparseTime, LazyWeightedBitnessOracleSparseTime,
    Rv32NonVirtualArchDomainOracleSparseTime, Rv32PackedAddOracleSparseTime, Rv32PackedAndOracleSparseTime,
    Rv32PackedAndnOracleSparseTime, Rv32PackedBitwiseAdapterOracleSparseTime, Rv32PackedDivOracleSparseTime,
    Rv32PackedDivRemAdapterOracleSparseTime, Rv32PackedDivRemuAdapterOracleSparseTime, Rv32PackedDivuOracleSparseTime,
    Rv32PackedEqAdapterOracleSparseTime, Rv32PackedEqOracleSparseTime, Rv32PackedMulHiOracleSparseTime,
    Rv32PackedMulOracleSparseTime, Rv32PackedMulhAdapterOracleSparseTime, Rv32PackedMulhsuAdapterOracleSparseTime,
    Rv32PackedMulhuOracleSparseTime, Rv32PackedNeqAdapterOracleSparseTime, Rv32PackedNeqOracleSparseTime,
    Rv32PackedOrOracleSparseTime, Rv32PackedRemOracleSparseTime, Rv32PackedRemuOracleSparseTime,
    Rv32PackedSllOracleSparseTime, Rv32PackedSltOracleSparseTime, Rv32PackedSltuOracleSparseTime,
    Rv32PackedSraAdapterOracleSparseTime, Rv32PackedSraOracleSparseTime, Rv32PackedSrlAdapterOracleSparseTime,
    Rv32PackedSrlOracleSparseTime, Rv32PackedSubOracleSparseTime, Rv32PackedXorOracleSparseTime,
    Rv32VirtualWriteDomainOracleSparseTime, ShoutValueOracleSparse, TwistLaneSparseCols,
    TwistReadCheckAddrOracleSparseTimeMultiLane, TwistReadCheckOracleSparseTime, TwistTotalIncOracleSparseTime,
    TwistValEvalOracleSparseTime, TwistWriteCheckAddrOracleSparseTimeMultiLane, TwistWriteCheckOracleSparseTime,
    U32DecompOracleSparseTime, ZeroOracleSparseTime,
};
pub(crate) use neo_memory::witness::{LutInstance, LutTableSpec, MemInstance, StepInstanceBundle, StepWitnessBundle};
pub(crate) use neo_memory::{eval_init_at_r_addr, twist, BatchedAddrProof, MemInit};
pub(crate) use neo_params::NeoParams;
pub(crate) use neo_reductions::sumcheck::{BatchedClaim, RoundOracle};
pub(crate) use neo_transcript::{Poseidon2Transcript, Transcript};
pub(crate) use p3_field::Field;
pub(crate) use p3_field::PrimeCharacteristicRing;
pub(crate) use p3_field::PrimeField64;
pub(crate) use std::collections::{BTreeMap, BTreeSet};

mod addr_pre_proofs;
mod event_table_context;
mod opening_lookup;
mod sparse_oracles_and_twist_pre;
mod sparse_time_oracles;
mod step_memory_binding;

pub(crate) use crate::memory_sidecar::route_a::verify_route_a_memory_step;
pub use addr_pre_proofs::{verify_shout_addr_pre_time, verify_twist_addr_pre_time};
pub use sparse_time_oracles::{TwistTimeLaneOpenings, TwistTimeLaneOpeningsLane};
pub use step_memory_binding::absorb_step_memory;

pub(crate) use crate::memory_sidecar::precompiles::poseidon2::*;
pub(crate) use crate::memory_sidecar::riscv::*;
pub(crate) use crate::memory_sidecar::route_a::*;
pub(crate) use addr_pre_proofs::*;
pub(crate) use event_table_context::*;
pub(crate) use opening_lookup::*;
pub(crate) use sparse_oracles_and_twist_pre::*;
pub(crate) use sparse_time_oracles::*;
pub(crate) use step_memory_binding::*;

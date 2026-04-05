//! Stage 2: Twist memory checking.
//!
//! Owns the stage-local module boundary. Shared math lives in `common.rs`, the
//! register and RAM subsystems live in `reg.rs` and `ram.rs`, and the public
//! prove/verify entrypoints live in `prove.rs` and `verify.rs`.

use neo_math::{F, K};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

mod common;
mod proof;
mod prove;
mod ram;
mod reg;
mod transcript;
mod verify;

use crate::chip8::kernel::{KernelStepAux, SimpleKernelError};

pub(crate) use self::common::{handoff_values_at_cycle, lane_values_at_cycle};
pub use self::proof::{
    AddressCorrectnessProof, CycleProductProof, Stage2LinkClaims, Stage2RamExecutionProof,
    Stage2RegisterExecutionProof, Stage2TwistProof, RAM_TWIST_POLY_IDS, REG_TWIST_POLY_IDS, STAGE2_LANE_OPEN_COLS,
};
pub use self::prove::prove_stage2;
pub(crate) use self::ram::reconstruct_ram_value_at_point;
pub(crate) use self::ram::{reconstruct_ram_raf_claims, reconstruct_ram_target_claims};
pub(crate) use self::reg::reconstruct_reg_value_at_point;
pub(crate) use self::transcript::replay_stage2_execution_transcript;
pub use self::verify::verify_stage2;
pub(crate) use self::verify::verify_stage2_execution;

#[derive(Clone, Debug)]
pub(crate) struct Stage2DerivedExecutionSurface {
    pub cycle_point: Vec<K>,
    pub reg_addr_point: Vec<K>,
    pub reg_val_at_point: K,
    pub ram_addr_point: Vec<K>,
    pub ram_val_at_point: K,
    pub gamma_reg: K,
    pub reg_val_from_inc_claim: K,
    pub gamma_ram: K,
    pub ram_val_from_inc_claim: K,
    pub ram_raf_read_claim: K,
    pub ram_raf_write_claim: K,
    pub reg_ra_y_target_claim: K,
    pub reg_wa_addr_target_claim: K,
    pub reg_write_x_target_claim: K,
    pub reg_write_i_target_claim: K,
    pub ram_read_target_claim: K,
    pub ram_write_target_claim: K,
    pub link_claims: Stage2LinkClaims,
    pub gamma_twist_link: K,
    pub linkage_batch_value: K,
    pub lane_values_at_twist: Vec<K>,
    pub handoff_values_at_twist: Vec<K>,
}

pub(crate) fn stage2_execution_surface_from_proof(proof: &Stage2TwistProof) -> Stage2DerivedExecutionSurface {
    Stage2DerivedExecutionSurface {
        cycle_point: proof.cycle_point.clone(),
        reg_addr_point: proof.reg_addr_point.clone(),
        reg_val_at_point: proof.reg_val_at_point,
        ram_addr_point: proof.ram_addr_point.clone(),
        ram_val_at_point: proof.ram_val_at_point,
        gamma_reg: proof.gamma_reg,
        reg_val_from_inc_claim: proof.reg_val_from_inc_claim,
        gamma_ram: proof.gamma_ram,
        ram_val_from_inc_claim: proof.ram_val_from_inc_claim,
        ram_raf_read_claim: proof.ram_raf_read_claim,
        ram_raf_write_claim: proof.ram_raf_write_claim,
        reg_ra_y_target_claim: proof.reg_ra_y_target_proof.claim,
        reg_wa_addr_target_claim: proof.reg_wa_addr_target_proof.claim,
        reg_write_x_target_claim: proof.reg_write_x_target_proof.claim,
        reg_write_i_target_claim: proof.reg_write_i_target_proof.claim,
        ram_read_target_claim: proof.ram_read_target_proof.claim,
        ram_write_target_claim: proof.ram_write_target_proof.claim,
        link_claims: proof.link_claims.clone(),
        gamma_twist_link: proof.gamma_twist_link,
        linkage_batch_value: proof.linkage_batch_value,
        lane_values_at_twist: proof.lane_values_at_twist.clone(),
        handoff_values_at_twist: proof.handoff_values_at_twist.clone(),
    }
}

pub(crate) fn compute_linkage_batch_value(
    link_claims: &Stage2LinkClaims,
    gamma_twist_link: K,
    reg_write_x_target_proof: &CycleProductProof,
    reg_write_i_target_proof: &CycleProductProof,
    ram_read_target_proof: &CycleProductProof,
    ram_write_target_proof: &CycleProductProof,
    ram_write_matches_x_zero_proof: &CycleProductProof,
    ram_idle_mem_zero_proof: &CycleProductProof,
    lane_values_at_twist: &[K],
) -> K {
    debug_assert_eq!(ram_write_matches_x_zero_proof.claim, K::ZERO);
    debug_assert_eq!(ram_idle_mem_zero_proof.claim, K::ZERO);
    compute_linkage_batch_value_from_claims(
        link_claims,
        gamma_twist_link,
        reg_write_x_target_proof.claim,
        reg_write_i_target_proof.claim,
        ram_read_target_proof.claim,
        ram_write_target_proof.claim,
        lane_values_at_twist,
    )
}

pub(crate) fn compute_linkage_batch_value_from_claims(
    link_claims: &Stage2LinkClaims,
    gamma_twist_link: K,
    reg_write_x_target_claim: K,
    reg_write_i_target_claim: K,
    ram_read_target_claim: K,
    ram_write_target_claim: K,
    lane_values_at_twist: &[K],
) -> K {
    let linkage_terms = [
        link_claims.rv_x - lane_values_at_twist[0],
        link_claims.rv_y - lane_values_at_twist[1],
        link_claims.rv_i - lane_values_at_twist[3],
        link_claims.wv_reg - (reg_write_x_target_claim + reg_write_i_target_claim),
        link_claims.rv_ram - ram_read_target_claim,
        link_claims.wv_ram - ram_write_target_claim,
        K::ZERO,
        K::ZERO,
    ];
    let mut linkage_batch_value = K::ZERO;
    let mut gamma_power = K::ONE;
    for term in linkage_terms {
        linkage_batch_value += gamma_power * term;
        gamma_power *= gamma_twist_link;
    }
    linkage_batch_value
}

pub(crate) struct Stage2ExecutionRegisterTargetClaims {
    pub reg_ra_y: K,
    pub reg_wa_addr: K,
    pub reg_write_x: K,
    pub reg_write_i: K,
}

fn cycle_product_claim(eq_cycle: &[K], factor_a: &[K], factor_b: &[K]) -> K {
    eq_cycle
        .iter()
        .zip(factor_a.iter())
        .zip(factor_b.iter())
        .fold(K::ZERO, |acc, ((&eq, &a), &b)| acc + eq * a * b)
}

pub(crate) fn reconstruct_register_target_claims(
    trace_rows: &[[F; 24]],
    aux: &[crate::chip8::kernel::KernelStepAux],
    cycle_point: &[K],
) -> Stage2ExecutionRegisterTargetClaims {
    let eq_cycle = crate::chip8::poly::build_eq_table(cycle_point);
    let uses_y_vals = self::common::bool_values_from_aux(aux, |row| row.uses_y);
    let writes_lookup_to_x = self::common::col_values(trace_rows, crate::chip8::spec::COL_WRITES_LOOKUP_TO_X);
    let writes_mem_to_x = self::common::col_values(trace_rows, crate::chip8::spec::COL_WRITES_MEM_TO_X);
    let writes_nnn_to_i = self::common::col_values(trace_rows, crate::chip8::spec::COL_WRITES_NNN_TO_I);
    let x_idx_vals = self::common::col_values(trace_rows, crate::chip8::spec::COL_X_IDX);
    let y_idx_vals = self::common::col_values(trace_rows, crate::chip8::spec::COL_Y_IDX);
    let reg_x_next_vals = self::common::col_values(trace_rows, crate::chip8::spec::COL_REG_X_NEXT);
    let i_next_vals = self::common::col_values(trace_rows, crate::chip8::spec::COL_I_NEXT);
    let write_x_target_flag: Vec<K> = writes_lookup_to_x
        .iter()
        .zip(writes_mem_to_x.iter())
        .map(|(&lookup, &mem)| lookup + mem)
        .collect();

    Stage2ExecutionRegisterTargetClaims {
        reg_ra_y: cycle_product_claim(&eq_cycle, &uses_y_vals, &y_idx_vals),
        reg_wa_addr: cycle_product_claim(&eq_cycle, &write_x_target_flag, &x_idx_vals),
        reg_write_x: cycle_product_claim(&eq_cycle, &write_x_target_flag, &reg_x_next_vals),
        reg_write_i: cycle_product_claim(&eq_cycle, &writes_nnn_to_i, &i_next_vals),
    }
}

pub(crate) fn reconstruct_link_claims_from_execution(
    lane_values_at_twist: &[K],
    reg_write_x_target_claim: K,
    reg_write_i_target_claim: K,
    ram_read_target_claim: K,
    ram_write_target_claim: K,
) -> Stage2LinkClaims {
    Stage2LinkClaims {
        rv_x: lane_values_at_twist[0],
        rv_y: lane_values_at_twist[1],
        rv_i: lane_values_at_twist[3],
        wv_reg: reg_write_x_target_claim + reg_write_i_target_claim,
        rv_ram: ram_read_target_claim,
        wv_ram: ram_write_target_claim,
    }
}

pub(crate) fn sample_stage2_cycle_point<Tr: neo_transcript::Transcript>(tr: &mut Tr, cycle_bits: usize) -> Vec<K> {
    self::common::squeeze_point(tr, b"stage2/r_cycle", cycle_bits)
}

pub(crate) fn derive_stage2_execution_surface<Tr: Transcript>(
    register: &Stage2RegisterExecutionProof,
    memory: &Stage2RamExecutionProof,
    initial_registers: &[u8; 16],
    initial_i: u16,
    initial_ram: &[u8],
    trace_rows: &[[F; 24]],
    aux: &[KernelStepAux],
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<Stage2DerivedExecutionSurface, SimpleKernelError> {
    let cycle_point = sample_stage2_cycle_point(transcript, cycle_bits);
    let lane_values_at_twist = lane_values_at_cycle(trace_rows, &cycle_point);
    let handoff_values_at_twist = handoff_values_at_cycle(aux, &cycle_point);
    let register_target_claims = reconstruct_register_target_claims(trace_rows, aux, &cycle_point);
    let (ram_read_target_claim, ram_write_target_claim) = reconstruct_ram_target_claims(trace_rows, aux, &cycle_point);
    let (ram_raf_read_claim, ram_raf_write_claim) = reconstruct_ram_raf_claims(trace_rows, aux, &cycle_point);
    let transcript_challenges = replay_stage2_execution_transcript(
        transcript,
        register,
        memory,
        initial_registers,
        initial_i,
        initial_ram,
        aux,
        &cycle_point,
        &lane_values_at_twist,
        &handoff_values_at_twist,
        &register_target_claims,
        ram_read_target_claim,
        ram_write_target_claim,
        ram_raf_read_claim,
        ram_raf_write_claim,
        cycle_bits,
    )?;
    let link_claims = reconstruct_link_claims_from_execution(
        &lane_values_at_twist,
        register_target_claims.reg_write_x,
        register_target_claims.reg_write_i,
        ram_read_target_claim,
        ram_write_target_claim,
    );
    let linkage_batch_value = compute_linkage_batch_value_from_claims(
        &link_claims,
        transcript_challenges.gamma_twist_link,
        register_target_claims.reg_write_x,
        register_target_claims.reg_write_i,
        ram_read_target_claim,
        ram_write_target_claim,
        &lane_values_at_twist,
    );

    Ok(Stage2DerivedExecutionSurface {
        cycle_point,
        reg_addr_point: transcript_challenges.reg_addr_point,
        reg_val_at_point: transcript_challenges.reg_val_at_point,
        ram_addr_point: transcript_challenges.ram_addr_point,
        ram_val_at_point: transcript_challenges.ram_val_at_point,
        gamma_reg: transcript_challenges.gamma_reg,
        reg_val_from_inc_claim: transcript_challenges.reg_val_from_inc_claim,
        gamma_ram: transcript_challenges.gamma_ram,
        ram_val_from_inc_claim: transcript_challenges.ram_val_from_inc_claim,
        ram_raf_read_claim,
        ram_raf_write_claim,
        reg_ra_y_target_claim: register_target_claims.reg_ra_y,
        reg_wa_addr_target_claim: register_target_claims.reg_wa_addr,
        reg_write_x_target_claim: register_target_claims.reg_write_x,
        reg_write_i_target_claim: register_target_claims.reg_write_i,
        ram_read_target_claim,
        ram_write_target_claim,
        link_claims,
        gamma_twist_link: transcript_challenges.gamma_twist_link,
        linkage_batch_value,
        lane_values_at_twist,
        handoff_values_at_twist,
    })
}

pub(crate) fn rebuild_stage2_proof_from_execution(
    register: &Stage2RegisterExecutionProof,
    memory: &Stage2RamExecutionProof,
    surface: &Stage2DerivedExecutionSurface,
) -> Stage2TwistProof {
    Stage2TwistProof {
        cycle_point: surface.cycle_point.clone(),
        reg_addr_point: surface.reg_addr_point.clone(),
        reg_val_at_point: surface.reg_val_at_point,
        ram_addr_point: surface.ram_addr_point.clone(),
        ram_val_at_point: surface.ram_val_at_point,
        gamma_reg: surface.gamma_reg,
        reg_rw_batched_rounds: register.reg_rw_batched_rounds.clone(),
        reg_val_from_inc_claim: surface.reg_val_from_inc_claim,
        reg_val_from_inc_rounds: register.reg_val_from_inc_rounds.clone(),
        reg_addr_correctness: register.reg_addr_correctness.clone(),
        gamma_ram: surface.gamma_ram,
        ram_rw_batched_rounds: memory.ram_rw_batched_rounds.clone(),
        ram_val_from_inc_claim: surface.ram_val_from_inc_claim,
        ram_val_from_inc_rounds: memory.ram_val_from_inc_rounds.clone(),
        ram_raf_read_claim: surface.ram_raf_read_claim,
        ram_raf_read_rounds: memory.ram_raf_read_rounds.clone(),
        ram_raf_write_claim: surface.ram_raf_write_claim,
        ram_raf_write_rounds: memory.ram_raf_write_rounds.clone(),
        reg_ra_y_target_proof: CycleProductProof {
            claim: surface.reg_ra_y_target_claim,
            rounds: register.reg_ra_y_target_rounds.clone(),
        },
        reg_wa_addr_target_proof: CycleProductProof {
            claim: surface.reg_wa_addr_target_claim,
            rounds: register.reg_wa_addr_target_rounds.clone(),
        },
        reg_write_x_target_proof: CycleProductProof {
            claim: surface.reg_write_x_target_claim,
            rounds: register.reg_write_x_target_rounds.clone(),
        },
        reg_write_i_target_proof: CycleProductProof {
            claim: surface.reg_write_i_target_claim,
            rounds: register.reg_write_i_target_rounds.clone(),
        },
        ram_read_target_proof: CycleProductProof {
            claim: surface.ram_read_target_claim,
            rounds: memory.ram_read_target_rounds.clone(),
        },
        ram_write_target_proof: CycleProductProof {
            claim: surface.ram_write_target_claim,
            rounds: memory.ram_write_target_rounds.clone(),
        },
        ram_write_matches_x_zero_proof: CycleProductProof {
            claim: K::ZERO,
            rounds: memory.ram_write_matches_x_zero_rounds.clone(),
        },
        ram_idle_mem_zero_proof: CycleProductProof {
            claim: K::ZERO,
            rounds: memory.ram_idle_mem_zero_rounds.clone(),
        },
        ram_addr_correctness: memory.ram_addr_correctness.clone(),
        link_claims: surface.link_claims.clone(),
        gamma_twist_link: surface.gamma_twist_link,
        linkage_batch_value: surface.linkage_batch_value,
        lane_values_at_twist: surface.lane_values_at_twist.clone(),
        handoff_values_at_twist: surface.handoff_values_at_twist.clone(),
    }
}

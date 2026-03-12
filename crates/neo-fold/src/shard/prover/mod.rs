//! Shard proving orchestration and phase assembly for the SuperNeo shard path.
//!
//! This module owns the proving-side coordinator for one shard run. It builds
//! the step-invariant proving context, drives per-step Route-A + CCS + folding
//! phases, and packages the final shard proof artifacts. Shared arithmetic and
//! reusable helper logic live in sibling modules.

use super::*;

mod ccs_only_batched;
mod context;
mod lanes;
mod mixed_batched;
mod openings;
mod poseidon_lane_helpers;
mod rlc_dec;
mod route_a;
mod route_a_segment;
mod step;

use context::{
    commit_poseidon_lane_wits_batched, cpu_sumcheck_from_ccs, prepare_shard_prove_context,
    shift_sumcheck_from_batched_time, PreparedShardProveContext,
};
use lanes::{prove_aux_cpu_me_lane, prove_val_lane, AuxCpuLaneConfig};
use openings::{prove_openings_phase, OpeningsPhaseContext};
use route_a::{
    prepare_route_a_step_metadata, prove_route_a_time_phase, PreparedRouteAStepMetadata, PreparedRouteATimePhase,
};
use step::{prove_shard_step, ShardRunState, ShardStepEnvironment};

pub use ccs_only_batched::{fold_shard_prove_ccs_only_batched, fold_shard_verify_ccs_only_batched};
pub(crate) use context::mode_uses_sparse_cache;
pub(crate) use mixed_batched::*;
pub(crate) use poseidon_lane_helpers::*;
pub(crate) use rlc_dec::*;
pub(crate) use route_a_segment::*;

#[derive(Clone)]
pub(crate) struct ShardProverContext {
    pub ccs_mat_digest: Vec<F>,
    pub ccs_sparse_cache: Option<Arc<SparseCache<F>>>,
}

pub(crate) struct ShardProveArtifacts {
    pub proof: ShardProof,
    pub final_main_wits: Vec<Mat<F>>,
    pub val_lane_wits: Vec<Mat<F>>,
    pub next_prev_twist_decoded: Option<Vec<crate::memory_sidecar::memory::TwistDecodedColsSparse>>,
    pub next_poseidon_carry: crate::memory_sidecar::memory::PoseidonSidecarCarryState,
    pub audit: ShardProofAudit<F>,
}

/// Stable proving inputs that configure one shard run but do not evolve across steps.
pub(crate) struct ShardProveOptions<'a, MR, MB>
where
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt,
    MB: Fn(&[Cmt], u32) -> Cmt,
{
    pub collect_val_lane_wits: bool,
    pub mode: FoldingMode,
    pub step_idx_offset: usize,
    pub mixers: CommitMixers<MR, MB>,
    pub output_binding: Option<(&'a crate::output_binding::OutputBindingConfig, &'a [F])>,
    pub prover_ctx: Option<&'a ShardProverContext>,
    pub step_prove_ms_out: Option<&'a mut Vec<f64>>,
}

/// Step-to-step carry state entering a shard proving run.
pub(crate) struct ShardCarryInput<'a> {
    pub prev_step: Option<&'a StepWitnessBundle<Cmt, F, K>>,
    pub prev_twist_decoded: Option<Vec<crate::memory_sidecar::memory::TwistDecodedColsSparse>>,
    pub poseidon_carry: Option<crate::memory_sidecar::memory::PoseidonSidecarCarryState>,
}

pub(crate) fn fold_shard_prove_impl<L, MR, MB>(
    options: ShardProveOptions<'_, MR, MB>,
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    s_me: &CcsStructure<F>,
    steps: &[StepWitnessBundle<Cmt, F, K>],
    acc_init: &[CeClaim<Cmt, F, K>],
    acc_wit_init: &[Mat<F>],
    l: &L,
    carry: ShardCarryInput<'_>,
) -> Result<ShardProveArtifacts, PiCcsError>
where
    L: SModuleHomomorphism<F, Cmt> + Sync,
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
{
    let ShardProveOptions {
        collect_val_lane_wits,
        mode,
        step_idx_offset,
        mixers,
        output_binding: ob,
        prover_ctx,
        mut step_prove_ms_out,
    } = options;
    let ShardCarryInput {
        prev_step: initial_prev_step,
        prev_twist_decoded: initial_prev_twist_decoded,
        poseidon_carry: initial_poseidon_carry,
    } = carry;

    tr.append_message(b"shard/cpu_bus_mode", &[1u8]);
    let prepared = prepare_shard_prove_context(&mode, params, s_me, steps, acc_init, acc_wit_init, prover_ctx)?;

    let mut run_state = ShardRunState::new(
        acc_init.to_vec(),
        acc_wit_init.to_vec(),
        initial_prev_twist_decoded,
        initial_poseidon_carry,
        steps.len(),
    );
    if ob.is_some() && steps.is_empty() {
        return Err(PiCcsError::InvalidInput("output binding requires >= 1 step".into()));
    }

    for (idx, step) in steps.iter().enumerate() {
        let step_idx = step_idx_offset
            .checked_add(idx)
            .ok_or_else(|| PiCcsError::InvalidInput("step index overflow".into()))?;
        let step_start = time_now();
        let prev_step = if idx > 0 {
            Some(&steps[idx - 1])
        } else {
            initial_prev_step
        };
        prove_shard_step(
            ShardStepEnvironment {
                tr,
                params,
                prepared: &prepared,
                mode: &mode,
                step,
                step_idx,
                is_last_step: idx + 1 == steps.len(),
                output_binding: ob,
                collect_val_lane_wits,
                l,
                mixers,
                prev_step,
            },
            &mut run_state,
        )?;
        if let Some(out) = step_prove_ms_out.as_deref_mut() {
            out.push(elapsed_ms(step_start));
        }
    }

    Ok(run_state.into_artifacts())
}

//! Public shard verification/finalization entrypoints and compatibility wrappers.
//!
//! This module owns the outward-facing verify/finalize API: canonical
//! options-based entrypoints plus compatibility wrappers. Core shard
//! verification logic remains in `verifier.rs`.

use super::*;

/// Semantic options for shard verification/finalization.
#[derive(Clone, Copy, Default)]
pub struct ShardVerifyApiOptions<'a> {
    pub step_idx_offset: usize,
    pub step_linking: Option<&'a StepLinkingConfig>,
    pub output_binding: Option<&'a crate::output_binding::OutputBindingConfig>,
}

pub fn fold_shard_verify_with_options<MR, MB>(
    mode: FoldingMode,
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    s_me: &CcsStructure<F>,
    steps: &[StepInstanceBundle<Cmt, F, K>],
    acc_init: &[CeClaim<Cmt, F, K>],
    proof: &ShardProof,
    mixers: CommitMixers<MR, MB>,
    options: ShardVerifyApiOptions<'_>,
) -> Result<ShardFoldOutputs<Cmt, F, K>, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
{
    fold_shard_verify_with_options_and_prover_ctx(mode, tr, params, s_me, steps, acc_init, proof, mixers, options, None)
}

pub(crate) fn fold_shard_verify_with_options_and_prover_ctx<MR, MB>(
    mode: FoldingMode,
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    s_me: &CcsStructure<F>,
    steps: &[StepInstanceBundle<Cmt, F, K>],
    acc_init: &[CeClaim<Cmt, F, K>],
    proof: &ShardProof,
    mixers: CommitMixers<MR, MB>,
    options: ShardVerifyApiOptions<'_>,
    prover_ctx: Option<&ShardProverContext>,
) -> Result<ShardFoldOutputs<Cmt, F, K>, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
{
    if let Some(step_linking) = options.step_linking {
        check_step_linking(steps, step_linking)?;
    }

    if let Some(ob_cfg) = options.output_binding {
        fold_shard_verify_mixed_ccs_batched_with_output_binding(
            mode,
            tr,
            params,
            s_me,
            steps,
            options.step_idx_offset,
            acc_init,
            proof,
            mixers,
            ob_cfg,
            prover_ctx,
        )
    } else {
        fold_shard_verify_mixed_ccs_batched(
            mode,
            tr,
            params,
            s_me,
            steps,
            options.step_idx_offset,
            acc_init,
            proof,
            mixers,
            prover_ctx,
        )
    }
}

pub fn fold_shard_verify<MR, MB>(
    mode: FoldingMode,
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    s_me: &CcsStructure<F>,
    steps: &[StepInstanceBundle<Cmt, F, K>],
    acc_init: &[CeClaim<Cmt, F, K>],
    proof: &ShardProof,
    mixers: CommitMixers<MR, MB>,
) -> Result<ShardFoldOutputs<Cmt, F, K>, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
{
    fold_shard_verify_with_options(
        mode,
        tr,
        params,
        s_me,
        steps,
        acc_init,
        proof,
        mixers,
        ShardVerifyApiOptions::default(),
    )
}

pub fn fold_shard_verify_and_finalize_with_options<MR, MB, Fin>(
    mode: FoldingMode,
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    s_me: &CcsStructure<F>,
    steps: &[StepInstanceBundle<Cmt, F, K>],
    acc_init: &[CeClaim<Cmt, F, K>],
    proof: &ShardProof,
    mixers: CommitMixers<MR, MB>,
    options: ShardVerifyApiOptions<'_>,
    finalizer: &mut Fin,
) -> Result<(), PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
    Fin: ObligationFinalizer<Cmt, F, K, Error = PiCcsError>,
{
    let outputs = fold_shard_verify_with_options(mode, tr, params, s_me, steps, acc_init, proof, mixers, options)?;
    let report = finalizer.finalize(&outputs.obligations)?;
    outputs
        .obligations
        .require_all_finalized(report.did_finalize_main, report.did_finalize_val)?;
    Ok(())
}

pub fn fold_shard_verify_and_finalize<MR, MB, Fin>(
    mode: FoldingMode,
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    s_me: &CcsStructure<F>,
    steps: &[StepInstanceBundle<Cmt, F, K>],
    acc_init: &[CeClaim<Cmt, F, K>],
    proof: &ShardProof,
    mixers: CommitMixers<MR, MB>,
    finalizer: &mut Fin,
) -> Result<(), PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
    Fin: ObligationFinalizer<Cmt, F, K, Error = PiCcsError>,
{
    fold_shard_verify_and_finalize_with_options(
        mode,
        tr,
        params,
        s_me,
        steps,
        acc_init,
        proof,
        mixers,
        ShardVerifyApiOptions::default(),
        finalizer,
    )
}

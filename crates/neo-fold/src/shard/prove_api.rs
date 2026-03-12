//! Public shard proving entrypoints and compatibility wrappers.
//!
//! This module owns the outward-facing prove API: canonical options-based
//! entrypoints plus thin compatibility wrappers for existing call sites. The
//! proving core itself stays in `prover.rs`.

use super::*;

/// Output-binding inputs for shard proving.
#[derive(Clone, Copy)]
pub struct ShardOutputBindingInput<'a> {
    pub config: &'a crate::output_binding::OutputBindingConfig,
    pub final_memory_state: &'a [F],
}

/// Semantic options for shard proving.
#[derive(Clone, Copy, Default)]
pub struct ShardProveApiOptions<'a> {
    pub step_idx_offset: usize,
    pub output_binding: Option<ShardOutputBindingInput<'a>>,
    pub include_audit: bool,
}

/// Canonical shard proving outputs.
pub struct ShardProveApiResult {
    pub proof: ShardProof,
    pub outputs: ShardFoldOutputs<Cmt, F, K>,
    pub witnesses: ShardFoldWitnesses<F>,
    pub audit: Option<ShardProofAudit<F>>,
}

#[derive(Clone, Copy, Default)]
pub(crate) struct ShardProveInternalOptions<'a> {
    pub step_idx_offset: usize,
    pub output_binding: Option<ShardOutputBindingInput<'a>>,
    pub prover_ctx: Option<&'a ShardProverContext>,
    pub include_audit: bool,
}

fn build_shard_prove_result(
    proof: ShardProof,
    acc_init: &[CeClaim<Cmt, F, K>],
    final_main_wits: Vec<Mat<F>>,
    val_lane_wits: Vec<Mat<F>>,
    audit: Option<ShardProofAudit<F>>,
) -> Result<ShardProveApiResult, PiCcsError> {
    let outputs = proof.compute_fold_outputs(acc_init);
    if outputs.obligations.main.len() != final_main_wits.len() {
        return Err(PiCcsError::ProtocolError(format!(
            "final main witness count mismatch (have {}, need {})",
            final_main_wits.len(),
            outputs.obligations.main.len()
        )));
    }
    Ok(ShardProveApiResult {
        proof,
        outputs,
        witnesses: ShardFoldWitnesses {
            final_main_wits,
            val_lane_wits,
        },
        audit,
    })
}

pub fn fold_shard_prove_with_options<L, MR, MB>(
    mode: FoldingMode,
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    s_me: &CcsStructure<F>,
    steps: &[StepWitnessBundle<Cmt, F, K>],
    acc_init: &[CeClaim<Cmt, F, K>],
    acc_wit_init: &[Mat<F>],
    l: &L,
    mixers: CommitMixers<MR, MB>,
    options: ShardProveApiOptions<'_>,
) -> Result<ShardProveApiResult, PiCcsError>
where
    L: SModuleHomomorphism<F, Cmt> + Sync,
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
{
    fold_shard_prove_with_internal_options(
        mode,
        tr,
        params,
        s_me,
        steps,
        acc_init,
        acc_wit_init,
        l,
        mixers,
        ShardProveInternalOptions {
            step_idx_offset: options.step_idx_offset,
            output_binding: options.output_binding,
            include_audit: options.include_audit,
            prover_ctx: None,
        },
    )
}

pub(crate) fn fold_shard_prove_with_internal_options<L, MR, MB>(
    mode: FoldingMode,
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    s_me: &CcsStructure<F>,
    steps: &[StepWitnessBundle<Cmt, F, K>],
    acc_init: &[CeClaim<Cmt, F, K>],
    acc_wit_init: &[Mat<F>],
    l: &L,
    mixers: CommitMixers<MR, MB>,
    options: ShardProveInternalOptions<'_>,
) -> Result<ShardProveApiResult, PiCcsError>
where
    L: SModuleHomomorphism<F, Cmt> + Sync,
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
{
    let ShardProveInternalOptions {
        step_idx_offset,
        output_binding,
        prover_ctx,
        include_audit,
    } = options;
    let (proof, final_main_wits, val_lane_wits, audit) = if let Some(ob) = output_binding {
        let (proof, final_main_wits, val_lane_wits, audit) =
            fold_shard_prove_mixed_ccs_batched_with_output_binding_and_audit(
                mode,
                tr,
                params,
                s_me,
                steps,
                acc_init,
                acc_wit_init,
                l,
                mixers,
                step_idx_offset,
                ob.config,
                ob.final_memory_state,
                prover_ctx,
            )?;
        (proof, final_main_wits, val_lane_wits, include_audit.then_some(audit))
    } else if include_audit {
        let (proof, final_main_wits, val_lane_wits, audit) =
            fold_shard_prove_mixed_ccs_batched_with_witnesses_and_audit(
                mode,
                tr,
                params,
                s_me,
                steps,
                acc_init,
                acc_wit_init,
                l,
                mixers,
                step_idx_offset,
                prover_ctx,
            )?;
        (proof, final_main_wits, val_lane_wits, Some(audit))
    } else {
        let (proof, final_main_wits, val_lane_wits) = fold_shard_prove_mixed_ccs_batched_with_witnesses(
            mode,
            tr,
            params,
            s_me,
            steps,
            acc_init,
            acc_wit_init,
            l,
            mixers,
            step_idx_offset,
            prover_ctx,
        )?;
        (proof, final_main_wits, val_lane_wits, None)
    };
    build_shard_prove_result(proof, acc_init, final_main_wits, val_lane_wits, audit)
}

pub fn fold_shard_prove<L, MR, MB>(
    mode: FoldingMode,
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    s_me: &CcsStructure<F>,
    steps: &[StepWitnessBundle<Cmt, F, K>],
    acc_init: &[CeClaim<Cmt, F, K>],
    acc_wit_init: &[Mat<F>],
    l: &L,
    mixers: CommitMixers<MR, MB>,
) -> Result<ShardProof, PiCcsError>
where
    L: SModuleHomomorphism<F, Cmt> + Sync,
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
{
    Ok(fold_shard_prove_with_internal_options(
        mode,
        tr,
        params,
        s_me,
        steps,
        acc_init,
        acc_wit_init,
        l,
        mixers,
        ShardProveInternalOptions::default(),
    )?
    .proof)
}

pub fn fold_shard_prove_with_witnesses<L, MR, MB>(
    mode: FoldingMode,
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    s_me: &CcsStructure<F>,
    steps: &[StepWitnessBundle<Cmt, F, K>],
    acc_init: &[CeClaim<Cmt, F, K>],
    acc_wit_init: &[Mat<F>],
    l: &L,
    mixers: CommitMixers<MR, MB>,
) -> Result<(ShardProof, ShardFoldOutputs<Cmt, F, K>, ShardFoldWitnesses<F>), PiCcsError>
where
    L: SModuleHomomorphism<F, Cmt> + Sync,
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
{
    let result = fold_shard_prove_with_options(
        mode,
        tr,
        params,
        s_me,
        steps,
        acc_init,
        acc_wit_init,
        l,
        mixers,
        ShardProveApiOptions::default(),
    )?;
    Ok((result.proof, result.outputs, result.witnesses))
}

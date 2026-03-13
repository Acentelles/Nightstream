//! Shard proving preflight and step-invariant context construction.

use super::*;

/// Step-invariant context computed during shard preflight and reused across all steps.
pub(super) struct PreparedShardProveContext<'a> {
    pub s: &'a CcsStructure<F>,
    pub cpu_bus: neo_memory::cpu::BusLayout,
    pub dims: utils::Dims,
    pub ell_d: usize,
    pub ell_n: usize,
    pub ell_m: usize,
    pub ell: usize,
    pub d_sc: usize,
    pub ccs_sparse_cache: Option<Arc<SparseCache<F>>>,
    pub ccs_mat_digest: Vec<F>,
    pub k_dec: usize,
    pub ring: ccs::RotRing,
}

#[inline]
pub(crate) fn mode_uses_sparse_cache(mode: &FoldingMode) -> bool {
    match mode {
        FoldingMode::Optimized => true,
        #[cfg(feature = "paper-exact")]
        FoldingMode::OptimizedWithCrosscheck(_) => true,
        #[cfg(feature = "paper-exact")]
        FoldingMode::PaperExact => false,
    }
}

pub(super) fn cpu_sumcheck_from_ccs(
    claimed_sum: K,
    round_polys: Vec<Vec<K>>,
    r_time: &[K],
) -> crate::shard_proof_types::CpuTimeSumcheckProof {
    crate::shard_proof_types::CpuTimeSumcheckProof {
        claimed_sum,
        round_polys,
        r_time: r_time.to_vec(),
    }
}

#[inline]
pub(super) fn commit_poseidon_lane_wits_batched(
    params: &NeoParams,
    wits: &[Mat<F>],
    label: &str,
) -> Result<Vec<Cmt>, PiCcsError> {
    if wits.is_empty() {
        return Ok(Vec::new());
    }
    let mut by_cols: std::collections::BTreeMap<usize, Vec<(usize, &Mat<F>)>> = std::collections::BTreeMap::new();
    for (idx, z) in wits.iter().enumerate() {
        by_cols.entry(z.cols()).or_default().push((idx, z));
    }
    let mut out: Vec<Option<Cmt>> = vec![None; wits.len()];
    for (cols, grouped) in by_cols {
        let committer = crate::shard::prover::poseidon_lane_helpers::poseidon_lane_committer(params, cols, label)?;
        let refs: Vec<&Mat<F>> = grouped.iter().map(|(_, z)| *z).collect();
        let commits = committer.commit_many(&refs);
        if commits.len() != refs.len() {
            return Err(PiCcsError::ProtocolError(format!(
                "{label}: commit_many returned {} commitments for {} matrices",
                commits.len(),
                refs.len()
            )));
        }
        for ((idx, _), c) in grouped.into_iter().zip(commits.into_iter()) {
            out[idx] = Some(c);
        }
    }
    out.into_iter()
        .enumerate()
        .map(|(idx, c)| {
            c.ok_or_else(|| PiCcsError::ProtocolError(format!("{label}: missing commitment at index {idx}")))
        })
        .collect()
}

pub(super) fn prepare_shard_prove_context<'a>(
    mode: &FoldingMode,
    params: &NeoParams,
    s_me: &'a CcsStructure<F>,
    steps: &[StepWitnessBundle<Cmt, F, K>],
    acc_init: &[CeClaim<Cmt, F, K>],
    acc_wit_init: &[Mat<F>],
    prover_ctx: Option<&ShardProverContext>,
) -> Result<PreparedShardProveContext<'a>, PiCcsError> {
    for (step_idx, step) in steps.iter().enumerate() {
        if step.lut_instances.is_empty() && step.mem_instances.is_empty() {
            continue;
        }
        let is_shared_step = step
            .lut_instances
            .iter()
            .all(|(inst, wit)| inst.comms.is_empty() && wit.mats.is_empty())
            && step
                .mem_instances
                .iter()
                .all(|(inst, wit)| inst.comms.is_empty() && wit.mats.is_empty());
        if !is_shared_step {
            return Err(PiCcsError::InvalidInput(format!(
                "legacy no-shared CPU bus mode was removed; step_idx={step_idx} must use shared-bus witness format"
            )));
        }
    }

    let (s, cpu_bus) = crate::memory_sidecar::cpu_bus::prepare_ccs_for_shared_cpu_bus_steps(s_me, steps)?;
    let dims = utils::build_dims_and_policy(params, s)?;
    let utils::Dims {
        ell_d,
        ell_n,
        ell_m,
        ell,
        d_sc,
        ..
    } = dims;
    let ccs_sparse_cache = if mode_uses_sparse_cache(mode) {
        Some(
            prover_ctx
                .and_then(|ctx| ctx.ccs_sparse_cache.clone())
                .unwrap_or_else(|| Arc::new(SparseCache::build(s))),
        )
    } else {
        None
    };
    let ccs_mat_digest = prover_ctx
        .map(|ctx| ctx.ccs_mat_digest.clone())
        .unwrap_or_else(|| utils::digest_ccs_matrices_with_sparse_cache(s, ccs_sparse_cache.as_deref()));
    if mode_uses_sparse_cache(mode) && ccs_sparse_cache.is_none() {
        return Err(PiCcsError::ProtocolError(
            "missing SparseCache for optimized mode".into(),
        ));
    }
    if acc_init.len() != acc_wit_init.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "acc_init.len()={} != acc_wit_init.len()={}",
            acc_init.len(),
            acc_wit_init.len()
        )));
    }

    Ok(PreparedShardProveContext {
        s,
        cpu_bus,
        dims,
        ell_d,
        ell_n,
        ell_m,
        ell,
        d_sc,
        ccs_sparse_cache,
        ccs_mat_digest,
        k_dec: params.k_rho as usize,
        ring: ccs::RotRing::goldilocks(),
    })
}

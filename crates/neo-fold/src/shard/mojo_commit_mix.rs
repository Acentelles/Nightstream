use neo_ajtai::Commitment as Cmt;
use neo_ccs::Mat;
use neo_gpu::FlatRq;
use neo_math::{D, F};
use p3_field::{PrimeCharacteristicRing, PrimeField64};

use crate::PiCcsError;

#[inline]
fn flat_rq_from_rot_matrix(mat: &Mat<F>) -> Option<FlatRq> {
    if mat.rows() != D || mat.cols() != D {
        return None;
    }
    let mut coeffs = [0u64; D];
    for row in 0..D {
        coeffs[row] = mat[(row, 0)].as_canonical_u64();
    }
    Some(FlatRq { coeffs })
}

#[inline]
fn flat_rq_from_commitment_col(c: &Cmt, col: usize) -> Option<FlatRq> {
    if c.d != D || col >= c.kappa {
        return None;
    }
    let mut coeffs = [0u64; D];
    for (dst, src) in coeffs.iter_mut().zip(c.col(col).iter()) {
        *dst = src.as_canonical_u64();
    }
    Some(FlatRq { coeffs })
}

#[inline]
fn ring_mix_tasks(cs: &[Cmt]) -> usize {
    cs.first()
        .map(|c| cs.len().saturating_mul(c.kappa).saturating_mul(D))
        .unwrap_or(0)
}

fn ring_mix_tasks_many(cs_groups: &[Vec<Cmt>]) -> usize {
    cs_groups.iter().map(|group| ring_mix_tasks(group)).sum()
}

fn try_mix_rhos_commits_with_mojo(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    rhos: &[Mat<F>],
    cs: &[Cmt],
) -> Result<Option<Cmt>, PiCcsError> {
    if rhos.is_empty() || cs.is_empty() || rhos.len() != cs.len() {
        return Ok(None);
    }
    let tasks = ring_mix_tasks(cs);
    if matches!(
        backend_ctx.commit_mix_execution_status(tasks),
        neo_reductions::accelerator::BackendExecutionStatus::RustCpu
    ) {
        return Ok(None);
    }
    let Some(session) = backend_ctx.aux_session()? else {
        return Ok(None);
    };

    let d = cs[0].d;
    let kappa = cs[0].kappa;
    if d != D || cs.iter().any(|c| c.d != d || c.kappa != kappa) {
        return Ok(None);
    }

    let mut lhs_batch = Vec::with_capacity(rhos.len() * kappa);
    let mut rhs_batch = Vec::with_capacity(rhos.len() * kappa);
    let mut slot_offsets = Vec::with_capacity(kappa + 1);
    slot_offsets.push(0u64);
    for col in 0..kappa {
        for (rho, c) in rhos.iter().zip(cs.iter()) {
            let Some(rho_words) = flat_rq_from_rot_matrix(rho) else {
                return Ok(None);
            };
            let Some(col_words) = flat_rq_from_commitment_col(c, col) else {
                return Ok(None);
            };
            lhs_batch.push(rho_words);
            rhs_batch.push(col_words);
        }
        slot_offsets.push(lhs_batch.len() as u64);
    }

    let products = match crate::shard::rq_accumulate_with_backend(session, &lhs_batch, &rhs_batch, &slot_offsets) {
        Ok(values) => values,
        Err(err) if backend_ctx.mojo_required() => {
            return Err(PiCcsError::ProtocolError(format!(
                "strict Mojo commit mix failed during rq_accumulate: {err}"
            )))
        }
        Err(err) => {
            backend_ctx.record_aux_backend_failure("Mojo commit mix rq_accumulate failed", &err)?;
            return Ok(None);
        }
    };

    let mut acc = Cmt::zeros(d, kappa);
    for (col, prod) in products.iter().enumerate() {
        for (dst, src) in acc.col_mut(col).iter_mut().zip(prod.coeffs.iter()) {
            *dst += F::from_u64(*src);
        }
    }

    Ok(Some(acc))
}

fn try_combine_b_pows_with_mojo(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    cs: &[Cmt],
    b: u32,
) -> Result<Option<Cmt>, PiCcsError> {
    if cs.is_empty() {
        return Ok(None);
    }
    let tasks = ring_mix_tasks(cs);
    if matches!(
        backend_ctx.commit_mix_execution_status(tasks),
        neo_reductions::accelerator::BackendExecutionStatus::RustCpu
    ) {
        return Ok(None);
    }
    let Some(session) = backend_ctx.aux_session()? else {
        return Ok(None);
    };

    let d = cs[0].d;
    let kappa = cs[0].kappa;
    if d != D || cs.iter().any(|c| c.d != d || c.kappa != kappa) {
        return Ok(None);
    }

    let mut lhs_batch = Vec::with_capacity((cs.len().saturating_sub(1)) * kappa);
    let mut rhs_batch = Vec::with_capacity((cs.len().saturating_sub(1)) * kappa);
    let mut slot_offsets = Vec::with_capacity(kappa + 1);
    slot_offsets.push(0u64);
    for col in 0..kappa {
        let mut pow = F::from_u64(b as u64);
        for c in cs.iter().skip(1) {
            let rho_words = FlatRq {
                coeffs: std::array::from_fn(|idx| if idx == 0 { pow.as_canonical_u64() } else { 0 }),
            };
            let Some(col_words) = flat_rq_from_commitment_col(c, col) else {
                return Ok(None);
            };
            lhs_batch.push(rho_words);
            rhs_batch.push(col_words);
            pow *= F::from_u64(b as u64);
        }
        slot_offsets.push(lhs_batch.len() as u64);
    }

    let products = match crate::shard::rq_accumulate_with_backend(session, &lhs_batch, &rhs_batch, &slot_offsets) {
        Ok(values) => values,
        Err(err) if backend_ctx.mojo_required() => {
            return Err(PiCcsError::ProtocolError(format!(
                "strict Mojo combine_b_pows failed during rq_accumulate: {err}"
            )))
        }
        Err(err) => {
            backend_ctx.record_aux_backend_failure("Mojo combine_b_pows rq_accumulate failed", &err)?;
            return Ok(None);
        }
    };

    let mut acc = cs[0].clone();
    for (col, prod) in products.iter().enumerate() {
        for (dst, src) in acc.col_mut(col).iter_mut().zip(prod.coeffs.iter()) {
            *dst += F::from_u64(*src);
        }
    }

    Ok(Some(acc))
}

pub(crate) fn mix_rhos_commits_with_backend_result<MR>(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    fallback: MR,
    rhos: &[Mat<F>],
    cs: &[Cmt],
) -> Result<Cmt, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Cmt]) -> Result<Cmt, PiCcsError>,
{
    match try_mix_rhos_commits_with_mojo(backend_ctx, rhos, cs) {
        Ok(Some(commitment)) => Ok(commitment),
        Ok(None) => fallback(rhos, cs),
        Err(err) if backend_ctx.mojo_required() => Err(err),
        Err(_) => fallback(rhos, cs),
    }
}

fn try_mix_many_rhos_commits_with_mojo(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    rhos_groups: &[Vec<Mat<F>>],
    cs_groups: &[Vec<Cmt>],
) -> Result<Option<Vec<Cmt>>, PiCcsError> {
    if rhos_groups.is_empty() {
        return Ok(Some(Vec::new()));
    }
    if rhos_groups.len() != cs_groups.len() {
        return Ok(None);
    }
    if rhos_groups
        .iter()
        .zip(cs_groups.iter())
        .any(|(rhos, cs)| rhos.is_empty() || cs.is_empty() || rhos.len() != cs.len())
    {
        return Ok(None);
    }

    let tasks = ring_mix_tasks_many(cs_groups);
    if matches!(
        backend_ctx.commit_mix_execution_status(tasks),
        neo_reductions::accelerator::BackendExecutionStatus::RustCpu
    ) {
        return Ok(None);
    }
    let Some(session) = backend_ctx.aux_session()? else {
        return Ok(None);
    };

    let first = &cs_groups[0][0];
    let d = first.d;
    let kappa = first.kappa;
    if d != D
        || cs_groups
            .iter()
            .flatten()
            .any(|c| c.d != d || c.kappa != kappa)
    {
        return Ok(None);
    }

    let mut lhs_batch = Vec::new();
    let mut rhs_batch = Vec::new();
    let mut slot_offsets = Vec::with_capacity(rhos_groups.len() * kappa + 1);
    slot_offsets.push(0u64);
    for (rhos, cs) in rhos_groups.iter().zip(cs_groups.iter()) {
        for col in 0..kappa {
            for (rho, c) in rhos.iter().zip(cs.iter()) {
                let Some(rho_words) = flat_rq_from_rot_matrix(rho) else {
                    return Ok(None);
                };
                let Some(col_words) = flat_rq_from_commitment_col(c, col) else {
                    return Ok(None);
                };
                lhs_batch.push(rho_words);
                rhs_batch.push(col_words);
            }
            slot_offsets.push(lhs_batch.len() as u64);
        }
    }

    let products = match crate::shard::rq_accumulate_with_backend(session, &lhs_batch, &rhs_batch, &slot_offsets) {
        Ok(values) => values,
        Err(err) if backend_ctx.mojo_required() => {
            return Err(PiCcsError::ProtocolError(format!(
                "strict Mojo batched commit mix failed during rq_accumulate: {err}"
            )))
        }
        Err(err) => {
            backend_ctx.record_aux_backend_failure("Mojo batched commit mix rq_accumulate failed", &err)?;
            return Ok(None);
        }
    };

    let mut out = vec![Cmt::zeros(d, kappa); rhos_groups.len()];
    for (group_idx, group_products) in products.chunks(kappa).enumerate() {
        for (col, prod) in group_products.iter().enumerate() {
            for (dst, src) in out[group_idx]
                .col_mut(col)
                .iter_mut()
                .zip(prod.coeffs.iter())
            {
                *dst += F::from_u64(*src);
            }
        }
    }

    Ok(Some(out))
}

pub(crate) fn mix_many_rhos_commits_with_backend<MR>(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    fallback: MR,
    rhos_groups: &[Vec<Mat<F>>],
    cs_groups: &[Vec<Cmt>],
) -> Result<Vec<Cmt>, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Copy,
{
    mix_many_rhos_commits_with_backend_result(backend_ctx, |rhos, cs| Ok(fallback(rhos, cs)), rhos_groups, cs_groups)
}

pub(crate) fn mix_many_rhos_commits_with_backend_result<MR>(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    fallback: MR,
    rhos_groups: &[Vec<Mat<F>>],
    cs_groups: &[Vec<Cmt>],
) -> Result<Vec<Cmt>, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Cmt]) -> Result<Cmt, PiCcsError> + Copy,
{
    match try_mix_many_rhos_commits_with_mojo(backend_ctx, rhos_groups, cs_groups) {
        Ok(Some(commitments)) => Ok(commitments),
        Ok(None) => rhos_groups
            .iter()
            .zip(cs_groups.iter())
            .map(|(rhos, cs)| fallback(rhos, cs))
            .collect(),
        Err(err) if backend_ctx.mojo_required() => Err(err),
        Err(_) => rhos_groups
            .iter()
            .zip(cs_groups.iter())
            .map(|(rhos, cs)| fallback(rhos, cs))
            .collect(),
    }
}

pub(crate) fn combine_b_pows_with_backend_result<MB>(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    fallback: MB,
    cs: &[Cmt],
    b: u32,
) -> Result<Cmt, PiCcsError>
where
    MB: Fn(&[Cmt], u32) -> Cmt,
{
    match try_combine_b_pows_with_mojo(backend_ctx, cs, b) {
        Ok(Some(commitment)) => Ok(commitment),
        Ok(None) => Ok(fallback(cs, b)),
        Err(err) if backend_ctx.mojo_required() => Err(err),
        Err(_) => Ok(fallback(cs, b)),
    }
}

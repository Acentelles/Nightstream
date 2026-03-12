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
    for (rho, c) in rhos.iter().zip(cs.iter()) {
        let Some(rho_words) = flat_rq_from_rot_matrix(rho) else {
            return Ok(None);
        };
        for col in 0..kappa {
            let Some(col_words) = flat_rq_from_commitment_col(c, col) else {
                return Ok(None);
            };
            lhs_batch.push(rho_words);
            rhs_batch.push(col_words);
        }
    }

    let products = match session.rq_mul_batch_u64x54(&lhs_batch, &rhs_batch) {
        Ok(values) => values,
        Err(_) => return Ok(None),
    };

    let mut acc = Cmt::zeros(d, kappa);
    for (pair_idx, prod) in products.iter().enumerate() {
        let col = pair_idx % kappa;
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
    let mut pow = F::from_u64(b as u64);
    for c in cs.iter().skip(1) {
        let rho_words = FlatRq {
            coeffs: std::array::from_fn(|idx| if idx == 0 { pow.as_canonical_u64() } else { 0 }),
        };
        for col in 0..kappa {
            let Some(col_words) = flat_rq_from_commitment_col(c, col) else {
                return Ok(None);
            };
            lhs_batch.push(rho_words);
            rhs_batch.push(col_words);
        }
        pow *= F::from_u64(b as u64);
    }

    let products = match session.rq_mul_batch_u64x54(&lhs_batch, &rhs_batch) {
        Ok(values) => values,
        Err(_) => return Ok(None),
    };

    let mut acc = cs[0].clone();
    for (pair_idx, prod) in products.iter().enumerate() {
        let col = pair_idx % kappa;
        for (dst, src) in acc.col_mut(col).iter_mut().zip(prod.coeffs.iter()) {
            *dst += F::from_u64(*src);
        }
    }

    Ok(Some(acc))
}

pub(crate) fn mix_rhos_commits_with_backend<MR>(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    fallback: MR,
    rhos: &[Mat<F>],
    cs: &[Cmt],
) -> Cmt
where
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt,
{
    match try_mix_rhos_commits_with_mojo(backend_ctx, rhos, cs) {
        Ok(Some(commitment)) => commitment,
        Ok(None) | Err(_) => fallback(rhos, cs),
    }
}

pub(crate) fn combine_b_pows_with_backend<MB>(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    fallback: MB,
    cs: &[Cmt],
    b: u32,
) -> Cmt
where
    MB: Fn(&[Cmt], u32) -> Cmt,
{
    match try_combine_b_pows_with_mojo(backend_ctx, cs, b) {
        Ok(Some(commitment)) => commitment,
        Ok(None) | Err(_) => fallback(cs, b),
    }
}

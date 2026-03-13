use std::any::Any;

use neo_ajtai::{sample_uniform_rq, seeded_pp_chunk_seeds, AjtaiSModule, Commitment as Cmt};
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::Mat;
use neo_gpu::FlatRq;
use neo_math::{D, F};
use p3_field::{PrimeCharacteristicRing, PrimeField64};
use rand_chacha::rand_core::SeedableRng;
use rand_chacha::ChaCha8Rng;

use crate::PiCcsError;

#[inline]
fn flat_rq_from_mat_col_if_nonzero(mat: &Mat<F>, col: usize) -> Option<FlatRq> {
    if mat.rows() != D || col >= mat.cols() {
        return None;
    }
    let mut coeffs = [0u64; D];
    let mut any_nonzero = false;
    for row in 0..D {
        let value = mat[(row, col)];
        any_nonzero |= value != F::ZERO;
        coeffs[row] = value.as_canonical_u64();
    }
    any_nonzero.then_some(FlatRq { coeffs })
}

fn try_commit_many_seeded_with_mojo(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    committer: &AjtaiSModule,
    zs: &[&Mat<F>],
) -> Result<Option<Vec<Cmt>>, PiCcsError> {
    if zs.is_empty() {
        return Ok(Some(Vec::new()));
    }
    let Some((d, kappa, m, seed)) = committer.global_seeded_params() else {
        return Ok(None);
    };
    if d != D || zs.iter().any(|z| z.rows() != d || z.cols() != m) {
        return Ok(None);
    }
    let total_tasks = zs
        .len()
        .saturating_mul(kappa)
        .saturating_mul(m)
        .saturating_mul(D);
    let session = backend_ctx.aux_session()?;
    if session.is_none() {
        return Ok(None);
    }
    if matches!(
        backend_ctx.commit_many_execution_status(total_tasks),
        neo_reductions::accelerator::BackendExecutionStatus::RustCpu
    ) {
        return Ok(None);
    }
    let session = session.expect("checked is_some above");

    let (chunk_size, chunk_seeds_by_row) = seeded_pp_chunk_seeds(seed, kappa, m);
    let mut out: Vec<Cmt> = (0..zs.len()).map(|_| Cmt::zeros(d, kappa)).collect();

    for (row_idx, chunk_seeds) in chunk_seeds_by_row.iter().enumerate() {
        for (chunk_idx, chunk_seed) in chunk_seeds.iter().copied().enumerate() {
            let start = chunk_idx * chunk_size;
            let end = core::cmp::min(m, start + chunk_size);
            let mut rng = ChaCha8Rng::from_seed(chunk_seed);
            let mut lhs_batch = Vec::new();
            let mut rhs_batch = Vec::new();
            let mut lhs_by_col = Vec::with_capacity(end.saturating_sub(start));
            for _col_idx in start..end {
                lhs_by_col.push(FlatRq {
                    coeffs: sample_uniform_rq(&mut rng).0.map(|x| x.as_canonical_u64()),
                });
            }
            let mut slot_offsets = Vec::with_capacity(zs.len() + 1);
            slot_offsets.push(0u64);
            for z in zs.iter() {
                for (local_col_idx, col_idx) in (start..end).enumerate() {
                    let Some(rhs) = flat_rq_from_mat_col_if_nonzero(z, col_idx) else {
                        continue;
                    };
                    lhs_batch.push(lhs_by_col[local_col_idx]);
                    rhs_batch.push(rhs);
                }
                slot_offsets.push(lhs_batch.len() as u64);
            }

            if lhs_batch.is_empty() {
                continue;
            }

            let products =
                match crate::shard::rq_accumulate_with_backend(session, &lhs_batch, &rhs_batch, &slot_offsets) {
                    Ok(values) => values,
                    Err(err) if backend_ctx.mojo_required() => {
                        return Err(PiCcsError::ProtocolError(format!(
                            "strict Mojo commit_many failed during rq_accumulate: {err}"
                        )))
                    }
                    Err(err) => {
                        backend_ctx.record_aux_backend_failure("Mojo commit_many rq_accumulate failed", &err)?;
                        return Ok(None);
                    }
                };
            for (target_idx, product) in products.into_iter().enumerate() {
                for (dst, src) in out[target_idx]
                    .col_mut(row_idx)
                    .iter_mut()
                    .zip(product.coeffs.into_iter())
                {
                    *dst += F::from_u64(src);
                }
            }
        }
    }

    Ok(Some(out))
}

pub(crate) fn commit_many_with_backend<L>(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    committer: &L,
    zs: &[&Mat<F>],
) -> Result<Vec<Cmt>, PiCcsError>
where
    L: SModuleHomomorphism<F, Cmt> + Sync + Any,
{
    if let Some(ajtai) = (committer as &dyn Any).downcast_ref::<AjtaiSModule>() {
        match try_commit_many_seeded_with_mojo(backend_ctx, ajtai, zs) {
            Ok(Some(commitments)) => return Ok(commitments),
            Ok(None) => {}
            Err(err) => return Err(err),
        }
    }
    Ok(committer.commit_many(zs))
}

use crate::PiCcsError;
use neo_ccs::Mat;
use neo_gpu::FlatRq;
use neo_math::{ring::Rq as RqEl, D, F};
use p3_field::{PrimeCharacteristicRing, PrimeField64};

pub(crate) struct RqColumnTerm<'a> {
    pub lhs: FlatRq,
    pub rhs_cols: &'a [FlatRq],
}

pub(crate) struct SparseRqColumnTerm<'a> {
    pub lhs: FlatRq,
    pub rhs_nonzero_cols: &'a [(usize, FlatRq)],
}

#[inline]
pub(crate) fn flat_rq_is_zero(words: &FlatRq) -> bool {
    words.coeffs.iter().all(|&coeff| coeff == 0)
}

#[inline]
pub(crate) fn rq_from_rot_matrix(mat: &Mat<F>) -> Result<RqEl, PiCcsError> {
    if mat.rows() != D || mat.cols() != D {
        return Err(PiCcsError::InvalidInput(format!(
            "stage8 witness accel: rotation matrix must be {D}x{D} (got {}x{})",
            mat.rows(),
            mat.cols()
        )));
    }
    let mut coeffs = [F::ZERO; D];
    for row in 0..D {
        coeffs[row] = mat[(row, 0)];
    }
    Ok(RqEl(coeffs))
}

#[inline]
pub(crate) fn flat_rq_from_rq(rq: &RqEl) -> FlatRq {
    FlatRq {
        coeffs: rq.0.map(|coeff| coeff.as_canonical_u64()),
    }
}

#[inline]
pub(crate) fn rq_from_flat_rq(words: &FlatRq) -> RqEl {
    RqEl(words.coeffs.map(F::from_u64))
}

#[inline]
pub(crate) fn flat_rq_from_rot_matrix(mat: &Mat<F>) -> Result<FlatRq, PiCcsError> {
    rq_from_rot_matrix(mat).map(|rq| flat_rq_from_rq(&rq))
}

pub(crate) fn flat_rq_from_mat_col_if_nonzero(mat: &Mat<F>, col: usize) -> Option<FlatRq> {
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

pub(crate) fn mat_from_flat_rq_cols(cols: &[FlatRq], width: usize) -> Result<Mat<F>, PiCcsError> {
    if cols.len() != width {
        return Err(PiCcsError::InvalidInput(format!(
            "stage8 witness accel: slot count mismatch (slots={}, width={width})",
            cols.len()
        )));
    }
    let mut row_major = vec![F::ZERO; D * width];
    for (col_idx, col) in cols.iter().enumerate() {
        for row in 0..D {
            row_major[row * width + col_idx] = F::from_u64(col.coeffs[row]);
        }
    }
    Ok(Mat::from_row_major(D, width, row_major))
}

#[inline]
fn allow_stage8_witness_acceleration(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    slot_count: usize,
    pair_count: usize,
) -> bool {
    match backend_ctx.selected_device_api() {
        Some(neo_gpu::DeviceApi::Metal) if slot_count.saturating_mul(pair_count) < 128 => false,
        Some(neo_gpu::DeviceApi::Cuda) if slot_count.saturating_mul(pair_count) < 64 => false,
        Some(_) => {
            backend_ctx.mojo_required()
                || !matches!(
                    backend_ctx.commit_mix_execution_status(slot_count.saturating_mul(pair_count).saturating_mul(D)),
                    neo_reductions::accelerator::BackendExecutionStatus::RustCpu
                )
        }
        None => false,
    }
}

pub(crate) fn try_accumulate_rq_terms_with_backend(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    slot_count: usize,
    terms: &[RqColumnTerm<'_>],
) -> Result<Option<Mat<F>>, PiCcsError> {
    if slot_count == 0 {
        return Ok(Some(Mat::zero(D, 0, F::ZERO)));
    }
    if terms.is_empty() {
        return Ok(Some(Mat::zero(D, slot_count, F::ZERO)));
    }
    if !allow_stage8_witness_acceleration(backend_ctx, slot_count, terms.len()) {
        return Ok(None);
    }
    let Some(session) = backend_ctx.aux_session()? else {
        return Ok(None);
    };

    let mut slot_pairs = vec![Vec::new(); slot_count];
    for term in terms {
        for (col, rhs) in term.rhs_cols.iter().copied().enumerate() {
            if col >= slot_count || flat_rq_is_zero(&rhs) {
                continue;
            }
            slot_pairs[col].push((term.lhs, rhs));
        }
    }
    let mut schedule = crate::shard::RqAccumulateSchedule::new(slot_count);
    for (slot_idx, pairs) in slot_pairs.into_iter().enumerate() {
        schedule.push_slot_pairs(slot_idx, pairs);
    }
    let schedule = schedule.finish();
    if schedule.is_empty() {
        return Ok(Some(Mat::zero(D, slot_count, F::ZERO)));
    }

    let products = match crate::shard::rq_accumulate_schedule_with_backend(session, &schedule) {
        Ok(values) => values,
        Err(err) if backend_ctx.mojo_required() => {
            return Err(PiCcsError::ProtocolError(format!(
                "strict Mojo stage8 witness mix failed during rq_accumulate: {err}"
            )))
        }
        Err(err) => {
            backend_ctx.record_aux_backend_failure("Mojo stage8 witness mix rq_accumulate failed", &err)?;
            return Ok(None);
        }
    };

    Ok(Some(mat_from_flat_rq_cols(products.as_slice(), slot_count)?))
}

pub(crate) fn try_accumulate_sparse_group_rq_terms_with_backend(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    slot_count: usize,
    groups: &[Vec<SparseRqColumnTerm<'_>>],
) -> Result<Option<Vec<Mat<F>>>, PiCcsError> {
    if groups.is_empty() {
        return Ok(Some(Vec::new()));
    }
    if slot_count == 0 {
        return Ok(Some(vec![Mat::zero(D, 0, F::ZERO); groups.len()]));
    }

    let pair_count = groups
        .iter()
        .flat_map(|terms| terms.iter())
        .map(|term| term.rhs_nonzero_cols.len())
        .sum::<usize>();
    let total_slots = slot_count.saturating_mul(groups.len());
    if pair_count == 0 {
        return Ok(Some(vec![Mat::zero(D, slot_count, F::ZERO); groups.len()]));
    }
    if !allow_stage8_witness_acceleration(backend_ctx, total_slots, pair_count) {
        return Ok(None);
    }
    let Some(session) = backend_ctx.aux_session()? else {
        return Ok(None);
    };

    let mut slot_pairs = vec![Vec::new(); total_slots];
    for (group_idx, terms) in groups.iter().enumerate() {
        let slot_base = group_idx.saturating_mul(slot_count);
        for term in terms {
            for &(col_idx, rhs) in term.rhs_nonzero_cols {
                if col_idx >= slot_count {
                    continue;
                }
                slot_pairs[slot_base + col_idx].push((term.lhs, rhs));
            }
        }
    }

    let mut schedule = crate::shard::RqAccumulateSchedule::new(total_slots);
    for (slot_idx, pairs) in slot_pairs.into_iter().enumerate() {
        schedule.push_slot_pairs(slot_idx, pairs);
    }
    let schedule = schedule.finish();
    if schedule.is_empty() {
        return Ok(Some(vec![Mat::zero(D, slot_count, F::ZERO); groups.len()]));
    }

    let products = match crate::shard::rq_accumulate_schedule_with_backend(session, &schedule) {
        Ok(values) => values,
        Err(err) if backend_ctx.mojo_required() => {
            return Err(PiCcsError::ProtocolError(format!(
                "strict Mojo sparse stage8 witness mix failed during rq_accumulate: {err}"
            )))
        }
        Err(err) => {
            backend_ctx.record_aux_backend_failure("Mojo sparse stage8 witness mix rq_accumulate failed", &err)?;
            return Ok(None);
        }
    };

    products
        .chunks(slot_count)
        .map(|chunk| mat_from_flat_rq_cols(chunk, slot_count))
        .collect::<Result<Vec<_>, _>>()
        .map(Some)
}

pub(crate) fn try_accumulate_sparse_rq_terms_with_backend(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    slot_count: usize,
    terms: Vec<SparseRqColumnTerm<'_>>,
) -> Result<Option<Mat<F>>, PiCcsError> {
    let grouped = vec![terms];
    Ok(
        try_accumulate_sparse_group_rq_terms_with_backend(backend_ctx, slot_count, grouped.as_slice())?
            .and_then(|mut mats| mats.pop()),
    )
}

pub(crate) fn try_mix_witness_refs_with_backend(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    group_wits: &[&Mat<F>],
    mix_rhos: &[Mat<F>],
    time_t: usize,
) -> Result<Option<Mat<F>>, PiCcsError> {
    if group_wits.is_empty() || time_t == 0 {
        return Ok(Some(Mat::zero(D, time_t, F::ZERO)));
    }
    let lhs_terms = mix_rhos
        .iter()
        .map(flat_rq_from_rot_matrix)
        .collect::<Result<Vec<_>, _>>()?;
    let rhs_cols = group_wits
        .iter()
        .map(|wit| {
            (0..time_t)
                .map(|col| Ok(flat_rq_from_mat_col_if_nonzero(wit, col).unwrap_or(FlatRq { coeffs: [0u64; D] })))
                .collect::<Result<Vec<_>, PiCcsError>>()
        })
        .collect::<Result<Vec<_>, _>>()?;
    let terms = lhs_terms
        .into_iter()
        .zip(rhs_cols.iter())
        .map(|(lhs, rhs_cols)| RqColumnTerm {
            lhs,
            rhs_cols: rhs_cols.as_slice(),
        })
        .collect::<Vec<_>>();
    try_accumulate_rq_terms_with_backend(backend_ctx, time_t, terms.as_slice())
}

pub(crate) fn try_mix_shared_witness_many_rhos_with_backend(
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    witness: &Mat<F>,
    mix_rhos: &[Mat<F>],
    time_t: usize,
) -> Result<Option<Vec<Mat<F>>>, PiCcsError> {
    if mix_rhos.is_empty() || time_t == 0 {
        return Ok(Some(vec![Mat::zero(D, time_t, F::ZERO); mix_rhos.len()]));
    }
    if !allow_stage8_witness_acceleration(backend_ctx, time_t.saturating_mul(mix_rhos.len()), mix_rhos.len()) {
        return Ok(None);
    }
    let Some(session) = backend_ctx.aux_session()? else {
        return Ok(None);
    };

    let lhs_terms = mix_rhos
        .iter()
        .map(flat_rq_from_rot_matrix)
        .collect::<Result<Vec<_>, _>>()?;
    let rhs_cols = (0..time_t)
        .map(|col| Ok(flat_rq_from_mat_col_if_nonzero(witness, col).unwrap_or(FlatRq { coeffs: [0u64; D] })))
        .collect::<Result<Vec<_>, PiCcsError>>()?;
    let mut schedule = crate::shard::RqAccumulateSchedule::new(time_t.saturating_mul(lhs_terms.len()));
    for lhs in lhs_terms {
        for rhs in rhs_cols.iter().copied() {
            let slot_idx = schedule.slot_offsets().len().saturating_sub(1);
            if flat_rq_is_zero(&rhs) {
                schedule.push_slot_pairs(slot_idx, core::iter::empty());
            } else {
                schedule.push_slot_pairs(slot_idx, core::iter::once((lhs, rhs)));
            }
        }
    }
    let schedule = schedule.finish();
    if schedule.is_empty() {
        return Ok(Some(vec![Mat::zero(D, time_t, F::ZERO); mix_rhos.len()]));
    }

    let products = match crate::shard::rq_accumulate_schedule_with_backend(session, &schedule) {
        Ok(values) => values,
        Err(err) if backend_ctx.mojo_required() => {
            return Err(PiCcsError::ProtocolError(format!(
                "strict Mojo shared-witness mix failed during rq_accumulate: {err}"
            )))
        }
        Err(err) => {
            backend_ctx.record_aux_backend_failure("Mojo shared-witness mix rq_accumulate failed", &err)?;
            return Ok(None);
        }
    };

    products
        .chunks(time_t)
        .map(|chunk| mat_from_flat_rq_cols(chunk, time_t))
        .collect::<Result<Vec<_>, _>>()
        .map(Some)
}

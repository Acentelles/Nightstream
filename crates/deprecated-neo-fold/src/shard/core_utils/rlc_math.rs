use super::*;

#[derive(Clone, Copy, Debug)]
pub(crate) enum RlcLane {
    Main,
    Val,
}

#[inline]
pub(crate) fn balanced_divrem_i64(v: i64, b: i64) -> (i64, i64) {
    debug_assert!(b >= 2);
    let mut r = v % b;
    let mut q = (v - r) / b;
    let half = b / 2;
    if r > half {
        r -= b;
        q += 1;
    } else if r < -half {
        r += b;
        q -= 1;
    }
    (r, q)
}

#[inline]
pub(crate) fn balanced_divrem_i128(v: i128, b: i128) -> (i128, i128) {
    debug_assert!(b >= 2);
    let mut r = v % b;
    let mut q = (v - r) / b;
    let half = b / 2;
    if r > half {
        r -= b;
        q += 1;
    } else if r < -half {
        r += b;
        q -= 1;
    }
    (r, q)
}

#[inline]
pub(crate) fn f_from_i64(x: i64) -> F {
    if x >= 0 {
        F::from_u64(x as u64)
    } else {
        F::ZERO - F::from_u64((-x) as u64)
    }
}

#[inline]
fn balanced_abs_u128(v: F) -> u128 {
    let p = F::ORDER_U64 as u128;
    let u = v.as_canonical_u64() as u128;
    core::cmp::min(u, p.saturating_sub(u))
}

#[inline]
fn min_balanced_digits_for_abs(abs: u128, b: u32) -> Result<usize, PiCcsError> {
    if b < 2 {
        return Err(PiCcsError::InvalidInput(format!("invalid base b={b}")));
    }
    if abs == 0 {
        return Ok(1);
    }
    let base = b as u128;
    let half = (b / 2) as u128;
    if half == 0 {
        return Err(PiCcsError::InvalidInput(format!(
            "invalid balanced digit range for b={b}"
        )));
    }
    let mut k = 0usize;
    let mut place = 1u128;
    let mut geom_sum = 0u128;
    loop {
        k = k
            .checked_add(1)
            .ok_or_else(|| PiCcsError::InvalidInput("k_dec overflow".into()))?;
        geom_sum = geom_sum
            .checked_add(place)
            .ok_or_else(|| PiCcsError::InvalidInput(format!("balanced range overflow for b={b}, k={k}")))?;
        let max_abs = half
            .checked_mul(geom_sum)
            .ok_or_else(|| PiCcsError::InvalidInput(format!("balanced range overflow for b={b}, k={k}")))?;
        if abs <= max_abs {
            return Ok(k);
        }
        place = place
            .checked_mul(base)
            .ok_or_else(|| PiCcsError::InvalidInput(format!("b^k overflow for b={b}, k={k}")))?;
    }
}

/// Lower bound on DEC digit count needed so every entry of `Z` fits in balanced base-`b`.
pub(crate) fn required_dec_digits_for_matrix(params: &NeoParams, z: &Mat<F>) -> Result<usize, PiCcsError> {
    let mut need = 1usize;
    for &v in z.as_slice() {
        let k = min_balanced_digits_for_abs(balanced_abs_u128(v), params.b)?;
        need = core::cmp::max(need, k);
    }
    Ok(need)
}

#[inline]
pub(crate) fn verify_me_y_scalars_canonical(
    me: &CeClaim<Cmt, F, K>,
    _b: u32,
    ccs_m: usize,
    step_idx: usize,
    context: &str,
) -> Result<(), PiCcsError> {
    if me.ct.len() != me.y_ring.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "step {}: {}: y_scalars.len()={} must equal y.len()={}",
            step_idx,
            context,
            me.ct.len(),
            me.y_ring.len()
        )));
    }
    for (j, row) in me.y_ring.iter().enumerate() {
        if row.is_empty() {
            return Err(PiCcsError::InvalidInput(format!(
                "step {}: {}: y[{}].len()={} must be >= 1",
                step_idx,
                context,
                j,
                row.len(),
            )));
        }
        if ccs_m == 0 {
            return Err(PiCcsError::InvalidInput(format!(
                "step {}: {}: invalid ccs_m=0",
                step_idx, context
            )));
        }
        let expect = neo_reductions::common::ct_from_y_digits(row);
        if me.ct[j] != expect {
            return Err(PiCcsError::ProtocolError(format!(
                "step {}: {}: ct[{}] does not match layout-aware CE scalar semantics",
                step_idx, context, j
            )));
        }
    }
    Ok(())
}

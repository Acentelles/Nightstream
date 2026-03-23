use super::*;

pub fn normalize_me_claims(
    me_claims: &mut [CeClaim<Cmt, F, K>],
    ell_n: usize,
    ell_d: usize,
    t: usize,
) -> Result<(), PiCcsError> {
    let y_pad = 1usize << ell_d;
    for (i, me) in me_claims.iter_mut().enumerate() {
        if me.r.len() != ell_n {
            return Err(PiCcsError::InvalidInput(format!(
                "ME[{}] r.len()={}, expected ell_n={}",
                i,
                me.r.len(),
                ell_n
            )));
        }
        if me.y_ring.len() > t {
            return Err(PiCcsError::InvalidInput(format!(
                "ME[{}] y.len()={}, expected <= t={}",
                i,
                me.y_ring.len(),
                t
            )));
        }
        for (j, row) in me.y_ring.iter_mut().enumerate() {
            if row.len() > y_pad {
                return Err(PiCcsError::InvalidInput(format!(
                    "ME[{}] y[{}].len()={}, expected <= {}",
                    i,
                    j,
                    row.len(),
                    y_pad
                )));
            }
            row.resize(y_pad, K::ZERO);
        }
        me.y_ring.resize_with(t, || vec![K::ZERO; y_pad]);
        if me.ct.len() > t {
            return Err(PiCcsError::InvalidInput(format!(
                "ME[{}] y_scalars.len()={}, expected <= t={}",
                i,
                me.ct.len(),
                t
            )));
        }
        me.ct.resize(t, K::ZERO);
    }
    Ok(())
}

pub(crate) fn validate_me_batch_invariants(batch: &[CeClaim<Cmt, F, K>], context: &str) -> Result<(), PiCcsError> {
    if batch.is_empty() {
        return Ok(());
    }
    let me0 = &batch[0];
    let r0 = &me0.r;
    let m_in0 = me0.m_in;
    let y_len0 = me0.y_ring.len();
    let y_row_len0 = me0.y_ring.first().map(|r| r.len()).unwrap_or(0);
    let y_scalars_len0 = me0.ct.len();

    if me0.X.rows() != D {
        return Err(PiCcsError::ProtocolError(format!(
            "{}: ME claim 0 has X.rows()={}, expected D={}",
            context,
            me0.X.rows(),
            D
        )));
    }
    if me0.X.cols() != m_in0 {
        return Err(PiCcsError::ProtocolError(format!(
            "{}: ME claim 0 has X.cols()={}, expected m_in={}",
            context,
            me0.X.cols(),
            m_in0
        )));
    }

    for (i, me) in batch.iter().enumerate().skip(1) {
        if me.r != *r0 {
            return Err(PiCcsError::ProtocolError(format!(
                "{}: ME claim {} has different r than claim 0 (r-alignment required for RLC)",
                context, i
            )));
        }
        if me.m_in != m_in0 {
            return Err(PiCcsError::ProtocolError(format!(
                "{}: ME claim {} has m_in={}, expected {}",
                context, i, me.m_in, m_in0
            )));
        }
        if me.X.rows() != D || me.X.cols() != m_in0 {
            return Err(PiCcsError::ProtocolError(format!(
                "{}: ME claim {} has X shape {}x{}, expected {}x{}",
                context,
                i,
                me.X.rows(),
                me.X.cols(),
                D,
                m_in0
            )));
        }
        if me.y_ring.len() != y_len0 {
            return Err(PiCcsError::ProtocolError(format!(
                "{}: ME claim {} has y.len()={}, expected {}",
                context,
                i,
                me.y_ring.len(),
                y_len0
            )));
        }
        for (j, row) in me.y_ring.iter().enumerate() {
            if row.len() != y_row_len0 {
                return Err(PiCcsError::ProtocolError(format!(
                    "{}: ME claim {} has y[{}].len()={}, expected {}",
                    context,
                    i,
                    j,
                    row.len(),
                    y_row_len0
                )));
            }
        }
        if me.ct.len() != y_scalars_len0 {
            return Err(PiCcsError::ProtocolError(format!(
                "{}: ME claim {} has y_scalars.len()={}, expected {}",
                context,
                i,
                me.ct.len(),
                y_scalars_len0
            )));
        }
    }
    Ok(())
}

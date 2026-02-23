use super::*;
use std::collections::BTreeSet;
use std::sync::Arc;

pub(crate) fn infer_trace_t_len_for_step_instance(
    step: &StepInstanceBundle<Cmt, F, K>,
    trace: &Rv32TraceLayout,
    m_total: Option<usize>,
    ctx: &str,
) -> Result<usize, PiCcsError> {
    if let Some(inst) = step.mem_insts.first() {
        return Ok(inst.steps);
    }
    if let Some(inst) = step
        .lut_insts
        .iter()
        .find(|inst| !matches!(inst.table_spec, Some(LutTableSpec::RiscvOpcodeEventTablePacked { .. })))
    {
        return Ok(inst.steps);
    }

    let m = m_total.ok_or_else(|| {
        PiCcsError::InvalidInput(format!(
            "{ctx}: cannot infer trace t_len from step instance without witness width"
        ))
    })?;
    let m_in = step.mcs_inst.m_in;
    let w = m
        .checked_sub(m_in)
        .ok_or_else(|| PiCcsError::InvalidInput(format!("{ctx}: trace width underflow while inferring t_len")))?;
    if trace.cols == 0 || w % trace.cols != 0 {
        return Err(PiCcsError::InvalidInput(format!(
            "{ctx}: cannot infer RV32 trace t_len (missing mem/lut instances and non-divisible witness width)"
        )));
    }
    let t_len = w / trace.cols;
    if t_len == 0 {
        return Err(PiCcsError::InvalidInput(format!(
            "{ctx}: RV32 trace t_len must be >= 1"
        )));
    }
    Ok(t_len)
}

pub(crate) struct TraceColumnViewSidecar {
    t_len: usize,
    trace_cols: usize,
    cols: Arc<Vec<Vec<F>>>,
}

impl TraceColumnViewSidecar {
    pub(crate) fn from_step(
        step: &StepWitnessBundle<Cmt, F, K>,
        trace: &Rv32TraceLayout,
        ctx: &str,
    ) -> Result<Self, PiCcsError> {
        let sidecar = step.trace_sidecar.clone().ok_or_else(|| {
            PiCcsError::InvalidInput(format!("{ctx}: missing trace column sidecar on step witness bundle"))
        })?;

        if sidecar.trace_cols != trace.cols {
            return Err(PiCcsError::InvalidInput(format!(
                "{ctx}: trace sidecar cols mismatch (have {}, expected trace.cols={})",
                sidecar.trace_cols, trace.cols
            )));
        }
        if sidecar.m_in != step.mcs.0.m_in {
            return Err(PiCcsError::InvalidInput(format!(
                "{ctx}: trace sidecar m_in mismatch (have {}, expected {})",
                sidecar.m_in, step.mcs.0.m_in
            )));
        }
        if sidecar.t_len == 0 {
            return Err(PiCcsError::InvalidInput(format!(
                "{ctx}: trace sidecar t_len must be >= 1"
            )));
        }
        if sidecar.cols.len() != trace.cols {
            return Err(PiCcsError::InvalidInput(format!(
                "{ctx}: trace sidecar column count mismatch (have {}, expected trace.cols={})",
                sidecar.cols.len(),
                trace.cols
            )));
        }
        for (col_id, col) in sidecar.cols.iter().enumerate() {
            if col.len() != sidecar.t_len {
                return Err(PiCcsError::InvalidInput(format!(
                    "{ctx}: trace sidecar column length mismatch at col_id={col_id} (have {}, expected t_len={})",
                    col.len(),
                    sidecar.t_len
                )));
            }
        }

        Ok(Self {
            t_len: sidecar.t_len,
            trace_cols: sidecar.trace_cols,
            cols: sidecar.cols,
        })
    }

    pub(crate) fn decode_cols(
        &self,
        _params: &NeoParams,
        col_ids: &[usize],
        ctx: &str,
    ) -> Result<BTreeMap<usize, Vec<K>>, PiCcsError> {
        let unique_col_ids: BTreeSet<usize> = col_ids.iter().copied().collect();
        let mut decoded = BTreeMap::<usize, Vec<K>>::new();
        for col_id in unique_col_ids {
            if col_id >= self.trace_cols {
                return Err(PiCcsError::InvalidInput(format!(
                    "{ctx}: trace column id out of range (col_id={col_id}, trace_cols={})",
                    self.trace_cols
                )));
            }
            let vals_f = self.cols.get(col_id).ok_or_else(|| {
                PiCcsError::InvalidInput(format!("{ctx}: trace sidecar missing column col_id={col_id}"))
            })?;
            let vals_k = vals_f.iter().copied().map(K::from).collect();
            decoded.insert(col_id, vals_k);
        }
        Ok(decoded)
    }

    #[inline]
    pub(crate) fn t_len(&self) -> usize {
        self.t_len
    }
}

pub(crate) struct TraceColumnSourceWitness {
    view: TraceColumnViewSidecar,
}

impl TraceColumnSourceWitness {
    pub(crate) fn from_step(
        step: &StepWitnessBundle<Cmt, F, K>,
        trace: &Rv32TraceLayout,
        ctx: &str,
    ) -> Result<Self, PiCcsError> {
        Ok(Self {
            view: TraceColumnViewSidecar::from_step(step, trace, ctx)?,
        })
    }

    #[inline]
    pub(crate) fn t_len(&self) -> usize {
        self.view.t_len()
    }

    pub(crate) fn decode_cols(
        &self,
        params: &NeoParams,
        col_ids: &[usize],
        ctx: &str,
    ) -> Result<BTreeMap<usize, Vec<K>>, PiCcsError> {
        self.view.decode_cols(params, col_ids, ctx)
    }
}

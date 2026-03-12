//! Opening and lookup helpers for Route-A memory-sidecar validation.
//!
//! This module owns the logic for:
//! - selecting named time openings by point/column set
//! - validating time-opening coverage
//! - decoding canonical trace and lookup-backed column batches
//! - mapping step instances to logical bus columns

use super::*;

#[inline]
pub(crate) fn named_opening(openings: &BTreeMap<usize, K>, col_id: usize, label: &str) -> Result<K, PiCcsError> {
    openings
        .get(&col_id)
        .copied()
        .ok_or_else(|| PiCcsError::ProtocolError(format!("{label}: missing opening col_id={col_id}")))
}

pub(crate) fn time_openings_for_point(
    openings: &[crate::shard_proof_types::TimePointOpening],
    point: &[K],
    required_col_ids: &[usize],
    label: &str,
) -> Result<Option<BTreeMap<usize, K>>, PiCcsError> {
    if required_col_ids.is_empty() {
        return Ok(Some(BTreeMap::new()));
    }
    let opening = match time_opening_entry_for_point(openings, point, required_col_ids, label)? {
        Some(opening) => opening,
        None => return Ok(None),
    };
    let mut map = BTreeMap::new();
    for (&col_id, &eval) in opening.col_ids.iter().zip(opening.evals.iter()) {
        map.insert(col_id, eval);
    }
    Ok(Some(map))
}

pub(crate) fn time_opening_entry_for_point<'a>(
    openings: &'a [crate::shard_proof_types::TimePointOpening],
    point: &[K],
    required_col_ids: &[usize],
    label: &str,
) -> Result<Option<&'a crate::shard_proof_types::TimePointOpening>, PiCcsError> {
    if required_col_ids.is_empty() {
        return Ok(None);
    }
    let mut required_norm = required_col_ids.to_vec();
    required_norm.sort_unstable();
    if required_norm.windows(2).any(|w| w[0] == w[1]) {
        return Err(PiCcsError::ProtocolError(format!(
            "{label}: required_col_ids contains duplicates"
        )));
    }

    let mut matched: Option<&crate::shard_proof_types::TimePointOpening> = None;
    for opening in openings
        .iter()
        .filter(|opening| opening.point.as_slice() == point)
    {
        if opening.col_ids.len() != opening.evals.len() {
            return Err(PiCcsError::ProtocolError(format!(
                "{label}: malformed time opening (col_ids={}, evals={})",
                opening.col_ids.len(),
                opening.evals.len()
            )));
        }
        let mut opening_norm = opening.col_ids.clone();
        opening_norm.sort_unstable();
        if opening_norm.windows(2).any(|w| w[0] == w[1]) {
            return Err(PiCcsError::ProtocolError(format!(
                "{label}: malformed time opening has duplicate col_ids"
            )));
        }
        if opening_norm != required_norm {
            continue;
        }

        if matched.is_some() {
            return Err(PiCcsError::ProtocolError(format!(
                "{label}: duplicate time openings for the same point/column set"
            )));
        }
        matched = Some(opening);
    }

    Ok(matched)
}

pub(crate) fn require_time_openings_for_point(
    openings: &[crate::shard_proof_types::TimePointOpening],
    point: &[K],
    required_col_ids: &[usize],
    label: &str,
) -> Result<BTreeMap<usize, K>, PiCcsError> {
    time_openings_for_point(openings, point, required_col_ids, label)?.ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "{label}: missing required named time opening for point/column set"
        ))
    })
}

pub(crate) fn require_time_opening_entry_for_point<'a>(
    openings: &'a [crate::shard_proof_types::TimePointOpening],
    point: &[K],
    required_col_ids: &[usize],
    label: &str,
) -> Result<&'a crate::shard_proof_types::TimePointOpening, PiCcsError> {
    time_opening_entry_for_point(openings, point, required_col_ids, label)?.ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "{label}: missing required named time opening for point/column set"
        ))
    })
}

pub(crate) fn require_time_openings_covering_point<'a>(
    openings: &'a [crate::shard_proof_types::TimePointOpening],
    point: &[K],
    required_col_ids: &[usize],
    label: &str,
) -> Result<(&'a crate::shard_proof_types::TimePointOpening, BTreeMap<usize, K>), PiCcsError> {
    if required_col_ids.is_empty() {
        return Err(PiCcsError::InvalidInput(format!(
            "{label}: required_col_ids must be non-empty"
        )));
    }
    let required: BTreeSet<usize> = required_col_ids.iter().copied().collect();
    if required.len() != required_col_ids.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "{label}: required_col_ids contains duplicates"
        )));
    }

    let mut matched: Option<(&crate::shard_proof_types::TimePointOpening, BTreeMap<usize, K>)> = None;
    for opening in openings
        .iter()
        .filter(|opening| opening.point.as_slice() == point)
    {
        if opening.col_ids.len() != opening.evals.len() {
            return Err(PiCcsError::ProtocolError(format!(
                "{label}: malformed time opening (col_ids={}, evals={})",
                opening.col_ids.len(),
                opening.evals.len()
            )));
        }
        let mut map = BTreeMap::new();
        for (&col_id, &eval) in opening.col_ids.iter().zip(opening.evals.iter()) {
            map.insert(col_id, eval);
        }
        if !required.iter().all(|col_id| map.contains_key(col_id)) {
            continue;
        }
        let mut selected = BTreeMap::new();
        for &col_id in &required {
            let eval = *map.get(&col_id).ok_or_else(|| {
                PiCcsError::ProtocolError(format!("{label}: missing opening col_id={col_id} in matched entry"))
            })?;
            selected.insert(col_id, eval);
        }
        if matched.is_some() {
            return Err(PiCcsError::ProtocolError(format!(
                "{label}: multiple covering time openings found for point"
            )));
        }
        matched = Some((opening, selected));
    }

    matched.ok_or_else(|| {
        PiCcsError::ProtocolError(format!(
            "{label}: missing required named time opening covering the requested columns"
        ))
    })
}

pub(crate) fn bus_logical_col_ids_for_step_instance(
    step: &StepInstanceBundle<Cmt, F, K>,
    cpu_bus: &BusLayout,
    label: &str,
) -> Result<Vec<usize>, PiCcsError> {
    let cpu_cols_len = step.time_columns.cpu_cols.len();
    let mem_cols_len = step.time_columns.mem_cols.len();
    let total_cols = cpu_cols_len
        .checked_add(mem_cols_len)
        .ok_or_else(|| PiCcsError::InvalidInput(format!("{label}: cpu_cols + mem_cols overflow")))?;
    if mem_cols_len != cpu_bus.bus_cols {
        return Err(PiCcsError::ProtocolError(format!(
            "{label}: mem_cols.len()={} must equal bus_cols={}",
            mem_cols_len, cpu_bus.bus_cols
        )));
    }
    if step.time_columns.col_ids.len() != total_cols {
        return Err(PiCcsError::ProtocolError(format!(
            "{label}: logical col_id table mismatch (col_ids={}, expected cpu+mem={})",
            step.time_columns.col_ids.len(),
            total_cols
        )));
    }
    Ok(step.time_columns.col_ids[cpu_cols_len..].to_vec())
}

pub(crate) fn infer_rv32_trace_t_len_for_trace_openings(
    step: &StepWitnessBundle<Cmt, F, K>,
    trace: &Rv32TraceLayout,
) -> Result<usize, PiCcsError> {
    let t_len = step.time_columns.t;
    if t_len == 0 {
        return Err(PiCcsError::InvalidInput(
            "booleanity/trace-opening requires canonical time columns with t >= 1".into(),
        ));
    }
    if step.time_columns.cpu_cols.len() < trace.cols {
        return Err(PiCcsError::InvalidInput(format!(
            "booleanity/trace-opening requires canonical RV32 time cpu prefix columns (got {}, expected at least {})",
            step.time_columns.cpu_cols.len(),
            trace.cols
        )));
    }
    Ok(t_len)
}

pub(crate) fn decode_trace_col_values_batch(
    _params: &NeoParams,
    step: &StepWitnessBundle<Cmt, F, K>,
    t_len: usize,
    col_ids: &[usize],
) -> Result<BTreeMap<usize, Vec<K>>, PiCcsError> {
    if step.time_columns.t != t_len || step.time_columns.cpu_cols.is_empty() {
        return Err(PiCcsError::InvalidInput(format!(
            "booleanity/trace-opening requires canonical time CPU columns (time_t={}, cpu_cols={}, expected_t={t_len})",
            step.time_columns.t,
            step.time_columns.cpu_cols.len()
        )));
    }

    let unique_col_ids: BTreeSet<usize> = col_ids.iter().copied().collect();
    let mut decoded = BTreeMap::<usize, Vec<K>>::new();
    for col_id in unique_col_ids {
        let vals = step.time_columns.cpu_cols.get(col_id).ok_or_else(|| {
            PiCcsError::InvalidInput(format!(
                "booleanity/trace-opening: trace col_id {} out of range for time_columns.cpu_cols.len()={}",
                col_id,
                step.time_columns.cpu_cols.len()
            ))
        })?;
        if vals.len() != t_len {
            return Err(PiCcsError::InvalidInput(format!(
                "booleanity/trace-opening: time_columns.cpu_cols[{col_id}].len()={} != t_len={t_len}",
                vals.len()
            )));
        }
        decoded.insert(col_id, vals.iter().copied().map(K::from).collect());
    }

    Ok(decoded)
}

pub(crate) fn decode_lookup_backed_col_values_batch(
    t_len: usize,
    max_cols: usize,
    time_mem_cols: Option<&[Vec<F>]>,
    col_ids: &[usize],
) -> Result<BTreeMap<usize, Vec<K>>, PiCcsError> {
    let mem_cols = time_mem_cols
        .ok_or_else(|| PiCcsError::InvalidInput("decode: canonical time mem columns are required".into()))?;
    if mem_cols.is_empty() {
        return Err(PiCcsError::InvalidInput(
            "decode: canonical time mem columns are required".into(),
        ));
    }

    let unique_col_ids: BTreeSet<usize> = col_ids.iter().copied().collect();
    let mut decoded = BTreeMap::<usize, Vec<K>>::new();
    for col_id in unique_col_ids {
        if col_id >= max_cols {
            return Err(PiCcsError::InvalidInput(format!(
                "decode: decode lookup-backed column out of range (col_id={col_id}, cols={max_cols})"
            )));
        }
        let vals = mem_cols.get(col_id).ok_or_else(|| {
            PiCcsError::InvalidInput(format!(
                "decode: missing time mem column col_id={col_id} (mem_cols={})",
                mem_cols.len()
            ))
        })?;
        if vals.len() != t_len {
            return Err(PiCcsError::InvalidInput(format!(
                "decode: time mem column length mismatch for col_id={col_id} (len={}, t_len={t_len})",
                vals.len()
            )));
        }
        decoded.insert(col_id, vals.iter().copied().map(K::from).collect());
    }
    Ok(decoded)
}

use super::*;

struct DenseCols<T> {
    cols: Vec<Option<Vec<T>>>,
}

impl<T> DenseCols<T> {
    fn from_cols(cols: Vec<Vec<T>>) -> Self {
        Self {
            cols: cols.into_iter().map(Some).collect(),
        }
    }

    fn get(&self, col_id: &usize) -> Option<&Vec<T>> {
        self.cols.get(*col_id).and_then(|v| v.as_ref())
    }

    fn get_mut(&mut self, col_id: &usize) -> Option<&mut Vec<T>> {
        self.cols.get_mut(*col_id).and_then(|v| v.as_mut())
    }

    fn insert(&mut self, col_id: usize, vals: Vec<T>) {
        if col_id >= self.cols.len() {
            self.cols.resize_with(col_id + 1, || None);
        }
        self.cols[col_id] = Some(vals);
    }
}

pub(crate) fn width_lookup_bus_val_cols_witness(
    step: &StepWitnessBundle<Cmt, F, K>,
    t_len: usize,
) -> Result<Vec<usize>, PiCcsError> {
    let width = Rv32WidthSidecarLayout::new();
    let (width_cols, width_lut_slots) = resolve_shared_width_lookup_lut_indices(step, &width)?;
    let mut width_bus_col_by_col: BTreeMap<usize, usize> = BTreeMap::new();
    if step.time_columns.t != t_len || step.time_columns.cpu_cols.is_empty() {
        return Err(PiCcsError::ProtocolError(format!(
            "width(shared): canonical time columns required for width lookup openings (time_t={}, cpu_cols={}, expected_t={t_len})",
            step.time_columns.t,
            step.time_columns.cpu_cols.len()
        )));
    }
    let bus = build_bus_layout_for_step_witness(step, t_len)?;
    if bus.shout_cols.len() != step.lut_instances.len() {
        return Err(PiCcsError::ProtocolError(
            "width(shared): bus shout lane count drift while resolving width lookup columns".into(),
        ));
    }
    for (&width_col_id, &(lut_idx, val_slot)) in width_cols.iter().zip(width_lut_slots.iter()) {
        let inst_cols = bus.shout_cols.get(lut_idx).ok_or_else(|| {
            PiCcsError::ProtocolError("width(shared): missing shout cols for width lookup table".into())
        })?;
        let lane0 = inst_cols.lanes.get(0).ok_or_else(|| {
            PiCcsError::ProtocolError("width(shared): expected one shout lane for width lookup table".into())
        })?;
        let val_col = lane0.vals.get(val_slot).copied().ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "width(shared): width val_slot={} out of range for lut_idx={} (n_vals={})",
                val_slot,
                lut_idx,
                lane0.vals.len()
            ))
        })?;
        let logical_bus_col = time_mem_logical_col_id_for_step(step, val_col, "width(shared)")?;
        width_bus_col_by_col.insert(width_col_id, logical_bus_col);
    }
    let mut out = Vec::with_capacity(width_cols.len());
    for &col_id in width_cols.iter() {
        let bus_col = width_bus_col_by_col.get(&col_id).copied().ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "width(shared): missing width lookup bus val column for width col_id={col_id}"
            ))
        })?;
        out.push(bus_col);
    }
    Ok(out)
}

pub(crate) fn build_route_a_width_time_claims(
    params: &NeoParams,
    step: &StepWitnessBundle<Cmt, F, K>,
    r_cycle: &[K],
) -> Result<WidthResidualTimeClaims, PiCcsError> {
    if rv64_fullword_width_stage_required_for_step_witness(step) {
        return build_route_a_rv64_fullword_time_claims(params, step, r_cycle);
    }
    if !width_stage_required_for_step_witness(step) {
        return Ok((None, None, None, None, None));
    }
    let trace = Rv32TraceLayout::new();
    let width = Rv32WidthSidecarLayout::new();
    let decode = Rv32DecodeSidecarLayout::new();
    let m_in = step.mcs.0.m_in;
    let ell_n = r_cycle.len();
    let t_len = infer_rv32_trace_t_len_for_trace_openings(step, &trace)?;
    if t_len == 0 {
        return Err(PiCcsError::InvalidInput("width: t_len must be >= 1".into()));
    }

    let main_col_ids = [
        trace.active,
        trace.instr_word,
        trace.rd_val,
        trace.ram_rv,
        trace.ram_wv,
        trace.rs2_val,
    ];
    let main_decoded = decode_trace_col_values_batch(params, step, t_len, &main_col_ids)?;
    let width_col_ids = riscv_trace_shared_width_lookup_backed_cols(&width);
    let width_decoded: DenseCols<K> = {
        let width_bus_abs_cols = width_lookup_bus_val_cols_witness(step, t_len)?;
        let bus = build_bus_layout_for_step_witness(step, t_len)?;
        let mut width_bus_val_cols = Vec::with_capacity(width_bus_abs_cols.len());
        for abs_col in width_bus_abs_cols.iter().copied() {
            let local_col = time_mem_local_col_for_step(step, abs_col, "width(shared)")?;
            if local_col >= bus.bus_cols {
                return Err(PiCcsError::ProtocolError(format!(
                    "width(shared): width lookup bus column out of range (local_col={local_col}, bus_cols={})",
                    bus.bus_cols
                )));
            }
            width_bus_val_cols.push(local_col);
        }
        let lookup_vals = decode_lookup_backed_col_values_batch(
            t_len,
            bus.bus_cols,
            Some(&step.time_columns.mem_cols),
            &width_bus_val_cols,
        )?;
        let mut by_col = DenseCols::from_cols(Vec::new());
        for (idx, &col_id) in width_col_ids.iter().enumerate() {
            let bus_col_id = width_bus_val_cols[idx];
            let vals = lookup_vals.get(&bus_col_id).ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "width(shared): missing decoded lookup values for bus_col={bus_col_id}"
                ))
            })?;
            by_col.insert(col_id, vals.clone());
        }
        by_col
    };
    let decode_col_ids: Vec<usize> = core::iter::once(decode.op_load)
        .chain(core::iter::once(decode.op_store))
        .chain(core::iter::once(decode.rd_has_write))
        .chain(core::iter::once(decode.ram_has_read))
        .chain(core::iter::once(decode.ram_has_write))
        .chain(decode.funct3_is.iter().copied())
        .collect();
    let decode_decoded = {
        let instr_vals = main_decoded
            .get(&trace.instr_word)
            .ok_or_else(|| PiCcsError::ProtocolError("width(shared): missing instr_word decode column".into()))?;
        let active_vals = main_decoded
            .get(&trace.active)
            .ok_or_else(|| PiCcsError::ProtocolError("width(shared): missing active decode column".into()))?;
        if instr_vals.len() != t_len || active_vals.len() != t_len {
            return Err(PiCcsError::ProtocolError(format!(
                "width(shared): decoded CPU column lengths drift (instr={}, active={}, t_len={t_len})",
                instr_vals.len(),
                active_vals.len()
            )));
        }
        let mut decoded = DenseCols::from_cols(Vec::new());
        for &col_id in decode_col_ids.iter() {
            decoded.insert(col_id, Vec::with_capacity(t_len));
        }
        for j in 0..t_len {
            let instr_word = decode_k_to_u32(instr_vals[j], "width(shared)/instr_word")?;
            let active = active_vals[j] != K::ZERO;
            let mut row = riscv_decode_lookup_backed_row_from_instr_word(&decode, instr_word, active);
            if !active {
                row.fill(F::ZERO);
            }
            for &col_id in decode_col_ids.iter() {
                decoded
                    .get_mut(&col_id)
                    .ok_or_else(|| PiCcsError::ProtocolError("width(shared): decode map build failed".into()))?
                    .push(K::from(row[col_id]));
            }
        }
        decoded
    };

    #[cfg(debug_assertions)]
    for j in 0..t_len {
        let rd_val = *main_decoded
            .get(&trace.rd_val)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("width(shared): missing rd_val row while validating".into()))?;
        let ram_rv = *main_decoded
            .get(&trace.ram_rv)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("width(shared): missing ram_rv row while validating".into()))?;
        let ram_wv = *main_decoded
            .get(&trace.ram_wv)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("width(shared): missing ram_wv row while validating".into()))?;
        let rs2_val = *main_decoded
            .get(&trace.rs2_val)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("width(shared): missing rs2_val row while validating".into()))?;
        let active = *main_decoded
            .get(&trace.active)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("width(shared): missing active row while validating".into()))?;

        let rd_has_write = *decode_decoded
            .get(&decode.rd_has_write)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("width(shared): missing rd_has_write row while validating".into())
            })?;
        let ram_has_read = *decode_decoded
            .get(&decode.ram_has_read)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("width(shared): missing ram_has_read row while validating".into())
            })?;
        let ram_has_write = *decode_decoded
            .get(&decode.ram_has_write)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("width(shared): missing ram_has_write row while validating".into())
            })?;
        let op_load = *decode_decoded
            .get(&decode.op_load)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("width(shared): missing op_load row while validating".into()))?;
        let op_store = *decode_decoded
            .get(&decode.op_store)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("width(shared): missing op_store row while validating".into()))?;
        let funct3_is = [
            *decode_decoded
                .get(&decode.funct3_is[0])
                .and_then(|v| v.get(j))
                .ok_or_else(|| {
                    PiCcsError::ProtocolError("width(shared): missing funct3_is[0] row while validating".into())
                })?,
            *decode_decoded
                .get(&decode.funct3_is[1])
                .and_then(|v| v.get(j))
                .ok_or_else(|| {
                    PiCcsError::ProtocolError("width(shared): missing funct3_is[1] row while validating".into())
                })?,
            *decode_decoded
                .get(&decode.funct3_is[2])
                .and_then(|v| v.get(j))
                .ok_or_else(|| {
                    PiCcsError::ProtocolError("width(shared): missing funct3_is[2] row while validating".into())
                })?,
            *decode_decoded
                .get(&decode.funct3_is[3])
                .and_then(|v| v.get(j))
                .ok_or_else(|| {
                    PiCcsError::ProtocolError("width(shared): missing funct3_is[3] row while validating".into())
                })?,
            *decode_decoded
                .get(&decode.funct3_is[4])
                .and_then(|v| v.get(j))
                .ok_or_else(|| {
                    PiCcsError::ProtocolError("width(shared): missing funct3_is[4] row while validating".into())
                })?,
            *decode_decoded
                .get(&decode.funct3_is[5])
                .and_then(|v| v.get(j))
                .ok_or_else(|| {
                    PiCcsError::ProtocolError("width(shared): missing funct3_is[5] row while validating".into())
                })?,
            *decode_decoded
                .get(&decode.funct3_is[6])
                .and_then(|v| v.get(j))
                .ok_or_else(|| {
                    PiCcsError::ProtocolError("width(shared): missing funct3_is[6] row while validating".into())
                })?,
            *decode_decoded
                .get(&decode.funct3_is[7])
                .and_then(|v| v.get(j))
                .ok_or_else(|| {
                    PiCcsError::ProtocolError("width(shared): missing funct3_is[7] row while validating".into())
                })?,
        ];
        let ram_rv_q16 = *width_decoded
            .get(&width.ram_rv_q16)
            .and_then(|v| v.get(j))
            .ok_or_else(|| {
                PiCcsError::ProtocolError("width(shared): missing ram_rv_q16 row while validating".into())
            })?;
        let rs2_q16 = *width_decoded
            .get(&width.rs2_q16)
            .and_then(|v| v.get(j))
            .ok_or_else(|| PiCcsError::ProtocolError("width(shared): missing rs2_q16 row while validating".into()))?;
        let mut ram_rv_low_bits = [K::ZERO; 16];
        let mut rs2_low_bits = [K::ZERO; 16];
        for bit in 0..16usize {
            ram_rv_low_bits[bit] = *width_decoded
                .get(&width.ram_rv_low_bit[bit])
                .and_then(|v| v.get(j))
                .ok_or_else(|| {
                    PiCcsError::ProtocolError(format!(
                        "width(shared): missing ram_rv_low_bit[{bit}] row while validating"
                    ))
                })?;
            rs2_low_bits[bit] = *width_decoded
                .get(&width.rs2_low_bit[bit])
                .and_then(|v| v.get(j))
                .ok_or_else(|| {
                    PiCcsError::ProtocolError(format!(
                        "width(shared): missing rs2_low_bit[{bit}] row while validating"
                    ))
                })?;
        }

        let load_flags = [
            op_load * funct3_is[0],
            op_load * funct3_is[4],
            op_load * funct3_is[1],
            op_load * funct3_is[5],
            op_load * funct3_is[2],
        ];
        let load_residuals = width_load_semantics_residuals(
            rd_val,
            ram_rv,
            rd_has_write,
            ram_has_read,
            load_flags,
            ram_rv_q16,
            ram_rv_low_bits,
        );
        if let Some((idx, _)) = load_residuals
            .iter()
            .enumerate()
            .find(|(_, r)| **r != K::ZERO)
        {
            return Err(PiCcsError::ProtocolError(format!(
                "w3/load_semantics residual non-zero at row={j}, idx={idx}, active={active}, op_load={op_load}, funct3_is={:?}, rd_has_write={rd_has_write}, ram_has_read={ram_has_read}",
                funct3_is
            )));
        }

        let store_flags = [
            op_store * funct3_is[0],
            op_store * funct3_is[1],
            op_store * funct3_is[2],
        ];
        let store_residuals = width_store_semantics_residuals(
            ram_wv,
            ram_rv,
            rs2_val,
            rd_has_write,
            ram_has_read,
            ram_has_write,
            store_flags,
            rs2_q16,
            ram_rv_low_bits,
            rs2_low_bits,
        );
        if let Some((idx, _)) = store_residuals
            .iter()
            .enumerate()
            .find(|(_, r)| **r != K::ZERO)
        {
            return Err(PiCcsError::ProtocolError(format!(
                "w3/store_semantics residual non-zero at row={j}, idx={idx}, active={active}, op_store={op_store}, funct3_is={:?}, ram_has_read={ram_has_read}, ram_has_write={ram_has_write}",
                funct3_is
            )));
        }
    }

    let mut main_sparse = BTreeMap::<usize, SparseIdxVec<K>>::new();
    for &col_id in main_col_ids.iter() {
        let vals = main_decoded
            .get(&col_id)
            .ok_or_else(|| PiCcsError::ProtocolError(format!("width missing main decoded column {col_id}")))?;
        main_sparse.insert(col_id, sparse_trace_col_from_values(m_in, ell_n, vals)?);
    }
    let mut width_sparse = BTreeMap::<usize, SparseIdxVec<K>>::new();
    for &col_id in width_col_ids.iter() {
        let vals = width_decoded
            .get(&col_id)
            .ok_or_else(|| PiCcsError::ProtocolError(format!("width missing width decoded column {col_id}")))?;
        width_sparse.insert(col_id, sparse_trace_col_from_values(m_in, ell_n, vals)?);
    }
    let mut decode_sparse = BTreeMap::<usize, SparseIdxVec<K>>::new();
    for &col_id in decode_col_ids.iter() {
        let vals = decode_decoded
            .get(&col_id)
            .ok_or_else(|| PiCcsError::ProtocolError(format!("width missing decode decoded column {col_id}")))?;
        decode_sparse.insert(col_id, sparse_trace_col_from_values(m_in, ell_n, vals)?);
    }

    let main_col = |col_id: usize| -> Result<SparseIdxVec<K>, PiCcsError> {
        main_sparse
            .get(&col_id)
            .cloned()
            .ok_or_else(|| PiCcsError::ProtocolError(format!("width missing main sparse column {col_id}")))
    };
    let width_col = |col_id: usize| -> Result<SparseIdxVec<K>, PiCcsError> {
        width_sparse
            .get(&col_id)
            .cloned()
            .ok_or_else(|| PiCcsError::ProtocolError(format!("width missing width sparse column {col_id}")))
    };
    let decode_col = |col_id: usize| -> Result<SparseIdxVec<K>, PiCcsError> {
        decode_sparse
            .get(&col_id)
            .cloned()
            .ok_or_else(|| PiCcsError::ProtocolError(format!("width missing decode sparse column {col_id}")))
    };

    let bitness_cols: Vec<usize> = width
        .ram_rv_low_bit
        .iter()
        .chain(width.rs2_low_bit.iter())
        .copied()
        .collect();
    let mut bitness_sparse = Vec::with_capacity(bitness_cols.len());
    for &col_id in bitness_cols.iter() {
        bitness_sparse.push(width_col(col_id)?);
    }
    let bitness_weights = width_bitness_weight_vector(r_cycle, bitness_cols.len());
    let bitness_oracle = FormulaOracleSparseTime::new(bitness_sparse, 3, r_cycle, move |vals: &[K]| {
        let mut weighted = K::ZERO;
        for (b, w) in vals.iter().zip(bitness_weights.iter()) {
            weighted += *w * *b * (*b - K::ONE);
        }
        weighted
    });

    let mut quiescence_sparse = Vec::with_capacity(1 + width.cols);
    quiescence_sparse.push(main_col(trace.active)?);
    for &col_id in width_col_ids.iter() {
        quiescence_sparse.push(width_col(col_id)?);
    }
    let quiescence_weights = width_quiescence_weight_vector(r_cycle, width.cols);
    let quiescence_oracle = FormulaOracleSparseTime::new(quiescence_sparse, 3, r_cycle, move |vals: &[K]| {
        let active = vals[0];
        let mut weighted = K::ZERO;
        for (i, w) in quiescence_weights.iter().enumerate() {
            weighted += *w * vals[1 + i];
        }
        (K::ONE - active) * weighted
    });

    let mut load_sparse = Vec::with_capacity(31);
    load_sparse.push(main_col(trace.rd_val)?);
    load_sparse.push(main_col(trace.ram_rv)?);
    load_sparse.push(decode_col(decode.rd_has_write)?);
    load_sparse.push(decode_col(decode.ram_has_read)?);
    load_sparse.push(decode_col(decode.op_load)?);
    load_sparse.push(decode_col(decode.funct3_is[0])?);
    load_sparse.push(decode_col(decode.funct3_is[1])?);
    load_sparse.push(decode_col(decode.funct3_is[2])?);
    load_sparse.push(decode_col(decode.funct3_is[4])?);
    load_sparse.push(decode_col(decode.funct3_is[5])?);
    load_sparse.push(width_col(width.ram_rv_q16)?);
    for &col_id in width.ram_rv_low_bit.iter() {
        load_sparse.push(width_col(col_id)?);
    }
    let load_weights = width_load_weight_vector(r_cycle, 16);
    let load_oracle = FormulaOracleSparseTime::new(load_sparse, 5, r_cycle, move |vals: &[K]| {
        let rd_val = vals[0];
        let ram_rv = vals[1];
        let rd_has_write = vals[2];
        let ram_has_read = vals[3];
        let op_load = vals[4];
        let funct3_is_0 = vals[5];
        let funct3_is_1 = vals[6];
        let funct3_is_2 = vals[7];
        let funct3_is_4 = vals[8];
        let funct3_is_5 = vals[9];
        let ram_rv_q16 = vals[10];
        let load_flags = [
            op_load * funct3_is_0,
            op_load * funct3_is_4,
            op_load * funct3_is_1,
            op_load * funct3_is_5,
            op_load * funct3_is_2,
        ];
        let mut ram_rv_low_bits = [K::ZERO; 16];
        ram_rv_low_bits.copy_from_slice(&vals[11..27]);
        let residuals = width_load_semantics_residuals(
            rd_val,
            ram_rv,
            rd_has_write,
            ram_has_read,
            load_flags,
            ram_rv_q16,
            ram_rv_low_bits,
        );
        let mut weighted = K::ZERO;
        for (r, w) in residuals.iter().zip(load_weights.iter()) {
            weighted += *w * *r;
        }
        weighted
    });

    let mut store_sparse = Vec::with_capacity(45);
    store_sparse.push(main_col(trace.ram_wv)?);
    store_sparse.push(main_col(trace.ram_rv)?);
    store_sparse.push(main_col(trace.rs2_val)?);
    store_sparse.push(decode_col(decode.rd_has_write)?);
    store_sparse.push(decode_col(decode.ram_has_read)?);
    store_sparse.push(decode_col(decode.ram_has_write)?);
    store_sparse.push(decode_col(decode.op_store)?);
    store_sparse.push(decode_col(decode.funct3_is[0])?);
    store_sparse.push(decode_col(decode.funct3_is[1])?);
    store_sparse.push(decode_col(decode.funct3_is[2])?);
    store_sparse.push(width_col(width.rs2_q16)?);
    for &col_id in width.ram_rv_low_bit.iter() {
        store_sparse.push(width_col(col_id)?);
    }
    for &col_id in width.rs2_low_bit.iter() {
        store_sparse.push(width_col(col_id)?);
    }
    let store_weights = width_store_weight_vector(r_cycle, 12);
    let store_oracle = FormulaOracleSparseTime::new(store_sparse, 4, r_cycle, move |vals: &[K]| {
        let ram_wv = vals[0];
        let ram_rv = vals[1];
        let rs2_val = vals[2];
        let rd_has_write = vals[3];
        let ram_has_read = vals[4];
        let ram_has_write = vals[5];
        let op_store = vals[6];
        let funct3_is_0 = vals[7];
        let funct3_is_1 = vals[8];
        let funct3_is_2 = vals[9];
        let rs2_q16 = vals[10];
        let store_flags = [op_store * funct3_is_0, op_store * funct3_is_1, op_store * funct3_is_2];
        let mut ram_rv_low_bits = [K::ZERO; 16];
        ram_rv_low_bits.copy_from_slice(&vals[11..27]);
        let mut rs2_low_bits = [K::ZERO; 16];
        rs2_low_bits.copy_from_slice(&vals[27..43]);
        let residuals = width_store_semantics_residuals(
            ram_wv,
            ram_rv,
            rs2_val,
            rd_has_write,
            ram_has_read,
            ram_has_write,
            store_flags,
            rs2_q16,
            ram_rv_low_bits,
            rs2_low_bits,
        );
        let mut weighted = K::ZERO;
        for (r, w) in residuals.iter().zip(store_weights.iter()) {
            weighted += *w * *r;
        }
        weighted
    });

    Ok((
        Some((Box::new(bitness_oracle), K::ZERO)),
        Some((Box::new(quiescence_oracle), K::ZERO)),
        None,
        Some((Box::new(load_oracle), K::ZERO)),
        Some((Box::new(store_oracle), K::ZERO)),
    ))
}

fn width_lookup_open_map_from_committed_openings(
    step: &StepInstanceBundle<Cmt, F, K>,
    cpu_bus: &BusLayout,
    point: &[K],
    step_time_openings: &[crate::shard_proof_types::TimePointOpening],
    label: &str,
) -> Result<BTreeMap<usize, K>, PiCcsError> {
    let width = Rv32WidthSidecarLayout::new();
    let width_open_cols = riscv_trace_shared_width_lookup_backed_cols(&width);
    let bus_logical_cols = bus_logical_col_ids_for_step_instance(step, cpu_bus, label)?;
    let mut width_col_to_logical = Vec::with_capacity(width_open_cols.len());
    for &col_id in width_open_cols.iter() {
        let table_id = riscv_trace_shared_width_lookup_table_id_for_col(col_id);
        let val_slot = riscv_trace_shared_width_lookup_val_slot_for_col(col_id).ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "{label}: width col_id={col_id} is not part of width lookup transport slot map"
            ))
        })?;
        let lut_idx = step
            .lut_insts
            .iter()
            .position(|inst| inst.table_id == table_id)
            .ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "{label}: missing width lookup table_id={table_id} for col_id={col_id}"
                ))
            })?;
        let inst_cols = cpu_bus
            .shout_cols
            .get(lut_idx)
            .ok_or_else(|| PiCcsError::ProtocolError(format!("{label}: missing shout cols for lut_idx={lut_idx}")))?;
        let lane0 = inst_cols.lanes.first().ok_or_else(|| {
            PiCcsError::ProtocolError(format!("{label}: expected one shout lane for lut_idx={lut_idx}"))
        })?;
        let mem_local_col = lane0.vals.get(val_slot).copied().ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "{label}: width val_slot={} out of range for lut_idx={} (n_vals={})",
                val_slot,
                lut_idx,
                lane0.vals.len()
            ))
        })?;
        let logical_col = bus_logical_cols
            .get(mem_local_col)
            .copied()
            .ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "{label}: bus local col {} out of range (bus_cols={})",
                    mem_local_col,
                    bus_logical_cols.len()
                ))
            })?;
        width_col_to_logical.push((col_id, logical_col));
    }
    let mut required_logical: Vec<usize> = width_col_to_logical
        .iter()
        .map(|(_, logical)| *logical)
        .collect();
    required_logical.sort_unstable();
    required_logical.dedup();
    let (_entry, logical_map) =
        require_time_openings_covering_point(step_time_openings, point, &required_logical, label)?;

    let mut width_open_map = BTreeMap::new();
    for (col_id, logical_col) in width_col_to_logical {
        let v = logical_map.get(&logical_col).copied().ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "{label}: missing logical opening value for logical_col_id={logical_col}"
            ))
        })?;
        width_open_map.insert(col_id, v);
    }
    Ok(width_open_map)
}

pub(crate) fn verify_route_a_width_terminals(
    cpu_bus: &BusLayout,
    step: &StepInstanceBundle<Cmt, F, K>,
    r_time: &[K],
    r_cycle: &[K],
    batched_final_values: &[K],
    claim_plan: &RouteATimeClaimPlan,
    mem_proof: &MemSidecarProof<Cmt, F, K>,
    step_time_openings: &[crate::shard_proof_types::TimePointOpening],
    rv64_fullword_width_stage_from_proof: bool,
) -> Result<(), PiCcsError> {
    let any_w3_claim = claim_plan.width_bitness.is_some()
        || claim_plan.width_quiescence.is_some()
        || claim_plan.width_selector_linkage.is_some()
        || claim_plan.width_load_semantics.is_some()
        || claim_plan.width_store_semantics.is_some();
    if !any_w3_claim {
        return Ok(());
    }

    if rv64_fullword_width_stage_required_for_step_instance(step) || rv64_fullword_width_stage_from_proof {
        return verify_route_a_rv64_fullword_terminals(
            cpu_bus,
            step,
            r_time,
            r_cycle,
            batched_final_values,
            claim_plan,
            mem_proof,
            step_time_openings,
        );
    }

    if mem_proof.trace_opening_me_claims.len() != 1 {
        return Err(PiCcsError::ProtocolError(
            "width requires trace-opening ME openings for shared main-trace terminals".into(),
        ));
    }

    let trace = Rv32TraceLayout::new();
    let width = Rv32WidthSidecarLayout::new();
    let decode = Rv32DecodeSidecarLayout::new();

    let trace_opening_me = &mem_proof.trace_opening_me_claims[0];
    if trace_opening_me.r.as_slice() != r_time {
        return Err(PiCcsError::ProtocolError(
            "width trace-opening ME claim r mismatch (expected r_time)".into(),
        ));
    }
    if trace_opening_me.c != step.mcs_inst.c {
        return Err(PiCcsError::ProtocolError(
            "width trace-opening ME claim commitment mismatch".into(),
        ));
    }
    if trace_opening_me.m_in != step.mcs_inst.m_in {
        return Err(PiCcsError::ProtocolError(
            "width trace-opening ME claim m_in mismatch".into(),
        ));
    }
    let trace_opening_cols = riscv_trace_opening_columns(&trace);
    let (_trace_opening_entry, trace_opening_map) = require_time_openings_covering_point(
        step_time_openings,
        trace_opening_me.r.as_slice(),
        &trace_opening_cols,
        "width trace-opening",
    )?;
    let trace_opening_col =
        |col_id: usize| -> Result<K, PiCcsError> { named_opening(&trace_opening_map, col_id, "width trace-opening") };

    let decode_open_map =
        decode_lookup_open_map_from_committed_openings(step, cpu_bus, r_time, step_time_openings, "width decode")?;
    let decode_open_col =
        |col_id: usize| -> Result<K, PiCcsError> { named_opening(&decode_open_map, col_id, "width decode") };
    let width_open_map =
        width_lookup_open_map_from_committed_openings(step, cpu_bus, r_time, step_time_openings, "width width")?;
    let width_open_col =
        |col_id: usize| -> Result<K, PiCcsError> { named_opening(&width_open_map, col_id, "width width") };

    let active = trace_opening_col(trace.active)?;
    let rd_has_write = decode_open_col(decode.rd_has_write)?;
    let rd_val = trace_opening_col(trace.rd_val)?;
    let ram_has_read = decode_open_col(decode.ram_has_read)?;
    let ram_has_write = decode_open_col(decode.ram_has_write)?;
    let ram_rv = trace_opening_col(trace.ram_rv)?;
    let ram_wv = trace_opening_col(trace.ram_wv)?;
    let rs2_val = trace_opening_col(trace.rs2_val)?;

    let mut ram_rv_low_bits = [K::ZERO; 16];
    let mut rs2_low_bits = [K::ZERO; 16];
    for k in 0..16 {
        ram_rv_low_bits[k] = width_open_col(width.ram_rv_low_bit[k])?;
        rs2_low_bits[k] = width_open_col(width.rs2_low_bit[k])?;
    }
    let ram_rv_q16 = width_open_col(width.ram_rv_q16)?;
    let rs2_q16 = width_open_col(width.rs2_q16)?;
    let funct3_is = [
        decode_open_col(decode.funct3_is[0])?,
        decode_open_col(decode.funct3_is[1])?,
        decode_open_col(decode.funct3_is[2])?,
        decode_open_col(decode.funct3_is[3])?,
        decode_open_col(decode.funct3_is[4])?,
        decode_open_col(decode.funct3_is[5])?,
        decode_open_col(decode.funct3_is[6])?,
        decode_open_col(decode.funct3_is[7])?,
    ];
    let op_load = decode_open_col(decode.op_load)?;
    let op_store = decode_open_col(decode.op_store)?;
    let load_flags = [
        op_load * funct3_is[0],
        op_load * funct3_is[4],
        op_load * funct3_is[1],
        op_load * funct3_is[5],
        op_load * funct3_is[2],
    ];
    let store_flags = [
        op_store * funct3_is[0],
        op_store * funct3_is[1],
        op_store * funct3_is[2],
    ];

    if let Some(claim_idx) = claim_plan.width_bitness {
        if claim_idx >= batched_final_values.len() {
            return Err(PiCcsError::ProtocolError("w3/bitness claim index out of range".into()));
        }
        let mut bitness_open = Vec::with_capacity(32);
        bitness_open.extend_from_slice(&ram_rv_low_bits);
        bitness_open.extend_from_slice(&rs2_low_bits);
        let weights = width_bitness_weight_vector(r_cycle, bitness_open.len());
        let mut weighted = K::ZERO;
        for (b, w) in bitness_open.iter().zip(weights.iter()) {
            weighted += *w * *b * (*b - K::ONE);
        }
        let expected = eq_points(r_time, r_cycle) * weighted;
        if batched_final_values[claim_idx] != expected {
            return Err(PiCcsError::ProtocolError("w3/bitness terminal value mismatch".into()));
        }
    }

    if let Some(claim_idx) = claim_plan.width_quiescence {
        if claim_idx >= batched_final_values.len() {
            return Err(PiCcsError::ProtocolError(
                "w3/quiescence claim index out of range".into(),
            ));
        }
        let mut quiescence_open = vec![ram_rv_q16, rs2_q16];
        quiescence_open.extend_from_slice(&ram_rv_low_bits);
        quiescence_open.extend_from_slice(&rs2_low_bits);
        let weights = width_quiescence_weight_vector(r_cycle, quiescence_open.len());
        let mut weighted = K::ZERO;
        for (v, w) in quiescence_open.iter().zip(weights.iter()) {
            weighted += *w * *v;
        }
        let expected = eq_points(r_time, r_cycle) * (K::ONE - active) * weighted;
        if batched_final_values[claim_idx] != expected {
            return Err(PiCcsError::ProtocolError(
                "w3/quiescence terminal value mismatch".into(),
            ));
        }
    }

    if claim_plan.width_selector_linkage.is_some() {
        return Err(PiCcsError::ProtocolError(
            "w3/selector_linkage must be disabled in reduced width-sidecar mode".into(),
        ));
    }

    if let Some(claim_idx) = claim_plan.width_load_semantics {
        if claim_idx >= batched_final_values.len() {
            return Err(PiCcsError::ProtocolError(
                "w3/load_semantics claim index out of range".into(),
            ));
        }
        let residuals = width_load_semantics_residuals(
            rd_val,
            ram_rv,
            rd_has_write,
            ram_has_read,
            load_flags,
            ram_rv_q16,
            ram_rv_low_bits,
        );
        let weights = width_load_weight_vector(r_cycle, residuals.len());
        let mut weighted = K::ZERO;
        for (r, w) in residuals.iter().zip(weights.iter()) {
            weighted += *w * *r;
        }
        let expected = eq_points(r_time, r_cycle) * weighted;
        if batched_final_values[claim_idx] != expected {
            return Err(PiCcsError::ProtocolError(
                "w3/load_semantics terminal value mismatch".into(),
            ));
        }
    }

    if let Some(claim_idx) = claim_plan.width_store_semantics {
        if claim_idx >= batched_final_values.len() {
            return Err(PiCcsError::ProtocolError(
                "w3/store_semantics claim index out of range".into(),
            ));
        }
        let residuals = width_store_semantics_residuals(
            ram_wv,
            ram_rv,
            rs2_val,
            rd_has_write,
            ram_has_read,
            ram_has_write,
            store_flags,
            rs2_q16,
            ram_rv_low_bits,
            rs2_low_bits,
        );
        let weights = width_store_weight_vector(r_cycle, residuals.len());
        let mut weighted = K::ZERO;
        for (r, w) in residuals.iter().zip(weights.iter()) {
            weighted += *w * *r;
        }
        let expected = eq_points(r_time, r_cycle) * weighted;
        if batched_final_values[claim_idx] != expected {
            return Err(PiCcsError::ProtocolError(
                "w3/store_semantics terminal value mismatch".into(),
            ));
        }
    }

    Ok(())
}

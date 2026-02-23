use super::*;

#[derive(Clone)]
pub(crate) struct ShardProverContext {
    pub ccs_mat_digest: Vec<F>,
    pub ccs_sparse_cache: Option<Arc<SparseCache<F>>>,
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

#[derive(Clone)]
struct SidecarLaneWitness {
    mat: Mat<F>,
    t_len: usize,
    n_cols: usize,
    is_all_zero: bool,
}

#[inline]
fn mat_is_all_zero(mat: &Mat<F>) -> bool {
    mat.as_slice().iter().all(|&x| x == F::ZERO)
}

#[inline]
fn copy_mat_column_into_packed(packed: &mut Mat<F>, src: &Mat<F>, dst_col_start: usize, t_len: usize, d: usize) {
    for rho in 0..d {
        let src_row = src.row(rho);
        let dst_row = packed.row_mut(rho);
        dst_row[dst_col_start..dst_col_start + t_len].copy_from_slice(src_row);
    }
}

fn normalize_or_copy_sidecar_column(
    params: &NeoParams,
    packed: &mut Mat<F>,
    src: &Mat<F>,
    dst_col_start: usize,
    t_len: usize,
    bool_expected: bool,
    ctx: &str,
) -> Result<(), PiCcsError> {
    let d = params.d as usize;
    if src.rows() != d {
        return Err(PiCcsError::InvalidInput(format!(
            "{ctx}: source rows mismatch (rows={}, expected D={d})",
            src.rows()
        )));
    }
    if src.cols() != t_len {
        return Err(PiCcsError::InvalidInput(format!(
            "{ctx}: source cols mismatch (cols={}, expected steps={t_len})",
            src.cols()
        )));
    }

    // Fast path: scalar row-0 columns (builder shape). Fallback: already-decomposed mats.
    let mut scalar_row0 = true;
    for rho in 1..d {
        let row = src.row(rho);
        for &x in row {
            if x != F::ZERO {
                scalar_row0 = false;
                break;
            }
        }
        if !scalar_row0 {
            break;
        }
    }

    if !scalar_row0 {
        copy_mat_column_into_packed(packed, src, dst_col_start, t_len, d);
        return Ok(());
    }

    let row0 = src.row(0);
    if bool_expected {
        let mut all_bool = true;
        for &x in row0 {
            if x != F::ZERO && x != F::ONE {
                all_bool = false;
                break;
            }
        }
        if all_bool {
            let dst_row0 = packed.row_mut(0);
            dst_row0[dst_col_start..dst_col_start + t_len].copy_from_slice(row0);
            return Ok(());
        }
    }

    let half = (params.b / 2) as u64;
    let mut all_small_nonneg = true;
    for &x in row0 {
        if x.as_canonical_u64() > half {
            all_small_nonneg = false;
            break;
        }
    }
    if all_small_nonneg {
        let dst_row0 = packed.row_mut(0);
        dst_row0[dst_col_start..dst_col_start + t_len].copy_from_slice(row0);
        return Ok(());
    }

    let src_norm = neo_memory::ajtai::encode_vector_balanced_to_mat(params, row0);
    copy_mat_column_into_packed(packed, &src_norm, dst_col_start, t_len, d);
    Ok(())
}

fn build_shout_sidecar_lane_witnesses(
    params: &NeoParams,
    step: &StepWitnessBundle<Cmt, F, K>,
) -> Result<Vec<SidecarLaneWitness>, PiCcsError> {
    if step.lut_instances.is_empty() {
        return Ok(Vec::new());
    }

    let d = params.d as usize;
    let m_in = step.mcs.0.m_in;
    if step.mcs.1.Z.rows() != d {
        return Err(PiCcsError::InvalidInput(format!(
            "Shout sidecar: witness rows mismatch (rows={}, expected D={d})",
            step.mcs.1.Z.rows()
        )));
    }

    let mut out = Vec::new();
    for (lut_idx, (inst, wit)) in step.lut_instances.iter().enumerate() {
        if !inst.comms.is_empty() {
            return Err(PiCcsError::InvalidInput(format!(
                "Route-A Shout sidecar requires metadata-only LUT instances (comms must be empty, lut_idx={lut_idx}, table_id={})",
                inst.table_id
            )));
        }
        let lanes = inst.lanes.max(1);
        if lanes != 1 {
            return Err(PiCcsError::InvalidInput(format!(
                "Shout sidecar currently requires lanes=1 (lut_idx={lut_idx}, table_id={}, lanes={})",
                inst.table_id, inst.lanes
            )));
        }
        if inst.steps == 0 {
            return Err(PiCcsError::InvalidInput(format!(
                "Shout sidecar requires steps>=1 (lut_idx={lut_idx}, table_id={})",
                inst.table_id
            )));
        }

        let ell_addr = inst
            .d
            .checked_mul(inst.ell)
            .ok_or_else(|| PiCcsError::InvalidInput("Shout sidecar: d*ell overflow".into()))?;
        let n_cols = ell_addr
            .checked_add(2)
            .ok_or_else(|| PiCcsError::InvalidInput("Shout sidecar: ell_addr+2 overflow".into()))?;
        let packed_cols = packed_sidecar_width(m_in, inst.steps, n_cols, "Shout sidecar")?;
        let mut packed = Mat::zero(d, packed_cols, F::ZERO);
        let mut normalize_or_copy_col = |col_idx: usize, src: &Mat<F>, bool_expected: bool| -> Result<(), PiCcsError> {
            let dst_col_start = m_in
                .checked_add(
                    col_idx
                        .checked_mul(inst.steps)
                        .ok_or_else(|| PiCcsError::InvalidInput("Shout sidecar dst offset overflow".into()))?,
                )
                .ok_or_else(|| PiCcsError::InvalidInput("Shout sidecar dst start overflow".into()))?;
            normalize_or_copy_sidecar_column(
                params,
                &mut packed,
                src,
                dst_col_start,
                inst.steps,
                bool_expected,
                "Shout sidecar",
            )
        };
        if wit.mats.len() == n_cols {
            for (col_idx, src) in wit.mats.iter().enumerate() {
                if src.rows() != d {
                    return Err(PiCcsError::InvalidInput(format!(
                        "Shout sidecar mat rows mismatch (lut_idx={lut_idx}, table_id={}, col_idx={col_idx}, rows={}, expected D={d})",
                        inst.table_id,
                        src.rows()
                    )));
                }
                if src.cols() != inst.steps {
                    return Err(PiCcsError::InvalidInput(format!(
                        "Shout sidecar mat cols mismatch (lut_idx={lut_idx}, table_id={}, col_idx={col_idx}, cols={}, expected steps={})",
                        inst.table_id,
                        src.cols(),
                        inst.steps
                    )));
                }
                let bool_expected = col_idx < ell_addr + 1;
                normalize_or_copy_col(col_idx, src, bool_expected)?;
            }
        } else if wit.mats.is_empty() {
            return Err(PiCcsError::InvalidInput(format!(
                "Shout sidecar witness mats missing at lut_idx={lut_idx}, table_id={} (expected full mats len={n_cols} or compact decode/width len=1)",
                inst.table_id
            )));
        } else if wit.mats.len() == 1 {
            // Compact single-mat fallback is only valid for decode/width lookup families when the
            // value column is identically zero across the shard (inactive lane). Any non-zero
            // entries would require has_lookup/addr-bit witnesses to stay sound.
            let is_decode_or_width = neo_memory::riscv::trace::rv32_is_decode_lookup_table_id(inst.table_id)
                || neo_memory::riscv::trace::rv32_is_width_lookup_table_id(inst.table_id);
            if !is_decode_or_width {
                return Err(PiCcsError::InvalidInput(format!(
                    "Shout sidecar compact single-mat witness is only allowed for decode/width families (lut_idx={lut_idx}, table_id={})",
                    inst.table_id
                )));
            }
            let src = &wit.mats[0];
            if src.rows() != d {
                return Err(PiCcsError::InvalidInput(format!(
                    "Shout sidecar compact mat rows mismatch (lut_idx={lut_idx}, table_id={}, rows={}, expected D={d})",
                    inst.table_id,
                    src.rows()
                )));
            }
            if src.cols() != inst.steps {
                return Err(PiCcsError::InvalidInput(format!(
                    "Shout sidecar compact mat cols mismatch (lut_idx={lut_idx}, table_id={}, cols={}, expected steps={})",
                    inst.table_id,
                    src.cols(),
                    inst.steps
                )));
            }
            let vals = neo_memory::ajtai::decode_vector(params, src);
            if vals.iter().any(|&v| v != F::ZERO) {
                return Err(PiCcsError::InvalidInput(format!(
                    "Shout sidecar compact witness has non-zero values but missing has_lookup/addr bits (lut_idx={lut_idx}, table_id={})",
                    inst.table_id
                )));
            }
            // Keep packed matrix all-zero. This encodes inactive lookup lane safely.
        } else {
            return Err(PiCcsError::InvalidInput(format!(
                "Shout sidecar witness shape mismatch at lut_idx={lut_idx}, table_id={} (mats={}, expected full={n_cols} or compact decode/width len=1)",
                inst.table_id,
                wit.mats.len()
            )));
        }

        let is_all_zero = mat_is_all_zero(&packed);
        out.push(SidecarLaneWitness {
            mat: packed,
            t_len: inst.steps,
            n_cols,
            is_all_zero,
        });
    }

    Ok(out)
}

fn build_twist_sidecar_lane_witnesses(
    params: &NeoParams,
    step: &StepWitnessBundle<Cmt, F, K>,
) -> Result<Vec<SidecarLaneWitness>, PiCcsError> {
    if step.mem_instances.is_empty() {
        return Ok(Vec::new());
    }

    let d = params.d as usize;
    let m_in = step.mcs.0.m_in;

    let mut out = Vec::with_capacity(step.mem_instances.len());
    for (mem_idx, (inst, wit)) in step.mem_instances.iter().enumerate() {
        if !inst.comms.is_empty() {
            return Err(PiCcsError::InvalidInput(format!(
                "Route-A Twist sidecar requires metadata-only MEM instances (comms must be empty, mem_idx={mem_idx}, mem_id={})",
                inst.mem_id
            )));
        }
        let lanes = inst.lanes.max(1);
        if inst.steps == 0 {
            return Err(PiCcsError::InvalidInput(format!(
                "Twist sidecar requires steps>=1 (mem_idx={mem_idx}, mem_id={})",
                inst.mem_id
            )));
        }

        let lane_cols = inst
            .d
            .checked_mul(inst.ell)
            .and_then(|ell_addr| ell_addr.checked_mul(2))
            .and_then(|v| v.checked_add(5))
            .ok_or_else(|| PiCcsError::InvalidInput("Twist sidecar: lane width overflow".into()))?;
        let n_cols = lane_cols
            .checked_mul(lanes)
            .ok_or_else(|| PiCcsError::InvalidInput("Twist sidecar: n_cols overflow".into()))?;
        let packed_cols = packed_sidecar_width(m_in, inst.steps, n_cols, "Twist sidecar")?;
        let mut packed = Mat::zero(d, packed_cols, F::ZERO);
        let ell_addr = inst
            .d
            .checked_mul(inst.ell)
            .ok_or_else(|| PiCcsError::InvalidInput("Twist sidecar: d*ell overflow".into()))?;
        let mut normalize_or_copy_col = |col_idx: usize, src: &Mat<F>| -> Result<(), PiCcsError> {
            let dst_col_start = m_in
                .checked_add(
                    col_idx
                        .checked_mul(inst.steps)
                        .ok_or_else(|| PiCcsError::InvalidInput("Twist sidecar dst offset overflow".into()))?,
                )
                .ok_or_else(|| PiCcsError::InvalidInput("Twist sidecar dst start overflow".into()))?;
            let lane_col = col_idx % lane_cols;
            let bool_expected = lane_col < (2 * ell_addr + 2) || lane_col == (2 * ell_addr + 4);
            normalize_or_copy_sidecar_column(
                params,
                &mut packed,
                src,
                dst_col_start,
                inst.steps,
                bool_expected,
                "Twist sidecar",
            )
        };
        if wit.mats.len() == n_cols {
            for (col_idx, src) in wit.mats.iter().enumerate() {
                if src.rows() != d {
                    return Err(PiCcsError::InvalidInput(format!(
                        "Twist sidecar mat rows mismatch (mem_idx={mem_idx}, mem_id={}, col_idx={col_idx}, rows={}, expected D={d})",
                        inst.mem_id,
                        src.rows()
                    )));
                }
                if src.cols() != inst.steps {
                    return Err(PiCcsError::InvalidInput(format!(
                        "Twist sidecar mat cols mismatch (mem_idx={mem_idx}, mem_id={}, col_idx={col_idx}, cols={}, expected steps={})",
                        inst.mem_id,
                        src.cols(),
                        inst.steps
                    )));
                }
                normalize_or_copy_col(col_idx, src)?;
            }
        } else if wit.mats.is_empty() {
            return Err(PiCcsError::InvalidInput(format!(
                "Twist sidecar witness mats missing at mem_idx={mem_idx}, mem_id={} (expected full mats len={n_cols})",
                inst.mem_id
            )));
        } else {
            return Err(PiCcsError::InvalidInput(format!(
                "Twist sidecar witness shape mismatch at mem_idx={mem_idx}, mem_id={} (mats={}, expected full={n_cols})",
                inst.mem_id,
                wit.mats.len()
            )));
        }

        let is_all_zero = mat_is_all_zero(&packed);
        out.push(SidecarLaneWitness {
            mat: packed,
            t_len: inst.steps,
            n_cols,
            is_all_zero,
        });
    }

    Ok(out)
}

fn build_sidecar_me_claims_from_lane_wits(
    tr: &Poseidon2Transcript,
    params: &NeoParams,
    s: &CcsStructure<F>,
    sidecar_ccs_cache: &mut std::collections::HashMap<usize, CcsStructure<F>>,
    sidecar_committer_cache: &mut std::collections::HashMap<usize, neo_ajtai::AjtaiSModule>,
    m_in: usize,
    r_eval: &[K],
    digest_label: &'static [u8],
    lane_wits: &[SidecarLaneWitness],
    expected_comms: Option<&[Cmt]>,
) -> Result<Vec<MeInstance<Cmt, F, K>>, PiCcsError> {
    let core_t = s.t();
    if lane_wits.is_empty() {
        return Ok(Vec::new());
    }
    if let Some(comms) = expected_comms {
        if comms.len() != lane_wits.len() {
            return Err(PiCcsError::InvalidInput(format!(
                "sidecar claim commitment count mismatch (comms={}, lane_wits={})",
                comms.len(),
                lane_wits.len()
            )));
        }
    } else {
        let mut widths: Vec<usize> = lane_wits.iter().map(|lane| lane.mat.cols()).collect();
        widths.sort_unstable();
        widths.dedup();
        for lane_m in widths {
            ensure_sidecar_pp_for_width(params, lane_m)?;
            let _ = get_or_build_sidecar_committer(sidecar_committer_cache, params, lane_m)?;
        }
    }

    let mut claims = Vec::with_capacity(lane_wits.len());
    for (lane_idx, lane) in lane_wits.iter().enumerate() {
        let lane_m = lane.mat.cols();
        let lane_s = get_or_build_zero_sidecar_ccs(sidecar_ccs_cache, s, lane_m)?;
        let c = if let Some(comms) = expected_comms {
            comms[lane_idx].clone()
        } else {
            let lane_l = get_or_build_sidecar_committer(sidecar_committer_cache, params, lane_m)?;
            lane_l.commit(&lane.mat)
        };
        let mut me = neo_memory::ts_common::mk_me_opening_with_ccs(
            tr,
            digest_label,
            params,
            lane_s,
            &c,
            &lane.mat,
            r_eval,
            m_in,
        )?;

        let col_starts: Vec<usize> = (0..lane.n_cols)
            .map(|col_idx| {
                let col_offset = col_idx
                    .checked_mul(lane.t_len)
                    .ok_or_else(|| PiCcsError::InvalidInput("sidecar lane column offset overflow".into()))?;
                m_in.checked_add(col_offset)
                    .ok_or(PiCcsError::InvalidInput("sidecar lane column start overflow".into()))
            })
            .collect::<Result<_, _>>()?;
        crate::memory_sidecar::cpu_bus::append_col_major_time_openings_to_me_instance(
            params,
            m_in,
            lane.t_len,
            &col_starts,
            core_t,
            &lane.mat,
            &mut me,
        )?;
        claims.push(me);
    }

    Ok(claims)
}

fn commit_sidecar_lane_witnesses(
    params: &NeoParams,
    sidecar_committer_cache: &mut std::collections::HashMap<usize, neo_ajtai::AjtaiSModule>,
    lane_wits: &[SidecarLaneWitness],
) -> Result<Vec<Cmt>, PiCcsError> {
    let mut widths: Vec<usize> = lane_wits
        .iter()
        .filter(|lane| !lane.is_all_zero)
        .map(|lane| lane.mat.cols())
        .collect();
    widths.sort_unstable();
    widths.dedup();
    for m in widths {
        ensure_sidecar_pp_for_width(params, m)?;
        let _ = get_or_build_sidecar_committer(sidecar_committer_cache, params, m)?;
    }

    let mut out = Vec::with_capacity(lane_wits.len());
    let zero_c = Cmt::zeros(D, params.kappa as usize);
    for lane in lane_wits.iter() {
        if lane.is_all_zero {
            // Keep sidecar PP availability consistent for later fold lanes that may
            // require a committer handle at this width, even when commit is skipped.
            ensure_sidecar_pp_for_width(params, lane.mat.cols())?;
            out.push(zero_c.clone());
            continue;
        }
        let lane_l = get_or_build_sidecar_committer(sidecar_committer_cache, params, lane.mat.cols())?;
        out.push(lane_l.commit(&lane.mat));
    }
    Ok(out)
}

fn build_decode_width_sidecar_lane_witness(
    params: &NeoParams,
    step: &StepWitnessBundle<Cmt, F, K>,
    plan: crate::memory_sidecar::memory::RouteALookupSidecarPlan,
) -> Result<Option<SidecarLaneWitness>, PiCcsError> {
    if !plan.include_trace_main {
        return Ok(None);
    }
    let include_decode = plan.include_decode;
    let include_width = plan.include_width;
    let decode_needed = include_decode || include_width;

    let trace = Rv32TraceLayout::new();
    let decode = neo_memory::riscv::trace::Rv32DecodeSidecarLayout::new();
    let width = neo_memory::riscv::trace::Rv32WidthSidecarLayout::new();
    let t_len = crate::memory_sidecar::memory::infer_rv32_trace_t_len_for_wb_wp(step, &trace)?;
    if t_len == 0 {
        return Err(PiCcsError::InvalidInput("lookup sidecar requires t_len >= 1".into()));
    }

    let m_in = step.mcs.0.m_in;
    let trace_main_cols = crate::memory_sidecar::memory::rv32_trace_main_opening_columns(&trace);
    let decoded_trace =
        crate::memory_sidecar::memory::decode_trace_col_values_batch(params, step, t_len, &trace_main_cols)?;
    let active_vals_opt = if decode_needed {
        Some(
            decoded_trace
                .get(&trace.active)
                .ok_or_else(|| PiCcsError::ProtocolError("lookup sidecar: missing active column".into()))?,
        )
    } else {
        None
    };
    let instr_vals_opt = if decode_needed {
        Some(
            decoded_trace
                .get(&trace.instr_word)
                .ok_or_else(|| PiCcsError::ProtocolError("lookup sidecar: missing instr_word column".into()))?,
        )
    } else {
        None
    };
    if let (Some(active_vals), Some(instr_vals)) = (active_vals_opt.as_ref(), instr_vals_opt.as_ref()) {
        if active_vals.len() != t_len || instr_vals.len() != t_len {
            return Err(PiCcsError::ProtocolError(format!(
                "lookup sidecar: decoded active/instr lengths drift (active={}, instr={}, t_len={t_len})",
                active_vals.len(),
                instr_vals.len()
            )));
        }
    }

    let rs2_vals_opt = if include_width {
        Some(
            decoded_trace
                .get(&trace.rs2_val)
                .ok_or_else(|| PiCcsError::ProtocolError("lookup sidecar: missing rs2_val column".into()))?,
        )
    } else {
        None
    };
    let ram_rv_vals_opt = if include_width {
        Some(
            decoded_trace
                .get(&trace.ram_rv)
                .ok_or_else(|| PiCcsError::ProtocolError("lookup sidecar: missing ram_rv column".into()))?,
        )
    } else {
        None
    };
    if let (Some(rs2_vals), Some(ram_rv_vals)) = (rs2_vals_opt, ram_rv_vals_opt) {
        if rs2_vals.len() != t_len || ram_rv_vals.len() != t_len {
            return Err(PiCcsError::ProtocolError(format!(
                "lookup sidecar: decoded rs2/ram_rv lengths drift (rs2={}, ram_rv={}, t_len={t_len})",
                rs2_vals.len(),
                ram_rv_vals.len()
            )));
        }
    }

    let decode_col_ids = if include_decode {
        neo_memory::riscv::trace::rv32_decode_lookup_backed_cols(&decode)
    } else {
        Vec::new()
    };
    let width_col_ids = if include_width {
        neo_memory::riscv::trace::rv32_width_lookup_backed_cols(&width)
    } else {
        Vec::new()
    };
    let n_cols = trace_main_cols
        .len()
        .checked_add(decode_col_ids.len())
        .and_then(|v| v.checked_add(width_col_ids.len()))
        .ok_or_else(|| PiCcsError::InvalidInput("lookup sidecar: n_cols overflow".into()))?;
    let packed_cols = packed_sidecar_width(m_in, t_len, n_cols, "lookup sidecar")?;

    let mut col_vals = vec![vec![F::ZERO; t_len]; n_cols];
    for (idx, &col_id) in trace_main_cols.iter().enumerate() {
        let vals = decoded_trace
            .get(&col_id)
            .ok_or_else(|| PiCcsError::ProtocolError(format!("lookup sidecar: missing trace column {col_id}")))?;
        if vals.len() != t_len {
            return Err(PiCcsError::ProtocolError(format!(
                "lookup sidecar: trace column length drift for col_id={col_id} (len={}, t_len={t_len})",
                vals.len()
            )));
        }
        for j in 0..t_len {
            col_vals[idx][j] =
                crate::memory_sidecar::memory::decode_k_to_base_f(vals[j], "lookup sidecar/trace_open_col")?;
        }
    }
    let decode_base = trace_main_cols.len();
    let width_base = decode_base
        .checked_add(decode_col_ids.len())
        .ok_or_else(|| PiCcsError::InvalidInput("lookup sidecar width base overflow".into()))?;
    for j in 0..t_len {
        if decode_needed {
            let active_vals = active_vals_opt.ok_or_else(|| {
                PiCcsError::ProtocolError("lookup sidecar: active column missing while decode is enabled".into())
            })?;
            let instr_vals = instr_vals_opt.ok_or_else(|| {
                PiCcsError::ProtocolError("lookup sidecar: instr column missing while decode is enabled".into())
            })?;
            let active = active_vals[j] != K::ZERO;
            let instr_word =
                crate::memory_sidecar::memory::decode_k_to_u32(instr_vals[j], "lookup sidecar/instr_word")?;

            let mut decode_row =
                neo_memory::riscv::trace::rv32_decode_lookup_backed_row_from_instr_word(&decode, instr_word, active);
            if !active {
                decode_row.fill(F::ZERO);
            }
            if include_decode {
                for (idx, &col_id) in decode_col_ids.iter().enumerate() {
                    col_vals[decode_base + idx][j] = decode_row[col_id];
                }
            }

            if include_width {
                let rs2_vals = rs2_vals_opt.ok_or_else(|| {
                    PiCcsError::ProtocolError("lookup sidecar: rs2 column missing while width is enabled".into())
                })?;
                let ram_rv_vals = ram_rv_vals_opt.ok_or_else(|| {
                    PiCcsError::ProtocolError("lookup sidecar: ram_rv column missing while width is enabled".into())
                })?;
                let mut width_row = vec![F::ZERO; width.cols];
                if active {
                    let rs2_u32 =
                        crate::memory_sidecar::memory::decode_k_to_u32(rs2_vals[j], "lookup sidecar/rs2_val")? as u64;
                    width_row[width.rs2_q16] = F::from_u64(rs2_u32 >> 16);
                    for (k, &bit_col) in width.rs2_low_bit.iter().enumerate() {
                        width_row[bit_col] = F::from_u64((rs2_u32 >> k) & 1);
                    }

                    if decode_row[decode.ram_has_read] != F::ZERO {
                        let ram_rv_u32 =
                            crate::memory_sidecar::memory::decode_k_to_u32(ram_rv_vals[j], "lookup sidecar/ram_rv")?
                                as u64;
                        width_row[width.ram_rv_q16] = F::from_u64(ram_rv_u32 >> 16);
                        for (k, &bit_col) in width.ram_rv_low_bit.iter().enumerate() {
                            width_row[bit_col] = F::from_u64((ram_rv_u32 >> k) & 1);
                        }
                    }
                }
                for (w_idx, &col_id) in width_col_ids.iter().enumerate() {
                    col_vals[width_base + w_idx][j] = width_row[col_id];
                }
            }
        }
    }

    let d = params.d as usize;
    let mut packed = Mat::zero(d, packed_cols, F::ZERO);
    for (col_idx, vals) in col_vals.iter().enumerate() {
        let src_norm = neo_memory::ajtai::encode_vector_balanced_to_mat(params, vals);
        let dst_col_start = m_in
            .checked_add(
                col_idx
                    .checked_mul(t_len)
                    .ok_or_else(|| PiCcsError::InvalidInput("lookup sidecar dst offset overflow".into()))?,
            )
            .ok_or_else(|| PiCcsError::InvalidInput("lookup sidecar dst start overflow".into()))?;
        for rho in 0..d {
            let src_row = src_norm.row(rho);
            let dst_row = packed.row_mut(rho);
            dst_row[dst_col_start..dst_col_start + t_len].copy_from_slice(src_row);
        }
    }

    let is_all_zero = mat_is_all_zero(&packed);
    Ok(Some(SidecarLaneWitness {
        mat: packed,
        t_len,
        n_cols,
        is_all_zero,
    }))
}

pub(crate) fn fold_shard_prove_impl<L, MR, MB>(
    collect_val_lane_wits: bool,
    mode: FoldingMode,
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    s_me: &CcsStructure<F>,
    steps: &[StepWitnessBundle<Cmt, F, K>],
    step_idx_offset: usize,
    acc_init: &[MeInstance<Cmt, F, K>],
    acc_wit_init: &[Mat<F>],
    l: &L,
    mixers: CommitMixers<MR, MB>,
    ob: Option<(&crate::output_binding::OutputBindingConfig, &[F])>,
    prover_ctx: Option<&ShardProverContext>,
    mut step_prove_ms_out: Option<&mut Vec<f64>>,
) -> Result<(ShardProof, Vec<Mat<F>>, Vec<Mat<F>>), PiCcsError>
where
    L: SModuleHomomorphism<F, Cmt> + Sync,
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
{
    for (step_idx, step) in steps.iter().enumerate() {
        if step.lut_instances.is_empty() && step.mem_instances.is_empty() {
            continue;
        }
        let shout_ok = step
            .lut_instances
            .iter()
            .all(|(inst, _wit)| inst.comms.is_empty());
        let twist_ok = step
            .mem_instances
            .iter()
            .all(|(inst, _wit)| inst.comms.is_empty());
        let is_shared_step = shout_ok && twist_ok;
        if !is_shared_step {
            return Err(PiCcsError::InvalidInput(format!(
                "step_idx={step_idx} must use shared-bus witness format (Twist/Shout metadata-only instances with empty comms)"
            )));
        }
    }
    tr.append_message(b"shard/cpu_bus_mode", &[1u8]);
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
    let ccs_sparse_cache: Option<Arc<SparseCache<F>>> = if mode_uses_sparse_cache(&mode) {
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
    if mode_uses_sparse_cache(&mode) && ccs_sparse_cache.is_none() {
        return Err(PiCcsError::ProtocolError(
            "missing SparseCache for optimized mode".into(),
        ));
    }
    let k_dec = params.k_rho as usize;
    let ring = ccs::RotRing::goldilocks();

    if acc_init.len() != acc_wit_init.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "acc_init.len()={} != acc_wit_init.len()={}",
            acc_init.len(),
            acc_wit_init.len()
        )));
    }

    // Initialize accumulator
    let mut accumulator = acc_init.to_vec();
    let mut accumulator_wit = acc_wit_init.to_vec();

    let mut step_proofs = Vec::with_capacity(steps.len());
    let mut val_lane_wits: Vec<Mat<F>> = Vec::new();
    let mut prev_twist_decoded: Option<Vec<crate::memory_sidecar::memory::TwistDecodedColsSparse>> = None;
    let mut prev_twist_sidecar_wits: Option<Vec<SidecarLaneWitness>> = None;
    let mut sidecar_ccs_cache = std::collections::HashMap::<usize, CcsStructure<F>>::new();
    let mut sidecar_committer_cache = std::collections::HashMap::<usize, neo_ajtai::AjtaiSModule>::new();
    let mut output_proof: Option<neo_memory::output_check::OutputBindingProof> = None;

    if ob.is_some() && steps.is_empty() {
        return Err(PiCcsError::InvalidInput("output binding requires >= 1 step".into()));
    }

    for (idx, step) in steps.iter().enumerate() {
        let step_idx = step_idx_offset
            .checked_add(idx)
            .ok_or_else(|| PiCcsError::InvalidInput("step index overflow".into()))?;
        let step_start = time_now();
        crate::memory_sidecar::memory::absorb_step_memory_witness(tr, step);

        let include_ob = ob.is_some() && (idx + 1 == steps.len());
        let mut wb_time_claim: Option<crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim> = None;
        let mut wp_time_claim: Option<crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim> = None;
        let mut decode_decode_fields_claim: Option<crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim> = None;
        let mut decode_decode_immediates_claim: Option<crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim> =
            None;
        let mut width_bitness_claim: Option<crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim> = None;
        let mut width_quiescence_claim: Option<crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim> = None;
        let mut width_load_semantics_claim: Option<crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim> = None;
        let mut width_store_semantics_claim: Option<crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim> = None;
        let mut control_next_pc_linear_claim: Option<crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim> = None;
        let mut control_next_pc_control_claim: Option<crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim> =
            None;
        let mut control_branch_semantics_claim: Option<crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim> =
            None;
        let mut control_control_writeback_claim: Option<crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim> =
            None;
        let mut ob_time_claim: Option<crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim> = None;
        let mut ob_r_prime: Option<Vec<K>> = None;

        // Output binding is injected only on the final step, and must run before sampling Route-A `r_time`.
        if include_ob {
            let (cfg, final_memory_state) =
                ob.ok_or_else(|| PiCcsError::InvalidInput("output binding enabled but config missing".into()))?;

            if output_proof.is_some() {
                return Err(PiCcsError::ProtocolError(
                    "output binding already attached (internal error)".into(),
                ));
            }

            if cfg.mem_idx >= step.mem_instances.len() {
                return Err(PiCcsError::InvalidInput("output binding mem_idx out of range".into()));
            }
            let expected_k = 1usize
                .checked_shl(cfg.num_bits as u32)
                .ok_or_else(|| PiCcsError::InvalidInput("output binding: 2^num_bits overflow".into()))?;
            if final_memory_state.len() != expected_k {
                return Err(PiCcsError::InvalidInput(format!(
                    "output binding: final_memory_state.len()={} != 2^num_bits={}",
                    final_memory_state.len(),
                    expected_k
                )));
            }
            let mem_inst = &step.mem_instances[cfg.mem_idx].0;
            if mem_inst.k != expected_k {
                return Err(PiCcsError::InvalidInput(format!(
                    "output binding: cfg.num_bits implies k={}, but mem_inst.k={}",
                    expected_k, mem_inst.k
                )));
            }
            let ell_addr = mem_inst.twist_layout().lanes[0].ell_addr;
            if ell_addr != cfg.num_bits {
                return Err(PiCcsError::InvalidInput(format!(
                    "output binding: cfg.num_bits={}, but twist_layout.ell_addr={}",
                    cfg.num_bits, ell_addr
                )));
            }

            tr.append_message(b"shard/output_binding_start", &(step_idx as u64).to_le_bytes());
            tr.append_u64s(b"output_binding/mem_idx", &[cfg.mem_idx as u64]);
            tr.append_u64s(b"output_binding/num_bits", &[cfg.num_bits as u64]);

            let (output_sc, r_prime) = neo_memory::output_check::generate_output_sumcheck_proof_and_challenges(
                tr,
                cfg.num_bits,
                cfg.program_io.clone(),
                final_memory_state,
            )
            .map_err(|e| PiCcsError::ProtocolError(format!("output sumcheck failed: {e:?}")))?;

            output_proof = Some(neo_memory::output_check::OutputBindingProof { output_sc });
            ob_r_prime = Some(r_prime);
        }

        let (mcs_inst, mcs_wit) = &step.mcs;

        // k = accumulator.len() + 1
        let k = accumulator.len() + 1;
        let lookup_sidecar_plan = crate::memory_sidecar::memory::route_a_lookup_sidecar_plan_for_step_witness(step);
        let shout_sidecar_wits = build_shout_sidecar_lane_witnesses(params, step)?;
        let twist_sidecar_wits = build_twist_sidecar_lane_witnesses(params, step)?;
        let lookup_sidecar_wit = if lookup_sidecar_plan.include_trace_main {
            Some(
                build_decode_width_sidecar_lane_witness(params, step, lookup_sidecar_plan)?.ok_or_else(|| {
                    PiCcsError::ProtocolError("lookup sidecar plan enabled but lane witness is missing".into())
                })?,
            )
        } else {
            None
        };
        let shout_sidecar_comms =
            commit_sidecar_lane_witnesses(params, &mut sidecar_committer_cache, &shout_sidecar_wits)?;
        let twist_sidecar_comms =
            commit_sidecar_lane_witnesses(params, &mut sidecar_committer_cache, &twist_sidecar_wits)?;
        let lookup_sidecar_comm = if let Some(wit) = lookup_sidecar_wit.as_ref() {
            ensure_sidecar_pp_for_width(params, wit.mat.cols())?;
            let lane_l = get_or_build_sidecar_committer(&mut sidecar_committer_cache, params, wit.mat.cols())?;
            Some(lane_l.commit(&wit.mat))
        } else {
            None
        };
        if lookup_sidecar_plan.include_trace_main && (lookup_sidecar_wit.is_none() || lookup_sidecar_comm.is_none()) {
            return Err(PiCcsError::ProtocolError(
                "lookup sidecar plan enabled but witness/commitment precomputation is missing".into(),
            ));
        }

        // --------------------------------------------------------------------
        // Route A: Shared-challenge batched sum-check for time/row rounds.
        // --------------------------------------------------------------------
        //
        // 1) Bind CCS header + ME inputs
        // 2) Sample CCS challenges (α, β, γ) and bind initial sum
        // 3) Build CCS oracle + lazy Twist/Shout oracles
        // 4) Run ONE batched sum-check for the first ell_n rounds (row/time)
        // 5) Finish CCS alone for remaining ell_d Ajtai rounds
        // 6) Emit CCS + memory ME claims at the shared r_time and fold via RLC/DEC

        utils::bind_header_and_instances_with_digest(
            tr,
            params,
            &s,
            core::slice::from_ref(mcs_inst),
            dims,
            &ccs_mat_digest,
        )?;
        utils::bind_me_inputs(tr, &accumulator)?;
        absorb_route_a_sidecar_time_commitments(
            tr,
            step_idx,
            &shout_sidecar_comms,
            &twist_sidecar_comms,
            lookup_sidecar_comm.as_ref(),
        );
        let mut ch = utils::sample_challenges(tr, ell_d, ell)?;
        ch.beta_m = utils::sample_beta_m(tr, ell_m)?;
        let ccs_initial_sum = claimed_initial_sum_from_inputs(&s, &ch, &accumulator);
        tr.append_fields(b"sumcheck/initial_sum", &ccs_initial_sum.as_coeffs());

        // Route A memory checks use a separate transcript-derived cycle point `r_cycle`
        // to form χ_{r_cycle}(t) weights inside their sum-check polynomials.
        let r_cycle: Vec<K> =
            ts::sample_ext_point(tr, b"route_a/r_cycle", b"route_a/cycle/0", b"route_a/cycle/1", ell_n);

        // CCS oracle (engine-selected).
        //
        // Keep the optimized oracle concrete so we can build outputs from its Ajtai precompute.
        let mut ccs_oracle: CcsOracleDispatch<'_> = match mode.clone() {
            FoldingMode::Optimized => {
                let sparse = ccs_sparse_cache
                    .as_ref()
                    .ok_or_else(|| PiCcsError::ProtocolError("missing SparseCache for optimized mode".into()))?;
                CcsOracleDispatch::Optimized(
                    neo_reductions::engines::optimized_engine::oracle::OptimizedOracle::new_with_sparse(
                        &s,
                        params,
                        core::slice::from_ref(mcs_wit),
                        &accumulator_wit,
                        ch.clone(),
                        ell_d,
                        ell_n,
                        d_sc,
                        accumulator.first().map(|mi| mi.r.as_slice()),
                        sparse.clone(),
                    ),
                )
            }
            #[cfg(feature = "paper-exact")]
            FoldingMode::PaperExact => CcsOracleDispatch::PaperExact(
                neo_reductions::engines::paper_exact_engine::oracle::PaperExactOracle::new(
                    &s,
                    params,
                    core::slice::from_ref(mcs_wit),
                    &accumulator_wit,
                    ch.clone(),
                    ell_d,
                    ell_n,
                    d_sc,
                    accumulator.first().map(|mi| mi.r.as_slice()),
                ),
            ),
            #[cfg(feature = "paper-exact")]
            FoldingMode::OptimizedWithCrosscheck(_) => {
                let sparse = ccs_sparse_cache
                    .as_ref()
                    .ok_or_else(|| PiCcsError::ProtocolError("missing SparseCache for optimized mode".into()))?;
                CcsOracleDispatch::Optimized(
                    neo_reductions::engines::optimized_engine::oracle::OptimizedOracle::new_with_sparse(
                        &s,
                        params,
                        core::slice::from_ref(mcs_wit),
                        &accumulator_wit,
                        ch.clone(),
                        ell_d,
                        ell_n,
                        d_sc,
                        accumulator.first().map(|mi| mi.r.as_slice()),
                        sparse.clone(),
                    ),
                )
            }
        };

        let shout_pre =
            crate::memory_sidecar::memory::prove_shout_addr_pre_time(tr, params, step, ell_n, &r_cycle, step_idx)?;

        let twist_pre =
            crate::memory_sidecar::memory::prove_twist_addr_pre_time(tr, params, step, ell_n, &r_cycle)
                .map_err(|e| PiCcsError::ProtocolError(format!("twist addr-pre failed at step_idx={step_idx}: {e}")))?;
        let twist_read_claims: Vec<K> = twist_pre.iter().map(|p| p.read_check_claim_sum).collect();
        let twist_write_claims: Vec<K> = twist_pre.iter().map(|p| p.write_check_claim_sum).collect();
        let mut mem_oracles = crate::memory_sidecar::memory::build_route_a_memory_oracles(
            params, step, ell_n, &r_cycle, &shout_pre, &twist_pre,
        )?;

        let (wb_time_claim_built, wp_time_claim_built) =
            crate::memory_sidecar::memory::build_route_a_wb_wp_time_claims(params, step, &r_cycle)?;
        let wb_wp_required = crate::memory_sidecar::memory::wb_wp_required_for_step_witness(step);
        if wb_wp_required && (wb_time_claim_built.is_none() || wp_time_claim_built.is_none()) {
            return Err(PiCcsError::ProtocolError(
                "WB/WP claims are required in RV32 trace mode but were not built".into(),
            ));
        }
        if let Some((oracle, _claimed_sum)) = wb_time_claim_built {
            wb_time_claim = Some(crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"wb/booleanity",
            });
        }
        if let Some((oracle, _claimed_sum)) = wp_time_claim_built {
            wp_time_claim = Some(crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"wp/quiescence",
            });
        }
        let (decode_decode_fields_built, decode_decode_immediates_built) =
            crate::memory_sidecar::memory::build_route_a_decode_time_claims(params, step, &r_cycle)?;
        let decode_required = crate::memory_sidecar::memory::decode_stage_required_for_step_witness(step);
        if decode_required && (decode_decode_fields_built.is_none() || decode_decode_immediates_built.is_none()) {
            return Err(PiCcsError::ProtocolError(
                "decode stage claims are required in RV32 trace mode but were not built".into(),
            ));
        }
        if let Some((oracle, _claimed_sum)) = decode_decode_fields_built {
            decode_decode_fields_claim = Some(crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"decode/fields",
            });
        }
        if let Some((oracle, _claimed_sum)) = decode_decode_immediates_built {
            decode_decode_immediates_claim = Some(crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"decode/immediates",
            });
        }
        let (
            width_bitness_built,
            width_quiescence_built,
            _width_selector_linkage_built,
            width_load_semantics_built,
            width_store_semantics_built,
        ) = crate::memory_sidecar::memory::build_route_a_width_time_claims(params, step, &r_cycle)?;
        let width_required = crate::memory_sidecar::memory::width_stage_required_for_step_witness(step);
        if width_required
            && (width_bitness_built.is_none()
                || width_quiescence_built.is_none()
                || width_load_semantics_built.is_none()
                || width_store_semantics_built.is_none())
        {
            return Err(PiCcsError::ProtocolError(
                "width stage claims are required in RV32 trace mode but were not built".into(),
            ));
        }
        if let Some((oracle, _claimed_sum)) = width_bitness_built {
            width_bitness_claim = Some(crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"width/bitness",
            });
        }
        if let Some((oracle, _claimed_sum)) = width_quiescence_built {
            width_quiescence_claim = Some(crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"width/quiescence",
            });
        }
        if let Some((oracle, _claimed_sum)) = width_load_semantics_built {
            width_load_semantics_claim = Some(crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"width/load_semantics",
            });
        }
        if let Some((oracle, _claimed_sum)) = width_store_semantics_built {
            width_store_semantics_claim = Some(crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"width/store_semantics",
            });
        }
        let (
            control_next_pc_linear_built,
            control_next_pc_control_built,
            control_branch_semantics_built,
            control_control_writeback_built,
        ) = crate::memory_sidecar::memory::build_route_a_control_time_claims(params, step, &r_cycle)?;
        let control_required = crate::memory_sidecar::memory::control_stage_required_for_step_witness(step);
        if control_required
            && (control_next_pc_linear_built.is_none()
                || control_next_pc_control_built.is_none()
                || control_branch_semantics_built.is_none()
                || control_control_writeback_built.is_none())
        {
            return Err(PiCcsError::ProtocolError(
                "control stage claims are required in RV32 trace mode but were not built".into(),
            ));
        }
        if let Some((oracle, _claimed_sum)) = control_next_pc_linear_built {
            control_next_pc_linear_claim = Some(crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"control/next_pc_linear",
            });
        }
        if let Some((oracle, _claimed_sum)) = control_next_pc_control_built {
            control_next_pc_control_claim = Some(crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"control/next_pc_control",
            });
        }
        if let Some((oracle, _claimed_sum)) = control_branch_semantics_built {
            control_branch_semantics_claim = Some(crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"control/branch_semantics",
            });
        }
        if let Some((oracle, _claimed_sum)) = control_control_writeback_built {
            control_control_writeback_claim = Some(crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle,
                claimed_sum: K::ZERO,
                label: b"control/writeback",
            });
        }

        if include_ob {
            let (cfg, _final_memory_state) =
                ob.ok_or_else(|| PiCcsError::InvalidInput("output binding enabled but config missing".into()))?;
            let r_prime = ob_r_prime
                .as_ref()
                .ok_or_else(|| PiCcsError::ProtocolError("output binding r_prime missing".into()))?;
            let pre = twist_pre
                .get(cfg.mem_idx)
                .ok_or_else(|| PiCcsError::ProtocolError("output binding mem_idx out of range for twist_pre".into()))?;

            if pre.decoded.lanes.is_empty() {
                return Err(PiCcsError::ProtocolError(
                    "output binding: Twist decoded lanes empty".into(),
                ));
            }

            let mut oracles: Vec<Box<dyn RoundOracle>> = Vec::with_capacity(pre.decoded.lanes.len());
            let mut claimed_sum = K::ZERO;
            for lane in pre.decoded.lanes.iter() {
                let (oracle, claim) = neo_memory::twist_oracle::TwistTotalIncOracleSparseTime::new(
                    lane.wa_bits.clone(),
                    lane.has_write.clone(),
                    lane.inc_at_write_addr.clone(),
                    r_prime,
                );
                oracles.push(Box::new(oracle));
                claimed_sum += claim;
            }
            let oracle = crate::memory_sidecar::memory::SumRoundOracle::new(oracles);

            ob_time_claim = Some(crate::memory_sidecar::route_a_time::ExtraBatchedTimeClaim {
                oracle: Box::new(oracle),
                claimed_sum,
                label: crate::output_binding::OB_INC_TOTAL_LABEL,
            });
        }

        let crate::memory_sidecar::route_a_time::RouteABatchedTimeProverOutput {
            r_time,
            per_claim_results,
            proof: batched_time,
        } = crate::memory_sidecar::route_a_time::prove_route_a_batched_time(
            tr,
            step_idx,
            ell_n,
            d_sc,
            ccs_initial_sum,
            &mut ccs_oracle,
            &mut mem_oracles,
            step,
            twist_read_claims,
            twist_write_claims,
            wb_time_claim,
            wp_time_claim,
            decode_decode_fields_claim,
            decode_decode_immediates_claim,
            width_bitness_claim,
            width_quiescence_claim,
            None,
            width_load_semantics_claim,
            width_store_semantics_claim,
            control_next_pc_linear_claim,
            control_next_pc_control_claim,
            control_branch_semantics_claim,
            control_control_writeback_claim,
            ob_time_claim,
        )?;

        // Finish CCS Ajtai rounds alone, continuing from the CCS oracle state after ell_n folds.
        let ccs_time_rounds = per_claim_results
            .first()
            .map(|r| r.round_polys.clone())
            .unwrap_or_default();
        let mut sumcheck_rounds = ccs_time_rounds;
        let mut sumcheck_chals = r_time.clone();
        let ajtai_initial_sum = per_claim_results
            .first()
            .map(|r| r.final_value)
            .unwrap_or(ccs_initial_sum);

        let mut ccs_ajtai = RoundOraclePrefix::new(&mut ccs_oracle, ell_d);
        let (ajtai_rounds, ajtai_chals) =
            run_sumcheck_prover_ds(tr, b"ccs/ajtai", step_idx, &mut ccs_ajtai, ajtai_initial_sum)?;
        let mut running_sum = ajtai_initial_sum;
        for (round_poly, &r_i) in ajtai_rounds.iter().zip(ajtai_chals.iter()) {
            running_sum = poly_eval_k(round_poly, r_i);
        }
        sumcheck_rounds.extend_from_slice(&ajtai_rounds);
        sumcheck_chals.extend_from_slice(&ajtai_chals);

        // --------------------------------------------------------------------
        // NC-only sumcheck (digit-range / norm-check) over {0,1}^{ell_m + ell_d}.
        // --------------------------------------------------------------------
        let mut ccs_nc_oracle = neo_reductions::engines::optimized_engine::oracle::NcOracle::new(
            &s,
            params,
            core::slice::from_ref(mcs_wit),
            &accumulator_wit,
            ch.clone(),
            ell_d,
            ell_m,
            d_sc,
        );
        let (sumcheck_rounds_nc, sumcheck_chals_nc) =
            run_sumcheck_prover_ds(tr, b"ccs/nc", step_idx, &mut ccs_nc_oracle, K::ZERO)?;
        let mut running_sum_nc = K::ZERO;
        for (round_poly, &r_i) in sumcheck_rounds_nc.iter().zip(sumcheck_chals_nc.iter()) {
            running_sum_nc = poly_eval_k(round_poly, r_i);
        }
        let (s_col, _alpha_prime_nc) = sumcheck_chals_nc.split_at(ell_m);

        // Build CCS ME outputs at r_time.
        let fold_digest = tr.digest32();
        let mut ccs_out = match &mut ccs_oracle {
            CcsOracleDispatch::Optimized(oracle) => oracle.build_me_outputs_from_ajtai_precomp(
                core::slice::from_ref(mcs_inst),
                &accumulator,
                s_col,
                fold_digest,
                l,
            ),
            #[cfg(feature = "paper-exact")]
            CcsOracleDispatch::PaperExact(_) => build_me_outputs_paper_exact(
                &s,
                params,
                core::slice::from_ref(mcs_inst),
                core::slice::from_ref(mcs_wit),
                &accumulator,
                &accumulator_wit,
                &r_time,
                s_col,
                ell_d,
                fold_digest,
                l,
            ),
        };

        // CCS oracle borrows accumulator_wit; drop before updating accumulator_wit at the end.
        drop(ccs_oracle);

        let trace_linkage_t_len: Option<usize> = None;

        // Shared CPU bus: append "implicit openings" for all bus columns without materializing
        // bus copyout matrices into the CCS.
        if cpu_bus.bus_cols > 0 {
            let core_t = s.t();
            if ccs_out.len() != 1 + accumulator_wit.len() {
                return Err(PiCcsError::ProtocolError(format!(
                    "CCS output count mismatch for bus openings (ccs_out.len()={}, expected {})",
                    ccs_out.len(),
                    1 + accumulator_wit.len()
                )));
            }

            crate::memory_sidecar::cpu_bus::append_bus_openings_to_me_instance(
                params,
                &cpu_bus,
                core_t,
                &mcs_wit.Z,
                &mut ccs_out[0],
            )?;
            for (out, Z) in ccs_out.iter_mut().skip(1).zip(accumulator_wit.iter()) {
                crate::memory_sidecar::cpu_bus::append_bus_openings_to_me_instance(params, &cpu_bus, core_t, Z, out)?;
            }
        }

        // Trace linkage openings now come from the lookup sidecar ME claim instead of
        // appending flattened trace openings onto `ccs_out`.

        if ccs_out.len() != k {
            return Err(PiCcsError::ProtocolError(format!(
                "Π_CCS returned {} outputs; expected k={k}",
                ccs_out.len()
            )));
        }

        let mut ccs_proof = crate::PiCcsProof::new(sumcheck_rounds, Some(ccs_initial_sum));
        ccs_proof.variant = crate::optimized_engine::PiCcsProofVariant::SplitNcV1;
        ccs_proof.sumcheck_challenges = sumcheck_chals;
        ccs_proof.sumcheck_rounds_nc = sumcheck_rounds_nc;
        ccs_proof.sc_initial_sum_nc = Some(K::ZERO);
        ccs_proof.sumcheck_challenges_nc = sumcheck_chals_nc;
        ccs_proof.challenges_public = ch;
        ccs_proof.sumcheck_final = running_sum;
        ccs_proof.sumcheck_final_nc = running_sum_nc;
        ccs_proof.header_digest = fold_digest.to_vec();

        #[cfg(feature = "paper-exact")]
        if let FoldingMode::OptimizedWithCrosscheck(cfg) = &mode {
            crosscheck_route_a_ccs_step(
                cfg,
                step_idx,
                params,
                &s,
                &cpu_bus,
                mcs_inst,
                mcs_wit,
                &accumulator,
                &accumulator_wit,
                &ccs_out,
                &ccs_proof,
                ell_d,
                ell_n,
                ell_m,
                d_sc,
                fold_digest,
                l,
            )?;
        }

        // Witnesses for CCS outputs: [Z_mcs, Z_seed...] (borrow; avoid multi-GB clones)
        let mut outs_Z: Vec<&Mat<F>> = Vec::with_capacity(k);
        outs_Z.push(&mcs_wit.Z);
        outs_Z.extend(accumulator_wit.iter());

        // Memory sidecar: emit ME claims at the shared r_time (no fixed-challenge sumcheck).
        let prev_step = (idx > 0).then(|| &steps[idx - 1]);
        let has_prev = prev_step.is_some();
        let prev_twist_decoded_ref = prev_twist_decoded.as_deref();
        let prev_twist_sidecar_comms = if has_prev {
            let prev_wits = prev_twist_sidecar_wits
                .as_ref()
                .ok_or_else(|| PiCcsError::ProtocolError("missing prev Twist sidecar witnesses for rollover".into()))?;
            commit_sidecar_lane_witnesses(params, &mut sidecar_committer_cache, prev_wits)?
        } else {
            Vec::new()
        };
        absorb_route_a_sidecar_val_commitments(tr, step_idx, &twist_sidecar_comms, &prev_twist_sidecar_comms);
        let mut mem_proof = crate::memory_sidecar::memory::finalize_route_a_memory_prover(
            tr,
            params,
            &cpu_bus,
            &s,
            step,
            prev_step,
            prev_twist_decoded_ref,
            &mut mem_oracles,
            &shout_pre.addr_pre,
            &twist_pre,
            &r_time,
            mcs_inst.m_in,
            step_idx,
        )?;
        prev_twist_decoded = Some(twist_pre.into_iter().map(|p| p.decoded).collect());
        let mut sidecar_wits = shout_sidecar_wits.clone();
        let mut sidecar_me_claims = build_sidecar_me_claims_from_lane_wits(
            tr,
            params,
            &s,
            &mut sidecar_ccs_cache,
            &mut sidecar_committer_cache,
            step.mcs.0.m_in,
            &r_time,
            b"shout/sidecar/me_digest_time",
            &shout_sidecar_wits,
            Some(&shout_sidecar_comms),
        )?;
        let twist_sidecar_me_claims = build_sidecar_me_claims_from_lane_wits(
            tr,
            params,
            &s,
            &mut sidecar_ccs_cache,
            &mut sidecar_committer_cache,
            step.mcs.0.m_in,
            &r_time,
            b"twist/sidecar/me_digest_time",
            &twist_sidecar_wits,
            Some(&twist_sidecar_comms),
        )?;
        let mut val_claim_wits: Vec<SidecarLaneWitness> = Vec::new();
        if !step.mem_instances.is_empty() {
            let r_val = mem_proof
                .val_me_claims
                .first()
                .map(|me| me.r.clone())
                .ok_or_else(|| PiCcsError::ProtocolError("missing r_val CPU placeholder claim".into()))?;

            let mut val_sidecar_claims = build_sidecar_me_claims_from_lane_wits(
                tr,
                params,
                &s,
                &mut sidecar_ccs_cache,
                &mut sidecar_committer_cache,
                step.mcs.0.m_in,
                &r_val,
                b"twist/sidecar/me_digest_val",
                &twist_sidecar_wits,
                Some(&twist_sidecar_comms),
            )?;
            val_claim_wits.extend(twist_sidecar_wits.iter().cloned());

            if has_prev {
                let prev_wits = prev_twist_sidecar_wits.as_ref().ok_or_else(|| {
                    PiCcsError::ProtocolError("missing prev Twist sidecar witnesses for rollover".into())
                })?;
                if prev_wits.len() != step.mem_instances.len() {
                    return Err(PiCcsError::ProtocolError(format!(
                        "Twist prev sidecar witness count mismatch (have {}, expected {})",
                        prev_wits.len(),
                        step.mem_instances.len()
                    )));
                }
                let prev_claims = build_sidecar_me_claims_from_lane_wits(
                    tr,
                    params,
                    &s,
                    &mut sidecar_ccs_cache,
                    &mut sidecar_committer_cache,
                    step.mcs.0.m_in,
                    &r_val,
                    b"twist/sidecar/me_digest_val",
                    prev_wits,
                    Some(&prev_twist_sidecar_comms),
                )?;
                val_sidecar_claims.extend(prev_claims);
                val_claim_wits.extend(prev_wits.iter().cloned());
            }
            mem_proof.val_me_claims = val_sidecar_claims;
        } else {
            mem_proof.val_me_claims.clear();
        }

        sidecar_me_claims.extend(twist_sidecar_me_claims);
        sidecar_wits.extend(twist_sidecar_wits.iter().cloned());
        if let (Some(lookup_wit), Some(lookup_comm)) = (lookup_sidecar_wit.as_ref(), lookup_sidecar_comm.as_ref()) {
            let lookup_claims = build_sidecar_me_claims_from_lane_wits(
                tr,
                params,
                &s,
                &mut sidecar_ccs_cache,
                &mut sidecar_committer_cache,
                step.mcs.0.m_in,
                &r_time,
                b"lookup/sidecar/me_digest_time",
                core::slice::from_ref(lookup_wit),
                Some(core::slice::from_ref(lookup_comm)),
            )?;
            if lookup_claims.len() != 1 {
                return Err(PiCcsError::ProtocolError(format!(
                    "lookup sidecar expected exactly one ME claim, got {}",
                    lookup_claims.len()
                )));
            }
            sidecar_me_claims.extend(lookup_claims);
            sidecar_wits.push(lookup_wit.clone());
        }
        mem_proof.sidecar_me_claims = sidecar_me_claims;
        prev_twist_sidecar_wits = Some(twist_sidecar_wits);

        // Normalize ME claim shapes for per-claim folding lanes.
        for me in mem_proof.val_me_claims.iter_mut() {
            let t = me.y.len();
            normalize_me_claims(core::slice::from_mut(me), ell_n, ell_d, t)?;
        }
        for me in mem_proof.sidecar_me_claims.iter_mut() {
            let t = me.y.len();
            normalize_me_claims(core::slice::from_mut(me), ell_n, ell_d, t)?;
        }

        validate_me_batch_invariants(&ccs_out, "prove step ccs outputs")?;

        let want_main_wits = collect_val_lane_wits || idx + 1 < steps.len();
        let (main_fold, Z_split) = prove_rlc_dec_lane(
            &mode,
            RlcLane::Main,
            tr,
            params,
            &s,
            ccs_sparse_cache.as_deref(),
            Some(&cpu_bus),
            &ring,
            ell_d,
            k_dec,
            step_idx,
            trace_linkage_t_len,
            &ccs_out,
            &outs_Z,
            want_main_wits,
            l,
            mixers,
        )?;
        let RlcDecProof {
            rlc_rhos: rhos,
            rlc_parent: parent_pub,
            dec_children: children,
        } = main_fold;

        // --------------------------------------------------------------------
        // Phase 2: Second folding lane for Twist val-eval ME claims at r_val.
        // --------------------------------------------------------------------
        let mut val_fold: Vec<RlcDecProof> = Vec::new();
        if !mem_proof.val_me_claims.is_empty() {
            tr.append_message(b"fold/val_lane_start", &(step_idx as u64).to_le_bytes());
            let expected = step
                .mem_instances
                .len()
                .checked_mul(1usize + usize::from(has_prev))
                .ok_or_else(|| PiCcsError::ProtocolError("Twist(val) claim count overflow".into()))?;
            if mem_proof.val_me_claims.len() != expected {
                return Err(PiCcsError::ProtocolError(format!(
                    "Twist(val) claim count mismatch (have {}, expected {})",
                    mem_proof.val_me_claims.len(),
                    expected
                )));
            }
            if val_claim_wits.len() != expected {
                return Err(PiCcsError::ProtocolError(format!(
                    "Twist(val) sidecar witness count mismatch (have {}, expected {})",
                    val_claim_wits.len(),
                    expected
                )));
            }

            for (claim_idx, (me, wit)) in mem_proof
                .val_me_claims
                .iter()
                .zip(val_claim_wits.iter())
                .enumerate()
            {
                tr.append_message(b"fold/val_lane_claim_idx", &(claim_idx as u64).to_le_bytes());
                let lane_s = get_or_build_zero_sidecar_ccs(&mut sidecar_ccs_cache, &s, wit.mat.cols())?;
                let lane_l = get_or_build_sidecar_committer(&mut sidecar_committer_cache, params, wit.mat.cols())?;
                let (proof, mut z_split_val) = prove_rlc_dec_lane(
                    &mode,
                    RlcLane::Val,
                    tr,
                    params,
                    lane_s,
                    None,
                    None,
                    &ring,
                    ell_d,
                    k_dec,
                    step_idx,
                    None,
                    core::slice::from_ref(me),
                    &[&wit.mat],
                    collect_val_lane_wits,
                    lane_l,
                    mixers,
                )?;
                if collect_val_lane_wits {
                    if proof.dec_children.len() != z_split_val.len() {
                        return Err(PiCcsError::ProtocolError(format!(
                            "Twist(val) DEC witness count mismatch (children={}, wits={})",
                            proof.dec_children.len(),
                            z_split_val.len()
                        )));
                    }
                    val_lane_wits.extend(z_split_val.drain(..));
                }
                val_fold.push(proof);
            }
        }

        let mut sidecar_fold: Vec<RlcDecProof> = Vec::new();
        if !mem_proof.sidecar_me_claims.is_empty() {
            if mem_proof.sidecar_me_claims.len() != sidecar_wits.len() {
                return Err(PiCcsError::ProtocolError(format!(
                    "Route-A sidecar claim/witness count mismatch (claims={}, wits={})",
                    mem_proof.sidecar_me_claims.len(),
                    sidecar_wits.len()
                )));
            }
            let sidecar_lane_shapes: Vec<(usize, usize)> = sidecar_wits
                .iter()
                .zip(mem_proof.sidecar_me_claims.iter())
                .map(|(wit, me)| (wit.mat.cols(), me.y.len()))
                .collect();
            let sidecar_groups = group_claims_by_lane_shape(&sidecar_lane_shapes, "prove/sidecar-fold")?;
            tr.append_message(b"fold/sidecar_lane_start", &(step_idx as u64).to_le_bytes());
            for (group_idx, group) in sidecar_groups.iter().enumerate() {
                tr.append_message(b"fold/sidecar_lane_group_idx", &(group_idx as u64).to_le_bytes());
                for &claim_idx in group.claim_indices.iter() {
                    tr.append_message(b"fold/sidecar_lane_claim_idx", &(claim_idx as u64).to_le_bytes());
                }
                let lane_s = get_or_build_zero_sidecar_ccs(&mut sidecar_ccs_cache, &s, group.lane_m)?;
                let lane_l = get_or_build_sidecar_committer(&mut sidecar_committer_cache, params, group.lane_m)?;
                let mut me_group = Vec::with_capacity(group.claim_indices.len());
                let mut wit_group: Vec<&Mat<F>> = Vec::with_capacity(group.claim_indices.len());
                for &claim_idx in group.claim_indices.iter() {
                    let me = mem_proof.sidecar_me_claims.get(claim_idx).ok_or_else(|| {
                        PiCcsError::ProtocolError(format!(
                            "Route-A sidecar group index out of range (claim_idx={claim_idx})"
                        ))
                    })?;
                    let wit = sidecar_wits.get(claim_idx).ok_or_else(|| {
                        PiCcsError::ProtocolError(format!(
                            "Route-A sidecar witness index out of range (claim_idx={claim_idx})"
                        ))
                    })?;
                    me_group.push(me.clone());
                    wit_group.push(&wit.mat);
                }
                let (proof, mut z_split_sidecar) = prove_rlc_dec_lane(
                    &mode,
                    RlcLane::Val,
                    tr,
                    params,
                    lane_s,
                    None,
                    None,
                    &ring,
                    ell_d,
                    k_dec,
                    step_idx,
                    None,
                    &me_group,
                    &wit_group,
                    collect_val_lane_wits,
                    lane_l,
                    mixers,
                )?;
                if collect_val_lane_wits {
                    if proof.dec_children.len() != z_split_sidecar.len() {
                        return Err(PiCcsError::ProtocolError(format!(
                            "Route-A sidecar DEC witness count mismatch (children={}, wits={})",
                            proof.dec_children.len(),
                            z_split_sidecar.len()
                        )));
                    }
                    val_lane_wits.extend(z_split_sidecar.drain(..));
                }
                sidecar_fold.push(proof);
            }
        }

        accumulator = children.clone();
        accumulator_wit = if want_main_wits { Z_split } else { Vec::new() };

        step_proofs.push(StepProof {
            fold: FoldStep {
                ccs_out,
                ccs_proof,
                rlc_rhos: rhos,
                rlc_parent: parent_pub,
                dec_children: children,
            },
            mem: mem_proof,
            batched_time,
            val_fold,
            sidecar_fold,
        });

        tr.append_message(b"fold/step_done", &(step_idx as u64).to_le_bytes());
        if let Some(out) = step_prove_ms_out.as_deref_mut() {
            out.push(elapsed_ms(step_start));
        }
    }

    Ok((
        ShardProof {
            steps: step_proofs,
            output_proof,
        },
        accumulator_wit,
        val_lane_wits,
    ))
}

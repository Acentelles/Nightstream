use super::*;

pub(crate) fn sparse_trace_col_from_values(
    m_in: usize,
    ell_n: usize,
    values: &[K],
) -> Result<SparseIdxVec<K>, PiCcsError> {
    let pow2_cycle = 1usize
        .checked_shl(ell_n as u32)
        .ok_or_else(|| PiCcsError::InvalidInput("WB/WP: 2^ell_n overflow".into()))?;
    let t_len = values.len();
    if m_in
        .checked_add(t_len)
        .ok_or_else(|| PiCcsError::InvalidInput("WB/WP: m_in + t_len overflow".into()))?
        > pow2_cycle
    {
        return Err(PiCcsError::InvalidInput(format!(
            "WB/WP: trace rows out of range (m_in={m_in}, t_len={t_len}, 2^ell_n={pow2_cycle})"
        )));
    }
    let mut entries = Vec::new();
    for (j, &v) in values.iter().enumerate() {
        if v != K::ZERO {
            entries.push((m_in + j, v));
        }
    }
    Ok(SparseIdxVec::from_entries(pow2_cycle, entries))
}

#[inline]
pub(crate) fn decode_k_to_u32(v: K, ctx: &str) -> Result<u32, PiCcsError> {
    let coeffs = v.as_coeffs();
    if coeffs.iter().skip(1).any(|&c| c != F::ZERO) {
        return Err(PiCcsError::ProtocolError(format!(
            "{ctx}: expected base-field value while decoding shared decode columns"
        )));
    }
    let lo = coeffs
        .first()
        .copied()
        .ok_or_else(|| PiCcsError::ProtocolError(format!("{ctx}: missing base coefficient")))?
        .as_canonical_u64();
    if lo > u32::MAX as u64 {
        return Err(PiCcsError::ProtocolError(format!(
            "{ctx}: value {lo} exceeds u32 range while decoding shared decode columns"
        )));
    }
    Ok(lo as u32)
}

#[inline]
pub(crate) fn decode_k_to_base_f(v: K, ctx: &str) -> Result<F, PiCcsError> {
    let coeffs = v.as_coeffs();
    if coeffs.iter().skip(1).any(|&c| c != F::ZERO) {
        return Err(PiCcsError::ProtocolError(format!(
            "{ctx}: expected base-field value while decoding shared columns"
        )));
    }
    coeffs
        .first()
        .copied()
        .ok_or_else(|| PiCcsError::ProtocolError(format!("{ctx}: missing base coefficient")))
}

pub(crate) struct WeightedMaskOracleSparseTime {
    bit_idx: usize,
    r_cycle: Vec<K>,
    prefix_eq: K,
    active: SparseIdxVec<K>,
    cols: Vec<SparseIdxVec<K>>,
    weights: Vec<K>,
}

impl WeightedMaskOracleSparseTime {
    pub(crate) fn new(active: SparseIdxVec<K>, cols: Vec<SparseIdxVec<K>>, weights: Vec<K>, r_cycle: &[K]) -> Self {
        debug_assert_eq!(cols.len(), weights.len());
        Self {
            bit_idx: 0,
            r_cycle: r_cycle.to_vec(),
            prefix_eq: K::ONE,
            active,
            cols,
            weights,
        }
    }
}

impl RoundOracle for WeightedMaskOracleSparseTime {
    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        if self.cols.is_empty() {
            return vec![K::ZERO; points.len()];
        }

        if self.active.len() == 1 {
            let gate = K::ONE - self.active.singleton_value();
            let mut acc = K::ZERO;
            for (col, w) in self.cols.iter().zip(self.weights.iter()) {
                acc += *w * col.singleton_value();
            }
            return vec![self.prefix_eq * gate * acc; points.len()];
        }

        let mut pairs = gather_pairs_from_sparse(self.active.entries());
        for col in self.cols.iter() {
            pairs.extend(gather_pairs_from_sparse(col.entries()));
        }
        pairs.sort_unstable();
        pairs.dedup();
        let mut ys = vec![K::ZERO; points.len()];
        for &pair in pairs.iter() {
            let child0 = 2 * pair;
            let child1 = child0 + 1;

            let gate0 = K::ONE - self.active.get(child0);
            let gate1 = K::ONE - self.active.get(child1);
            if gate0 == K::ZERO && gate1 == K::ZERO {
                continue;
            }

            let (chi0, chi1) = chi_cycle_children(&self.r_cycle, self.bit_idx, self.prefix_eq, pair);
            for (i, &x) in points.iter().enumerate() {
                let chi_x = interp(chi0, chi1, x);
                if chi_x == K::ZERO {
                    continue;
                }
                let gate_x = interp(gate0, gate1, x);
                if gate_x == K::ZERO {
                    continue;
                }
                let mut sum_x = K::ZERO;
                for (col, w) in self.cols.iter().zip(self.weights.iter()) {
                    let c0 = col.get(child0);
                    let c1 = col.get(child1);
                    if c0 == K::ZERO && c1 == K::ZERO {
                        continue;
                    }
                    sum_x += *w * interp(c0, c1, x);
                }
                ys[i] += chi_x * gate_x * sum_x;
            }
        }
        ys
    }

    fn num_rounds(&self) -> usize {
        self.r_cycle.len().saturating_sub(self.bit_idx)
    }

    fn degree_bound(&self) -> usize {
        3
    }

    fn fold(&mut self, r: K) {
        if self.num_rounds() == 0 {
            return;
        }
        self.prefix_eq *= eq_single_k(r, self.r_cycle[self.bit_idx]);
        self.active.fold_round_in_place(r);
        for col in self.cols.iter_mut() {
            col.fold_round_in_place(r);
        }
        self.bit_idx += 1;
    }
}

pub(crate) struct FormulaOracleSparseTime {
    bit_idx: usize,
    r_cycle: Vec<K>,
    prefix_eq: K,
    cols: Vec<SparseIdxVec<K>>,
    degree_bound: usize,
    eval_fn: Box<dyn Fn(&[K]) -> K>,
}

impl FormulaOracleSparseTime {
    pub(crate) fn new(
        cols: Vec<SparseIdxVec<K>>,
        degree_bound: usize,
        r_cycle: &[K],
        eval_fn: Box<dyn Fn(&[K]) -> K>,
    ) -> Self {
        Self {
            bit_idx: 0,
            r_cycle: r_cycle.to_vec(),
            prefix_eq: K::ONE,
            cols,
            degree_bound,
            eval_fn,
        }
    }
}

impl RoundOracle for FormulaOracleSparseTime {
    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        if self.cols.is_empty() {
            return vec![K::ZERO; points.len()];
        }

        let mut pairs = Vec::new();
        for col in self.cols.iter() {
            pairs.extend(gather_pairs_from_sparse(col.entries()));
        }
        pairs.sort_unstable();
        pairs.dedup();

        let mut ys = vec![K::ZERO; points.len()];
        let mut vals = vec![K::ZERO; self.cols.len()];
        for &pair in pairs.iter() {
            let child0 = 2 * pair;
            let child1 = child0 + 1;
            let (chi0, chi1) = chi_cycle_children(&self.r_cycle, self.bit_idx, self.prefix_eq, pair);
            for (i, &x) in points.iter().enumerate() {
                let chi_x = interp(chi0, chi1, x);
                if chi_x == K::ZERO {
                    continue;
                }
                for (j, col) in self.cols.iter().enumerate() {
                    vals[j] = interp(col.get(child0), col.get(child1), x);
                }
                let f_x = (self.eval_fn)(&vals);
                if f_x == K::ZERO {
                    continue;
                }
                ys[i] += chi_x * f_x;
            }
        }
        ys
    }

    fn num_rounds(&self) -> usize {
        self.r_cycle.len().saturating_sub(self.bit_idx)
    }

    fn degree_bound(&self) -> usize {
        self.degree_bound
    }

    fn fold(&mut self, r: K) {
        if self.num_rounds() == 0 {
            return;
        }
        self.prefix_eq *= eq_single_k(r, self.r_cycle[self.bit_idx]);
        for col in self.cols.iter_mut() {
            col.fold_round_in_place(r);
        }
        self.bit_idx += 1;
    }
}

#[inline]
pub(crate) fn unpack_interleaved_halves_lsb(addr_bits: &[K]) -> Result<(K, K), PiCcsError> {
    if !addr_bits.len().is_multiple_of(2) {
        return Err(PiCcsError::InvalidInput(format!(
            "shout linkage expects even ell_addr, got {}",
            addr_bits.len()
        )));
    }
    let half_len = addr_bits.len() / 2;
    let two = K::from(F::from_u64(2));
    let mut pow = K::ONE;
    let mut lhs = K::ZERO;
    let mut rhs = K::ZERO;
    for k in 0..half_len {
        lhs += pow * addr_bits[2 * k];
        rhs += pow * addr_bits[2 * k + 1];
        pow *= two;
    }
    Ok((lhs, rhs))
}

pub(crate) fn extract_trace_cpu_link_openings(
    core_t: usize,
    step: &StepInstanceBundle<Cmt, F, K>,
    mem_proof: &MemSidecarProof<Cmt, F, K>,
    r_time: &[K],
) -> Result<Option<TraceCpuLinkOpenings>, PiCcsError> {
    let Some(open_map) = trace_main_openings_at_r_time(core_t, step, mem_proof, r_time)? else {
        return Err(PiCcsError::ProtocolError(
            "missing lookup sidecar trace openings for CPU linkage".into(),
        ));
    };
    let trace = Rv32TraceLayout::new();
    let cpu_open = |col_id: usize| -> Result<K, PiCcsError> {
        open_map
            .get(&col_id)
            .copied()
            .ok_or_else(|| PiCcsError::ProtocolError(format!("missing CPU trace linkage opening for col_id={col_id}")))
    };

    Ok(Some(TraceCpuLinkOpenings {
        shout_has_lookup: cpu_open(trace.shout_has_lookup)?,
        shout_val: cpu_open(trace.shout_val)?,
        shout_lhs: cpu_open(trace.shout_lhs)?,
        shout_rhs: cpu_open(trace.shout_rhs)?,
    }))
}

#[inline]
fn route_a_lookup_sidecar_claim_index(step: &StepInstanceBundle<Cmt, F, K>) -> Result<Option<usize>, PiCcsError> {
    if !route_a_lookup_sidecar_required_for_step_instance(step) {
        return Ok(None);
    }
    let idx = step
        .lut_insts
        .len()
        .checked_add(step.mem_insts.len())
        .ok_or_else(|| PiCcsError::InvalidInput("lookup sidecar claim index overflow".into()))?;
    Ok(Some(idx))
}

pub(crate) fn trace_main_openings_at_r_time(
    core_t: usize,
    step: &StepInstanceBundle<Cmt, F, K>,
    mem_proof: &MemSidecarProof<Cmt, F, K>,
    r_time: &[K],
) -> Result<Option<BTreeMap<usize, K>>, PiCcsError> {
    let Some(lookup_idx) = route_a_lookup_sidecar_claim_index(step)? else {
        return Ok(None);
    };
    let lookup_me = mem_proof
        .sidecar_me_claims
        .get(lookup_idx)
        .ok_or_else(|| PiCcsError::ProtocolError("missing lookup sidecar ME claim".into()))?;
    if lookup_me.r.as_slice() != r_time {
        return Err(PiCcsError::ProtocolError("lookup sidecar ME r mismatch".into()));
    }
    if lookup_me.m_in != step.mcs_inst.m_in {
        return Err(PiCcsError::ProtocolError(format!(
            "lookup sidecar ME m_in mismatch: got {}, expected {}",
            lookup_me.m_in, step.mcs_inst.m_in
        )));
    }
    let trace = Rv32TraceLayout::new();
    let trace_open_cols = rv32_trace_main_opening_columns(&trace);
    let trace_open_start = core_t;
    let trace_open_end = trace_open_start
        .checked_add(trace_open_cols.len())
        .ok_or_else(|| PiCcsError::InvalidInput("trace sidecar opening range overflow".into()))?;
    if lookup_me.y_scalars.len() < trace_open_end {
        return Err(PiCcsError::ProtocolError(format!(
            "trace sidecar openings missing (got {}, need at least {trace_open_end})",
            lookup_me.y_scalars.len()
        )));
    }
    let open_map = trace_open_cols
        .iter()
        .copied()
        .zip(
            lookup_me.y_scalars[trace_open_start..trace_open_end]
                .iter()
                .copied(),
        )
        .collect();
    Ok(Some(open_map))
}

#[derive(Clone, Copy, Debug)]
pub(crate) struct TraceDecodeOpeningsAtRTime {
    pub shout_table_id: K,
    pub rd_has_write: K,
    pub ram_has_read: K,
    pub ram_has_write: K,
}

pub(crate) fn trace_decode_width_open_maps_at_r_time(
    core_t: usize,
    step: &StepInstanceBundle<Cmt, F, K>,
    mem_proof: &MemSidecarProof<Cmt, F, K>,
    r_time: &[K],
    require_width: bool,
) -> Result<Option<(BTreeMap<usize, K>, BTreeMap<usize, K>)>, PiCcsError> {
    let decode_required = decode_stage_required_for_step_instance(step);
    let width_required = width_stage_required_for_step_instance(step);
    if !decode_required && !width_required {
        return Ok(None);
    }

    let decode_layout = Rv32DecodeSidecarLayout::new();
    let decode_open_cols = rv32_decode_lookup_backed_cols(&decode_layout);
    let width_layout = Rv32WidthSidecarLayout::new();
    let width_open_cols = rv32_width_lookup_backed_cols(&width_layout);

    let Some(lookup_idx) = route_a_lookup_sidecar_claim_index(step)? else {
        return Ok(None);
    };
    let lookup_me = mem_proof
        .sidecar_me_claims
        .get(lookup_idx)
        .ok_or_else(|| PiCcsError::ProtocolError("missing lookup sidecar ME claim".into()))?;
    if lookup_me.r.as_slice() != r_time {
        return Err(PiCcsError::ProtocolError("lookup sidecar ME r mismatch".into()));
    }
    if lookup_me.m_in != step.mcs_inst.m_in {
        return Err(PiCcsError::ProtocolError(format!(
            "lookup sidecar ME m_in mismatch: got {}, expected {}",
            lookup_me.m_in, step.mcs_inst.m_in
        )));
    }

    let trace_layout = Rv32TraceLayout::new();
    let trace_open_cols = rv32_trace_main_opening_columns(&trace_layout);
    let decode_open_start = core_t
        .checked_add(trace_open_cols.len())
        .ok_or_else(|| PiCcsError::InvalidInput("decode sidecar opening range overflow".into()))?;
    let decode_open_end = decode_open_start
        .checked_add(decode_open_cols.len())
        .ok_or_else(|| PiCcsError::InvalidInput("decode sidecar opening range overflow".into()))?;
    if lookup_me.y_scalars.len() < decode_open_end {
        return Err(PiCcsError::ProtocolError(format!(
            "decode sidecar openings missing (got {}, need at least {decode_open_end})",
            lookup_me.y_scalars.len()
        )));
    }

    let decode_open_map: BTreeMap<usize, K> = decode_open_cols
        .iter()
        .copied()
        .zip(
            lookup_me.y_scalars[decode_open_start..decode_open_end]
                .iter()
                .copied(),
        )
        .collect();
    let width_open_map = if require_width {
        let width_open_end = decode_open_end
            .checked_add(width_open_cols.len())
            .ok_or_else(|| PiCcsError::InvalidInput("width sidecar opening range overflow".into()))?;
        if lookup_me.y_scalars.len() < width_open_end {
            return Err(PiCcsError::ProtocolError(format!(
                "width sidecar openings missing (got {}, need at least {width_open_end})",
                lookup_me.y_scalars.len()
            )));
        }
        width_open_cols
            .iter()
            .copied()
            .zip(
                lookup_me.y_scalars[decode_open_end..width_open_end]
                    .iter()
                    .copied(),
            )
            .collect()
    } else {
        BTreeMap::new()
    };

    Ok(Some((decode_open_map, width_open_map)))
}

pub(crate) fn trace_decode_openings_at_r_time(
    core_t: usize,
    step: &StepInstanceBundle<Cmt, F, K>,
    mem_proof: &MemSidecarProof<Cmt, F, K>,
    r_time: &[K],
) -> Result<Option<TraceDecodeOpeningsAtRTime>, PiCcsError> {
    let Some((decode_open_map, _)) = trace_decode_width_open_maps_at_r_time(core_t, step, mem_proof, r_time, false)?
    else {
        return Ok(None);
    };
    let decode_layout = Rv32DecodeSidecarLayout::new();
    let decode_open_col = |col_id: usize| -> Result<K, PiCcsError> {
        decode_open_map.get(&col_id).copied().ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "decode-linked Shout table_id check: missing decode opening col {col_id}"
            ))
        })
    };

    Ok(Some(TraceDecodeOpeningsAtRTime {
        shout_table_id: decode_open_col(decode_layout.shout_table_id)?,
        rd_has_write: decode_open_col(decode_layout.rd_has_write)?,
        ram_has_read: decode_open_col(decode_layout.ram_has_read)?,
        ram_has_write: decode_open_col(decode_layout.ram_has_write)?,
    }))
}

pub(crate) fn expected_trace_shout_table_id_from_openings(
    core_t: usize,
    step: &StepInstanceBundle<Cmt, F, K>,
    mem_proof: &MemSidecarProof<Cmt, F, K>,
    r_time: &[K],
) -> Result<K, PiCcsError> {
    Ok(trace_decode_openings_at_r_time(core_t, step, mem_proof, r_time)?
        .map(|open| open.shout_table_id)
        .unwrap_or(K::ZERO))
}

pub(crate) fn prove_twist_addr_pre_time(
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    step: &StepWitnessBundle<Cmt, F, K>,
    ell_n: usize,
    r_cycle: &[K],
) -> Result<Vec<TwistAddrPreProverData>, PiCcsError> {
    if step.mem_instances.is_empty() {
        return Ok(Vec::new());
    }
    let mut out = Vec::with_capacity(step.mem_instances.len());

    for (idx, (mem_inst, mem_wit)) in step.mem_instances.iter().enumerate() {
        neo_memory::addr::validate_twist_bit_addressing(mem_inst)?;
        let pow2_cycle = 1usize << ell_n;
        if mem_inst.steps > pow2_cycle {
            return Err(PiCcsError::InvalidInput(format!(
                "Twist(Route A): steps={} exceeds 2^ell_cycle={pow2_cycle}",
                mem_inst.steps
            )));
        }

        let ell_addr = mem_inst.d * mem_inst.ell;
        let expected_lanes = mem_inst.lanes.max(1);
        let mut lanes: Vec<TwistLaneSparseCols> = Vec::with_capacity(expected_lanes);
        let twist_layout = mem_inst.twist_layout();
        if mem_wit.mats.len() != twist_layout.expected_len() {
            return Err(PiCcsError::InvalidInput(format!(
                "Twist(Route A): witness mats shape mismatch at mem_idx={idx} (mats={}, expected={})",
                mem_wit.mats.len(),
                twist_layout.expected_len()
            )));
        }
        for (lane_idx, lane_layout) in twist_layout.lanes.iter().enumerate() {
            if lane_layout.ell_addr != ell_addr {
                return Err(PiCcsError::InvalidInput(format!(
                    "Twist(Route A): witness/layout ell_addr mismatch at mem_idx={idx}, lane={lane_idx} (layout={}, expected={ell_addr})",
                    lane_layout.ell_addr
                )));
            }
            let decode_col_sparse = |col_idx: usize, name: &str| -> Result<SparseIdxVec<K>, PiCcsError> {
                let mat = mem_wit.mats.get(col_idx).ok_or_else(|| {
                    PiCcsError::InvalidInput(format!(
                        "Twist(Route A): witness mats missing {name} column at mem_idx={idx}, col_idx={col_idx}"
                    ))
                })?;
                if mat.rows() != params.d as usize {
                    return Err(PiCcsError::InvalidInput(format!(
                        "Twist(Route A): witness mat rows mismatch at mem_idx={idx}, col_idx={col_idx} (rows={}, expected D={})",
                        mat.rows(),
                        params.d
                    )));
                }
                if mat.cols() != mem_inst.steps {
                    return Err(PiCcsError::InvalidInput(format!(
                        "Twist(Route A): witness mat cols mismatch at mem_idx={idx}, col_idx={col_idx} (cols={}, expected steps={})",
                        mat.cols(),
                        mem_inst.steps
                    )));
                }
                let vals: Vec<K> = neo_memory::ajtai::decode_vector(params, mat)
                    .into_iter()
                    .map(Into::into)
                    .collect();
                sparse_trace_col_from_values(step.mcs.0.m_in, ell_n, &vals)
            };

            let mut ra_bits = Vec::with_capacity(ell_addr);
            for col_idx in lane_layout.ra_bits.clone() {
                ra_bits.push(decode_col_sparse(col_idx, "ra_bits")?);
            }
            let mut wa_bits = Vec::with_capacity(ell_addr);
            for col_idx in lane_layout.wa_bits.clone() {
                wa_bits.push(decode_col_sparse(col_idx, "wa_bits")?);
            }
            let has_read = decode_col_sparse(lane_layout.has_read, "has_read")?;
            let has_write = decode_col_sparse(lane_layout.has_write, "has_write")?;
            let wv = decode_col_sparse(lane_layout.wv, "wv")?;
            let rv = decode_col_sparse(lane_layout.rv, "rv")?;
            let inc_at_write_addr = decode_col_sparse(lane_layout.inc_at_write_addr, "inc_at_write_addr")?;

            lanes.push(TwistLaneSparseCols {
                ra_bits,
                wa_bits,
                has_read,
                has_write,
                wv,
                rv,
                inc_at_write_addr,
            });
        }

        let decoded = TwistDecodedColsSparse { lanes };

        let init_sparse: Vec<(usize, K)> = match &mem_inst.init {
            MemInit::Zero => Vec::new(),
            MemInit::Sparse(pairs) => pairs
                .iter()
                .map(|(addr, val)| {
                    let addr_usize = usize::try_from(*addr).map_err(|_| {
                        PiCcsError::InvalidInput(format!("Twist: init address doesn't fit usize: addr={addr}"))
                    })?;
                    if addr_usize >= mem_inst.k {
                        return Err(PiCcsError::InvalidInput(format!(
                            "Twist: init address out of range: addr={addr} >= k={}",
                            mem_inst.k
                        )));
                    }
                    Ok((addr_usize, (*val).into()))
                })
                .collect::<Result<_, _>>()?,
        };

        let mut read_addr_oracle =
            TwistReadCheckAddrOracleSparseTimeMultiLane::new(init_sparse.clone(), r_cycle, &decoded.lanes);
        let mut write_addr_oracle =
            TwistWriteCheckAddrOracleSparseTimeMultiLane::new(init_sparse, r_cycle, &decoded.lanes);

        let labels: [&[u8]; 2] = [b"twist/read_addr_pre".as_slice(), b"twist/write_addr_pre".as_slice()];
        let claimed_sums = vec![K::ZERO, K::ZERO];
        tr.append_message(b"twist/addr_pre_time/claim_idx", &(idx as u64).to_le_bytes());
        bind_batched_claim_sums(tr, b"twist/addr_pre_time/claimed_sums", &claimed_sums, &labels);

        let mut claims = [
            BatchedClaim {
                oracle: &mut read_addr_oracle,
                claimed_sum: K::ZERO,
                label: labels[0],
            },
            BatchedClaim {
                oracle: &mut write_addr_oracle,
                claimed_sum: K::ZERO,
                label: labels[1],
            },
        ];

        let (r_addr, per_claim_results) = run_batched_sumcheck_prover_ds(tr, b"twist/addr_pre_time", idx, &mut claims)?;
        if per_claim_results.len() != 2 {
            return Err(PiCcsError::ProtocolError(format!(
                "twist addr-pre per-claim results len()={}, expected 2",
                per_claim_results.len()
            )));
        }

        out.push(TwistAddrPreProverData {
            addr_pre: BatchedAddrProof {
                claimed_sums,
                round_polys: vec![
                    per_claim_results[0].round_polys.clone(),
                    per_claim_results[1].round_polys.clone(),
                ],
                r_addr: r_addr.clone(),
            },
            decoded,
            read_check_claim_sum: per_claim_results[0].final_value,
            write_check_claim_sum: per_claim_results[1].final_value,
        });
    }

    Ok(out)
}

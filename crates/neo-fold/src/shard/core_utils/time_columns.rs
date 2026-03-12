//! Time-column commitment and opening-batch helpers for shard proving and
//! verification.
//!
//! This module owns the deterministic PP seed, time-column commitment flow, and
//! transcript binding for the Stage-8 opening batches.

use super::*;

#[inline]
fn time_column_commit_seed(t: usize) -> [u8; 32] {
    #[inline]
    fn mix64(mut x: u64) -> u64 {
        x ^= x >> 30;
        x = x.wrapping_mul(0xbf58_476d_1ce4_e5b9);
        x ^= x >> 27;
        x = x.wrapping_mul(0x94d0_49bb_1331_11eb);
        x ^ (x >> 31)
    }

    let d = neo_math::D as u64;
    let tt = t as u64;
    let words = [
        mix64(0x6e65_6f2d_666f_6c64 ^ d ^ (tt << 1)),
        mix64(0x7469_6d65_2d63_6f6c ^ (tt << 7)),
        mix64(0x636f_6d6d_6974_2d76 ^ (d << 13) ^ (tt << 5)),
        mix64(0x312f_6465_7465_726d ^ (d << 17) ^ (tt << 19)),
    ];
    let mut seed = [0u8; 32];
    for (i, w) in words.iter().enumerate() {
        seed[i * 8..(i + 1) * 8].copy_from_slice(&w.to_le_bytes());
    }
    seed
}

#[inline]
pub(crate) fn stage8_time_decomp_params(params: &NeoParams) -> Result<NeoParams, PiCcsError> {
    let mut out = *params;
    out.b = crate::time_opening::STAGE8_TIME_DECOMP_BASE;
    out.B = (out.b as u64).checked_pow(out.k_rho).ok_or_else(|| {
        PiCcsError::InvalidInput(format!(
            "stage8/time params: b^k_rho overflow (b={}, k_rho={})",
            out.b, out.k_rho
        ))
    })?;
    let lhs = (out.k_rho as u128 + 1) * (out.T as u128) * ((out.b as u128).saturating_sub(1));
    if lhs >= out.B as u128 {
        return Err(PiCcsError::InvalidInput(format!(
            "stage8/time params: guard inequality fails ((k_rho+1)·T·(b-1)={} >= B={})",
            lhs, out.B
        )));
    }
    Ok(out)
}

pub(crate) fn commit_time_column_sets(
    params: &NeoParams,
    t: usize,
    cpu_cols: &[Vec<F>],
    mem_cols: &[Vec<F>],
    label: &str,
) -> Result<(Vec<Cmt>, Vec<Cmt>), PiCcsError> {
    if t == 0 {
        if cpu_cols.is_empty() && mem_cols.is_empty() {
            return Ok((Vec::new(), Vec::new()));
        }
        return Err(PiCcsError::InvalidInput(format!(
            "{label}: t must be > 0 when time columns are present"
        )));
    }

    for (idx, col) in cpu_cols.iter().enumerate() {
        if col.len() != t {
            return Err(PiCcsError::InvalidInput(format!(
                "{label}: cpu_cols[{idx}].len()={} != t={}",
                col.len(),
                t
            )));
        }
    }
    for (idx, col) in mem_cols.iter().enumerate() {
        if col.len() != t {
            return Err(PiCcsError::InvalidInput(format!(
                "{label}: mem_cols[{idx}].len()={} != t={}",
                col.len(),
                t
            )));
        }
    }

    let want_kappa = params.kappa as usize;
    let expected_seed = time_column_commit_seed(t);
    if has_global_pp_for_dims(D, t) {
        if let Ok((kappa, seed)) = get_global_pp_seeded_params_for_dims(D, t) {
            if kappa != want_kappa {
                return Err(PiCcsError::InvalidInput(format!(
                    "{label}: time-column PP kappa mismatch for (D,t)=({D},{t}) (have {kappa}, want {want_kappa})"
                )));
            }
            if seed != expected_seed {
                return Err(PiCcsError::InvalidInput(format!(
                    "{label}: time-column PP seed mismatch for (D,t)=({D},{t})"
                )));
            }
        } else {
            let pp = get_global_pp_for_dims(D, t).map_err(|e| {
                PiCcsError::InvalidInput(format!(
                    "{label}: failed to load existing time-column PP for (D,t)=({D},{t}): {e}"
                ))
            })?;
            if pp.kappa != want_kappa {
                return Err(PiCcsError::InvalidInput(format!(
                    "{label}: time-column PP kappa mismatch for (D,t)=({D},{t}) (have {}, want {want_kappa})",
                    pp.kappa
                )));
            }
        }
    } else {
        match neo_ajtai::set_global_pp_seeded(D, want_kappa, t, expected_seed) {
            Ok(()) => {}
            Err(e) if has_global_pp_for_dims(D, t) => {
                if let Ok((kappa, seed)) = get_global_pp_seeded_params_for_dims(D, t) {
                    if kappa != want_kappa {
                        return Err(PiCcsError::InvalidInput(format!(
                            "{label}: time-column PP race produced kappa mismatch for (D,t)=({D},{t}) (have {kappa}, want {want_kappa})"
                        )));
                    }
                    if seed != expected_seed {
                        return Err(PiCcsError::InvalidInput(format!(
                            "{label}: time-column PP race produced seed mismatch for (D,t)=({D},{t})"
                        )));
                    }
                } else {
                    return Err(PiCcsError::InvalidInput(format!(
                        "{label}: failed to register/load seeded time-column PP for (D,t)=({D},{t}): {e}"
                    )));
                }
            }
            Err(e) => {
                return Err(PiCcsError::InvalidInput(format!(
                    "{label}: failed to register seeded time-column PP for (D,t)=({D},{t}): {e}"
                )));
            }
        }
    }

    let committer = neo_ajtai::AjtaiSModule::from_global_for_dims(D, t).map_err(|e| {
        PiCcsError::InvalidInput(format!(
            "{label}: time-column committer unavailable for (D,t)=({D},{t}): {e}"
        ))
    })?;

    const TIME_COMMIT_BATCH: usize = 512;
    let mut all_cols: Vec<&Vec<F>> = Vec::with_capacity(cpu_cols.len() + mem_cols.len());
    all_cols.extend(cpu_cols.iter());
    all_cols.extend(mem_cols.iter());
    let mut all_comms = Vec::with_capacity(all_cols.len());
    for chunk in all_cols.chunks(TIME_COMMIT_BATCH) {
        #[cfg(any(not(target_arch = "wasm32"), feature = "wasm-threads"))]
        let mats: Vec<Mat<F>> = if chunk.len() >= 32 {
            chunk
                .par_iter()
                .map(|col| {
                    neo_memory::ajtai::encode_vector_balanced_to_mat_with_base(
                        params,
                        *col,
                        crate::time_opening::STAGE8_TIME_DECOMP_BASE,
                    )
                })
                .collect()
        } else {
            chunk
                .iter()
                .map(|col| {
                    neo_memory::ajtai::encode_vector_balanced_to_mat_with_base(
                        params,
                        *col,
                        crate::time_opening::STAGE8_TIME_DECOMP_BASE,
                    )
                })
                .collect()
        };
        #[cfg(all(target_arch = "wasm32", not(feature = "wasm-threads")))]
        let mats: Vec<Mat<F>> = chunk
            .iter()
            .map(|col| {
                neo_memory::ajtai::encode_vector_balanced_to_mat_with_base(
                    params,
                    *col,
                    crate::time_opening::STAGE8_TIME_DECOMP_BASE,
                )
            })
            .collect();
        let refs: Vec<&Mat<F>> = mats.iter().collect();
        all_comms.extend(committer.commit_many(&refs));
    }

    let mem_comms = all_comms.split_off(cpu_cols.len());
    let cpu_comms = all_comms;

    Ok((cpu_comms, mem_comms))
}

pub(crate) fn bind_time_column_commitments(
    tr: &mut Poseidon2Transcript,
    step_idx: usize,
    time_t: usize,
    time_declared_len: usize,
    time_col_ids: &[usize],
    cpu_commitments: &[Cmt],
    mem_commitments: &[Cmt],
) {
    tr.append_message(b"time_columns/commit_bind/v2", &[]);
    let header = [
        step_idx as u64,
        time_t as u64,
        time_declared_len as u64,
        time_col_ids.len() as u64,
        cpu_commitments.len() as u64,
        mem_commitments.len() as u64,
        crate::time_opening::STAGE8_TIME_DECOMP_BASE as u64,
    ];
    tr.append_u64s(b"time_columns/commit_bind/header", &header);
    let time_col_ids_u64: Vec<u64> = time_col_ids.iter().map(|&id| id as u64).collect();
    tr.append_u64s(b"time_columns/commit_bind/time_col_ids", &time_col_ids_u64);
    let cpu_lens: Vec<u64> = cpu_commitments
        .iter()
        .map(|c| c.data.len() as u64)
        .collect();
    tr.append_u64s(b"time_columns/commit_bind/cpu_c_data_lens", &cpu_lens);
    let cpu_data_len: usize = cpu_commitments.iter().map(|c| c.data.len()).sum();
    tr.append_fields_iter(
        b"time_columns/commit_bind/cpu_c_data_flat",
        cpu_data_len,
        cpu_commitments.iter().flat_map(|c| c.data.iter().copied()),
    );

    let mem_lens: Vec<u64> = mem_commitments
        .iter()
        .map(|c| c.data.len() as u64)
        .collect();
    tr.append_u64s(b"time_columns/commit_bind/mem_c_data_lens", &mem_lens);
    let mem_data_len: usize = mem_commitments.iter().map(|c| c.data.len()).sum();
    tr.append_fields_iter(
        b"time_columns/commit_bind/mem_c_data_flat",
        mem_data_len,
        mem_commitments.iter().flat_map(|c| c.data.iter().copied()),
    );
}

pub(crate) fn validate_time_active_mask_and_count(
    active_col: &[F],
    time_t: usize,
    label: &str,
) -> Result<usize, PiCcsError> {
    if time_t == 0 {
        if active_col.is_empty() {
            return Ok(0);
        }
        return Err(PiCcsError::InvalidInput(format!(
            "{label}: time_t=0 requires empty active_col (got len={})",
            active_col.len()
        )));
    }
    if active_col.len() != time_t {
        return Err(PiCcsError::InvalidInput(format!(
            "{label}: active_col.len()={} != time_t={time_t}",
            active_col.len()
        )));
    }
    let mut seen_zero = false;
    let mut active_count = 0usize;
    for (j, &a) in active_col.iter().enumerate() {
        if a != F::ZERO && a != F::ONE {
            return Err(PiCcsError::ProtocolError(format!(
                "{label}: active_col[{j}] must be boolean (got {a:?})"
            )));
        }
        if a == F::ONE {
            if seen_zero {
                return Err(PiCcsError::ProtocolError(format!(
                    "{label}: active_col is not monotone tail at row {j}"
                )));
            }
            active_count = active_count
                .checked_add(1)
                .ok_or_else(|| PiCcsError::InvalidInput(format!("{label}: active_count overflow")))?;
        } else {
            seen_zero = true;
        }
    }
    if active_count > time_t {
        return Err(PiCcsError::ProtocolError(format!(
            "{label}: active_count {} exceeds time_t {}",
            active_count, time_t
        )));
    }
    Ok(active_count)
}

pub(crate) fn bind_time_opening_batches_and_sample_coeffs(
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    step_idx: usize,
    opening_proofs: &[crate::shard_proof_types::TimeOpeningProof],
) -> Result<Vec<Vec<Mat<F>>>, PiCcsError> {
    #[inline]
    fn f_from_i64(x: i64) -> F {
        if x >= 0 {
            F::from_u64(x as u64)
        } else {
            F::ZERO - F::from_u64((-x) as u64)
        }
    }

    #[inline]
    fn rot_matrix_to_rq(mat: &Mat<F>) -> Result<neo_math::ring::Rq, PiCcsError> {
        if mat.rows() != D || mat.cols() != D {
            return Err(PiCcsError::InvalidInput(format!(
                "time_openings/batch_bind: sampled rho must be {D}x{D} (got {}x{})",
                mat.rows(),
                mat.cols()
            )));
        }
        let mut coeffs = [F::ZERO; D];
        for i in 0..D {
            coeffs[i] = mat[(i, 0)];
        }
        Ok(neo_math::ring::Rq(coeffs))
    }

    #[inline]
    fn rot_from_coeffs(coeffs: &[F; D], neg_phi_coeffs: &[F; D]) -> Mat<F> {
        let mut out = Mat::zero(D, D, F::ZERO);
        let mut col = *coeffs;
        for j in 0..D {
            for r in 0..D {
                out[(r, j)] = col[r];
            }
            let last = col[D - 1];
            let mut next = [F::ZERO; D];
            next[0] = last * neg_phi_coeffs[0];
            for r in 1..D {
                next[r] = col[r - 1] + last * neg_phi_coeffs[r];
            }
            col = next;
        }
        out
    }

    tr.append_message(b"time_openings/batch_bind/v2", &[]);
    tr.append_u64s(b"time_openings/batch_bind/step_idx", &[step_idx as u64]);
    tr.append_u64s(b"time_openings/batch_bind/proof_count", &[opening_proofs.len() as u64]);

    let mut all_coeffs = Vec::with_capacity(opening_proofs.len());
    let ring = ccs::RotRing::goldilocks();
    let mut neg_phi_coeffs = [F::ZERO; D];
    for (i, &c) in ring.phi_coeffs.iter().enumerate() {
        neg_phi_coeffs[i] = f_from_i64(-(c as i64));
    }

    let mut point_field_lens = Vec::with_capacity(opening_proofs.len());
    let mut col_id_lens = Vec::with_capacity(opening_proofs.len());
    let mut eval_field_lens = Vec::with_capacity(opening_proofs.len());
    let mut digit_row_lens = Vec::with_capacity(opening_proofs.len());
    let mut digit_field_lens = Vec::with_capacity(opening_proofs.len());
    let mut total_point_fields = 0usize;
    let mut total_eval_fields = 0usize;
    let mut total_digit_fields = 0usize;
    let mut total_col_ids = 0usize;

    for (proof_idx, pf) in opening_proofs.iter().enumerate() {
        if pf.col_ids.len() != pf.evals.len() || pf.col_ids.len() != pf.digit_evals.len() {
            return Err(PiCcsError::ProtocolError(format!(
                "time_openings/batch_bind: proof[{proof_idx}] malformed (col_ids={}, evals={}, digit_evals={})",
                pf.col_ids.len(),
                pf.evals.len(),
                pf.digit_evals.len()
            )));
        }
        for (digit_idx, row) in pf.digit_evals.iter().enumerate() {
            if row.len() != D {
                return Err(PiCcsError::ProtocolError(format!(
                    "time_openings/batch_bind: proof[{proof_idx}] digit_evals[{digit_idx}] len {} != D={D}",
                    row.len()
                )));
            }
        }

        let point_coeffs_per_elem = pf.point.first().map(|v| v.as_coeffs().len()).unwrap_or(0);
        let point_len = pf
            .point
            .len()
            .checked_mul(point_coeffs_per_elem)
            .ok_or_else(|| PiCcsError::ProtocolError("time_openings/batch_bind point length overflow".into()))?;

        let eval_coeffs_per_elem = pf.evals.first().map(|v| v.as_coeffs().len()).unwrap_or(0);
        let eval_len = pf
            .evals
            .len()
            .checked_mul(eval_coeffs_per_elem)
            .ok_or_else(|| PiCcsError::ProtocolError("time_openings/batch_bind eval length overflow".into()))?;
        let digit_coeffs_per_elem = pf
            .digit_evals
            .first()
            .and_then(|row| row.first())
            .map(|v| v.as_coeffs().len())
            .unwrap_or(0);
        let digit_len = pf
            .digit_evals
            .len()
            .checked_mul(D)
            .and_then(|n| n.checked_mul(digit_coeffs_per_elem))
            .ok_or_else(|| PiCcsError::ProtocolError("time_openings/batch_bind digit eval length overflow".into()))?;

        point_field_lens.push(point_len as u64);
        eval_field_lens.push(eval_len as u64);
        digit_row_lens.push(pf.digit_evals.len() as u64);
        digit_field_lens.push(digit_len as u64);
        col_id_lens.push(pf.col_ids.len() as u64);
        total_point_fields = total_point_fields
            .checked_add(point_len)
            .ok_or_else(|| PiCcsError::ProtocolError("time_openings/batch_bind point total overflow".into()))?;
        total_eval_fields = total_eval_fields
            .checked_add(eval_len)
            .ok_or_else(|| PiCcsError::ProtocolError("time_openings/batch_bind eval total overflow".into()))?;
        total_digit_fields = total_digit_fields
            .checked_add(digit_len)
            .ok_or_else(|| PiCcsError::ProtocolError("time_openings/batch_bind digit total overflow".into()))?;
        total_col_ids = total_col_ids
            .checked_add(pf.col_ids.len())
            .ok_or_else(|| PiCcsError::ProtocolError("time_openings/batch_bind col_id total overflow".into()))?;
    }

    tr.append_u64s(b"time_openings/batch_bind/point_field_lens", &point_field_lens);
    tr.append_fields_iter(
        b"time_openings/batch_bind/points_flat",
        total_point_fields,
        opening_proofs
            .iter()
            .flat_map(|pf| pf.point.iter())
            .flat_map(|v| v.as_coeffs()),
    );

    tr.append_u64s(b"time_openings/batch_bind/col_id_lens", &col_id_lens);
    let col_ids_u64: Vec<u64> = opening_proofs
        .iter()
        .flat_map(|pf| pf.col_ids.iter())
        .map(|&id| id as u64)
        .collect();
    debug_assert_eq!(col_ids_u64.len(), total_col_ids);
    tr.append_u64s(b"time_openings/batch_bind/col_ids_flat", &col_ids_u64);

    tr.append_u64s(b"time_openings/batch_bind/eval_field_lens", &eval_field_lens);
    tr.append_fields_iter(
        b"time_openings/batch_bind/evals_flat",
        total_eval_fields,
        opening_proofs
            .iter()
            .flat_map(|pf| pf.evals.iter())
            .flat_map(|v| v.as_coeffs()),
    );

    tr.append_u64s(b"time_openings/batch_bind/digit_row_lens", &digit_row_lens);
    tr.append_u64s(b"time_openings/batch_bind/digit_field_lens", &digit_field_lens);
    tr.append_fields_iter(
        b"time_openings/batch_bind/eval_digits_flat",
        total_digit_fields,
        opening_proofs
            .iter()
            .flat_map(|pf| pf.digit_evals.iter())
            .flat_map(|row| row.iter())
            .flat_map(|v| v.as_coeffs()),
    );

    tr.append_message(b"time_openings/batch_bind/rho_bases/v2", &[]);
    let bases = ccs::sample_rot_rhos_n(tr, params, &ring, opening_proofs.len())?;
    if bases.len() != opening_proofs.len() {
        return Err(PiCcsError::ProtocolError(format!(
            "time_openings/batch_bind: sampled {} rho bases for {} proofs",
            bases.len(),
            opening_proofs.len()
        )));
    }

    for (pf, base) in opening_proofs.iter().zip(bases.into_iter()) {
        let base_rq = rot_matrix_to_rq(&base)?;
        let mut coeffs = Vec::with_capacity(pf.col_ids.len());
        let mut cur_rq = neo_math::ring::Rq::one();
        for _ in 0..pf.col_ids.len() {
            coeffs.push(rot_from_coeffs(&cur_rq.0, &neg_phi_coeffs));
            cur_rq = cur_rq.mul(&base_rq);
        }
        all_coeffs.push(coeffs);
    }

    Ok(all_coeffs)
}

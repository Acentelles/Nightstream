//! Transcript-binding helpers for shard-level RLC inputs.
//!
//! These helpers own the compact digest encoding that binds CE claim inputs into
//! the shard transcript before Π_RLC folding.

use super::*;

pub(crate) fn bind_rlc_inputs(
    tr: &mut Poseidon2Transcript,
    lane: RlcLane,
    step_idx: usize,
    me_inputs: &[CeClaim<Cmt, F, K>],
) -> Result<(), PiCcsError> {
    let lane_scope: &'static [u8] = match lane {
        RlcLane::Main => b"main",
        RlcLane::Val => b"val",
    };

    // v6: compact transcript binding via per-input Poseidon2 digest.
    // Encoding update: K-coefficient width is encoded once per K-slice (not per K element).
    tr.append_message(b"fold/rlc_inputs/v6", lane_scope);
    tr.append_u64s(b"step_idx", &[step_idx as u64]);
    tr.append_u64s(b"me_count", &[me_inputs.len() as u64]);

    #[inline]
    fn extend_packed_bytes_as_fields(dst: &mut Vec<F>, bytes: &[u8]) {
        const BYTES_PER_LIMB: usize = 7;
        dst.push(F::from_u64(bytes.len() as u64));
        for chunk in bytes.chunks(BYTES_PER_LIMB) {
            let mut limb = [0u8; 8];
            limb[..chunk.len()].copy_from_slice(chunk);
            dst.push(F::from_u64(u64::from_le_bytes(limb)));
        }
    }

    #[inline]
    fn extend_f_slice(dst: &mut Vec<F>, vals: &[F]) {
        dst.push(F::from_u64(vals.len() as u64));
        dst.extend_from_slice(vals);
    }

    #[inline]
    fn extend_k_slice(dst: &mut Vec<F>, vals: &[K]) {
        dst.push(F::from_u64(vals.len() as u64));
        let coeffs_len = vals.first().map(|v| v.as_coeffs().len()).unwrap_or(0);
        dst.push(F::from_u64(coeffs_len as u64));
        for v in vals {
            let coeffs = v.as_coeffs();
            debug_assert_eq!(
                coeffs.len(),
                coeffs_len,
                "non-uniform K coeff length in RLC ME digest encoding"
            );
            dst.extend(coeffs.iter().copied());
        }
    }

    #[inline]
    fn poseidon_digest32_fields(input: &[F]) -> [u8; 32] {
        let digest = neo_ccs::crypto::poseidon2_goldilocks::poseidon2_hash(input);
        let mut out = [0u8; 32];
        for (i, limb) in digest.iter().enumerate() {
            out[i * 8..(i + 1) * 8].copy_from_slice(&limb.as_canonical_u64().to_le_bytes());
        }
        out
    }

    #[inline]
    fn packed_bytes_as_fields_len(bytes_len: usize) -> usize {
        1 + bytes_len.div_ceil(7)
    }

    #[inline]
    fn f_slice_as_fields_len(vals_len: usize) -> usize {
        1 + vals_len
    }

    #[inline]
    fn k_slice_as_fields_len(vals: &[K]) -> usize {
        let coeffs_len = vals.first().map(|v| v.as_coeffs().len()).unwrap_or(0);
        2 + vals.len() * coeffs_len
    }

    #[inline]
    fn me_digest_poseidon_input_capacity(lane_scope: &'static [u8], me: &CeClaim<Cmt, F, K>) -> usize {
        let mut cap = 0usize;
        cap += packed_bytes_as_fields_len(b"neo/fold/rlc_me_input_digest_poseidon/v2".len());
        cap += packed_bytes_as_fields_len(lane_scope.len());
        cap += f_slice_as_fields_len(me.c.data.len());
        cap += f_slice_as_fields_len(me.X.as_slice().len());
        cap += k_slice_as_fields_len(&me.r);
        cap += k_slice_as_fields_len(&me.s_col);
        cap += k_slice_as_fields_len(&me.y_zcol);
        cap += 1; // y_ring.len marker
        for row in &me.y_ring {
            cap += k_slice_as_fields_len(row);
        }
        cap += k_slice_as_fields_len(&me.ct);
        cap += k_slice_as_fields_len(&me.aux_openings);
        cap += f_slice_as_fields_len(me.c_step_coords.len());
        cap += 3; // m_in, u_offset, u_len
        cap += packed_bytes_as_fields_len(me.fold_digest.len());
        cap
    }

    #[inline]
    fn me_digest_poseidon(lane_scope: &'static [u8], me: &CeClaim<Cmt, F, K>, capacity_hint: usize) -> [u8; 32] {
        let mut digest_input = Vec::<F>::with_capacity(capacity_hint.max(256));
        extend_packed_bytes_as_fields(&mut digest_input, b"neo/fold/rlc_me_input_digest_poseidon/v2");
        extend_packed_bytes_as_fields(&mut digest_input, lane_scope);

        extend_f_slice(&mut digest_input, &me.c.data);
        extend_f_slice(&mut digest_input, me.X.as_slice());
        extend_k_slice(&mut digest_input, &me.r);
        extend_k_slice(&mut digest_input, &me.s_col);
        extend_k_slice(&mut digest_input, &me.y_zcol);
        digest_input.push(F::from_u64(me.y_ring.len() as u64));
        for row in &me.y_ring {
            extend_k_slice(&mut digest_input, row);
        }
        extend_k_slice(&mut digest_input, &me.ct);
        extend_k_slice(&mut digest_input, &me.aux_openings);
        extend_f_slice(&mut digest_input, &me.c_step_coords);
        digest_input.push(F::from_u64(me.m_in as u64));
        digest_input.push(F::from_u64(me.u_offset as u64));
        digest_input.push(F::from_u64(me.u_len as u64));
        extend_packed_bytes_as_fields(&mut digest_input, &me.fold_digest);

        poseidon_digest32_fields(&digest_input)
    }

    let digest_capacity_hint = me_inputs
        .first()
        .map(|me| me_digest_poseidon_input_capacity(lane_scope, me))
        .unwrap_or(256);

    #[cfg(any(not(target_arch = "wasm32"), feature = "wasm-threads"))]
    let allow_parallel = rayon::current_num_threads() > 1 && rayon::current_thread_index().is_none();
    #[cfg(not(any(not(target_arch = "wasm32"), feature = "wasm-threads")))]
    let _allow_parallel = false;

    #[cfg(any(not(target_arch = "wasm32"), feature = "wasm-threads"))]
    let digests: Vec<[u8; 32]> = if allow_parallel && me_inputs.len() >= 8 {
        use rayon::prelude::*;
        me_inputs
            .par_iter()
            .map(|me| me_digest_poseidon(lane_scope, me, digest_capacity_hint))
            .collect()
    } else {
        me_inputs
            .iter()
            .map(|me| me_digest_poseidon(lane_scope, me, digest_capacity_hint))
            .collect()
    };
    #[cfg(not(any(not(target_arch = "wasm32"), feature = "wasm-threads")))]
    let digests: Vec<[u8; 32]> = me_inputs
        .iter()
        .map(|me| me_digest_poseidon(lane_scope, me, digest_capacity_hint))
        .collect();

    for digest in digests {
        tr.append_bytes_packed(b"me/rlc_digest", &digest);
    }

    Ok(())
}

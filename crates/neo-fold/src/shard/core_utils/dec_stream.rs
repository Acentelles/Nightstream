use super::*;

pub(crate) fn dec_stream_no_witness<MB>(
    params: &NeoParams,
    s: &CcsStructure<F>,
    parent: &CeClaim<Cmt, F, K>,
    Z_mix: &Mat<F>,
    ell_d: usize,
    k_dec: usize,
    combine_b_pows: MB,
    sparse: Option<&SparseCache<F>>,
) -> Result<(Vec<CeClaim<Cmt, F, K>>, Vec<Cmt>, bool, bool, bool), PiCcsError>
where
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
{
    if k_dec == 0 {
        return Err(PiCcsError::InvalidInput("DEC: k_dec must be > 0".into()));
    }
    if Z_mix.rows() != D {
        return Err(PiCcsError::InvalidInput(format!(
            "DEC: Z_mix must have {} rows (got {})",
            D,
            Z_mix.rows()
        )));
    }
    let z_layout = neo_reductions::common::witness_mat_layout(Z_mix, s.m).map_err(|e| {
        PiCcsError::InvalidInput(format!(
            "DEC: Z_mix shape is incompatible with logical CCS width m={} ({})",
            s.m, e
        ))
    })?;
    let m_commit = Z_mix.cols();

    let d_pad = 1usize << ell_d;
    let want_nc_channel = !(parent.s_col.is_empty() && parent.y_zcol.is_empty());
    if want_nc_channel && (parent.s_col.is_empty() || parent.y_zcol.is_empty()) {
        return Err(PiCcsError::InvalidInput(
            "DEC: incomplete NC channel on parent (expected both s_col and y_zcol)".into(),
        ));
    }
    if want_nc_channel && parent.y_zcol.len() != d_pad {
        return Err(PiCcsError::InvalidInput(format!(
            "DEC: parent y_zcol length mismatch (expected {}, got {})",
            d_pad,
            parent.y_zcol.len()
        )));
    }

    enum PpAccess {
        Seeded {
            kappa: usize,
            chunk_size: usize,
            chunk_seeds_by_row: Vec<Vec<[u8; 32]>>,
        },
        Loaded {
            pp: Arc<neo_ajtai::PP<neo_math::ring::Rq>>,
        },
    }

    let pp_access = if let Some(pp) = try_get_loaded_global_pp_for_dims(D, m_commit) {
        if pp.kappa == 0 {
            return Err(PiCcsError::InvalidInput("DEC: PP.kappa must be > 0".into()));
        }
        PpAccess::Loaded { pp }
    } else if let Ok((kappa, seed)) = get_global_pp_seeded_params_for_dims(D, m_commit) {
        if kappa == 0 {
            return Err(PiCcsError::InvalidInput("DEC: PP.kappa must be > 0".into()));
        }
        let (chunk_size, chunk_seeds_by_row) = seeded_pp_chunk_seeds(seed, kappa, m_commit);
        PpAccess::Seeded {
            kappa,
            chunk_size,
            chunk_seeds_by_row,
        }
    } else {
        let pp = get_global_pp_for_dims(D, m_commit).map_err(|e| {
            PiCcsError::InvalidInput(format!(
                "DEC: Ajtai PP unavailable for (d,m_commit)=({},{}) ({})",
                D, m_commit, e
            ))
        })?;
        if pp.kappa == 0 {
            return Err(PiCcsError::InvalidInput("DEC: PP.kappa must be > 0".into()));
        }
        PpAccess::Loaded { pp }
    };

    let ell_n = parent.r.len();
    let n_sz = 1usize
        .checked_shl(ell_n as u32)
        .ok_or_else(|| PiCcsError::InvalidInput("DEC: 2^ell_n overflow".into()))?;
    let n_eff = core::cmp::min(s.n, n_sz);

    #[inline]
    fn chi_tail_weights(bits: &[K]) -> Vec<K> {
        let t = bits.len();
        let len = 1usize << t;
        let mut w = vec![K::ZERO; len];
        w[0] = K::ONE;
        for (i, &b) in bits.iter().enumerate() {
            let step = 1usize << i;
            let one_minus = K::ONE - b;
            for mask in 0..step {
                let v = w[mask];
                w[mask] = v * one_minus;
                w[mask + step] = v * b;
            }
        }
        w
    }

    let chi_r = chi_tail_weights(&parent.r);
    debug_assert_eq!(chi_r.len(), n_sz);

    let chi_s = if want_nc_channel {
        let chi = chi_tail_weights(&parent.s_col);
        if chi.len() < s.m {
            return Err(PiCcsError::InvalidInput(format!(
                "DEC: chi(s_col) too short for CCS width (need >= {}, got {})",
                s.m,
                chi.len()
            )));
        }
        chi
    } else {
        Vec::new()
    };

    let t_mats = s.t();

    enum VjsAccess<'a> {
        Dense(Vec<Vec<K>>),
        Sparse {
            cap: usize,
            cache: &'a SparseCache<F>,
        },
    }

    let vjs_access = if let Some(cache) = sparse {
        if cache.len() != t_mats {
            return Err(PiCcsError::InvalidInput(format!(
                "DEC: sparse cache matrix count mismatch: got {}, expected {}",
                cache.len(),
                t_mats
            )));
        }
        let cap = core::cmp::min(s.m, n_eff);
        VjsAccess::Sparse { cap, cache }
    } else {
        let mut vjs: Vec<Vec<K>> = vec![vec![K::ZERO; s.m]; t_mats];
        for j in 0..t_mats {
            s.matrices[j].add_mul_transpose_into(&chi_r, &mut vjs[j], n_eff);
        }
        VjsAccess::Dense(vjs)
    };

    let bF = F::from_u64(params.b as u64);
    let bK = K::from(bF);

    let b_u = params.b as u128;
    let mut B_u: u128 = 1;
    for _ in 0..k_dec {
        B_u = B_u.saturating_mul(b_u);
    }
    let p: u128 = F::ORDER_U64 as u128;

    let z_rows: Vec<&[F]> = (0..D).map(|r| Z_mix.row(r)).collect();

    struct Acc {
        commit: Vec<[F; D]>,
        y_ring: Vec<[K; D]>,
        y_zcol: Vec<[K; D]>,
        any_nonzero: Vec<bool>,
        vj: Vec<K>,
        digits: Vec<i32>,
        rot_next: [F; D],
        err: Option<String>,
    }

    impl Acc {
        fn new(k_dec: usize, kappa: usize, t: usize) -> Self {
            Self {
                commit: vec![[F::ZERO; D]; k_dec * kappa],
                y_ring: vec![[K::ZERO; D]; k_dec * t],
                y_zcol: vec![[K::ZERO; D]; k_dec],
                any_nonzero: vec![false; k_dec],
                vj: vec![K::ZERO; t],
                digits: vec![0i32; k_dec * D],
                rot_next: [F::ZERO; D],
                err: None,
            }
        }

        #[cfg(any(not(target_arch = "wasm32"), feature = "wasm-threads"))]
        fn add_inplace(&mut self, rhs: &Acc, k_dec: usize, kappa: usize, t: usize) {
            for (dst, src) in self.commit.iter_mut().zip(rhs.commit.iter()) {
                for r in 0..D {
                    dst[r] += src[r];
                }
            }
            for (dst, src) in self.y_ring.iter_mut().zip(rhs.y_ring.iter()) {
                for r in 0..D {
                    dst[r] += src[r];
                }
            }
            for (dst, src) in self.y_zcol.iter_mut().zip(rhs.y_zcol.iter()) {
                for r in 0..D {
                    dst[r] += src[r];
                }
            }
            for i in 0..k_dec {
                self.any_nonzero[i] |= rhs.any_nonzero[i];
            }
            if self.err.is_none() {
                self.err = rhs.err.clone();
            }
            let _ = (k_dec, kappa, t);
        }
    }

    let m_phys = m_commit;
    let b_i64 = params.b as i64;
    let b_i128 = params.b as i128;

    #[inline]
    fn logical_col_for_entry(
        layout: neo_reductions::common::WitnessMatLayout,
        col_phys: usize,
        rho: usize,
        logical_m: usize,
    ) -> Option<usize> {
        match layout {
            neo_reductions::common::WitnessMatLayout::SuperneoPacked => {
                let col = col_phys
                    .checked_mul(D)
                    .and_then(|v| v.checked_add(rho))
                    .unwrap_or(usize::MAX);
                if col < logical_m {
                    Some(col)
                } else {
                    None
                }
            }
            neo_reductions::common::WitnessMatLayout::DenseUnpacked => {
                if col_phys < logical_m {
                    Some(col_phys)
                } else {
                    None
                }
            }
        }
    }

    #[inline]
    fn rot_step_phi_81(cur: &[F; D], next: &mut [F; D]) {
        let last = cur[D - 1];
        next[0] = F::ZERO;
        next[1..D].copy_from_slice(&cur[..(D - 1)]);
        next[0] -= last;
        next[27] -= last;
    }

    #[inline]
    fn acc_add_assign(acc: &mut [F; D], col: &[F; D]) {
        type P = <F as Field>::Packing;
        let prefix_len = D - (D % P::WIDTH);
        let (acc_prefix, acc_suffix) = acc.split_at_mut(prefix_len);
        let (col_prefix, col_suffix) = col.split_at(prefix_len);

        for (a, b) in P::pack_slice_mut(acc_prefix)
            .iter_mut()
            .zip(P::pack_slice(col_prefix).iter())
        {
            *a += *b;
        }
        for (a, &b) in acc_suffix.iter_mut().zip(col_suffix.iter()) {
            *a += b;
        }
    }

    #[inline]
    fn acc_sub_assign(acc: &mut [F; D], col: &[F; D]) {
        type P = <F as Field>::Packing;
        let prefix_len = D - (D % P::WIDTH);
        let (acc_prefix, acc_suffix) = acc.split_at_mut(prefix_len);
        let (col_prefix, col_suffix) = col.split_at(prefix_len);

        for (a, b) in P::pack_slice_mut(acc_prefix)
            .iter_mut()
            .zip(P::pack_slice(col_prefix).iter())
        {
            *a -= *b;
        }
        for (a, &b) in acc_suffix.iter_mut().zip(col_suffix.iter()) {
            *a -= b;
        }
    }

    #[inline]
    fn acc_mul_add_assign(acc: &mut [F; D], col: &[F; D], scalar: F) {
        type P = <F as Field>::Packing;
        let prefix_len = D - (D % P::WIDTH);
        let (acc_prefix, acc_suffix) = acc.split_at_mut(prefix_len);
        let (col_prefix, col_suffix) = col.split_at(prefix_len);
        let scalar_p: P = scalar.into();

        for (a, b) in P::pack_slice_mut(acc_prefix)
            .iter_mut()
            .zip(P::pack_slice(col_prefix).iter())
        {
            *a += *b * scalar_p;
        }
        for (a, &b) in acc_suffix.iter_mut().zip(col_suffix.iter()) {
            *a += b * scalar;
        }
    }

    let (kappa, acc) = match &pp_access {
        PpAccess::Loaded { pp } => {
            let kappa = pp.kappa;
            let process_col = |mut st: Acc, col: usize| -> Acc {
                if st.err.is_some() {
                    return st;
                }

                for rho in 0..D {
                    let u = z_rows[rho][col].as_canonical_u64() as u128;
                    if B_u <= i64::MAX as u128 {
                        let val_opt: Option<i64> = if u < B_u {
                            Some(u as i64)
                        } else if p.checked_sub(u).map(|w| w < B_u).unwrap_or(false) {
                            Some(-((p - u) as i64))
                        } else {
                            None
                        };
                        let mut v = match val_opt {
                            Some(v) => v,
                            None => {
                                st.err = Some(format!(
                                    "DEC split: Z_mix[{},{}] is out of range for k_rho={}, b={}",
                                    rho, col, k_dec, params.b
                                ));
                                return st;
                            }
                        };
                        for i in 0..k_dec {
                            if v == 0 {
                                st.digits[i * D + rho] = 0;
                                continue;
                            }
                            let (r_i, q) = balanced_divrem_i64(v, b_i64);
                            if r_i != 0 {
                                st.any_nonzero[i] = true;
                            }
                            st.digits[i * D + rho] = r_i as i32;
                            v = q;
                        }
                        if v != 0 {
                            st.err = Some(format!(
                                "DEC split: Z_mix[{},{}] needs more than k_rho={} digits in base b={}",
                                rho, col, k_dec, params.b
                            ));
                            return st;
                        }
                    } else {
                        let val_opt: Option<i128> = if u < B_u {
                            Some(u as i128)
                        } else if p.checked_sub(u).map(|w| w < B_u).unwrap_or(false) {
                            Some(-((p - u) as i128))
                        } else {
                            None
                        };
                        let mut v = match val_opt {
                            Some(v) => v,
                            None => {
                                st.err = Some(format!(
                                    "DEC split: Z_mix[{},{}] is out of range for k_rho={}, b={}",
                                    rho, col, k_dec, params.b
                                ));
                                return st;
                            }
                        };
                        for i in 0..k_dec {
                            if v == 0 {
                                st.digits[i * D + rho] = 0;
                                continue;
                            }
                            let (r_i, q) = balanced_divrem_i128(v, b_i128);
                            if r_i != 0 {
                                st.any_nonzero[i] = true;
                            }
                            st.digits[i * D + rho] = r_i as i32;
                            v = q;
                        }
                        if v != 0 {
                            st.err = Some(format!(
                                "DEC split: Z_mix[{},{}] needs more than k_rho={} digits in base b={}",
                                rho, col, k_dec, params.b
                            ));
                            return st;
                        }
                    }
                }

                for rho in 0..D {
                    let logical_col = logical_col_for_entry(z_layout, col, rho, s.m);
                    if let Some(logical_col) = logical_col {
                        match &vjs_access {
                            VjsAccess::Dense(vjs) => {
                                for j in 0..t_mats {
                                    st.vj[j] = vjs[j][logical_col];
                                }
                            }
                            VjsAccess::Sparse { cap, cache } => {
                                for j in 0..t_mats {
                                    st.vj[j] = if let Some(csc) = cache.csc(j) {
                                        let mut sum = K::ZERO;
                                        let s_ptr = csc.col_ptr[logical_col];
                                        let e_ptr = csc.col_ptr[logical_col + 1];
                                        for k in s_ptr..e_ptr {
                                            let r = csc.row_idx[k];
                                            if r < n_eff {
                                                sum += K::from(csc.vals[k]) * chi_r[r];
                                            }
                                        }
                                        sum
                                    } else if logical_col < *cap {
                                        chi_r[logical_col]
                                    } else {
                                        K::ZERO
                                    };
                                }
                            }
                        }
                    } else {
                        for j in 0..t_mats {
                            st.vj[j] = K::ZERO;
                        }
                    }

                    for i in 0..k_dec {
                        let digit = st.digits[i * D + rho];
                        if digit == 0 {
                            continue;
                        }
                        let y_base = i * t_mats;
                        for j in 0..t_mats {
                            let vj = st.vj[j];
                            if vj != K::ZERO {
                                match digit {
                                    1 => st.y_ring[y_base + j][rho] += vj,
                                    -1 => st.y_ring[y_base + j][rho] -= vj,
                                    _ => st.y_ring[y_base + j][rho] += vj.scale_base(f_from_i64(digit as i64)),
                                }
                            }
                        }
                    }

                    if let Some(logical_col) = logical_col {
                        if !chi_s.is_empty() {
                            let w_col = chi_s[logical_col];
                            if w_col != K::ZERO {
                                for i in 0..k_dec {
                                    let digit = st.digits[i * D + rho];
                                    if digit == 0 {
                                        continue;
                                    }
                                    match digit {
                                        1 => st.y_zcol[i][rho] += w_col,
                                        -1 => st.y_zcol[i][rho] -= w_col,
                                        _ => st.y_zcol[i][rho] += w_col.scale_base(f_from_i64(digit as i64)),
                                    }
                                }
                            }
                        }
                    }
                }

                for kr in 0..kappa {
                    let mut rot_col = neo_math::ring::cf(pp.m_rows[kr][col]);
                    for rho in 0..D {
                        for i in 0..k_dec {
                            let digit = st.digits[i * D + rho];
                            if digit == 0 {
                                continue;
                            }
                            let acc = &mut st.commit[i * kappa + kr];
                            match digit {
                                1 => acc_add_assign(acc, &rot_col),
                                -1 => acc_sub_assign(acc, &rot_col),
                                _ => acc_mul_add_assign(acc, &rot_col, f_from_i64(digit as i64)),
                            }
                        }
                        rot_step_phi_81(&rot_col, &mut st.rot_next);
                        core::mem::swap(&mut rot_col, &mut st.rot_next);
                    }
                }

                st
            };

            let acc = {
                #[cfg(any(not(target_arch = "wasm32"), feature = "wasm-threads"))]
                {
                    (0..m_phys)
                        .into_par_iter()
                        .fold(|| Acc::new(k_dec, kappa, t_mats), |st, col| process_col(st, col))
                        .reduce(
                            || Acc::new(k_dec, kappa, t_mats),
                            |mut a, b| {
                                if a.err.is_none() {
                                    a.add_inplace(&b, k_dec, kappa, t_mats);
                                }
                                a
                            },
                        )
                }
                #[cfg(all(target_arch = "wasm32", not(feature = "wasm-threads")))]
                {
                    let mut st = Acc::new(k_dec, kappa, t_mats);
                    for col in 0..m_phys {
                        st = process_col(st, col);
                    }
                    st
                }
            };
            (kappa, acc)
        }
        PpAccess::Seeded {
            kappa,
            chunk_size,
            chunk_seeds_by_row,
        } => {
            let kappa = *kappa;
            let chunk_size = *chunk_size;
            let num_chunks = m_phys.div_ceil(chunk_size);

            let process_chunk = |mut st: Acc, chunk_idx: usize| -> Acc {
                if st.err.is_some() {
                    return st;
                }

                let start = chunk_idx * chunk_size;
                let end = core::cmp::min(m_phys, start + chunk_size);

                let mut rngs: Vec<ChaCha8Rng> = (0..kappa)
                    .map(|kr| ChaCha8Rng::from_seed(chunk_seeds_by_row[kr][chunk_idx]))
                    .collect();

                for col in start..end {
                    for rho in 0..D {
                        let u = z_rows[rho][col].as_canonical_u64() as u128;
                        if B_u <= i64::MAX as u128 {
                            let val_opt: Option<i64> = if u < B_u {
                                Some(u as i64)
                            } else if p.checked_sub(u).map(|w| w < B_u).unwrap_or(false) {
                                Some(-((p - u) as i64))
                            } else {
                                None
                            };
                            let mut v = match val_opt {
                                Some(v) => v,
                                None => {
                                    st.err = Some(format!(
                                        "DEC split: Z_mix[{},{}] is out of range for k_rho={}, b={}",
                                        rho, col, k_dec, params.b
                                    ));
                                    return st;
                                }
                            };
                            for i in 0..k_dec {
                                if v == 0 {
                                    st.digits[i * D + rho] = 0;
                                    continue;
                                }
                                let (r_i, q) = balanced_divrem_i64(v, b_i64);
                                if r_i != 0 {
                                    st.any_nonzero[i] = true;
                                }
                                st.digits[i * D + rho] = r_i as i32;
                                v = q;
                            }
                            if v != 0 {
                                st.err = Some(format!(
                                    "DEC split: Z_mix[{},{}] needs more than k_rho={} digits in base b={}",
                                    rho, col, k_dec, params.b
                                ));
                                return st;
                            }
                        } else {
                            let val_opt: Option<i128> = if u < B_u {
                                Some(u as i128)
                            } else if p.checked_sub(u).map(|w| w < B_u).unwrap_or(false) {
                                Some(-((p - u) as i128))
                            } else {
                                None
                            };
                            let mut v = match val_opt {
                                Some(v) => v,
                                None => {
                                    st.err = Some(format!(
                                        "DEC split: Z_mix[{},{}] is out of range for k_rho={}, b={}",
                                        rho, col, k_dec, params.b
                                    ));
                                    return st;
                                }
                            };
                            for i in 0..k_dec {
                                if v == 0 {
                                    st.digits[i * D + rho] = 0;
                                    continue;
                                }
                                let (r_i, q) = balanced_divrem_i128(v, b_i128);
                                if r_i != 0 {
                                    st.any_nonzero[i] = true;
                                }
                                st.digits[i * D + rho] = r_i as i32;
                                v = q;
                            }
                            if v != 0 {
                                st.err = Some(format!(
                                    "DEC split: Z_mix[{},{}] needs more than k_rho={} digits in base b={}",
                                    rho, col, k_dec, params.b
                                ));
                                return st;
                            }
                        }
                    }

                    for rho in 0..D {
                        let logical_col = logical_col_for_entry(z_layout, col, rho, s.m);
                        if let Some(logical_col) = logical_col {
                            match &vjs_access {
                                VjsAccess::Dense(vjs) => {
                                    for j in 0..t_mats {
                                        st.vj[j] = vjs[j][logical_col];
                                    }
                                }
                                VjsAccess::Sparse { cap, cache } => {
                                    for j in 0..t_mats {
                                        st.vj[j] = if let Some(csc) = cache.csc(j) {
                                            let mut sum = K::ZERO;
                                            let s_ptr = csc.col_ptr[logical_col];
                                            let e_ptr = csc.col_ptr[logical_col + 1];
                                            for k in s_ptr..e_ptr {
                                                let r = csc.row_idx[k];
                                                if r < n_eff {
                                                    sum += K::from(csc.vals[k]) * chi_r[r];
                                                }
                                            }
                                            sum
                                        } else if logical_col < *cap {
                                            chi_r[logical_col]
                                        } else {
                                            K::ZERO
                                        };
                                    }
                                }
                            }
                        } else {
                            for j in 0..t_mats {
                                st.vj[j] = K::ZERO;
                            }
                        }

                        for i in 0..k_dec {
                            let digit = st.digits[i * D + rho];
                            if digit == 0 {
                                continue;
                            }
                            let y_base = i * t_mats;
                            for j in 0..t_mats {
                                let vj = st.vj[j];
                                if vj != K::ZERO {
                                    match digit {
                                        1 => st.y_ring[y_base + j][rho] += vj,
                                        -1 => st.y_ring[y_base + j][rho] -= vj,
                                        _ => st.y_ring[y_base + j][rho] += vj.scale_base(f_from_i64(digit as i64)),
                                    }
                                }
                            }
                        }

                        if let Some(logical_col) = logical_col {
                            if !chi_s.is_empty() {
                                let w_col = chi_s[logical_col];
                                if w_col != K::ZERO {
                                    for i in 0..k_dec {
                                        let digit = st.digits[i * D + rho];
                                        if digit == 0 {
                                            continue;
                                        }
                                        match digit {
                                            1 => st.y_zcol[i][rho] += w_col,
                                            -1 => st.y_zcol[i][rho] -= w_col,
                                            _ => st.y_zcol[i][rho] += w_col.scale_base(f_from_i64(digit as i64)),
                                        }
                                    }
                                }
                            }
                        }
                    }

                    for kr in 0..kappa {
                        let a_kr_col = sample_uniform_rq(&mut rngs[kr]);
                        let mut rot_col = neo_math::ring::cf(a_kr_col);
                        for rho in 0..D {
                            for i in 0..k_dec {
                                let digit = st.digits[i * D + rho];
                                if digit == 0 {
                                    continue;
                                }
                                let acc = &mut st.commit[i * kappa + kr];
                                match digit {
                                    1 => acc_add_assign(acc, &rot_col),
                                    -1 => acc_sub_assign(acc, &rot_col),
                                    _ => acc_mul_add_assign(acc, &rot_col, f_from_i64(digit as i64)),
                                }
                            }
                            rot_step_phi_81(&rot_col, &mut st.rot_next);
                            core::mem::swap(&mut rot_col, &mut st.rot_next);
                        }
                    }
                }

                st
            };

            let acc = {
                #[cfg(any(not(target_arch = "wasm32"), feature = "wasm-threads"))]
                {
                    (0..num_chunks)
                        .into_par_iter()
                        .fold(
                            || Acc::new(k_dec, kappa, t_mats),
                            |st, chunk_idx| process_chunk(st, chunk_idx),
                        )
                        .reduce(
                            || Acc::new(k_dec, kappa, t_mats),
                            |mut a, b| {
                                if a.err.is_none() {
                                    a.add_inplace(&b, k_dec, kappa, t_mats);
                                }
                                a
                            },
                        )
                }
                #[cfg(all(target_arch = "wasm32", not(feature = "wasm-threads")))]
                {
                    let mut st = Acc::new(k_dec, kappa, t_mats);
                    for chunk_idx in 0..num_chunks {
                        st = process_chunk(st, chunk_idx);
                    }
                    st
                }
            };
            (kappa, acc)
        }
    };

    if let Some(err) = acc.err {
        return Err(PiCcsError::ProtocolError(err));
    }

    let mut child_cs: Vec<Cmt> = Vec::with_capacity(k_dec);
    for i in 0..k_dec {
        if !acc.any_nonzero[i] {
            child_cs.push(Cmt::zeros(D, kappa));
            continue;
        }
        let mut c = Cmt::zeros(D, kappa);
        for kr in 0..kappa {
            c.col_mut(kr).copy_from_slice(&acc.commit[i * kappa + kr]);
        }
        child_cs.push(c);
    }

    let m_in = parent.m_in;
    let mut xs_row_major: Vec<Vec<F>> = vec![vec![F::ZERO; D * m_in]; k_dec];
    for col in 0..m_in {
        for rho in 0..D {
            let z_rc = neo_reductions::common::witness_mat_get_f(Z_mix, z_layout, s.m, rho, col);
            let u = z_rc.as_canonical_u64() as u128;
            if B_u <= i64::MAX as u128 {
                let val_opt: Option<i64> = if u < B_u {
                    Some(u as i64)
                } else if p.checked_sub(u).map(|w| w < B_u).unwrap_or(false) {
                    Some(-((p - u) as i64))
                } else {
                    None
                };
                let mut v = val_opt.ok_or_else(|| {
                    PiCcsError::ProtocolError(format!(
                        "DEC split(X): Z_mix[{},{}] out of range for k_rho={}, b={}",
                        rho, col, k_dec, params.b
                    ))
                })?;
                for i in 0..k_dec {
                    if v == 0 {
                        break;
                    }
                    let (r_i, q) = balanced_divrem_i64(v, b_i64);
                    xs_row_major[i][rho * m_in + col] = f_from_i64(r_i);
                    v = q;
                }
                if v != 0 {
                    return Err(PiCcsError::ProtocolError(format!(
                        "DEC split(X): Z_mix[{},{}] needs more than k_rho={} digits in base b={}",
                        rho, col, k_dec, params.b
                    )));
                }
            } else {
                let val_opt: Option<i128> = if u < B_u {
                    Some(u as i128)
                } else if p.checked_sub(u).map(|w| w < B_u).unwrap_or(false) {
                    Some(-((p - u) as i128))
                } else {
                    None
                };
                let mut v = val_opt.ok_or_else(|| {
                    PiCcsError::ProtocolError(format!(
                        "DEC split(X): Z_mix[{},{}] out of range for k_rho={}, b={}",
                        rho, col, k_dec, params.b
                    ))
                })?;
                for i in 0..k_dec {
                    if v == 0 {
                        break;
                    }
                    let (r_i, q) = balanced_divrem_i128(v, b_i128);
                    xs_row_major[i][rho * m_in + col] = f_from_i64(r_i as i64);
                    v = q;
                }
                if v != 0 {
                    return Err(PiCcsError::ProtocolError(format!(
                        "DEC split(X): Z_mix[{},{}] needs more than k_rho={} digits in base b={}",
                        rho, col, k_dec, params.b
                    )));
                }
            }
        }
    }

    let parent_r = parent.r.clone();
    let fold_digest = parent.fold_digest;

    let mut children: Vec<CeClaim<Cmt, F, K>> = Vec::with_capacity(k_dec);
    for i in 0..k_dec {
        let Xi = Mat::from_row_major(D, m_in, xs_row_major[i].clone());
        let mut y_i: Vec<Vec<K>> = Vec::with_capacity(t_mats);
        for j in 0..t_mats {
            let mut yj = vec![K::ZERO; d_pad];
            let row = &acc.y_ring[i * t_mats + j];
            for rho in 0..D {
                yj[rho] = row[rho];
            }
            y_i.push(yj);
        }
        let y_scalars_i = neo_reductions::common::ct_from_y_ring_for_ccs_m(&y_i, params, s.m);

        let y_zcol = if chi_s.is_empty() {
            Vec::new()
        } else {
            let mut yz = vec![K::ZERO; d_pad];
            let row = &acc.y_zcol[i];
            for rho in 0..D {
                yz[rho] = row[rho];
            }
            yz
        };

        children.push(CeClaim::<Cmt, F, K> {
            c_step_coords: vec![],
            u_offset: 0,
            u_len: 0,
            c: child_cs[i].clone(),
            X: Xi,
            r: parent_r.clone(),
            s_col: parent.s_col.clone(),
            y_ring: y_i,
            ct: y_scalars_i,
            aux_openings: Vec::new(),
            y_zcol,
            m_in,
            fold_digest,
        });
    }

    let mut ok_y = true;
    for j in 0..t_mats {
        let mut lhs = vec![K::ZERO; d_pad];
        let mut pow = K::ONE;
        for child in children.iter().take(k_dec) {
            for (lhs_t, child_t) in lhs.iter_mut().zip(child.y_ring[j].iter()).take(d_pad) {
                *lhs_t += pow * *child_t;
            }
            pow *= bK;
        }
        if lhs != parent.y_ring[j] {
            ok_y = false;
            break;
        }
    }

    if ok_y && !chi_s.is_empty() {
        let mut lhs = vec![K::ZERO; d_pad];
        let mut pow = K::ONE;
        for child in children.iter().take(k_dec) {
            for (lhs_t, child_t) in lhs.iter_mut().zip(child.y_zcol.iter()).take(d_pad) {
                *lhs_t += pow * *child_t;
            }
            pow *= bK;
        }
        if lhs != parent.y_zcol {
            ok_y = false;
        }
    }

    let mut lhs_X = Mat::zero(D, m_in, F::ZERO);
    let mut pow = F::ONE;
    for child in children.iter().take(k_dec) {
        for r in 0..D {
            for c in 0..m_in {
                lhs_X[(r, c)] += pow * child.X[(r, c)];
            }
        }
        pow *= bF;
    }
    let ok_X = lhs_X.as_slice() == parent.X.as_slice();

    let ok_c = combine_b_pows(&child_cs, params.b) == parent.c;
    Ok((children, child_cs, ok_y, ok_X, ok_c))
}

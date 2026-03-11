mod cases;

use std::fmt::Write as _;
use std::fs;
use std::path::PathBuf;

use cases::*;
use neo_math::ring::inf_norm;
use neo_math::{cf_inv, ct, superneo_bar_block, superneo_bar_matrix, Fq as F, Rq, D};
use p3_field::{Field, PrimeCharacteristicRing, PrimeField64};

fn deterministic_block(seed: u64) -> [F; D] {
    let mut out = [F::ZERO; D];
    let mut x = seed;
    for oi in &mut out {
        x = x
            .wrapping_mul(6364136223846793005)
            .wrapping_add(1442695040888963407);
        *oi = F::from_u64(x);
    }
    out
}

fn deterministic_vec(seed: u64, len: usize) -> Vec<F> {
    let mut out = Vec::with_capacity(len);
    let mut x = seed;
    for _ in 0..len {
        x = x
            .wrapping_mul(6364136223846793005)
            .wrapping_add(1442695040888963407);
        out.push(F::from_u64(x));
    }
    out
}

fn bounded_vec(seed: u64, len: usize, bound: i64) -> Vec<F> {
    let mut out = Vec::with_capacity(len);
    let mut x = seed;
    let width = (2 * bound + 1) as u64;
    for _ in 0..len {
        x = x
            .wrapping_mul(6364136223846793005)
            .wrapping_add(1442695040888963407);
        let centered = (x % width) as i64 - bound;
        out.push(from_balanced_i128(centered as i128));
    }
    out
}

fn dot(a: &[F; D], b: &[F; D]) -> F {
    let mut acc = F::ZERO;
    for i in 0..D {
        acc += a[i] * b[i];
    }
    acc
}

fn f_u64(x: F) -> u64 {
    x.as_canonical_u64()
}

fn field_modulus() -> i128 {
    F::ORDER_U64 as i128
}

fn to_balanced_i128(x: F) -> i128 {
    let q = field_modulus();
    let u = x.as_canonical_u64() as i128;
    let half = (q - 1) / 2;
    if u <= half {
        u
    } else {
        u - q
    }
}

fn from_balanced_i128(x: i128) -> F {
    let q = field_modulus();
    let mut r = x % q;
    if r < 0 {
        r += q;
    }
    F::from_u64(r as u64)
}

fn centered_abs_u64(x: F) -> u64 {
    to_balanced_i128(x).unsigned_abs() as u64
}

fn split_balanced_scalar(a: F, b: u64, k: usize) -> Vec<F> {
    assert!(b >= 2);
    let bi = b as i128;
    let half = bi / 2;
    let mut cur = to_balanced_i128(a);
    let mut out = Vec::with_capacity(k);
    for _ in 0..k {
        let mut residue = cur % bi;
        if residue < 0 {
            residue += bi;
        }
        let digit = if residue < half {
            residue
        } else if residue == half {
            if cur < 0 {
                residue - bi
            } else {
                residue
            }
        } else {
            residue - bi
        };
        out.push(from_balanced_i128(digit));
        cur = (cur - digit) / bi;
    }
    out
}

fn split_balanced_vec(z: &[F], b: u64, k: usize) -> Vec<Vec<F>> {
    let mut out = vec![vec![F::ZERO; z.len()]; k];
    for (j, &zij) in z.iter().enumerate() {
        let digits = split_balanced_scalar(zij, b, k);
        for i in 0..k {
            out[i][j] = digits[i];
        }
    }
    out
}

fn recompose_split_digits(digits: &[Vec<F>], b: u64) -> Vec<F> {
    if digits.is_empty() {
        return vec![];
    }
    let m = digits[0].len();
    let mut out = vec![F::ZERO; m];
    let mut scale = F::ONE;
    let b_f = F::from_u64(b);
    for row in digits {
        for j in 0..m {
            out[j] += scale * row[j];
        }
        scale *= b_f;
    }
    out
}

fn digits_within_base(digits: &[Vec<F>], b: u64) -> bool {
    digits
        .iter()
        .all(|row| row.iter().all(|&x| centered_abs_u64(x) < b))
}

fn eq_poly(x: &[F], y: &[F]) -> F {
    assert_eq!(x.len(), y.len());
    let mut acc = F::ONE;
    for i in 0..x.len() {
        let xi = x[i];
        let yi = y[i];
        let term = xi * yi + (F::ONE - xi) * (F::ONE - yi);
        acc *= term;
    }
    acc
}

fn bool_vec(mask: usize, ell: usize) -> Vec<F> {
    let mut out = vec![F::ZERO; ell];
    for (i, oi) in out.iter_mut().enumerate() {
        let bit = (mask >> i) & 1;
        *oi = if bit == 0 { F::ZERO } else { F::ONE };
    }
    out
}

fn chi_weight(r: &[F], j: usize) -> F {
    let mut w = F::ONE;
    for (i, &ri) in r.iter().enumerate() {
        let bit = (j >> i) & 1;
        let term = if bit == 1 { ri } else { F::ONE - ri };
        w *= term;
    }
    w
}

fn r_hat(r: &[F], n: usize) -> Vec<F> {
    (0..n).map(|j| chi_weight(r, j)).collect()
}

fn dot_vec(a: &[F], b: &[F]) -> F {
    assert_eq!(a.len(), b.len());
    let mut acc = F::ZERO;
    for i in 0..a.len() {
        acc += a[i] * b[i];
    }
    acc
}

fn mle_by_inner(v: &[F], r: &[F]) -> F {
    dot_vec(v, &r_hat(r, v.len()))
}

fn mle_by_folding(v: &[F], r: &[F]) -> F {
    let mut cur = v.to_vec();
    for &ri in r {
        assert_eq!(cur.len() % 2, 0);
        let mut next = vec![F::ZERO; cur.len() / 2];
        for i in 0..next.len() {
            next[i] = cur[2 * i] * (F::ONE - ri) + cur[2 * i + 1] * ri;
        }
        cur = next;
    }
    assert_eq!(cur.len(), 1);
    cur[0]
}

fn chunk_exact(z: &[F], chunk: usize) -> Vec<Vec<F>> {
    assert_eq!(z.len() % chunk, 0);
    let mut out = Vec::with_capacity(z.len() / chunk);
    for c in z.chunks_exact(chunk) {
        out.push(c.to_vec());
    }
    out
}

fn add_vec(a: &[F], b: &[F]) -> Vec<F> {
    assert_eq!(a.len(), b.len());
    let mut out = vec![F::ZERO; a.len()];
    for i in 0..a.len() {
        out[i] = a[i] + b[i];
    }
    out
}

fn scale_vec(a: &[F], s: F) -> Vec<F> {
    a.iter().map(|&x| s * x).collect()
}

fn vec_add_len_guard(a: &[F], b: &[F]) -> Vec<F> {
    if a.len() != b.len() {
        return vec![];
    }
    add_vec(a, b)
}

fn dot_by_size(row: &[F], v: &[F]) -> F {
    if row.len() != v.len() {
        return F::ZERO;
    }
    dot_vec(row, v)
}

fn vec_module_map(z: &[F], factor: F, bias: &[F]) -> Vec<F> {
    vec_add_len_guard(&scale_vec(z, factor), bias)
}

fn scalar_module_map(z: &[F], weights: &[F], bias: F) -> F {
    dot_by_size(weights, z) + bias
}

fn vec_module_check_pair(factor: F, bias: &[F], scalar: F, x: &[F], y: &[F]) -> bool {
    let add_ok = vec_module_map(&vec_add_len_guard(x, y), factor, bias)
        == vec_add_len_guard(&vec_module_map(x, factor, bias), &vec_module_map(y, factor, bias));
    let scale_ok =
        vec_module_map(&scale_vec(x, scalar), factor, bias) == scale_vec(&vec_module_map(x, factor, bias), scalar);
    add_ok && scale_ok
}

fn scalar_module_check_pair(weights: &[F], bias: F, scalar: F, x: &[F], y: &[F]) -> bool {
    let add_ok = scalar_module_map(&vec_add_len_guard(x, y), weights, bias)
        == scalar_module_map(x, weights, bias) + scalar_module_map(y, weights, bias);
    let scale_ok =
        scalar_module_map(&scale_vec(x, scalar), weights, bias) == scalar * scalar_module_map(x, weights, bias);
    add_ok && scale_ok
}

fn to_block(xs: &[F]) -> [F; D] {
    assert_eq!(xs.len(), D);
    let mut out = [F::ZERO; D];
    out.copy_from_slice(xs);
    out
}

fn bar_lift_vec(v: &[F]) -> Vec<F> {
    assert_eq!(v.len() % D, 0);
    let mut out = Vec::with_capacity(v.len());
    for blk in v.chunks_exact(D) {
        let lifted = superneo_bar_block(to_block(blk));
        out.extend_from_slice(&lifted);
    }
    out
}

fn bar_lift_matrix(m: &[Vec<F>]) -> Vec<Vec<F>> {
    m.iter().map(|row| bar_lift_vec(row)).collect()
}

fn row_ct_bar_prod(row: &[F], z: &[F]) -> F {
    assert_eq!(row.len(), z.len());
    assert_eq!(row.len() % D, 0);
    let mut acc = F::ZERO;
    for (a_blk, z_blk) in row.chunks_exact(D).zip(z.chunks_exact(D)) {
        let a_bar = superneo_bar_block(to_block(a_blk));
        let term = ct(&cf_inv(a_bar).mul(&cf_inv(to_block(z_blk))));
        acc += term;
    }
    acc
}

fn matrix_vec_direct(m: &[Vec<F>], z: &[F]) -> Vec<F> {
    m.iter().map(|row| dot_vec(row, z)).collect()
}

fn matrix_vec_ct_bar(m: &[Vec<F>], z: &[F]) -> Vec<F> {
    m.iter().map(|row| row_ct_bar_prod(row, z)).collect()
}

fn add_block(a: [F; D], b: [F; D]) -> [F; D] {
    let mut out = [F::ZERO; D];
    for i in 0..D {
        out[i] = a[i] + b[i];
    }
    out
}

fn scale_block(a: [F; D], s: F) -> [F; D] {
    let mut out = [F::ZERO; D];
    for i in 0..D {
        out[i] = s * a[i];
    }
    out
}

fn row_bar_mz_ring(row: &[F], z: &[F]) -> [F; D] {
    assert_eq!(row.len(), z.len());
    assert_eq!(row.len() % D, 0);
    let mut acc = [F::ZERO; D];
    for (a_blk, z_blk) in row.chunks_exact(D).zip(z.chunks_exact(D)) {
        let a_bar = superneo_bar_block(to_block(a_blk));
        let term = cf_inv(a_bar).mul(&cf_inv(to_block(z_blk))).0;
        acc = add_block(acc, term);
    }
    acc
}

fn bar_mz_ring(matrix: &[Vec<F>], z: &[F]) -> Vec<[F; D]> {
    matrix.iter().map(|row| row_bar_mz_ring(row, z)).collect()
}

fn eval_ring_vector(ys: &[[F; D]], weights: &[F]) -> [F; D] {
    assert_eq!(ys.len(), weights.len());
    let mut acc = [F::ZERO; D];
    for i in 0..ys.len() {
        acc = add_block(acc, scale_block(ys[i], weights[i]));
    }
    acc
}

fn eval_coeff_rows(ys: &[[F; D]], weights: &[F]) -> [F; D] {
    assert_eq!(ys.len(), weights.len());
    let mut out = [F::ZERO; D];
    for ell in 0..D {
        let mut acc = F::ZERO;
        for i in 0..ys.len() {
            acc += ys[i][ell] * weights[i];
        }
        out[ell] = acc;
    }
    out
}

fn eval_bar_mz_at(matrix: &[Vec<F>], z: &[F], r: &[F]) -> [F; D] {
    let ys = bar_mz_ring(matrix, z);
    let weights = r_hat(r, ys.len());
    eval_ring_vector(&ys, &weights)
}

fn norm_inf_vec(v: &[F]) -> u64 {
    v.iter().map(|&x| centered_abs_u64(x)).max().unwrap_or(0)
}

fn sub_vec(a: &[F], b: &[F]) -> Vec<F> {
    assert_eq!(a.len(), b.len());
    let mut out = vec![F::ZERO; a.len()];
    for i in 0..a.len() {
        out[i] = a[i] - b[i];
    }
    out
}

fn strong_sampling_set(cset: &[Vec<F>], b_inv: u64) -> bool {
    for i in 0..cset.len() {
        for j in (i + 1)..cset.len() {
            let diff = sub_vec(&cset[i], &cset[j]);
            if norm_inf_vec(&diff) >= b_inv {
                return false;
            }
        }
    }
    true
}

fn max_rho_norm(cset: &[Vec<F>]) -> u64 {
    cset.iter().map(|rho| norm_inf_vec(rho)).max().unwrap_or(0)
}

fn empirical_expansion(cset: &[Vec<F>], samples: &[Vec<F>]) -> u64 {
    let mut max_ratio = 0u64;
    for rho in cset {
        for v in samples {
            let denom = norm_inf_vec(v).max(1);
            let num = norm_inf_vec(&Rq(to_block(rho)).mul(&Rq(to_block(v))).0);
            max_ratio = max_ratio.max(num / denom);
        }
    }
    max_ratio
}

fn bool_mask(z: &[F]) -> Option<usize> {
    let mut mask = 0usize;
    for (i, &zi) in z.iter().enumerate() {
        if zi == F::ZERO {
            continue;
        } else if zi == F::ONE {
            mask |= 1 << i;
        } else {
            return None;
        }
    }
    Some(mask)
}

fn eq_lift_from_table(q_vals: &[F], z: &[F]) -> F {
    let ell = z.len();
    assert_eq!(q_vals.len(), 1usize << ell);
    let mut acc = F::ZERO;
    for mask in 0..q_vals.len() {
        let x = bool_vec(mask, ell);
        acc += eq_poly(&x, z) * q_vals[mask];
    }
    acc
}

fn fmt_nat_array(vals: &[u64]) -> String {
    let mut s = String::new();
    s.push_str("#[");
    for (i, v) in vals.iter().enumerate() {
        if i != 0 {
            s.push_str(", ");
        }
        let _ = write!(s, "{}", v);
    }
    s.push(']');
    s
}

fn fmt_nat_array2(vals: &[Vec<u64>]) -> String {
    let mut s = String::new();
    s.push_str("#[");
    for (i, row) in vals.iter().enumerate() {
        if i != 0 {
            s.push_str(", ");
        }
        s.push_str(&fmt_nat_array(row));
    }
    s.push(']');
    s
}

fn fmt_nat_array3(vals: &[Vec<Vec<u64>>]) -> String {
    let mut s = String::new();
    s.push_str("#[");
    for (i, mat) in vals.iter().enumerate() {
        if i != 0 {
            s.push_str(", ");
        }
        s.push_str(&fmt_nat_array2(mat));
    }
    s.push(']');
    s
}

fn fmt_bool(v: bool) -> &'static str {
    if v {
        "true"
    } else {
        "false"
    }
}

fn fmt_nat_mat(vals: &[[u64; D]; D]) -> String {
    let mut s = String::new();
    s.push_str("#[\n");
    for row in vals.iter() {
        let row_vec: Vec<u64> = row.to_vec();
        let _ = writeln!(s, "  {},", fmt_nat_array(&row_vec));
    }
    s.push(']');
    s
}

fn poly_eval(coeffs: &[F], x: F) -> F {
    if coeffs.is_empty() {
        return F::ZERO;
    }
    let mut result = coeffs[coeffs.len() - 1];
    for &c in coeffs.iter().rev().skip(1) {
        result = result * x + c;
    }
    result
}

fn interpolate_from_evals(xs: &[F], ys: &[F]) -> Vec<F> {
    assert_eq!(xs.len(), ys.len());
    let n = xs.len();
    let mut coeffs = vec![F::ZERO; n];

    for i in 0..n {
        let mut numer = vec![F::ZERO; n];
        numer[0] = F::ONE;
        let mut cur_deg = 0usize;

        for (j, &xj) in xs.iter().enumerate() {
            if i == j {
                continue;
            }
            let mut next = vec![F::ZERO; n];
            for d in 0..=cur_deg {
                next[d + 1] += numer[d];
                next[d] -= xj * numer[d];
            }
            numer = next;
            cur_deg += 1;
        }

        let mut denom = F::ONE;
        for (j, &xj) in xs.iter().enumerate() {
            if i != j {
                denom *= xs[i] - xj;
            }
        }

        let scale = ys[i] * denom.inverse();
        for d in 0..=cur_deg {
            coeffs[d] += scale * numer[d];
        }
    }

    coeffs
}

fn main() {
    let mut super_cases = Vec::new();
    for round in 0..8u64 {
        let a = deterministic_block(0x1234_5678_9abc_def0 ^ round);
        let b = deterministic_block(0xfedc_ba98_7654_3210 ^ (round.wrapping_mul(17)));
        let abar = superneo_bar_block(a);
        let lhs = ct(&cf_inv(abar).mul(&cf_inv(b)));
        let rhs = dot(&a, &b);
        assert_eq!(lhs, rhs);
        super_cases.push(SuperNeoCase {
            a,
            b,
            expected_ct: lhs,
            expected_dot: rhs,
        });
    }

    let mut mul_cases = Vec::new();
    for round in 0..4u64 {
        let a = deterministic_block(0xdead_beef_0000_0000 ^ (round * 9));
        let b = deterministic_block(0x1111_2222_3333_4444 ^ (round * 13));
        let expected = Rq(a).mul(&Rq(b)).0;
        mul_cases.push(RingMulCase { a, b, expected });
    }

    let mut norm_cases = Vec::new();
    for round in 0..8u64 {
        let a = deterministic_block(0xbead_feed_9000_0000 ^ (round * 7));
        let expected_norm = inf_norm(&Rq(a)) as u64;
        norm_cases.push(NormCase { a, expected_norm });
    }

    let mut split_cases = Vec::new();
    for (seed, base, k, len, bound) in [
        (0x1010_2020_3030_4040u64, 2u64, 8usize, 10usize, 90i64),
        (0x5151_6262_7373_8484u64, 3u64, 7usize, 9usize, 400i64),
        (0x9191_a2a2_b3b3_c4c4u64, 5u64, 6usize, 8usize, 2000i64),
    ] {
        let input = bounded_vec(seed, len, bound);
        let expected_digits = split_balanced_vec(&input, base, k);
        let expected_recomposed = recompose_split_digits(&expected_digits, base);
        assert_eq!(expected_recomposed, input);
        assert!(digits_within_base(&expected_digits, base));
        split_cases.push(SplitCase {
            input,
            base,
            k: k as u64,
            expected_digits,
            expected_recomposed,
        });
    }

    let mut eq_cases = Vec::new();
    let ell = 3usize;
    for x_mask in 0..(1usize << ell) {
        for y_mask in 0..(1usize << ell) {
            let x = bool_vec(x_mask, ell);
            let y = bool_vec(y_mask, ell);
            let expected = eq_poly(&x, &y);
            let want = if x_mask == y_mask { F::ONE } else { F::ZERO };
            assert_eq!(expected, want);
            eq_cases.push(EqCase { x, y, expected });
        }
    }
    for round in 0..4u64 {
        let x = deterministic_vec(0xaaaa_0000_0000_0000 ^ round, 4);
        let y = deterministic_vec(0xbbbb_0000_0000_0000 ^ (round * 5), 4);
        let expected = eq_poly(&x, &y);
        eq_cases.push(EqCase { x, y, expected });
    }

    let mut mle_cases = Vec::new();
    for round in 0..6u64 {
        let r = deterministic_vec(0x1357_2468_0000_0000 ^ (round * 11), 3);
        let v = deterministic_vec(0x2468_1357_0000_0000 ^ (round * 13), 8);
        let expected_inner = mle_by_inner(&v, &r);
        let expected_fold = mle_by_folding(&v, &r);
        assert_eq!(expected_inner, expected_fold);
        mle_cases.push(MleCase {
            v,
            r,
            expected_inner,
            expected_fold,
        });
    }

    let mut embedding_vec_cases = Vec::new();
    for round in 0..3u64 {
        let blocks = 2 + (round as usize % 2);
        let input = deterministic_vec(0x8888_7777_6666_5555 ^ (round * 19), blocks * D);
        let expected_blocks = chunk_exact(&input, D);
        embedding_vec_cases.push(EmbeddingVecCase { input, expected_blocks });
    }

    let mut embedding_matrix_cases = Vec::new();
    for round in 0..2u64 {
        let rows = 2 + round as usize;
        let cols = 2 * D;
        let mut input = Vec::with_capacity(rows);
        for r in 0..rows {
            input.push(deterministic_vec(
                0x1111_eeee_dddd_cccc ^ ((round as u64) * 31) ^ (r as u64),
                cols,
            ));
        }
        let expected_blocks: Vec<Vec<Vec<F>>> = input.iter().map(|row| chunk_exact(row, D)).collect();
        embedding_matrix_cases.push(EmbeddingMatrixCase { input, expected_blocks });
    }

    let mut bar_lift_vec_cases = Vec::new();
    for round in 0..4u64 {
        let blocks = 2 + (round as usize % 2);
        let len = blocks * D;
        let v = deterministic_vec(0x4444_aaaa_2222_9999 ^ (round * 7), len);
        let w = deterministic_vec(0x2222_bbbb_6666_3333 ^ (round * 9), len);
        let scalar = F::from_u64(3 + round);

        let expected_lift_v = bar_lift_vec(&v);
        let expected_lift_w = bar_lift_vec(&w);
        let expected_lift_add = bar_lift_vec(&add_vec(&v, &w));
        let expected_lift_scale = bar_lift_vec(&scale_vec(&v, scalar));

        assert_eq!(expected_lift_add, add_vec(&expected_lift_v, &expected_lift_w));
        assert_eq!(expected_lift_scale, scale_vec(&expected_lift_v, scalar));

        bar_lift_vec_cases.push(BarLiftVecCase {
            v,
            w,
            scalar,
            expected_lift_v,
            expected_lift_w,
            expected_lift_add,
            expected_lift_scale,
        });
    }

    let mut bar_lift_matrix_cases = Vec::new();
    for round in 0..3u64 {
        let rows = 2 + (round as usize % 2);
        let cols = (2 + (round as usize % 2)) * D;
        let mut input = Vec::with_capacity(rows);
        for r in 0..rows {
            input.push(deterministic_vec(
                0xabcd_dcba_1111_0000 ^ (round * 17) ^ (r as u64),
                cols,
            ));
        }
        let expected_lifted = bar_lift_matrix(&input);
        bar_lift_matrix_cases.push(BarLiftMatrixCase { input, expected_lifted });
    }

    let mut matrix_transform_cases = Vec::new();
    for round in 0..4u64 {
        let rows = 2 + (round as usize % 2);
        let cols = (2 + (round as usize % 2)) * D;
        let mut matrix = Vec::with_capacity(rows);
        for r in 0..rows {
            matrix.push(deterministic_vec(
                0x7777_1111_9999_5555 ^ (round * 13) ^ (r as u64),
                cols,
            ));
        }
        let z = deterministic_vec(0x1234_ffff_7777_aaaa ^ (round * 29), cols);
        let expected_mz = matrix_vec_direct(&matrix, &z);
        let expected_ct_bar_mz = matrix_vec_ct_bar(&matrix, &z);
        assert_eq!(expected_mz, expected_ct_bar_mz);
        matrix_transform_cases.push(MatrixTransformCase {
            matrix,
            z,
            expected_mz,
            expected_ct_bar_mz,
        });
    }

    let mut eval_link_cases = Vec::new();
    for round in 0..2u64 {
        let rows = 4usize;
        let cols = 2 * D;
        let mut matrix = Vec::with_capacity(rows);
        for r in 0..rows {
            matrix.push(deterministic_vec(
                0xeeee_1111_2222_3333 ^ (round * 41) ^ (r as u64),
                cols,
            ));
        }
        let z = deterministic_vec(0x9999_0000_abcd_1234 ^ (round * 23), cols);
        let r = deterministic_vec(0x5555_aaaa_0f0f_f0f0 ^ (round * 31), 2);
        let ys = bar_mz_ring(&matrix, &z);
        let weights = r_hat(&r, ys.len());
        let y = eval_ring_vector(&ys, &weights);
        let coeff_side = eval_coeff_rows(&ys, &weights);
        assert_eq!(y, coeff_side);
        eval_link_cases.push(EvalLinkCase {
            matrix,
            z,
            r,
            expected_y: y.to_vec(),
            expected_ct_y: y[0],
        });
    }

    let mut eval_hom_cases = Vec::new();
    for round in 0..2u64 {
        let rows = 4usize;
        let cols = 2 * D;
        let mut matrix = Vec::with_capacity(rows);
        for r in 0..rows {
            matrix.push(deterministic_vec(
                0x1212_3434_5656_7878 ^ (round * 17) ^ (r as u64),
                cols,
            ));
        }
        let z1 = deterministic_vec(0x9876_abcd_1111_2222 ^ (round * 13), cols);
        let z2 = deterministic_vec(0x1357_2468_3333_4444 ^ (round * 29), cols);
        let r = deterministic_vec(0xaaaa_9999_8888_7777 ^ (round * 7), 2);
        let rho1 = F::from_u64(3 + round);
        let rho2 = F::from_u64(11 + 2 * round);

        let y1 = eval_bar_mz_at(&matrix, &z1, &r);
        let y2 = eval_bar_mz_at(&matrix, &z2, &r);
        let y_lin = add_block(scale_block(y1, rho1), scale_block(y2, rho2));
        let z_star = add_vec(&scale_vec(&z1, rho1), &scale_vec(&z2, rho2));
        let y_direct = eval_bar_mz_at(&matrix, &z_star, &r);
        assert_eq!(y_lin, y_direct);
        eval_hom_cases.push(EvalHomCase {
            matrix,
            z1,
            z2,
            r,
            rho1,
            rho2,
            expected_y1: y1.to_vec(),
            expected_y2: y2.to_vec(),
            expected_y_lin: y_lin.to_vec(),
            expected_y_direct: y_direct.to_vec(),
        });
    }

    let mut sampling_cases = Vec::new();
    {
        let b_inv = 2_500_000_000u64;
        let cset = vec![
            bounded_vec(0x1001_1001_1001_1001, D, 2),
            bounded_vec(0x2002_2002_2002_2002, D, 2),
            bounded_vec(0x3003_3003_3003_3003, D, 2),
            bounded_vec(0x4004_4004_4004_4004, D, 2),
        ];
        let vectors = vec![
            bounded_vec(0xabc1_0000_0000_0000, D, 40),
            bounded_vec(0xabc2_0000_0000_0000, D, 40),
            bounded_vec(0xabc3_0000_0000_0000, D, 40),
        ];
        let expected_strong = strong_sampling_set(&cset, b_inv);
        let expected_max_rho_norm = max_rho_norm(&cset);
        let expected_bound = 2 * (D as u64) * expected_max_rho_norm;
        let expected_empirical = empirical_expansion(&cset, &vectors);
        assert!(expected_empirical <= expected_bound);
        sampling_cases.push(SamplingCase {
            cset,
            vectors,
            b_inv,
            expected_strong,
            expected_max_rho_norm,
            expected_bound,
            expected_empirical,
        });
    }

    let mut eq_lift_cases = Vec::new();
    for round in 0..3u64 {
        let q_vals = deterministic_vec(0x5151_aaaa_1212_bbbb ^ round, 8);
        let z_bool = bool_vec((round as usize) % 8, 3);
        let expected_sum_bool = eq_lift_from_table(&q_vals, &z_bool);
        let mask = bool_mask(&z_bool).expect("bool point");
        eq_lift_cases.push(EqLiftCase {
            q_vals: q_vals.clone(),
            z: z_bool,
            expected_sum: expected_sum_bool,
            is_boolean_point: true,
            expected_at_boolean: q_vals[mask],
        });
    }
    {
        let q_vals = deterministic_vec(0x4444_eeee_9999_1111, 8);
        let z = vec![F::from_u64(2), F::from_u64(3), F::from_u64(5)];
        let expected_sum = eq_lift_from_table(&q_vals, &z);
        eq_lift_cases.push(EqLiftCase {
            q_vals,
            z,
            expected_sum,
            is_boolean_point: false,
            expected_at_boolean: F::ZERO,
        });
    }

    let mut interp_cases = Vec::new();
    {
        let coeffs = vec![F::from_u64(7), F::from_u64(13), F::from_u64(29), F::from_u64(5)];
        let xs = vec![F::from_u64(0), F::from_u64(1), F::from_u64(2), F::from_u64(3)];
        let ys: Vec<F> = xs.iter().copied().map(|x| poly_eval(&coeffs, x)).collect();
        let expected_coeffs = interpolate_from_evals(&xs, &ys);
        let eval_point = F::from_u64(17);
        let expected_eval_at = poly_eval(&expected_coeffs, eval_point);
        interp_cases.push(InterpCase {
            xs,
            ys,
            expected_coeffs,
            eval_point,
            expected_eval_at,
        });
    }
    {
        let coeffs = vec![
            F::from_u64(3),
            F::from_u64(1),
            F::from_u64(4),
            F::from_u64(1),
            F::from_u64(5),
        ];
        let xs = vec![
            F::from_u64(1),
            F::from_u64(2),
            F::from_u64(4),
            F::from_u64(8),
            F::from_u64(16),
        ];
        let ys: Vec<F> = xs.iter().copied().map(|x| poly_eval(&coeffs, x)).collect();
        let expected_coeffs = interpolate_from_evals(&xs, &ys);
        let eval_point = F::from_u64(9);
        let expected_eval_at = poly_eval(&expected_coeffs, eval_point);
        interp_cases.push(InterpCase {
            xs,
            ys,
            expected_coeffs,
            eval_point,
            expected_eval_at,
        });
    }

    let mut module_hom_cases = Vec::new();
    {
        let scalar = F::from_u64(7);
        let x = bounded_vec(0x5050_0101_aaaa_bbbb, D, 8);
        let y = bounded_vec(0x5050_0101_cccc_dddd, D, 8);
        let vec_factor = F::from_u64(9);
        let vec_bias = vec![F::ZERO; D];
        let scalar_weights = bounded_vec(0x1234_5678_aaaa_0001, D, 3);
        let scalar_bias = F::ZERO;
        module_hom_cases.push(ModuleHomCase {
            scalar,
            x: x.clone(),
            y: y.clone(),
            vec_factor,
            vec_bias: vec_bias.clone(),
            scalar_weights: scalar_weights.clone(),
            scalar_bias,
            expected_vec_check: vec_module_check_pair(vec_factor, &vec_bias, scalar, &x, &y),
            expected_scalar_check: scalar_module_check_pair(&scalar_weights, scalar_bias, scalar, &x, &y),
        });
    }
    {
        let scalar = F::from_u64(5);
        let x = bounded_vec(0x6060_0101_aaaa_bbbb, D, 8);
        let y = bounded_vec(0x6060_0101_cccc_dddd, D, 8);
        let vec_factor = F::from_u64(4);
        let vec_bias = bounded_vec(0x9999_0000_1111_2222, D, 2);
        let scalar_weights = bounded_vec(0x1234_5678_aaaa_0002, D, 3);
        let scalar_bias = F::ZERO;
        module_hom_cases.push(ModuleHomCase {
            scalar,
            x: x.clone(),
            y: y.clone(),
            vec_factor,
            vec_bias: vec_bias.clone(),
            scalar_weights: scalar_weights.clone(),
            scalar_bias,
            expected_vec_check: vec_module_check_pair(vec_factor, &vec_bias, scalar, &x, &y),
            expected_scalar_check: scalar_module_check_pair(&scalar_weights, scalar_bias, scalar, &x, &y),
        });
    }
    {
        let scalar = F::from_u64(3);
        let x = bounded_vec(0x7070_0101_aaaa_bbbb, D, 8);
        let y = bounded_vec(0x7070_0101_cccc_dddd, D, 8);
        let vec_factor = F::from_u64(6);
        let vec_bias = vec![F::ZERO; D];
        let scalar_weights = bounded_vec(0x1234_5678_aaaa_0003, D, 3);
        let scalar_bias = F::from_u64(11);
        module_hom_cases.push(ModuleHomCase {
            scalar,
            x: x.clone(),
            y: y.clone(),
            vec_factor,
            vec_bias: vec_bias.clone(),
            scalar_weights: scalar_weights.clone(),
            scalar_bias,
            expected_vec_check: vec_module_check_pair(vec_factor, &vec_bias, scalar, &x, &y),
            expected_scalar_check: scalar_module_check_pair(&scalar_weights, scalar_bias, scalar, &x, &y),
        });
    }
    {
        let scalar = F::from_u64(2);
        let x = bounded_vec(0x8080_0101_aaaa_bbbb, D, 8);
        let y = bounded_vec(0x8080_0101_cccc_dddd, D - 1, 8);
        let vec_factor = F::from_u64(12);
        let vec_bias = vec![F::ZERO; D];
        let scalar_weights = bounded_vec(0x1234_5678_aaaa_0004, D, 3);
        let scalar_bias = F::ZERO;
        module_hom_cases.push(ModuleHomCase {
            scalar,
            x: x.clone(),
            y: y.clone(),
            vec_factor,
            vec_bias: vec_bias.clone(),
            scalar_weights: scalar_weights.clone(),
            scalar_bias,
            expected_vec_check: vec_module_check_pair(vec_factor, &vec_bias, scalar, &x, &y),
            expected_scalar_check: scalar_module_check_pair(&scalar_weights, scalar_bias, scalar, &x, &y),
        });
    }

    let mut invertibility_cases = Vec::new();
    for (coeffs, bound) in [
        (vec![F::ZERO; D], 383u64),
        (bounded_vec(0x9001_1111_0000_0001, D, 4), 5u64),
        (bounded_vec(0x9001_1111_0000_0002, D, 382), 383u64),
        (bounded_vec(0x9001_1111_0000_0003, D, 400), 383u64),
        (bounded_vec(0x9001_1111_0000_0004, D - 2, 4), 5u64),
    ] {
        let max_norm = norm_inf_vec(&coeffs);
        let expected_shape = coeffs.len() == D;
        let expected_weak_window = max_norm <= bound;
        let expected_strict_window = max_norm > 0 && max_norm < bound;
        let expected_derivable_invertible = expected_shape && expected_strict_window && (bound == 5 || bound == 383);
        invertibility_cases.push(InvertibilityCase {
            coeffs,
            bound,
            expected_shape,
            expected_weak_window,
            expected_strict_window,
            expected_derivable_invertible,
        });
    }

    let bar_src = superneo_bar_matrix();
    let mut bar_u64 = [[0u64; D]; D];
    for r in 0..D {
        for c in 0..D {
            bar_u64[r][c] = f_u64(bar_src[r][c]);
        }
    }

    let mut out = String::new();
    out.push_str("import SuperNeo.Generated.Cases\n\n");
    out.push_str("set_option maxRecDepth 100000\n\n");
    out.push_str("namespace SuperNeo.Generated\n\n");

    out.push_str("def barMatrixU64 : Array (Array Nat) :=\n");
    out.push_str(&fmt_nat_mat(&bar_u64));
    out.push_str("\n\n");

    out.push_str("def superneoCases : Array SuperNeoCase := #[\n");
    for c in &super_cases {
        let a: Vec<u64> = c.a.iter().copied().map(f_u64).collect();
        let b: Vec<u64> = c.b.iter().copied().map(f_u64).collect();
        let _ = writeln!(
            out,
            "  {{ a := {}, b := {}, expectedCt := {}, expectedDot := {} }},",
            fmt_nat_array(&a),
            fmt_nat_array(&b),
            f_u64(c.expected_ct),
            f_u64(c.expected_dot)
        );
    }
    out.push_str("]\n\n");

    out.push_str("def ringMulCases : Array RingMulCase := #[\n");
    for c in &mul_cases {
        let a: Vec<u64> = c.a.iter().copied().map(f_u64).collect();
        let b: Vec<u64> = c.b.iter().copied().map(f_u64).collect();
        let e: Vec<u64> = c.expected.iter().copied().map(f_u64).collect();
        let _ = writeln!(
            out,
            "  {{ a := {}, b := {}, expected := {} }},",
            fmt_nat_array(&a),
            fmt_nat_array(&b),
            fmt_nat_array(&e)
        );
    }
    out.push_str("]\n\n");

    out.push_str("def normCases : Array NormCase := #[\n");
    for c in &norm_cases {
        let a: Vec<u64> = c.a.iter().copied().map(f_u64).collect();
        let _ = writeln!(
            out,
            "  {{ a := {}, expectedNorm := {} }},",
            fmt_nat_array(&a),
            c.expected_norm
        );
    }
    out.push_str("]\n\n");

    out.push_str("def splitCases : Array SplitCase := #[\n");
    for c in &split_cases {
        let input: Vec<u64> = c.input.iter().copied().map(f_u64).collect();
        let digits: Vec<Vec<u64>> = c
            .expected_digits
            .iter()
            .map(|row| row.iter().copied().map(f_u64).collect())
            .collect();
        let recomposed: Vec<u64> = c.expected_recomposed.iter().copied().map(f_u64).collect();
        let _ = writeln!(
            out,
            "  {{ input := {}, base := {}, k := {}, expectedDigits := {}, expectedRecomposed := {} }},",
            fmt_nat_array(&input),
            c.base,
            c.k,
            fmt_nat_array2(&digits),
            fmt_nat_array(&recomposed)
        );
    }
    out.push_str("]\n\n");

    out.push_str("def eqCases : Array EqCase := #[\n");
    for c in &eq_cases {
        let x: Vec<u64> = c.x.iter().copied().map(f_u64).collect();
        let y: Vec<u64> = c.y.iter().copied().map(f_u64).collect();
        let _ = writeln!(
            out,
            "  {{ x := {}, y := {}, expected := {} }},",
            fmt_nat_array(&x),
            fmt_nat_array(&y),
            f_u64(c.expected)
        );
    }
    out.push_str("]\n\n");

    out.push_str("def mleCases : Array MleCase := #[\n");
    for c in &mle_cases {
        let v: Vec<u64> = c.v.iter().copied().map(f_u64).collect();
        let r: Vec<u64> = c.r.iter().copied().map(f_u64).collect();
        let _ = writeln!(
            out,
            "  {{ v := {}, r := {}, expectedInner := {}, expectedFold := {} }},",
            fmt_nat_array(&v),
            fmt_nat_array(&r),
            f_u64(c.expected_inner),
            f_u64(c.expected_fold)
        );
    }
    out.push_str("]\n\n");

    out.push_str("def embeddingVecCases : Array EmbeddingVecCase := #[\n");
    for c in &embedding_vec_cases {
        let input: Vec<u64> = c.input.iter().copied().map(f_u64).collect();
        let blocks: Vec<Vec<u64>> = c
            .expected_blocks
            .iter()
            .map(|row| row.iter().copied().map(f_u64).collect())
            .collect();
        let _ = writeln!(
            out,
            "  {{ input := {}, expectedBlocks := {} }},",
            fmt_nat_array(&input),
            fmt_nat_array2(&blocks)
        );
    }
    out.push_str("]\n\n");

    out.push_str("def embeddingMatrixCases : Array EmbeddingMatrixCase := #[\n");
    for c in &embedding_matrix_cases {
        let input: Vec<Vec<u64>> = c
            .input
            .iter()
            .map(|row| row.iter().copied().map(f_u64).collect())
            .collect();
        let blocks: Vec<Vec<Vec<u64>>> = c
            .expected_blocks
            .iter()
            .map(|mat| {
                mat.iter()
                    .map(|row| row.iter().copied().map(f_u64).collect())
                    .collect()
            })
            .collect();
        let _ = writeln!(
            out,
            "  {{ input := {}, expectedBlocks := {} }},",
            fmt_nat_array2(&input),
            fmt_nat_array3(&blocks)
        );
    }
    out.push_str("]\n\n");

    out.push_str("def barLiftVecCases : Array BarLiftVecCase := #[\n");
    for c in &bar_lift_vec_cases {
        let v: Vec<u64> = c.v.iter().copied().map(f_u64).collect();
        let w: Vec<u64> = c.w.iter().copied().map(f_u64).collect();
        let exp_v: Vec<u64> = c.expected_lift_v.iter().copied().map(f_u64).collect();
        let exp_w: Vec<u64> = c.expected_lift_w.iter().copied().map(f_u64).collect();
        let exp_add: Vec<u64> = c.expected_lift_add.iter().copied().map(f_u64).collect();
        let exp_scale: Vec<u64> = c.expected_lift_scale.iter().copied().map(f_u64).collect();
        let _ = writeln!(
            out,
            "  {{ v := {}, w := {}, scalar := {}, expectedLiftV := {}, expectedLiftW := {}, expectedLiftAdd := {}, expectedLiftScale := {} }},",
            fmt_nat_array(&v),
            fmt_nat_array(&w),
            f_u64(c.scalar),
            fmt_nat_array(&exp_v),
            fmt_nat_array(&exp_w),
            fmt_nat_array(&exp_add),
            fmt_nat_array(&exp_scale)
        );
    }
    out.push_str("]\n\n");

    out.push_str("def barLiftMatrixCases : Array BarLiftMatrixCase := #[\n");
    for c in &bar_lift_matrix_cases {
        let input: Vec<Vec<u64>> = c
            .input
            .iter()
            .map(|row| row.iter().copied().map(f_u64).collect())
            .collect();
        let exp: Vec<Vec<u64>> = c
            .expected_lifted
            .iter()
            .map(|row| row.iter().copied().map(f_u64).collect())
            .collect();
        let _ = writeln!(
            out,
            "  {{ input := {}, expectedLifted := {} }},",
            fmt_nat_array2(&input),
            fmt_nat_array2(&exp)
        );
    }
    out.push_str("]\n\n");

    out.push_str("def matrixTransformCases : Array MatrixTransformCase := #[\n");
    for c in &matrix_transform_cases {
        let matrix: Vec<Vec<u64>> = c
            .matrix
            .iter()
            .map(|row| row.iter().copied().map(f_u64).collect())
            .collect();
        let z: Vec<u64> = c.z.iter().copied().map(f_u64).collect();
        let mz: Vec<u64> = c.expected_mz.iter().copied().map(f_u64).collect();
        let ct_bar: Vec<u64> = c.expected_ct_bar_mz.iter().copied().map(f_u64).collect();
        let _ = writeln!(
            out,
            "  {{ matrix := {}, z := {}, expectedMz := {}, expectedCtBarMz := {} }},",
            fmt_nat_array2(&matrix),
            fmt_nat_array(&z),
            fmt_nat_array(&mz),
            fmt_nat_array(&ct_bar)
        );
    }
    out.push_str("]\n\n");

    out.push_str("def evalLinkCases : Array EvalLinkCase := #[\n");
    for c in &eval_link_cases {
        let matrix: Vec<Vec<u64>> = c
            .matrix
            .iter()
            .map(|row| row.iter().copied().map(f_u64).collect())
            .collect();
        let z: Vec<u64> = c.z.iter().copied().map(f_u64).collect();
        let r: Vec<u64> = c.r.iter().copied().map(f_u64).collect();
        let y: Vec<u64> = c.expected_y.iter().copied().map(f_u64).collect();
        let _ = writeln!(
            out,
            "  {{ matrix := {}, z := {}, r := {}, expectedY := {}, expectedCtY := {} }},",
            fmt_nat_array2(&matrix),
            fmt_nat_array(&z),
            fmt_nat_array(&r),
            fmt_nat_array(&y),
            f_u64(c.expected_ct_y)
        );
    }
    out.push_str("]\n\n");

    out.push_str("def evalHomCases : Array EvalHomCase := #[\n");
    for c in &eval_hom_cases {
        let matrix: Vec<Vec<u64>> = c
            .matrix
            .iter()
            .map(|row| row.iter().copied().map(f_u64).collect())
            .collect();
        let z1: Vec<u64> = c.z1.iter().copied().map(f_u64).collect();
        let z2: Vec<u64> = c.z2.iter().copied().map(f_u64).collect();
        let r: Vec<u64> = c.r.iter().copied().map(f_u64).collect();
        let y1: Vec<u64> = c.expected_y1.iter().copied().map(f_u64).collect();
        let y2: Vec<u64> = c.expected_y2.iter().copied().map(f_u64).collect();
        let y_lin: Vec<u64> = c.expected_y_lin.iter().copied().map(f_u64).collect();
        let y_direct: Vec<u64> = c.expected_y_direct.iter().copied().map(f_u64).collect();
        let _ = writeln!(
            out,
            "  {{ matrix := {}, z1 := {}, z2 := {}, r := {}, rho1 := {}, rho2 := {}, expectedY1 := {}, expectedY2 := {}, expectedYLin := {}, expectedYDirect := {} }},",
            fmt_nat_array2(&matrix),
            fmt_nat_array(&z1),
            fmt_nat_array(&z2),
            fmt_nat_array(&r),
            f_u64(c.rho1),
            f_u64(c.rho2),
            fmt_nat_array(&y1),
            fmt_nat_array(&y2),
            fmt_nat_array(&y_lin),
            fmt_nat_array(&y_direct)
        );
    }
    out.push_str("]\n\n");

    out.push_str("def samplingCases : Array SamplingCase := #[\n");
    for c in &sampling_cases {
        let cset: Vec<Vec<u64>> = c
            .cset
            .iter()
            .map(|row| row.iter().copied().map(f_u64).collect())
            .collect();
        let vectors: Vec<Vec<u64>> = c
            .vectors
            .iter()
            .map(|row| row.iter().copied().map(f_u64).collect())
            .collect();
        let _ = writeln!(
            out,
            "  {{ cset := {}, vectors := {}, bInv := {}, expectedStrong := {}, expectedMaxRhoNorm := {}, expectedBound := {}, expectedEmpirical := {} }},",
            fmt_nat_array2(&cset),
            fmt_nat_array2(&vectors),
            c.b_inv,
            fmt_bool(c.expected_strong),
            c.expected_max_rho_norm,
            c.expected_bound,
            c.expected_empirical
        );
    }
    out.push_str("]\n\n");

    out.push_str("def eqLiftCases : Array EqLiftCase := #[\n");
    for c in &eq_lift_cases {
        let q_vals: Vec<u64> = c.q_vals.iter().copied().map(f_u64).collect();
        let z: Vec<u64> = c.z.iter().copied().map(f_u64).collect();
        let _ = writeln!(
            out,
            "  {{ qVals := {}, z := {}, expectedSum := {}, isBooleanPoint := {}, expectedAtBoolean := {} }},",
            fmt_nat_array(&q_vals),
            fmt_nat_array(&z),
            f_u64(c.expected_sum),
            fmt_bool(c.is_boolean_point),
            f_u64(c.expected_at_boolean)
        );
    }
    out.push_str("]\n\n");

    out.push_str("def interpCases : Array InterpCase := #[\n");
    for c in &interp_cases {
        let xs: Vec<u64> = c.xs.iter().copied().map(f_u64).collect();
        let ys: Vec<u64> = c.ys.iter().copied().map(f_u64).collect();
        let ec: Vec<u64> = c.expected_coeffs.iter().copied().map(f_u64).collect();
        let _ = writeln!(
            out,
            "  {{ xs := {}, ys := {}, expectedCoeffs := {}, evalPoint := {}, expectedEvalAt := {} }},",
            fmt_nat_array(&xs),
            fmt_nat_array(&ys),
            fmt_nat_array(&ec),
            f_u64(c.eval_point),
            f_u64(c.expected_eval_at)
        );
    }
    out.push_str("]\n\n");

    out.push_str("def moduleHomCases : Array ModuleHomCase := #[\n");
    for c in &module_hom_cases {
        let x: Vec<u64> = c.x.iter().copied().map(f_u64).collect();
        let y: Vec<u64> = c.y.iter().copied().map(f_u64).collect();
        let vec_bias: Vec<u64> = c.vec_bias.iter().copied().map(f_u64).collect();
        let scalar_weights: Vec<u64> = c.scalar_weights.iter().copied().map(f_u64).collect();
        let _ = writeln!(
            out,
            "  {{ scalar := {}, x := {}, y := {}, vecFactor := {}, vecBias := {}, scalarWeights := {}, scalarBias := {}, expectedVecCheck := {}, expectedScalarCheck := {} }},",
            f_u64(c.scalar),
            fmt_nat_array(&x),
            fmt_nat_array(&y),
            f_u64(c.vec_factor),
            fmt_nat_array(&vec_bias),
            fmt_nat_array(&scalar_weights),
            f_u64(c.scalar_bias),
            fmt_bool(c.expected_vec_check),
            fmt_bool(c.expected_scalar_check)
        );
    }
    out.push_str("]\n\n");

    out.push_str("def invertibilityCases : Array InvertibilityCase := #[\n");
    for c in &invertibility_cases {
        let coeffs: Vec<u64> = c.coeffs.iter().copied().map(f_u64).collect();
        let _ = writeln!(
            out,
            "  {{ coeffs := {}, bound := {}, expectedShape := {}, expectedWeakWindow := {}, expectedStrictWindow := {}, expectedDerivableInvertible := {} }},",
            fmt_nat_array(&coeffs),
            c.bound,
            fmt_bool(c.expected_shape),
            fmt_bool(c.expected_weak_window),
            fmt_bool(c.expected_strict_window),
            fmt_bool(c.expected_derivable_invertible)
        );
    }
    out.push_str("]\n\n");

    out.push_str("end SuperNeo.Generated\n");

    let out_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("SuperNeo")
        .join("Generated")
        .join("Vectors.lean");
    fs::write(&out_path, out).expect("write vectors");
    println!("wrote {}", out_path.display());
}

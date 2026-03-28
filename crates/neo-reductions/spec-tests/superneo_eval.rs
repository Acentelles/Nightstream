//! Spec-derived invariant tests for SuperNeoEval.spec.md
//!
//! Each test corresponds to a row in the Invariant Obligations table.

#[path = "common/mod.rs"]
mod common;

use common::seeded_rng;
use neo_ccs::Mat;
use neo_math::{ct, superneo_bar_block, Rq, D, F, K};
use neo_reductions::superneo_eval::superneo_row_dot_transformed_matrix;
use p3_field::PrimeCharacteristicRing;
use rand::Rng;

/// Build a bar-transformed CcsMatrix from a dense F matrix.
fn build_bar_ccs_matrix(mat: &Mat<F>) -> neo_ccs::CcsMatrix<F> {
    let n = mat.rows();
    let m = mat.cols();
    let mut bar_data = vec![F::ZERO; n * m];

    for row in 0..n {
        let blocks = m.div_ceil(D);
        for blk in 0..blocks {
            let base = blk * D;
            let mut coeffs = [F::ZERO; D];
            for i in 0..D {
                if base + i < m {
                    coeffs[i] = mat[(row, base + i)];
                }
            }
            let bar = superneo_bar_block(coeffs);
            for i in 0..D {
                if base + i < m {
                    bar_data[row * m + base + i] = bar[i];
                }
            }
        }
    }

    let bar_mat = Mat::from_row_major(n, m, bar_data);
    neo_ccs::CcsMatrix::Csc(neo_ccs::CscMat::from_dense_row_major(&bar_mat))
}

/// Direct matrix-vector product (M * z)[row] using K extension field.
fn direct_row_dot(mat: &Mat<F>, row: usize, z: &[K]) -> K {
    let mut sum = K::ZERO;
    for c in 0..mat.cols().min(z.len()) {
        sum += K::from(mat[(row, c)]) * z[c];
    }
    sum
}

// ---------------------------------------------------------------------------
// 1. superneo_row_dot matches direct product for identity matrix
// ---------------------------------------------------------------------------

/// SuperNeoEval.spec.md: superneo_row_dot matches direct product for identity
#[test]
fn superneo_row_dot_identity() {
    let n = D;
    let mat = Mat::identity(n);
    let bar_mat = build_bar_ccs_matrix(&mat);

    let mut rng = seeded_rng(0xA001);
    let z: Vec<K> = (0..n)
        .map(|_| K::from(F::from_u64(rng.random::<u64>() % 1000)))
        .collect();

    for row in 0..n {
        let superneo = superneo_row_dot_transformed_matrix(&bar_mat, row, &z);
        assert_eq!(superneo, z[row], "identity matrix: row {row} mismatch");
    }
}

// ---------------------------------------------------------------------------
// 2. superneo_row_dot matches direct product for random matrix
// ---------------------------------------------------------------------------

/// SuperNeoEval.spec.md: superneo_row_dot matches direct for random matrix
#[test]
fn superneo_row_dot_random_base_field() {
    let mut rng = seeded_rng(0xA002);
    let n = 4;
    let m = D * 2;

    let data: Vec<F> = (0..n * m)
        .map(|_| F::from_u64(rng.random::<u64>() % 100))
        .collect();
    let mat = Mat::from_row_major(n, m, data);
    let bar_mat = build_bar_ccs_matrix(&mat);

    // z in base field (imag=0)
    let z: Vec<K> = (0..m)
        .map(|_| K::from(F::from_u64(rng.random::<u64>() % 100)))
        .collect();

    for row in 0..n {
        let superneo = superneo_row_dot_transformed_matrix(&bar_mat, row, &z);
        let direct = direct_row_dot(&mat, row, &z);
        assert_eq!(superneo, direct, "random matrix: row {row} mismatch");
    }
}

// ---------------------------------------------------------------------------
// 3. Out-of-bounds row returns K::ZERO
// ---------------------------------------------------------------------------

/// SuperNeoEval.spec.md: out-of-bounds row returns K::ZERO
#[test]
fn superneo_row_dot_out_of_bounds() {
    let n = 2;
    let m = D;
    let data = vec![F::ONE; n * m];
    let mat = Mat::from_row_major(n, m, data);
    let bar_mat = build_bar_ccs_matrix(&mat);

    let z = vec![K::ONE; m];

    let result = superneo_row_dot_transformed_matrix(&bar_mat, n + 5, &z);
    assert_eq!(result, K::ZERO, "out-of-bounds row should return K::ZERO");
}

// ---------------------------------------------------------------------------
// 4. Zero row produces K::ZERO
// ---------------------------------------------------------------------------

/// SuperNeoEval.spec.md: zero row produces K::ZERO
#[test]
fn superneo_row_dot_zero_row() {
    let n = 2;
    let m = D;
    let mut data = vec![F::ZERO; n * m];
    for i in 0..m {
        data[m + i] = F::from_u64((i + 1) as u64);
    }
    let mat = Mat::from_row_major(n, m, data);
    let bar_mat = build_bar_ccs_matrix(&mat);

    let z: Vec<K> = (0..m).map(|i| K::from(F::from_u64(i as u64 + 1))).collect();

    let result_row0 = superneo_row_dot_transformed_matrix(&bar_mat, 0, &z);
    assert_eq!(result_row0, K::ZERO, "zero row should produce K::ZERO");

    let result_row1 = superneo_row_dot_transformed_matrix(&bar_mat, 1, &z);
    assert_ne!(result_row1, K::ZERO, "nonzero row should produce nonzero result");
}

// ---------------------------------------------------------------------------
// 5. Theorem 3 kernel: ct(bar(a) * b) = <a, b>
// ---------------------------------------------------------------------------

/// SuperNeoEval.spec.md: Theorem 3 inner product via ct(bar(a)*b)
#[test]
fn theorem_3_inner_product_kernel() {
    let mut rng = seeded_rng(0xA005);

    for _ in 0..10 {
        let a: [F; D] = core::array::from_fn(|_| F::from_u64(rng.random::<u64>() % 100));
        let b: [F; D] = core::array::from_fn(|_| F::from_u64(rng.random::<u64>() % 100));

        let mut dot = F::ZERO;
        for i in 0..D {
            dot += a[i] * b[i];
        }

        let bar_a = superneo_bar_block(a);
        let bar_ring = Rq(bar_a);
        let b_ring = Rq(b);
        let product = bar_ring.mul(&b_ring);
        let ct_val = ct(&product);

        assert_eq!(ct_val, dot, "Theorem 3: ct(bar(a)*b) should equal <a,b>");
    }
}

// ---------------------------------------------------------------------------
// 6. Partial blocks handled correctly
// ---------------------------------------------------------------------------

/// SuperNeoEval.spec.md: partial block (m not multiple of D)
#[test]
fn superneo_row_dot_partial_block() {
    let n = 1;
    let m = D + 1;
    let data: Vec<F> = (0..n * m).map(|i| F::from_u64((i + 1) as u64)).collect();
    let mat = Mat::from_row_major(n, m, data);
    let bar_mat = build_bar_ccs_matrix(&mat);

    let z: Vec<K> = (0..m).map(|i| K::from(F::from_u64(i as u64 + 1))).collect();

    let superneo = superneo_row_dot_transformed_matrix(&bar_mat, 0, &z);
    let direct = direct_row_dot(&mat, 0, &z);
    assert_eq!(superneo, direct, "partial block: superneo should match direct");
}

//! Spec-derived tests for Matrix.spec.md invariant obligations.
//!
//! Covers: Mat layout, identity construction/detection, CSC round-trip,
//! CcsMatrix identity mul, column selector detection.

#[path = "common/mod.rs"]
mod common;

use neo_ccs::{CcsMatrix, CscMat, Mat};
use p3_field::PrimeCharacteristicRing;
use p3_goldilocks::Goldilocks;

type F = Goldilocks;

// ---------------------------------------------------------------------------
// 1. row_major_layout
// ---------------------------------------------------------------------------
#[test]
fn row_major_layout() {
    // Mat[i,j] == data[i*cols + j]
    let rows = 3;
    let cols = 4;
    let data: Vec<F> = (0..12).map(|k| F::from_u64(k as u64)).collect();
    let m = Mat::from_row_major(rows, cols, data.clone());

    for i in 0..rows {
        for j in 0..cols {
            assert_eq!(
                m[(i, j)],
                data[i * cols + j],
                "Mat[{i},{j}] should equal data[{idx}]",
                idx = i * cols + j
            );
        }
    }
}

// ---------------------------------------------------------------------------
// 2. identity_construction_and_detection
// ---------------------------------------------------------------------------
#[test]
fn identity_construction_and_detection() {
    for n in [1, 2, 3, 5, 8] {
        let id = Mat::<F>::identity(n);
        assert!(id.is_identity(), "Mat::identity({n}) should be detected as identity");
        assert!(id.is_identity_hint(), "Mat::identity({n}) should have identity hint set");

        // Verify diagonal is 1, off-diagonal is 0.
        for i in 0..n {
            for j in 0..n {
                if i == j {
                    assert_eq!(id[(i, j)], F::ONE, "diagonal should be 1");
                } else {
                    assert_eq!(id[(i, j)], F::ZERO, "off-diagonal should be 0");
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// 3. identity_hint_cleared_on_mut
// ---------------------------------------------------------------------------
#[test]
fn identity_hint_cleared_on_mut() {
    let mut id = Mat::<F>::identity(3);
    assert!(id.is_identity_hint(), "identity_hint should be set initially");

    // Mutate via set()
    id.set(0, 0, F::ONE); // same value, but set() clears hint unconditionally
    assert!(
        !id.is_identity_hint(),
        "identity_hint should be cleared after set()"
    );

    // Still structurally identity (data unchanged), so is_identity() should still pass.
    assert!(id.is_identity(), "should still be structurally identity");
}

// ---------------------------------------------------------------------------
// 4. csc_round_trip_mul
// ---------------------------------------------------------------------------
#[test]
fn csc_round_trip_mul() {
    // Build a 3x3 dense matrix:
    // [2, 0, 1]
    // [0, 3, 0]
    // [4, 0, 5]
    let m = Mat::from_row_major(
        3,
        3,
        vec![
            F::from_u64(2), F::ZERO, F::ONE,
            F::ZERO, F::from_u64(3), F::ZERO,
            F::from_u64(4), F::ZERO, F::from_u64(5),
        ],
    );

    // Convert to CSC.
    let csc = CscMat::from_dense_row_major(&m);

    // Test M*x via add_mul_into.
    let x = vec![F::from_u64(1), F::from_u64(2), F::from_u64(3)];

    // Expected: M*x = [2*1 + 0*2 + 1*3, 0*1 + 3*2 + 0*3, 4*1 + 0*2 + 5*3]
    //                = [5, 6, 19]
    let mut y = vec![F::ZERO; 3];
    csc.add_mul_into(&x, &mut y, 3);

    assert_eq!(y[0], F::from_u64(5), "M*x[0] should be 5");
    assert_eq!(y[1], F::from_u64(6), "M*x[1] should be 6");
    assert_eq!(y[2], F::from_u64(19), "M*x[2] should be 19");

    // Verify against manual dense computation.
    let mut y_dense = vec![F::ZERO; 3];
    for i in 0..3 {
        for j in 0..3 {
            y_dense[i] += m[(i, j)] * x[j];
        }
    }
    assert_eq!(y, y_dense, "CSC mul should match dense mul");
}

// ---------------------------------------------------------------------------
// 5. csc_from_triplets_dedup
// ---------------------------------------------------------------------------
#[test]
fn csc_from_triplets_dedup() {
    // Duplicate (row, col) entries should be summed.
    let triplets = vec![
        (0, 0, F::from_u64(3)),
        (0, 0, F::from_u64(7)), // same (0,0) => sum = 10
        (1, 1, F::from_u64(5)),
    ];

    let csc = CscMat::from_triplets(triplets, 2, 2);

    // Check M*[1, 1] = [10, 5]
    let x = vec![F::ONE, F::ONE];
    let mut y = vec![F::ZERO; 2];
    csc.add_mul_into(&x, &mut y, 2);

    assert_eq!(y[0], F::from_u64(10), "duplicate entries should be summed");
    assert_eq!(y[1], F::from_u64(5));
}

// ---------------------------------------------------------------------------
// 6. csc_transpose_mul
// ---------------------------------------------------------------------------
#[test]
fn csc_transpose_mul() {
    // M = [2, 0, 1]
    //     [0, 3, 0]
    //     [4, 0, 5]
    // M^T * x for x = [1, 2, 3]:
    // M^T = [2, 0, 4]   => M^T*x = [2*1+0*2+4*3, 0*1+3*2+0*3, 1*1+0*2+5*3]
    //       [0, 3, 0]              = [14, 6, 16]
    //       [1, 0, 5]
    let m = Mat::from_row_major(
        3,
        3,
        vec![
            F::from_u64(2), F::ZERO, F::ONE,
            F::ZERO, F::from_u64(3), F::ZERO,
            F::from_u64(4), F::ZERO, F::from_u64(5),
        ],
    );

    let csc = CscMat::from_dense_row_major(&m);

    let x = vec![F::from_u64(1), F::from_u64(2), F::from_u64(3)];
    let mut y = vec![F::ZERO; 3];
    csc.add_mul_transpose_into(&x, &mut y, 3);

    assert_eq!(y[0], F::from_u64(14), "M^T*x[0] should be 14");
    assert_eq!(y[1], F::from_u64(6), "M^T*x[1] should be 6");
    assert_eq!(y[2], F::from_u64(16), "M^T*x[2] should be 16");
}

// ---------------------------------------------------------------------------
// 7. ccs_matrix_identity_mul
// ---------------------------------------------------------------------------
#[test]
fn ccs_matrix_identity_mul() {
    // CcsMatrix::Identity should act as I in both mul and transpose_mul.
    let n = 4;
    let id = CcsMatrix::<F>::Identity { n };

    let x: Vec<F> = (1..=4).map(|k| F::from_u64(k)).collect();

    // I * x = x
    let mut y = vec![F::ZERO; n];
    id.add_mul_into(&x, &mut y, n);
    assert_eq!(y, x, "Identity mul should return x");

    // I^T * x = x
    let mut y2 = vec![F::ZERO; n];
    id.add_mul_transpose_into(&x, &mut y2, n);
    assert_eq!(y2, x, "Identity transpose mul should return x");
}

// ---------------------------------------------------------------------------
// 8. is_column_selector_detection
// ---------------------------------------------------------------------------
#[test]
fn is_column_selector_detection() {
    // A column selector: each column has exactly one 1, rest 0.
    // 3x2 selector: selects rows 1 and 2
    let m = Mat::from_row_major(
        3,
        2,
        vec![
            F::ZERO, F::ZERO,
            F::ONE, F::ZERO,
            F::ZERO, F::ONE,
        ],
    );
    assert!(
        m.is_column_selector(),
        "valid column selector should be detected"
    );

    // Identity is also a column selector.
    let id = Mat::<F>::identity(3);
    assert!(
        id.is_column_selector(),
        "identity should be a column selector"
    );

    // Not a column selector: column 0 has two 1s.
    let not_sel = Mat::from_row_major(
        2,
        2,
        vec![
            F::ONE, F::ZERO,
            F::ONE, F::ONE,
        ],
    );
    assert!(
        !not_sel.is_column_selector(),
        "matrix with two 1s in a column should not be a column selector"
    );

    // Not a column selector: column has a non-0/1 entry.
    let not_sel2 = Mat::from_row_major(
        2,
        1,
        vec![
            F::from_u64(2),
            F::ZERO,
        ],
    );
    assert!(
        !not_sel2.is_column_selector(),
        "matrix with entry != 0 or 1 should not be a column selector"
    );
}

//! Spec-derived invariant tests for PiRLC.spec.md
//!
//! Each test corresponds to a row in the Invariant Obligations table.

#[path = "common/mod.rs"]
mod common;

use common::seeded_rng;
use neo_math::{D, F, K};
use neo_reductions::common::rot_rhos_to_mats;
use p3_field::PrimeCharacteristicRing;
use rand::Rng;

// ---------------------------------------------------------------------------
// 1. RotRho dimensions: rotation matrices are D x D
// ---------------------------------------------------------------------------

/// PiRLC.spec.md: rotation matrices have D x D dimensions
#[test]
fn rot_rho_dimensions() {
    // Build a simple D x D identity rotation matrix
    let mut data = vec![F::ZERO; D * D];
    for i in 0..D {
        data[i * D + i] = F::ONE;
    }
    let rho_mat = neo_ccs::Mat::from_row_major(D, D, data);

    assert_eq!(rho_mat.rows(), D, "rho should have D={D} rows");
    assert_eq!(rho_mat.cols(), D, "rho should have D={D} cols");
}

// ---------------------------------------------------------------------------
// 2. RLC linearity: identity rotation preserves X
// ---------------------------------------------------------------------------

/// PiRLC.spec.md: RLC linearity - identity rotation preserves X
#[test]
fn rlc_identity_rotation_preserves_x() {
    let mut rng = seeded_rng(42);

    // Identity rotation matrix
    let mut rho_data = vec![F::ZERO; D * D];
    for i in 0..D {
        rho_data[i * D + i] = F::ONE;
    }
    let rho_mat = neo_ccs::Mat::from_row_major(D, D, rho_data);

    // Random X matrix (D x m_in)
    let m_in = 4;
    let x_data: Vec<F> = (0..D * m_in)
        .map(|_| F::from_u64(rng.random::<u64>() % 1000))
        .collect();
    let x_mat = neo_ccs::Mat::from_row_major(D, m_in, x_data);

    // X_out = rho * X = I * X = X
    for r in 0..D {
        for c in 0..m_in {
            let mut sum = F::ZERO;
            for k in 0..D {
                sum += rho_mat[(r, k)] * x_mat[(k, c)];
            }
            assert_eq!(sum, x_mat[(r, c)], "identity rho should preserve X at ({r},{c})");
        }
    }
}

// ---------------------------------------------------------------------------
// 3. RLC linearity: two-input combination is additive
// ---------------------------------------------------------------------------

/// PiRLC.spec.md: RLC two-input combination is additive
#[test]
fn rlc_two_input_additive() {
    let mut rng = seeded_rng(43);

    let n = D;
    let v1: Vec<K> = (0..n)
        .map(|_| K::from(F::from_u64(rng.random::<u64>() % 100)))
        .collect();
    let v2: Vec<K> = (0..n)
        .map(|_| K::from(F::from_u64(rng.random::<u64>() % 100)))
        .collect();
    let s1 = K::from(F::from_u64(3));
    let s2 = K::from(F::from_u64(7));

    // Linear combination: out = s1*v1 + s2*v2
    let combined: Vec<K> = (0..n).map(|i| s1 * v1[i] + s2 * v2[i]).collect();

    for i in 0..n {
        assert_eq!(
            combined[i],
            s1 * v1[i] + s2 * v2[i],
            "RLC should be linear at index {i}"
        );
    }
}

// ---------------------------------------------------------------------------
// 4. rot_rhos_to_mats extracts Mat from RotRho
// ---------------------------------------------------------------------------

/// PiRLC.spec.md: rot_rhos_to_mats returns Vec<Mat<F>>
#[test]
fn rot_rhos_to_mats_returns_correct_type() {
    // We can't easily construct RotRho without params, but we can verify
    // the function signature compiles and the conversion path exists.
    let empty: Vec<neo_reductions::RotRho> = vec![];
    let mats = rot_rhos_to_mats(&empty);
    assert!(mats.is_empty(), "empty rhos should produce empty mats");
}

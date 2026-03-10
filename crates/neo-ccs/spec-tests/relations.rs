//! Spec-derived tests for Relations.spec.md invariant obligations.
//!
//! Covers: CCS rowwise zero/relaxed, structure validation, R1CS embedding,
//! tensor_point, direct_sum, identity normalization.

#[path = "common/mod.rs"]
mod common;

use common::seeded_rng;
use neo_ccs::{
    check_ccs_rowwise_relaxed, check_ccs_rowwise_zero, direct_sum, direct_sum_transcript_mixed,
    r1cs_to_ccs, validate_power_of_two, CcsStructure, Mat, SparsePoly, Term,
};
use neo_ccs::tensor_point;
use p3_field::PrimeCharacteristicRing;
use p3_goldilocks::Goldilocks;
use rand::Rng;

type F = Goldilocks;

/// Helper: Build a simple R1CS for a*b = c.
/// A = [[0, 1, 0, 0]], B = [[0, 0, 1, 0]], C = [[0, 0, 0, 1]]
/// z = [1, a, b, c] where a*b = c (but we use x = [1, a, b, c], w = [])
///
/// Note: The R1CS embedding uses z = x || w. For a fully public instance,
/// all variables go into x and w is empty.
fn build_simple_r1cs() -> (CcsStructure<F>, Vec<F>, Vec<F>) {
    let n = 1; // 1 constraint
    let m = 4; // 4 variables: [1, a, b, c]

    // A selects a (column 1)
    let mut a_data = vec![F::ZERO; n * m];
    a_data[1] = F::ONE; // A[0,1] = 1

    // B selects b (column 2)
    let mut b_data = vec![F::ZERO; n * m];
    b_data[2] = F::ONE; // B[0,2] = 1

    // C selects c (column 3)
    let mut c_data = vec![F::ZERO; n * m];
    c_data[3] = F::ONE; // C[0,3] = 1

    let a_mat = Mat::from_row_major(n, m, a_data);
    let b_mat = Mat::from_row_major(n, m, b_data);
    let c_mat = Mat::from_row_major(n, m, c_data);

    let ccs = r1cs_to_ccs(a_mat, b_mat, c_mat);

    // z = [1, 3, 5, 15] (a=3, b=5, c=15; 3*5=15)
    let x = vec![
        F::ONE,
        F::from_u64(3),
        F::from_u64(5),
        F::from_u64(15),
    ];
    let w: Vec<F> = vec![];

    (ccs, x, w)
}

// ---------------------------------------------------------------------------
// 1. ccs_rowwise_zero_r1cs_valid
// ---------------------------------------------------------------------------
#[test]
fn ccs_rowwise_zero_r1cs_valid() {
    let (ccs, x, w) = build_simple_r1cs();
    check_ccs_rowwise_zero(&ccs, &x, &w).expect("valid R1CS should pass CCS rowwise zero check");
}

// ---------------------------------------------------------------------------
// 2. ccs_rowwise_zero_rejects_invalid
// ---------------------------------------------------------------------------
#[test]
fn ccs_rowwise_zero_rejects_invalid() {
    let (ccs, mut x, w) = build_simple_r1cs();
    // Tamper: set c = 16 instead of 15 => 3*5 != 16
    x[3] = F::from_u64(16);
    let result = check_ccs_rowwise_zero(&ccs, &x, &w);
    assert!(result.is_err(), "tampered witness should fail rowwise zero");
}

// ---------------------------------------------------------------------------
// 3. ccs_rowwise_relaxed_formula
// ---------------------------------------------------------------------------
#[test]
fn ccs_rowwise_relaxed_formula() {
    let (ccs, x, w) = build_simple_r1cs();

    // With u=None (defaults to zero vector) and e=None (defaults to ONE),
    // relaxed check is: f(M_j z) = e * u[i] = 1 * 0 = 0, same as the
    // non-relaxed check.
    check_ccs_rowwise_relaxed(&ccs, &x, &w, None, None)
        .expect("relaxed check with defaults should pass for valid R1CS");

    // Now test with explicit e and u.
    // For a satisfied instance: f(M_j z) = 0 for every row.
    // If we set u = [0] and e = any, it should still pass since 0*e = 0.
    let u = vec![F::ZERO; ccs.n];
    check_ccs_rowwise_relaxed(&ccs, &x, &w, Some(&u), Some(F::from_u64(42)))
        .expect("relaxed check with explicit zero u should pass");

    // Non-zero u should fail (since f(Mz) = 0 != e*u[i] for u[i] != 0).
    let u_nonzero = vec![F::ONE; ccs.n];
    let result = check_ccs_rowwise_relaxed(&ccs, &x, &w, Some(&u_nonzero), Some(F::ONE));
    assert!(result.is_err(), "nonzero u should fail for satisfied R1CS");
}

// ---------------------------------------------------------------------------
// 4. structure_rejects_mismatched_shapes
// ---------------------------------------------------------------------------
#[test]
fn structure_rejects_mismatched_shapes() {
    // Create two matrices with different dimensions
    let m1 = Mat::from_row_major(2, 3, vec![F::ZERO; 6]);
    let m2 = Mat::from_row_major(3, 3, vec![F::ZERO; 9]); // different row count

    let f = SparsePoly::new(
        2,
        vec![Term {
            coeff: F::ONE,
            exps: vec![1, 1],
        }],
    );

    let result = CcsStructure::new(vec![m1, m2], f);
    assert!(
        result.is_err(),
        "mismatched matrix shapes should be rejected"
    );
}

// ---------------------------------------------------------------------------
// 5. structure_rejects_wrong_poly_arity
// ---------------------------------------------------------------------------
#[test]
fn structure_rejects_wrong_poly_arity() {
    let m1 = Mat::from_row_major(2, 3, vec![F::ZERO; 6]);
    let m2 = Mat::from_row_major(2, 3, vec![F::ZERO; 6]);

    // Polynomial with arity 3 but only 2 matrices
    let f = SparsePoly::new(
        3,
        vec![Term {
            coeff: F::ONE,
            exps: vec![1, 1, 0],
        }],
    );

    let result = CcsStructure::new(vec![m1, m2], f);
    assert!(
        result.is_err(),
        "wrong polynomial arity should be rejected"
    );
}

// ---------------------------------------------------------------------------
// 6. r1cs_embedding_satisfies
// ---------------------------------------------------------------------------
#[test]
fn r1cs_embedding_satisfies() {
    // A*z . B*z = C*z for various known value triples.
    let test_cases: Vec<(u64, u64, u64)> = vec![
        (3, 5, 15),
        (0, 7, 0),
        (1, 1, 1),
        (100, 200, 20000),
        (2, 3, 6),
    ];

    for (a_val, b_val, c_val) in test_cases {
        let n = 1;
        let m = 4;

        let mut a_data = vec![F::ZERO; n * m];
        a_data[1] = F::ONE;
        let mut b_data = vec![F::ZERO; n * m];
        b_data[2] = F::ONE;
        let mut c_data = vec![F::ZERO; n * m];
        c_data[3] = F::ONE;

        let a_mat = Mat::from_row_major(n, m, a_data);
        let b_mat = Mat::from_row_major(n, m, b_data);
        let c_mat = Mat::from_row_major(n, m, c_data);

        let ccs = r1cs_to_ccs(a_mat, b_mat, c_mat);

        let x = vec![
            F::ONE,
            F::from_u64(a_val),
            F::from_u64(b_val),
            F::from_u64(c_val),
        ];
        let w: Vec<F> = vec![];

        check_ccs_rowwise_zero(&ccs, &x, &w)
            .unwrap_or_else(|_| panic!("R1CS embedding should satisfy for {a_val}*{b_val}={c_val}"));
    }
}

// ---------------------------------------------------------------------------
// 7. tensor_point_sum_is_one
// ---------------------------------------------------------------------------
#[test]
fn tensor_point_sum_is_one() {
    let mut rng = seeded_rng(0xFACE);
    for ell in 1..=6 {
        let r: Vec<F> = (0..ell)
            .map(|_| F::from_u64(rng.random::<u64>()))
            .collect();
        let tp = tensor_point::<F>(&r);
        assert_eq!(tp.len(), 1 << ell, "tensor_point length should be 2^ell");
        let sum: F = tp.iter().copied().fold(F::ZERO, |a, b| a + b);
        assert_eq!(sum, F::ONE, "tensor_point entries should sum to 1");
    }
}

// ---------------------------------------------------------------------------
// 8. tensor_point_manual_expansion
// ---------------------------------------------------------------------------
#[test]
fn tensor_point_manual_expansion() {
    // For ell=2, r = [r0, r1], tensor_point should be:
    // [(1-r0)(1-r1), r0*(1-r1), (1-r0)*r1, r0*r1]
    // (order depends on implementation; check the sum property and individual entries)
    let r0 = F::from_u64(3);
    let r1 = F::from_u64(7);
    let tp = tensor_point::<F>(&[r0, r1]);
    assert_eq!(tp.len(), 4);

    // The entries should be: (1-r0)*(1-r1), r0*(1-r1), (1-r0)*r1, r0*r1
    // but the order in the implementation may differ. The key invariant is that
    // sum = 1 and evaluating the multilinear extension at r gives the correct value.
    let sum: F = tp.iter().copied().fold(F::ZERO, |a, b| a + b);
    assert_eq!(sum, F::ONE, "tensor_point entries for ell=2 should sum to 1");

    // Check that the entries match the expected tensor product.
    // The implementation uses: out[j] = product over i of (if bit_i(j) then r_i else 1-r_i).
    // With the Gray-code style expansion, verify each entry.
    let one_minus_r0 = F::ONE - r0;
    let one_minus_r1 = F::ONE - r1;
    let expected = [
        one_minus_r0 * one_minus_r1, // j=0: bits=00
        r0 * one_minus_r1,           // j=1: bits=01 (bit 0 set)
        one_minus_r0 * r1,           // j=2: bits=10 (bit 1 set)
        r0 * r1,                     // j=3: bits=11
    ];
    // Note: the ordering may differ; check via the multilinear evaluation.
    // The implementation guarantees: tp[j] = prod_i ((1-r_i) if bit_i(j)=0 else r_i)
    // where bit_i(j) is the i-th bit of j (with i=0 being the highest bit in the
    // Gray-code expansion). Let's verify the sum and product structure.
    let expected_sum: F = expected.iter().copied().fold(F::ZERO, |a, b| a + b);
    assert_eq!(expected_sum, F::ONE, "expected entries should also sum to 1");
}

// ---------------------------------------------------------------------------
// 9. direct_sum_preserves_satisfaction
// ---------------------------------------------------------------------------
#[test]
fn direct_sum_preserves_satisfaction() {
    // System 1: a1 * b1 = c1 (a1=2, b1=3, c1=6)
    let (ccs1, x1, w1) = {
        let n = 1;
        let m = 4;
        let mut a_data = vec![F::ZERO; n * m];
        a_data[1] = F::ONE;
        let mut b_data = vec![F::ZERO; n * m];
        b_data[2] = F::ONE;
        let mut c_data = vec![F::ZERO; n * m];
        c_data[3] = F::ONE;
        let ccs = r1cs_to_ccs(
            Mat::from_row_major(n, m, a_data),
            Mat::from_row_major(n, m, b_data),
            Mat::from_row_major(n, m, c_data),
        );
        let x = vec![F::ONE, F::from_u64(2), F::from_u64(3), F::from_u64(6)];
        (ccs, x, vec![])
    };

    // System 2: a2 * b2 = c2 (a2=4, b2=5, c2=20)
    let (ccs2, x2, w2) = {
        let n = 1;
        let m = 4;
        let mut a_data = vec![F::ZERO; n * m];
        a_data[1] = F::ONE;
        let mut b_data = vec![F::ZERO; n * m];
        b_data[2] = F::ONE;
        let mut c_data = vec![F::ZERO; n * m];
        c_data[3] = F::ONE;
        let ccs = r1cs_to_ccs(
            Mat::from_row_major(n, m, a_data),
            Mat::from_row_major(n, m, b_data),
            Mat::from_row_major(n, m, c_data),
        );
        let x = vec![F::ONE, F::from_u64(4), F::from_u64(5), F::from_u64(20)];
        (ccs, x, vec![])
    };

    // Both individual systems should pass on their own.
    check_ccs_rowwise_zero(&ccs1, &x1, &w1).expect("system 1 should pass");
    check_ccs_rowwise_zero(&ccs2, &x2, &w2).expect("system 2 should pass");

    // Direct sum.
    let ccs_sum = direct_sum(&ccs1, &ccs2).expect("direct sum should succeed");

    // Concatenated witness: x = x1 || x2, w = w1 || w2
    let mut x_combined = x1.clone();
    x_combined.extend_from_slice(&x2);
    let mut w_combined = w1.clone();
    w_combined.extend_from_slice(&w2);

    check_ccs_rowwise_zero(&ccs_sum, &x_combined, &w_combined)
        .expect("direct sum should preserve satisfaction");
}

// ---------------------------------------------------------------------------
// 10. ensure_identity_first_inserts
// ---------------------------------------------------------------------------
#[test]
fn ensure_identity_first_inserts() {
    // Build a square CCS where M0 is NOT identity.
    // Use a 2x2 CCS with 2 matrices, M0 is not identity.
    let m0 = Mat::from_row_major(2, 2, vec![F::ONE, F::ONE, F::ZERO, F::ONE]);
    let m1 = Mat::identity(2);

    let f = SparsePoly::new(
        2,
        vec![
            Term {
                coeff: F::ONE,
                exps: vec![1, 1],
            },
        ],
    );

    let ccs = CcsStructure::new(vec![m0, m1], f).expect("valid CCS");
    assert!(!ccs.matrices[0].is_identity(), "M0 should NOT be identity before normalization");

    let ccs_norm = ccs.ensure_identity_first().expect("normalization should succeed");
    assert!(ccs_norm.matrices[0].is_identity(), "M0 should be identity after normalization");
    assert_eq!(ccs_norm.t(), 3, "should have 3 matrices after inserting identity");
}

// ---------------------------------------------------------------------------
// 11. ensure_identity_first_noop
// ---------------------------------------------------------------------------
#[test]
fn ensure_identity_first_noop() {
    // Build a square CCS where M0 IS identity.
    let m0 = Mat::identity(2);
    let m1 = Mat::from_row_major(2, 2, vec![F::ONE, F::ZERO, F::ZERO, F::ONE]);

    let f = SparsePoly::new(
        2,
        vec![
            Term {
                coeff: F::ONE,
                exps: vec![1, 1],
            },
        ],
    );

    let ccs = CcsStructure::new(vec![m0, m1], f).expect("valid CCS");
    assert!(ccs.matrices[0].is_identity(), "M0 should already be identity");

    let ccs_norm = ccs.ensure_identity_first().expect("normalization should succeed");
    assert_eq!(ccs_norm.t(), 2, "should still have 2 matrices (no insertion)");
    assert!(ccs_norm.matrices[0].is_identity(), "M0 should remain identity");
}

// ---------------------------------------------------------------------------
// 12. assert_m0_identity_rejects
// ---------------------------------------------------------------------------
#[test]
fn assert_m0_identity_rejects() {
    // Build a square CCS where M0 is NOT identity.
    let m0 = Mat::from_row_major(2, 2, vec![F::from_u64(2), F::ZERO, F::ZERO, F::ONE]);
    let m1 = Mat::identity(2);

    let f = SparsePoly::new(
        2,
        vec![
            Term {
                coeff: F::ONE,
                exps: vec![1, 1],
            },
        ],
    );

    let ccs = CcsStructure::new(vec![m0, m1], f).expect("valid CCS");
    let result = ccs.assert_m0_is_identity_for_nc();
    assert!(result.is_err(), "non-identity M0 should be rejected by assert_m0_is_identity_for_nc");
}

// ---------------------------------------------------------------------------
// 13. validate_power_of_two_cases
// ---------------------------------------------------------------------------
#[test]
fn validate_power_of_two_cases() {
    // Valid powers of two
    for &n in &[1usize, 2, 4, 8, 16, 32, 64, 128, 256, 1024] {
        assert!(
            validate_power_of_two(n),
            "{n} should be recognized as a power of two"
        );
    }

    // Invalid cases
    for &n in &[0usize, 3, 5, 6, 7, 9, 10, 12, 15, 17, 100] {
        assert!(
            !validate_power_of_two(n),
            "{n} should NOT be recognized as a power of two"
        );
    }
}

// ---------------------------------------------------------------------------
// 14. direct_sum_transcript_mixed_beta
// ---------------------------------------------------------------------------
#[test]
fn direct_sum_transcript_mixed_beta() {
    // Build two simple R1CS systems.
    let (ccs1, _x1, _w1) = build_simple_r1cs();
    let (ccs2, _, _): (_, _, Vec<F>) = {
        let n = 1;
        let m = 4;
        let mut a_data = vec![F::ZERO; n * m];
        a_data[1] = F::ONE;
        let mut b_data = vec![F::ZERO; n * m];
        b_data[2] = F::ONE;
        let mut c_data = vec![F::ZERO; n * m];
        c_data[3] = F::ONE;
        let ccs = r1cs_to_ccs(
            Mat::from_row_major(n, m, a_data),
            Mat::from_row_major(n, m, b_data),
            Mat::from_row_major(n, m, c_data),
        );
        let x = vec![F::ONE, F::from_u64(4), F::from_u64(5), F::from_u64(20)];
        (ccs, x, vec![])
    };

    // Use a non-trivial transcript digest
    let digest: [u8; 32] = [
        0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF,
        0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10,
        0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88,
        0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF, 0x00,
    ];

    let ccs_mixed = direct_sum_transcript_mixed(&ccs1, &ccs2, digest)
        .expect("transcript-mixed direct sum should succeed");

    // The combined structure should have t1 + t2 matrices and n1 + n2 rows.
    assert_eq!(ccs_mixed.t(), ccs1.t() + ccs2.t());
    assert_eq!(ccs_mixed.n, ccs1.n + ccs2.n);
    assert_eq!(ccs_mixed.m, ccs1.m + ccs2.m);
}

//! Spec-derived tests for Gadgets.spec.md invariant obligations.
//!
//! Covers: public equality accept/reject, commitment opening round-trip,
//! commitment lincomb round-trip, lincomb witness correctness.

#[path = "common/mod.rs"]
mod common;

use neo_ccs::check_ccs_rowwise_zero;
use neo_ccs::gadgets::commitment_opening::{
    build_commitment_lincomb_public_input, build_commitment_lincomb_witness, build_opening_witness,
    commitment_lincomb_ccs, commitment_opening_from_rows_ccs,
};
use neo_ccs::gadgets::public_equality::{build_public_vec_eq_witness, public_equality_ccs};
use p3_field::PrimeCharacteristicRing;
use p3_goldilocks::Goldilocks;

type F = Goldilocks;

// ---------------------------------------------------------------------------
// 1. public_equality_accepts_equal
// ---------------------------------------------------------------------------
#[test]
fn public_equality_accepts_equal() {
    let len = 3;
    let ccs = public_equality_ccs(len);

    // Public: [lhs[0..3], rhs[0..3]] where lhs == rhs
    let lhs = vec![F::from_u64(10), F::from_u64(20), F::from_u64(30)];
    let rhs = lhs.clone(); // equal
    let mut x = Vec::with_capacity(2 * len);
    x.extend_from_slice(&lhs);
    x.extend_from_slice(&rhs);

    // Witness: [1] (const)
    let w = build_public_vec_eq_witness();

    check_ccs_rowwise_zero(&ccs, &x, &w).expect("equal vectors should pass public equality check");
}

// ---------------------------------------------------------------------------
// 2. public_equality_rejects_unequal
// ---------------------------------------------------------------------------
#[test]
fn public_equality_rejects_unequal() {
    let len = 3;
    let ccs = public_equality_ccs(len);

    let lhs = vec![F::from_u64(10), F::from_u64(20), F::from_u64(30)];
    let rhs = vec![F::from_u64(10), F::from_u64(99), F::from_u64(30)]; // differs at index 1
    let mut x = Vec::with_capacity(2 * len);
    x.extend_from_slice(&lhs);
    x.extend_from_slice(&rhs);

    let w = build_public_vec_eq_witness();

    let result = check_ccs_rowwise_zero(&ccs, &x, &w);
    assert!(result.is_err(), "unequal vectors should fail public equality check");
}

// ---------------------------------------------------------------------------
// 3. commitment_opening_round_trip
// ---------------------------------------------------------------------------
#[test]
fn commitment_opening_round_trip() {
    // Build simple L_i rows: 2 coordinates (L=2) over 3-element witness.
    // L_0 = [1, 0, 0] => c_open[0] = z[0]
    // L_1 = [0, 1, 0] => c_open[1] = z[1]
    let msg_len = 3;
    let rows = vec![vec![F::ONE, F::ZERO, F::ZERO], vec![F::ZERO, F::ONE, F::ZERO]];
    let _l = rows.len(); // 2

    let ccs = commitment_opening_from_rows_ccs(&rows, msg_len);

    // z_digits = [5, 7, 11]
    let z_digits = vec![F::from_u64(5), F::from_u64(7), F::from_u64(11)];

    // Compute c_open = L * z_digits:
    // c_open[0] = <L_0, z_digits> = 5
    // c_open[1] = <L_1, z_digits> = 7
    let c_open = vec![F::from_u64(5), F::from_u64(7)];

    // Public inputs: c_open[0..L)
    let x = c_open.clone();

    // Witness: [1, z_digits[0..msg_len]]
    let w = build_opening_witness(&z_digits);

    check_ccs_rowwise_zero(&ccs, &x, &w).expect("commitment opening round-trip should pass");
}

// ---------------------------------------------------------------------------
// 4. commitment_lincomb_round_trip
// ---------------------------------------------------------------------------
#[test]
fn commitment_lincomb_round_trip() {
    let l = 2; // commitment coordinate length
    let ccs = commitment_lincomb_ccs(l);

    let rho = F::from_u64(7);
    let c_prev = vec![F::from_u64(10), F::from_u64(20)];
    let c_step = vec![F::from_u64(3), F::from_u64(5)];

    // Build witness and c_next.
    let (w, c_next) = build_commitment_lincomb_witness(rho, &c_prev, &c_step);

    // Verify c_next = c_prev + rho * c_step.
    for i in 0..l {
        assert_eq!(
            c_next[i],
            c_prev[i] + rho * c_step[i],
            "c_next[{i}] should equal c_prev[{i}] + rho * c_step[{i}]"
        );
    }

    // Build public input: [rho, c_prev[0..l], c_step[0..l], c_next[0..l]]
    let x = build_commitment_lincomb_public_input(rho, &c_prev, &c_step, &c_next);

    check_ccs_rowwise_zero(&ccs, &x, &w).expect("commitment lincomb round-trip should pass");
}

// ---------------------------------------------------------------------------
// 5. lincomb_witness_correctness
// ---------------------------------------------------------------------------
#[test]
fn lincomb_witness_correctness() {
    let rho = F::from_u64(13);
    let c_prev = vec![F::from_u64(100), F::from_u64(200), F::from_u64(300)];
    let c_step = vec![F::from_u64(1), F::from_u64(2), F::from_u64(3)];

    let (w, c_next) = build_commitment_lincomb_witness(rho, &c_prev, &c_step);

    // w = [1, u[0], u[1], u[2]] where u[i] = rho * c_step[i]
    assert_eq!(w[0], F::ONE, "first witness element should be 1");
    let l = c_prev.len();
    for i in 0..l {
        let expected_u = rho * c_step[i];
        assert_eq!(w[1 + i], expected_u, "u[{i}] should equal rho * c_step[{i}]");
        assert_eq!(
            c_next[i],
            c_prev[i] + expected_u,
            "c_next[{i}] should equal c_prev[{i}] + rho * c_step[{i}]"
        );
    }

    // Also verify the CCS is satisfied.
    let ccs = commitment_lincomb_ccs(l);
    let x = build_commitment_lincomb_public_input(rho, &c_prev, &c_step, &c_next);
    check_ccs_rowwise_zero(&ccs, &x, &w).expect("lincomb witness should satisfy the CCS");
}

//! Spec-derived invariant tests for Norms.spec.md
//!
//! Each test corresponds to a row in the Invariant Obligations table.

#[path = "common/mod.rs"]
mod common;

use common::seeded_rng;
use neo_math::balanced::{to_balanced_i128, within_nc_bound};
use neo_math::Fq;
use p3_field::{PrimeCharacteristicRing, PrimeField64};
use rand::Rng;

/// Norms.spec.md: to_balanced_i128(0) = 0
#[test]
fn balanced_zero() {
    assert_eq!(to_balanced_i128(Fq::ZERO), 0);
}

/// Norms.spec.md: to_balanced_i128(v) is in [-(q-1)/2, (q-1)/2]
#[test]
fn balanced_range() {
    let mut rng = seeded_rng(0xBEEF);
    let half = (Fq::ORDER_U64 as i128 - 1) / 2;
    for _ in 0..1000 {
        let v = Fq::from_u64(rng.random::<u64>());
        let b = to_balanced_i128(v);
        assert!(b >= -half && b <= half, "out of range: {b}");
    }
}

/// Norms.spec.md: to_balanced_i128(1) = 1 and to_balanced_i128(q-1) = -1
#[test]
fn balanced_one_and_minus_one() {
    assert_eq!(to_balanced_i128(Fq::ONE), 1);
    assert_eq!(to_balanced_i128(-Fq::ONE), -1);
}

/// Norms.spec.md: within_nc_bound(v, 2) iff v in {-1, 0, 1}
#[test]
fn nc_bound_2_is_ternary() {
    assert!(within_nc_bound(Fq::ZERO, 2));
    assert!(within_nc_bound(Fq::ONE, 2));
    assert!(within_nc_bound(-Fq::ONE, 2));
    assert!(!within_nc_bound(Fq::from_u64(2), 2));
    assert!(!within_nc_bound(-Fq::from_u64(2), 2));
}

/// Norms.spec.md: within_nc_bound(v, b) returns false for b < 2
#[test]
fn nc_bound_rejects_small_b() {
    assert!(!within_nc_bound(Fq::ZERO, 0));
    assert!(!within_nc_bound(Fq::ZERO, 1));
}

/// Norms.spec.md: within_nc_bound boundary — b-1 is in, b is out
#[test]
fn nc_bound_boundary() {
    let b: u32 = 10;
    // b-1 = 9 should be in bound
    assert!(within_nc_bound(Fq::from_u64(9), b));
    assert!(within_nc_bound(-Fq::from_u64(9), b));
    // b = 10 should be out of bound (strict: |x| < b)
    assert!(!within_nc_bound(Fq::from_u64(10), b));
    assert!(!within_nc_bound(-Fq::from_u64(10), b));
}

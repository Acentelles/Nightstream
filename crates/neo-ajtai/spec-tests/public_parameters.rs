//! Spec-derived tests for PublicParameters.spec.md invariant obligations.
//!
//! Covers: PRG determinism, balanced conversion correctness.

use neo_ajtai::prg::expand_row_v2;
use neo_ajtai::util::{to_balanced_i128, to_balanced_i64};
use neo_math::Fq;
use p3_field::{PrimeCharacteristicRing, PrimeField64};

/// PublicParameters.spec.md: PRG determinism — same seed + row_idx -> same output
#[test]
fn prg_determinism() {
    let seed = [42u8; 32];
    let out1 = expand_row_v2(&seed, 0, 100);
    let out2 = expand_row_v2(&seed, 0, 100);
    assert_eq!(out1, out2, "PRG must be deterministic");
}

/// PublicParameters.spec.md: different row_idx -> different output
#[test]
fn prg_different_rows() {
    let seed = [42u8; 32];
    let out1 = expand_row_v2(&seed, 0, 100);
    let out2 = expand_row_v2(&seed, 1, 100);
    assert_ne!(out1, out2, "different row indices must produce different output");
}

/// PublicParameters.spec.md: different seed -> different output
#[test]
fn prg_different_seeds() {
    let seed1 = [42u8; 32];
    let seed2 = [43u8; 32];
    let out1 = expand_row_v2(&seed1, 0, 100);
    let out2 = expand_row_v2(&seed2, 0, 100);
    assert_ne!(out1, out2, "different seeds must produce different output");
}

/// PublicParameters.spec.md: balanced conversion correctness
#[test]
fn balanced_conversion_basic() {
    const Q: u64 = <Fq as PrimeField64>::ORDER_U64;

    // Zero maps to 0
    assert_eq!(to_balanced_i128(Fq::ZERO), 0);
    assert_eq!(to_balanced_i64(Fq::ZERO), 0);

    // One maps to 1
    assert_eq!(to_balanced_i128(Fq::ONE), 1);
    assert_eq!(to_balanced_i64(Fq::ONE), 1);

    // q-1 maps to -1
    let q_minus_1 = Fq::from_u64(Q - 1);
    assert_eq!(to_balanced_i128(q_minus_1), -1);
    assert_eq!(to_balanced_i64(q_minus_1), -1);
}

/// PublicParameters.spec.md: to_balanced_i128 and to_balanced_i64 agree
#[test]
fn balanced_i128_i64_agree() {
    let test_vals = [0u64, 1, 2, 100, 1000, (1u64 << 32) - 1, (1u64 << 32), (1u64 << 63)];
    for &v in &test_vals {
        let fq = Fq::from_u64(v);
        let b128 = to_balanced_i128(fq);
        let b64 = to_balanced_i64(fq) as i128;
        assert_eq!(b128, b64, "i128 and i64 balanced conversions must agree for {v}");
    }
}

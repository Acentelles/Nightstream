//! Spec-derived invariant tests for Goldilocks.spec.md
//!
//! Each test corresponds to a row in the Invariant Obligations table.

#[path = "common/mod.rs"]
mod common;

use common::{pow_mod, seeded_rng};
use neo_math::{from_complex, Fq, KExtensions, K};
use p3_field::{PrimeCharacteristicRing, PrimeField64};
use rand::Rng;

/// Goldilocks.spec.md: q = 18446744069414584321
#[test]
fn goldilocks_modulus() {
    assert_eq!(Fq::ORDER_U64, 18446744069414584321u64);
}

/// Goldilocks.spec.md: conj(conj(x)) = x for all x in K
#[test]
fn conjugation_involution() {
    let mut rng = seeded_rng(0xCAFE);
    for _ in 0..50 {
        let x = from_complex(Fq::from_u64(rng.random::<u64>()), Fq::from_u64(rng.random::<u64>()));
        assert_eq!(x.conj().conj(), x);
    }
}

/// Goldilocks.spec.md: x * inv(x) = 1 for all nonzero x in K
#[test]
fn extension_inverse() {
    let mut rng = seeded_rng(0xBEEF);
    for _ in 0..50 {
        let x = from_complex(Fq::from_u64(rng.random::<u64>()), Fq::from_u64(rng.random::<u64>()));
        if x == K::ZERO {
            continue;
        }
        let product = x * x.inv();
        assert_eq!(product, K::ONE);
    }
}

/// Goldilocks.spec.md: from_coeffs(as_coeffs(x)) = x round-trip
#[test]
fn k_coeffs_roundtrip() {
    let mut rng = seeded_rng(0xFACE);
    for _ in 0..50 {
        let x = from_complex(Fq::from_u64(rng.random::<u64>()), Fq::from_u64(rng.random::<u64>()));
        assert_eq!(K::from_coeffs(x.as_coeffs()), x);
    }
}

/// Goldilocks.spec.md: conj(a + bu) = a - bu
#[test]
fn conjugation_negates_imag() {
    let a = Fq::from_u64(123);
    let b = Fq::from_u64(456);
    let x = from_complex(a, b);
    let conj_x = x.conj();
    assert_eq!(conj_x.real(), a);
    assert_eq!(conj_x.imag(), -b);
}

/// Goldilocks.spec.md: scale_base(x, s) = x * s for base-field scalar
#[test]
fn scale_base_matches_multiplication() {
    let x = from_complex(Fq::from_u64(7), Fq::from_u64(11));
    let s = Fq::from_u64(3);
    let via_scale = x.scale_base(s);
    let via_mul = x * from_complex(s, Fq::ZERO);
    assert_eq!(via_scale, via_mul);
}

/// Goldilocks.spec.md: q = 2^64 - 2^32 + 1 is prime
/// Lucas primality test: if there exists a witness `a` such that
/// a^(q-1) = 1 mod q AND a^((q-1)/p) != 1 for every prime factor p of q-1,
/// then q is prime. We use witness a = 7 (a quadratic non-residue mod q).
/// q-1 = 2^32 * 3 * 5 * 17 * 257 * 65537
#[test]
fn q_is_prime_lucas_test() {
    let q = Fq::ORDER_U64;
    let qm1 = q - 1;
    let witness = Fq::from_u64(7);

    // Step 1: a^(q-1) = 1 (Fermat condition)
    assert_eq!(pow_mod(witness, qm1), Fq::ONE, "7^(q-1) != 1 mod q");

    // Step 2: for every prime factor p of q-1, a^((q-1)/p) != 1
    // q-1 = 2^32 * (2^32 - 1) = 2^32 * 3 * 5 * 17 * 257 * 65537
    let prime_factors: [u64; 6] = [2, 3, 5, 17, 257, 65537];
    for p in prime_factors {
        let sub_exp = qm1 / p;
        assert_ne!(
            pow_mod(witness, sub_exp),
            Fq::ONE,
            "7^((q-1)/{p}) = 1 mod q — Lucas test failed for factor {p}"
        );
    }
}

/// Goldilocks.spec.md: u^2 - 7 is irreducible over F_q (no x in F_q satisfies x^2 = 7)
/// This ensures K = F_q[u]/(u^2 - 7) is a valid degree-2 extension field.
#[test]
fn extension_polynomial_irreducible() {
    // If x^2 = 7 has a root in F_q, then that root r satisfies r^2 = 7.
    // By Euler's criterion, 7 is a quadratic residue mod q iff 7^((q-1)/2) = 1 mod q.
    // For irreducibility we need 7 to be a quadratic NON-residue, i.e. 7^((q-1)/2) = -1 mod q.
    let q = Fq::ORDER_U64;
    let exp = (q - 1) / 2;
    let result = pow_mod(Fq::from_u64(7), exp);
    assert_eq!(
        result,
        -Fq::ONE,
        "7^((q-1)/2) should be -1 mod q (quadratic non-residue), got {:?}",
        result
    );
}

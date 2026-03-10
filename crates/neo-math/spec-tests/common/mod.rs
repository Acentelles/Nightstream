//! Shared helpers for spec-tests.
//!
//! Each `[[test]]` binary includes this via `#[path = "common/mod.rs"] mod common;`.

use neo_math::Fq;
use p3_field::PrimeCharacteristicRing;
use rand::Rng;
use rand::SeedableRng;
use rand_chacha::ChaCha20Rng;

use neo_math::ring::D;

/// Deterministic RNG from a fixed seed (reproducible across runs).
#[allow(dead_code)]
pub fn seeded_rng(seed: u64) -> ChaCha20Rng {
    ChaCha20Rng::seed_from_u64(seed)
}

/// Modular exponentiation in F_q via repeated squaring.
#[allow(dead_code)]
pub fn pow_mod(base: Fq, exp: u64) -> Fq {
    let mut result = Fq::ONE;
    let mut b = base;
    let mut e = exp;
    while e > 0 {
        if e & 1 == 1 {
            result = result * b;
        }
        b = b * b;
        e >>= 1;
    }
    result
}

/// Generate a random `[Fq; D]` array from the given RNG.
#[allow(dead_code)]
pub fn random_fq_array(rng: &mut impl Rng) -> [Fq; D] {
    std::array::from_fn(|_| Fq::from_u64(rng.random::<u64>()))
}

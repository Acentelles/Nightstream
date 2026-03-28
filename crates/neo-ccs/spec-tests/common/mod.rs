//! Shared helpers for neo-ccs spec-tests.

use p3_field::PrimeCharacteristicRing;
use p3_goldilocks::Goldilocks;
use rand::Rng;
use rand_chacha::{rand_core::SeedableRng, ChaCha8Rng};

#[allow(dead_code)]
pub fn seeded_rng(seed: u64) -> ChaCha8Rng {
    ChaCha8Rng::seed_from_u64(seed)
}

#[allow(dead_code)]
pub fn random_fq_vec(rng: &mut impl Rng, len: usize) -> Vec<Goldilocks> {
    (0..len)
        .map(|_| Goldilocks::from_u64(rng.random::<u64>()))
        .collect()
}

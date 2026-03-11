//! Shared utilities for neo-reductions spec-tests.

#[allow(dead_code)]
pub fn seeded_rng(seed: u64) -> rand_chacha::ChaCha20Rng {
    use rand::SeedableRng;
    let mut s = [0u8; 32];
    s[..8].copy_from_slice(&seed.to_le_bytes());
    rand_chacha::ChaCha20Rng::from_seed(s)
}

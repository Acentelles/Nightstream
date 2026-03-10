//! Spec-derived tests for AjtaiCommit.spec.md invariant obligations.
//!
//! Covers: commit/verify round-trip, binding, constant-time equivalence,
//! determinism. S-homomorphism is tested in spec_s_module.

use neo_ajtai::{commit, commit_masked_ct, commit_precomp_ct, setup, verify_open, PP};
use neo_math::{Fq, Rq, D};
use p3_field::PrimeCharacteristicRing;
use rand_chacha::{rand_core::SeedableRng, ChaCha8Rng};

fn test_pp() -> PP<Rq> {
    let mut rng = ChaCha8Rng::seed_from_u64(42);
    setup(&mut rng, D, 2, 4).unwrap()
}

fn random_witness(rng: &mut impl rand::Rng, d: usize, m: usize) -> Vec<Fq> {
    (0..d * m).map(|_| Fq::from_u64(rng.random::<u64>())).collect()
}

/// AjtaiCommit.spec.md: verify_open(pp, commit(pp, Z), Z) == true
#[test]
fn commit_verify_round_trip() {
    let pp = test_pp();
    let mut rng = ChaCha8Rng::seed_from_u64(99);
    let z = random_witness(&mut rng, D, pp.m);
    let c = commit(&pp, &z);
    assert!(verify_open(&pp, &c, &z), "commit/verify round-trip must succeed");
}

/// AjtaiCommit.spec.md: verify_open(pp, c, Z') == false for Z' != Z
#[test]
fn commit_wrong_opening_fails() {
    let pp = test_pp();
    let mut rng = ChaCha8Rng::seed_from_u64(100);
    let z = random_witness(&mut rng, D, pp.m);
    let c = commit(&pp, &z);
    let z_wrong = random_witness(&mut rng, D, pp.m);
    assert!(!verify_open(&pp, &c, &z_wrong), "wrong opening must fail");
}

/// AjtaiCommit.spec.md: commit_masked_ct == commit (constant-time equivalence)
#[test]
fn commit_ct_masked_matches() {
    let pp = test_pp();
    let mut rng = ChaCha8Rng::seed_from_u64(101);
    let z = random_witness(&mut rng, D, pp.m);
    let c_normal = commit(&pp, &z);
    let c_masked = commit_masked_ct(&pp, &z);
    assert_eq!(c_normal, c_masked, "masked CT commit must match normal commit");
}

/// AjtaiCommit.spec.md: commit_precomp_ct == commit (constant-time equivalence)
#[test]
fn commit_ct_precomp_matches() {
    let pp = test_pp();
    let mut rng = ChaCha8Rng::seed_from_u64(102);
    let z = random_witness(&mut rng, D, pp.m);
    let c_normal = commit(&pp, &z);
    let c_precomp = commit_precomp_ct(&pp, &z);
    assert_eq!(c_normal, c_precomp, "precomp CT commit must match normal commit");
}

/// AjtaiCommit.spec.md: commit determinism (same inputs -> same output)
#[test]
fn commit_determinism() {
    let pp = test_pp();
    let mut rng = ChaCha8Rng::seed_from_u64(103);
    let z = random_witness(&mut rng, D, pp.m);
    let c1 = commit(&pp, &z);
    let c2 = commit(&pp, &z);
    assert_eq!(c1, c2, "commit must be deterministic");
}

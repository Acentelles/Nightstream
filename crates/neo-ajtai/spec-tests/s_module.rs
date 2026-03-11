//! Spec-derived tests for SModule.spec.md invariant obligations.
//!
//! NOTE: Registry tests are tricky because the registry is global/static.
//! These tests must be careful about test ordering and isolation.

// Registry tests are already covered in tests/s_module.rs and tests/pp_registry.rs.
// The spec-test here focuses on the S-module homomorphism property.

use neo_ajtai::{commit, s_mul, setup};
use neo_math::{Fq, Rq, D};
use p3_field::PrimeCharacteristicRing;
use rand::Rng;
use rand_chacha::{rand_core::SeedableRng, ChaCha8Rng};

/// SModule.spec.md: S-homomorphism — s_mul(rho, commit(pp, Z))
/// is consistent with applying rho at the ring level.
#[test]
fn s_module_homomorphism() {
    let mut rng = ChaCha8Rng::seed_from_u64(200);
    let pp = setup(&mut rng, D, 2, 4).unwrap();

    // Random witness
    let z: Vec<Fq> = (0..D * pp.m)
        .map(|_| Fq::from_u64(rng.random::<u64>()))
        .collect();
    let c = commit(&pp, &z);

    // Random ring element for S-action
    let rho = Rq::random_uniform(&mut rng);

    // Apply S-action to commitment
    let rho_c = s_mul(&rho, &c);

    // Apply S-action to witness (block-wise ring multiplication)
    let mut rho_z = vec![Fq::ZERO; D * pp.m];
    for col in 0..pp.m {
        let block_start = col * D;
        let mut v = [Fq::ZERO; D];
        v.copy_from_slice(&z[block_start..block_start + D]);
        let rho_v = neo_math::ring::rot_apply_vec(&rho, &v);
        rho_z[block_start..block_start + D].copy_from_slice(&rho_v);
    }
    let c_rho_z = commit(&pp, &rho_z);

    // S-homomorphism: s_mul(rho, commit(Z)) == commit(rho * Z)
    assert_eq!(rho_c, c_rho_z, "S-module homomorphism must hold");
}

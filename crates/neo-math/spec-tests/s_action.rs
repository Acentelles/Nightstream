//! Spec-derived invariant tests for SAction.spec.md
//!
//! Each test corresponds to a row in the Invariant Obligations table.

#[path = "common/mod.rs"]
mod common;

use common::seeded_rng;
use neo_math::ring::{cf, cf_inv, Rq, D};
use neo_math::{from_complex, Fq, SAction, K};
use p3_field::PrimeCharacteristicRing;
use rand::Rng;

/// SAction.spec.md: apply_vec(a, v) = cf(a * cf_inv(v))
#[test]
fn apply_vec_is_ring_multiplication() {
    let mut rng = seeded_rng(0x5ACE);
    for _ in 0..20 {
        let a = Rq::random_uniform(&mut rng);
        let v: [Fq; D] = std::array::from_fn(|_| Fq::from_u64(rng.random::<u64>()));
        let s = SAction::from_ring(a);

        let via_action = s.apply_vec(&v);
        let via_ring = cf(a.mul(&cf_inv(v)));

        assert_eq!(via_action, via_ring);
    }
}

/// SAction.spec.md: compose(a, b).apply_vec(v) = apply_vec(a, apply_vec(b, v))
#[test]
fn composition_is_sequential_application() {
    let mut rng = seeded_rng(0x5ACE);
    for _ in 0..10 {
        let a = Rq::random_small(&mut rng, 50);
        let b = Rq::random_small(&mut rng, 50);
        let v: [Fq; D] = std::array::from_fn(|_| Fq::from_u64(rng.random_range(0..100)));

        let sa = SAction::from_ring(a);
        let sb = SAction::from_ring(b);

        let composed = sa.compose(&sb).apply_vec(&v);
        let sequential = sa.apply_vec(&sb.apply_vec(&v));

        assert_eq!(composed, sequential);
    }
}

/// SAction.spec.md: scalar(f).apply_vec(v) = f * v (coefficient-wise)
#[test]
fn scalar_action_is_scaling() {
    let mut rng = seeded_rng(0x5ACE);
    let f = Fq::from_u64(42);
    let v: [Fq; D] = std::array::from_fn(|_| Fq::from_u64(rng.random::<u64>()));

    let via_action = SAction::scalar(f).apply_vec(&v);
    let via_scale: [Fq; D] = std::array::from_fn(|i| f * v[i]);

    assert_eq!(via_action, via_scale);
}

/// SAction.spec.md: to_matrix column j = cf(a * X^j mod Phi_81)
#[test]
fn to_matrix_columns() {
    let mut rng = seeded_rng(0x5ACE);
    let a = Rq::random_small(&mut rng, 10);
    let s = SAction::from_ring(a);
    let mat = s.to_matrix();

    for j in 0..D {
        let expected = cf(a.mul_by_monomial(j));
        for i in 0..D {
            assert_eq!(mat.values[i * D + j], expected[i], "mismatch at ({i},{j})");
        }
    }
}

/// SAction.spec.md: apply_k_vec rejects nonzero elements at index >= D
#[test]
fn k_vec_rejects_nonzero_padding() {
    let a = Rq::one();
    let s = SAction::from_ring(a);

    // Vector longer than D with nonzero tail
    let mut y = vec![K::ZERO; D + 4];
    y[D] = from_complex(Fq::ONE, Fq::ZERO);

    assert!(s.apply_k_vec(&y).is_err());
}

/// SAction.spec.md: apply_k_vec accepts zero-padded vectors
#[test]
fn k_vec_accepts_zero_padding() {
    let a = Rq::one();
    let s = SAction::from_ring(a);

    let y = vec![K::ZERO; D + 4];
    assert!(s.apply_k_vec(&y).is_ok());
}

/// SAction.spec.md: K-action linearity — apply_k_vec(a, u + v) = apply_k_vec(a, u) + apply_k_vec(a, v)
#[test]
fn k_action_linear() {
    let mut rng = seeded_rng(0x5ACE);
    let a = Rq::random_small(&mut rng, 10);
    let s = SAction::from_ring(a);

    let u: Vec<K> = (0..D)
        .map(|_| {
            from_complex(
                Fq::from_u64(rng.random_range(0..100)),
                Fq::from_u64(rng.random_range(0..100)),
            )
        })
        .collect();
    let v: Vec<K> = (0..D)
        .map(|_| {
            from_complex(
                Fq::from_u64(rng.random_range(0..100)),
                Fq::from_u64(rng.random_range(0..100)),
            )
        })
        .collect();

    let sum: Vec<K> = u.iter().zip(v.iter()).map(|(&a, &b)| a + b).collect();
    let action_sum = s.apply_k_vec(&sum).unwrap();
    let action_u = s.apply_k_vec(&u).unwrap();
    let action_v = s.apply_k_vec(&v).unwrap();
    let sum_actions: Vec<K> = action_u
        .iter()
        .zip(action_v.iter())
        .map(|(&a, &b)| a + b)
        .collect();

    assert_eq!(action_sum, sum_actions);
}

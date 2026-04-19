use neo_abba::{commit, setup, verify_open, Commitment};
use neo_math::quaternion::{QuatEl, TracelessEl};
use neo_math::ring::{Rq, D};
use neo_math::Fq;
use p3_field::PrimeCharacteristicRing;
use rand::SeedableRng;
use rand_chacha::ChaCha8Rng;

fn make_rng() -> ChaCha8Rng {
    ChaCha8Rng::seed_from_u64(42)
}

#[test]
fn commit_verify_roundtrip() {
    let mut rng = make_rng();
    let d = D;
    let kappa = 4;
    let m = 8;
    let pp = setup(&mut rng, d, kappa, m).unwrap();

    // Binary witness: d*m elements
    let z: Vec<Fq> = (0..d * m)
        .map(|i| if i % 3 == 0 { Fq::ONE } else { Fq::ZERO })
        .collect();

    let c = commit(&pp, &z);
    assert!(verify_open(&pp, &c, &z), "commit-verify roundtrip failed");

    let mut z_bad = z.clone();
    z_bad[0] = Fq::from_u64(2);
    assert!(!verify_open(&pp, &c, &z_bad), "modified witness should fail");
}

#[test]
fn commit_zero_witness() {
    let mut rng = make_rng();
    let d = D;
    let kappa = 4;
    let m = 4;
    let pp = setup(&mut rng, d, kappa, m).unwrap();

    let z = vec![Fq::ZERO; d * m];
    let c = commit(&pp, &z);
    assert_eq!(c, Commitment::zeros(d, kappa), "commit(0) should be zero");
}

#[test]
fn commit_linearity() {
    let mut rng = make_rng();
    let d = D;
    let kappa = 4;
    let m = 8;
    let pp = setup(&mut rng, d, kappa, m).unwrap();

    let z1: Vec<Fq> = (0..d * m).map(|i| Fq::from_u64((i % 5) as u64)).collect();
    let z2: Vec<Fq> = (0..d * m).map(|i| Fq::from_u64((i % 3) as u64)).collect();

    let c1 = commit(&pp, &z1);
    let c2 = commit(&pp, &z2);
    let z_sum: Vec<Fq> = z1.iter().zip(&z2).map(|(&a, &b)| a + b).collect();
    let c_sum = commit(&pp, &z_sum);

    let mut c12 = c1.clone();
    c12.add_inplace(&c2);
    assert_eq!(c12, c_sum, "commit(z1) + commit(z2) should equal commit(z1+z2)");
}

#[test]
fn scale_commitment_test() {
    let mut rng = make_rng();
    let d = D;
    let kappa = 4;
    let m = 4;
    let pp = setup(&mut rng, d, kappa, m).unwrap();

    let z: Vec<Fq> = (0..d * m).map(|i| Fq::from_u64((i % 3) as u64)).collect();
    let c = commit(&pp, &z);
    let scalar = Fq::from_u64(7);
    let scaled = neo_abba::scale_commitment(scalar, &c);
    let sz: Vec<Fq> = z.iter().map(|&v| v * scalar).collect();
    assert_eq!(scaled, commit(&pp, &sz), "scalar * C(z) = C(scalar*z)");
}

// ─── Column-based {0, u} embedding tests ─────────────────────────────────────

/// Single column with one nonzero bit at position t: should match [A, (0, X^t)].
#[test]
fn column_single_bit_each_position() {
    let mut rng = make_rng();
    let d = D;
    let kappa = 2;
    let m = 1; // single column
    let pp = setup(&mut rng, d, kappa, m).unwrap();

    for t in 0..d {
        let mut z = vec![Fq::ZERO; d * m];
        z[t] = Fq::ONE; // bit at position t in column 0

        let c = commit(&pp, &z);

        for i in 0..kappa {
            // Expected: [A[i][0], (0, X^t)] via sparse commutator
            let expected = pp.a_rows[i][0].commutator_with_uz_sparse(&[t]);
            assert_eq!(c.col(i), expected.as_slice(), "single bit at position {t}, kappa {i}");
        }
    }
}

/// Column with all bits set: should match [A, (0, sum X^t)] via generic commutator.
#[test]
fn column_all_bits_set() {
    let mut rng = make_rng();
    let d = D;
    let kappa = 2;
    let m = 1;
    let pp = setup(&mut rng, d, kappa, m).unwrap();

    let z = vec![Fq::ONE; d * m]; // all 1s
    let c = commit(&pp, &z);

    // Build z_rq = sum_{t=0}^{d-1} X^t
    let mut z_coeffs = [Fq::ZERO; D];
    for t in 0..d {
        z_coeffs[t] = Fq::ONE;
    }
    let z_rq = Rq(z_coeffs);
    let z_quat = QuatEl {
        a0: Rq::zero(),
        a1: z_rq,
    };

    for i in 0..kappa {
        let generic = QuatEl::commutator(&pp.a_rows[i][0], &z_quat);
        let expected = TracelessEl::from_components(&generic.a0, &generic.a1);
        assert_eq!(
            c.col(i),
            expected.as_slice(),
            "all-ones column should match generic commutator"
        );
    }
}

/// Multiple columns: verify additivity across columns.
#[test]
fn multi_column_additivity() {
    let mut rng = make_rng();
    let d = D;
    let kappa = 3;
    let m = 4;
    let pp = setup(&mut rng, d, kappa, m).unwrap();

    // Commit each column separately, then sum
    let z: Vec<Fq> = (0..d * m)
        .map(|i| if i % 2 == 0 { Fq::ONE } else { Fq::ZERO })
        .collect();

    let c_full = commit(&pp, &z);

    let mut c_sum = Commitment::zeros(d, kappa);
    for j in 0..m {
        let mut z_single = vec![Fq::ZERO; d * m];
        z_single[j * d..(j + 1) * d].copy_from_slice(&z[j * d..(j + 1) * d]);
        let c_j = commit(&pp, &z_single);
        c_sum.add_inplace(&c_j);
    }

    assert_eq!(c_full, c_sum, "commit(z) should equal sum of per-column commits");
}

/// Verify the sparse path matches the generic commutator path for each column.
#[test]
fn sparse_matches_generic_per_column() {
    let mut rng = make_rng();
    let d = D;
    let kappa = 2;
    let m = 3;
    let pp = setup(&mut rng, d, kappa, m).unwrap();

    // Witness with varying density per column
    let z: Vec<Fq> = (0..d * m)
        .map(|i| Fq::from_u64(((i * 7 + 3) % 2) as u64))
        .collect();

    let c = commit(&pp, &z);

    // Manually compute using generic quaternion commutator
    for i in 0..kappa {
        let mut expected = TracelessEl::zero();
        for j in 0..m {
            let col = &z[j * d..(j + 1) * d];
            let mut z_coeffs = [Fq::ZERO; D];
            z_coeffs[..d].copy_from_slice(col);
            let z_rq = Rq(z_coeffs);
            let z_quat = QuatEl {
                a0: Rq::zero(),
                a1: z_rq,
            };
            let comm = QuatEl::commutator(&pp.a_rows[i][j], &z_quat);
            expected += TracelessEl::from_components(&comm.a0, &comm.a1);
        }
        assert_eq!(
            c.col(i),
            expected.as_slice(),
            "sparse commit should match generic at kappa {i}"
        );
    }
}

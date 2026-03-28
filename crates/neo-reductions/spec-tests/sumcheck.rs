//! Spec-derived invariant tests for SumCheck.spec.md
//!
//! Each test corresponds to a row in the Invariant Obligations table.

#[path = "common/mod.rs"]
mod common;

use neo_math::{Fq, K};
use neo_reductions::sumcheck::{
    interpolate_from_evals, poly_eval_k, poly_eval_k_base, run_sumcheck_prover, verify_sumcheck_rounds, RoundOracle,
    SumcheckError,
};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

/// A trivial oracle for testing: g(x_0, ..., x_{n-1}) = c (constant).
/// The sum over {0,1}^n equals c * 2^n.
struct ConstantOracle {
    value: K,
    rounds: usize,
    current_round: usize,
}

impl ConstantOracle {
    fn new(value: K, rounds: usize) -> Self {
        Self {
            value,
            rounds,
            current_round: 0,
        }
    }
}

impl RoundOracle for ConstantOracle {
    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let remaining = self.rounds - self.current_round - 1;
        let scale = K::from(Fq::from_u64(1u64 << remaining));
        points.iter().map(|_| self.value * scale).collect()
    }

    fn num_rounds(&self) -> usize {
        self.rounds
    }

    fn degree_bound(&self) -> usize {
        1
    }

    fn fold(&mut self, _r: K) {
        self.current_round += 1;
    }
}

/// A linear oracle for testing: g(x_0, ..., x_{n-1}) = sum_i x_i.
struct LinearOracle {
    rounds: usize,
    current_round: usize,
    accumulated: K,
}

impl LinearOracle {
    fn new(rounds: usize) -> Self {
        Self {
            rounds,
            current_round: 0,
            accumulated: K::ZERO,
        }
    }
}

impl RoundOracle for LinearOracle {
    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let remaining = self.rounds - self.current_round - 1;
        let two_remaining = K::from(Fq::from_u64(1u64 << remaining));
        let tail_sum = if remaining > 0 {
            K::from(Fq::from_u64((remaining as u64) * (1u64 << (remaining - 1))))
        } else {
            K::ZERO
        };
        let base = self.accumulated * two_remaining + tail_sum;
        points.iter().map(|&x| base + x * two_remaining).collect()
    }

    fn num_rounds(&self) -> usize {
        self.rounds
    }

    fn degree_bound(&self) -> usize {
        1
    }

    fn fold(&mut self, r: K) {
        self.accumulated += r;
        self.current_round += 1;
    }
}

// ---------------------------------------------------------------------------
// 1. poly_eval_k correctness
// ---------------------------------------------------------------------------

/// SumCheck.spec.md: poly_eval_k correctness (Horner agrees with naive)
#[test]
fn poly_eval_k_correctness() {
    let coeffs = [
        K::from(Fq::from_u64(3)),
        K::from(Fq::from_u64(2)),
        K::from(Fq::from_u64(5)),
    ];
    let x = K::from(Fq::from_u64(7));
    let result = poly_eval_k(&coeffs, x);
    let expected = K::from(Fq::from_u64(262)); // 3 + 2*7 + 5*49
    assert_eq!(result, expected, "Horner evaluation should match naive");
}

/// SumCheck.spec.md: poly_eval_k empty coefficients returns zero
#[test]
fn poly_eval_k_empty() {
    let result = poly_eval_k(&[], K::from(Fq::from_u64(42)));
    assert_eq!(result, K::ZERO, "empty polynomial should evaluate to zero");
}

// ---------------------------------------------------------------------------
// 2. poly_eval_k_base consistency
// ---------------------------------------------------------------------------

/// SumCheck.spec.md: poly_eval_k_base agrees with poly_eval_k for base-field inputs
#[test]
fn poly_eval_k_base_consistency() {
    let coeffs = [
        K::from(Fq::from_u64(1)),
        K::from(Fq::from_u64(3)),
        K::from(Fq::from_u64(7)),
        K::from(Fq::from_u64(2)),
    ];

    for x_val in 0..20u64 {
        let x_base = Fq::from_u64(x_val);
        let x_ext = K::from(x_base);

        let result_base = poly_eval_k_base(&coeffs, x_base);
        let result_ext = poly_eval_k(&coeffs, x_ext);
        assert_eq!(
            result_base, result_ext,
            "poly_eval_k_base and poly_eval_k should agree for x={x_val}"
        );
    }
}

// ---------------------------------------------------------------------------
// 3. interpolate_from_evals round-trip
// ---------------------------------------------------------------------------

/// SumCheck.spec.md: interpolate round-trip: poly_eval_k(interp(xs,ys), xs[i]) == ys[i]
#[test]
fn interpolate_round_trip() {
    let xs = [
        K::from(Fq::from_u64(0)),
        K::from(Fq::from_u64(1)),
        K::from(Fq::from_u64(2)),
    ];
    let ys = [
        K::from(Fq::from_u64(1)),
        K::from(Fq::from_u64(6)),
        K::from(Fq::from_u64(17)),
    ];

    let coeffs = interpolate_from_evals(&xs, &ys);

    for (i, (&x, &y)) in xs.iter().zip(ys.iter()).enumerate() {
        let eval = poly_eval_k(&coeffs, x);
        assert_eq!(eval, y, "interpolation round-trip failed at point {i}");
    }
}

// ---------------------------------------------------------------------------
// 4. Prover-verifier roundtrip (constant oracle)
// ---------------------------------------------------------------------------

/// SumCheck.spec.md: Prover-verifier agreement for constant oracle
#[test]
fn prover_verifier_roundtrip_constant() {
    let rounds = 3;
    let value = K::from(Fq::from_u64(5));
    let initial_sum = value * K::from(Fq::from_u64(1u64 << rounds));

    let mut tr_prove = Poseidon2Transcript::new(b"test_sumcheck");
    let mut oracle = ConstantOracle::new(value, rounds);
    let (round_polys, prover_challenges) =
        run_sumcheck_prover(&mut tr_prove, &mut oracle, initial_sum).expect("prover should succeed");

    assert_eq!(round_polys.len(), rounds);
    assert_eq!(prover_challenges.len(), rounds);

    let mut tr_verify = Poseidon2Transcript::new(b"test_sumcheck");
    let (verifier_challenges, _final_sum, is_valid) =
        verify_sumcheck_rounds(&mut tr_verify, 1, initial_sum, &round_polys);

    assert!(is_valid, "verifier should accept honest prover's proof");
    assert_eq!(prover_challenges, verifier_challenges);
}

// ---------------------------------------------------------------------------
// 5. Prover-verifier roundtrip (linear oracle)
// ---------------------------------------------------------------------------

/// SumCheck.spec.md: Prover-verifier agreement for linear oracle
#[test]
fn prover_verifier_roundtrip_linear() {
    let rounds = 4;
    let initial_sum = K::from(Fq::from_u64(rounds as u64 * (1u64 << (rounds - 1))));

    let mut tr_prove = Poseidon2Transcript::new(b"test_sumcheck_linear");
    let mut oracle = LinearOracle::new(rounds);
    let (round_polys, prover_challenges) =
        run_sumcheck_prover(&mut tr_prove, &mut oracle, initial_sum).expect("prover should succeed for linear oracle");

    let mut tr_verify = Poseidon2Transcript::new(b"test_sumcheck_linear");
    let (verifier_challenges, _final_sum, is_valid) =
        verify_sumcheck_rounds(&mut tr_verify, 1, initial_sum, &round_polys);

    assert!(is_valid, "verifier should accept linear oracle proof");
    assert_eq!(prover_challenges, verifier_challenges);
}

// ---------------------------------------------------------------------------
// 6. Verifier rejects tampered round polynomial
// ---------------------------------------------------------------------------

/// SumCheck.spec.md: Verifier rejects tampered round polynomial
#[test]
fn verifier_rejects_tampered_rounds() {
    let rounds = 3;
    let value = K::from(Fq::from_u64(5));
    let initial_sum = value * K::from(Fq::from_u64(1u64 << rounds));

    let mut tr_prove = Poseidon2Transcript::new(b"test_sumcheck_tamper");
    let mut oracle = ConstantOracle::new(value, rounds);
    let (mut round_polys, _) =
        run_sumcheck_prover(&mut tr_prove, &mut oracle, initial_sum).expect("prover should succeed");

    if !round_polys[0].is_empty() {
        round_polys[0][0] += K::from(Fq::from_u64(1));
    }

    let mut tr_verify = Poseidon2Transcript::new(b"test_sumcheck_tamper");
    let (_, _, is_valid) = verify_sumcheck_rounds(&mut tr_verify, 1, initial_sum, &round_polys);

    assert!(!is_valid, "verifier should reject tampered round polynomial");
}

// ---------------------------------------------------------------------------
// 7. Verifier rejects degree violation
// ---------------------------------------------------------------------------

/// SumCheck.spec.md: Verifier rejects polynomial exceeding degree bound
#[test]
fn verifier_rejects_degree_violation() {
    let round_poly = vec![
        K::from(Fq::from_u64(1)),
        K::from(Fq::from_u64(2)),
        K::from(Fq::from_u64(3)),
    ]; // degree 2

    let initial_sum = poly_eval_k(&round_poly, K::ZERO) + poly_eval_k(&round_poly, K::ONE);

    let mut tr = Poseidon2Transcript::new(b"test_degree");
    let degree_bound = 1; // Only allows degree 1
    let (_, _, is_valid) = verify_sumcheck_rounds(&mut tr, degree_bound, initial_sum, &[round_poly]);

    assert!(!is_valid, "verifier should reject polynomial exceeding degree bound");
}

// ---------------------------------------------------------------------------
// 8. Round consistency invariant
// ---------------------------------------------------------------------------

/// SumCheck.spec.md: Round consistency p(0) + p(1) = running_sum
#[test]
fn round_consistency_invariant() {
    let rounds = 3;
    let value = K::from(Fq::from_u64(7));
    let initial_sum = value * K::from(Fq::from_u64(1u64 << rounds));

    let mut tr = Poseidon2Transcript::new(b"test_consistency");
    let mut oracle = ConstantOracle::new(value, rounds);
    let (round_polys, challenges) =
        run_sumcheck_prover(&mut tr, &mut oracle, initial_sum).expect("prover should succeed");

    let mut running = initial_sum;
    for (i, (poly, &challenge)) in round_polys.iter().zip(challenges.iter()).enumerate() {
        let p0 = poly_eval_k(poly, K::ZERO);
        let p1 = poly_eval_k(poly, K::ONE);
        assert_eq!(p0 + p1, running, "round {i}: p(0) + p(1) should equal running sum");
        running = poly_eval_k(poly, challenge);
    }
}

// ---------------------------------------------------------------------------
// 9. Wrong initial sum is caught by prover
// ---------------------------------------------------------------------------

/// SumCheck.spec.md: Prover detects wrong initial sum
#[test]
fn prover_detects_wrong_initial_sum() {
    let rounds = 2;
    let value = K::from(Fq::from_u64(5));
    let wrong_sum = K::from(Fq::from_u64(999));

    let mut tr = Poseidon2Transcript::new(b"test_wrong_sum");
    let mut oracle = ConstantOracle::new(value, rounds);
    let result = run_sumcheck_prover(&mut tr, &mut oracle, wrong_sum);

    assert!(result.is_err(), "prover should fail with incorrect initial sum");
    match result.unwrap_err() {
        SumcheckError::Invariant { round, .. } => {
            assert_eq!(round, 0, "should fail at round 0");
        }
        other => panic!("expected Invariant error, got {other:?}"),
    }
}

//! Spec-derived tests for Decomposition.spec.md invariant obligations.
//!
//! Covers: round-trip, digit bounds, col vs row-major equivalence,
//! split_b round-trip, assert_range_b.

use neo_ajtai::{decomp_b, decomp_b_row_major, split_b, assert_range_b, DecompStyle};
use neo_math::Fq;
use p3_field::PrimeCharacteristicRing;
use rand_chacha::{rand_core::SeedableRng, ChaCha8Rng};
use rand::Rng;

fn random_fq_vec(rng: &mut impl Rng, len: usize) -> Vec<Fq> {
    (0..len).map(|_| Fq::from_u64(rng.random::<u64>())).collect()
}

fn recompose(digits: &[Fq], b: u32, d: usize, m: usize) -> Vec<Fq> {
    // Column-major: digits[col * d + row] = digit at (row, col)
    let mut result = vec![Fq::ZERO; m];
    for col in 0..m {
        let mut power = Fq::ONE;
        let b_fq = Fq::from_u64(b as u64);
        for row in 0..d {
            result[col] += digits[col * d + row] * power;
            power *= b_fq;
        }
    }
    result
}

/// Decomposition.spec.md: round-trip z = Sigma b^i * d_i (balanced)
#[test]
fn decomp_round_trip_balanced() {
    let mut rng = ChaCha8Rng::seed_from_u64(1);
    // d=64 covers the full Goldilocks balanced range (|val| < 2^63)
    let d = 64;
    for b in [2u32, 3, 5, 7] {
        let z = random_fq_vec(&mut rng, 8);
        let digits = decomp_b(&z, b, d, DecompStyle::Balanced);
        let recomp = recompose(&digits, b, d, z.len());
        assert_eq!(recomp, z, "balanced round-trip failed for b={b}");
    }
}

/// Decomposition.spec.md: round-trip z = Sigma b^i * d_i (non-negative)
///
/// Non-negative decomposition operates on `to_balanced_i64` values, so round-trip
/// is only valid for elements with positive balanced representation (x < q/2).
/// We use small values to stay in this range.
#[test]
fn decomp_round_trip_nonneg() {
    let mut rng = ChaCha8Rng::seed_from_u64(2);
    let d = 64;
    for b in [2u32, 3, 5] {
        // Small positive values ensure positive balanced representation
        let z: Vec<Fq> = (0..8)
            .map(|_| Fq::from_u64((rng.random::<u32>() as u64) % 100_000))
            .collect();
        let digits = decomp_b(&z, b, d, DecompStyle::NonNegative);
        let recomp = recompose(&digits, b, d, z.len());
        assert_eq!(recomp, z, "non-negative round-trip failed for b={b}");
    }
}

/// Decomposition.spec.md: digit bound ||d_j||_inf < b (balanced)
#[test]
fn decomp_digit_bound_balanced() {
    let mut rng = ChaCha8Rng::seed_from_u64(3);
    for b in [2u32, 3, 5] {
        let z = random_fq_vec(&mut rng, 8);
        let d = 64;
        let digits = decomp_b(&z, b, d, DecompStyle::Balanced);
        assert!(assert_range_b(&digits, b).is_ok(), "balanced digit out of range for b={b}");
    }
}

/// Decomposition.spec.md: column-major vs row-major transpose equivalence
#[test]
fn decomp_col_vs_row_major() {
    let mut rng = ChaCha8Rng::seed_from_u64(4);
    let z = random_fq_vec(&mut rng, 8);
    let b = 3u32;
    let d = 14;
    let m = z.len();
    let col_major = decomp_b(&z, b, d, DecompStyle::Balanced);
    let row_major = decomp_b_row_major(&z, b, d, DecompStyle::Balanced);
    // Transpose: col_major[col * d + row] == row_major[row * m + col]
    for row in 0..d {
        for col in 0..m {
            assert_eq!(
                col_major[col * d + row],
                row_major[row * m + col],
                "col/row major mismatch at ({row},{col})"
            );
        }
    }
}

/// Decomposition.spec.md: split_b round-trip
///
/// split_b decomposes each entry of a d×m matrix into k base-b digits.
/// k must be large enough to represent all entry values.
#[test]
fn split_b_round_trip() {
    let d = 4;
    let m = 3;
    let b = 2u32;
    let k = 64; // enough digits for any Goldilocks balanced value
    // Use small values so balanced decomposition is well-defined
    let z: Vec<Fq> = (0..d * m)
        .map(|i| Fq::from_u64((i as u64) * 7 + 1))
        .collect();
    let splits = split_b(&z, b, d, m, k, DecompStyle::Balanced);
    assert_eq!(splits.len(), k);
    // Recompose: z = Sigma b^i * splits[i]
    let mut recomp = vec![Fq::ZERO; d * m];
    let b_fq = Fq::from_u64(b as u64);
    let mut power = Fq::ONE;
    for split in &splits {
        for (j, &digit) in split.iter().enumerate() {
            recomp[j] += digit * power;
        }
        power *= b_fq;
    }
    assert_eq!(recomp, z, "split_b round-trip failed");
}

/// Decomposition.spec.md: assert_range_b catches out-of-range digits
#[test]
fn assert_range_b_catches_violation() {
    let bad = vec![Fq::from_u64(10)]; // |10| >= 3
    assert!(assert_range_b(&bad, 3).is_err(), "should reject out-of-range digit");
    let good = vec![Fq::from_u64(1), Fq::ZERO];
    assert!(assert_range_b(&good, 3).is_ok(), "should accept in-range digit");
}

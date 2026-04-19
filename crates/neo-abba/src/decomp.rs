//! Bit decomposition utilities for ABBA witnesses.
//!
//! These are pure F_q operations identical to neo-ajtai's decomposition.
//! Copied here to avoid coupling neo-abba to neo-ajtai.

use crate::error::{AbbaError, AbbaResult};
use p3_field::{PrimeCharacteristicRing, PrimeField64};
use p3_goldilocks::Goldilocks as Fq;

/// Decomposition style.
#[derive(Copy, Clone, Debug, Eq, PartialEq)]
pub enum DecompStyle {
    Balanced,
    NonNegative,
}

#[inline]
fn to_balanced_i64(x: Fq) -> i64 {
    const Q: u64 = <Fq as PrimeField64>::ORDER_U64;
    const HALF: u64 = (Q - 1) / 2;
    let u = x.as_canonical_u64();
    if u <= HALF {
        u as i64
    } else {
        -((Q - u) as i64)
    }
}

#[inline]
fn balanced_digit_and_next(a: i64, b_i64: i64) -> (i64, i64) {
    debug_assert!(b_i64 >= 2);
    let half = b_i64 / 2;
    let residue = a.rem_euclid(b_i64);
    let digit = if residue < half {
        residue
    } else if residue == half {
        if a < 0 {
            residue - b_i64
        } else {
            residue
        }
    } else {
        residue - b_i64
    };
    let next = (a - digit) / b_i64;
    (digit, next)
}

/// decomp_b: vector z in F_q^m -> Z in F_q^{d x m} with ||Z||_inf < b.
#[allow(non_snake_case)]
pub fn decomp_b(z: &[Fq], b: u32, d: usize, style: DecompStyle) -> Vec<Fq> {
    let m = z.len();
    let b_i64 = b as i64;
    let mut Z = Vec::with_capacity(d * m);

    for &zij in z {
        let mut a = to_balanced_i64(zij);
        for _ in 0..d {
            let (digit, next) = match style {
                DecompStyle::NonNegative => {
                    let r = a.rem_euclid(b_i64);
                    let n = (a - r) / b_i64;
                    (r, n)
                }
                DecompStyle::Balanced => balanced_digit_and_next(a, b_i64),
            };
            let fq_digit = if digit >= 0 {
                Fq::from_u64(digit as u64)
            } else {
                Fq::ZERO - Fq::from_u64((-digit) as u64)
            };
            Z.push(fq_digit);
            a = next;
        }
    }
    Z
}

/// Assert all values fit in [-b/2, b/2] (balanced range check).
#[allow(non_snake_case)]
pub fn assert_range_b(Z: &[Fq], b: u32) -> AbbaResult<()> {
    let half = (b / 2) as i64;
    for (idx, &z) in Z.iter().enumerate() {
        let v = to_balanced_i64(z);
        if v.unsigned_abs() > half as u64 {
            return Err(AbbaError::InvalidDimensions(format!(
                "range violation at index {idx}: |{v}| > {half}"
            )));
        }
    }
    Ok(())
}

/// Split Z into k decomposition levels.
#[allow(non_snake_case)]
pub fn split_b(Z: &[Fq], b: u32, d: usize, m: usize, k: usize, style: DecompStyle) -> Vec<Vec<Fq>> {
    let full = decomp_b(Z, b, d * k, style);
    let mut levels = Vec::with_capacity(k);
    for level in 0..k {
        let mut part = Vec::with_capacity(d * m);
        for j in 0..m {
            for t in 0..d {
                part.push(full[j * (d * k) + level * d + t]);
            }
        }
        levels.push(part);
    }
    levels
}

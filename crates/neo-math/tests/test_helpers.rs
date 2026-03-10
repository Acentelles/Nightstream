//! Test helpers for neo-math tests
//! This module contains constants and functions that are only needed for testing.

use neo_math::Fq;
use p3_field::TwoAdicField;

/// Goldilocks modulus for test assertions
#[allow(dead_code)]
pub const GOLDILOCKS_MODULUS: u128 = 18446744069414584321u128;

/// Two-adicity of F_q^* (Goldilocks has 2^32 | q-1).
#[allow(dead_code)]
pub const TWO_ADICITY: usize = <Fq as TwoAdicField>::TWO_ADICITY;

/// Provide a two-adic generator (2^bits-th root of unity) for NTT tests.
#[inline]
#[allow(dead_code)]
pub fn two_adic_generator(bits: usize) -> Fq {
    <Fq as TwoAdicField>::two_adic_generator(bits)
}

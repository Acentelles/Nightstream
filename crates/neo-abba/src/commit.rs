//! ABBA commitment operations: setup, commit, verify, S-action.
//!
//! Owns: commit/verify lifecycle and S-homomorphic operations on ABBA commitments.
//! Does NOT own: quaternion arithmetic (neo-math), decomposition (decomp.rs).
//!
//! ## Column-based approach for Neo (b=2)
//!
//! Each column of the witness Z (d field elements) is packed into one Rq element
//! z_j = sum_t z_t X^t and embedded as the quaternion (0, z_j). The commitment
//! for kappa-row i is:
//!
//!   output[i] = sum_{j=0}^{m-1} [A[i][j], (0, z_j)]
//!
//! For binary z_t in {0, 1}, the commutator decomposes via bilinearity into a
//! sum over nonzero bits, each contributing [A, (0, X^t)]. These are computed
//! using `commutator_with_uz_sparse`, which uses only additions and
//! mul_by_monomial (zero Fq multiplications).
//!
//! This approach uses m keys per kappa-row (matching Ajtai), while the output
//! lives in T_0 (81 Fq per kappa-slot).

use crate::error::{AbbaError, AbbaResult};
use crate::types::{Commitment, PP};
use neo_math::quaternion::{QuatEl, TracelessEl};
use neo_math::ring::{Rq, D};
use neo_math::Fq;
use p3_field::{PrimeCharacteristicRing, PrimeField64};
use rand::{CryptoRng, RngCore};

/// Sample a uniform element from F_q using rejection sampling.
#[inline]
fn sample_uniform_fq<R: RngCore + CryptoRng>(rng: &mut R) -> Fq {
    const Q: u64 = <Fq as PrimeField64>::ORDER_U64;
    loop {
        let x = rng.next_u64();
        if x < Q {
            return Fq::from_u64(x);
        }
    }
}

/// Sample a uniform quaternion element from Lambda_q.
fn sample_uniform_quat<R: RngCore + CryptoRng>(rng: &mut R) -> QuatEl {
    let a0 = Rq(core::array::from_fn(|_| sample_uniform_fq(rng)));
    let a1 = Rq(core::array::from_fn(|_| sample_uniform_fq(rng)));
    QuatEl { a0, a1 }
}

/// Generate ABBA public parameters: key matrix A in Lambda_q^{kappa x m}.
///
/// Same key count as Ajtai: m keys per kappa-row. Each key is a QuatEl
/// (2 x D = 108 Fq elements, vs Ajtai's Rq = 54 Fq elements per key).
#[allow(non_snake_case)]
pub fn setup<R: RngCore + CryptoRng>(rng: &mut R, d: usize, kappa: usize, m: usize) -> AbbaResult<PP> {
    if kappa == 0 || m == 0 || d == 0 {
        return Err(AbbaError::InvalidDimensions("kappa, m, d must be positive".into()));
    }

    let mut a_rows = Vec::with_capacity(kappa);
    for _ in 0..kappa {
        let row: Vec<QuatEl> = (0..m).map(|_| sample_uniform_quat(rng)).collect();
        a_rows.push(row);
    }

    Ok(PP { kappa, m, d, a_rows })
}

/// ABBA commit: column-based with sparse multiplication for b=2.
///
/// Z is d*m field elements (same layout as Ajtai: d rows, m columns,
/// column-major). For each column j, the d entries Z[j*d..j*d+d] are
/// packed into z_j = sum_t Z[j*d+t] X^t, and the commitment accumulates
/// [A[i][j], (0, z_j)] for each kappa-row i.
///
/// For binary witnesses (b=2), this uses `commutator_with_uz_sparse`
/// which costs O(w*D) additions per column (zero multiplications),
/// where w is the column's Hamming weight.
#[allow(non_snake_case)]
pub fn try_commit(pp: &PP, Z: &[Fq]) -> AbbaResult<Commitment> {
    let d = pp.d;
    let m = pp.m;
    let kappa = pp.kappa;

    if Z.len() != d * m {
        return Err(AbbaError::SizeMismatch {
            expected: d * m,
            actual: Z.len(),
        });
    }

    let mut c = Commitment::zeros(d, kappa);

    for i in 0..kappa {
        let mut acc = TracelessEl::zero();

        for j in 0..m {
            let col = &Z[j * d..j * d + d];

            // Collect nonzero bit positions in this column
            let bits: Vec<usize> = col
                .iter()
                .enumerate()
                .filter(|(_, &v)| v != Fq::ZERO)
                .map(|(t, _)| t)
                .collect();

            if bits.is_empty() {
                continue;
            }

            // Check if all nonzero entries are binary (the fast path)
            let all_binary = col.iter().all(|&v| v == Fq::ZERO || v == Fq::ONE);

            if all_binary {
                // Sparse commutator: zero Fq multiplications
                acc += pp.a_rows[i][j].commutator_with_uz_sparse(&bits);
            } else {
                // General case: build z_j as Rq and use full commutator
                let mut z_coeffs = [Fq::ZERO; D];
                z_coeffs[..d.min(D)].copy_from_slice(&col[..d.min(D)]);
                let z_rq = Rq(z_coeffs);
                let z_quat = QuatEl {
                    a0: Rq::zero(),
                    a1: z_rq,
                };
                let comm = QuatEl::commutator(&pp.a_rows[i][j], &z_quat);
                acc += TracelessEl::from_components(&comm.a0, &comm.a1);
            }
        }

        c.col_mut(i).copy_from_slice(acc.as_slice());
    }

    Ok(c)
}

/// Convenience wrapper that panics on dimension mismatch.
#[allow(non_snake_case)]
pub fn commit(pp: &PP, Z: &[Fq]) -> Commitment {
    try_commit(pp, Z).expect("commit: Z dimensions must match d*m")
}

/// Verify opening by recomputing commitment.
#[must_use = "ABBA verification must be checked"]
#[allow(non_snake_case)]
pub fn verify_open(pp: &PP, c: &Commitment, Z: &[Fq]) -> bool {
    &commit(pp, Z) == c
}

/// Verify split opening: c == sum b^{i-1} c_i and each c_i opens to Z_i.
#[must_use = "ABBA verification must be checked"]
#[allow(non_snake_case)]
pub fn verify_split_open(pp: &PP, c: &Commitment, b: u32, c_is: &[Commitment], z_is: &[Vec<Fq>]) -> bool {
    let k = c_is.len();
    if k != z_is.len() {
        return false;
    }
    for ci in c_is {
        if ci.kappa != c.kappa {
            return false;
        }
    }
    let mut acc = Commitment::zeros(c.d, c.kappa);
    let mut pow = Fq::ONE;
    let b_f = Fq::from_u64(b as u64);
    for i in 0..k {
        for (a, &x) in acc.data.iter_mut().zip(&c_is[i].data) {
            *a += x * pow;
        }
        pow *= b_f;
    }
    if &acc != c {
        return false;
    }
    let n = pp.d * pp.m;
    let mut z_full = vec![Fq::ZERO; n];
    let mut pow = Fq::ONE;
    for zi in z_is {
        if zi.len() != n {
            return false;
        }
        for (a, &x) in z_full.iter_mut().zip(zi) {
            *a += x * pow;
        }
        pow *= b_f;
    }
    &commit(pp, &z_full) == c
}

/// S-homomorphism: alpha * c for alpha in O_{K,q} (the real subfield).
pub fn s_mul(alpha: &Rq, c: &Commitment) -> Commitment {
    let kappa = c.kappa;
    let mut out = Commitment::zeros(c.d, kappa);
    s_mul_add(&mut out, alpha, c);
    out
}

/// Accumulate alpha * c into acc.
pub fn s_mul_add(acc: &mut Commitment, alpha: &Rq, c: &Commitment) {
    let kappa = c.kappa;
    debug_assert_eq!(acc.kappa, kappa);

    for i in 0..kappa {
        let src_slice = c.col(i);
        let mut t = TracelessEl::zero();
        t.data.copy_from_slice(src_slice);
        let scaled = t.scale_ok(alpha);
        let dst = acc.col_mut(i);
        for (d, &s) in dst.iter_mut().zip(scaled.as_slice().iter()) {
            *d += s;
        }
    }
}

/// Linear combination: sum_i alpha_i * c_i.
pub fn s_lincomb(alphas: &[Rq], cs: &[Commitment]) -> AbbaResult<Commitment> {
    if alphas.is_empty() || cs.is_empty() {
        return Err(AbbaError::EmptyInput);
    }
    if alphas.len() != cs.len() {
        return Err(AbbaError::SizeMismatch {
            expected: alphas.len(),
            actual: cs.len(),
        });
    }
    let mut acc = Commitment::zeros(cs[0].d, cs[0].kappa);
    for (alpha, c) in alphas.iter().zip(cs) {
        s_mul_add(&mut acc, alpha, c);
    }
    Ok(acc)
}

/// Scale commitment by a base-field scalar.
pub fn scale_commitment(scalar: Fq, c: &Commitment) -> Commitment {
    let mut out = Commitment::zeros(c.d, c.kappa);
    scale_commitment_add_inplace(&mut out, scalar, c);
    out
}

/// Add a field-scalar multiple of a commitment into an accumulator.
pub fn scale_commitment_add_inplace(acc: &mut Commitment, scalar: Fq, c: &Commitment) {
    debug_assert_eq!(acc.kappa, c.kappa);
    if scalar == Fq::ZERO {
        return;
    }
    if scalar == Fq::ONE {
        acc.add_inplace(c);
        return;
    }
    for (dst, src) in acc.data.iter_mut().zip(c.data.iter()) {
        *dst += *src * scalar;
    }
}

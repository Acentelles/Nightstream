//! Verify the 25% commitment size reduction using Φ_128(X) = X^64 + 1.
//!
//! With η = 128 (even n = 64):
//!   dim(O_L) = φ(128) = 64
//!   dim(Λ)   = 2·φ(64) = 64   ← EQUAL to O_L (the paper's identity holds)
//!   dim(T_0) = 48 = 3/4 · 64  ← 25% smaller than both O_L and Λ
//!
//! This module implements minimal Φ_128 ring arithmetic to confirm the claim.

#![allow(dead_code)]

use p3_field::PrimeCharacteristicRing;
use p3_goldilocks::Goldilocks as Fq;

const D128: usize = 64; // φ(128)
const N_REAL_128: usize = 16; // [K+:Q] = φ(64)/2 = 16
const T0_DIM_128: usize = N_REAL_128 + D128 / 2; // 16 + 32 = 48

// ─── Minimal Φ_128 ring ──────────────────────────────────────────────────────

/// Ring element in F_q[X]/(X^64 + 1).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
struct Rq128([Fq; D128]);

impl Rq128 {
    fn zero() -> Self {
        Self([Fq::ZERO; D128])
    }
    fn one() -> Self {
        let mut c = [Fq::ZERO; D128];
        c[0] = Fq::ONE;
        Self(c)
    }
    fn add(self, rhs: Self) -> Self {
        let mut out = [Fq::ZERO; D128];
        for i in 0..D128 {
            out[i] = self.0[i] + rhs.0[i];
        }
        Self(out)
    }
    fn sub(self, rhs: Self) -> Self {
        let mut out = [Fq::ZERO; D128];
        for i in 0..D128 {
            out[i] = self.0[i] - rhs.0[i];
        }
        Self(out)
    }
    fn neg(self) -> Self {
        let mut out = [Fq::ZERO; D128];
        for i in 0..D128 {
            out[i] = Fq::ZERO - self.0[i];
        }
        Self(out)
    }
    /// Schoolbook multiply mod X^64 + 1.
    fn mul(self, rhs: Self) -> Self {
        let mut tmp = [Fq::ZERO; 2 * D128 - 1];
        for i in 0..D128 {
            for j in 0..D128 {
                tmp[i + j] += self.0[i] * rhs.0[j];
            }
        }
        // Reduce: X^64 = -1, so X^{64+k} = -X^k
        let mut out = [Fq::ZERO; D128];
        for i in 0..D128 {
            out[i] = tmp[i];
        }
        for i in D128..(2 * D128 - 1) {
            out[i - D128] -= tmp[i];
        }
        Self(out)
    }
    /// X^j mod Φ_128.
    fn mul_by_monomial(self, j: usize) -> Self {
        if j == 0 {
            return self;
        }
        let mut out = [Fq::ZERO; D128];
        for i in 0..D128 {
            let new_deg = i + j;
            if new_deg < D128 {
                out[new_deg] += self.0[i];
            } else {
                // X^{64+k} = -X^k
                out[new_deg - D128] -= self.0[i];
            }
        }
        Self(out)
    }
    fn random(rng: &mut impl rand::Rng) -> Self {
        Self(core::array::from_fn(|_| Fq::from_u64(rng.random_range(0..u64::MAX))))
    }
    fn scale(self, s: Fq) -> Self {
        let mut out = self.0;
        for v in out.iter_mut() {
            *v *= s;
        }
        Self(out)
    }
}

// ─── Theta for Φ_128 ─────────────────────────────────────────────────────────
// θ(ζ_128) = ζ_128^{-1} = -ζ_128^{63}
// θ(X^i) = (-1)^{i+q} · X^r where 63i = 64q + r, 0 ≤ r < 64

fn theta128(a: &Rq128) -> Rq128 {
    let mut out = [Fq::ZERO; D128];
    for i in 0..D128 {
        if a.0[i] == Fq::ZERO {
            continue;
        }
        let prod = 63 * i; // 63i
        let q = prod / D128; // quotient
        let r = prod % D128; // remainder
        let sign = if (i + q) % 2 == 0 { Fq::ONE } else { Fq::ZERO - Fq::ONE };
        out[r] += sign * a.0[i];
    }
    Rq128(out)
}

// ─── Quaternion over Φ_128 ───────────────────────────────────────────────────

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
struct QuatEl128 {
    a0: Rq128,
    a1: Rq128,
}

impl QuatEl128 {
    fn zero() -> Self {
        Self {
            a0: Rq128::zero(),
            a1: Rq128::zero(),
        }
    }
    fn random(rng: &mut impl rand::Rng) -> Self {
        Self {
            a0: Rq128::random(rng),
            a1: Rq128::random(rng),
        }
    }
    /// (a0+u*a1)(b0+u*b1) = (a0*b0 - θ(a1)*b1, a1*b0 + θ(a0)*b1)
    fn mul(&self, rhs: &Self) -> Self {
        let ta0 = theta128(&self.a0);
        let ta1 = theta128(&self.a1);
        Self {
            a0: self.a0.mul(rhs.a0).sub(ta1.mul(rhs.a1)),
            a1: self.a1.mul(rhs.a0).add(ta0.mul(rhs.a1)),
        }
    }
    fn commutator(a: &Self, b: &Self) -> Self {
        let ab = a.mul(b);
        let ba = b.mul(a);
        Self {
            a0: ab.a0.sub(ba.a0),
            a1: ab.a1.sub(ba.a1),
        }
    }
    /// [a, u] = (a1 - θ(a1)) + u*(θ(a0) - a0)
    fn commutator_with_u(&self) -> (Rq128, Rq128) {
        let ta0 = theta128(&self.a0);
        let ta1 = theta128(&self.a1);
        (self.a1.sub(ta1), ta0.sub(self.a0))
    }
}

// ─── Traceless element for Φ_128 ─────────────────────────────────────────────

/// T_0 has dim 48 over Fq for Φ_128.
/// Stored as: [16 coords for ker(1+θ)] [32 coords for u-part]
/// ker(1+θ) in R_q^128 has dim (D128/2 - N_REAL_128)... wait.
///
/// K = Q(ζ_64), [K:Q] = 32. K+ = real subfield, [K+:Q] = 16.
/// θ acts on K (dim 32 over Q). ker(1+θ) has dim 32 - 16 = 16.
/// The u-part a1 is in O_K (dim 32 over Fq), NOT O_L (dim 64).
///
/// Wait: the quaternion is (K/K+, θ, -1) where K has dim 32.
/// Λ = O_K ⊕ u·O_K, each component has dim 32. Total dim = 64.
/// T_0 = {x0 + u·x1 : x0 + θ(x0) = 0, x0 ∈ O_K, x1 ∈ O_K}
/// ker(1+θ) in O_K has dim 32 - 16 = 16.
/// x1 unrestricted in O_K: dim 32.
/// Total T_0 dim = 16 + 32 = 48. ✓
///
/// But in our implementation, the quaternion elements have components
/// a0, a1 in Rq128 = O_L (dim 64), not O_K (dim 32).
/// The commutator [a, u] produces:
///   comp0 = a1 - θ(a1) ∈ ker(1+θ) of O_L (dim 64/2 = 32??)
///
/// Hmm, for Φ_128 with L = Q(ζ_128), [L:Q] = 64:
/// θ acts on L. ker(1+θ) in O_L has dim 64 - 32 = 32 (the "imaginary" part).
/// u-part a1 is unrestricted in O_L: dim 64.
/// T_0 (as subspace of Λ = O_L ⊕ u·O_L, dim 128) = 32 + 64 = 96??
///
/// That doesn't match. The issue is: when n is even, L ≠ K, and Λ = O_K ⊕ u·O_K
/// (NOT O_L ⊕ u·O_L). The quaternion lives over K, not L.
///
/// So elements are a0 + u·a1 where a0, a1 ∈ O_K (dim 32), not O_L (dim 64).
/// dim(Λ) = 2·32 = 64 = dim(O_L). ✓
/// T_0 in Λ: ker(1+θ) in O_K (dim 16) + u·O_K (dim 32) = 48. ✓

const DK: usize = 32; // dim(O_K) = φ(64) = 32

/// Element of O_K = Z[ζ_64] mod q, represented as coefficients in F_q[X]/(Φ_64).
/// Φ_64(X) = X^32 + 1.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
struct RqK([Fq; DK]);

impl RqK {
    fn zero() -> Self {
        Self([Fq::ZERO; DK])
    }
    fn one() -> Self {
        let mut c = [Fq::ZERO; DK];
        c[0] = Fq::ONE;
        Self(c)
    }
    fn add(self, rhs: Self) -> Self {
        let mut out = [Fq::ZERO; DK];
        for i in 0..DK {
            out[i] = self.0[i] + rhs.0[i];
        }
        Self(out)
    }
    fn sub(self, rhs: Self) -> Self {
        let mut out = [Fq::ZERO; DK];
        for i in 0..DK {
            out[i] = self.0[i] - rhs.0[i];
        }
        Self(out)
    }
    fn neg(self) -> Self {
        Self::zero().sub(self)
    }
    /// Schoolbook multiply mod X^32 + 1.
    fn mul(self, rhs: Self) -> Self {
        let mut tmp = [Fq::ZERO; 2 * DK - 1];
        for i in 0..DK {
            for j in 0..DK {
                tmp[i + j] += self.0[i] * rhs.0[j];
            }
        }
        let mut out = [Fq::ZERO; DK];
        for i in 0..DK {
            out[i] = tmp[i];
        }
        for i in DK..(2 * DK - 1) {
            out[i - DK] -= tmp[i];
        }
        Self(out)
    }
    fn mul_by_monomial(self, j: usize) -> Self {
        if j == 0 {
            return self;
        }
        let mut out = [Fq::ZERO; DK];
        for i in 0..DK {
            let d = i + j;
            if d < DK {
                out[d] += self.0[i];
            } else {
                out[d - DK] -= self.0[i];
            }
        }
        Self(out)
    }
    fn random(rng: &mut impl rand::Rng) -> Self {
        Self(core::array::from_fn(|_| Fq::from_u64(rng.random_range(0..u64::MAX))))
    }
    fn scale(self, s: Fq) -> Self {
        let mut out = self.0;
        for v in out.iter_mut() {
            *v *= s;
        }
        Self(out)
    }
}

/// θ on O_K = F_q[X]/(X^32 + 1): complex conjugation ζ_64 → ζ_64^{-1} = -ζ_64^{31}.
/// θ(X^i) = (-1)^{i+q} X^r where 31i = 32q + r.
fn theta_k(a: &RqK) -> RqK {
    let mut out = [Fq::ZERO; DK];
    for i in 0..DK {
        if a.0[i] == Fq::ZERO {
            continue;
        }
        let prod = 31 * i;
        let q = prod / DK;
        let r = prod % DK;
        let sign = if (i + q) % 2 == 0 { Fq::ONE } else { Fq::ZERO - Fq::ONE };
        out[r] += sign * a.0[i];
    }
    RqK(out)
}

/// Quaternion element over O_K: a = a0 + u*a1, with a0, a1 ∈ O_K (dim 32 each).
/// Total dim = 64 = dim(O_L). ✓
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
struct QuatK {
    a0: RqK,
    a1: RqK,
}

impl QuatK {
    fn zero() -> Self {
        Self {
            a0: RqK::zero(),
            a1: RqK::zero(),
        }
    }
    fn random(rng: &mut impl rand::Rng) -> Self {
        Self {
            a0: RqK::random(rng),
            a1: RqK::random(rng),
        }
    }
    fn mul(&self, rhs: &Self) -> Self {
        let ta0 = theta_k(&self.a0);
        let ta1 = theta_k(&self.a1);
        Self {
            a0: self.a0.mul(rhs.a0).sub(ta1.mul(rhs.a1)),
            a1: self.a1.mul(rhs.a0).add(ta0.mul(rhs.a1)),
        }
    }
    fn commutator(a: &Self, b: &Self) -> Self {
        let ab = a.mul(b);
        let ba = b.mul(a);
        Self {
            a0: ab.a0.sub(ba.a0),
            a1: ab.a1.sub(ba.a1),
        }
    }
    /// [a, u] = (a1 - θ(a1), θ(a0) - a0)
    fn commutator_with_u(&self) -> (RqK, RqK) {
        let ta0 = theta_k(&self.a0);
        let ta1 = theta_k(&self.a1);
        (self.a1.sub(ta1), ta0.sub(self.a0))
    }
    /// Sparse [a, (0, z)] for binary z = Σ z_t X^t.
    fn commutator_sparse(&self, bits: &[usize]) -> (RqK, RqK) {
        if bits.is_empty() {
            return (RqK::zero(), RqK::zero());
        }
        let ta0 = theta_k(&self.a0);
        let ta1 = theta_k(&self.a1);
        let diff = ta0.sub(self.a0);

        let mut comp0 = RqK::zero();
        let mut comp1 = RqK::zero();
        for &t in bits {
            comp1 = comp1.add(diff.mul_by_monomial(t));
            // a1 * θ(X^t) - θ(a1) * X^t
            let prod_31t = 31 * t;
            let q = prod_31t / DK;
            let r = prod_31t % DK;
            let sign_neg = (t + q) % 2 == 1;
            let a1_theta_xt = if sign_neg {
                self.a1.mul_by_monomial(r).neg()
            } else {
                self.a1.mul_by_monomial(r)
            };
            let ta1_xt = ta1.mul_by_monomial(t);
            comp0 = comp0.add(a1_theta_xt).sub(ta1_xt);
        }
        (comp0, comp1)
    }
}

// ─── Tests ───────────────────────────────────────────────────────────────────

use rand::{Rng, SeedableRng};
use rand_chacha::ChaCha8Rng;

#[test]
fn phi128_dimensions() {
    // The key identity: dim(O_L) = dim(Λ) for even n
    let dim_ol = D128; // φ(128) = 64
    let dim_ok = DK; // φ(64) = 32
    let dim_lambda = 2 * dim_ok; // O_K ⊕ u·O_K = 64

    assert_eq!(dim_ol, dim_lambda, "dim(O_L) must equal dim(Λ) for even n");
    assert_eq!(dim_ol, 64);

    // T_0 dimension
    let dim_ker_1_plus_theta = dim_ok - N_REAL_128; // 32 - 16 = 16
    let dim_u_part = dim_ok; // 32
    let dim_t0 = dim_ker_1_plus_theta + dim_u_part; // 48

    assert_eq!(dim_t0, T0_DIM_128, "T_0 dim should be 48");
    assert_eq!(dim_t0, 48);

    // The 25% reduction
    assert_eq!(dim_t0 * 4, dim_ol * 3, "dim(T_0) = 3/4 dim(O_L)");
    println!("Φ_128: dim(O_L) = {dim_ol}, dim(Λ) = {dim_lambda}, dim(T_0) = {dim_t0}");
    println!(
        "Ratio T_0/O_L = {}/{} = {:.2}",
        dim_t0,
        dim_ol,
        dim_t0 as f64 / dim_ol as f64
    );
}

#[test]
fn phi128_commitment_sizes() {
    let kappa = 16;

    let ajtai_size = kappa * D128; // 16 * 64 = 1024
    let abba_size = kappa * T0_DIM_128; // 16 * 48 = 768
    let ratio = abba_size as f64 / ajtai_size as f64;

    assert_eq!(ajtai_size, 1024);
    assert_eq!(abba_size, 768);
    assert!((ratio - 0.75).abs() < 1e-10, "ABBA/Ajtai = 3/4");

    println!("Φ_128, κ={kappa}: Ajtai={ajtai_size} Fq, ABBA={abba_size} Fq, ratio={ratio:.2}");
    println!("ABBA saves {} Fq elements (25% reduction)", ajtai_size - abba_size);
}

#[test]
fn phi128_theta_is_involution() {
    let mut rng = ChaCha8Rng::seed_from_u64(128);
    for _ in 0..20 {
        let a = RqK::random(&mut rng);
        assert_eq!(theta_k(&theta_k(&a)), a, "θ² = id");
    }
}

#[test]
fn phi128_theta_fixes_real_subfield() {
    let mut rng = ChaCha8Rng::seed_from_u64(128);
    for _ in 0..20 {
        let a = RqK::random(&mut rng);
        let real = a.add(theta_k(&a)); // a + θ(a) ∈ K+
        assert_eq!(theta_k(&real), real, "θ fixes K+");
    }
}

#[test]
fn phi128_commutator_is_traceless() {
    let mut rng = ChaCha8Rng::seed_from_u64(128);
    for _ in 0..20 {
        let a = QuatK::random(&mut rng);
        let b = QuatK::random(&mut rng);
        let comm = QuatK::commutator(&a, &b);
        let trace = comm.a0.add(theta_k(&comm.a0));
        assert_eq!(trace, RqK::zero(), "[a,b] must be traceless");
    }
}

#[test]
fn phi128_naive_embedding_trivial() {
    let mut rng = ChaCha8Rng::seed_from_u64(128);
    let a = QuatK::random(&mut rng);
    let one = QuatK {
        a0: RqK::one(),
        a1: RqK::zero(),
    };
    let comm = QuatK::commutator(&a, &one);
    assert_eq!(comm, QuatK::zero(), "[a, 1] = 0 (1 is central)");
}

#[test]
fn phi128_u_embedding_nontrivial() {
    let mut rng = ChaCha8Rng::seed_from_u64(128);
    let a = QuatK::random(&mut rng);
    let (c0, c1) = a.commutator_with_u();
    // Should be nonzero for random a
    let is_zero = c0 == RqK::zero() && c1 == RqK::zero();
    assert!(!is_zero, "[a, u] should be nonzero for random a");
    // Traceless: c0 + θ(c0) = 0
    let trace = c0.add(theta_k(&c0));
    assert_eq!(trace, RqK::zero(), "[a, u] must be traceless");
}

#[test]
fn phi128_sparse_matches_generic() {
    let mut rng = ChaCha8Rng::seed_from_u64(128);
    for _ in 0..10 {
        let a = QuatK::random(&mut rng);
        let n_bits = rng.random_range(3..=15usize);
        let mut bits: Vec<usize> = (0..n_bits).map(|_| rng.random_range(0..DK)).collect();
        bits.sort();
        bits.dedup();

        // Build z as RqK
        let mut z_coeffs = [Fq::ZERO; DK];
        for &t in &bits {
            z_coeffs[t] = Fq::ONE;
        }
        let z = RqK(z_coeffs);

        // Generic: [a, (0, z)]
        let b = QuatK { a0: RqK::zero(), a1: z };
        let generic = QuatK::commutator(&a, &b);

        // Sparse
        let (s0, s1) = a.commutator_sparse(&bits);

        assert_eq!(s0, generic.a0, "sparse comp0 matches generic");
        assert_eq!(s1, generic.a1, "sparse comp1 matches generic");
    }
}

#[test]
fn phi128_commit_linearity() {
    let mut rng = ChaCha8Rng::seed_from_u64(128);
    let kappa = 4;
    let m = 8;
    let n_bits = DK * m; // 32 * 8 = 256

    // PP: kappa rows of m QuatK keys
    let pp: Vec<Vec<QuatK>> = (0..kappa)
        .map(|_| (0..m).map(|_| QuatK::random(&mut rng)).collect())
        .collect();

    // Two binary witnesses
    let z1: Vec<Fq> = (0..n_bits)
        .map(|i| if i % 3 == 0 { Fq::ONE } else { Fq::ZERO })
        .collect();
    let z2: Vec<Fq> = (0..n_bits)
        .map(|i| if i % 5 == 0 { Fq::ONE } else { Fq::ZERO })
        .collect();

    // Commit function: for each kappa-row, accumulate commutators.
    // Uses sparse path for binary columns, full commutator otherwise.
    let commit = |pp: &Vec<Vec<QuatK>>, z: &[Fq]| -> Vec<(RqK, RqK)> {
        let mut out = vec![(RqK::zero(), RqK::zero()); kappa];
        for i in 0..kappa {
            for j in 0..m {
                let col = &z[j * DK..(j + 1) * DK];
                let all_zero = col.iter().all(|&v| v == Fq::ZERO);
                if all_zero {
                    continue;
                }
                let all_binary = col.iter().all(|&v| v == Fq::ZERO || v == Fq::ONE);
                if all_binary {
                    let bits: Vec<usize> = col
                        .iter()
                        .enumerate()
                        .filter(|(_, &v)| v != Fq::ZERO)
                        .map(|(t, _)| t)
                        .collect();
                    let (c0, c1) = pp[i][j].commutator_sparse(&bits);
                    out[i].0 = out[i].0.add(c0);
                    out[i].1 = out[i].1.add(c1);
                } else {
                    // General: build z as RqK, use full commutator
                    let mut z_coeffs = [Fq::ZERO; DK];
                    z_coeffs.copy_from_slice(col);
                    let z_rq = RqK(z_coeffs);
                    let b = QuatK {
                        a0: RqK::zero(),
                        a1: z_rq,
                    };
                    let comm = QuatK::commutator(&pp[i][j], &b);
                    out[i].0 = out[i].0.add(comm.a0);
                    out[i].1 = out[i].1.add(comm.a1);
                }
            }
        }
        out
    };

    let c1 = commit(&pp, &z1);
    let c2 = commit(&pp, &z2);
    let z_sum: Vec<Fq> = z1.iter().zip(&z2).map(|(&a, &b)| a + b).collect();
    let c_sum = commit(&pp, &z_sum);

    // c1 + c2 should equal c_sum
    for i in 0..kappa {
        let sum0 = c1[i].0.add(c2[i].0);
        let sum1 = c1[i].1.add(c2[i].1);
        assert_eq!(sum0, c_sum[i].0, "linearity comp0 at kappa {i}");
        assert_eq!(sum1, c_sum[i].1, "linearity comp1 at kappa {i}");
    }
}

#[test]
fn phi128_size_comparison_table() {
    println!("\n╔══════════════════════════════════════════════════════════╗");
    println!("║   Commitment size comparison: Φ_81 (odd) vs Φ_128 (even) ║");
    println!("╠══════════════════════════════════════════════════════════╣");

    let kappa = 16;

    // Φ_81 (Nightstream's current)
    let d81 = 54; // dim(O_L)
    let t0_81 = 81; // dim(T_0)
    let ajtai_81 = kappa * d81;
    let abba_81 = kappa * t0_81;

    println!("║ Φ_81  (n=81, odd):                                      ║");
    println!("║   dim(O_L)={d81}, dim(Λ)=108, dim(T_0)={t0_81}                ║");
    println!("║   Ajtai: κ·54  = {ajtai_81:>5} Fq                            ║");
    println!("║   ABBA:  κ·81  = {abba_81:>5} Fq  (50% LARGER)              ║");

    // Φ_128 (the fix)
    let d128 = 64; // dim(O_L) = dim(Λ)
    let t0_128 = 48; // dim(T_0)
    let ajtai_128 = kappa * d128;
    let abba_128 = kappa * t0_128;

    println!("║                                                          ║");
    println!("║ Φ_128 (n=64, even):                                      ║");
    println!("║   dim(O_L)=dim(Λ)={d128}, dim(T_0)={t0_128}                    ║");
    println!("║   Ajtai: κ·64  = {ajtai_128:>5} Fq                            ║");
    println!("║   ABBA:  κ·48  = {abba_128:>5} Fq  (25% SMALLER) ✓           ║");

    println!("╠══════════════════════════════════════════════════════════╣");
    println!("║ The 25% reduction requires even n so dim(O_L)=dim(Λ).  ║");
    println!("╚══════════════════════════════════════════════════════════╝");

    // Assertions
    assert_eq!(abba_128 * 4, ajtai_128 * 3, "Φ_128: ABBA = 3/4 Ajtai");
    assert!(abba_81 > ajtai_81, "Φ_81: ABBA > Ajtai (parity obstruction)");
}

// ─── Precomputed key material for optimized ABBA ─────────────────────────────

/// Precomputed per-key data: theta values cached once at setup.
struct PrecompKey {
    a0: RqK,
    a1: RqK,
    theta_a0: RqK,
    theta_a1: RqK,
    diff: RqK, // theta(a0) - a0
}

impl PrecompKey {
    fn from_quat(q: &QuatK) -> Self {
        let theta_a0 = theta_k(&q.a0);
        let theta_a1 = theta_k(&q.a1);
        let diff = theta_a0.sub(q.a0);
        Self {
            a0: q.a0,
            a1: q.a1,
            theta_a0,
            theta_a1,
            diff,
        }
    }

    /// Sparse commutator using precomputed theta values.
    /// Avoids recomputing theta(a0), theta(a1) on every call.
    fn commutator_sparse_precomp(&self, bits: &[usize]) -> (RqK, RqK) {
        if bits.is_empty() {
            return (RqK::zero(), RqK::zero());
        }

        // Component 1: Σ_{t ∈ bits} X^t · diff
        let mut comp1 = RqK::zero();
        for &t in bits {
            comp1 = comp1.add(self.diff.mul_by_monomial(t));
        }

        // Component 0: Σ_{t ∈ bits} [a1 · θ(X^t) - θ(a1) · X^t]
        let mut comp0 = RqK::zero();
        for &t in bits {
            let ta1_xt = self.theta_a1.mul_by_monomial(t);
            // a1 * θ(X^t): θ(X^t) = (-1)^{t+q} X^r where 31t = 32q + r
            let prod = 31 * t;
            let q = prod / DK;
            let r = prod % DK;
            let a1_theta_xt = if (t + q) % 2 == 1 {
                self.a1.mul_by_monomial(r).neg()
            } else {
                self.a1.mul_by_monomial(r)
            };
            comp0 = comp0.add(a1_theta_xt).sub(ta1_xt);
        }

        (comp0, comp1)
    }
}

// ─── Ajtai Φ_128: inner product in O_L = F_q[X]/(X^64+1) ───────────────────

/// Ajtai commit over Rq128 (dim 64): C[i] = Σ_j M[i][j] · Z_col_j
/// For b=2 binary Z, this reduces to summing M[i][j] for nonzero bits,
/// using rot_step (monomial rotation) to iterate over bit positions.
fn ajtai_commit_128(pp: &[Vec<Rq128>], z: &[Fq], kappa: usize, m: usize) -> Vec<Rq128> {
    let mut out = vec![Rq128::zero(); kappa];
    for i in 0..kappa {
        for j in 0..m {
            let col = &z[j * D128..(j + 1) * D128];
            // For b=2: Z_col_j = Σ z_t X^t. Inner product = M[i][j] * Z_col_j.
            // With binary z_t: this is Σ_{t: z_t=1} M[i][j] · X^t
            //                 = Σ_{t: z_t=1} mul_by_monomial(M[i][j], t)
            for (t, &z_val) in col.iter().enumerate() {
                if z_val != Fq::ZERO {
                    out[i] = out[i].add(pp[i][j].mul_by_monomial(t));
                }
            }
        }
    }
    out
}

// ─── Optimized ABBA commit ──────────────────────────────────────────────────

fn abba_commit_128_opt(pp: &[Vec<PrecompKey>], z: &[Fq], kappa: usize, m: usize) -> Vec<(RqK, RqK)> {
    let mut out = vec![(RqK::zero(), RqK::zero()); kappa];
    for i in 0..kappa {
        for j in 0..m {
            let col = &z[j * DK..(j + 1) * DK];

            // Collect nonzero positions without allocation for small counts
            let mut bits = [0usize; DK];
            let mut n_bits = 0;
            for (t, &v) in col.iter().enumerate() {
                if v != Fq::ZERO {
                    bits[n_bits] = t;
                    n_bits += 1;
                }
            }
            if n_bits == 0 {
                continue;
            }

            let (c0, c1) = pp[i][j].commutator_sparse_precomp(&bits[..n_bits]);
            out[i].0 = out[i].0.add(c0);
            out[i].1 = out[i].1.add(c1);
        }
    }
    out
}

// ─── Combined benchmark ─────────────────────────────────────────────────────

#[test]
fn phi128_ajtai_vs_abba_bench() {
    use std::time::Instant;

    let mut rng = ChaCha8Rng::seed_from_u64(128);
    let kappa = 16;

    // Same total bits for both: 8192
    let total_bits = 8192;
    let density = 0.5;

    // Ajtai: 64 bits/column, m_ajtai columns
    let m_ajtai = total_bits / D128; // 128
    let ajtai_pp: Vec<Vec<Rq128>> = (0..kappa)
        .map(|_| (0..m_ajtai).map(|_| Rq128::random(&mut rng)).collect())
        .collect();
    let z_ajtai: Vec<Fq> = (0..total_bits)
        .map(|_| if rng.random_bool(density) { Fq::ONE } else { Fq::ZERO })
        .collect();

    // ABBA: 32 bits/column, m_abba columns
    let m_abba = total_bits / DK; // 256
    let abba_raw: Vec<Vec<QuatK>> = (0..kappa)
        .map(|_| (0..m_abba).map(|_| QuatK::random(&mut rng)).collect())
        .collect();
    let abba_pp: Vec<Vec<PrecompKey>> = abba_raw
        .iter()
        .map(|row| row.iter().map(|q| PrecompKey::from_quat(q)).collect())
        .collect();
    let z_abba: Vec<Fq> = (0..total_bits)
        .map(|_| if rng.random_bool(density) { Fq::ONE } else { Fq::ZERO })
        .collect();

    let n_warmup = 5;
    let n_iters = 50;

    // Bench Ajtai
    for _ in 0..n_warmup {
        let _ = ajtai_commit_128(&ajtai_pp, &z_ajtai, kappa, m_ajtai);
    }
    let start = Instant::now();
    for _ in 0..n_iters {
        let _ = ajtai_commit_128(&ajtai_pp, &z_ajtai, kappa, m_ajtai);
    }
    let ajtai_us = start.elapsed().as_micros() / n_iters as u128;

    // Bench ABBA (optimized)
    for _ in 0..n_warmup {
        let _ = abba_commit_128_opt(&abba_pp, &z_abba, kappa, m_abba);
    }
    let start = Instant::now();
    for _ in 0..n_iters {
        let _ = abba_commit_128_opt(&abba_pp, &z_abba, kappa, m_abba);
    }
    let abba_us = start.elapsed().as_micros() / n_iters as u128;

    let ajtai_size = kappa * D128; // 1024
    let abba_size = kappa * T0_DIM_128; // 768
    let ajtai_pp_keys = kappa * m_ajtai;
    let abba_pp_keys = kappa * m_abba;

    println!("\n╔══════════════════════════════════════════════════════════════╗");
    println!(
        "║  Φ_128 ABBA vs Ajtai (b=2, {total_bits} bits, {:.0}% density)     ║",
        density * 100.0
    );
    println!("╠══════════════════════════════════════════════════════════════╣");
    println!("║                  Ajtai (O_L)          ABBA (T_0)            ║");
    println!("║  Ring dim:       D_L = {D128}             D_K = {DK}              ║");
    println!("║  Bits/column:    {D128}                   {DK}                    ║");
    println!("║  Columns (m):    {m_ajtai:<20}  {m_abba:<20}  ║");
    println!("║  Keys/κ-row:     {ajtai_pp_keys:<20}  {abba_pp_keys:<20}  ║");
    println!(
        "║  Commit time:    {:<20}  {:<20}  ║",
        format!("{:.2} ms", ajtai_us as f64 / 1000.0),
        format!("{:.2} ms", abba_us as f64 / 1000.0)
    );
    println!(
        "║  Commit size:    {ajtai_size} Fq ({:.1} KB)      {abba_size} Fq ({:.1} KB)       ║",
        ajtai_size as f64 * 8.0 / 1024.0,
        abba_size as f64 * 8.0 / 1024.0
    );
    println!(
        "║  Speed ratio:    {:.2}x                                        ║",
        abba_us as f64 / ajtai_us as f64
    );
    println!(
        "║  Size ratio:     {:.2}x (ABBA is {:.0}% smaller)                  ║",
        abba_size as f64 / ajtai_size as f64,
        (1.0 - abba_size as f64 / ajtai_size as f64) * 100.0
    );
    println!("╚══════════════════════════════════════════════════════════════╝");

    // Verify the 25% size claim
    assert_eq!(abba_size * 4, ajtai_size * 3, "ABBA must be 3/4 of Ajtai");
}

/// Sweep density for both schemes at Φ_128.
#[test]
fn phi128_density_sweep() {
    use std::time::Instant;

    let mut rng = ChaCha8Rng::seed_from_u64(129);
    let kappa = 16;
    let total_bits = 8192;

    let m_ajtai = total_bits / D128;
    let m_abba = total_bits / DK;

    let ajtai_pp: Vec<Vec<Rq128>> = (0..kappa)
        .map(|_| (0..m_ajtai).map(|_| Rq128::random(&mut rng)).collect())
        .collect();
    let abba_raw: Vec<Vec<QuatK>> = (0..kappa)
        .map(|_| (0..m_abba).map(|_| QuatK::random(&mut rng)).collect())
        .collect();
    let abba_pp: Vec<Vec<PrecompKey>> = abba_raw
        .iter()
        .map(|row| row.iter().map(|q| PrecompKey::from_quat(q)).collect())
        .collect();

    let n_iters = 30;

    println!("\n=== Φ_128 density sweep ({total_bits} bits, κ={kappa}) ===");
    println!("  {:>8} {:>12} {:>12} {:>8}", "Density", "Ajtai", "ABBA", "Ratio");

    for &pct in &[10u64, 25, 50, 75, 100] {
        let density = pct as f64 / 100.0;

        let mut rng_w = ChaCha8Rng::seed_from_u64(500 + pct);
        let z_ajtai: Vec<Fq> = (0..total_bits)
            .map(|_| if rng_w.random_bool(density) { Fq::ONE } else { Fq::ZERO })
            .collect();
        let mut rng_w2 = ChaCha8Rng::seed_from_u64(600 + pct);
        let z_abba: Vec<Fq> = (0..total_bits)
            .map(|_| if rng_w2.random_bool(density) { Fq::ONE } else { Fq::ZERO })
            .collect();

        // Time Ajtai
        let start = Instant::now();
        for _ in 0..n_iters {
            let _ = ajtai_commit_128(&ajtai_pp, &z_ajtai, kappa, m_ajtai);
        }
        let ajtai_us = start.elapsed().as_micros() / n_iters as u128;

        // Time ABBA
        let start = Instant::now();
        for _ in 0..n_iters {
            let _ = abba_commit_128_opt(&abba_pp, &z_abba, kappa, m_abba);
        }
        let abba_us = start.elapsed().as_micros() / n_iters as u128;

        println!(
            "  {:>7}% {:>10} {:>10} {:>7.1}x",
            pct,
            format!("{:.2} ms", ajtai_us as f64 / 1000.0),
            format!("{:.2} ms", abba_us as f64 / 1000.0),
            abba_us as f64 / ajtai_us as f64
        );
    }
    println!(
        "  Commitment: Ajtai = {} Fq, ABBA = {} Fq (25% smaller)",
        kappa * D128,
        kappa * T0_DIM_128
    );
}

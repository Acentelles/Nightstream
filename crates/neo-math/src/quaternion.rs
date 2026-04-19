//! Quaternion algebra types for ABBA commitments.
//!
//! Owns: QuatEl (quaternion elements over R_q), TracelessEl (traceless subspace T_0),
//! theta automorphism, and the commutator [a,b] = ab - ba.
//!
//! Does NOT own: ring arithmetic (see ring.rs), field arithmetic (see field.rs).

use crate::ring::{Rq, D};
use crate::Fq;
use p3_field::{Field, PrimeCharacteristicRing};
use std::ops::{Add, AddAssign, Neg, Sub};
use std::sync::OnceLock;

/// Degree of the maximal real subfield K = Q(zeta_81 + zeta_81^{-1}).
/// [K:Q] = phi(81)/2 = 27.
pub const N_REAL: usize = D / 2; // 27

/// Dimension of the traceless subspace T_0 over F_q.
/// T_0 = ker(1+theta) direct-sum u*O_{L,q}, dim = N_REAL + D = 27 + 54 = 81.
pub const T0_DIM: usize = N_REAL + D; // 81

/// Complex conjugation automorphism theta on R_q = F_q[X]/(Phi_81).
///
/// theta(zeta_81) = zeta_81^{-1} = zeta_81^{80}, so theta(f)(X) = f(X^{80}).
/// Since X^{81} = 1 mod Phi_81, the exponent 80*i reduces mod 81 to (81-i) for i >= 1.
///
/// Concretely:
///   - Coefficient 0 maps to itself.
///   - For i in 1..=27: X^{81-i} = X^{54+(27-i)} = -X^{27+(27-i)} - X^{27-i} mod Phi_81.
///   - For i in 28..54: X^{81-i} has degree < 54, no reduction needed.
pub fn theta(a: &Rq) -> Rq {
    let c = &a.0;
    let mut out = [Fq::ZERO; D];

    out[0] = c[0];

    for i in 1..=27usize {
        let k = 27 - i;
        // c_i * X^{54+k} = c_i * (-X^{27+k} - X^k) mod Phi_81
        out[27 + k] -= c[i];
        out[k] -= c[i];
    }

    for i in 28..D {
        out[81 - i] += c[i];
    }

    Rq(out)
}

/// Precomputed 54x54 matrix for theta, applied as out = M_theta * coeffs.
fn theta_matrix() -> &'static [[Fq; D]; D] {
    static M: OnceLock<[[Fq; D]; D]> = OnceLock::new();
    M.get_or_init(|| {
        let mut mat = [[Fq::ZERO; D]; D];
        for i in 0..D {
            let mut basis = [Fq::ZERO; D];
            basis[i] = Fq::ONE;
            let img = theta(&Rq(basis));
            for j in 0..D {
                mat[j][i] = img.0[j];
            }
        }
        mat
    })
}

/// Quaternion element a = a0 + u*a1 in the natural order Lambda_q.
///
/// Algebra structure: (L/K, theta, -1) where L = Q(zeta_81), K = Q(zeta_81 + zeta_81^{-1}).
/// Relations: u*l = theta(l)*u for l in L, u^2 = -1.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct QuatEl {
    pub a0: Rq,
    pub a1: Rq,
}

impl QuatEl {
    #[inline]
    pub fn zero() -> Self {
        Self {
            a0: Rq::zero(),
            a1: Rq::zero(),
        }
    }

    #[inline]
    pub fn from_u_basis() -> Self {
        Self {
            a0: Rq::zero(),
            a1: Rq::one(),
        }
    }

    pub fn random_uniform(rng: &mut impl rand::Rng) -> Self {
        Self {
            a0: Rq::random_uniform(rng),
            a1: Rq::random_uniform(rng),
        }
    }

    /// Quaternion multiplication: (a0+u*a1)(b0+u*b1) = c0 + u*c1
    /// where c0 = a0*b0 - theta(a1)*b1, c1 = a1*b0 + theta(a0)*b1.
    pub fn mul(&self, rhs: &Self) -> Self {
        let theta_a0 = theta(&self.a0);
        let theta_a1 = theta(&self.a1);
        Self {
            a0: self.a0 * rhs.a0 - theta_a1 * rhs.a1,
            a1: self.a1 * rhs.a0 + theta_a0 * rhs.a1,
        }
    }

    /// Quaternion conjugation: conj(a0 + u*a1) = theta(a0) - u*a1.
    pub fn conjugate(&self) -> Self {
        Self {
            a0: theta(&self.a0),
            a1: Rq::zero() - self.a1,
        }
    }

    /// Commutator [a, b] = a*b - b*a.
    pub fn commutator(a: &Self, b: &Self) -> Self {
        let ab = a.mul(b);
        let ba = b.mul(a);
        Self {
            a0: ab.a0 - ba.a0,
            a1: ab.a1 - ba.a1,
        }
    }

    /// Fast commutator [a, u] using only 2*D field additions (no multiplications).
    ///
    /// [a0+u*a1, u] = (a1 - theta(a1)) + u*(theta(a0) - a0)
    ///
    /// Both components lie in ker(1+theta), so the result is traceless.
    pub fn commutator_with_u(&self) -> TracelessEl {
        let theta_a0 = theta(&self.a0);
        let theta_a1 = theta(&self.a1);

        // t0 = a1 - theta(a1) in ker(1+theta)
        let t0_full = self.a1 - theta_a1;
        // t1 = theta(a0) - a0 (the u-component)
        let t1_full = theta_a0 - self.a0;

        TracelessEl::from_components(&t0_full, &t1_full)
    }

    /// Commutator [a, (0, z)] for sparse z (binary column embedding).
    ///
    /// Given a = a0 + u*a1 and b = (0, z) = u*z, computes [a, b] using only
    /// additions and mul_by_monomial (no Fq multiplications) when z is sparse.
    ///
    /// Formula:
    ///   [a, (0, z)]_0 = a1*theta(z) - theta(a1)*z
    ///   [a, (0, z)]_1 = z*(theta(a0) - a0)
    ///
    /// For binary z = sum z_t X^t with z_t in {0,1}, each multiplication by z
    /// decomposes into w additions of mul_by_monomial results, where w is the
    /// Hamming weight of z.
    ///
    /// `bits` is the list of nonzero positions in z (i.e., t where z_t = 1).
    pub fn commutator_with_uz_sparse(&self, bits: &[usize]) -> TracelessEl {
        if bits.is_empty() {
            return TracelessEl::zero();
        }

        let theta_a0 = theta(&self.a0);
        let theta_a1 = theta(&self.a1);

        // Precompute dense values used across all bits
        let diff = theta_a0 - self.a0; // theta(a0) - a0

        // Component 1: z * (theta(a0) - a0) = sum_{t in bits} X^t * diff
        let mut comp1 = Rq::zero();
        for &t in bits {
            comp1 = comp1 + diff.mul_by_monomial(t);
        }

        // Component 0: a1*theta(z) - theta(a1)*z
        // = sum_{t in bits} [a1*theta(X^t) - theta(a1)*X^t]
        //
        // theta(X^t) is a sparse element (at most 2 nonzero +-1 coefficients).
        // a1*theta(X^t) = sum of at most 2 rotated copies of a1.
        // theta(a1)*X^t = mul_by_monomial(theta(a1), t).
        let mut comp0 = Rq::zero();
        for &t in bits {
            // theta(a1) * X^t
            let ta1_shift = theta_a1.mul_by_monomial(t);

            // a1 * theta(X^t): theta(X^t) has closed form from the theta function
            let a1_theta_xt = mul_by_theta_monomial(&self.a1, t);

            comp0 = comp0 + a1_theta_xt - ta1_shift;
        }

        TracelessEl::from_components(&comp0, &comp1)
    }
}

/// Multiply a dense Rq element by theta(X^t), where theta(X^t) is sparse.
///
/// theta(X^0) = 1
/// theta(X^t) for t in 1..=27: -X^{54-t} - X^{27-t}  (2 terms, both -1)
/// theta(X^t) for t in 28..53: X^{81-t}  (1 term, +1)
///
/// Returns a * theta(X^t) using at most 2 additions of rotated copies.
fn mul_by_theta_monomial(a: &Rq, t: usize) -> Rq {
    if t == 0 {
        return *a;
    }
    if t <= 27 {
        // theta(X^t) = -X^{54-t} - X^{27-t}
        let shift1 = a.mul_by_monomial(54 - t);
        let shift2 = a.mul_by_monomial(27 - t);
        Rq::zero() - shift1 - shift2
    } else {
        // t in 28..54: theta(X^t) = X^{81-t}
        a.mul_by_monomial(81 - t)
    }
}

impl Add for QuatEl {
    type Output = Self;
    fn add(self, rhs: Self) -> Self {
        Self {
            a0: self.a0 + rhs.a0,
            a1: self.a1 + rhs.a1,
        }
    }
}

impl Sub for QuatEl {
    type Output = Self;
    fn sub(self, rhs: Self) -> Self {
        Self {
            a0: self.a0 - rhs.a0,
            a1: self.a1 - rhs.a1,
        }
    }
}

impl Neg for QuatEl {
    type Output = Self;
    fn neg(self) -> Self {
        Self {
            a0: Rq::zero() - self.a0,
            a1: Rq::zero() - self.a1,
        }
    }
}

/// Traceless quaternion element in T_0 = {x0 + u*x1 : x0 + theta(x0) = 0}.
///
/// Stored as T0_DIM = 81 field elements:
///   - First N_REAL = 27 elements: the ker(1+theta) component of x0
///     (a basis for ker(1+theta) in R_q is chosen once at init time).
///   - Next D = 54 elements: the full x1 component in R_q.
///
/// The representation uses a fixed basis for ker(1+theta) that is precomputed
/// from the theta automorphism.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TracelessEl {
    pub data: [Fq; T0_DIM],
}

/// Basis for ker(1+theta) in R_q (the "anti-fixed" subspace under theta).
/// This is a 27-dimensional subspace of the 54-dimensional R_q.
/// We store both the basis vectors and the projection matrix.
#[allow(dead_code)]
struct AntiFixedBasis {
    /// 27 basis vectors for ker(1+theta), each of dimension D=54.
    basis: [[Fq; D]; N_REAL],
    /// Projection: given a in ker(1+theta), recover the 27 coordinates.
    /// proj[i][j] means: coordinate i of the projection is sum_j proj[i][j] * a.0[j].
    proj: [[Fq; D]; N_REAL],
    /// Embedding: given 27 coordinates, reconstruct the full D=54 element.
    /// Same as `basis` transposed for application.
    embed: [[Fq; N_REAL]; D],
}

fn anti_fixed_basis() -> &'static AntiFixedBasis {
    static B: OnceLock<AntiFixedBasis> = OnceLock::new();
    B.get_or_init(build_anti_fixed_basis)
}

fn build_anti_fixed_basis() -> AntiFixedBasis {
    // ker(1+theta) = {a in R_q : theta(a) = -a}.
    // We find a basis by applying the projector (1-theta)/2 to the standard basis
    // and extracting linearly independent vectors.

    // First, compute (Id - theta_matrix) / 2 as a projector onto ker(1+theta).
    let tm = theta_matrix();
    let inv2 = Fq::from_u64(2).inverse();

    let mut proj_matrix = [[Fq::ZERO; D]; D];
    for i in 0..D {
        for j in 0..D {
            let delta = if i == j { Fq::ONE } else { Fq::ZERO };
            proj_matrix[i][j] = (delta - tm[i][j]) * inv2;
        }
    }

    // Apply projector to each standard basis vector e_i and collect images.
    let mut images = Vec::with_capacity(D);
    for i in 0..D {
        let mut img = [Fq::ZERO; D];
        for j in 0..D {
            img[j] = proj_matrix[j][i];
        }
        images.push(img);
    }

    // Extract N_REAL linearly independent vectors via row reduction.
    let mut count = 0;

    // Gaussian elimination on the images to find pivot columns
    let mut mat = images.clone();
    let mut pivot_indices = Vec::with_capacity(N_REAL);

    for col in 0..D {
        if count >= N_REAL {
            break;
        }
        // Find pivot row
        let mut pivot_row = None;
        for row in count..mat.len() {
            if mat[row][col] != Fq::ZERO {
                pivot_row = Some(row);
                break;
            }
        }
        let Some(pr) = pivot_row else { continue };

        mat.swap(count, pr);
        let piv_inv = mat[count][col].inverse();
        for c in 0..D {
            mat[count][c] *= piv_inv;
        }
        // Eliminate other rows
        let pivot_row_copy: [Fq; D] = mat[count];
        for r in 0..mat.len() {
            if r == count {
                continue;
            }
            let factor = mat[r][col];
            if factor == Fq::ZERO {
                continue;
            }
            for c in 0..D {
                mat[r][c] -= factor * pivot_row_copy[c];
            }
        }
        pivot_indices.push(col);
        count += 1;
    }

    assert_eq!(
        count, N_REAL,
        "ker(1+theta) should have dimension {N_REAL}, got {count}"
    );

    // The reduced matrix rows 0..N_REAL are our RREF basis.
    let mut basis = [[Fq::ZERO; D]; N_REAL];
    for i in 0..N_REAL {
        basis[i] = mat[i];
    }

    // In RREF, coordinate i of the decomposition = a[pivot_indices[i]].
    let mut proj = [[Fq::ZERO; D]; N_REAL];
    for (i, &pc) in pivot_indices.iter().enumerate() {
        proj[i][pc] = Fq::ONE;
    }

    // Embedding: embed[j][i] = basis[i][j]
    let mut embed = [[Fq::ZERO; N_REAL]; D];
    for j in 0..D {
        for i in 0..N_REAL {
            embed[j][i] = basis[i][j];
        }
    }

    AntiFixedBasis { basis, proj, embed }
}

impl TracelessEl {
    #[inline]
    pub fn zero() -> Self {
        Self {
            data: [Fq::ZERO; T0_DIM],
        }
    }

    /// Construct from full Rq components (x0, x1) where x0 must be in ker(1+theta).
    /// x0 is compressed to N_REAL coordinates; x1 is stored as-is.
    pub fn from_components(x0: &Rq, x1: &Rq) -> Self {
        let afb = anti_fixed_basis();
        let mut data = [Fq::ZERO; T0_DIM];

        // Project x0 onto ker(1+theta) basis: coord_i = x0[pivot_i]
        for i in 0..N_REAL {
            let mut acc = Fq::ZERO;
            for j in 0..D {
                acc += afb.proj[i][j] * x0.0[j];
            }
            data[i] = acc;
        }

        // Store x1 directly
        data[N_REAL..T0_DIM].copy_from_slice(&x1.0);

        Self { data }
    }

    /// Recover the full Rq components (x0, x1).
    pub fn to_components(&self) -> (Rq, Rq) {
        let afb = anti_fixed_basis();
        let mut x0 = [Fq::ZERO; D];
        for j in 0..D {
            let mut acc = Fq::ZERO;
            for i in 0..N_REAL {
                acc += afb.embed[j][i] * self.data[i];
            }
            x0[j] = acc;
        }

        let mut x1 = [Fq::ZERO; D];
        x1.copy_from_slice(&self.data[N_REAL..T0_DIM]);

        (Rq(x0), Rq(x1))
    }

    /// Scale by an element of O_{K,q} (the real subfield).
    /// For alpha in O_{K,q}: alpha * (x0 + u*x1) = alpha*x0 + u*alpha*x1.
    /// Since alpha is fixed by theta, the result is still traceless.
    pub fn scale_ok(&self, alpha: &Rq) -> Self {
        let (x0, x1) = self.to_components();
        let scaled_x0 = *alpha * x0;
        let scaled_x1 = *alpha * x1;
        Self::from_components(&scaled_x0, &scaled_x1)
    }

    /// Scale by a base field element.
    pub fn scale_fq(&self, scalar: Fq) -> Self {
        let mut out = self.data;
        for v in out.iter_mut() {
            *v *= scalar;
        }
        Self { data: out }
    }

    /// Number of Fq elements in the representation.
    #[inline]
    pub fn size(&self) -> usize {
        T0_DIM
    }

    /// Access the raw data slice.
    #[inline]
    pub fn as_slice(&self) -> &[Fq] {
        &self.data
    }
}

impl Add for TracelessEl {
    type Output = Self;
    fn add(self, rhs: Self) -> Self {
        let mut data = self.data;
        for (a, &b) in data.iter_mut().zip(rhs.data.iter()) {
            *a += b;
        }
        Self { data }
    }
}

impl Add for &TracelessEl {
    type Output = TracelessEl;
    fn add(self, rhs: &TracelessEl) -> TracelessEl {
        let mut data = self.data;
        for (a, &b) in data.iter_mut().zip(rhs.data.iter()) {
            *a += b;
        }
        TracelessEl { data }
    }
}

impl AddAssign for TracelessEl {
    fn add_assign(&mut self, rhs: Self) {
        for (a, &b) in self.data.iter_mut().zip(rhs.data.iter()) {
            *a += b;
        }
    }
}

impl AddAssign<&TracelessEl> for TracelessEl {
    fn add_assign(&mut self, rhs: &TracelessEl) {
        for (a, &b) in self.data.iter_mut().zip(rhs.data.iter()) {
            *a += b;
        }
    }
}

impl Sub for TracelessEl {
    type Output = Self;
    fn sub(self, rhs: Self) -> Self {
        let mut data = self.data;
        for (a, &b) in data.iter_mut().zip(rhs.data.iter()) {
            *a -= b;
        }
        Self { data }
    }
}

impl Neg for TracelessEl {
    type Output = Self;
    fn neg(self) -> Self {
        let mut data = self.data;
        for v in data.iter_mut() {
            *v = Fq::ZERO - *v;
        }
        Self { data }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use rand::Rng;

    #[test]
    fn theta_is_involution() {
        let mut rng = rand::rng();
        for _ in 0..10 {
            let a = Rq::random_uniform(&mut rng);
            let tt = theta(&theta(&a));
            assert_eq!(a, tt, "theta(theta(a)) should equal a");
        }
    }

    #[test]
    fn theta_fixes_real_subfield() {
        // Elements of K = Q(zeta_81 + zeta_81^{-1}) are fixed by theta.
        // A basis element of K is X^i + X^{81-i} for suitable i.
        // Test: theta(X^i + theta(X^i)) should equal X^i + theta(X^i).
        let mut rng = rand::rng();
        for _ in 0..10 {
            let a = Rq::random_uniform(&mut rng);
            let real_part = a + theta(&a); // a + theta(a) is in K
            let should_be_same = theta(&real_part);
            assert_eq!(
                real_part, should_be_same,
                "theta should fix elements of the real subfield"
            );
        }
    }

    #[test]
    fn theta_specific_values() {
        // theta(1) = 1
        assert_eq!(theta(&Rq::one()), Rq::one());

        // theta(X) = X^{80} mod Phi_81 = -X^{53} - X^{26}
        let x = Rq::from_field_coeffs(&{
            let mut c = vec![Fq::ZERO; D];
            c[1] = Fq::ONE;
            c
        });
        let tx = theta(&x);
        let mut expected = [Fq::ZERO; D];
        expected[53] = Fq::ZERO - Fq::ONE;
        expected[26] = Fq::ZERO - Fq::ONE;
        assert_eq!(tx, Rq(expected), "theta(X) should be -X^53 - X^26");
    }

    #[test]
    fn anti_fixed_basis_dimension() {
        let afb = anti_fixed_basis();
        // Verify each basis vector is in ker(1+theta)
        for i in 0..N_REAL {
            let v = Rq(afb.basis[i]);
            let tv = theta(&v);
            let sum = v + tv;
            assert_eq!(sum, Rq::zero(), "basis[{i}] should be in ker(1+theta)");
        }
    }

    #[test]
    fn traceless_roundtrip() {
        let mut rng = rand::rng();
        for _ in 0..10 {
            // Create a traceless element: x0 in ker(1+theta), x1 arbitrary
            let a = Rq::random_uniform(&mut rng);
            let x0 = a - theta(&a); // a - theta(a) is in ker(1+theta)
            let x1 = Rq::random_uniform(&mut rng);

            let t = TracelessEl::from_components(&x0, &x1);
            let (x0_recovered, x1_recovered) = t.to_components();

            assert_eq!(x0, x0_recovered, "x0 roundtrip failed");
            assert_eq!(x1, x1_recovered, "x1 roundtrip failed");
        }
    }

    #[test]
    fn commutator_is_traceless() {
        let mut rng = rand::rng();
        for _ in 0..10 {
            let a = QuatEl::random_uniform(&mut rng);
            let b = QuatEl::random_uniform(&mut rng);
            let comm = QuatEl::commutator(&a, &b);
            // Trace = x0 + theta(x0) should be zero
            let trace = comm.a0 + theta(&comm.a0);
            assert_eq!(trace, Rq::zero(), "commutator should be traceless");
        }
    }

    #[test]
    fn commutator_bilinear() {
        let mut rng = rand::rng();
        for _ in 0..5 {
            let a = QuatEl::random_uniform(&mut rng);
            let b = QuatEl::random_uniform(&mut rng);
            let c = QuatEl::random_uniform(&mut rng);

            let ab_c = QuatEl::commutator(&(a + b), &c);
            let a_c = QuatEl::commutator(&a, &c);
            let b_c = QuatEl::commutator(&b, &c);
            let sum = a_c + b_c;
            assert_eq!(ab_c.a0, sum.a0, "[a+b, c]_0 != [a,c]_0 + [b,c]_0");
            assert_eq!(ab_c.a1, sum.a1, "[a+b, c]_1 != [a,c]_1 + [b,c]_1");
        }
    }

    #[test]
    fn commutator_antisymmetric() {
        let mut rng = rand::rng();
        for _ in 0..5 {
            let a = QuatEl::random_uniform(&mut rng);
            let b = QuatEl::random_uniform(&mut rng);
            let ab = QuatEl::commutator(&a, &b);
            let ba = QuatEl::commutator(&b, &a);
            let sum = ab + ba;
            assert_eq!(sum.a0, Rq::zero(), "[a,b] + [b,a] should be zero");
            assert_eq!(sum.a1, Rq::zero(), "[a,b] + [b,a] should be zero");
        }
    }

    #[test]
    fn commutator_with_u_matches_generic() {
        let mut rng = rand::rng();
        let u = QuatEl::from_u_basis();
        for _ in 0..10 {
            let a = QuatEl::random_uniform(&mut rng);

            // Generic commutator
            let comm = QuatEl::commutator(&a, &u);
            // Fast path
            let fast = a.commutator_with_u();

            // Convert generic to TracelessEl and compare
            let generic_t = TracelessEl::from_components(&comm.a0, &comm.a1);
            assert_eq!(
                fast.data, generic_t.data,
                "fast commutator_with_u should match generic commutator"
            );
        }
    }

    #[test]
    fn traceless_add_sub() {
        let mut rng = rand::rng();
        let a = QuatEl::random_uniform(&mut rng);
        let b = QuatEl::random_uniform(&mut rng);
        let ta = a.commutator_with_u();
        let tb = b.commutator_with_u();

        let sum = ta.clone() + tb.clone();
        let ab = a + b;
        let tab = ab.commutator_with_u();
        assert_eq!(sum.data, tab.data, "[a,u] + [b,u] should equal [a+b, u] by bilinearity");
    }

    #[test]
    fn commutator_with_uz_sparse_matches_generic() {
        let mut rng = rand::rng();
        for _ in 0..10 {
            let a = QuatEl::random_uniform(&mut rng);

            // Random sparse z: pick 5-15 random bit positions out of D=54
            let n_bits = rng.random_range(5..=15usize);
            let mut bits: Vec<usize> = (0..n_bits).map(|_| rng.random_range(0..D)).collect();
            bits.sort();
            bits.dedup();

            // Build z as Rq element
            let mut z_coeffs = [Fq::ZERO; D];
            for &t in &bits {
                z_coeffs[t] = Fq::ONE;
            }
            let z_rq = Rq(z_coeffs);

            // Generic: [a, (0, z_rq)] via full quaternion commutator
            let b = QuatEl {
                a0: Rq::zero(),
                a1: z_rq,
            };
            let generic = QuatEl::commutator(&a, &b);
            let generic_t = TracelessEl::from_components(&generic.a0, &generic.a1);

            // Sparse: commutator_with_uz_sparse
            let sparse_t = a.commutator_with_uz_sparse(&bits);

            assert_eq!(
                sparse_t.data,
                generic_t.data,
                "sparse commutator should match generic for {} bits",
                bits.len()
            );
        }
    }

    #[test]
    fn commutator_with_uz_sparse_single_bit_matches_u() {
        // [a, (0, X^0)] = [a, u] (the t=0 case)
        let mut rng = rand::rng();
        for _ in 0..10 {
            let a = QuatEl::random_uniform(&mut rng);
            let from_u = a.commutator_with_u();
            let from_sparse = a.commutator_with_uz_sparse(&[0]);
            assert_eq!(from_u.data, from_sparse.data, "sparse [a, (0, 1)] should match [a, u]");
        }
    }
}

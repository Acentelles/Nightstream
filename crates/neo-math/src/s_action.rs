//! S-action implementation: "left multiplication by a in R_q" as rot(a).
//! Definitionally correct: j-th column is cf(a * X^j mod Phi_81).

use crate::ring::{cf, cf_inv};
use crate::{from_complex, Fq, Rq, SActionError, D, K};
use p3_field::PrimeCharacteristicRing;
use p3_matrix::dense::DenseMatrix;

#[derive(Clone, Debug)]
pub struct SAction {
    a: Rq,
}

impl SAction {
    /// Create S-action from ring element a: rot(a) matrix via column-wise definition
    pub fn from_ring(a: Rq) -> Self {
        Self { a }
    }

    /// Scalar multiple (ρ = f·I) as an S-action.
    /// This creates the S-action corresponding to multiplication by the scalar f in the base field.
    pub fn scalar(f: Fq) -> Self {
        Self::from_ring(Rq::from_field_scalar(f))
    }

    /// Build the full d×d rotation matrix definitionally: column j = cf(a * X^j mod Phi)
    pub fn to_matrix(&self) -> DenseMatrix<Fq> {
        let mut values = vec![Fq::ZERO; D * D];
        let mut x_power = Rq::one(); // Start with X^0 = 1

        for j in 0..D {
            let col = cf(self.a.mul(&x_power));
            for i in 0..D {
                values[i * D + j] = col[i]; // Column j, row i
            }
            x_power = x_power.mul_by_monomial(1); // X^j -> X^(j+1)
        }

        DenseMatrix::new(values, D)
    }

    /// Left action on v ∈ F_q^d.
    #[inline]
    pub fn apply_vec(&self, v: &[Fq; D]) -> [Fq; D] {
        let prod = self.a.mul(&cf_inv(*v));
        cf(prod)
    }

    /// Compose S-actions (rot(a) ∘ rot(b) = rot(a*b)).
    #[inline]
    pub fn compose(&self, other: &SAction) -> SAction {
        SAction {
            a: self.a.mul(&other.a),
        }
    }

    /// Left action on a K-vector by applying the S-action independently to real and imaginary parts.
    /// This extends the Fq-linear S-action to the extension field K = Fq\[u\]/(u^2 - 7).
    ///
    /// Security: For ME claims (y_j ∈ K^d should be length D), vectors may be
    /// padded up to the next power-of-two (for sum-check alignment). If the
    /// vector is longer than D, all tail elements beyond D must be zero. Any
    /// non-zero padding is rejected to prevent dimension-mismatch attacks.
    pub fn apply_k_vec(&self, y: &[K]) -> Result<Vec<K>, SActionError> {
        // Allow zero-padded tails up to 2^ell_d; enforce zeros for indices ≥ D
        if y.len() > D {
            // Reject if any tail element is non-zero
            if y[D..].iter().any(|&v| v != K::ZERO) {
                return Err(SActionError::DimMismatch {
                    expected: D,
                    got: y.len(),
                });
            }
        }

        if y.is_empty() {
            return Ok(Vec::new());
        }

        // Process up to min(y.len(), D) elements - this handles both short vectors (tests)
        // and exactly D-length vectors (production ME claims)
        let process_len = y.len().min(D);

        // Split each K element into real/imaginary parts
        let mut y_re = [Fq::ZERO; D];
        let mut y_im = [Fq::ZERO; D];

        for (i, &yk) in y.iter().enumerate().take(process_len) {
            y_re[i] = yk.real();
            y_im[i] = yk.imag();
        }

        // Apply S-action to each coordinate array separately
        let rotated_re = self.apply_vec(&y_re);
        let rotated_im = self.apply_vec(&y_im);

        // Recombine into K elements - return exactly y.len() elements
        let mut result = Vec::with_capacity(y.len());

        for i in 0..process_len {
            result.push(from_complex(rotated_re[i], rotated_im[i]));
        }

        // Copy any remaining elements unchanged (must be zeros by contract)
        result.extend_from_slice(&y[process_len..]);

        Ok(result)
    }
}

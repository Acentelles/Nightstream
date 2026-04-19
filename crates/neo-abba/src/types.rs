//! Types for ABBA commitments: public parameters and commitment output.

use neo_math::quaternion::{QuatEl, T0_DIM};
use p3_field::PrimeCharacteristicRing;
use p3_goldilocks::Goldilocks as Fq;

/// Public parameters for ABBA: key matrix A in Lambda_q^{kappa x m}.
///
/// Column-based approach: each column of the witness (d field elements packed
/// as one Rq element) pairs with one quaternion key element. This matches
/// Ajtai's key count (m keys per kappa-row).
#[derive(Clone, Debug)]
pub struct PP {
    pub kappa: usize,
    pub m: usize,
    pub d: usize,
    /// Key matrix: kappa rows, each of m QuatEl elements.
    pub a_rows: Vec<Vec<QuatEl>>,
}

/// ABBA commitment c in T_0^kappa, stored as kappa traceless quaternion elements.
///
/// Layout: data[c * T0_DIM + i] = i-th field element of the c-th T_0 slot.
/// Total length: kappa * T0_DIM.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Commitment {
    pub d: usize,
    pub kappa: usize,
    /// Flat column-major storage: kappa columns, each T0_DIM field elements.
    pub data: Vec<Fq>,
}

impl Commitment {
    pub fn zeros(d: usize, kappa: usize) -> Self {
        Self {
            d,
            kappa,
            data: vec![Fq::ZERO; kappa * T0_DIM],
        }
    }

    #[inline]
    pub fn col(&self, c: usize) -> &[Fq] {
        &self.data[c * T0_DIM..(c + 1) * T0_DIM]
    }

    #[inline]
    pub fn col_mut(&mut self, c: usize) -> &mut [Fq] {
        &mut self.data[c * T0_DIM..(c + 1) * T0_DIM]
    }

    pub fn add_inplace(&mut self, rhs: &Commitment) {
        debug_assert_eq!(self.kappa, rhs.kappa);
        for (a, b) in self.data.iter_mut().zip(rhs.data.iter()) {
            *a += *b;
        }
    }

    pub fn size_in_field_elements(&self) -> usize {
        self.data.len()
    }
}

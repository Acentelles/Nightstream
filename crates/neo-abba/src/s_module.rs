//! SModuleHomomorphism implementation for ABBA commitments.

use crate::types::{Commitment, PP};
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::Mat;
use neo_math::Fq;
use p3_field::PrimeCharacteristicRing;
use std::sync::Arc;

/// ABBA commitment module implementing the same SModuleHomomorphism trait
/// as neo-ajtai's AjtaiSModule.
pub struct AbbaSModule {
    pp: Arc<PP>,
}

impl AbbaSModule {
    pub fn new(pp: Arc<PP>) -> Self {
        Self { pp }
    }
}

impl SModuleHomomorphism<Fq, Commitment> for AbbaSModule {
    fn commit(&self, z: &Mat<Fq>) -> Commitment {
        // z is d x cols, stored row-major. Flatten to column-major for neo-abba::commit.
        let d = z.rows();
        let cols = z.cols();
        assert_eq!(d * cols, self.pp.d * self.pp.m, "Z dimensions must match PP");

        let mut col_major = vec![Fq::ZERO; d * cols];
        for j in 0..cols {
            for i in 0..d {
                col_major[j * d + i] = z[(i, j)];
            }
        }
        crate::commit::commit(&self.pp, &col_major)
    }

    fn project_x(&self, z: &Mat<Fq>, min: usize) -> Mat<Fq> {
        let d = z.rows();
        let mut x = Mat::zero(d, min, Fq::ZERO);
        for j in 0..min {
            for i in 0..d {
                x[(i, j)] = z[(i, j)];
            }
        }
        x
    }
}

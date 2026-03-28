//! Owns the local packed witness layout helpers used by CHIP-8 and RV64IM kernels.
//! It does not own deprecated memory-sidecar logic or witness builders.

use neo_ccs::matrix::Mat;
use neo_math::balanced::to_balanced_i128;
use neo_math::{D, F as BaseField};
use neo_params::NeoParams;
use p3_field::{PrimeCharacteristicRing, PrimeField};

#[inline]
fn balanced_divrem(value: i128, base: i128) -> (i128, i128) {
    debug_assert!(base >= 2);
    let mut remainder = value % base;
    let mut quotient = (value - remainder) / base;
    let half = base / 2;
    if remainder > half {
        remainder -= base;
        quotient += 1;
    } else if remainder < -half {
        remainder += base;
        quotient -= 1;
    }
    (remainder, quotient)
}

pub fn commit_cols_for_ccs_m(ccs_m: usize) -> usize {
    ccs_m.div_ceil(D)
}

pub fn encode_vector_for_ccs_m(
    params: &NeoParams,
    ccs_m: usize,
    witness: &[BaseField],
) -> Result<Mat<BaseField>, String> {
    if witness.len() != ccs_m {
        return Err(format!(
            "encode_vector_for_ccs_m: witness length {} != ccs_m {}",
            witness.len(),
            ccs_m
        ));
    }
    if ccs_m == 0 {
        return Err("encode_vector_for_ccs_m: ccs_m must be > 0".into());
    }
    validate_packed_vector_nc_range(params, ccs_m, witness, "encode_vector_for_ccs_m")?;
    let cols = ccs_m.div_ceil(D);
    let mut out = Mat::zero(D, cols, BaseField::ZERO);
    for column in 0..ccs_m {
        let block = column / D;
        let rho = column % D;
        out[(rho, block)] = witness[column];
    }
    Ok(out)
}

pub fn decode_vector_for_ccs_m<F: PrimeField>(
    _params: &NeoParams,
    ccs_m: usize,
    mat: &Mat<F>,
) -> Result<Vec<F>, String> {
    if mat.rows() != D {
        return Err(format!(
            "decode_vector_for_ccs_m: mat.rows()={} expected D={D}",
            mat.rows()
        ));
    }
    if ccs_m == 0 {
        return Err("decode_vector_for_ccs_m: ccs_m must be > 0".into());
    }
    let expected_cols = ccs_m.div_ceil(D);
    if mat.cols() != expected_cols {
        return Err(format!(
            "decode_vector_for_ccs_m: packed layout expects cols={} for ccs_m={}, got {}",
            expected_cols,
            ccs_m,
            mat.cols()
        ));
    }

    let pad_start = ccs_m;
    let pad_end = expected_cols
        .checked_mul(D)
        .ok_or_else(|| "decode_vector_for_ccs_m: expected_cols*D overflow".to_string())?;
    for column in pad_start..pad_end {
        let block = column / D;
        let rho = column % D;
        if mat[(rho, block)] != F::ZERO {
            return Err(format!(
                "decode_vector_for_ccs_m: non-zero padded coefficient at logical index {} (blk={}, rho={})",
                column, block, rho
            ));
        }
    }

    let mut out = Vec::with_capacity(ccs_m);
    for column in 0..ccs_m {
        let block = column / D;
        let rho = column % D;
        out.push(mat[(rho, block)]);
    }
    Ok(out)
}

fn validate_packed_vector_nc_range(
    params: &NeoParams,
    ccs_m: usize,
    witness: &[BaseField],
    label: &str,
) -> Result<(), String> {
    if witness.len() != ccs_m {
        return Err(format!("{label}: witness length {} != ccs_m {}", witness.len(), ccs_m));
    }
    if ccs_m == 0 {
        return Err(format!("{label}: ccs_m must be > 0"));
    }
    if params.b < 2 {
        return Err(format!("{label}: invalid b={} (must be >= 2)", params.b));
    }

    let base = params.b as i128;
    for (index, &value) in witness.iter().enumerate() {
        let mut remainder = to_balanced_i128(value);
        for _ in 0..D {
            let (_digit, quotient) = balanced_divrem(remainder, base);
            remainder = quotient;
        }
        if remainder != 0 {
            return Err(format!(
                "{label}: packed coefficient at index {index} is not representable in D={} balanced base-{} digits (centered value {})",
                D, params.b, to_balanced_i128(value)
            ));
        }
    }
    Ok(())
}

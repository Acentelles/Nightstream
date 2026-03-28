//! Owns the shared Ajtai transport for explicit time-vector commitment families.

use neo_ajtai::{
    decomp_b_row_major, get_global_pp_for_dims, get_global_pp_seeded_params_for_dims, has_global_pp_for_dims,
    set_global_pp_seeded, AjtaiSModule, Commitment, DecompStyle,
};
use neo_ccs::{traits::SModuleHomomorphism, Mat};
use neo_math::balanced::to_balanced_i128;
use neo_math::{KExtensions, F, K};
use neo_params::NeoParams;
use neo_transcript::{Poseidon2Transcript, Transcript, TranscriptProtocol};
use p3_field::PrimeCharacteristicRing;

use super::super::{KernelOpeningClaim, KernelOpeningManifest, SimpleKernelError};
use super::{TimeVectorFamilySpec, TimeVectorOpeningProof};
use crate::chip8::kernel::openings::commitment_polynomial_slot;
use crate::chip8::poly::build_eq_table;

const TIME_VECTOR_OPENING_DECOMP_BASE: u32 = 2;
const TIME_VECTOR_OPENING_SLICE_BITS: usize = 32;
const TIME_VECTOR_OPENING_SLICE_COUNT: usize = 2;
const TIME_VECTOR_COMMIT_BATCH: usize = 256;

impl TimeVectorOpeningProof {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/time_vector_opening");
        tr.append_u64s(
            b"neo.fold.next/chip8/time_vector_opening/meta",
            &[
                self.point.len() as u64,
                self.polynomial_ids.len() as u64,
                self.claimed_values.len() as u64,
                self.digit_evals.len() as u64,
            ],
        );
        append_k_point(&mut tr, b"neo.fold.next/chip8/time_vector_opening/point", &self.point);
        let polynomial_ids_u64: Vec<u64> = self.polynomial_ids.iter().map(|&id| id as u64).collect();
        tr.append_u64s(
            b"neo.fold.next/chip8/time_vector_opening/polynomial_ids",
            &polynomial_ids_u64,
        );
        append_k_values(
            &mut tr,
            b"neo.fold.next/chip8/time_vector_opening/claimed_values",
            &self.claimed_values,
        );
        tr.append_u64s(
            b"neo.fold.next/chip8/time_vector_opening/digit_eval_count",
            &[self.digit_evals.len() as u64],
        );
        for digits in &self.digit_evals {
            append_k_values(&mut tr, b"neo.fold.next/chip8/time_vector_opening/digit_eval", digits);
        }
        tr.digest32()
    }
}

pub(super) fn build_family_commitments(
    params: &NeoParams,
    columns: &[Vec<F>],
    family: TimeVectorFamilySpec,
) -> Result<Vec<Commitment>, SimpleKernelError> {
    let encoded_mats = encode_time_vector_columns(params, columns, family.label)?;
    let logical_len = columns.first().map_or(0, Vec::len);
    let committer = family_committer(params, logical_len, family)?;
    let mut commitments = Vec::with_capacity(encoded_mats.len());
    for chunk in encoded_mats.chunks(TIME_VECTOR_COMMIT_BATCH) {
        let refs: Vec<&Mat<F>> = chunk.iter().collect();
        commitments.extend(committer.commit_many(&refs));
    }
    Ok(commitments)
}

pub(super) fn build_family_opening_proofs(
    params: &NeoParams,
    columns: &[Vec<F>],
    manifest: &KernelOpeningManifest,
    family: TimeVectorFamilySpec,
) -> Result<Vec<TimeVectorOpeningProof>, SimpleKernelError> {
    let encoded_mats = encode_time_vector_columns(params, columns, family.label)?;
    manifest
        .claims
        .iter()
        .filter(|claim| claim.commitment_id == family.commitment_id)
        .map(|claim| build_opening_proof(&encoded_mats, claim, family.label))
        .collect()
}

pub(super) fn commitment_set_digest(domain: &'static [u8], commitments: &[Commitment]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(domain);
    tr.append_u64s(
        b"neo.fold.next/chip8/time_vector_commitments/len",
        &[commitments.len() as u64],
    );
    for commitment in commitments {
        tr.append_u64s(
            b"neo.fold.next/chip8/time_vector_commitments/shape",
            &[commitment.d as u64, commitment.kappa as u64],
        );
        tr.absorb_commit_coords(&commitment.data);
    }
    tr.digest32()
}

pub(super) fn expect_commitments_match(
    actual: &[Commitment],
    expected: &[Commitment],
    label: &str,
) -> Result<(), SimpleKernelError> {
    if actual.len() != expected.len() {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{label} commitment count {} != expected {}",
            actual.len(),
            expected.len()
        )));
    }
    for (index, (got, want)) in actual.iter().zip(expected.iter()).enumerate() {
        if got != want {
            return Err(SimpleKernelError::OpeningFailed(format!(
                "{label} commitment {index} mismatch"
            )));
        }
    }
    Ok(())
}

pub(crate) fn encoded_time_width(t: usize) -> Result<usize, SimpleKernelError> {
    t.checked_mul(TIME_VECTOR_OPENING_SLICE_COUNT)
        .ok_or_else(|| {
            SimpleKernelError::OpeningFailed(format!(
                "time-vector opening encoded width overflow for trace length {t}"
            ))
        })
}

pub(crate) fn recompose_time_vector_digits_to_scalar(digits: &[K]) -> K {
    let base = K::from(F::from_u64(TIME_VECTOR_OPENING_DECOMP_BASE as u64));
    let mut power = K::ONE;
    let mut acc = K::ZERO;
    for &digit in digits {
        acc += power * digit;
        power *= base;
    }
    acc
}

fn build_opening_proof(
    encoded_mats: &[Mat<F>],
    claim: &KernelOpeningClaim,
    label: &str,
) -> Result<TimeVectorOpeningProof, SimpleKernelError> {
    let mut digit_evals = Vec::with_capacity(claim.polynomial_ids.len());
    for (&poly_id, &claimed_value) in claim.polynomial_ids.iter().zip(claim.claimed_values.iter()) {
        let slot = commitment_polynomial_slot(claim.commitment_id, poly_id)?;
        let encoded = encoded_mats.get(slot).ok_or_else(|| {
            SimpleKernelError::OpeningFailed(format!(
                "{label} opening references out-of-range polynomial id {poly_id}"
            ))
        })?;
        let digits = eval_time_mat_digits_at_point(&claim.point, encoded, label)?;
        if recompose_time_vector_digits_to_scalar(&digits) != claimed_value {
            return Err(SimpleKernelError::OpeningFailed(format!(
                "{label} opening claim for polynomial {poly_id} does not match exact transport"
            )));
        }
        digit_evals.push(digits);
    }

    Ok(TimeVectorOpeningProof {
        point: claim.point.clone(),
        polynomial_ids: claim.polynomial_ids.clone(),
        claimed_values: claim.claimed_values.clone(),
        digit_evals,
    })
}

fn family_committer(
    params: &NeoParams,
    t: usize,
    family: TimeVectorFamilySpec,
) -> Result<AjtaiSModule, SimpleKernelError> {
    let d = params.d as usize;
    let encoded_t = encoded_time_width(t)?;
    let want_kappa = params.kappa as usize;
    let expected_seed = time_vector_commit_seed(d, t, encoded_t);

    if has_global_pp_for_dims(d, encoded_t) {
        if let Ok((kappa, seed)) = get_global_pp_seeded_params_for_dims(d, encoded_t) {
            if kappa != want_kappa || seed != expected_seed {
                return Err(SimpleKernelError::OpeningFailed(format!(
                    "{} commitment PP mismatch for (d,m)=({d},{encoded_t})",
                    family.label
                )));
            }
        } else {
            let pp = get_global_pp_for_dims(d, encoded_t).map_err(|err| {
                SimpleKernelError::OpeningFailed(format!(
                    "failed to load {} commitment PP for (d,m)=({d},{encoded_t}): {err}",
                    family.label
                ))
            })?;
            if pp.kappa != want_kappa {
                return Err(SimpleKernelError::OpeningFailed(format!(
                    "{} commitment PP kappa mismatch for (d,m)=({d},{encoded_t})",
                    family.label
                )));
            }
        }
    } else {
        set_global_pp_seeded(d, want_kappa, encoded_t, expected_seed).map_err(|err| {
            SimpleKernelError::OpeningFailed(format!(
                "failed to register seeded {} commitment PP for (d,m)=({d},{encoded_t}): {err}",
                family.label
            ))
        })?;
    }

    AjtaiSModule::from_global_for_dims(d, encoded_t).map_err(|err| {
        SimpleKernelError::OpeningFailed(format!(
            "failed to initialize {} committer for (d,m)=({d},{encoded_t}): {err}",
            family.label
        ))
    })
}

fn time_vector_commit_seed(d: usize, t: usize, encoded_t: usize) -> [u8; 32] {
    #[inline]
    fn mix64(mut x: u64) -> u64 {
        x ^= x >> 30;
        x = x.wrapping_mul(0xbf58_476d_1ce4_e5b9);
        x ^= x >> 27;
        x = x.wrapping_mul(0x94d0_49bb_1331_11eb);
        x ^ (x >> 31)
    }

    let dd = d as u64;
    let tt = t as u64;
    let enc = encoded_t as u64;
    let words = [
        mix64(0x6e65_6f2d_6368_6970 ^ dd ^ (tt << 1) ^ (enc << 3)),
        mix64(0x7469_6d65_2d76_6563 ^ (tt << 7) ^ (enc << 11)),
        mix64(0x636f_6d6d_6974_2d76 ^ (dd << 13) ^ (tt << 5) ^ (enc << 17)),
        mix64(
            0x6465_7465_726d_2d73
                ^ (dd << 17)
                ^ (tt << 19)
                ^ ((TIME_VECTOR_OPENING_SLICE_BITS as u64) << 23)
                ^ ((TIME_VECTOR_OPENING_SLICE_COUNT as u64) << 27),
        ),
    ];
    let mut seed = [0u8; 32];
    for (index, word) in words.iter().enumerate() {
        seed[index * 8..(index + 1) * 8].copy_from_slice(&word.to_le_bytes());
    }
    seed
}

fn encode_time_vector_columns(
    params: &NeoParams,
    columns: &[Vec<F>],
    label: &str,
) -> Result<Vec<Mat<F>>, SimpleKernelError> {
    columns
        .iter()
        .map(|column| encode_time_opening_vector_to_mat(params, column, label))
        .collect()
}

fn field_from_small_signed(value: i128) -> F {
    debug_assert!(value.unsigned_abs() <= u64::MAX as u128);
    if value >= 0 {
        F::from_u64(value as u64)
    } else {
        F::ZERO - F::from_u64((-value) as u64)
    }
}

fn slice_radix_u64() -> u64 {
    1u64 << TIME_VECTOR_OPENING_SLICE_BITS
}

fn split_time_scalar_slices(value: F) -> [F; TIME_VECTOR_OPENING_SLICE_COUNT] {
    let radix = slice_radix_u64() as i128;
    let centered = to_balanced_i128(value);
    let lo = centered.rem_euclid(radix);
    let hi = (centered - lo) / radix;
    [field_from_small_signed(lo), field_from_small_signed(hi)]
}

fn encode_time_opening_vector_to_mat(
    params: &NeoParams,
    values: &[F],
    label: &str,
) -> Result<Mat<F>, SimpleKernelError> {
    let t = values.len();
    let encoded_t = encoded_time_width(t)?;
    let mut slice_values = [Vec::with_capacity(t), Vec::with_capacity(t)];
    for &value in values {
        let [lo, hi] = split_time_scalar_slices(value);
        slice_values[0].push(lo);
        slice_values[1].push(hi);
    }

    let d = params.d as usize;
    let row_major_slices = [
        decomp_b_row_major(
            slice_values[0].as_slice(),
            TIME_VECTOR_OPENING_DECOMP_BASE,
            d,
            DecompStyle::Balanced,
        ),
        decomp_b_row_major(
            slice_values[1].as_slice(),
            TIME_VECTOR_OPENING_DECOMP_BASE,
            d,
            DecompStyle::Balanced,
        ),
    ];

    let mut row_major = Vec::with_capacity(d * encoded_t);
    for rho in 0..d {
        let row_start = rho * t;
        let row_end = row_start + t;
        row_major.extend_from_slice(&row_major_slices[0][row_start..row_end]);
        row_major.extend_from_slice(&row_major_slices[1][row_start..row_end]);
    }
    if row_major.len() != d * encoded_t {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{label} encoded row-major size {} != expected {}",
            row_major.len(),
            d * encoded_t
        )));
    }
    Ok(Mat::from_row_major(d, encoded_t, row_major))
}

fn expand_time_row_weights(weights: &[K]) -> Vec<K> {
    let mut out = Vec::with_capacity(weights.len() * TIME_VECTOR_OPENING_SLICE_COUNT);
    let slice_radix = K::from(F::from_u64(slice_radix_u64()));
    let mut scale = K::ONE;
    for _ in 0..TIME_VECTOR_OPENING_SLICE_COUNT {
        for &weight in weights {
            out.push(scale * weight);
        }
        scale *= slice_radix;
    }
    out
}

fn eval_time_mat_digits_at_point(point: &[K], encoded: &Mat<F>, label: &str) -> Result<Vec<K>, SimpleKernelError> {
    let raw_t = encoded.cols() / TIME_VECTOR_OPENING_SLICE_COUNT;
    if raw_t * TIME_VECTOR_OPENING_SLICE_COUNT != encoded.cols() {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{label} encoded matrix column count {} is not divisible by slice count {}",
            encoded.cols(),
            TIME_VECTOR_OPENING_SLICE_COUNT
        )));
    }
    let weights = build_eq_table(point);
    if weights.len() != raw_t {
        return Err(SimpleKernelError::OpeningFailed(format!(
            "{label} opening point dimension {} yields {} weights for raw_t {}",
            point.len(),
            weights.len(),
            raw_t
        )));
    }
    let expanded_weights = expand_time_row_weights(&weights);
    let mut digits = vec![K::ZERO; encoded.rows()];
    let cols = encoded.cols();
    let data = encoded.as_slice();
    for rho in 0..encoded.rows() {
        let row = &data[rho * cols..(rho + 1) * cols];
        let mut acc = K::ZERO;
        for (&weight, &value) in expanded_weights.iter().zip(row.iter()) {
            if value != F::ZERO {
                acc += weight.scale_base(value);
            }
        }
        digits[rho] = acc;
    }
    Ok(digits)
}

fn append_k_point(tr: &mut Poseidon2Transcript, label: &'static [u8], point: &[K]) {
    tr.append_u64s(
        b"neo.fold.next/chip8/time_vector_opening/point_len",
        &[point.len() as u64],
    );
    let coeffs_per_elem = point
        .first()
        .map(|value| value.as_coeffs().len())
        .unwrap_or(0);
    tr.append_fields_iter(
        label,
        point.len().saturating_mul(coeffs_per_elem),
        point.iter().flat_map(|value| value.as_coeffs()),
    );
}

fn append_k_values(tr: &mut Poseidon2Transcript, label: &'static [u8], values: &[K]) {
    tr.append_u64s(
        b"neo.fold.next/chip8/time_vector_opening/value_len",
        &[values.len() as u64],
    );
    let coeffs_per_elem = values
        .first()
        .map(|value| value.as_coeffs().len())
        .unwrap_or(0);
    tr.append_fields_iter(
        label,
        values.len().saturating_mul(coeffs_per_elem),
        values.iter().flat_map(|value| value.as_coeffs()),
    );
}

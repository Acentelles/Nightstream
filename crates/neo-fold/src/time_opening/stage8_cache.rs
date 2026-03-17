use crate::shard_proof_types::{OpeningDomain, TimeOpeningProof, TimeOpeningSource, TimePointOpening};
use crate::time_opening::joint_lane_accel as accel;
use crate::PiCcsError;
use neo_ajtai::Commitment as Cmt;
use neo_ccs::Mat;
use neo_math::{D, F, K};
use neo_memory::witness::StepWitnessBundle;
use neo_params::NeoParams;
use p3_field::{PrimeCharacteristicRing, PrimeField64};

#[derive(Clone)]
pub(crate) struct EncodedStage8Column {
    pub abs_pos: usize,
    pub z_col: Mat<F>,
    #[allow(dead_code)]
    pub row_nz: Vec<Vec<(usize, F)>>,
    pub rq_nonzero_cols: Vec<(usize, neo_gpu::FlatRq)>,
}

pub(crate) type EncodedStage8ColumnCache = std::collections::BTreeMap<usize, EncodedStage8Column>;

#[allow(dead_code)]
pub(crate) fn collect_committed_opening_col_ids(openings: &[TimePointOpening]) -> std::collections::BTreeSet<usize> {
    let mut unique_col_ids = std::collections::BTreeSet::new();
    for opening in openings {
        if opening.source == TimeOpeningSource::CommittedOpening {
            unique_col_ids.extend(opening.col_ids.iter().copied());
        }
    }
    unique_col_ids
}

pub(crate) fn collect_opening_proof_col_ids(opening_proofs: &[TimeOpeningProof]) -> std::collections::BTreeSet<usize> {
    let mut unique_col_ids = std::collections::BTreeSet::new();
    for proof in opening_proofs {
        unique_col_ids.extend(proof.col_ids.iter().copied());
    }
    unique_col_ids
}

pub(crate) fn precompute_stage8_encoded_columns_for_col_ids(
    params: &NeoParams,
    step: &StepWitnessBundle<Cmt, F, K>,
    logical_col_pos: &std::collections::BTreeMap<usize, usize>,
    cpu_cols_len: usize,
    col_ids: impl IntoIterator<Item = usize>,
) -> Result<EncodedStage8ColumnCache, PiCcsError> {
    let mut out = EncodedStage8ColumnCache::new();
    for col_id in col_ids {
        let abs_pos = logical_col_pos.get(&col_id).copied().ok_or_else(|| {
            PiCcsError::ProtocolError(format!("time/opening stage8 cache: logical col_id={} missing", col_id))
        })?;
        let col = if abs_pos < cpu_cols_len {
            step.time_columns.cpu_cols.get(abs_pos).ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "time/opening stage8 cache: CPU column index {} out of range",
                    abs_pos
                ))
            })?
        } else {
            let mem_idx = abs_pos - cpu_cols_len;
            step.time_columns.mem_cols.get(mem_idx).ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "time/opening stage8 cache: MEM column index {} out of range",
                    mem_idx
                ))
            })?
        };
        let z_col = neo_memory::ajtai::encode_vector_balanced_to_mat_with_base(
            params,
            col,
            crate::time_opening::STAGE8_TIME_DECOMP_BASE,
        );
        let row_nz = crate::time_opening::me_adapter::mat_row_nonzero_entries(&z_col);
        let mut rq_nonzero_cols = std::collections::BTreeMap::<usize, [u64; D]>::new();
        for (row, entries) in row_nz.iter().enumerate() {
            for &(col, value) in entries {
                rq_nonzero_cols
                    .entry(col)
                    .or_insert([0u64; D])[row] = value.as_canonical_u64();
            }
        }
        let rq_nonzero_cols = rq_nonzero_cols
            .into_iter()
            .map(|(col, coeffs)| (col, neo_gpu::FlatRq { coeffs }))
            .filter(|(_, col)| !accel::flat_rq_is_zero(col))
            .collect();
        out.insert(
            col_id,
            EncodedStage8Column {
                abs_pos,
                z_col,
                row_nz,
                rq_nonzero_cols,
            },
        );
    }
    Ok(out)
}

#[inline]
pub(crate) fn validate_encoded_stage8_column_domain(
    encoded_col: &EncodedStage8Column,
    cpu_cols_len: usize,
    domain: OpeningDomain,
) -> Result<(), PiCcsError> {
    match domain {
        OpeningDomain::Cpu if encoded_col.abs_pos >= cpu_cols_len => Err(PiCcsError::ProtocolError(
            "time/opening joint/prove: expected CPU claim but found MEM column id".into(),
        )),
        OpeningDomain::Mem if encoded_col.abs_pos < cpu_cols_len => Err(PiCcsError::ProtocolError(
            "time/opening joint/prove: expected MEM claim but found CPU column id".into(),
        )),
        _ => Ok(()),
    }
}

pub(crate) fn build_claim_witness_from_cache(
    t: usize,
    open_pf: &TimeOpeningProof,
    coeffs: &[Mat<F>],
    encoded_stage8_cols: &EncodedStage8ColumnCache,
    cpu_cols_len: usize,
    domain: OpeningDomain,
) -> Result<Mat<F>, PiCcsError> {
    let mut out = Mat::zero(D, t, F::ZERO);
    for (coeff, &col_id) in coeffs.iter().zip(open_pf.col_ids.iter()) {
        let encoded_col = encoded_stage8_cols.get(&col_id).ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "time/opening joint/prove: missing cached column encoding for col_id={col_id}"
            ))
        })?;
        validate_encoded_stage8_column_domain(encoded_col, cpu_cols_len, domain)?;
        super::joint_lane::left_mul_add_row_major_into(&mut out, coeff, encoded_col.z_col.as_slice(), t)?;
    }
    Ok(out)
}

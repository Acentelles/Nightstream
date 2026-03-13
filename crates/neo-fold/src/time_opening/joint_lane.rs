use crate::shard_proof_types::{
    JointClaimKind, JointOpeningGroupProof, JointOpeningLaneProof, OpeningDomain, OpeningReductionProof,
    OpeningUnificationProof, Stage8ClusterProof, TimeOpeningProof,
};
use crate::time_opening::me_adapter::{
    add_rot_scaled_commitment, apply_rot_to_digits, build_logical_col_pos, claim_commitment_and_eval,
    eval_time_mat_digits_at_point, recompose_digits_to_scalar,
};
use crate::time_opening::reduction::bind_opening_reduction_and_sample_group_coeffs;
use crate::PiCcsError;
use neo_ajtai::Commitment as Cmt;
use neo_ccs::{CcsMatrix, CcsStructure, CeClaim, CscMat, Mat, SModuleHomomorphism, SparsePoly, Term};
use neo_math::{KExtensions, D, F, K};
use neo_memory::witness::{StepInstanceBundle, StepWitnessBundle};
use neo_params::NeoParams;
use neo_reductions as ccs;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;
#[cfg(any(not(target_arch = "wasm32"), feature = "wasm-threads"))]
use rayon::prelude::*;
use std::time::Duration;

#[cfg(target_arch = "wasm32")]
type TimePoint = f64;
#[cfg(not(target_arch = "wasm32"))]
type TimePoint = std::time::Instant;

#[inline]
fn time_now() -> TimePoint {
    #[cfg(target_arch = "wasm32")]
    {
        js_sys::Date::now()
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        std::time::Instant::now()
    }
}

#[inline]
fn elapsed_duration(start: TimePoint) -> Duration {
    #[cfg(target_arch = "wasm32")]
    {
        Duration::from_secs_f64((js_sys::Date::now() - start) / 1_000.0)
    }
    #[cfg(not(target_arch = "wasm32"))]
    {
        start.elapsed()
    }
}

#[inline]
fn allow_stage8_commit_acceleration(backend_ctx: &neo_reductions::accelerator::BackendContext) -> bool {
    backend_ctx.mojo_required()
        || !matches!(
            backend_ctx.commit_many_execution_status(D),
            neo_reductions::accelerator::BackendExecutionStatus::RustCpu
        )
}

fn build_claim_witness_from_step(
    params: &NeoParams,
    step: &StepWitnessBundle<Cmt, F, K>,
    open_pf: &TimeOpeningProof,
    coeffs: &[Mat<F>],
    logical_col_pos: &std::collections::BTreeMap<usize, usize>,
    cpu_cols_len: usize,
    domain: OpeningDomain,
) -> Result<Mat<F>, PiCcsError> {
    let t = step.time_columns.t;
    let mut out = Mat::zero(D, t, F::ZERO);
    let mut z_col_row_major = Vec::new();
    for (i, &col_id) in open_pf.col_ids.iter().enumerate() {
        let abs_pos = logical_col_pos.get(&col_id).copied().ok_or_else(|| {
            PiCcsError::ProtocolError(format!("time/opening joint/prove: logical col_id={} missing", col_id))
        })?;
        match domain {
            OpeningDomain::Cpu if abs_pos >= cpu_cols_len => {
                return Err(PiCcsError::ProtocolError(
                    "time/opening joint/prove: expected CPU claim but found MEM column id".into(),
                ));
            }
            OpeningDomain::Mem if abs_pos < cpu_cols_len => {
                return Err(PiCcsError::ProtocolError(
                    "time/opening joint/prove: expected MEM claim but found CPU column id".into(),
                ));
            }
            _ => {}
        }
        let col = if abs_pos < cpu_cols_len {
            step.time_columns.cpu_cols.get(abs_pos).ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "time/opening joint/prove: CPU column index {} out of range",
                    abs_pos
                ))
            })?
        } else {
            let mem_idx = abs_pos - cpu_cols_len;
            step.time_columns.mem_cols.get(mem_idx).ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "time/opening joint/prove: MEM column index {} out of range",
                    mem_idx
                ))
            })?
        };
        neo_memory::ajtai::encode_vector_balanced_to_row_major_with_base_into(
            params,
            col,
            crate::time_opening::STAGE8_TIME_DECOMP_BASE,
            &mut z_col_row_major,
        );
        left_mul_add_row_major_into(&mut out, &coeffs[i], z_col_row_major.as_slice(), t)?;
    }
    Ok(out)
}

#[inline]
fn left_mul_add_into(dst: &mut Mat<F>, rho: &Mat<F>, src: &Mat<F>) -> Result<(), PiCcsError> {
    left_mul_add_row_major_into(dst, rho, src.as_slice(), src.cols())
}

#[inline]
fn left_mul_add_row_major_into(dst: &mut Mat<F>, rho: &Mat<F>, src_data: &[F], m: usize) -> Result<(), PiCcsError> {
    if rho.rows() != D || rho.cols() != D {
        return Err(PiCcsError::InvalidInput(format!(
            "time/opening joint: rho must be {D}x{D} (got {}x{})",
            rho.rows(),
            rho.cols()
        )));
    }
    if dst.rows() != D || dst.cols() != m || src_data.len() != D * m {
        return Err(PiCcsError::InvalidInput(format!(
            "time/opening joint: matrix shape mismatch (dst={}x{}, src={} entries)",
            dst.rows(),
            dst.cols(),
            src_data.len(),
        )));
    }
    if m == 0 {
        return Ok(());
    }
    let rho_data = rho.as_slice();
    const BLOCK_COLS: usize = 512;

    #[cfg(any(not(target_arch = "wasm32"), feature = "wasm-threads"))]
    {
        dst.as_mut_slice()
            .par_chunks_exact_mut(m)
            .enumerate()
            .for_each(|(rr, row_out)| {
                let rho_off = rr * D;
                let mut nz_coeffs = [F::ZERO; D];
                let mut nz_rows = [0usize; D];
                let mut nz_len = 0usize;
                for kk in 0..D {
                    let coeff = rho_data[rho_off + kk];
                    if coeff != F::ZERO {
                        nz_coeffs[nz_len] = coeff;
                        nz_rows[nz_len] = kk;
                        nz_len += 1;
                    }
                }
                if nz_len == 0 {
                    return;
                }

                if m <= BLOCK_COLS {
                    for nz in 0..nz_len {
                        let coeff = nz_coeffs[nz];
                        let in_row = &src_data[nz_rows[nz] * m..(nz_rows[nz] + 1) * m];
                        for (out, &inp) in row_out.iter_mut().zip(in_row.iter()) {
                            *out += coeff * inp;
                        }
                    }
                    return;
                }

                for col0 in (0..m).step_by(BLOCK_COLS) {
                    let len = core::cmp::min(BLOCK_COLS, m - col0);
                    let row_block = &mut row_out[col0..col0 + len];
                    for nz in 0..nz_len {
                        let coeff = nz_coeffs[nz];
                        let in_off = nz_rows[nz] * m + col0;
                        let in_row = &src_data[in_off..in_off + len];
                        for (out, &inp) in row_block.iter_mut().zip(in_row.iter()) {
                            *out += coeff * inp;
                        }
                    }
                }
            });
    }
    #[cfg(all(target_arch = "wasm32", not(feature = "wasm-threads")))]
    {
        let dst_data = dst.as_mut_slice();
        for rr in 0..D {
            let out_off = rr * m;
            let rho_off = rr * D;
            let mut nz_coeffs = [F::ZERO; D];
            let mut nz_rows = [0usize; D];
            let mut nz_len = 0usize;
            for kk in 0..D {
                let coeff = rho_data[rho_off + kk];
                if coeff != F::ZERO {
                    nz_coeffs[nz_len] = coeff;
                    nz_rows[nz_len] = kk;
                    nz_len += 1;
                }
            }
            if nz_len == 0 {
                continue;
            }

            if m <= BLOCK_COLS {
                let row_out = &mut dst_data[out_off..out_off + m];
                for nz in 0..nz_len {
                    let coeff = nz_coeffs[nz];
                    let in_row = &src_data[nz_rows[nz] * m..(nz_rows[nz] + 1) * m];
                    for (out, &inp) in row_out.iter_mut().zip(in_row.iter()) {
                        *out += coeff * inp;
                    }
                }
                continue;
            }

            for col0 in (0..m).step_by(BLOCK_COLS) {
                let len = core::cmp::min(BLOCK_COLS, m - col0);
                let row_block = &mut dst_data[out_off + col0..out_off + col0 + len];
                for nz in 0..nz_len {
                    let coeff = nz_coeffs[nz];
                    let in_off = nz_rows[nz] * m + col0;
                    let in_row = &src_data[in_off..in_off + len];
                    for (out, &inp) in row_block.iter_mut().zip(in_row.iter()) {
                        *out += coeff * inp;
                    }
                }
            }
        }
    }
    Ok(())
}

#[derive(Clone, Debug)]
pub struct Stage8FoldLanePlan {
    pub ccs: CcsStructure<F>,
    pub claims: Vec<CeClaim<Cmt, F, K>>,
}

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct JointOpeningLaneDurations {
    pub group_build: Duration,
    pub joint_commit_many: Duration,
    pub unified_fold_mix: Duration,
}

#[inline]
fn can_use_unified_stage8_witness(groups: &[JointOpeningGroupProof]) -> bool {
    let Some(anchor) = groups.first() else {
        return false;
    };
    groups
        .iter()
        .all(|g| g.point == anchor.point && g.domain == anchor.domain)
}

fn unified_fold_digest(groups: &[JointOpeningGroupProof]) -> [u8; 32] {
    let mut tr = neo_transcript::Poseidon2Transcript::new(b"stage8/unified_fold_digest");
    tr.append_message(b"stage8/unified_fold_digest/version", b"v2");
    tr.append_u64s(b"stage8/unified_fold_digest/groups_len", &[groups.len() as u64]);
    let mut group_digests_flat = Vec::with_capacity(groups.len() * 32);
    for g in groups {
        group_digests_flat.extend_from_slice(&g.group_digest);
    }
    tr.append_bytes_packed(b"stage8/unified_fold_digest/group_digests_flat", &group_digests_flat);
    tr.digest32()
}

fn build_stage8_group_clusters(groups: &[JointOpeningGroupProof]) -> Vec<Vec<usize>> {
    let mut clusters: Vec<Vec<usize>> = Vec::new();
    for (group_idx, group) in groups.iter().enumerate() {
        if let Some(cluster) = clusters.iter_mut().find(|cluster| {
            let anchor = &groups[cluster[0]];
            anchor.point == group.point && anchor.domain == group.domain
        }) {
            cluster.push(group_idx);
        } else {
            clusters.push(vec![group_idx]);
        }
    }
    clusters
}

fn stage8_cluster_digest(groups: &[&JointOpeningGroupProof]) -> [u8; 32] {
    let mut tr = neo_transcript::Poseidon2Transcript::new(b"stage8/cluster_fold_digest");
    tr.append_message(b"stage8/cluster_fold_digest/version", b"v1");
    tr.append_u64s(b"stage8/cluster_fold_digest/groups_len", &[groups.len() as u64]);
    let mut group_digests_flat = Vec::with_capacity(groups.len() * 32);
    for group in groups {
        group_digests_flat.extend_from_slice(&group.group_digest);
    }
    tr.append_bytes_packed(b"stage8/cluster_fold_digest/group_digests_flat", &group_digests_flat);
    tr.digest32()
}

fn bind_and_sample_stage8_cluster_mixers(
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    step_idx: usize,
    cluster_idx: usize,
    groups: &[&JointOpeningGroupProof],
    opening_unification: &OpeningUnificationProof,
) -> Result<Vec<Mat<F>>, PiCcsError> {
    tr.append_message(b"stage8/cluster_fold_bind/v1", &[]);
    tr.append_u64s(
        b"stage8/cluster_fold_bind/header",
        &[
            step_idx as u64,
            cluster_idx as u64,
            groups.len() as u64,
            opening_unification.round_polys.len() as u64,
            opening_unification.r_unify.len() as u64,
        ],
    );
    let mut group_digests_flat = Vec::with_capacity(groups.len() * 32);
    for group in groups {
        group_digests_flat.extend_from_slice(&group.group_digest);
    }
    tr.append_bytes_packed(b"stage8/cluster_fold_bind/group_digests_flat", &group_digests_flat);
    tr.append_message(b"stage8/cluster_fold_bind/digest", &stage8_cluster_digest(groups));
    tr.append_fields(
        b"stage8/cluster_fold_bind/opening_unify_claimed_sum",
        &opening_unification.claimed_sum.as_coeffs(),
    );
    let mut round_field_lens = Vec::with_capacity(opening_unification.round_polys.len());
    let mut total_round_fields = 0usize;
    for coeffs in &opening_unification.round_polys {
        let per_elem = coeffs.first().map(|v| v.as_coeffs().len()).unwrap_or(0);
        let round_len = coeffs.len().checked_mul(per_elem).ok_or_else(|| {
            PiCcsError::ProtocolError("stage8 cluster fold bind: round coefficient length overflow".into())
        })?;
        round_field_lens.push(round_len as u64);
        total_round_fields = total_round_fields.checked_add(round_len).ok_or_else(|| {
            PiCcsError::ProtocolError("stage8 cluster fold bind: total round coefficient length overflow".into())
        })?;
    }
    tr.append_u64s(
        b"stage8/cluster_fold_bind/opening_unify_round_field_lens",
        &round_field_lens,
    );
    tr.append_fields_iter(
        b"stage8/cluster_fold_bind/opening_unify_round_coeffs_flat",
        total_round_fields,
        opening_unification
            .round_polys
            .iter()
            .flat_map(|coeffs| coeffs.iter())
            .flat_map(|v| v.as_coeffs()),
    );
    let r_coeffs = opening_unification
        .r_unify
        .first()
        .map(|v| v.as_coeffs().len())
        .unwrap_or(0);
    tr.append_fields_iter(
        b"stage8/cluster_fold_bind/opening_unify_r",
        opening_unification.r_unify.len().saturating_mul(r_coeffs),
        opening_unification
            .r_unify
            .iter()
            .flat_map(|v| v.as_coeffs()),
    );
    let ring = ccs::RotRing::goldilocks();
    ccs::sample_rot_rhos_n(tr, params, &ring, groups.len())
}

fn bind_and_sample_unified_fold_mixers(
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    step_idx: usize,
    groups: &[JointOpeningGroupProof],
    opening_unification: &OpeningUnificationProof,
) -> Result<Vec<Mat<F>>, PiCcsError> {
    tr.append_message(b"stage8/unified_fold_bind/v2", &[]);
    tr.append_u64s(
        b"stage8/unified_fold_bind/header",
        &[
            step_idx as u64,
            groups.len() as u64,
            opening_unification.round_polys.len() as u64,
            opening_unification.r_unify.len() as u64,
        ],
    );
    let mut group_digests_flat = Vec::with_capacity(groups.len() * 32);
    for g in groups {
        group_digests_flat.extend_from_slice(&g.group_digest);
    }
    tr.append_bytes_packed(b"stage8/unified_fold_bind/group_digests_flat", &group_digests_flat);
    tr.append_message(b"stage8/unified_fold_bind/digest", &unified_fold_digest(groups));
    tr.append_fields(
        b"stage8/unified_fold_bind/opening_unify_claimed_sum",
        &opening_unification.claimed_sum.as_coeffs(),
    );
    let mut round_field_lens = Vec::with_capacity(opening_unification.round_polys.len());
    let mut total_round_fields = 0usize;
    for coeffs in &opening_unification.round_polys {
        let per_elem = coeffs.first().map(|v| v.as_coeffs().len()).unwrap_or(0);
        let round_len = coeffs.len().checked_mul(per_elem).ok_or_else(|| {
            PiCcsError::ProtocolError("stage8 unified fold bind: round coefficient length overflow".into())
        })?;
        round_field_lens.push(round_len as u64);
        total_round_fields = total_round_fields.checked_add(round_len).ok_or_else(|| {
            PiCcsError::ProtocolError("stage8 unified fold bind: total round coefficient length overflow".into())
        })?;
    }
    tr.append_u64s(
        b"stage8/unified_fold_bind/opening_unify_round_field_lens",
        &round_field_lens,
    );
    tr.append_fields_iter(
        b"stage8/unified_fold_bind/opening_unify_round_coeffs_flat",
        total_round_fields,
        opening_unification
            .round_polys
            .iter()
            .flat_map(|coeffs| coeffs.iter())
            .flat_map(|v| v.as_coeffs()),
    );
    let r_coeffs = opening_unification
        .r_unify
        .first()
        .map(|v| v.as_coeffs().len())
        .unwrap_or(0);
    tr.append_fields_iter(
        b"stage8/unified_fold_bind/opening_unify_r",
        opening_unification.r_unify.len().saturating_mul(r_coeffs),
        opening_unification
            .r_unify
            .iter()
            .flat_map(|v| v.as_coeffs()),
    );
    let ring = ccs::RotRing::goldilocks();
    ccs::sample_rot_rhos_n(tr, params, &ring, groups.len())
}

fn mix_group_witnesses(group_wits: &[Mat<F>], mix_rhos: &[Mat<F>], time_t: usize) -> Result<Mat<F>, PiCcsError> {
    if group_wits.len() != mix_rhos.len() {
        return Err(PiCcsError::ProtocolError(format!(
            "stage8 unified fold: witness/mixer length mismatch (wits={}, mixers={})",
            group_wits.len(),
            mix_rhos.len()
        )));
    }
    for (idx, (rho, wit)) in mix_rhos.iter().zip(group_wits.iter()).enumerate() {
        if rho.rows() != D || rho.cols() != D {
            return Err(PiCcsError::ProtocolError(format!(
                "stage8 unified fold: mixer[{idx}] shape mismatch (got {}x{}, expected {}x{})",
                rho.rows(),
                rho.cols(),
                D,
                D
            )));
        }
        if wit.rows() != D || wit.cols() != time_t {
            return Err(PiCcsError::ProtocolError(format!(
                "stage8 unified fold: witness[{idx}] shape mismatch (got {}x{}, expected {}x{})",
                wit.rows(),
                wit.cols(),
                D,
                time_t
            )));
        }
    }
    let mut out = Mat::zero(D, time_t, F::ZERO);
    if group_wits.is_empty() || time_t == 0 {
        return Ok(out);
    }

    const BLOCK_COLS: usize = 1024;
    #[cfg(any(not(target_arch = "wasm32"), feature = "wasm-threads"))]
    {
        out.as_mut_slice()
            .par_chunks_exact_mut(time_t)
            .enumerate()
            .for_each(|(rr, row_out)| {
                for col0 in (0..time_t).step_by(BLOCK_COLS) {
                    let len = core::cmp::min(BLOCK_COLS, time_t - col0);
                    for (rho, wit) in mix_rhos.iter().zip(group_wits.iter()) {
                        let rho_data = rho.as_slice();
                        let wit_data = wit.as_slice();
                        let rho_off = rr * D;
                        for kk in 0..D {
                            let coeff = rho_data[rho_off + kk];
                            if coeff == F::ZERO {
                                continue;
                            }
                            let in_off = kk * time_t + col0;
                            let in_row = &wit_data[in_off..in_off + len];
                            for t in 0..len {
                                row_out[col0 + t] += coeff * in_row[t];
                            }
                        }
                    }
                }
            });
    }
    #[cfg(all(target_arch = "wasm32", not(feature = "wasm-threads")))]
    {
        let out_data = out.as_mut_slice();
        for rr in 0..D {
            let out_off = rr * time_t;
            for col0 in (0..time_t).step_by(BLOCK_COLS) {
                let len = core::cmp::min(BLOCK_COLS, time_t - col0);
                for (rho, wit) in mix_rhos.iter().zip(group_wits.iter()) {
                    let rho_data = rho.as_slice();
                    let wit_data = wit.as_slice();
                    let rho_off = rr * D;
                    for kk in 0..D {
                        let coeff = rho_data[rho_off + kk];
                        if coeff == F::ZERO {
                            continue;
                        }
                        let in_off = kk * time_t + col0;
                        for t in 0..len {
                            out_data[out_off + col0 + t] += coeff * wit_data[in_off + t];
                        }
                    }
                }
            }
        }
    }
    Ok(out)
}

fn build_stage8_commit_fold_ccs(time_t: usize, r_len: usize) -> Result<CcsStructure<F>, PiCcsError> {
    if time_t == 0 {
        return Err(PiCcsError::InvalidInput(
            "stage8/commit fold: time_t must be > 0".into(),
        ));
    }
    let n = 1usize
        .checked_shl(r_len as u32)
        .ok_or_else(|| PiCcsError::InvalidInput("stage8/commit fold: 2^ell_n overflow".into()))?
        .max(1);
    let mat = CscMat::from_triplets(Vec::new(), n, time_t);
    let poly = SparsePoly::new(
        1,
        vec![Term {
            coeff: F::ONE,
            exps: vec![1],
        }],
    );
    CcsStructure::new_sparse(vec![CcsMatrix::Csc(mat)], poly)
        .map_err(|e| PiCcsError::InvalidInput(format!("stage8/commit fold: invalid CCS structure: {e:?}")))
}

pub fn build_stage8_fold_lane_plan(
    lane: &JointOpeningLaneProof,
    opening_unification: &OpeningUnificationProof,
    time_t: usize,
) -> Result<Option<Stage8FoldLanePlan>, PiCcsError> {
    if lane.claim_kind != JointClaimKind::VectorPartial {
        return Err(PiCcsError::ProtocolError(
            "stage8/commit fold: unsupported claim kind (expected VectorPartial)".into(),
        ));
    }
    if lane.groups.is_empty() {
        return Ok(None);
    }
    if time_t == 0 {
        return Err(PiCcsError::ProtocolError(
            "stage8/commit fold: time_t must be > 0 in canonical mode".into(),
        ));
    }
    if opening_unification.r_unify.is_empty() {
        return Err(PiCcsError::ProtocolError(
            "stage8/commit fold: opening_unification.r_unify must be non-empty when groups are present".into(),
        ));
    }

    let ccs = build_stage8_commit_fold_ccs(time_t, opening_unification.r_unify.len())?;
    let d_pad = D.next_power_of_two();
    let fold_digest = unified_fold_digest(&lane.groups);
    let input_groups: Vec<(Vec<K>, OpeningDomain, Cmt)> = if !lane.stage8_clusters.is_empty() {
        lane.stage8_clusters
            .iter()
            .map(|cluster| (cluster.point.clone(), cluster.domain, cluster.joint_commitment.clone()))
            .collect()
    } else if can_use_unified_stage8_witness(&lane.groups) {
        vec![(
            lane.unified_fold
                .as_ref()
                .ok_or_else(|| {
                    PiCcsError::ProtocolError("stage8/commit fold: missing unified_fold for collapsible groups".into())
                })?
                .point
                .clone(),
            lane.unified_fold
                .as_ref()
                .ok_or_else(|| {
                    PiCcsError::ProtocolError("stage8/commit fold: missing unified_fold for collapsible groups".into())
                })?
                .domain,
            lane.unified_fold
                .as_ref()
                .ok_or_else(|| {
                    PiCcsError::ProtocolError("stage8/commit fold: missing unified_fold for collapsible groups".into())
                })?
                .joint_commitment
                .clone(),
        )]
    } else {
        lane.groups
            .iter()
            .map(|group| (group.point.clone(), group.domain, group.joint_commitment.clone()))
            .collect()
    };
    let claims = input_groups
        .into_iter()
        .map(|(_, _, commitment)| CeClaim::<Cmt, F, K> {
            c: commitment,
            X: Mat::zero(D, 0, F::ZERO),
            r: opening_unification.r_unify.clone(),
            s_col: Vec::new(),
            y_ring: vec![vec![K::ZERO; d_pad]],
            ct: vec![K::ZERO],
            aux_openings: Vec::new(),
            y_zcol: Vec::new(),
            m_in: 0,
            fold_digest,
            c_step_coords: Vec::new(),
            u_offset: 0,
            u_len: 0,
        })
        .collect();
    Ok(Some(Stage8FoldLanePlan { ccs, claims }))
}

pub fn prove_joint_opening_lane_with_witnesses(
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    step_idx: usize,
    step: &StepWitnessBundle<Cmt, F, K>,
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    cpu_bus: &neo_memory::cpu::BusLayout,
    time_cpu_commitments: &[Cmt],
    time_mem_commitments: &[Cmt],
    time_col_ids: &[usize],
    opening_proofs: &[TimeOpeningProof],
    manifest_digest: &[u8; 32],
    reduction: &OpeningReductionProof,
    opening_unification: &OpeningUnificationProof,
    claim_eta_coeffs: &[Vec<Mat<F>>],
) -> Result<(JointOpeningLaneProof, Vec<Mat<F>>), PiCcsError> {
    prove_joint_opening_lane_with_witnesses_and_metrics(
        tr,
        params,
        step_idx,
        step,
        backend_ctx,
        cpu_bus,
        time_cpu_commitments,
        time_mem_commitments,
        time_col_ids,
        opening_proofs,
        manifest_digest,
        reduction,
        opening_unification,
        claim_eta_coeffs,
    )
    .map(|(lane, wits, _metrics)| (lane, wits))
}

pub fn prove_joint_opening_lane_with_witnesses_and_metrics(
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    step_idx: usize,
    step: &StepWitnessBundle<Cmt, F, K>,
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    cpu_bus: &neo_memory::cpu::BusLayout,
    time_cpu_commitments: &[Cmt],
    time_mem_commitments: &[Cmt],
    time_col_ids: &[usize],
    opening_proofs: &[TimeOpeningProof],
    manifest_digest: &[u8; 32],
    reduction: &OpeningReductionProof,
    opening_unification: &OpeningUnificationProof,
    claim_eta_coeffs: &[Vec<Mat<F>>],
) -> Result<(JointOpeningLaneProof, Vec<Mat<F>>, JointOpeningLaneDurations), PiCcsError> {
    let mut metrics = JointOpeningLaneDurations::default();
    let allow_commit_accel = allow_stage8_commit_acceleration(backend_ctx);
    if opening_proofs.len() != claim_eta_coeffs.len() {
        return Err(PiCcsError::ProtocolError(
            "time/opening joint/prove: opening_proofs and claim_eta_coeffs length mismatch".into(),
        ));
    }
    let t = step.time_columns.t;
    if t == 0 {
        return Err(PiCcsError::ProtocolError(
            "time/opening joint/prove: time_t must be > 0 in canonical mode".into(),
        ));
    }

    let logical_col_pos = build_logical_col_pos(time_col_ids)?;
    let group_rhos = bind_opening_reduction_and_sample_group_coeffs(
        tr,
        params,
        step_idx,
        opening_proofs.len(),
        manifest_digest,
        reduction,
    )?;
    if group_rhos.len() != reduction.groups.len() {
        return Err(PiCcsError::ProtocolError(
            "time/opening joint/prove: sampled group rho count mismatch".into(),
        ));
    }

    let committer = neo_ajtai::AjtaiSModule::from_global_for_dims(D, t).map_err(|e| {
        PiCcsError::InvalidInput(format!(
            "time/opening joint/prove: missing Ajtai committer for (D,t)=({D},{t}): {e}"
        ))
    })?;
    let cpu_cols_len = time_cpu_commitments.len();

    struct GroupWork {
        point: Vec<K>,
        domain: OpeningDomain,
        claim_indices: Vec<usize>,
        group_digest: [u8; 32],
        mix_rhos: Vec<Mat<F>>,
        claim_commitments: Vec<Cmt>,
        joint_claim_digits: Vec<K>,
        joint_z: Mat<F>,
    }

    let build_group = |group_idx: usize,
                       group: &crate::shard_proof_types::OpeningReductionGroup|
     -> Result<GroupWork, PiCcsError> {
        let rhos = group_rhos
            .get(group_idx)
            .ok_or_else(|| PiCcsError::ProtocolError("time/opening joint/prove: missing group coefficients".into()))?;
        if rhos.len() != group.claim_indices.len() {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/prove: group {} rho len {} != claim_indices len {}",
                group_idx,
                rhos.len(),
                group.claim_indices.len()
            )));
        }

        let mut joint_z = Mat::zero(D, t, F::ZERO);
        let mut claim_commitments: Vec<Cmt> = Vec::with_capacity(group.claim_indices.len());
        let mut expected_claim_digits = vec![K::ZERO; D];

        for (local_idx, &claim_idx) in group.claim_indices.iter().enumerate() {
            let open_pf = opening_proofs.get(claim_idx).ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "time/opening joint/prove: claim index {} out of range",
                    claim_idx
                ))
            })?;
            let eta = claim_eta_coeffs.get(claim_idx).ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "time/opening joint/prove: missing eta coeffs for claim {}",
                    claim_idx
                ))
            })?;

            let claim = claim_commitment_and_eval(
                open_pf,
                eta,
                &logical_col_pos,
                cpu_cols_len,
                time_cpu_commitments,
                time_mem_commitments,
                crate::time_opening::STAGE8_TIME_DECOMP_BASE,
            )?;

            let rho = &rhos[local_idx];
            claim_commitments.push(claim.commitment.clone());
            let rotated_digits = apply_rot_to_digits(rho, claim.eval_digits.as_slice())?;
            for i in 0..D {
                expected_claim_digits[i] += rotated_digits[i];
            }

            let claim_z = build_claim_witness_from_step(
                params,
                step,
                open_pf,
                eta,
                &logical_col_pos,
                cpu_cols_len,
                claim.domain,
            )?;
            left_mul_add_into(&mut joint_z, rho, &claim_z)?;
        }

        let joint_claim_digits =
            eval_time_mat_digits_at_point(group.domain, group.point.as_slice(), step.mcs.0.m_in, cpu_bus, &joint_z)?;
        if joint_claim_digits != expected_claim_digits {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/prove: group {} claim(digits) mismatch",
                group_idx
            )));
        }
        let joint_claim = recompose_digits_to_scalar(
            joint_claim_digits.as_slice(),
            crate::time_opening::STAGE8_TIME_DECOMP_BASE,
        );
        let expected_claim = recompose_digits_to_scalar(
            expected_claim_digits.as_slice(),
            crate::time_opening::STAGE8_TIME_DECOMP_BASE,
        );
        if joint_claim != expected_claim {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/prove: group {} claim(scalar) mismatch",
                group_idx
            )));
        }

        Ok(GroupWork {
            point: group.point.clone(),
            domain: group.domain,
            claim_indices: group.claim_indices.clone(),
            group_digest: group.group_digest,
            mix_rhos: rhos.clone(),
            claim_commitments,
            joint_claim_digits,
            joint_z,
        })
    };

    let group_results_start = time_now();
    #[cfg(any(not(target_arch = "wasm32"), feature = "wasm-threads"))]
    let group_results: Result<Vec<GroupWork>, PiCcsError> = reduction
        .groups
        .par_iter()
        .enumerate()
        .map(|(group_idx, group)| build_group(group_idx, group))
        .collect();
    #[cfg(all(target_arch = "wasm32", not(feature = "wasm-threads")))]
    let group_results: Result<Vec<GroupWork>, PiCcsError> = reduction
        .groups
        .iter()
        .enumerate()
        .map(|(group_idx, group)| build_group(group_idx, group))
        .collect();

    let group_results = group_results?;
    metrics.group_build += elapsed_duration(group_results_start);
    let joint_refs: Vec<&Mat<F>> = group_results.iter().map(|g| &g.joint_z).collect();
    let joint_commit_start = time_now();
    let joint_commitments = if allow_commit_accel {
        crate::shard::commit_many_with_backend(backend_ctx, &committer, &joint_refs)?
    } else {
        committer.commit_many(&joint_refs)
    };
    metrics.joint_commit_many += elapsed_duration(joint_commit_start);
    if joint_commitments.len() != group_results.len() {
        return Err(PiCcsError::ProtocolError(format!(
            "time/opening joint/prove: joint commitment count mismatch (got {}, expected {})",
            joint_commitments.len(),
            group_results.len()
        )));
    }

    let expected_commitments = if allow_commit_accel {
        crate::shard::mix_many_rhos_commits_with_backend(
            backend_ctx,
            |mix_rhos, commits| {
                let mut acc: Option<Cmt> = None;
                for (rho, commit) in mix_rhos.iter().zip(commits.iter()) {
                    add_rot_scaled_commitment(&mut acc, commit, rho).expect("stage8 batched group fallback mix");
                }
                acc.expect("stage8 batched group fallback commitment")
            },
            &group_results
                .iter()
                .map(|group| group.mix_rhos.clone())
                .collect::<Vec<_>>(),
            &group_results
                .iter()
                .map(|group| group.claim_commitments.clone())
                .collect::<Vec<_>>(),
        )?
    } else {
        group_results
            .iter()
            .enumerate()
            .map(|(group_idx, group)| {
                let mut acc: Option<Cmt> = None;
                for (rho, commit) in group.mix_rhos.iter().zip(group.claim_commitments.iter()) {
                    add_rot_scaled_commitment(&mut acc, commit, rho)?;
                }
                acc.ok_or_else(|| {
                    PiCcsError::ProtocolError(format!("time/opening joint/prove: group {} has no claims", group_idx))
                })
            })
            .collect::<Result<Vec<_>, _>>()?
    };
    if expected_commitments.len() != group_results.len() {
        return Err(PiCcsError::ProtocolError(format!(
            "time/opening joint/prove: expected commitment count mismatch (got {}, expected {})",
            expected_commitments.len(),
            group_results.len()
        )));
    }

    let mut out_groups = Vec::with_capacity(group_results.len());
    let mut out_wits = Vec::with_capacity(group_results.len());
    for (group_idx, ((group_work, joint_commitment), expected_commitment)) in group_results
        .into_iter()
        .zip(joint_commitments.into_iter())
        .zip(expected_commitments.into_iter())
        .enumerate()
    {
        if joint_commitment != expected_commitment {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/prove: group {} commitment mismatch",
                group_idx
            )));
        }

        let joint_claim = recompose_digits_to_scalar(
            group_work.joint_claim_digits.as_slice(),
            crate::time_opening::STAGE8_TIME_DECOMP_BASE,
        );

        out_groups.push(JointOpeningGroupProof {
            point: group_work.point,
            domain: group_work.domain,
            claim_indices: group_work.claim_indices,
            group_digest: group_work.group_digest,
            joint_claim_digits: group_work.joint_claim_digits,
            joint_claim,
            joint_commitment,
            opening_ccs_proof: None,
        });
        out_wits.push(group_work.joint_z);
    }

    let mut stage8_clusters: Vec<Stage8ClusterProof> = Vec::new();
    let mut unified_fold: Option<JointOpeningGroupProof> = None;
    let mut stage8_fold_wits: Option<Vec<Mat<F>>> = None;
    if !out_groups.is_empty() {
        let cluster_layouts = build_stage8_group_clusters(&out_groups);
        let unified_mix_start = time_now();
        let anchor = out_groups
            .first()
            .ok_or_else(|| PiCcsError::ProtocolError("stage8 unified fold: empty groups".into()))?;
        let can_unify = can_use_unified_stage8_witness(&out_groups);
        if !can_unify {
            let mut cluster_wits = Vec::with_capacity(cluster_layouts.len());
            stage8_clusters.reserve(cluster_layouts.len());
            for (cluster_idx, group_indices) in cluster_layouts.iter().enumerate() {
                let member_groups: Vec<&JointOpeningGroupProof> =
                    group_indices.iter().map(|&idx| &out_groups[idx]).collect();
                let cluster_digest = stage8_cluster_digest(&member_groups);
                if group_indices.len() == 1 {
                    let idx = group_indices[0];
                    let group = &out_groups[idx];
                    stage8_clusters.push(Stage8ClusterProof {
                        point: group.point.clone(),
                        domain: group.domain,
                        group_indices: vec![idx],
                        cluster_digest,
                        joint_claim_digits: group.joint_claim_digits.clone(),
                        joint_claim: group.joint_claim,
                        joint_commitment: group.joint_commitment.clone(),
                    });
                    cluster_wits.push(out_wits[idx].clone());
                    continue;
                }

                let mix_rhos = bind_and_sample_stage8_cluster_mixers(
                    tr,
                    params,
                    step_idx,
                    cluster_idx,
                    &member_groups,
                    opening_unification,
                )?;
                if mix_rhos.len() != member_groups.len() {
                    return Err(PiCcsError::ProtocolError(format!(
                        "stage8 cluster fold: sampled mixer count {} != cluster group count {}",
                        mix_rhos.len(),
                        member_groups.len()
                    )));
                }
                let expected_commitment = if allow_commit_accel {
                    crate::shard::mix_rhos_commits_with_backend_result(
                        backend_ctx,
                        |rhos, commits| {
                            let mut acc: Option<Cmt> = None;
                            for (rho, commit) in rhos.iter().zip(commits.iter()) {
                                add_rot_scaled_commitment(&mut acc, commit, rho)
                                    .expect("stage8 cluster fold fallback mix");
                            }
                            acc.expect("stage8 cluster fold fallback commitment")
                        },
                        mix_rhos.as_slice(),
                        &member_groups
                            .iter()
                            .map(|group| group.joint_commitment.clone())
                            .collect::<Vec<_>>(),
                    )?
                } else {
                    let mut acc: Option<Cmt> = None;
                    for (rho, group) in mix_rhos.iter().zip(member_groups.iter()) {
                        add_rot_scaled_commitment(&mut acc, &group.joint_commitment, rho)?;
                    }
                    acc.ok_or_else(|| {
                        PiCcsError::ProtocolError("stage8 cluster fold: missing expected commitment".into())
                    })?
                };
                let mut expected_claim_digits = vec![K::ZERO; D];
                for (rho, group) in mix_rhos.iter().zip(member_groups.iter()) {
                    let rotated = apply_rot_to_digits(rho, group.joint_claim_digits.as_slice())?;
                    for i in 0..D {
                        expected_claim_digits[i] += rotated[i];
                    }
                }
                let cluster_group_wits: Vec<Mat<F>> = group_indices
                    .iter()
                    .map(|&idx| out_wits[idx].clone())
                    .collect();
                let cluster_wit = mix_group_witnesses(&cluster_group_wits, &mix_rhos, t)?;
                let cluster_commitment = if allow_commit_accel {
                    let commits = crate::shard::commit_many_with_backend(backend_ctx, &committer, &[&cluster_wit])?;
                    commits
                        .into_iter()
                        .next()
                        .ok_or_else(|| PiCcsError::ProtocolError("stage8 cluster fold: missing commitment".into()))?
                } else {
                    committer.commit(&cluster_wit)
                };
                if cluster_commitment != expected_commitment {
                    return Err(PiCcsError::ProtocolError(
                        "stage8 cluster fold: commitment mismatch".into(),
                    ));
                }
                let cluster_anchor = member_groups[0];
                let cluster_claim_digits = eval_time_mat_digits_at_point(
                    cluster_anchor.domain,
                    cluster_anchor.point.as_slice(),
                    step.mcs.0.m_in,
                    cpu_bus,
                    &cluster_wit,
                )?;
                if cluster_claim_digits != expected_claim_digits {
                    return Err(PiCcsError::ProtocolError(
                        "stage8 cluster fold: claim digits mismatch vs transcript-mixed group claims".into(),
                    ));
                }
                stage8_clusters.push(Stage8ClusterProof {
                    point: cluster_anchor.point.clone(),
                    domain: cluster_anchor.domain,
                    group_indices: group_indices.clone(),
                    cluster_digest,
                    joint_claim: recompose_digits_to_scalar(
                        cluster_claim_digits.as_slice(),
                        crate::time_opening::STAGE8_TIME_DECOMP_BASE,
                    ),
                    joint_claim_digits: cluster_claim_digits,
                    joint_commitment: cluster_commitment,
                });
                cluster_wits.push(cluster_wit);
            }
            stage8_fold_wits = Some(cluster_wits);
        }
        let mix_rhos = bind_and_sample_unified_fold_mixers(tr, params, step_idx, &out_groups, opening_unification)?;
        if mix_rhos.len() != out_groups.len() {
            return Err(PiCcsError::ProtocolError(format!(
                "stage8 unified fold: sampled mixer count {} != group count {}",
                mix_rhos.len(),
                out_groups.len()
            )));
        }
        let expected_commitment = if allow_commit_accel {
            crate::shard::mix_rhos_commits_with_backend_result(
                backend_ctx,
                |rhos, commits| {
                    let mut acc: Option<Cmt> = None;
                    for (rho, commit) in rhos.iter().zip(commits.iter()) {
                        add_rot_scaled_commitment(&mut acc, commit, rho).expect("stage8 unified fold fallback mix");
                    }
                    acc.expect("stage8 unified fold fallback commitment")
                },
                mix_rhos.as_slice(),
                &out_groups
                    .iter()
                    .map(|g| g.joint_commitment.clone())
                    .collect::<Vec<_>>(),
            )?
        } else {
            let mut acc: Option<Cmt> = None;
            for (rho, group) in mix_rhos.iter().zip(out_groups.iter()) {
                add_rot_scaled_commitment(&mut acc, &group.joint_commitment, rho)?;
            }
            acc.ok_or_else(|| PiCcsError::ProtocolError("stage8 unified fold: missing expected commitment".into()))?
        };
        let mut expected_claim_digits = vec![K::ZERO; D];
        for (rho, group) in mix_rhos.iter().zip(out_groups.iter()) {
            let rotated = apply_rot_to_digits(rho, group.joint_claim_digits.as_slice())?;
            for i in 0..D {
                expected_claim_digits[i] += rotated[i];
            }
        }
        let (unified_point, unified_domain, unified_commitment, unified_claim_digits) = if can_unify {
            let unified_z = mix_group_witnesses(&out_wits, &mix_rhos, t)?;
            let unified_commitment = if allow_commit_accel {
                let commits = crate::shard::commit_many_with_backend(backend_ctx, &committer, &[&unified_z])?;
                commits
                    .into_iter()
                    .next()
                    .ok_or_else(|| PiCcsError::ProtocolError("stage8 unified fold: missing commitment".into()))?
            } else {
                committer.commit(&unified_z)
            };
            if unified_commitment != expected_commitment {
                return Err(PiCcsError::ProtocolError(
                    "stage8 unified fold: commitment mismatch".into(),
                ));
            }
            let unified_claim_digits = eval_time_mat_digits_at_point(
                anchor.domain,
                anchor.point.as_slice(),
                step.mcs.0.m_in,
                cpu_bus,
                &unified_z,
            )?;
            if unified_claim_digits != expected_claim_digits {
                return Err(PiCcsError::ProtocolError(
                    "stage8 unified fold: joint claim digits mismatch vs transcript-mixed group claims".into(),
                ));
            }
            stage8_fold_wits = Some(vec![unified_z]);
            (
                anchor.point.clone(),
                anchor.domain,
                unified_commitment,
                unified_claim_digits,
            )
        } else {
            (
                opening_unification.r_unify.clone(),
                OpeningDomain::Cpu,
                expected_commitment,
                expected_claim_digits,
            )
        };
        let unified_claim = recompose_digits_to_scalar(
            unified_claim_digits.as_slice(),
            crate::time_opening::STAGE8_TIME_DECOMP_BASE,
        );
        unified_fold = Some(JointOpeningGroupProof {
            point: unified_point,
            domain: unified_domain,
            claim_indices: (0..out_groups.len()).collect(),
            group_digest: unified_fold_digest(&out_groups),
            joint_claim_digits: unified_claim_digits,
            joint_claim: unified_claim,
            joint_commitment: unified_commitment,
            opening_ccs_proof: None,
        });
        if can_unify {
            stage8_clusters.push(Stage8ClusterProof {
                point: anchor.point.clone(),
                domain: anchor.domain,
                group_indices: (0..out_groups.len()).collect(),
                cluster_digest: stage8_cluster_digest(&out_groups.iter().collect::<Vec<_>>()),
                joint_claim_digits: unified_fold
                    .as_ref()
                    .expect("stage8 cluster unified fold")
                    .joint_claim_digits
                    .clone(),
                joint_claim: unified_fold
                    .as_ref()
                    .expect("stage8 cluster unified fold")
                    .joint_claim,
                joint_commitment: unified_fold
                    .as_ref()
                    .expect("stage8 cluster unified fold")
                    .joint_commitment
                    .clone(),
            });
        }
        metrics.unified_fold_mix += elapsed_duration(unified_mix_start);
    }

    let stage8_fold_wits = stage8_fold_wits.unwrap_or(out_wits);

    Ok((
        JointOpeningLaneProof {
            claim_kind: JointClaimKind::VectorPartial,
            groups: out_groups,
            stage8_clusters,
            unified_fold,
        },
        stage8_fold_wits,
        metrics,
    ))
}

pub fn prove_joint_opening_lane(
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    step_idx: usize,
    step: &StepWitnessBundle<Cmt, F, K>,
    backend_ctx: &neo_reductions::accelerator::BackendContext,
    cpu_bus: &neo_memory::cpu::BusLayout,
    time_cpu_commitments: &[Cmt],
    time_mem_commitments: &[Cmt],
    time_col_ids: &[usize],
    opening_proofs: &[TimeOpeningProof],
    manifest_digest: &[u8; 32],
    reduction: &OpeningReductionProof,
    opening_unification: &OpeningUnificationProof,
    claim_eta_coeffs: &[Vec<Mat<F>>],
) -> Result<JointOpeningLaneProof, PiCcsError> {
    let (lane, _wits, _metrics) = prove_joint_opening_lane_with_witnesses_and_metrics(
        tr,
        params,
        step_idx,
        step,
        backend_ctx,
        cpu_bus,
        time_cpu_commitments,
        time_mem_commitments,
        time_col_ids,
        opening_proofs,
        manifest_digest,
        reduction,
        opening_unification,
        claim_eta_coeffs,
    )?;
    Ok(lane)
}

pub fn verify_joint_opening_lane(
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    step_idx: usize,
    _step: &StepInstanceBundle<Cmt, F, K>,
    _cpu_bus: &neo_memory::cpu::BusLayout,
    time_t: usize,
    time_cpu_commitments: &[Cmt],
    time_mem_commitments: &[Cmt],
    time_col_ids: &[usize],
    opening_proofs: &[TimeOpeningProof],
    manifest_digest: &[u8; 32],
    reduction: &OpeningReductionProof,
    opening_unification: &OpeningUnificationProof,
    lane: &JointOpeningLaneProof,
    claim_eta_coeffs: &[Vec<Mat<F>>],
) -> Result<(), PiCcsError> {
    if opening_proofs.len() != claim_eta_coeffs.len() {
        return Err(PiCcsError::ProtocolError(
            "time/opening joint/verify: opening_proofs and claim_eta_coeffs length mismatch".into(),
        ));
    }
    if time_t == 0 {
        return Err(PiCcsError::ProtocolError(
            "time/opening joint/verify: time_t must be > 0 in canonical mode".into(),
        ));
    }
    if lane.claim_kind != JointClaimKind::VectorPartial {
        return Err(PiCcsError::ProtocolError(
            "time/opening joint/verify: unsupported claim kind (expected VectorPartial)".into(),
        ));
    }

    let logical_col_pos = build_logical_col_pos(time_col_ids)?;
    let group_rhos = bind_opening_reduction_and_sample_group_coeffs(
        tr,
        params,
        step_idx,
        opening_proofs.len(),
        manifest_digest,
        reduction,
    )?;
    if reduction.groups.len() != lane.groups.len() {
        return Err(PiCcsError::ProtocolError(format!(
            "time/opening joint/verify: reduction groups {} != lane groups {}",
            reduction.groups.len(),
            lane.groups.len()
        )));
    }

    let cpu_cols_len = time_cpu_commitments.len();
    for (group_idx, (group, pf_group)) in reduction.groups.iter().zip(lane.groups.iter()).enumerate() {
        if group.point != pf_group.point
            || group.domain != pf_group.domain
            || group.claim_indices != pf_group.claim_indices
            || group.group_digest != pf_group.group_digest
        {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/verify: group {} metadata mismatch between reduction and proof",
                group_idx
            )));
        }

        let rhos = group_rhos.get(group_idx).ok_or_else(|| {
            PiCcsError::ProtocolError("time/opening joint/verify: missing sampled group coefficients".into())
        })?;
        if rhos.len() != group.claim_indices.len() {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/verify: group {} rho len {} != claim_indices len {}",
                group_idx,
                rhos.len(),
                group.claim_indices.len()
            )));
        }

        let mut expected_commitment: Option<Cmt> = None;
        let mut expected_claim_digits = vec![K::ZERO; D];
        for (local_idx, &claim_idx) in group.claim_indices.iter().enumerate() {
            let open_pf = opening_proofs.get(claim_idx).ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "time/opening joint/verify: claim index {} out of range",
                    claim_idx
                ))
            })?;
            let eta = claim_eta_coeffs.get(claim_idx).ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "time/opening joint/verify: missing eta coeffs for claim {}",
                    claim_idx
                ))
            })?;
            let claim = claim_commitment_and_eval(
                open_pf,
                eta,
                &logical_col_pos,
                cpu_cols_len,
                time_cpu_commitments,
                time_mem_commitments,
                crate::time_opening::STAGE8_TIME_DECOMP_BASE,
            )?;
            let rho = &rhos[local_idx];
            add_rot_scaled_commitment(&mut expected_commitment, &claim.commitment, rho)?;
            let rotated_digits = apply_rot_to_digits(rho, claim.eval_digits.as_slice())?;
            for i in 0..D {
                expected_claim_digits[i] += rotated_digits[i];
            }
        }
        let expected_claim = recompose_digits_to_scalar(
            expected_claim_digits.as_slice(),
            crate::time_opening::STAGE8_TIME_DECOMP_BASE,
        );

        let expected_commitment = expected_commitment.ok_or_else(|| {
            PiCcsError::ProtocolError(format!("time/opening joint/verify: group {} has no claims", group_idx))
        })?;
        if pf_group.joint_commitment != expected_commitment {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/verify: group {} joint_commitment mismatch",
                group_idx
            )));
        }
        if pf_group.joint_claim_digits != expected_claim_digits {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/verify: group {} joint_claim_digits mismatch",
                group_idx
            )));
        }
        if pf_group.joint_claim != expected_claim {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/verify: group {} joint_claim mismatch",
                group_idx
            )));
        }
    }

    if lane.groups.is_empty() {
        if !lane.stage8_clusters.is_empty() {
            return Err(PiCcsError::ProtocolError(
                "time/opening joint/verify: stage8_clusters must be absent when there are no groups".into(),
            ));
        }
        if lane.unified_fold.is_some() {
            return Err(PiCcsError::ProtocolError(
                "time/opening joint/verify: unified_fold must be absent when there are no groups".into(),
            ));
        }
        return Ok(());
    }
    let first_group = lane
        .groups
        .first()
        .ok_or_else(|| PiCcsError::ProtocolError("time/opening joint/verify: missing first group".into()))?;
    let can_unify = lane
        .groups
        .iter()
        .all(|g| g.point == first_group.point && g.domain == first_group.domain);
    let cluster_layouts = build_stage8_group_clusters(&lane.groups);
    if lane.stage8_clusters.len() != cluster_layouts.len() {
        return Err(PiCcsError::ProtocolError(format!(
            "time/opening joint/verify: stage8 cluster count {} != expected {}",
            lane.stage8_clusters.len(),
            cluster_layouts.len()
        )));
    }

    let unified = lane
        .unified_fold
        .as_ref()
        .ok_or_else(|| PiCcsError::ProtocolError("time/opening joint/verify: missing unified_fold claim".into()))?;
    let expected_indices: Vec<usize> = (0..lane.groups.len()).collect();
    if unified.claim_indices != expected_indices {
        return Err(PiCcsError::ProtocolError(
            "time/opening joint/verify: unified_fold claim_indices must be 0..groups.len()".into(),
        ));
    }
    if can_unify {
        if unified.point != first_group.point || unified.domain != first_group.domain {
            return Err(PiCcsError::ProtocolError(
                "time/opening joint/verify: unified_fold anchor point/domain must match first group".into(),
            ));
        }
    } else if unified.point.as_slice() != opening_unification.r_unify.as_slice() || unified.domain != OpeningDomain::Cpu
    {
        return Err(PiCcsError::ProtocolError(
            "time/opening joint/verify: unified_fold must use synthetic (r_unify, Cpu) anchor for multi-point/domain groups"
                .into(),
        ));
    }
    if unified.group_digest != unified_fold_digest(&lane.groups) {
        return Err(PiCcsError::ProtocolError(
            "time/opening joint/verify: unified_fold digest mismatch".into(),
        ));
    }
    if unified.joint_claim_digits.len() != D {
        return Err(PiCcsError::ProtocolError(format!(
            "time/opening joint/verify: unified_fold joint_claim_digits.len()={} != D={D}",
            unified.joint_claim_digits.len()
        )));
    }
    let recomposed = recompose_digits_to_scalar(
        unified.joint_claim_digits.as_slice(),
        crate::time_opening::STAGE8_TIME_DECOMP_BASE,
    );
    if unified.joint_claim != recomposed {
        return Err(PiCcsError::ProtocolError(
            "time/opening joint/verify: unified_fold scalar recomposition mismatch".into(),
        ));
    }
    for (cluster_idx, (cluster, group_indices)) in lane
        .stage8_clusters
        .iter()
        .zip(cluster_layouts.iter())
        .enumerate()
    {
        let member_groups: Vec<&JointOpeningGroupProof> = group_indices.iter().map(|&idx| &lane.groups[idx]).collect();
        let anchor = member_groups[0];
        if cluster.group_indices != *group_indices {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/verify: stage8 cluster {} group_indices mismatch",
                cluster_idx
            )));
        }
        if cluster.point != anchor.point || cluster.domain != anchor.domain {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/verify: stage8 cluster {} anchor mismatch",
                cluster_idx
            )));
        }
        if cluster.cluster_digest != stage8_cluster_digest(&member_groups) {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/verify: stage8 cluster {} digest mismatch",
                cluster_idx
            )));
        }
        if cluster.joint_claim_digits.len() != D {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/verify: stage8 cluster {} claim digit length {} != D={D}",
                cluster_idx,
                cluster.joint_claim_digits.len()
            )));
        }
        let cluster_claim = recompose_digits_to_scalar(
            cluster.joint_claim_digits.as_slice(),
            crate::time_opening::STAGE8_TIME_DECOMP_BASE,
        );
        if cluster.joint_claim != cluster_claim {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/verify: stage8 cluster {} scalar recomposition mismatch",
                cluster_idx
            )));
        }
        if can_unify {
            if cluster.joint_commitment != unified.joint_commitment
                || cluster.joint_claim_digits != unified.joint_claim_digits
                || cluster.joint_claim != unified.joint_claim
            {
                return Err(PiCcsError::ProtocolError(
                    "time/opening joint/verify: unified stage8 cluster must mirror unified_fold".into(),
                ));
            }
            continue;
        }
        if group_indices.len() == 1 {
            let group = member_groups[0];
            if cluster.joint_commitment != group.joint_commitment
                || cluster.joint_claim_digits != group.joint_claim_digits
                || cluster.joint_claim != group.joint_claim
            {
                return Err(PiCcsError::ProtocolError(format!(
                    "time/opening joint/verify: stage8 cluster {} singleton mismatch",
                    cluster_idx
                )));
            }
            continue;
        }
        let mix_rhos = bind_and_sample_stage8_cluster_mixers(
            tr,
            params,
            step_idx,
            cluster_idx,
            &member_groups,
            opening_unification,
        )?;
        if mix_rhos.len() != member_groups.len() {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/verify: stage8 cluster {} mixer count {} != groups {}",
                cluster_idx,
                mix_rhos.len(),
                member_groups.len()
            )));
        }
        let mut expected_commitment: Option<Cmt> = None;
        let mut expected_claim_digits = vec![K::ZERO; D];
        for (rho, group) in mix_rhos.iter().zip(member_groups.iter()) {
            add_rot_scaled_commitment(&mut expected_commitment, &group.joint_commitment, rho)?;
            let rotated = apply_rot_to_digits(rho, group.joint_claim_digits.as_slice())?;
            for i in 0..D {
                expected_claim_digits[i] += rotated[i];
            }
        }
        let expected_commitment = expected_commitment.ok_or_else(|| {
            PiCcsError::ProtocolError(format!(
                "time/opening joint/verify: stage8 cluster {} missing expected commitment",
                cluster_idx
            ))
        })?;
        if cluster.joint_commitment != expected_commitment || cluster.joint_claim_digits != expected_claim_digits {
            return Err(PiCcsError::ProtocolError(format!(
                "time/opening joint/verify: stage8 cluster {} transcript mix mismatch",
                cluster_idx
            )));
        }
    }
    let mix_rhos = bind_and_sample_unified_fold_mixers(tr, params, step_idx, &lane.groups, opening_unification)?;
    if mix_rhos.len() != lane.groups.len() {
        return Err(PiCcsError::ProtocolError(format!(
            "time/opening joint/verify: unified mixer count {} != groups {}",
            mix_rhos.len(),
            lane.groups.len()
        )));
    }
    let mut expected_commitment: Option<Cmt> = None;
    let mut expected_claim_digits = vec![K::ZERO; D];
    for (rho, group) in mix_rhos.iter().zip(lane.groups.iter()) {
        add_rot_scaled_commitment(&mut expected_commitment, &group.joint_commitment, rho)?;
        let rotated = apply_rot_to_digits(rho, group.joint_claim_digits.as_slice())?;
        for i in 0..D {
            expected_claim_digits[i] += rotated[i];
        }
    }
    let expected_commitment = expected_commitment.ok_or_else(|| {
        PiCcsError::ProtocolError("time/opening joint/verify: missing expected unified commitment".into())
    })?;
    if unified.joint_commitment != expected_commitment {
        return Err(PiCcsError::ProtocolError(
            "time/opening joint/verify: unified_fold commitment mismatch".into(),
        ));
    }
    if unified.joint_claim_digits != expected_claim_digits {
        return Err(PiCcsError::ProtocolError(
            "time/opening joint/verify: unified_fold claim digits mismatch vs transcript-mixed group claims".into(),
        ));
    }

    Ok(())
}

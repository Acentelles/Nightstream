//! Auxiliary CPU and Twist value-lane folding phases.

use super::*;

pub(super) struct ValLaneFoldResult {
    pub proofs: Vec<RlcDecProof>,
    pub audits: Vec<LaneWitnessAudit<F>>,
}

#[allow(clippy::too_many_arguments)]
pub(super) fn prove_val_lane<L, MR, MB>(
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    s: &CcsStructure<F>,
    mode: &FoldingMode,
    ccs_sparse_cache: Option<&SparseCache<F>>,
    cpu_bus: &neo_memory::cpu::BusLayout,
    ring: &ccs::RotRing,
    ell_d: usize,
    k_dec: usize,
    step_idx: usize,
    claims: &[CeClaim<Cmt, F, K>],
    mcs_wit: &Mat<F>,
    prev_step: Option<&StepWitnessBundle<Cmt, F, K>>,
    collect_val_lane_wits: bool,
    val_lane_wits: &mut Vec<Mat<F>>,
    l: &L,
    mixers: CommitMixers<MR, MB>,
) -> Result<ValLaneFoldResult, PiCcsError>
where
    L: SModuleHomomorphism<F, Cmt> + Sync,
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
{
    let mut proofs = Vec::new();
    let mut audits = Vec::new();

    if claims.is_empty() {
        return Ok(ValLaneFoldResult { proofs, audits });
    }

    tr.append_message(b"fold/val_lane_start", &(step_idx as u64).to_le_bytes());
    let expected = 1usize + usize::from(prev_step.is_some());
    if claims.len() != expected {
        return Err(PiCcsError::ProtocolError(format!(
            "Twist(val) claim count mismatch (have {}, expected {})",
            claims.len(),
            expected
        )));
    }

    for (claim_idx, me) in claims.iter().enumerate() {
        let (wit, ctx) = match claim_idx {
            0 => (mcs_wit, "cpu"),
            1 => {
                let prev =
                    prev_step.ok_or_else(|| PiCcsError::ProtocolError("missing prev_step for r_val claim".into()))?;
                (&prev.mcs.1.Z, "cpu_prev")
            }
            _ => {
                return Err(PiCcsError::ProtocolError(
                    "unexpected extra r_val ME claim in shared-bus mode".into(),
                ));
            }
        };

        tr.append_message(b"fold/val_lane_claim_idx", &(claim_idx as u64).to_le_bytes());
        tr.append_message(b"fold/val_lane_claim_ctx", ctx.as_bytes());

        let input_wit = wit.clone();
        let (proof, mut z_split_val, parent_wit) = prove_rlc_dec_lane(
            mode,
            RlcLane::Val,
            tr,
            params,
            s,
            ccs_sparse_cache,
            Some(cpu_bus),
            ring,
            ell_d,
            k_dec,
            step_idx,
            None,
            core::slice::from_ref(me),
            core::slice::from_ref(&wit),
            collect_val_lane_wits,
            l,
            mixers,
        )?;
        audits.push(LaneWitnessAudit::new(vec![input_wit], parent_wit, z_split_val.clone()));
        if collect_val_lane_wits {
            val_lane_wits.extend(z_split_val.drain(..));
        }
        proofs.push(proof);
    }

    Ok(ValLaneFoldResult { proofs, audits })
}

pub(super) struct AuxCpuLaneConfig<'a> {
    pub start_label: &'static [u8],
    pub claim_idx_label: &'static [u8],
    pub lane_name: &'static str,
    pub opening_cols: &'a [usize],
    pub claims: &'a [CeClaim<Cmt, F, K>],
}

pub(super) struct AuxCpuLaneFoldResult {
    pub proofs: Vec<RlcDecProof>,
    pub audits: Vec<LaneWitnessAudit<F>>,
}

#[allow(clippy::too_many_arguments)]
pub(super) fn prove_aux_cpu_me_lane<L, MR, MB>(
    config: AuxCpuLaneConfig<'_>,
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    s: &CcsStructure<F>,
    mode: &FoldingMode,
    ccs_sparse_cache: Option<&SparseCache<F>>,
    ring: &ccs::RotRing,
    ell_d: usize,
    k_dec: usize,
    step_idx: usize,
    core_t: usize,
    input_wit: &Mat<F>,
    child_commit_dims: (usize, usize),
    collect_val_lane_wits: bool,
    val_lane_wits: &mut Vec<Mat<F>>,
    l: &L,
    mixers: CommitMixers<MR, MB>,
) -> Result<AuxCpuLaneFoldResult, PiCcsError>
where
    L: SModuleHomomorphism<F, Cmt> + Sync,
    MR: Fn(&[Mat<F>], &[Cmt]) -> Cmt + Clone + Copy,
    MB: Fn(&[Cmt], u32) -> Cmt + Clone + Copy,
{
    let AuxCpuLaneConfig {
        start_label,
        claim_idx_label,
        lane_name,
        opening_cols,
        claims,
    } = config;
    let (child_commit_d, child_commit_kappa) = child_commit_dims;
    let want_len = core_t
        .checked_add(opening_cols.len())
        .ok_or_else(|| PiCcsError::InvalidInput(format!("core_t + {lane_name}_open_cols overflow")))?;
    let y_pad = (params.d as usize).next_power_of_two();
    let mut proofs = Vec::new();
    let mut audits = Vec::new();

    tr.append_message(start_label, &(step_idx as u64).to_le_bytes());
    for (claim_idx, me) in claims.iter().enumerate() {
        let n_lane = 1usize
            .checked_shl(me.r.len() as u32)
            .ok_or_else(|| PiCcsError::InvalidInput(format!("{lane_name}-lane r dimension overflow")))?;
        let mut s_lane = s.clone();
        s_lane.n = n_lane;
        tr.append_message(claim_idx_label, &(claim_idx as u64).to_le_bytes());
        bind_rlc_inputs(tr, RlcLane::Val, step_idx, core::slice::from_ref(me))?;
        let rlc_rhos = ccs::sample_rot_rhos_n_typed(tr, params, ring, 1)?;
        let rlc_parent = ccs::rlc_public(
            &s_lane,
            params,
            &rlc_rhos,
            core::slice::from_ref(me),
            mixers.mix_rhos_commits,
            ell_d,
        )?;
        let rlc_rho_mats = ccs::rot_rhos_to_mats(&rlc_rhos);
        let (_, z_mix) = neo_reductions::optimized_engine::rlc_reduction_optimized_with_commit_mix(
            &s_lane,
            params,
            &rlc_rho_mats,
            core::slice::from_ref(me),
            &[input_wit],
            ell_d,
            mixers.mix_rhos_commits,
        );
        let k_dec_lane = core::cmp::max(k_dec, required_dec_digits_for_matrix(params, &z_mix)?);
        let materialize_lane = || -> Result<(Vec<Mat<F>>, Vec<CeClaim<Cmt, F, K>>, bool, bool, bool), PiCcsError> {
            let (dec_wits, digit_nonzero) = ccs::split_b_matrix_k_with_nonzero_flags(&z_mix, k_dec_lane, params.b)?;
            let zero_c = Cmt::zeros(child_commit_d, child_commit_kappa);
            let mut child_cs: Vec<Cmt> = vec![zero_c.clone(); dec_wits.len()];
            let nonzero_idx: Vec<usize> = digit_nonzero
                .iter()
                .enumerate()
                .filter_map(|(idx, &nz)| nz.then_some(idx))
                .collect();
            if !nonzero_idx.is_empty() {
                let mats: Vec<&Mat<F>> = nonzero_idx.iter().map(|&idx| &dec_wits[idx]).collect();
                let commits = l.commit_many(&mats);
                if commits.len() != mats.len() {
                    return Err(PiCcsError::ProtocolError(format!(
                        "{} DEC commit_many returned {} commitments for {} matrices",
                        lane_name.to_ascii_uppercase(),
                        commits.len(),
                        mats.len()
                    )));
                }
                for (pos, &idx) in nonzero_idx.iter().enumerate() {
                    child_cs[idx] = commits[pos].clone();
                }
            }
            let (dec_children, ok_y, ok_x, ok_c) = ccs::dec_children_with_commit_cached(
                mode.clone(),
                &s_lane,
                params,
                &rlc_parent,
                &dec_wits,
                ell_d,
                &child_cs,
                mixers.combine_b_pows,
                ccs_sparse_cache,
            );
            Ok((dec_wits, dec_children, ok_y, ok_x, ok_c))
        };

        let (mut dec_children, dec_wits, ok_y, ok_x, ok_c) = if !collect_val_lane_wits {
            match dec_stream_no_witness(
                params,
                &s_lane,
                &rlc_parent,
                &z_mix,
                ell_d,
                k_dec_lane,
                mixers.combine_b_pows,
                ccs_sparse_cache,
            ) {
                Ok((children, _child_cs, ok_y, ok_x, ok_c)) if ok_y && ok_x && ok_c => {
                    (children, None, ok_y, ok_x, ok_c)
                }
                Ok(_) | Err(_) => {
                    let (dec_wits, children, ok_y, ok_x, ok_c) = materialize_lane()?;
                    (children, Some(dec_wits), ok_y, ok_x, ok_c)
                }
            }
        } else {
            let (dec_wits, children, ok_y, ok_x, ok_c) = materialize_lane()?;
            (children, Some(dec_wits), ok_y, ok_x, ok_c)
        };
        if !(ok_y && ok_x && ok_c) {
            return Err(PiCcsError::ProtocolError(format!(
                "DEC({lane_name} lane) public check failed at step {} claim_idx={} (y={}, X={}, c={}, me.r.len()={}, parent.r.len()={}, s_lane.n={})",
                step_idx,
                claim_idx,
                ok_y,
                ok_x,
                ok_c,
                me.r.len(),
                rlc_parent.r.len(),
                s_lane.n
            )));
        }
        if let Some(dec_wits) = dec_wits.as_ref() {
            if dec_children.len() != dec_wits.len() {
                return Err(PiCcsError::ProtocolError(format!(
                    "step {}: {} fold requires materialized DEC witnesses (children={}, wits={})",
                    step_idx,
                    lane_name.to_ascii_uppercase(),
                    dec_children.len(),
                    dec_wits.len()
                )));
            }
        }
        if collect_val_lane_wits {
            let dec_wits = dec_wits.as_ref().ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "step {}: {} fold expected materialized DEC witnesses for witness collection",
                    step_idx,
                    lane_name.to_ascii_uppercase()
                ))
            })?;
            val_lane_wits.extend(dec_wits.iter().cloned());
        }
        if rlc_parent.y_ring.len() != want_len || rlc_parent.ct.len() != want_len {
            return Err(PiCcsError::ProtocolError(format!(
                "step {}: {} fold expects exact parent y/ct len {} (got y.len()={}, ct.len()={})",
                step_idx,
                lane_name.to_ascii_uppercase(),
                want_len,
                rlc_parent.y_ring.len(),
                rlc_parent.ct.len()
            )));
        }
        for (child_idx, child) in dec_children.iter_mut().enumerate() {
            if child.y_ring.len() < core_t || child.ct.len() < core_t {
                return Err(PiCcsError::ProtocolError(format!(
                    "step {}: {} fold expects child y/ct len >= core_t={} (got y.len()={}, ct.len()={})",
                    step_idx,
                    lane_name.to_ascii_uppercase(),
                    core_t,
                    child.y_ring.len(),
                    child.ct.len()
                )));
            }
            child.y_ring.truncate(core_t);
            child.ct.truncate(core_t);
            for open_idx in 0..opening_cols.len() {
                if child_idx == 0 {
                    child
                        .y_ring
                        .push(rlc_parent.y_ring[core_t + open_idx].clone());
                    child.ct.push(rlc_parent.ct[core_t + open_idx]);
                } else {
                    child.y_ring.push(vec![K::ZERO; y_pad]);
                    child.ct.push(K::ZERO);
                }
            }
            if child.y_ring.len() != want_len || child.ct.len() != want_len {
                return Err(PiCcsError::ProtocolError(format!(
                    "step {}: {} fold child suffix-length drift (child y/ct={}/{}, expected={})",
                    step_idx,
                    lane_name.to_ascii_uppercase(),
                    child.y_ring.len(),
                    child.ct.len(),
                    want_len
                )));
            }
        }

        let child_wits = dec_wits.clone().unwrap_or_default();
        audits.push(LaneWitnessAudit::new(vec![input_wit.clone()], z_mix, child_wits));
        proofs.push(RlcDecProof {
            rlc_rhos,
            rlc_parent,
            dec_children,
        });
    }

    Ok(AuxCpuLaneFoldResult { proofs, audits })
}

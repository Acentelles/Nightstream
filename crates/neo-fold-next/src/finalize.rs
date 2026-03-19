//! Owns the packaged proof boundary for the active main-lane path.
//!
//! Ownership:
//! - packages the verified session spine into one final proof/public statement pair
//! - binds the package with Poseidon2 digests
//! - reserves explicit slots for extension-family proofs and future time opening
//! - does not redefine `Π_CCS -> Π_RLC -> Π_DEC`

use neo_ajtai::Commitment;
use neo_ccs::{CcsClaim, CcsStructure, CeClaim, Mat};
use neo_math::{KExtensions, F, K};
use neo_params::NeoParams;
use neo_reductions::api::FoldingMode;
use neo_reductions::error::PiCcsError;
use neo_transcript::{Poseidon2Transcript, Transcript, TranscriptProtocol};

use crate::proof::{
    ExtensionFamily, FinalProof, OpeningClaim, OpeningDomain, OpeningSource, PackagedProof, PublicStatement,
    PublicStep, RunProof, SessionExtensionProofs, StepProof, TimeOpeningProofSummary,
};
use crate::prover::CommitmentMixers;
use crate::run::verify_steps;

fn extension_family_tag(family: ExtensionFamily) -> u64 {
    match family {
        ExtensionFamily::BytecodeFetch => 1,
        ExtensionFamily::InstructionSemanticsLookup => 2,
        ExtensionFamily::RegisterHistory => 3,
        ExtensionFamily::RamHistory => 4,
    }
}

fn absorb_commitment(tr: &mut Poseidon2Transcript, label: &'static [u8], c: &Commitment) {
    tr.append_message(label, b"commitment");
    tr.append_u64s(b"finalize/commitment_shape", &[c.d as u64, c.kappa as u64]);
    tr.absorb_commit_coords(&c.data);
}

fn absorb_mat_f(tr: &mut Poseidon2Transcript, label: &'static [u8], m: &Mat<F>) {
    tr.append_message(label, b"mat_f");
    tr.append_u64s(b"finalize/mat_f_shape", &[m.rows() as u64, m.cols() as u64]);
    tr.append_fields(b"finalize/mat_f_data", m.as_slice());
}

fn absorb_vec_k(tr: &mut Poseidon2Transcript, label: &'static [u8], values: &[K]) {
    tr.append_message(label, b"vec_k");
    tr.append_u64s(b"finalize/vec_k_len", &[values.len() as u64]);
    let coeffs_per_elem = values.first().map(|v| v.as_coeffs().len()).unwrap_or(0);
    tr.append_fields_iter(
        b"finalize/vec_k_data",
        values.len().saturating_mul(coeffs_per_elem),
        values.iter().flat_map(|v| v.as_coeffs()),
    );
}

fn absorb_vecvec_k(tr: &mut Poseidon2Transcript, label: &'static [u8], values: &[Vec<K>]) {
    tr.append_message(label, b"vecvec_k");
    tr.append_u64s(b"finalize/vecvec_k_len", &[values.len() as u64]);
    for row in values {
        absorb_vec_k(tr, b"finalize/vecvec_k_row", row);
    }
}

fn absorb_ccs_claim(tr: &mut Poseidon2Transcript, label: &'static [u8], claim: &CcsClaim<Commitment, F>) {
    tr.append_message(label, b"ccs_claim");
    absorb_commitment(tr, b"finalize/ccs_claim_commitment", &claim.c);
    tr.append_u64s(b"finalize/ccs_claim_meta", &[claim.m_in as u64, claim.x.len() as u64]);
    tr.append_fields(b"finalize/ccs_claim_x", &claim.x);
}

fn absorb_ce_claim(tr: &mut Poseidon2Transcript, label: &'static [u8], claim: &CeClaim<Commitment, F, K>) {
    tr.append_message(label, b"ce_claim");
    absorb_commitment(tr, b"finalize/ce_claim_commitment", &claim.c);
    absorb_mat_f(tr, b"finalize/ce_claim_X", &claim.X);
    absorb_vec_k(tr, b"finalize/ce_claim_r", &claim.r);
    absorb_vec_k(tr, b"finalize/ce_claim_s_col", &claim.s_col);
    absorb_vecvec_k(tr, b"finalize/ce_claim_y_ring", &claim.y_ring);
    absorb_vec_k(tr, b"finalize/ce_claim_ct", &claim.ct);
    absorb_vec_k(tr, b"finalize/ce_claim_aux_openings", &claim.aux_openings);
    absorb_vec_k(tr, b"finalize/ce_claim_y_zcol", &claim.y_zcol);
    tr.append_u64s(
        b"finalize/ce_claim_meta",
        &[claim.m_in as u64, claim.u_offset as u64, claim.u_len as u64],
    );
    tr.append_message(b"finalize/ce_claim_fold_digest", &claim.fold_digest);
    tr.append_fields(b"finalize/ce_claim_c_step_coords", &claim.c_step_coords);
}

fn absorb_public_step(tr: &mut Poseidon2Transcript, label: &'static [u8], step: &PublicStep) {
    tr.append_message(label, b"step_instance");
    tr.append_message(b"finalize/step_label", step.label.as_bytes());
    absorb_ccs_claim(tr, b"finalize/step_mcs", &step.mcs);
    tr.append_u64s(
        b"finalize/step_extensions_len",
        &[step.deferred_extensions.len() as u64],
    );
    for family in step.deferred_extensions.iter().copied() {
        tr.append_u64s(b"finalize/step_extension", &[extension_family_tag(family)]);
    }
}

fn absorb_pi_ccs_proof(tr: &mut Poseidon2Transcript, proof: &neo_reductions::api::PiCcsProof) {
    tr.append_message(b"finalize/pi_ccs_proof", b"split_nc_v1");
    tr.append_u64s(
        b"finalize/pi_ccs_proof_lens",
        &[
            proof.sumcheck_rounds.len() as u64,
            proof.sumcheck_challenges.len() as u64,
            proof.sumcheck_rounds_nc.len() as u64,
            proof.sumcheck_challenges_nc.len() as u64,
        ],
    );
    for round in &proof.sumcheck_rounds {
        absorb_vec_k(tr, b"finalize/pi_ccs_round", round);
    }
    absorb_vec_k(
        tr,
        b"finalize/pi_ccs_initial_sum",
        proof
            .sc_initial_sum
            .as_ref()
            .map(core::slice::from_ref)
            .unwrap_or(&[]),
    );
    absorb_vec_k(tr, b"finalize/pi_ccs_round_challenges", &proof.sumcheck_challenges);
    for round in &proof.sumcheck_rounds_nc {
        absorb_vec_k(tr, b"finalize/pi_ccs_round_nc", round);
    }
    absorb_vec_k(
        tr,
        b"finalize/pi_ccs_initial_sum_nc",
        proof
            .sc_initial_sum_nc
            .as_ref()
            .map(core::slice::from_ref)
            .unwrap_or(&[]),
    );
    absorb_vec_k(
        tr,
        b"finalize/pi_ccs_round_challenges_nc",
        &proof.sumcheck_challenges_nc,
    );
    absorb_vec_k(tr, b"finalize/pi_ccs_alpha", &proof.challenges_public.alpha);
    absorb_vec_k(tr, b"finalize/pi_ccs_beta_a", &proof.challenges_public.beta_a);
    absorb_vec_k(tr, b"finalize/pi_ccs_beta_r", &proof.challenges_public.beta_r);
    absorb_vec_k(tr, b"finalize/pi_ccs_beta_m", &proof.challenges_public.beta_m);
    absorb_vec_k(
        tr,
        b"finalize/pi_ccs_gamma",
        core::slice::from_ref(&proof.challenges_public.gamma),
    );
    absorb_vec_k(
        tr,
        b"finalize/pi_ccs_sumcheck_final",
        core::slice::from_ref(&proof.sumcheck_final),
    );
    absorb_vec_k(
        tr,
        b"finalize/pi_ccs_sumcheck_final_nc",
        core::slice::from_ref(&proof.sumcheck_final_nc),
    );
    tr.append_message(b"finalize/pi_ccs_header_digest", &proof.header_digest);
    match &proof._extra {
        Some(extra) => {
            tr.append_message(b"finalize/pi_ccs_extra_present", &[1]);
            tr.append_message(b"finalize/pi_ccs_extra", extra);
        }
        None => tr.append_message(b"finalize/pi_ccs_extra_present", &[0]),
    }
}

fn absorb_step_proof(tr: &mut Poseidon2Transcript, step: &StepProof) {
    absorb_public_step(tr, b"finalize/proof_step_instance", &step.step);
    tr.append_u64s(
        b"finalize/proof_step_claim_lens",
        &[
            step.ccs_outputs.len() as u64,
            step.rlc.rhos.len() as u64,
            step.dec.children.len() as u64,
        ],
    );
    for claim in &step.ccs_outputs {
        absorb_ce_claim(tr, b"finalize/proof_step_ccs_output", claim);
    }
    absorb_pi_ccs_proof(tr, &step.ccs_proof);
    for rho in &step.rlc.rhos {
        absorb_mat_f(tr, b"finalize/proof_step_rlc_rho", rho.as_mat());
    }
    absorb_ce_claim(tr, b"finalize/proof_step_rlc_parent", &step.rlc.parent);
    for child in &step.dec.children {
        absorb_ce_claim(tr, b"finalize/proof_step_dec_child", child);
    }
}

fn absorb_extension_summary(tr: &mut Poseidon2Transcript, extensions: &SessionExtensionProofs) {
    tr.append_message(b"finalize/extensions", b"v1");
    tr.append_u64s(
        b"finalize/extensions/header",
        &[
            extensions.bytecode_fetch.is_some() as u64,
            extensions.register_history.is_some() as u64,
            extensions.ram_history.is_some() as u64,
            extensions.opening_claims.len() as u64,
        ],
    );
    if let Some(pf) = &extensions.bytecode_fetch {
        tr.append_u64s(b"finalize/extensions/bytecode_fetch", &[pf.record_count as u64]);
        append_point(tr, b"finalize/extensions/bytecode_fetch_point", &pf.point);
        tr.append_message(b"finalize/extensions/bytecode_fetch_digest", &pf.digest);
    }
    if let Some(pf) = &extensions.register_history {
        tr.append_u64s(
            b"finalize/extensions/register_history",
            &[pf.read_count as u64, pf.write_count as u64],
        );
        append_point(tr, b"finalize/extensions/register_history_point", &pf.point);
        tr.append_message(b"finalize/extensions/register_history_digest", &pf.digest);
    }
    if let Some(pf) = &extensions.ram_history {
        tr.append_u64s(
            b"finalize/extensions/ram_history",
            &[pf.read_count as u64, pf.write_count as u64],
        );
        append_point(tr, b"finalize/extensions/ram_history_point", &pf.point);
        tr.append_message(b"finalize/extensions/ram_history_digest", &pf.digest);
    }
    for claim in &extensions.opening_claims {
        absorb_opening_claim(tr, claim);
    }
}

fn opening_source_tag(source: OpeningSource) -> u64 {
    match source {
        OpeningSource::MainLane => 1,
        OpeningSource::BytecodeFetch => 2,
        OpeningSource::RegisterHistory => 3,
        OpeningSource::RamHistory => 4,
    }
}

fn opening_domain_tag(domain: OpeningDomain) -> u64 {
    match domain {
        OpeningDomain::Cpu => 1,
        OpeningDomain::Mem => 2,
    }
}

fn absorb_opening_claim(tr: &mut Poseidon2Transcript, claim: &OpeningClaim) {
    tr.append_u64s(
        b"finalize/opening_claim_meta",
        &[
            opening_source_tag(claim.source),
            opening_domain_tag(claim.domain),
            claim.ordinal,
            claim.point.len() as u64,
            claim.column_ids.len() as u64,
        ],
    );
    append_point(tr, b"finalize/opening_claim_point", &claim.point);
    let column_ids_u64: Vec<u64> = claim.column_ids.iter().map(|&id| id as u64).collect();
    tr.append_u64s(b"finalize/opening_claim_column_ids", &column_ids_u64);
    tr.append_message(b"finalize/opening_claim_digest", &claim.digest);
}

fn absorb_time_opening(tr: &mut Poseidon2Transcript, time_opening: &Option<TimeOpeningProofSummary>) {
    match time_opening {
        Some(summary) => {
            tr.append_message(b"finalize/time_opening/present", &[1]);
            tr.append_message(b"finalize/time_opening/manifest_digest", &summary.manifest_digest);
            tr.append_message(b"finalize/time_opening/proof_digest", &summary.proof_digest);
            tr.append_u64s(
                b"finalize/time_opening/unify_meta",
                &[
                    summary.can_unify as u64,
                    opening_domain_tag(summary.unified_domain),
                    summary.unified_point.len() as u64,
                ],
            );
            append_point(tr, b"finalize/time_opening/unified_point", &summary.unified_point);
            tr.append_u64s(b"finalize/time_opening/group_count", &[summary.groups.len() as u64]);
            for group in &summary.groups {
                tr.append_u64s(
                    b"finalize/time_opening/group_meta",
                    &[
                        opening_domain_tag(group.domain),
                        group.sources.len() as u64,
                        group.claim_indices.len() as u64,
                        group.point.len() as u64,
                        group.coefficients.len() as u64,
                    ],
                );
                let source_tags: Vec<u64> = group
                    .sources
                    .iter()
                    .map(|&source| opening_source_tag(source))
                    .collect();
                tr.append_u64s(b"finalize/time_opening/group_sources", &source_tags);
                append_point(tr, b"finalize/time_opening/group_point", &group.point);
                append_k_vec(tr, b"finalize/time_opening/group_coefficients", &group.coefficients);
                let claim_indices_u64: Vec<u64> = group.claim_indices.iter().map(|&idx| idx as u64).collect();
                tr.append_u64s(b"finalize/time_opening/group_indices", &claim_indices_u64);
                tr.append_message(b"finalize/time_opening/group_digest", &group.group_digest);
                tr.append_message(b"finalize/time_opening/group_reduced_digest", &group.reduced_digest);
            }
            tr.append_message(b"finalize/time_opening/unified_digest", &summary.unified_digest);
        }
        None => tr.append_message(b"finalize/time_opening/present", &[0]),
    }
}

fn append_point(tr: &mut Poseidon2Transcript, label: &'static [u8], point: &[K]) {
    tr.append_u64s(b"finalize/point_len", &[point.len() as u64]);
    let coeffs_per_elem = point.first().map(|v| v.as_coeffs().len()).unwrap_or(0);
    tr.append_fields_iter(
        label,
        point.len().saturating_mul(coeffs_per_elem),
        point.iter().flat_map(|v| v.as_coeffs()),
    );
}

fn append_k_vec(tr: &mut Poseidon2Transcript, label: &'static [u8], values: &[K]) {
    tr.append_u64s(b"finalize/k_vec_len", &[values.len() as u64]);
    let coeffs_per_elem = values.first().map(|v| v.as_coeffs().len()).unwrap_or(0);
    tr.append_fields_iter(
        label,
        values.len().saturating_mul(coeffs_per_elem),
        values.iter().flat_map(|v| v.as_coeffs()),
    );
}

fn digest_public_statement(steps: &[PublicStep], final_main_claims: &[CeClaim<Commitment, F, K>]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/final_statement");
    tr.append_message(b"neo.fold.next/final_statement/version", b"v1");
    tr.append_u64s(
        b"neo.fold.next/final_statement/header",
        &[steps.len() as u64, final_main_claims.len() as u64],
    );
    for step in steps {
        absorb_public_step(&mut tr, b"neo.fold.next/final_statement/step", step);
    }
    for claim in final_main_claims {
        absorb_ce_claim(&mut tr, b"neo.fold.next/final_statement/final_main_claim", claim);
    }
    tr.digest32()
}

fn digest_final_proof(
    statement_digest: &[u8; 32],
    session: &RunProof,
    extensions: &SessionExtensionProofs,
    time_opening: &Option<TimeOpeningProofSummary>,
) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/final_proof");
    tr.append_message(b"neo.fold.next/final_proof/version", b"v1");
    tr.append_message(b"neo.fold.next/final_proof/statement_digest", statement_digest);
    tr.append_u64s(
        b"neo.fold.next/final_proof/header",
        &[session.steps.len() as u64, session.final_main_claims.len() as u64],
    );
    for step in &session.steps {
        absorb_step_proof(&mut tr, step);
    }
    for claim in &session.final_main_claims {
        absorb_ce_claim(&mut tr, b"neo.fold.next/final_proof/final_main_claim", claim);
    }
    absorb_extension_summary(&mut tr, extensions);
    absorb_time_opening(&mut tr, time_opening);
    tr.digest32()
}

fn validate_public_steps_against_session(steps: &[PublicStep], session: &RunProof) -> Result<(), PiCcsError> {
    if steps.len() != session.steps.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "finalizer step mismatch: public steps={}, session steps={}",
            steps.len(),
            session.steps.len()
        )));
    }
    for (idx, (step, proved)) in steps.iter().zip(session.steps.iter()).enumerate() {
        if proved.step.label != step.label
            || proved.step.deferred_extensions != step.deferred_extensions
            || proved.step.mcs.m_in != step.mcs.m_in
            || proved.step.mcs.x != step.mcs.x
            || proved.step.mcs.c != step.mcs.c
        {
            return Err(PiCcsError::InvalidInput(format!(
                "finalizer step[{idx}] public/proof mismatch for '{}'",
                step.label
            )));
        }
    }
    Ok(())
}

pub fn package_session_proof(steps: Vec<PublicStep>, session: RunProof) -> Result<PackagedProof, PiCcsError> {
    package_full_session_proof(steps, session, SessionExtensionProofs::default(), None)
}

pub fn package_full_session_proof(
    steps: Vec<PublicStep>,
    session: RunProof,
    extensions: SessionExtensionProofs,
    time_opening: Option<TimeOpeningProofSummary>,
) -> Result<PackagedProof, PiCcsError> {
    validate_public_steps_against_session(&steps, &session)?;

    let statement_digest = digest_public_statement(&steps, &session.final_main_claims);
    let proof_digest = digest_final_proof(&statement_digest, &session, &extensions, &time_opening);

    Ok(PackagedProof {
        statement: PublicStatement {
            steps,
            final_main_claims: session.final_main_claims.clone(),
            digest: statement_digest,
        },
        proof: FinalProof {
            session,
            extensions,
            time_opening,
            statement_digest,
            proof_digest,
        },
    })
}

pub fn package_proof(steps: Vec<PublicStep>, session: RunProof) -> Result<PackagedProof, PiCcsError> {
    package_session_proof(steps, session)
}

pub fn verify_finalized_session<MR, MB>(
    mode: FoldingMode,
    params: &NeoParams,
    s: &CcsStructure<F>,
    packaged: &PackagedProof,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<Vec<CeClaim<Commitment, F, K>>, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    let expected_statement_digest =
        digest_public_statement(&packaged.statement.steps, &packaged.statement.final_main_claims);
    if packaged.statement.digest != expected_statement_digest {
        return Err(PiCcsError::ProtocolError("final statement digest mismatch".into()));
    }

    validate_public_steps_against_session(&packaged.statement.steps, &packaged.proof.session)?;

    let expected_digest = digest_final_proof(
        &packaged.statement.digest,
        &packaged.proof.session,
        &packaged.proof.extensions,
        &packaged.proof.time_opening,
    );
    if packaged.proof.proof_digest != expected_digest {
        return Err(PiCcsError::ProtocolError("final proof digest mismatch".into()));
    }

    let verified = verify_steps(
        mode,
        params,
        s,
        packaged.statement.steps.clone(),
        &packaged.proof.session,
        mixers,
    )?;
    if verified != packaged.statement.final_main_claims {
        return Err(PiCcsError::ProtocolError(
            "final public statement claims do not match verified output".into(),
        ));
    }
    Ok(verified)
}

pub fn verify_packaged_proof<MR, MB>(
    mode: FoldingMode,
    params: &NeoParams,
    s: &CcsStructure<F>,
    packaged: &PackagedProof,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<Vec<CeClaim<Commitment, F, K>>, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    verify_finalized_session(mode, params, s, packaged, mixers)
}

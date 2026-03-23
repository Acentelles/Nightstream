//! Owns the packaged proof boundary for the active main-lane path.
//!
//! Ownership:
//! - packages the verified session spine into one final proof/public statement pair
//! - binds the package with Poseidon2 digests
//! - does not redefine `Π_CCS -> Π_RLC -> Π_DEC`

use neo_ajtai::Commitment;
use neo_ccs::{CcsClaim, CcsStructure, CeClaim, Mat};
use neo_math::{KExtensions, F, K};
use neo_params::NeoParams;
use neo_reductions::api::FoldingMode;
use neo_reductions::error::PiCcsError;
use neo_transcript::{Poseidon2Transcript, Transcript, TranscriptProtocol};

use crate::proof::{FinalProof, PackagedProof, PublicStatement, PublicStep, RunProof, StepProof};
use crate::prover::CommitmentMixers;
use crate::run::verify_steps;

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

fn absorb_ce_claim_ref(tr: &mut Poseidon2Transcript, label: &'static [u8], claim: &CeClaim<Commitment, F, K>) {
    tr.append_message(label, b"ce_claim_ref");
    tr.append_message(b"finalize/ce_claim_ref_fold_digest", &claim.fold_digest);
    tr.append_u64s(
        b"finalize/ce_claim_ref_meta",
        &[claim.m_in as u64, claim.u_offset as u64, claim.u_len as u64],
    );
}

fn absorb_public_step(tr: &mut Poseidon2Transcript, label: &'static [u8], step: &PublicStep) {
    tr.append_message(label, b"step_instance");
    tr.append_message(b"finalize/step_label", step.label.as_bytes());
    absorb_ccs_claim(tr, b"finalize/step_mcs", &step.mcs);
}

fn absorb_step_proof_compact(tr: &mut Poseidon2Transcript, step: &StepProof) {
    tr.append_message(b"finalize/proof_step", b"compact_v1");
    tr.append_u64s(
        b"finalize/proof_step_claim_lens",
        &[
            step.ccs_outputs.len() as u64,
            step.rlc.rhos.len() as u64,
            step.dec.children.len() as u64,
        ],
    );
    tr.append_message(b"finalize/proof_step_ccs_header_digest", &step.ccs_proof.header_digest);
    absorb_ce_claim_ref(tr, b"finalize/proof_step_rlc_parent", &step.rlc.parent);
    for child in &step.dec.children {
        absorb_ce_claim_ref(tr, b"finalize/proof_step_dec_child", child);
    }
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

fn digest_final_proof(statement_digest: &[u8; 32], session: &RunProof) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/final_proof");
    tr.append_message(b"neo.fold.next/final_proof/version", b"v3");
    tr.append_message(b"neo.fold.next/final_proof/statement_digest", statement_digest);
    tr.append_u64s(
        b"neo.fold.next/final_proof/header",
        &[session.steps.len() as u64, session.final_main_claims.len() as u64],
    );
    for step in &session.steps {
        absorb_step_proof_compact(&mut tr, step);
    }
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
    validate_public_steps_against_session(&steps, &session)?;

    let statement_digest = digest_public_statement(&steps, &session.final_main_claims);
    let proof_digest = digest_final_proof(&statement_digest, &session);

    Ok(PackagedProof {
        statement: PublicStatement {
            steps,
            final_main_claims: session.final_main_claims.clone(),
            digest: statement_digest,
        },
        proof: FinalProof {
            session,
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

    let expected_digest = digest_final_proof(&packaged.statement.digest, &packaged.proof.session);
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

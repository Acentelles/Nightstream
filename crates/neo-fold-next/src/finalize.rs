//! Owns the packaged proof boundary for the active main-lane path.
//!
//! Ownership:
//! - packages the verified session spine into one final proof/public statement pair
//! - binds the package with Poseidon2 digests
//! - does not redefine `Π_CCS -> Π_RLC -> Π_DEC`

use neo_ajtai::Commitment;
use neo_ccs::{CcsClaim, CcsStructure, CeClaim, Mat};
use neo_math::{F, K};
use neo_params::NeoParams;
use neo_reductions::api::FoldingMode;
use neo_reductions::engines::utils::me_digest_poseidon;
use neo_reductions::error::PiCcsError;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use crate::proof::{FinalProof, PackagedProof, PublicStatement, PublicStep, RunProof, StepProof};
use crate::prover::CommitmentMixers;
use crate::run::verify_steps;

#[inline]
fn extend_packed_bytes_as_fields(dst: &mut Vec<F>, bytes: &[u8]) {
    const BYTES_PER_LIMB: usize = 7;
    dst.push(F::from_u64(bytes.len() as u64));
    for chunk in bytes.chunks(BYTES_PER_LIMB) {
        let mut limb = [0u8; 8];
        limb[..chunk.len()].copy_from_slice(chunk);
        dst.push(F::from_u64(u64::from_le_bytes(limb)));
    }
}

#[inline]
fn poseidon_digest_fields(input: &[F]) -> [F; 4] {
    neo_ccs::crypto::poseidon2_goldilocks::poseidon2_hash(input)
}

fn ccs_claim_digest_fields(claim: &CcsClaim<Commitment, F>) -> [F; 4] {
    let mut digest_input = Vec::<F>::with_capacity(256);
    extend_packed_bytes_as_fields(&mut digest_input, b"neo.fold.next/finalize/ccs_claim_digest/v1");
    digest_input.push(F::from_u64(claim.c.d as u64));
    digest_input.push(F::from_u64(claim.c.kappa as u64));
    digest_input.push(F::from_u64(claim.c.data.len() as u64));
    digest_input.extend_from_slice(&claim.c.data);
    digest_input.push(F::from_u64(claim.x.len() as u64));
    digest_input.extend_from_slice(&claim.x);
    digest_input.push(F::from_u64(claim.m_in as u64));
    poseidon_digest_fields(&digest_input)
}

fn public_step_digest_fields(step: &PublicStep) -> [F; 4] {
    let mut digest_input = Vec::<F>::with_capacity(96);
    extend_packed_bytes_as_fields(&mut digest_input, b"neo.fold.next/finalize/public_step_digest/v1");
    extend_packed_bytes_as_fields(&mut digest_input, step.label.as_bytes());
    digest_input.extend_from_slice(&ccs_claim_digest_fields(&step.mcs));
    poseidon_digest_fields(&digest_input)
}

fn ce_claim_ref_digest_fields(claim: &CeClaim<Commitment, F, K>) -> [F; 4] {
    let mut digest_input = Vec::<F>::with_capacity(32);
    extend_packed_bytes_as_fields(&mut digest_input, b"neo.fold.next/finalize/ce_claim_ref_digest/v1");
    extend_packed_bytes_as_fields(&mut digest_input, &claim.fold_digest);
    digest_input.push(F::from_u64(claim.m_in as u64));
    digest_input.push(F::from_u64(claim.u_offset as u64));
    digest_input.push(F::from_u64(claim.u_len as u64));
    poseidon_digest_fields(&digest_input)
}

fn step_proof_compact_digest_fields(step: &StepProof) -> [F; 4] {
    let mut digest_input = Vec::<F>::with_capacity(96);
    extend_packed_bytes_as_fields(
        &mut digest_input,
        b"neo.fold.next/finalize/step_proof_compact_digest/v1",
    );
    digest_input.push(F::from_u64(step.ccs_outputs.len() as u64));
    digest_input.push(F::from_u64(step.rlc.rhos.len() as u64));
    digest_input.push(F::from_u64(step.dec.children.len() as u64));
    extend_packed_bytes_as_fields(&mut digest_input, &step.ccs_proof.header_digest);
    digest_input.extend_from_slice(&ce_claim_ref_digest_fields(&step.rlc.parent));
    for child in &step.dec.children {
        digest_input.extend_from_slice(&ce_claim_ref_digest_fields(child));
    }
    poseidon_digest_fields(&digest_input)
}

fn digest_public_statement(steps: &[PublicStep], final_main_claims: &[CeClaim<Commitment, F, K>]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/final_statement");
    tr.append_message(b"neo.fold.next/final_statement/version", b"v1");
    tr.append_u64s(
        b"neo.fold.next/final_statement/header",
        &[steps.len() as u64, final_main_claims.len() as u64],
    );
    tr.append_fields_iter(
        b"neo.fold.next/final_statement/step_digest",
        steps.len() * 4,
        steps
            .iter()
            .flat_map(|step| public_step_digest_fields(step)),
    );
    tr.append_fields_iter(
        b"neo.fold.next/final_statement/final_main_claim_digest",
        final_main_claims.len() * 4,
        final_main_claims
            .iter()
            .flat_map(|claim| me_digest_poseidon(claim)),
    );
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
    tr.append_fields_iter(
        b"neo.fold.next/final_proof/step_digest",
        session.steps.len() * 4,
        session
            .steps
            .iter()
            .flat_map(|step| step_proof_compact_digest_fields(step)),
    );
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

    let expected_digest = digest_final_proof(&packaged.statement.digest, &packaged.proof.session);
    if packaged.proof.proof_digest != expected_digest {
        return Err(PiCcsError::ProtocolError("final proof digest mismatch".into()));
    }

    let verified = verify_steps(
        mode,
        params,
        s,
        &packaged.statement.steps,
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

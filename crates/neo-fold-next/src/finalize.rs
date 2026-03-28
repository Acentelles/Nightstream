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

use crate::proof::{
    ChunkProof, FinalProof, FoldSchedule, PackagedProof, PublicChunk, PublicStatement, PublicStep, RunProof,
};
use crate::prover::CommitmentMixers;
use crate::run::verify_chunks;

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

fn append_fold_schedule_meta(tr: &mut Poseidon2Transcript, label: &'static [u8], schedule: FoldSchedule) {
    tr.append_u64s(label, &schedule.meta_words());
}

fn public_chunk_digest_fields(chunk: &PublicChunk) -> [F; 4] {
    let mut digest_input = Vec::<F>::with_capacity(32 + (chunk.steps.len() * 4));
    extend_packed_bytes_as_fields(&mut digest_input, b"neo.fold.next/finalize/public_chunk_digest/v1");
    digest_input.push(F::from_u64(chunk.start_index as u64));
    digest_input.push(F::from_u64(chunk.steps.len() as u64));
    for step in &chunk.steps {
        digest_input.extend_from_slice(&public_step_digest_fields(step));
    }
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

fn chunk_proof_compact_digest_fields(chunk: &ChunkProof) -> [F; 4] {
    let mut digest_input = Vec::<F>::with_capacity(128 + (chunk.chunk.steps.len() * 4));
    extend_packed_bytes_as_fields(
        &mut digest_input,
        b"neo.fold.next/finalize/chunk_proof_compact_digest/v1",
    );
    digest_input.extend_from_slice(&public_chunk_digest_fields(&chunk.chunk));
    digest_input.push(F::from_u64(chunk.ccs_outputs.len() as u64));
    digest_input.push(F::from_u64(chunk.rlc.rhos.len() as u64));
    digest_input.push(F::from_u64(chunk.dec.children.len() as u64));
    extend_packed_bytes_as_fields(&mut digest_input, &chunk.ccs_proof.header_digest);
    digest_input.extend_from_slice(&ce_claim_ref_digest_fields(&chunk.rlc.parent));
    for child in &chunk.dec.children {
        digest_input.extend_from_slice(&ce_claim_ref_digest_fields(child));
    }
    poseidon_digest_fields(&digest_input)
}

fn digest_public_statement(
    schedule: FoldSchedule,
    chunks: &[PublicChunk],
    final_main_claims: &[CeClaim<Commitment, F, K>],
) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/final_statement");
    tr.append_message(b"neo.fold.next/final_statement/version", b"v2");
    append_fold_schedule_meta(&mut tr, b"neo.fold.next/final_statement/fold_schedule", schedule);
    tr.append_u64s(
        b"neo.fold.next/final_statement/header",
        &[chunks.len() as u64, final_main_claims.len() as u64],
    );
    tr.append_fields_iter(
        b"neo.fold.next/final_statement/chunk_digest",
        chunks.len() * 4,
        chunks.iter().flat_map(public_chunk_digest_fields),
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
    tr.append_message(b"neo.fold.next/final_proof/version", b"v4");
    tr.append_message(b"neo.fold.next/final_proof/statement_digest", statement_digest);
    append_fold_schedule_meta(
        &mut tr,
        b"neo.fold.next/final_proof/fold_schedule",
        session.fold_schedule,
    );
    tr.append_u64s(
        b"neo.fold.next/final_proof/header",
        &[session.chunks.len() as u64, session.final_main_claims.len() as u64],
    );
    tr.append_fields_iter(
        b"neo.fold.next/final_proof/chunk_digest",
        session.chunks.len() * 4,
        session
            .chunks
            .iter()
            .flat_map(chunk_proof_compact_digest_fields),
    );
    tr.digest32()
}

fn validate_public_chunks_against_session(chunks: &[PublicChunk], session: &RunProof) -> Result<(), PiCcsError> {
    if chunks.len() != session.chunks.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "finalizer chunk mismatch: public chunks={}, session chunks={}",
            chunks.len(),
            session.chunks.len()
        )));
    }
    for (chunk_idx, (chunk, proved)) in chunks.iter().zip(session.chunks.iter()).enumerate() {
        if chunk.start_index != proved.chunk.start_index {
            return Err(PiCcsError::InvalidInput(format!(
                "finalizer chunk[{chunk_idx}] start mismatch: {} != {}",
                chunk.start_index, proved.chunk.start_index
            )));
        }
        if chunk.steps.len() != proved.chunk.steps.len() {
            return Err(PiCcsError::InvalidInput(format!(
                "finalizer chunk[{chunk_idx}] length mismatch: {} != {}",
                chunk.steps.len(),
                proved.chunk.steps.len()
            )));
        }
        for (step_idx, (step, proved_step)) in chunk
            .steps
            .iter()
            .zip(proved.chunk.steps.iter())
            .enumerate()
        {
            if proved_step.label != step.label
                || proved_step.mcs.m_in != step.mcs.m_in
                || proved_step.mcs.x != step.mcs.x
                || proved_step.mcs.c != step.mcs.c
            {
                return Err(PiCcsError::InvalidInput(format!(
                    "finalizer chunk[{chunk_idx}] step[{step_idx}] public/proof mismatch for '{}'",
                    step.label
                )));
            }
        }
    }
    Ok(())
}

fn validate_chunk_schedule(
    schedule: FoldSchedule,
    chunk_count: usize,
    public_step_count: usize,
) -> Result<(), PiCcsError> {
    let expected = schedule.chunk_count(public_step_count)?;
    if expected != chunk_count {
        return Err(PiCcsError::InvalidInput(format!(
            "chunk count {} does not match {:?} for {} public steps",
            chunk_count, schedule, public_step_count
        )));
    }
    Ok(())
}

pub fn package_session_proof(chunks: Vec<PublicChunk>, session: RunProof) -> Result<PackagedProof, PiCcsError> {
    validate_public_chunks_against_session(&chunks, &session)?;
    let public_step_count = chunks.iter().map(|chunk| chunk.steps.len()).sum();
    validate_chunk_schedule(session.fold_schedule, chunks.len(), public_step_count)?;

    let statement_digest = digest_public_statement(session.fold_schedule, &chunks, &session.final_main_claims);
    let proof_digest = digest_final_proof(&statement_digest, &session);

    Ok(PackagedProof {
        statement: PublicStatement {
            fold_schedule: session.fold_schedule,
            chunk_count: chunks.len() as u64,
            chunks,
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

pub fn package_proof(chunks: Vec<PublicChunk>, session: RunProof) -> Result<PackagedProof, PiCcsError> {
    package_session_proof(chunks, session)
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
    let expected_statement_digest = digest_public_statement(
        packaged.statement.fold_schedule,
        &packaged.statement.chunks,
        &packaged.statement.final_main_claims,
    );
    if packaged.statement.digest != expected_statement_digest {
        return Err(PiCcsError::ProtocolError("final statement digest mismatch".into()));
    }
    let public_step_count = packaged
        .statement
        .chunks
        .iter()
        .map(|chunk| chunk.steps.len())
        .sum();
    if packaged.statement.chunk_count as usize != packaged.statement.chunks.len() {
        return Err(PiCcsError::ProtocolError(
            "final statement chunk_count does not match chunk list".into(),
        ));
    }
    validate_chunk_schedule(
        packaged.statement.fold_schedule,
        packaged.statement.chunks.len(),
        public_step_count,
    )?;
    if packaged.proof.session.fold_schedule != packaged.statement.fold_schedule {
        return Err(PiCcsError::ProtocolError(
            "final proof schedule does not match public statement schedule".into(),
        ));
    }

    let expected_digest = digest_final_proof(&packaged.statement.digest, &packaged.proof.session);
    if packaged.proof.proof_digest != expected_digest {
        return Err(PiCcsError::ProtocolError("final proof digest mismatch".into()));
    }

    let verified = verify_chunks(
        mode,
        params,
        s,
        &packaged.statement.chunks,
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

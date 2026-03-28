//! Owns the run-level SuperNeo driver.
//!
//! This layer threads the main carry and transcript across prepared steps.

use neo_ajtai::Commitment;
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{CcsStructure, CeClaim, Mat};
use neo_math::{F, K};
use neo_params::NeoParams;
use neo_reductions::api::FoldingMode;
use neo_reductions::error::PiCcsError;
use neo_reductions::optimized_engine::OptimizedStructureCache;
use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::finalize::{package_session_proof, verify_finalized_session};
use crate::proof::{
    partition_public_steps, partition_step_inputs, Carry, ChunkInput, FoldSchedule, PackagedProof, PublicChunk,
    PublicStep, RunProof, StepInput,
};
use crate::prover::{CommitmentMixers, ShardProver};
use crate::verifier::ShardVerifier;

pub fn prove_chunks<L, MR, MB>(
    mode: FoldingMode,
    schedule: FoldSchedule,
    params: &NeoParams,
    s: &CcsStructure<F>,
    chunks: impl IntoIterator<Item = ChunkInput>,
    log: &L,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<RunProof, PiCcsError>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    schedule.validate()?;
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/session");
    let mut main_carry = Carry::default();
    let mut session = RunProof {
        fold_schedule: schedule,
        ..RunProof::default()
    };
    let optimized_cache = if matches!(mode, FoldingMode::Optimized) {
        Some(OptimizedStructureCache::build(s)?)
    } else {
        None
    };

    for chunk in chunks {
        let proved = ShardProver::prove_chunk(
            mode.clone(),
            &mut tr,
            params,
            s,
            &chunk,
            &main_carry,
            log,
            mixers,
            optimized_cache.as_ref(),
        )?;
        main_carry = proved.next_main;
        session.chunks.push(proved.proof);
        tr.append_message(b"neo.fold.next/chunk_done", &[1]);
    }

    validate_chunk_layout(
        schedule,
        &session
            .chunks
            .iter()
            .map(|chunk| chunk.chunk.clone())
            .collect::<Vec<_>>(),
    )?;
    session.final_main_claims = main_carry.claims;
    Ok(session)
}

pub fn verify_chunks<MR, MB>(
    mode: FoldingMode,
    params: &NeoParams,
    s: &CcsStructure<F>,
    chunks: &[PublicChunk],
    proof: &RunProof,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<Vec<CeClaim<Commitment, F, K>>, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/session");
    let mut main_carry: &[CeClaim<Commitment, F, K>] = &[];
    let optimized_cache = if matches!(mode, FoldingMode::Optimized) {
        Some(OptimizedStructureCache::build(s)?)
    } else {
        None
    };

    validate_chunk_layout(proof.fold_schedule, chunks)?;

    for (idx, chunk_proof) in proof.chunks.iter().enumerate() {
        let chunk = chunks
            .get(idx)
            .ok_or_else(|| PiCcsError::InvalidInput(format!("missing public chunk {idx} during verification")))?;
        main_carry = ShardVerifier::verify_chunk(
            mode.clone(),
            &mut tr,
            params,
            s,
            chunk,
            &main_carry,
            chunk_proof,
            mixers,
            optimized_cache.as_ref(),
        )?;
        tr.append_message(b"neo.fold.next/chunk_done", &[1]);
    }
    if chunks.len() != proof.chunks.len() {
        return Err(PiCcsError::InvalidInput(
            "public chunk list is longer than proof chunk list".into(),
        ));
    }
    if main_carry != proof.final_main_claims.as_slice() {
        return Err(PiCcsError::ProtocolError(
            "final carried main claims do not match proof footer".into(),
        ));
    }
    Ok(proof.final_main_claims.clone())
}

pub fn prove_run<L, MR, MB>(
    mode: FoldingMode,
    schedule: FoldSchedule,
    params: &NeoParams,
    s: &CcsStructure<F>,
    steps: impl IntoIterator<Item = StepInput>,
    log: &L,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<RunProof, PiCcsError>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    let steps_vec: Vec<StepInput> = steps.into_iter().collect();
    let chunks = partition_step_inputs(schedule, steps_vec)?;
    prove_chunks(mode, schedule, params, s, chunks, log, mixers)
}

pub fn verify_run<MR, MB>(
    mode: FoldingMode,
    params: &NeoParams,
    s: &CcsStructure<F>,
    steps: &[PublicStep],
    proof: &RunProof,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<Vec<CeClaim<Commitment, F, K>>, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    let chunks = partition_public_steps(proof.fold_schedule, steps.to_vec())?;
    verify_chunks(mode, params, s, &chunks, proof, mixers)
}

pub fn prove_and_package<L, MR, MB>(
    mode: FoldingMode,
    schedule: FoldSchedule,
    params: &NeoParams,
    s: &CcsStructure<F>,
    steps: impl IntoIterator<Item = StepInput>,
    log: &L,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<PackagedProof, PiCcsError>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    let steps_vec: Vec<StepInput> = steps.into_iter().collect();
    let public_chunks = partition_public_steps(schedule, steps_vec.iter().map(StepInput::instance).collect())?;
    let input_chunks = partition_step_inputs(schedule, steps_vec)?;
    let session = prove_chunks(mode, schedule, params, s, input_chunks, log, mixers)?;
    package_session_proof(public_chunks, session)
}

pub fn verify_packaged<MR, MB>(
    mode: FoldingMode,
    params: &NeoParams,
    s: &CcsStructure<F>,
    proof: &PackagedProof,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<Vec<CeClaim<Commitment, F, K>>, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    verify_finalized_session(mode, params, s, proof, mixers)
}

fn validate_chunk_layout(schedule: FoldSchedule, chunks: &[PublicChunk]) -> Result<(), PiCcsError> {
    schedule.validate()?;
    let mut next_start = 0usize;
    let row_cap = match schedule {
        FoldSchedule::WholeTrace => None,
        FoldSchedule::RowsPerChunk(rows) => Some(rows),
    };

    for (idx, chunk) in chunks.iter().enumerate() {
        if chunk.steps.is_empty() {
            return Err(PiCcsError::InvalidInput(format!("chunk[{idx}] is empty")));
        }
        if chunk.start_index != next_start {
            return Err(PiCcsError::InvalidInput(format!(
                "chunk[{idx}] starts at {}, expected {}",
                chunk.start_index, next_start
            )));
        }
        if let Some(rows_per_chunk) = row_cap {
            if chunk.steps.len() > rows_per_chunk {
                return Err(PiCcsError::InvalidInput(format!(
                    "chunk[{idx}] has {} steps, exceeds RowsPerChunk({rows_per_chunk})",
                    chunk.steps.len()
                )));
            }
            if idx + 1 != chunks.len() && chunk.steps.len() != rows_per_chunk {
                return Err(PiCcsError::InvalidInput(format!(
                    "chunk[{idx}] has {} steps, expected exactly {} before the final chunk",
                    chunk.steps.len(),
                    rows_per_chunk
                )));
            }
        }
        next_start += chunk.steps.len();
    }

    if matches!(schedule, FoldSchedule::WholeTrace) && chunks.len() > 1 {
        return Err(PiCcsError::InvalidInput(
            "WholeTrace schedule must carry exactly one chunk".into(),
        ));
    }
    if schedule.chunk_count(next_start)? != chunks.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "chunk count {} does not match {:?} for {} steps",
            chunks.len(),
            schedule,
            next_start
        )));
    }
    Ok(())
}

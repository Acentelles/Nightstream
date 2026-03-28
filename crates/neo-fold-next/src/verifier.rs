//! Owns the explicit SuperNeo shard verify script.
//!
//! This mirrors the real `Π_CCS -> Π_RLC -> Π_DEC` spine.

use neo_ajtai::Commitment;
use neo_ccs::CcsStructure;
use neo_math::{F, K};
use neo_params::NeoParams;
use neo_reductions::api::{
    rlc_public_matches, sample_rot_rhos_n_typed, verify, verify_dec_public, FoldingMode, RotRing,
};
use neo_reductions::engines::utils;
use neo_reductions::error::PiCcsError;
use neo_reductions::optimized_engine::{optimized_verify_with_cache_and_perf, OptimizedStructureCache};
use neo_transcript::{Poseidon2Transcript, Transcript};
use std::time::Instant;

use crate::proof::{ChunkProof, ChunkVerifyPerf, PublicChunk};
use crate::prover::CommitmentMixers;

pub struct ShardVerifier;

impl ShardVerifier {
    pub fn verify_chunk<'a, MR, MB>(
        mode: FoldingMode,
        tr: &mut Poseidon2Transcript,
        params: &NeoParams,
        s: &CcsStructure<F>,
        chunk: &PublicChunk,
        incoming_main: &[neo_ccs::CeClaim<Commitment, F, K>],
        proof: &'a ChunkProof,
        mixers: CommitmentMixers<MR, MB>,
        optimized_cache: Option<&OptimizedStructureCache>,
    ) -> Result<&'a [neo_ccs::CeClaim<Commitment, F, K>], PiCcsError>
    where
        MR: Fn(&[neo_ccs::Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
        MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
    {
        Ok(Self::verify_chunk_with_perf(
            mode,
            tr,
            params,
            s,
            chunk,
            incoming_main,
            proof,
            mixers,
            optimized_cache,
        )?
        .0)
    }

    pub fn verify_chunk_with_perf<'a, MR, MB>(
        mode: FoldingMode,
        tr: &mut Poseidon2Transcript,
        params: &NeoParams,
        s: &CcsStructure<F>,
        chunk: &PublicChunk,
        incoming_main: &[neo_ccs::CeClaim<Commitment, F, K>],
        proof: &'a ChunkProof,
        mixers: CommitmentMixers<MR, MB>,
        optimized_cache: Option<&OptimizedStructureCache>,
    ) -> Result<(&'a [neo_ccs::CeClaim<Commitment, F, K>], ChunkVerifyPerf), PiCcsError>
    where
        MR: Fn(&[neo_ccs::Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
        MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
    {
        let total_started = Instant::now();
        validate_chunk_metadata(chunk, proof)?;
        append_chunk_transcript(tr, chunk);

        let prepare_inputs_started = Instant::now();
        let fresh_claims = chunk
            .steps
            .iter()
            .map(|step| step.mcs.clone())
            .collect::<Vec<_>>();
        let prepare_inputs_ms = prepare_inputs_started.elapsed().as_secs_f64() * 1_000.0;

        let ccs_started = Instant::now();
        let (ok_ccs, ccs_perf) = if matches!(mode, FoldingMode::Optimized) {
            let cache = optimized_cache.ok_or_else(|| {
                PiCcsError::InvalidInput("missing optimized structure cache for optimized verify_chunk".into())
            })?;
            optimized_verify_with_cache_and_perf(
                tr,
                params,
                s,
                &fresh_claims,
                incoming_main,
                &proof.ccs_outputs,
                &proof.ccs_proof,
                cache,
            )?
        } else {
            (
                verify(
                    mode,
                    tr,
                    params,
                    s,
                    &fresh_claims,
                    incoming_main,
                    &proof.ccs_outputs,
                    &proof.ccs_proof,
                )?,
                neo_reductions::optimized_engine::PiCcsVerifyPerf::default(),
            )
        };
        let ccs_ms = ccs_started.elapsed().as_secs_f64() * 1_000.0;
        if !ok_ccs {
            return Err(PiCcsError::ProtocolError(format!(
                "Π_CCS verification failed for chunk starting at {}",
                chunk.start_index
            )));
        }

        let digest_checks_started = Instant::now();
        let observed_digest = tr.digest32();
        if proof.ccs_proof.header_digest.as_slice() != observed_digest {
            return Err(PiCcsError::ProtocolError(format!(
                "Π_CCS header digest mismatch for chunk starting at {}",
                chunk.start_index
            )));
        }
        for (idx, out) in proof.ccs_outputs.iter().enumerate() {
            if out.fold_digest != observed_digest {
                return Err(PiCcsError::ProtocolError(format!(
                    "Π_CCS output[{idx}] fold_digest mismatch for chunk starting at {}",
                    chunk.start_index
                )));
            }
        }
        let digest_checks_ms = digest_checks_started.elapsed().as_secs_f64() * 1_000.0;

        let dims_started = Instant::now();
        let dims = utils::build_dims_and_policy(params, s)?;
        let dims_ms = dims_started.elapsed().as_secs_f64() * 1_000.0;
        let rlc_challenge_started = Instant::now();
        let expected_rhos = sample_rlc_rhos(tr, params, proof.ccs_outputs.len())?;
        let rlc_challenge_ms = rlc_challenge_started.elapsed().as_secs_f64() * 1_000.0;
        if expected_rhos != proof.rlc.rhos {
            return Err(PiCcsError::ProtocolError(format!(
                "Π_RLC challenge mismatch for chunk starting at {}",
                chunk.start_index
            )));
        }

        let rlc_started = Instant::now();
        let parent_matches = rlc_public_matches(
            s,
            params,
            &proof.rlc.rhos,
            &proof.ccs_outputs,
            &proof.rlc.parent,
            mixers.mix_rhos_commits,
            dims.ell_d,
        )?;
        if !parent_matches {
            return Err(PiCcsError::ProtocolError(format!(
                "Π_RLC public recompute mismatch for chunk starting at {}",
                chunk.start_index
            )));
        }
        let rlc_ms = rlc_started.elapsed().as_secs_f64() * 1_000.0;

        let dec_started = Instant::now();
        if !verify_dec_public(
            s,
            params,
            &proof.rlc.parent,
            &proof.dec.children,
            mixers.combine_b_pows,
            dims.ell_d,
        ) {
            return Err(PiCcsError::ProtocolError(format!(
                "Π_DEC public verification failed for chunk starting at {}",
                chunk.start_index
            )));
        }
        let dec_ms = dec_started.elapsed().as_secs_f64() * 1_000.0;

        let perf = ChunkVerifyPerf {
            start_index: chunk.start_index,
            fresh_steps: chunk.steps.len(),
            incoming_main_claims: incoming_main.len(),
            ccs_outputs: proof.ccs_outputs.len(),
            dec_children: proof.dec.children.len(),
            prepare_inputs_ms,
            ccs_bind_ms: ccs_perf.bind_ms,
            ccs_fe_sumcheck_ms: ccs_perf.fe_sumcheck_ms,
            ccs_nc_sumcheck_ms: ccs_perf.nc_sumcheck_ms,
            ccs_output_checks_ms: ccs_perf.output_checks_ms,
            ccs_terminal_ms: ccs_perf.terminal_ms,
            ccs_ms,
            digest_checks_ms,
            dims_ms,
            rlc_challenge_ms,
            rlc_ms,
            dec_ms,
            total_ms: total_started.elapsed().as_secs_f64() * 1_000.0,
        };

        Ok((&proof.dec.children, perf))
    }
}

fn append_chunk_transcript(tr: &mut Poseidon2Transcript, chunk: &PublicChunk) {
    if chunk.steps.len() == 1 {
        tr.append_u64s(b"neo.fold.next/step_index", &[chunk.start_index as u64]);
        return;
    }

    tr.append_u64s(
        b"neo.fold.next/chunk_meta",
        &[chunk.start_index as u64, chunk.steps.len() as u64],
    );
}

fn validate_chunk_metadata(chunk: &PublicChunk, proof: &ChunkProof) -> Result<(), PiCcsError> {
    if proof.chunk.start_index != chunk.start_index {
        return Err(PiCcsError::InvalidInput(format!(
            "proof chunk start mismatch: expected {}, got {}",
            chunk.start_index, proof.chunk.start_index
        )));
    }
    if proof.chunk.steps.len() != chunk.steps.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "proof chunk length mismatch: expected {}, got {}",
            chunk.steps.len(),
            proof.chunk.steps.len()
        )));
    }
    for (idx, (expected, actual)) in chunk.steps.iter().zip(proof.chunk.steps.iter()).enumerate() {
        if actual.label != expected.label {
            return Err(PiCcsError::InvalidInput(format!(
                "proof chunk step[{idx}] label mismatch: expected '{}', got '{}'",
                expected.label, actual.label
            )));
        }
        if actual.mcs.m_in != expected.mcs.m_in || actual.mcs.x != expected.mcs.x || actual.mcs.c != expected.mcs.c {
            return Err(PiCcsError::InvalidInput(format!(
                "public MCS mismatch for chunk step[{}] '{}'",
                idx, expected.label
            )));
        }
    }
    if proof.ccs_outputs.is_empty() {
        return Err(PiCcsError::InvalidInput("missing Π_CCS outputs for chunk".into()));
    }
    Ok(())
}

fn sample_rlc_rhos(
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    input_count: usize,
) -> Result<Vec<neo_reductions::api::RotRho>, PiCcsError> {
    let ring = RotRing::goldilocks();
    sample_rot_rhos_n_typed(tr, params, &ring, input_count)
}

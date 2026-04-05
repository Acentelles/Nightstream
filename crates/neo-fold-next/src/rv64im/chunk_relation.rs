//! Owns the RV64IM per-chunk replay surface above the verified export seam.

use neo_ajtai::AjtaiSModule;
use neo_ccs::CcsStructure;
use neo_math::{KExtensions, F, K};
use neo_reductions::api::FoldingMode;
use neo_reductions::engines::utils::me_digest_poseidon_into;
use neo_reductions::optimized_engine::OptimizedStructureCache;
use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::chunk_relation::{compute_chunk_relation_with_perf, verify_chunk_relation_with_witness, ChunkReplayWitness};
use crate::finalize::fixed_shape_recursive_step_handle;
use crate::proof::{Carry, PublicChunk};
use crate::rv64im::kernel::{
    rv64im_ajtai_mixers, rv64im_public_chunk_digest, Rv64imVerifiedKernelChunkHandoff, SimpleKernelError,
};

pub(crate) fn prove_rv64im_chunk_transition(
    chunk_index: usize,
    handoff: &Rv64imVerifiedKernelChunkHandoff,
    incoming_main: &Carry,
    transcript: &mut Poseidon2Transcript,
    params: &neo_params::NeoParams,
    structure: &CcsStructure<F>,
    log: &AjtaiSModule,
    optimized_cache: &OptimizedStructureCache,
) -> Result<(ChunkReplayWitness, Carry, [u8; 32]), SimpleKernelError> {
    let (computation, _perf) = compute_chunk_relation_with_perf(
        FoldingMode::Optimized,
        transcript,
        params,
        structure,
        &handoff.chunk_input,
        incoming_main,
        log,
        rv64im_ajtai_mixers(),
        Some(optimized_cache),
    )
    .map_err(|err| SimpleKernelError::Proof(format!("RV64IM chunk transition {chunk_index} prove failed: {err}")))?;
    let replay_witness = computation.replay_witness().map_err(|err| {
        SimpleKernelError::Proof(format!(
            "RV64IM chunk transition {chunk_index} replay extraction failed: {err}"
        ))
    })?;
    let proved = computation.into_relation_result().map_err(|err| {
        SimpleKernelError::Proof(format!(
            "RV64IM chunk transition {chunk_index} relation result failed: {err}"
        ))
    })?;
    let chunk_relation_digest = rv64im_chunk_relation_digest(
        &handoff.public_chunk,
        proved.artifacts.relation_digest,
        handoff.bridge_witness.digest,
    );
    Ok((replay_witness, proved.next_main, chunk_relation_digest))
}

pub(crate) fn verify_rv64im_chunk_relation_with_replay(
    chunk_index: usize,
    handoff: &Rv64imVerifiedKernelChunkHandoff,
    incoming_main: &Carry,
    replay_witness: &ChunkReplayWitness,
    transcript: &mut Poseidon2Transcript,
    params: &neo_params::NeoParams,
    structure: &CcsStructure<F>,
    log: &AjtaiSModule,
    optimized_cache: &OptimizedStructureCache,
) -> Result<(Carry, [u8; 32]), SimpleKernelError> {
    let proved = verify_chunk_relation_with_witness(
        transcript,
        params,
        structure,
        &handoff.chunk_input,
        incoming_main,
        replay_witness,
        log,
        rv64im_ajtai_mixers(),
        optimized_cache,
    )
    .map_err(|err| SimpleKernelError::Proof(format!("RV64IM chunk transition {chunk_index} verify failed: {err}")))?;
    let chunk_relation_digest = rv64im_chunk_relation_digest(
        &handoff.public_chunk,
        proved.artifacts.relation_digest,
        handoff.bridge_witness.digest,
    );
    Ok((proved.next_main, chunk_relation_digest))
}

pub(crate) fn rv64im_step_handle(
    previous_handle: [u8; 32],
    chunk_index: usize,
    chunk_start_index: usize,
    chunk_len: usize,
    chunk_relation_digest: [u8; 32],
) -> [u8; 32] {
    fixed_shape_recursive_step_handle(
        previous_handle,
        chunk_index,
        chunk_start_index,
        chunk_len,
        chunk_relation_digest,
    )
}

pub(crate) fn rv64im_chunk_replay_witness_digest(replay_witness: &ChunkReplayWitness) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/chunk_transition_witness");
    tr.append_message(
        b"neo.fold.next/rv64im/chunk_transition_witness/header_digest",
        &replay_witness.ccs_replay_proof.header_digest,
    );
    tr.append_u64s(
        b"neo.fold.next/rv64im/chunk_transition_witness/counts",
        &[
            replay_witness.ccs_outputs.len() as u64,
            replay_witness.ccs_replay_proof.sumcheck_rounds.len() as u64,
            replay_witness.ccs_replay_proof.sumcheck_rounds_nc.len() as u64,
        ],
    );
    let mut me_scratch = Vec::<F>::with_capacity(2048);
    for output in &replay_witness.ccs_outputs {
        let digest = me_digest_poseidon_into(&mut me_scratch, output);
        tr.append_fields_iter(
            b"neo.fold.next/rv64im/chunk_transition_witness/output_digest",
            digest.len(),
            digest.iter().copied(),
        );
    }
    append_k_rounds(
        &mut tr,
        b"neo.fold.next/rv64im/chunk_transition_witness/fe_round",
        &replay_witness.ccs_replay_proof.sumcheck_rounds,
    );
    append_k_rounds(
        &mut tr,
        b"neo.fold.next/rv64im/chunk_transition_witness/nc_round",
        &replay_witness.ccs_replay_proof.sumcheck_rounds_nc,
    );
    tr.digest32()
}

fn rv64im_chunk_relation_digest(
    public_chunk: &PublicChunk,
    main_relation_digest: [u8; 32],
    bridge_digest: [u8; 32],
) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/chunk_relation_digest");
    tr.append_message(
        b"neo.fold.next/rv64im/chunk_relation_digest/public_chunk",
        &rv64im_public_chunk_digest(public_chunk),
    );
    tr.append_message(
        b"neo.fold.next/rv64im/chunk_relation_digest/main",
        &main_relation_digest,
    );
    tr.append_message(b"neo.fold.next/rv64im/chunk_relation_digest/bridge", &bridge_digest);
    tr.digest32()
}

fn append_k_rounds(tr: &mut Poseidon2Transcript, label: &'static [u8], rounds: &[Vec<K>]) {
    tr.append_u64s(
        b"neo.fold.next/rv64im/chunk_transition_witness/round_count",
        &[rounds.len() as u64],
    );
    for round in rounds {
        append_k_values(tr, label, round);
    }
}

fn append_k_values(tr: &mut Poseidon2Transcript, label: &'static [u8], values: &[K]) {
    tr.append_u64s(
        b"neo.fold.next/rv64im/chunk_transition_witness/k_len",
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

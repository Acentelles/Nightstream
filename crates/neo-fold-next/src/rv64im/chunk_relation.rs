//! Owns the RV64IM per-chunk replay surface above the verified export seam.

use neo_ajtai::AjtaiSModule;
use neo_ccs::CcsStructure;
use neo_math::{KExtensions, F, K};
use neo_reductions::optimized_engine::OptimizedStructureCache;
use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::chunk_relation::{
    claim_digests, compute_chunk_replay_witness_and_relation_with_instance_digest_and_perf,
    verify_chunk_relation_with_witness_and_instance_digest, ChunkReplayWitness,
};
use crate::finalize::fixed_shape_recursive_step_handle;
use crate::proof::{Carry, ChunkProvePerf};
use crate::rv64im::kernel::{
    prepared_step_digest, rv64im_ajtai_mixers, Rv64imVerifiedKernelChunkHandoff, SimpleKernelError,
};

pub(crate) fn prove_rv64im_chunk_transition_with_perf(
    chunk_index: usize,
    handoff: &Rv64imVerifiedKernelChunkHandoff,
    incoming_main: &Carry,
    transcript: &mut Poseidon2Transcript,
    params: &neo_params::NeoParams,
    structure: &CcsStructure<F>,
    log: &AjtaiSModule,
    optimized_cache: &OptimizedStructureCache,
) -> Result<((ChunkReplayWitness, Carry, [u8; 32], [u8; 32]), ChunkProvePerf), SimpleKernelError> {
    // This builder only accepts a verified export handoff, so the prover hot path
    // does not replay structural bridge validation here. Verification still does.
    let ((replay_witness, proved), perf) = compute_chunk_replay_witness_and_relation_with_instance_digest_and_perf(
        transcript,
        params,
        structure,
        &handoff.chunk_input,
        incoming_main,
        log,
        rv64im_ajtai_mixers(),
        optimized_cache,
        Some(handoff.public_chunk_instance_digest),
    )
    .map_err(|err| SimpleKernelError::Proof(format!("RV64IM chunk transition {chunk_index} prove failed: {err}")))?;
    let public_chunk_digest = handoff.public_chunk_digest;
    let chunk_relation_digest = rv64im_chunk_relation_digest(
        public_chunk_digest,
        proved.artifacts.relation_digest,
        handoff.bridge_handoff.digest,
    );
    Ok((
        (
            replay_witness,
            proved.next_main,
            public_chunk_digest,
            chunk_relation_digest,
        ),
        perf,
    ))
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
) -> Result<(Carry, [u8; 32], [u8; 32]), SimpleKernelError> {
    validate_rv64im_chunk_bridge_handoff(chunk_index, handoff)?;
    let proved = verify_chunk_relation_with_witness_and_instance_digest(
        transcript,
        params,
        structure,
        &handoff.chunk_input,
        incoming_main,
        replay_witness,
        log,
        rv64im_ajtai_mixers(),
        optimized_cache,
        Some(handoff.public_chunk_instance_digest),
    )
    .map_err(|err| SimpleKernelError::Proof(format!("RV64IM chunk transition {chunk_index} verify failed: {err}")))?;
    let public_chunk_digest = handoff.public_chunk_digest;
    let chunk_relation_digest = rv64im_chunk_relation_digest(
        public_chunk_digest,
        proved.artifacts.relation_digest,
        handoff.bridge_handoff.digest,
    );
    Ok((proved.next_main, public_chunk_digest, chunk_relation_digest))
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
    append_output_digests(&mut tr, &replay_witness.ccs_outputs);
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
    public_chunk_digest: [u8; 32],
    main_relation_digest: [u8; 32],
    bridge_handoff_digest: [u8; 32],
) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/chunk_relation_digest");
    tr.append_message(
        b"neo.fold.next/rv64im/chunk_relation_digest/public_chunk",
        &public_chunk_digest,
    );
    tr.append_message(
        b"neo.fold.next/rv64im/chunk_relation_digest/main",
        &main_relation_digest,
    );
    tr.append_message(
        b"neo.fold.next/rv64im/chunk_relation_digest/bridge",
        &bridge_handoff_digest,
    );
    tr.digest32()
}

fn validate_rv64im_chunk_bridge_handoff(
    chunk_index: usize,
    handoff: &Rv64imVerifiedKernelChunkHandoff,
) -> Result<(), SimpleKernelError> {
    if handoff.public_chunk.start_index != handoff.chunk_input.start_index {
        return Err(SimpleKernelError::Bridge(format!(
            "RV64IM chunk transition {chunk_index} public chunk start does not match the carried chunk input"
        )));
    }
    if handoff.public_chunk.steps.len() != handoff.chunk_input.steps.len() {
        return Err(SimpleKernelError::Bridge(format!(
            "RV64IM chunk transition {chunk_index} public chunk step count does not match the carried chunk input"
        )));
    }
    if handoff.bridge_handoff.digest != handoff.bridge_handoff.expected_digest() {
        return Err(SimpleKernelError::Bridge(format!(
            "RV64IM chunk transition {chunk_index} bridge handoff digest mismatch"
        )));
    }
    if handoff.bridge_handoff.chunk_index != chunk_index as u64 {
        return Err(SimpleKernelError::Bridge(format!(
            "RV64IM chunk transition {chunk_index} bridge handoff chunk index mismatch"
        )));
    }
    if handoff.bridge_handoff.chunk_start_index != handoff.chunk_input.start_index as u64 {
        return Err(SimpleKernelError::Bridge(format!(
            "RV64IM chunk transition {chunk_index} bridge handoff chunk start mismatch"
        )));
    }
    if handoff.bridge_handoff.public_step_count != handoff.chunk_input.steps.len() as u64 {
        return Err(SimpleKernelError::Bridge(format!(
            "RV64IM chunk transition {chunk_index} bridge handoff step count mismatch"
        )));
    }
    if handoff.bridge_handoff.step_bindings.len() != handoff.chunk_input.steps.len() {
        return Err(SimpleKernelError::Bridge(format!(
            "RV64IM chunk transition {chunk_index} bridge handoff binding count mismatch"
        )));
    }
    for (chunk_local_index, (binding, step)) in handoff
        .bridge_handoff
        .step_bindings
        .iter()
        .zip(handoff.chunk_input.steps.iter())
        .enumerate()
    {
        let public_step = handoff
            .public_chunk
            .steps
            .get(chunk_local_index)
            .ok_or_else(|| {
                SimpleKernelError::Bridge(format!(
                    "RV64IM chunk transition {chunk_index}:{chunk_local_index} public chunk step missing"
                ))
            })?;
        if public_step.label != step.label
            || public_step.mcs.m_in != step.mcs.m_in
            || public_step.mcs.x != step.mcs.x
            || public_step.mcs.c != step.mcs.c
        {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM chunk transition {chunk_index}:{chunk_local_index} public step does not match the carried chunk input"
            )));
        }
        if binding.digest != binding.expected_digest() {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM chunk transition {chunk_index}:{chunk_local_index} bridge binding digest mismatch"
            )));
        }
        if binding.logical_index != (handoff.chunk_input.start_index + chunk_local_index) as u64 {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM chunk transition {chunk_index}:{chunk_local_index} bridge binding logical index mismatch"
            )));
        }
        if binding.prepared_step_digest != prepared_step_digest(step) {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM chunk transition {chunk_index}:{chunk_local_index} bridge binding does not match the carried chunk step"
            )));
        }
    }
    Ok(())
}

fn append_output_digests(tr: &mut Poseidon2Transcript, ccs_outputs: &[neo_ccs::CeClaim<neo_ajtai::Commitment, F, K>]) {
    for digest in claim_digests(ccs_outputs) {
        tr.append_fields_iter(
            b"neo.fold.next/rv64im/chunk_transition_witness/output_digest",
            digest.len(),
            digest,
        );
    }
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

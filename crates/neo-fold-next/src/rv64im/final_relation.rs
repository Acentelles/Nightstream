//! Owns the RV64IM folded/final relation replay above the accepted/export seam.

use neo_ajtai::Commitment;
use neo_ccs::{CcsStructure, CeClaim};
use neo_math::{F, K};
use neo_params::NeoParams;
use neo_reductions::engines::utils::me_digest_poseidon_into;
use neo_reductions::optimized_engine::OptimizedStructureCache;
use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};

use crate::finalize::{digest_fixed_shape_final_proof, fixed_shape_recursive_seed, FixedShapeChunkSummary};
use crate::proof::{Carry, FoldSchedule};
use crate::rv64im::chunk_relation::{
    prove_rv64im_chunk_transition, rv64im_chunk_replay_witness_digest, rv64im_step_handle,
    verify_rv64im_chunk_relation_with_replay,
};
use crate::rv64im::kernel::{
    build_rv64im_kernel_export_relation_from_artifact, build_rv64im_kernel_export_seam_from_accepted_artifact,
    rv64im_cached_root_main_lane_context, rv64im_public_chunk_digest, verify_rv64im_kernel_export_witness_with_output,
    Rv64imAcceptedProofArtifact, Rv64imKernelExportRelationResult, Rv64imKernelExportWitness,
    Rv64imVerifiedKernelChunkHandoff, SimpleKernelError,
};

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Rv64imAccumulatorHandle(pub [u8; 32]);

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct Rv64imRecursiveAccumulator {
    pub final_main_claims: Vec<CeClaim<Commitment, F, K>>,
    pub terminal_handle: Rv64imAccumulatorHandle,
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct Rv64imFoldedStatement {
    pub fold_schedule: FoldSchedule,
    pub chunk_count: u64,
    pub semantic_step_count: u64,
    pub kernel_relation_digest: [u8; 32],
    pub final_accumulator: Rv64imRecursiveAccumulator,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug)]
pub struct Rv64imChunkTransitionWitness {
    pub replay_witness: crate::chunk_relation::ChunkReplayWitness,
}

#[derive(Clone, Debug)]
pub struct Rv64imFoldedProof {
    pub accepted_artifact: Rv64imAcceptedProofArtifact,
    pub kernel_export: Rv64imKernelExportWitness,
    pub steps: Vec<Rv64imChunkTransitionWitness>,
}

#[derive(Clone, Debug)]
pub struct Rv64imFinalProof {
    pub proof_digest: [u8; 32],
    pub accepted_artifact: Rv64imAcceptedProofArtifact,
    pub kernel_export: Rv64imKernelExportWitness,
    pub chunk_summaries: Vec<FixedShapeChunkSummary>,
    pub steps: Vec<Rv64imChunkTransitionWitness>,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) struct Rv64imFinalProofComponentDigests {
    pub accepted_artifact_digest: [u8; 32],
    pub kernel_export_digest: [u8; 32],
    pub chunk_transition_digests: Vec<[u8; 32]>,
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
pub struct Rv64imFinalStatement {
    pub public_statement_digest: [u8; 32],
    pub folded: Rv64imFoldedStatement,
    pub digest: [u8; 32],
}

struct Rv64imFoldedBuildOutput {
    folded: Rv64imFoldedStatement,
    chunk_summaries: Vec<FixedShapeChunkSummary>,
    proof: Rv64imFoldedProof,
}

struct Rv64imRecursiveAccumulatorState {
    main: Carry,
    terminal_handle: Rv64imAccumulatorHandle,
}

impl Rv64imRecursiveAccumulatorState {
    fn seed() -> Self {
        Self {
            main: Carry::default(),
            terminal_handle: Rv64imAccumulatorHandle(recursive_seed()),
        }
    }

    fn into_public(self) -> Rv64imRecursiveAccumulator {
        Rv64imRecursiveAccumulator {
            final_main_claims: self.main.claims,
            terminal_handle: self.terminal_handle,
        }
    }
}

pub fn prove_rv64im_folded_statement_from_accepted(
    artifact: &Rv64imAcceptedProofArtifact,
) -> Result<(Rv64imFoldedStatement, Rv64imFoldedProof), SimpleKernelError> {
    let built = build_rv64im_folded_statement_from_accepted(artifact)?;
    Ok((built.folded, built.proof))
}

pub fn verify_rv64im_folded_statement(
    folded: &Rv64imFoldedStatement,
    proof: &Rv64imFoldedProof,
) -> Result<(), SimpleKernelError> {
    verify_folded_statement_components_with_output(
        folded,
        &proof.accepted_artifact,
        &proof.kernel_export,
        &proof.steps,
    )?;
    Ok(())
}

pub fn prove_rv64im_final_statement_from_accepted(
    artifact: &Rv64imAcceptedProofArtifact,
) -> Result<(Rv64imFinalStatement, Rv64imFinalProof), SimpleKernelError> {
    let built = build_rv64im_folded_statement_from_accepted(artifact)?;
    let final_proof = build_final_proof(&built.folded, built.chunk_summaries, built.proof)?;
    let mut statement = Rv64imFinalStatement {
        public_statement_digest: artifact.statement.digest,
        folded: built.folded,
        digest: [0; 32],
    };
    statement.digest = final_statement_digest(&statement);
    Ok((statement, final_proof))
}

pub fn verify_rv64im_final_statement(
    statement: &Rv64imFinalStatement,
    proof: &Rv64imFinalProof,
) -> Result<(), SimpleKernelError> {
    verify_rv64im_final_statement_with_output(statement, proof)?;
    Ok(())
}

pub(crate) fn verify_rv64im_final_statement_with_output(
    statement: &Rv64imFinalStatement,
    proof: &Rv64imFinalProof,
) -> Result<Rv64imKernelExportRelationResult, SimpleKernelError> {
    if statement.folded.digest != folded_statement_digest(&statement.folded) {
        return Err(SimpleKernelError::Bridge(
            "RV64IM folded statement digest mismatch".into(),
        ));
    }
    if statement.digest != final_statement_digest(statement) {
        return Err(SimpleKernelError::Bridge(
            "RV64IM final statement digest mismatch".into(),
        ));
    }
    if statement.public_statement_digest != proof.accepted_artifact.statement.digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM final statement public digest does not match the carried accepted artifact".into(),
        ));
    }
    if proof.proof_digest
        != final_proof_digest(
            &statement.folded,
            &proof.accepted_artifact,
            &proof.kernel_export,
            &proof.chunk_summaries,
            &proof.steps,
        )
    {
        return Err(SimpleKernelError::Bridge("RV64IM final proof digest mismatch".into()));
    }
    let (verified_kernel, expected_chunk_summaries) = verify_folded_statement_components_with_output(
        &statement.folded,
        &proof.accepted_artifact,
        &proof.kernel_export,
        &proof.steps,
    )?;
    if proof.chunk_summaries != expected_chunk_summaries {
        return Err(SimpleKernelError::Bridge(
            "RV64IM final proof chunk summaries do not match the verified export seam".into(),
        ));
    }
    Ok(verified_kernel)
}

pub(crate) fn folded_statement_digest(folded: &Rv64imFoldedStatement) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/folded_statement");
    tr.append_message(b"neo.fold.next/rv64im/folded_statement/version", b"v1");
    tr.append_u64s(
        b"neo.fold.next/rv64im/folded_statement/meta",
        &[folded.chunk_count, folded.semantic_step_count],
    );
    tr.append_u64s(
        b"neo.fold.next/rv64im/folded_statement/schedule",
        &folded.fold_schedule.meta_words(),
    );
    tr.append_message(
        b"neo.fold.next/rv64im/folded_statement/kernel_relation_digest",
        &folded.kernel_relation_digest,
    );
    append_recursive_accumulator(&mut tr, &folded.final_accumulator);
    tr.digest32()
}

pub(crate) fn final_statement_digest(statement: &Rv64imFinalStatement) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/final_statement");
    tr.append_message(b"neo.fold.next/rv64im/final_statement/version", b"v1");
    tr.append_message(
        b"neo.fold.next/rv64im/final_statement/public_statement_digest",
        &statement.public_statement_digest,
    );
    tr.append_message(
        b"neo.fold.next/rv64im/final_statement/folded_digest",
        &statement.folded.digest,
    );
    tr.digest32()
}

fn build_rv64im_folded_statement_from_accepted(
    artifact: &Rv64imAcceptedProofArtifact,
) -> Result<Rv64imFoldedBuildOutput, SimpleKernelError> {
    let (relation, kernel_export, verified_kernel) = build_rv64im_kernel_export_seam_from_accepted_artifact(artifact)?;
    let (params, log, structure) = rv64im_cached_root_main_lane_context()?;
    let (steps, chunk_summaries, final_accumulator) =
        build_recursive_proof(&verified_kernel.chunk_handoffs, params, structure, log)?;
    let mut folded = Rv64imFoldedStatement {
        fold_schedule: verified_kernel.fold_schedule,
        chunk_count: verified_kernel.chunk_handoffs.len() as u64,
        semantic_step_count: verified_kernel
            .chunk_handoffs
            .iter()
            .map(|handoff| handoff.chunk_input.steps.len() as u64)
            .sum(),
        kernel_relation_digest: relation.digest,
        final_accumulator,
        digest: [0; 32],
    };
    folded.digest = folded_statement_digest(&folded);
    Ok(Rv64imFoldedBuildOutput {
        folded,
        chunk_summaries,
        proof: Rv64imFoldedProof {
            accepted_artifact: artifact.clone(),
            kernel_export,
            steps,
        },
    })
}

fn verify_folded_statement_components_with_output(
    folded: &Rv64imFoldedStatement,
    accepted_artifact: &Rv64imAcceptedProofArtifact,
    kernel_export: &Rv64imKernelExportWitness,
    steps: &[Rv64imChunkTransitionWitness],
) -> Result<(Rv64imKernelExportRelationResult, Vec<FixedShapeChunkSummary>), SimpleKernelError> {
    if folded.digest != folded_statement_digest(folded) {
        return Err(SimpleKernelError::Bridge(
            "RV64IM folded statement digest mismatch".into(),
        ));
    }
    let (relation, verified_kernel) = build_rv64im_kernel_export_relation_from_artifact(accepted_artifact)?;
    if folded.fold_schedule != relation.fold_schedule {
        return Err(SimpleKernelError::Bridge(
            "RV64IM folded statement schedule does not match the verified export relation".into(),
        ));
    }
    if folded.kernel_relation_digest != relation.digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM folded statement kernel relation digest does not match the verified export relation".into(),
        ));
    }
    let verified_witness = verify_rv64im_kernel_export_witness_with_output(&relation, kernel_export)?;
    if verified_witness.fold_schedule != verified_kernel.fold_schedule
        || verified_witness.final_state_digest != verified_kernel.final_state_digest
        || verified_witness.final_pc != verified_kernel.final_pc
        || verified_witness.halted != verified_kernel.halted
        || verified_witness.chunk_handoffs.len() != verified_kernel.chunk_handoffs.len()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM export witness does not match the verified accepted artifact".into(),
        ));
    }
    for (witness_handoff, expected_handoff) in verified_witness
        .chunk_handoffs
        .iter()
        .zip(verified_kernel.chunk_handoffs.iter())
    {
        if rv64im_public_chunk_digest(&witness_handoff.public_chunk)
            != rv64im_public_chunk_digest(&expected_handoff.public_chunk)
            || witness_handoff.bridge_witness.digest != expected_handoff.bridge_witness.digest
        {
            return Err(SimpleKernelError::Bridge(
                "RV64IM export witness handoff surface does not match the verified accepted artifact".into(),
            ));
        }
    }
    if folded.chunk_count as usize != verified_kernel.chunk_handoffs.len() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM folded statement chunk count does not match the verified export relation".into(),
        ));
    }
    let verified_semantic_step_count: usize = verified_kernel
        .chunk_handoffs
        .iter()
        .map(|handoff| handoff.chunk_input.steps.len())
        .sum();
    if folded.semantic_step_count as usize != verified_semantic_step_count {
        return Err(SimpleKernelError::Bridge(
            "RV64IM folded statement semantic step count does not match the verified export relation".into(),
        ));
    }
    if steps.len() != verified_kernel.chunk_handoffs.len() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM folded proof chunk replay count does not match the verified export relation".into(),
        ));
    }
    let chunk_summaries = verify_recursive_steps(folded, &verified_kernel, steps)?;
    Ok((verified_kernel, chunk_summaries))
}

fn verify_recursive_steps(
    folded: &Rv64imFoldedStatement,
    verified_kernel: &Rv64imKernelExportRelationResult,
    steps: &[Rv64imChunkTransitionWitness],
) -> Result<Vec<FixedShapeChunkSummary>, SimpleKernelError> {
    let (params, log, structure) = rv64im_cached_root_main_lane_context()?;
    let optimized_cache = OptimizedStructureCache::build(structure).map_err(run_error)?;
    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/session");
    let mut accumulator = Rv64imRecursiveAccumulatorState::seed();
    let mut chunk_summaries = Vec::with_capacity(steps.len());

    for (chunk_index, step_witness) in steps.iter().enumerate() {
        let handoff = verified_kernel
            .chunk_handoffs
            .get(chunk_index)
            .ok_or_else(|| {
                SimpleKernelError::Bridge(format!(
                    "RV64IM chunk transition {chunk_index} missing a verified export handoff"
                ))
            })?;
        let (next_main, chunk_relation_digest) = verify_rv64im_chunk_relation_with_replay(
            chunk_index,
            handoff,
            &accumulator.main,
            &step_witness.replay_witness,
            &mut transcript,
            params,
            structure,
            log,
            &optimized_cache,
        )?;
        let next_handle = Rv64imAccumulatorHandle(rv64im_step_handle(
            accumulator.terminal_handle.0,
            chunk_index,
            handoff.public_chunk.start_index,
            handoff.public_chunk.steps.len(),
            chunk_relation_digest,
        ));
        chunk_summaries.push(FixedShapeChunkSummary::from_public_chunk(
            &handoff.public_chunk,
            rv64im_public_chunk_digest(&handoff.public_chunk),
            chunk_relation_digest,
        ));
        accumulator = Rv64imRecursiveAccumulatorState {
            main: next_main,
            terminal_handle: next_handle,
        };
        transcript.append_message(b"neo.fold.next/chunk_done", &[1]);
    }

    let final_accumulator = accumulator.into_public();
    if final_accumulator != folded.final_accumulator {
        return Err(SimpleKernelError::Bridge(
            "RV64IM folded statement final accumulator mismatch".into(),
        ));
    }
    Ok(chunk_summaries)
}

fn build_recursive_proof(
    chunk_handoffs: &[Rv64imVerifiedKernelChunkHandoff],
    params: &NeoParams,
    structure: &CcsStructure<F>,
    log: &neo_ajtai::AjtaiSModule,
) -> Result<
    (
        Vec<Rv64imChunkTransitionWitness>,
        Vec<FixedShapeChunkSummary>,
        Rv64imRecursiveAccumulator,
    ),
    SimpleKernelError,
> {
    let optimized_cache = OptimizedStructureCache::build(structure).map_err(run_error)?;
    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/session");
    let mut accumulator = Rv64imRecursiveAccumulatorState::seed();
    let mut steps = Vec::with_capacity(chunk_handoffs.len());
    let mut chunk_summaries = Vec::with_capacity(chunk_handoffs.len());

    for (chunk_index, handoff) in chunk_handoffs.iter().enumerate() {
        let (replay_witness, next_main, chunk_relation_digest) = prove_rv64im_chunk_transition(
            chunk_index,
            handoff,
            &accumulator.main,
            &mut transcript,
            params,
            structure,
            log,
            &optimized_cache,
        )?;
        let next_handle = Rv64imAccumulatorHandle(rv64im_step_handle(
            accumulator.terminal_handle.0,
            chunk_index,
            handoff.public_chunk.start_index,
            handoff.public_chunk.steps.len(),
            chunk_relation_digest,
        ));
        chunk_summaries.push(FixedShapeChunkSummary::from_public_chunk(
            &handoff.public_chunk,
            rv64im_public_chunk_digest(&handoff.public_chunk),
            chunk_relation_digest,
        ));
        accumulator = Rv64imRecursiveAccumulatorState {
            main: next_main,
            terminal_handle: next_handle,
        };
        steps.push(Rv64imChunkTransitionWitness { replay_witness });
        transcript.append_message(b"neo.fold.next/chunk_done", &[1]);
    }

    Ok((steps, chunk_summaries, accumulator.into_public()))
}

fn build_final_proof(
    folded: &Rv64imFoldedStatement,
    chunk_summaries: Vec<FixedShapeChunkSummary>,
    proof: Rv64imFoldedProof,
) -> Result<Rv64imFinalProof, SimpleKernelError> {
    let proof_digest = final_proof_digest(
        folded,
        &proof.accepted_artifact,
        &proof.kernel_export,
        &chunk_summaries,
        &proof.steps,
    );
    Ok(Rv64imFinalProof {
        proof_digest,
        accepted_artifact: proof.accepted_artifact,
        kernel_export: proof.kernel_export,
        chunk_summaries,
        steps: proof.steps,
    })
}

pub(crate) fn final_proof_digest(
    folded: &Rv64imFoldedStatement,
    accepted_artifact: &Rv64imAcceptedProofArtifact,
    kernel_export: &Rv64imKernelExportWitness,
    chunk_summaries: &[FixedShapeChunkSummary],
    steps: &[Rv64imChunkTransitionWitness],
) -> [u8; 32] {
    let component_digests = rv64im_final_proof_component_digests_from_parts(accepted_artifact, kernel_export, steps);
    digest_fixed_shape_final_proof(
        &folded.digest,
        folded.chunk_count,
        chunk_summaries,
        &[
            component_digests.accepted_artifact_digest,
            component_digests.kernel_export_digest,
        ],
        &component_digests.chunk_transition_digests,
    )
}

pub(crate) fn final_proof_component_digests(proof: &Rv64imFinalProof) -> Rv64imFinalProofComponentDigests {
    rv64im_final_proof_component_digests_from_parts(&proof.accepted_artifact, &proof.kernel_export, &proof.steps)
}

fn rv64im_final_proof_component_digests_from_parts(
    accepted_artifact: &Rv64imAcceptedProofArtifact,
    kernel_export: &Rv64imKernelExportWitness,
    steps: &[Rv64imChunkTransitionWitness],
) -> Rv64imFinalProofComponentDigests {
    Rv64imFinalProofComponentDigests {
        accepted_artifact_digest: accepted_artifact.digest,
        kernel_export_digest: kernel_export.digest,
        chunk_transition_digests: steps.iter().map(chunk_transition_witness_digest).collect(),
    }
}

pub(crate) fn recursive_seed() -> [u8; 32] {
    fixed_shape_recursive_seed(b"neo.fold.next/rv64im/recursive_seed")
}

fn append_recursive_accumulator(tr: &mut Poseidon2Transcript, accumulator: &Rv64imRecursiveAccumulator) {
    let final_main_claim_digests = final_main_claim_digests(&accumulator.final_main_claims);
    tr.append_u64s(
        b"neo.fold.next/rv64im/final_accumulator/claim_count",
        &[final_main_claim_digests.len() as u64],
    );
    tr.append_fields_iter(
        b"neo.fold.next/rv64im/final_accumulator/final_main_claim_digest",
        final_main_claim_digests.len() * 4,
        final_main_claim_digests
            .iter()
            .flat_map(|digest| digest.iter().copied()),
    );
    tr.append_message(
        b"neo.fold.next/rv64im/final_accumulator/terminal_handle",
        &accumulator.terminal_handle.0,
    );
}

fn final_main_claim_digests(final_main_claims: &[CeClaim<Commitment, F, K>]) -> Vec<[F; 4]> {
    let mut digests = Vec::with_capacity(final_main_claims.len());
    let mut scratch = Vec::<F>::with_capacity(2048);
    for claim in final_main_claims {
        digests.push(me_digest_poseidon_into(&mut scratch, claim));
    }
    digests
}

pub(crate) fn chunk_transition_witness_digest(step: &Rv64imChunkTransitionWitness) -> [u8; 32] {
    rv64im_chunk_replay_witness_digest(&step.replay_witness)
}

fn run_error(err: impl ToString) -> SimpleKernelError {
    SimpleKernelError::Proof(err.to_string())
}

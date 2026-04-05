//! Owns the RV64IM kernel export relation above the accepted-proof artifact.
//!
//! It verifies the rich accepted artifact once, then collapses it into:
//! - canonical per-chunk public surfaces,
//! - canonical per-chunk row-binding bridge witnesses,
//! - one fixed export relation digest for recursion/decider work.

use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};

use crate::proof::{partition_step_inputs, ChunkInput, FoldSchedule, PublicChunk};

use super::proof_accepted::{accepted_proof_artifact_from_legacy_proof, Rv64imAcceptedProofArtifact};
use super::proof_api::Rv64imProof;
use super::proof_staged_verify::verify_accepted_proof_artifact_with_perf;
use super::root_lane_witness::RootExecutionBundle;
use super::simple::{build_prepared_steps_from_execution_rows, SimpleKernelError};
use super::{prepared_step_digest, public_step_digest};

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imChunkBridgeRelationWitness {
    pub chunk_index: u64,
    pub chunk_start_index: u64,
    pub public_step_count: u64,
    pub prepared_step_binding_digests: Vec<[u8; 32]>,
    pub row_chunk_route_digests: Vec<[u8; 32]>,
    pub row_local_ccs_acceptance_digests: Vec<[u8; 32]>,
    pub semantics_refinement_digests: Vec<[u8; 32]>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug)]
pub struct Rv64imVerifiedKernelChunkHandoff {
    pub chunk_input: ChunkInput,
    pub public_chunk: PublicChunk,
    pub bridge_witness: Rv64imChunkBridgeRelationWitness,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imKernelChunkExportWitness {
    pub chunk_input: ChunkInput,
    pub bridge_witness: Rv64imChunkBridgeRelationWitness,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imKernelExportWitness {
    pub chunk_handoffs: Vec<Rv64imKernelChunkExportWitness>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug)]
pub struct Rv64imKernelExportRelationResult {
    pub fold_schedule: FoldSchedule,
    pub chunk_handoffs: Vec<Rv64imVerifiedKernelChunkHandoff>,
    pub final_state_digest: [u8; 32],
    pub final_pc: u64,
    pub halted: bool,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imChunkExportSurface {
    pub public_chunk_digest: [u8; 32],
    pub bridge_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imKernelExportRelation {
    pub fold_schedule: FoldSchedule,
    pub chunk_count: u64,
    pub public_step_count: u64,
    pub final_state_digest: [u8; 32],
    pub final_pc: u64,
    pub halted: bool,
    pub chunk_surfaces: Vec<Rv64imChunkExportSurface>,
    pub digest: [u8; 32],
}

impl Rv64imChunkBridgeRelationWitness {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/chunk_bridge_relation_witness");
        tr.append_u64s(
            b"rv64im/chunk_bridge_relation_witness/meta",
            &[self.chunk_index, self.chunk_start_index, self.public_step_count],
        );
        append_digest_vec(
            &mut tr,
            b"rv64im/chunk_bridge_relation_witness/prepared_step_binding",
            &self.prepared_step_binding_digests,
        );
        append_digest_vec(
            &mut tr,
            b"rv64im/chunk_bridge_relation_witness/row_chunk_route",
            &self.row_chunk_route_digests,
        );
        append_digest_vec(
            &mut tr,
            b"rv64im/chunk_bridge_relation_witness/row_local_ccs_acceptance",
            &self.row_local_ccs_acceptance_digests,
        );
        append_digest_vec(
            &mut tr,
            b"rv64im/chunk_bridge_relation_witness/semantics_refinement",
            &self.semantics_refinement_digests,
        );
        tr.digest32()
    }
}

impl Rv64imKernelChunkExportWitness {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_chunk_export_witness");
        tr.append_u64s(
            b"rv64im/kernel_chunk_export_witness/meta",
            &[self.chunk_input.start_index as u64, self.chunk_input.steps.len() as u64],
        );
        for step in &self.chunk_input.steps {
            tr.append_message(
                b"rv64im/kernel_chunk_export_witness/prepared_step_digest",
                &prepared_step_digest(step),
            );
        }
        tr.append_message(
            b"rv64im/kernel_chunk_export_witness/bridge_digest",
            &self.bridge_witness.digest,
        );
        tr.digest32()
    }
}

impl Rv64imKernelExportWitness {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_export_witness");
        tr.append_u64s(
            b"rv64im/kernel_export_witness/chunk_count",
            &[self.chunk_handoffs.len() as u64],
        );
        for handoff in &self.chunk_handoffs {
            tr.append_message(b"rv64im/kernel_export_witness/chunk_handoff_digest", &handoff.digest);
        }
        tr.digest32()
    }
}

impl Rv64imChunkExportSurface {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/chunk_export_surface");
        tr.append_message(
            b"rv64im/chunk_export_surface/public_chunk_digest",
            &self.public_chunk_digest,
        );
        tr.append_message(b"rv64im/chunk_export_surface/bridge_digest", &self.bridge_digest);
        tr.digest32()
    }
}

impl Rv64imKernelExportRelation {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_export_relation");
        tr.append_u64s(
            b"rv64im/kernel_export_relation/fold_schedule",
            &self.fold_schedule.meta_words(),
        );
        tr.append_u64s(
            b"rv64im/kernel_export_relation/meta",
            &[
                self.chunk_count,
                self.public_step_count,
                self.final_pc,
                self.halted as u64,
            ],
        );
        tr.append_message(
            b"rv64im/kernel_export_relation/final_state_digest",
            &self.final_state_digest,
        );
        append_chunk_surfaces(&mut tr, &self.chunk_surfaces);
        tr.digest32()
    }
}

pub fn build_rv64im_kernel_export_witness(proof: &Rv64imProof) -> Result<Rv64imKernelExportWitness, SimpleKernelError> {
    build_rv64im_kernel_export_seam(proof).map(|(_, witness)| witness)
}

pub fn verify_rv64im_kernel_export_witness(
    relation: &Rv64imKernelExportRelation,
    witness: &Rv64imKernelExportWitness,
) -> Result<(), SimpleKernelError> {
    verify_rv64im_kernel_export_witness_with_output(relation, witness).map(|_| ())
}

pub fn build_rv64im_kernel_export_relation(
    proof: &Rv64imProof,
) -> Result<Rv64imKernelExportRelation, SimpleKernelError> {
    build_rv64im_kernel_export_seam(proof).map(|(relation, _)| relation)
}

pub fn verify_rv64im_kernel_export_relation(
    relation: &Rv64imKernelExportRelation,
    proof: &Rv64imProof,
) -> Result<(), SimpleKernelError> {
    verify_rv64im_kernel_export_relation_with_output(relation, proof).map(|_| ())
}

pub(crate) fn verify_rv64im_kernel_export_relation_with_output(
    relation: &Rv64imKernelExportRelation,
    proof: &Rv64imProof,
) -> Result<Rv64imKernelExportRelationResult, SimpleKernelError> {
    let artifact = accepted_proof_artifact_from_legacy_proof(proof)?;
    let (expected, result) = build_rv64im_kernel_export_relation_from_artifact(&artifact)?;
    if relation != &expected {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel export relation does not match the verified accepted artifact".into(),
        ));
    }
    Ok(result)
}

pub(crate) fn build_rv64im_kernel_export_seam(
    proof: &Rv64imProof,
) -> Result<(Rv64imKernelExportRelation, Rv64imKernelExportWitness), SimpleKernelError> {
    let artifact = accepted_proof_artifact_from_legacy_proof(proof)?;
    build_rv64im_kernel_export_seam_from_accepted_artifact(&artifact).map(|(relation, witness, _)| (relation, witness))
}

pub(crate) fn build_rv64im_kernel_export_seam_from_accepted_artifact(
    artifact: &Rv64imAcceptedProofArtifact,
) -> Result<
    (
        Rv64imKernelExportRelation,
        Rv64imKernelExportWitness,
        Rv64imKernelExportRelationResult,
    ),
    SimpleKernelError,
> {
    let (relation, result) = build_rv64im_kernel_export_relation_from_artifact(artifact)?;
    let witness = kernel_export_witness_from_result(&result);
    Ok((relation, witness, result))
}

pub(crate) fn verify_rv64im_kernel_export_witness_with_output(
    relation: &Rv64imKernelExportRelation,
    witness: &Rv64imKernelExportWitness,
) -> Result<Rv64imKernelExportRelationResult, SimpleKernelError> {
    if relation.digest != relation.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel export relation digest mismatch".into(),
        ));
    }
    if witness.digest != witness.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel export witness digest mismatch".into(),
        ));
    }
    if relation.chunk_count as usize != relation.chunk_surfaces.len() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel export relation chunk-count surface mismatch".into(),
        ));
    }
    if relation.chunk_count as usize != witness.chunk_handoffs.len() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel export witness chunk count does not match relation".into(),
        ));
    }

    let mut chunk_handoffs = Vec::with_capacity(witness.chunk_handoffs.len());
    let mut public_step_count = 0u64;
    for (chunk_index, (handoff, surface)) in witness
        .chunk_handoffs
        .iter()
        .zip(relation.chunk_surfaces.iter())
        .enumerate()
    {
        if handoff.digest != handoff.expected_digest() {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM kernel export witness chunk {chunk_index} digest mismatch"
            )));
        }
        if handoff.bridge_witness.digest != handoff.bridge_witness.expected_digest() {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM kernel export bridge witness chunk {chunk_index} digest mismatch"
            )));
        }

        let public_chunk = handoff.chunk_input.public();
        if handoff.bridge_witness.chunk_index != chunk_index as u64 {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM kernel export bridge witness chunk {chunk_index} index mismatch"
            )));
        }
        if handoff.bridge_witness.chunk_start_index != public_chunk.start_index as u64 {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM kernel export bridge witness chunk {chunk_index} start-index mismatch"
            )));
        }
        if handoff.bridge_witness.public_step_count != public_chunk.steps.len() as u64 {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM kernel export bridge witness chunk {chunk_index} step-count mismatch"
            )));
        }
        if surface.digest != surface.expected_digest() {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM kernel export surface chunk {chunk_index} digest mismatch"
            )));
        }
        if rv64im_public_chunk_digest(&public_chunk) != surface.public_chunk_digest {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM kernel export witness chunk {chunk_index} public chunk does not match relation"
            )));
        }
        if handoff.bridge_witness.digest != surface.bridge_digest {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM kernel export witness chunk {chunk_index} bridge witness does not match relation"
            )));
        }

        public_step_count += public_chunk.steps.len() as u64;
        chunk_handoffs.push(Rv64imVerifiedKernelChunkHandoff {
            chunk_input: handoff.chunk_input.clone(),
            public_chunk,
            bridge_witness: handoff.bridge_witness.clone(),
        });
    }

    if public_step_count != relation.public_step_count {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel export witness public-step count does not match relation".into(),
        ));
    }

    Ok(Rv64imKernelExportRelationResult {
        fold_schedule: relation.fold_schedule,
        chunk_handoffs,
        final_state_digest: relation.final_state_digest,
        final_pc: relation.final_pc,
        halted: relation.halted,
    })
}

pub(crate) fn build_rv64im_kernel_export_relation_from_artifact(
    artifact: &Rv64imAcceptedProofArtifact,
) -> Result<(Rv64imKernelExportRelation, Rv64imKernelExportRelationResult), SimpleKernelError> {
    verify_accepted_proof_artifact_with_perf(artifact)?;

    let result = build_export_relation_result(artifact)?;
    let mut relation = Rv64imKernelExportRelation {
        fold_schedule: result.fold_schedule,
        chunk_count: result.chunk_handoffs.len() as u64,
        public_step_count: result
            .chunk_handoffs
            .iter()
            .map(|handoff| handoff.public_chunk.steps.len() as u64)
            .sum(),
        final_state_digest: result.final_state_digest,
        final_pc: result.final_pc,
        halted: result.halted,
        chunk_surfaces: result
            .chunk_handoffs
            .iter()
            .map(chunk_export_surface)
            .collect(),
        digest: [0; 32],
    };
    relation.digest = relation.expected_digest();
    Ok((relation, result))
}

fn build_export_relation_result(
    artifact: &Rv64imAcceptedProofArtifact,
) -> Result<Rv64imKernelExportRelationResult, SimpleKernelError> {
    let fold_schedule = artifact.main_lane.packaged.statement.fold_schedule;
    let prepared_steps = build_prepared_steps_from_execution_rows(&artifact.root_execution.execution_rows)?;
    let chunk_inputs = partition_step_inputs(fold_schedule, prepared_steps)?;
    let public_chunks = artifact.main_lane.packaged.statement.chunks.clone();

    if chunk_inputs.len() != public_chunks.len() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel export chunk partition does not match the verified main-lane statement".into(),
        ));
    }

    let total_public_steps: usize = public_chunks.iter().map(|chunk| chunk.steps.len()).sum();
    if total_public_steps
        != artifact
            .root_execution
            .prepared_step_bindings
            .bindings
            .len()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel export prepared-step count does not match root-execution bindings".into(),
        ));
    }

    let mut chunk_handoffs = Vec::with_capacity(public_chunks.len());
    for (chunk_index, (chunk_input, public_chunk)) in chunk_inputs
        .into_iter()
        .zip(public_chunks.into_iter())
        .enumerate()
    {
        let derived_public_chunk = chunk_input.public();
        if rv64im_public_chunk_digest(&derived_public_chunk) != rv64im_public_chunk_digest(&public_chunk) {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM kernel export public chunk {chunk_index} does not match the verified main-lane statement"
            )));
        }
        let bridge_witness =
            build_chunk_bridge_relation_witness(&artifact.root_execution, chunk_index as u64, &public_chunk)?;
        chunk_handoffs.push(Rv64imVerifiedKernelChunkHandoff {
            chunk_input,
            public_chunk,
            bridge_witness,
        });
    }

    Ok(Rv64imKernelExportRelationResult {
        fold_schedule,
        chunk_handoffs,
        final_state_digest: artifact.statement.final_state_digest,
        final_pc: artifact.statement.final_pc,
        halted: artifact.statement.halted,
    })
}

fn build_chunk_bridge_relation_witness(
    root_execution: &RootExecutionBundle,
    chunk_index: u64,
    public_chunk: &PublicChunk,
) -> Result<Rv64imChunkBridgeRelationWitness, SimpleKernelError> {
    let start = public_chunk.start_index;
    let end = start + public_chunk.steps.len();
    let bindings = root_execution
        .prepared_step_bindings
        .bindings
        .get(start..end)
        .ok_or_else(|| SimpleKernelError::Bridge("RV64IM chunk bridge binding range exceeds root execution".into()))?;
    let routes = root_execution
        .row_chunk_routes
        .get(start..end)
        .ok_or_else(|| SimpleKernelError::Bridge("RV64IM chunk bridge route range exceeds root execution".into()))?;
    let acceptances = root_execution
        .row_local_ccs_acceptance
        .acceptances
        .get(start..end)
        .ok_or_else(|| {
            SimpleKernelError::Bridge("RV64IM chunk bridge acceptance range exceeds root execution".into())
        })?;
    let refinements = root_execution
        .execution_semantics_refinement
        .refinements
        .get(start..end)
        .ok_or_else(|| {
            SimpleKernelError::Bridge("RV64IM chunk bridge refinement range exceeds root execution".into())
        })?;

    for (chunk_local_index, route) in routes.iter().enumerate() {
        if route.logical_index != (start + chunk_local_index) as u64
            || route.chunk_index != chunk_index
            || route.chunk_start_index != start as u64
            || route.chunk_local_index != chunk_local_index as u64
        {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM chunk bridge route {chunk_index}:{chunk_local_index} lost verified row-to-chunk alignment"
            )));
        }
    }

    let mut witness = Rv64imChunkBridgeRelationWitness {
        chunk_index,
        chunk_start_index: start as u64,
        public_step_count: public_chunk.steps.len() as u64,
        prepared_step_binding_digests: bindings.iter().map(|binding| binding.digest).collect(),
        row_chunk_route_digests: routes.iter().map(|route| route.digest).collect(),
        row_local_ccs_acceptance_digests: acceptances
            .iter()
            .map(|acceptance| acceptance.digest)
            .collect(),
        semantics_refinement_digests: refinements
            .iter()
            .map(|refinement| refinement.digest)
            .collect(),
        digest: [0; 32],
    };
    witness.digest = witness.expected_digest();
    Ok(witness)
}

fn chunk_export_surface(handoff: &Rv64imVerifiedKernelChunkHandoff) -> Rv64imChunkExportSurface {
    let public_chunk_digest = rv64im_public_chunk_digest(&handoff.public_chunk);
    let bridge_digest = handoff.bridge_witness.digest;
    let mut surface = Rv64imChunkExportSurface {
        public_chunk_digest,
        bridge_digest,
        digest: [0; 32],
    };
    surface.digest = surface.expected_digest();
    surface
}

fn kernel_export_witness_from_result(result: &Rv64imKernelExportRelationResult) -> Rv64imKernelExportWitness {
    let chunk_handoffs = result
        .chunk_handoffs
        .iter()
        .map(kernel_chunk_export_witness)
        .collect();
    let mut witness = Rv64imKernelExportWitness {
        chunk_handoffs,
        digest: [0; 32],
    };
    witness.digest = witness.expected_digest();
    witness
}

fn kernel_chunk_export_witness(handoff: &Rv64imVerifiedKernelChunkHandoff) -> Rv64imKernelChunkExportWitness {
    let mut witness = Rv64imKernelChunkExportWitness {
        chunk_input: handoff.chunk_input.clone(),
        bridge_witness: handoff.bridge_witness.clone(),
        digest: [0; 32],
    };
    witness.digest = witness.expected_digest();
    witness
}

pub(crate) fn rv64im_public_chunk_digest(chunk: &PublicChunk) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/public_chunk");
    tr.append_u64s(
        b"rv64im/public_chunk/meta",
        &[chunk.start_index as u64, chunk.steps.len() as u64],
    );
    for step in &chunk.steps {
        tr.append_message(b"rv64im/public_chunk/step", &public_step_digest(step));
    }
    tr.digest32()
}

fn append_digest_vec(tr: &mut Poseidon2Transcript, label: &'static [u8], digests: &[[u8; 32]]) {
    tr.append_u64s(label, &[digests.len() as u64]);
    for digest in digests {
        tr.append_message(label, digest);
    }
}

fn append_chunk_surfaces(tr: &mut Poseidon2Transcript, surfaces: &[Rv64imChunkExportSurface]) {
    tr.append_u64s(
        b"rv64im/kernel_export_relation/chunk_surface_count",
        &[surfaces.len() as u64],
    );
    for surface in surfaces {
        tr.append_message(b"rv64im/kernel_export_relation/chunk_surface_digest", &surface.digest);
    }
}

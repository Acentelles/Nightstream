//! Owns the RV64IM decider relation seam between the owned folded/final relation and generic decider backends.

use crate::decider::spartan2::{
    build_spartan2_decider_relation, validate_spartan2_decider_relation_surface, Spartan2DeciderRelation,
};
use crate::finalize::digest32_as_fields;
use crate::rv64im::final_relation::{
    final_proof_component_digests, prove_rv64im_final_statement_from_accepted, recursive_seed,
    validate_rv64im_final_statement_surface, verify_rv64im_final_statement_with_output, Rv64imFinalProof,
    Rv64imFinalProofComponentDigests, Rv64imFinalStatement,
};
use crate::rv64im::kernel::{
    build_rv64im_accepted_proof_artifact, Rv64imKernelExportRelationResult, Rv64imProof, SimpleKernelError,
};

pub type Rv64imDeciderRelation = Spartan2DeciderRelation;

pub fn validate_rv64im_decider_relation_surface(relation: &Rv64imDeciderRelation) -> Result<(), SimpleKernelError> {
    validate_spartan2_decider_relation_surface(relation).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn build_rv64im_decider_relation(proof: &Rv64imProof) -> Result<Rv64imDeciderRelation, SimpleKernelError> {
    let artifact = build_rv64im_accepted_proof_artifact(proof)?;
    let (statement, final_proof) = prove_rv64im_final_statement_from_accepted(&artifact)?;
    build_rv64im_decider_relation_from_final(&statement, &final_proof)
}

pub fn verify_rv64im_decider_relation(
    relation: &Rv64imDeciderRelation,
    proof: &Rv64imProof,
) -> Result<(), SimpleKernelError> {
    let expected = build_rv64im_decider_relation(proof)?;
    if relation != &expected {
        return Err(SimpleKernelError::Bridge(
            "RV64IM decider relation does not match the carried public proof seam".into(),
        ));
    }
    Ok(())
}

pub fn build_rv64im_decider_relation_from_final(
    statement: &Rv64imFinalStatement,
    proof: &Rv64imFinalProof,
) -> Result<Rv64imDeciderRelation, SimpleKernelError> {
    validate_rv64im_final_statement_surface(statement, proof)?;
    let verified_kernel = verify_rv64im_final_statement_with_output(statement, proof)?;
    build_rv64im_decider_relation_from_verified_final(statement, proof, &verified_kernel)
}

pub(crate) fn build_rv64im_decider_relation_from_verified_final(
    statement: &Rv64imFinalStatement,
    proof: &Rv64imFinalProof,
    verified_kernel: &Rv64imKernelExportRelationResult,
) -> Result<Rv64imDeciderRelation, SimpleKernelError> {
    let component_digests = final_proof_component_digests(proof);
    build_rv64im_decider_relation_from_verified_final_with_component_digests(
        statement,
        proof,
        verified_kernel,
        &component_digests,
    )
}

pub(crate) fn build_rv64im_decider_relation_from_verified_final_with_component_digests(
    statement: &Rv64imFinalStatement,
    proof: &Rv64imFinalProof,
    verified_kernel: &Rv64imKernelExportRelationResult,
    component_digests: &Rv64imFinalProofComponentDigests,
) -> Result<Rv64imDeciderRelation, SimpleKernelError> {
    if statement.folded.chunk_count as usize != verified_kernel.chunk_handoffs.len() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM decider relation chunk count does not match verified kernel export handoffs".into(),
        ));
    }
    if statement.folded.chunk_count as usize != proof.chunk_summaries.len() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM decider relation chunk count does not match final proof chunk summaries".into(),
        ));
    }
    if statement.folded.chunk_count as usize != component_digests.chunk_transition_digests.len() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM decider relation chunk count does not match final proof replay witness".into(),
        ));
    }

    build_spartan2_decider_relation(
        statement.digest,
        statement.folded.digest,
        proof.proof_digest,
        digest32_as_fields(recursive_seed()),
        digest32_as_fields(statement.folded.final_accumulator.terminal_handle.0),
        statement.folded.fold_schedule,
        statement.folded.semantic_step_count,
        proof.chunk_summaries.clone(),
        vec![component_digests.kernel_export_proof_digest],
        component_digests.chunk_transition_digests.clone(),
    )
    .map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

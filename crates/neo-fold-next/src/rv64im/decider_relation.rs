//! Owns the RV64IM decider relation seam between the owned folded/final relation and generic decider backends.

use crate::decider::spartan2::{
    build_spartan2_decider_relation, validate_spartan2_decider_relation_surface, Spartan2DeciderRelation,
};
use crate::finalize::digest32_as_fields;
use crate::rv64im::final_relation::{
    final_proof_component_digests, final_proof_digest, final_statement_digest, folded_statement_digest,
    prove_rv64im_final_statement_from_accepted, recursive_seed, verify_rv64im_final_statement_with_output,
    Rv64imFinalProof, Rv64imFinalStatement,
};
use crate::rv64im::kernel::{build_rv64im_accepted_proof_artifact, Rv64imProof, SimpleKernelError};

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
    verify_rv64im_final_statement_with_output(statement, proof)?;
    let component_digests = final_proof_component_digests(proof);
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
        vec![
            component_digests.accepted_artifact_digest,
            component_digests.kernel_export_digest,
        ],
        component_digests.chunk_transition_digests,
    )
    .map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

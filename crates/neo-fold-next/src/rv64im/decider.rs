//! Owns RV64IM adapters from the owned final proof seam into generic decider targets.

use crate::decider::spartan2::{
    prove_spartan2_decider, setup_spartan2_decider, verify_spartan2_decider, Spartan2DeciderProof,
    Spartan2DeciderProverKey, Spartan2DeciderTarget, Spartan2DeciderVerifierKey,
};
use crate::rv64im::decider_relation::build_rv64im_decider_relation_from_final;
use crate::rv64im::final_relation::{
    prove_rv64im_final_statement_from_accepted, Rv64imFinalProof, Rv64imFinalStatement,
};
use crate::rv64im::kernel::{build_rv64im_accepted_proof_artifact, Rv64imProof};
use crate::rv64im::SimpleKernelError;

pub fn build_rv64im_spartan2_decider_target(
    statement: &Rv64imFinalStatement,
    proof: &Rv64imFinalProof,
) -> Result<Spartan2DeciderTarget, SimpleKernelError> {
    let relation = build_rv64im_decider_relation_from_final(statement, proof)?;
    Ok(relation.target())
}

pub fn setup_rv64im_spartan2_decider(
    statement: &Rv64imFinalStatement,
    proof: &Rv64imFinalProof,
) -> Result<(Spartan2DeciderProverKey, Spartan2DeciderVerifierKey), SimpleKernelError> {
    let target = build_rv64im_spartan2_decider_target(statement, proof)?;
    setup_spartan2_decider(&target.shape()).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn prove_rv64im_spartan2_decider(
    pk: &Spartan2DeciderProverKey,
    statement: &Rv64imFinalStatement,
    proof: &Rv64imFinalProof,
) -> Result<Spartan2DeciderProof, SimpleKernelError> {
    let target = build_rv64im_spartan2_decider_target(statement, proof)?;
    prove_spartan2_decider(pk, &target).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn verify_rv64im_spartan2_decider(
    vk: &Spartan2DeciderVerifierKey,
    statement: &Rv64imFinalStatement,
    proof: &Rv64imFinalProof,
    decider_proof: &Spartan2DeciderProof,
) -> Result<(), SimpleKernelError> {
    let target = build_rv64im_spartan2_decider_target(statement, proof)?;
    verify_spartan2_decider(vk, &target, decider_proof).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn setup_rv64im_spartan2_decider_from_public_proof(
    proof: &Rv64imProof,
) -> Result<(Spartan2DeciderProverKey, Spartan2DeciderVerifierKey), SimpleKernelError> {
    let artifact = build_rv64im_accepted_proof_artifact(proof)?;
    let (statement, final_proof) = prove_rv64im_final_statement_from_accepted(&artifact)?;
    setup_rv64im_spartan2_decider(&statement, &final_proof)
}

pub fn prove_rv64im_spartan2_decider_from_public_proof(
    pk: &Spartan2DeciderProverKey,
    proof: &Rv64imProof,
) -> Result<Spartan2DeciderProof, SimpleKernelError> {
    let artifact = build_rv64im_accepted_proof_artifact(proof)?;
    let (statement, final_proof) = prove_rv64im_final_statement_from_accepted(&artifact)?;
    prove_rv64im_spartan2_decider(pk, &statement, &final_proof)
}

pub fn verify_rv64im_spartan2_decider_from_public_proof(
    vk: &Spartan2DeciderVerifierKey,
    proof: &Rv64imProof,
    decider_proof: &Spartan2DeciderProof,
) -> Result<(), SimpleKernelError> {
    let artifact = build_rv64im_accepted_proof_artifact(proof)?;
    let (statement, final_proof) = prove_rv64im_final_statement_from_accepted(&artifact)?;
    verify_rv64im_spartan2_decider(vk, &statement, &final_proof, decider_proof)
}

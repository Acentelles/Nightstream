//! Owns RV64IM adapters from the owned final proof seam into generic decider targets.

use std::time::Instant;

use crate::decider::spartan2::{
    prove_spartan2_decider, prove_spartan2_decider_with_perf, setup_spartan2_decider, verify_spartan2_decider,
    Spartan2DeciderProof, Spartan2DeciderProvePerf, Spartan2DeciderProverKey, Spartan2DeciderTarget,
    Spartan2DeciderVerifierKey,
};
use crate::rv64im::decider_relation::build_rv64im_decider_relation_from_final;
use crate::rv64im::final_relation::{
    prove_rv64im_final_statement_from_accepted_with_output_and_perf_and_source, Rv64imFinalBuildOutput,
    Rv64imFinalProof, Rv64imFinalProofComponentDigests, Rv64imFinalStatement,
};
use crate::rv64im::kernel::{
    build_rv64im_accepted_proof_artifact, build_rv64im_kernel_export_source_from_accepted_artifact,
    Rv64imAcceptedProofArtifact, Rv64imKernelExportRelationResult, Rv64imKernelExportSource, Rv64imProof,
};
use crate::rv64im::SimpleKernelError;

#[derive(Clone, Copy, Debug, Default)]
pub struct Rv64imPublishedProofSeamBuildPerf {
    pub accepted_artifact_ms: f64,
    pub kernel_export_source_ms: f64,
    pub final_statement_ms: f64,
    pub final_statement_kernel_export_ms: f64,
    pub final_statement_recursive_proof_ms: f64,
    pub final_statement_recursive_prepare_inputs_ms: f64,
    pub final_statement_recursive_ccs_bind_ms: f64,
    pub final_statement_recursive_ccs_sample_challenges_ms: f64,
    pub final_statement_recursive_ccs_fe_sumcheck_ms: f64,
    pub final_statement_recursive_ccs_nc_sumcheck_ms: f64,
    pub final_statement_recursive_ccs_output_materialize_ms: f64,
    pub final_statement_recursive_ccs_ms: f64,
    pub final_statement_recursive_dims_ms: f64,
    pub final_statement_recursive_rlc_prepare_ms: f64,
    pub final_statement_recursive_rlc_ms: f64,
    pub final_statement_recursive_dec_split_ms: f64,
    pub final_statement_recursive_dec_commit_ms: f64,
    pub final_statement_recursive_dec_ms: f64,
    pub final_statement_folded_digest_ms: f64,
    pub final_statement_final_proof_ms: f64,
    pub final_statement_statement_digest_ms: f64,
    pub decider_target_ms: f64,
    pub total_ms: f64,
}

#[derive(Clone, Debug)]
pub struct Rv64imPublishedProofSeam {
    pub accepted_artifact: Rv64imAcceptedProofArtifact,
    pub final_statement: Rv64imFinalStatement,
    pub final_proof: Rv64imFinalProof,
    pub decider_target: Spartan2DeciderTarget,
    pub(crate) final_component_digests: Rv64imFinalProofComponentDigests,
    pub(crate) verified_kernel: Rv64imKernelExportRelationResult,
    kernel_export_source: Rv64imKernelExportSource,
}

impl Rv64imPublishedProofSeam {
    pub fn kernel_export_source(&self) -> &Rv64imKernelExportSource {
        &self.kernel_export_source
    }
}

fn elapsed_ms(started: Instant) -> f64 {
    started.elapsed().as_secs_f64() * 1_000.0
}

pub fn build_rv64im_published_proof_seam(proof: &Rv64imProof) -> Result<Rv64imPublishedProofSeam, SimpleKernelError> {
    let (built, _) = build_rv64im_published_proof_seam_with_perf(proof)?;
    Ok(built)
}

pub fn build_rv64im_published_proof_seam_with_perf(
    proof: &Rv64imProof,
) -> Result<(Rv64imPublishedProofSeam, Rv64imPublishedProofSeamBuildPerf), SimpleKernelError> {
    let total_started = Instant::now();

    let started = Instant::now();
    let accepted_artifact = build_rv64im_accepted_proof_artifact(proof)?;
    let accepted_artifact_ms = elapsed_ms(started);

    let started = Instant::now();
    let kernel_export_source = build_rv64im_kernel_export_source_from_accepted_artifact(&accepted_artifact)?;
    let kernel_export_source_ms = elapsed_ms(started);

    let started = Instant::now();
    let (
        Rv64imFinalBuildOutput {
            statement: final_statement,
            proof: final_proof,
            component_digests: final_component_digests,
            verified_kernel,
        },
        final_perf,
    ) = prove_rv64im_final_statement_from_accepted_with_output_and_perf_and_source(
        &accepted_artifact,
        Some(&kernel_export_source),
    )?;
    let final_statement_ms = elapsed_ms(started);

    let started = Instant::now();
    let decider_target = build_rv64im_spartan2_decider_target(&final_statement, &final_proof)?;
    let decider_target_ms = elapsed_ms(started);

    Ok((
        Rv64imPublishedProofSeam {
            accepted_artifact,
            final_statement,
            final_proof,
            decider_target,
            final_component_digests,
            verified_kernel,
            kernel_export_source,
        },
        Rv64imPublishedProofSeamBuildPerf {
            accepted_artifact_ms,
            kernel_export_source_ms,
            final_statement_ms,
            final_statement_kernel_export_ms: final_perf.folded.kernel_export_ms,
            final_statement_recursive_proof_ms: final_perf.folded.recursive.total_ms,
            final_statement_recursive_prepare_inputs_ms: final_perf.folded.recursive.prepare_inputs_ms,
            final_statement_recursive_ccs_bind_ms: final_perf.folded.recursive.ccs_bind_ms,
            final_statement_recursive_ccs_sample_challenges_ms: final_perf.folded.recursive.ccs_sample_challenges_ms,
            final_statement_recursive_ccs_fe_sumcheck_ms: final_perf.folded.recursive.ccs_fe_sumcheck_ms,
            final_statement_recursive_ccs_nc_sumcheck_ms: final_perf.folded.recursive.ccs_nc_sumcheck_ms,
            final_statement_recursive_ccs_output_materialize_ms: final_perf.folded.recursive.ccs_output_materialize_ms,
            final_statement_recursive_ccs_ms: final_perf.folded.recursive.ccs_ms,
            final_statement_recursive_dims_ms: final_perf.folded.recursive.dims_ms,
            final_statement_recursive_rlc_prepare_ms: final_perf.folded.recursive.rlc_prepare_ms,
            final_statement_recursive_rlc_ms: final_perf.folded.recursive.rlc_ms,
            final_statement_recursive_dec_split_ms: final_perf.folded.recursive.dec_split_ms,
            final_statement_recursive_dec_commit_ms: final_perf.folded.recursive.dec_commit_ms,
            final_statement_recursive_dec_ms: final_perf.folded.recursive.dec_ms,
            final_statement_folded_digest_ms: final_perf.folded.folded_digest_ms,
            final_statement_final_proof_ms: final_perf.final_proof_ms,
            final_statement_statement_digest_ms: final_perf.statement_digest_ms,
            decider_target_ms,
            total_ms: elapsed_ms(total_started),
        },
    ))
}

pub fn build_rv64im_spartan2_decider_target(
    statement: &Rv64imFinalStatement,
    proof: &Rv64imFinalProof,
) -> Result<Spartan2DeciderTarget, SimpleKernelError> {
    let relation = build_rv64im_decider_relation_from_final(statement, proof)?;
    Ok(relation.target())
}

pub fn setup_rv64im_spartan2_decider_for_target(
    target: &Spartan2DeciderTarget,
) -> Result<(Spartan2DeciderProverKey, Spartan2DeciderVerifierKey), SimpleKernelError> {
    setup_spartan2_decider(&target.shape()).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn setup_rv64im_spartan2_decider(
    statement: &Rv64imFinalStatement,
    proof: &Rv64imFinalProof,
) -> Result<(Spartan2DeciderProverKey, Spartan2DeciderVerifierKey), SimpleKernelError> {
    let target = build_rv64im_spartan2_decider_target(statement, proof)?;
    setup_rv64im_spartan2_decider_for_target(&target)
}

pub fn prove_rv64im_spartan2_decider_for_target(
    pk: &Spartan2DeciderProverKey,
    target: &Spartan2DeciderTarget,
) -> Result<Spartan2DeciderProof, SimpleKernelError> {
    prove_spartan2_decider(pk, target).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn prove_rv64im_spartan2_decider_for_target_with_perf(
    pk: &Spartan2DeciderProverKey,
    target: &Spartan2DeciderTarget,
) -> Result<(Spartan2DeciderProof, Spartan2DeciderProvePerf), SimpleKernelError> {
    prove_spartan2_decider_with_perf(pk, target).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn prove_rv64im_spartan2_decider(
    pk: &Spartan2DeciderProverKey,
    statement: &Rv64imFinalStatement,
    proof: &Rv64imFinalProof,
) -> Result<Spartan2DeciderProof, SimpleKernelError> {
    let target = build_rv64im_spartan2_decider_target(statement, proof)?;
    prove_rv64im_spartan2_decider_for_target(pk, &target)
}

pub fn verify_rv64im_spartan2_decider_for_target(
    vk: &Spartan2DeciderVerifierKey,
    target: &Spartan2DeciderTarget,
    decider_proof: &Spartan2DeciderProof,
) -> Result<(), SimpleKernelError> {
    verify_spartan2_decider(vk, target, decider_proof).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn verify_rv64im_spartan2_decider(
    vk: &Spartan2DeciderVerifierKey,
    statement: &Rv64imFinalStatement,
    proof: &Rv64imFinalProof,
    decider_proof: &Spartan2DeciderProof,
) -> Result<(), SimpleKernelError> {
    let target = build_rv64im_spartan2_decider_target(statement, proof)?;
    verify_rv64im_spartan2_decider_for_target(vk, &target, decider_proof)
}

pub fn setup_rv64im_spartan2_decider_from_public_proof(
    proof: &Rv64imProof,
) -> Result<(Spartan2DeciderProverKey, Spartan2DeciderVerifierKey), SimpleKernelError> {
    let built = build_rv64im_published_proof_seam(proof)?;
    setup_rv64im_spartan2_decider_for_target(&built.decider_target)
}

pub fn prove_rv64im_spartan2_decider_from_public_proof(
    pk: &Spartan2DeciderProverKey,
    proof: &Rv64imProof,
) -> Result<Spartan2DeciderProof, SimpleKernelError> {
    let built = build_rv64im_published_proof_seam(proof)?;
    prove_rv64im_spartan2_decider_for_target(pk, &built.decider_target)
}

pub fn verify_rv64im_spartan2_decider_from_public_proof(
    vk: &Spartan2DeciderVerifierKey,
    proof: &Rv64imProof,
    decider_proof: &Spartan2DeciderProof,
) -> Result<(), SimpleKernelError> {
    let built = build_rv64im_published_proof_seam(proof)?;
    verify_rv64im_spartan2_decider_for_target(vk, &built.decider_target, decider_proof)
}

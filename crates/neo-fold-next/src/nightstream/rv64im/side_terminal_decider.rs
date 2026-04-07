//! Owns the below-export RV64IM side-terminal decider-target adapter.
//!
//! This does not compress the hidden theorem witness yet. It only maps the
//! fixed-shape side-terminal theorem statement into the generic Spartan2
//! decider target seam so the eventual compact proof has one exact target.

use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{de::DeserializeOwned, Deserialize, Serialize};
use spartan2::traits::snark::DigestHelperTrait;
use std::{
    collections::HashMap,
    sync::{Arc, Mutex, OnceLock},
};

use crate::decider::spartan2::{
    build_spartan2_self_bound_decider_relation, prove_spartan2_backend_binding_shell,
    prove_spartan2_public_relation_shell, prove_spartan2_public_target_shell, setup_spartan2_backend_binding_shell,
    setup_spartan2_public_relation_shell, setup_spartan2_public_target_shell, verify_spartan2_backend_binding_shell,
    verify_spartan2_public_relation_shell, verify_spartan2_public_target_shell, Spartan2BackendBindingShellProof,
    Spartan2BackendBindingShellProverKey, Spartan2BackendBindingShellVerifierKey, Spartan2DeciderBackendRelation,
    Spartan2DeciderRelation, Spartan2DeciderTarget, Spartan2PublicRelationShellProof,
    Spartan2PublicRelationShellProverKey, Spartan2PublicRelationShellVerifierKey, Spartan2PublicTargetShellProof,
    Spartan2PublicTargetShellProverKey, Spartan2PublicTargetShellVerifierKey,
};
use crate::finalize::digest32_as_fields;
use crate::nightstream::NightstreamStatement;
use crate::rv64im::kernel::{
    Rv64imAcceptedProofArtifact, Rv64imProof, Rv64imProofStatement, Rv64imStageClaimDigestBundle, SimpleKernelError,
};

use super::side_terminal_relation::rv64im_side_terminal_relation_statement_digest;
use super::{
    build_rv64im_kernel_opening_claim_from_side_proof_bundle, build_rv64im_nightstream_from_public_proof,
    build_rv64im_side_terminal_relation_statement, build_rv64im_side_terminal_relation_witness_from_accepted_artifact,
    build_rv64im_stage_claim_bundle_from_side_proof_bundle,
    compact_surfaces::kernel_claim_summary_digest_from_surfaces,
    compact_surfaces::kernel_opening_binding_bundle_digest_from_surfaces,
    compact_surfaces::kernel_opening_bundle_digest_from_surfaces,
    compact_surfaces::kernel_opening_proof_bundle_digest_from_surfaces,
    compact_surfaces::packaged_claim_proof_digest_from_surfaces,
    compact_surfaces::stage_package_proof_bundle_digest_from_surfaces, verify_rv64im_side_terminal_witness_artifact,
    Rv64imNightstreamProof, Rv64imSideProofBundle, Rv64imSideTerminalRelationStatement,
    Rv64imSideTerminalWitnessArtifact,
};

pub type Rv64imSideTerminalDeciderRelation = Spartan2DeciderRelation;
pub type Rv64imSideTerminalBackendBindingRelation = Spartan2DeciderBackendRelation;
pub type Rv64imSideTerminalBackendBindingShellProof = Spartan2BackendBindingShellProof;
pub type Rv64imSideTerminalBackendBindingShellProverKey = Spartan2BackendBindingShellProverKey;
pub type Rv64imSideTerminalBackendBindingShellVerifierKey = Spartan2BackendBindingShellVerifierKey;
pub type Rv64imSideTerminalPublicRelationShellProof = Spartan2PublicRelationShellProof;
pub type Rv64imSideTerminalPublicRelationShellProverKey = Spartan2PublicRelationShellProverKey;
pub type Rv64imSideTerminalPublicRelationShellVerifierKey = Spartan2PublicRelationShellVerifierKey;
pub type Rv64imSideTerminalPublicTargetShellProof = Spartan2PublicTargetShellProof;
pub type Rv64imSideTerminalPublicTargetShellProverKey = Spartan2PublicTargetShellProverKey;
pub type Rv64imSideTerminalPublicTargetShellVerifierKey = Spartan2PublicTargetShellVerifierKey;
pub type Rv64imSideTerminalBackendProofProverKey = Spartan2BackendBindingShellProverKey;
pub type Rv64imSideTerminalBackendProofVerifierKey = Spartan2BackendBindingShellVerifierKey;

#[derive(Clone)]
struct CachedBackendBindingShellKeys {
    // Keep the live keys so the verifier key retains its internal digest cache
    // across Nightstream build -> verify within one process.
    pk: Arc<Rv64imSideTerminalBackendBindingShellProverKey>,
    vk: Arc<Rv64imSideTerminalBackendBindingShellVerifierKey>,
}

static SIDE_TERMINAL_BACKEND_BINDING_SHELL_KEYS: OnceLock<Mutex<HashMap<[u8; 32], CachedBackendBindingShellKeys>>> =
    OnceLock::new();

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Rv64imSideTerminalBackendProof {
    pub shape_digest: [u8; 32],
    pub snark_data: Vec<u8>,
}

impl Rv64imSideTerminalBackendProof {
    pub fn digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/nightstream/rv64im/side_terminal_backend_proof");
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/side_terminal_backend_proof/version",
            b"v1",
        );
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/side_terminal_backend_proof/shape_digest",
            &self.shape_digest,
        );
        tr.append_u64s(
            b"neo.fold.next/nightstream/rv64im/side_terminal_backend_proof/snark_bytes_len",
            &[self.snark_data.len() as u64],
        );
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/side_terminal_backend_proof/snark_bytes",
            &self.snark_data,
        );
        tr.digest32()
    }

    pub fn snark_bytes_len(&self) -> usize {
        self.snark_data.len()
    }

    fn as_shell_proof(&self) -> Spartan2BackendBindingShellProof {
        Spartan2BackendBindingShellProof {
            snark_data: self.snark_data.clone(),
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Rv64imSideTerminalProofArtifact {
    pub witness_artifact: Rv64imSideTerminalWitnessArtifact,
    pub backend_proof: Rv64imSideTerminalBackendProof,
    pub digest: [u8; 32],
}

impl Rv64imSideTerminalProofArtifact {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/nightstream/rv64im/side_terminal_proof_artifact");
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/side_terminal_proof_artifact/version",
            b"v1",
        );
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/side_terminal_proof_artifact/witness_artifact_digest",
            &self.witness_artifact.digest,
        );
        tr.append_message(
            b"neo.fold.next/nightstream/rv64im/side_terminal_proof_artifact/backend_proof_digest",
            &self.backend_proof.digest(),
        );
        tr.digest32()
    }
}

fn rv64im_side_terminal_cached_backend_binding_shell_keys(
    shape: &crate::decider::spartan2::Spartan2DeciderShape,
) -> Result<
    (
        Arc<Rv64imSideTerminalBackendBindingShellProverKey>,
        Arc<Rv64imSideTerminalBackendBindingShellVerifierKey>,
    ),
    SimpleKernelError,
> {
    let shape_digest = shape.digest();
    let cache = SIDE_TERMINAL_BACKEND_BINDING_SHELL_KEYS.get_or_init(|| Mutex::new(HashMap::new()));
    if let Some(cached) = cache
        .lock()
        .map_err(|_| SimpleKernelError::Bridge("RV64IM side-terminal backend shell key cache lock poisoned".into()))?
        .get(&shape_digest)
        .cloned()
    {
        return Ok((cached.pk, cached.vk));
    }

    let (pk, vk) =
        setup_spartan2_backend_binding_shell(shape).map_err(|err| SimpleKernelError::Bridge(err.to_string()))?;
    let cached = CachedBackendBindingShellKeys {
        pk: Arc::new(pk),
        vk: Arc::new(vk),
    };
    let (pk, vk) = (Arc::clone(&cached.pk), Arc::clone(&cached.vk));
    cache
        .lock()
        .map_err(|_| SimpleKernelError::Bridge("RV64IM side-terminal backend shell key cache lock poisoned".into()))?
        .entry(shape_digest)
        .or_insert(cached);
    Ok((pk, vk))
}

fn clone_cached_backend_binding_shell_key<T: Serialize + DeserializeOwned>(
    value: &T,
    label: &str,
) -> Result<T, SimpleKernelError> {
    let encoded = bincode::serialize(value).map_err(|err| {
        SimpleKernelError::Bridge(format!(
            "RV64IM side-terminal backend shell {label} cache clone encode failed: {err}"
        ))
    })?;
    bincode::deserialize(&encoded).map_err(|err| {
        SimpleKernelError::Bridge(format!(
            "RV64IM side-terminal backend shell {label} cache clone decode failed: {err}"
        ))
    })
}

fn rv64im_side_terminal_backend_binding_shell_keys_for_setup(
    shape: &crate::decider::spartan2::Spartan2DeciderShape,
) -> Result<
    (
        Rv64imSideTerminalBackendBindingShellProverKey,
        Rv64imSideTerminalBackendBindingShellVerifierKey,
    ),
    SimpleKernelError,
> {
    let (pk, vk) = rv64im_side_terminal_cached_backend_binding_shell_keys(shape)?;
    let vk = clone_cached_backend_binding_shell_key(&*vk, "verifier key")?;
    vk.digest().map_err(|err| {
        SimpleKernelError::Bridge(format!(
            "RV64IM side-terminal backend shell verifier key digest precompute failed: {err}"
        ))
    })?;
    Ok((clone_cached_backend_binding_shell_key(&*pk, "prover key")?, vk))
}

fn rv64im_side_terminal_stage_package_proof_bundle_digest(
    statement: &Rv64imSideTerminalRelationStatement,
) -> Result<[u8; 32], SimpleKernelError> {
    let digest = stage_package_proof_bundle_digest_from_surfaces(
        statement.side_bundle.stage1.packaged_digest,
        statement.side_bundle.stage2.packaged_digest,
        statement.side_bundle.stage3.packaged_digest,
    );
    if digest != statement.public_statement.stage_packages_digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal decider relation compact stage-package proof surface does not match the carried RV64IM public statement"
                .into(),
        ));
    }
    Ok(digest)
}

fn rv64im_side_terminal_stage_claim_proof_bundle_digest(
    statement: &Rv64imSideTerminalRelationStatement,
) -> Result<[u8; 32], SimpleKernelError> {
    let claims = build_rv64im_stage_claim_bundle_from_side_proof_bundle(
        &statement.side_bundle,
        statement.public_statement.execution_digest,
    )?;
    let summary = Rv64imStageClaimDigestBundle {
        claim_bundle_digest: claims.digest,
        stage1_digest: claims.stage1.rows.digest,
        stage2_digest: claims.stage2.families.digest,
        stage3_digest: claims.stage3.continuity.digest,
        transcript_digest: claims.transcript.commitment.digest,
        execution_digest: claims.execution_digest,
        digest: [0; 32],
    };
    let summary = Rv64imStageClaimDigestBundle {
        digest: summary.expected_digest(),
        ..summary
    };
    let digest = packaged_claim_proof_digest_from_surfaces(
        b"neo.fold.next/rv64im/stage_claim_proof_bundle",
        summary.digest,
        statement
            .side_bundle
            .stage_claim_proof_bridge
            .packaged_statement_digest,
        statement
            .side_bundle
            .stage_claim_proof_bridge
            .packaged_proof_digest,
    );
    if digest
        != statement
            .side_bundle
            .stage_claim_proof_bridge
            .stage_claim_proof_bundle_digest
        || digest != statement.public_statement.stage_claims_digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal decider relation compact stage-claim proof surface does not match the carried RV64IM public statement"
                .into(),
        ));
    }
    Ok(digest)
}

fn rv64im_side_terminal_kernel_opening_proof_bundle_digest(
    statement: &Rv64imSideTerminalRelationStatement,
) -> Result<[u8; 32], SimpleKernelError> {
    let claim =
        build_rv64im_kernel_opening_claim_from_side_proof_bundle(&statement.side_bundle, &statement.public_statement)?;
    let opening_digest = kernel_opening_bundle_digest_from_surfaces(
        claim.digest,
        statement
            .side_bundle
            .kernel_opening_bridge
            .bindings_opening_digest,
        statement
            .side_bundle
            .kernel_opening_bridge
            .prepared_steps_opening_digest,
    );
    let binding_digest = kernel_opening_binding_bundle_digest_from_surfaces(
        claim.digest,
        statement
            .side_bundle
            .kernel_opening_bridge
            .bindings_opening_digest,
        statement
            .side_bundle
            .kernel_opening_bridge
            .prepared_steps_opening_digest,
    );
    let digest = kernel_opening_proof_bundle_digest_from_surfaces(opening_digest, binding_digest);
    if digest != statement.public_statement.kernel_opening_digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal decider relation compact kernel-opening proof surface does not match the carried RV64IM public statement"
                .into(),
        ));
    }
    Ok(digest)
}

fn rv64im_side_terminal_kernel_claim_proof_bundle_digest(
    statement: &Rv64imSideTerminalRelationStatement,
) -> Result<[u8; 32], SimpleKernelError> {
    let summary_digest = kernel_claim_summary_digest_from_surfaces(
        statement.public_statement.prepared_step_bindings_digest,
        statement.side_bundle.kernel_claim_bridge.root0_digest,
        statement.public_statement.execution_digest,
        statement.public_statement.final_state_digest,
        statement.public_statement.transcript_final_digest,
        statement.public_statement.final_pc,
        statement.public_statement.halted,
    );
    let digest = packaged_claim_proof_digest_from_surfaces(
        b"neo.fold.next/rv64im/kernel_claim_proof_bundle",
        summary_digest,
        statement
            .side_bundle
            .kernel_claim_proof_bridge
            .packaged_statement_digest,
        statement
            .side_bundle
            .kernel_claim_proof_bridge
            .packaged_proof_digest,
    );
    if digest
        != statement
            .side_bundle
            .kernel_claim_proof_bridge
            .kernel_claim_proof_bundle_digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal decider relation compact kernel-claim proof surface does not match the carried RV64IM public statement"
                .into(),
        ));
    }
    Ok(digest)
}

fn rv64im_side_terminal_base_component_digests(
    statement: &Rv64imSideTerminalRelationStatement,
) -> Result<Vec<[u8; 32]>, SimpleKernelError> {
    Ok(vec![
        rv64im_side_terminal_stage_claim_proof_bundle_digest(statement)?,
        rv64im_side_terminal_stage_package_proof_bundle_digest(statement)?,
        rv64im_side_terminal_kernel_opening_proof_bundle_digest(statement)?,
        rv64im_side_terminal_kernel_claim_proof_bundle_digest(statement)?,
    ])
}

fn validate_rv64im_side_terminal_decider_inputs(
    nightstream_statement: &NightstreamStatement,
    statement: &Rv64imSideTerminalRelationStatement,
    bridge_handoff_digests: &[[u8; 32]],
) -> Result<(), SimpleKernelError> {
    if statement.public_statement.digest != statement.public_statement.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal decider relation public statement digest mismatch".into(),
        ));
    }
    if statement.side_bundle.digest != statement.side_bundle.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal decider relation side-proof bundle digest mismatch".into(),
        ));
    }
    if nightstream_statement.public_io_digest != statement.public_statement.digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal decider relation Nightstream public IO does not match the carried RV64IM statement"
                .into(),
        ));
    }
    if statement.side_bundle.statement_core_digest != nightstream_statement.core_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal decider relation side-proof bundle does not match the carried Nightstream statement core"
                .into(),
        ));
    }
    if nightstream_statement.fold_schedule != statement.public_statement.fold_schedule {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal decider relation fold schedule does not match the carried Nightstream statement"
                .into(),
        ));
    }
    if nightstream_statement.chunk_summaries.len() as u64 != statement.public_statement.chunk_count {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal decider relation chunk count does not match the carried Nightstream statement".into(),
        ));
    }
    let public_step_count = crate::finalize::fixed_shape_chunk_coverage_terminal_index(
        &nightstream_statement.chunk_summaries,
    )
    .map_err(|err| {
        SimpleKernelError::Bridge(format!(
            "RV64IM side-terminal decider relation Nightstream chunk summaries are not contiguous: {err}"
        ))
    })?;
    if public_step_count != statement.public_statement.public_step_count {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal decider relation public-step count does not match the carried Nightstream statement"
                .into(),
        ));
    }
    if bridge_handoff_digests.len() != nightstream_statement.chunk_summaries.len() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal decider relation handoff count does not match the carried Nightstream chunk summaries"
                .into(),
        ));
    }
    Ok(())
}

fn build_rv64im_side_terminal_decider_relation_from_base_component_digests(
    nightstream_statement: &NightstreamStatement,
    statement: &Rv64imSideTerminalRelationStatement,
    bridge_handoff_digests: &[[u8; 32]],
    base_component_digests: Vec<[u8; 32]>,
) -> Result<Rv64imSideTerminalDeciderRelation, SimpleKernelError> {
    validate_rv64im_side_terminal_decider_inputs(nightstream_statement, statement, bridge_handoff_digests)?;

    // Bind the side-terminal theorem to the Nightstream statement core. The
    // proof-binding root then commits to the theorem artifact digest on top of
    // that core without introducing a circular dependency.
    let public_statement_digest = nightstream_statement.core_digest();
    let relation_digest = rv64im_side_terminal_relation_statement_digest(statement);
    let initial_handle_digest = digest32_as_fields(nightstream_statement.core_digest());

    build_spartan2_self_bound_decider_relation(
        public_statement_digest,
        relation_digest,
        initial_handle_digest,
        nightstream_statement.fold_schedule,
        nightstream_statement.semantic_step_count,
        nightstream_statement.chunk_summaries.clone(),
        base_component_digests,
        bridge_handoff_digests.to_vec(),
    )
    .map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn build_rv64im_side_terminal_decider_relation(
    nightstream_statement: &NightstreamStatement,
    statement: &Rv64imSideTerminalRelationStatement,
    bridge_handoff_digests: &[[u8; 32]],
) -> Result<Rv64imSideTerminalDeciderRelation, SimpleKernelError> {
    let base_component_digests = rv64im_side_terminal_base_component_digests(statement)?;
    build_rv64im_side_terminal_decider_relation_from_base_component_digests(
        nightstream_statement,
        statement,
        bridge_handoff_digests,
        base_component_digests,
    )
}

pub(super) fn prove_rv64im_side_terminal_backend_proof_from_decider_relation(
    relation: &Rv64imSideTerminalDeciderRelation,
) -> Result<Rv64imSideTerminalBackendProof, SimpleKernelError> {
    let shape = relation.backend_shape();
    let backend_relation = relation.backend_relation();
    let (pk, _) = rv64im_side_terminal_cached_backend_binding_shell_keys(&shape)?;
    let shell = prove_spartan2_backend_binding_shell(&pk, &backend_relation)
        .map_err(|err| SimpleKernelError::Bridge(err.to_string()))?;
    Ok(Rv64imSideTerminalBackendProof {
        shape_digest: shape.digest(),
        snark_data: shell.snark_data,
    })
}

pub(super) fn prewarm_rv64im_side_terminal_backend_binding_shell_cache_for_relation(
    relation: &Rv64imSideTerminalDeciderRelation,
) -> Result<(), SimpleKernelError> {
    let shape = relation.backend_shape();
    let _ = rv64im_side_terminal_cached_backend_binding_shell_keys(&shape)?;
    Ok(())
}

fn prove_rv64im_side_terminal_backend_proof_from_relation(
    nightstream_statement: &NightstreamStatement,
    relation_statement: &Rv64imSideTerminalRelationStatement,
    bridge_handoff_digests: &[[u8; 32]],
) -> Result<Rv64imSideTerminalBackendProof, SimpleKernelError> {
    let relation =
        build_rv64im_side_terminal_decider_relation(nightstream_statement, relation_statement, bridge_handoff_digests)?;
    prove_rv64im_side_terminal_backend_proof_from_decider_relation(&relation)
}

fn rv64im_side_terminal_proof_artifact_from_parts(
    witness_artifact: Rv64imSideTerminalWitnessArtifact,
    backend_proof: Rv64imSideTerminalBackendProof,
) -> Rv64imSideTerminalProofArtifact {
    let mut artifact = Rv64imSideTerminalProofArtifact {
        witness_artifact,
        backend_proof,
        digest: [0; 32],
    };
    artifact.digest = artifact.expected_digest();
    artifact
}

pub(super) fn build_rv64im_side_terminal_proof_material_from_accepted_artifact(
    nightstream_statement: &NightstreamStatement,
    bridge_handoff_digests: &[[u8; 32]],
    public_statement: &Rv64imProofStatement,
    side_bundle: &Rv64imSideProofBundle,
    accepted_artifact: &Rv64imAcceptedProofArtifact,
) -> Result<(Rv64imSideTerminalWitnessArtifact, Rv64imSideTerminalDeciderRelation), SimpleKernelError> {
    let relation_statement = build_rv64im_side_terminal_relation_statement(public_statement, side_bundle)?;
    let (witness_artifact, base_component_digests) =
        rv64im_side_terminal_fast_path_from_accepted_artifact(&relation_statement, accepted_artifact)?;
    let relation = build_rv64im_side_terminal_decider_relation_from_base_component_digests(
        nightstream_statement,
        &relation_statement,
        bridge_handoff_digests,
        base_component_digests,
    )?;
    Ok((witness_artifact, relation))
}

pub(super) fn assemble_rv64im_side_terminal_proof_artifact(
    witness_artifact: Rv64imSideTerminalWitnessArtifact,
    backend_proof: Rv64imSideTerminalBackendProof,
) -> Rv64imSideTerminalProofArtifact {
    rv64im_side_terminal_proof_artifact_from_parts(witness_artifact, backend_proof)
}

fn guard_rv64im_side_terminal_relation_statement_against_accepted_artifact(
    statement: &Rv64imSideTerminalRelationStatement,
    accepted_artifact: &Rv64imAcceptedProofArtifact,
) -> Result<(), SimpleKernelError> {
    if statement.public_statement.digest != accepted_artifact.statement.digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal accepted-artifact fast path public statement does not match the carried accepted artifact"
                .into(),
        ));
    }
    if statement.public_statement.stage_claims_digest != accepted_artifact.stage_claims.digest
        || statement.public_statement.stage_packages_digest != accepted_artifact.stage_packages.digest
        || statement.public_statement.kernel_opening_digest != accepted_artifact.kernel_opening.digest
        || statement.public_statement.prepared_step_bindings_digest
            != accepted_artifact
                .kernel_claims
                .prepared_step_bindings_digest()
        || statement.public_statement.execution_digest != accepted_artifact.kernel_claims.execution_digest()
        || statement.public_statement.final_state_digest != accepted_artifact.kernel_claims.final_state_digest()
        || statement.public_statement.transcript_final_digest
            != accepted_artifact.kernel_claims.transcript_final_digest()
        || statement.public_statement.final_pc != accepted_artifact.kernel_claims.final_pc()
        || statement.public_statement.halted != accepted_artifact.kernel_claims.halted()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal accepted-artifact fast path public statement component digests do not match the carried accepted artifact"
                .into(),
        ));
    }

    let stage_package_digest = stage_package_proof_bundle_digest_from_surfaces(
        statement.side_bundle.stage1.packaged_digest,
        statement.side_bundle.stage2.packaged_digest,
        statement.side_bundle.stage3.packaged_digest,
    );
    if stage_package_digest != accepted_artifact.stage_packages.digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal accepted-artifact fast path stage-package bridge does not match the carried accepted artifact"
                .into(),
        ));
    }
    if statement
        .side_bundle
        .stage_claim_proof_bridge
        .packaged_statement_digest
        != accepted_artifact.stage_claims.packaged.statement.digest
        || statement
            .side_bundle
            .stage_claim_proof_bridge
            .packaged_proof_digest
            != accepted_artifact.stage_claims.packaged.proof.proof_digest
        || statement
            .side_bundle
            .stage_claim_proof_bridge
            .stage_claim_proof_bundle_digest
            != accepted_artifact.stage_claims.digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal accepted-artifact fast path stage-claim bridge does not match the carried accepted artifact"
                .into(),
        ));
    }
    if statement
        .side_bundle
        .kernel_opening_bridge
        .prepared_step_bindings
        .binding_count
        != accepted_artifact
            .root_execution
            .prepared_step_bindings
            .binding_count
        || statement
            .side_bundle
            .kernel_opening_bridge
            .prepared_step_bindings
            .first_binding_digest
            != accepted_artifact
                .root_execution
                .prepared_step_bindings
                .first_binding_digest
        || statement
            .side_bundle
            .kernel_opening_bridge
            .prepared_step_bindings
            .last_binding_digest
            != accepted_artifact
                .root_execution
                .prepared_step_bindings
                .last_binding_digest
        || statement
            .side_bundle
            .kernel_opening_bridge
            .root_lane_commitment
            .digest
            != accepted_artifact.root_lane_commitment.digest
        || statement
            .side_bundle
            .kernel_opening_bridge
            .bindings_opening_digest
            != accepted_artifact.kernel_opening.opening.bindings.digest
        || statement
            .side_bundle
            .kernel_opening_bridge
            .prepared_steps_opening_digest
            != accepted_artifact
                .kernel_opening
                .opening
                .prepared_steps
                .digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal accepted-artifact fast path kernel-opening bridge does not match the carried accepted artifact"
                .into(),
        ));
    }
    if statement.side_bundle.kernel_claim_bridge.stage1_digest
        != accepted_artifact.kernel_claims.claims.kernel.stage1_digest
        || statement.side_bundle.kernel_claim_bridge.stage2_digest
            != accepted_artifact.kernel_claims.claims.kernel.stage2_digest
        || statement.side_bundle.kernel_claim_bridge.stage3_digest
            != accepted_artifact.kernel_claims.claims.kernel.stage3_digest
        || statement.side_bundle.kernel_claim_bridge.root0_digest != accepted_artifact.kernel_claims.root0_digest()
        || statement
            .side_bundle
            .kernel_claim_bridge
            .kernel_claim_bundle_digest
            != accepted_artifact.claim.digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal accepted-artifact fast path kernel-claim bridge does not match the carried accepted artifact"
                .into(),
        ));
    }
    if statement
        .side_bundle
        .kernel_claim_proof_bridge
        .packaged_statement_digest
        != accepted_artifact.kernel_claims.packaged.statement.digest
        || statement
            .side_bundle
            .kernel_claim_proof_bridge
            .packaged_proof_digest
            != accepted_artifact.kernel_claims.packaged.proof.proof_digest
        || statement
            .side_bundle
            .kernel_claim_proof_bridge
            .kernel_claim_proof_bundle_digest
            != accepted_artifact.kernel_claims.digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal accepted-artifact fast path kernel-claim proof bridge does not match the carried accepted artifact"
                .into(),
        ));
    }
    Ok(())
}

fn rv64im_side_terminal_fast_path_from_accepted_artifact(
    statement: &Rv64imSideTerminalRelationStatement,
    accepted_artifact: &Rv64imAcceptedProofArtifact,
) -> Result<(Rv64imSideTerminalWitnessArtifact, Vec<[u8; 32]>), SimpleKernelError> {
    guard_rv64im_side_terminal_relation_statement_against_accepted_artifact(statement, accepted_artifact)?;
    let mut witness_artifact = Rv64imSideTerminalWitnessArtifact {
        statement_digest: rv64im_side_terminal_relation_statement_digest(statement),
        witness: build_rv64im_side_terminal_relation_witness_from_accepted_artifact(accepted_artifact),
        digest: [0; 32],
    };
    witness_artifact.digest = witness_artifact.expected_digest();
    let base_component_digests = vec![
        accepted_artifact.stage_claims.digest,
        accepted_artifact.stage_packages.digest,
        accepted_artifact.kernel_opening.digest,
        accepted_artifact.kernel_claims.digest,
    ];
    Ok((witness_artifact, base_component_digests))
}

pub fn build_rv64im_side_terminal_proof_artifact(
    nightstream_statement: &NightstreamStatement,
    bridge_handoff_digests: &[[u8; 32]],
    public_statement: &Rv64imProofStatement,
    side_bundle: &Rv64imSideProofBundle,
    witness_artifact: &Rv64imSideTerminalWitnessArtifact,
) -> Result<Rv64imSideTerminalProofArtifact, SimpleKernelError> {
    let relation_statement = build_rv64im_side_terminal_relation_statement(public_statement, side_bundle)?;
    verify_rv64im_side_terminal_witness_artifact(&relation_statement, witness_artifact)?;
    let backend_proof = prove_rv64im_side_terminal_backend_proof_from_relation(
        nightstream_statement,
        &relation_statement,
        bridge_handoff_digests,
    )?;
    Ok(rv64im_side_terminal_proof_artifact_from_parts(
        witness_artifact.clone(),
        backend_proof,
    ))
}

pub fn verify_rv64im_side_terminal_proof_artifact(
    nightstream_statement: &NightstreamStatement,
    bridge_handoff_digests: &[[u8; 32]],
    public_statement: &Rv64imProofStatement,
    side_bundle: &Rv64imSideProofBundle,
    artifact: &Rv64imSideTerminalProofArtifact,
) -> Result<(), SimpleKernelError> {
    let relation_statement = build_rv64im_side_terminal_relation_statement(public_statement, side_bundle)?;
    verify_rv64im_side_terminal_witness_artifact(&relation_statement, &artifact.witness_artifact)?;
    let relation = build_rv64im_side_terminal_decider_relation(
        nightstream_statement,
        &relation_statement,
        bridge_handoff_digests,
    )?;
    let shape = relation.backend_shape();
    let backend_relation = relation.backend_relation();
    if artifact.backend_proof.shape_digest != shape.digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal proof artifact shape digest does not match the carried backend relation".into(),
        ));
    }
    let (_, vk) = rv64im_side_terminal_cached_backend_binding_shell_keys(&shape)?;
    verify_spartan2_backend_binding_shell(&vk, &backend_relation, &artifact.backend_proof.as_shell_proof())
        .map_err(|err| SimpleKernelError::Bridge(err.to_string()))?;
    if artifact.digest != artifact.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal proof artifact digest mismatch".into(),
        ));
    }
    Ok(())
}

pub fn build_rv64im_side_terminal_proof_artifact_from_accepted_artifact(
    nightstream_statement: &NightstreamStatement,
    bridge_handoff_digests: &[[u8; 32]],
    public_statement: &Rv64imProofStatement,
    side_bundle: &Rv64imSideProofBundle,
    accepted_artifact: &Rv64imAcceptedProofArtifact,
) -> Result<Rv64imSideTerminalProofArtifact, SimpleKernelError> {
    let (witness_artifact, relation) = build_rv64im_side_terminal_proof_material_from_accepted_artifact(
        nightstream_statement,
        bridge_handoff_digests,
        public_statement,
        side_bundle,
        accepted_artifact,
    )?;
    let backend_proof = prove_rv64im_side_terminal_backend_proof_from_decider_relation(&relation)?;
    Ok(rv64im_side_terminal_proof_artifact_from_parts(
        witness_artifact,
        backend_proof,
    ))
}

pub fn build_rv64im_side_terminal_decider_target(
    nightstream_statement: &NightstreamStatement,
    statement: &Rv64imSideTerminalRelationStatement,
    bridge_handoff_digests: &[[u8; 32]],
) -> Result<Spartan2DeciderTarget, SimpleKernelError> {
    Ok(build_rv64im_side_terminal_decider_relation(nightstream_statement, statement, bridge_handoff_digests)?.target())
}

pub fn build_rv64im_side_terminal_public_target(
    nightstream_statement: &NightstreamStatement,
    nightstream_proof: &Rv64imNightstreamProof,
    public_statement: &Rv64imProofStatement,
) -> Result<Spartan2DeciderTarget, SimpleKernelError> {
    let side_terminal_statement =
        build_rv64im_side_terminal_relation_statement(public_statement, &nightstream_proof.side_proof_artifact.bundle)?;
    build_rv64im_side_terminal_decider_target(
        nightstream_statement,
        &side_terminal_statement,
        &nightstream_proof.main_residual_proof.bridge_handoff_digests,
    )
}

pub fn build_rv64im_side_terminal_public_target_from_public_proof(
    proof: &Rv64imProof,
) -> Result<Spartan2DeciderTarget, SimpleKernelError> {
    let (nightstream_statement, nightstream_proof) = build_rv64im_nightstream_from_public_proof(proof)?;
    build_rv64im_side_terminal_public_target(&nightstream_statement, &nightstream_proof, &proof.statement)
}

pub fn build_rv64im_side_terminal_backend_binding_relation(
    nightstream_statement: &NightstreamStatement,
    nightstream_proof: &Rv64imNightstreamProof,
    public_statement: &Rv64imProofStatement,
) -> Result<Rv64imSideTerminalBackendBindingRelation, SimpleKernelError> {
    let target = build_rv64im_side_terminal_public_target(nightstream_statement, nightstream_proof, public_statement)?;
    Ok(target.backend_relation())
}

pub fn build_rv64im_side_terminal_backend_binding_relation_from_public_proof(
    proof: &Rv64imProof,
) -> Result<Rv64imSideTerminalBackendBindingRelation, SimpleKernelError> {
    let target = build_rv64im_side_terminal_public_target_from_public_proof(proof)?;
    Ok(target.backend_relation())
}

pub fn setup_rv64im_side_terminal_public_target_shell(
    nightstream_statement: &NightstreamStatement,
    nightstream_proof: &Rv64imNightstreamProof,
    public_statement: &Rv64imProofStatement,
) -> Result<
    (
        Rv64imSideTerminalPublicTargetShellProverKey,
        Rv64imSideTerminalPublicTargetShellVerifierKey,
    ),
    SimpleKernelError,
> {
    let target = build_rv64im_side_terminal_public_target(nightstream_statement, nightstream_proof, public_statement)?;
    setup_spartan2_public_target_shell(&target.shape()).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn setup_rv64im_side_terminal_public_target_shell_from_public_proof(
    proof: &Rv64imProof,
) -> Result<
    (
        Rv64imSideTerminalPublicTargetShellProverKey,
        Rv64imSideTerminalPublicTargetShellVerifierKey,
    ),
    SimpleKernelError,
> {
    let target = build_rv64im_side_terminal_public_target_from_public_proof(proof)?;
    setup_spartan2_public_target_shell(&target.shape()).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn prove_rv64im_side_terminal_public_target_shell(
    pk: &Rv64imSideTerminalPublicTargetShellProverKey,
    nightstream_statement: &NightstreamStatement,
    nightstream_proof: &Rv64imNightstreamProof,
    public_statement: &Rv64imProofStatement,
) -> Result<Rv64imSideTerminalPublicTargetShellProof, SimpleKernelError> {
    let target = build_rv64im_side_terminal_public_target(nightstream_statement, nightstream_proof, public_statement)?;
    prove_spartan2_public_target_shell(pk, &target).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn prove_rv64im_side_terminal_public_target_shell_from_public_proof(
    pk: &Rv64imSideTerminalPublicTargetShellProverKey,
    proof: &Rv64imProof,
) -> Result<Rv64imSideTerminalPublicTargetShellProof, SimpleKernelError> {
    let target = build_rv64im_side_terminal_public_target_from_public_proof(proof)?;
    prove_spartan2_public_target_shell(pk, &target).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn verify_rv64im_side_terminal_public_target_shell(
    vk: &Rv64imSideTerminalPublicTargetShellVerifierKey,
    nightstream_statement: &NightstreamStatement,
    nightstream_proof: &Rv64imNightstreamProof,
    public_statement: &Rv64imProofStatement,
    shell: &Rv64imSideTerminalPublicTargetShellProof,
) -> Result<(), SimpleKernelError> {
    let target = build_rv64im_side_terminal_public_target(nightstream_statement, nightstream_proof, public_statement)?;
    verify_spartan2_public_target_shell(vk, &target, shell).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn verify_rv64im_side_terminal_public_target_shell_from_public_proof(
    vk: &Rv64imSideTerminalPublicTargetShellVerifierKey,
    proof: &Rv64imProof,
    shell: &Rv64imSideTerminalPublicTargetShellProof,
) -> Result<(), SimpleKernelError> {
    let target = build_rv64im_side_terminal_public_target_from_public_proof(proof)?;
    verify_spartan2_public_target_shell(vk, &target, shell).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn setup_rv64im_side_terminal_public_relation_shell(
    nightstream_statement: &NightstreamStatement,
    nightstream_proof: &Rv64imNightstreamProof,
    public_statement: &Rv64imProofStatement,
) -> Result<
    (
        Rv64imSideTerminalPublicRelationShellProverKey,
        Rv64imSideTerminalPublicRelationShellVerifierKey,
    ),
    SimpleKernelError,
> {
    let target = build_rv64im_side_terminal_public_target(nightstream_statement, nightstream_proof, public_statement)?;
    setup_spartan2_public_relation_shell(&target.shape()).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn setup_rv64im_side_terminal_public_relation_shell_from_public_proof(
    proof: &Rv64imProof,
) -> Result<
    (
        Rv64imSideTerminalPublicRelationShellProverKey,
        Rv64imSideTerminalPublicRelationShellVerifierKey,
    ),
    SimpleKernelError,
> {
    let target = build_rv64im_side_terminal_public_target_from_public_proof(proof)?;
    setup_spartan2_public_relation_shell(&target.shape()).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn prove_rv64im_side_terminal_public_relation_shell(
    pk: &Rv64imSideTerminalPublicRelationShellProverKey,
    nightstream_statement: &NightstreamStatement,
    nightstream_proof: &Rv64imNightstreamProof,
    public_statement: &Rv64imProofStatement,
) -> Result<Rv64imSideTerminalPublicRelationShellProof, SimpleKernelError> {
    let target = build_rv64im_side_terminal_public_target(nightstream_statement, nightstream_proof, public_statement)?;
    prove_spartan2_public_relation_shell(pk, &target).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn prove_rv64im_side_terminal_public_relation_shell_from_public_proof(
    pk: &Rv64imSideTerminalPublicRelationShellProverKey,
    proof: &Rv64imProof,
) -> Result<Rv64imSideTerminalPublicRelationShellProof, SimpleKernelError> {
    let target = build_rv64im_side_terminal_public_target_from_public_proof(proof)?;
    prove_spartan2_public_relation_shell(pk, &target).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn verify_rv64im_side_terminal_public_relation_shell(
    vk: &Rv64imSideTerminalPublicRelationShellVerifierKey,
    nightstream_statement: &NightstreamStatement,
    nightstream_proof: &Rv64imNightstreamProof,
    public_statement: &Rv64imProofStatement,
    shell: &Rv64imSideTerminalPublicRelationShellProof,
) -> Result<(), SimpleKernelError> {
    let target = build_rv64im_side_terminal_public_target(nightstream_statement, nightstream_proof, public_statement)?;
    verify_spartan2_public_relation_shell(vk, &target, shell).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn verify_rv64im_side_terminal_public_relation_shell_from_public_proof(
    vk: &Rv64imSideTerminalPublicRelationShellVerifierKey,
    proof: &Rv64imProof,
    shell: &Rv64imSideTerminalPublicRelationShellProof,
) -> Result<(), SimpleKernelError> {
    let target = build_rv64im_side_terminal_public_target_from_public_proof(proof)?;
    verify_spartan2_public_relation_shell(vk, &target, shell).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn setup_rv64im_side_terminal_backend_binding_shell(
    nightstream_statement: &NightstreamStatement,
    nightstream_proof: &Rv64imNightstreamProof,
    public_statement: &Rv64imProofStatement,
) -> Result<
    (
        Rv64imSideTerminalBackendBindingShellProverKey,
        Rv64imSideTerminalBackendBindingShellVerifierKey,
    ),
    SimpleKernelError,
> {
    let relation = build_rv64im_side_terminal_backend_binding_relation(
        nightstream_statement,
        nightstream_proof,
        public_statement,
    )?;
    rv64im_side_terminal_backend_binding_shell_keys_for_setup(&relation.shape())
}

pub fn setup_rv64im_side_terminal_backend_proof(
    nightstream_statement: &NightstreamStatement,
    nightstream_proof: &Rv64imNightstreamProof,
    public_statement: &Rv64imProofStatement,
) -> Result<
    (
        Rv64imSideTerminalBackendProofProverKey,
        Rv64imSideTerminalBackendProofVerifierKey,
    ),
    SimpleKernelError,
> {
    setup_rv64im_side_terminal_backend_binding_shell(nightstream_statement, nightstream_proof, public_statement)
}

pub fn setup_rv64im_side_terminal_backend_binding_shell_from_public_proof(
    proof: &Rv64imProof,
) -> Result<
    (
        Rv64imSideTerminalBackendBindingShellProverKey,
        Rv64imSideTerminalBackendBindingShellVerifierKey,
    ),
    SimpleKernelError,
> {
    let relation = build_rv64im_side_terminal_backend_binding_relation_from_public_proof(proof)?;
    rv64im_side_terminal_backend_binding_shell_keys_for_setup(&relation.shape())
}

pub fn setup_rv64im_side_terminal_backend_proof_from_public_proof(
    proof: &Rv64imProof,
) -> Result<
    (
        Rv64imSideTerminalBackendProofProverKey,
        Rv64imSideTerminalBackendProofVerifierKey,
    ),
    SimpleKernelError,
> {
    setup_rv64im_side_terminal_backend_binding_shell_from_public_proof(proof)
}

pub fn prove_rv64im_side_terminal_backend_binding_shell(
    pk: &Rv64imSideTerminalBackendBindingShellProverKey,
    nightstream_statement: &NightstreamStatement,
    nightstream_proof: &Rv64imNightstreamProof,
    public_statement: &Rv64imProofStatement,
) -> Result<Rv64imSideTerminalBackendBindingShellProof, SimpleKernelError> {
    let relation = build_rv64im_side_terminal_backend_binding_relation(
        nightstream_statement,
        nightstream_proof,
        public_statement,
    )?;
    prove_spartan2_backend_binding_shell(pk, &relation).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn prove_rv64im_side_terminal_backend_binding_shell_from_public_proof(
    pk: &Rv64imSideTerminalBackendBindingShellProverKey,
    proof: &Rv64imProof,
) -> Result<Rv64imSideTerminalBackendBindingShellProof, SimpleKernelError> {
    let relation = build_rv64im_side_terminal_backend_binding_relation_from_public_proof(proof)?;
    prove_spartan2_backend_binding_shell(pk, &relation).map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn verify_rv64im_side_terminal_backend_binding_shell(
    vk: &Rv64imSideTerminalBackendBindingShellVerifierKey,
    nightstream_statement: &NightstreamStatement,
    nightstream_proof: &Rv64imNightstreamProof,
    public_statement: &Rv64imProofStatement,
    shell: &Rv64imSideTerminalBackendBindingShellProof,
) -> Result<(), SimpleKernelError> {
    let relation = build_rv64im_side_terminal_backend_binding_relation(
        nightstream_statement,
        nightstream_proof,
        public_statement,
    )?;
    verify_spartan2_backend_binding_shell(vk, &relation, shell)
        .map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn verify_rv64im_side_terminal_backend_binding_shell_from_public_proof(
    vk: &Rv64imSideTerminalBackendBindingShellVerifierKey,
    proof: &Rv64imProof,
    shell: &Rv64imSideTerminalBackendBindingShellProof,
) -> Result<(), SimpleKernelError> {
    let relation = build_rv64im_side_terminal_backend_binding_relation_from_public_proof(proof)?;
    verify_spartan2_backend_binding_shell(vk, &relation, shell)
        .map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn prove_rv64im_side_terminal_backend_proof(
    pk: &Rv64imSideTerminalBackendProofProverKey,
    nightstream_statement: &NightstreamStatement,
    nightstream_proof: &Rv64imNightstreamProof,
    public_statement: &Rv64imProofStatement,
) -> Result<Rv64imSideTerminalBackendProof, SimpleKernelError> {
    let relation = build_rv64im_side_terminal_backend_binding_relation(
        nightstream_statement,
        nightstream_proof,
        public_statement,
    )?;
    let shell = prove_spartan2_backend_binding_shell(pk, &relation)
        .map_err(|err| SimpleKernelError::Bridge(err.to_string()))?;
    Ok(Rv64imSideTerminalBackendProof {
        shape_digest: relation.shape().digest(),
        snark_data: shell.snark_data,
    })
}

pub fn prove_rv64im_side_terminal_backend_proof_from_public_proof(
    pk: &Rv64imSideTerminalBackendProofProverKey,
    proof: &Rv64imProof,
) -> Result<Rv64imSideTerminalBackendProof, SimpleKernelError> {
    let relation = build_rv64im_side_terminal_backend_binding_relation_from_public_proof(proof)?;
    let shell = prove_spartan2_backend_binding_shell(pk, &relation)
        .map_err(|err| SimpleKernelError::Bridge(err.to_string()))?;
    Ok(Rv64imSideTerminalBackendProof {
        shape_digest: relation.shape().digest(),
        snark_data: shell.snark_data,
    })
}

pub fn verify_rv64im_side_terminal_backend_proof(
    vk: &Rv64imSideTerminalBackendProofVerifierKey,
    nightstream_statement: &NightstreamStatement,
    nightstream_proof: &Rv64imNightstreamProof,
    public_statement: &Rv64imProofStatement,
    proof: &Rv64imSideTerminalBackendProof,
) -> Result<(), SimpleKernelError> {
    let relation = build_rv64im_side_terminal_backend_binding_relation(
        nightstream_statement,
        nightstream_proof,
        public_statement,
    )?;
    let expected_shape_digest = relation.shape().digest();
    if proof.shape_digest != expected_shape_digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal backend proof shape digest does not match the carried backend relation".into(),
        ));
    }
    verify_spartan2_backend_binding_shell(vk, &relation, &proof.as_shell_proof())
        .map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

pub fn verify_rv64im_side_terminal_backend_proof_from_public_proof(
    vk: &Rv64imSideTerminalBackendProofVerifierKey,
    public_proof: &Rv64imProof,
    proof: &Rv64imSideTerminalBackendProof,
) -> Result<(), SimpleKernelError> {
    let relation = build_rv64im_side_terminal_backend_binding_relation_from_public_proof(public_proof)?;
    let expected_shape_digest = relation.shape().digest();
    if proof.shape_digest != expected_shape_digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM side-terminal backend proof shape digest does not match the carried backend relation".into(),
        ));
    }
    verify_spartan2_backend_binding_shell(vk, &relation, &proof.as_shell_proof())
        .map_err(|err| SimpleKernelError::Bridge(err.to_string()))
}

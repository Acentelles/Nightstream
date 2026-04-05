//! Owns the RV64IM parity-slice kernel artifacts and transcript logging.

mod canonical_openings;
mod perf_diagnostics;
mod simple;
mod transcript;

#[path = "parity/cases.rs"]
mod artifacts;
#[path = "main_lane/family.rs"]
mod lane_family;
#[path = "main_lane/artifact.rs"]
mod main_lane_artifact;
#[path = "main_lane/surface.rs"]
mod main_lane_surface;
#[path = "proof/accepted.rs"]
mod proof_accepted;
#[path = "proof/api.rs"]
mod proof_api;
#[path = "proof/bridge.rs"]
mod proof_bridge;
#[path = "proof/completeness.rs"]
mod proof_completeness;
#[path = "proof/export_relation.rs"]
mod proof_export_relation;
#[path = "proof/staged_verify.rs"]
mod proof_staged_verify;
#[path = "proof/verify.rs"]
mod proof_verify;
#[path = "proof/witness.rs"]
mod proof_witness;
#[path = "root_lane/columns.rs"]
mod root_lane_columns;
#[path = "root_lane/commitment.rs"]
mod root_lane_commitment;
#[path = "root_lane/witness.rs"]
mod root_lane_witness;
#[path = "openings/simple.rs"]
mod simple_openings;
#[path = "stages/stage1.rs"]
mod stage1_canonical;
#[path = "stages/stage2.rs"]
mod stage2_canonical;
#[path = "stages/stage3.rs"]
mod stage3_canonical;
#[path = "openings/stage_artifacts.rs"]
mod stage_artifacts;
#[path = "stages/package_perf.rs"]
mod stage_package_perf;

pub use artifacts::{
    aligned_memory_focus_manifest, build_aligned_memory_focus_parity_case, build_all_parity_cases,
    build_control_flow_beq_parity_case, build_control_flow_bge_parity_case, build_control_flow_bgeu_parity_case,
    build_control_flow_blt_parity_case, build_control_flow_bltu_parity_case, build_control_flow_bne_parity_case,
    build_control_flow_focus_parity_case, build_control_flow_jal_parity_case, build_control_flow_jalr_parity_case,
    build_multiply_high_parity_case, build_multiply_low_parity_case, build_narrow_memory_load_parity_case,
    build_narrow_memory_store_parity_case, build_native_alu_focus_parity_case, build_native_logic_compare_parity_case,
    build_native_shift_parity_case, build_native_upper_parity_case, build_native_word_arith_parity_case,
    build_native_word_shift_parity_case, build_parity_case_from_source, build_signed_divrem_parity_case,
    build_unsigned_divrem_parity_case, build_vertical_slice_parity_case, control_flow_beq_manifest,
    control_flow_bge_manifest, control_flow_bgeu_manifest, control_flow_blt_manifest, control_flow_bltu_manifest,
    control_flow_bne_manifest, control_flow_focus_manifest, control_flow_jal_manifest, control_flow_jalr_manifest,
    multiply_high_manifest, multiply_low_manifest, narrow_memory_load_manifest, narrow_memory_store_manifest,
    native_alu_focus_manifest, native_logic_compare_manifest, native_shift_manifest, native_upper_manifest,
    native_word_arith_manifest, native_word_shift_manifest, parity_source_cases, signed_divrem_manifest,
    unsigned_divrem_manifest, vertical_slice_manifest, Rv64imKernelSummary, Rv64imParityCaseManifest,
    Rv64imParityDerivedCase, Rv64imParitySourceCase,
};
pub(crate) use artifacts::{
    family_word, opcode_word, ram_access_kind_word, register_read_role_word, trace_virtual_opcode_word,
};
pub use canonical_openings::{
    AjtaiFamilyKind, AjtaiObjectId, AjtaiOpeningId, OpeningAccumulator, OpeningAccumulatorStats, OpeningAliasError,
    SelectedOpeningRef,
};
pub use lane_family::{
    build_main_lane_family_summary, prepared_step_digest, public_step_digest, public_step_family_digest,
    same_public_step, MainLaneFamilySummary,
};
pub use main_lane_artifact::{
    build_simple_kernel_main_lane_artifact, validate_simple_kernel_main_lane_artifact, SimpleKernelMainLaneArtifact,
    SimpleKernelMainLaneBinding,
};
pub use main_lane_surface::{build_main_lane_surface, Rv64imMainLaneSurface};
pub use perf_diagnostics::{
    ExactStageVectorBuildPerf, KernelOpeningBundleBuildPerf, KernelOpeningBundleVerifyPerf, PackagedOpeningBuildPerf,
    PackagedSimpleKernelVerifyPerf, RootMainLanePackagedProofProvePerf, RootMainLanePackagedProofVerifyPerf,
    RootMainLaneRunProofProvePerf, RootMainLaneRunProofVerifyPerf, Rv64imProofProvePerf, Rv64imPublicProofVerifyPerf,
    SimpleKernelBuildPerf, SimpleKernelVerifyPerf, StageClaimBundleBuildPerf, StagePackageBundleBuildPerf,
    StagePackageBundleVerifyPerf,
};
pub use proof_accepted::{Rv64imAcceptedProofArtifact, Rv64imAuditBundle};
pub use proof_api::{
    audit_rv64im_accepted_proof_against_input, audit_rv64im_accepted_proof_against_input_with_perf,
    build_rv64im_accepted_proof_artifact, build_rv64im_audit_bundle, build_rv64im_audit_witness_bundle,
    prove_rv64im_accepted_proof, prove_rv64im_accepted_proof_with_options,
    prove_rv64im_accepted_proof_with_options_and_perf, prove_rv64im_accepted_proof_with_perf, prove_rv64im_audit_proof,
    prove_rv64im_audit_proof_with_perf, prove_rv64im_public_proof, prove_rv64im_public_proof_with_options,
    prove_rv64im_public_proof_with_options_and_perf, prove_rv64im_public_proof_with_perf,
    validate_rv64im_public_proof_against_input, validate_rv64im_public_proof_against_input_with_perf,
    verify_rv64im_accepted_proof, verify_rv64im_accepted_proof_with_perf, verify_rv64im_audit_proof,
    verify_rv64im_audit_proof_with_perf, verify_rv64im_public_proof, verify_rv64im_public_proof_with_perf,
    Rv64imAcceptedProofClaim, Rv64imAcceptedProofMainLaneBinding, Rv64imAcceptedProofStatementBinding,
    Rv64imAcceptedProofTerminalBinding, Rv64imJointOpeningClaim, Rv64imKernelClaimBundle, Rv64imKernelOpeningClaim,
    Rv64imKernelProofBundle, Rv64imMainLaneClaim, Rv64imMainLaneClaimBinding, Rv64imMainLaneProofBinding,
    Rv64imMainLaneProofBundle, Rv64imMainLaneProofSummaryBundle, Rv64imProof, Rv64imProofInput, Rv64imProofStatement,
    Rv64imPublicProofOptions, Rv64imRoot0Claim,
};
pub use proof_completeness::{KernelSoundnessAccountingSurface, StepCompositionSurface};
pub use proof_export_relation::{
    build_rv64im_kernel_export_relation, build_rv64im_kernel_export_witness, verify_rv64im_kernel_export_relation,
    verify_rv64im_kernel_export_witness, Rv64imChunkBridgeRelationWitness, Rv64imChunkExportSurface,
    Rv64imKernelChunkExportWitness, Rv64imKernelExportRelation, Rv64imKernelExportWitness,
    Rv64imVerifiedKernelChunkHandoff,
};
pub(crate) use proof_export_relation::{
    build_rv64im_kernel_export_relation_from_artifact, build_rv64im_kernel_export_seam_from_accepted_artifact,
    rv64im_public_chunk_digest, verify_rv64im_kernel_export_witness_with_output, Rv64imKernelExportRelationResult,
};
pub use proof_staged_verify::{
    Stage1VerifiedClaims, Stage2VerifiedClaims, Stage3VerifiedClaims, TranscriptChallenges, VerifierClaimAccumulator,
};
pub use proof_witness::{
    Rv64imKernelClaimProofBundle, Rv64imKernelClaimSummaryBundle, Rv64imKernelClaimSummaryProofBundle,
    Rv64imKernelClaimTerminalBundle, Rv64imKernelOpeningBindingBundle, Rv64imKernelOpeningProofBundle,
    Rv64imKernelOpeningSummaryBundle, Rv64imProofWitnessBundle, Rv64imStageClaimDigestBundle,
    Rv64imStageClaimProofBundle, Rv64imStageClaimSummaryProofBundle, Rv64imStagePackageDigestBundle,
    Rv64imStagePackageProofBundle, Rv64imStagePackageSummaryProofBundle, Rv64imStageWitnessProjectionBundle,
    Rv64imStageWitnessProofBundle, Rv64imStageWitnessSummaryBundle, Rv64imTraceProjectionBundle,
    Rv64imTraceProofBundle, Rv64imTraceShapeBundle,
};
pub use root_lane_columns::{build_root_lane_columns, RootLaneColumns};
pub use root_lane_commitment::{
    build_root_lane_commitment_artifact, verify_root_lane_commitment_artifact, RootLaneCommitmentArtifact,
    RootLaneCommitmentSet, RootLaneCommitmentSetSummary, RootLaneCommitmentSummaryArtifact, RootLaneOpeningProof,
};
pub use root_lane_witness::{
    RootExecutionBundle, RootExecutionSemanticsRefinement, RootExecutionSemanticsRefinementSummary,
    RootRowLocalCcsAcceptance, RootRowLocalCcsAcceptanceSummary, RootSemanticRow, RowChunkRoute,
};
pub(crate) use simple::rv64im_cached_root_main_lane_context;
pub use simple::{
    build_simple_kernel_witness, build_simple_kernel_witness_with_perf, prove_packaged_simple_kernel,
    prove_packaged_simple_kernel_with_perf, prove_root_main_lane_packaged_proof_with_perf,
    prove_root_main_lane_run_proof_with_perf, prove_simple_kernel, rv64im_ajtai_mixers, rv64im_simple_root_context_id,
    rv64im_simple_root_params, verify_packaged_simple_kernel, verify_packaged_simple_kernel_with_perf,
    verify_root_main_lane_packaged_proof_with_public_rows, verify_root_main_lane_run_proof_with_public_rows,
    verify_simple_kernel, verify_simple_kernel_with_perf, PreparedStepBinding, PreparedStepBindingSummary,
    SimpleKernelAuditOutput, SimpleKernelError, SimpleKernelKernelClaimBundle, SimpleKernelOutput,
    SimpleKernelPackagedProof, SimpleKernelProof, SimpleKernelProverInput, SimpleKernelPublicInput,
    SimpleKernelStageWitnessBundle, SimpleKernelTraceWitness, SimpleKernelVerifierInput,
};
pub use simple_openings::{
    KernelBindingOpeningClaim, KernelBindingOpeningPoints, KernelBindingPackagedOpeningProof,
    KernelPreparedStepOpeningClaim, KernelPreparedStepOpeningPoints, KernelPreparedStepPackagedOpeningProof,
    OpeningPointLabel, SimpleKernelOpeningBundle, SimpleKernelOpeningClaim, SimpleKernelStagePackageBundle,
    Stage1OpeningPoints, Stage1PackagedOpeningProof, Stage1SelectedOpeningClaim, Stage2OpeningPoints,
    Stage2PackagedOpeningProof, Stage2SelectedOpeningClaim, Stage3OpeningPoints, Stage3PackagedOpeningProof,
    Stage3SelectedOpeningClaim,
};
pub use stage1_canonical::Stage1CanonicalRowBundle;
pub use stage2_canonical::Stage2CanonicalFamilyBundle;
pub use stage3_canonical::Stage3CanonicalContinuityBundle;
pub use stage_artifacts::{
    SimpleKernelStageClaimBundle, Stage1ArtifactSurface, Stage1ClaimSurface, Stage2ArtifactSurface, Stage2ClaimSurface,
    Stage3ArtifactSurface, Stage3ClaimSurface, StageDigestCommitment, TranscriptArtifactSurface,
    TranscriptClaimSurface,
};
pub use transcript::{TranscriptCursorSnapshot, TranscriptEventKind, TranscriptEventRecord, TranscriptRecord};

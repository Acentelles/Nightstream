//! Owns the RV64IM parity-slice kernel artifacts and transcript logging.

mod artifacts;
mod perf_diagnostics;
mod proof_api;
mod proof_bridge;
mod proof_verify;
mod proof_witness;
mod simple;
mod simple_openings;
mod stage_artifacts;
mod stage_package_perf;
mod transcript;

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
pub use perf_diagnostics::{
    ExactStageVectorBuildPerf, KernelOpeningBundleBuildPerf, KernelOpeningBundleVerifyPerf, PackagedOpeningBuildPerf,
    PackagedSimpleKernelVerifyPerf, Rv64imProofProvePerf, Rv64imPublicProofVerifyPerf, SimpleKernelBuildPerf,
    SimpleKernelVerifyPerf, StageClaimBundleBuildPerf, StagePackageBundleBuildPerf, StagePackageBundleVerifyPerf,
};
pub use proof_api::{
    build_rv64im_proof_witness, prove_rv64im_proof, prove_rv64im_proof_with_perf, verify_rv64im_proof,
    verify_rv64im_proof_with_perf, Rv64imAcceptedProofClaim, Rv64imAcceptedProofMainLaneBinding,
    Rv64imAcceptedProofStatementBinding, Rv64imAcceptedProofTerminalBinding, Rv64imJointOpeningClaim,
    Rv64imKernelClaimBundle, Rv64imKernelOpeningClaim, Rv64imKernelProofBundle, Rv64imMainLaneClaim,
    Rv64imMainLaneClaimBinding, Rv64imMainLaneProofBinding, Rv64imMainLaneProofBundle,
    Rv64imMainLaneProofSummaryBundle, Rv64imProof, Rv64imProofInput, Rv64imProofStatement, Rv64imRoot0Claim,
};
pub use proof_witness::{
    Rv64imKernelClaimProofBundle, Rv64imKernelClaimSummaryBundle, Rv64imKernelClaimTerminalBundle,
    Rv64imKernelOpeningBindingBundle, Rv64imKernelOpeningProofBundle, Rv64imKernelOpeningSummaryBundle,
    Rv64imProofWitnessBundle, Rv64imStageClaimDigestBundle, Rv64imStageClaimProofBundle,
    Rv64imStagePackageDigestBundle, Rv64imStagePackageProofBundle, Rv64imStageWitnessProofBundle,
    Rv64imStageWitnessSummaryBundle, Rv64imTraceProofBundle, Rv64imTraceShapeBundle,
};
pub use simple::{
    build_simple_kernel_witness, build_simple_kernel_witness_with_perf, prepared_step_digest,
    prove_packaged_simple_kernel, prove_packaged_simple_kernel_with_perf, prove_simple_kernel, rv64im_ajtai_mixers,
    rv64im_simple_root_context_id, rv64im_simple_root_params, verify_packaged_simple_kernel,
    verify_packaged_simple_kernel_with_perf, verify_simple_kernel, verify_simple_kernel_with_perf,
    ExactCommitmentArtifact, ExactOpeningArtifact, PreparedStepBinding, PreparedStepBindingSummary, SimpleKernelError,
    SimpleKernelKernelClaimBundle, SimpleKernelOutput, SimpleKernelPackagedProof, SimpleKernelProof,
    SimpleKernelProverInput, SimpleKernelPublicInput, SimpleKernelStageWitnessBundle, SimpleKernelTraceWitness,
    SimpleKernelVerifierInput,
};
pub use simple_openings::{
    DigestPoint, KernelBindingOpeningClaim, KernelBindingOpeningPoints, KernelBindingPackagedOpeningProof,
    KernelPreparedStepOpeningClaim, KernelPreparedStepOpeningPoints, KernelPreparedStepPackagedOpeningProof,
    OpeningPointLabel, SimpleKernelOpeningBundle, SimpleKernelOpeningClaim, SimpleKernelStagePackageBundle,
    Stage1OpeningPoints, Stage1PackagedOpeningProof, Stage1SelectedOpeningClaim, Stage2OpeningPoints,
    Stage2PackagedOpeningProof, Stage2SelectedOpeningClaim, Stage3OpeningPoints, Stage3PackagedOpeningProof,
    Stage3SelectedOpeningClaim,
};
pub use stage_artifacts::{
    ExactOpeningClaim, ExactOpeningManifest, ExactOpeningProof, SimpleKernelStageClaimBundle, Stage1ArtifactSurface,
    Stage1ClaimSurface, Stage2ArtifactSurface, Stage2ClaimSurface, Stage3ArtifactSurface, Stage3ClaimSurface,
    StageDigestCommitment, TranscriptArtifactSurface, TranscriptClaimSurface,
};
pub use transcript::{TranscriptCursorSnapshot, TranscriptEventKind, TranscriptEventRecord, TranscriptRecord};

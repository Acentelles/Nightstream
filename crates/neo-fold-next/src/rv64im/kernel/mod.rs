//! Owns the RV64IM parity-slice kernel artifacts and transcript logging.

mod artifacts;
mod simple;
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
pub use simple::{
    build_simple_kernel_witness, prepared_step_digest, prove_packaged_simple_kernel, prove_simple_kernel,
    rv64im_ajtai_mixers, rv64im_simple_root_context_id, rv64im_simple_root_params, verify_packaged_simple_kernel,
    verify_simple_kernel, ExactCommitmentArtifact, ExactOpeningArtifact, ExactOpeningClaim, ExactOpeningManifest,
    ExactOpeningProof, PreparedStepBinding, PreparedStepBindingSummary, SimpleKernelError,
    SimpleKernelKernelClaimBundle, SimpleKernelOutput, SimpleKernelPackagedProof, SimpleKernelProof,
    SimpleKernelProverInput, SimpleKernelPublicInput, SimpleKernelStageClaimBundle, SimpleKernelStagePackageBundle,
    SimpleKernelStageWitnessBundle, SimpleKernelTraceWitness, SimpleKernelVerifierInput, Stage1ArtifactSurface,
    Stage1ClaimSurface, Stage2ArtifactSurface, Stage2ClaimSurface, Stage3ArtifactSurface, Stage3ClaimSurface,
    StageDigestCommitment, StagePackagedOpeningProof, TranscriptArtifactSurface, TranscriptClaimSurface,
};
pub use transcript::{TranscriptCursorSnapshot, TranscriptEventKind, TranscriptEventRecord, TranscriptRecord};

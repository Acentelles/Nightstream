//! Owns the RV64IM frontend parity slice: machine layer, staged summaries, and kernel artifacts.

pub mod builder;
pub mod ccs;
pub mod execute;
pub mod isa;
pub mod kernel;
pub mod layout;
pub mod lower;
mod perf_case;
pub mod stage1;
pub mod stage2;
pub mod stage3;
pub mod tables;
mod trace_expand;

pub use builder::{build_program, Rv64ProgramBuild};
pub use isa::{
    decode_instruction, encode_add, encode_addi, encode_addiw, encode_addw, encode_and, encode_andi, encode_auipc,
    encode_beq, encode_bge, encode_bgeu, encode_blt, encode_bltu, encode_bne, encode_div, encode_divu, encode_divuw,
    encode_divw, encode_ecall, encode_fence, encode_jal, encode_jalr, encode_lb, encode_lbu, encode_ld, encode_lh,
    encode_lhu, encode_lui, encode_lw, encode_lwu, encode_mul, encode_mulh, encode_mulhsu, encode_mulhu, encode_mulw,
    encode_or, encode_ori, encode_rem, encode_remu, encode_remuw, encode_remw, encode_sb, encode_sd, encode_sh,
    encode_sll, encode_slli, encode_slliw, encode_sllw, encode_slt, encode_slti, encode_sltiu, encode_sltu, encode_sra,
    encode_srai, encode_sraiw, encode_sraw, encode_srl, encode_srli, encode_srliw, encode_srlw, encode_sub,
    encode_subw, encode_sw, encode_xor, encode_xori, MemoryWord, Rv64BuildError, Rv64DecodedInstruction, Rv64Opcode,
    Rv64Program, Rv64State,
};
pub use kernel::{
    aligned_memory_focus_manifest, build_aligned_memory_focus_parity_case, build_all_parity_cases,
    build_control_flow_beq_parity_case, build_control_flow_bge_parity_case, build_control_flow_bgeu_parity_case,
    build_control_flow_blt_parity_case, build_control_flow_bltu_parity_case, build_control_flow_bne_parity_case,
    build_control_flow_focus_parity_case, build_control_flow_jal_parity_case, build_control_flow_jalr_parity_case,
    build_main_lane_surface, build_multiply_high_parity_case, build_multiply_low_parity_case,
    build_narrow_memory_load_parity_case, build_narrow_memory_store_parity_case, build_native_alu_focus_parity_case,
    build_native_logic_compare_parity_case, build_native_shift_parity_case, build_native_upper_parity_case,
    build_native_word_arith_parity_case, build_native_word_shift_parity_case, build_parity_case_from_source,
    build_rv64im_audit_witness_bundle, build_signed_divrem_parity_case, build_simple_kernel_witness,
    build_simple_kernel_witness_with_perf, build_unsigned_divrem_parity_case, build_vertical_slice_parity_case,
    control_flow_beq_manifest, control_flow_bge_manifest, control_flow_bgeu_manifest, control_flow_blt_manifest,
    control_flow_bltu_manifest, control_flow_bne_manifest, control_flow_focus_manifest, control_flow_jal_manifest,
    control_flow_jalr_manifest, multiply_high_manifest, multiply_low_manifest, narrow_memory_load_manifest,
    narrow_memory_store_manifest, native_alu_focus_manifest, native_logic_compare_manifest, native_shift_manifest,
    native_upper_manifest, native_word_arith_manifest, native_word_shift_manifest, parity_source_cases,
    prepared_step_digest, prove_packaged_simple_kernel, prove_packaged_simple_kernel_with_perf,
    prove_rv64im_audit_proof, prove_rv64im_audit_proof_with_perf, prove_rv64im_public_proof,
    prove_rv64im_public_proof_with_options, prove_rv64im_public_proof_with_options_and_perf,
    prove_rv64im_public_proof_with_perf, prove_simple_kernel, public_step_digest, public_step_family_digest,
    rv64im_ajtai_mixers, rv64im_simple_root_context_id, rv64im_simple_root_params, signed_divrem_manifest,
    unsigned_divrem_manifest, validate_rv64im_public_proof_against_input,
    validate_rv64im_public_proof_against_input_with_perf, verify_packaged_simple_kernel,
    verify_packaged_simple_kernel_with_perf, verify_rv64im_audit_proof, verify_rv64im_audit_proof_with_perf,
    verify_rv64im_public_proof, verify_rv64im_public_proof_with_perf, verify_simple_kernel,
    verify_simple_kernel_with_perf, vertical_slice_manifest, AjtaiFamilyKind, AjtaiObjectId, AjtaiOpeningId,
    ExactStageVectorBuildPerf, KernelBindingOpeningClaim, KernelBindingOpeningPoints,
    KernelBindingPackagedOpeningProof, KernelOpeningBundleBuildPerf, KernelOpeningBundleVerifyPerf,
    KernelPreparedStepOpeningClaim, KernelPreparedStepOpeningPoints, KernelPreparedStepPackagedOpeningProof,
    MainLaneFamilySummary, OpeningAccumulator, OpeningAccumulatorStats, OpeningAliasError, OpeningPointLabel,
    PackagedOpeningBuildPerf, PackagedSimpleKernelVerifyPerf, PreparedStepBinding, PreparedStepBindingSummary,
    RootLaneColumns, RootLaneCommitmentSetSummary, RootLaneCommitmentSummaryArtifact, Rv64imAcceptedProofClaim,
    Rv64imAcceptedProofMainLaneBinding, Rv64imAcceptedProofStatementBinding, Rv64imAcceptedProofTerminalBinding,
    Rv64imJointOpeningClaim, Rv64imKernelClaimBundle, Rv64imKernelClaimProofBundle, Rv64imKernelClaimSummaryBundle,
    Rv64imKernelClaimSummaryProofBundle, Rv64imKernelClaimTerminalBundle, Rv64imKernelOpeningBindingBundle,
    Rv64imKernelOpeningClaim, Rv64imKernelOpeningProofBundle, Rv64imKernelOpeningSummaryBundle,
    Rv64imKernelProofBundle, Rv64imKernelSummary, Rv64imMainLaneClaim, Rv64imMainLaneClaimBinding,
    Rv64imMainLaneProofBinding, Rv64imMainLaneProofBundle, Rv64imMainLaneProofSummaryBundle, Rv64imMainLaneSurface,
    Rv64imParityCaseManifest, Rv64imParityDerivedCase, Rv64imParitySourceCase, Rv64imProof, Rv64imProofInput,
    Rv64imProofProvePerf, Rv64imProofStatement, Rv64imProofWitnessBundle, Rv64imPublicProofOptions,
    Rv64imPublicProofVerifyPerf, Rv64imRoot0Claim, Rv64imStageClaimDigestBundle, Rv64imStageClaimProofBundle,
    Rv64imStageClaimSummaryProofBundle, Rv64imStagePackageDigestBundle, Rv64imStagePackageProofBundle,
    Rv64imStagePackageSummaryProofBundle, Rv64imStageWitnessProjectionBundle, Rv64imStageWitnessProofBundle,
    Rv64imStageWitnessSummaryBundle, Rv64imTraceProjectionBundle, Rv64imTraceProofBundle, Rv64imTraceShapeBundle,
    SelectedOpeningRef, SimpleKernelAuditOutput, SimpleKernelBuildPerf, SimpleKernelError,
    SimpleKernelKernelClaimBundle, SimpleKernelMainLaneArtifact, SimpleKernelMainLaneBinding,
    SimpleKernelOpeningBundle, SimpleKernelOpeningClaim, SimpleKernelOutput, SimpleKernelPackagedProof,
    SimpleKernelProof, SimpleKernelProverInput, SimpleKernelPublicInput, SimpleKernelStageClaimBundle,
    SimpleKernelStagePackageBundle, SimpleKernelStageWitnessBundle, SimpleKernelTraceWitness,
    SimpleKernelVerifierInput, SimpleKernelVerifyPerf, Stage1ArtifactSurface, Stage1CanonicalRowBundle,
    Stage1ClaimSurface, Stage1OpeningPoints, Stage1PackagedOpeningProof, Stage1SelectedOpeningClaim,
    Stage2ArtifactSurface, Stage2CanonicalFamilyBundle, Stage2ClaimSurface, Stage2OpeningPoints,
    Stage2PackagedOpeningProof, Stage2SelectedOpeningClaim, Stage3ArtifactSurface, Stage3CanonicalContinuityBundle,
    Stage3ClaimSurface, Stage3OpeningPoints, Stage3PackagedOpeningProof, Stage3SelectedOpeningClaim,
    StageClaimBundleBuildPerf, StageDigestCommitment, StagePackageBundleBuildPerf, StagePackageBundleVerifyPerf,
    TranscriptArtifactSurface, TranscriptClaimSurface, TranscriptCursorSnapshot, TranscriptEventKind,
    TranscriptEventRecord, TranscriptRecord,
};
pub use lower::{Rv64ExpandedRow, Rv64TraceOpcode, Rv64TraceVirtualOpcode};
pub use perf_case::{
    build_mixed_opcode_perf_source_case, mixed_opcode_perf_expected_x1, RV64IM_MIXED_OPCODE_PERF_BLOCK_LEN,
    RV64IM_MIXED_OPCODE_PERF_DEFAULT_N,
};

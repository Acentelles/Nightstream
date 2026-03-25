//! Owns the RV64IM frontend parity slice: machine layer, staged summaries, and kernel artifacts.

pub mod builder;
pub mod ccs;
pub mod execute;
pub mod isa;
pub mod kernel;
pub mod layout;
pub mod lower;
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
    build_multiply_high_parity_case, build_multiply_low_parity_case, build_narrow_memory_load_parity_case,
    build_narrow_memory_store_parity_case, build_native_alu_focus_parity_case, build_native_logic_compare_parity_case,
    build_native_shift_parity_case, build_native_upper_parity_case, build_native_word_arith_parity_case,
    build_native_word_shift_parity_case, build_parity_case_from_source, build_signed_divrem_parity_case,
    build_simple_kernel_witness, build_unsigned_divrem_parity_case, build_vertical_slice_parity_case,
    control_flow_beq_manifest, control_flow_bge_manifest, control_flow_bgeu_manifest, control_flow_blt_manifest,
    control_flow_bltu_manifest, control_flow_bne_manifest, control_flow_focus_manifest, control_flow_jal_manifest,
    control_flow_jalr_manifest, multiply_high_manifest, multiply_low_manifest, narrow_memory_load_manifest,
    narrow_memory_store_manifest, native_alu_focus_manifest, native_logic_compare_manifest, native_shift_manifest,
    native_upper_manifest, native_word_arith_manifest, native_word_shift_manifest, parity_source_cases,
    prepared_step_digest, prove_packaged_simple_kernel, prove_simple_kernel, rv64im_ajtai_mixers,
    rv64im_simple_root_context_id, rv64im_simple_root_params, signed_divrem_manifest, unsigned_divrem_manifest,
    verify_packaged_simple_kernel, verify_simple_kernel, vertical_slice_manifest, ExactCommitmentArtifact,
    ExactOpeningArtifact, ExactOpeningClaim, ExactOpeningManifest, ExactOpeningProof, PreparedStepBinding,
    PreparedStepBindingSummary, Rv64imKernelSummary, Rv64imParityCaseManifest, Rv64imParityDerivedCase,
    Rv64imParitySourceCase, SimpleKernelError, SimpleKernelKernelClaimBundle, SimpleKernelOutput,
    SimpleKernelPackagedProof, SimpleKernelProof, SimpleKernelProverInput, SimpleKernelPublicInput,
    SimpleKernelStageClaimBundle, SimpleKernelStagePackageBundle, SimpleKernelStageWitnessBundle,
    SimpleKernelTraceWitness, SimpleKernelVerifierInput, Stage1ArtifactSurface, Stage1ClaimSurface,
    Stage2ArtifactSurface, Stage2ClaimSurface, Stage3ArtifactSurface, Stage3ClaimSurface, StageDigestCommitment,
    StagePackagedOpeningProof, TranscriptArtifactSurface, TranscriptClaimSurface, TranscriptCursorSnapshot,
    TranscriptEventKind, TranscriptEventRecord, TranscriptRecord,
};
pub use lower::{Rv64ExpandedRow, Rv64TraceOpcode, Rv64TraceVirtualOpcode};

//! Temporary compatibility barrel for the WASM machine-layer frontend.

pub use super::adapters::rwasm::{traces_from_rwasm_instr_states, traces_from_rwasm_tracer};
pub use super::builder::WasmTraceBuilder;
pub use super::ccs::WasmVmSpec;
pub use super::ir::{StackLaneAccess, WasmBoundaryState, WasmBuildError, WasmStepTrace};
pub use super::isa::{opcode_info_from_code, WasmOpcode, WasmOpcodeClass, WasmOpcodeInfo, WasmShoutOpcode};
pub use super::kernel::{
    prove_kernel_run, prove_simple_kernel, verify_kernel_run, verify_simple_kernel, WasmKernelError,
    WasmKernelOpeningSummary, WasmKernelOutput, WasmKernelPreparedStepSummary, WasmKernelProof, WasmKernelProverInput,
    WasmKernelPublicInput, WasmKernelRunProof, WasmKernelSelectedRowRef, WasmKernelStage1OpeningSummary,
    WasmKernelStage2OpeningSummary, WasmKernelStage3OpeningSummary, WasmKernelVerifierInput, WasmStage1ProofSet,
};
pub use super::lower::{build_row_traces, normalize_source, normalize_tracer, WasmExecutionStep, WasmTraceSource};
pub use super::stage1::{
    build_stage1_summary, prove_stage1_binary, prove_stage1_eqz, stage1_channel_label, stage1_mix_label,
    verify_stage1_binary, verify_stage1_eqz, Stage1BinaryProof, Stage1ChannelSummary, Stage1EqzProof,
    Stage1LookupRowBinding, Stage1Summary,
};
pub use super::stage2::{
    build_stage2_summary, prove_stage2_stack, verify_stage2_stack, Stage2StackProof, Stage2StackRowBinding,
    Stage2Summary,
};
pub use super::stage3::{
    build_stage3_summary, prove_stage3_boundaries, verify_stage3_boundaries, Stage3BoundaryProof,
    Stage3BoundaryRowBinding, Stage3BoundarySummary,
};
pub use super::tables::{lookup_payload, WasmLookupArity, WasmLookupPayload};

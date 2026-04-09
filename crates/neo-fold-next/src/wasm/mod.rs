//! Owns the WASM frontend scaffold.

pub mod adapters;
pub mod builder;
pub mod ccs;
pub mod ir;
pub mod isa;
pub mod kernel;
pub mod layout;
pub mod lower;
pub mod spec;
pub mod stage1;
pub mod stage2;
pub mod stage3;
pub mod tables;
pub mod trace;

pub use adapters::rwasm::{traces_from_rwasm_instr_states, traces_from_rwasm_tracer};
pub use adapters::wasmtime::{
    collect_wasmtime_steps, traces_from_wasmtime_steps, traces_from_wasmtime_wasm_bytes, WasmtimeTraceMemoryAccess,
    WasmtimeTraceRun, WasmtimeTraceStep,
};
pub use builder::WasmTraceBuilder;
pub use ccs::WasmVmSpec;
pub use ir::{boundary_states, StackLaneAccess, WasmBoundaryState, WasmBuildError, WasmStepTrace};
pub use isa::{opcode_code, opcode_info_from_code, WasmOpcode, WasmOpcodeClass, WasmOpcodeInfo, WasmShoutOpcode};
pub use kernel::{
    prove_kernel_run, prove_simple_kernel, verify_kernel_run, verify_simple_kernel, WasmKernelError,
    WasmKernelOpeningSummary, WasmKernelOutput, WasmKernelPreparedStepSummary, WasmKernelProof, WasmKernelProverInput,
    WasmKernelPublicInput, WasmKernelRunProof, WasmKernelSelectedRowRef, WasmKernelStage1OpeningSummary,
    WasmKernelStage2OpeningSummary, WasmKernelStage3OpeningSummary, WasmKernelVerifierInput, WasmStage1ProofSet,
};
pub use lower::{build_row_traces, normalize_source, normalize_tracer, WasmExecutionStep, WasmTraceSource};
pub use stage1::{
    build_stage1_summary, prove_stage1_binary, prove_stage1_eqz, stage1_channel_label, stage1_mix_label,
    verify_stage1_binary, verify_stage1_eqz, Stage1BinaryProof, Stage1ChannelSummary, Stage1EqzProof,
    Stage1LookupRowBinding, Stage1Summary,
};
pub use stage2::{
    build_stage2_summary, prove_stage2_stack, verify_stage2_stack, Stage2StackProof, Stage2StackRowBinding,
    Stage2Summary,
};
pub use stage3::{
    build_stage3_summary, prove_stage3_boundaries, verify_stage3_boundaries, Stage3BoundaryProof,
    Stage3BoundaryRowBinding, Stage3BoundarySummary,
};
pub use tables::{lookup_payload, WasmLookupArity, WasmLookupPayload};

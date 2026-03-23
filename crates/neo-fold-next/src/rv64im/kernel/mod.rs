//! Owns the RV64IM parity-slice kernel artifacts and transcript logging.

mod artifacts;
mod transcript;

pub use artifacts::{
    aligned_memory_focus_manifest, build_aligned_memory_focus_parity_case, build_all_parity_cases,
    build_control_flow_focus_parity_case, build_native_alu_focus_parity_case, build_vertical_slice_parity_case,
    control_flow_focus_manifest, native_alu_focus_manifest, parity_source_cases, vertical_slice_manifest,
    Rv64imKernelSummary, Rv64imParityCaseManifest, Rv64imParityDerivedCase, Rv64imParitySourceCase,
};
pub use transcript::{TranscriptCursorSnapshot, TranscriptEventKind, TranscriptEventRecord, TranscriptRecord};

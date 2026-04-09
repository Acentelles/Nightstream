//! Owns the exact Stage 3 boundary summary for WASM.

use super::super::ir::WasmStepTrace;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Stage3BoundaryRowBinding {
    pub trace_index: usize,
    pub cycle: u64,
    pub pc_before: u64,
    pub pc_after: u64,
    pub sp_before: u64,
    pub sp_after: u64,
    pub halted: bool,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Stage3BoundarySummary {
    pub rows: Vec<Stage3BoundaryRowBinding>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct Stage3BoundaryProof {
    pub rows: Vec<Stage3BoundaryRowBinding>,
    pub continuity_batched_claim: neo_math::K,
    pub start_boundary: Option<(u64, u64)>,
    pub final_boundary: Option<(u64, u64, bool)>,
}

pub fn build_stage3_summary(steps: &[WasmStepTrace]) -> Stage3BoundarySummary {
    Stage3BoundarySummary {
        rows: steps
            .iter()
            .enumerate()
            .map(|(trace_index, step)| Stage3BoundaryRowBinding {
                trace_index,
                cycle: step.cycle,
                pc_before: step.pc_before,
                pc_after: step.pc_after,
                sp_before: step.sp_before,
                sp_after: step.sp_after,
                halted: step.halted,
            })
            .collect(),
    }
}

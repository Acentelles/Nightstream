//! Owns the exact Stage 2 stack-row summary for WASM.

use super::super::ir::{StackLaneAccess, WasmStepTrace};

#[derive(Clone, Copy, Debug, Eq, PartialEq, Hash)]
pub enum Stage2StackAccessFamily {
    Read0,
    Read1,
    Read2,
    Write1,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Stage2StackRowBinding {
    pub trace_index: usize,
    pub cycle: u64,
    pub read0: Option<StackLaneAccess>,
    pub read1: Option<StackLaneAccess>,
    pub read2: Option<StackLaneAccess>,
    pub write1: Option<StackLaneAccess>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Stage2Summary {
    pub rows: Vec<Stage2StackRowBinding>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Stage2FamilyClaim {
    pub family: Stage2StackAccessFamily,
    pub claim: neo_math::K,
}

#[derive(Clone, Debug, PartialEq)]
pub struct Stage2StackProof {
    pub rows: Vec<Stage2StackRowBinding>,
    pub batched_read_claim: neo_math::K,
    pub family_claims: Vec<Stage2FamilyClaim>,
    pub value_from_inc_claim: neo_math::K,
    pub gamma_twist_link: neo_math::K,
    pub linkage_batch_value: neo_math::K,
    pub final_slots: Vec<(u64, u32)>,
}

pub fn build_stage2_summary(steps: &[WasmStepTrace]) -> Stage2Summary {
    Stage2Summary {
        rows: steps
            .iter()
            .enumerate()
            .map(|(trace_index, step)| Stage2StackRowBinding {
                trace_index,
                cycle: step.cycle,
                read0: step.stack_read0,
                read1: step.stack_read1,
                read2: step.stack_read2,
                write1: step.stack_write1,
            })
            .collect(),
    }
}

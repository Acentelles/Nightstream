//! Owns Stage 3 continuity and export summaries for the RV64IM parity slice.

use serde::{Deserialize, Serialize};

use crate::rv64im::lower::Rv64ExpandedRow;

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct ContinuityEvent {
    pub step_index: usize,
    pub pc: u64,
    pub next_pc: u64,
    pub successor_pc: Option<u64>,
    pub final_step: bool,
    pub continuity_holds: bool,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage3Summary {
    pub continuity: Vec<ContinuityEvent>,
    pub halted: bool,
}

pub fn build_stage3_summary(rows: &[Rv64ExpandedRow]) -> Stage3Summary {
    let real_rows = rows.iter().filter(|row| row.is_real).collect::<Vec<_>>();
    let continuity = real_rows
        .iter()
        .enumerate()
        .map(|(idx, row)| {
            let successor_pc = real_rows.get(idx + 1).map(|next| next.pc);
            let final_step = idx + 1 == real_rows.len();
            let continuity_holds = successor_pc.is_none_or(|pc| row.next_pc == pc);
            ContinuityEvent {
                step_index: row.step_index,
                pc: row.pc,
                next_pc: row.next_pc,
                successor_pc,
                final_step,
                continuity_holds,
            }
        })
        .collect::<Vec<_>>();

    Stage3Summary {
        halted: real_rows.last().is_some_and(|row| row.halted),
        continuity,
    }
}

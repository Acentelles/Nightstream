//! Owns Stage 3 continuity and export summaries for the RV64IM parity slice.

use neo_transcript::{Poseidon2Transcript, Transcript};
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

pub(crate) fn continuity_event_words(event: &ContinuityEvent) -> [u64; 6] {
    [
        event.step_index as u64,
        event.pc,
        event.next_pc,
        event.successor_pc.unwrap_or(0),
        event.final_step as u64,
        event.continuity_holds as u64,
    ]
}

pub(crate) fn continuity_event_digest(event: &ContinuityEvent) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage3_selected_continuity");
    tr.append_u64s_iter(
        b"stage3/continuity",
        8,
        std::iter::once(event.final_step as u64)
            .chain(std::iter::once(1u64))
            .chain(continuity_event_words(event).into_iter()),
    );
    tr.digest32()
}

pub fn build_stage3_summary(rows: &[Rv64ExpandedRow]) -> Stage3Summary {
    let real_rows = rows.iter().filter(|row| row.is_real).collect::<Vec<_>>();
    let mut continuity = Vec::with_capacity(real_rows.len());

    for (idx, row) in real_rows.iter().enumerate() {
        let successor_pc = real_rows.get(idx + 1).map(|next| next.pc);
        let final_step = idx + 1 == real_rows.len();
        let continuity_holds = successor_pc.is_none_or(|pc| row.next_pc == pc);
        let event = ContinuityEvent {
            step_index: row.step_index,
            pc: row.pc,
            next_pc: row.next_pc,
            successor_pc,
            final_step,
            continuity_holds,
        };
        continuity.push(event);
    }

    Stage3Summary {
        halted: real_rows.last().is_some_and(|row| row.halted),
        continuity,
    }
}

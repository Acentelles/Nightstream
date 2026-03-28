//! Owns the exact Stage 1 row-binding and helper-result summaries for the RV64IM parity slice.

use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};

use crate::rv64im::kernel::{family_word, opcode_word, trace_virtual_opcode_word};
use crate::rv64im::lower::{Rv64ExpandedRow, Rv64TraceVirtualOpcode};
use crate::rv64im::tables::Rv64FamilyTag;

use crate::rv64im::isa::Rv64Opcode;

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage1RowBinding {
    pub trace_index: usize,
    pub step_index: usize,
    pub sequence_index: usize,
    pub fetch_pc: u64,
    pub fetched_word: u32,
    pub opcode: Rv64Opcode,
    pub trace_opcode: Option<Rv64Opcode>,
    pub trace_virtual_opcode: Option<Rv64TraceVirtualOpcode>,
    pub family: Rv64FamilyTag,
    pub next_pc: u64,
    pub alu_result: u64,
    pub effective_addr: Option<u64>,
    pub writes_rd: bool,
    pub rd: u8,
    pub rd_after: u64,
    pub is_first_in_sequence: bool,
    pub virtual_sequence_remaining: Option<u16>,
    pub is_effect_row: bool,
    pub is_commit_row: bool,
    pub is_real: bool,
    pub preserves_x0: bool,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage1Summary {
    pub rows: Vec<Stage1RowBinding>,
}

pub(crate) fn stage1_row_words(row: &Stage1RowBinding) -> [u64; 23] {
    [
        row.trace_index as u64,
        row.step_index as u64,
        row.sequence_index as u64,
        row.fetch_pc,
        row.fetched_word as u64,
        opcode_word(row.opcode),
        row.trace_opcode.map(opcode_word).unwrap_or(0),
        row.trace_virtual_opcode
            .map(trace_virtual_opcode_word)
            .unwrap_or(0),
        row.trace_opcode.is_some() as u64,
        row.trace_virtual_opcode.is_some() as u64,
        family_word(row.family),
        row.next_pc,
        row.alu_result,
        row.effective_addr.unwrap_or(0),
        row.writes_rd as u64,
        row.rd as u64,
        row.rd_after,
        row.is_first_in_sequence as u64,
        row.virtual_sequence_remaining.unwrap_or(u16::MAX) as u64,
        row.is_effect_row as u64,
        row.is_commit_row as u64,
        row.is_real as u64,
        row.preserves_x0 as u64,
    ]
}

pub(crate) fn stage1_row_digest(row: &Stage1RowBinding) -> [u8; 32] {
    let words = stage1_row_words(row);
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage1_selected_row");
    tr.append_u64s_iter(b"stage1/row", words.len(), words.into_iter());
    tr.digest32()
}

pub fn build_stage1_summary(rows: &[Rv64ExpandedRow]) -> Stage1Summary {
    Stage1Summary {
        rows: rows
            .iter()
            .map(|row| Stage1RowBinding {
                trace_index: row.trace_index,
                step_index: row.step_index,
                sequence_index: row.sequence_index,
                fetch_pc: row.pc,
                fetched_word: row.word,
                opcode: row.opcode,
                trace_opcode: row.trace_opcode,
                trace_virtual_opcode: row.trace_virtual_opcode,
                family: row.family,
                next_pc: row.next_pc,
                alu_result: row.alu_result,
                effective_addr: row.effective_addr,
                writes_rd: row.writes_rd,
                rd: row.rd,
                rd_after: row.rd_after,
                is_first_in_sequence: row.is_first_in_sequence,
                virtual_sequence_remaining: row.virtual_sequence_remaining,
                is_effect_row: row.is_effect_row,
                is_commit_row: row.is_commit_row,
                is_real: row.is_real,
                preserves_x0: row.rd == 0 || !row.writes_rd,
            })
            .collect(),
    }
}

//! Owns the exact Stage 1 row-binding and helper-result summaries for the RV64IM parity slice.

use serde::{Deserialize, Serialize};

use crate::rv64im::lower::Rv64ExpandedRow;
use crate::rv64im::tables::Rv64FamilyTag;

use crate::rv64im::isa::Rv64Opcode;

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage1RowBinding {
    pub step_index: usize,
    pub fetch_pc: u64,
    pub fetched_word: u32,
    pub opcode: Rv64Opcode,
    pub family: Rv64FamilyTag,
    pub next_pc: u64,
    pub alu_result: u64,
    pub effective_addr: Option<u64>,
    pub writes_rd: bool,
    pub rd: u8,
    pub rd_after: u64,
    pub preserves_x0: bool,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage1Summary {
    pub rows: Vec<Stage1RowBinding>,
}

pub fn build_stage1_summary(rows: &[Rv64ExpandedRow]) -> Stage1Summary {
    Stage1Summary {
        rows: rows
            .iter()
            .map(|row| Stage1RowBinding {
                step_index: row.step_index,
                fetch_pc: row.pc,
                fetched_word: row.word,
                opcode: row.opcode,
                family: row.family,
                next_pc: row.next_pc,
                alu_result: row.alu_result,
                effective_addr: row.effective_addr,
                writes_rd: row.writes_rd,
                rd: row.rd,
                rd_after: row.rd_after,
                preserves_x0: row.rd == 0 || !row.writes_rd,
            })
            .collect(),
    }
}

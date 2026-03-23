//! Owns Stage 2 register history, RAM history, and Twist-link summaries for the RV64IM parity slice.

use serde::{Deserialize, Serialize};

use crate::rv64im::isa::Rv64Opcode;
use crate::rv64im::lower::Rv64ExpandedRow;
use crate::rv64im::tables::Rv64FamilyTag;

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub enum RegisterReadRole {
    Rs1,
    Rs2,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RegisterReadEvent {
    pub step_index: usize,
    pub role: RegisterReadRole,
    pub reg: u8,
    pub value: u64,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RegisterWriteEvent {
    pub step_index: usize,
    pub reg: u8,
    pub previous: u64,
    pub next: u64,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub enum RamAccessKind {
    Read,
    Write,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RamEvent {
    pub step_index: usize,
    pub kind: RamAccessKind,
    pub addr: u64,
    pub previous: u64,
    pub next: u64,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct TwistLinkEvent {
    pub step_index: usize,
    pub family: Rv64FamilyTag,
    pub routed_write_value: Option<u64>,
    pub routed_memory_before: Option<u64>,
    pub routed_memory_after: Option<u64>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage2Summary {
    pub register_reads: Vec<RegisterReadEvent>,
    pub register_writes: Vec<RegisterWriteEvent>,
    pub ram_events: Vec<RamEvent>,
    pub twist_links: Vec<TwistLinkEvent>,
}

pub fn build_stage2_summary(rows: &[Rv64ExpandedRow]) -> Stage2Summary {
    let mut register_reads = Vec::new();
    let mut register_writes = Vec::new();
    let mut ram_events = Vec::new();
    let mut twist_links = Vec::new();

    for row in rows {
        match row.opcode {
            Rv64Opcode::Addi | Rv64Opcode::Ld | Rv64Opcode::Sd => {
                register_reads.push(RegisterReadEvent {
                    step_index: row.step_index,
                    role: RegisterReadRole::Rs1,
                    reg: row.rs1,
                    value: row.rs1_value,
                });
            }
            Rv64Opcode::Add => {
                register_reads.push(RegisterReadEvent {
                    step_index: row.step_index,
                    role: RegisterReadRole::Rs1,
                    reg: row.rs1,
                    value: row.rs1_value,
                });
                register_reads.push(RegisterReadEvent {
                    step_index: row.step_index,
                    role: RegisterReadRole::Rs2,
                    reg: row.rs2,
                    value: row.rs2_value,
                });
            }
            Rv64Opcode::Ecall => {}
        }

        if row.writes_rd {
            register_writes.push(RegisterWriteEvent {
                step_index: row.step_index,
                reg: row.rd,
                previous: row.rd_before,
                next: row.rd_after,
            });
        }

        if let Some(addr) = row.effective_addr {
            if let Some(before) = row.memory_before {
                let next = row.memory_after.unwrap_or(before);
                let kind = if row.writes_ram {
                    RamAccessKind::Write
                } else {
                    RamAccessKind::Read
                };
                ram_events.push(RamEvent {
                    step_index: row.step_index,
                    kind,
                    addr,
                    previous: before,
                    next,
                });
            }
        }

        twist_links.push(TwistLinkEvent {
            step_index: row.step_index,
            family: row.family,
            routed_write_value: row.writes_rd.then_some(row.rd_after),
            routed_memory_before: row.memory_before,
            routed_memory_after: row.memory_after,
        });
    }

    Stage2Summary {
        register_reads,
        register_writes,
        ram_events,
        twist_links,
    }
}

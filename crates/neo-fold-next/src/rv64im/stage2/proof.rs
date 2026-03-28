//! Owns Stage 2 register history, RAM history, and Twist-link summaries for the RV64IM parity slice.

use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};

use crate::rv64im::isa::Rv64Opcode;
use crate::rv64im::kernel::{family_word, ram_access_kind_word, register_read_role_word};
use crate::rv64im::lower::{Rv64ExpandedRow, Rv64TraceVirtualOpcode};
use crate::rv64im::tables::Rv64FamilyTag;

#[derive(Clone, Copy, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub enum RegisterReadRole {
    Rs1,
    Rs2,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RegisterReadEvent {
    pub trace_index: usize,
    pub step_index: usize,
    pub role: RegisterReadRole,
    pub reg: u8,
    pub value: u64,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RegisterWriteEvent {
    pub trace_index: usize,
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
    pub trace_index: usize,
    pub step_index: usize,
    pub kind: RamAccessKind,
    pub addr: u64,
    pub previous: u64,
    pub next: u64,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct TwistLinkEvent {
    pub trace_index: usize,
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

pub(crate) fn register_read_words(event: &RegisterReadEvent) -> [u64; 5] {
    [
        event.trace_index as u64,
        event.step_index as u64,
        register_read_role_word(event.role),
        event.reg as u64,
        event.value,
    ]
}

pub(crate) fn register_write_words(event: &RegisterWriteEvent) -> [u64; 5] {
    [
        event.trace_index as u64,
        event.step_index as u64,
        event.reg as u64,
        event.previous,
        event.next,
    ]
}

pub(crate) fn ram_event_words(event: &RamEvent) -> [u64; 6] {
    [
        event.trace_index as u64,
        event.step_index as u64,
        ram_access_kind_word(event.kind),
        event.addr,
        event.previous,
        event.next,
    ]
}

pub(crate) fn twist_link_words(event: &TwistLinkEvent) -> [u64; 6] {
    [
        event.trace_index as u64,
        event.step_index as u64,
        family_word(event.family),
        event.routed_write_value.unwrap_or(0),
        event.routed_memory_before.unwrap_or(0),
        event.routed_memory_after.unwrap_or(0),
    ]
}

pub(crate) fn register_read_event_digest(event: &RegisterReadEvent) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage2_selected_register_read");
    tr.append_u64s_iter(
        b"stage2/read",
        9,
        std::iter::once(1u64)
            .chain(register_read_words(event).into_iter())
            .chain(std::iter::once(0u64))
            .chain(std::iter::once(0u64))
            .chain(std::iter::once(0u64)),
    );
    tr.digest32()
}

pub(crate) fn register_write_event_digest(event: &RegisterWriteEvent) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage2_selected_register_write");
    tr.append_u64s_iter(
        b"stage2/write",
        9,
        std::iter::once(0u64)
            .chain(std::iter::once(1u64))
            .chain(register_write_words(event).into_iter())
            .chain(std::iter::once(0u64))
            .chain(std::iter::once(0u64)),
    );
    tr.digest32()
}

pub(crate) fn ram_event_digest(event: &RamEvent) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage2_selected_ram_event");
    tr.append_u64s_iter(
        b"stage2/ram",
        10,
        std::iter::once(0u64)
            .chain(std::iter::once(0u64))
            .chain(std::iter::once(1u64))
            .chain(ram_event_words(event).into_iter())
            .chain(std::iter::once(0u64)),
    );
    tr.digest32()
}

pub(crate) fn twist_link_event_digest(event: &TwistLinkEvent) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage2_selected_twist_link");
    tr.append_u64s_iter(
        b"stage2/twist",
        10,
        std::iter::once(0u64)
            .chain(std::iter::once(0u64))
            .chain(std::iter::once(0u64))
            .chain(std::iter::once(1u64))
            .chain(twist_link_words(event).into_iter()),
    );
    tr.digest32()
}

fn row_reads_rs1(row: &Rv64ExpandedRow) -> bool {
    matches!(
        row.trace_opcode,
        Some(
            Rv64Opcode::Addi
                | Rv64Opcode::Add
                | Rv64Opcode::Sub
                | Rv64Opcode::Addiw
                | Rv64Opcode::Addw
                | Rv64Opcode::Subw
                | Rv64Opcode::Andi
                | Rv64Opcode::And
                | Rv64Opcode::Ori
                | Rv64Opcode::Or
                | Rv64Opcode::Xori
                | Rv64Opcode::Xor
                | Rv64Opcode::Slti
                | Rv64Opcode::Slt
                | Rv64Opcode::Sltiu
                | Rv64Opcode::Sltu
                | Rv64Opcode::Slli
                | Rv64Opcode::Sll
                | Rv64Opcode::Srli
                | Rv64Opcode::Srl
                | Rv64Opcode::Srai
                | Rv64Opcode::Sra
                | Rv64Opcode::Slliw
                | Rv64Opcode::Sllw
                | Rv64Opcode::Srliw
                | Rv64Opcode::Srlw
                | Rv64Opcode::Sraiw
                | Rv64Opcode::Sraw
                | Rv64Opcode::Mul
                | Rv64Opcode::Mulhu
                | Rv64Opcode::Div
                | Rv64Opcode::Divu
                | Rv64Opcode::Rem
                | Rv64Opcode::Remu
                | Rv64Opcode::Divw
                | Rv64Opcode::Divuw
                | Rv64Opcode::Remw
                | Rv64Opcode::Remuw
                | Rv64Opcode::Lb
                | Rv64Opcode::Lbu
                | Rv64Opcode::Lh
                | Rv64Opcode::Lhu
                | Rv64Opcode::Lw
                | Rv64Opcode::Lwu
                | Rv64Opcode::Ld
                | Rv64Opcode::Sb
                | Rv64Opcode::Sh
                | Rv64Opcode::Sw
                | Rv64Opcode::Sd
                | Rv64Opcode::Jalr
                | Rv64Opcode::Beq
                | Rv64Opcode::Bne
                | Rv64Opcode::Blt
                | Rv64Opcode::Bge
                | Rv64Opcode::Bltu
                | Rv64Opcode::Bgeu
        )
    ) || row.trace_virtual_opcode.is_some()
}

fn row_reads_rs2(row: &Rv64ExpandedRow) -> bool {
    matches!(
        row.trace_opcode,
        Some(
            Rv64Opcode::Add
                | Rv64Opcode::Sub
                | Rv64Opcode::Addw
                | Rv64Opcode::Subw
                | Rv64Opcode::And
                | Rv64Opcode::Or
                | Rv64Opcode::Xor
                | Rv64Opcode::Slt
                | Rv64Opcode::Sltu
                | Rv64Opcode::Sll
                | Rv64Opcode::Srl
                | Rv64Opcode::Sra
                | Rv64Opcode::Sllw
                | Rv64Opcode::Srlw
                | Rv64Opcode::Sraw
                | Rv64Opcode::Mul
                | Rv64Opcode::Mulhu
                | Rv64Opcode::Div
                | Rv64Opcode::Divu
                | Rv64Opcode::Rem
                | Rv64Opcode::Remu
                | Rv64Opcode::Divw
                | Rv64Opcode::Divuw
                | Rv64Opcode::Remw
                | Rv64Opcode::Remuw
                | Rv64Opcode::Sb
                | Rv64Opcode::Sh
                | Rv64Opcode::Sw
                | Rv64Opcode::Sd
                | Rv64Opcode::Beq
                | Rv64Opcode::Bne
                | Rv64Opcode::Blt
                | Rv64Opcode::Bge
                | Rv64Opcode::Bltu
                | Rv64Opcode::Bgeu
        )
    ) || matches!(
        row.trace_virtual_opcode,
        Some(
            Rv64TraceVirtualOpcode::Advice
                | Rv64TraceVirtualOpcode::ChangeDivisor
                | Rv64TraceVirtualOpcode::AssertValidDiv0
                | Rv64TraceVirtualOpcode::AssertMulNoOverflow
                | Rv64TraceVirtualOpcode::AssertLte
                | Rv64TraceVirtualOpcode::AssertValidUnsignedRemainder
                | Rv64TraceVirtualOpcode::AssertSignedDivIdentity
                | Rv64TraceVirtualOpcode::AssertSignedRemainderBounds
        )
    )
}

pub fn build_stage2_summary(rows: &[Rv64ExpandedRow]) -> Stage2Summary {
    let mut register_reads = Vec::new();
    let mut register_writes = Vec::new();
    let mut ram_events = Vec::new();
    let mut twist_links = Vec::new();

    for row in rows {
        if row_reads_rs1(row) {
            let event = RegisterReadEvent {
                trace_index: row.trace_index,
                step_index: row.step_index,
                role: RegisterReadRole::Rs1,
                reg: row.rs1,
                value: row.rs1_value,
            };
            register_reads.push(event);
        }
        if row_reads_rs2(row) {
            let event = RegisterReadEvent {
                trace_index: row.trace_index,
                step_index: row.step_index,
                role: RegisterReadRole::Rs2,
                reg: row.rs2,
                value: row.rs2_value,
            };
            register_reads.push(event);
        }

        if row.writes_rd {
            let event = RegisterWriteEvent {
                trace_index: row.trace_index,
                step_index: row.step_index,
                reg: row.rd,
                previous: row.rd_before,
                next: row.rd_after,
            };
            register_writes.push(event);
        }

        if let Some(addr) = row.effective_addr {
            if let Some(before) = row.memory_before {
                let next = row.memory_after.unwrap_or(before);
                let kind = if row.writes_ram {
                    RamAccessKind::Write
                } else {
                    RamAccessKind::Read
                };
                let event = RamEvent {
                    trace_index: row.trace_index,
                    step_index: row.step_index,
                    kind,
                    addr,
                    previous: before,
                    next,
                };
                ram_events.push(event);
            }
        }

        let twist = TwistLinkEvent {
            trace_index: row.trace_index,
            step_index: row.step_index,
            family: row.family,
            routed_write_value: row.writes_rd.then_some(row.rd_after),
            routed_memory_before: row.memory_before,
            routed_memory_after: row.memory_after,
        };
        twist_links.push(twist);
    }

    Stage2Summary {
        register_reads,
        register_writes,
        ram_events,
        twist_links,
    }
}

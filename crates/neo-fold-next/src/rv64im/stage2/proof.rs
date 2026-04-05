//! Owns Stage 2 register history, RAM history, and Twist-link summaries for the RV64IM parity slice.

use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};

use crate::rv64im::isa::Rv64Opcode;
use crate::rv64im::kernel::{
    family_word, ram_access_kind_word, register_read_role_word, Stage2ArtifactSurface, Stage2PackagedOpeningProof,
};
use crate::rv64im::lower::{Rv64ExpandedRow, Rv64TraceVirtualOpcode};
use crate::rv64im::tables::Rv64FamilyTag;

use super::semantics::Stage2SemanticsProof;

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

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RegisterTwistProof {
    pub reads: Vec<RegisterReadEvent>,
    pub writes: Vec<RegisterWriteEvent>,
    pub timeline_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct RamTwistProof {
    pub events: Vec<RamEvent>,
    pub timeline_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage2TemporalContext {
    pub twist_links: Vec<TwistLinkEvent>,
    pub register_timeline_digest: [u8; 32],
    pub ram_timeline_digest: [u8; 32],
    pub twist_links_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage2LinkageProof {
    pub register_reads_family_digest: [u8; 32],
    pub register_writes_family_digest: [u8; 32],
    pub ram_events_family_digest: [u8; 32],
    pub twist_links_family_digest: [u8; 32],
    pub reg_mix: u64,
    pub ram_mix: u64,
    pub packaged_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Stage2ProofBundle {
    pub register: RegisterTwistProof,
    pub ram: RamTwistProof,
    pub temporal: Stage2TemporalContext,
    pub semantics: Stage2SemanticsProof,
    pub linkage: Stage2LinkageProof,
    pub selected_opening: Stage2PackagedOpeningProof,
    pub digest: [u8; 32],
}

pub(crate) fn canonical_ram_addr(row: &Rv64ExpandedRow, addr: u64) -> u64 {
    match row.trace_opcode {
        Some(
            Rv64Opcode::Lb
            | Rv64Opcode::Lbu
            | Rv64Opcode::Lh
            | Rv64Opcode::Lhu
            | Rv64Opcode::Lw
            | Rv64Opcode::Lwu
            | Rv64Opcode::Sb
            | Rv64Opcode::Sh
            | Rv64Opcode::Sw,
        ) => addr & !0x7,
        _ => addr,
    }
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

pub(super) fn row_reads_rs1(row: &Rv64ExpandedRow) -> bool {
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

pub(super) fn row_reads_rs2(row: &Rv64ExpandedRow) -> bool {
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
                    addr: canonical_ram_addr(row, addr),
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

fn digest_event_sequence(label: &'static [u8], digests: impl IntoIterator<Item = [u8; 32]>, len: usize) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(label);
    tr.append_u64s(b"meta", &[len as u64]);
    for digest in digests {
        tr.append_message(b"entry", &digest);
    }
    tr.digest32()
}

impl RegisterTwistProof {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage2_register_twist_proof");
        tr.append_message(
            b"rv64im/stage2_register_twist_proof/timeline_digest",
            &self.timeline_digest,
        );
        tr.append_u64s(
            b"rv64im/stage2_register_twist_proof/meta",
            &[self.reads.len() as u64, self.writes.len() as u64],
        );
        tr.digest32()
    }
}

impl RamTwistProof {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage2_ram_twist_proof");
        tr.append_message(b"rv64im/stage2_ram_twist_proof/timeline_digest", &self.timeline_digest);
        tr.append_u64s(b"rv64im/stage2_ram_twist_proof/meta", &[self.events.len() as u64]);
        tr.digest32()
    }
}

impl Stage2TemporalContext {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage2_temporal_context");
        tr.append_message(
            b"rv64im/stage2_temporal_context/register_timeline_digest",
            &self.register_timeline_digest,
        );
        tr.append_message(
            b"rv64im/stage2_temporal_context/ram_timeline_digest",
            &self.ram_timeline_digest,
        );
        tr.append_message(
            b"rv64im/stage2_temporal_context/twist_links_digest",
            &self.twist_links_digest,
        );
        tr.append_u64s(b"rv64im/stage2_temporal_context/meta", &[self.twist_links.len() as u64]);
        tr.digest32()
    }
}

impl Stage2LinkageProof {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage2_linkage_proof");
        tr.append_message(
            b"rv64im/stage2_linkage_proof/register_reads_family_digest",
            &self.register_reads_family_digest,
        );
        tr.append_message(
            b"rv64im/stage2_linkage_proof/register_writes_family_digest",
            &self.register_writes_family_digest,
        );
        tr.append_message(
            b"rv64im/stage2_linkage_proof/ram_events_family_digest",
            &self.ram_events_family_digest,
        );
        tr.append_message(
            b"rv64im/stage2_linkage_proof/twist_links_family_digest",
            &self.twist_links_family_digest,
        );
        tr.append_message(b"rv64im/stage2_linkage_proof/packaged_digest", &self.packaged_digest);
        tr.append_u64s(b"rv64im/stage2_linkage_proof/meta", &[self.reg_mix, self.ram_mix]);
        tr.digest32()
    }
}

impl Stage2ProofBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage2_proof_bundle");
        tr.append_message(b"rv64im/stage2_proof_bundle/register", &self.register.digest);
        tr.append_message(b"rv64im/stage2_proof_bundle/ram", &self.ram.digest);
        tr.append_message(b"rv64im/stage2_proof_bundle/temporal", &self.temporal.digest);
        tr.append_message(b"rv64im/stage2_proof_bundle/semantics", &self.semantics.digest);
        tr.append_message(b"rv64im/stage2_proof_bundle/linkage", &self.linkage.digest);
        tr.append_message(
            b"rv64im/stage2_proof_bundle/selected_opening",
            &self.selected_opening.digest,
        );
        tr.digest32()
    }
}

pub(crate) fn register_timeline_digest(reads: &[RegisterReadEvent], writes: &[RegisterWriteEvent]) -> [u8; 32] {
    digest_event_sequence(
        b"neo.fold.next/rv64im/stage2_register_timeline",
        reads
            .iter()
            .map(register_read_event_digest)
            .chain(writes.iter().map(register_write_event_digest)),
        reads.len() + writes.len(),
    )
}

pub(crate) fn ram_timeline_digest(events: &[RamEvent]) -> [u8; 32] {
    digest_event_sequence(
        b"neo.fold.next/rv64im/stage2_ram_timeline",
        events.iter().map(ram_event_digest),
        events.len(),
    )
}

pub(crate) fn twist_links_timeline_digest(events: &[TwistLinkEvent]) -> [u8; 32] {
    digest_event_sequence(
        b"neo.fold.next/rv64im/stage2_twist_links",
        events.iter().map(twist_link_event_digest),
        events.len(),
    )
}

pub fn build_stage2_proof_bundle(
    summary: &Stage2Summary,
    artifact: &Stage2ArtifactSurface,
    selected_opening: &Stage2PackagedOpeningProof,
) -> Stage2ProofBundle {
    let register_timeline_digest = register_timeline_digest(&summary.register_reads, &summary.register_writes);
    let ram_timeline_digest = ram_timeline_digest(&summary.ram_events);
    let twist_links_digest = twist_links_timeline_digest(&summary.twist_links);

    let register = RegisterTwistProof {
        reads: summary.register_reads.clone(),
        writes: summary.register_writes.clone(),
        timeline_digest: register_timeline_digest,
        digest: [0; 32],
    };
    let register = RegisterTwistProof {
        digest: register.expected_digest(),
        ..register
    };
    let ram = RamTwistProof {
        events: summary.ram_events.clone(),
        timeline_digest: ram_timeline_digest,
        digest: [0; 32],
    };
    let ram = RamTwistProof {
        digest: ram.expected_digest(),
        ..ram
    };
    let temporal = Stage2TemporalContext {
        twist_links: summary.twist_links.clone(),
        register_timeline_digest,
        ram_timeline_digest,
        twist_links_digest,
        digest: [0; 32],
    };
    let temporal = Stage2TemporalContext {
        digest: temporal.expected_digest(),
        ..temporal
    };
    let semantics = Stage2SemanticsProof::new(summary);
    let linkage = Stage2LinkageProof {
        register_reads_family_digest: artifact.families.register_reads_digest,
        register_writes_family_digest: artifact.families.register_writes_digest,
        ram_events_family_digest: artifact.families.ram_events_digest,
        twist_links_family_digest: artifact.families.twist_links_digest,
        reg_mix: artifact.claim.reg_mix,
        ram_mix: artifact.claim.ram_mix,
        packaged_digest: selected_opening.digest,
        digest: [0; 32],
    };
    let linkage = Stage2LinkageProof {
        digest: linkage.expected_digest(),
        ..linkage
    };
    let bundle = Stage2ProofBundle {
        register,
        ram,
        temporal,
        semantics,
        linkage,
        selected_opening: selected_opening.clone(),
        digest: [0; 32],
    };
    Stage2ProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

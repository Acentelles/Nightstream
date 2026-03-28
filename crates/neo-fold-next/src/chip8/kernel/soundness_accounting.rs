//! Owns the exact symbolic soundness-accounting export for the CHIP-8 kernel.
//! This mirrors the finite families and decomposition from spec §10 without
//! pretending Rust proves negligibility internally.

use neo_transcript::{Poseidon2Transcript, Transcript};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Stage1ShoutChannel {
    Fetch,
    Decode,
    Alu,
    Eq4,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum AddressFamily {
    Fetch,
    Decode,
    Alu,
    Eq4,
    RegRaX,
    RegRaY,
    RegRaI,
    RegWa,
    RamRa,
    RamWa,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum TwistReadFamily {
    RegX,
    RegY,
    RegI,
    Ram,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum TwistMemoryFamily {
    Reg,
    Ram,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum KernelErrorTerm {
    ShoutCore(Stage1ShoutChannel),
    Addr(AddressFamily),
    TwistRead(TwistReadFamily),
    TwistWrite(TwistMemoryFamily),
    TwistVal(TwistMemoryFamily),
    RamRafRead,
    RamRafWrite,
    ShiftReduce,
    Continuity,
    RegRwBatch,
    RamRwBatch,
    LookupLink,
    TwistLink,
    Pcs,
    Fs,
    Outer,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct KernelErrorSurface {
    pub stage1_channels: Vec<Stage1ShoutChannel>,
    pub stage1_address_families: Vec<AddressFamily>,
    pub reg_read_families: Vec<TwistReadFamily>,
    pub reg_address_families: Vec<AddressFamily>,
    pub ram_address_families: Vec<AddressFamily>,
    pub twist_memory_families: Vec<TwistMemoryFamily>,
    pub stage1_terms: Vec<KernelErrorTerm>,
    pub stage2_terms: Vec<KernelErrorTerm>,
    pub stage3_terms: Vec<KernelErrorTerm>,
    pub batch_terms: Vec<KernelErrorTerm>,
    pub tail_terms: Vec<KernelErrorTerm>,
    pub total_upper_digest: [u8; 32],
    pub digest: [u8; 32],
}

impl KernelErrorSurface {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_error_surface");
        append_stage1_channels(
            &mut tr,
            b"neo.fold.next/chip8/kernel_error_surface/stage1_channels",
            &self.stage1_channels,
        );
        append_address_families(
            &mut tr,
            b"neo.fold.next/chip8/kernel_error_surface/stage1_address_families",
            &self.stage1_address_families,
        );
        append_twist_read_families(
            &mut tr,
            b"neo.fold.next/chip8/kernel_error_surface/reg_read_families",
            &self.reg_read_families,
        );
        append_address_families(
            &mut tr,
            b"neo.fold.next/chip8/kernel_error_surface/reg_address_families",
            &self.reg_address_families,
        );
        append_address_families(
            &mut tr,
            b"neo.fold.next/chip8/kernel_error_surface/ram_address_families",
            &self.ram_address_families,
        );
        append_twist_memory_families(
            &mut tr,
            b"neo.fold.next/chip8/kernel_error_surface/twist_memory_families",
            &self.twist_memory_families,
        );
        append_error_terms(
            &mut tr,
            b"neo.fold.next/chip8/kernel_error_surface/stage1_terms",
            &self.stage1_terms,
        );
        append_error_terms(
            &mut tr,
            b"neo.fold.next/chip8/kernel_error_surface/stage2_terms",
            &self.stage2_terms,
        );
        append_error_terms(
            &mut tr,
            b"neo.fold.next/chip8/kernel_error_surface/stage3_terms",
            &self.stage3_terms,
        );
        append_error_terms(
            &mut tr,
            b"neo.fold.next/chip8/kernel_error_surface/batch_terms",
            &self.batch_terms,
        );
        append_error_terms(
            &mut tr,
            b"neo.fold.next/chip8/kernel_error_surface/tail_terms",
            &self.tail_terms,
        );
        tr.append_message(
            b"neo.fold.next/chip8/kernel_error_surface/total_upper_digest",
            &self.total_upper_digest,
        );
        tr.digest32()
    }
}

pub(crate) fn build_kernel_error_surface() -> KernelErrorSurface {
    let stage1_channels = vec![
        Stage1ShoutChannel::Fetch,
        Stage1ShoutChannel::Decode,
        Stage1ShoutChannel::Alu,
        Stage1ShoutChannel::Eq4,
    ];
    let stage1_address_families = vec![
        AddressFamily::Fetch,
        AddressFamily::Decode,
        AddressFamily::Alu,
        AddressFamily::Eq4,
    ];
    let reg_read_families = vec![TwistReadFamily::RegX, TwistReadFamily::RegY, TwistReadFamily::RegI];
    let reg_address_families = vec![
        AddressFamily::RegRaX,
        AddressFamily::RegRaY,
        AddressFamily::RegRaI,
        AddressFamily::RegWa,
    ];
    let ram_address_families = vec![AddressFamily::RamRa, AddressFamily::RamWa];
    let twist_memory_families = vec![TwistMemoryFamily::Reg, TwistMemoryFamily::Ram];

    let stage1_terms = vec![
        KernelErrorTerm::ShoutCore(Stage1ShoutChannel::Fetch),
        KernelErrorTerm::ShoutCore(Stage1ShoutChannel::Decode),
        KernelErrorTerm::ShoutCore(Stage1ShoutChannel::Alu),
        KernelErrorTerm::ShoutCore(Stage1ShoutChannel::Eq4),
        KernelErrorTerm::Addr(AddressFamily::Fetch),
        KernelErrorTerm::Addr(AddressFamily::Decode),
        KernelErrorTerm::Addr(AddressFamily::Alu),
        KernelErrorTerm::Addr(AddressFamily::Eq4),
    ];
    let stage2_terms = vec![
        KernelErrorTerm::TwistRead(TwistReadFamily::RegX),
        KernelErrorTerm::TwistRead(TwistReadFamily::RegY),
        KernelErrorTerm::TwistRead(TwistReadFamily::RegI),
        KernelErrorTerm::TwistWrite(TwistMemoryFamily::Reg),
        KernelErrorTerm::TwistVal(TwistMemoryFamily::Reg),
        KernelErrorTerm::Addr(AddressFamily::RegRaX),
        KernelErrorTerm::Addr(AddressFamily::RegRaY),
        KernelErrorTerm::Addr(AddressFamily::RegRaI),
        KernelErrorTerm::Addr(AddressFamily::RegWa),
        KernelErrorTerm::TwistRead(TwistReadFamily::Ram),
        KernelErrorTerm::TwistWrite(TwistMemoryFamily::Ram),
        KernelErrorTerm::TwistVal(TwistMemoryFamily::Ram),
        KernelErrorTerm::RamRafRead,
        KernelErrorTerm::RamRafWrite,
        KernelErrorTerm::Addr(AddressFamily::RamRa),
        KernelErrorTerm::Addr(AddressFamily::RamWa),
    ];
    let stage3_terms = vec![KernelErrorTerm::ShiftReduce, KernelErrorTerm::Continuity];
    let batch_terms = vec![
        KernelErrorTerm::RegRwBatch,
        KernelErrorTerm::RamRwBatch,
        KernelErrorTerm::LookupLink,
        KernelErrorTerm::TwistLink,
    ];
    let tail_terms = vec![KernelErrorTerm::Pcs, KernelErrorTerm::Fs, KernelErrorTerm::Outer];

    let total_upper_digest = digest_total_upper_terms(&[
        stage1_terms.as_slice(),
        stage2_terms.as_slice(),
        stage3_terms.as_slice(),
        batch_terms.as_slice(),
        tail_terms.as_slice(),
    ]);

    let surface = KernelErrorSurface {
        stage1_channels,
        stage1_address_families,
        reg_read_families,
        reg_address_families,
        ram_address_families,
        twist_memory_families,
        stage1_terms,
        stage2_terms,
        stage3_terms,
        batch_terms,
        tail_terms,
        total_upper_digest,
        digest: [0; 32],
    };
    KernelErrorSurface {
        digest: surface.expected_digest(),
        ..surface
    }
}

fn digest_total_upper_terms(stages: &[&[KernelErrorTerm]]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_error_surface/total_upper");
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_error_surface/total_upper/stage_count",
        &[stages.len() as u64],
    );
    for terms in stages {
        append_error_terms(
            &mut tr,
            b"neo.fold.next/chip8/kernel_error_surface/total_upper/stage_terms",
            terms,
        );
    }
    tr.digest32()
}

fn append_stage1_channels(tr: &mut Poseidon2Transcript, label: &'static [u8], channels: &[Stage1ShoutChannel]) {
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_error_surface/channel_len",
        &[channels.len() as u64],
    );
    for channel in channels {
        tr.append_u64s(label, &[stage1_channel_tag(*channel)]);
    }
}

fn append_address_families(tr: &mut Poseidon2Transcript, label: &'static [u8], families: &[AddressFamily]) {
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_error_surface/address_len",
        &[families.len() as u64],
    );
    for family in families {
        tr.append_u64s(label, &[address_family_tag(*family)]);
    }
}

fn append_twist_read_families(tr: &mut Poseidon2Transcript, label: &'static [u8], families: &[TwistReadFamily]) {
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_error_surface/twist_read_len",
        &[families.len() as u64],
    );
    for family in families {
        tr.append_u64s(label, &[twist_read_family_tag(*family)]);
    }
}

fn append_twist_memory_families(tr: &mut Poseidon2Transcript, label: &'static [u8], families: &[TwistMemoryFamily]) {
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_error_surface/twist_memory_len",
        &[families.len() as u64],
    );
    for family in families {
        tr.append_u64s(label, &[twist_memory_family_tag(*family)]);
    }
}

fn append_error_terms(tr: &mut Poseidon2Transcript, label: &'static [u8], terms: &[KernelErrorTerm]) {
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_error_surface/error_term_len",
        &[terms.len() as u64],
    );
    for term in terms {
        append_error_term(tr, label, *term);
    }
}

fn append_error_term(tr: &mut Poseidon2Transcript, label: &'static [u8], term: KernelErrorTerm) {
    match term {
        KernelErrorTerm::ShoutCore(channel) => tr.append_u64s(label, &[1, stage1_channel_tag(channel)]),
        KernelErrorTerm::Addr(family) => tr.append_u64s(label, &[2, address_family_tag(family)]),
        KernelErrorTerm::TwistRead(family) => tr.append_u64s(label, &[3, twist_read_family_tag(family)]),
        KernelErrorTerm::TwistWrite(family) => tr.append_u64s(label, &[4, twist_memory_family_tag(family)]),
        KernelErrorTerm::TwistVal(family) => tr.append_u64s(label, &[5, twist_memory_family_tag(family)]),
        KernelErrorTerm::RamRafRead => tr.append_u64s(label, &[6, 0]),
        KernelErrorTerm::RamRafWrite => tr.append_u64s(label, &[7, 0]),
        KernelErrorTerm::ShiftReduce => tr.append_u64s(label, &[8, 0]),
        KernelErrorTerm::Continuity => tr.append_u64s(label, &[9, 0]),
        KernelErrorTerm::RegRwBatch => tr.append_u64s(label, &[10, 0]),
        KernelErrorTerm::RamRwBatch => tr.append_u64s(label, &[11, 0]),
        KernelErrorTerm::LookupLink => tr.append_u64s(label, &[12, 0]),
        KernelErrorTerm::TwistLink => tr.append_u64s(label, &[13, 0]),
        KernelErrorTerm::Pcs => tr.append_u64s(label, &[14, 0]),
        KernelErrorTerm::Fs => tr.append_u64s(label, &[15, 0]),
        KernelErrorTerm::Outer => tr.append_u64s(label, &[16, 0]),
    }
}

fn stage1_channel_tag(channel: Stage1ShoutChannel) -> u64 {
    match channel {
        Stage1ShoutChannel::Fetch => 1,
        Stage1ShoutChannel::Decode => 2,
        Stage1ShoutChannel::Alu => 3,
        Stage1ShoutChannel::Eq4 => 4,
    }
}

fn address_family_tag(family: AddressFamily) -> u64 {
    match family {
        AddressFamily::Fetch => 1,
        AddressFamily::Decode => 2,
        AddressFamily::Alu => 3,
        AddressFamily::Eq4 => 4,
        AddressFamily::RegRaX => 5,
        AddressFamily::RegRaY => 6,
        AddressFamily::RegRaI => 7,
        AddressFamily::RegWa => 8,
        AddressFamily::RamRa => 9,
        AddressFamily::RamWa => 10,
    }
}

fn twist_read_family_tag(family: TwistReadFamily) -> u64 {
    match family {
        TwistReadFamily::RegX => 1,
        TwistReadFamily::RegY => 2,
        TwistReadFamily::RegI => 3,
        TwistReadFamily::Ram => 4,
    }
}

fn twist_memory_family_tag(family: TwistMemoryFamily) -> u64 {
    match family {
        TwistMemoryFamily::Reg => 1,
        TwistMemoryFamily::Ram => 2,
    }
}

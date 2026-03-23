//! Owns the sharded source/derived parity artifacts for the RV64IM parity corpus.

use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};

use crate::rv64im::builder::build_program;
use crate::rv64im::ccs::{
    RV64IM_PARITY_CASE_NAME_LABEL, RV64IM_PARITY_EXECUTION_DIGEST_LABEL, RV64IM_PARITY_FINAL_STATE_DIGEST_LABEL,
    RV64IM_PARITY_INITIAL_MEMORY_LABEL, RV64IM_PARITY_INITIAL_REGS_LABEL, RV64IM_PARITY_KERNEL_FINAL_MIX_LABEL,
    RV64IM_PARITY_PROGRAM_WORDS_LABEL, RV64IM_PARITY_ROOT0_DIGEST_LABEL, RV64IM_PARITY_STAGE1_DIGEST_LABEL,
    RV64IM_PARITY_STAGE1_MIX_LABEL, RV64IM_PARITY_STAGE2_DIGEST_LABEL, RV64IM_PARITY_STAGE2_RAM_MIX_LABEL,
    RV64IM_PARITY_STAGE2_REG_MIX_LABEL, RV64IM_PARITY_STAGE3_CONTINUITY_MIX_LABEL, RV64IM_PARITY_STAGE3_DIGEST_LABEL,
    RV64IM_PARITY_TRANSCRIPT_APP_LABEL, RV64IM_PARITY_TRANSCRIPT_SEED_LABEL,
};
use crate::rv64im::isa::{
    encode_add, encode_addi, encode_ecall, encode_ld, encode_sd, MemoryWord, Rv64BuildError, Rv64Program, Rv64State,
};
use crate::rv64im::layout::{
    RV64IM_PARITY_LOWERING_VERSION_ID, RV64IM_PARITY_PROTOCOL_VERSION_ID, RV64_REGISTER_COUNT,
};
use crate::rv64im::lower::Rv64ExpandedRow;
use crate::rv64im::stage1::{build_stage1_summary, Stage1Summary};
use crate::rv64im::stage2::{build_stage2_summary, Stage2Summary};
use crate::rv64im::stage3::{build_stage3_summary, Stage3Summary};
use crate::rv64im::tables::{
    Rv64FamilyTag, RV64IM_ALIGNED_MEMORY_FOCUS_FIXTURE_ID, RV64IM_CONTROL_FLOW_FOCUS_FIXTURE_ID,
    RV64IM_NATIVE_ALU_FOCUS_FIXTURE_ID, RV64IM_VERTICAL_SLICE_FIXTURE_ID,
};

use super::transcript::{LoggingTranscript, TranscriptRecord};

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imParityCaseManifest {
    pub name: String,
    pub fixture_id: String,
    pub protocol_version_id: u64,
    pub lowering_version_id: u64,
    pub family_tags: Vec<Rv64FamilyTag>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imParitySourceCase {
    pub manifest: Rv64imParityCaseManifest,
    pub start_pc: u64,
    pub program_words: Vec<u32>,
    pub initial_registers: [u64; RV64_REGISTER_COUNT],
    pub initial_memory: Vec<MemoryWord>,
    pub transcript_seed: Vec<u8>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imKernelSummary {
    pub root0_digest: [u8; 32],
    pub stage1_digest: [u8; 32],
    pub stage2_digest: [u8; 32],
    pub stage3_digest: [u8; 32],
    pub execution_digest: [u8; 32],
    pub final_state_digest: [u8; 32],
    pub stage1_mix: u64,
    pub stage2_reg_mix: u64,
    pub stage2_ram_mix: u64,
    pub stage3_continuity_mix: u64,
    pub kernel_final_mix: u64,
    pub transcript_final_digest: [u8; 32],
    pub final_pc: u64,
    pub final_registers: [u64; RV64_REGISTER_COUNT],
    pub final_memory: Vec<MemoryWord>,
    pub halted: bool,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Rv64imParityDerivedCase {
    pub manifest: Rv64imParityCaseManifest,
    pub execution_rows: Vec<Rv64ExpandedRow>,
    pub stage1: Stage1Summary,
    pub stage2: Stage2Summary,
    pub stage3: Stage3Summary,
    pub transcript: TranscriptRecord,
    pub kernel: Rv64imKernelSummary,
}

fn make_manifest(name: &str, fixture_id: &str, family_tags: Vec<Rv64FamilyTag>) -> Rv64imParityCaseManifest {
    Rv64imParityCaseManifest {
        name: name.into(),
        fixture_id: fixture_id.into(),
        protocol_version_id: RV64IM_PARITY_PROTOCOL_VERSION_ID,
        lowering_version_id: RV64IM_PARITY_LOWERING_VERSION_ID,
        family_tags,
    }
}

pub fn vertical_slice_manifest() -> Rv64imParityCaseManifest {
    make_manifest(
        "vertical_add_sd_ld_ecall",
        RV64IM_VERTICAL_SLICE_FIXTURE_ID,
        vec![
            Rv64FamilyTag::NativeAlu,
            Rv64FamilyTag::AlignedMemory,
            Rv64FamilyTag::ControlFlow,
        ],
    )
}

pub fn native_alu_focus_manifest() -> Rv64imParityCaseManifest {
    make_manifest(
        "native_add_chain_x0_ecall",
        RV64IM_NATIVE_ALU_FOCUS_FIXTURE_ID,
        vec![Rv64FamilyTag::NativeAlu, Rv64FamilyTag::ControlFlow],
    )
}

pub fn aligned_memory_focus_manifest() -> Rv64imParityCaseManifest {
    make_manifest(
        "aligned_negative_offset_roundtrip",
        RV64IM_ALIGNED_MEMORY_FOCUS_FIXTURE_ID,
        vec![
            Rv64FamilyTag::NativeAlu,
            Rv64FamilyTag::AlignedMemory,
            Rv64FamilyTag::ControlFlow,
        ],
    )
}

pub fn control_flow_focus_manifest() -> Rv64imParityCaseManifest {
    make_manifest(
        "control_flow_ecall_only",
        RV64IM_CONTROL_FLOW_FOCUS_FIXTURE_ID,
        vec![Rv64FamilyTag::ControlFlow],
    )
}

fn vertical_slice_source_case() -> Rv64imParitySourceCase {
    let mut registers = [0u64; RV64_REGISTER_COUNT];
    registers[10] = 0x1000;
    let program_words = vec![
        encode_addi(1, 0, 5),
        encode_add(2, 1, 1),
        encode_sd(2, 10, 0),
        encode_ld(3, 10, 0),
        encode_ecall(),
    ];

    Rv64imParitySourceCase {
        manifest: vertical_slice_manifest(),
        start_pc: 0,
        program_words,
        initial_registers: registers,
        initial_memory: vec![MemoryWord { addr: 0x1000, value: 0 }],
        transcript_seed: b"rv64im-vertical-slice-v1".to_vec(),
    }
}

fn native_alu_focus_source_case() -> Rv64imParitySourceCase {
    let program_words = vec![
        encode_addi(1, 0, 7),
        encode_addi(2, 1, 9),
        encode_add(3, 2, 1),
        encode_addi(0, 3, 5),
        encode_ecall(),
    ];

    Rv64imParitySourceCase {
        manifest: native_alu_focus_manifest(),
        start_pc: 0,
        program_words,
        initial_registers: [0u64; RV64_REGISTER_COUNT],
        initial_memory: vec![],
        transcript_seed: b"rv64im-native-alu-focus-v1".to_vec(),
    }
}

fn aligned_memory_focus_source_case() -> Rv64imParitySourceCase {
    let mut registers = [0u64; RV64_REGISTER_COUNT];
    registers[10] = 0x2008;
    let program_words = vec![
        encode_addi(1, 0, 42),
        encode_sd(1, 10, -8),
        encode_ld(2, 10, -8),
        encode_ecall(),
    ];

    Rv64imParitySourceCase {
        manifest: aligned_memory_focus_manifest(),
        start_pc: 0,
        program_words,
        initial_registers: registers,
        initial_memory: vec![
            MemoryWord {
                addr: 0x2000,
                value: 13,
            },
            MemoryWord {
                addr: 0x2008,
                value: 99,
            },
        ],
        transcript_seed: b"rv64im-aligned-memory-focus-v1".to_vec(),
    }
}

fn control_flow_focus_source_case() -> Rv64imParitySourceCase {
    Rv64imParitySourceCase {
        manifest: control_flow_focus_manifest(),
        start_pc: 0,
        program_words: vec![encode_ecall()],
        initial_registers: [0u64; RV64_REGISTER_COUNT],
        initial_memory: vec![],
        transcript_seed: b"rv64im-control-flow-focus-v1".to_vec(),
    }
}

pub fn parity_source_cases() -> Vec<Rv64imParitySourceCase> {
    vec![
        vertical_slice_source_case(),
        native_alu_focus_source_case(),
        aligned_memory_focus_source_case(),
        control_flow_focus_source_case(),
    ]
}

fn append_u64_matrix_digest(app_label: &'static [u8], sections: &[(&'static [u8], Vec<u64>)]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(app_label);
    for (label, words) in sections {
        tr.append_u64s(label, words);
    }
    tr.digest32()
}

fn flatten_memory_words(words: &[MemoryWord]) -> Vec<u64> {
    let mut out = Vec::with_capacity(words.len() * 2);
    for word in words {
        out.push(word.addr);
        out.push(word.value);
    }
    out
}

fn flatten_row(row: &Rv64ExpandedRow) -> Vec<u64> {
    let mut out = vec![
        row.step_index as u64,
        row.pc,
        row.next_pc,
        row.word as u64,
        row.opcode as u64,
        row.family as u64,
        row.rs1 as u64,
        row.rs1_value,
        row.rs2 as u64,
        row.rs2_value,
        row.rd as u64,
        row.rd_before,
        row.rd_after,
        row.imm as u64,
        row.alu_result,
        row.writes_rd as u64,
        row.writes_ram as u64,
        row.halted as u64,
    ];
    out.push(row.effective_addr.unwrap_or(0));
    out.push(row.memory_before.unwrap_or(0));
    out.push(row.memory_after.unwrap_or(0));
    out
}

fn flatten_stage1(stage1: &Stage1Summary) -> Vec<u64> {
    let mut out = Vec::new();
    for row in &stage1.rows {
        out.extend([
            row.step_index as u64,
            row.fetch_pc,
            row.fetched_word as u64,
            row.opcode as u64,
            row.family as u64,
            row.next_pc,
            row.alu_result,
            row.effective_addr.unwrap_or(0),
            row.writes_rd as u64,
            row.rd as u64,
            row.rd_after,
            row.preserves_x0 as u64,
        ]);
    }
    out
}

fn flatten_stage2(stage2: &Stage2Summary) -> Vec<u64> {
    let mut out = Vec::new();
    out.push(stage2.register_reads.len() as u64);
    for event in &stage2.register_reads {
        out.extend([
            event.step_index as u64,
            event.role as u64,
            event.reg as u64,
            event.value,
        ]);
    }
    out.push(stage2.register_writes.len() as u64);
    for event in &stage2.register_writes {
        out.extend([event.step_index as u64, event.reg as u64, event.previous, event.next]);
    }
    out.push(stage2.ram_events.len() as u64);
    for event in &stage2.ram_events {
        out.extend([
            event.step_index as u64,
            event.kind as u64,
            event.addr,
            event.previous,
            event.next,
        ]);
    }
    out.push(stage2.twist_links.len() as u64);
    for event in &stage2.twist_links {
        out.extend([
            event.step_index as u64,
            event.family as u64,
            event.routed_write_value.unwrap_or(0),
            event.routed_memory_before.unwrap_or(0),
            event.routed_memory_after.unwrap_or(0),
        ]);
    }
    out
}

fn flatten_stage3(stage3: &Stage3Summary) -> Vec<u64> {
    let mut out = vec![stage3.halted as u64, stage3.continuity.len() as u64];
    for event in &stage3.continuity {
        out.extend([
            event.step_index as u64,
            event.pc,
            event.next_pc,
            event.successor_pc.unwrap_or(0),
            event.final_step as u64,
            event.continuity_holds as u64,
        ]);
    }
    out
}

fn flatten_registers(values: &[u64; RV64_REGISTER_COUNT]) -> Vec<u64> {
    values.to_vec()
}

fn digest_source_case(source: &Rv64imParitySourceCase) -> [u8; 32] {
    append_u64_matrix_digest(
        b"neo.fold.next/rv64im/source_digest_v1",
        &[
            (
                b"source/protocol",
                vec![source.manifest.protocol_version_id, source.manifest.lowering_version_id],
            ),
            (
                b"source/program",
                source
                    .program_words
                    .iter()
                    .map(|word| *word as u64)
                    .collect(),
            ),
            (b"source/regs", flatten_registers(&source.initial_registers)),
            (b"source/memory", flatten_memory_words(&source.initial_memory)),
            (
                b"source/seed",
                source
                    .transcript_seed
                    .iter()
                    .map(|byte| *byte as u64)
                    .collect(),
            ),
        ],
    )
}

fn digest_rows(rows: &[Rv64ExpandedRow]) -> [u8; 32] {
    let mut sections = Vec::with_capacity(rows.len());
    for row in rows {
        sections.push((b"execution/row".as_slice(), flatten_row(row)));
    }
    append_u64_matrix_digest(b"neo.fold.next/rv64im/execution_digest_v1", &sections)
}

fn digest_final_state(final_state: &Rv64State) -> [u8; 32] {
    append_u64_matrix_digest(
        b"neo.fold.next/rv64im/final_state_digest_v1",
        &[
            (b"final/pc", vec![final_state.pc]),
            (b"final/halted", vec![final_state.halted as u64]),
            (b"final/registers", flatten_registers(&final_state.regs)),
            (b"final/memory", flatten_memory_words(&final_state.memory_words())),
        ],
    )
}

fn build_parity_case(
    source: Rv64imParitySourceCase,
) -> Result<(Rv64imParitySourceCase, Rv64imParityDerivedCase), Rv64BuildError> {
    let program = Rv64Program::new(source.start_pc, source.program_words.clone());
    let initial_state = Rv64State::new(source.start_pc, source.initial_registers, &source.initial_memory);
    let build = build_program(&program, &initial_state, source.program_words.len())?;

    let stage1 = build_stage1_summary(&build.rows);
    let stage2 = build_stage2_summary(&build.rows);
    let stage3 = build_stage3_summary(&build.rows);

    let root0_digest = digest_source_case(&source);
    let stage1_digest = append_u64_matrix_digest(
        b"neo.fold.next/rv64im/stage1_digest_v1",
        &[(b"stage1/rows", flatten_stage1(&stage1))],
    );
    let stage2_digest = append_u64_matrix_digest(
        b"neo.fold.next/rv64im/stage2_digest_v1",
        &[(b"stage2/summary", flatten_stage2(&stage2))],
    );
    let stage3_digest = append_u64_matrix_digest(
        b"neo.fold.next/rv64im/stage3_digest_v1",
        &[(b"stage3/summary", flatten_stage3(&stage3))],
    );
    let execution_digest = digest_rows(&build.rows);
    let final_state_digest = digest_final_state(&build.final_state);

    let mut transcript = LoggingTranscript::new(RV64IM_PARITY_TRANSCRIPT_APP_LABEL);
    transcript.append_message(RV64IM_PARITY_TRANSCRIPT_SEED_LABEL, &source.transcript_seed);
    transcript.append_message(RV64IM_PARITY_CASE_NAME_LABEL, source.manifest.name.as_bytes());
    transcript.append_u64s(
        RV64IM_PARITY_PROGRAM_WORDS_LABEL,
        &source
            .program_words
            .iter()
            .map(|word| *word as u64)
            .collect::<Vec<_>>(),
    );
    transcript.append_u64s(RV64IM_PARITY_INITIAL_REGS_LABEL, &source.initial_registers);
    transcript.append_u64s(
        RV64IM_PARITY_INITIAL_MEMORY_LABEL,
        &flatten_memory_words(&source.initial_memory),
    );
    transcript.append_message(RV64IM_PARITY_ROOT0_DIGEST_LABEL, &root0_digest);
    let stage1_mix = transcript.challenge_field(RV64IM_PARITY_STAGE1_MIX_LABEL);
    transcript.append_message(RV64IM_PARITY_STAGE1_DIGEST_LABEL, &stage1_digest);
    let stage2_reg_mix = transcript.challenge_field(RV64IM_PARITY_STAGE2_REG_MIX_LABEL);
    let stage2_ram_mix = transcript.challenge_field(RV64IM_PARITY_STAGE2_RAM_MIX_LABEL);
    transcript.append_message(RV64IM_PARITY_STAGE2_DIGEST_LABEL, &stage2_digest);
    let stage3_continuity_mix = transcript.challenge_field(RV64IM_PARITY_STAGE3_CONTINUITY_MIX_LABEL);
    transcript.append_message(RV64IM_PARITY_STAGE3_DIGEST_LABEL, &stage3_digest);
    transcript.append_message(RV64IM_PARITY_EXECUTION_DIGEST_LABEL, &execution_digest);
    transcript.append_message(RV64IM_PARITY_FINAL_STATE_DIGEST_LABEL, &final_state_digest);
    let kernel_final_mix = transcript.challenge_field(RV64IM_PARITY_KERNEL_FINAL_MIX_LABEL);
    let transcript_final_digest = transcript.digest32();
    let transcript = transcript.finish();

    let kernel = Rv64imKernelSummary {
        root0_digest,
        stage1_digest,
        stage2_digest,
        stage3_digest,
        execution_digest,
        final_state_digest,
        stage1_mix,
        stage2_reg_mix,
        stage2_ram_mix,
        stage3_continuity_mix,
        kernel_final_mix,
        transcript_final_digest,
        final_pc: build.final_state.pc,
        final_registers: build.final_state.regs,
        final_memory: build.final_state.memory_words(),
        halted: build.final_state.halted,
    };

    Ok((
        source.clone(),
        Rv64imParityDerivedCase {
            manifest: source.manifest.clone(),
            execution_rows: build.rows,
            stage1,
            stage2,
            stage3,
            transcript,
            kernel,
        },
    ))
}

pub fn build_vertical_slice_parity_case() -> Result<(Rv64imParitySourceCase, Rv64imParityDerivedCase), Rv64BuildError> {
    build_parity_case(vertical_slice_source_case())
}

pub fn build_native_alu_focus_parity_case() -> Result<(Rv64imParitySourceCase, Rv64imParityDerivedCase), Rv64BuildError>
{
    build_parity_case(native_alu_focus_source_case())
}

pub fn build_aligned_memory_focus_parity_case(
) -> Result<(Rv64imParitySourceCase, Rv64imParityDerivedCase), Rv64BuildError> {
    build_parity_case(aligned_memory_focus_source_case())
}

pub fn build_control_flow_focus_parity_case(
) -> Result<(Rv64imParitySourceCase, Rv64imParityDerivedCase), Rv64BuildError> {
    build_parity_case(control_flow_focus_source_case())
}

pub fn build_all_parity_cases() -> Result<Vec<(Rv64imParitySourceCase, Rv64imParityDerivedCase)>, Rv64BuildError> {
    parity_source_cases()
        .into_iter()
        .map(build_parity_case)
        .collect()
}

//! Owns canonical public metadata, input validation, and `root0` transcript binding.

use neo_math::F;
use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::chip8::spec::{CHIP8_MEMORY_BYTES, CHIP8_PROGRAM_START};
use crate::chip8::tables::ROM_ADDR_BITS;

use super::root_context::chip8_simple_root_context_id;
use super::{KernelCommitments, SimpleKernelError, SimpleKernelPublicInput};

const SIMPLE_KERNEL_TRANSCRIPT_DOMAIN: &[u8] = b"neo.fold.next/chip8/simple_kernel";

#[derive(Clone, Debug, PartialEq)]
pub struct KernelMetaPub {
    pub program_image_digest: [u8; 32],
    pub initial_state_digest: [u8; 32],
    pub rom_table_digest: [u8; 32],
    pub decode_table_digest: [u8; 32],
    pub alu_table_digest: [u8; 32],
    pub eq4_table_digest: [u8; 32],
    pub transcript_seed_digest: [u8; 32],
    pub protocol_version_id: u64,
    pub field_id: u64,
    pub extension_field_id: u64,
    pub root_params_id: [u8; 32],
    pub variable_order_id: u64,
    pub domain_shape_id: u64,
    pub sink_convention_id: u64,
    pub init_mode_id: u64,
    pub lowering_convention_id: u64,
    pub padding_convention_id: u64,
    pub table_auth_mode_id: u64,
    pub opening_reduction_mode_id: u64,
    pub program_word_count: usize,
    pub semantic_rows: usize,
    pub padded_trace_length: usize,
    pub pad_pc_word: u16,
    pub program_base_addr: u16,
    pub cycle_bits: usize,
}

impl KernelMetaPub {
    pub(crate) fn expect_matches(&self, expected: &Self) -> Result<(), SimpleKernelError> {
        expect_digest32(
            self.program_image_digest,
            expected.program_image_digest,
            "kernel meta program image digest",
        )?;
        expect_digest32(
            self.initial_state_digest,
            expected.initial_state_digest,
            "kernel meta initial state digest",
        )?;
        expect_digest32(
            self.rom_table_digest,
            expected.rom_table_digest,
            "kernel meta rom table digest",
        )?;
        expect_digest32(
            self.decode_table_digest,
            expected.decode_table_digest,
            "kernel meta decode table digest",
        )?;
        expect_digest32(
            self.alu_table_digest,
            expected.alu_table_digest,
            "kernel meta alu table digest",
        )?;
        expect_digest32(
            self.eq4_table_digest,
            expected.eq4_table_digest,
            "kernel meta eq4 table digest",
        )?;
        expect_digest32(
            self.transcript_seed_digest,
            expected.transcript_seed_digest,
            "kernel meta transcript seed digest",
        )?;
        expect_digest32(
            self.root_params_id,
            expected.root_params_id,
            "kernel meta root params id",
        )?;
        if self.protocol_version_id != expected.protocol_version_id {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta protocol_version_id {} != expected {}",
                self.protocol_version_id, expected.protocol_version_id
            )));
        }
        if self.field_id != expected.field_id {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta field_id {} != expected {}",
                self.field_id, expected.field_id
            )));
        }
        if self.extension_field_id != expected.extension_field_id {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta extension_field_id {} != expected {}",
                self.extension_field_id, expected.extension_field_id
            )));
        }
        if self.variable_order_id != expected.variable_order_id {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta variable_order_id {} != expected {}",
                self.variable_order_id, expected.variable_order_id
            )));
        }
        if self.domain_shape_id != expected.domain_shape_id {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta domain_shape_id {} != expected {}",
                self.domain_shape_id, expected.domain_shape_id
            )));
        }
        if self.sink_convention_id != expected.sink_convention_id {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta sink_convention_id {} != expected {}",
                self.sink_convention_id, expected.sink_convention_id
            )));
        }
        if self.init_mode_id != expected.init_mode_id {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta init_mode_id {} != expected {}",
                self.init_mode_id, expected.init_mode_id
            )));
        }
        if self.lowering_convention_id != expected.lowering_convention_id {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta lowering_convention_id {} != expected {}",
                self.lowering_convention_id, expected.lowering_convention_id
            )));
        }
        if self.padding_convention_id != expected.padding_convention_id {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta padding_convention_id {} != expected {}",
                self.padding_convention_id, expected.padding_convention_id
            )));
        }
        if self.table_auth_mode_id != expected.table_auth_mode_id {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta table_auth_mode_id {} != expected {}",
                self.table_auth_mode_id, expected.table_auth_mode_id
            )));
        }
        if self.opening_reduction_mode_id != expected.opening_reduction_mode_id {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta opening_reduction_mode_id {} != expected {}",
                self.opening_reduction_mode_id, expected.opening_reduction_mode_id
            )));
        }
        if self.program_word_count != expected.program_word_count {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta program_word_count {} != expected {}",
                self.program_word_count, expected.program_word_count
            )));
        }
        if self.semantic_rows != expected.semantic_rows {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta semantic_rows {} != expected {}",
                self.semantic_rows, expected.semantic_rows
            )));
        }
        if self.padded_trace_length != expected.padded_trace_length {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta padded_trace_length {} != expected {}",
                self.padded_trace_length, expected.padded_trace_length
            )));
        }
        if self.pad_pc_word != expected.pad_pc_word {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta pad_pc_word {} != expected {}",
                self.pad_pc_word, expected.pad_pc_word
            )));
        }
        if self.program_base_addr != expected.program_base_addr {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta program_base_addr {} != expected {}",
                self.program_base_addr, expected.program_base_addr
            )));
        }
        if self.cycle_bits != expected.cycle_bits {
            return Err(SimpleKernelError::InvalidProgram(format!(
                "kernel meta cycle_bits {} != expected {}",
                self.cycle_bits, expected.cycle_bits
            )));
        }
        Ok(())
    }
}

pub fn new_simple_kernel_transcript(transcript_seed: &[u8]) -> Poseidon2Transcript {
    let mut transcript = Poseidon2Transcript::new(SIMPLE_KERNEL_TRANSCRIPT_DOMAIN);
    transcript.append_message(b"chip8/kernel/transcript_seed", transcript_seed);
    transcript
}

const CHIP8_KERNEL_PROTOCOL_VERSION_ID: u64 = 1;
const CHIP8_FIELD_ID_GOLDILOCKS: u64 = 1;
const CHIP8_EXTENSION_FIELD_ID_GOLDILOCKS_QUADRATIC: u64 = 1;
const CHIP8_VARIABLE_ORDER_ID: u64 = 1;
const CHIP8_DOMAIN_SHAPE_ID: u64 = 1;
const CHIP8_SINK_CONVENTION_ID: u64 = 1;
const CHIP8_INIT_MODE_ID_AUTHENTICATED_NONZERO_INIT: u64 = 1;
const CHIP8_LOWERING_CONVENTION_ID_ROW_LOCAL_PRE_POST: u64 = 1;
const CHIP8_PADDING_CONVENTION_ID_POW2_SELF_LOOP: u64 = 1;
const CHIP8_TABLE_AUTH_MODE_ID_PUBLIC_RECOMPUTE: u64 = 1;
const CHIP8_OPENING_REDUCTION_MODE_ID_SIMPLE_BOUNDARY_NONE: u64 = 1;

pub fn build_kernel_meta_pub(
    public: &SimpleKernelPublicInput,
    rom_table: &[F],
    decode_table: &[Vec<F>],
    alu_table: &[F],
    eq4_table: &[F],
    word_count: usize,
    semantic_rows: usize,
    padded_trace_length: usize,
    pad_pc_word: u16,
    cycle_bits: usize,
) -> KernelMetaPub {
    KernelMetaPub {
        program_image_digest: digest_bytes(b"neo.fold.next/chip8/program_image", &public.program_image),
        initial_state_digest: initial_state_digest(
            public.initial_pc_word,
            &public.initial_registers,
            public.initial_i,
            &public.initial_ram,
        ),
        rom_table_digest: digest_field_slice(b"neo.fold.next/chip8/rom_table", rom_table),
        decode_table_digest: digest_field_columns(b"neo.fold.next/chip8/decode_table", decode_table),
        alu_table_digest: digest_field_slice(b"neo.fold.next/chip8/alu_table", alu_table),
        eq4_table_digest: digest_field_slice(b"neo.fold.next/chip8/eq4_table", eq4_table),
        transcript_seed_digest: transcript_seed_digest(&public.transcript_seed),
        protocol_version_id: CHIP8_KERNEL_PROTOCOL_VERSION_ID,
        field_id: CHIP8_FIELD_ID_GOLDILOCKS,
        extension_field_id: CHIP8_EXTENSION_FIELD_ID_GOLDILOCKS_QUADRATIC,
        root_params_id: chip8_simple_root_context_id(),
        variable_order_id: CHIP8_VARIABLE_ORDER_ID,
        domain_shape_id: CHIP8_DOMAIN_SHAPE_ID,
        sink_convention_id: CHIP8_SINK_CONVENTION_ID,
        init_mode_id: CHIP8_INIT_MODE_ID_AUTHENTICATED_NONZERO_INIT,
        lowering_convention_id: CHIP8_LOWERING_CONVENTION_ID_ROW_LOCAL_PRE_POST,
        padding_convention_id: CHIP8_PADDING_CONVENTION_ID_POW2_SELF_LOOP,
        table_auth_mode_id: CHIP8_TABLE_AUTH_MODE_ID_PUBLIC_RECOMPUTE,
        opening_reduction_mode_id: CHIP8_OPENING_REDUCTION_MODE_ID_SIMPLE_BOUNDARY_NONE,
        program_word_count: word_count,
        semantic_rows,
        padded_trace_length,
        pad_pc_word,
        program_base_addr: CHIP8_PROGRAM_START,
        cycle_bits,
    }
}

pub(crate) fn validate_public_input(public: &SimpleKernelPublicInput) -> Result<usize, SimpleKernelError> {
    if public.program_image.len() % 2 != 0 {
        return Err(SimpleKernelError::InvalidProgram(format!(
            "program image length {} must be even",
            public.program_image.len()
        )));
    }
    if public.initial_ram.len() != CHIP8_MEMORY_BYTES {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "initial RAM length {} != expected {}",
            public.initial_ram.len(),
            CHIP8_MEMORY_BYTES
        )));
    }

    let word_count = public.program_image.len() / 2;
    let base_word = (CHIP8_PROGRAM_START / 2) as usize;
    let max_program_words = (1usize << ROM_ADDR_BITS) - base_word - 1;
    if word_count > max_program_words {
        return Err(SimpleKernelError::InvalidProgram(format!(
            "program image word count {} exceeds max {}",
            word_count, max_program_words
        )));
    }

    Ok(word_count)
}

pub fn absorb_root0(transcript: &mut Poseidon2Transcript, commitments: &KernelCommitments, meta_pub: &KernelMetaPub) {
    transcript.append_u64s(b"chip8/root0/version", &[meta_pub.protocol_version_id]);
    transcript.append_u64s(b"chip8/root0/field_id", &[meta_pub.field_id]);
    transcript.append_u64s(b"chip8/root0/extension_field_id", &[meta_pub.extension_field_id]);
    transcript.append_message(b"chip8/root0/c_lane", &commitments.c_lane);
    transcript.append_message(b"chip8/root0/c_fetch_ra", &commitments.c_fetch_ra);
    transcript.append_message(b"chip8/root0/c_decode_ra", &commitments.c_decode_ra);
    transcript.append_message(b"chip8/root0/c_alu_ra", &commitments.c_alu_ra);
    transcript.append_message(b"chip8/root0/c_eq4_ra", &commitments.c_eq4_ra);
    transcript.append_message(b"chip8/root0/c_decode_handoff", &commitments.c_decode_handoff);
    transcript.append_message(b"chip8/root0/c_reg", &commitments.c_reg);
    transcript.append_message(b"chip8/root0/c_ram", &commitments.c_ram);
    transcript.append_message(b"chip8/root0/c_rom_table", &commitments.c_rom_table);
    transcript.append_message(b"chip8/root0/c_decode_table", &commitments.c_decode_table);
    transcript.append_message(b"chip8/root0/c_alu_table", &commitments.c_alu_table);
    transcript.append_message(b"chip8/root0/c_eq4_table", &commitments.c_eq4_table);
    transcript.append_message(b"chip8/root0/program_image_digest", &meta_pub.program_image_digest);
    transcript.append_message(b"chip8/root0/initial_state_digest", &meta_pub.initial_state_digest);
    transcript.append_message(b"chip8/root0/rom_table_digest", &meta_pub.rom_table_digest);
    transcript.append_message(b"chip8/root0/decode_table_digest", &meta_pub.decode_table_digest);
    transcript.append_message(b"chip8/root0/alu_table_digest", &meta_pub.alu_table_digest);
    transcript.append_message(b"chip8/root0/eq4_table_digest", &meta_pub.eq4_table_digest);
    transcript.append_message(b"chip8/root0/transcript_seed_digest", &meta_pub.transcript_seed_digest);
    transcript.append_message(b"chip8/root0/root_params_id", &meta_pub.root_params_id);
    transcript.append_u64s(
        b"chip8/root0/meta_pub",
        &[
            meta_pub.variable_order_id,
            meta_pub.domain_shape_id,
            meta_pub.sink_convention_id,
            meta_pub.init_mode_id,
            meta_pub.lowering_convention_id,
            meta_pub.padding_convention_id,
            meta_pub.table_auth_mode_id,
            meta_pub.opening_reduction_mode_id,
            meta_pub.program_word_count as u64,
            meta_pub.semantic_rows as u64,
            meta_pub.padded_trace_length as u64,
            meta_pub.pad_pc_word as u64,
            meta_pub.program_base_addr as u64,
            meta_pub.cycle_bits as u64,
        ],
    );
}

fn digest_bytes(domain: &'static [u8], bytes: &[u8]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(domain);
    tr.append_message(b"chip8/kernel/bytes", bytes);
    tr.digest32()
}

fn initial_state_digest(
    initial_pc_word: u16,
    initial_registers: &[u8; 16],
    initial_i: u16,
    initial_ram: &[u8],
) -> [u8; 32] {
    let mut bytes = Vec::with_capacity(2 + 16 + 2 + initial_ram.len());
    bytes.extend_from_slice(&initial_pc_word.to_le_bytes());
    bytes.extend(*initial_registers);
    bytes.extend_from_slice(&initial_i.to_le_bytes());
    bytes.extend_from_slice(initial_ram);
    digest_bytes(b"neo.fold.next/chip8/initial_state", &bytes)
}

fn transcript_seed_digest(transcript_seed: &[u8]) -> [u8; 32] {
    digest_bytes(b"neo.fold.next/chip8/transcript_seed", transcript_seed)
}

fn digest_field_slice(domain: &'static [u8], values: &[F]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(domain);
    tr.append_u64s(b"chip8/kernel/field_slice_len", &[values.len() as u64]);
    tr.append_fields_iter(b"chip8/kernel/field_slice_values", values.len(), values.iter().copied());
    tr.digest32()
}

fn digest_field_columns(domain: &'static [u8], columns: &[Vec<F>]) -> [u8; 32] {
    let width = columns.len();
    let height = columns.first().map(Vec::len).unwrap_or(0);
    let mut tr = Poseidon2Transcript::new(domain);
    tr.append_u64s(b"chip8/kernel/field_columns_shape", &[width as u64, height as u64]);
    for (idx, column) in columns.iter().enumerate() {
        tr.append_u64s(b"chip8/kernel/field_columns_index", &[idx as u64, column.len() as u64]);
        tr.append_fields_iter(
            b"chip8/kernel/field_columns_values",
            column.len(),
            column.iter().copied(),
        );
    }
    tr.digest32()
}

fn expect_digest32(actual: [u8; 32], expected: [u8; 32], label: &str) -> Result<(), SimpleKernelError> {
    if actual != expected {
        return Err(SimpleKernelError::InvalidProgram(format!(
            "{label} mismatch: {:02x?} != {:02x?}",
            actual, expected
        )));
    }
    Ok(())
}

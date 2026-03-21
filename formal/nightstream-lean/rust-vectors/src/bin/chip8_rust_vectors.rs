use std::fmt::Write as _;
use std::fs;
use std::path::PathBuf;

use neo_fold_next::chip8::kernel::{
    absorb_root0, new_simple_kernel_transcript, prove_simple_kernel, KernelCommitments, KernelMetaPub,
    SimpleKernelProverInput, SimpleKernelPublicInput, SimpleKernelWitness,
};
use neo_fold_next::chip8::trace::Chip8TraceBuilder;
use neo_fold_next::chip8::{Chip8Program, Chip8State};
use neo_math::{KExtensions, K};
use neo_transcript::Transcript;
use p3_field::PrimeField64;

#[derive(Clone)]
struct TranscriptVectorCase {
    name: &'static str,
    transcript_seed: Vec<u8>,
    commitment_bindings: Vec<(&'static str, Vec<u8>)>,
    meta_pub: KernelMetaPub,
    root0_transcript_state_words: [u64; 8],
    root0_digest_state_words: [u64; 8],
    root0_digest_words: [u64; 4],
    root0_digest_bytes: [u8; 32],
    stage1_lookup_point: Vec<(u64, u64)>,
}

fn build_jump_kernel_input(semantic_rows: usize, transcript_seed: Vec<u8>) -> SimpleKernelProverInput {
    let program = Chip8Program::from_opcodes(&[0x1200]);
    let initial_state = Chip8State::default();
    let execution =
        Chip8TraceBuilder::<()>::execute_program(&program, &initial_state, semantic_rows).expect("jump trace");

    let mut semantic_trace_rows = Vec::new();
    let mut semantic_aux_data = Vec::new();
    for step in execution {
        for row_trace in step.row_traces {
            semantic_trace_rows.push(row_trace.row);
            semantic_aux_data.push(row_trace.kernel_aux);
        }
    }

    SimpleKernelProverInput {
        public: SimpleKernelPublicInput {
            program_image: program.bytes,
            initial_pc_word: initial_state.pc / 2,
            initial_registers: initial_state.v,
            initial_i: initial_state.i,
            initial_ram: initial_state.memory.to_vec(),
            transcript_seed,
        },
        witness: SimpleKernelWitness {
            semantic_trace_rows,
            semantic_aux_data,
        },
    }
}

fn commitment_bindings(commitments: &KernelCommitments) -> Vec<(&'static str, Vec<u8>)> {
    vec![
        ("lane", commitments.c_lane.to_vec()),
        ("fetchRa", commitments.c_fetch_ra.to_vec()),
        ("decodeRa", commitments.c_decode_ra.to_vec()),
        ("aluRa", commitments.c_alu_ra.to_vec()),
        ("eq4Ra", commitments.c_eq4_ra.to_vec()),
        ("decodeHandoff", commitments.c_decode_handoff.to_vec()),
        ("regTwist", commitments.c_reg.to_vec()),
        ("ramTwist", commitments.c_ram.to_vec()),
        ("romTable", commitments.c_rom_table.to_vec()),
        ("decodeTable", commitments.c_decode_table.to_vec()),
        ("aluTable", commitments.c_alu_table.to_vec()),
        ("eq4Table", commitments.c_eq4_table.to_vec()),
    ]
}

fn state_words(st: [neo_math::F; 8]) -> [u64; 8] {
    st.map(|x| x.as_canonical_u64())
}

fn digest_words(bytes: [u8; 32]) -> [u64; 4] {
    let mut out = [0u64; 4];
    for (idx, chunk) in bytes.chunks_exact(8).enumerate() {
        let mut word = [0u8; 8];
        word.copy_from_slice(chunk);
        out[idx] = u64::from_le_bytes(word);
    }
    out
}

fn k_pair(value: K) -> (u64, u64) {
    let [re, im] = value.as_coeffs();
    (re.as_canonical_u64(), im.as_canonical_u64())
}

fn build_case(name: &'static str, semantic_rows: usize, transcript_seed: Vec<u8>) -> TranscriptVectorCase {
    let input = build_jump_kernel_input(semantic_rows, transcript_seed.clone());
    let (_output, proof) = prove_simple_kernel(&input).expect("simple kernel proof");

    let mut transcript = new_simple_kernel_transcript(&input.public.transcript_seed);
    absorb_root0(&mut transcript, &proof.commitments, &proof.meta_pub);
    let root0_transcript_state_words = state_words(transcript.state());
    let stage1_lookup_point = proof.stage1.cycle_point.iter().copied().map(k_pair).collect();
    let root0_digest_bytes = transcript.digest32();
    let root0_digest_words = digest_words(root0_digest_bytes);
    let root0_digest_state_words = state_words(transcript.state());

    TranscriptVectorCase {
        name,
        transcript_seed,
        commitment_bindings: commitment_bindings(&proof.commitments),
        meta_pub: proof.meta_pub,
        root0_transcript_state_words,
        root0_digest_state_words,
        root0_digest_words,
        root0_digest_bytes,
        stage1_lookup_point,
    }
}

fn render_u8_list(values: &[u8]) -> String {
    let mut out = String::from("(bytes [");
    for (idx, value) in values.iter().enumerate() {
        if idx > 0 {
            out.push_str(", ");
        }
        let _ = write!(out, "{value}");
    }
    out.push_str("])");
    out
}

fn render_u64_list(values: &[u64]) -> String {
    let mut out = String::from("[");
    for (idx, value) in values.iter().enumerate() {
        if idx > 0 {
            out.push_str(", ");
        }
        let _ = write!(out, "{value}");
    }
    out.push(']');
    out
}

fn render_meta_pub(meta: &KernelMetaPub) -> String {
    format!(
        "mkMetaPub\n    {program_image_digest}\n    {initial_state_digest}\n    {rom_table_digest}\n    {decode_table_digest}\n    {alu_table_digest}\n    {eq4_table_digest}\n    {transcript_seed_digest}\n    {protocol_version_id}\n    {field_id}\n    {extension_field_id}\n    {root_params_id}\n    {variable_order_id}\n    {domain_shape_id}\n    {sink_convention_id}\n    {init_mode_id}\n    {lowering_convention_id}\n    {padding_convention_id}\n    {table_auth_mode_id}\n    {opening_reduction_mode_id}\n    {program_word_count}\n    {semantic_rows}\n    {padded_trace_length}\n    {pad_pc_word}\n    {program_base_addr}\n    {cycle_bits}",
        program_image_digest = render_u8_list(&meta.program_image_digest),
        initial_state_digest = render_u8_list(&meta.initial_state_digest),
        rom_table_digest = render_u8_list(&meta.rom_table_digest),
        decode_table_digest = render_u8_list(&meta.decode_table_digest),
        alu_table_digest = render_u8_list(&meta.alu_table_digest),
        eq4_table_digest = render_u8_list(&meta.eq4_table_digest),
        transcript_seed_digest = render_u8_list(&meta.transcript_seed_digest),
        protocol_version_id = meta.protocol_version_id,
        field_id = meta.field_id,
        extension_field_id = meta.extension_field_id,
        root_params_id = render_u8_list(&meta.root_params_id),
        variable_order_id = meta.variable_order_id,
        domain_shape_id = meta.domain_shape_id,
        sink_convention_id = meta.sink_convention_id,
        init_mode_id = meta.init_mode_id,
        lowering_convention_id = meta.lowering_convention_id,
        padding_convention_id = meta.padding_convention_id,
        table_auth_mode_id = meta.table_auth_mode_id,
        opening_reduction_mode_id = meta.opening_reduction_mode_id,
        program_word_count = meta.program_word_count,
        semantic_rows = meta.semantic_rows,
        padded_trace_length = meta.padded_trace_length,
        pad_pc_word = meta.pad_pc_word,
        program_base_addr = meta.program_base_addr,
        cycle_bits = meta.cycle_bits,
    )
}

fn render_binding(id: &str, digest: &[u8]) -> String {
    format!("binding .{id} ({})", render_u8_list(digest))
}

fn render_point(values: &[(u64, u64)]) -> String {
    let mut out = String::from("[");
    for (idx, (re, im)) in values.iter().enumerate() {
        if idx > 0 {
            out.push_str(", ");
        }
        let _ = write!(out, "pair {re} {im}");
    }
    out.push(']');
    out
}

fn lean_ident_fragment(name: &str) -> String {
    name.chars()
        .map(|ch| if ch.is_ascii_alphanumeric() { ch } else { '_' })
        .collect()
}

fn meta_pub_def_name(case: &TranscriptVectorCase) -> String {
    format!("metaPub_{}", lean_ident_fragment(case.name))
}

fn render_meta_pub_def(case: &TranscriptVectorCase) -> String {
    format!(
        "def {name} : MetaPub :=\n  {value}\n",
        name = meta_pub_def_name(case),
        value = render_meta_pub(&case.meta_pub),
    )
}

fn render_case(case: &TranscriptVectorCase) -> String {
    let mut bindings = String::from("[");
    for (idx, (id, digest)) in case.commitment_bindings.iter().enumerate() {
        if idx > 0 {
            bindings.push_str(", ");
        }
        bindings.push_str(&render_binding(id, digest));
    }
    bindings.push(']');

    format!(
        "mkTranscriptVectorCase\n      \"{name}\"\n      {transcript_seed}\n      {commitment_bindings}\n      {meta_pub_name}\n      {root0_transcript_state_words}\n      {root0_digest_state_words}\n      {root0_digest_words}\n      {root0_digest_bytes}\n      {stage1_lookup_point}",
        name = case.name,
        transcript_seed = render_u8_list(&case.transcript_seed),
        commitment_bindings = bindings,
        meta_pub_name = meta_pub_def_name(case),
        root0_transcript_state_words = render_u64_list(&case.root0_transcript_state_words),
        root0_digest_state_words = render_u64_list(&case.root0_digest_state_words),
        root0_digest_words = render_u64_list(&case.root0_digest_words),
        root0_digest_bytes = render_u8_list(&case.root0_digest_bytes),
        stage1_lookup_point = render_point(&case.stage1_lookup_point),
    )
}

fn output_path() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../Nightstream/Chip8/Generated/TranscriptVectors.lean")
}

fn main() {
    let cases = vec![
        build_case("jump_rows_2_seed_empty", 2, vec![]),
        build_case("jump_rows_3_seed_nonempty", 3, b"chip8-transcript-seed-v1".to_vec()),
    ];

    let mut out = String::new();
    out.push_str("import Nightstream.Chip8.Generated.TranscriptVectorTypes\n\n");
    out.push_str("namespace Nightstream.Chip8.Generated\n\n");
    for case in &cases {
        out.push_str(&render_meta_pub_def(case));
        out.push('\n');
    }
    out.push_str("def transcriptVectorCases : List TranscriptVectorCase :=\n");
    out.push_str("  [\n");
    for (idx, case) in cases.iter().enumerate() {
        out.push_str("    ");
        out.push_str(&render_case(case));
        if idx + 1 < cases.len() {
            out.push(',');
        }
        out.push('\n');
    }
    out.push_str("  ]\n\n");
    out.push_str("end Nightstream.Chip8.Generated\n");

    let path = output_path();
    fs::create_dir_all(path.parent().expect("generated dir")).expect("create generated dir");
    fs::write(&path, out).expect("write transcript vectors");
    println!("{}", path.display());
}

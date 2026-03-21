use neo_fold_next::chip8::kernel::{
    chip8_simple_root_params, prove_simple_kernel as prove_simple_kernel_impl,
    verify_simple_kernel as verify_simple_kernel_impl, KernelOpeningClaim, KernelStepAux, SimpleKernelError,
    SimpleKernelOutput, SimpleKernelProof, SimpleKernelProverInput, SimpleKernelPublicInput, SimpleKernelVerifierInput,
    SimpleKernelWitness,
};
use neo_fold_next::chip8::spec::{
    build_pad_row, Chip8Program, Chip8State, CommitmentId, CHIP8_PROGRAM_START, COL_BURST_LAST, COL_IS_JUMP,
    COL_IS_MEMOP, COL_LOOKUP_OUTPUT, COL_NNN_ADDR, COL_NNN_WORD, COL_PC, COL_PC_NEXT, COL_PRESERVES_X, COL_REG_X,
    COL_X_IDX, WITNESS_WIDTH,
};
use neo_fold_next::chip8::stage1::{prove_stage1, verify_stage1};
use neo_fold_next::chip8::stage3::prove_stage3;
use neo_fold_next::chip8::tables::{build_alu_table, build_decode_table, build_eq4_table, build_rom_table};
use neo_fold_next::chip8::trace::Chip8TraceBuilder;
use neo_fold_next::chip8::{RAM_SINK_ADDR, REG_SINK_ADDR};
use neo_math::{F, K};
use neo_params::NeoParams;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

fn eq_at(point: &[K], index: usize) -> K {
    point.iter().enumerate().fold(K::ONE, |acc, (bit, &ri)| {
        if (index >> bit) & 1 == 1 {
            acc * ri
        } else {
            acc * (K::ONE - ri)
        }
    })
}

fn make_row(pc: u64, pc_next: u64, x_idx: u64, is_memop: bool, burst_last: bool) -> [F; WITNESS_WIDTH] {
    let mut row = [F::ZERO; WITNESS_WIDTH];
    row[COL_PC] = F::from_u64(pc);
    row[COL_PC_NEXT] = F::from_u64(pc_next);
    row[COL_X_IDX] = F::from_u64(x_idx);
    row[COL_IS_MEMOP] = if is_memop { F::ONE } else { F::ZERO };
    row[COL_BURST_LAST] = if burst_last { F::ONE } else { F::ZERO };
    row
}

fn make_jump_row(pc_next: u64) -> [F; WITNESS_WIDTH] {
    let mut row = make_row(0x100, pc_next, 0, false, false);
    row[COL_NNN_ADDR] = F::from_u64(0x200);
    row[COL_NNN_WORD] = F::from_u64(0x100);
    row[COL_PRESERVES_X] = F::ONE;
    row[COL_IS_JUMP] = F::ONE;
    row[COL_LOOKUP_OUTPUT] = F::ZERO;
    row
}

fn make_jump_aux() -> KernelStepAux {
    KernelStepAux {
        fetch_addr: 0x100,
        decode_addr: 0x1200,
        alu_key: 0,
        eq4_key: 0,
        reg_ra_x_addr: 0,
        reg_ra_y_addr: REG_SINK_ADDR,
        reg_ra_i_addr: 16,
        reg_wa_addr: REG_SINK_ADDR,
        ram_ra_addr: RAM_SINK_ADDR,
        ram_wa_addr: RAM_SINK_ADDR,
        reg_inc: F::ZERO,
        ram_inc: F::ZERO,
        uses_y: false,
        reads_ram: false,
        writes_ram: false,
    }
}

pub(super) fn build_jump_kernel_input(semantic_rows: usize) -> SimpleKernelProverInput {
    let program = Chip8Program::from_opcodes(&[0x1200]);
    let word_count = program.bytes.len() / 2;
    let pad_pc_word = 0x100 + word_count as u64;
    let padded_rows = semantic_rows.next_power_of_two();
    let mut semantic_trace_rows = Vec::with_capacity(semantic_rows);
    for row_idx in 0..semantic_rows {
        let pc_next = if row_idx + 1 == semantic_rows {
            if semantic_rows == padded_rows {
                0x100
            } else {
                pad_pc_word
            }
        } else {
            0x100
        };
        semantic_trace_rows.push(make_jump_row(pc_next));
    }
    SimpleKernelProverInput {
        public: SimpleKernelPublicInput {
            program_image: program.bytes.clone(),
            initial_pc_word: 0x100,
            initial_registers: [0; 16],
            initial_i: 0,
            initial_ram: vec![0; 4096],
            transcript_seed: Vec::new(),
        },
        witness: SimpleKernelWitness {
            semantic_trace_rows,
            semantic_aux_data: vec![make_jump_aux(); semantic_rows],
        },
    }
}

pub(super) fn verifier_input_from_public(public: &SimpleKernelPublicInput) -> SimpleKernelVerifierInput {
    SimpleKernelVerifierInput {
        public: SimpleKernelPublicInput {
            program_image: public.program_image.clone(),
            initial_pc_word: public.initial_pc_word,
            initial_registers: public.initial_registers,
            initial_i: public.initial_i,
            initial_ram: public.initial_ram.clone(),
            transcript_seed: public.transcript_seed.clone(),
        },
    }
}

pub(crate) fn prove_simple_kernel(
    input: &SimpleKernelProverInput,
    _params: &NeoParams,
    _log: &(),
    _transcript: &mut Poseidon2Transcript,
) -> Result<(SimpleKernelOutput, SimpleKernelProof), SimpleKernelError> {
    prove_simple_kernel_impl(input)
}

pub(crate) fn verify_simple_kernel(
    input: &SimpleKernelVerifierInput,
    proof: &SimpleKernelProof,
    _params: &NeoParams,
    _log: &(),
    _transcript: &mut Poseidon2Transcript,
) -> Result<SimpleKernelOutput, SimpleKernelError> {
    verify_simple_kernel_impl(input, proof)
}

pub(crate) fn chip8_root_params() -> NeoParams {
    chip8_simple_root_params()
}

pub(crate) fn make_ajtai_module(_params: &NeoParams) {}

#[test]
fn stage3_shift_claim_uses_next_row_values() {
    let trace_rows = vec![make_row(10, 20, 0, false, false), make_row(20, 20, 0, false, false)];
    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/stage3_shift");
    let proof = prove_stage3(&trace_rows, 1, 1, &mut transcript).expect("stage3 proof");

    let expected_shift_pc = eq_at(&proof.shift_proof.source_point, 0) * K::from(trace_rows[1][COL_PC]);
    assert_eq!(proof.shift_proof.claimed_shift_values[0], expected_shift_pc);
}

#[test]
fn stage3_rejects_invalid_start_boundary() {
    let trace_rows = vec![make_row(10, 20, 1, true, false), make_row(20, 20, 2, true, true)];
    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/stage3_boundary");
    let err = prove_stage3(&trace_rows, 2, 1, &mut transcript)
        .err()
        .expect("invalid start boundary must fail");
    assert!(format!("{err}").contains("start boundary"));
}

#[test]
fn simple_kernel_populates_opening_manifest() {
    let input = build_jump_kernel_input(1);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel");
    let (output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");

    assert_eq!(proof.stage1.decode_handoff_values.len(), 3);
    assert_eq!(proof.stage1.lane_values_at_lookup.len(), 17);
    assert_eq!(proof.stage1.fetch_proof.addr_point.len(), 11);
    assert_eq!(proof.stage1.decode_proof.addr_point.len(), 16);
    assert_eq!(proof.stage1.alu_proof.addr_point.len(), 18);
    assert_eq!(proof.stage1.eq4_proof.addr_point.len(), 8);
    assert_eq!(proof.stage1.fetch_proof.table_opening_values.len(), 1);
    assert_eq!(proof.stage1.decode_proof.table_opening_values.len(), 22);
    assert_eq!(proof.stage1.alu_proof.table_opening_values.len(), 1);
    assert_eq!(proof.stage1.eq4_proof.table_opening_values.len(), 1);
    assert_eq!(proof.stage2.handoff_values_at_twist.len(), 3);
    assert_eq!(proof.stage2.lane_values_at_twist.len(), 14);
    assert_eq!(proof.stage2.linkage_batch_value, K::ZERO);
    assert_eq!(proof.meta_pub.semantic_rows, 1);
    assert_eq!(proof.meta_pub.padded_trace_length, 1);
    assert_eq!(proof.stage3.row_bindings.len(), output.prepared_steps.len());
    assert_eq!(proof.stage3.row_bindings[0].opened_values.len(), WITNESS_WIDTH - 1);
    assert!(proof.commitments.c_lane.iter().any(|&byte| byte != 0));
    assert_eq!(proof.lane_commitments.commitments.len(), WITNESS_WIDTH - 1);
    assert_eq!(proof.lane_commitments.expected_digest(), proof.commitments.c_lane);
    assert_eq!(proof.fetch_ra_commitments.commitments.len(), 1);
    assert_eq!(
        proof.fetch_ra_commitments.expected_digest(),
        proof.commitments.c_fetch_ra
    );
    assert_eq!(proof.decode_ra_commitments.commitments.len(), 1);
    assert_eq!(
        proof.decode_ra_commitments.expected_digest(),
        proof.commitments.c_decode_ra
    );
    assert_eq!(proof.alu_ra_commitments.commitments.len(), 1);
    assert_eq!(proof.alu_ra_commitments.expected_digest(), proof.commitments.c_alu_ra);
    assert_eq!(proof.eq4_ra_commitments.commitments.len(), 1);
    assert_eq!(proof.eq4_ra_commitments.expected_digest(), proof.commitments.c_eq4_ra);
    assert_eq!(proof.rom_table_commitments.commitments.len(), 1);
    assert_eq!(
        proof.rom_table_commitments.expected_digest(),
        proof.commitments.c_rom_table
    );
    assert_eq!(proof.decode_table_commitments.commitments.len(), 22);
    assert_eq!(
        proof.decode_table_commitments.expected_digest(),
        proof.commitments.c_decode_table
    );
    assert_eq!(proof.alu_table_commitments.commitments.len(), 1);
    assert_eq!(
        proof.alu_table_commitments.expected_digest(),
        proof.commitments.c_alu_table
    );
    assert_eq!(proof.eq4_table_commitments.commitments.len(), 1);
    assert_eq!(
        proof.eq4_table_commitments.expected_digest(),
        proof.commitments.c_eq4_table
    );
    assert_eq!(proof.decode_handoff_commitments.commitments.len(), 3);
    assert_eq!(
        proof.decode_handoff_commitments.expected_digest(),
        proof.commitments.c_decode_handoff
    );
    assert_eq!(proof.reg_twist_commitments.commitments.len(), 5);
    assert_eq!(proof.reg_twist_commitments.expected_digest(), proof.commitments.c_reg);
    assert_eq!(proof.ram_twist_commitments.commitments.len(), 3);
    assert_eq!(proof.ram_twist_commitments.expected_digest(), proof.commitments.c_ram);
    assert!(proof
        .commitments
        .c_decode_handoff
        .iter()
        .any(|&byte| byte != 0));
    assert_ne!(proof.commitments.c_lane, proof.commitments.c_reg);
    assert_ne!(proof.commitments.c_rom_table, proof.commitments.c_eq4_table);
    assert_eq!(output.prepared_steps.len(), 1);
    assert_eq!(output.public_steps.len(), 1);
    assert_eq!(output.prepared_steps[0].mcs.x, vec![F::ONE]);
    assert_eq!(output.prepared_steps[0].mcs.m_in, 1);
    assert_eq!(output.prepared_steps[0].witness.w.len(), WITNESS_WIDTH - 1);
    assert!(proof.kernel_opening_manifest.claims.len() >= 17);
    assert!(output.kernel_opening_manifest.claims.len() >= 17);
    assert!(proof.root_opening_manifest.claims.is_empty());
    assert!(output.root_opening_manifest.claims.is_empty());
    assert!(!proof.time_opening_summary.groups.is_empty());
    assert!(proof
        .time_opening_summary
        .manifest_digest
        .iter()
        .any(|&byte| byte != 0));
    assert!(proof
        .time_opening_summary
        .proof_digest
        .iter()
        .any(|&byte| byte != 0));
    assert!(!proof
        .time_opening_summary
        .unification
        .round_polys
        .is_empty());
    assert_eq!(
        proof.time_opening_summary.unification.r_unify.len(),
        proof.time_opening_summary.unification.round_polys.len()
    );
    assert!(!proof.joint_opening_summary.groups.is_empty());
    assert_eq!(
        proof.joint_opening_summary.groups.len(),
        proof.time_opening_summary.groups.len()
    );
    assert!(!proof
        .joint_opening_summary
        .unification
        .round_polys
        .is_empty());
    assert_eq!(
        proof.joint_opening_summary.unification.r_unify.len(),
        proof.joint_opening_summary.unification.round_polys.len()
    );
    assert!(proof.joint_opening_summary.unified_fold.is_none());
    assert_eq!(
        proof.joint_opening_summary.claims.len(),
        proof.kernel_opening_manifest.claims.len()
    );
    assert!(proof
        .joint_opening_summary
        .groups
        .iter()
        .any(|group| group.commitment_id == CommitmentId::Lane));
    assert!(proof
        .joint_opening_summary
        .groups
        .iter()
        .any(|group| group.commitment_id == CommitmentId::FetchRa));
    assert!(proof
        .joint_opening_summary
        .digest
        .iter()
        .any(|&byte| byte != 0));
    for commitment in [
        CommitmentId::FetchRa,
        CommitmentId::DecodeRa,
        CommitmentId::AluRa,
        CommitmentId::Eq4Ra,
        CommitmentId::RomTable,
        CommitmentId::DecodeTable,
        CommitmentId::AluTable,
        CommitmentId::Eq4Table,
    ] {
        assert!(proof
            .kernel_opening_manifest
            .claims
            .iter()
            .any(|claim| claim.commitment_id == commitment));
    }
    assert!(proof
        .kernel_opening_manifest
        .claims
        .iter()
        .any(|claim| claim.commitment_id == CommitmentId::DecodeHandoff && claim.claimed_values.len() == 3));
    assert!(proof
        .kernel_opening_manifest
        .claims
        .iter()
        .any(|claim| claim.commitment_id == CommitmentId::RegTwist && claim.claimed_values.len() == 5));
    assert!(proof
        .kernel_opening_manifest
        .claims
        .iter()
        .any(|claim| claim.commitment_id == CommitmentId::RamTwist && claim.claimed_values.len() == 3));
    let lane_claim_count = proof
        .kernel_opening_manifest
        .claims
        .iter()
        .filter(|claim| claim.commitment_id == CommitmentId::Lane)
        .count();
    assert_eq!(proof.lane_opening_proofs.len(), lane_claim_count);
    let fetch_ra_claim_count = proof
        .kernel_opening_manifest
        .claims
        .iter()
        .filter(|claim| claim.commitment_id == CommitmentId::FetchRa)
        .count();
    assert_eq!(proof.fetch_ra_opening_proofs.len(), fetch_ra_claim_count);
    let decode_ra_claim_count = proof
        .kernel_opening_manifest
        .claims
        .iter()
        .filter(|claim| claim.commitment_id == CommitmentId::DecodeRa)
        .count();
    assert_eq!(proof.decode_ra_opening_proofs.len(), decode_ra_claim_count);
    let alu_ra_claim_count = proof
        .kernel_opening_manifest
        .claims
        .iter()
        .filter(|claim| claim.commitment_id == CommitmentId::AluRa)
        .count();
    assert_eq!(proof.alu_ra_opening_proofs.len(), alu_ra_claim_count);
    let eq4_ra_claim_count = proof
        .kernel_opening_manifest
        .claims
        .iter()
        .filter(|claim| claim.commitment_id == CommitmentId::Eq4Ra)
        .count();
    assert_eq!(proof.eq4_ra_opening_proofs.len(), eq4_ra_claim_count);
    let rom_table_claim_count = proof
        .kernel_opening_manifest
        .claims
        .iter()
        .filter(|claim| claim.commitment_id == CommitmentId::RomTable)
        .count();
    assert_eq!(proof.rom_table_opening_proofs.len(), rom_table_claim_count);
    let decode_table_claim_count = proof
        .kernel_opening_manifest
        .claims
        .iter()
        .filter(|claim| claim.commitment_id == CommitmentId::DecodeTable)
        .count();
    assert_eq!(proof.decode_table_opening_proofs.len(), decode_table_claim_count);
    let alu_table_claim_count = proof
        .kernel_opening_manifest
        .claims
        .iter()
        .filter(|claim| claim.commitment_id == CommitmentId::AluTable)
        .count();
    assert_eq!(proof.alu_table_opening_proofs.len(), alu_table_claim_count);
    let eq4_table_claim_count = proof
        .kernel_opening_manifest
        .claims
        .iter()
        .filter(|claim| claim.commitment_id == CommitmentId::Eq4Table)
        .count();
    assert_eq!(proof.eq4_table_opening_proofs.len(), eq4_table_claim_count);
    let decode_handoff_claim_count = proof
        .kernel_opening_manifest
        .claims
        .iter()
        .filter(|claim| claim.commitment_id == CommitmentId::DecodeHandoff)
        .count();
    assert_eq!(proof.decode_handoff_opening_proofs.len(), decode_handoff_claim_count);
    let reg_twist_claim_count = proof
        .kernel_opening_manifest
        .claims
        .iter()
        .filter(|claim| claim.commitment_id == CommitmentId::RegTwist)
        .count();
    assert_eq!(proof.reg_twist_opening_proofs.len(), reg_twist_claim_count);
    let ram_twist_claim_count = proof
        .kernel_opening_manifest
        .claims
        .iter()
        .filter(|claim| claim.commitment_id == CommitmentId::RamTwist)
        .count();
    assert_eq!(proof.ram_twist_opening_proofs.len(), ram_twist_claim_count);
}

#[test]
fn simple_kernel_rejects_stage1_linkage_mismatch() {
    let mut input = build_jump_kernel_input(2);
    input.witness.semantic_aux_data[0].decode_addr = 0x6001;
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_linkage");
    let err = match prove_simple_kernel(&input, &params, &log, &mut transcript) {
        Ok(_) => panic!("tampered stage1 linkage must fail"),
        Err(err) => err,
    };
    let err_text = format!("{err}");
    assert!(err_text.contains("stage1"));
}

#[test]
fn stage1_verifier_rejects_tampered_fetch_decode_consistency_rounds() {
    let input = build_jump_kernel_input(1);
    let program = Chip8Program {
        bytes: input.public.program_image.clone(),
        start_pc: CHIP8_PROGRAM_START,
    };
    let word_count = program.bytes.len() / 2;
    let pad_pc_word = 0x100 + word_count as u16;
    let rom_table = build_rom_table(&program, pad_pc_word);
    let decode_table = build_decode_table();
    let alu_table = build_alu_table();
    let eq4_table = build_eq4_table();

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/stage1_decode_consistency_ok");
    let mut proof = prove_stage1(
        &input.witness.semantic_trace_rows,
        &input.witness.semantic_aux_data,
        &rom_table,
        &decode_table,
        &alu_table,
        &eq4_table,
        0,
        &mut prove_transcript,
    )
    .expect("stage1 proof");
    let last_round = proof
        .fetch_proof
        .addr_correctness_rounds
        .last_mut()
        .expect("fetch decode-consistency rounds");
    last_round[0] += K::ONE;

    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/stage1_decode_consistency_ok");
    let err = verify_stage1(
        &proof,
        &rom_table,
        &decode_table,
        &alu_table,
        &eq4_table,
        0,
        &mut verify_transcript,
    )
    .expect_err("tampered fetch decode-consistency rounds must fail");
    assert!(err.contains("decode consistency"));
}

#[test]
fn stage1_verifier_rejects_tampered_alu_decode_consistency_rounds() {
    let program = Chip8Program::from_opcodes(&[0x637b]);
    let initial_state = Chip8State::with_program(&program).expect("initial state");
    let execution = Chip8TraceBuilder::<()>::execute_program(&program, &initial_state, 1).expect("execution");
    let trace_rows = vec![execution[0].row_traces[0].row];
    let aux = vec![execution[0].row_traces[0].kernel_aux.clone()];
    let rom_table = build_rom_table(&program, 0x101);
    let decode_table = build_decode_table();
    let alu_table = build_alu_table();
    let eq4_table = build_eq4_table();

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/stage1_alu_decode_consistency_ok");
    let mut proof = prove_stage1(
        &trace_rows,
        &aux,
        &rom_table,
        &decode_table,
        &alu_table,
        &eq4_table,
        0,
        &mut prove_transcript,
    )
    .expect("stage1 proof");
    let last_round = proof
        .alu_proof
        .addr_correctness_rounds
        .last_mut()
        .expect("alu decode-consistency rounds");
    last_round[0] += K::ONE;

    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/stage1_alu_decode_consistency_ok");
    let err = verify_stage1(
        &proof,
        &rom_table,
        &decode_table,
        &alu_table,
        &eq4_table,
        0,
        &mut verify_transcript,
    )
    .expect_err("tampered ALU decode-consistency rounds must fail");
    assert!(err.contains("decode consistency"));
}

#[test]
fn simple_kernel_rejects_stage1_fetch_pc_mismatch() {
    let mut input = build_jump_kernel_input(2);
    input.witness.semantic_aux_data[0].fetch_addr = 0x101;
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_fetch_pc_mismatch");
    let err = match prove_simple_kernel(&input, &params, &log, &mut transcript) {
        Ok(_) => panic!("tampered fetch PC binding must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("fetch address claim"));
}

#[test]
fn simple_kernel_rejects_stage2_linkage_mismatch() {
    let mut input = build_jump_kernel_input(2);
    input.witness.semantic_trace_rows[0][COL_REG_X] = F::from_u64(7);
    input.witness.semantic_trace_rows[1][COL_REG_X] = F::from_u64(7);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_stage2_linkage");
    let err = match prove_simple_kernel(&input, &params, &log, &mut transcript) {
        Ok(_) => panic!("tampered stage2 linkage must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("stage2 linkage"));
}

#[test]
fn simple_kernel_rejects_stage2_raw_sink_mismatch() {
    let mut input = build_jump_kernel_input(2);
    input.witness.semantic_aux_data[0].reg_ra_y_addr = 0;
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_stage2_raw_sink");
    let err = match prove_simple_kernel(&input, &params, &log, &mut transcript) {
        Ok(_) => panic!("tampered stage2 raw sink routing must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("raw address"));
}

#[test]
fn stage3_uses_active_rows_for_padded_trace_suffix() {
    let trace_rows = vec![
        make_row(10, 20, 0, false, false),
        make_row(20, 30, 0, false, false),
        make_row(30, 0, 0, false, false),
        make_row(0, 0, 0, false, false),
    ];
    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/stage3_padding_suffix");
    let proof = prove_stage3(&trace_rows, 3, 2, &mut transcript).expect("stage3 proof");

    assert_eq!(proof.row_bindings.len(), 3);
    assert_eq!(proof.row_bindings[0].row_index, 0);
    assert_eq!(proof.row_bindings[1].row_index, 1);
    assert_eq!(proof.row_bindings[2].row_index, 2);
    assert_eq!(proof.row_bindings[2].row_bits, vec![false, true]);
    assert_eq!(proof.final_boundary_values, [K::ZERO, K::ZERO]);
}

#[test]
fn stage3_continuity_is_masked_sum_not_pair_mask_times_raw_openings() {
    let pad_pc_word = 0x101;
    let trace_rows = vec![
        make_row(10, 20, 0, false, false),
        make_row(20, 30, 0, false, false),
        make_row(30, pad_pc_word as u64, 0, false, false),
        build_pad_row(pad_pc_word),
    ];
    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/stage3_masked_sum");
    let proof = prove_stage3(&trace_rows, 3, 2, &mut transcript).expect("stage3 proof");

    let pair_mask_at_r = eq_at(&proof.shift_proof.source_point, 0) + eq_at(&proof.shift_proof.source_point, 1);
    let direct_pair_mask_value =
        pair_mask_at_r * (proof.shift_proof.claimed_shift_values[0] - proof.shift_opening_values[1]);

    assert_eq!(proof.continuity_check_value, K::ZERO);
    assert_ne!(direct_pair_mask_value, K::ZERO);
}

#[test]
fn simple_kernel_rejects_empty_semantic_trace() {
    let mut input = build_jump_kernel_input(1);
    input.witness.semantic_trace_rows.clear();
    input.witness.semantic_aux_data.clear();
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_empty_semantic_trace");
    let err = match prove_simple_kernel(&input, &params, &log, &mut transcript) {
        Ok(_) => panic!("empty semantic trace must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("semantic trace must contain at least one row"));
}

#[test]
fn simple_kernel_rejects_invalid_initial_ram_length_at_prove_time() {
    let mut input = build_jump_kernel_input(2);
    input.public.initial_ram.pop();
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_initial_ram_len_prove");
    let err = match prove_simple_kernel(&input, &params, &log, &mut transcript) {
        Ok(_) => panic!("invalid initial RAM length must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("initial RAM length"));
}

#[test]
fn simple_kernel_rejects_odd_program_image_length() {
    let mut input = build_jump_kernel_input(2);
    input.public.program_image.push(0xaa);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_odd_program_image");
    let err = match prove_simple_kernel(&input, &params, &log, &mut transcript) {
        Ok(_) => panic!("odd-length program image must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("program image length"));
}

#[test]
fn simple_kernel_rejects_program_image_that_overflows_rom_domain() {
    let mut input = build_jump_kernel_input(2);
    input.public.program_image = vec![0; 3584];
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_program_overflow");
    let err = match prove_simple_kernel(&input, &params, &log, &mut transcript) {
        Ok(_) => panic!("oversized program image must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("program image word count"));
}

#[test]
fn simple_kernel_rejects_initial_pc_public_mismatch_at_prove_time() {
    let mut input = build_jump_kernel_input(2);
    input.public.initial_pc_word = 0x101;
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_initial_pc_prove");
    let err = match prove_simple_kernel(&input, &params, &log, &mut transcript) {
        Ok(_) => panic!("public initial_pc_word mismatch must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("initial_pc_word"));
}

#[test]
fn simple_kernel_rejects_non_loader_start_even_if_trace_matches_it() {
    let mut input = build_jump_kernel_input(1);
    input.public.initial_pc_word = 0x101;
    input.witness.semantic_trace_rows[0][COL_PC] = F::from_u64(0x101);
    input.witness.semantic_trace_rows[0][COL_PC_NEXT] = F::from_u64(0x101);
    input.witness.semantic_trace_rows[0][COL_NNN_ADDR] = F::from_u64(0x202);
    input.witness.semantic_trace_rows[0][COL_NNN_WORD] = F::from_u64(0x101);
    input.witness.semantic_aux_data[0].fetch_addr = 0x101;
    input.witness.semantic_aux_data[0].decode_addr = 0x1202;
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_non_loader_start");
    let err = match prove_simple_kernel(&input, &params, &log, &mut transcript) {
        Ok(_) => panic!("non-loader start PC must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("standard loader base word"));
}

#[test]
fn simple_kernel_rejects_semantic_aux_length_mismatch() {
    let mut input = build_jump_kernel_input(2);
    input.witness.semantic_aux_data.pop();
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_aux_length_mismatch");
    let err = match prove_simple_kernel(&input, &params, &log, &mut transcript) {
        Ok(_) => panic!("semantic aux length mismatch must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("semantic trace row count 2 does not match aux row count 1"));
}

#[test]
fn simple_kernel_verifier_reconstructs_output() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify");
    let (proved_output, proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify");
    let verified_output =
        verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript).expect("verify");

    assert_eq!(verified_output.prepared_steps.len(), proved_output.prepared_steps.len());
    assert_eq!(verified_output.public_steps.len(), proved_output.public_steps.len());
    assert_eq!(
        verified_output.kernel_opening_manifest.claims.len(),
        proved_output.kernel_opening_manifest.claims.len()
    );
    assert_eq!(
        verified_output.root_opening_manifest.claims.len(),
        proved_output.root_opening_manifest.claims.len()
    );
    assert_eq!(
        verified_output.joint_opening_fold_bucket_proofs,
        proved_output.joint_opening_fold_bucket_proofs
    );
    for (verified, proved) in verified_output
        .prepared_steps
        .iter()
        .zip(proved_output.prepared_steps.iter())
    {
        assert_eq!(verified.label, proved.label);
        assert_eq!(verified.mcs.c, proved.mcs.c);
        assert_eq!(verified.mcs.x, proved.mcs.x);
        assert_eq!(verified.mcs.m_in, proved.mcs.m_in);
        assert_eq!(verified.witness.w, proved.witness.w);
        assert_eq!(verified.witness.Z, proved.witness.Z);
    }
}

#[test]
fn simple_kernel_verifier_rejects_initial_pc_public_mismatch() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_initial_pc_verify");
    let (_proved_output, proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");

    let mut verifier_input = verifier_input_from_public(&input.public);
    verifier_input.public.initial_pc_word = 0x101;
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_initial_pc_verify");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered verifier initial_pc_word must fail"),
        Err(err) => err,
    };
    let err_text = format!("{err}");
    assert!(
        err_text.contains("standard loader base word")
            || err_text.contains("initial state digest")
            || err_text.contains("first semantic row PC")
    );
}

#[test]
fn simple_kernel_verifier_rejects_invalid_initial_ram_length() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_initial_ram_len_verify");
    let (_proved_output, proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");

    let mut verifier_input = verifier_input_from_public(&input.public);
    verifier_input.public.initial_ram.pop();
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_initial_ram_len_verify");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered verifier initial RAM length must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("initial RAM length"));
}

#[test]
fn simple_kernel_verifier_rejects_transcript_seed_public_mismatch() {
    let mut input = build_jump_kernel_input(2);
    input.public.transcript_seed = b"kernel-seed".to_vec();
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_transcript_seed_verify");
    let (_proved_output, proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");

    let mut verifier_input = verifier_input_from_public(&input.public);
    verifier_input.public.transcript_seed = b"other-seed".to_vec();
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_transcript_seed_verify");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered verifier transcript_seed must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("transcript seed digest"));
}

#[test]
fn simple_kernel_challenges_are_canonical_from_public_transcript_seed() {
    let mut input = build_jump_kernel_input(2);
    input.public.transcript_seed = b"kernel-seed-a".to_vec();
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript_a = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_seed_a");
    let (_output_a, proof_a) =
        prove_simple_kernel(&input, &params, &log, &mut transcript_a).expect("simple kernel proof");
    let mut transcript_b = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_seed_b");
    let (_output_b, proof_b) =
        prove_simple_kernel(&input, &params, &log, &mut transcript_b).expect("simple kernel proof");

    assert_eq!(proof_a.stage1.cycle_point, proof_b.stage1.cycle_point);
    assert_eq!(proof_a.stage2.cycle_point, proof_b.stage2.cycle_point);
    assert_eq!(
        proof_a.stage3.shift_proof.source_point,
        proof_b.stage3.shift_proof.source_point
    );

    input.public.transcript_seed = b"kernel-seed-c".to_vec();
    let mut transcript_c = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_seed_c");
    let (_output_c, proof_c) =
        prove_simple_kernel(&input, &params, &log, &mut transcript_c).expect("simple kernel proof");

    assert_ne!(proof_a.stage1.cycle_point, proof_c.stage1.cycle_point);
}

#[test]
fn simple_kernel_verifier_rejects_tampered_opening_claim_digest() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_opening_claim_digest");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.kernel_opening_manifest.claims[0].digest[0] ^= 1;
    proof.kernel_opening_manifest.digest = proof.kernel_opening_manifest.expected_digest();

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_opening_claim_digest");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered kernel opening-claim digest must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("opening-claim digest"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_opening_manifest_digest() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_opening_manifest_digest");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.kernel_opening_manifest.digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_opening_manifest_digest");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered kernel opening-manifest digest must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("manifest digest"));
}

#[test]
fn simple_kernel_verifier_rejects_nonempty_root_opening_manifest() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_root_manifest");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof
        .root_opening_manifest
        .push(KernelOpeningClaim::root(0, vec![K::ZERO], vec![0], vec![K::ONE]));
    proof.root_opening_manifest.canonicalize();

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_root_manifest");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("non-empty root opening manifest must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("root opening claims"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_time_opening_summary() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_time_opening");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.time_opening_summary.unified_digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_time_opening");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered kernel time-opening summary must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("time-opening"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_time_opening_unification_rounds() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_time_opening_unify");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.time_opening_summary.unification.round_polys[0][0] += K::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_time_opening_unify");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered kernel time-opening unification proof must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("time-opening"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_joint_opening_summary() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.joint_opening_summary.groups[0].joint_claim_digits[0] += K::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered kernel joint-opening summary must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("joint-opening"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_joint_opening_unification_rounds() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening_unify");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.joint_opening_summary.unification.round_polys[0][0] += K::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening_unify");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered kernel joint-opening unification proof must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("joint-opening"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_joint_opening_claim_summary() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening_claim");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.joint_opening_summary.claims[0].joint_claim_digits[0] += K::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening_claim");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered kernel joint-opening claim summary must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("joint-opening"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_joint_opening_claim_digest() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening_claim_digest");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.joint_opening_summary.claims[0].digest[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening_claim_digest");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered kernel joint-opening claim digest must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("joint-opening"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_joint_opening_unified_fold() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening_unified");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.joint_opening_summary.unified_fold = Some(proof.joint_opening_summary.groups[0].clone());

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_joint_opening_unified");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("forged kernel joint-opening unified fold must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("joint-opening"));
}

#[test]
fn simple_kernel_verifier_rejects_noncanonical_row_binding_manifest_order() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_manifest_order");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");

    let row_binding_poly_ids: Vec<usize> = (1..WITNESS_WIDTH).collect();
    let row_binding_claims: Vec<usize> = proof
        .kernel_opening_manifest
        .claims
        .iter()
        .enumerate()
        .filter_map(|(idx, claim)| {
            (claim.commitment_id == CommitmentId::Lane
                && claim.polynomial_ids == row_binding_poly_ids
                && claim.claimed_values.len() == WITNESS_WIDTH - 1)
                .then_some(idx)
        })
        .collect();
    assert_eq!(row_binding_claims.len(), 2);
    proof
        .kernel_opening_manifest
        .claims
        .swap(row_binding_claims[0], row_binding_claims[1]);
    proof.kernel_opening_manifest.digest = proof.kernel_opening_manifest.expected_digest();

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_manifest_order");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("non-canonical row-binding manifest order must fail"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("not in canonical order"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_row_binding() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_tamper");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.stage3.row_bindings[0].row_bits[0] = !proof.stage3.row_bindings[0].row_bits[0];

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_tamper");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered row binding must fail verification"),
        Err(err) => err,
    };
    let err_text = format!("{err}");
    assert!(
        err_text.contains("mismatch")
            || err_text.contains("row 0 bits do not match its row index")
            || err_text.contains("row 0 missing opened lane value")
    );
}

#[test]
fn simple_kernel_verifier_rejects_tampered_lane_commitment_digest() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_lane_digest");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.commitments.c_lane[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_lane_digest");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered lane digest must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("kernel commitment c_lane"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_lane_commitment_coords() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_lane_commitment");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.lane_commitments.commitments[0].data[0] += F::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_lane_commitment");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered lane commitment coordinates must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("lane commitment 0 mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_lane_opening_digits() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_lane_opening");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.lane_opening_proofs[0].digit_evals[0][0] += K::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_lane_opening");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered lane opening digits must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("lane opening proofs mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_fetch_ra_commitment_coords() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_fetch_ra_commitment");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.fetch_ra_commitments.commitments[0].data[0] += F::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_fetch_ra_commitment");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered fetch-ra commitment coordinates must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("fetch-ra commitment 0 mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_decode_ra_opening_digits() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_decode_ra_opening");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.decode_ra_opening_proofs[0].digit_evals[0][0] += K::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_decode_ra_opening");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered decode-ra opening digits must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("decode-ra opening proofs mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_alu_ra_commitment_coords() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_alu_ra_commitment");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.alu_ra_commitments.commitments[0].data[0] += F::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_alu_ra_commitment");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered alu-ra commitment coordinates must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("alu-ra commitment 0 mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_eq4_ra_opening_digits() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_eq4_ra_opening");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.eq4_ra_opening_proofs[0].digit_evals[0][0] += K::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_eq4_ra_opening");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered eq4-ra opening digits must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("eq4-ra opening proofs mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_rom_table_commitment_coords() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_rom_table_commitment");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.rom_table_commitments.commitments[0].data[0] += F::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_rom_table_commitment");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered rom-table commitment coordinates must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("rom-table commitment 0 mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_decode_table_opening_digits() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_decode_table_opening");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.decode_table_opening_proofs[0].digit_evals[0][0] += K::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_decode_table_opening");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered decode-table opening digits must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("decode-table opening proofs mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_alu_table_commitment_coords() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_alu_table_commitment");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.alu_table_commitments.commitments[0].data[0] += F::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_alu_table_commitment");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered alu-table commitment coordinates must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("alu-table commitment 0 mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_eq4_table_opening_digits() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_eq4_table_opening");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.eq4_table_opening_proofs[0].digit_evals[0][0] += K::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_eq4_table_opening");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered eq4-table opening digits must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("eq4-table opening proofs mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_decode_handoff_commitment_coords() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_decode_handoff_commitment");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.decode_handoff_commitments.commitments[0].data[0] += F::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_decode_handoff_commitment");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered decode-handoff commitment coordinates must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("decode-handoff commitment 0 mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_decode_handoff_opening_digits() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_decode_handoff_opening");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.decode_handoff_opening_proofs[0].digit_evals[0][0] += K::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_decode_handoff_opening");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered decode-handoff opening digits must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("decode-handoff opening proofs mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_reg_twist_commitment_coords() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_reg_twist_commitment");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.reg_twist_commitments.commitments[0].data[0] += F::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_reg_twist_commitment");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered reg-twist commitment coordinates must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("reg-twist commitment 0 mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_reg_twist_opening_digits() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_reg_twist_opening");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.reg_twist_opening_proofs[0].digit_evals[0][0] += K::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_reg_twist_opening");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered reg-twist opening digits must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("reg-twist opening proofs mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_ram_twist_commitment_coords() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_ram_twist_commitment");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.ram_twist_commitments.commitments[0].data[0] += F::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_ram_twist_commitment");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered ram-twist commitment coordinates must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("ram-twist commitment 0 mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_ram_twist_opening_digits() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_ram_twist_opening");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.ram_twist_opening_proofs[0].digit_evals[0][0] += K::ONE;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_ram_twist_opening");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered ram-twist opening digits must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("ram-twist opening proofs mismatch"));
}

#[test]
fn simple_kernel_verifier_rejects_tampered_rom_table_commitment_digest() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_rom_digest");
    let (_output, mut proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    proof.commitments.c_rom_table[0] ^= 1;

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_verify_rom_digest");
    let err = match verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript) {
        Ok(_) => panic!("tampered ROM-table digest must fail verification"),
        Err(err) => err,
    };
    assert!(format!("{err}").contains("kernel commitment c_rom_table"));
}

use std::sync::Arc;

use neo_ajtai::{setup as ajtai_setup, AjtaiSModule};
use neo_fold_next::chip8::kernel::{
    prove_simple_kernel, verify_simple_kernel, KernelStepAux, SimpleKernelProverInput, SimpleKernelPublicInput,
    SimpleKernelVerifierInput, SimpleKernelWitness,
};
use neo_fold_next::chip8::spec::{
    Chip8Program, CommitmentId, COL_BURST_LAST, COL_IS_JUMP, COL_IS_MEMOP, COL_LOOKUP_OUTPUT, COL_NNN_ADDR,
    COL_NNN_WORD, COL_PC, COL_PC_NEXT, COL_PRESERVES_X, COL_REG_X, COL_X_IDX, WITNESS_WIDTH,
};
use neo_fold_next::chip8::stage3::prove_stage3;
use neo_fold_next::chip8::{RAM_SINK_ADDR, REG_SINK_ADDR};
use neo_math::{D, F, K};
use neo_memory::ajtai::commit_cols_for_ccs_m;
use neo_params::NeoParams;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;
use rand_chacha::rand_core::SeedableRng;
use rand_chacha::ChaCha8Rng;

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
        reg_ra_y_addr: 0,
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

fn build_jump_kernel_input(semantic_rows: usize) -> SimpleKernelProverInput {
    let program = Chip8Program::from_opcodes(&[0x1200]);
    let word_count = program.bytes.len() / 2;
    let pad_pc_word = 0x100 + word_count as u64;
    let padded_rows = semantic_rows.next_power_of_two();
    let mut semantic_trace_rows = Vec::with_capacity(semantic_rows);
    for row_idx in 0..semantic_rows {
        let pc_next = if row_idx + 1 == semantic_rows {
            if semantic_rows == padded_rows {
                0
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

fn verifier_input_from_public(public: &SimpleKernelPublicInput) -> SimpleKernelVerifierInput {
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

fn chip8_root_params() -> NeoParams {
    let mut params = NeoParams::goldilocks_auto_r1cs_ccs(WITNESS_WIDTH).expect("params");
    params.k_rho = 16;
    params.B = 1 << 16;
    params
}

fn make_ajtai_module(params: &NeoParams) -> AjtaiSModule {
    let mut rng = ChaCha8Rng::seed_from_u64(777);
    let pp =
        ajtai_setup(&mut rng, D, params.kappa as usize, commit_cols_for_ccs_m(WITNESS_WIDTH)).expect("Ajtai setup");
    AjtaiSModule::new(Arc::new(pp))
}

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
    assert!(output.prepared_steps[0].deferred_extensions.is_empty());
    assert!(proof.kernel_opening_manifest.claims.len() >= 18);
    assert!(output.kernel_opening_manifest.claims.len() >= 18);
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
    assert!(format!("{err}").contains("linkage"));
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
        assert_eq!(verified.deferred_extensions, proved.deferred_extensions);
    }
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

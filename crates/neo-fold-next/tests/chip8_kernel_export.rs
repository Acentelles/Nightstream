#[path = "support/chip8.rs"]
mod chip8_support;

use neo_fold_next::chip8::kernel::{
    build_chip8_bridge_final_state_from_bridge_source, build_chip8_bridge_final_state_from_relation_witness,
    build_kernel_exact_frames_from_relation_witness, build_kernel_execution_digest_from_relation_witness,
    rebuild_kernel_joint_opening_from_relation_witness, simple_kernel_root_opening_manifest,
    verify_kernel_execution_relation, CHIP8_BRIDGE_FOLD_SCHEDULE,
};
use neo_fold_next::chip8::proof::{prove_kernel_export, verify_kernel_export};
use neo_math::K;
use p3_field::PrimeCharacteristicRing;

#[test]
fn chip8_kernel_export_round_trip() {
    let input = chip8_support::build_jump_kernel_input(4);
    let (relation_digest, proof) = prove_kernel_export(&input).expect("prove kernel export");
    let reads = proof.reads();
    let fetch_sumcheck_rounds = &reads.fetch().sumcheck_rounds;
    let fetch_addr_correctness_rounds = &reads.fetch().addr_correctness_rounds;
    let decode_sumcheck_rounds = &reads.decode().sumcheck_rounds;
    let decode_addr_correctness_rounds = &reads.decode().addr_correctness_rounds;
    let alu_sumcheck_rounds = &reads.alu().sumcheck_rounds;
    let alu_addr_correctness_rounds = &reads.alu().addr_correctness_rounds;
    let eq4_sumcheck_rounds = &reads.eq4().sumcheck_rounds;
    let eq4_addr_correctness_rounds = &reads.eq4().addr_correctness_rounds;
    let neo_fold_next::chip8::stage2::Stage2RegisterExecutionProof {
        reg_rw_batched_rounds,
        reg_val_from_inc_rounds,
        reg_addr_correctness,
        reg_ra_y_target_rounds,
        reg_wa_addr_target_rounds,
        reg_write_x_target_rounds,
        reg_write_i_target_rounds,
    } = proof.twists().register();
    let neo_fold_next::chip8::stage2::Stage2RamExecutionProof {
        ram_rw_batched_rounds,
        ram_val_from_inc_rounds,
        ram_raf_read_rounds,
        ram_raf_write_rounds,
        ram_read_target_rounds,
        ram_write_target_rounds,
        ram_write_matches_x_zero_rounds,
        ram_idle_mem_zero_rounds,
        ram_addr_correctness,
    } = proof.twists().memory();
    let reduction_rounds = proof.shift().reduction_rounds();

    assert_eq!(proof.bridge_chunk_transitions().len(), 2);
    assert_eq!(
        proof.bridge_chunk_transitions()[0].row_slots[0]
            .as_ref()
            .expect("active bridge row")
            .row_binding
            .row_bits
            .len(),
        2
    );
    assert!(!fetch_sumcheck_rounds.is_empty());
    assert!(!decode_sumcheck_rounds.is_empty());
    assert!(!alu_sumcheck_rounds.is_empty());
    assert!(!eq4_sumcheck_rounds.is_empty());
    assert!(!fetch_addr_correctness_rounds.is_empty());
    assert!(!decode_addr_correctness_rounds.is_empty());
    assert!(!alu_addr_correctness_rounds.is_empty());
    assert!(!eq4_addr_correctness_rounds.is_empty());
    assert!(!reg_rw_batched_rounds.is_empty());
    assert!(!ram_rw_batched_rounds.is_empty());
    assert!(!reg_val_from_inc_rounds.is_empty());
    assert!(!ram_val_from_inc_rounds.is_empty());
    assert!(!ram_raf_read_rounds.is_empty());
    assert!(!ram_raf_write_rounds.is_empty());
    assert!(!reg_addr_correctness.is_empty());
    assert!(!ram_addr_correctness.is_empty());
    assert!(!reg_ra_y_target_rounds.is_empty());
    assert!(!reg_wa_addr_target_rounds.is_empty());
    assert!(!reg_write_x_target_rounds.is_empty());
    assert!(!reg_write_i_target_rounds.is_empty());
    assert!(!ram_read_target_rounds.is_empty());
    assert!(!ram_write_target_rounds.is_empty());
    assert!(!ram_write_matches_x_zero_rounds.is_empty());
    assert!(!ram_idle_mem_zero_rounds.is_empty());
    assert!(!reduction_rounds.is_empty());
    verify_kernel_export(&input.public, CHIP8_BRIDGE_FOLD_SCHEDULE, relation_digest, &proof)
        .expect("verify kernel export");
    assert_ne!(relation_digest, [0; 32]);

    let execution_relation =
        verify_kernel_execution_relation(&chip8_support::verifier_input_from_public(&input.public), &proof)
            .expect("verify kernel execution relation");
    assert_eq!(
        execution_relation.chunk_handoffs[0]
            .bridge_handoff
            .step_bindings[0]
            .as_ref()
            .expect("active compact bridge binding")
            .row_index,
        0
    );
    let split_output = execution_relation.export_output();
    assert_eq!(split_output.prepared_steps.len(), 4);
    assert_eq!(
        split_output.root_opening_manifest,
        simple_kernel_root_opening_manifest()
    );
    let split_frames =
        build_kernel_exact_frames_from_relation_witness(&input.public, &proof).expect("build split kernel frames");
    assert_eq!(split_frames.len(), 4);
    let split_digest =
        build_kernel_execution_digest_from_relation_witness(&input.public, &proof).expect("build split kernel digest");
    assert_ne!(split_digest.digest32(), [0; 32]);
    let (joint_summary, joint_bucket_proofs) =
        rebuild_kernel_joint_opening_from_relation_witness(&input.public, &proof)
            .expect("rebuild split joint opening surfaces");
    assert_ne!(joint_summary.digest, [0; 32]);
    assert_eq!(joint_bucket_proofs, execution_relation.joint_opening_fold_bucket_proofs);
    let split_bridge_final_state = build_chip8_bridge_final_state_from_relation_witness(&input.public, &proof)
        .expect("rebuild split bridge final state");
    assert_ne!(split_bridge_final_state, [0; 32]);
    let bridge_source_final_state = build_chip8_bridge_final_state_from_bridge_source(
        &execution_relation.kernel_opening_manifest,
        &proof
            .bridge_chunk_transitions()
            .iter()
            .flat_map(|transition| transition.row_slots.iter().flatten())
            .map(|row| row.row_binding.clone())
            .collect::<Vec<_>>(),
        &execution_relation.opening_refinement_summary,
    )
    .expect("rebuild bridge final state from bridge source");
    assert_eq!(bridge_source_final_state, split_bridge_final_state);
}

#[test]
fn chip8_kernel_export_rejects_tampered_relation_digest() {
    let input = chip8_support::build_jump_kernel_input(4);
    let (mut relation_digest, proof) = prove_kernel_export(&input).expect("prove kernel export");
    relation_digest[0] ^= 1;

    let err = verify_kernel_export(&input.public, CHIP8_BRIDGE_FOLD_SCHEDULE, relation_digest, &proof)
        .expect_err("tampered relation digest must fail");
    assert!(!format!("{err}").is_empty());
}

#[test]
fn chip8_kernel_export_rejects_tampered_bridge_source_row_binding() {
    let input = chip8_support::build_jump_kernel_input(4);
    let (relation_digest, mut proof) = prove_kernel_export(&input).expect("prove kernel export");
    proof.bridge_chunk_transitions_mut()[0].row_slots[0]
        .as_mut()
        .expect("active bridge row")
        .row_binding
        .row_index ^= 1;

    let err = verify_kernel_export(&input.public, CHIP8_BRIDGE_FOLD_SCHEDULE, relation_digest, &proof)
        .expect_err("tampered bridge source must fail");
    assert!(format!("{err}").contains("bridge") || format!("{err}").contains("row"));
}

#[test]
fn chip8_kernel_export_rejects_tampered_bridge_row_bit_width() {
    let input = chip8_support::build_jump_kernel_input(4);
    let (relation_digest, mut proof) = prove_kernel_export(&input).expect("prove kernel export");
    proof.bridge_chunk_transitions_mut()[0].row_slots[0]
        .as_mut()
        .expect("active bridge row")
        .row_binding
        .row_bits
        .push(true);

    let err = verify_kernel_export(&input.public, CHIP8_BRIDGE_FOLD_SCHEDULE, relation_digest, &proof)
        .expect_err("tampered bridge row bit width must fail");
    assert!(format!("{err}").contains("bridge") || format!("{err}").contains("row"));
}

#[test]
fn chip8_kernel_export_rejects_tampered_shift_execution_surface() {
    let input = chip8_support::build_jump_kernel_input(4);
    let (relation_digest, mut proof) = prove_kernel_export(&input).expect("prove kernel export");
    let original = proof.shift().reduction_rounds()[0][0];
    proof.shift_mut().reduction_rounds_mut()[0][0] += original;

    let err = verify_kernel_export(&input.public, CHIP8_BRIDGE_FOLD_SCHEDULE, relation_digest, &proof)
        .expect_err("tampered shift execution surface must fail");
    assert!(format!("{err}").contains("stage") || format!("{err}").contains("opening"));
}

#[test]
fn chip8_kernel_export_rejects_tampered_read_channel_rounds() {
    let input = chip8_support::build_jump_kernel_input(4);
    let (relation_digest, mut proof) = prove_kernel_export(&input).expect("prove kernel export");
    proof.reads_mut().fetch_mut().sumcheck_rounds[0][0] += K::ONE;

    let err = verify_kernel_export(&input.public, CHIP8_BRIDGE_FOLD_SCHEDULE, relation_digest, &proof)
        .expect_err("tampered read-channel witness must fail");
    assert!(format!("{err}").contains("stage1") || format!("{err}").contains("fetch"));
}

#[test]
fn chip8_kernel_export_rejects_tampered_twist_memory_raf_rounds() {
    let input = chip8_support::build_jump_kernel_input(4);
    let (relation_digest, mut proof) = prove_kernel_export(&input).expect("prove kernel export");
    proof.twists_mut().memory_mut().ram_raf_read_rounds[0][0] += K::ONE;

    let err = verify_kernel_export(&input.public, CHIP8_BRIDGE_FOLD_SCHEDULE, relation_digest, &proof)
        .expect_err("tampered twist memory RAF rounds must fail");
    assert!(format!("{err}").contains("stage2") || format!("{err}").contains("ram"));
}

#[test]
fn chip8_kernel_export_rejects_tampered_twist_register_target_rounds() {
    let input = chip8_support::build_jump_kernel_input(4);
    let (relation_digest, mut proof) = prove_kernel_export(&input).expect("prove kernel export");
    proof.twists_mut().register_mut().reg_write_x_target_rounds[0][0] += K::ONE;

    let err = verify_kernel_export(&input.public, CHIP8_BRIDGE_FOLD_SCHEDULE, relation_digest, &proof)
        .expect_err("tampered twist register target rounds must fail");
    assert!(format!("{err}").contains("stage2") || format!("{err}").contains("register"));
}

#[test]
fn chip8_kernel_export_rejects_tampered_twist_memory_target_rounds() {
    let input = chip8_support::build_jump_kernel_input(4);
    let (relation_digest, mut proof) = prove_kernel_export(&input).expect("prove kernel export");
    proof.twists_mut().memory_mut().ram_read_target_rounds[0][0] += K::ONE;

    let err = verify_kernel_export(&input.public, CHIP8_BRIDGE_FOLD_SCHEDULE, relation_digest, &proof)
        .expect_err("tampered twist memory target rounds must fail");
    assert!(format!("{err}").contains("stage2") || format!("{err}").contains("ram"));
}

#[path = "support/chip8.rs"]
mod chip8_support;

use neo_fold_next::chip8::kernel::{
    build_chip8_bridge_chunk_proof_bundle, verify_chip8_bridge_chunk_proof_bundle, CHIP8_BRIDGE_FOLD_SCHEDULE,
};
use p3_field::PrimeCharacteristicRing;

#[test]
fn chip8_native_preserves_prepared_steps_as_root_handoff() {
    let input = chip8_support::build_jump_kernel_input(4);
    let (output, proof) = chip8_support::run_native_kernel(&input).expect("prove simple kernel");
    let verifier_input = chip8_support::verifier_input_from_public(&input.public);
    let verified = chip8_support::rerun_native_kernel(&verifier_input, &proof).expect("verify simple kernel");

    assert_eq!(output.prepared_steps.len(), 4);
    assert_eq!(output.prepared_steps.len(), output.public_steps.len());
    assert_eq!(verified.prepared_steps.len(), output.prepared_steps.len());
    assert_eq!(verified.public_steps.len(), output.public_steps.len());
    assert_eq!(verified.public_steps[0].label, output.public_steps[0].label);
}

#[test]
fn chip8_native_bridge_chunk_round_trip_matches_root_handoff() {
    let input = chip8_support::build_jump_kernel_input(4);
    let (_output, proof) = chip8_support::run_native_kernel(&input).expect("prove simple kernel");
    let bundle = build_chip8_bridge_chunk_proof_bundle(
        &proof.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.stage3.row_bindings,
    )
    .expect("build bridge chunk proof");

    verify_chip8_bridge_chunk_proof_bundle(
        &proof.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.stage3.row_bindings,
        &bundle,
    )
    .expect("verify bridge chunk proof");

    assert_eq!(bundle.fold_schedule, CHIP8_BRIDGE_FOLD_SCHEDULE);
    assert!(!bundle.chunk_transitions.is_empty());
}

#[test]
fn chip8_native_bridge_chunk_rejects_tampered_row_membership() {
    let input = chip8_support::build_jump_kernel_input(4);
    let (_output, proof) = chip8_support::run_native_kernel(&input).expect("prove simple kernel");
    let mut bundle = build_chip8_bridge_chunk_proof_bundle(
        &proof.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.stage3.row_bindings,
    )
    .expect("build bridge chunk proof");
    bundle.chunk_transitions[0].row_slots[0]
        .as_mut()
        .expect("active row slot")
        .row_binding
        .row_bits[0] = !bundle.chunk_transitions[0].row_slots[0]
        .as_ref()
        .expect("active row slot")
        .row_binding
        .row_bits[0];

    let err = verify_chip8_bridge_chunk_proof_bundle(
        &proof.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.stage3.row_bindings,
        &bundle,
    )
    .expect_err("tampered row membership must fail");
    assert!(format!("{err}").contains("bridge"));
}

#[test]
fn chip8_native_bridge_chunk_rejects_tampered_root_encode() {
    let input = chip8_support::build_jump_kernel_input(4);
    let (_output, proof) = chip8_support::run_native_kernel(&input).expect("prove simple kernel");
    let mut bundle = build_chip8_bridge_chunk_proof_bundle(
        &proof.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.stage3.row_bindings,
    )
    .expect("build bridge chunk proof");
    bundle.chunk_transitions[0].row_slots[0]
        .as_mut()
        .expect("active row slot")
        .row_binding
        .opened_values[0] += neo_math::K::ONE;

    let err = verify_chip8_bridge_chunk_proof_bundle(
        &proof.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.stage3.row_bindings,
        &bundle,
    )
    .expect_err("tampered root encode must fail");
    assert!(format!("{err}").contains("bridge"));
}

#[test]
fn chip8_native_bridge_chunk_rejects_tampered_chunk_route() {
    let input = chip8_support::build_jump_kernel_input(4);
    let (_output, proof) = chip8_support::run_native_kernel(&input).expect("prove simple kernel");
    let mut bundle = build_chip8_bridge_chunk_proof_bundle(
        &proof.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.stage3.row_bindings,
    )
    .expect("build bridge chunk proof");
    bundle.chunk_transitions[0].row_slots.swap(0, 1);

    let err = verify_chip8_bridge_chunk_proof_bundle(
        &proof.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.stage3.row_bindings,
        &bundle,
    )
    .expect_err("tampered chunk route must fail");
    assert!(format!("{err}").contains("bridge"));
}

#[test]
fn chip8_native_bridge_chunk_rejects_nonempty_inactive_slot() {
    let input = chip8_support::build_jump_kernel_input(1);
    let (_output, proof) = chip8_support::run_native_kernel(&input).expect("prove simple kernel");
    let mut bundle = build_chip8_bridge_chunk_proof_bundle(
        &proof.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.stage3.row_bindings,
    )
    .expect("build bridge chunk proof");
    let cloned = bundle.chunk_transitions[0].row_slots[0]
        .clone()
        .expect("active row slot");
    bundle.chunk_transitions[0].row_slots[1] = Some(cloned);

    let err = verify_chip8_bridge_chunk_proof_bundle(
        &proof.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.stage3.row_bindings,
        &bundle,
    )
    .expect_err("inactive bridge slot pollution must fail");
    assert!(format!("{err}").contains("slot") || format!("{err}").contains("bridge"));
}

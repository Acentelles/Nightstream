use crate::common::proof_cases::{
    branch_input, expect_accepted_verify_failure, prove_accepted, refresh_stage3_semantic_digests,
};
use neo_fold_next::rv64im::verify_rv64im_accepted_proof;

#[test]
fn accepted_stage3_bundle_tracks_pc_adjacent_bridge() {
    let input = branch_input();
    let (artifact, _) = prove_accepted(&input);
    verify_rv64im_accepted_proof(&artifact).expect("accepted proof verifies");
    assert!(!artifact.stage3.bridge.continuity.is_empty());
}

#[test]
fn accepted_stage3_rejects_tampered_continuity() {
    let input = branch_input();
    let (mut artifact, _) = prove_accepted(&input);
    artifact.stage3.bridge.continuity[0].successor_pc = Some(artifact.stage3.bridge.continuity[0].next_pc + 8);
    expect_accepted_verify_failure(&artifact, "stage3 continuity surface mismatch");
}

#[test]
fn accepted_stage3_rejects_tampered_start_boundary_bridge() {
    let input = branch_input();
    let (mut artifact, _) = prove_accepted(&input);
    artifact.stage3.semantics.initial_pc = artifact.stage3.semantics.initial_pc.wrapping_add(4);
    refresh_stage3_semantic_digests(&mut artifact);
    expect_accepted_verify_failure(&artifact, "stage3 semantic bridge mismatch");
}

#[test]
fn accepted_stage3_rejects_tampered_stage2_temporal_bridge() {
    let input = branch_input();
    let (mut artifact, _) = prove_accepted(&input);
    artifact.stage3.semantics.stage2_temporal_digest[0] ^= 1;
    refresh_stage3_semantic_digests(&mut artifact);
    expect_accepted_verify_failure(&artifact, "stage3 semantic bridge mismatch");
}

use crate::common::proof_cases::{
    alu_input, expect_accepted_verify_failure, prove_accepted, refresh_accepted_artifact_digest,
    refresh_step_composition_surface_digest,
};
use neo_fold_next::rv64im::{
    audit_rv64im_accepted_proof_against_input, verify_rv64im_accepted_proof, verify_rv64im_accepted_proof_with_perf,
};

#[test]
fn accepted_verifier_replays_transcript_and_verifies_without_audit() {
    let input = alu_input();
    let (artifact, _) = prove_accepted(&input);
    let perf = verify_rv64im_accepted_proof_with_perf(&artifact).expect("accepted verify");
    assert!(perf.public_claim_digests_ms >= 0.0);
    assert!(perf.summary_consistency_ms >= 0.0);
}

#[test]
fn audit_path_replays_against_public_input_only_when_requested() {
    let input = alu_input();
    let (artifact, audit) = prove_accepted(&input);
    verify_rv64im_accepted_proof(&artifact).expect("accepted verify");
    audit_rv64im_accepted_proof_against_input(&input, &artifact, &audit).expect("audit verify");
}

#[test]
fn accepted_verifier_rejects_tampered_transcript() {
    let input = alu_input();
    let (mut artifact, _) = prove_accepted(&input);
    artifact.transcript.events[0].message.push(0xA5);
    expect_accepted_verify_failure(&artifact, "accepted proof artifact digest mismatch");
}

#[test]
fn accepted_artifact_digest_binds_transcript_contents() {
    let input = alu_input();
    let (mut artifact, _) = prove_accepted(&input);
    let original_digest = artifact.digest;
    artifact.transcript.events[0].message.push(0xA5);
    refresh_accepted_artifact_digest(&mut artifact);
    assert_ne!(artifact.digest, original_digest);
}

#[test]
fn accepted_verifier_rejects_tampered_transcript_even_if_digest_is_refreshed() {
    let input = alu_input();
    let (mut artifact, _) = prove_accepted(&input);
    artifact.transcript.events[0].message.push(0xA5);
    refresh_accepted_artifact_digest(&mut artifact);
    expect_accepted_verify_failure(&artifact, "transcript replay");
}

#[test]
fn accepted_verifier_rejects_tampered_step_composition_surface() {
    let input = alu_input();
    let (mut artifact, _) = prove_accepted(&input);
    artifact.step_composition.last_real_step_index ^= 1;
    refresh_step_composition_surface_digest(&mut artifact);
    expect_accepted_verify_failure(&artifact, "step composition surface mismatch");
}

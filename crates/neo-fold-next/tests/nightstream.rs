use std::fmt::Debug;

use neo_fold_next::decider::spartan2::{
    setup_spartan2_decider, Spartan2DeciderProof, Spartan2DeciderShape, Spartan2DeciderVerifierKey,
};
use neo_fold_next::nightstream::rv64im::{
    build_rv64im_kernel_opening_claim_from_side_proof_bundle, build_rv64im_main_decider_proof,
    build_rv64im_main_residual_proof, build_rv64im_nightstream_decider_target,
    build_rv64im_nightstream_from_public_proof, build_rv64im_nightstream_linkage_claims,
    build_rv64im_nightstream_linkage_claims_from_relation, build_rv64im_nightstream_statement_from_final,
    build_rv64im_phase0_opened_object_bundle_from_claim_witnesses,
    build_rv64im_side_claim_relation_from_accepted_artifact, build_rv64im_side_claim_relation_statement,
    build_rv64im_side_claim_relation_witness_from_accepted_artifact,
    build_rv64im_side_eval_claim_artifact_from_accepted_artifact,
    build_rv64im_side_eval_claim_relation_from_accepted_artifact,
    build_rv64im_side_eval_claim_relation_statement_from_artifact,
    build_rv64im_side_eval_claim_relation_witness_from_accepted_artifact,
    build_rv64im_side_opening_relation_from_accepted_artifact, build_rv64im_side_opening_relation_statement,
    build_rv64im_side_opening_relation_witness_from_accepted_artifact,
    build_rv64im_side_proof_bundle_from_accepted_artifact, build_rv64im_side_terminal_proof_artifact,
    build_rv64im_side_terminal_proof_artifact_from_accepted_artifact,
    build_rv64im_side_terminal_relation_from_accepted_artifact, build_rv64im_side_terminal_relation_statement,
    build_rv64im_side_terminal_relation_witness_from_accepted_artifact, build_rv64im_side_terminal_witness_artifact,
    build_rv64im_side_terminal_witness_artifact_from_accepted_artifact,
    build_rv64im_stage_claim_bundle_from_side_proof_bundle, rv64im_nightstream_decider_target_digest,
    rv64im_nightstream_linkage_root, rv64im_verifier_context_digest, verify_rv64im_main_decider_proof,
    verify_rv64im_main_residual_proof, verify_rv64im_nightstream, verify_rv64im_side_claim_relation,
    verify_rv64im_side_eval_claim_artifact, verify_rv64im_side_eval_claim_relation,
    verify_rv64im_side_opening_relation, verify_rv64im_side_terminal_relation,
    verify_rv64im_side_terminal_witness_artifact, Rv64imNightstreamProof,
};
use neo_fold_next::nightstream::{
    nightstream_proof_binding_root, nightstream_statement_digest, NightstreamProofBindingInputs, NightstreamStatement,
};
use neo_fold_next::rv64im::final_relation::prove_rv64im_final_statement_from_accepted;
use neo_fold_next::rv64im::{
    build_rv64im_accepted_proof_artifact, build_rv64im_spartan2_decider_target, parity_source_cases,
    prove_rv64im_public_proof, prove_rv64im_spartan2_decider_from_public_proof,
    setup_rv64im_spartan2_decider_from_public_proof, Rv64imProofInput, Rv64imProofStatement, SimpleKernelError,
};
use serde::{de::DeserializeOwned, Serialize};

fn source_case(name: &str) -> neo_fold_next::rv64im::Rv64imParitySourceCase {
    parity_source_cases()
        .into_iter()
        .find(|case| case.manifest.name == name)
        .unwrap_or_else(|| panic!("missing parity source case {name}"))
}

fn alternate_case_name(exclude: &str) -> String {
    parity_source_cases()
        .into_iter()
        .find(|case| case.manifest.name != exclude)
        .unwrap_or_else(|| panic!("missing alternate parity source case for {exclude}"))
        .manifest
        .name
        .to_string()
}

fn proof_input(name: &str) -> Rv64imProofInput {
    let source = source_case(name);
    let max_steps = source.program_words.len();
    Rv64imProofInput { source, max_steps }
}

struct ExternalNightstreamFixture {
    trusted_root_params_id: [u8; 32],
    public_statement: Rv64imProofStatement,
    decider_vk: Spartan2DeciderVerifierKey,
    decider_proof: Spartan2DeciderProof,
    statement: NightstreamStatement,
    nightstream_proof: Rv64imNightstreamProof,
}

fn external_fixture(name: &str) -> ExternalNightstreamFixture {
    let public_proof = prove_rv64im_public_proof(&proof_input(name)).expect("prove rv64im public proof");
    let trusted_root_params_id = public_proof.statement.root_params_id;
    let public_statement = public_proof.statement.clone();
    let (decider_pk, decider_vk) =
        setup_rv64im_spartan2_decider_from_public_proof(&public_proof).expect("setup rv64im spartan2 decider");
    let decider_proof = prove_rv64im_spartan2_decider_from_public_proof(&decider_pk, &public_proof)
        .expect("prove rv64im spartan2 decider");
    let (statement, nightstream_proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream proof");
    ExternalNightstreamFixture {
        trusted_root_params_id,
        public_statement,
        decider_vk,
        decider_proof,
        statement,
        nightstream_proof,
    }
}

fn verify_fixture(fixture: &ExternalNightstreamFixture) -> Result<(), SimpleKernelError> {
    verify_rv64im_nightstream(
        &fixture.statement,
        &fixture.nightstream_proof,
        fixture.trusted_root_params_id,
        &fixture.decider_vk,
        &fixture.decider_proof,
        &fixture.public_statement,
    )
}

#[test]
fn rv64im_side_bundle_rebuilds_exact_stage_claim_bundle() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let bundle = build_rv64im_side_proof_bundle_from_accepted_artifact(&artifact).expect("build side proof bundle");
    let rebuilt = build_rv64im_stage_claim_bundle_from_side_proof_bundle(&bundle, proof.statement.execution_digest)
        .expect("rebuild exact stage-claim bundle from side proof bundle");

    assert_eq!(rebuilt, artifact.stage_claims.claims);
}

#[test]
fn rv64im_side_bundle_rebuilds_exact_kernel_opening_claim() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let bundle = build_rv64im_side_proof_bundle_from_accepted_artifact(&artifact).expect("build side proof bundle");
    let rebuilt = build_rv64im_kernel_opening_claim_from_side_proof_bundle(&bundle, &proof.statement)
        .expect("rebuild exact kernel-opening claim from side proof bundle");

    assert_eq!(rebuilt, artifact.kernel_opening.opening.claim);
}

#[test]
fn rv64im_side_opening_relation_roundtrips_from_accepted_artifact() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, witness) =
        build_rv64im_side_opening_relation_from_accepted_artifact(&artifact).expect("build side-opening relation");

    verify_rv64im_side_opening_relation(&statement, &witness).expect("verify side-opening relation");
}

#[test]
fn rv64im_side_opening_relation_rejects_tampered_stage1_selected_row_witness() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, mut witness) =
        build_rv64im_side_opening_relation_from_accepted_artifact(&artifact).expect("build side-opening relation");

    witness.stage1_selected_rows.first.fetched_word ^= 1;

    let err = verify_rv64im_side_opening_relation(&statement, &witness)
        .expect_err("tampered stage1 selected row witness must fail");
    assert!(format!("{err}")
        .contains("RV64IM side-opening relation stage1 selected rows do not match the carried opening claim"));
}

#[test]
fn rv64im_side_opening_relation_rejects_tampered_stage1_package_statement_step_witness() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, mut witness) =
        build_rv64im_side_opening_relation_from_accepted_artifact(&artifact).expect("build side-opening relation");

    witness.stage1_packaged.step.label.push_str("/tamper");

    let err = verify_rv64im_side_opening_relation(&statement, &witness)
        .expect_err("tampered stage1 package statement step must fail");
    assert!(
        format!("{err}").contains("rv64im/stage1 selected-claim package statement digest mismatch")
            || format!("{err}").contains("rv64im/stage1 selected-claim package public step mismatch")
    );
}

#[test]
fn rv64im_side_opening_relation_rejects_self_consistent_binding_summary_swap() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let side_bundle =
        build_rv64im_side_proof_bundle_from_accepted_artifact(&artifact).expect("build side proof bundle");
    let mut statement =
        build_rv64im_side_opening_relation_statement(&proof.statement, &side_bundle).expect("build relation statement");
    let witness = build_rv64im_side_opening_relation_witness_from_accepted_artifact(&artifact);

    let last_binding = statement
        .side_bundle
        .kernel_opening_bridge
        .prepared_step_bindings
        .last_binding_digest
        .as_mut()
        .expect("last binding digest");
    last_binding[0] ^= 1;
    statement
        .side_bundle
        .kernel_opening_bridge
        .prepared_step_bindings
        .digest = statement
        .side_bundle
        .kernel_opening_bridge
        .prepared_step_bindings
        .expected_digest();
    statement.side_bundle.kernel_opening_bridge.digest = statement
        .side_bundle
        .kernel_opening_bridge
        .expected_digest();
    statement.side_bundle.digest = statement.side_bundle.expected_digest();

    let err = verify_rv64im_side_opening_relation(&statement, &witness)
        .expect_err("self-consistent binding-summary swap must fail");
    assert!(format!("{err}").contains(
        "RV64IM Nightstream compact kernel-opening proof surface does not match the carried public statement"
    ));
}

#[test]
fn rv64im_side_opening_relation_compact_witness_is_smaller_than_full_opening_bundles() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let witness = build_rv64im_side_opening_relation_witness_from_accepted_artifact(&artifact);

    let full_len = bincode::serialize(&(
        artifact.stage_packages.packages.clone(),
        artifact.kernel_opening.opening.clone(),
    ))
    .expect("serialize full opening-side witness material")
    .len();
    let compact_len = bincode::serialize(&witness)
        .expect("serialize compact opening-side witness")
        .len();

    println!(
        "rv64im side-opening compact witness sizes: full_opening={} compact_opening={}",
        full_len, compact_len
    );

    assert!(compact_len < full_len);
}

#[test]
fn rv64im_side_eval_claim_relation_roundtrips_from_accepted_artifact() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, witness) = build_rv64im_side_eval_claim_relation_from_accepted_artifact(&artifact)
        .expect("build side-eval-claim relation");

    verify_rv64im_side_eval_claim_relation(&statement, &witness).expect("verify side-eval-claim relation");
}

#[test]
fn rv64im_side_eval_claim_relation_rejects_tampered_stage_proof_binding_digest() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (mut statement, witness) = build_rv64im_side_eval_claim_relation_from_accepted_artifact(&artifact)
        .expect("build side-eval-claim relation");

    statement.phase0_stage_proof_bindings.stage2_proof_digest[0] ^= 1;
    statement.phase0_stage_proof_bindings.digest = statement.phase0_stage_proof_bindings.expected_digest();

    let err = verify_rv64im_side_eval_claim_relation(&statement, &witness)
        .expect_err("tampered stage proof binding digest must fail");
    assert!(format!("{err}").contains("binding digest does not match the carried theorem surfaces"));
}

#[test]
fn rv64im_side_eval_claim_relation_rejects_tampered_opened_object_summary() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (mut statement, witness) = build_rv64im_side_eval_claim_relation_from_accepted_artifact(&artifact)
        .expect("build side-eval-claim relation");

    let stage1 = &mut statement.phase0_opened_objects.objects[0];
    stage1.opened_object.commitment_root_digest[0] ^= 1;
    stage1.opened_object.digest = stage1
        .opened_object
        .expected_digest(&stage1.commitment_context);
    stage1.digest = stage1.expected_digest();
    statement.phase0_opened_objects.digest = statement.phase0_opened_objects.expected_digest();

    let err = verify_rv64im_side_eval_claim_relation(&statement, &witness)
        .expect_err("tampered opened-object summary must fail");
    assert!(format!("{err}").contains("opened-object summaries do not match the carried Phase 0 bundle"));
}

#[test]
fn rv64im_side_eval_claim_relation_opened_objects_match_claim_witness_projection() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let witness = build_rv64im_side_eval_claim_relation_witness_from_accepted_artifact(&artifact)
        .expect("build side-eval-claim witness");
    let opened_objects = build_rv64im_phase0_opened_object_bundle_from_claim_witnesses(&witness.claim_witnesses)
        .expect("build phase0 opened-object bundle");

    assert_eq!(opened_objects.objects.len(), 6);
    assert_ne!(opened_objects.digest, [0; 32]);
}

#[test]
fn rv64im_side_eval_claim_artifact_roundtrips_from_accepted_artifact() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let side_bundle =
        build_rv64im_side_proof_bundle_from_accepted_artifact(&artifact).expect("build side proof bundle");
    let phase0_artifact = build_rv64im_side_eval_claim_artifact_from_accepted_artifact(&artifact)
        .expect("build side eval claim artifact");

    verify_rv64im_side_eval_claim_artifact(&proof.statement, &side_bundle, &phase0_artifact)
        .expect("verify side eval claim artifact");
}

#[test]
fn rv64im_side_eval_claim_artifact_reconstructs_relation_statement() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let side_bundle =
        build_rv64im_side_proof_bundle_from_accepted_artifact(&artifact).expect("build side proof bundle");
    let (statement, _) = build_rv64im_side_eval_claim_relation_from_accepted_artifact(&artifact)
        .expect("build side eval claim relation");
    let phase0_artifact = build_rv64im_side_eval_claim_artifact_from_accepted_artifact(&artifact)
        .expect("build side eval claim artifact");

    let rebuilt =
        build_rv64im_side_eval_claim_relation_statement_from_artifact(&proof.statement, &side_bundle, &phase0_artifact)
            .expect("rebuild side eval claim relation statement from artifact");

    assert_eq!(rebuilt, statement);
}

#[test]
fn rv64im_side_eval_claim_artifact_rejects_tampered_statement_digest() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let side_bundle =
        build_rv64im_side_proof_bundle_from_accepted_artifact(&artifact).expect("build side proof bundle");
    let mut phase0_artifact = build_rv64im_side_eval_claim_artifact_from_accepted_artifact(&artifact)
        .expect("build side eval claim artifact");

    phase0_artifact.statement_digest[0] ^= 1;
    phase0_artifact.digest = phase0_artifact.expected_digest();

    let err = verify_rv64im_side_eval_claim_artifact(&proof.statement, &side_bundle, &phase0_artifact)
        .expect_err("tampered statement digest must fail");
    assert!(format!("{err}").contains("statement digest does not match the carried relation statement"));
}

#[test]
fn rv64im_side_eval_claim_artifact_rejects_tampered_eval_claim_bundle() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let side_bundle =
        build_rv64im_side_proof_bundle_from_accepted_artifact(&artifact).expect("build side proof bundle");
    let mut phase0_artifact = build_rv64im_side_eval_claim_artifact_from_accepted_artifact(&artifact)
        .expect("build side eval claim artifact");

    phase0_artifact.eval_claim_bundle.claims[0].binding_digest[0] ^= 1;
    phase0_artifact.eval_claim_bundle.digest = phase0_artifact.eval_claim_bundle.expected_digest();
    phase0_artifact.digest = phase0_artifact.expected_digest();

    let err = verify_rv64im_side_eval_claim_artifact(&proof.statement, &side_bundle, &phase0_artifact)
        .expect_err("tampered eval claim bundle must fail");
    assert!(format!("{err}").contains("statement digest does not match the carried relation statement"));
}

#[test]
fn rv64im_side_claim_relation_roundtrips_from_accepted_artifact() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, witness) =
        build_rv64im_side_claim_relation_from_accepted_artifact(&artifact).expect("build side-claim relation");

    verify_rv64im_side_claim_relation(&statement, &witness).expect("verify side-claim relation");
}

#[test]
fn rv64im_side_claim_relation_rejects_tampered_stage_claim_witness() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, mut witness) =
        build_rv64im_side_claim_relation_from_accepted_artifact(&artifact).expect("build side-claim relation");

    witness.stage_claims_packaged.proof_digest[0] ^= 1;

    let err =
        verify_rv64im_side_claim_relation(&statement, &witness).expect_err("tampered stage-claim witness must fail");
    assert!(format!("{err}")
        .contains("RV64IM side-claim relation stage-claim witness does not match the carried side bundle"));
}

#[test]
fn rv64im_side_claim_relation_rejects_tampered_stage_claim_statement_step_witness() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, mut witness) =
        build_rv64im_side_claim_relation_from_accepted_artifact(&artifact).expect("build side-claim relation");

    witness.stage_claims_packaged.step.label.push_str("/tamper");

    let err = verify_rv64im_side_claim_relation(&statement, &witness)
        .expect_err("tampered stage-claim statement step must fail");
    assert!(
        format!("{err}").contains("rv64im/stage_claim_bundle selected-claim package statement digest mismatch")
            || format!("{err}").contains("rv64im/stage_claim_bundle selected-claim package public step mismatch")
    );
}

#[test]
fn rv64im_side_claim_relation_rejects_self_consistent_kernel_claim_witness_swap() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let side_bundle =
        build_rv64im_side_proof_bundle_from_accepted_artifact(&artifact).expect("build side proof bundle");
    let statement =
        build_rv64im_side_claim_relation_statement(&proof.statement, &side_bundle).expect("build relation statement");
    let mut witness = build_rv64im_side_claim_relation_witness_from_accepted_artifact(&artifact);

    let alternate_proof = prove_rv64im_public_proof(&proof_input(&alternate_case_name("control_flow_jal_skip_ecall")))
        .expect("prove alternate rv64im public proof");
    let alternate_artifact =
        build_rv64im_accepted_proof_artifact(&alternate_proof).expect("build alternate accepted artifact");
    witness.kernel_claims_packaged =
        build_rv64im_side_claim_relation_witness_from_accepted_artifact(&alternate_artifact).kernel_claims_packaged;

    let err = verify_rv64im_side_claim_relation(&statement, &witness)
        .expect_err("self-consistent kernel-claim witness swap must fail");
    assert!(
        format!("{err}")
            .contains("RV64IM side-claim relation kernel-claim witness does not match the carried side bundle")
            || format!("{err}").contains("rv64im/kernel_claim_bundle selected-claim package public step mismatch")
    );
}

#[test]
fn rv64im_side_claim_relation_compact_witness_is_smaller_than_full_packaged_proofs() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let witness = build_rv64im_side_claim_relation_witness_from_accepted_artifact(&artifact);

    let full_stage_len = bincode::serialize(&artifact.stage_claims.packaged)
        .expect("serialize full stage packaged proof")
        .len();
    let compact_stage_len = bincode::serialize(&witness.stage_claims_packaged)
        .expect("serialize compact stage packaged witness")
        .len();
    let full_kernel_len = bincode::serialize(&artifact.kernel_claims.packaged)
        .expect("serialize full kernel packaged proof")
        .len();
    let compact_kernel_len = bincode::serialize(&witness.kernel_claims_packaged)
        .expect("serialize compact kernel packaged witness")
        .len();

    println!(
        "rv64im side-claim compact witness sizes: full_stage={} compact_stage={} full_kernel={} compact_kernel={}",
        full_stage_len, compact_stage_len, full_kernel_len, compact_kernel_len
    );

    assert!(compact_stage_len < full_stage_len);
    assert!(compact_kernel_len < full_kernel_len);
}

#[test]
fn rv64im_side_terminal_relation_roundtrips_from_accepted_artifact() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, witness) =
        build_rv64im_side_terminal_relation_from_accepted_artifact(&artifact).expect("build side-terminal relation");

    verify_rv64im_side_terminal_relation(&statement, &witness).expect("verify side-terminal relation");
}

#[test]
fn rv64im_side_terminal_witness_artifact_roundtrips_from_accepted_artifact() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, _) =
        build_rv64im_side_terminal_relation_from_accepted_artifact(&artifact).expect("build side-terminal relation");
    let witness_artifact = build_rv64im_side_terminal_witness_artifact_from_accepted_artifact(&artifact)
        .expect("build side-terminal witness artifact");

    verify_rv64im_side_terminal_witness_artifact(&statement, &witness_artifact)
        .expect("verify side-terminal witness artifact");
    assert_ne!(witness_artifact.digest, [0; 32]);
}

#[test]
fn rv64im_side_terminal_proof_artifact_from_accepted_matches_checked_builder() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (nightstream_statement, nightstream_proof) =
        build_rv64im_nightstream_from_public_proof(&proof).expect("build nightstream proof");
    let relation_statement =
        build_rv64im_side_terminal_relation_statement(&proof.statement, &nightstream_proof.side_proof_artifact.bundle)
            .expect("build bound side-terminal relation statement");
    let witness = build_rv64im_side_terminal_relation_witness_from_accepted_artifact(&artifact);
    let witness_artifact =
        build_rv64im_side_terminal_witness_artifact(&relation_statement, &witness).expect("build witness artifact");

    let checked = build_rv64im_side_terminal_proof_artifact(
        &nightstream_statement,
        &nightstream_proof.main_residual_proof.bridge_handoff_digests,
        &proof.statement,
        &nightstream_proof.side_proof_artifact.bundle,
        &witness_artifact,
    )
    .expect("build checked side-terminal proof artifact");
    let from_accepted = build_rv64im_side_terminal_proof_artifact_from_accepted_artifact(
        &nightstream_statement,
        &nightstream_proof.main_residual_proof.bridge_handoff_digests,
        &proof.statement,
        &nightstream_proof.side_proof_artifact.bundle,
        &artifact,
    )
    .expect("build accepted-artifact side-terminal proof artifact");

    verify_rv64im_side_terminal_witness_artifact(&relation_statement, &witness_artifact)
        .expect("verify witness artifact");
    verify_rv64im_side_terminal_relation(&relation_statement, &witness).expect("verify side-terminal relation");
    assert_eq!(checked, from_accepted);
}

#[test]
fn rv64im_side_terminal_proof_artifact_from_accepted_rejects_mismatched_side_bundle() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (nightstream_statement, mut nightstream_proof) =
        build_rv64im_nightstream_from_public_proof(&proof).expect("build nightstream proof");

    nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_claim_proof_bridge
        .kernel_claim_proof_bundle_digest = [9; 32];
    nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_claim_proof_bridge
        .digest = nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_claim_proof_bridge
        .expected_digest();
    nightstream_proof.side_proof_artifact.bundle.digest = nightstream_proof
        .side_proof_artifact
        .bundle
        .expected_digest();

    let err = build_rv64im_side_terminal_proof_artifact_from_accepted_artifact(
        &nightstream_statement,
        &nightstream_proof.main_residual_proof.bridge_handoff_digests,
        &proof.statement,
        &nightstream_proof.side_proof_artifact.bundle,
        &artifact,
    )
    .expect_err("accepted-artifact fast path should reject a mismatched side bundle");

    assert!(
        format!("{err}").contains("kernel-claim proof bridge"),
        "unexpected error: {err}"
    );
}

#[test]
fn rv64im_side_terminal_relation_compact_witness_is_smaller_than_full_hidden_material() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let witness = build_rv64im_side_terminal_relation_witness_from_accepted_artifact(&artifact);

    let full_len = bincode::serialize(&(
        artifact.stage_claims.packaged.clone(),
        artifact.kernel_claims.packaged.clone(),
        artifact.stage_packages.packages.clone(),
        artifact.kernel_opening.opening.clone(),
    ))
    .expect("serialize full side-terminal hidden material")
    .len();
    let compact_len = bincode::serialize(&witness)
        .expect("serialize compact side-terminal witness")
        .len();

    println!(
        "rv64im side-terminal compact witness sizes: full_hidden={} compact_witness={} digest={:?}",
        full_len,
        compact_len,
        witness.digest()
    );

    assert_ne!(witness.digest(), [0; 32]);
    assert!(compact_len < full_len);
}

#[test]
fn rv64im_side_terminal_witness_artifact_rejects_tampered_digest() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, _) =
        build_rv64im_side_terminal_relation_from_accepted_artifact(&artifact).expect("build side-terminal relation");
    let mut witness_artifact = build_rv64im_side_terminal_witness_artifact_from_accepted_artifact(&artifact)
        .expect("build side-terminal witness artifact");

    witness_artifact.digest[0] ^= 1;

    let err = verify_rv64im_side_terminal_witness_artifact(&statement, &witness_artifact)
        .expect_err("tampered side-terminal witness artifact digest must fail");
    assert!(format!("{err}").contains("RV64IM side-terminal witness artifact digest mismatch"));
}

#[test]
fn rv64im_side_terminal_relation_rejects_claim_side_tamper() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, mut witness) =
        build_rv64im_side_terminal_relation_from_accepted_artifact(&artifact).expect("build side-terminal relation");

    witness.claims.stage_claims_packaged.proof_digest[0] ^= 1;

    let err =
        verify_rv64im_side_terminal_relation(&statement, &witness).expect_err("tampered claim-side witness must fail");
    assert!(format!("{err}")
        .contains("RV64IM side-claim relation stage-claim witness does not match the carried side bundle"));
}

#[test]
fn rv64im_side_terminal_relation_rejects_opening_side_tamper() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let side_bundle =
        build_rv64im_side_proof_bundle_from_accepted_artifact(&artifact).expect("build side proof bundle");
    let statement = build_rv64im_side_terminal_relation_statement(&proof.statement, &side_bundle)
        .expect("build relation statement");
    let mut witness = build_rv64im_side_terminal_relation_witness_from_accepted_artifact(&artifact);

    witness.openings.stage1_selected_rows.first.fetched_word ^= 1;

    let err = verify_rv64im_side_terminal_relation(&statement, &witness)
        .expect_err("tampered opening-side witness must fail");
    assert!(format!("{err}")
        .contains("RV64IM side-opening relation stage1 selected rows do not match the carried opening claim"));
}

fn rebind_statement(statement: &mut NightstreamStatement, proof: &Rv64imNightstreamProof) {
    let proof_binding_inputs = NightstreamProofBindingInputs {
        main_decider_proof_digest: proof.main_decider_proof.expected_digest(),
        main_residual_proof_digest: proof.main_residual_proof.expected_digest(),
        side_terminal_artifact_digest: proof.side_terminal_artifact.digest,
        side_proof_artifact_digest: proof.side_proof_artifact.digest,
        opening_artifact_digest: proof.opening_artifact.digest,
        linkage_artifact_digest: proof.linkage_artifact.digest,
    };
    statement.proof_binding_root = nightstream_proof_binding_root(statement.core_digest(), &proof_binding_inputs);
}

fn rebind_side_artifact_digest(fixture: &mut ExternalNightstreamFixture) {
    fixture.nightstream_proof.side_proof_artifact.digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .expected_digest();
}

fn tamper_snark_bytes(snark_data: &mut Vec<u8>) {
    if let Some(first) = snark_data.first_mut() {
        *first ^= 1;
    } else {
        snark_data.push(1);
    }
}

#[test]
fn rv64im_nightstream_rejects_stale_stage1_claim_digest_inside_side_bundle() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .stage1
        .claim
        .points
        .first
        .value_digest[0] ^= 1;

    let err = verify_fixture(&fixture).expect_err("tampered stage1 selected-opening claim must fail");
    assert!(format!("{err}").contains("stage1 selected-opening claim digest mismatch"));
}

fn assert_bincode_roundtrip<T>(value: &T)
where
    T: Serialize + DeserializeOwned + Eq + Debug,
{
    let bytes = bincode::serialize(value).expect("serialize roundtrip value");
    let decoded: T = bincode::deserialize(&bytes).expect("deserialize roundtrip value");
    assert_eq!(decoded, *value);
}

#[test]
fn nightstream_statement_digest_tracks_binding_root() {
    let mut statement = NightstreamStatement {
        public_io_digest: [1; 32],
        verifier_context_digest: [2; 32],
        fold_schedule: neo_fold_next::proof::FoldSchedule::WholeTrace,
        semantic_step_count: 7,
        chunk_summaries: Vec::new(),
        linkage_root: [3; 32],
        proof_binding_root: [0; 32],
    };
    let inputs = NightstreamProofBindingInputs {
        main_decider_proof_digest: [4; 32],
        main_residual_proof_digest: [5; 32],
        side_terminal_artifact_digest: [6; 32],
        side_proof_artifact_digest: [7; 32],
        opening_artifact_digest: [8; 32],
        linkage_artifact_digest: [9; 32],
    };
    statement.proof_binding_root = nightstream_proof_binding_root(statement.core_digest(), &inputs);
    let digest_before = nightstream_statement_digest(&statement);
    statement.proof_binding_root[0] ^= 1;
    let digest_after = nightstream_statement_digest(&statement);
    assert_ne!(digest_before, digest_after);
}

#[test]
fn rv64im_nightstream_decider_target_bridge_matches_current_target() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, final_proof) =
        prove_rv64im_final_statement_from_accepted(&artifact).expect("prove rv64im final statement");

    let existing = build_rv64im_spartan2_decider_target(&statement, &final_proof).expect("existing target");
    let bridged = build_rv64im_nightstream_decider_target(&statement, &final_proof).expect("nightstream target");

    assert_eq!(existing, bridged);
    assert_eq!(
        rv64im_nightstream_decider_target_digest(&statement, &final_proof).expect("target digest"),
        existing.digest(),
    );
}

#[test]
fn rv64im_nightstream_linkage_and_residual_follow_verified_final_seam() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, final_proof) =
        prove_rv64im_final_statement_from_accepted(&artifact).expect("prove rv64im final statement");

    let linkage_claims =
        build_rv64im_nightstream_linkage_claims(&statement, &final_proof).expect("build linkage claims");
    assert_eq!(
        linkage_claims.public_chunk_digests.len(),
        statement.folded.chunk_count as usize
    );
    assert_eq!(
        linkage_claims.bridge_handoff_digests.len(),
        statement.folded.chunk_count as usize
    );
    assert_ne!(linkage_claims.digest, [0; 32]);
    assert_ne!(
        rv64im_nightstream_linkage_root(final_proof.kernel_export.digest, &linkage_claims),
        [0; 32]
    );

    let residual = build_rv64im_main_residual_proof(&statement, &final_proof).expect("build residual proof");
    verify_rv64im_main_residual_proof(&statement, &final_proof, &residual).expect("verify residual proof");

    let main_decider_proof =
        build_rv64im_main_decider_proof(&statement, &final_proof).expect("build main decider proof");
    verify_rv64im_main_decider_proof(&statement, &final_proof, &main_decider_proof).expect("verify main decider proof");

    let verifier_context = rv64im_verifier_context_digest(proof.statement.root_params_id);
    assert_ne!(verifier_context, [0; 32]);
}

#[test]
fn rv64im_nightstream_linkage_claims_from_relation_match_verified_final_seam() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, final_proof) =
        prove_rv64im_final_statement_from_accepted(&artifact).expect("prove rv64im final statement");

    let from_final = build_rv64im_nightstream_linkage_claims(&statement, &final_proof).expect("build linkage claims");
    let residual = build_rv64im_main_residual_proof(&statement, &final_proof).expect("build residual proof");
    let from_relation = build_rv64im_nightstream_linkage_claims_from_relation(
        &residual.decider_relation,
        &residual.bridge_handoff_digests,
    )
    .expect("build linkage claims from carried relation");

    assert_eq!(from_relation, from_final);
}

#[test]
fn rv64im_main_residual_and_decider_relation_public_statement_digests_are_distinct_surfaces() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (final_statement, final_proof) =
        prove_rv64im_final_statement_from_accepted(&artifact).expect("prove rv64im final statement");

    let residual = build_rv64im_main_residual_proof(&final_statement, &final_proof).expect("build main residual proof");

    assert_eq!(
        residual.public_statement_digest,
        final_statement.public_statement_digest
    );
    assert_eq!(
        residual.decider_relation.public_statement_digest,
        final_statement.digest
    );
    assert_ne!(
        residual.public_statement_digest,
        residual.decider_relation.public_statement_digest
    );
}

#[test]
fn rv64im_main_decider_proof_rejects_tampered_target_digest() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, final_proof) =
        prove_rv64im_final_statement_from_accepted(&artifact).expect("prove rv64im final statement");

    let mut main_decider_proof =
        build_rv64im_main_decider_proof(&statement, &final_proof).expect("build main decider proof");
    main_decider_proof.decider_target_digest[0] ^= 1;
    let err = verify_rv64im_main_decider_proof(&statement, &final_proof, &main_decider_proof)
        .expect_err("tampered main decider proof must fail");
    assert!(format!("{err}").contains("main decider proof"));
}

#[test]
fn rv64im_nightstream_statement_projects_verified_final_seam() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (statement, final_proof) =
        prove_rv64im_final_statement_from_accepted(&artifact).expect("prove rv64im final statement");

    let verifier_context = rv64im_verifier_context_digest(proof.statement.root_params_id);
    let linkage_claims =
        build_rv64im_nightstream_linkage_claims(&statement, &final_proof).expect("build linkage claims");
    let linkage_root = rv64im_nightstream_linkage_root(final_proof.kernel_export.digest, &linkage_claims);

    let proof_binding_inputs = NightstreamProofBindingInputs {
        main_decider_proof_digest: [9; 32],
        main_residual_proof_digest: [10; 32],
        side_terminal_artifact_digest: [11; 32],
        side_proof_artifact_digest: [12; 32],
        opening_artifact_digest: [13; 32],
        linkage_artifact_digest: linkage_claims.digest,
    };
    let mut nightstream = build_rv64im_nightstream_statement_from_final(
        statement.public_statement_digest,
        verifier_context,
        &statement,
        &final_proof,
        linkage_root,
        [0; 32],
    )
    .expect("build nightstream statement");
    nightstream.proof_binding_root = nightstream_proof_binding_root(nightstream.core_digest(), &proof_binding_inputs);

    assert_eq!(nightstream.fold_schedule, statement.folded.fold_schedule);
    assert_eq!(nightstream.semantic_step_count, statement.folded.semantic_step_count);
    assert_eq!(nightstream.chunk_summaries, final_proof.chunk_summaries);
    assert_ne!(nightstream.digest(), [0; 32]);
}

#[test]
fn rv64im_nightstream_round_trips_against_current_public_proof_seam() {
    let fixture = external_fixture("control_flow_jal_skip_ecall");
    verify_fixture(&fixture).expect("verify nightstream proof");
}

#[test]
fn rv64im_nightstream_rejects_tampered_statement_binding_root() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture.statement.proof_binding_root[0] ^= 1;
    let err = verify_fixture(&fixture).expect_err("tampered statement binding must fail");
    assert!(format!("{err}").contains("Nightstream statement"));
}

#[test]
fn rv64im_nightstream_rejects_tampered_statement_verifier_context_with_rebound_binding() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture.statement.verifier_context_digest[0] ^= 1;
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .statement_core_digest = fixture.statement.core_digest();
    fixture.nightstream_proof.side_proof_artifact.bundle.digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .expected_digest();
    rebind_side_artifact_digest(&mut fixture);
    rebind_statement(&mut fixture.statement, &fixture.nightstream_proof);
    let err = verify_fixture(&fixture).expect_err("tampered verifier context must fail");
    assert!(format!("{err}").contains("verifier context"));
}

#[test]
fn rv64im_nightstream_rejects_tampered_statement_public_io_digest_with_rebound_binding() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture.statement.public_io_digest[0] ^= 1;
    rebind_statement(&mut fixture.statement, &fixture.nightstream_proof);
    let err = verify_fixture(&fixture).expect_err("tampered public io digest must fail");
    assert!(format!("{err}").contains("Nightstream statement") || format!("{err}").contains("public IO"));
}

#[test]
fn rv64im_nightstream_rejects_tampered_side_artifact() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture.nightstream_proof.side_proof_artifact.digest[0] ^= 1;
    let err = verify_fixture(&fixture).expect_err("tampered side artifact must fail");
    assert!(format!("{err}").contains("side-proof artifact"));
}

#[test]
fn rv64im_nightstream_rejects_tampered_side_terminal_artifact() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture.nightstream_proof.side_terminal_artifact.digest[0] ^= 1;
    let err = verify_fixture(&fixture).expect_err("tampered side-terminal artifact must fail");
    assert!(
        format!("{err}").contains("side-terminal proof artifact")
            || format!("{err}").contains("verified final seam")
            || format!("{err}").contains("Nightstream statement")
    );
}

#[test]
fn rv64im_nightstream_rejects_tampered_opening_artifact() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture.nightstream_proof.opening_artifact.digest[0] ^= 1;
    rebind_statement(&mut fixture.statement, &fixture.nightstream_proof);
    let err = verify_fixture(&fixture).expect_err("tampered opening artifact must fail");
    assert!(format!("{err}").contains("opening artifact"));
}

#[test]
fn rv64im_nightstream_rejects_opening_artifact_with_tampered_bundle() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture
        .nightstream_proof
        .opening_artifact
        .convergence_artifact
        .digest[0] ^= 1;
    let err = verify_fixture(&fixture).expect_err("opening artifact with a tampered compact artifact must fail");
    assert!(format!("{err}").contains("opening"));
}

#[test]
fn rv64im_nightstream_rejects_opening_artifact_with_tampered_phase0_stage_binding() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture
        .nightstream_proof
        .opening_artifact
        .phase0_stage_proof_bindings
        .stage2_proof_digest[0] ^= 1;
    fixture
        .nightstream_proof
        .opening_artifact
        .phase0_stage_proof_bindings
        .digest = fixture
        .nightstream_proof
        .opening_artifact
        .phase0_stage_proof_bindings
        .expected_digest();
    fixture.nightstream_proof.opening_artifact.digest = fixture.nightstream_proof.opening_artifact.expected_digest();
    rebind_statement(&mut fixture.statement, &fixture.nightstream_proof);

    let err = verify_fixture(&fixture).expect_err("opening artifact with a tampered Phase 0 stage binding must fail");
    assert!(format!("{err}").contains("opening artifact"));
}

#[test]
fn rv64im_nightstream_rejects_rebound_side_root_execution_surface_tamper() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .semantic_rows_digest[0] ^= 1;
    fixture.nightstream_proof.side_proof_artifact.bundle.digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .expected_digest();
    rebind_side_artifact_digest(&mut fixture);
    rebind_statement(&mut fixture.statement, &fixture.nightstream_proof);

    let err = verify_fixture(&fixture).expect_err("side root-execution summary tamper with rebound binding must fail");
    assert!(
        format!("{err}").contains("root-execution surface")
            || format!("{err}").contains("side-terminal")
            || format!("{err}").contains("side-opening relation")
            || format!("{err}").contains("side-claim relation")
    );
}

#[test]
fn rv64im_nightstream_rejects_rebound_side_kernel_opening_surface_tamper() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_opening_bridge
        .bindings_opening_digest[0] ^= 1;
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_opening_bridge
        .digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_opening_bridge
        .expected_digest();
    fixture.nightstream_proof.side_proof_artifact.bundle.digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .expected_digest();
    rebind_side_artifact_digest(&mut fixture);
    rebind_statement(&mut fixture.statement, &fixture.nightstream_proof);

    let err = verify_fixture(&fixture).expect_err("rebound side kernel-opening surface tamper must fail");
    assert!(format!("{err}").contains("kernel-opening proof surface"));
}

#[test]
fn rv64im_nightstream_rejects_rebound_side_kernel_opening_binding_summary_tamper() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_opening_bridge
        .prepared_step_bindings
        .last_binding_digest
        .as_mut()
        .expect("last binding digest")[0] ^= 1;
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_opening_bridge
        .prepared_step_bindings
        .digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_opening_bridge
        .prepared_step_bindings
        .expected_digest();
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_opening_bridge
        .digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_opening_bridge
        .expected_digest();
    fixture.nightstream_proof.side_proof_artifact.bundle.digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .expected_digest();
    rebind_side_artifact_digest(&mut fixture);
    rebind_statement(&mut fixture.statement, &fixture.nightstream_proof);

    let err = verify_fixture(&fixture).expect_err("rebound side kernel-opening binding summary tamper must fail");
    assert!(!format!("{err}").is_empty());
}

#[test]
fn rv64im_nightstream_rejects_rebound_side_kernel_opening_root_lane_summary_tamper() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_opening_bridge
        .root_lane_commitment
        .last_selected_row
        .as_mut()
        .expect("last selected row")
        .value_digest[0] ^= 1;
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_opening_bridge
        .digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_opening_bridge
        .expected_digest();
    fixture.nightstream_proof.side_proof_artifact.bundle.digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .expected_digest();
    rebind_side_artifact_digest(&mut fixture);
    rebind_statement(&mut fixture.statement, &fixture.nightstream_proof);

    let err = verify_fixture(&fixture).expect_err("rebound side kernel-opening root-lane summary tamper must fail");
    assert!(
        format!("{err}").contains("kernel-opening proof surface")
            || format!("{err}").contains("root-lane commitment summary")
    );
}

#[test]
fn rv64im_nightstream_rejects_rebound_side_stage_packages_surface_tamper() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .stage1
        .packaged_digest[0] ^= 1;
    fixture.nightstream_proof.side_proof_artifact.bundle.digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .expected_digest();
    rebind_side_artifact_digest(&mut fixture);
    rebind_statement(&mut fixture.statement, &fixture.nightstream_proof);

    let err = verify_fixture(&fixture).expect_err("rebound side stage-package surface tamper must fail");
    assert!(format!("{err}").contains("stage-package proof surface"));
}

#[test]
fn rv64im_nightstream_rejects_rebound_side_stage_claim_proof_surface_tamper() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .stage_claim_proof_bridge
        .packaged_proof_digest[0] ^= 1;
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .stage_claim_proof_bridge
        .digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .stage_claim_proof_bridge
        .expected_digest();
    fixture.nightstream_proof.side_proof_artifact.bundle.digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .expected_digest();
    rebind_side_artifact_digest(&mut fixture);
    rebind_statement(&mut fixture.statement, &fixture.nightstream_proof);

    let err = verify_fixture(&fixture).expect_err("rebound side stage-claim proof surface tamper must fail");
    assert!(format!("{err}").contains("stage-claim proof surface"));
}

#[test]
fn rv64im_nightstream_rejects_rebound_side_kernel_claim_proof_surface_tamper() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_claim_proof_bridge
        .packaged_proof_digest[0] ^= 1;
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_claim_proof_bridge
        .digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_claim_proof_bridge
        .expected_digest();
    fixture.nightstream_proof.side_proof_artifact.bundle.digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .expected_digest();
    rebind_side_artifact_digest(&mut fixture);
    rebind_statement(&mut fixture.statement, &fixture.nightstream_proof);

    let err = verify_fixture(&fixture).expect_err("rebound side kernel-claim proof surface tamper must fail");
    assert!(format!("{err}").contains("kernel-claim proof surface"));
}

#[test]
fn rv64im_nightstream_rejects_side_kernel_claim_bridge_cross_instance_swap() {
    let mut primary = external_fixture("control_flow_jal_skip_ecall");
    let alternate = external_fixture(&alternate_case_name("control_flow_jal_skip_ecall"));

    primary
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_claim_bridge = alternate
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_claim_bridge
        .clone();
    primary.nightstream_proof.side_proof_artifact.bundle.digest = primary
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .expected_digest();
    rebind_side_artifact_digest(&mut primary);
    rebind_statement(&mut primary.statement, &primary.nightstream_proof);

    let err = verify_fixture(&primary).expect_err("cross-instance kernel-claim bridge swap must fail");
    assert!(format!("{err}").contains("main-lane proof surface") || format!("{err}").contains("kernel-claim surface"));
}

#[test]
fn rv64im_nightstream_rejects_side_kernel_export_bridge_cross_instance_swap() {
    let mut primary = external_fixture("control_flow_jal_skip_ecall");
    let alternate_name = alternate_case_name("control_flow_jal_skip_ecall");
    let alternate = external_fixture(&alternate_name);

    primary
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_export_bridge = alternate
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_export_bridge
        .clone();
    primary.nightstream_proof.side_proof_artifact.bundle.digest = primary
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .expected_digest();
    rebind_side_artifact_digest(&mut primary);
    rebind_statement(&mut primary.statement, &primary.nightstream_proof);

    let err = verify_fixture(&primary).expect_err("cross-instance kernel-export bridge swap must fail");
    assert!(
        format!("{err}").contains("main-lane proof surface")
            || format!("{err}").contains("kernel-claim surface")
            || format!("{err}").contains("root-lane commitment summary")
            || format!("{err}").contains("kernel-export source surface")
    );
}

#[test]
fn rv64im_nightstream_rejects_rebound_side_main_lane_surface_tamper() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_opening_bridge
        .root_lane_commitment
        .first_selected_row
        .as_mut()
        .expect("fixture must carry the first selected row")
        .digest[0] ^= 1;
    fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_opening_bridge
        .digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .kernel_opening_bridge
        .expected_digest();
    fixture.nightstream_proof.side_proof_artifact.bundle.digest = fixture
        .nightstream_proof
        .side_proof_artifact
        .bundle
        .expected_digest();
    rebind_side_artifact_digest(&mut fixture);
    rebind_statement(&mut fixture.statement, &fixture.nightstream_proof);

    let err = verify_fixture(&fixture).expect_err("rebound side main-lane surface tamper must fail");
    assert!(
        format!("{err}").contains("main-lane proof surface")
            || format!("{err}").contains("root-lane commitment summary")
    );
}

#[test]
fn rv64im_nightstream_rejects_tampered_main_decider_proof() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture
        .nightstream_proof
        .main_decider_proof
        .decider_target_digest[0] ^= 1;
    let err = verify_fixture(&fixture).expect_err("tampered main decider proof must fail");
    assert!(format!("{err}").contains("main decider proof"));
}

#[test]
fn rv64im_nightstream_rejects_tampered_main_residual_proof() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture
        .nightstream_proof
        .main_residual_proof
        .decider_relation
        .digest[0] ^= 1;
    let err = verify_fixture(&fixture).expect_err("tampered main residual proof must fail");
    assert!(format!("{err}").contains("main residual proof"));
}

#[test]
fn rv64im_nightstream_rejects_tampered_linkage_artifact() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture.nightstream_proof.linkage_artifact.digest[0] ^= 1;
    let err = verify_fixture(&fixture).expect_err("tampered linkage artifact must fail");
    assert!(format!("{err}").contains("linkage artifact"));
}

#[test]
fn rv64im_nightstream_rejects_tampered_spartan_snark_data() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    tamper_snark_bytes(&mut fixture.decider_proof.snark_data);
    let err = verify_fixture(&fixture).expect_err("tampered Spartan proof bytes must fail");
    assert!(format!("{err}").contains("Spartan proof"));
}

#[test]
fn rv64im_nightstream_rejects_tampered_spartan_shape_digest() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture.decider_proof.shape_digest[0] ^= 1;
    let err = verify_fixture(&fixture).expect_err("tampered Spartan proof shape digest must fail");
    assert!(format!("{err}").contains("Spartan proof"));
}

#[test]
fn rv64im_nightstream_rejects_wrong_spartan_verifier_key_shape() {
    let fixture = external_fixture("control_flow_jal_skip_ecall");
    let target_shape = fixture
        .nightstream_proof
        .main_residual_proof
        .decider_relation
        .target()
        .shape();
    let wrong_shape = Spartan2DeciderShape {
        base_component_count: target_shape.base_component_count + 1,
        chunk_transition_count: target_shape.chunk_transition_count,
    };
    let (_, wrong_vk) = setup_spartan2_decider(&wrong_shape).expect("setup wrong-shape spartan2 decider");
    let err = verify_rv64im_nightstream(
        &fixture.statement,
        &fixture.nightstream_proof,
        fixture.trusted_root_params_id,
        &wrong_vk,
        &fixture.decider_proof,
        &fixture.public_statement,
    )
    .expect_err("wrong Spartan verifier key must fail");
    assert!(format!("{err}").contains("Spartan proof"));
}

#[test]
fn rv64im_nightstream_rejects_public_statement_with_stale_digest() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture.public_statement.final_pc += 1;
    let err = verify_fixture(&fixture).expect_err("stale public statement digest must fail");
    assert!(format!("{err}").contains("public statement"));
}

#[test]
fn rv64im_nightstream_rejects_public_statement_with_recomputed_digest_but_wrong_fields() {
    let mut fixture = external_fixture("control_flow_jal_skip_ecall");
    fixture.public_statement.final_pc += 1;
    fixture.public_statement.digest = fixture.public_statement.recompute_digest();
    let err = verify_fixture(&fixture).expect_err("wrong public statement fields with a recomputed digest must fail");
    assert!(format!("{err}").contains("public statement"));
}

#[test]
fn rv64im_nightstream_rejects_side_opening_cross_instance_swap() {
    let mut primary = external_fixture("control_flow_jal_skip_ecall");
    let alternate_name = alternate_case_name("control_flow_jal_skip_ecall");
    let alternate = external_fixture(&alternate_name);

    primary.nightstream_proof.side_proof_artifact = alternate.nightstream_proof.side_proof_artifact.clone();
    primary.nightstream_proof.opening_artifact = alternate.nightstream_proof.opening_artifact.clone();
    rebind_statement(&mut primary.statement, &primary.nightstream_proof);

    let err = verify_fixture(&primary).expect_err("cross-instance side/opening swap must fail");
    assert!(format!("{err}").contains("side-proof artifact"));
}

#[test]
fn rv64im_nightstream_serde_roundtrips_statement_proof_and_spartan_proof() {
    let fixture = external_fixture("control_flow_jal_skip_ecall");
    assert_eq!(fixture.decider_vk.shape_digest(), fixture.decider_proof.shape_digest);
    assert_bincode_roundtrip(&fixture.statement);
    assert_bincode_roundtrip(&fixture.nightstream_proof);
    assert_bincode_roundtrip(&fixture.decider_proof);
}

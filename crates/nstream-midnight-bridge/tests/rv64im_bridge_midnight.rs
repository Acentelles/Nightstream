use neo_fold_next::nightstream::rv64im::build_rv64im_nightstream_from_public_proof;
use neo_fold_next::proof::FoldSchedule;
use neo_fold_next::rv64im::{parity_source_cases, prove_rv64im_public_proof, Rv64imProofInput};
use nstream_midnight_bridge::rv64im::{
    build_rv64im_nightstream_bridge_preimage, build_rv64im_nightstream_midnight_proof_preimage,
    build_rv64im_nightstream_verifier_ir_v2, check_rv64im_nightstream_verifier_ir_v2,
    decode_rv64im_nightstream_bridge_private_witness_fields, encode_rv64im_nightstream_bridge_private_witness_fields,
    rv64im_nightstream_bridge_binding_input, Rv64imNightstreamBridgePrivateWitness,
    Rv64imNightstreamBridgePublicInputs, RV64IM_NIGHTSTREAM_BRIDGE_KEY_LOCATION,
};
use transient_crypto::curve::Fr;

const DIGEST32_FIELD_WORDS: usize = 5;
const PROOF_BINDING_CLAIM_DIGESTS: usize = 9;

fn private_claim_words(chunk_count: usize) -> usize {
    DIGEST32_FIELD_WORDS
        + DIGEST32_FIELD_WORDS
        + 2
        + (PROOF_BINDING_CLAIM_DIGESTS * DIGEST32_FIELD_WORDS)
        + DIGEST32_FIELD_WORDS
        + DIGEST32_FIELD_WORDS
        + DIGEST32_FIELD_WORDS
        + 1
        + (DIGEST32_FIELD_WORDS * chunk_count)
        + 1
        + (DIGEST32_FIELD_WORDS * chunk_count)
        + 1
        + ((2 * DIGEST32_FIELD_WORDS) * chunk_count)
}

fn first_linkage_public_chunk_digest_offset() -> usize {
    DIGEST32_FIELD_WORDS
        + DIGEST32_FIELD_WORDS
        + 2
        + (PROOF_BINDING_CLAIM_DIGESTS * DIGEST32_FIELD_WORDS)
        + DIGEST32_FIELD_WORDS
        + DIGEST32_FIELD_WORDS
        + DIGEST32_FIELD_WORDS
        + 1
}

fn statement_linkage_root_offset(chunk_count: usize) -> usize {
    private_claim_words(chunk_count) + DIGEST32_FIELD_WORDS + DIGEST32_FIELD_WORDS + 2 + 1 + 1 + (12 * chunk_count)
}

fn statement_proof_binding_root_offset(chunk_count: usize) -> usize {
    statement_linkage_root_offset(chunk_count) + DIGEST32_FIELD_WORDS
}

fn statement_first_chunk_start_index_offset(chunk_count: usize) -> usize {
    private_claim_words(chunk_count) + DIGEST32_FIELD_WORDS + DIGEST32_FIELD_WORDS + 2 + 1 + 1
}

fn statement_first_chunk_relation_digest_offset(chunk_count: usize) -> usize {
    private_claim_words(chunk_count)
        + DIGEST32_FIELD_WORDS
        + DIGEST32_FIELD_WORDS
        + 2
        + 1
        + 1
        + 1
        + 1
        + DIGEST32_FIELD_WORDS
}

fn source_case(name: &str) -> neo_fold_next::rv64im::Rv64imParitySourceCase {
    parity_source_cases()
        .into_iter()
        .find(|case| case.manifest.name == name)
        .unwrap_or_else(|| panic!("missing parity source case {name}"))
}

fn proof_input(name: &str) -> Rv64imProofInput {
    let source = source_case(name);
    let max_steps = source.program_words.len();
    Rv64imProofInput { source, max_steps }
}

#[test]
fn rv64im_bridge_builds_real_midnight_proof_preimage() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (statement, proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    let bridge_preimage = build_rv64im_nightstream_bridge_preimage(
        Rv64imNightstreamBridgePublicInputs::new(&statement),
        Rv64imNightstreamBridgePrivateWitness::new(&statement, &proof, &public_proof),
    )
    .expect("build bridge preimage");
    let midnight_preimage =
        build_rv64im_nightstream_midnight_proof_preimage(&bridge_preimage).expect("build midnight preimage");

    assert_eq!(midnight_preimage.inputs.len(), bridge_preimage.inputs.len());
    assert_eq!(
        midnight_preimage.private_transcript.len(),
        bridge_preimage.private_transcript.len()
    );
    assert_eq!(
        midnight_preimage.binding_input,
        Fr::from(rv64im_nightstream_bridge_binding_input(
            Rv64imNightstreamBridgePublicInputs::new(&statement),
        ))
    );
    assert_eq!(
        midnight_preimage.key_location.0.as_ref(),
        RV64IM_NIGHTSTREAM_BRIDGE_KEY_LOCATION
    );
}

#[test]
fn rv64im_bridge_midnight_verifier_ir_checks_current_preimage() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (statement, proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    let bridge_preimage = build_rv64im_nightstream_bridge_preimage(
        Rv64imNightstreamBridgePublicInputs::new(&statement),
        Rv64imNightstreamBridgePrivateWitness::new(&statement, &proof, &public_proof),
    )
    .expect("build bridge preimage");

    let pi_skips = check_rv64im_nightstream_verifier_ir_v2(&bridge_preimage).expect("check verifier ir");
    assert_eq!(pi_skips, Vec::<Option<usize>>::new());
}

#[test]
fn rv64im_bridge_midnight_verifier_ir_rejects_wrong_version_word() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (statement, proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    let bridge_preimage = build_rv64im_nightstream_bridge_preimage(
        Rv64imNightstreamBridgePublicInputs::new(&statement),
        Rv64imNightstreamBridgePrivateWitness::new(&statement, &proof, &public_proof),
    )
    .expect("build bridge preimage");
    let mut midnight_preimage =
        build_rv64im_nightstream_midnight_proof_preimage(&bridge_preimage).expect("build midnight preimage");
    let ir = build_rv64im_nightstream_verifier_ir_v2(&bridge_preimage).expect("build verifier ir");

    midnight_preimage.inputs[0] = Fr::from(2u64);
    let err = midnight_preimage
        .check(&ir)
        .expect_err("wrong version word must fail verifier ir");
    let msg = format!("{err}");
    assert!(msg.contains("assert") || msg.contains("Assertion"));
}

#[test]
fn rv64im_bridge_midnight_verifier_ir_rejects_tampered_public_digest_word() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (statement, proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    let bridge_preimage = build_rv64im_nightstream_bridge_preimage(
        Rv64imNightstreamBridgePublicInputs::new(&statement),
        Rv64imNightstreamBridgePrivateWitness::new(&statement, &proof, &public_proof),
    )
    .expect("build bridge preimage");
    let mut midnight_preimage =
        build_rv64im_nightstream_midnight_proof_preimage(&bridge_preimage).expect("build midnight preimage");
    let ir = build_rv64im_nightstream_verifier_ir_v2(&bridge_preimage).expect("build verifier ir");

    midnight_preimage.inputs[1] = Fr::from(0u64);
    let err = midnight_preimage
        .check(&ir)
        .expect_err("tampered public digest word must fail verifier ir");
    let msg = format!("{err}");
    assert!(msg.contains("assert") || msg.contains("Assertion"));
}

#[test]
fn rv64im_bridge_midnight_verifier_ir_rejects_tampered_residual_public_statement_digest() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (statement, proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    let bridge_preimage = build_rv64im_nightstream_bridge_preimage(
        Rv64imNightstreamBridgePublicInputs::new(&statement),
        Rv64imNightstreamBridgePrivateWitness::new(&statement, &proof, &public_proof),
    )
    .expect("build bridge preimage");
    let ir = build_rv64im_nightstream_verifier_ir_v2(&bridge_preimage).expect("build verifier ir");
    let mut midnight_preimage =
        build_rv64im_nightstream_midnight_proof_preimage(&bridge_preimage).expect("build midnight preimage");

    let mut private_witness =
        decode_rv64im_nightstream_bridge_private_witness_fields(&bridge_preimage.private_transcript)
            .expect("decode private witness");
    private_witness
        .proof
        .main_residual_proof
        .public_statement_digest[0] ^= 1;
    let tampered_private_words = encode_rv64im_nightstream_bridge_private_witness_fields(private_witness.borrowed())
        .expect("re-encode tampered private witness");
    midnight_preimage.private_transcript = tampered_private_words.into_iter().map(Fr::from).collect();

    let err = midnight_preimage
        .check(&ir)
        .expect_err("tampered residual digest must fail verifier ir");
    let msg = format!("{err}");
    assert!(msg.contains("assert") || msg.contains("Assertion"));
}

#[test]
fn rv64im_bridge_midnight_verifier_ir_rejects_tampered_statement_verifier_context_digest() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (statement, proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    let bridge_preimage = build_rv64im_nightstream_bridge_preimage(
        Rv64imNightstreamBridgePublicInputs::new(&statement),
        Rv64imNightstreamBridgePrivateWitness::new(&statement, &proof, &public_proof),
    )
    .expect("build bridge preimage");
    let ir = build_rv64im_nightstream_verifier_ir_v2(&bridge_preimage).expect("build verifier ir");
    let mut midnight_preimage =
        build_rv64im_nightstream_midnight_proof_preimage(&bridge_preimage).expect("build midnight preimage");

    let mut private_witness =
        decode_rv64im_nightstream_bridge_private_witness_fields(&bridge_preimage.private_transcript)
            .expect("decode private witness");
    private_witness.statement.verifier_context_digest[0] ^= 1;
    let tampered_private_words = encode_rv64im_nightstream_bridge_private_witness_fields(private_witness.borrowed())
        .expect("re-encode tampered private witness");
    midnight_preimage.private_transcript = tampered_private_words.into_iter().map(Fr::from).collect();

    let err = midnight_preimage
        .check(&ir)
        .expect_err("tampered verifier context digest must fail verifier ir");
    let msg = format!("{err}");
    assert!(msg.contains("assert") || msg.contains("Assertion"));
}

#[test]
fn rv64im_bridge_midnight_verifier_ir_rejects_tampered_statement_fold_schedule() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (statement, proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    let bridge_preimage = build_rv64im_nightstream_bridge_preimage(
        Rv64imNightstreamBridgePublicInputs::new(&statement),
        Rv64imNightstreamBridgePrivateWitness::new(&statement, &proof, &public_proof),
    )
    .expect("build bridge preimage");
    let ir = build_rv64im_nightstream_verifier_ir_v2(&bridge_preimage).expect("build verifier ir");
    let mut midnight_preimage =
        build_rv64im_nightstream_midnight_proof_preimage(&bridge_preimage).expect("build midnight preimage");

    let mut private_witness =
        decode_rv64im_nightstream_bridge_private_witness_fields(&bridge_preimage.private_transcript)
            .expect("decode private witness");
    private_witness.statement.fold_schedule = match private_witness.statement.fold_schedule {
        FoldSchedule::WholeTrace => FoldSchedule::RowsPerChunk(1),
        FoldSchedule::RowsPerChunk(rows) => FoldSchedule::RowsPerChunk(rows + 1),
    };
    let tampered_private_words = encode_rv64im_nightstream_bridge_private_witness_fields(private_witness.borrowed())
        .expect("re-encode tampered private witness");
    midnight_preimage.private_transcript = tampered_private_words.into_iter().map(Fr::from).collect();

    let err = midnight_preimage
        .check(&ir)
        .expect_err("tampered fold schedule must fail verifier ir");
    let msg = format!("{err}");
    assert!(msg.contains("assert") || msg.contains("Assertion"));
}

#[test]
fn rv64im_bridge_midnight_verifier_ir_rejects_tampered_linkage_public_chunk_digest() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (statement, proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    let bridge_preimage = build_rv64im_nightstream_bridge_preimage(
        Rv64imNightstreamBridgePublicInputs::new(&statement),
        Rv64imNightstreamBridgePrivateWitness::new(&statement, &proof, &public_proof),
    )
    .expect("build bridge preimage");
    let ir = build_rv64im_nightstream_verifier_ir_v2(&bridge_preimage).expect("build verifier ir");
    let mut midnight_preimage =
        build_rv64im_nightstream_midnight_proof_preimage(&bridge_preimage).expect("build midnight preimage");

    let first_linkage_public_chunk_digest_word = first_linkage_public_chunk_digest_offset();
    midnight_preimage.private_transcript[first_linkage_public_chunk_digest_word] = Fr::from(0u64);

    let err = midnight_preimage
        .check(&ir)
        .expect_err("tampered linkage public chunk digest must fail verifier ir");
    let msg = format!("{err}");
    assert!(msg.contains("assert") || msg.contains("Assertion"));
}

#[test]
fn rv64im_bridge_midnight_verifier_ir_rejects_tampered_statement_proof_binding_root() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (statement, proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    let bridge_preimage = build_rv64im_nightstream_bridge_preimage(
        Rv64imNightstreamBridgePublicInputs::new(&statement),
        Rv64imNightstreamBridgePrivateWitness::new(&statement, &proof, &public_proof),
    )
    .expect("build bridge preimage");
    let ir = build_rv64im_nightstream_verifier_ir_v2(&bridge_preimage).expect("build verifier ir");
    let mut midnight_preimage =
        build_rv64im_nightstream_midnight_proof_preimage(&bridge_preimage).expect("build midnight preimage");

    let proof_binding_root_word = statement_proof_binding_root_offset(statement.chunk_summaries.len());
    midnight_preimage.private_transcript[proof_binding_root_word] = Fr::from(0u64);

    let err = midnight_preimage
        .check(&ir)
        .expect_err("tampered statement proof binding root must fail verifier ir");
    let msg = format!("{err}");
    assert!(msg.contains("assert") || msg.contains("Assertion"));
}

#[test]
fn rv64im_bridge_midnight_verifier_ir_rejects_tampered_statement_linkage_root() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (statement, proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    let bridge_preimage = build_rv64im_nightstream_bridge_preimage(
        Rv64imNightstreamBridgePublicInputs::new(&statement),
        Rv64imNightstreamBridgePrivateWitness::new(&statement, &proof, &public_proof),
    )
    .expect("build bridge preimage");
    let ir = build_rv64im_nightstream_verifier_ir_v2(&bridge_preimage).expect("build verifier ir");
    let mut midnight_preimage =
        build_rv64im_nightstream_midnight_proof_preimage(&bridge_preimage).expect("build midnight preimage");

    let linkage_root_word = statement_linkage_root_offset(statement.chunk_summaries.len());
    midnight_preimage.private_transcript[linkage_root_word] = Fr::from(0u64);

    let err = midnight_preimage
        .check(&ir)
        .expect_err("tampered statement linkage root must fail verifier ir");
    let msg = format!("{err}");
    assert!(msg.contains("assert") || msg.contains("Assertion"));
}

#[test]
fn rv64im_bridge_midnight_verifier_ir_rejects_tampered_statement_chunk_relation_digest() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (statement, proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    let bridge_preimage = build_rv64im_nightstream_bridge_preimage(
        Rv64imNightstreamBridgePublicInputs::new(&statement),
        Rv64imNightstreamBridgePrivateWitness::new(&statement, &proof, &public_proof),
    )
    .expect("build bridge preimage");
    let ir = build_rv64im_nightstream_verifier_ir_v2(&bridge_preimage).expect("build verifier ir");
    let mut midnight_preimage =
        build_rv64im_nightstream_midnight_proof_preimage(&bridge_preimage).expect("build midnight preimage");

    let chunk_relation_digest_word = statement_first_chunk_relation_digest_offset(statement.chunk_summaries.len());
    midnight_preimage.private_transcript[chunk_relation_digest_word] = Fr::from(0u64);

    let err = midnight_preimage
        .check(&ir)
        .expect_err("tampered statement chunk relation digest must fail verifier ir");
    let msg = format!("{err}");
    assert!(msg.contains("assert") || msg.contains("Assertion"));
}

#[test]
fn rv64im_bridge_midnight_verifier_ir_rejects_tampered_statement_chunk_start_index() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (statement, proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    let bridge_preimage = build_rv64im_nightstream_bridge_preimage(
        Rv64imNightstreamBridgePublicInputs::new(&statement),
        Rv64imNightstreamBridgePrivateWitness::new(&statement, &proof, &public_proof),
    )
    .expect("build bridge preimage");
    let ir = build_rv64im_nightstream_verifier_ir_v2(&bridge_preimage).expect("build verifier ir");
    let mut midnight_preimage =
        build_rv64im_nightstream_midnight_proof_preimage(&bridge_preimage).expect("build midnight preimage");

    let start_index_word = statement_first_chunk_start_index_offset(statement.chunk_summaries.len());
    midnight_preimage.private_transcript[start_index_word] = Fr::from(1u64);

    let err = midnight_preimage
        .check(&ir)
        .expect_err("tampered statement chunk start index must fail verifier ir");
    let msg = format!("{err}");
    assert!(msg.contains("assert") || msg.contains("Assertion"));
}

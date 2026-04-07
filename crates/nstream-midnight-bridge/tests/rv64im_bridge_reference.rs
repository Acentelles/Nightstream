use neo_fold_next::nightstream::rv64im::build_rv64im_nightstream_from_public_proof;
use neo_fold_next::nightstream::{nightstream_proof_binding_root, NightstreamProofBindingInputs};
use neo_fold_next::rv64im::{parity_source_cases, prove_rv64im_public_proof, Rv64imProofInput};
use nstream_midnight_bridge::rv64im::{
    verify_rv64im_nightstream_bridge_input, Rv64imNightstreamBridgePrivateWitness, Rv64imNightstreamBridgePublicInputs,
    RV64IM_NIGHTSTREAM_BRIDGE_VERSION,
};

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
fn rv64im_bridge_reference_verifier_accepts_current_nightstream_boundary() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (statement, proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    let public_inputs = Rv64imNightstreamBridgePublicInputs::new(&statement);
    let private_witness = Rv64imNightstreamBridgePrivateWitness {
        statement: &statement,
        proof: &proof,
        proof_complete_transport: &public_proof,
    };
    verify_rv64im_nightstream_bridge_input(public_inputs, private_witness)
        .expect("bridge reference verifier accepts current boundary");
}

#[test]
fn rv64im_bridge_reference_verifier_rejects_wrong_version() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (statement, proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    let public_inputs = Rv64imNightstreamBridgePublicInputs {
        version: RV64IM_NIGHTSTREAM_BRIDGE_VERSION + 1,
        statement_digest: statement.digest(),
    };
    let private_witness = Rv64imNightstreamBridgePrivateWitness {
        statement: &statement,
        proof: &proof,
        proof_complete_transport: &public_proof,
    };
    let err =
        verify_rv64im_nightstream_bridge_input(public_inputs, private_witness).expect_err("wrong version must fail");
    assert!(format!("{err}").contains("unsupported RV64IM Nightstream bridge version"));
}

#[test]
fn rv64im_bridge_reference_verifier_rejects_tampered_public_boundary() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (statement, mut proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    proof.main_decider_proof.decider_target_digest[0] ^= 1;
    let public_inputs = Rv64imNightstreamBridgePublicInputs::new(&statement);
    let private_witness = Rv64imNightstreamBridgePrivateWitness {
        statement: &statement,
        proof: &proof,
        proof_complete_transport: &public_proof,
    };
    let err = verify_rv64im_nightstream_bridge_input(public_inputs, private_witness)
        .expect_err("tampered boundary must fail");
    assert!(format!("{err}").contains("main decider proof"));
}

#[test]
fn rv64im_bridge_reference_verifier_rejects_verifier_context_mismatch() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let public_proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let (mut statement, proof) =
        build_rv64im_nightstream_from_public_proof(&public_proof).expect("build nightstream boundary");

    statement.verifier_context_digest[0] ^= 1;
    let proof_binding_inputs = NightstreamProofBindingInputs {
        main_decider_proof_digest: proof.main_decider_proof.expected_digest(),
        main_residual_proof_digest: proof.main_residual_proof.expected_digest(),
        side_proof_artifact_digest: proof.side_proof_artifact.digest,
        opening_artifact_digest: proof.opening_artifact.digest,
        linkage_artifact_digest: proof.linkage_artifact.digest,
    };
    statement.proof_binding_root = nightstream_proof_binding_root(statement.core_digest(), &proof_binding_inputs);

    let public_inputs = Rv64imNightstreamBridgePublicInputs::new(&statement);
    let private_witness = Rv64imNightstreamBridgePrivateWitness {
        statement: &statement,
        proof: &proof,
        proof_complete_transport: &public_proof,
    };
    let err = verify_rv64im_nightstream_bridge_input(public_inputs, private_witness)
        .expect_err("verifier-context mismatch must fail");
    assert!(format!("{err}").contains("verifier-context digest"));
}

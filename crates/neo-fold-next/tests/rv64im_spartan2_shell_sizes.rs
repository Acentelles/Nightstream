use neo_fold_next::decider::spartan2::{
    prove_spartan2_backend_binding_shell, prove_spartan2_public_relation_shell, prove_spartan2_public_target_shell,
    setup_spartan2_backend_binding_shell, setup_spartan2_public_relation_shell, setup_spartan2_public_target_shell,
    Spartan2BackendBindingShellSnark, Spartan2DeciderProof, Spartan2PublicRelationShellSnark,
    Spartan2PublicTargetShellSnark,
};
use neo_fold_next::nightstream::rv64im::{
    build_rv64im_nightstream_from_public_proof, build_rv64im_side_terminal_decider_target,
    build_rv64im_side_terminal_relation_statement, Rv64imSideTerminalBackendProof,
};
use neo_fold_next::rv64im::final_relation::prove_rv64im_final_statement_from_accepted;
use neo_fold_next::rv64im::{
    build_rv64im_accepted_proof_artifact, build_rv64im_spartan2_decider_target, parity_source_cases,
    prove_rv64im_public_proof, prove_rv64im_spartan2_decider, setup_rv64im_spartan2_decider, Rv64imProofInput,
};
use spartan2::spartan::R1CSSNarkSerializedSizeBreakdown;
use std::fmt::Write as _;

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

fn format_breakdown(label: &str, breakdown: R1CSSNarkSerializedSizeBreakdown) -> String {
    let mut out = String::new();
    let _ = write!(&mut out, "{label}: total={}", breakdown.total);
    for (component, bytes) in breakdown.measured_components() {
        let _ = write!(&mut out, " {component}={bytes}");
    }
    out
}

fn decode_decider_proof(proof: &Spartan2DeciderProof) -> Spartan2PublicRelationShellSnark {
    bincode::deserialize(&proof.snark_data).expect("decode public-relation shell snark")
}

#[test]
fn rv64im_spartan2_shell_size_snapshot() {
    let input = proof_input("control_flow_jal_skip_ecall");
    let proof = prove_rv64im_public_proof(&input).expect("prove rv64im public proof");
    let artifact = build_rv64im_accepted_proof_artifact(&proof).expect("build accepted artifact");
    let (nightstream_statement, nightstream_proof) =
        build_rv64im_nightstream_from_public_proof(&proof).expect("build rv64im nightstream");
    let side_terminal_statement =
        build_rv64im_side_terminal_relation_statement(&proof.statement, &nightstream_proof.side_proof_artifact.bundle)
            .expect("build side-terminal relation");
    let (statement, final_proof) =
        prove_rv64im_final_statement_from_accepted(&artifact).expect("prove rv64im final statement");
    let target = build_rv64im_spartan2_decider_target(&statement, &final_proof).expect("build rv64im decider target");
    let side_terminal_target = build_rv64im_side_terminal_decider_target(
        &nightstream_statement,
        &side_terminal_statement,
        &nightstream_proof.main_residual_proof.bridge_handoff_digests,
    )
    .expect("build side-terminal decider target");

    let shape = target.shape();
    let (public_pk, _) = setup_spartan2_public_target_shell(&shape).expect("setup public-target shell");
    let public_shell = prove_spartan2_public_target_shell(&public_pk, &target).expect("prove public-target shell");
    let (side_terminal_pk, _) = setup_spartan2_public_target_shell(&side_terminal_target.shape())
        .expect("setup side-terminal public-target shell");
    let side_terminal_shell = prove_spartan2_public_target_shell(&side_terminal_pk, &side_terminal_target)
        .expect("prove side-terminal public-target shell");
    let (side_terminal_relation_pk, _) = setup_spartan2_public_relation_shell(&side_terminal_target.shape())
        .expect("setup side-terminal public-relation shell");
    let side_terminal_relation_shell =
        prove_spartan2_public_relation_shell(&side_terminal_relation_pk, &side_terminal_target)
            .expect("prove side-terminal public-relation shell");
    let (side_terminal_backend_pk, _) = setup_spartan2_backend_binding_shell(&side_terminal_target.shape())
        .expect("setup side-terminal backend-binding shell");
    let side_terminal_backend_shell =
        prove_spartan2_backend_binding_shell(&side_terminal_backend_pk, &side_terminal_target.backend_relation())
            .expect("prove side-terminal backend-binding shell");
    let side_terminal_backend_proof = Rv64imSideTerminalBackendProof {
        shape_digest: side_terminal_target.shape().digest(),
        snark_data: side_terminal_backend_shell.snark_data.clone(),
    };

    let (decider_pk, _) = setup_rv64im_spartan2_decider(&statement, &final_proof).expect("setup rv64im decider");
    let decider_proof =
        prove_rv64im_spartan2_decider(&decider_pk, &statement, &final_proof).expect("prove rv64im decider");

    println!(
        "rv64im spartan2 shell size snapshot: base_components={} chunk_transitions={} public_io={} backend_public_io={} public_target_shell={} backend_decider={} side_terminal_base_components={} side_terminal_chunk_transitions={} side_terminal_public_io={} side_terminal_backend_public_io={} side_terminal_public_target_shell={} side_terminal_public_relation_shell={} side_terminal_backend_binding_shell={} side_terminal_backend_proof={}",
        shape.base_component_count,
        shape.chunk_transition_count,
        shape.public_io_len(),
        shape.backend_public_io_len(),
        public_shell.snark_bytes_len(),
        decider_proof.snark_bytes_len(),
        side_terminal_target.shape().base_component_count,
        side_terminal_target.shape().chunk_transition_count,
        side_terminal_target.shape().public_io_len(),
        side_terminal_target.shape().backend_public_io_len(),
        side_terminal_shell.snark_bytes_len(),
        side_terminal_relation_shell.snark_bytes_len(),
        side_terminal_backend_shell.snark_bytes_len(),
        bincode::serialize(&side_terminal_backend_proof)
            .expect("serialize side-terminal backend proof")
            .len(),
    );

    let public_target_snark: Spartan2PublicTargetShellSnark =
        bincode::deserialize(&public_shell.snark_data).expect("decode public-target shell snark");
    let decider_snark = decode_decider_proof(&decider_proof);
    println!(
        "{}",
        format_breakdown(
            "rv64im spartan2 public-target shell breakdown",
            public_target_snark
                .serialized_size_breakdown()
                .expect("measure public-target shell"),
        )
    );
    println!(
        "{}",
        format_breakdown(
            "rv64im spartan2 decider breakdown",
            decider_snark
                .serialized_size_breakdown()
                .expect("measure decider shell"),
        )
    );
    let side_terminal_snark: Spartan2PublicTargetShellSnark =
        bincode::deserialize(&side_terminal_shell.snark_data).expect("decode side-terminal public-target shell snark");
    println!(
        "{}",
        format_breakdown(
            "rv64im side-terminal spartan2 public-target shell breakdown",
            side_terminal_snark
                .serialized_size_breakdown()
                .expect("measure side-terminal public-target shell"),
        )
    );
    let side_terminal_relation_snark: Spartan2PublicRelationShellSnark =
        bincode::deserialize(&side_terminal_relation_shell.snark_data)
            .expect("decode side-terminal public-relation shell snark");
    println!(
        "{}",
        format_breakdown(
            "rv64im side-terminal spartan2 public-relation shell breakdown",
            side_terminal_relation_snark
                .serialized_size_breakdown()
                .expect("measure side-terminal public-relation shell"),
        )
    );
    let side_terminal_backend_snark: Spartan2BackendBindingShellSnark =
        bincode::deserialize(&side_terminal_backend_shell.snark_data)
            .expect("decode side-terminal backend-binding shell snark");
    println!(
        "{}",
        format_breakdown(
            "rv64im side-terminal spartan2 backend-binding shell breakdown",
            side_terminal_backend_snark
                .serialized_size_breakdown()
                .expect("measure side-terminal backend-binding shell"),
        )
    );

    assert!(public_shell.snark_bytes_len() > 0);
    assert!(decider_proof.snark_bytes_len() > 0);
    assert!(side_terminal_shell.snark_bytes_len() > 0);
    assert!(side_terminal_relation_shell.snark_bytes_len() > 0);
    assert!(side_terminal_backend_shell.snark_bytes_len() > 0);
    assert!(side_terminal_backend_proof.snark_bytes_len() > 0);
}

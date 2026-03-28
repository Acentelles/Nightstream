use neo_fold_next::chip8::kernel::{
    build_kernel_execution_digest, verify_kernel_execution_digest, AddressFamily, KernelErrorTerm,
    KernelTranscriptEvent, Stage1ShoutChannel, TwistMemoryFamily, TwistReadFamily,
};
use neo_fold_next::chip8::spec::CommitmentId;
use neo_math::F;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use super::kernel_progress::{
    build_jump_kernel_input, chip8_root_params, make_ajtai_module, prove_simple_kernel, verifier_input_from_public,
    verify_simple_kernel,
};

#[test]
fn simple_kernel_populates_execution_digest() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_execution_digest");
    let (output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");

    let digest = build_kernel_execution_digest(&input.public, &proof, &output).expect("execution digest");
    verify_kernel_execution_digest(&input.public, &proof, &output, &digest).expect("execution digest");

    assert_eq!(digest.trace_surface.frames.len(), proof.meta_pub.semantic_rows);
    assert_eq!(digest.trace_surface.frames[0].step_idx, 0);
    assert_eq!(digest.trace_surface.frames[0].dec.pc_word, input.public.initial_pc_word);
    assert_eq!(digest.trace_surface.frames[0].pre.pc, input.public.initial_pc_word * 2);
    assert_eq!(
        digest.trace_surface.frames[0].kernel_aux.fetch_addr,
        input.public.initial_pc_word as usize
    );
    assert_eq!(
        digest.trace_surface.stage1_digest,
        proof.semantic_evidence_summary.stage1_digest
    );
    assert_eq!(
        digest.trace_surface.stage2_digest,
        proof.semantic_evidence_summary.stage2_digest
    );
    assert_eq!(
        digest.trace_surface.stage3_digest,
        proof.semantic_evidence_summary.stage3_digest
    );
    assert_eq!(digest.export_surface.semantic_rows, proof.meta_pub.semantic_rows);
    assert_eq!(digest.export_surface.prepared_steps.len(), output.prepared_steps.len());
    assert_eq!(
        digest.audit_surface.row_projection_summary,
        output.row_projection_summary
    );
    assert_eq!(
        digest.audit_surface.bridge_binding_summary,
        output.bridge_binding_summary
    );
    assert_eq!(
        digest.manifest_surface.root0_commitment_ids,
        vec![
            CommitmentId::Lane,
            CommitmentId::FetchRa,
            CommitmentId::DecodeRa,
            CommitmentId::AluRa,
            CommitmentId::Eq4Ra,
            CommitmentId::DecodeHandoff,
            CommitmentId::RegTwist,
            CommitmentId::RamTwist,
            CommitmentId::RomTable,
            CommitmentId::DecodeTable,
            CommitmentId::AluTable,
            CommitmentId::Eq4Table,
        ]
    );
    assert_eq!(digest.manifest_surface.kernel_manifest, output.kernel_opening_manifest);
    assert_eq!(digest.manifest_surface.root_manifest, output.root_opening_manifest);
    assert_eq!(
        digest.error_surface.stage1_channels,
        vec![
            Stage1ShoutChannel::Fetch,
            Stage1ShoutChannel::Decode,
            Stage1ShoutChannel::Alu,
            Stage1ShoutChannel::Eq4,
        ]
    );
    assert_eq!(
        digest.error_surface.reg_read_families,
        vec![TwistReadFamily::RegX, TwistReadFamily::RegY, TwistReadFamily::RegI,]
    );
    assert_eq!(
        digest.error_surface.twist_memory_families,
        vec![TwistMemoryFamily::Reg, TwistMemoryFamily::Ram]
    );
    assert_eq!(
        digest.error_surface.stage1_terms,
        vec![
            KernelErrorTerm::ShoutCore(Stage1ShoutChannel::Fetch),
            KernelErrorTerm::ShoutCore(Stage1ShoutChannel::Decode),
            KernelErrorTerm::ShoutCore(Stage1ShoutChannel::Alu),
            KernelErrorTerm::ShoutCore(Stage1ShoutChannel::Eq4),
            KernelErrorTerm::Addr(AddressFamily::Fetch),
            KernelErrorTerm::Addr(AddressFamily::Decode),
            KernelErrorTerm::Addr(AddressFamily::Alu),
            KernelErrorTerm::Addr(AddressFamily::Eq4),
        ]
    );
    assert_eq!(
        digest.error_surface.tail_terms,
        vec![KernelErrorTerm::Pcs, KernelErrorTerm::Fs, KernelErrorTerm::Outer]
    );
    assert!(digest.error_surface.digest.iter().any(|&byte| byte != 0));
    assert_eq!(
        digest.transcript_surface.events.first(),
        Some(&KernelTranscriptEvent::AbsorbCommitment(CommitmentId::Lane))
    );
    assert_eq!(
        digest.transcript_surface.events.get(12),
        Some(&KernelTranscriptEvent::AbsorbMetaPub)
    );
    assert_eq!(
        &digest.transcript_surface.events[55..57],
        &[
            KernelTranscriptEvent::RowBinding(0),
            KernelTranscriptEvent::RowBinding(1)
        ]
    );
    assert_eq!(
        digest.transcript_surface.events.last(),
        Some(&KernelTranscriptEvent::EmitKernelOpeningClaims)
    );
    assert_eq!(digest.transcript_surface.events.len(), 58);
    assert!(digest.digest32().iter().any(|&byte| byte != 0));
}

#[test]
fn simple_kernel_execution_digest_matches_verifier_reconstruction() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_execution_digest_reconstruction");
    let (prover_output, proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_execution_digest_reconstruction");
    let verifier_output =
        verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript).expect("verification");

    let prover_artifact =
        build_kernel_execution_digest(&input.public, &proof, &prover_output).expect("prover execution digest");
    let verifier_artifact =
        build_kernel_execution_digest(&input.public, &proof, &verifier_output).expect("verifier execution digest");

    assert_eq!(prover_artifact, verifier_artifact);
}

#[test]
fn simple_kernel_transcript_matches_verifier_reconstruction() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_transcript_reconstruction");
    let (_prover_output, proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");
    let prove_digest = prove_transcript.digest32();

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_transcript_reconstruction");
    verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript).expect("verification");
    let verify_digest = verify_transcript.digest32();

    assert_eq!(prove_digest, verify_digest);
}

#[test]
fn simple_kernel_execution_digest_rejects_tampered_transcript_surface() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_execution_digest_transcript_tamper");
    let (output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");

    let mut digest = build_kernel_execution_digest(&input.public, &proof, &output).expect("execution digest");
    digest.transcript_surface.events.pop();

    let err = verify_kernel_execution_digest(&input.public, &proof, &output, &digest).expect_err("tamper");
    assert!(err.contains("execution digest"));
}

#[test]
fn simple_kernel_execution_digest_rejects_tampered_manifest_surface() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_execution_digest_manifest_tamper");
    let (output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");

    let mut digest = build_kernel_execution_digest(&input.public, &proof, &output).expect("execution digest");
    digest.manifest_surface.kernel_manifest.claims[0].commitment_id = CommitmentId::RootProver(7);

    let err = verify_kernel_execution_digest(&input.public, &proof, &output, &digest).expect_err("tamper");
    assert!(err.contains("execution digest"));
}

#[test]
fn simple_kernel_execution_digest_rejects_tampered_error_surface() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_execution_digest_error_tamper");
    let (output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");

    let mut digest = build_kernel_execution_digest(&input.public, &proof, &output).expect("execution digest");
    digest.error_surface.batch_terms.swap(0, 1);

    let err = verify_kernel_execution_digest(&input.public, &proof, &output, &digest).expect_err("tamper");
    assert!(err.contains("execution digest"));
}

#[test]
fn simple_kernel_execution_digest_rejects_prepared_step_output_drift() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript =
        Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_execution_digest_prepared_step_drift");
    let (mut output, proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");

    output.prepared_steps[0].witness.w[0] += F::ONE;

    let err = build_kernel_execution_digest(&input.public, &proof, &output).expect_err("prepared step drift");
    assert!(err.to_string().contains("prepared step"));
}

//! Focused tests for the live RV64IM simple-kernel proof boundary.

use neo_fold_next::rv64im::{
    parity_source_cases, prepared_step_digest, prove_packaged_simple_kernel, prove_simple_kernel,
    verify_packaged_simple_kernel, verify_simple_kernel, SimpleKernelProverInput, SimpleKernelPublicInput,
    SimpleKernelVerifierInput,
};
use p3_field::PrimeCharacteristicRing;

fn source_case(name: &str) -> neo_fold_next::rv64im::Rv64imParitySourceCase {
    parity_source_cases()
        .into_iter()
        .find(|case| case.manifest.name == name)
        .unwrap_or_else(|| panic!("missing parity source case {name}"))
}

fn public_input(name: &str) -> SimpleKernelPublicInput {
    let source = source_case(name);
    let max_steps = source.program_words.len();
    SimpleKernelPublicInput { source, max_steps }
}

fn same_public_step(lhs: &neo_fold_next::proof::PublicStep, rhs: &neo_fold_next::proof::PublicStep) -> bool {
    lhs.label == rhs.label
        && lhs.mcs.m_in == rhs.mcs.m_in
        && lhs.mcs.x == rhs.mcs.x
        && lhs.mcs.c.d == rhs.mcs.c.d
        && lhs.mcs.c.kappa == rhs.mcs.c.kappa
        && lhs.mcs.c.data == rhs.mcs.c.data
}

#[test]
fn simple_kernel_roundtrip_exports_one_prepared_step_per_execution_row() {
    let public = public_input("vertical_add_sd_ld_ecall");
    let prover = SimpleKernelProverInput { public: public.clone() };
    let verifier = SimpleKernelVerifierInput { public };

    let (output, proof) = prove_simple_kernel(&prover).expect("prove simple kernel");
    let verified = verify_simple_kernel(&verifier, &proof).expect("verify simple kernel");

    assert_eq!(proof.trace, output.trace);
    assert_eq!(proof.stages, output.stages);
    assert_eq!(proof.stage_claims, output.stage_claims);
    assert_eq!(proof.stage_packages.digest, output.stage_packages.digest);
    assert_eq!(proof.kernel_claims, output.kernel_claims);
    assert_eq!(verified.trace, output.trace);
    assert_eq!(verified.stages, output.stages);
    assert_eq!(verified.stage_claims, output.stage_claims);
    assert_eq!(verified.stage_packages.digest, output.stage_packages.digest);
    assert_eq!(verified.kernel_claims, output.kernel_claims);
    assert_eq!(output.prepared_steps.len(), output.trace.execution_rows.len());
    assert_eq!(output.public_steps.len(), output.prepared_steps.len());
    assert_eq!(
        output.kernel_claims.prepared_step_bindings.bindings.len(),
        output.prepared_steps.len()
    );

    for ((row, step), binding) in output
        .trace
        .execution_rows
        .iter()
        .zip(output.prepared_steps.iter())
        .zip(output.kernel_claims.prepared_step_bindings.bindings.iter())
    {
        assert_eq!(binding.trace_index, row.trace_index);
        assert_eq!(binding.prepared_step_digest, prepared_step_digest(step));
        assert_ne!(binding.row_digest, [0; 32]);
        assert!(same_public_step(
            &step.instance(),
            &output.public_steps[row.trace_index]
        ));
    }

    assert_eq!(
        output.stage_claims.stage1.claim.row_count,
        output.stages.stage1.rows.len()
    );
    assert_eq!(
        output.stage_claims.stage2.claim.register_read_count,
        output.stages.stage2.register_reads.len()
    );
    assert_eq!(
        output.stage_claims.stage2.claim.register_write_count,
        output.stages.stage2.register_writes.len()
    );
    assert_eq!(
        output.stage_claims.stage2.claim.ram_event_count,
        output.stages.stage2.ram_events.len()
    );
    assert_eq!(
        output.stage_claims.stage2.claim.twist_link_count,
        output.stages.stage2.twist_links.len()
    );
    assert_eq!(
        output.stage_claims.stage3.claim.continuity_count,
        output.stages.stage3.continuity.len()
    );
    assert_eq!(
        output.stage_claims.transcript.claim.event_count,
        output.stages.transcript.events.len()
    );
    assert!(output
        .stages
        .stage3
        .continuity
        .iter()
        .all(|event| event.continuity_holds));
    assert!(output.stage_claims.stage3.claim.all_continuity_hold);
    assert_ne!(output.stage_claims.stage1.commitment.digest, [0; 32]);
    assert_ne!(output.stage_claims.stage1.opening_manifest.digest, [0; 32]);
    assert_ne!(output.stage_claims.stage1.opening_proof.digest, [0; 32]);
    assert_ne!(output.stage_claims.stage2.commitment.digest, [0; 32]);
    assert_ne!(output.stage_claims.stage2.opening_manifest.digest, [0; 32]);
    assert_ne!(output.stage_claims.stage2.opening_proof.digest, [0; 32]);
    assert_ne!(output.stage_claims.stage3.commitment.digest, [0; 32]);
    assert_ne!(output.stage_claims.stage3.opening_manifest.digest, [0; 32]);
    assert_ne!(output.stage_claims.stage3.opening_proof.digest, [0; 32]);
    assert_ne!(output.stage_claims.digest, [0; 32]);
    assert_ne!(output.stage_packages.stage1.digest, [0; 32]);
    assert_ne!(output.stage_packages.stage2.digest, [0; 32]);
    assert_ne!(output.stage_packages.stage3.digest, [0; 32]);
    assert_ne!(output.stage_packages.digest, [0; 32]);
}

#[test]
fn simple_kernel_packaged_roundtrip_matches_exported_public_steps() {
    let public = public_input("multiply_high_mulh_mulhu_mulhsu_ecall");
    let prover = SimpleKernelProverInput { public: public.clone() };
    let verifier = SimpleKernelVerifierInput { public };

    let (output, packaged) = prove_packaged_simple_kernel(&prover).expect("prove packaged simple kernel");
    let verified = verify_packaged_simple_kernel(&verifier, &packaged).expect("verify packaged simple kernel");

    assert_eq!(verified.trace, output.trace);
    assert_eq!(verified.stages, output.stages);
    assert_eq!(verified.stage_claims, output.stage_claims);
    assert_eq!(verified.stage_packages.digest, output.stage_packages.digest);
    assert_eq!(verified.kernel_claims, output.kernel_claims);
    assert_eq!(packaged.main_lane.statement.steps.len(), output.public_steps.len());
    assert!(packaged
        .main_lane
        .statement
        .steps
        .iter()
        .zip(output.public_steps.iter())
        .all(|(lhs, rhs)| same_public_step(lhs, rhs)));
    assert_eq!(output.public_steps.len(), output.trace.execution_rows.len());
    assert!(output
        .trace
        .execution_rows
        .iter()
        .any(|row| row.trace_virtual_opcode.is_some()));
}

#[test]
fn simple_kernel_rejects_tampered_kernel_and_packaged_boundaries() {
    let public = public_input("unsigned_divrem_chain_ecall");
    let prover = SimpleKernelProverInput { public: public.clone() };
    let verifier = SimpleKernelVerifierInput { public };

    let (_output, proof) = prove_simple_kernel(&prover).expect("prove simple kernel");
    let mut tampered_kernel = proof.clone();
    tampered_kernel.trace.execution_rows[0].is_commit_row = !tampered_kernel.trace.execution_rows[0].is_commit_row;
    assert!(verify_simple_kernel(&verifier, &tampered_kernel).is_err());

    let mut tampered_stage_claims = proof.clone();
    tampered_stage_claims.stage_claims.stage1.claim.row_count += 1;
    assert!(verify_simple_kernel(&verifier, &tampered_stage_claims).is_err());

    let mut tampered_stage_opening = proof.clone();
    tampered_stage_opening
        .stage_claims
        .stage1
        .opening_proof
        .opening
        .logical_values[0] += neo_math::F::ONE;
    let opening_error = verify_simple_kernel(&verifier, &tampered_stage_opening).expect_err("tampered stage opening");
    assert!(opening_error.to_string().contains("stage1 exact opening"));

    let mut tampered_stage_package = proof.clone();
    tampered_stage_package
        .stage_packages
        .stage1
        .exact_opening_proof_digest[0] ^= 1;
    assert!(verify_simple_kernel(&verifier, &tampered_stage_package).is_err());

    let (_output, packaged) = prove_packaged_simple_kernel(&prover).expect("prove packaged simple kernel");
    let mut tampered_packaged = packaged.clone();
    tampered_packaged.main_lane.statement.steps[0]
        .label
        .push_str("/tampered");
    assert!(verify_packaged_simple_kernel(&verifier, &tampered_packaged).is_err());
}

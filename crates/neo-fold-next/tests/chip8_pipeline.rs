use std::sync::Arc;

use neo_ajtai::{s_lincomb, s_mul, setup as ajtai_setup, AjtaiSModule, Commitment};
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::Mat;
use neo_fold_next::chip8::{build_row_extension_trace, Chip8TraceBuilder};
use neo_fold_next::chip8::{Chip8Program, Chip8State, Chip8VmSpec, WITNESS_WIDTH};
use neo_fold_next::families::compiler::lower_vm_spec;
use neo_fold_next::families::{prove_chip8_extensions, session_step_points, verify_chip8_extensions};
use neo_fold_next::pipeline::{prove_chip8_program, verify_chip8_program};
use neo_fold_next::proof::{OpeningSource, SessionExtensionAccumulator};
use neo_fold_next::prover::CommitmentMixers;
use neo_fold_next::stages::{planner::plan_vm, ChunkModel};
use neo_fold_next::vm::VmSpec;
use neo_math::ring::Rq as RqEl;
use neo_math::{D, F, K};
use neo_params::NeoParams;
use neo_reductions::api::FoldingMode;
use p3_field::PrimeCharacteristicRing;
use rand_chacha::rand_core::SeedableRng;
use rand_chacha::ChaCha8Rng;

struct ToyModule;

impl SModuleHomomorphism<F, Commitment> for ToyModule {
    fn commit(&self, z: &Mat<F>) -> Commitment {
        let mut out = Commitment::zeros(z.rows(), 1);
        for r in 0..z.rows() {
            let mut acc = F::ZERO;
            for c in 0..z.cols() {
                acc += z[(r, c)];
            }
            out.data[r] = acc;
        }
        out
    }

    fn project_x(&self, z: &Mat<F>, min: usize) -> Mat<F> {
        let cols = min.min(z.cols());
        let mut out = Mat::zero(z.rows(), cols, F::ZERO);
        for r in 0..z.rows() {
            for c in 0..cols {
                out[(r, c)] = z[(r, c)];
            }
        }
        out
    }
}

fn chip8_program() -> Chip8Program {
    Chip8Program::from_opcodes(&[
        0x6003, // LD V0, 0x03
        0x6105, // LD V1, 0x05
        0x8014, // ADD V0, V1 => V0 = 8
        0x3008, // SE V0, 0x08 => skip next
        0x6000, // skipped
        0xA300, // LD I, 0x300
        0xF155, // LD [I], V0..V1
        0x6000, // LD V0, 0
        0x6100, // LD V1, 0
        0xF165, // LD V0..V1, [I]
    ])
}

fn chip8_extension_accumulator(
    program: &Chip8Program,
    initial_state: &Chip8State,
    step_count: usize,
) -> SessionExtensionAccumulator {
    let execution =
        Chip8TraceBuilder::<()>::execute_program(program, initial_state, step_count).expect("execution trace");
    let mut acc = SessionExtensionAccumulator::default();
    for step in &execution {
        for row in build_row_extension_trace(step) {
            acc.push(row);
        }
    }
    acc
}

fn chip8_extension_step_points(program: &Chip8Program, initial_state: &Chip8State, step_count: usize) -> Vec<Vec<K>> {
    let vm = Chip8VmSpec::new().expect("vm");
    let params = chip8_params(&vm);
    let log = make_ajtai_module(&params, 1);
    let artifacts = prove_chip8_program(
        FoldingMode::Optimized,
        &params,
        &vm,
        program,
        initial_state,
        step_count,
        &log,
        ajtai_mixers(),
    )
    .expect("prove chip8 program for step points");
    session_step_points(&artifacts.proof.proof.session).expect("session step points")
}

fn rot_matrix_to_rq(mat: &Mat<F>) -> RqEl {
    use neo_math::ring::cf_inv;

    let mut coeffs = [F::ZERO; D];
    for i in 0..D {
        coeffs[i] = mat[(i, 0)];
    }
    cf_inv(coeffs)
}

fn ajtai_mixers() -> CommitmentMixers<fn(&[Mat<F>], &[Commitment]) -> Commitment, fn(&[Commitment], u32) -> Commitment>
{
    fn mix_rhos_commits(rhos: &[Mat<F>], cs: &[Commitment]) -> Commitment {
        let rq_els: Vec<RqEl> = rhos.iter().map(rot_matrix_to_rq).collect();
        s_lincomb(&rq_els, cs).expect("Ajtai S-linear combination should succeed")
    }

    fn combine_b_pows(cs: &[Commitment], b: u32) -> Commitment {
        let mut acc = cs[0].clone();
        let mut pow = F::from_u64(b as u64);
        for c in cs.iter().skip(1) {
            let rq_pow = RqEl::from_field_scalar(pow);
            let term = s_mul(&rq_pow, c);
            acc.add_inplace(&term);
            pow *= F::from_u64(b as u64);
        }
        acc
    }

    CommitmentMixers {
        mix_rhos_commits,
        combine_b_pows,
    }
}

fn make_ajtai_module(params: &NeoParams, witness_cols: usize) -> AjtaiSModule {
    let mut rng = ChaCha8Rng::seed_from_u64(4242);
    let pp = ajtai_setup(&mut rng, D, params.kappa as usize, witness_cols).expect("Ajtai setup");
    AjtaiSModule::new(Arc::new(pp))
}

fn chip8_params(vm: &Chip8VmSpec) -> NeoParams {
    let mut params = NeoParams::goldilocks_auto_r1cs_ccs(vm.core_ccs_spec().structure.n).expect("params");
    params.k_rho = 16;
    params.B = 1 << 16;
    params
}

#[test]
fn chip8_vm_spec_lowers_into_a_stage_plan() {
    let vm = Chip8VmSpec::new().expect("vm");
    let lowered = lower_vm_spec(&vm);
    let plan = plan_vm(&lowered, ChunkModel::CompatibilityPerCpuStep);

    assert_eq!(vm.name(), "chip8");
    assert_eq!(lowered.vm_name, "chip8");
    assert_eq!(lowered.witness_width, WITNESS_WIDTH);
    assert!(vm.core_ccs_spec().witness_width <= 54);
    assert_eq!(plan.stages.len(), 7);
    assert_eq!(plan.stages[1].label, "readonly_batch");
    assert_eq!(plan.stages[1].families.len(), 1);
    assert_eq!(plan.stages[2].families.len(), 1);
    assert_eq!(plan.stages[3].families.len(), 1);
}

#[test]
fn chip8_trace_builder_emits_shared_step_builds() {
    let vm = Chip8VmSpec::new().expect("vm");
    let program = chip8_program();
    let initial_state = Chip8State::with_program(&program).expect("initial state");
    let builder = Chip8TraceBuilder::new(&ToyModule);
    let steps = builder
        .build_program(&vm, &program, &initial_state, 4)
        .expect("build steps");

    assert_eq!(steps.len(), 4);
    assert_eq!(steps[0].prepared.mcs.m_in, 1);
    assert_eq!(steps[0].prepared.witness.Z.cols(), 1);
    assert_eq!(steps[0].prepared.deferred_extensions.len(), 2);
    assert_eq!(steps[1].extension_data.register_writes.len(), 1);
    assert_eq!(steps[2].extension_data.register_reads.len(), 2);
    assert_eq!(
        steps[3]
            .extension_data
            .bytecode_fetch
            .as_ref()
            .map(|r| r.opcode),
        Some(0x3008)
    );
}

#[test]
fn chip8_program_proves_through_the_compatibility_pipeline() {
    let vm = Chip8VmSpec::new().expect("vm");
    let program = chip8_program();
    let initial_state = Chip8State::with_program(&program).expect("initial state");
    let params = chip8_params(&vm);
    let log = make_ajtai_module(&params, 1);

    let artifacts = prove_chip8_program(
        FoldingMode::Optimized,
        &params,
        &vm,
        &program,
        &initial_state,
        9,
        &log,
        ajtai_mixers(),
    )
    .expect("prove chip8 program");

    assert_eq!(artifacts.lowered_plan.vm_name, "chip8");
    assert!(artifacts.bridge_view.compatibility_path);
    assert_eq!(artifacts.bridge_view.prepared_step_count, 11);
    assert_eq!(artifacts.proof.proof.session.steps.len(), 11);
    assert!(artifacts.proof.proof.extensions.bytecode_fetch.is_some());
    assert!(artifacts.proof.proof.extensions.register_history.is_some());
    assert!(artifacts.proof.proof.extensions.ram_history.is_some());
    assert!(artifacts.proof.proof.time_opening.is_some());
    let bytecode_point = artifacts
        .proof
        .proof
        .extensions
        .bytecode_fetch
        .as_ref()
        .expect("bytecode fetch proof")
        .point
        .clone();
    let register_point = artifacts
        .proof
        .proof
        .extensions
        .register_history
        .as_ref()
        .expect("register history proof")
        .point
        .clone();
    let ram_point = artifacts
        .proof
        .proof
        .extensions
        .ram_history
        .as_ref()
        .expect("ram history proof")
        .point
        .clone();
    for claim in artifacts.proof.proof.extensions.opening_claims.iter() {
        let expected = match claim.source {
            OpeningSource::BytecodeFetch => &bytecode_point,
            OpeningSource::RegisterHistory => &register_point,
            OpeningSource::RamHistory => &ram_point,
            OpeningSource::MainLane => panic!("extension opening claims should not contain main-lane entries"),
        };
        assert_eq!(&claim.point, expected);
    }
    assert_ne!(bytecode_point, register_point);
    assert_ne!(register_point, ram_point);
    assert_ne!(bytecode_point, ram_point);

    let verified = verify_chip8_program(
        FoldingMode::Optimized,
        &params,
        &vm,
        &program,
        &initial_state,
        9,
        &artifacts.proof,
        ajtai_mixers(),
    )
    .expect("verify chip8 program");
    assert_eq!(verified, artifacts.proof.statement.final_main_claims);
}

#[test]
fn chip8_pipeline_rejects_tampered_bytecode_fetch_digest() {
    let vm = Chip8VmSpec::new().expect("vm");
    let program = chip8_program();
    let initial_state = Chip8State::with_program(&program).expect("initial state");
    let params = chip8_params(&vm);
    let log = make_ajtai_module(&params, 1);

    let mut artifacts = prove_chip8_program(
        FoldingMode::Optimized,
        &params,
        &vm,
        &program,
        &initial_state,
        9,
        &log,
        ajtai_mixers(),
    )
    .expect("prove chip8 program");

    artifacts
        .proof
        .proof
        .extensions
        .bytecode_fetch
        .as_mut()
        .expect("bytecode proof")
        .digest[0] ^= 1;

    let err = verify_chip8_program(
        FoldingMode::Optimized,
        &params,
        &vm,
        &program,
        &initial_state,
        9,
        &artifacts.proof,
        ajtai_mixers(),
    )
    .expect_err("tampered bytecode proof must fail");
    assert!(format!("{err}").contains("bytecode-fetch"));
}

#[test]
fn chip8_extensions_reject_tampered_register_transcript() {
    let program = chip8_program();
    let initial_state = Chip8State::with_program(&program).expect("initial state");
    let acc = chip8_extension_accumulator(&program, &initial_state, 9);
    let step_points = chip8_extension_step_points(&program, &initial_state, 9);
    let proofs = prove_chip8_extensions(&program, &initial_state, &acc, &step_points).expect("extension proofs");
    let mut tampered = acc.clone();
    tampered.steps[2].register_reads[0].value ^= 1;

    let err = verify_chip8_extensions(&program, &initial_state, &tampered, &step_points, &proofs)
        .expect_err("tampered register transcript must fail");
    assert!(format!("{err}").contains("register-history"));
}

#[test]
fn chip8_extensions_reject_tampered_ram_transcript() {
    let program = chip8_program();
    let initial_state = Chip8State::with_program(&program).expect("initial state");
    let acc = chip8_extension_accumulator(&program, &initial_state, 9);
    let step_points = chip8_extension_step_points(&program, &initial_state, 9);
    let proofs = prove_chip8_extensions(&program, &initial_state, &acc, &step_points).expect("extension proofs");
    let mut tampered = acc.clone();
    tampered.steps[9].ram_reads[0].value ^= 1;

    let err = verify_chip8_extensions(&program, &initial_state, &tampered, &step_points, &proofs)
        .expect_err("tampered RAM transcript must fail");
    assert!(format!("{err}").contains("ram-history"));
}

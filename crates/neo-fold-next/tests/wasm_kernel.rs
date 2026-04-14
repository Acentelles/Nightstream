use neo_ajtai::Commitment;
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::Mat;
use neo_fold_next::proof::FoldSchedule;
use neo_fold_next::prover::CommitmentMixers;
use neo_fold_next::wasm::{
    build_pc_rom_from_binary, collect_wasmtime_steps, prove_kernel_run, prove_simple_kernel,
    traces_from_wasmtime_steps, verify_kernel_run, verify_simple_kernel, WasmKernelProverInput, WasmKernelPublicInput,
    WasmKernelVerifierInput,
};
use neo_math::F;
use neo_params::NeoParams;
use neo_reductions::api::FoldingMode;
use p3_field::PrimeCharacteristicRing;

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

fn add_commitments(lhs: &Commitment, rhs: &Commitment) -> Commitment {
    let mut out = lhs.clone();
    out.add_inplace(rhs);
    out
}

fn scale_commitment_by_rho(rho: &Mat<F>, c: &Commitment) -> Commitment {
    let mut out = Commitment::zeros(c.d, c.kappa);
    for col in 0..c.kappa {
        for r in 0..c.d {
            let mut acc = F::ZERO;
            for k in 0..c.d {
                acc += rho[(r, k)] * c.col(col)[k];
            }
            out.col_mut(col)[r] = acc;
        }
    }
    out
}

fn mix_rhos_commits(rhos: &[Mat<F>], cs: &[Commitment]) -> Commitment {
    let mut acc = Commitment::zeros(cs[0].d, cs[0].kappa);
    for (rho, c) in rhos.iter().zip(cs.iter()) {
        acc = add_commitments(&acc, &scale_commitment_by_rho(rho, c));
    }
    acc
}

fn combine_b_pows(cs: &[Commitment], b: u32) -> Commitment {
    let mut acc = Commitment::zeros(cs[0].d, cs[0].kappa);
    let mut pow = F::ONE;
    let base = F::from_u64(b as u64);
    for c in cs {
        let mut term = c.clone();
        for value in &mut term.data {
            *value *= pow;
        }
        acc = add_commitments(&acc, &term);
        pow *= base;
    }
    acc
}

fn mixers() -> CommitmentMixers<fn(&[Mat<F>], &[Commitment]) -> Commitment, fn(&[Commitment], u32) -> Commitment> {
    CommitmentMixers {
        mix_rhos_commits,
        combine_b_pows,
    }
}

/// Compile a WAT module, run it through the wasmtime adapter, and return (wasm_bytes, trace, pc_rom).
fn compile_and_trace(wat_src: &str) -> (Vec<u8>, Vec<neo_fold_next::wasm::WasmStepTrace>, Vec<(u64, u64)>) {
    let wasm = wat::parse_str(wat_src).expect("valid WAT");
    let run = collect_wasmtime_steps(&wasm, "main").expect("wasmtime trace");
    let trace = traces_from_wasmtime_steps(&run.steps).expect("normalize trace");
    let pc_rom = build_pc_rom_from_binary(&wasm).expect("pc rom");
    (wasm, trace, pc_rom)
}

#[test]
fn wasm_kernel_roundtrip() {
    let (_, trace, pc_rom) = compile_and_trace(
        r#"(module (func (export "main") (result i32)
             i32.const 7
             i32.const 9
             i32.eq))"#,
    );
    let log = ToyModule;
    let public = WasmKernelPublicInput {
        transcript_seed: b"wasm-kernel".to_vec(),
    };
    let prover_input = WasmKernelProverInput {
        public: public.clone(),
        trace: &trace,
        pc_rom: pc_rom.clone(),
    };
    let (output, proof) = prove_simple_kernel(&prover_input, &log).expect("prove");

    let verifier_input = WasmKernelVerifierInput {
        public,
        trace: &trace,
        pc_rom,
    };
    let verified = verify_simple_kernel(&verifier_input, &log, &proof).expect("verify");
    assert_eq!(output.public_steps.len(), trace.len());
    assert_eq!(verified.public_steps.len(), trace.len());
    assert_eq!(verified.public_steps.len(), output.public_steps.len());
    assert_eq!(verified.opening_summary, output.opening_summary);
}

#[test]
fn wasm_kernel_rejects_tampered_stage2() {
    let (_, trace, pc_rom) = compile_and_trace(
        r#"(module (func (export "main") (result i32)
             i32.const 7))"#,
    );
    let log = ToyModule;
    let public = WasmKernelPublicInput {
        transcript_seed: b"wasm-kernel".to_vec(),
    };
    let prover_input = WasmKernelProverInput {
        public: public.clone(),
        trace: &trace,
        pc_rom: pc_rom.clone(),
    };
    let (_, mut proof) = prove_simple_kernel(&prover_input, &log).expect("prove");
    proof.stage2.value_from_inc_claim += neo_math::K::ONE;

    let verifier_input = WasmKernelVerifierInput {
        public,
        trace: &trace,
        pc_rom,
    };
    let err = verify_simple_kernel(&verifier_input, &log, &proof)
        .err()
        .expect("tampered stage2 must fail");
    assert!(format!("{err}").contains("stage2"));
}

#[test]
fn wasm_kernel_rejects_wrong_stage1_order() {
    let (_, trace, pc_rom) = compile_and_trace(
        r#"(module (func (export "main") (result i32)
             i32.const 0
             i32.eqz))"#,
    );
    let log = ToyModule;
    let public = WasmKernelPublicInput {
        transcript_seed: b"wasm-kernel".to_vec(),
    };
    let prover_input = WasmKernelProverInput {
        public: public.clone(),
        trace: &trace,
        pc_rom: pc_rom.clone(),
    };
    let (_, mut proof) = prove_simple_kernel(&prover_input, &log).expect("prove");
    proof.stage1.binary.reverse();

    let verifier_input = WasmKernelVerifierInput {
        public,
        trace: &trace,
        pc_rom,
    };
    let err = verify_simple_kernel(&verifier_input, &log, &proof)
        .err()
        .expect("wrong order must fail");
    assert!(format!("{err}").contains("stage1"));
}

#[test]
fn wasm_kernel_rejects_tampered_opening_summary() {
    let (_, trace, pc_rom) = compile_and_trace(
        r#"(module (func (export "main") (result i32)
             i32.const 7))"#,
    );
    let log = ToyModule;
    let public = WasmKernelPublicInput {
        transcript_seed: b"wasm-kernel".to_vec(),
    };
    let prover_input = WasmKernelProverInput {
        public: public.clone(),
        trace: &trace,
        pc_rom: pc_rom.clone(),
    };
    let (_, mut proof) = prove_simple_kernel(&prover_input, &log).expect("prove");
    proof.opening_summary.digest[0] ^= 1;

    let verifier_input = WasmKernelVerifierInput {
        public,
        trace: &trace,
        pc_rom,
    };
    let err = verify_simple_kernel(&verifier_input, &log, &proof)
        .err()
        .expect("tampered opening summary must fail");
    assert!(format!("{err}").contains("bridge"));
}

#[test]
fn wasm_kernel_run_roundtrip() {
    let (_, trace, pc_rom) = compile_and_trace(
        r#"(module (func (export "main") (result i32)
             i32.const 7
             i32.const 9
             i32.add))"#,
    );
    let log = ToyModule;
    let public = WasmKernelPublicInput {
        transcript_seed: b"wasm-kernel-run".to_vec(),
    };
    let prover_input = WasmKernelProverInput {
        public: public.clone(),
        trace: &trace,
        pc_rom: pc_rom.clone(),
    };
    let params = NeoParams::goldilocks_auto_r1cs_ccs(1).expect("params");
    let (output, proof) = prove_kernel_run(
        FoldingMode::Optimized,
        FoldSchedule::RowsPerChunk(1),
        &params,
        &prover_input,
        &log,
        mixers(),
    )
    .expect("prove kernel run");

    let verifier_input = WasmKernelVerifierInput {
        public,
        trace: &trace,
        pc_rom,
    };
    let verified = verify_kernel_run(FoldingMode::Optimized, &params, &verifier_input, &log, &proof, mixers())
        .expect("verify kernel run");
    assert_eq!(verified.public_steps.len(), output.public_steps.len());
    assert_eq!(
        verified
            .public_steps
            .iter()
            .map(|step| step.label.as_str())
            .collect::<Vec<_>>(),
        output
            .public_steps
            .iter()
            .map(|step| step.label.as_str())
            .collect::<Vec<_>>()
    );
    assert_eq!(verified.opening_summary, output.opening_summary);
}

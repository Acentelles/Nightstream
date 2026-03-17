use std::ffi::OsString;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::Arc;
use std::sync::OnceLock;
use std::time::{Duration, Instant};

use neo_ajtai::{setup as ajtai_setup, AjtaiSModule, Commitment as Cmt};
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{CcsClaim, CcsStructure, CcsWitness, Mat, SparsePoly};
use neo_fold::pi_ccs::FoldingMode;
use neo_fold::riscv_trace_shard::{Rv32TraceProvePhaseDurations, Rv32TraceWiring};
use neo_fold::shard::{fold_shard_prove_ccs_only_batched, CommitMixers};
use neo_fold::{DeviceApi, MojoBackendConfig, ProverComputeBackend};
use neo_math::ring::Rq as RqEl;
use neo_math::{D, F, K};
use neo_memory::ajtai::{commit_cols_for_ccs_m, encode_vector_for_ccs_m};
use neo_memory::riscv::lookups::{encode_program, RiscvInstruction, RiscvMemOp, RiscvOpcode};
use neo_memory::witness::StepWitnessBundle;
use neo_params::NeoParams;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;
use rand_chacha::rand_core::SeedableRng;
use rand_chacha::ChaCha8Rng;

type Mixers = CommitMixers<fn(&[Mat<F>], &[Cmt]) -> Cmt, fn(&[Cmt], u32) -> Cmt>;

fn real_mojo_library_name() -> &'static str {
    #[cfg(target_os = "macos")]
    {
        "libnightstream_mojo_gpu.dylib"
    }
    #[cfg(target_os = "linux")]
    {
        "libnightstream_mojo_gpu.so"
    }
    #[cfg(target_os = "windows")]
    {
        "nightstream_mojo_gpu.dll"
    }
}

fn pixi_bin() -> OsString {
    if let Some(home) = std::env::var_os("HOME") {
        let candidate = PathBuf::from(home).join(".pixi").join("bin").join("pixi");
        if candidate.is_file() {
            return candidate.into_os_string();
        }
    }
    OsString::from("pixi")
}

fn build_real_mojo_library() -> &'static Path {
    static LIB_PATH: OnceLock<PathBuf> = OnceLock::new();
    LIB_PATH.get_or_init(|| {
        let project_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("..")
            .join("..")
            .join("gpu")
            .join("mojo");
        let output_dir = project_dir.join("build");
        let output = output_dir.join(real_mojo_library_name());
        std::fs::create_dir_all(&output_dir).expect("create mojo build directory");

        let status = Command::new(pixi_bin())
            .arg("run")
            .arg("mojo")
            .arg("build")
            .arg("--emit")
            .arg("shared-lib")
            .arg("src/lib.mojo")
            .arg("-o")
            .arg(&output)
            .current_dir(&project_dir)
            .status()
            .expect("spawn mojo build");
        assert!(status.success(), "real mojo gpu build failed");

        output
            .canonicalize()
            .expect("canonical real mojo gpu library path")
    })
}

fn run_poseidon_bench() -> String {
    let project_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("..")
        .join("gpu")
        .join("mojo");
    let output = Command::new(pixi_bin())
        .arg("run")
        .arg("mojo")
        .arg("run")
        .arg("src/poseidon_gpu_bench.mojo")
        .current_dir(project_dir)
        .output()
        .expect("run poseidon gpu bench");
    assert!(
        output.status.success(),
        "poseidon gpu bench failed: stdout=\n{}\nstderr=\n{}",
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
    String::from_utf8(output.stdout).expect("utf8 poseidon bench output")
}

fn select_poseidon_bench_lines(bench_output: &str, batch: usize) -> Vec<String> {
    let batch_tag = format!("batch={batch}");
    bench_output
        .lines()
        .filter(|line| line.contains(&batch_tag))
        .filter(|line| line.starts_with("cpu") || line.starts_with("gpu_steady") || line.starts_with("gpu_roundtrip"))
        .map(ToOwned::to_owned)
        .collect()
}

fn fmt_duration(d: Duration) -> String {
    if d.as_secs_f64() < 1.0 {
        format!("{:.3}ms", d.as_secs_f64() * 1000.0)
    } else {
        format!("{:.3}s", d.as_secs_f64())
    }
}

fn median_duration(mut samples: Vec<Duration>) -> Duration {
    samples.sort_unstable();
    samples[samples.len() / 2]
}

fn rot_matrix_to_rq(mat: &Mat<F>) -> RqEl {
    let mut coeffs = [F::ZERO; D];
    for i in 0..D {
        coeffs[i] = mat[(i, 0)];
    }
    neo_math::ring::cf_inv(coeffs)
}

fn default_mixers() -> Mixers {
    fn mix_rhos_commits(rhos: &[Mat<F>], cs: &[Cmt]) -> Cmt {
        assert!(!cs.is_empty(), "mix_rhos_commits: empty commitments");
        let rq_els: Vec<RqEl> = rhos.iter().map(rot_matrix_to_rq).collect();
        neo_ajtai::s_lincomb(&rq_els, cs).expect("s_lincomb should succeed")
    }

    fn combine_b_pows(cs: &[Cmt], b: u32) -> Cmt {
        assert!(!cs.is_empty(), "combine_b_pows: empty commitments");
        let mut acc = cs[0].clone();
        let mut pow = F::from_u64(b as u64);
        for c in cs.iter().skip(1) {
            let rq_pow = RqEl::from_field_scalar(pow);
            let term = neo_ajtai::s_mul(&rq_pow, c);
            acc.add_inplace(&term);
            pow *= F::from_u64(b as u64);
        }
        acc
    }

    CommitMixers {
        mix_rhos_commits,
        combine_b_pows,
    }
}

fn identity_ccs(n: usize) -> CcsStructure<F> {
    CcsStructure::new(vec![Mat::identity(n)], SparsePoly::new(1, vec![])).expect("valid CCS")
}

fn setup_ajtai_committer(params: &NeoParams, m: usize) -> AjtaiSModule {
    let m_commit = commit_cols_for_ccs_m(m);
    let mut rng = ChaCha8Rng::seed_from_u64(7);
    let pp = ajtai_setup(&mut rng, D, params.kappa as usize, m_commit).expect("Ajtai setup should succeed");
    AjtaiSModule::new(Arc::new(pp))
}

fn build_step(params: &NeoParams, l: &AjtaiSModule, m: usize, m_in: usize, seed: u64) -> StepWitnessBundle<Cmt, F, K> {
    let z: Vec<F> = (0..m)
        .map(|i| match (seed.wrapping_add(i as u64)) % 3 {
            0 => -F::ONE,
            1 => F::ZERO,
            _ => F::ONE,
        })
        .collect();
    let x = z[..m_in].to_vec();
    let w = z[m_in..].to_vec();
    let z_cols = encode_vector_for_ccs_m(params, m, &z).expect("encode witness for CCS width");
    let c = l.commit(&z_cols);
    StepWitnessBundle::from((CcsClaim { c, x, m_in }, CcsWitness { w, Z: z_cols }))
}

fn high_batch_params(n: usize) -> NeoParams {
    let base = NeoParams::goldilocks_auto_r1cs_ccs(n).expect("params");
    NeoParams::new(
        base.q,
        base.eta,
        base.d,
        base.kappa,
        base.m,
        base.b,
        16,
        base.T,
        base.s,
        base.lambda,
    )
    .expect("high batch params")
}

fn prove_ccs_only_batch(
    backend: &ProverComputeBackend,
    params: &NeoParams,
    ccs: &CcsStructure<F>,
    steps: &[StepWitnessBundle<Cmt, F, K>],
    l: &AjtaiSModule,
    mixers: Mixers,
    batch_size: usize,
    label: &'static [u8],
) -> (Vec<u8>, Duration) {
    let mut transcript = Poseidon2Transcript::new(label);
    let started = Instant::now();
    let proof = fold_shard_prove_ccs_only_batched(
        FoldingMode::Optimized,
        &mut transcript,
        params,
        ccs,
        steps,
        &[],
        &[],
        l,
        mixers,
        batch_size,
        backend,
    )
    .expect("prove ccs-only batch");
    let elapsed = started.elapsed();
    (serde_json::to_vec(&proof).expect("serialize proof"), elapsed)
}

fn shared_bus_trace_program(repeats: usize) -> Vec<RiscvInstruction> {
    let mut program = Vec::with_capacity(repeats * 5 + 1);
    for _ in 0..repeats {
        program.extend([
            RiscvInstruction::IAlu {
                op: RiscvOpcode::Add,
                rd: 1,
                rs1: 0,
                imm: 3,
            },
            RiscvInstruction::IAlu {
                op: RiscvOpcode::Add,
                rd: 2,
                rs1: 0,
                imm: 4,
            },
            RiscvInstruction::RAlu {
                op: RiscvOpcode::Mul,
                rd: 3,
                rs1: 1,
                rs2: 2,
            },
            RiscvInstruction::Store {
                op: RiscvMemOp::Sw,
                rs1: 0,
                rs2: 3,
                imm: 0,
            },
            RiscvInstruction::Load {
                op: RiscvMemOp::Lw,
                rd: 4,
                rs1: 0,
                imm: 0,
            },
        ]);
    }
    program.push(RiscvInstruction::Halt);
    program
}

fn prove_trace_shared_bus(
    backend: &ProverComputeBackend,
    program_bytes: &[u8],
    max_steps: usize,
) -> (Vec<u8>, Duration, Rv32TraceProvePhaseDurations) {
    let run = Rv32TraceWiring::from_rom(/*program_base=*/ 0, program_bytes)
        .xlen(32)
        .min_trace_len(max_steps)
        .chunk_rows(max_steps)
        .max_steps(max_steps)
        .shout_auto_minimal()
        .compute_backend(backend.clone())
        .prove()
        .expect("trace shared-bus prove");
    (
        serde_json::to_vec(run.proof()).expect("serialize trace proof"),
        run.prove_duration(),
        run.prove_phase_durations(),
    )
}

#[test]
#[ignore = "perf-style test: run on CUDA with `cargo test -p neo-fold --release --test perf -- --ignored --nocapture report_mojo_cuda_backend_compare_multi_step`"]
fn report_mojo_cuda_backend_compare_multi_step() {
    let n = 8usize;
    let batch_size = 40usize;
    let prove_iters = std::env::var("NS_GPU_PROVE_ITERS")
        .ok()
        .and_then(|v| v.parse::<usize>().ok())
        .unwrap_or(3);
    let poseidon_batch = std::env::var("NS_GPU_POSEIDON_BATCH")
        .ok()
        .and_then(|v| v.parse::<usize>().ok())
        .unwrap_or(512);

    let ccs = identity_ccs(n);
    let params = high_batch_params(n);
    let l = setup_ajtai_committer(&params, ccs.m);
    let mixers = default_mixers();
    let steps: Vec<StepWitnessBundle<Cmt, F, K>> = (0..batch_size)
        .map(|i| build_step(&params, &l, ccs.m, 2, 20_000 + (i as u64) * 97))
        .collect();

    let library_path = build_real_mojo_library();
    let mojo_backend =
        ProverComputeBackend::Mojo(MojoBackendConfig::new(DeviceApi::Cuda).with_library_path(library_path));
    let cpu_backend = ProverComputeBackend::Cpu;

    let poseidon_bench_output = run_poseidon_bench();
    let selected_poseidon_lines = select_poseidon_bench_lines(&poseidon_bench_output, poseidon_batch);

    let mut cpu_samples = Vec::with_capacity(prove_iters);
    let mut mojo_samples = Vec::with_capacity(prove_iters);
    let mut cpu_reference = None;

    for iter in 0..prove_iters {
        let (cpu_proof, cpu_time) = prove_ccs_only_batch(
            &cpu_backend,
            &params,
            &ccs,
            &steps,
            &l,
            mixers,
            batch_size,
            b"neo.fold/perf_mojo_cuda",
        );
        let (mojo_proof, mojo_time) = prove_ccs_only_batch(
            &mojo_backend,
            &params,
            &ccs,
            &steps,
            &l,
            mixers,
            batch_size,
            b"neo.fold/perf_mojo_cuda",
        );
        assert!(cpu_proof == mojo_proof, "cpu/mojo proof parity iter={iter}");
        cpu_reference.get_or_insert(cpu_proof);
        cpu_samples.push(cpu_time);
        mojo_samples.push(mojo_time);
    }

    let cpu_median = median_duration(cpu_samples.clone());
    let mojo_median = median_duration(mojo_samples.clone());
    let speedup = cpu_median.as_secs_f64() / mojo_median.as_secs_f64();

    println!();
    println!("[mojo-backend-compare] poseidon batch benchmark target={poseidon_batch}");
    if selected_poseidon_lines.is_empty() {
        println!("[mojo-backend-compare] poseidon bench output did not contain batch={poseidon_batch}");
        println!("{poseidon_bench_output}");
    } else {
        for line in selected_poseidon_lines {
            println!("[mojo-backend-compare] {line}");
        }
    }
    println!("[mojo-backend-compare] ccs_only workload: n={n} batch_size={batch_size} prove_iters={prove_iters}");
    println!("[mojo-backend-compare] cpu_prove_median={}", fmt_duration(cpu_median));
    println!(
        "[mojo-backend-compare] mojo_cuda_prove_median={}",
        fmt_duration(mojo_median)
    );
    println!("[mojo-backend-compare] end_to_end_speedup={speedup:.3}x");
}

#[test]
#[ignore = "perf-style test: run on CUDA with `cargo test -p neo-fold --release --test perf -- --ignored --nocapture report_mojo_cuda_trace_backend_compare_shared_bus`"]
fn report_mojo_cuda_trace_backend_compare_shared_bus() {
    let repeats = std::env::var("NS_GPU_TRACE_REPEATS")
        .ok()
        .and_then(|v| v.parse::<usize>().ok())
        .unwrap_or(128);
    let warmups = std::env::var("NS_GPU_TRACE_WARMUPS")
        .ok()
        .and_then(|v| v.parse::<usize>().ok())
        .unwrap_or(1);
    let prove_iters = std::env::var("NS_GPU_TRACE_ITERS")
        .ok()
        .and_then(|v| v.parse::<usize>().ok())
        .unwrap_or(3);

    let program = shared_bus_trace_program(repeats);
    let program_bytes = encode_program(&program);
    let max_steps = program.len();
    let library_path = build_real_mojo_library();
    let cpu_backend = ProverComputeBackend::Cpu;
    let mojo_backend =
        ProverComputeBackend::Mojo(MojoBackendConfig::new(DeviceApi::Cuda).with_library_path(library_path));

    let mut cpu_samples = Vec::with_capacity(prove_iters);
    let mut mojo_samples = Vec::with_capacity(prove_iters);
    let mut cpu_fold_samples = Vec::with_capacity(prove_iters);
    let mut mojo_fold_samples = Vec::with_capacity(prove_iters);

    for _ in 0..warmups {
        let _ = prove_trace_shared_bus(&cpu_backend, &program_bytes, max_steps);
        let _ = prove_trace_shared_bus(&mojo_backend, &program_bytes, max_steps);
    }

    for iter in 0..prove_iters {
        let (cpu_proof, cpu_time, cpu_phases) = prove_trace_shared_bus(&cpu_backend, &program_bytes, max_steps);
        let (mojo_proof, mojo_time, mojo_phases) = prove_trace_shared_bus(&mojo_backend, &program_bytes, max_steps);
        assert!(cpu_proof == mojo_proof, "cpu/mojo trace proof parity iter={iter}");
        cpu_samples.push(cpu_time);
        mojo_samples.push(mojo_time);
        cpu_fold_samples.push(cpu_phases.fold_and_prove);
        mojo_fold_samples.push(mojo_phases.fold_and_prove);
    }

    let cpu_median = median_duration(cpu_samples);
    let mojo_median = median_duration(mojo_samples);
    let cpu_fold_median = median_duration(cpu_fold_samples);
    let mojo_fold_median = median_duration(mojo_fold_samples);
    let speedup = cpu_median.as_secs_f64() / mojo_median.as_secs_f64();
    let fold_speedup = cpu_fold_median.as_secs_f64() / mojo_fold_median.as_secs_f64();

    println!(
        "[mojo-trace-compare] shared-bus trace repeats={repeats} max_steps={max_steps} warmups={warmups} prove_iters={prove_iters}"
    );
    println!("[mojo-trace-compare] cpu_prove_median={}", fmt_duration(cpu_median));
    println!(
        "[mojo-trace-compare] mojo_cuda_prove_median={}",
        fmt_duration(mojo_median)
    );
    println!(
        "[mojo-trace-compare] cpu_fold_and_prove_median={}",
        fmt_duration(cpu_fold_median)
    );
    println!(
        "[mojo-trace-compare] mojo_cuda_fold_and_prove_median={}",
        fmt_duration(mojo_fold_median)
    );
    println!("[mojo-trace-compare] end_to_end_speedup={speedup:.3}x");
    println!("[mojo-trace-compare] fold_and_prove_speedup={fold_speedup:.3}x");
}

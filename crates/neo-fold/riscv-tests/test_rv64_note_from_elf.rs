//! Canonical real-ELF RV64IM note repro tests.
//!
//! These are the maintained end-to-end note-circuit prove/verify perf repros.
//! New note-circuit validation and perf work should target this file.
#![cfg(feature = "poseidon-precompile")]

use neo_fold::pi_ccs::FoldingMode;
use neo_fold::rv64_trace_shard::{Rv64TraceWiring, Rv64TraceWiringRun};
use neo_fold::{DeviceApi, MojoBackendConfig, ProverComputeBackend};
use neo_math::F;
use neo_memory::riscv::exec_table::RiscvExecTable;
use neo_vm_trace::TwistOpKind;
use p3_field::PrimeCharacteristicRing;
use std::collections::{BTreeSet, HashMap};
use std::ffi::OsString;
use std::path::PathBuf;
use std::process::Command;
use std::time::{Duration, Instant};

#[path = "support/note_deposit_fixture.rs"]
mod note_deposit_fixture;
#[path = "support/note_spend_fixture.rs"]
mod note_spend_fixture;
#[path = "support/rv64_guest.rs"]
mod rv64_guest;

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

fn build_real_mojo_library() -> PathBuf {
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
}

fn required_accelerator_api() -> DeviceApi {
    #[cfg(target_os = "macos")]
    {
        DeviceApi::Metal
    }
    #[cfg(not(target_os = "macos"))]
    {
        DeviceApi::Cuda
    }
}

fn strict_requested_accelerator(backend: &ProverComputeBackend) -> Option<DeviceApi> {
    match backend {
        ProverComputeBackend::Mojo(cfg) if !cfg.fallback_to_cpu => match cfg.device_api {
            DeviceApi::Cpu | DeviceApi::Auto => None,
            api => Some(api),
        },
        _ => None,
    }
}

fn simulate_exec_with_witness_rv64(
    elf: &[u8],
    ram_pairs: &[(u64, u32)],
    max_steps: usize,
) -> Result<RiscvExecTable, String> {
    let mut wiring = Rv64TraceWiring::from_elf(elf)
        .map_err(|e| format!("from_elf failed: {e}"))?
        .mode(FoldingMode::Optimized)
        .max_steps(max_steps);
    for &(addr, val) in ram_pairs {
        wiring = wiring.ram_init_u32(addr, val);
    }
    let trace = wiring
        .simulate()
        .map_err(|e| format!("simulate failed: {e}"))?;
    if !trace.did_halt() {
        return Err(format!("RV64 note guest did not halt within {max_steps} steps"));
    }
    RiscvExecTable::from_trace_padded_with_xlen(&trace, trace.steps.len(), 64)
        .map_err(|e| format!("exec table build failed: {e}"))
}

fn derive_output_claims_for_addresses(
    exec: &RiscvExecTable,
    ram_pairs: &[(u64, u32)],
    output_addrs: &[u64],
) -> Vec<(u64, u32)> {
    let output_addr_set: BTreeSet<u64> = output_addrs.iter().copied().collect();
    let mut final_output_values: HashMap<u64, u32> = output_addr_set.iter().map(|&addr| (addr, 0u32)).collect();
    for &(addr, value) in ram_pairs {
        if output_addr_set.contains(&addr) {
            final_output_values.insert(addr, value);
        }
    }
    for row in exec.rows.iter().filter(|r| r.active) {
        for ev in &row.ram_events {
            if ev.kind == TwistOpKind::Write && output_addr_set.contains(&ev.addr) {
                final_output_values.insert(ev.addr, ev.value as u32);
            }
        }
    }
    output_addrs
        .iter()
        .map(|addr| (*addr, *final_output_values.get(addr).unwrap_or(&0u32)))
        .collect()
}

fn parse_usize_after(msg: &str, key: &str) -> Option<usize> {
    let start = msg.find(key)? + key.len();
    let rest = &msg[start..];
    let digits_end = rest
        .find(|c: char| !c.is_ascii_digit())
        .unwrap_or(rest.len());
    if digits_end == 0 {
        return None;
    }
    rest[..digits_end].parse::<usize>().ok()
}

fn next_chunk_rows_from_poseidon_split(msg: &str, current_chunk_rows: usize) -> Option<usize> {
    if !msg.contains("poseidon split") {
        return None;
    }
    let ccs_m = parse_usize_after(msg, "ccs_m=")?;
    let m_in = parse_usize_after(msg, "m_in=")?;
    let t_len = parse_usize_after(msg, "t_len=")?;
    let t_cap = ccs_m.saturating_sub(m_in).max(1);
    if t_len <= t_cap {
        return None;
    }
    let mut next = current_chunk_rows
        .saturating_mul(t_cap)
        .checked_div(t_len)
        .unwrap_or(0)
        .max(1);
    if next >= current_chunk_rows {
        next = current_chunk_rows.saturating_sub(1).max(1);
    }
    (next < current_chunk_rows).then_some(next)
}

fn summarize_error_for_log(msg: &str) -> String {
    const MAX_CHARS: usize = 180;
    let compact = msg.replace('\n', " ");
    let mut out = compact.chars().take(MAX_CHARS).collect::<String>();
    if compact.chars().count() > MAX_CHARS {
        out.push_str("...");
    }
    out
}

#[derive(Debug, Clone)]
struct ProveAttemptMetrics {
    attempt: usize,
    chunk_rows: usize,
    prove_wall: Duration,
    succeeded: bool,
    next_chunk_rows: Option<usize>,
    error_summary: Option<String>,
}

struct ProveWithRetryResult {
    run: Rv64TraceWiringRun,
    final_chunk_rows: usize,
    attempts: Vec<ProveAttemptMetrics>,
}

struct NoteCaseMetrics {
    simulated_steps: usize,
    simulated_twist_events: usize,
    simulated_shout_events: usize,
    output_claim_words: usize,
    witness_ram_words: usize,
}

#[derive(Clone, Copy, Debug, Default)]
struct NoteCaseRunMetrics {
    prove_wall: Duration,
    verify_wall: Duration,
    setup: Duration,
    chunk_build_commit: Duration,
    fold_and_prove: Duration,
}

struct NoteCaseProveResult {
    run: Rv64TraceWiringRun,
    metrics: NoteCaseRunMetrics,
}

fn median_duration(samples: &mut [Duration]) -> Duration {
    samples.sort_unstable();
    samples[samples.len() / 2]
}

fn prove_with_poseidon_retry_rv64(
    elf: &[u8],
    ram_pairs: &[(u64, u32)],
    output_claims: &[(u64, u32)],
    executed_steps: usize,
    initial_chunk_rows: usize,
    max_retries: usize,
    compute_backend: &ProverComputeBackend,
) -> Result<ProveWithRetryResult, String> {
    let mut chunk_rows = executed_steps.max(1);
    let configured_initial = initial_chunk_rows.max(1);
    if configured_initial < chunk_rows {
        chunk_rows = configured_initial;
    }
    let mut retry_idx = 0usize;
    let mut attempts = Vec::new();
    loop {
        let mut wiring = Rv64TraceWiring::from_elf(elf)
            .map_err(|e| format!("from_elf failed: {e}"))?
            .mode(FoldingMode::Optimized)
            .chunk_rows(chunk_rows)
            .compute_backend(compute_backend.clone())
            .max_steps(executed_steps);
        for &(addr, val) in ram_pairs {
            wiring = wiring.ram_init_u32(addr, val);
        }
        for &(addr, val) in output_claims {
            wiring = wiring.output_claim(addr, F::from_u64(val as u64));
        }

        let attempt_start = Instant::now();
        match wiring.prove() {
            Ok(run) => {
                attempts.push(ProveAttemptMetrics {
                    attempt: retry_idx + 1,
                    chunk_rows,
                    prove_wall: attempt_start.elapsed(),
                    succeeded: true,
                    next_chunk_rows: None,
                    error_summary: None,
                });
                return Ok(ProveWithRetryResult {
                    run,
                    final_chunk_rows: chunk_rows,
                    attempts,
                });
            }
            Err(err) => {
                let msg = err.to_string();
                let next_chunk_rows = if retry_idx < max_retries {
                    next_chunk_rows_from_poseidon_split(&msg, chunk_rows)
                } else {
                    None
                };
                attempts.push(ProveAttemptMetrics {
                    attempt: retry_idx + 1,
                    chunk_rows,
                    prove_wall: attempt_start.elapsed(),
                    succeeded: false,
                    next_chunk_rows,
                    error_summary: Some(summarize_error_for_log(&msg)),
                });
                if let Some(next_chunk_rows) = next_chunk_rows {
                    println!(
                        "rv64_poseidon_split_retry: chunk_rows {} -> {} (attempt {}/{})",
                        chunk_rows,
                        next_chunk_rows,
                        retry_idx + 1,
                        max_retries
                    );
                    chunk_rows = next_chunk_rows;
                    retry_idx += 1;
                    continue;
                }
                return Err(format!("prove failed at chunk_rows={chunk_rows}: {err}"));
            }
        }
    }
}

fn prove_rv64_note_case(
    label: &str,
    elf: &[u8],
    witness_ram_pairs: &[(u64, u32)],
    output_layout_words: &[(u64, u32)],
    max_steps: usize,
    compute_backend: &ProverComputeBackend,
) -> NoteCaseProveResult {
    let metrics = NoteCaseMetrics {
        witness_ram_words: witness_ram_pairs.len(),
        simulated_steps: 0,
        simulated_twist_events: 0,
        simulated_shout_events: 0,
        output_claim_words: output_layout_words.len(),
    };
    println!(
        "{label}: witness_ram_words={} output_claim_words={}",
        metrics.witness_ram_words, metrics.output_claim_words
    );

    let exec = simulate_exec_with_witness_rv64(elf, witness_ram_pairs, max_steps)
        .unwrap_or_else(|e| panic!("{label}: simulate witness failed: {e}"));
    let output_addrs: Vec<u64> = output_layout_words.iter().map(|(addr, _)| *addr).collect();
    let output_claims = derive_output_claims_for_addresses(&exec, witness_ram_pairs, &output_addrs);
    let metrics = NoteCaseMetrics {
        witness_ram_words: witness_ram_pairs.len(),
        simulated_steps: exec.rows.len(),
        simulated_twist_events: exec.rows.iter().map(|row| row.ram_events.len()).sum(),
        simulated_shout_events: exec.rows.iter().map(|row| row.shout_events.len()).sum(),
        output_claim_words: output_claims.len(),
    };
    println!(
        "{label}: simulated_steps={} simulated_twist_events={} simulated_shout_events={} output_claim_words={}",
        metrics.simulated_steps,
        metrics.simulated_twist_events,
        metrics.simulated_shout_events,
        metrics.output_claim_words
    );

    let prove_start = Instant::now();
    let prove_result = prove_with_poseidon_retry_rv64(
        elf,
        witness_ram_pairs,
        &output_claims,
        metrics.simulated_steps,
        metrics.simulated_steps,
        8,
        compute_backend,
    )
    .unwrap_or_else(|e| panic!("{label}: prove failed: {e}"));
    let prove_wall = prove_start.elapsed();
    let run = prove_result.run;
    let layout = run.layout().clone();
    let phases = run.prove_phase_durations();

    println!(
        "{label}: attempts={} final_chunk_rows={} prove_wall_ms={:.1}",
        prove_result.attempts.len(),
        prove_result.final_chunk_rows,
        prove_wall.as_secs_f64() * 1000.0
    );
    for attempt in &prove_result.attempts {
        println!(
            "{label}: attempt={} chunk_rows={} ok={} prove_wall_ms={:.1} next_chunk_rows={:?} err={}",
            attempt.attempt,
            attempt.chunk_rows,
            attempt.succeeded,
            attempt.prove_wall.as_secs_f64() * 1000.0,
            attempt.next_chunk_rows,
            attempt.error_summary.as_deref().unwrap_or("-")
        );
    }
    println!(
        "{label}: trace_len={} fold_count={} ccs_constraints={} ccs_variables={}",
        run.trace_len(),
        run.fold_count(),
        run.ccs_num_constraints(),
        run.ccs_num_variables()
    );
    println!(
        "{label}: layout_t={} layout_m_in={} layout_m={} used_memory_ids={:?} used_shout_table_ids={:?}",
        layout.t,
        layout.m_in,
        layout.m,
        run.used_memory_ids(),
        run.used_shout_table_ids()
    );
    println!(
        "{label}: setup_ms={:.1} chunk_build_commit_ms={:.1} fold_and_prove_ms={:.1}",
        phases.setup.as_secs_f64() * 1000.0,
        phases.chunk_build_commit.as_secs_f64() * 1000.0,
        phases.fold_and_prove.as_secs_f64() * 1000.0
    );
    if let Some(metrics) = run.shard_prove_metrics() {
        println!(
            "{label}: lane_ms main={:.1} val={:.1} wb={:.1} wp={:.1} poseidon_cycle={:.1} poseidon_local={:.1} stage8={:.1} finalize={:.1}",
            metrics.lane_durations.main_ccs_fold.as_secs_f64() * 1000.0,
            metrics.lane_durations.val_lane.as_secs_f64() * 1000.0,
            metrics.lane_durations.wb_lane.as_secs_f64() * 1000.0,
            metrics.lane_durations.wp_lane.as_secs_f64() * 1000.0,
            metrics.lane_durations.poseidon_cycle_lane.as_secs_f64() * 1000.0,
            metrics.lane_durations.poseidon_local_lane.as_secs_f64() * 1000.0,
            metrics.lane_durations.stage8_lane.as_secs_f64() * 1000.0,
            metrics.lane_durations.route_a_finalize.as_secs_f64() * 1000.0,
        );
        println!(
            "{label}: stage8_ms joint_prepare={:.1} group_build={:.1} joint_commit_many={:.1} expected_commitments={:.1} unified_fold_mix={:.1} rlc_dec={:.1}",
            metrics.stage8_subphases.joint_prepare.as_secs_f64() * 1000.0,
            metrics.stage8_subphases.group_build.as_secs_f64() * 1000.0,
            metrics.stage8_subphases.joint_commit_many.as_secs_f64() * 1000.0,
            metrics.stage8_subphases.expected_commitments.as_secs_f64() * 1000.0,
            metrics.stage8_subphases.unified_fold_mix.as_secs_f64() * 1000.0,
            metrics.stage8_subphases.rlc_dec.as_secs_f64() * 1000.0,
        );
        println!(
            "{label}: wbwp_ms parent_mix={:.1} rlc_parent={:.1} z_mix={:.1} dec_stream={:.1}",
            metrics.wbwp_subphases.parent_mix.as_secs_f64() * 1000.0,
            metrics.wbwp_subphases.rlc_parent.as_secs_f64() * 1000.0,
            metrics.wbwp_subphases.z_mix.as_secs_f64() * 1000.0,
            metrics.wbwp_subphases.dec_stream.as_secs_f64() * 1000.0,
        );
        println!(
            "{label}: route_a_ms fold_openings={:.1} opening_proofs={:.1} opening_manifest={:.1}",
            metrics.route_a_shared.fold_openings.as_secs_f64() * 1000.0,
            metrics.route_a_shared.opening_proofs.as_secs_f64() * 1000.0,
            metrics.route_a_shared.opening_manifest.as_secs_f64() * 1000.0,
        );
        println!(
            "{label}: materialized_ms digit_split={:.1} child_commit={:.1} child_build={:.1}",
            metrics.materialized_subphases.digit_split.as_secs_f64() * 1000.0,
            metrics.materialized_subphases.child_commit.as_secs_f64() * 1000.0,
            metrics.materialized_subphases.child_build.as_secs_f64() * 1000.0,
        );
        println!(
            "{label}: batchable_claims val={} wb={} wp={} poseidon_cycle={} poseidon_local={} stage8={} wb_materialized_batches={} wb_materialized_children={} wp_materialized_batches={} wp_materialized_children={} max_materialized_children={}",
            metrics.batch_opportunities.val_claims,
            metrics.batch_opportunities.wb_claims,
            metrics.batch_opportunities.wp_claims,
            metrics.batch_opportunities.poseidon_cycle_claims,
            metrics.batch_opportunities.poseidon_local_claims,
            metrics.batch_opportunities.stage8_claims,
            metrics.batch_opportunities.wb_materialized_batches,
            metrics.batch_opportunities.wb_materialized_children,
            metrics.batch_opportunities.wp_materialized_batches,
            metrics.batch_opportunities.wp_materialized_children,
            metrics.batch_opportunities.max_materialized_children,
        );
        println!(
            "{label}: mojo poseidon cpu={} host_fb={} accel={} states={} max_states={} fe create={} eval={} fold={} destroy={} fe_accel={} fe_tasks={} nc create={} eval={} fold={} destroy={} nc_accel={} nc_tasks={} rq_mul cpu={} host_fb={} accel={} items={} max_items={} superneo cpu={} host_fb={} accel={} items={}",
            metrics.mojo_delta.poseidon2_batch.cpu_calls,
            metrics.mojo_delta.poseidon2_batch.host_fallback_calls,
            metrics.mojo_delta.poseidon2_batch.accelerator_calls,
            metrics.mojo_delta.poseidon2_batch.total_items,
            metrics.mojo_delta.poseidon2_batch.max_items,
            metrics.mojo_delta.fe.create_calls,
            metrics.mojo_delta.fe.eval_calls,
            metrics.mojo_delta.fe.fold_calls,
            metrics.mojo_delta.fe.destroy_calls,
            metrics.mojo_delta.fe.accelerator_calls,
            metrics.mojo_delta.fe.total_items,
            metrics.mojo_delta.nc.create_calls,
            metrics.mojo_delta.nc.eval_calls,
            metrics.mojo_delta.nc.fold_calls,
            metrics.mojo_delta.nc.destroy_calls,
            metrics.mojo_delta.nc.accelerator_calls,
            metrics.mojo_delta.nc.total_items,
            metrics.mojo_delta.rq_mul.cpu_calls,
            metrics.mojo_delta.rq_mul.host_fallback_calls,
            metrics.mojo_delta.rq_mul.accelerator_calls,
            metrics.mojo_delta.rq_mul.total_items,
            metrics.mojo_delta.rq_mul.max_items,
            metrics.mojo_delta.superneo.cpu_calls,
            metrics.mojo_delta.superneo.host_fallback_calls,
            metrics.mojo_delta.superneo.accelerator_calls,
            metrics.mojo_delta.superneo.total_items,
        );
        if let Some(expected_api) = strict_requested_accelerator(compute_backend) {
            let accelerator_calls = metrics.mojo_delta.poseidon2_batch.accelerator_calls
                + metrics.mojo_delta.fe.accelerator_calls
                + metrics.mojo_delta.nc.accelerator_calls
                + metrics.mojo_delta.rq_mul.accelerator_calls
                + metrics.mojo_delta.superneo.accelerator_calls;
            assert!(
                accelerator_calls > 0,
                "{label}: strict Mojo backend requested {expected_api:?}, but shard prove metrics reported no accelerator execution",
            );
        }
    }
    NoteCaseProveResult {
        run,
        metrics: NoteCaseRunMetrics {
            prove_wall,
            verify_wall: Duration::ZERO,
            setup: phases.setup,
            chunk_build_commit: phases.chunk_build_commit,
            fold_and_prove: phases.fold_and_prove,
        },
    }
}

fn run_rv64_note_case(
    label: &str,
    elf: &[u8],
    witness_ram_pairs: &[(u64, u32)],
    output_layout_words: &[(u64, u32)],
    max_steps: usize,
    compute_backend: &ProverComputeBackend,
) -> NoteCaseRunMetrics {
    let NoteCaseProveResult { mut run, mut metrics } = prove_rv64_note_case(
        label,
        elf,
        witness_ram_pairs,
        output_layout_words,
        max_steps,
        compute_backend,
    );
    let verify_start = Instant::now();
    run.verify()
        .unwrap_or_else(|e| panic!("{label}: verify failed: {e}"));
    let verify_wall = verify_start.elapsed();
    println!("{label}: verify_wall_ms={:.1}", verify_wall.as_secs_f64() * 1000.0);
    metrics.verify_wall = verify_wall;
    metrics
}

#[test]
#[ignore = "slow RV64IM note-spend ELF perf repro"]
fn test_rv64_note_spend_from_elf_perf_repro() {
    let elf = rv64_guest::build_note_spend_rv64im_elf().expect("build RV64IM note guest ELF");
    let witness = note_spend_fixture::build_note_spend_fixture_witness();
    run_rv64_note_case(
        "rv64_note_spend_elf",
        &elf,
        &witness.ram_pairs,
        &witness.output_layout_words,
        400_000,
        &ProverComputeBackend::Cpu,
    );
}

#[test]
#[ignore = "slow RV64IM note-deposit ELF perf repro"]
fn test_rv64_note_deposit_from_elf_perf_repro() {
    let elf = rv64_guest::build_note_deposit_rv64im_elf().expect("build RV64IM note deposit guest ELF");
    let witness = note_deposit_fixture::build_note_deposit_witness();
    run_rv64_note_case(
        "rv64_note_deposit_elf",
        &elf,
        &witness.ram_pairs,
        &witness.output_layout_words,
        200_000,
        &ProverComputeBackend::Cpu,
    );
}

#[test]
#[ignore = "slow RV64IM note-spend ELF backend compare repro"]
fn test_rv64_note_spend_from_elf_auto_backend_perf_repro() {
    let elf = rv64_guest::build_note_spend_rv64im_elf().expect("build RV64IM note guest ELF");
    let witness = note_spend_fixture::build_note_spend_fixture_witness();
    let _ = build_real_mojo_library();

    run_rv64_note_case(
        "rv64_note_spend_elf_cpu",
        &elf,
        &witness.ram_pairs,
        &witness.output_layout_words,
        400_000,
        &ProverComputeBackend::Cpu,
    );
    run_rv64_note_case(
        "rv64_note_spend_elf_auto",
        &elf,
        &witness.ram_pairs,
        &witness.output_layout_words,
        400_000,
        &ProverComputeBackend::auto(),
    );
}

#[test]
#[ignore = "slow RV64IM note-spend ELF auto-only perf repro"]
fn test_rv64_note_spend_from_elf_auto_only_perf_repro() {
    let elf = rv64_guest::build_note_spend_rv64im_elf().expect("build RV64IM note guest ELF");
    let witness = note_spend_fixture::build_note_spend_fixture_witness();
    let _ = build_real_mojo_library();

    run_rv64_note_case(
        "rv64_note_spend_elf_auto_only",
        &elf,
        &witness.ram_pairs,
        &witness.output_layout_words,
        400_000,
        &ProverComputeBackend::auto(),
    );
}

#[test]
#[ignore = "slow RV64IM note-spend ELF median backend benchmark"]
fn test_rv64_note_spend_from_elf_backend_medians() {
    let elf = rv64_guest::build_note_spend_rv64im_elf().expect("build RV64IM note guest ELF");
    let witness = note_spend_fixture::build_note_spend_fixture_witness();
    let _ = build_real_mojo_library();
    let iters = std::env::var("NS_GPU_PROVE_ITERS")
        .ok()
        .and_then(|v| v.parse::<usize>().ok())
        .unwrap_or(5);

    let mut cpu_prove = Vec::with_capacity(iters);
    let mut cpu_verify = Vec::with_capacity(iters);
    let mut cpu_setup = Vec::with_capacity(iters);
    let mut cpu_chunk = Vec::with_capacity(iters);
    let mut cpu_fold = Vec::with_capacity(iters);
    let mut auto_prove = Vec::with_capacity(iters);
    let mut auto_verify = Vec::with_capacity(iters);
    let mut auto_setup = Vec::with_capacity(iters);
    let mut auto_chunk = Vec::with_capacity(iters);
    let mut auto_fold = Vec::with_capacity(iters);
    for iter in 0..iters {
        let cpu = run_rv64_note_case(
            &format!("rv64_note_spend_elf_cpu_iter{iter}"),
            &elf,
            &witness.ram_pairs,
            &witness.output_layout_words,
            400_000,
            &ProverComputeBackend::Cpu,
        );
        cpu_prove.push(cpu.prove_wall);
        cpu_verify.push(cpu.verify_wall);
        cpu_setup.push(cpu.setup);
        cpu_chunk.push(cpu.chunk_build_commit);
        cpu_fold.push(cpu.fold_and_prove);

        let auto = run_rv64_note_case(
            &format!("rv64_note_spend_elf_auto_iter{iter}"),
            &elf,
            &witness.ram_pairs,
            &witness.output_layout_words,
            400_000,
            &ProverComputeBackend::auto(),
        );
        auto_prove.push(auto.prove_wall);
        auto_verify.push(auto.verify_wall);
        auto_setup.push(auto.setup);
        auto_chunk.push(auto.chunk_build_commit);
        auto_fold.push(auto.fold_and_prove);
    }

    let cpu_prove_median = median_duration(&mut cpu_prove);
    let cpu_verify_median = median_duration(&mut cpu_verify);
    let cpu_setup_median = median_duration(&mut cpu_setup);
    let cpu_chunk_median = median_duration(&mut cpu_chunk);
    let cpu_fold_median = median_duration(&mut cpu_fold);
    let auto_prove_median = median_duration(&mut auto_prove);
    let auto_verify_median = median_duration(&mut auto_verify);
    let auto_setup_median = median_duration(&mut auto_setup);
    let auto_chunk_median = median_duration(&mut auto_chunk);
    let auto_fold_median = median_duration(&mut auto_fold);

    println!(
        "[note-spend-median] cpu prove_ms={:.1} verify_ms={:.1} setup_ms={:.1} chunk_build_commit_ms={:.1} fold_and_prove_ms={:.1}",
        cpu_prove_median.as_secs_f64() * 1000.0,
        cpu_verify_median.as_secs_f64() * 1000.0,
        cpu_setup_median.as_secs_f64() * 1000.0,
        cpu_chunk_median.as_secs_f64() * 1000.0,
        cpu_fold_median.as_secs_f64() * 1000.0,
    );
    println!(
        "[note-spend-median] auto prove_ms={:.1} verify_ms={:.1} setup_ms={:.1} chunk_build_commit_ms={:.1} fold_and_prove_ms={:.1}",
        auto_prove_median.as_secs_f64() * 1000.0,
        auto_verify_median.as_secs_f64() * 1000.0,
        auto_setup_median.as_secs_f64() * 1000.0,
        auto_chunk_median.as_secs_f64() * 1000.0,
        auto_fold_median.as_secs_f64() * 1000.0,
    );
}

#[test]
#[ignore = "slow RV64IM note-spend ELF real Mojo backend benchmark"]
fn test_rv64_note_spend_from_elf_real_mojo_backend_perf_repro() {
    let elf = rv64_guest::build_note_spend_rv64im_elf().expect("build RV64IM note guest ELF");
    let witness = note_spend_fixture::build_note_spend_fixture_witness();
    let library = build_real_mojo_library();
    let mojo_backend =
        ProverComputeBackend::Mojo(MojoBackendConfig::new(required_accelerator_api()).with_library_path(library));

    run_rv64_note_case(
        "rv64_note_spend_elf_real_mojo",
        &elf,
        &witness.ram_pairs,
        &witness.output_layout_words,
        400_000,
        &mojo_backend,
    );
}

#[test]
#[ignore = "slow RV64IM note-spend ELF CPU vs strict Mojo parity repro"]
fn test_rv64_note_spend_from_elf_real_mojo_backend_matches_cpu() {
    let elf = rv64_guest::build_note_spend_rv64im_elf().expect("build RV64IM note guest ELF");
    let witness = note_spend_fixture::build_note_spend_fixture_witness();
    let library = build_real_mojo_library();
    let mojo_backend =
        ProverComputeBackend::Mojo(MojoBackendConfig::new(required_accelerator_api()).with_library_path(library));

    let mut cpu = prove_rv64_note_case(
        "rv64_note_spend_elf_cpu_parity",
        &elf,
        &witness.ram_pairs,
        &witness.output_layout_words,
        400_000,
        &ProverComputeBackend::Cpu,
    );
    let cpu_proof = serde_json::to_vec(cpu.run.proof()).expect("serialize CPU note-spend proof");
    cpu.run
        .verify()
        .unwrap_or_else(|e| panic!("rv64_note_spend_elf_cpu_parity: verify failed: {e}"));

    let mut mojo = prove_rv64_note_case(
        "rv64_note_spend_elf_real_mojo_parity",
        &elf,
        &witness.ram_pairs,
        &witness.output_layout_words,
        400_000,
        &mojo_backend,
    );
    let mojo_proof = serde_json::to_vec(mojo.run.proof()).expect("serialize strict Mojo note-spend proof");
    mojo.run
        .verify()
        .unwrap_or_else(|e| panic!("rv64_note_spend_elf_real_mojo_parity: verify failed: {e}"));

    assert_eq!(
        cpu.run.trace_len(),
        mojo.run.trace_len(),
        "note-spend trace length parity"
    );
    assert_eq!(
        cpu.run.fold_count(),
        mojo.run.fold_count(),
        "note-spend fold count parity"
    );
    assert_eq!(cpu_proof, mojo_proof, "note-spend CPU/strict-Mojo proof parity");
}

use std::ffi::OsString;
use std::hint::black_box;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::OnceLock;
use std::time::{Duration, Instant};

use neo_gpu::{
    connect, DeviceApi, FlatK, FlatRq, MojoBackendConfig, MojoOperationCounters, MojoSession,
    POSEIDON2_STATE_WIDTH,
};

const BENCH_REPEATS: usize = 5;
const BENCH_MIN_ITERS: usize = 5;
const POSEIDON_TARGET_ITEMS: usize = 1 << 19;
const RQ_TARGET_ITEMS: usize = 1 << 15;
const SUPERNEO_TARGET_ITEMS: usize = 1 << 14;
const RQ_ACCUMULATE_GROUP_SIZE: usize = 8;

#[cfg(target_os = "macos")]
fn required_accelerator_api() -> DeviceApi {
    DeviceApi::Metal
}

#[cfg(not(target_os = "macos"))]
fn required_accelerator_api() -> DeviceApi {
    DeviceApi::Cuda
}

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

fn median_duration(mut samples: Vec<Duration>) -> Duration {
    samples.sort_unstable();
    samples[samples.len() / 2]
}

fn iter_count_for_target(work_items: usize, target_total_items: usize) -> usize {
    let work_items = work_items.max(1);
    let target = target_total_items.max(work_items);
    (target / work_items).max(BENCH_MIN_ITERS)
}

fn fmt_duration(d: Duration) -> String {
    if d.as_secs_f64() < 1.0 {
        format!("{:.3}ms", d.as_secs_f64() * 1000.0)
    } else {
        format!("{:.3}s", d.as_secs_f64())
    }
}

fn fmt_speedup(cpu: Duration, gpu: Duration) -> String {
    if gpu.is_zero() {
        return "inf".to_string();
    }
    format!("{:.2}x", cpu.as_secs_f64() / gpu.as_secs_f64())
}

fn ns_per_item(elapsed: Duration, total_items: usize) -> u128 {
    if total_items == 0 {
        return 0;
    }
    elapsed.as_nanos() / total_items as u128
}

fn bench_median(mut f: impl FnMut()) -> Duration {
    f();
    let mut samples = Vec::with_capacity(BENCH_REPEATS);
    for _ in 0..BENCH_REPEATS {
        let started = Instant::now();
        f();
        samples.push(started.elapsed());
    }
    median_duration(samples)
}

fn sample_poseidon_states(num_states: usize) -> Vec<[u64; POSEIDON2_STATE_WIDTH]> {
    (0..num_states)
        .map(|state_idx| {
            let seed = state_idx as u64 * 31;
            [
                seed + 3,
                seed + 5,
                seed + 7,
                seed + 11,
                seed + 13,
                seed + 17,
                seed + 19,
                seed + 23,
            ]
        })
        .collect()
}

fn sample_rq(seed: u64) -> FlatRq {
    FlatRq {
        coeffs: std::array::from_fn(|i| seed.wrapping_mul(17).wrapping_add((i as u64) * 9 + 3)),
    }
}

fn sample_rq_pair_batches(pair_count: usize) -> (Vec<FlatRq>, Vec<FlatRq>) {
    let lhs = (0..pair_count)
        .map(|i| sample_rq(11 + (i as u64) * 13))
        .collect();
    let rhs = (0..pair_count)
        .map(|i| sample_rq(23 + (i as u64) * 19))
        .collect();
    (lhs, rhs)
}

fn sample_slot_offsets(pair_count: usize, group_size: usize) -> Vec<u64> {
    assert_eq!(pair_count % group_size, 0, "pair_count must be divisible by group_size");
    let slot_count = pair_count / group_size;
    (0..=slot_count)
        .map(|slot_idx| (slot_idx * group_size) as u64)
        .collect()
}

fn sample_bar_blocks(num_blocks: usize) -> Vec<[u64; 54]> {
    (0..num_blocks)
        .map(|blk| std::array::from_fn(|i| 101 + (blk as u64) * 29 + (i as u64) * 7))
        .collect()
}

fn sample_z(len: usize) -> Vec<FlatK> {
    (0..len)
        .map(|i| FlatK {
            re: 211 + (i as u64) * 17,
            im: 307 + (i as u64) * 19,
        })
        .collect()
}

fn bench_poseidon_batch(session: &MojoSession, seed_states: &[[u64; POSEIDON2_STATE_WIDTH]], iters: usize) -> Duration {
    let mut states = seed_states.to_vec();
    bench_median(|| {
        for _ in 0..iters {
            states.copy_from_slice(seed_states);
            session
                .permute_poseidon2_batch_u64x8(states.as_mut_slice())
                .expect("poseidon2 batch");
            black_box(&states);
        }
    })
}

fn bench_rq_mul_batch(session: &MojoSession, lhs: &[FlatRq], rhs: &[FlatRq], iters: usize) -> Duration {
    bench_median(|| {
        for _ in 0..iters {
            let out = session.rq_mul_batch_u64x54(lhs, rhs).expect("rq mul batch");
            black_box(out);
        }
    })
}

fn bench_rq_accumulate_batch(
    session: &MojoSession,
    lhs: &[FlatRq],
    rhs: &[FlatRq],
    slot_offsets: &[u64],
    iters: usize,
) -> Duration {
    bench_median(|| {
        for _ in 0..iters {
            let out = session
                .rq_accumulate_batch_u64x54(lhs, rhs, slot_offsets)
                .expect("rq accumulate batch");
            black_box(out);
        }
    })
}

fn bench_superneo_row_dot(session: &MojoSession, bar_blocks: &[[u64; 54]], z: &[FlatK], iters: usize) -> Duration {
    bench_median(|| {
        for _ in 0..iters {
            let out = session
                .superneo_row_dot_blocks(bar_blocks, z)
                .expect("superneo row dot blocks");
            black_box(out);
        }
    })
}

fn bench_prepared_rq_mul_batch(session: &MojoSession, lhs: &[FlatRq], rhs: &[FlatRq], iters: usize) -> Duration {
    let prepared = session
        .prepare_rq_mul_batch_u64x54(lhs, rhs)
        .expect("prepare rq mul batch");
    bench_median(|| {
        for _ in 0..iters {
            prepared.execute().expect("execute prepared rq mul batch");
        }
        let out = prepared.read().expect("read prepared rq mul batch");
        black_box(out);
    })
}

fn bench_prepared_rq_accumulate_batch(
    session: &MojoSession,
    lhs: &[FlatRq],
    rhs: &[FlatRq],
    slot_offsets: &[u64],
    iters: usize,
) -> Duration {
    let prepared = session
        .prepare_rq_accumulate_batch_u64x54(lhs, rhs, slot_offsets)
        .expect("prepare rq accumulate batch");
    bench_median(|| {
        for _ in 0..iters {
            prepared
                .execute()
                .expect("execute prepared rq accumulate batch");
        }
        let out = prepared.read().expect("read prepared rq accumulate batch");
        black_box(out);
    })
}

fn bench_prepared_superneo_row_dot(
    session: &MojoSession,
    bar_blocks: &[[u64; 54]],
    z: &[FlatK],
    iters: usize,
) -> Duration {
    let prepared = session
        .prepare_superneo_row_dot_blocks(bar_blocks, z)
        .expect("prepare superneo row dot");
    bench_median(|| {
        for _ in 0..iters {
            prepared.execute().expect("execute prepared superneo row dot");
        }
        let out = prepared.read_single().expect("read prepared superneo row dot");
        black_box(out);
    })
}

fn print_header(api: DeviceApi) {
    println!();
    println!("==== mojo_primitive_perf ({api:?}) ====");
    println!(
        "{:<28} {:>14} {:>8} {:>12} {:>12} {:>12} {:>12} {:>10}",
        "primitive",
        "workload",
        "iters",
        "cpu",
        "gpu",
        "cpu ns/item",
        "gpu ns/item",
        "speedup",
    );
    println!("{:-<122}", "");
}

fn print_row(
    primitive: &str,
    workload: &str,
    iters: usize,
    work_items: usize,
    cpu_elapsed: Duration,
    gpu_elapsed: Duration,
) {
    let total_items = work_items.saturating_mul(iters);
    println!(
        "{:<28} {:>14} {:>8} {:>12} {:>12} {:>12} {:>12} {:>10}",
        primitive,
        workload,
        iters,
        fmt_duration(cpu_elapsed),
        fmt_duration(gpu_elapsed),
        ns_per_item(cpu_elapsed, total_items),
        ns_per_item(gpu_elapsed, total_items),
        fmt_speedup(cpu_elapsed, gpu_elapsed),
    );
}

fn print_diag(label: &str, counters: &MojoOperationCounters) {
    println!(
        "  {:<25} accel={} cpu={} fallback={} resident(p/e/r)={}/{}/{} h2d={}B d2h={}B",
        label,
        counters.accelerator_calls,
        counters.cpu_calls,
        counters.host_fallback_calls,
        counters.resident_prepare_calls,
        counters.resident_execute_calls,
        counters.resident_read_calls,
        counters.host_to_device_bytes,
        counters.device_to_host_bytes,
    );
}

#[test]
#[ignore = "perf-style benchmark: run with `cargo test -p neo-gpu --release --test primitive_perf -- --ignored --nocapture report_real_mojo_primitive_perf`"]
fn report_real_mojo_primitive_perf() {
    let library_path = build_real_mojo_library();
    let cpu_session = connect(&MojoBackendConfig::new(DeviceApi::Cpu).with_library_path(library_path))
        .expect("open real Mojo CPU session");
    let Ok(gpu_session) = connect(
        &MojoBackendConfig::new(required_accelerator_api()).with_library_path(library_path),
    ) else {
        eprintln!(
            "skipping: real Mojo {:?} session unavailable",
            required_accelerator_api()
        );
        return;
    };

    print_header(gpu_session.device_api());

    for &num_states in &[512usize, 4096usize] {
        let seed_states = sample_poseidon_states(num_states);
        let mut cpu_check = seed_states.clone();
        cpu_session
            .permute_poseidon2_batch_u64x8(cpu_check.as_mut_slice())
            .expect("cpu poseidon parity");
        let mut gpu_check = seed_states.clone();
        gpu_session
            .permute_poseidon2_batch_u64x8(gpu_check.as_mut_slice())
            .expect("gpu poseidon parity");
        assert_eq!(gpu_check, cpu_check, "poseidon parity batch={num_states}");

        let iters = iter_count_for_target(num_states, POSEIDON_TARGET_ITEMS);
        cpu_session.reset_diagnostics();
        let cpu_elapsed = bench_poseidon_batch(&cpu_session, seed_states.as_slice(), iters);
        let cpu_diag = cpu_session.diagnostics_snapshot();
        gpu_session.reset_diagnostics();
        let gpu_elapsed = bench_poseidon_batch(&gpu_session, seed_states.as_slice(), iters);
        let gpu_diag = gpu_session.diagnostics_snapshot();

        assert!(cpu_diag.poseidon2_batch.cpu_calls > 0, "cpu poseidon benchmark should stay on CPU");
        assert!(
            gpu_diag.poseidon2_batch.accelerator_calls > 0,
            "gpu poseidon benchmark should exercise the accelerator"
        );
        print_row(
            "poseidon2_batch_u64x8",
            &format!("states={num_states}"),
            iters,
            num_states,
            cpu_elapsed,
            gpu_elapsed,
        );
        print_diag("cpu/compat", &cpu_diag.poseidon2_batch);
        print_diag("gpu/compat", &gpu_diag.poseidon2_batch);
    }

    for &pair_count in &[1024usize, 4096usize] {
        let (lhs, rhs) = sample_rq_pair_batches(pair_count);
        let cpu_check = cpu_session
            .rq_mul_batch_u64x54(lhs.as_slice(), rhs.as_slice())
            .expect("cpu rq mul parity");
        let gpu_check = gpu_session
            .rq_mul_batch_u64x54(lhs.as_slice(), rhs.as_slice())
            .expect("gpu rq mul parity");
        assert_eq!(gpu_check, cpu_check, "rq mul parity pairs={pair_count}");

        let iters = iter_count_for_target(pair_count, RQ_TARGET_ITEMS);
        cpu_session.reset_diagnostics();
        let cpu_elapsed = bench_rq_mul_batch(&cpu_session, lhs.as_slice(), rhs.as_slice(), iters);
        let cpu_diag = cpu_session.diagnostics_snapshot();
        gpu_session.reset_diagnostics();
        let gpu_elapsed = bench_rq_mul_batch(&gpu_session, lhs.as_slice(), rhs.as_slice(), iters);
        let gpu_diag = gpu_session.diagnostics_snapshot();

        assert!(cpu_diag.rq_mul.cpu_calls > 0, "cpu rq benchmark should stay on CPU");
        assert!(
            gpu_diag.rq_mul.accelerator_calls > 0,
            "gpu rq benchmark should exercise the accelerator"
        );
        print_row(
            "rq_mul_batch_u64x54/compat",
            &format!("pairs={pair_count}"),
            iters,
            pair_count,
            cpu_elapsed,
            gpu_elapsed,
        );
        print_diag("cpu/compat", &cpu_diag.rq_mul);
        print_diag("gpu/compat", &gpu_diag.rq_mul);

        if cpu_session.supports_rq_prepared_api() && gpu_session.supports_rq_prepared_api() {
            let cpu_prepared = cpu_session
                .prepare_rq_mul_batch_u64x54(lhs.as_slice(), rhs.as_slice())
                .expect("cpu prepare rq mul parity");
            cpu_prepared.execute().expect("cpu execute prepared rq mul");
            let cpu_resident_check = cpu_prepared.read().expect("cpu read prepared rq mul");
            let gpu_prepared = gpu_session
                .prepare_rq_mul_batch_u64x54(lhs.as_slice(), rhs.as_slice())
                .expect("gpu prepare rq mul parity");
            gpu_prepared.execute().expect("gpu execute prepared rq mul");
            let gpu_resident_check = gpu_prepared.read().expect("gpu read prepared rq mul");
            assert_eq!(cpu_resident_check, cpu_check, "cpu resident rq mul parity pairs={pair_count}");
            assert_eq!(gpu_resident_check, cpu_check, "gpu resident rq mul parity pairs={pair_count}");

            cpu_session.reset_diagnostics();
            let cpu_resident_elapsed =
                bench_prepared_rq_mul_batch(&cpu_session, lhs.as_slice(), rhs.as_slice(), iters);
            let cpu_resident_diag = cpu_session.diagnostics_snapshot();
            gpu_session.reset_diagnostics();
            let gpu_resident_elapsed =
                bench_prepared_rq_mul_batch(&gpu_session, lhs.as_slice(), rhs.as_slice(), iters);
            let gpu_resident_diag = gpu_session.diagnostics_snapshot();

            print_row(
                "rq_mul_batch_u64x54/resident",
                &format!("pairs={pair_count}"),
                iters,
                pair_count,
                cpu_resident_elapsed,
                gpu_resident_elapsed,
            );
            print_diag("cpu/resident", &cpu_resident_diag.rq_mul);
            print_diag("gpu/resident", &gpu_resident_diag.rq_mul);
        }

        let slot_offsets = sample_slot_offsets(pair_count, RQ_ACCUMULATE_GROUP_SIZE);
        let cpu_acc = cpu_session
            .rq_accumulate_batch_u64x54(lhs.as_slice(), rhs.as_slice(), slot_offsets.as_slice())
            .expect("cpu rq accumulate parity");
        let gpu_acc = gpu_session
            .rq_accumulate_batch_u64x54(lhs.as_slice(), rhs.as_slice(), slot_offsets.as_slice())
            .expect("gpu rq accumulate parity");
        assert_eq!(gpu_acc, cpu_acc, "rq accumulate parity pairs={pair_count}");

        let iters = iter_count_for_target(pair_count, RQ_TARGET_ITEMS);
        cpu_session.reset_diagnostics();
        let cpu_elapsed = bench_rq_accumulate_batch(
            &cpu_session,
            lhs.as_slice(),
            rhs.as_slice(),
            slot_offsets.as_slice(),
            iters,
        );
        let cpu_diag = cpu_session.diagnostics_snapshot();
        gpu_session.reset_diagnostics();
        let gpu_elapsed = bench_rq_accumulate_batch(
            &gpu_session,
            lhs.as_slice(),
            rhs.as_slice(),
            slot_offsets.as_slice(),
            iters,
        );
        let gpu_diag = gpu_session.diagnostics_snapshot();

        assert!(
            cpu_diag.rq_mul.cpu_calls > 0,
            "cpu rq_accumulate benchmark should stay on CPU"
        );
        assert!(
            gpu_diag.rq_mul.accelerator_calls > 0,
            "gpu rq_accumulate benchmark should exercise the accelerator"
        );
        print_row(
            "rq_accumulate_batch/compat",
            &format!("pairs={pair_count}"),
            iters,
            pair_count,
            cpu_elapsed,
            gpu_elapsed,
        );
        print_diag("cpu/compat", &cpu_diag.rq_mul);
        print_diag("gpu/compat", &gpu_diag.rq_mul);

        if cpu_session.supports_rq_prepared_api() && gpu_session.supports_rq_prepared_api() {
            let cpu_prepared = cpu_session
                .prepare_rq_accumulate_batch_u64x54(lhs.as_slice(), rhs.as_slice(), slot_offsets.as_slice())
                .expect("cpu prepare rq accumulate parity");
            cpu_prepared.execute().expect("cpu execute prepared rq accumulate");
            let cpu_resident_check = cpu_prepared.read().expect("cpu read prepared rq accumulate");
            let gpu_prepared = gpu_session
                .prepare_rq_accumulate_batch_u64x54(lhs.as_slice(), rhs.as_slice(), slot_offsets.as_slice())
                .expect("gpu prepare rq accumulate parity");
            gpu_prepared.execute().expect("gpu execute prepared rq accumulate");
            let gpu_resident_check = gpu_prepared.read().expect("gpu read prepared rq accumulate");
            assert_eq!(
                cpu_resident_check, cpu_acc,
                "cpu resident rq accumulate parity pairs={pair_count}"
            );
            assert_eq!(
                gpu_resident_check, cpu_acc,
                "gpu resident rq accumulate parity pairs={pair_count}"
            );

            cpu_session.reset_diagnostics();
            let cpu_resident_elapsed = bench_prepared_rq_accumulate_batch(
                &cpu_session,
                lhs.as_slice(),
                rhs.as_slice(),
                slot_offsets.as_slice(),
                iters,
            );
            let cpu_resident_diag = cpu_session.diagnostics_snapshot();
            gpu_session.reset_diagnostics();
            let gpu_resident_elapsed = bench_prepared_rq_accumulate_batch(
                &gpu_session,
                lhs.as_slice(),
                rhs.as_slice(),
                slot_offsets.as_slice(),
                iters,
            );
            let gpu_resident_diag = gpu_session.diagnostics_snapshot();

            print_row(
                "rq_accumulate_batch/resident",
                &format!("pairs={pair_count}"),
                iters,
                pair_count,
                cpu_resident_elapsed,
                gpu_resident_elapsed,
            );
            print_diag("cpu/resident", &cpu_resident_diag.rq_mul);
            print_diag("gpu/resident", &gpu_resident_diag.rq_mul);
        }
    }

    for &num_blocks in &[512usize, 2048usize] {
        let bar_blocks = sample_bar_blocks(num_blocks);
        let z = sample_z(num_blocks * 54);
        let cpu_check = cpu_session
            .superneo_row_dot_blocks(bar_blocks.as_slice(), z.as_slice())
            .expect("cpu superneo parity");
        let gpu_check = gpu_session
            .superneo_row_dot_blocks(bar_blocks.as_slice(), z.as_slice())
            .expect("gpu superneo parity");
        assert_eq!(gpu_check, cpu_check, "superneo parity blocks={num_blocks}");

        let iters = iter_count_for_target(num_blocks, SUPERNEO_TARGET_ITEMS);
        cpu_session.reset_diagnostics();
        let cpu_elapsed = bench_superneo_row_dot(&cpu_session, bar_blocks.as_slice(), z.as_slice(), iters);
        let cpu_diag = cpu_session.diagnostics_snapshot();
        gpu_session.reset_diagnostics();
        let gpu_elapsed = bench_superneo_row_dot(&gpu_session, bar_blocks.as_slice(), z.as_slice(), iters);
        let gpu_diag = gpu_session.diagnostics_snapshot();

        assert!(
            cpu_diag.superneo.cpu_calls > 0,
            "cpu superneo benchmark should stay on CPU"
        );
        assert!(
            gpu_diag.superneo.accelerator_calls > 0,
            "gpu superneo benchmark should exercise the accelerator"
        );
        print_row(
            "superneo_row_dot_blocks/compat",
            &format!("blocks={num_blocks}"),
            iters,
            num_blocks,
            cpu_elapsed,
            gpu_elapsed,
        );
        print_diag("cpu/compat", &cpu_diag.superneo);
        print_diag("gpu/compat", &gpu_diag.superneo);

        if cpu_session.supports_superneo_prepared_api() && gpu_session.supports_superneo_prepared_api() {
            let cpu_prepared = cpu_session
                .prepare_superneo_row_dot_blocks(bar_blocks.as_slice(), z.as_slice())
                .expect("cpu prepare superneo parity");
            cpu_prepared.execute().expect("cpu execute prepared superneo");
            let cpu_resident_check = cpu_prepared.read_single().expect("cpu read prepared superneo");
            let gpu_prepared = gpu_session
                .prepare_superneo_row_dot_blocks(bar_blocks.as_slice(), z.as_slice())
                .expect("gpu prepare superneo parity");
            gpu_prepared.execute().expect("gpu execute prepared superneo");
            let gpu_resident_check = gpu_prepared.read_single().expect("gpu read prepared superneo");
            assert_eq!(cpu_resident_check, cpu_check, "cpu resident superneo parity blocks={num_blocks}");
            assert_eq!(gpu_resident_check, cpu_check, "gpu resident superneo parity blocks={num_blocks}");

            cpu_session.reset_diagnostics();
            let cpu_resident_elapsed =
                bench_prepared_superneo_row_dot(&cpu_session, bar_blocks.as_slice(), z.as_slice(), iters);
            let cpu_resident_diag = cpu_session.diagnostics_snapshot();
            gpu_session.reset_diagnostics();
            let gpu_resident_elapsed =
                bench_prepared_superneo_row_dot(&gpu_session, bar_blocks.as_slice(), z.as_slice(), iters);
            let gpu_resident_diag = gpu_session.diagnostics_snapshot();

            print_row(
                "superneo_row_dot_blocks/resident",
                &format!("blocks={num_blocks}"),
                iters,
                num_blocks,
                cpu_resident_elapsed,
                gpu_resident_elapsed,
            );
            print_diag("cpu/resident", &cpu_resident_diag.superneo);
            print_diag("gpu/resident", &gpu_resident_diag.superneo);
        }
    }

    println!("{:-<122}", "");
}

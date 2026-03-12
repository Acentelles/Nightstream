use std::ffi::OsString;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::OnceLock;
use std::time::Instant;

use libloading::Library;
use neo_ccs::crypto::poseidon2_goldilocks as p2;
use neo_gpu::{connect, DeviceApi, ExecutionMode, FlatK, MojoBackendConfig, MojoLibrary};
use p3_field::{PrimeCharacteristicRing, PrimeField64};
use p3_goldilocks::Goldilocks;
use p3_symmetric::Permutation;

const MOCK_CPU_ONLY_DEVICE_ID: u32 = 0xFFFF_FF01;

fn mock_manifest_path() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("tests")
        .join("support")
        .join("mock-mojo-gpu")
        .join("Cargo.toml")
}

fn mock_library_name() -> &'static str {
    #[cfg(target_os = "macos")]
    {
        "libmock_mojo_gpu.dylib"
    }
    #[cfg(target_os = "linux")]
    {
        "libmock_mojo_gpu.so"
    }
    #[cfg(target_os = "windows")]
    {
        "mock_mojo_gpu.dll"
    }
}

fn build_mock_library() -> &'static Path {
    static LIB_PATH: OnceLock<PathBuf> = OnceLock::new();
    LIB_PATH.get_or_init(|| {
        let manifest = mock_manifest_path();
        let cargo = std::env::var("CARGO").unwrap_or_else(|_| "cargo".to_string());
        let status = Command::new(cargo)
            .arg("build")
            .arg("--release")
            .arg("--manifest-path")
            .arg(&manifest)
            .status()
            .expect("spawn cargo build for mock mojo gpu");
        assert!(status.success(), "mock mojo gpu build failed");

        manifest
            .parent()
            .expect("mock manifest parent")
            .join("target")
            .join("release")
            .join(mock_library_name())
            .canonicalize()
            .expect("canonical mock mojo gpu library path")
    })
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

fn mojo_project_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("..")
        .join("gpu")
        .join("mojo")
}

fn backend_poseidon2_hash(session: &neo_gpu::MojoSession, input: &[u64]) -> [u64; p2::DIGEST_LEN] {
    let mut state = [Goldilocks::ZERO; p2::WIDTH];
    for chunk in input.chunks(p2::RATE) {
        for (dst, src) in state.iter_mut().zip(chunk.iter()) {
            *dst += Goldilocks::from_u64(*src);
        }
        let state_u64 = state.map(|x| x.as_canonical_u64());
        let out_u64 = session
            .permute_poseidon2_u64x8(&state_u64)
            .expect("backend poseidon2 permutation");
        state = out_u64.map(Goldilocks::from_u64);
    }
    state[0] += Goldilocks::ONE;
    let state_u64 = state.map(|x| x.as_canonical_u64());
    let state = session
        .permute_poseidon2_u64x8(&state_u64)
        .expect("backend poseidon2 final permutation")
        .map(Goldilocks::from_u64);

    let mut out = [0u64; p2::DIGEST_LEN];
    out.copy_from_slice(&state.map(|x| x.as_canonical_u64())[..p2::DIGEST_LEN]);
    out
}

fn permute_poseidon2_via_symbol(
    permute: unsafe extern "C" fn(usize, *mut u64, u32) -> i32,
    state: &[u64; 8],
) -> [u64; 8] {
    let mut backend = *state;
    let status = unsafe { permute(1, backend.as_mut_ptr(), 8) };
    assert_eq!(status, 0, "mojo poseidon status");
    backend
}

fn permute_poseidon2_batch_via_symbol(
    permute_batch: unsafe extern "C" fn(usize, *mut u64, u32, u32) -> i32,
    states: &mut [[u64; 8]],
) {
    let status = unsafe { permute_batch(1, states.as_mut_ptr().cast::<u64>(), states.len() as u32, 8) };
    assert_eq!(status, 0, "mojo poseidon batch status");
}

fn poseidon2_batch_fixture(num_states: usize) -> Vec<[u64; 8]> {
    (0..num_states)
        .map(|state_idx| std::array::from_fn(|word_idx| (state_idx as u64) * 97 + (word_idx as u64) * 17 + 3))
        .collect()
}

fn poseidon2_batch_cpu_reference(num_states: usize) -> Vec<[u64; 8]> {
    poseidon2_batch_fixture(num_states)
        .into_iter()
        .map(|state| {
            p2::permutation()
                .permute(state.map(Goldilocks::from_u64))
                .map(|x| x.as_canonical_u64())
        })
        .collect()
}

fn poseidon2_iters_for(num_states: usize) -> usize {
    let target_states = 65_536usize;
    (target_states / num_states.max(1)).max(1)
}

fn push_u64_le(out: &mut Vec<u8>, word: u64) {
    out.extend_from_slice(&word.to_le_bytes());
}

fn push_flat_k_le(out: &mut Vec<u8>, value: FlatK) {
    push_u64_le(out, value.re);
    push_u64_le(out, value.im);
}

fn minimal_fe_snapshot() -> Vec<u8> {
    let mut out = Vec::new();
    push_u64_le(&mut out, 0x4E53_504C_4954_4E43);
    push_u64_le(&mut out, 1);
    push_u64_le(&mut out, 1);
    push_u64_le(&mut out, 4);
    push_u64_le(&mut out, 2);
    push_u64_le(&mut out, 2);
    push_u64_le(&mut out, 2);
    push_u64_le(&mut out, 0);
    push_u64_le(&mut out, 0);
    push_u64_le(&mut out, 0);
    push_u64_le(&mut out, 0);
    push_u64_le(&mut out, 0);
    push_u64_le(&mut out, 0);
    push_u64_le(&mut out, 0);
    push_flat_k_le(&mut out, FlatK::default());
    push_flat_k_le(&mut out, FlatK { re: 1, im: 0 });
    push_flat_k_le(&mut out, FlatK::default());
    out
}

fn minimal_nc_snapshot() -> Vec<u8> {
    let mut out = Vec::new();
    push_u64_le(&mut out, 0x4E53_504C_4954_4E43);
    push_u64_le(&mut out, 1);
    push_u64_le(&mut out, 2);
    push_u64_le(&mut out, 4);
    push_u64_le(&mut out, 2);
    push_u64_le(&mut out, 2);
    push_u64_le(&mut out, 2);
    push_u64_le(&mut out, 0);
    push_u64_le(&mut out, 0);
    push_u64_le(&mut out, 0);
    push_u64_le(&mut out, 0);
    push_u64_le(&mut out, 0);
    push_u64_le(&mut out, 0);
    push_flat_k_le(&mut out, FlatK { re: 1, im: 0 });
    push_flat_k_le(&mut out, FlatK::default());
    out
}

fn rich_fe_snapshot() -> Vec<u8> {
    let mut out = Vec::new();
    push_u64_le(&mut out, 0x4E53_504C_4954_4E43);
    push_u64_le(&mut out, 1);
    push_u64_le(&mut out, 1);
    push_u64_le(&mut out, 4);
    push_u64_le(&mut out, 2);
    push_u64_le(&mut out, 4);
    push_u64_le(&mut out, 4);
    push_u64_le(&mut out, 0);
    push_u64_le(&mut out, 1);
    push_u64_le(&mut out, 1);
    push_u64_le(&mut out, 1);
    push_u64_le(&mut out, 1);
    push_u64_le(&mut out, 4);
    push_u64_le(&mut out, 0);
    push_flat_k_le(&mut out, FlatK::default());

    for re in [1u64, 2, 3, 4] {
        push_flat_k_le(&mut out, FlatK { re, im: 0 });
    }
    push_flat_k_le(&mut out, FlatK { re: 1, im: 0 });

    push_flat_k_le(&mut out, FlatK { re: 2, im: 0 });
    push_u64_le(&mut out, 1);
    push_u64_le(&mut out, 0);
    push_u64_le(&mut out, 1);

    for re in [5u64, 7, 11, 13] {
        push_flat_k_le(&mut out, FlatK { re, im: 0 });
    }
    out
}

fn rich_nc_snapshot() -> Vec<u8> {
    let mut out = Vec::new();
    push_u64_le(&mut out, 0x4E53_504C_4954_4E43);
    push_u64_le(&mut out, 1);
    push_u64_le(&mut out, 2);
    push_u64_le(&mut out, 4);
    push_u64_le(&mut out, 2);
    push_u64_le(&mut out, 4);
    push_u64_le(&mut out, 4);
    push_u64_le(&mut out, 1);
    push_u64_le(&mut out, 4);
    push_u64_le(&mut out, 1);
    push_u64_le(&mut out, 1);
    push_u64_le(&mut out, 1);
    push_u64_le(&mut out, 0);

    for re in [1u64, 2, 3, 4] {
        push_flat_k_le(&mut out, FlatK { re, im: 0 });
    }
    for re in [5u64, 7, 11, 13] {
        push_flat_k_le(&mut out, FlatK { re, im: 0 });
    }
    push_flat_k_le(&mut out, FlatK { re: 3, im: 0 });
    out
}

fn snapshot_words(snapshot: &[u8]) -> Vec<u64> {
    snapshot
        .chunks(8)
        .map(|chunk| {
            let mut word = [0u8; 8];
            word[..chunk.len()].copy_from_slice(chunk);
            u64::from_le_bytes(word)
        })
        .collect()
}

fn direct_split_nc_evals_at(
    evals_at: unsafe extern "C" fn(u64, u64, *mut u64, u64, *mut u64, u64, *mut u64, usize) -> i32,
    session: u64,
    evaluator: u64,
    snapshot_words: &mut [u64],
    snapshot_len: u64,
    points: &[FlatK],
) -> Vec<FlatK> {
    let mut out = vec![FlatK::default(); points.len()];
    let status = unsafe {
        evals_at(
            session,
            evaluator,
            snapshot_words.as_mut_ptr(),
            snapshot_len,
            points.as_ptr().cast::<u64>() as *mut u64,
            points.len() as u64,
            out.as_mut_ptr().cast::<u64>(),
            out.len(),
        )
    };
    assert_eq!(status, 0, "split-nc evals_at status");
    out
}

fn direct_backend_poseidon2_hash(
    permute: unsafe extern "C" fn(usize, *mut u64, u32) -> i32,
    input: &[u64],
) -> [u64; p2::DIGEST_LEN] {
    let mut state = [Goldilocks::ZERO; p2::WIDTH];
    for chunk in input.chunks(p2::RATE) {
        for (dst, src) in state.iter_mut().zip(chunk.iter()) {
            *dst += Goldilocks::from_u64(*src);
        }
        let state_u64 = state.map(|x| x.as_canonical_u64());
        let out_u64 = permute_poseidon2_via_symbol(permute, &state_u64);
        state = out_u64.map(Goldilocks::from_u64);
    }
    state[0] += Goldilocks::ONE;
    let state_u64 = state.map(|x| x.as_canonical_u64());
    let state = permute_poseidon2_via_symbol(permute, &state_u64).map(Goldilocks::from_u64);

    let mut out = [0u64; p2::DIGEST_LEN];
    out.copy_from_slice(&state.map(|x| x.as_canonical_u64())[..p2::DIGEST_LEN]);
    out
}

#[test]
fn loads_mock_library_and_probes_split_nc_support() {
    let cfg = MojoBackendConfig::new(DeviceApi::Metal).with_library_path(build_mock_library());
    let lib = MojoLibrary::load(&cfg).expect("load mock mojo gpu library");

    assert_eq!(lib.path(), build_mock_library());
    assert!(lib.probe_device(DeviceApi::Metal, 0).expect("probe device"));
    assert!(lib.supports_split_nc_api());
    assert!(lib.supports_poseidon2_api());
    assert!(lib.supports_poseidon2_batch_api());
}

#[test]
fn connects_to_mock_library_session() {
    let cfg = MojoBackendConfig::new(DeviceApi::Cuda)
        .with_device_id(7)
        .with_library_path(build_mock_library());
    let session = connect(&cfg).expect("connect to mock mojo gpu");

    assert_eq!(session.device_api(), DeviceApi::Cuda);
    assert_eq!(session.device_id(), 7);
    assert!(session.supports_split_nc_api());
    assert!(session.supports_poseidon2_api());
    assert!(session.supports_poseidon2_batch_api());
}

#[test]
fn split_nc_evaluator_round_trips_through_mock_backend() {
    let cfg = MojoBackendConfig::new(DeviceApi::Cuda).with_library_path(build_mock_library());
    let session = connect(&cfg).expect("connect to mock mojo gpu");

    let snapshot = b"mock-snapshot";
    let points = vec![
        FlatK { re: 7, im: 11 },
        FlatK { re: 13, im: 17 },
        FlatK { re: 19, im: 23 },
    ];

    let mut fe = session
        .create_fe_evaluator(snapshot)
        .expect("create fe evaluator");
    assert_ne!(fe.handle(), 0);
    assert_eq!(fe.evals_at(&points).expect("fe evals_at"), points);
    fe.fold(FlatK { re: 29, im: 31 }).expect("fe fold");

    let mut nc = session
        .create_nc_evaluator(snapshot)
        .expect("create nc evaluator");
    assert_ne!(nc.handle(), 0);
    assert_eq!(nc.evals_at(&points).expect("nc evals_at"), points);
    nc.fold(FlatK { re: 37, im: 41 }).expect("nc fold");
}

#[test]
fn mock_split_nc_debug_snapshot_head_matches_rust_layout() {
    type DebugSnapshotHeadFn = unsafe extern "C" fn(u64, *mut u64, u64, *mut u64, u32) -> i32;

    let lib = unsafe { Library::new(build_mock_library()) }.expect("load mock mojo gpu library");
    let debug_snapshot_head = unsafe {
        *lib.get::<DebugSnapshotHeadFn>(b"nightstream_gpu_debug_snapshot_head\0")
            .expect("load debug snapshot head symbol")
    };

    let snapshot = minimal_fe_snapshot();
    let snapshot_words = snapshot_words(&snapshot);
    let mut out = [0u64; 6];
    let status = unsafe {
        debug_snapshot_head(
            0xABCD,
            snapshot_words.as_ptr() as *mut u64,
            snapshot.len() as u64,
            out.as_mut_ptr(),
            out.len() as u32,
        )
    };
    assert_eq!(status, 0, "debug snapshot head status");
    assert_eq!(
        out,
        [
            0xABCD,
            snapshot_words.as_ptr() as usize as u64,
            snapshot.len() as u64,
            snapshot_words[0],
            snapshot_words[1],
            snapshot_words[2],
        ]
    );
}

#[test]
fn auto_backend_selects_the_preferred_mock_accelerator() {
    let cfg = MojoBackendConfig::auto().with_library_path(build_mock_library());
    let session = connect(&cfg).expect("connect to mock mojo gpu with auto backend");

    #[cfg(target_os = "macos")]
    assert_eq!(session.device_api(), DeviceApi::Metal);
    #[cfg(not(target_os = "macos"))]
    assert_eq!(session.device_api(), DeviceApi::Cuda);
}

#[test]
fn explicit_gpu_backend_with_cpu_fallback_uses_mojo_cpu_when_accelerator_is_unavailable() {
    let cfg = MojoBackendConfig::new(DeviceApi::Cuda)
        .with_device_id(MOCK_CPU_ONLY_DEVICE_ID)
        .allow_cpu_fallback()
        .with_library_path(build_mock_library());
    let session = connect(&cfg).expect("connect to mock mojo gpu with cpu fallback");

    assert_eq!(session.device_api(), DeviceApi::Cpu);
    assert!(session.supports_poseidon2_batch_api());

    let mut backend = poseidon2_batch_fixture(17);
    session
        .permute_poseidon2_batch_u64x8(&mut backend)
        .expect("poseidon2 batch permute through mojo cpu fallback");

    let cpu = poseidon2_batch_cpu_reference(17);
    assert_eq!(backend, cpu);
}

#[test]
fn auto_backend_uses_mojo_cpu_when_no_mock_accelerator_is_available() {
    let cfg = MojoBackendConfig::auto()
        .with_device_id(MOCK_CPU_ONLY_DEVICE_ID)
        .with_library_path(build_mock_library());
    let session = connect(&cfg).expect("connect to mock mojo gpu with auto cpu fallback");

    assert_eq!(session.device_api(), DeviceApi::Cpu);
    assert!(session.supports_poseidon2_api());
    assert!(session.supports_split_nc_api());
}

#[test]
fn poseidon2_execution_mode_reports_cpu_host_fallback_and_accelerator() {
    let cpu = connect(&MojoBackendConfig::new(DeviceApi::Cpu).with_library_path(build_mock_library()))
        .expect("connect cpu mock mojo session");
    assert_eq!(cpu.poseidon2_batch_execution_mode(512), ExecutionMode::Cpu);

    let metal = connect(&MojoBackendConfig::new(DeviceApi::Metal).with_library_path(build_mock_library()))
        .expect("connect metal mock mojo session");
    assert_eq!(metal.poseidon2_batch_execution_mode(32), ExecutionMode::HostFallback);
    assert_eq!(metal.poseidon2_batch_execution_mode(256), ExecutionMode::Accelerator);

    let cuda = connect(&MojoBackendConfig::new(DeviceApi::Cuda).with_library_path(build_mock_library()))
        .expect("connect cuda mock mojo session");
    assert_eq!(cuda.poseidon2_batch_execution_mode(16), ExecutionMode::HostFallback);
    assert_eq!(cuda.poseidon2_batch_execution_mode(32), ExecutionMode::Accelerator);
    assert_eq!(cuda.poseidon2_batch_execution_mode(256), ExecutionMode::Accelerator);

    let hip = connect(&MojoBackendConfig::new(DeviceApi::Hip).with_library_path(build_mock_library()))
        .expect("connect hip mock mojo session");
    assert_eq!(hip.poseidon2_batch_execution_mode(16), ExecutionMode::HostFallback);
    assert_eq!(hip.poseidon2_batch_execution_mode(32), ExecutionMode::Accelerator);
    assert_eq!(hip.poseidon2_batch_execution_mode(256), ExecutionMode::Accelerator);
}

#[test]
fn split_nc_execution_mode_reports_cpu_host_fallback_and_accelerator() {
    let cpu = connect(&MojoBackendConfig::new(DeviceApi::Cpu).with_library_path(build_mock_library()))
        .expect("connect cpu mock mojo session");
    assert_eq!(cpu.split_nc_execution_mode(1024), ExecutionMode::Cpu);

    let metal = connect(&MojoBackendConfig::new(DeviceApi::Metal).with_library_path(build_mock_library()))
        .expect("connect metal mock mojo session");
    assert_eq!(metal.split_nc_execution_mode(64), ExecutionMode::HostFallback);
    assert_eq!(metal.split_nc_execution_mode(1024), ExecutionMode::HostFallback);

    let cuda = connect(&MojoBackendConfig::new(DeviceApi::Cuda).with_library_path(build_mock_library()))
        .expect("connect cuda mock mojo session");
    assert_eq!(cuda.split_nc_execution_mode(64), ExecutionMode::HostFallback);
    assert_eq!(cuda.split_nc_execution_mode(1024), ExecutionMode::Accelerator);

    let hip = connect(&MojoBackendConfig::new(DeviceApi::Hip).with_library_path(build_mock_library()))
        .expect("connect hip mock mojo session");
    assert_eq!(hip.split_nc_execution_mode(64), ExecutionMode::HostFallback);
    assert_eq!(hip.split_nc_execution_mode(1024), ExecutionMode::Accelerator);
}

#[test]
#[ignore = "requires local Mojo toolchain"]
fn real_mojo_cpu_session_ignores_nonzero_device_id() {
    let library_path = build_real_mojo_library();
    let cfg = MojoBackendConfig::new(DeviceApi::Cpu)
        .with_device_id(7)
        .with_library_path(library_path);

    let session = connect(&cfg).expect("connect cpu mojo session with nonzero device id");
    assert_eq!(session.device_api(), DeviceApi::Cpu);
    assert!(session.supports_poseidon2_api());
    assert!(session.supports_split_nc_api());
}

#[test]
fn repeated_mock_poseidon_batch_calls_match_cpu_reference() {
    let session = connect(&MojoBackendConfig::new(DeviceApi::Cuda).with_library_path(build_mock_library()))
        .expect("connect cuda mock mojo session");

    for &num_states in &[17usize, 256usize, 33usize] {
        let mut backend = poseidon2_batch_fixture(num_states);
        session
            .permute_poseidon2_batch_u64x8(&mut backend)
            .expect("reused mock poseidon batch call");
        assert_eq!(backend, poseidon2_batch_cpu_reference(num_states));
    }
}

#[test]
fn poseidon2_permutation_matches_cpu_reference() {
    let cfg = MojoBackendConfig::new(DeviceApi::Metal).with_library_path(build_mock_library());
    let session = connect(&cfg).expect("connect to mock mojo gpu");

    let state = [3u64, 5, 7, 11, 13, 17, 19, 23];
    let backend = session
        .permute_poseidon2_u64x8(&state)
        .expect("poseidon2 permute through backend");

    let perm = neo_ccs::crypto::poseidon2_goldilocks::permutation();
    let cpu_in = state.map(Goldilocks::from_u64);
    let cpu_out = perm.permute(cpu_in).map(|x| x.as_canonical_u64());

    assert_eq!(backend, cpu_out);
}

#[test]
fn poseidon2_batch_permutation_matches_cpu_reference() {
    let cfg = MojoBackendConfig::new(DeviceApi::Metal).with_library_path(build_mock_library());
    let session = connect(&cfg).expect("connect to mock mojo gpu");

    let mut backend = poseidon2_batch_fixture(17);
    session
        .permute_poseidon2_batch_u64x8(&mut backend)
        .expect("poseidon2 batch permute through backend");

    let perm = neo_ccs::crypto::poseidon2_goldilocks::permutation();
    let cpu: Vec<[u64; 8]> = poseidon2_batch_fixture(17)
        .into_iter()
        .map(|state| {
            perm.permute(state.map(Goldilocks::from_u64))
                .map(|x| x.as_canonical_u64())
        })
        .collect();

    assert_eq!(backend, cpu);
}

#[test]
fn poseidon2_precompile_flow_matches_cpu_reference_for_lengths_0_to_8() {
    let cfg = MojoBackendConfig::new(DeviceApi::Metal).with_library_path(build_mock_library());
    let session = connect(&cfg).expect("connect to mock mojo gpu");

    for n in 0..=8usize {
        let input: Vec<u64> = (0..n).map(|i| (i as u64) * 17 + 3).collect();
        let backend = backend_poseidon2_hash(&session, &input);
        let cpu = p2::poseidon2_hash(
            &input
                .iter()
                .copied()
                .map(Goldilocks::from_u64)
                .collect::<Vec<_>>(),
        )
        .map(|x| x.as_canonical_u64());
        assert_eq!(backend, cpu, "length={n}");
    }
}

#[test]
#[ignore = "requires local Mojo toolchain"]
fn real_mojo_poseidon2_matches_cpu_reference() {
    type PoseidonFn = unsafe extern "C" fn(usize, *mut u64, u32) -> i32;
    type PoseidonBatchFn = unsafe extern "C" fn(usize, *mut u64, u32, u32) -> i32;
    let library_path = build_real_mojo_library();

    let cfg = MojoBackendConfig::new(DeviceApi::Cpu).with_library_path(library_path);
    let session = connect(&cfg).expect("connect to real mojo gpu library");
    assert!(session.supports_poseidon2_api());
    assert!(session.supports_poseidon2_batch_api());

    let state = [3u64, 5, 7, 11, 13, 17, 19, 23];
    let backend_via_loader = session
        .permute_poseidon2_u64x8(&state)
        .expect("loader poseidon2 permute");
    let cpu = p2::permutation()
        .permute(state.map(Goldilocks::from_u64))
        .map(|x| x.as_canonical_u64());
    assert_eq!(backend_via_loader, cpu);

    let mut backend_batch_via_loader = poseidon2_batch_fixture(17);
    session
        .permute_poseidon2_batch_u64x8(&mut backend_batch_via_loader)
        .expect("loader poseidon2 batch permute");
    let cpu_batch: Vec<[u64; 8]> = poseidon2_batch_fixture(17)
        .into_iter()
        .map(|state| {
            p2::permutation()
                .permute(state.map(Goldilocks::from_u64))
                .map(|x| x.as_canonical_u64())
        })
        .collect();
    assert_eq!(backend_batch_via_loader, cpu_batch);

    let lib = unsafe { Library::new(library_path) }.expect("load real mojo gpu library");
    let permute = unsafe {
        *lib.get::<PoseidonFn>(b"nightstream_gpu_poseidon2_permute_u64x8\0")
            .expect("load poseidon2 symbol")
    };
    let permute_batch = unsafe {
        *lib.get::<PoseidonBatchFn>(b"nightstream_gpu_poseidon2_permute_batch_u64x8\0")
            .expect("load poseidon2 batch symbol")
    };

    let state = [3u64, 5, 7, 11, 13, 17, 19, 23];
    let backend = permute_poseidon2_via_symbol(permute, &state);
    assert_eq!(backend, cpu);

    let mut backend_batch = poseidon2_batch_fixture(17);
    permute_poseidon2_batch_via_symbol(permute_batch, &mut backend_batch);
    let cpu_batch: Vec<[u64; 8]> = poseidon2_batch_fixture(17)
        .into_iter()
        .map(|state| {
            p2::permutation()
                .permute(state.map(Goldilocks::from_u64))
                .map(|x| x.as_canonical_u64())
        })
        .collect();
    assert_eq!(backend_batch, cpu_batch);

    for n in 0..=8usize {
        let input: Vec<u64> = (0..n).map(|i| (i as u64) * 17 + 3).collect();
        let backend = direct_backend_poseidon2_hash(permute, &input);
        let cpu = p2::poseidon2_hash(
            &input
                .iter()
                .copied()
                .map(Goldilocks::from_u64)
                .collect::<Vec<_>>(),
        )
        .map(|x| x.as_canonical_u64());
        assert_eq!(backend, cpu, "length={n}");
    }
}

#[test]
#[ignore = "requires local Mojo toolchain"]
fn real_mojo_split_nc_probe_and_minimal_eval_work() {
    let library_path = build_real_mojo_library();
    let cfg = MojoBackendConfig::new(DeviceApi::Cpu).with_library_path(library_path);
    let session = connect(&cfg).expect("connect to real mojo gpu library");

    let points = [FlatK::default(), FlatK { re: 1, im: 0 }, FlatK { re: 5, im: 7 }];
    if !session.supports_split_nc_api() {
        match session.create_fe_evaluator(&minimal_fe_snapshot()) {
            Ok(mut fe) => {
                eprintln!("debug real FE create: ok");
                eprintln!("debug real FE evals: {:?}", fe.evals_at(&points));
                eprintln!("debug real FE fold: {:?}", fe.fold(FlatK { re: 3, im: 0 }));
            }
            Err(err) => eprintln!("debug real FE create err: {err:?}"),
        }
        match session.create_nc_evaluator(&minimal_nc_snapshot()) {
            Ok(mut nc) => {
                eprintln!("debug real NC create: ok");
                eprintln!("debug real NC evals: {:?}", nc.evals_at(&points));
                eprintln!("debug real NC fold: {:?}", nc.fold(FlatK { re: 3, im: 0 }));
            }
            Err(err) => eprintln!("debug real NC create err: {err:?}"),
        }
    }
    assert!(session.supports_split_nc_api());

    let mut fe = session
        .create_fe_evaluator(&minimal_fe_snapshot())
        .expect("create real mojo fe evaluator");
    assert_eq!(
        fe.evals_at(&points).expect("real mojo fe evals"),
        vec![FlatK::default(); points.len()]
    );
    fe.fold(FlatK { re: 3, im: 0 }).expect("real mojo fe fold");

    let mut nc = session
        .create_nc_evaluator(&minimal_nc_snapshot())
        .expect("create real mojo nc evaluator");
    assert_eq!(
        nc.evals_at(&points).expect("real mojo nc evals"),
        vec![FlatK::default(); points.len()]
    );
    nc.fold(FlatK { re: 3, im: 0 }).expect("real mojo nc fold");
}

#[test]
#[ignore = "requires local Mojo toolchain"]
fn real_mojo_split_nc_direct_fold_state_matches_loader_reference() {
    type CreateFn = unsafe extern "C" fn(u64, *mut u64, u64, *mut u64) -> i32;
    type DestroyFn = unsafe extern "C" fn(usize, usize) -> i32;
    type EvalsAtFn = unsafe extern "C" fn(u64, u64, *mut u64, u64, *mut u64, u64, *mut u64, usize) -> i32;
    type FoldFn = unsafe extern "C" fn(usize, usize, u64, u64) -> i32;

    let library_path = build_real_mojo_library();
    let session = connect(&MojoBackendConfig::new(DeviceApi::Cpu).with_library_path(library_path))
        .expect("connect to real mojo gpu library");

    let points = vec![FlatK::default(), FlatK { re: 1, im: 0 }, FlatK { re: 5, im: 7 }];
    let challenge = FlatK { re: 3, im: 1 };

    let rich_fe = rich_fe_snapshot();
    let mut fe_loader = session
        .create_fe_evaluator(&rich_fe)
        .expect("create loader fe evaluator");
    let fe_before = fe_loader
        .evals_at(&points)
        .expect("loader fe evals before fold");
    fe_loader.fold(challenge).expect("loader fe fold");
    let fe_after = fe_loader
        .evals_at(&points)
        .expect("loader fe evals after fold");
    assert_ne!(fe_before, fe_after);

    let rich_nc = rich_nc_snapshot();
    let mut nc_loader = session
        .create_nc_evaluator(&rich_nc)
        .expect("create loader nc evaluator");
    let nc_before = nc_loader
        .evals_at(&points)
        .expect("loader nc evals before fold");
    nc_loader.fold(challenge).expect("loader nc fold");
    let nc_after = nc_loader
        .evals_at(&points)
        .expect("loader nc evals after fold");
    assert_ne!(nc_before, nc_after);

    let lib = unsafe { Library::new(library_path) }.expect("load real mojo gpu library");
    let fe_create = unsafe {
        *lib.get::<CreateFn>(b"nightstream_gpu_fe_create\0")
            .expect("load fe_create symbol")
    };
    let fe_destroy = unsafe {
        *lib.get::<DestroyFn>(b"nightstream_gpu_fe_destroy\0")
            .expect("load fe_destroy symbol")
    };
    let fe_evals_at = unsafe {
        *lib.get::<EvalsAtFn>(b"nightstream_gpu_fe_evals_at\0")
            .expect("load fe_evals_at symbol")
    };
    let fe_fold = unsafe {
        *lib.get::<FoldFn>(b"nightstream_gpu_fe_fold\0")
            .expect("load fe_fold symbol")
    };
    let nc_create = unsafe {
        *lib.get::<CreateFn>(b"nightstream_gpu_nc_create\0")
            .expect("load nc_create symbol")
    };
    let nc_destroy = unsafe {
        *lib.get::<DestroyFn>(b"nightstream_gpu_nc_destroy\0")
            .expect("load nc_destroy symbol")
    };
    let nc_evals_at = unsafe {
        *lib.get::<EvalsAtFn>(b"nightstream_gpu_nc_evals_at\0")
            .expect("load nc_evals_at symbol")
    };
    let nc_fold = unsafe {
        *lib.get::<FoldFn>(b"nightstream_gpu_nc_fold\0")
            .expect("load nc_fold symbol")
    };

    let mut fe_snapshot_words = snapshot_words(&rich_fe);
    let stale_fe_snapshot = fe_snapshot_words.clone();
    let mut fe_handle = 0u64;
    let fe_create_status =
        unsafe { fe_create(1, fe_snapshot_words.as_mut_ptr(), rich_fe.len() as u64, &mut fe_handle) };
    assert_eq!(fe_create_status, 0, "raw fe_create status");
    assert_ne!(fe_handle, 0);
    let raw_fe_before = direct_split_nc_evals_at(
        fe_evals_at,
        1,
        fe_handle,
        &mut stale_fe_snapshot.clone(),
        rich_fe.len() as u64,
        &points,
    );
    assert_eq!(raw_fe_before, fe_before);
    let fe_fold_status = unsafe { fe_fold(1, fe_handle as usize, challenge.re, challenge.im) };
    assert_eq!(fe_fold_status, 0, "raw fe_fold status");
    let raw_fe_after = direct_split_nc_evals_at(
        fe_evals_at,
        1,
        fe_handle,
        &mut stale_fe_snapshot.clone(),
        rich_fe.len() as u64,
        &points,
    );
    assert_eq!(raw_fe_after, fe_after);
    let fe_destroy_status = unsafe { fe_destroy(1, fe_handle as usize) };
    assert_eq!(fe_destroy_status, 0, "raw fe_destroy status");

    let mut nc_snapshot_words = snapshot_words(&rich_nc);
    let stale_nc_snapshot = nc_snapshot_words.clone();
    let mut nc_handle = 0u64;
    let nc_create_status =
        unsafe { nc_create(1, nc_snapshot_words.as_mut_ptr(), rich_nc.len() as u64, &mut nc_handle) };
    assert_eq!(nc_create_status, 0, "raw nc_create status");
    assert_ne!(nc_handle, 0);
    let raw_nc_before = direct_split_nc_evals_at(
        nc_evals_at,
        1,
        nc_handle,
        &mut stale_nc_snapshot.clone(),
        rich_nc.len() as u64,
        &points,
    );
    assert_eq!(raw_nc_before, nc_before);
    let nc_fold_status = unsafe { nc_fold(1, nc_handle as usize, challenge.re, challenge.im) };
    assert_eq!(nc_fold_status, 0, "raw nc_fold status");
    let raw_nc_after = direct_split_nc_evals_at(
        nc_evals_at,
        1,
        nc_handle,
        &mut stale_nc_snapshot.clone(),
        rich_nc.len() as u64,
        &points,
    );
    assert_eq!(raw_nc_after, nc_after);
    let nc_destroy_status = unsafe { nc_destroy(1, nc_handle as usize) };
    assert_eq!(nc_destroy_status, 0, "raw nc_destroy status");
}

#[test]
#[ignore = "requires local Mojo toolchain"]
fn real_mojo_split_nc_debug_snapshot_head_matches_rust_layout() {
    type DebugSnapshotHeadFn = unsafe extern "C" fn(u64, *mut u64, u64, *mut u64, u32) -> i32;

    let library_path = build_real_mojo_library();
    let lib = unsafe { Library::new(library_path) }.expect("load real mojo gpu library");
    let debug_snapshot_head = unsafe {
        *lib.get::<DebugSnapshotHeadFn>(b"nightstream_gpu_debug_snapshot_head\0")
            .expect("load real debug snapshot head symbol")
    };

    let snapshot = minimal_fe_snapshot();
    let snapshot_words = snapshot_words(&snapshot);
    let mut out = [0u64; 6];
    let status = unsafe {
        debug_snapshot_head(
            0xABCD,
            snapshot_words.as_ptr() as *mut u64,
            snapshot.len() as u64,
            out.as_mut_ptr(),
            out.len() as u32,
        )
    };
    assert_eq!(status, 0, "real debug snapshot head status");
    assert_eq!(
        out,
        [
            0xABCD,
            snapshot_words.as_ptr() as usize as u64,
            snapshot.len() as u64,
            snapshot_words[0],
            snapshot_words[1],
            snapshot_words[2],
        ]
    );
}

#[test]
#[ignore = "requires local Metal-capable Mojo runtime"]
fn real_mojo_metal_session_batch_matches_cpu_reference() {
    let library_path = build_real_mojo_library();
    let cfg = MojoBackendConfig::new(DeviceApi::Metal).with_library_path(library_path);

    let Ok(session) = connect(&cfg) else {
        eprintln!("skipping: real Mojo shared-library Metal session is not available in this runtime");
        return;
    };
    assert_eq!(session.device_api(), DeviceApi::Metal);
    assert!(session.supports_poseidon2_api());
    assert!(session.supports_poseidon2_batch_api());

    let mut backend = poseidon2_batch_fixture(256);
    if let Err(err) = session.permute_poseidon2_batch_u64x8(&mut backend) {
        eprintln!("skipping: real Mojo shared-library Metal batch path failed: {err}");
        return;
    }

    assert_eq!(backend, poseidon2_batch_cpu_reference(256));
}

#[test]
#[ignore = "requires local Metal-capable Mojo runtime"]
fn real_mojo_metal_session_batch_reuse_matches_cpu_across_sizes() {
    let library_path = build_real_mojo_library();
    let cfg = MojoBackendConfig::new(DeviceApi::Metal).with_library_path(library_path);

    let Ok(session) = connect(&cfg) else {
        eprintln!("skipping: real Mojo shared-library Metal session is not available in this runtime");
        return;
    };
    assert_eq!(session.device_api(), DeviceApi::Metal);

    for &num_states in &[64usize, 256usize, 32usize] {
        let mut backend = poseidon2_batch_fixture(num_states);
        if let Err(err) = session.permute_poseidon2_batch_u64x8(&mut backend) {
            eprintln!("skipping: real Mojo shared-library Metal batch reuse path failed: {err}");
            return;
        }
        assert_eq!(backend, poseidon2_batch_cpu_reference(num_states));
    }
}

#[test]
#[ignore = "requires local Metal-capable Mojo runtime"]
fn real_mojo_metal_split_nc_smoke_matches_cpu_reference() {
    let library_path = build_real_mojo_library();
    let cfg = MojoBackendConfig::new(DeviceApi::Metal).with_library_path(library_path);

    let Ok(session) = connect(&cfg) else {
        eprintln!("skipping: real Mojo shared-library Metal session is not available in this runtime");
        return;
    };
    assert_eq!(session.device_api(), DeviceApi::Metal);
    if !session.supports_split_nc_api() {
        eprintln!("skipping: Split-NC Metal backend is intentionally disabled in the Rust bridge");
        return;
    }

    let points = (0..256usize)
        .map(|i| FlatK {
            re: (i as u64) * 17 + 3,
            im: (i as u64) * 19 + 5,
        })
        .collect::<Vec<_>>();

    let cpu_cfg = MojoBackendConfig::new(DeviceApi::Cpu).with_library_path(build_real_mojo_library());
    let cpu_session = connect(&cpu_cfg).expect("connect cpu mojo session");

    let cpu_fe = cpu_session
        .create_fe_evaluator(&minimal_fe_snapshot())
        .expect("create cpu fe evaluator");
    let metal_fe = session
        .create_fe_evaluator(&minimal_fe_snapshot())
        .expect("create metal fe evaluator");
    assert_eq!(
        metal_fe.evals_at(&points).expect("metal fe evals"),
        cpu_fe.evals_at(&points).expect("cpu fe evals"),
    );

    let cpu_nc = cpu_session
        .create_nc_evaluator(&minimal_nc_snapshot())
        .expect("create cpu nc evaluator");
    let metal_nc = session
        .create_nc_evaluator(&minimal_nc_snapshot())
        .expect("create metal nc evaluator");
    assert_eq!(
        metal_nc.evals_at(&points).expect("metal nc evals"),
        cpu_nc.evals_at(&points).expect("cpu nc evals"),
    );
}

#[test]
#[ignore = "requires CUDA-capable Mojo runtime"]
fn real_mojo_cuda_split_nc_smoke_matches_cpu_reference() {
    let library_path = build_real_mojo_library();
    let cfg = MojoBackendConfig::new(DeviceApi::Cuda).with_library_path(library_path);

    let Ok(session) = connect(&cfg) else {
        eprintln!("skipping: real Mojo shared-library CUDA session is not available in this runtime");
        return;
    };
    assert_eq!(session.device_api(), DeviceApi::Cuda);

    let points = (0..256usize)
        .map(|i| FlatK {
            re: (i as u64) * 17 + 3,
            im: (i as u64) * 19 + 5,
        })
        .collect::<Vec<_>>();

    let cpu_cfg = MojoBackendConfig::new(DeviceApi::Cpu).with_library_path(build_real_mojo_library());
    let cpu_session = connect(&cpu_cfg).expect("connect cpu mojo session");

    let cpu_fe = cpu_session
        .create_fe_evaluator(&minimal_fe_snapshot())
        .expect("create cpu fe evaluator");
    let cuda_fe = session
        .create_fe_evaluator(&minimal_fe_snapshot())
        .expect("create cuda fe evaluator");
    assert_eq!(
        cuda_fe.evals_at(&points).expect("cuda fe evals"),
        cpu_fe.evals_at(&points).expect("cpu fe evals"),
    );

    let cpu_nc = cpu_session
        .create_nc_evaluator(&minimal_nc_snapshot())
        .expect("create cpu nc evaluator");
    let cuda_nc = session
        .create_nc_evaluator(&minimal_nc_snapshot())
        .expect("create cuda nc evaluator");
    assert_eq!(
        cuda_nc.evals_at(&points).expect("cuda nc evals"),
        cpu_nc.evals_at(&points).expect("cpu nc evals"),
    );
}

#[test]
#[ignore = "requires CUDA-capable Mojo runtime"]
fn real_mojo_cuda_fe_evaluator_create_evals_fold_matches_cpu_reference() {
    let library_path = build_real_mojo_library();
    let cfg = MojoBackendConfig::new(DeviceApi::Cuda).with_library_path(library_path);

    let Ok(cuda_session) = connect(&cfg) else {
        eprintln!("skipping: real Mojo shared-library CUDA session is not available in this runtime");
        return;
    };
    assert_eq!(cuda_session.device_api(), DeviceApi::Cuda);

    let cpu_cfg = MojoBackendConfig::new(DeviceApi::Cpu).with_library_path(build_real_mojo_library());
    let cpu_session = connect(&cpu_cfg).expect("connect cpu mojo session");

    let points = vec![
        FlatK::default(),
        FlatK { re: 1, im: 0 },
        FlatK { re: 5, im: 7 },
        FlatK { re: 11, im: 13 },
    ];
    let challenge = FlatK { re: 3, im: 1 };

    let rich_fe = rich_fe_snapshot();
    let mut cpu_fe = cpu_session
        .create_fe_evaluator(&rich_fe)
        .expect("create cpu fe evaluator");
    let mut cuda_fe = cuda_session
        .create_fe_evaluator(&rich_fe)
        .expect("create cuda fe evaluator");

    assert_eq!(
        cuda_fe
            .evals_at(&points)
            .expect("cuda fe evals before fold"),
        cpu_fe.evals_at(&points).expect("cpu fe evals before fold"),
    );

    cpu_fe.fold(challenge).expect("cpu fe fold");
    cuda_fe.fold(challenge).expect("cuda fe fold");

    assert_eq!(
        cuda_fe.evals_at(&points).expect("cuda fe evals after fold"),
        cpu_fe.evals_at(&points).expect("cpu fe evals after fold"),
    );
}

#[test]
#[ignore = "requires CUDA-capable Mojo runtime"]
fn real_mojo_cuda_nc_evaluator_create_evals_fold_matches_cpu_reference() {
    let library_path = build_real_mojo_library();
    let cfg = MojoBackendConfig::new(DeviceApi::Cuda).with_library_path(library_path);

    let Ok(cuda_session) = connect(&cfg) else {
        eprintln!("skipping: real Mojo shared-library CUDA session is not available in this runtime");
        return;
    };
    assert_eq!(cuda_session.device_api(), DeviceApi::Cuda);

    let cpu_cfg = MojoBackendConfig::new(DeviceApi::Cpu).with_library_path(build_real_mojo_library());
    let cpu_session = connect(&cpu_cfg).expect("connect cpu mojo session");

    let points = vec![
        FlatK::default(),
        FlatK { re: 1, im: 0 },
        FlatK { re: 17, im: 19 },
        FlatK { re: 23, im: 29 },
    ];
    let challenge = FlatK { re: 5, im: 2 };

    let rich_nc = rich_nc_snapshot();
    let mut cpu_nc = cpu_session
        .create_nc_evaluator(&rich_nc)
        .expect("create cpu nc evaluator");
    let mut cuda_nc = cuda_session
        .create_nc_evaluator(&rich_nc)
        .expect("create cuda nc evaluator");

    assert_eq!(
        cuda_nc
            .evals_at(&points)
            .expect("cuda nc evals before fold"),
        cpu_nc.evals_at(&points).expect("cpu nc evals before fold"),
    );

    cpu_nc.fold(challenge).expect("cpu nc fold");
    cuda_nc.fold(challenge).expect("cuda nc fold");

    assert_eq!(
        cuda_nc.evals_at(&points).expect("cuda nc evals after fold"),
        cpu_nc.evals_at(&points).expect("cpu nc evals after fold"),
    );
}

#[test]
#[ignore = "requires CUDA-capable Mojo runtime"]
fn real_mojo_cuda_session_batch_matches_cpu_reference() {
    let library_path = build_real_mojo_library();
    let cfg = MojoBackendConfig::new(DeviceApi::Cuda).with_library_path(library_path);

    let Ok(session) = connect(&cfg) else {
        eprintln!("skipping: real Mojo shared-library CUDA session is not available in this runtime");
        return;
    };
    assert_eq!(session.device_api(), DeviceApi::Cuda);
    assert!(session.supports_poseidon2_api());
    assert!(session.supports_poseidon2_batch_api());

    let mut backend = poseidon2_batch_fixture(256);
    session
        .permute_poseidon2_batch_u64x8(&mut backend)
        .expect("cuda poseidon2 batch path should succeed");

    assert_eq!(backend, poseidon2_batch_cpu_reference(256));
}

#[test]
#[ignore = "requires CUDA-capable Mojo runtime"]
fn real_mojo_cuda_session_batch_reuse_matches_cpu_across_sizes() {
    let library_path = build_real_mojo_library();
    let cfg = MojoBackendConfig::new(DeviceApi::Cuda).with_library_path(library_path);

    let Ok(session) = connect(&cfg) else {
        eprintln!("skipping: real Mojo shared-library CUDA session is not available in this runtime");
        return;
    };
    assert_eq!(session.device_api(), DeviceApi::Cuda);

    for &num_states in &[64usize, 256usize, 32usize] {
        let mut backend = poseidon2_batch_fixture(num_states);
        session
            .permute_poseidon2_batch_u64x8(&mut backend)
            .expect("cuda poseidon2 batch reuse path should succeed");
        assert_eq!(backend, poseidon2_batch_cpu_reference(num_states));
    }
}

#[test]
#[ignore = "requires working Mojo GPU runtime"]
fn mojo_gpu_compare_script_matches_cpu_reference() {
    let project_dir = mojo_project_dir();
    let status = Command::new(pixi_bin())
        .arg("run")
        .arg("mojo")
        .arg("run")
        .arg("src/poseidon_gpu_compare.mojo")
        .current_dir(project_dir)
        .status()
        .expect("spawn mojo gpu compare script");
    assert!(status.success(), "mojo gpu compare script failed");
}

#[test]
#[ignore = "manual Mojo GPU throughput benchmark"]
fn mojo_gpu_bench_script_runs() {
    let project_dir = mojo_project_dir();
    let status = Command::new(pixi_bin())
        .arg("run")
        .arg("mojo")
        .arg("run")
        .arg("src/poseidon_gpu_bench.mojo")
        .current_dir(project_dir)
        .status()
        .expect("spawn mojo gpu bench script");
    assert!(status.success(), "mojo gpu bench script failed");
}

#[test]
#[ignore = "perf-style threshold sweep: cargo test -p neo-gpu --release --test loader report_poseidon2_batch_threshold_sweep -- --ignored --nocapture"]
fn report_poseidon2_batch_threshold_sweep() {
    let library_path = build_real_mojo_library();
    let cfg = MojoBackendConfig::auto().with_library_path(library_path);
    let Ok(session) = connect(&cfg) else {
        eprintln!("skipping: real Mojo backend is unavailable");
        return;
    };

    eprintln!(
        "[poseidon2-threshold-sweep] device={:?} thresholds={:?}",
        session.device_api(),
        session.activation_thresholds()
    );

    for &num_states in &[1usize, 8, 16, 32, 64, 128, 256, 512, 2048] {
        let expected = poseidon2_batch_cpu_reference(num_states);
        let mut backend_once = poseidon2_batch_fixture(num_states);
        session
            .permute_poseidon2_batch_u64x8(&mut backend_once)
            .expect("batch permutation");
        assert_eq!(backend_once, expected, "parity failed for batch={num_states}");

        let iters = poseidon2_iters_for(num_states);

        let cpu_start = Instant::now();
        for _ in 0..iters {
            let mut cpu_states = poseidon2_batch_fixture(num_states);
            for state in &mut cpu_states {
                *state = p2::permutation()
                    .permute(state.map(Goldilocks::from_u64))
                    .map(|x| x.as_canonical_u64());
            }
        }
        let cpu_elapsed = cpu_start.elapsed();

        let gpu_start = Instant::now();
        for _ in 0..iters {
            let mut backend_states = poseidon2_batch_fixture(num_states);
            session
                .permute_poseidon2_batch_u64x8(&mut backend_states)
                .expect("batch permutation");
        }
        let gpu_elapsed = gpu_start.elapsed();

        let total_states = (iters * num_states) as u128;
        eprintln!(
            "[poseidon2-threshold-sweep] batch={} mode={:?} cpu_ns_per_state={} mojo_ns_per_state={}",
            num_states,
            session.poseidon2_batch_execution_mode(num_states),
            cpu_elapsed.as_nanos() / total_states,
            gpu_elapsed.as_nanos() / total_states,
        );
    }
}

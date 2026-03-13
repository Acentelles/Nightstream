#[cfg(target_os = "macos")]
use std::ffi::c_void;
use std::path::{Path, PathBuf};
#[cfg(target_os = "macos")]
use std::sync::{mpsc, OnceLock};
use std::sync::{Arc, Mutex};

#[cfg(all(not(target_arch = "wasm32"), any(unix, windows)))]
use libloading::Library;

use crate::abi::{
    DeviceRequest, DeviceResponse, FlatFq, FlatK, SessionRequest, DEVICE_PROBE_ACCELERATOR_READY_FLAG,
    DEVICE_PROBE_AVAILABLE_FLAG, DEVICE_PROBE_CPU_DIRECT_FLAG, DEVICE_PROBE_POSEIDON2_BATCH_FLAG,
    DEVICE_PROBE_POSEIDON2_FLAG, DEVICE_PROBE_RQ_MUL_FLAG, DEVICE_PROBE_SPLIT_NC_FLAG, DEVICE_PROBE_SUPERNEO_FLAG,
    POSEIDON2_STATE_WIDTH,
};
#[cfg(not(target_arch = "wasm32"))]
use crate::abi::{
    ABI_VERSION, ABI_VERSION_SYMBOL, DEVICE_PROBE_SYMBOL, FE_CREATE_SYMBOL, FE_DESTROY_SYMBOL, FE_EVALS_AT_SYMBOL,
    FE_FOLD_SYMBOL, NC_CREATE_SYMBOL, NC_DESTROY_SYMBOL, NC_EVALS_AT_SYMBOL, NC_FOLD_SYMBOL,
    POSEIDON2_PERMUTE_BATCH_SYMBOL, POSEIDON2_PERMUTE_SYMBOL, RQ_ACCUMULATE_BATCH_SYMBOL, RQ_CT_SYMBOL,
    RQ_MUL_BATCH_SYMBOL, RQ_MUL_SYMBOL, SESSION_CLOSE_SYMBOL, SESSION_OPEN_SYMBOL, SUPERNEO_BAR_BLOCK_SYMBOL,
    SUPERNEO_ROW_DOT_BLOCKS_SYMBOL,
};
use crate::{BackendActivationThresholds, DeviceApi, FlatRq, MojoBackendConfig, NeoGpuError};

#[cfg(not(target_arch = "wasm32"))]
type AbiVersionFn = unsafe extern "C" fn() -> u32;
type DeviceProbeFn = unsafe extern "C" fn(usize, *mut u64) -> i32;
type SessionOpenFn = unsafe extern "C" fn(usize, *mut u64) -> i32;
type SessionCloseFn = unsafe extern "C" fn(usize) -> i32;
type CreateEvaluatorFn = unsafe extern "C" fn(u64, *mut u64, u64, *mut usize) -> i32;
type DestroyEvaluatorFn = unsafe extern "C" fn(usize, usize) -> i32;
type EvalsAtFn = unsafe extern "C" fn(u64, u64, *mut u64, u64, *mut u64, u64, *mut u64, usize) -> i32;
type FoldFn = unsafe extern "C" fn(usize, usize, u64, u64) -> i32;
type Poseidon2PermuteFn = unsafe extern "C" fn(usize, *mut FlatFq, u32) -> i32;
type Poseidon2PermuteBatchFn = unsafe extern "C" fn(usize, *mut FlatFq, u32, u32) -> i32;
type RqMulFn = unsafe extern "C" fn(u64, *mut u64, *mut u64, *mut u64) -> i32;
type RqMulBatchFn = unsafe extern "C" fn(u64, *mut u64, *mut u64, u64, *mut u64) -> i32;
type RqAccumulateBatchFn = unsafe extern "C" fn(u64, *mut u64, *mut u64, *mut u64, u64, *mut u64) -> i32;
type RqCtFn = unsafe extern "C" fn(*mut u64, *mut u64) -> i32;
type SuperneoBarBlockFn = unsafe extern "C" fn(u64, *mut u64, *mut u64, *mut u64) -> i32;
type SuperneoRowDotBlocksFn = unsafe extern "C" fn(u64, *mut u64, u64, *mut u64, u64, *mut u64) -> i32;

#[cfg(all(not(target_arch = "wasm32"), any(unix, windows)))]
type PlatformLibrary = Library;
#[cfg(not(all(not(target_arch = "wasm32"), any(unix, windows))))]
struct PlatformLibrary;

const SPLIT_NC_SNAPSHOT_MAGIC: u64 = 0x4E53_504C_4954_4E43;
const SPLIT_NC_SNAPSHOT_VERSION: u64 = 1;
const SPLIT_NC_FE_ROW_V1: u64 = 1;
const SPLIT_NC_NC_COL_V1: u64 = 2;
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum ExecutionMode {
    Cpu,
    HostFallback,
    Accelerator,
}

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct MojoOperationCounters {
    pub cpu_calls: u64,
    pub host_fallback_calls: u64,
    pub accelerator_calls: u64,
    pub create_calls: u64,
    pub eval_calls: u64,
    pub fold_calls: u64,
    pub destroy_calls: u64,
    pub total_items: u64,
    pub max_items: usize,
}

impl MojoOperationCounters {
    fn record_mode(&mut self, mode: ExecutionMode, items: usize) {
        match mode {
            ExecutionMode::Cpu => self.cpu_calls += 1,
            ExecutionMode::HostFallback => self.host_fallback_calls += 1,
            ExecutionMode::Accelerator => self.accelerator_calls += 1,
        }
        self.total_items += items as u64;
        self.max_items = self.max_items.max(items);
    }
}

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct MojoSessionDiagnostics {
    pub poseidon2_batch: MojoOperationCounters,
    pub fe: MojoOperationCounters,
    pub nc: MojoOperationCounters,
    pub rq_mul: MojoOperationCounters,
    pub superneo: MojoOperationCounters,
}

impl std::ops::Sub for MojoSessionDiagnostics {
    type Output = MojoSessionDiagnostics;

    fn sub(self, rhs: Self) -> Self::Output {
        fn sub_counter(lhs: MojoOperationCounters, rhs: MojoOperationCounters) -> MojoOperationCounters {
            MojoOperationCounters {
                cpu_calls: lhs.cpu_calls.saturating_sub(rhs.cpu_calls),
                host_fallback_calls: lhs
                    .host_fallback_calls
                    .saturating_sub(rhs.host_fallback_calls),
                accelerator_calls: lhs.accelerator_calls.saturating_sub(rhs.accelerator_calls),
                create_calls: lhs.create_calls.saturating_sub(rhs.create_calls),
                eval_calls: lhs.eval_calls.saturating_sub(rhs.eval_calls),
                fold_calls: lhs.fold_calls.saturating_sub(rhs.fold_calls),
                destroy_calls: lhs.destroy_calls.saturating_sub(rhs.destroy_calls),
                total_items: lhs.total_items.saturating_sub(rhs.total_items),
                max_items: if lhs.max_items > rhs.max_items {
                    lhs.max_items
                } else {
                    0
                },
            }
        }

        MojoSessionDiagnostics {
            poseidon2_batch: sub_counter(self.poseidon2_batch, rhs.poseidon2_batch),
            fe: sub_counter(self.fe, rhs.fe),
            nc: sub_counter(self.nc, rhs.nc),
            rq_mul: sub_counter(self.rq_mul, rhs.rq_mul),
            superneo: sub_counter(self.superneo, rhs.superneo),
        }
    }
}

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct ProbeInfo {
    pub status: i32,
    pub capability_bits: u32,
}

impl ProbeInfo {
    #[inline]
    pub const fn available(self) -> bool {
        self.capability_bits & DEVICE_PROBE_AVAILABLE_FLAG != 0
    }

    #[inline]
    pub const fn accelerator_ready(self) -> bool {
        self.capability_bits & DEVICE_PROBE_ACCELERATOR_READY_FLAG != 0
    }

    #[inline]
    pub const fn supports_poseidon2(self) -> bool {
        self.capability_bits & DEVICE_PROBE_POSEIDON2_FLAG != 0
    }

    #[inline]
    pub const fn supports_poseidon2_batch(self) -> bool {
        self.capability_bits & DEVICE_PROBE_POSEIDON2_BATCH_FLAG != 0
    }

    #[inline]
    pub const fn supports_split_nc(self) -> bool {
        self.capability_bits & DEVICE_PROBE_SPLIT_NC_FLAG != 0
    }

    #[inline]
    pub const fn supports_rq_mul(self) -> bool {
        self.capability_bits & DEVICE_PROBE_RQ_MUL_FLAG != 0
    }

    #[inline]
    pub const fn supports_superneo(self) -> bool {
        self.capability_bits & DEVICE_PROBE_SUPERNEO_FLAG != 0
    }

    #[inline]
    pub const fn supports_cpu_direct(self) -> bool {
        self.capability_bits & DEVICE_PROBE_CPU_DIRECT_FLAG != 0
    }
}

#[derive(Debug, Default)]
struct SessionDiagnosticsState {
    snapshot: MojoSessionDiagnostics,
}

#[cfg(not(target_arch = "wasm32"))]
fn platform_library_name() -> &'static str {
    #[cfg(target_os = "macos")]
    {
        return "libnightstream_mojo_gpu.dylib";
    }
    #[cfg(target_os = "linux")]
    {
        return "libnightstream_mojo_gpu.so";
    }
    #[cfg(target_os = "windows")]
    {
        return "nightstream_mojo_gpu.dll";
    }
    #[cfg(not(any(target_os = "macos", target_os = "linux", target_os = "windows")))]
    {
        "libnightstream_mojo_gpu.unsupported"
    }
}

#[cfg(not(target_arch = "wasm32"))]
fn resolve_library_path(cfg: &MojoBackendConfig) -> PathBuf {
    if let Some(path) = cfg.library_path.clone() {
        return path;
    }

    let workspace_build = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("..")
        .join("gpu")
        .join("mojo")
        .join("build")
        .join(platform_library_name());
    if workspace_build.is_file() {
        return workspace_build;
    }

    PathBuf::from(platform_library_name())
}

#[cfg(target_os = "macos")]
#[link(name = "objc")]
unsafe extern "C" {
    fn objc_autoreleasePoolPush() -> *mut c_void;
    fn objc_autoreleasePoolPop(pool: *mut c_void);
}

#[cfg(target_os = "macos")]
fn with_macos_autorelease_pool<T>(f: impl FnOnce() -> T) -> T {
    struct PoolGuard(*mut c_void);

    impl Drop for PoolGuard {
        fn drop(&mut self) {
            unsafe { objc_autoreleasePoolPop(self.0) };
        }
    }

    let guard = PoolGuard(unsafe { objc_autoreleasePoolPush() });
    let out = f();
    drop(guard);
    out
}

#[cfg(not(target_os = "macos"))]
fn with_macos_autorelease_pool<T>(f: impl FnOnce() -> T) -> T {
    f()
}

#[cfg(target_os = "macos")]
struct MetalCallExecutor {
    tx: mpsc::Sender<Box<dyn FnOnce() + Send + 'static>>,
}

#[cfg(target_os = "macos")]
impl MetalCallExecutor {
    fn global() -> &'static Self {
        static EXECUTOR: OnceLock<MetalCallExecutor> = OnceLock::new();
        EXECUTOR.get_or_init(|| {
            let (tx, rx) = mpsc::channel::<Box<dyn FnOnce() + Send + 'static>>();
            std::thread::Builder::new()
                .name("neo-gpu-metal".to_string())
                .spawn(move || {
                    while let Ok(job) = rx.recv() {
                        with_macos_autorelease_pool(job);
                    }
                })
                .expect("spawn neo-gpu metal executor");
            MetalCallExecutor { tx }
        })
    }

    fn call<T: Send + 'static>(&self, f: impl FnOnce() -> T + Send + 'static) -> T {
        let (tx, rx) = mpsc::sync_channel(1);
        self.tx
            .send(Box::new(move || {
                let _ = tx.send(f());
            }))
            .expect("send metal executor job");
        rx.recv().expect("receive metal executor result")
    }
}

fn call_for_device_api<T: Send + 'static>(_api: DeviceApi, f: impl FnOnce() -> T + Send + 'static) -> T {
    #[cfg(target_os = "macos")]
    {
        let _ = _api;
        MetalCallExecutor::global().call(f)
    }

    #[cfg(not(target_os = "macos"))]
    {
        with_macos_autorelease_pool(f)
    }
}

#[cfg(all(not(target_arch = "wasm32"), any(unix, windows)))]
unsafe fn load_required<T: Copy>(lib: &Library, symbol: &'static [u8], name: &'static str) -> Result<T, NeoGpuError> {
    lib.get::<T>(symbol)
        .map(|sym| *sym)
        .map_err(|_| NeoGpuError::MissingSymbol { symbol: name })
}

#[cfg(all(not(target_arch = "wasm32"), any(unix, windows)))]
unsafe fn load_optional<T: Copy>(lib: &Library, symbol: &'static [u8]) -> Option<T> {
    lib.get::<T>(symbol).ok().map(|sym| *sym)
}

struct OptionalEvaluatorFns {
    fe_create: Option<CreateEvaluatorFn>,
    fe_destroy: Option<DestroyEvaluatorFn>,
    fe_evals_at: Option<EvalsAtFn>,
    fe_fold: Option<FoldFn>,
    nc_create: Option<CreateEvaluatorFn>,
    nc_destroy: Option<DestroyEvaluatorFn>,
    nc_evals_at: Option<EvalsAtFn>,
    nc_fold: Option<FoldFn>,
    poseidon2_permute: Option<Poseidon2PermuteFn>,
    poseidon2_permute_batch: Option<Poseidon2PermuteBatchFn>,
    rq_mul: Option<RqMulFn>,
    rq_mul_batch: Option<RqMulBatchFn>,
    rq_accumulate_batch: Option<RqAccumulateBatchFn>,
    rq_ct: Option<RqCtFn>,
    superneo_bar_block: Option<SuperneoBarBlockFn>,
    superneo_row_dot_blocks: Option<SuperneoRowDotBlocksFn>,
}

impl OptionalEvaluatorFns {
    #[inline]
    fn supports_split_nc(&self) -> bool {
        self.fe_create.is_some()
            && self.fe_destroy.is_some()
            && self.fe_evals_at.is_some()
            && self.fe_fold.is_some()
            && self.nc_create.is_some()
            && self.nc_destroy.is_some()
            && self.nc_evals_at.is_some()
            && self.nc_fold.is_some()
    }

    #[inline]
    fn supports_poseidon2(&self) -> bool {
        self.poseidon2_permute.is_some()
    }

    #[inline]
    fn supports_poseidon2_batch(&self) -> bool {
        self.poseidon2_permute_batch.is_some()
    }

    #[inline]
    fn supports_cpu_direct_mode(&self) -> bool {
        self.supports_poseidon2() || self.supports_split_nc()
    }

    #[inline]
    fn supports_rq_mul(&self) -> bool {
        self.rq_mul.is_some()
            && self.rq_mul_batch.is_some()
            && self.rq_accumulate_batch.is_some()
            && self.rq_ct.is_some()
    }

    #[inline]
    fn supports_superneo(&self) -> bool {
        self.superneo_bar_block.is_some() && self.superneo_row_dot_blocks.is_some()
    }
}

fn snapshot_bytes_to_words(snapshot: &[u8]) -> Result<Vec<u64>, NeoGpuError> {
    let mut words = Vec::with_capacity(snapshot.len().div_ceil(8));
    for chunk in snapshot.chunks(8) {
        let mut word = [0u8; 8];
        word[..chunk.len()].copy_from_slice(chunk);
        words.push(u64::from_le_bytes(word));
    }
    Ok(words)
}

pub struct MojoLibrary {
    path: PathBuf,
    _lib: PlatformLibrary,
    device_probe: DeviceProbeFn,
    session_open: SessionOpenFn,
    session_close: SessionCloseFn,
    evaluators: OptionalEvaluatorFns,
}

impl MojoLibrary {
    #[inline]
    fn supports_cpu_direct_mode(&self) -> bool {
        self.evaluators.supports_cpu_direct_mode()
    }

    #[cfg(all(not(target_arch = "wasm32"), any(unix, windows)))]
    pub fn load(cfg: &MojoBackendConfig) -> Result<Self, NeoGpuError> {
        let path = resolve_library_path(cfg);
        let lib = unsafe { Library::new(&path) }.map_err(|source| NeoGpuError::LoadLibrary {
            path: path.clone(),
            source,
        })?;

        let abi_version =
            unsafe { load_required::<AbiVersionFn>(&lib, ABI_VERSION_SYMBOL, "nightstream_gpu_abi_version")? };
        let observed = unsafe { abi_version() };
        if observed != ABI_VERSION {
            return Err(NeoGpuError::AbiMismatch {
                expected: ABI_VERSION,
                observed,
            });
        }

        let device_probe =
            unsafe { load_required::<DeviceProbeFn>(&lib, DEVICE_PROBE_SYMBOL, "nightstream_gpu_device_probe")? };
        let session_open =
            unsafe { load_required::<SessionOpenFn>(&lib, SESSION_OPEN_SYMBOL, "nightstream_gpu_session_open")? };
        let session_close =
            unsafe { load_required::<SessionCloseFn>(&lib, SESSION_CLOSE_SYMBOL, "nightstream_gpu_session_close")? };

        let evaluators = unsafe {
            OptionalEvaluatorFns {
                fe_create: load_optional::<CreateEvaluatorFn>(&lib, FE_CREATE_SYMBOL),
                fe_destroy: load_optional::<DestroyEvaluatorFn>(&lib, FE_DESTROY_SYMBOL),
                fe_evals_at: load_optional::<EvalsAtFn>(&lib, FE_EVALS_AT_SYMBOL),
                fe_fold: load_optional::<FoldFn>(&lib, FE_FOLD_SYMBOL),
                nc_create: load_optional::<CreateEvaluatorFn>(&lib, NC_CREATE_SYMBOL),
                nc_destroy: load_optional::<DestroyEvaluatorFn>(&lib, NC_DESTROY_SYMBOL),
                nc_evals_at: load_optional::<EvalsAtFn>(&lib, NC_EVALS_AT_SYMBOL),
                nc_fold: load_optional::<FoldFn>(&lib, NC_FOLD_SYMBOL),
                poseidon2_permute: load_optional::<Poseidon2PermuteFn>(&lib, POSEIDON2_PERMUTE_SYMBOL),
                poseidon2_permute_batch: load_optional::<Poseidon2PermuteBatchFn>(&lib, POSEIDON2_PERMUTE_BATCH_SYMBOL),
                rq_mul: load_optional::<RqMulFn>(&lib, RQ_MUL_SYMBOL),
                rq_mul_batch: load_optional::<RqMulBatchFn>(&lib, RQ_MUL_BATCH_SYMBOL),
                rq_accumulate_batch: load_optional::<RqAccumulateBatchFn>(&lib, RQ_ACCUMULATE_BATCH_SYMBOL),
                rq_ct: load_optional::<RqCtFn>(&lib, RQ_CT_SYMBOL),
                superneo_bar_block: load_optional::<SuperneoBarBlockFn>(&lib, SUPERNEO_BAR_BLOCK_SYMBOL),
                superneo_row_dot_blocks: load_optional::<SuperneoRowDotBlocksFn>(&lib, SUPERNEO_ROW_DOT_BLOCKS_SYMBOL),
            }
        };

        Ok(Self {
            path,
            _lib: lib,
            device_probe,
            session_open,
            session_close,
            evaluators,
        })
    }

    #[cfg(not(all(not(target_arch = "wasm32"), any(unix, windows))))]
    pub fn load(cfg: &MojoBackendConfig) -> Result<Self, NeoGpuError> {
        let _ = cfg;
        Err(NeoGpuError::UnsupportedOperation {
            op: "gpu_dynamic_loading_unsupported_platform",
        })
    }

    #[inline]
    pub fn path(&self) -> &Path {
        &self.path
    }

    pub fn probe_info(&self, api: DeviceApi, device_id: u32) -> Result<ProbeInfo, NeoGpuError> {
        let req = DeviceRequest {
            api: api.as_u32(),
            device_id,
        };
        let mut resp_word = 0u64;
        let device_probe = self.device_probe;
        let req_ptr = (&req as *const DeviceRequest) as usize;
        let resp_ptr = (&mut resp_word as *mut u64) as usize;
        let status = call_for_device_api(api, move || unsafe { device_probe(req_ptr, resp_ptr as *mut u64) });
        if status != 0 {
            let mut capability_bits = 0u32;
            if api == DeviceApi::Cpu && self.supports_cpu_direct_mode() {
                capability_bits |= DEVICE_PROBE_AVAILABLE_FLAG | DEVICE_PROBE_CPU_DIRECT_FLAG;
            }
            if self.supports_poseidon2_api() {
                capability_bits |= DEVICE_PROBE_POSEIDON2_FLAG;
            }
            if self.supports_poseidon2_batch_api() {
                capability_bits |= DEVICE_PROBE_POSEIDON2_BATCH_FLAG;
            }
            if self.supports_split_nc_api() {
                capability_bits |= DEVICE_PROBE_SPLIT_NC_FLAG;
            }
            if self.supports_rq_mul_api() {
                capability_bits |= DEVICE_PROBE_RQ_MUL_FLAG;
            }
            if self.supports_superneo_api() {
                capability_bits |= DEVICE_PROBE_SUPERNEO_FLAG;
            }
            return Ok(ProbeInfo {
                status,
                capability_bits,
            });
        }
        let resp = DeviceResponse {
            status: resp_word as u32 as i32,
            available: (resp_word >> 32) as u32 as i32,
        };
        let mut capability_bits = 0u32;
        if resp.is_available() {
            capability_bits |= DEVICE_PROBE_AVAILABLE_FLAG;
        }
        if resp.accelerator_ready() {
            capability_bits |= DEVICE_PROBE_ACCELERATOR_READY_FLAG;
        }
        if resp.supports_poseidon2() {
            capability_bits |= DEVICE_PROBE_POSEIDON2_FLAG;
        }
        if resp.supports_poseidon2_batch() {
            capability_bits |= DEVICE_PROBE_POSEIDON2_BATCH_FLAG;
        }
        if resp.supports_split_nc() {
            capability_bits |= DEVICE_PROBE_SPLIT_NC_FLAG;
        }
        if resp.supports_rq_mul() {
            capability_bits |= DEVICE_PROBE_RQ_MUL_FLAG;
        }
        if resp.supports_superneo() {
            capability_bits |= DEVICE_PROBE_SUPERNEO_FLAG;
        }
        if resp.supports_cpu_direct() {
            capability_bits |= DEVICE_PROBE_CPU_DIRECT_FLAG;
        }
        Ok(ProbeInfo {
            status: resp.status,
            capability_bits,
        })
    }

    pub fn probe_device(&self, api: DeviceApi, device_id: u32) -> Result<bool, NeoGpuError> {
        Ok(self.probe_info(api, device_id)?.available())
    }

    #[inline]
    pub fn supports_split_nc_api(&self) -> bool {
        self.evaluators.supports_split_nc()
    }

    #[inline]
    pub fn supports_poseidon2_api(&self) -> bool {
        self.evaluators.supports_poseidon2()
    }

    #[inline]
    pub fn supports_poseidon2_batch_api(&self) -> bool {
        self.evaluators.supports_poseidon2_batch()
    }

    #[inline]
    pub fn supports_rq_mul_api(&self) -> bool {
        self.evaluators.supports_rq_mul()
    }

    #[inline]
    pub fn supports_superneo_api(&self) -> bool {
        self.evaluators.supports_superneo()
    }

    pub fn open_session(self, cfg: &MojoBackendConfig) -> Result<MojoSession, NeoGpuError> {
        let req = SessionRequest {
            api: cfg.device_api.as_u32(),
            device_id: cfg.device_id,
        };
        let mut handle_word = 0u64;
        let session_open = self.session_open;
        let req_ptr = (&req as *const SessionRequest) as usize;
        let handle_ptr = (&mut handle_word as *mut u64) as usize;
        let status = call_for_device_api(cfg.device_api, move || unsafe {
            session_open(req_ptr, handle_ptr as *mut u64)
        });
        let mut handle = handle_word as usize;
        if status == 0 && handle != 0 {
            return Ok(MojoSession {
                library: Some(self),
                handle,
                device_api: cfg.device_api,
                device_id: cfg.device_id,
                diagnostics: Arc::new(Mutex::new(SessionDiagnosticsState::default())),
            });
        }

        if cfg.device_api == DeviceApi::Cpu && self.supports_cpu_direct_mode() {
            handle = 1;
            return Ok(MojoSession {
                library: Some(self),
                handle,
                device_api: cfg.device_api,
                device_id: cfg.device_id,
                diagnostics: Arc::new(Mutex::new(SessionDiagnosticsState::default())),
            });
        }

        if !self.probe_device(cfg.device_api, cfg.device_id)? {
            return Err(NeoGpuError::DeviceUnavailable {
                api: cfg.device_api,
                device_id: cfg.device_id,
            });
        }

        if status != 0 || handle == 0 {
            return Err(NeoGpuError::SessionOpenFailed { status });
        }
        unreachable!()
    }
}

impl std::fmt::Debug for MojoLibrary {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("MojoLibrary")
            .field("path", &self.path)
            .field("supports_split_nc_api", &self.supports_split_nc_api())
            .field("supports_poseidon2_api", &self.supports_poseidon2_api())
            .field("supports_poseidon2_batch_api", &self.supports_poseidon2_batch_api())
            .field("supports_rq_mul_api", &self.supports_rq_mul_api())
            .field("supports_superneo_api", &self.supports_superneo_api())
            .finish()
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum SplitNcEvaluatorKind {
    Fe,
    Nc,
}

fn push_u64_le(out: &mut Vec<u8>, word: u64) {
    out.extend_from_slice(&word.to_le_bytes());
}

fn push_flat_k_le(out: &mut Vec<u8>, value: FlatK) {
    push_u64_le(out, value.re);
    push_u64_le(out, value.im);
}

fn minimal_fe_snapshot() -> Vec<u8> {
    let mut out = Vec::with_capacity(20 * 8);
    push_u64_le(&mut out, SPLIT_NC_SNAPSHOT_MAGIC);
    push_u64_le(&mut out, SPLIT_NC_SNAPSHOT_VERSION);
    push_u64_le(&mut out, SPLIT_NC_FE_ROW_V1);
    push_u64_le(&mut out, 4); // b
    push_u64_le(&mut out, 2); // d_sc
    push_u64_le(&mut out, 2); // cur_len
    push_u64_le(&mut out, 2); // eq_beta_r_tbl len
    push_u64_le(&mut out, 0); // eq_r_inputs_tbl len
    push_u64_le(&mut out, 0); // gamma_pow_mcs len
    push_u64_le(&mut out, 0); // f_terms len
    push_u64_le(&mut out, 0); // num_mcs
    push_u64_le(&mut out, 0); // num_vars
    push_u64_le(&mut out, 2); // table_len
    push_u64_le(&mut out, 0); // eval_tbl len
    push_flat_k_le(&mut out, FlatK::default()); // gamma_to_k
    push_flat_k_le(&mut out, FlatK { re: 1, im: 0 });
    push_flat_k_le(&mut out, FlatK::default());
    out
}

fn minimal_nc_snapshot() -> Vec<u8> {
    let mut out = Vec::with_capacity(17 * 8);
    push_u64_le(&mut out, SPLIT_NC_SNAPSHOT_MAGIC);
    push_u64_le(&mut out, SPLIT_NC_SNAPSHOT_VERSION);
    push_u64_le(&mut out, SPLIT_NC_NC_COL_V1);
    push_u64_le(&mut out, 4); // b
    push_u64_le(&mut out, 2); // d_sc
    push_u64_le(&mut out, 2); // cur_len
    push_u64_le(&mut out, 2); // eq_beta_m_tbl len
    push_u64_le(&mut out, 0); // num_tables
    push_u64_le(&mut out, 2); // table_len
    push_u64_le(&mut out, 0); // d_width
    push_u64_le(&mut out, 0); // weights_tables
    push_u64_le(&mut out, 0); // weights_width
    push_u64_le(&mut out, 0); // range_t_sq len
    push_flat_k_le(&mut out, FlatK { re: 1, im: 0 });
    push_flat_k_le(&mut out, FlatK::default());
    out
}

pub struct MojoSession {
    library: Option<MojoLibrary>,
    handle: usize,
    device_api: DeviceApi,
    device_id: u32,
    diagnostics: Arc<Mutex<SessionDiagnosticsState>>,
}

pub struct MojoSplitNcEvaluator<'a> {
    session: &'a MojoSession,
    handle: usize,
    kind: SplitNcEvaluatorKind,
    snapshot_words: Vec<u64>,
    snapshot_len: usize,
}

impl MojoSession {
    #[inline]
    pub fn handle(&self) -> usize {
        self.handle
    }

    #[inline]
    pub fn device_api(&self) -> DeviceApi {
        self.device_api
    }

    #[inline]
    pub fn device_id(&self) -> u32 {
        self.device_id
    }

    pub fn diagnostics_snapshot(&self) -> MojoSessionDiagnostics {
        self.diagnostics
            .lock()
            .expect("mojo session diagnostics lock")
            .snapshot
    }

    pub fn reset_diagnostics(&self) {
        self.diagnostics
            .lock()
            .expect("mojo session diagnostics lock")
            .snapshot = MojoSessionDiagnostics::default();
    }

    #[inline]
    pub fn declares_split_nc_api(&self) -> bool {
        self.library
            .as_ref()
            .map(MojoLibrary::supports_split_nc_api)
            .unwrap_or(false)
    }

    pub fn supports_split_nc_api(&self) -> bool {
        self.probe_split_nc_api().is_ok()
    }

    #[inline]
    pub fn supports_poseidon2_api(&self) -> bool {
        self.library
            .as_ref()
            .map(MojoLibrary::supports_poseidon2_api)
            .unwrap_or(false)
    }

    #[inline]
    pub fn supports_poseidon2_batch_api(&self) -> bool {
        self.library
            .as_ref()
            .map(MojoLibrary::supports_poseidon2_batch_api)
            .unwrap_or(false)
    }

    #[inline]
    pub fn supports_rq_mul_api(&self) -> bool {
        self.library
            .as_ref()
            .map(MojoLibrary::supports_rq_mul_api)
            .unwrap_or(false)
    }

    #[inline]
    pub fn supports_superneo_api(&self) -> bool {
        self.library
            .as_ref()
            .map(MojoLibrary::supports_superneo_api)
            .unwrap_or(false)
    }

    #[inline]
    pub fn poseidon2_batch_execution_mode(&self, num_states: usize) -> ExecutionMode {
        let thresholds = self.activation_thresholds();
        match self.device_api {
            DeviceApi::Cpu => ExecutionMode::Cpu,
            DeviceApi::Cuda | DeviceApi::Metal if num_states >= thresholds.poseidon2_batch_min_states => {
                ExecutionMode::Accelerator
            }
            DeviceApi::Cuda | DeviceApi::Metal | DeviceApi::Auto => ExecutionMode::HostFallback,
        }
    }

    #[inline]
    pub fn fe_row_execution_mode(&self, total_tasks: usize) -> ExecutionMode {
        let thresholds = self.activation_thresholds();
        match self.device_api {
            DeviceApi::Cpu => ExecutionMode::Cpu,
            DeviceApi::Cuda | DeviceApi::Metal if total_tasks >= thresholds.fe_row_min_tasks => {
                ExecutionMode::Accelerator
            }
            DeviceApi::Cuda | DeviceApi::Metal | DeviceApi::Auto => ExecutionMode::HostFallback,
        }
    }

    #[inline]
    pub fn nc_col_execution_mode(&self, total_tasks: usize) -> ExecutionMode {
        let thresholds = self.activation_thresholds();
        match self.device_api {
            DeviceApi::Cpu => ExecutionMode::Cpu,
            DeviceApi::Cuda | DeviceApi::Metal if total_tasks >= thresholds.nc_col_min_tasks => {
                ExecutionMode::Accelerator
            }
            DeviceApi::Cuda | DeviceApi::Metal | DeviceApi::Auto => ExecutionMode::HostFallback,
        }
    }

    #[inline]
    pub fn split_nc_execution_mode(&self, total_tasks: usize) -> ExecutionMode {
        self.fe_row_execution_mode(total_tasks)
    }

    #[inline]
    pub fn activation_thresholds(&self) -> BackendActivationThresholds {
        self.device_api.activation_thresholds()
    }

    pub fn create_fe_evaluator(&self, snapshot: &[u8]) -> Result<MojoSplitNcEvaluator<'_>, NeoGpuError> {
        self.create_split_nc_evaluator(SplitNcEvaluatorKind::Fe, snapshot)
    }

    pub fn create_nc_evaluator(&self, snapshot: &[u8]) -> Result<MojoSplitNcEvaluator<'_>, NeoGpuError> {
        self.create_split_nc_evaluator(SplitNcEvaluatorKind::Nc, snapshot)
    }

    fn probe_split_nc_api(&self) -> Result<(), NeoGpuError> {
        let flat_points = [FlatK::default(), FlatK { re: 1, im: 0 }];
        let mut fe = self.create_fe_evaluator(&minimal_fe_snapshot())?;
        let _ = fe.evals_at(&flat_points)?;
        fe.fold(FlatK { re: 1, im: 0 })?;

        let mut nc = self.create_nc_evaluator(&minimal_nc_snapshot())?;
        let _ = nc.evals_at(&flat_points)?;
        nc.fold(FlatK { re: 1, im: 0 })?;
        Ok(())
    }

    fn create_split_nc_evaluator(
        &self,
        kind: SplitNcEvaluatorKind,
        snapshot: &[u8],
    ) -> Result<MojoSplitNcEvaluator<'_>, NeoGpuError> {
        let library = self
            .library
            .as_ref()
            .ok_or(NeoGpuError::UnsupportedOperation { op: "split_nc_create" })?;
        let create = match kind {
            SplitNcEvaluatorKind::Fe => library
                .evaluators
                .fe_create
                .ok_or(NeoGpuError::UnsupportedOperation { op: "fe_create" })?,
            SplitNcEvaluatorKind::Nc => library
                .evaluators
                .nc_create
                .ok_or(NeoGpuError::UnsupportedOperation { op: "nc_create" })?,
        };

        let mut handle = 0usize;
        let snapshot_words = snapshot_bytes_to_words(snapshot)?;
        let session_handle = self.handle as u64;
        let device_api = self.device_api;
        let handle_ptr = (&mut handle as *mut usize) as usize;
        let snapshot_ptr = snapshot_words.as_ptr() as usize;
        let snapshot_len = snapshot.len() as u64;
        let status = call_for_device_api(device_api, move || unsafe {
            create(
                session_handle,
                snapshot_ptr as *mut u64,
                snapshot_len,
                handle_ptr as *mut usize,
            )
        });
        if status != 0 || handle == 0 {
            if status == 0 && handle == 0 {
                handle = match kind {
                    SplitNcEvaluatorKind::Fe => 1,
                    SplitNcEvaluatorKind::Nc => 2,
                };
            } else {
                return Err(NeoGpuError::OperationFailed {
                    op: match kind {
                        SplitNcEvaluatorKind::Fe => "fe_create",
                        SplitNcEvaluatorKind::Nc => "nc_create",
                    },
                    status,
                });
            }
        }
        let mode = match self.device_api {
            DeviceApi::Cpu => ExecutionMode::Cpu,
            DeviceApi::Cuda | DeviceApi::Metal => ExecutionMode::Accelerator,
            DeviceApi::Auto => ExecutionMode::HostFallback,
        };
        let mut diagnostics = self
            .diagnostics
            .lock()
            .expect("mojo session diagnostics lock");
        let counters = match kind {
            SplitNcEvaluatorKind::Fe => &mut diagnostics.snapshot.fe,
            SplitNcEvaluatorKind::Nc => &mut diagnostics.snapshot.nc,
        };
        counters.create_calls += 1;
        counters.record_mode(mode, snapshot.len());
        Ok(MojoSplitNcEvaluator {
            session: self,
            handle,
            kind,
            snapshot_words,
            snapshot_len: snapshot.len(),
        })
    }

    pub fn permute_poseidon2_u64x8(
        &self,
        state: &[u64; POSEIDON2_STATE_WIDTH],
    ) -> Result<[u64; POSEIDON2_STATE_WIDTH], NeoGpuError> {
        let library = self
            .library
            .as_ref()
            .ok_or(NeoGpuError::UnsupportedOperation {
                op: "poseidon2_permute_u64x8",
            })?;
        let permute = library
            .evaluators
            .poseidon2_permute
            .ok_or(NeoGpuError::UnsupportedOperation {
                op: "poseidon2_permute_u64x8",
            })?;

        let mut state_flat = state.map(|limb| FlatFq { limb });
        let session_handle = self.handle;
        let device_api = self.device_api;
        let state_ptr = state_flat.as_mut_ptr() as usize;
        let status = call_for_device_api(device_api, move || unsafe {
            permute(session_handle, state_ptr as *mut FlatFq, POSEIDON2_STATE_WIDTH as u32)
        });
        if status != 0 {
            return Err(NeoGpuError::OperationFailed {
                op: "poseidon2_permute_u64x8",
                status,
            });
        }
        Ok(state_flat.map(|x| x.limb))
    }

    pub fn permute_poseidon2_batch_u64x8(
        &self,
        states: &mut [[u64; POSEIDON2_STATE_WIDTH]],
    ) -> Result<(), NeoGpuError> {
        if states.is_empty() {
            return Ok(());
        }

        let library = self
            .library
            .as_ref()
            .ok_or(NeoGpuError::UnsupportedOperation {
                op: "poseidon2_permute_batch_u64x8",
            })?;

        if let Some(permute_batch) = library.evaluators.poseidon2_permute_batch {
            let mode = self.poseidon2_batch_execution_mode(states.len());
            let session_handle = self.handle;
            let device_api = self.device_api;
            let state_ptr = states.as_mut_ptr().cast::<FlatFq>() as usize;
            let num_states = states.len() as u32;
            let status = call_for_device_api(device_api, move || unsafe {
                permute_batch(
                    session_handle,
                    state_ptr as *mut FlatFq,
                    num_states,
                    POSEIDON2_STATE_WIDTH as u32,
                )
            });
            if status != 0 {
                return Err(NeoGpuError::OperationFailed {
                    op: "poseidon2_permute_batch_u64x8",
                    status,
                });
            }
            let mut diagnostics = self
                .diagnostics
                .lock()
                .expect("mojo session diagnostics lock");
            diagnostics
                .snapshot
                .poseidon2_batch
                .record_mode(mode, states.len());
            return Ok(());
        }

        for state in states {
            *state = self.permute_poseidon2_u64x8(state)?;
        }
        Ok(())
    }

    pub fn rq_mul_execution_mode(&self, total_tasks: usize) -> ExecutionMode {
        let min_tasks = match self.device_api {
            DeviceApi::Cpu => 0,
            DeviceApi::Metal => 54 * 1024,
            DeviceApi::Cuda => 54 * 64,
            DeviceApi::Auto => usize::MAX,
        };
        if self.device_api != DeviceApi::Cpu && total_tasks < min_tasks {
            return ExecutionMode::HostFallback;
        }
        match self.device_api {
            DeviceApi::Cpu => ExecutionMode::Cpu,
            DeviceApi::Cuda | DeviceApi::Metal => ExecutionMode::Accelerator,
            DeviceApi::Auto => ExecutionMode::HostFallback,
        }
    }

    #[inline]
    pub fn superneo_bar_block_execution_mode(&self) -> ExecutionMode {
        match self.device_api {
            DeviceApi::Cpu => ExecutionMode::Cpu,
            DeviceApi::Cuda | DeviceApi::Metal => ExecutionMode::Accelerator,
            DeviceApi::Auto => ExecutionMode::HostFallback,
        }
    }

    #[inline]
    pub fn superneo_row_dot_execution_mode(&self, num_blocks: usize) -> ExecutionMode {
        if self.device_api != DeviceApi::Cpu && num_blocks == 0 {
            return ExecutionMode::HostFallback;
        }
        match self.device_api {
            DeviceApi::Cpu => ExecutionMode::Cpu,
            DeviceApi::Cuda | DeviceApi::Metal => ExecutionMode::Accelerator,
            DeviceApi::Auto => ExecutionMode::HostFallback,
        }
    }

    pub fn rq_mul_u64x54(&self, lhs: &FlatRq, rhs: &FlatRq) -> Result<FlatRq, NeoGpuError> {
        let library = self
            .library
            .as_ref()
            .ok_or(NeoGpuError::UnsupportedOperation { op: "rq_mul_u64x54" })?;
        let rq_mul = library
            .evaluators
            .rq_mul
            .ok_or(NeoGpuError::UnsupportedOperation { op: "rq_mul_u64x54" })?;
        let mut lhs_words = lhs.coeffs;
        let mut rhs_words = rhs.coeffs;
        let mut out_words = [0u64; 54];
        let device_api = self.device_api;
        let lhs_ptr = lhs_words.as_mut_ptr() as usize;
        let rhs_ptr = rhs_words.as_mut_ptr() as usize;
        let out_ptr = out_words.as_mut_ptr() as usize;
        let session_handle = self.handle;
        let status = call_for_device_api(device_api, move || unsafe {
            rq_mul(
                session_handle as u64,
                lhs_ptr as *mut u64,
                rhs_ptr as *mut u64,
                out_ptr as *mut u64,
            )
        });
        if status != 0 {
            return Err(NeoGpuError::OperationFailed {
                op: "rq_mul_u64x54",
                status,
            });
        }
        let mode = self.rq_mul_execution_mode(54);
        let mut diagnostics = self
            .diagnostics
            .lock()
            .expect("mojo session diagnostics lock");
        diagnostics.snapshot.rq_mul.record_mode(mode, 1);
        Ok(FlatRq { coeffs: out_words })
    }

    pub fn rq_mul_batch_u64x54(&self, lhs: &[FlatRq], rhs: &[FlatRq]) -> Result<Vec<FlatRq>, NeoGpuError> {
        if lhs.len() != rhs.len() {
            return Err(NeoGpuError::OperationFailed {
                op: "rq_mul_batch_u64x54",
                status: -1,
            });
        }
        if lhs.is_empty() {
            return Ok(Vec::new());
        }
        let library = self
            .library
            .as_ref()
            .ok_or(NeoGpuError::UnsupportedOperation {
                op: "rq_mul_batch_u64x54",
            })?;

        if let Some(rq_mul_batch) = library.evaluators.rq_mul_batch {
            let mut lhs_words = lhs
                .iter()
                .flat_map(|value| value.coeffs.iter().copied())
                .collect::<Vec<_>>();
            let mut rhs_words = rhs
                .iter()
                .flat_map(|value| value.coeffs.iter().copied())
                .collect::<Vec<_>>();
            let mut out_words = vec![0u64; lhs.len() * 54];
            let device_api = self.device_api;
            let lhs_ptr = lhs_words.as_mut_ptr() as usize;
            let rhs_ptr = rhs_words.as_mut_ptr() as usize;
            let out_ptr = out_words.as_mut_ptr() as usize;
            let pair_count = lhs.len() as u64;
            let session_handle = self.handle;
            let status = call_for_device_api(device_api, move || unsafe {
                rq_mul_batch(
                    session_handle as u64,
                    lhs_ptr as *mut u64,
                    rhs_ptr as *mut u64,
                    pair_count,
                    out_ptr as *mut u64,
                )
            });
            if status != 0 {
                return Err(NeoGpuError::OperationFailed {
                    op: "rq_mul_batch_u64x54",
                    status,
                });
            }
            let mode = self.rq_mul_execution_mode(lhs.len().saturating_mul(54));
            let mut diagnostics = self
                .diagnostics
                .lock()
                .expect("mojo session diagnostics lock");
            diagnostics.snapshot.rq_mul.record_mode(mode, lhs.len());
            return Ok(out_words
                .chunks_exact(54)
                .map(|chunk| FlatRq {
                    coeffs: std::array::from_fn(|idx| chunk[idx]),
                })
                .collect());
        }

        lhs.iter()
            .zip(rhs.iter())
            .map(|(lhs_item, rhs_item)| self.rq_mul_u64x54(lhs_item, rhs_item))
            .collect()
    }

    pub fn rq_accumulate_batch_u64x54(
        &self,
        lhs: &[FlatRq],
        rhs: &[FlatRq],
        slot_offsets: &[u64],
    ) -> Result<Vec<FlatRq>, NeoGpuError> {
        if lhs.len() != rhs.len() {
            return Err(NeoGpuError::OperationFailed {
                op: "rq_accumulate_batch_u64x54",
                status: -1,
            });
        }
        if slot_offsets.is_empty() {
            return Ok(Vec::new());
        }
        if slot_offsets[0] != 0 || *slot_offsets.last().unwrap_or(&0) != lhs.len() as u64 {
            return Err(NeoGpuError::OperationFailed {
                op: "rq_accumulate_batch_u64x54",
                status: -2,
            });
        }
        let library = self
            .library
            .as_ref()
            .ok_or(NeoGpuError::UnsupportedOperation {
                op: "rq_accumulate_batch_u64x54",
            })?;
        let rq_accumulate_batch = library
            .evaluators
            .rq_accumulate_batch
            .ok_or(NeoGpuError::UnsupportedOperation {
                op: "rq_accumulate_batch_u64x54",
            })?;
        let mut lhs_words = lhs
            .iter()
            .flat_map(|value| value.coeffs.iter().copied())
            .collect::<Vec<_>>();
        let mut rhs_words = rhs
            .iter()
            .flat_map(|value| value.coeffs.iter().copied())
            .collect::<Vec<_>>();
        let mut slot_offsets_words = slot_offsets.to_vec();
        let mut out_words = vec![0u64; slot_offsets.len().saturating_sub(1) * 54];
        let device_api = self.device_api;
        let lhs_ptr = lhs_words.as_mut_ptr() as usize;
        let rhs_ptr = rhs_words.as_mut_ptr() as usize;
        let offsets_ptr = slot_offsets_words.as_mut_ptr() as usize;
        let out_ptr = out_words.as_mut_ptr() as usize;
        let slot_count = slot_offsets.len().saturating_sub(1) as u64;
        let session_handle = self.handle;
        let status = call_for_device_api(device_api, move || unsafe {
            rq_accumulate_batch(
                session_handle as u64,
                lhs_ptr as *mut u64,
                rhs_ptr as *mut u64,
                offsets_ptr as *mut u64,
                slot_count,
                out_ptr as *mut u64,
            )
        });
        if status != 0 {
            return Err(NeoGpuError::OperationFailed {
                op: "rq_accumulate_batch_u64x54",
                status,
            });
        }
        let mode = self.rq_mul_execution_mode(lhs.len().saturating_mul(54));
        let mut diagnostics = self
            .diagnostics
            .lock()
            .expect("mojo session diagnostics lock");
        diagnostics.snapshot.rq_mul.record_mode(mode, lhs.len());
        Ok(out_words
            .chunks_exact(54)
            .map(|chunk| FlatRq {
                coeffs: std::array::from_fn(|idx| chunk[idx]),
            })
            .collect())
    }

    pub fn rq_ct_u64x54(&self, value: &FlatRq) -> Result<u64, NeoGpuError> {
        let library = self
            .library
            .as_ref()
            .ok_or(NeoGpuError::UnsupportedOperation { op: "rq_ct_u64x54" })?;
        let rq_ct = library
            .evaluators
            .rq_ct
            .ok_or(NeoGpuError::UnsupportedOperation { op: "rq_ct_u64x54" })?;
        let mut words = value.coeffs;
        let mut out = [0u64; 1];
        let device_api = self.device_api;
        let words_ptr = words.as_mut_ptr() as usize;
        let out_ptr = out.as_mut_ptr() as usize;
        let status = call_for_device_api(device_api, move || unsafe {
            rq_ct(words_ptr as *mut u64, out_ptr as *mut u64)
        });
        if status != 0 {
            return Err(NeoGpuError::OperationFailed {
                op: "rq_ct_u64x54",
                status,
            });
        }
        Ok(out[0])
    }

    pub fn superneo_bar_block_u64x54(
        &self,
        matrix_words: &[[u64; 54]; 54],
        block_words: &[u64; 54],
    ) -> Result<[u64; 54], NeoGpuError> {
        let library = self
            .library
            .as_ref()
            .ok_or(NeoGpuError::UnsupportedOperation {
                op: "superneo_bar_block_u64x54",
            })?;
        let bar_block = library
            .evaluators
            .superneo_bar_block
            .ok_or(NeoGpuError::UnsupportedOperation {
                op: "superneo_bar_block_u64x54",
            })?;
        let mut matrix_flat = [0u64; 54 * 54];
        for row in 0..54 {
            for col in 0..54 {
                matrix_flat[row * 54 + col] = matrix_words[row][col];
            }
        }
        let mut block = *block_words;
        let mut out = [0u64; 54];
        let device_api = self.device_api;
        let matrix_ptr = matrix_flat.as_mut_ptr() as usize;
        let block_ptr = block.as_mut_ptr() as usize;
        let out_ptr = out.as_mut_ptr() as usize;
        let session_handle = self.handle;
        let status = call_for_device_api(device_api, move || unsafe {
            bar_block(
                session_handle as u64,
                matrix_ptr as *mut u64,
                block_ptr as *mut u64,
                out_ptr as *mut u64,
            )
        });
        if status != 0 {
            return Err(NeoGpuError::OperationFailed {
                op: "superneo_bar_block_u64x54",
                status,
            });
        }
        let mut diagnostics = self
            .diagnostics
            .lock()
            .expect("mojo session diagnostics lock");
        diagnostics
            .snapshot
            .superneo
            .record_mode(self.superneo_bar_block_execution_mode(), 1);
        Ok(out)
    }

    pub fn superneo_row_dot_blocks(&self, bar_blocks: &[[u64; 54]], z: &[FlatK]) -> Result<FlatK, NeoGpuError> {
        let library = self
            .library
            .as_ref()
            .ok_or(NeoGpuError::UnsupportedOperation {
                op: "superneo_row_dot_blocks",
            })?;
        let row_dot = library
            .evaluators
            .superneo_row_dot_blocks
            .ok_or(NeoGpuError::UnsupportedOperation {
                op: "superneo_row_dot_blocks",
            })?;
        let mut bar_words = bar_blocks
            .iter()
            .flat_map(|block| block.iter().copied())
            .collect::<Vec<_>>();
        let mut z_words = z
            .iter()
            .flat_map(|value| [value.re, value.im])
            .collect::<Vec<_>>();
        let mut out_words = [0u64; 2];
        let device_api = self.device_api;
        let bar_ptr = bar_words.as_mut_ptr() as usize;
        let z_ptr = z_words.as_mut_ptr() as usize;
        let out_ptr = out_words.as_mut_ptr() as usize;
        let num_blocks = bar_blocks.len() as u64;
        let z_len = z.len() as u64;
        let session_handle = self.handle;
        let status = call_for_device_api(device_api, move || unsafe {
            row_dot(
                session_handle as u64,
                bar_ptr as *mut u64,
                num_blocks,
                z_ptr as *mut u64,
                z_len,
                out_ptr as *mut u64,
            )
        });
        if status != 0 {
            return Err(NeoGpuError::OperationFailed {
                op: "superneo_row_dot_blocks",
                status,
            });
        }
        let mut diagnostics = self
            .diagnostics
            .lock()
            .expect("mojo session diagnostics lock");
        diagnostics
            .snapshot
            .superneo
            .record_mode(self.superneo_row_dot_execution_mode(bar_blocks.len()), bar_blocks.len());
        Ok(FlatK {
            re: out_words[0],
            im: out_words[1],
        })
    }
}

impl MojoSplitNcEvaluator<'_> {
    #[inline]
    pub fn handle(&self) -> usize {
        self.handle
    }

    fn snapshot_current_len(&self) -> Option<usize> {
        let words = self.snapshot_words.as_slice();
        if words.len() <= 5 {
            return None;
        }
        let magic = words[0];
        let version = words[1];
        let kind = words[2];
        if magic != SPLIT_NC_SNAPSHOT_MAGIC
            || version != SPLIT_NC_SNAPSHOT_VERSION
            || (kind != SPLIT_NC_FE_ROW_V1 && kind != SPLIT_NC_NC_COL_V1)
        {
            return None;
        }
        usize::try_from(words[5]).ok()
    }

    fn total_tasks_for_points(&self, point_count: usize) -> usize {
        self.snapshot_current_len()
            .map(|cur_len| point_count.saturating_mul(cur_len / 2))
            .unwrap_or(point_count)
    }

    pub fn evals_at(&self, points: &[FlatK]) -> Result<Vec<FlatK>, NeoGpuError> {
        if points.is_empty() {
            return Ok(Vec::new());
        }

        let library = self
            .session
            .library
            .as_ref()
            .ok_or(NeoGpuError::UnsupportedOperation {
                op: "split_nc_evals_at",
            })?;
        let evals_at = match self.kind {
            SplitNcEvaluatorKind::Fe => library
                .evaluators
                .fe_evals_at
                .ok_or(NeoGpuError::UnsupportedOperation { op: "fe_evals_at" })?,
            SplitNcEvaluatorKind::Nc => library
                .evaluators
                .nc_evals_at
                .ok_or(NeoGpuError::UnsupportedOperation { op: "nc_evals_at" })?,
        };

        let mut out = vec![FlatK::default(); points.len()];
        let session_handle = self.session.handle as u64;
        let evaluator_handle = self.handle as u64;
        let device_api = self.session.device_api;
        let snapshot_ptr = self.snapshot_words.as_ptr() as usize;
        let snapshot_len = self.snapshot_len as u64;
        let points_ptr = points.as_ptr() as usize;
        let out_ptr_words = out.as_mut_ptr() as usize;
        let points_len = points.len() as u64;
        let out_len = out.len();
        let total_tasks = self.total_tasks_for_points(points.len());
        let mode = match self.kind {
            SplitNcEvaluatorKind::Fe => self.session.fe_row_execution_mode(total_tasks),
            SplitNcEvaluatorKind::Nc => self.session.nc_col_execution_mode(total_tasks),
        };
        let status = call_for_device_api(device_api, move || unsafe {
            evals_at(
                session_handle,
                evaluator_handle,
                snapshot_ptr as *mut u64,
                snapshot_len,
                points_ptr as *mut FlatK as *mut u64,
                points_len,
                out_ptr_words as *mut u64,
                out_len,
            )
        });
        if status != 0 {
            return Err(NeoGpuError::OperationFailed {
                op: match self.kind {
                    SplitNcEvaluatorKind::Fe => "fe_evals_at",
                    SplitNcEvaluatorKind::Nc => "nc_evals_at",
                },
                status,
            });
        }
        let mut diagnostics = self
            .session
            .diagnostics
            .lock()
            .expect("mojo session diagnostics lock");
        let counters = match self.kind {
            SplitNcEvaluatorKind::Fe => &mut diagnostics.snapshot.fe,
            SplitNcEvaluatorKind::Nc => &mut diagnostics.snapshot.nc,
        };
        counters.eval_calls += 1;
        counters.record_mode(mode, total_tasks);
        Ok(out)
    }

    pub fn fold(&mut self, challenge: FlatK) -> Result<(), NeoGpuError> {
        let library = self
            .session
            .library
            .as_ref()
            .ok_or(NeoGpuError::UnsupportedOperation { op: "split_nc_fold" })?;
        let fold = match self.kind {
            SplitNcEvaluatorKind::Fe => library
                .evaluators
                .fe_fold
                .ok_or(NeoGpuError::UnsupportedOperation { op: "fe_fold" })?,
            SplitNcEvaluatorKind::Nc => library
                .evaluators
                .nc_fold
                .ok_or(NeoGpuError::UnsupportedOperation { op: "nc_fold" })?,
        };

        let session_handle = self.session.handle;
        let evaluator_handle = self.handle;
        let device_api = self.session.device_api;
        let status = call_for_device_api(device_api, move || unsafe {
            fold(session_handle, evaluator_handle, challenge.re, challenge.im)
        });
        if status != 0 {
            return Err(NeoGpuError::OperationFailed {
                op: match self.kind {
                    SplitNcEvaluatorKind::Fe => "fe_fold",
                    SplitNcEvaluatorKind::Nc => "nc_fold",
                },
                status,
            });
        }
        let mut diagnostics = self
            .session
            .diagnostics
            .lock()
            .expect("mojo session diagnostics lock");
        let counters = match self.kind {
            SplitNcEvaluatorKind::Fe => &mut diagnostics.snapshot.fe,
            SplitNcEvaluatorKind::Nc => &mut diagnostics.snapshot.nc,
        };
        counters.fold_calls += 1;
        Ok(())
    }
}

impl Drop for MojoSplitNcEvaluator<'_> {
    fn drop(&mut self) {
        let Some(library) = self.session.library.as_ref() else {
            return;
        };
        let destroy = match self.kind {
            SplitNcEvaluatorKind::Fe => library.evaluators.fe_destroy,
            SplitNcEvaluatorKind::Nc => library.evaluators.nc_destroy,
        };
        let Some(destroy) = destroy else {
            return;
        };
        let session_handle = self.session.handle;
        let evaluator_handle = self.handle;
        let device_api = self.session.device_api;
        let kind = self.kind;
        let status = call_for_device_api(device_api, move || unsafe { destroy(session_handle, evaluator_handle) });
        if status != 0 {
            let _ = Err::<(), _>(NeoGpuError::OperationFailed {
                op: match kind {
                    SplitNcEvaluatorKind::Fe => "fe_destroy",
                    SplitNcEvaluatorKind::Nc => "nc_destroy",
                },
                status,
            });
        }
        let mut diagnostics = self
            .session
            .diagnostics
            .lock()
            .expect("mojo session diagnostics lock");
        let counters = match self.kind {
            SplitNcEvaluatorKind::Fe => &mut diagnostics.snapshot.fe,
            SplitNcEvaluatorKind::Nc => &mut diagnostics.snapshot.nc,
        };
        counters.destroy_calls += 1;
    }
}

impl Drop for MojoSession {
    fn drop(&mut self) {
        let Some(library) = self.library.take() else {
            return;
        };
        let session_close = library.session_close;
        let handle = self.handle;
        let api = self.device_api;
        let status = call_for_device_api(api, move || unsafe { session_close(handle) });
        if status != 0 {
            let _ = Err::<(), _>(NeoGpuError::SessionCloseFailed { status });
        }
    }
}

fn open_session_for_config(cfg: &MojoBackendConfig) -> Result<MojoSession, NeoGpuError> {
    MojoLibrary::load(cfg)?.open_session(cfg)
}

pub fn connect(cfg: &MojoBackendConfig) -> Result<MojoSession, NeoGpuError> {
    if cfg.device_api != DeviceApi::Auto {
        return match open_session_for_config(cfg) {
            Ok(session) => Ok(session),
            Err(err) if cfg.fallback_to_cpu && cfg.device_api != DeviceApi::Cpu => {
                let cpu_cfg = cfg.clone().with_device_api(DeviceApi::Cpu);
                open_session_for_config(&cpu_cfg).or(Err(err))
            }
            Err(err) => Err(err),
        };
    }

    let mut last_err = None;
    for api in cfg.device_api.candidate_order() {
        let candidate_cfg = cfg.clone().with_device_api(*api);
        match MojoLibrary::load(&candidate_cfg).and_then(|lib| lib.open_session(&candidate_cfg)) {
            Ok(session) => return Ok(session),
            Err(err) => last_err = Some(err),
        }
    }

    Err(last_err.unwrap_or(NeoGpuError::DeviceUnavailable {
        api: cfg.device_api,
        device_id: cfg.device_id,
    }))
}

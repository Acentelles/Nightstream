# Nightstream Mojo GPU Scaffold

This directory is the staged Mojo shared-library project for prover-side GPU acceleration.

Current scope:

- keep proof format, verifier logic, and Poseidon2 transcript semantics unchanged,
- expose a small C ABI that Rust can load through `crates/neo-gpu`,
- start with Split-NC FE/NC evaluator hooks,
- leave witness decoding, transcript control, and final proof assembly in Rust.

Project status:

- `mojo` is installed locally through `pixi`,
- the Rust side is already wired to load a shared library and select it explicitly through
  `ProverComputeBackend::Mojo(...)` or automatically through `ProverComputeBackend::auto()`,
- the shared library now contains a bit-exact width-8 Poseidon2 permutation primitive,
- `src/poseidon_gpu_compare.mojo` is the first Mojo GPU API harness for CPU-vs-GPU parity checks.

## Layout

- `pixi.toml`: pinned Mojo toolchain environment
- `mojoproject.toml`: Nightstream-local build and ABI metadata
- `src/lib.mojo`: shared-library export surface
- `src/nightstream_gpu/field.mojo`: Goldilocks/K/Rq arithmetic
- `src/nightstream_gpu/ring.mojo`: ring helpers and reductions
- `src/nightstream_gpu/superneo.mojo`: SuperNeo row/block helpers
- `src/nightstream_gpu/sumcheck.mojo`: FE/NC evaluator state and fold kernels
- `src/nightstream_gpu/poseidon.mojo`: Poseidon2 primitive entrypoints used by the shared library
- `src/nightstream_gpu/ffi.mojo`: ABI-facing stub implementations
- `src/poseidon_gpu_compare.mojo`: batched Mojo GPU API parity check for Poseidon2
- `src/poseidon_gpu_bench.mojo`: Mojo CPU vs batched Mojo GPU throughput benchmark

## Build

Current Modular docs use `pixi.toml` to manage Mojo projects, so this scaffold includes both:

- `pixi.toml` for the pinned environment
- `mojoproject.toml` for repo-local metadata and expected output naming

Build the shared library from this directory with:

```bash
pixi run mojo build --emit shared-lib src/lib.mojo -o build/libnightstream_mojo_gpu.dylib
```

On Linux or Windows, adjust the output filename to `.so` or `.dll`.

Run the direct GPU parity harness with:

```bash
pixi run mojo run src/poseidon_gpu_compare.mojo
```

This harness uses `gpu.host.DeviceContext`, launches a batched Poseidon2 kernel across many
independent width-8 states, and compares the GPU result against the CPU Mojo implementation.

Current verified status:

- the standalone Mojo GPU scripts are the authoritative CPU-vs-GPU parity and perf path,
- the shared library exports the same Poseidon2 batch symbol and can be used from Rust in
  CPU/direct mode today,
- Rust-side auto selection prefers `Metal` on macOS and `Cuda`/`Hip` on non-macOS hosts, then
  falls back to the Mojo CPU session if no accelerator session opens,
- real shared-library Metal sessions are stable for the Rust bridge path, including Split-NC FE/NC
  parity through the same shared-library session path used on CUDA,
- real reductions-level CUDA parity is working for transcript digest checks, FE/NC round parity, and
  `optimized_prove` parity,
- real `neo-fold` CCS-only batched proving and Poseidon2 single-step prove/verify parity now pass on
  supported Mac and CUDA-backed T4 setups through the Rust bridge.

## Current State

### Implemented

- Goldilocks / `K` arithmetic in `src/nightstream_gpu/field.mojo`
- Poseidon2 shared-library entrypoints in `src/nightstream_gpu/poseidon.mojo`
- Split-NC FE/NC shared-library evaluators, including resident `fe_fold` / `nc_fold`, in
  `src/nightstream_gpu/sumcheck.mojo`
- Session-owned persistent buffers and kernel caches in `src/nightstream_gpu/runtime.mojo`
- `Rq` arithmetic and batch multiply entrypoints in `src/nightstream_gpu/ring.mojo`
- SuperNeo block helpers in `src/nightstream_gpu/superneo.mojo`
- Rust bridge loading, backend policy, diagnostics, and session methods in `crates/neo-gpu`
- Reductions-level hybrid backend use for transcript Poseidon and Split-NC FE/NC in
  `crates/neo-reductions`
- Initial commit-side / Ajtai-side Mojo integration in `crates/neo-fold`, including backend-aware
  `commit_many` and ring-based commitment mixing

### Parity Complete But Not Yet Performance-Promoted

- Metal Split-NC FE/NC shared-library parity
  - FE row oracle parity passes
  - NC col oracle parity passes
  - `optimized_prove` parity passes
- Metal and CUDA Poseidon2 shared-library parity
- Metal and CUDA `Rq` / SuperNeo primitive parity
- CUDA note-spend proving path
  - end-to-end proving is slightly faster than CPU on the T4 baseline
- Metal note-spend proving path
  - end-to-end parity is correct
  - current proving performance is still worse than CPU

### Implemented But Still Stub-Like / Partial

- `src/nightstream_gpu/ffi.mojo`
  - production ABI exists and now reports per-backend capability bits
  - `device_probe` / session selection are still intentionally small and session-oriented rather
    than a large global backend manager
- `src/nightstream_gpu/ring.mojo`
  - `Rq` multiply batch exists and is wired into note-spend commitment paths
  - current GPU kernel shape is correctness-first and not yet tuned for Metal
- `src/nightstream_gpu/superneo.mojo`
  - exported helpers are real and parity-tested
  - they are not yet the dominant backend for note-spend hot loops

### Mocked In Tests

- `crates/neo-gpu/tests/support/mock-mojo-gpu/src/lib.rs`
  - still the fast mock shared library used by many CI/integration tests
  - used to verify call routing and parity without requiring a real Mojo toolchain or GPU
- Some `neo-fold` integration tests still validate “backend path was exercised” through the mock
  dylib instead of requiring a real accelerator session
- Real shared-lib coverage now complements the mock path for:
  - ring / SuperNeo session parity on local CPU-direct sessions
  - Metal ring / SuperNeo session parity on macOS
  - CUDA ring / SuperNeo session parity on the T4 VM
  - seeded CCS-only commit-many parity through a real Mojo CPU session

### Explicitly Disabled / Gated Today

- Metal commit-side acceleration for note-spend hot lanes is intentionally conservative
  - Stage-8 joint-opening commitment acceleration is gated off on Metal
  - `RlcLane::Val` commitment/ring acceleration is gated off on Metal
  - reason: the current Metal `Rq` path is parity-correct but still too slow for those hot lanes
- Below threshold, `auto()` keeps work on Rust CPU instead of forcing a Mojo path
- Mojo CPU/direct fallback is still preferred only when the explicit backend choice or policy calls
  for it; otherwise `auto()` can stay entirely on Rust CPU

### Known Gaps

- Note-spend lane batching is still incomplete
  - sibling lanes are not yet collapsed into a few large resident GPU jobs
- Stage-8 `prove_rlc_dec_lane` is still the main remaining hot path for note-spend
- The current ring / commitment-side GPU path is only mildly beneficial on CUDA and still too slow
  on Metal
- End-to-end note-spend GPU wins are still small on CUDA and negative on Metal

### Practical Backend Status

| Area | CPU | Metal | CUDA | Notes |
|------|-----|-------|------|-------|
| Poseidon2 batch | Yes | Yes | Yes | Real shared-lib parity on both accelerators. |
| Split-NC FE/NC parity | Yes | Yes | Yes | Metal now matches CUDA at shared-lib parity level. |
| Split-NC FE/NC promotion | N/A | Yes | Yes | Threshold-driven in Rust. |
| `Rq` batch multiply parity | Yes | Yes | Yes | Real session parity exists. |
| Commit-side promotion | N/A | Partial | Partial | CUDA is modestly useful; Metal is still gated in hot lanes. |
| Note-spend end-to-end speedup | Baseline | No | Small yes | Metal remains slower than CPU on the canonical repro. |

Current backend matrix:

| Path | CPU session | Metal session | CUDA session | Notes |
|------|-------------|---------------|--------------|-------|
| Poseidon2 single/batch via Rust bridge | Yes | Yes | Yes | Rust bridge is the supported production entrypoint. |
| Poseidon2 accelerator execution | No | Yes | Yes | Metal uses the bridge-thread fix on macOS. |
| Split-NC FE/NC via shared library | Yes | Yes | Yes | Metal and CUDA both use the shared-library evaluator path. |
| Split-NC accelerator execution | No | Yes | Yes | Metal now follows the same FE/NC evaluator promotion model as CUDA/HIP. |
| Rust CPU fallback when Mojo unavailable | Yes | Yes | Yes | Auto mode falls back to Rust CPU only if no Mojo session can be opened. |
| Mojo CPU/direct fallback when requested accelerator is unavailable | Yes | Yes | Yes | Explicit Mojo backend configs prefer a Mojo CPU session before dropping to Rust CPU. |

Run the throughput benchmark with:

```bash
pixi run mojo run src/poseidon_gpu_bench.mojo
```

The benchmark reports:

- `cpu`: serial Mojo CPU throughput over many states
- `gpu_steady`: GPU throughput with persistent device buffers and repeated kernel launches
- `gpu_roundtrip`: GPU throughput including host-device copies each iteration

## Version Pin

The environment is pinned to `mojo==0.26.1` for reproducibility. Update that pin deliberately when
we start relying on newer GPU APIs or language changes.

## Implementation Roadmap

Assumptions:

- proof format, verifier logic, and transcript semantics remain unchanged,
- Rust remains the protocol/orchestration layer,
- CUDA is the primary acceleration target,
- Metal is correctness-first and may stay partially CPU-gated in note-spend hot lanes until stable,
- GPU promotion must be justified by end-to-end prover wins, not only kernel microbenches.

### Milestone 1: Shared-Library Runtime Hardening

- [ ] replace deprecated `enqueue_function` launches with `enqueue_function_checked` in Poseidon and
  sumcheck kernels,
- [x] keep the Rust `neo-gpu` loader as the only supported production entrypoint for Mojo GPU work,
- [x] keep Metal Poseidon shared-lib enabled through the Rust bridge fix,
- [x] stabilize Metal Split-NC through the shared-library evaluator path,
- [x] add explicit backend fallback/status reporting so we can tell whether a path ran on CPU, Metal
  host mode, or real accelerator execution,
- [x] document the supported backend matrix clearly in this README and in the Rust bridge docs.

### Milestone 2: Persistent Sessions And Buffers

- [x] add persistent session-owned host/device buffers for Poseidon batch,
- [x] add persistent session-owned host/device buffers for FE/NC evaluator calls,
- [x] cache compiled kernels on the Mojo side,
- [x] cache uploaded immutable tables on the Mojo side,
- [x] follow the `neo-midnight-mojo-bridge` pattern of reusing GPU context and uploaded state
  instead of recreating them on every call,
- [x] centralize buffer lifetime and reuse behind the Rust session boundary so callers do not manage
  raw GPU resources directly.

### Milestone 3: Split-NC Correctness Completion

- [x] keep Rust as the canonical FE/NC snapshot builder,
- [x] flatten FE/NC snapshot tables into stable ABI payloads with no witness decoding on the Mojo
  side,
- [x] implement Mojo-side `fe_fold` so FE evaluators can stay resident across rounds,
- [x] implement Mojo-side `nc_fold` so NC evaluators can stay resident across rounds,
- [x] avoid rebuilding full FE/NC evaluator state on every round once fold support is in place,
- [x] keep CPU Ajtai-tail rounds unchanged and synchronized with the Mojo-backed phase.

### Milestone 4: Stage-Level Parity Coverage

- [x] add stage-specific FE chunk snapshot fixtures,
- [x] add stage-specific FE aggregate snapshot fixtures,
- [x] add stage-specific NC chunk snapshot fixtures,
- [x] add stage-specific NC aggregate snapshot fixtures,
- [x] add terminal FE/NC round fixtures,
- [x] add real Mojo parity tests for `neo-fold` RLC input binding and CCS-only batched folding,
- [x] keep end-to-end `optimized_prove` parity tests as the final correctness gate,
- [x] add Mojo golden-vector tests once a Mojo toolchain is available in CI or on a supported dev
  host.

### Milestone 5: CUDA Sign-Off

- [x] add CUDA-only real-accelerator parity tests for Poseidon batch,
- [x] add CUDA-only real-accelerator parity tests for FE evaluator creation/evals/fold,
- [x] add CUDA-only real-accelerator parity tests for NC evaluator creation/evals/fold,
- [x] add CUDA-only real `optimized_prove` parity checks,
- [x] add one real `neo-fold` multi-step prove/verify CUDA-backed parity test,
- [x] run these on the Ubuntu CUDA VM until GPU CI is available.

### Milestone 6: Thresholds And Backend Policy

- [x] add threshold sweep benches for Poseidon batch,
- [x] add threshold sweep benches for FE row phase,
- [x] add threshold sweep benches for NC column phase,
- [x] store measured cutovers in one place in Rust instead of scattering ad hoc constants,
- [x] make backend activation policy threshold-driven and backend-specific,
- [x] keep CPU fallback as the default below cutover sizes.

### Milestone 7: Remaining Mojo Modules

- [x] finish `src/nightstream_gpu/ring.mojo`,
- [x] finish `src/nightstream_gpu/superneo.mojo`,
- [x] connect those modules to Ajtai/commit-side acceleration only after Split-NC is stable,
- [x] keep proof-compatible transcript binding on the Rust side while those modules land.

### Milestone 8: End-To-End Performance Promotion

- [x] add one backend-compare performance test for a real `neo-fold` multi-step proof on CUDA,
- [x] report CPU baseline, GPU steady-state, GPU roundtrip, and end-to-end prove time,
- [x] promote a GPU path only when it improves the real prover flow rather than only microbench
  numbers,
- [x] revisit Metal Split-NC after CUDA was stable and the shared-lib Metal runtime issue was
  isolated.

## Current Optimization Priorities

1. Reduce note-spend Stage-8 `prove_rlc_dec_lane` time.
2. Batch more commitment/ring work across sibling lanes.
3. Improve the Metal `Rq` batch kernel enough to remove current hot-lane gates.
4. Keep CUDA promoted where it beats CPU, and keep Metal conservative until it does.

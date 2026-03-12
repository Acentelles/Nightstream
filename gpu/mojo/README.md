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
- real shared-library Metal sessions are stable for the Rust bridge path, but Split-NC still uses a
  Mojo CPU/direct companion session there until Metal Split-NC acceleration is fully signed off,
- real reductions-level CUDA parity is working for transcript digest checks, FE/NC round parity, and
  `optimized_prove` parity,
- real `neo-fold` CCS-only batched proving and Poseidon2 single-step prove/verify parity now pass on
  supported Mac and CUDA-backed T4 setups through the Rust bridge.

Current backend matrix:

| Path | CPU session | Metal session | CUDA session | Notes |
|------|-------------|---------------|--------------|-------|
| Poseidon2 single/batch via Rust bridge | Yes | Yes | Yes | Rust bridge is the supported production entrypoint. |
| Poseidon2 accelerator execution | No | Yes | Yes | Metal uses the bridge-thread fix on macOS. |
| Split-NC FE/NC via shared library | Yes | No | Yes | Metal uses a Mojo CPU/direct companion session through `BackendContext`, not a Metal Split-NC session. |
| Split-NC accelerator execution | No | No | Yes | CUDA is the promoted real-accelerator target for Split-NC today. |
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
- Metal is correctness-first and may stay partially host-backed until stable,
- GPU promotion must be justified by end-to-end prover wins, not only kernel microbenches.

### Milestone 1: Shared-Library Runtime Hardening

- [ ] replace deprecated `enqueue_function` launches with `enqueue_function_checked` in Poseidon and
  sumcheck kernels,
- [x] keep the Rust `neo-gpu` loader as the only supported production entrypoint for Mojo GPU work,
- [x] keep Metal Poseidon shared-lib enabled through the Rust bridge fix,
- [x] keep Metal Split-NC disabled until its separate shared-lib instability is resolved,
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
- [x] revisit Metal Split-NC only after CUDA is stable and the shared-lib Metal runtime issue is
  isolated.

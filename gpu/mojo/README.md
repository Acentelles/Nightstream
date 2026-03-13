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
- Stage-8 `prove_rlc_dec_lane` now routes through the backend-aware commitment path, but it is still
  the main remaining hot path for note-spend
- The current ring / commitment-side GPU path is only mildly beneficial on CUDA and still too slow
  on Metal
- End-to-end note-spend GPU wins are still small on CUDA and negative on Metal

## Paper-Informed Performance Roadmap

The SuperNeo, Twist/Shout, and Jolt papers all point to the same conclusion: real prover wins
come from changing the shape of the prover work so the accelerator sees a few large resident jobs,
not from offloading many small scalar loops one by one.

Protocol takeaways we should follow:

- SuperNeo's evaluation homomorphism wants ring-linear combinations to stay in ring space until
  the final constant-term extraction.
- Twist/Shout's fast prover implementations win by grouping terms that share multiplicative updates,
  choosing a GPU-friendly variable-binding order, and rebuilding larger partial aggregates instead
  of processing fragmented rows independently.
- Jolt's qualitative cost model reinforces that commitment-side and memory-checking work dominate
  prover time once primitive hashes are no longer the bottleneck.

Current implementation mismatch:

- Stage-8 still clusters only by identical `(point, domain)` groups, which is better than the old
  one-group-per-proof path but still too fragmented for the dominant hot loop.
- `Rq` acceleration exists, but Stage-8 / WB / WP / `Val` work is still launched as many smaller
  jobs rather than a few large resident batches.
- SuperNeo row-dot still materializes intermediate channel buffers and performs the final constant
  term extraction after the accumulated ring products, leaving fusion headroom.
- Split-NC FE/NC kernels still emit grouped partials that are reduced on the host rather than
  finishing the reduction on-device.

Concrete optimization roadmap:

1. Step-level ring super-batching
   - Batch Stage-8, WB, WP, and `Val` parent commitment mixing through shared `rq_accumulate`
     backend calls.
   - Extend that same batching strategy to DEC child `commit_many` work so we stop paying per-lane
     submission overhead.
   - Goal: move from lane-local GPU calls to a small number of step-local ring jobs.

2. Stage-8 clustering by update structure, not only point/domain
   - Reorganize Stage-8 around shared challenge/update structure so heterogeneous groups can still
     collapse when they share the same multiplicative schedule.
   - Goal: match the Twist/Shout lesson of aggregating terms with identical update factors.

3. Fully fused SuperNeo row-dot
   - Replace the current `bar_blocks -> rq_accumulate -> rq_ct` split with one device-resident
     reduction that multiplies, accumulates, and extracts the final constant terms on device.
   - Goal: turn SuperNeo into the dominant backend for the hot ring-dot loops instead of a helper.

4. Device-side Split-NC reductions
   - Keep FE/NC snapshot creation in Rust, but finish grouped partial reductions on device instead
     of copying partials back for host reduction.
   - Goal: keep one oracle round resident until final outputs are ready.

5. GPU-first buffer layout
   - Store hot Stage-8 / SuperNeo / `Rq` batches in coefficient-packed, coalesced layouts instead
     of repacking CPU-oriented matrices before every kernel launch.
   - Goal: make large resident jobs cheap to launch and cheap to feed.

Roadmap status on this branch:

1. Step-level ring super-batching
   - Implemented:
     - `Val` parent commitment mixing is batched across claims before lane proving.
     - `Val` materialized DEC child commitments now share one batched `commit_many` finalize path.
     - WB/WP parent mixing and materialized DEC child commitments already share batched commit paths.
     - Stage-8 joint groups already share batched `joint_commit_many`.
     - Stage-8 multi-group cluster witnesses now share one batched commit pass instead of one commit per cluster.
   - Still missing:
     - Stage-8, WB, WP, and `Val` are still separate jobs; they are not yet collapsed into one step-global resident ring job.
     - Stage-8 unified-fold and cluster planning still creates more jobs than the paper-guided ideal.

2. Stage-8 clustering by update structure, not only point/domain
   - Implemented:
     - Stage-8 can collapse to one fold claim when groups share the same point/domain.
     - Each reduction group now carries an `update_class_digest` derived from the actual ordered
       multiplicative update schedule: per-claim opening-batch `eta` matrices plus the reduction-level
       `rho` mixers used to form the Stage-8 joint group.
     - Heterogeneous Stage-8 groups now cluster by shared `update_class_digest`, so groups only share a
       cluster when the prover is applying the same real update schedule rather than just a matching layout.
   - Still missing:
     - The current digest is group-local. We still do not derive a larger step-global schedule that can
       coalesce Stage-8, WB, WP, and `Val` work into a single resident ring job.
     - We still do not exploit finer-grained update-schedule structure inside each clustered batch.

3. Fully fused SuperNeo row-dot
   - Implemented:
     - SuperNeo routes the heavy ring products through the GPU `Rq` path.
   - Still missing:
     - The final row-dot remains a staged flow rather than one fully fused on-device reduction.
     - Constant-term extraction is not yet integrated into one dominant resident SuperNeo kernel.

4. Device-side Split-NC reductions
   - Implemented:
     - FE/NC evaluation parity and backend routing are in place for CUDA and Metal.
   - Still missing:
     - Grouped partials are still copied back and reduced on the host.

5. GPU-first buffer layout
   - Implemented:
     - None as a dedicated layout layer yet; current improvements still reuse mostly CPU-oriented layouts.
   - Still missing:
     - Hot Stage-8 / SuperNeo / `Rq` buffers are still repacked per operation instead of stored in a GPU-first resident format.

Execution plan for this branch:

- Step 1 now: keep widening Stage-8 batching so cluster/unified commitments are paid once per phase.
- Step 2 next: redesign Stage-8 clustering around shared update structure instead of only point/domain.
- Step 3 after that: fuse SuperNeo row-dot into one device-resident reduction.

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
| Split-NC accelerator execution | No | Yes | Yes | Metal now follows the same FE/NC evaluator promotion model as CUDA. |
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

- [x] keep kernel launches on the current checked Mojo API surface; in the pinned Mojo `0.26.1`
  toolchain `enqueue_function_checked` was renamed to `enqueue_function`,
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

## Review Status (2026-03-13, updated)

Post-review audit of the `feature/gpu-acceleration` branch against the issues raised in
`GPU_CODE_REVIEW.md`. Items are grouped by current status.

### Resolved

| Issue | Original Severity | Resolution |
|-------|-------------------|------------|
| Snapshot bounds validation | P1 HIGH | `validate_fe_snapshot_layout()` / `validate_nc_snapshot_layout()` with overflow-safe `checked_mul_words` / `checked_add_words` helpers; called on every create, evals_at, and fold entry. |
| Extension field canonicalization | LOW | `k_add`, `k_sub`, `k_mul` now canonicalize both inputs. `k_store` and `k_load` also canonicalize. |
| Snapshot schema versioning | P2 | Magic, version, and per-kind tags (`FE_ROW_V1`, `NC_COL_V1`) checked at every snapshot entry point. |
| `enqueue_function` deprecation | P3 | Non-issue: Mojo 0.26.1 renamed `enqueue_function_checked` to `enqueue_function`. Current calls are the checked API. |
| Poseidon2 batch race condition | MEDIUM | `batch` array is a temporary rebuilt per chunk; `states[input_idx]` only written after successful permutation. Failure returns `Ok(None)` or `Err`. |
| Non-constant-time field ops | MEDIUM | `field.mojo` now documents: "These helpers are only used for public/hash-side arithmetic today. They are not written as constant-time primitives for secret witness handling." |
| SuperNeo was CPU-only | P2 | Real GPU kernel (`superneo_bar_block_gpu_kernel`) with per-thread row parallelism. `superneo_row_dot_blocks_gpu_words` batches ring multiplies through the GPU path. Rust-side `SuperneoMatrixCache` / `SuperneoLinearForm` / `SuperneoZBlocks` now cache transformed blocks for repeated evaluations. |
| Note-spend e2e GPU test missing | P0 | `test_rv64_note_from_elf.rs` has: strict-Mojo prove + verify, byte-exact CPU-vs-Mojo proof parity, multi-iteration median benchmarks, and `accelerator_calls > 0` assertions. `split_nc_gpu_parity.rs` adds 211 lines of new FE/NC/SuperNeo parity tests. All `#[ignore]` (slow perf repros). |
| Ring host-reduce inefficiency | P2 | Stage-8/commit-side Rust routing now prefers fused `rq_accumulate` for accelerator sessions, and `RQ_ACCUMULATE_GPU_MIN_SLOTS = 1` keeps the dedicated accumulate kernel on the fast path. Host-reduce fallback only used when `slot_count < 1` (effectively never). |
| Stage-8 `prove_rlc_dec_lane` was CPU-only | P1 | `prove_rlc_dec_lane` now accepts `force_backend_commit_accel` and routes `mix_rhos_commits` / `combine_b_pows` through the Mojo `rq_accumulate` path. `mojo_commit_mix.rs` expanded with batched multi-group ring mix (`mix_many_rhos_commits_with_mojo`) and `combine_b_pows_with_mojo`. FE oracle's Ajtai-phase evals now thread through `evals_at_with_backend` for backend-aware SuperNeo evaluation. |
| HIP was half-exposed in Rust config | P3 | Rust now only exposes `Cpu` / `Metal` / `Cuda` / `Auto`. The branch no longer advertises `DeviceApi::Hip` as a selectable backend while HIP remains unsupported in the real Mojo runtime. |

### Mitigated (acceptable but not fully closed)

| Issue | Original Severity | Current State | Remaining Gap |
|-------|-------------------|---------------|---------------|
| GPU fold failure causes state misalignment | P0 HIGH | FE/NC fold is now atomic at the wrapper level: a fresh shadow evaluator folds first, the live GPU evaluator is only swapped in on success, and failures fall back to the canonical CPU snapshot. No divergent GPU state is kept after an error, and later rounds may recreate the evaluator from CPU state. | There is still no proof-level retry/abort transaction. A failed accelerator fold wastes that attempt's GPU work and the proof continues from CPU-owned state. |
| Inconsistent error handling | P1 HIGH | Split-NC oracle wrappers now capture strict-mode FE/NC create/eval/fold failures as deferred `PiCcsError`s and surface them through the prover instead of panicking. Optional paths still downgrade to CPU fallback through the backend breaker. | Some strict commit-mix helper paths still use `panic!()` in no-fallback mode because the surrounding ring-mix APIs are still `Cmt`-returning rather than `Result`-returning. |
| Circuit breaker for GPU failures | P2 | Two-level breaker: per-oracle (`SPLIT_NC_MAX_FAILURES_PER_ORACLE = 1`) and per-session (`BACKEND_MAX_FAILURES_PER_SESSION = 1`). After one create/eval failure the backend is disabled for the remainder of the oracle/session, and breaker activations are emitted to stderr. Atomic fold failures now drop only the evaluator and retry from CPU snapshot on the next round. | No exponential backoff, no cooldown period, and breaker logging is visible but still ad hoc rather than a structured telemetry stream. |

### Open (requires further work)

| Priority | Issue | Location | Detail |
|----------|-------|----------|--------|
| **P1** | Stage-8 `prove_rlc_dec_lane` is still the dominant bottleneck | `crates/neo-fold` | Stage-8 now uses the backend-aware commit path and clusters heterogeneous groups by a digest of the real per-group `eta`/`rho` update schedule, but the work is still only clustered within Stage-8 itself and note-spend end-to-end wins remain modest on CUDA and negative on Metal. |
| **P2** | Metal `Rq` batch slower than CPU | `ring.mojo` | Parity-correct but too slow for hot lanes. Stage-8 joint-opening and `RlcLane::Val` acceleration are gated off on Metal. |
| **P2** | Note-spend lane batching incomplete | `crates/neo-fold` | Collapsible Stage-8 sibling groups now reduce to one fold claim, but WB/WP / heterogeneous Stage-8 groups are still not collapsed into a few large resident GPU jobs. |
| **P3** | No automated accelerator CI gate | CI | GitHub Actions now runs a real Mojo CPU parity lane and a manual self-hosted Metal/CUDA parity workflow, but accelerator coverage is still not a required merge gate. GPU-breaking changes can still merge unless someone runs the manual GPU workflow. |

## Current Optimization Priorities

1. Reduce note-spend Stage-8 `prove_rlc_dec_lane` time.
2. Batch more commitment/ring work across sibling lanes.
3. Improve the Metal `Rq` batch kernel enough to remove current hot-lane gates.
4. Keep CUDA promoted where it beats CPU, and keep Metal conservative until it does.

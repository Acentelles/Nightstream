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
     - `Val` and WB/WP now also share one combined parent ring-mix batch and one combined materialized
       DEC child commit batch, so those lanes no longer pay separate commit-side launches.
     - Materialized DEC child finalization now groups `commit_many` work by actual Ajtai width / global
       committer availability instead of assuming one committer shape for every pending batch.
     - Stage-8 joint groups already share batched `joint_commit_many`.
     - Stage-8 multi-group cluster witnesses now share one batched commit pass instead of one commit per cluster.
     - Stage-8 now pre-samples its own `ρ` schedule and joins the same step-level parent ring-mix batch as
       the earlier folding lanes instead of paying a standalone parent mix.
   - Still missing:
     - Stage-8 still uses its own downstream DEC/commit path after the shared parent batch; we do not yet
       have one fully resident step-global ring/DEC job.
     - Stage-8 unified-fold and cluster planning still creates more jobs than the paper-guided ideal.

2. Stage-8 clustering by update structure, not only point/domain
   - Implemented:
     - Stage-8 can collapse to one fold claim when groups share the same point/domain.
     - Each joint-opening group now carries a schedule-derived `update_class_digest` bound to the ordered
       per-claim `eta` matrices used to build that group's Stage-8 witness.
     - Heterogeneous Stage-8 groups now cluster by shared `update_class_digest` instead of only by identical
       `(point, domain)` anchors.
     - When a clustered batch is heterogeneous in `(point, domain)`, the prover/verifier now treat it as a
       transcript-mixed synthetic Stage-8 cluster anchored at `(r_unify, Cpu)` rather than pretending it is a
       real opening at one member point. `trace_shout` and integration parity cover this path.
   - Still missing:
     - We still do not derive a larger step-global schedule that can coalesce Stage-8, WB, WP, and `Val`
       work into a single resident ring job.
     - We still do not exploit finer-grained update-schedule structure inside each clustered batch.

3. Fully fused SuperNeo row-dot
   - Implemented:
     - SuperNeo routes the heavy ring products through the GPU `Rq` path.
     - The GPU row-dot path now emits the final `(re, im)` constant terms from one device-resident
       kernel instead of staging `rq_accumulate` outputs back to the host and calling `rq_ct` there.
     - The fused GPU row-dot path now parallelizes over bar blocks, writes packed per-block partials into
       a resident device buffer, and performs the final reduction on device.
   - Still missing:
     - The fused row-dot kernel is still correctness-first; it is not yet the dominant,
       throughput-tuned SuperNeo kernel for note-spend hot loops.
     - Stage-8 and sibling lanes still do not feed SuperNeo through a GPU-first resident buffer layout.

4. Device-side Split-NC reductions
   - Implemented:
     - FE/NC evaluation parity and backend routing are in place for CUDA and Metal.
     - FE/NC grouped partials are now reduced on device; only final per-point outputs are copied back.
   - Still missing:
     - Snapshot creation/folding still starts from CPU-owned layouts, so FE/NC rounds are not yet fully
       end-to-end resident.

5. GPU-first buffer layout
   - Implemented:
     - SuperNeo row-dot now uses a dedicated packed resident buffer layout for block words, interleaved
       `z` channels, and per-block partial outputs on device.
     - Split-NC FE/NC now reuses resident device buffers for points, grouped partials, and final outputs.
     - `Rq` multiply / accumulate kernels now choose the sparser operand for the outer loop and skip zero
       coefficients entirely, which better matches the low-norm decomposed witness shape in Ajtai-heavy paths.
     - Scalar-only ring factors now use a dedicated fast path in `ring.mojo`, which helps `combine_b_pows`
       and other constant-term-heavy commitment mixing avoid the general convolution loop.
   - Still missing:
     - Hot Stage-8 / generic `Rq` lane buffers are still repacked per operation instead of stored in one
       step-resident GPU-first format.

Execution plan for this branch:

- Step 1 now: push Stage-8 past the shared parent ring-mix into the same downstream DEC/commit finalize path as the
  other folding lanes when the shapes line up.
- Step 2 now: derive a larger step-global schedule that can coalesce Stage-8, WB, WP, and `Val` work into fewer
  resident ring jobs.
- Step 3 next: keep more Split-NC snapshot/fold state resident instead of rebuilding from CPU-owned layouts.

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
| SuperNeo was CPU-only | P2 | Real GPU kernel (`superneo_bar_block_gpu_kernel`) with per-thread row parallelism. `superneo_row_dot_blocks_gpu_kernel` now fuses ring multiply and constant-term extraction into one device-resident kernel via `rq_mul_ct_z_channel_words`, eliminating the old staged `rq_accumulate → rq_ct` round-trip. Session-owned SuperNeo buffers (`ensure_superneo_buffers`) avoid per-call allocation. Rust-side `SuperneoMatrixCache` / `SuperneoLinearForm` / `SuperneoZBlocks` cache transformed blocks for repeated evaluations. |
| Note-spend e2e GPU test missing | P0 | `test_rv64_note_from_elf.rs` has: strict-Mojo prove + verify, byte-exact CPU-vs-Mojo proof parity, multi-iteration median benchmarks, and `accelerator_calls > 0` assertions. `split_nc_gpu_parity.rs` adds 211 lines of new FE/NC/SuperNeo parity tests. All `#[ignore]` (slow perf repros). |
| Ring host-reduce inefficiency | P2 | Stage-8/commit-side Rust routing now prefers fused `rq_accumulate` for accelerator sessions, and `RQ_ACCUMULATE_GPU_MIN_SLOTS = 1` keeps the dedicated accumulate kernel on the fast path. Host-reduce fallback only used when `slot_count < 1` (effectively never). |
| Stage-8 `prove_rlc_dec_lane` was CPU-only | P1 | `prove_rlc_dec_lane` now accepts `force_backend_commit_accel` and routes `mix_rhos_commits` / `combine_b_pows` through the Mojo `rq_accumulate` path. `mojo_commit_mix.rs` expanded with batched multi-group ring mix (`mix_many_rhos_commits_with_mojo`) and `combine_b_pows_with_mojo`. FE oracle's Ajtai-phase evals now thread through `evals_at_with_backend` for backend-aware SuperNeo evaluation. |
| HIP was half-exposed in Rust config | P3 | `DeviceApi::Hip` variant fully removed from the Rust enum. `candidate_order` is `[Metal, Cpu]` on macOS, `[Cuda, Cpu]` on Linux. Mojo-side `accelerator_ready_for_api` returns `False` for the HIP constant. |

### Mitigated (acceptable but not fully closed)

| Issue | Original Severity | Current State | Remaining Gap |
|-------|-------------------|---------------|---------------|
| GPU fold failure causes state misalignment | P0 HIGH | FE/NC fold is now atomic at the wrapper level: a fresh shadow evaluator folds first, the live GPU evaluator is only swapped in on success, and failures fall back to the canonical CPU snapshot. No divergent GPU state is kept after an error, and later rounds may recreate the evaluator from CPU state. Poseidon2 digest failures now route through `record_poseidon_backend_failure` for consistent breaker integration. | There is still no proof-level retry/abort transaction. A failed accelerator fold wastes that attempt's GPU work and the proof continues from CPU-owned state. |
| Inconsistent error handling | P1 HIGH | Split-NC oracle wrappers capture strict-mode FE/NC create/eval/fold failures as deferred `PiCcsError`s via `pending_error: Option<PiCcsError>` and surface them through `RoundOracle::take_error()`. The sumcheck prover checks `take_error()` after every `evals_at` and `fold`. `SumcheckError::Runtime(String)` variant added for deferred-error propagation. Stage-8 batched fallback commitment mixing now runs through a `Result`-returning helper instead of `expect()`-based fallback closures. Optional paths still downgrade to CPU fallback through the backend breaker. | Some ring-mix call surfaces are still `Cmt`-returning rather than `Result`-returning, so strict no-fallback behavior is not fully normalized across every helper yet. |
| Circuit breaker for GPU failures | P2 | Two-level breaker: per-oracle (`SPLIT_NC_MAX_FAILURES_PER_ORACLE = 1`) and per-session (`BACKEND_MAX_FAILURES_PER_SESSION = 1`) via `BackendFailureState` struct tracking poseidon/split_nc/aux failures independently behind `Mutex`. `BackendOperation` enum routes `ensure_backend_enabled()` / `record_backend_failure()` per operation type. Atomic fold failures drop only the evaluator and retry from CPU snapshot on the next round. `split_nc_gpu_parity.rs` has fault-injection tests: `split_nc_fe_row_recovers_gpu_after_atomic_fold_failure` and `split_nc_session_breaker_disables_gpu_across_oracles_after_fe_failure`. | No exponential backoff, no cooldown period, and breaker logging is visible but still ad hoc rather than a structured telemetry stream. |

### Open (requires further work)

| Priority | Issue | Location | Detail |
|----------|-------|----------|--------|
| **P1** | Stage-8 `prove_rlc_dec_lane` is still the dominant bottleneck | `crates/neo-fold` | Stage-8 now uses the backend-aware commit path and clusters heterogeneous groups by a digest of the real per-group `eta`/`rho` update schedule, but the work is still only clustered within Stage-8 itself and note-spend end-to-end wins remain modest on CUDA and negative on Metal. |
| **P2** | Metal `Rq` batch slower than CPU | `ring.mojo` | Parity-correct but too slow for hot lanes. Stage-8 joint-opening and `RlcLane::Val` acceleration are gated off on Metal. |
| **P2** | Note-spend lane batching incomplete | `crates/neo-fold` | `Val`, WB, and WP now share parent-mix and materialized-child commit batches, but Stage-8 is still outside that combined batch and the proof step still does not collapse into a few large resident GPU jobs. |
| **P2** | Ajtai kernels still need deeper bit-width specialization | `ring.mojo` / `mojo_commit_many.rs` | `Rq` multiply now skips zero coefficients, iterates with the sparser operand outermost, and has a scalar-only fast path for constant factors. We still do not have digit-range-specialized kernels or a dedicated packed Ajtai descriptor format. |
| **P3** | No automated accelerator CI gate | CI | GitHub Actions now runs a real Mojo CPU parity lane and a manual self-hosted Metal/CUDA parity workflow, but accelerator coverage is still not a required merge gate. GPU-breaking changes can still merge unless someone runs the manual GPU workflow. |

## SuperNeo Paper Cross-Reference

Mapping between the SuperNeo paper's core operations and the current GPU branch implementation.

### Paper Operation → Code Mapping

| Paper Concept | Paper Reference | Code Location | GPU Status |
|---------------|-----------------|---------------|------------|
| Goldilocks field F (q = 2^64 - 2^32 + 1) | §2 | `field.mojo`: `fq_add`, `fq_sub`, `fq_mul`, `fq_canonicalize` | GPU kernels use these directly. |
| Extension field K = F_{q^2} | §2 | `field.mojo` / `sumcheck.mojo`: `k_add`, `k_sub`, `k_mul` with δ=7 | Used in FE/NC evaluator kernels. |
| Cyclotomic ring R_F = F[X]/(X^54 + X^27 + 1) | §2, Def 1 | `ring.mojo`: `rq_mul_batch_words`, `rq_accumulate_batch_words` | GPU ring multiply and accumulate kernels exist. D_WIDTH=54 matches paper's d=54. |
| SuperNeo embedding (z ∈ F^{d·n} → z ∈ R_F^n) | §4, Def 8 | `superneo_eval.rs`: `SuperneoZBlocks::from_z` packs d-element chunks as ring coefficients | Host-side; feeds GPU ring kernels. |
| Bar transform (σ̄: F^d → F^d) | §3, Thm 3 | `superneo.mojo`: `superneo_bar_block_gpu_kernel` — per-thread row parallelism over D_WIDTH=54 | Real GPU kernel with session-owned buffers. |
| Constant-term extraction ct(M̄z(r)) = Mz(r) | §4, Thm 4 | `superneo.mojo`: `rq_mul_ct_z_channel_words` fuses ring multiply + ct extraction | Fused into `superneo_row_dot_blocks_gpu_kernel`. |
| Weighted ring linear combination (Σ χ_r · M̄_i) | §4, Def 9 | `superneo_eval.rs`: `WeightedSuperneoBlocks` / `build_weighted_blocks` — sparse accumulation by chi_r | Host-side sparse accumulation; GPU `rq_accumulate_batch_u64x54` for dense phase. |
| Π_CCS sumcheck reduction | §5.1 | `sumcheck.rs`: `run_sumcheck_prover` / `run_batched_sumcheck_prover` with Split-NC oracle | FE/NC evaluator kernels on GPU via `fe_partial_group_gpu_kernel` / `nc_partial_group_gpu_kernel`. |
| Π_RLC random linear combination | §5.2 | `rlc_dec.rs`: `prove_rlc_dec_lane` with ring scalar mixing from sampling set C | Ring mix routed through `mix_rhos_commits_with_backend` / `rq_accumulate`. |
| Π_DEC b-ary decomposition | §5.3 | `rlc_dec.rs`: `split_b_matrix_k` decomposes witness; `commit_dec_wits_batched` for batch commit | Commitment batched across lanes; b=2 matches paper's binary decomposition. |
| Ajtai commitment Az | §2, §6 | `mojo_commit_many.rs`: `commit_many_with_backend` / `mix_many_rhos_commits_with_mojo` | GPU `rq_accumulate` for ring matrix-vector products. |
| Pay-per-bit commitment cost | §4.2 | `superneo_eval.rs`: ring path uses 2 or 4 `accumulate_weighted_blocks` calls depending on `z.imag_all_zero` | Optimization: skips imaginary channel when all-zero, halving ring work. |
| Strong sampling set C (coeffs in [-2,-1,0,1,2]) | §2, Def 3 | Rust-side challenge generation; not GPU-specific | N/A — challenge sampling stays on host. |

### Paper-Informed GPU Optimization Opportunities

The paper identifies the dominant prover costs (§6, Table 2) as:

1. **Ajtai commitment Az** — ring matrix-vector product, cost scales with witness bit-width
2. **Sumcheck polynomial evaluation** — d evaluations per round per constraint
3. **Π_DEC decomposition** — b-ary split and re-commitment of decomposed witnesses

Current GPU coverage vs paper-predicted bottlenecks:

| Paper Bottleneck | Current GPU Coverage | Optimization Opportunity |
|------------------|---------------------|--------------------------|
| Ajtai commitment Az | `rq_accumulate_batch` routes through GPU; session buffers exist. `Rq` multiply now skips zero coefficients, chooses the sparser operand as the outer loop, and fast-paths scalar-only factors. | Remaining work is digit-range-aware specialization and step-resident Ajtai descriptors so decomposed witnesses avoid repeated repacking. |
| Sumcheck evaluation | FE/NC evaluators on GPU with grouped partials (`SUMCHECK_PAIR_GROUP = 128`) | Grouped partials now reduce on device; remaining work is keeping snapshot creation/folding resident instead of CPU-owned. |
| Π_DEC re-commitment | `commit_dec_wits_batched` across lanes | **Step-global DEC batching**: currently lanes batch independently within Val/WB/WP groups. Paper shows DEC dominates for deep folding (k=14 digits × many lanes). One step-global DEC commit pass would amortize launch overhead. |
| SuperNeo ring-dot evaluation | `superneo_row_dot_blocks_gpu_kernel` now parallelizes across blocks and reduces on device | Remaining work is throughput tuning and pushing more of Stage-8/sibling-lane traffic through this path. |
| Weighted block accumulation | `build_weighted_blocks` on host, dual-channel SuperNeo row-dot on GPU | Real/imaginary scalar accumulation is now fused in one GPU call; ring-valued accumulation still uses separate weighted `rq_accumulate_batch` passes. |

### What the Paper Suggests We Should NOT GPU-Accelerate

- **Challenge sampling** (random oracle / Fiat-Shamir): sequential, transcript-dependent, tiny cost.
- **Sparse weighted block construction** (`build_weighted_blocks`): paper's CCS structure makes this sparse — host-side accumulation by non-zero chi_r entries is correct.
- **Proof serialization / verification**: verifier cost is sublinear and not a prover bottleneck.

## Current Optimization Priorities

1. **Extend step-global batching beyond the shared parent ring-mix**: Stage-8 still needs to join a unified downstream DEC/commit path with the other lanes.
2. **Deepen the new sparse-aware Ajtai kernels**: add digit-range-aware specialization and step-resident Ajtai descriptors on top of the zero-skipping / scalar-fast-path `Rq` kernels.
3. **Improve the Metal `Rq` batch kernel enough to remove current hot-lane gates**.
4. **Keep more Split-NC state resident**: snapshot creation/folding still begins from CPU-owned layouts.
5. **Push more Stage-8 / sibling-lane traffic through the tuned SuperNeo path**.
6. Keep CUDA promoted where it beats CPU, and keep Metal conservative until it does.

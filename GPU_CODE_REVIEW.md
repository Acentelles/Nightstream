# Code Review: `feature/gpu-acceleration` Branch

**Reviewer:** Claude | **Date:** 2026-03-13 | **Base:** `main` | **Commits:** 16

---

## Executive Summary

This branch introduces Mojo-based GPU acceleration for ZK proving primitives (Poseidon2, sumcheck, ring multiplication) targeting CUDA and Metal backends. The architecture is sound — Mojo kernels are compiled to a shared library, loaded at runtime via FFI from Rust, with threshold-driven backend selection and CPU fallback.

**Milestones 1–8 are marked complete**, with real CUDA parity verified on T4 GPUs and Metal correctness established on Apple Silicon. However, the branch has several critical gaps before it's production-ready, particularly around the note-spend circuit e2e path, snapshot bounds validation, and error handling robustness.

| Dimension | Rating | Summary |
|-----------|--------|---------|
| **Security** | ⚠️ Medium | Non-constant-time field ops; missing snapshot bounds checks |
| **Performance** | ⚠️ Medium | CUDA slightly faster than CPU; Metal still gated; note-spend not benchmarked through GPU |
| **Correctness** | ✅ Good | Strong parity tests for oracle evaluation; Poseidon2 byte-exact match |
| **Maintainability** | ⚠️ Medium | Silent fallbacks, inconsistent error patterns, no circuit breaker |

---

## 1. Security

### 1.1 Snapshot Bounds Validation — HIGH

**File:** `gpu/mojo/src/nightstream_gpu/sumcheck.mojo`

Snapshot data constructed by Rust is trusted completely on the Mojo side. The code checks magic number and version but **does not validate that extracted array lengths stay within `snapshot_word_count`**. Fields like `cur_len`, `eq_beta_len`, and table offsets (`fe_tables_offset`) are read from the snapshot header and used to index into the snapshot buffer without range checks.

**Risk:** A malformed snapshot (from a Rust bug or memory corruption) could cause out-of-bounds GPU memory reads, leading to incorrect proofs or crashes.

**Recommendation:** Add bounds validation after reading each length field:
```
if fe_tables_offset + table_size > snapshot_word_count:
    return error("snapshot overflow")
```

### 1.2 Non-Constant-Time Field Arithmetic — MEDIUM

**File:** `gpu/mojo/src/nightstream_gpu/field.mojo`

`fq_mul` and `fq_canonicalize` use conditional branches for modular reduction. While acceptable for Poseidon2 (commitment hash, public data), this is a concern if these field ops are ever used for secret-dependent computation.

**Recommendation:** Document the constant-time assumption clearly. If field ops touch secret witnesses in future, implement branchless reduction.

### 1.3 Extension Field Arithmetic Missing Canonicalization — LOW

**File:** `gpu/mojo/src/nightstream_gpu/sumcheck.mojo` (lines 58–72)

`k_mul` implements extension field multiplication with delta=7 but doesn't canonicalize results. `k_add` similarly doesn't verify results fit in field size. Intermediate values could exceed field bounds temporarily.

---

## 2. Performance

### 2.1 Current Measured Results

| Backend | Status | Note-Spend Speedup |
|---------|--------|--------------------|
| **CUDA (T4)** | Promoted for Poseidon2, FE/NC, `optimized_prove` | "Slightly faster than CPU" |
| **Metal (Apple Silicon)** | Correct but slower; hot lanes gated | Not yet faster |

The projected speedups from `GPU_ACCELERATION_PLAN.md` (20–40x on full shard proof) have **not materialized yet**. The current wins are modest because:

1. **Stage-8 `prove_rlc_dec_lane`** remains a CPU bottleneck — this is the dominant hot path
2. **Metal Rq batch multiply** is still slower than CPU, gating commit-side acceleration
3. **Sibling lane batching** for note-spend is incomplete — lanes aren't collapsed into resident GPU jobs

### 2.2 SuperNeo is CPU-Only — GAP

**File:** `gpu/mojo/src/nightstream_gpu/superneo.mojo`

All SuperNeo operations (dot products, row operations) are pure CPU with sequential iteration and per-call array allocation. No GPU kernels exist despite this being on the performance-critical path. The 54×54 mat-vec operations are a natural fit for GPU parallelism.

### 2.3 Ring Accumulation Inefficiency

**File:** `gpu/mojo/src/nightstream_gpu/ring.mojo` (lines 436–484)

The host-reduce fallback path recomputes all multiplications on GPU, then re-reduces on CPU. For small slot counts this is wasteful — should either do full GPU reduction or skip GPU entirely.

### 2.4 Sumcheck Snapshot Memory Access Pattern

**File:** `gpu/mojo/src/nightstream_gpu/sumcheck.mojo`

Kernels read snapshot header data repeatedly without shared memory caching. This generates many small pointer dereferences that can cause memory stalls on GPUs.

### 2.5 Missing Benchmarks

- **No note-spend circuit GPU benchmark** — the critical e2e path is not measured
- **No batch size scalability study** beyond 2048 Poseidon states
- **No GPU memory bandwidth/utilization metrics**
- **No per-stage GPU profiling** to identify where time is actually spent

---

## 3. Correctness

### 3.1 Positive Observations

The parity testing is thorough at the primitive level:

- **Poseidon2:** Byte-exact CPU/GPU match across batch sizes, both CUDA and Metal
- **Split-NC oracles:** FE row-phase and NC column-phase `evals_at()` match CPU reference across all folding rounds
- **Full prove/verify:** Synthetic CCS workloads produce identical proofs on CPU and GPU
- **Mock backend:** Enables CI testing without GPU hardware

### 3.2 GPU Fold Failure Causes State Misalignment — HIGH

**File:** `crates/neo-reductions/src/accelerator.rs` (lines 502–517)

If `gpu_result` errors during `fold()`:
1. The GPU evaluator is dropped (line 510)
2. The Rust CPU oracle is still folded (line 513)
3. Subsequent rounds use misaligned GPU/CPU state

**Risk:** Silent proof corruption — the GPU and CPU oracles diverge but the system continues proving.

**Recommendation:** Make fold atomic: if GPU fails, either retry or abort the entire proof rather than continuing with inconsistent state.

### 3.3 Poseidon2 Batch Race Condition — MEDIUM

**File:** `crates/neo-reductions/src/accelerator.rs` (lines 290–321)

If GPU permutation fails mid-batch, the states array may contain partially-updated data that gets written back. The error path catches this eventually but the `states` array may have been corrupted.

### 3.4 Note-Spend E2E Path NOT Tested — HIGH (GAP)

**Existing note-spend tests:** `neo-fold/riscv-tests/test_rv64_note_from_elf.rs` — all CPU-only, marked `#[ignore]`.

**Missing:** No test that:
- Generates a note-spend proof using GPU acceleration
- Verifies the GPU-generated proof is correct
- Compares GPU vs CPU note-spend outputs for parity

This is the stated goal of the branch but has no test coverage.

---

## 4. Maintainability

### 4.1 Inconsistent Error Handling — HIGH

Three different error patterns coexist:

| Pattern | Location | Behavior |
|---------|----------|----------|
| `panic!()` | accelerator.rs:453, 594 | Process termination when `split_nc_required=true` |
| `.expect()` | accelerator.rs:483, 506, 624, 647 | Panic on "impossible" states |
| Silent fallback | accelerator.rs:93, 160, 177 | `Ok(None)` or `RustCpu` without logging |

**Recommendation:** Standardize on `Result` propagation throughout. Replace panics with proper error returns. Add structured logging for all fallback decisions.

### 4.2 No Circuit Breaker for GPU Failures

If the GPU fails repeatedly (e.g., out of memory), the system will thrash between attempting GPU execution and falling back to CPU on every operation. There's no `max_retries`, exponential backoff, or session-level disable-after-N-failures.

### 4.3 No Snapshot Schema Versioning

`fe_row_snapshot_bytes()` and `nc_col_snapshot_bytes()` serialize oracle state for GPU consumption but include no version tag or schema hash. If the Mojo FFI changes struct layout, silent data corruption occurs.

### 4.4 `enqueue_function` Deprecation

**File:** `gpu/mojo/src/nightstream_gpu/poseidon.mojo` (line 158)

Using `enqueue_function` instead of `enqueue_function_checked`. The README explicitly calls this out as a TODO. Unchecked kernel enqueue means GPU errors may go undetected.

### 4.5 HIP Support is Incomplete

ABI constant defined (`DEVICE_API_HIP = 3`) and thresholds default to CUDA values, but there are no HIP-specific tests, threshold tuning, or validation. Should either be properly supported or explicitly marked as unsupported.

---

## 5. CI/CD Integration

**Current state:** GitHub Actions CI runs mock-mode tests only. Real GPU parity verification happens on developer machines (Mac Metal, T4 CUDA). No automated GPU CI pipeline exists.

**Gap:** There's no gate preventing GPU-breaking changes from merging. A CI job with a GPU runner (even periodic/nightly) would catch regressions.

---

## 6. Gaps Summary — Prioritized

| Priority | Gap | Impact |
|----------|-----|--------|
| **P0** | Note-spend circuit has no GPU e2e test or benchmark | Cannot validate the branch's stated goal |
| **P0** | GPU fold failure causes state misalignment | Silent proof corruption possible |
| **P1** | Snapshot bounds validation missing in Mojo | OOB reads from malformed snapshots |
| **P1** | Stage-8 `prove_rlc_dec_lane` remains CPU bottleneck | Limits overall speedup |
| **P1** | Inconsistent error handling (panic vs silent fallback) | Unpredictable failure modes |
| **P2** | SuperNeo has no GPU acceleration | Missed parallelism opportunity |
| **P2** | Metal Rq still slower than CPU | Gating commit-side acceleration |
| **P2** | No circuit breaker for repeated GPU failures | GPU thrashing risk |
| **P2** | No snapshot schema versioning | Silent corruption on ABI change |
| **P3** | `enqueue_function` → `enqueue_function_checked` | Undetected GPU kernel errors |
| **P3** | HIP support incomplete | Misleading API surface |
| **P3** | No GPU CI pipeline | Regression risk |

---

## 7. What's Done Well

- **Architecture is clean:** Mojo for compute, Rust for orchestration, runtime-loaded shared library via FFI — this is the right separation
- **Parity testing at primitive level is excellent:** Byte-exact Poseidon2 matching, multi-round oracle fold parity, full prove/verify cycle comparison
- **Threshold-driven backend selection** is pragmatic — no GPU for small workloads, device-specific thresholds
- **Mock backend** enables CI testing without hardware, which is essential
- **Graceful degradation** philosophy (CPU fallback) is correct for production
- **Field arithmetic** in `field.mojo` uses proper Goldilocks decomposition — the math is sound
- **Comprehensive README** in `gpu/mojo/` documents status, gates, and known gaps transparently

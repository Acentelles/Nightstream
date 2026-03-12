# neo-fold Source Reorganization Plan

## Executive Summary

The `crates/neo-fold/src/` directory contains **72 Rust files totaling ~49,000 lines** across 10 directories. The structure has grown organically and several areas would benefit from reorganization:

1. **Root-level file sprawl**: 9 files at the root, mixing core types with trace frontends
2. **memory_sidecar/memory/**: A flat dump of 17+ files with no grouping — 8 of them share the `route_a_` prefix
3. **Shard prover internals scattered**: Prover-only files mixed with API and utility modules at the same level
4. **Multiple 2,000+ line files** that could benefit from splitting
5. **Tiny files** that add module overhead without meaningful separation

This plan proposes **conservative structural changes in two phases**:

1. **Phase 1**: group obvious subsystems (`frontends/`, `shard/prover/`, `shard/verifier/`, `memory_sidecar/route_a/`) and flatten accidental indirection.
2. **Phase 2**: extract the clearly RISC-V-specific residual/oracle/opening-carrier code into a shallow sibling `memory_sidecar/riscv/` namespace.

The key refinement from the initial draft is that **multi-VM support is a real requirement**, but we still should **not** introduce a `RouteAAdapter` trait or generic untyped claim bags yet. The right intermediate shape is a file/module boundary, not an abstraction boundary guessed from one implementation.

## Implementation Status (March 11, 2026)

The structural reorganization is now mostly implemented:

- `frontends/`, `session/mod.rs`, `shard/prover/`, `shard/verifier/`, `memory_sidecar/route_a/`, `memory_sidecar/riscv/`, and `memory_sidecar/precompiles/` exist in the tree.
- `transcript_and_common.rs` has been deleted.
- Packed-op ownership moved into `memory_sidecar/riscv/packed_ops.rs`.
- The first function-level RISC-V extractions have landed:
  - `memory_sidecar/riscv/trace_openings.rs`
  - `memory_sidecar/riscv/width_residuals.rs`
  - `memory_sidecar/riscv/control_residuals.rs`
- `memory_sidecar/route_a/claim_builders.rs` has been fully dissolved; its RISC-V-specific contents now live under `memory_sidecar/riscv/`.

The remaining follow-up work is cleanup rather than directory surgery:

- finish shrinking `route_a/claims.rs`, which still carries the decode time-claim builder and remains oversized
- split `memory/sparse_oracles_and_twist_pre.rs`, which still mixes generic sparse helpers with RISC-V lookup-slot logic
- remove the temporary broad re-export/import-facade behavior after the moved modules stabilize

### Comparison with Jolt's Organization

For reference, Jolt (`external/jolt/jolt-core/src/zkvm/`) organizes by **protocol component** — each directory names what it checks:

| Jolt module | What it does | neo-fold equivalent |
|---|---|---|
| `ram/` | RAM read/write checking | `memory_sidecar/route_a_*` (Twist part) |
| `registers/` | Register read/write checking | `memory_sidecar/route_a_*` (Twist part) |
| `instruction_lookups/` | Lookup argument sumcheck | `memory_sidecar/route_a_*` (Shout part) |
| `bytecode/` | Bytecode fetch checking | (embedded in trace frontends) |
| `claim_reductions/` | Reduce claims to committed polys | (embedded in `shard/rlc_dec.rs`) |
| `spartan/` | Outer Spartan sumcheck | (lives in `neo-reductions`) |
| `r1cs/` | R1CS constraints | (lives in `neo-ccs`) |

Key difference: Jolt can separate RAM and lookups into sibling modules because they're independent sumchecks. neo-fold **cannot** — Twist and Shout share a batched time domain (`r_time`), so the Route-A code is naturally interleaved and belongs in one directory.

The naming style Jolt uses (descriptive of what-it-checks) is something to aspire to. The `route_a` name is an internal convention that doesn't describe what the subsystem does. A future rename (e.g., `twist_shout`, `mem_checking`) would align with Jolt's philosophy, but we defer that to avoid blocking the structural reorganization on a naming decision.

## Design Constraints for This Plan

These constraints come from the current code and from the explicit requirement to support additional VMs alongside RV64:

1. **Do not design traits for one implementation.**
   `RouteAAdapter`-style abstraction is deferred until a second VM has real code. The first extraction should be module-level only.

2. **Keep maximum nesting depth shallow.**
   The deepest new path should be `memory_sidecar/riscv/<file>.rs` or `memory_sidecar/precompiles/poseidon2/<file>.rs`, not `memory_sidecar/core/adapters/riscv/...`.

3. **Preserve typed proof objects.**
   Do not replace named fields or stage-grouped structs with a generic `Vec` of claims/openings in this round.

4. **Separate proof plumbing from VM semantics.**
   Generic Route-A batched-sumcheck plumbing belongs in `memory_sidecar/route_a/`. RISC-V trace semantics, residuals, and opening carriers belong in `memory_sidecar/riscv/`.

5. **Defer cross-cutting renames until after the file moves.**
   Names like `WB`, `WP`, `W2`, and `W3` should eventually be replaced by semantic names, but not in the same round as the structural reorganization.

---

## Current Structure (Annotated)

```
src/
├── lib.rs                          (39 lines)   crate root
├── finalize.rs                     (17 lines)   tiny standalone module
├── output_binding.rs               (170 lines)  standalone strengthening layer
├── shard_proof_types.rs            (511 lines)  proof data types — consumed everywhere
├── test_export.rs                  (862 lines)  ⚠ JSON test runner, NOT a core module
├── riscv_trace_shard.rs            (1,814 lines)⚠ legacy RV32 frontend at root
├── rv64_ram_bridge.rs              (153 lines)  ⚠ RV64 support at root, only used by rv64_trace_shard
├── rv64_trace_shard.rs             (1,018 lines)⚠ maintained RV64 frontend at root
│   └── helpers.rs                  (973 lines)  ⚠ RV64 helpers as pseudo-submodule
├── session/                                      ✅ well-organized
│   ├── session.rs                  (1,097 lines)
│   ├── ccs_builder.rs             (165 lines)
│   ├── circuit.rs                 (441 lines)
│   ├── driver.rs                  (946 lines)
│   ├── layout.rs                  (953 lines)
│   └── resources.rs               (190 lines)
├── shard/                                        ⚠ flat mix of API, prover, verifier, utils
│   ├── shard.rs                   (120 lines)
│   ├── audit_types.rs             (48 lines)
│   ├── ccs_only_batched.rs        (558 lines)   prover-side
│   ├── mixed_batched.rs           (578 lines)   prover-side
│   ├── poseidon_lane_helpers.rs   (1,574 lines) prover-side
│   ├── prove_api.rs               (237 lines)   public API
│   ├── prover.rs                  (1,828 lines) prover orchestration
│   │   ├── context.rs             (198 lines)
│   │   ├── lanes.rs               (241 lines)
│   │   └── route_a.rs             (526 lines)
│   ├── rlc_dec.rs                 (1,108 lines) prover-side
│   ├── route_a_segment.rs         (442 lines)   prover-side
│   ├── verifier.rs                (1,208 lines) verification core
│   ├── verify_api.rs              (187 lines)   public API
│   ├── verify_consistency.rs      (477 lines)   verification support
│   └── core_utils/                              ✅ well-organized internally
│       ├── core_utils.rs          (44 lines)
│       ├── commit_mixers.rs       (14 lines)
│       ├── dec_stream.rs          (933 lines)
│       ├── me_claims.rs           (137 lines)
│       ├── oracle_dispatch.rs     (41 lines)
│       ├── rlc_math.rs            (146 lines)
│       ├── step_linking.rs        (39 lines)
│       ├── time_columns.rs        (497 lines)
│       └── transcript_binding.rs  (166 lines)
├── time_opening/                                 ✅ well-organized
│   ├── mod.rs                     (10 lines)
│   ├── joint_lane.rs              (1,015 lines)
│   ├── manifest.rs                (210 lines)
│   ├── me_adapter.rs              (598 lines)
│   └── reduction.rs               (421 lines)
└── memory_sidecar/                               ⚠ biggest problem area
    ├── mod.rs                     (11 lines)
    ├── claim_plan.rs              (1,037 lines)
    ├── cpu_bus.rs                  (2,574 lines) ⚠ largest file in crate
    ├── cpu_bus_tests.rs           (407 lines)
    ├── route_a_compiler.rs        (515 lines)
    ├── route_a_time.rs            (953 lines)
    ├── sumcheck_ds.rs             (77 lines)
    ├── transcript.rs              (59 lines)
    ├── utils.rs                   (72 lines)
    └── memory/                                   ⚠ 17 files, no grouping
        ├── memory.rs              (109 lines)
        ├── transcript_and_common.rs(176 lines)
        │   ├── opening_lookup.rs  (294 lines)
        │   ├── sparse_time_oracles.rs(434 lines)
        │   ├── step_memory_binding.rs(171 lines)
        │   └── trace_semantics.rs (671 lines)
        ├── addr_pre_proofs.rs     (711 lines)
        ├── event_table_context.rs (126 lines)
        ├── route_a_claim_builders.rs(1,602 lines)⚠ all route_a_*
        ├── route_a_claims.rs      (2,036 lines) ⚠ 2nd largest
        ├── route_a_finalize.rs    (517 lines)
        ├── route_a_oracles.rs     (1,874 lines) ⚠ 4th largest
        ├── route_a_rv64_fullword.rs(1,382 lines)
        ├── route_a_rv64_reg_output.rs(358 lines)
        ├── route_a_terminal_checks.rs(930 lines)
        ├── route_a_verify.rs      (1,397 lines)
        ├── sparse_oracles_and_twist_pre.rs(1,599 lines)
        ├── w2_virtual_constraints.rs(2,241 lines)⚠ 2nd largest
        └── precompiles/poseidon2/ (4 files, 3,988 lines total)
```

---

## Proposed Structure

```
src/
├── lib.rs                          ← updated mod declarations
├── shard_proof_types.rs            ← stays (consumed everywhere; renaming has high churn cost)
├── finalize.rs                     ← stays (tiny, clear contract)
├── output_binding.rs               ← stays (small, clear layer)
│
├── frontends/                      ← NEW: group all trace frontends
│   ├── mod.rs
│   ├── test_export.rs              ← moved from root
│   ├── rv64_trace_shard.rs         ← moved from root
│   ├── rv64_helpers.rs             ← moved from rv64_trace_shard/helpers.rs
│   ├── rv64_ram_bridge.rs          ← moved from root
│   └── riscv_trace_shard.rs        ← moved from root
│
├── session/                        ← no changes (already well-organized)
│   ├── mod.rs                      (was session.rs)
│   ├── ccs_builder.rs
│   ├── circuit.rs
│   ├── driver.rs
│   ├── layout.rs
│   └── resources.rs
│
├── shard/                          ← reorganize: split prover/verifier into subdirs
│   ├── mod.rs                      (was shard.rs — update mod declarations)
│   ├── prove_api.rs                ← stays (public API surface)
│   ├── verify_api.rs               ← stays (public API surface)
│   ├── audit_types.rs              ← stays
│   ├── prover/                     ← absorb loose prover files
│   │   ├── mod.rs                  (was prover.rs)
│   │   ├── context.rs
│   │   ├── lanes.rs
│   │   ├── route_a.rs
│   │   ├── ccs_only_batched.rs     ← moved from shard/
│   │   ├── mixed_batched.rs        ← moved from shard/
│   │   ├── rlc_dec.rs              ← moved from shard/
│   │   ├── route_a_segment.rs      ← moved from shard/
│   │   └── poseidon_lane_helpers.rs← moved from shard/
│   ├── verifier/                   ← NEW: group verification code
│   │   ├── mod.rs                  (was verifier.rs)
│   │   └── consistency.rs          (was verify_consistency.rs)
│   └── core_utils/                 ← no changes (already well-organized)
│       ├── mod.rs
│       ├── commit_mixers.rs
│       ├── dec_stream.rs
│       ├── me_claims.rs
│       ├── oracle_dispatch.rs
│       ├── rlc_math.rs
│       ├── step_linking.rs
│       ├── time_columns.rs
│       └── transcript_binding.rs
│
├── time_opening/                   ← no changes (already well-organized)
│   ├── mod.rs
│   ├── joint_lane.rs
│   ├── manifest.rs
│   ├── me_adapter.rs
│   └── reduction.rs
│
└── memory_sidecar/                 ← major reorganization
    ├── mod.rs                      ← updated mod declarations
    ├── claim_plan.rs               ← stays (core planning module)
    ├── cpu_bus.rs                   ← stays for now (see "Files to Consider Splitting")
    ├── cpu_bus_tests.rs            ← stays
    ├── sumcheck_ds.rs              ← stays
    ├── transcript.rs               ← stays
    ├── utils.rs                    ← stays
    ├── route_a/                    ← NEW: group generic Route-A proof plumbing
    │   ├── mod.rs
    │   ├── compiler.rs             ← was route_a_compiler.rs
    │   ├── time.rs                 ← was route_a_time.rs
    │   ├── claims.rs               ← was memory/route_a_claims.rs
    │   ├── finalize.rs             ← was memory/route_a_finalize.rs
    │   ├── verify.rs               ← was memory/route_a_verify.rs
    │   └── terminal_checks.rs      ← was memory/route_a_terminal_checks.rs
    ├── memory/                     ← slimmed down to non-Route-A memory logic
    │   ├── mod.rs                  ← updated (was memory.rs + transcript_and_common.rs)
    │   ├── addr_pre_proofs.rs      ← stays
    │   ├── event_table_context.rs  ← stays for now (small event-table helper; revisit after Phase 2 lands)
    │   ├── opening_lookup.rs       ← promoted from transcript_and_common/ sub-module
    │   ├── sparse_time_oracles.rs  ← promoted from transcript_and_common/ sub-module
    │   ├── step_memory_binding.rs  ← promoted from transcript_and_common/ sub-module
    │   ├── sparse_oracles_and_twist_pre.rs ← stays
    ├── riscv/                      ← NEW: shallow VM-specific refinement layer
    │   ├── mod.rs
    │   ├── oracles.rs              ← was memory/route_a_oracles.rs
    │   ├── trace_openings.rs       ← WB/WP opening-carrier builders and lane wiring extracted from claim_builders/step
    │   ├── trace_semantics.rs      ← was transcript_and_common/trace_semantics.rs
    │   ├── packed_ops.rs           ← packed-op enums and packed Route-A binding helpers extracted from transcript_and_common.rs
    │   ├── decode_residuals.rs     ← was memory/w2_virtual_constraints.rs
    │   ├── width_residuals.rs      ← width-stage residual helpers extracted from mixed Route-A files
    │   ├── control_residuals.rs    ← control-stage residual helpers extracted from mixed Route-A files
    │   ├── rv64_width_residuals.rs ← was memory/route_a_rv64_fullword.rs
    │   └── rv64_reg_output.rs      ← was memory/route_a_rv64_reg_output.rs
    └── precompiles/                ← promoted one level up from memory/precompiles/
        └── poseidon2/
            ├── mod.rs
            ├── claim_builders.rs
            ├── link_claim_builders.rs
            ├── local_commit.rs
            └── terminal_checks.rs
```

---

## Change-by-Change Rationale

### Change 1: Create `frontends/` directory

**Move**: `test_export.rs`, `rv64_trace_shard.rs`, `rv64_trace_shard/helpers.rs`, `rv64_ram_bridge.rs`, `riscv_trace_shard.rs` → `frontends/`

**Why this is a no-brainer**:
- These 4 files (5 counting helpers.rs) are all trace-level frontend adapters. They sit at the crate root alongside core modules like `shard_proof_types.rs` and `output_binding.rs`, making it look like they're at the same architectural layer — they're not.
- The specs already identify these as "frontend" layer modules (Architecture.spec.md layer stack). The folder name matches the spec terminology.
- `rv64_ram_bridge.rs` is only imported by `rv64_trace_shard.rs`, so it clearly belongs with it.
- `test_export.rs` is a JSON test runner for cross-language testing — it's not part of the core protocol.

**What changes in calling code**:
- `lib.rs`: Change `pub mod riscv_trace_shard;` → `pub mod frontends;` (with re-exports for backward compatibility)
- `lib.rs`: Remove `mod rv64_ram_bridge;`, `pub mod rv64_trace_shard;`, `pub mod test_export;`
- External consumers (`neo-spartan-bridge`, `neo-fold-ffi`, `neo-midnight-bridge`) currently import `neo_fold::test_export`, `neo_fold::rv64_trace_shard`, `neo_fold::riscv_trace_shard` — we must add re-exports in `lib.rs` to avoid breaking them:
  ```rust
  pub mod frontends;
  // backward-compatible re-exports
  pub use frontends::test_export;
  pub use frontends::rv64_trace_shard;
  pub use frontends::riscv_trace_shard;
  ```
- Internal imports within `rv64_trace_shard.rs` that reference `crate::rv64_ram_bridge` → change to `super::rv64_ram_bridge` or update path

**Risk**: Low. The re-exports ensure no external breakage. Internal changes are path-only.

---

### Change 2: Group generic Route-A files into `memory_sidecar/route_a/`

**Move**: the generic Route-A orchestration/proof-plumbing files into `memory_sidecar/route_a/`

| From | To |
|------|-----|
| `memory_sidecar/route_a_compiler.rs` | `memory_sidecar/route_a/compiler.rs` |
| `memory_sidecar/route_a_time.rs` | `memory_sidecar/route_a/time.rs` |
| `memory/route_a_claims.rs` | `memory_sidecar/route_a/claims.rs` |
| `memory/route_a_finalize.rs` | `memory_sidecar/route_a/finalize.rs` |
| `memory/route_a_terminal_checks.rs` | `memory_sidecar/route_a/terminal_checks.rs` |
| `memory/route_a_verify.rs` | `memory_sidecar/route_a/verify.rs` |

**Why this is a no-brainer**:
- The current code already has a real distinction between generic Route-A plumbing and RISC-V-specific residual/oracle logic; the problem is that the files are mixed together.
- Currently they're split across two directories (`memory_sidecar/` and `memory_sidecar/memory/`), making it hard to find all Route-A code.
- After this move, generic batched-time proving, verification orchestration, and claim assembly have one obvious home.
- The Route-A protocol (Twist/Shout sidecar integration) is a distinct subsystem with its own paper anchors (Twist/Shout paper §4-5). It deserves its own directory.

**What changes in calling code**:
- `memory_sidecar/mod.rs`: Add `pub(crate) mod route_a;`, remove `pub(crate) mod route_a_compiler;` and `pub(crate) mod route_a_time;`
- `memory_sidecar/memory.rs`: Remove the generic `route_a_*` `#[path]` declarations and re-export the new `route_a` module.
- `memory_sidecar/route_a/mod.rs`: New file that declares the generic Route-A submodules and re-exports their `pub(crate)` items.
- During **Change 2**, moved files retain their current non-`riscv/` imports. The import rewiring to `crate::memory_sidecar::riscv::*` happens in **Change 3** when that sibling module actually exists.
- To minimize churn from the current `use super::*` pattern, `route_a/mod.rs` may initially mirror the old `memory.rs` re-export surface for the files that move there.
- **Acceptance rule for Change 2**: if temporary mirroring is introduced, land an immediate follow-up cleanup commit that replaces `use super::*` in the moved `route_a/` files with explicit imports and deletes any now-unused mirrored re-exports. Do not leave the mirrored surface as open-ended debt.

**Risk**: Medium. Some files in this group still have RISC-V leaks. The goal of this move is to expose that boundary, not to solve it all at once.

---

### Change 3: Create a shallow `memory_sidecar/riscv/` sibling for VM-specific code

**Move/extract**: the clearly RISC-V-specific residuals, opening carriers, and opcode/oracle code into `memory_sidecar/riscv/`

This phase should land in three explicit substeps.

**Change 3A: whole-file moves**

| From | To |
|------|-----|
| `memory/route_a_oracles.rs` | `memory_sidecar/riscv/oracles.rs` |
| `memory/route_a_rv64_fullword.rs` | `memory_sidecar/riscv/rv64_width_residuals.rs` |
| `memory/route_a_rv64_reg_output.rs` | `memory_sidecar/riscv/rv64_reg_output.rs` |
| `memory/w2_virtual_constraints.rs` | `memory_sidecar/riscv/decode_residuals.rs` |

**Change 3B: targeted extractions from mixed files**

| From | To |
|------|-----|
| `memory/transcript_and_common.rs` packed-op enum and packed-route binding bits | `memory_sidecar/riscv/packed_ops.rs` |
| `memory/transcript_and_common.rs` / `memory/trace_semantics.rs` RISC-V trace linkage code | `memory_sidecar/riscv/trace_semantics.rs` |
| WB/WP stage gating, bus-layout helpers, time-claim builder, ME emission, and terminal verification extracted from mixed Route-A files | `memory_sidecar/riscv/trace_openings.rs` |
| width-stage time-claim builder and terminal verification extracted from mixed Route-A files | `memory_sidecar/riscv/width_residuals.rs` |
| control-stage time-claim builder and terminal verification extracted from mixed Route-A files | `memory_sidecar/riscv/control_residuals.rs` |

**Why this is the right second phase**:
- Supporting additional VMs is a real requirement, so the RISC-V boundary should be made explicit now.
- The current code already proves these pieces are VM-specific: decode/width/control stages are keyed off RISC-V lookup families and RV64-specific layouts, while generic Route-A plumbing only cares about ordered batched claims and shared `r_time`.
- A shallow sibling `riscv/` namespace keeps the depth acceptable and makes room for a future second VM without forcing a trait too early.

**Change 3C: function-level extraction from mixed `route_a/` files**

This pass is now partially implemented:

- `route_a/claim_builders.rs` is gone; its WB/WP, width, and control responsibilities now live under `riscv/`.
- `route_a/terminal_checks.rs` now keeps the decode terminal verifier and decode opening-map helpers, while width/control terminal verification moved under `riscv/`.
- `route_a/claims.rs` still contains the decode time-claim builder and remains the main oversized mixed file.

**Pattern**: each extraction follows the same shape:

```rust
// BEFORE:
fn build_route_a_width_time_claims(...) -> Result<...> {
    // Route-A file owns RISC-V width-stage decode/transport wiring inline
}

// AFTER:
pub(crate) fn build_route_a_width_time_claims(...) -> Result<...> {
    // moved into crates/neo-fold/src/memory_sidecar/riscv/width_residuals.rs
}
```

**Why this substep matters**:
- Without it, `route_a/` files still import `neo_memory::riscv::*` types and call RISC-V-specific helpers directly. The module boundary exists but the code inside doesn't respect it.
- When VM #2 arrives, you need to see exactly where `riscv::*` is called from generic code. After 3C, every call site is a single function call with an explicit `riscv::` path — making it obvious where a second VM would plug in.
- No traits are introduced. Each extracted function takes the data it needs as parameters and returns what it produces. The call sites are plain function calls, not trait dispatch.

**What this substep deliberately does not do**:
- It does **not** introduce a `RouteAAdapter` trait.
- It does **not** replace typed proof fields with generic `Vec` containers.
- It does **not** guarantee `route_a/` has zero RISC-V imports after completion — some conditional-enablement checks (e.g., `riscv_is_decode_lookup_table_id()`) may remain as thin dispatch predicates until VM #2 forces a generic table-family classifier.

**Import strategy for moved files**:
- `riscv/mod.rs` may initially mirror the subset of the old `memory.rs` surface needed by files that still use `use super::*`.
- **Acceptance rule for Change 3**: each substep is allowed to use temporary mirroring only long enough to keep the crate compiling. Follow it immediately with import cleanup for the files that moved or were extracted, replacing `use super::*` with explicit imports and deleting any now-unused mirrored re-exports.

**Risk**: Medium. The first extraction pass is done, but `route_a/claims.rs` still needs a second pass before the generic-vs-RISC-V split is complete.

---

### Change 4: Move prover-only files into `shard/prover/`

**Move**: 5 prover-side files from `shard/` → `shard/prover/`

| From | To |
|------|-----|
| `shard/ccs_only_batched.rs` | `shard/prover/ccs_only_batched.rs` |
| `shard/mixed_batched.rs` | `shard/prover/mixed_batched.rs` |
| `shard/rlc_dec.rs` | `shard/prover/rlc_dec.rs` |
| `shard/route_a_segment.rs` | `shard/prover/route_a_segment.rs` |
| `shard/poseidon_lane_helpers.rs` | `shard/prover/poseidon_lane_helpers.rs` |

**Why this is a no-brainer**:
- These 5 files are exclusively called from the prover path. They're never imported by the verifier, the API surface, or external consumers.
- `prover/` already exists as a subdirectory with 3 files (context.rs, lanes.rs, route_a.rs). These 5 files are conceptually identical — they're prover internals that got left one level too high.
- After this move, `shard/` at the top level contains only: the module root, two API files (prove_api.rs, verify_api.rs), audit_types.rs, and the three subdirectories (prover/, verifier/, core_utils/). That's a clean, scannable layout.

**What changes in calling code**:
- `shard.rs`: Remove the 5 `#[path]` declarations for these files. Update the `pub(crate) use` re-exports to pull from `prover::*` instead.
- `shard/prover.rs` (now `shard/prover/mod.rs`): Add `mod ccs_only_batched;`, etc. and `pub(crate) use` re-exports.
- Since `shard.rs` already does `pub(crate) use prover::*;`, and the prover module already re-exports its internals, crate-wide callers that use `crate::shard::fold_shard_prove_impl` etc. continue to work.

**Risk**: Low. All re-exports stay at the same level. The `pub(crate)` boundary doesn't change.

---

### Change 5: Create `shard/verifier/` directory

**Move**: 2 verifier files from `shard/` → `shard/verifier/`

| From | To |
|------|-----|
| `shard/verifier.rs` | `shard/verifier/mod.rs` |
| `shard/verify_consistency.rs` | `shard/verifier/consistency.rs` |

**Why this is a no-brainer**:
- With prover files in `shard/prover/`, having verifier files at the root level is inconsistent. The verifier and its consistency checks form a natural pair.
- `verify_consistency.rs` is only imported by `verifier.rs`.

**What changes in calling code**:
- `shard.rs`: Replace the 2 `#[path]` declarations with `mod verifier;` and update re-exports.
- `shard/verifier/mod.rs` (was `verifier.rs`): Add `mod consistency;` and import from it instead of the old path.

**Risk**: Low. Same re-export strategy as Change 4.

---

### Change 6: Flatten `memory/transcript_and_common.rs` and delete it

**Promote/move**: the non-packed shared helpers out of `transcript_and_common.rs`; move RISC-V-specific parts into `riscv/`

| From | To |
|------|-----|
| `memory/opening_lookup.rs` (sub of transcript_and_common) | `memory/opening_lookup.rs` (direct child) |
| `memory/sparse_time_oracles.rs` (sub of transcript_and_common) | `memory/sparse_time_oracles.rs` (direct child) |
| `memory/step_memory_binding.rs` (sub of transcript_and_common) | `memory/step_memory_binding.rs` (direct child) |
| `memory/trace_semantics.rs` (sub of transcript_and_common) | `memory_sidecar/riscv/trace_semantics.rs` |
| packed-op enum / packed-route glue from `transcript_and_common.rs` | `memory_sidecar/riscv/packed_ops.rs` |

**Why this is a no-brainer**:
- `transcript_and_common.rs` is essentially a re-export hub plus one packed-op enum. The extra layer of indirection adds cognitive load without providing real grouping value.
- The 4 child files are already physically located in `memory/` — they're just routed through `transcript_and_common.rs` via `#[path]` for no obvious benefit.
- After this change, the shared helpers are declared directly, and the RISC-V-specific packed/trace pieces move to the new `riscv/` namespace where they actually belong.

**What changes in calling code**:
- `memory.rs` → `memory/mod.rs`: Remove `#[path = "memory/transcript_and_common.rs"]` and add 4 direct `mod` declarations.
- Re-export `absorb_step_memory` from `memory/mod.rs` directly out of `step_memory_binding.rs`.
- Re-export `TwistTimeLaneOpenings` from `memory/mod.rs` directly out of `sparse_time_oracles.rs`.
- After those direct re-exports are in place, delete `transcript_and_common.rs` entirely. This file does not survive as a smaller hub.
- All crate-internal callers use `crate::memory_sidecar::memory::*` re-exports which won't change.

**Risk**: Low. Pure structural simplification.

---

### Change 7: Promote `precompiles/` one level up

**Move**: `memory_sidecar/memory/precompiles/poseidon2/` → `memory_sidecar/precompiles/poseidon2/`

**Why**:
- The Poseidon2 precompile files are currently 3 levels deep: `memory_sidecar/memory/precompiles/poseidon2/`. But they're included via `#[path]` from `memory.rs` with no actual filesystem traversal benefit from the extra `memory/` layer.
- Since we're moving Route-A files out of `memory/`, the precompiles should also be promoted to reduce the depth of `memory/`.
- The Poseidon2 precompile is a distinct subsystem (it has its own trace layout, claim builders, link builders, and terminal checks). Placing it at `memory_sidecar/precompiles/poseidon2/` makes it easy to add future precompiles (e.g., `precompiles/sha256/`) at the same level.

**What changes in calling code**:
- `memory.rs` → `memory/mod.rs`: Update the 4 `#[path = "memory/precompiles/poseidon2/*.rs"]` declarations to reference the new location, or the parent `memory_sidecar/mod.rs` declares the `precompiles` module.
- Internal re-exports don't change.

**Risk**: Low. Path-only change in 4 `#[path]` declarations.

---

## Files to Consider Splitting (Future)

These files are too large for comfort. I'm listing them for awareness and future planning but **not proposing to split them in this round** since file splits touch internal logic, not just directory structure.

### `cpu_bus.rs` — 2,574 lines

This is the largest file in the crate. It handles:
1. Bus layout definition and column allocation (~800 lines)
2. CCS extension for shared CPU bus (~600 lines)
3. Decoding/encoding helpers (decode_cpu_z_to_k, etc.) (~400 lines)
4. Time-sparse column construction (~400 lines)
5. Bus step view trait implementation (~300 lines)

**Potential split**: `cpu_bus/mod.rs` + `cpu_bus/layout.rs` + `cpu_bus/ccs_extension.rs` + `cpu_bus/decode.rs` + `cpu_bus/time_sparse.rs`. However, many internal functions cross-reference each other, so the split boundaries need careful analysis.

### `riscv/decode_residuals.rs` (currently `w2_virtual_constraints.rs`) — 2,241 lines

This file defines RISC-V virtual instruction constraint residuals. It's essentially a big dispatch table by opcode:
- Selector residuals (~400 lines)
- Bitness/shift residuals (~400 lines)
- ALU residuals (add/sub/mul/div) (~800 lines)
- Branch/jump residuals (~400 lines)
- Table ID caching (~200 lines)

**Potential split by instruction category**: `w2_virtual/mod.rs` + `w2_virtual/alu.rs` + `w2_virtual/branch.rs` + `w2_virtual/bitness.rs` + `w2_virtual/selectors.rs`. This is cleaner than cpu_bus because the different opcode families are fairly independent.

### `sparse_oracles_and_twist_pre.rs` — 1,599 lines

This file is mixed in a way that cuts directly across the planned `route_a/` vs `riscv/` split:
- generic sparse-time oracle implementations
- shared sparse-column helpers
- RISC-V-specific decode/width lookup-slot resolution helpers

**Near-term plan**:
- keep the generic sparse-oracle types here during Phase 1
- extract the clearly RISC-V-specific lookup-slot resolvers during Phase 2 into `riscv/trace_openings.rs`

**Potential follow-up split**:
- `memory/sparse_oracles.rs` — generic sparse-time oracle types
- `riscv/trace_lookup_slots.rs` or `riscv/trace_openings.rs` — RISC-V decode/width lookup-slot helpers
- any remaining shared Twist-pre helpers stay in `memory/`

### `route_a_claims.rs` — 2,036 lines

This file builds both Shout and Twist Route-A claims. It could be split into:
- `claims/shout.rs` — Shout claim construction
- `claims/twist.rs` — Twist claim construction
- `claims/common.rs` — Shared types like `ValueCursor`, `DenseCols`

### `riscv/oracles.rs` (currently `route_a_oracles.rs`) — 1,874 lines

This file builds all Route-A memory oracles. It could be split by oracle type:
- `oracles/shout.rs` — Shout time-lane oracles
- `oracles/twist.rs` — Twist oracles
- `oracles/rv64_packed.rs` — RV64 packed mul/div oracles

### `prover.rs` — 1,828 lines

The main shard proving orchestration. It's heavily sequential (the proving loop), so splitting is harder. The submodules (context.rs, lanes.rs, route_a.rs) already extracted the clearest pieces. The remaining ~1,800 lines is the core loop and its immediate helpers. I'd leave this alone.

### `riscv_trace_shard.rs` — 1,814 lines

The legacy RV32 frontend. Given it's explicitly marked as legacy/reference and not the maintained product path, splitting it adds maintenance burden to code that ideally shrinks over time. I'd leave this alone.

---

## Files to Consider Merging (Future)

### Tiny core_utils files

| File | Lines | Content |
|------|-------|---------|
| `commit_mixers.rs` | 14 | One struct definition |
| `step_linking.rs` | 39 | One struct + one function |
| `oracle_dispatch.rs` | 41 | One enum |

These 3 files total **94 lines**. They could merge into a `core_utils/small_types.rs` or even fold into `core_utils/mod.rs`. However, each is thematically distinct (commitment mixing, step linking, oracle dispatch), so the current organization isn't wrong — it's just more granular than necessary. **Low priority.**

### memory_sidecar utility files

| File | Lines | Content |
|------|-------|---------|
| `sumcheck_ds.rs` | 77 | 4 domain-separated sumcheck wrappers |
| `transcript.rs` | 59 | 4 transcript binding helpers |
| `utils.rs` | 72 | `RoundOraclePrefix` + `bitness_weights` |

These 3 files total **208 lines**. They're all small utility modules for the memory sidecar. Could merge into a single `memory_sidecar/helpers.rs`. **Low priority.**

---

## External API Preservation Strategy

### Critical External Consumers

| Consumer Crate | Imports From | Used Types/Functions |
|---|---|---|
| neo-spartan-bridge | `neo_fold::shard::*` | `ShardProof`, `StepProof`, `BatchedTimeProof`, `MemSidecarProof`, `FoldStep` |
| neo-spartan-bridge | `neo_fold::session::*` | `FoldingSession`, `Accumulator`, `ProveInput`, `me_from_z_balanced` |
| neo-spartan-bridge | `neo_fold::pi_ccs::*` | `FoldingMode`, `RotRho`, `rot_rhos_from_mats` |
| neo-fold-ffi | `neo_fold::test_export::*` | `parse_test_export_json`, `run_test_export`, `estimate_proof`, `folding_summary`, `TestExportSession` |
| neo-fold-ffi | `neo_fold::shard::ShardProof` | `ShardProof` |
| neo-midnight-bridge | `neo_fold::test_export::*` | `parse_test_export_json`, `TestExportSession` |

### Backward-Compatibility Re-exports

Every module that moves gets a re-export at its old path in `lib.rs`:

```rust
// New module structure
pub mod frontends;

// Backward-compatible re-exports (old paths still work)
pub use frontends::test_export;
pub use frontends::rv64_trace_shard;
pub use frontends::riscv_trace_shard;
```

The `pi_ccs` re-export from `neo_reductions` is untouched. The `shard` and `session` module paths are untouched. Only `test_export`, `rv64_trace_shard`, and `riscv_trace_shard` paths change, and they get backward-compatible re-exports.

### Internal Test Impact

The crate has **147 test files** across 6 test directories:
- `tests/` (integration tests)
- `riscv-tests/`
- `poseidon2-tests/`
- `sha256-tests/`
- `perf-tests/`
- `starstream-tests/`

These all import via `neo_fold::*` (the crate name), so the backward-compatible re-exports in `lib.rs` ensure they continue to work without modification. Only tests that import `crate::*` (i.e., in-crate unit tests like `cpu_bus_tests.rs`) would need path updates, and those are handled by updating the parent module's re-exports.

---

## Execution Order

To minimize risk, changes should be applied in this order:

1. **Change 7 first** (promote precompiles) — small, path-only
2. **Change 2** (generic Route-A grouping) — medium scope, biggest navigability win in `memory_sidecar`
3. **Change 3A** (whole-file `riscv/` moves) — medium scope, establishes the sibling VM namespace
4. **Change 3B** (targeted `riscv/` extractions) — medium scope, finishes the obvious VM-specific split
5. **Change 3C** (function-level extraction from mixed `route_a/` files) — medium scope, removes inline RISC-V bodies from generic files
6. **Change 6** (delete `transcript_and_common`, promote remaining shared helpers) — now safe because `riscv/` exists
7. **Change 5** (verifier directory) — small, natural pair with prover grouping
8. **Change 4** (prover directory) — medium scope, depends on verifier move being done
9. **Change 1 last** (frontends directory) — touches external API surface, needs re-exports

Each change should be a separate commit so we can verify compilation at each step.

---

## What This Plan Does NOT Do

- **Does not rename any public types or functions** — only file/directory locations change
- **Does not change any module visibility** — `pub`, `pub(crate)`, and private stay the same
- **Does not do broad logic rewrites** — the plan is primarily structural, though Phase 2 includes a small number of targeted extractions from mixed files
- **Does not intentionally change any logic** — Phase 2 extractions are semantics-preserving refactors, not protocol changes
- **Does not add more than 2 levels of directory nesting** — deepest path is `memory_sidecar/precompiles/poseidon2/`
- **Does not break any external consumer** — backward-compatible re-exports preserve all old import paths
- **Does not introduce a VM adapter trait yet** — module boundaries come first
- **Does not replace typed stage/opening structs with generic bags of claims** — type safety stays local until there are two real VM implementations
- **Does not rename `WB` / `WP` / `W2` / `W3` / `stage8` in this round** — naming cleanup is deferred until after the structural moves stabilize

---

## Summary of Impact

| Metric | Before | After |
|--------|--------|-------|
| Files at crate root (src/) | 9 | 4 |
| Files in memory_sidecar/memory/ | 17+ (incl. sub-modules) | 7-8 shared files |
| Files in memory_sidecar/riscv/ | 0 | ~8 VM-specific files |
| Files in shard/ top-level | 13 | 4 (mod, prove_api, verify_api, audit_types) |
| Generic Route-A files scattered across | 2 directories | 1 directory |
| RISC-V Route-A refinements | mixed into memory/route_a files | 1 shallow sibling directory |
| Prover files in shard/ top-level | 5 (loose) + 3 (in prover/) | 0 (loose) + 8 (all in prover/) |
| Verifier files | 2 scattered in shard/ | 2 grouped in shard/verifier/ |
| Maximum directory depth | 4 (memory/precompiles/poseidon2/) | 3 (`memory_sidecar/riscv/*`, `precompiles/poseidon2/`) |
| External API changes | — | None (re-exports) |
| Total whole-file moves | — | ~two dozen |
| Targeted extractions from mixed files | — | a handful (Phase 2 only) |
| New directories created | — | 4 (frontends/, route_a/, riscv/, verifier/) |

---

## Future Phase: Naming and VM Abstraction Cleanup

These are **not part of this round** and should happen only after the structural moves above land cleanly.

### 1. Replace opaque stage nicknames with semantic names

The current names are coordinated but opaque:
- `WB` → likely `trace_booleanity`
- `WP` → likely `trace_terminal_openings`
- `W2` → `decode_residuals`
- `W3` → `width_residuals`

This rename is intentionally deferred because it touches claim labels, transcript labels, proof-data names, tests, and Lean-side artifact validators.

### 2. Introduce a real VM adapter boundary only after VM #2 exists

Once a second VM has concrete code, extract the interface from the two implementations rather than guessing it today. The likely boundary will sit between:
- generic Route-A batched-time plumbing in `memory_sidecar/route_a/`
- VM-specific residual/oracle/opening-carrier code in `memory_sidecar/riscv/` and its future siblings

Until then, direct module dependencies are clearer and safer than traits.

### 3. Remove the remaining RISC-V classification leak from `claim_plan.rs`

`claim_plan.rs` currently calls RISC-V-specific table-family predicates such as:
- `riscv_is_decode_lookup_table_id`
- `riscv_trace_is_width_lookup_table_id`

That is acceptable during the shallow `riscv/` extraction, but once VM #2 lands this should be replaced by VM-owned table-family classification rather than hardcoded RISC-V predicates in the sidecar root.

---

## Future Phase: Jolt-Inspired Improvements

These are **not part of this round** but worth tracking for a future pass. They come from studying how Jolt (`external/jolt/jolt-core/src/zkvm/`) organizes its codebase.

### 1. Rename `route_a` → descriptive name

`route_a` is an internal convention that doesn't appear in any paper. Jolt names modules by what they check (`ram/`, `registers/`, `instruction_lookups/`). Candidates:
- `twist_shout` — paper-protocol naming
- `mem_checking` — functional naming (aligns with Jolt paper Section B)

Deferred because: ~150+ references to `route_a` / `RouteA` across the crate; renaming is pure churn that doesn't affect structure.

### 2. Split `w2_virtual_constraints.rs` (2,241 lines) by instruction category

Jolt has **65 separate files** in `instruction/`, one per RISC-V instruction. neo-fold puts all virtual constraint residuals in one file. A middle ground: split by instruction family (ALU, branch, bitwise, memory) into 4-5 files inside a `w2_virtual/` directory.

### 3. Consider Jolt's "claim_reductions" pattern

Jolt has an explicit `claim_reductions/` layer (6 files, ~3,200 lines) between sumcheck proofs and opening proofs. neo-fold embeds this logic inside `shard/rlc_dec.rs` (1,108 lines) and `shard/prover.rs`. If this grows, extracting a `shard/claim_reductions/` module would align with Jolt's pattern.

### 4. Consider splitting `route_a/claims.rs` and `riscv/oracles.rs` by protocol

Jolt separates `ram/` from `instruction_lookups/` as siblings. neo-fold can't fully separate Twist from Shout (shared `r_time`), but within the `route_a/` directory, individual files could split:
- `claims.rs` (2,036 lines) → `claims/shout.rs` + `claims/twist.rs`
- `riscv/oracles.rs` (1,874 lines) → `oracles/shout.rs` + `oracles/twist.rs`

### 5. Rename `memory_sidecar` → more descriptive

The parent module `memory_sidecar` is also opaque. Jolt doesn't use "sidecar" at all. Options for a future rename:
- `mem_extensions` — extension proofs for memory/lookups
- `twist_shout` (if the inner directory gets a different name)
- `memory_protocol` — the memory-checking protocol layer

# RWASM Implementation Plan For `neo-fold-next`

## Purpose

This document is a detailed implementation plan for rebuilding the historical
RWASM prototype on top of the `neo-fold-next` architecture.

It is based on:

- the historical RWASM proving strategy,
- the current `neo-fold-next` VM/frontend contracts,
- the CHIP-8 implementation as the primary frontend reference,
- and the maintained RV64 path as the main reference for soundness boundaries
  and machine-data preparation discipline.

This is an implementation plan, not a theorem spec.

## Assumptions

These are the assumptions used in the plan:

1. The long-term owner should be `neo-fold-next`, not legacy `neo-fold`.
2. Phase 1 should reproduce the historical proving envelope, not solve full
   WASM proving.
3. The initial target is a frontend-integrated proving path that can build
   `StepBuild` records and run through the generic `neo-fold-next` proving
   spine.
4. A full RWASM kernel comparable to the CHIP-8 or RV64 kernel is out of scope
   for phase 1.
5. The branch should remain lean. New code should be added only where it has a
   clear ownership boundary in the `neo-fold-next` structure.

These are conventions and not necessities:

1. Mirroring the CHIP-8 directory shape exactly.
2. Reusing the historical witness layout verbatim.
3. Building Stage 1 / Stage 2 / Stage 3 submodules immediately.

## Executive Recommendation

Implement RWASM in two phases:

### Phase 1

Build a **frontend-owned RWASM row builder** inside `neo-fold-next` that:

- owns opcode metadata,
- owns trace normalization from `rwasm::Tracer`,
- owns a fixed-width core CCS spec,
- builds `StepBuild` records directly,
- and proves the historical narrow subset through the generic `neo-fold-next`
  run/prove/verify flow.

This phase should not attempt to build a full staged kernel.

### Phase 2

After phase 1 is stable, decide whether RWASM should:

- stay as a lightweight frontend with only generic `neo-fold-next` proof
  packaging,
- or grow a staged kernel analogous to CHIP-8 and RV64 with explicit auxiliary
  commitment/opening stages.

This split keeps the initial rewrite tractable.

## Mapping The Historical Design To The New Architecture

## Old responsibility -> New owner

### Opcode metadata

Old role:

- `neo-memory::wasm::opcode`

New owner:

- `crates/neo-fold-next/src/rwasm/isa.rs`
- `crates/neo-fold-next/src/rwasm/tables.rs`

Reason:

- CHIP-8 keeps opcode taxonomy and decode/table metadata inside the VM frontend.
- `neo-fold-next::vm` only owns generic contracts, not VM-specific opcode sets.

### Trace normalization

Old role:

- `neo-memory::wasm::tracer_adapter`

New owner:

- `crates/neo-fold-next/src/rwasm/execute.rs`
- `crates/neo-fold-next/src/rwasm/lower.rs`

Reason:

- in CHIP-8, execution and lowering are frontend-owned,
- the builder consumes already normalized per-step trace data,
- keeping normalization frontend-owned prevents generic crate pollution.

### Step witness layout and core CCS

Old role:

- `neo-memory::wasm::arith`

New owner:

- `crates/neo-fold-next/src/rwasm/layout.rs`
- `crates/neo-fold-next/src/rwasm/ccs.rs`

Reason:

- CHIP-8 keeps fixed layout constants and core CCS in `layout.rs` and `ccs.rs`,
- `VmSpec::core_ccs_spec()` expects the frontend to own its core CCS.

### Step packaging into proof inputs

Old role:

- `WasmTraceArith`,
- direct legacy `R1csCpu` / shared-bus witness path.

New owner:

- `crates/neo-fold-next/src/rwasm/builder.rs`

Reason:

- CHIP-8’s `Chip8TraceBuilder` is the direct model.
- The frontend should produce `StepBuild` records with `StepInput` and
  `extension_data`.

### VM contract boundary

Old role:

- implicit through legacy shared-bus/session APIs.

New owner:

- `crates/neo-fold-next/src/rwasm/spec.rs`
- `crates/neo-fold-next/src/rwasm/mod.rs`

Reason:

- CHIP-8 exposes `Chip8VmSpec` and a thin compatibility surface.
- RWASM should have an explicit `RwasmVmSpec` implementing `VmSpec`.

## Proposed File Structure

Add a new frontend subtree:

```text
crates/neo-fold-next/src/rwasm/
├── mod.rs
├── spec.rs
├── isa.rs
├── layout.rs
├── ccs.rs
├── tables.rs
├── execute.rs
├── lower.rs
├── builder.rs
└── trace.rs
```

### Ownership rules

`mod.rs`

- owns the frontend barrel,
- exports only the curated public RWASM frontend surface.

`spec.rs`

- thin compatibility / curated re-export layer,
- should stay small.

`isa.rs`

- owns opcode ids,
- opcode classification,
- stack arity metadata,
- stable lookup ids,
- trace-visible semantic categories.

`layout.rs`

- owns all witness column and width constants,
- owns public-prefix definition.

`ccs.rs`

- owns `RwasmVmSpec`,
- owns `CoreCcsSpec`,
- owns core row-local CCS construction.

`tables.rs`

- owns lookup-family metadata,
- owns packed relation family declarations,
- owns mapping from opcode family to frontend lookup channels.

`execute.rs`

- owns direct translation from `rwasm::Tracer` rows into frontend-local trace
  records.

`lower.rs`

- owns any trace normalization or row expansion required before proof building,
- should initially remain shallow because phase 1 is one-row-per-step.

`builder.rs`

- owns `RwasmTraceBuilder`,
- converts normalized rows into `StepBuild`,
- creates `StepInput` values by packing row-major witness vectors and committing
  them.

`trace.rs`

- thin compatibility barrel over `execute` + `lower` + `builder`.

## Detailed Phase Plan

## Phase 0: Documentation And Surface Definition

Goal:

- land the strategy and implementation plan before code.

Tasks:

1. Add this plan and the clean-room strategy doc to `neo-fold-next/specs/`.
2. Keep the docs frontend-oriented, not legacy-API-oriented.
3. State explicitly that phase 1 proves stack semantics and selected ALU ops
   only.

Exit condition:

- reviewers can point to one obvious intended ownership structure for RWASM.

## Phase 1: Frontend Skeleton

Goal:

- create a compilable RWASM frontend skeleton inside `neo-fold-next`.

Tasks:

1. Add `src/rwasm/mod.rs`.
2. Add `src/rwasm/spec.rs`.
3. Wire `pub mod rwasm;` into `crates/neo-fold-next/src/lib.rs`.
4. Re-export:
   - `RwasmVmSpec`,
   - `RwasmTraceBuilder`,
   - frontend-local trace/build error types.

Design constraint:

- keep the barrel thin like CHIP-8.

Exit condition:

- `neo-fold-next` exposes a placeholder RWASM frontend namespace with no proving
  logic yet.

## Phase 2: Opcode And Trace Taxonomy

Goal:

- rebuild the historical metadata layer under frontend ownership.

Tasks:

1. In `isa.rs`, define:
   - `RwasmOpcodeId` or reuse the concrete rWASM opcode code type,
   - `WasmOpcodeClass`,
   - `WasmShoutOpcode`,
   - `WasmOpcodeInfo`.
2. Preserve stable `WasmShoutOpcode -> ShoutId` numbering from the old branch.
3. Expose:
   - stack read count,
   - stack write count,
   - whether the row is direct arithmetic or auxiliary-routed,
   - whether the row touches observed linear memory or tables.
4. Define the explicit **phase-1 supported subset** in one obvious function or
   constant set.

Trade-off:

- The metadata table may cover more opcodes than phase 1 proves.
- That is acceptable as long as the supported subset is explicit.

Exit condition:

- frontend code can classify any tracer row and reject unsupported rows
  deterministically.

## Phase 3: Frontend-Local Trace Model

Goal:

- define the normalized row representation that the builder consumes.

Tasks:

1. In `execute.rs`, define `RwasmStepTrace` with at least:
   - cycle,
   - `pc_before`,
   - `pc_after`,
   - opcode id,
   - opcode metadata snapshot or recoverable key,
   - `sp_before`,
   - `sp_after`,
   - stack lane values,
   - optional observed linear-memory changes,
   - optional observed table changes,
   - optional lookup payload for auxiliary-routed ops,
   - halted flag.
2. Keep this frontend-local rather than forcing direct use of
   `neo-vm-trace::StepTrace`.
3. Implement translation from `rwasm::Tracer` to `Vec<RwasmStepTrace>`.

Why not use `neo-vm-trace` directly here:

- `neo-fold-next` does not require it at the frontend seam,
- the builder only needs enough structured data to produce `StepBuild`,
- frontend-local trace records keep the new design independent from legacy
  shared-bus API assumptions.

Exit condition:

- given a tracer, the frontend can produce deterministic normalized rows with
  the historical stack-pointer and lane semantics.

## Phase 4: Core Layout

Goal:

- define the fixed-width row shape for the RWASM main lane.

Tasks:

1. In `layout.rs`, define:
   - public prefix length,
   - witness width,
   - fixed `ONE` column,
   - opcode / PC / SP columns,
   - stack lane selector/address/value columns,
   - lookup metadata columns,
   - helper columns for direct ops.
2. Preserve the historical three-lane stack convention explicitly in comments.
3. Do **not** blindly copy the historical numeric column indices. Reassign them
   cleanly if needed, but preserve the semantic fields.
4. Keep witness width narrow enough that phase 1 remains small.

Recommended policy:

- prefer a fresh contiguous layout rather than carrying historical sparse
  numbering.

Exit condition:

- one file owns the canonical row shape for the RWASM frontend.

## Phase 5: Core CCS Spec

Goal:

- make RWASM a real `VmSpec`.

Tasks:

1. In `ccs.rs`, define `RwasmVmSpec { core: CoreCcsSpec, ... }`.
2. Implement `VmSpec`:
   - `name() -> "rwasm"`,
   - `state_spec()`,
   - `shout_tables()`,
   - `twist_tables()`,
   - `opcode_classes()`,
   - `decode_spec()`,
   - `core_ccs_spec()`.
3. Build the core CCS using `vm::r1cs_builder::R1csBuilder`, like CHIP-8.
4. Phase 1 direct obligations should include:
   - selector booleanness,
   - stack-pointer update,
   - non-branch PC update,
   - stack lane occupancy consistency,
   - direct arithmetic relations for supported direct ops.
5. For auxiliary-routed ops, the row-local lane should only enforce the local
   metadata consistency needed for phase 1.

Important design decision:

- Phase 1 should **not** attempt to encode all packed lookup soundness in the
  main CCS.
- Keep the main lane row-local and narrow, following the CHIP-8 and RV64 kernel
  design principle that non-local obligations belong outside the main lane.

Exit condition:

- `RwasmVmSpec::new()` produces a stable `CoreCcsSpec`.

## Phase 6: Step Builder

Goal:

- package normalized rows into `StepBuild`.

Tasks:

1. In `builder.rs`, define `RwasmTraceBuilder<'a, L> { log: &'a L }`.
2. Follow the `Chip8TraceBuilder` pattern:
   - build the frontend-local row witness vector,
   - pack row-major into `Mat<F>`,
   - split public prefix vs witness suffix,
   - commit the row matrix,
   - emit `StepInput`,
   - wrap as `StepBuild`.
3. Define a label format that is stable and trace-friendly, for example:
   - `rwasm@pc:<pc>:op:<opcode>`
4. Populate `extension_data` conservatively.

Recommended phase-1 extension mapping:

- `bytecode_fetch`:
  - use when the row has a meaningful fetch address / opcode code pair.
- `register_reads` / `register_writes`:
  - leave empty in phase 1 unless a concrete register-bank story exists.
- `ram_reads` / `ram_writes`:
  - use only if representing stack memory through this generic shape is more
    helpful than harmful.

Important point:

- CHIP-8’s `StepExtensionData` is optimized for CHIP-8 audit data.
- RWASM should not contort itself to overuse these fields if the semantics do
  not fit. Keep them shallow in phase 1.

Exit condition:

- given `Vec<RwasmStepTrace>`, the frontend can produce `Vec<StepBuild>`.

## Phase 7: Public API And Trace Barrel

Goal:

- expose a frontend surface similar in quality to CHIP-8.

Tasks:

1. In `trace.rs`, re-export:
   - the builder,
   - the execution / normalization entrypoints,
   - the frontend-local build error.
2. In `spec.rs`, re-export:
   - `RwasmVmSpec`,
   - selected ISA/taxonomy items.
3. Keep both files thin.

Exit condition:

- external callers can discover RWASM through one curated frontend surface.

## Phase 8: Phase-1 Tests

Goal:

- reproduce the historical proving envelope on the new spine.

Tasks:

1. Add tests under `crates/neo-fold-next/tests/`.
2. Create direct frontend tests for:
   - tracer normalization,
   - stack-pointer updates,
   - lane mapping,
   - supported-subset rejection.
3. Create prove/verify tests using:
   - `RwasmVmSpec`,
   - `RwasmTraceBuilder`,
   - `run::prove_run` / `run::verify_run`,
   - or packaged proof APIs where appropriate.
4. Cover historical examples:
   - `i32.const + i32.add`,
   - `i32.sub`,
   - `i32.popcnt`,
   - `i32.mul`,
   - `i32.and`,
   - `i32.or`,
   - `i32.xor`,
   - `i32.eq`,
   - `i32.ne`,
   - `i32.lt_s`,
   - `i32.lt_u`,
   - `i32.eqz`.

Testing constraint:

- phase 1 tests should validate the frontend and generic proof spine.
- they should not claim a full staged kernel exists.

Exit condition:

- the historical supported subset proves end to end on `neo-fold-next`.

## Phase 9: Auxiliary Lookup Design Decision

Goal:

- decide how to represent the historical packed lookup families in the new
  architecture without prematurely building a full staged kernel.

There are two viable phase-1 options.

### Option A: Frontend-local direct encoding only

Description:

- implement the historical supported subset entirely with row-local direct
  constraints in the core CCS.

Pros:

- simplest phase-1 integration with `neo-fold-next`,
- no new auxiliary protocol owner needed immediately.

Cons:

- loses the historical “reuse packed Route-A semantics” design,
- scales worse as more WASM ops are added,
- diverges from the intended long-term staged-kernel direction.

### Option B: Frontend-local placeholder auxiliary family

Description:

- keep row-local CCS narrow,
- define frontend-owned packed relation payload columns and proof-side metadata,
- but postpone full kernelization.

Pros:

- preserves the direct-vs-auxiliary split,
- aligns better with the CHIP-8 / RV64 philosophy,
- eases later migration into a staged kernel.

Cons:

- more design work in phase 1,
- some scaffolding may later move again.

Recommendation:

- choose Option B if the team is committed to a future RWASM kernel,
- choose Option A only if the near-term goal is proving the historical subset as
  quickly as possible with minimal architecture work.

Given the stated goal of upstream maintenance on Nico’s converging architecture,
Option B is the better fit.

## Proposed Phase-1 Scope Boundary

Phase 1 should prove:

- stack pointer continuity inside each row,
- direct semantics for:
  - `i32.const`,
  - `i32.add`,
  - `i32.sub`,
  - `i32.popcnt`,
  - `select`,
  - `br_if_eqz`,
  - `return`,
- auxiliary-routed or placeholder-aux families for:
  - `i32.mul`,
  - `i32.and`,
  - `i32.or`,
  - `i32.xor`,
  - `i32.eqz`,
  - `i32.eq`,
  - `i32.ne`,
  - `i32.lt_s`,
  - `i32.lt_u`.

Phase 1 should **not** prove:

- full linear-memory writes,
- table writes,
- arbitrary unsupported control-flow forms,
- multi-step continuity,
- full staged opening/kernel artifacts.

## Integration With The Generic Proof Spine

The target proving flow should look like:

1. Build `RwasmVmSpec`.
2. Normalize tracer rows into `Vec<RwasmStepTrace>`.
3. Use `RwasmTraceBuilder` to produce `Vec<StepBuild>`.
4. Extract `prepared` fields into `Vec<StepInput>`.
5. Call:
   - `run::prove_run` / `run::verify_run`, or
   - `run::prove_and_package` / `run::verify_packaged`.

This matches the current generic `neo-fold-next` API and avoids routing phase 1
through the older `neo-fold` session/shared-bus entrypoints.

## Suggested Milestones

### Milestone 1: Skeleton

- `rwasm/` subtree exists,
- `RwasmVmSpec` compiles,
- tracer normalization compiles,
- no proof tests yet.

### Milestone 2: Direct subset

- direct row-local ops prove end to end,
- no auxiliary lookup families yet.

### Milestone 3: Historical supported subset

- all historically covered ops prove end to end,
- labels, extension data, and public-step packaging are stable.

### Milestone 4: Kernel decision

- decide whether to:
  - stay frontend-only for now,
  - or begin a true staged `rwasm/kernel/` subtree.

## Future Kernelization Path

If phase 1 succeeds and the project decides to grow RWASM into a first-class
kernel, the natural next structure is:

```text
crates/neo-fold-next/src/rwasm/
├── mod.rs
├── spec.rs
├── isa.rs
├── layout.rs
├── ccs.rs
├── tables.rs
├── execute.rs
├── lower.rs
├── builder.rs
├── trace.rs
├── stage1/
├── stage2/
├── stage3/
└── kernel/
```

But phase 1 should not create those directories prematurely.

## Concrete Initial Work Queue

A practical first coding sequence is:

1. Add `src/rwasm/mod.rs`, `spec.rs`, `isa.rs`.
2. Add `layout.rs` with a fresh contiguous witness layout.
3. Add `ccs.rs` with `RwasmVmSpec` and only direct-op row-local constraints.
4. Add `execute.rs` with tracer normalization and stack-pointer replay.
5. Add `builder.rs` producing `StepBuild`.
6. Add one direct prove/verify test for `i32.const + i32.add`.
7. Add direct tests for `i32.sub`, `i32.popcnt`.
8. Add placeholder auxiliary-family interfaces in `tables.rs`.
9. Extend to the historical lookup-routed subset.
10. Only then evaluate whether a proper kernel subtree is justified.

## Summary

The right first implementation on `neo-fold-next` is not “port the old files”.

It is:

- build a new RWASM frontend in the CHIP-8 style,
- keep the main lane row-local and narrow,
- preserve the historical trace and stack semantics,
- preserve the direct-vs-auxiliary split,
- and defer full kernelization until the frontend proves the historical subset
  cleanly through the new proof spine.

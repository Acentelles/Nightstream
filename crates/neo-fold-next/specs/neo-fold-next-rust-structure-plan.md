# neo-fold-next Rust Structure Plan

## Purpose

This document records the target Rust ownership structure for
`crates/neo-fold-next`.

It is an implementation plan, not a theorem spec. Lean owns the mathematical
contract. This document owns how the Rust crate should be organized so a human
auditor can trace:

- the generic proving spine,
- the VM frontend boundary,
- the CHIP-8 kernel boundary,
- and the final packaged/audit surfaces,

without reconstructing ownership from historical scaffolding or Lean module
names.

## First-principles constraints

These are necessities:

- the generic `Π_CCS -> Π_RLC -> Π_DEC` spine stays VM-agnostic,
- protocol-critical Rust↔Lean boundaries stay exact,
- one invariant family should have one obvious Rust owner,
- the audit build path stays narrow and off the hot path by default,
- file structure should follow runtime ownership and data flow, not theorem
  decomposition.

These are conventions and should be rejected:

- putting every exported proof-related type in one `proof.rs`,
- making `chip8` a wide barrel that re-exports almost everything,
- forcing Rust files to mirror Lean surfaces,
- keeping stale scaffold docs because they were once true.

## Stable boundary rules

Structural refactors must preserve:

- transcript event ordering and challenge derivation,
- `root0` commitment ordering and `meta_pub` absorption semantics,
- opening-manifest meaning and canonical ordering,
- stage boundary meanings,
- prepared-step / bridge / staged-digest meanings,
- external release-artifact shape,
- generated-vector and imported-artifact parity results.

Rust does not need to mirror Lean internally. It only needs to preserve these
exported protocol surfaces.

## Current structure target

```text
crates/neo-fold-next/src/
├── lib.rs
├── proof.rs
├── opening.rs
├── step_build.rs
├── prover.rs
├── verifier.rs
├── run.rs
├── finalize.rs
├── time_opening.rs
├── vm/
│   ├── mod.rs
│   ├── state.rs
│   ├── decode.rs
│   ├── opcode_classes.rs
│   └── r1cs_builder.rs
└── chip8/
    ├── mod.rs
    ├── layout.rs
    ├── isa.rs
    ├── ccs.rs
    ├── tables.rs
    ├── execute.rs
    ├── lower.rs
    ├── builder.rs
    ├── spec.rs
    ├── trace.rs
    ├── stage1.rs
    ├── stage2/
    │   ├── mod.rs
    │   ├── common.rs
    │   ├── reg.rs
    │   └── ram.rs
    ├── stage3.rs
    └── kernel/
        ├── types.rs
        ├── public_meta.rs
        ├── transcript.rs
        ├── openings.rs
        ├── joint_opening.rs
        ├── bridge.rs
        ├── artifacts.rs
        ├── evidence.rs
        ├── lane_commitment.rs
        ├── lane_commitment/transport.rs
        ├── soundness_accounting.rs
        ├── stage_terminal.rs
        ├── stage_terminal/
        │   ├── stage1.rs
        │   ├── stage2.rs
        │   └── stage3.rs
        ├── verify_common.rs
        ├── verify_transcript.rs
        └── verify_artifact.rs
```

## Compatibility barrels

Two temporary barrels remain while callers are migrated onto the narrower
owners:

- `chip8/spec.rs` re-exports the machine-layer owners,
- `chip8/trace.rs` re-exports the runtime-builder owners.

They should stay thin and should not become mixed-responsibility owners again.

## Next target

The next structural cleanup should follow the real remaining mixed
responsibilities:

```text
crates/neo-fold-next/src/
├── lib.rs
├── proof.rs
├── opening.rs
├── step_build.rs
├── prover.rs
├── verifier.rs
├── run.rs
├── finalize.rs
├── time_opening.rs
├── vm/
└── chip8/
    ├── mod.rs
    ├── layout.rs
    ├── isa.rs
    ├── ccs.rs
    ├── tables.rs
    ├── execute.rs
    ├── lower.rs
    ├── builder.rs
    ├── stage1.rs
    ├── stage2/
    │   ├── mod.rs
    │   ├── common.rs
    │   ├── reg.rs
    │   └── ram.rs
    ├── stage3.rs
    └── kernel/
        ├── types.rs
        ├── public_meta.rs
        ├── transcript.rs
        ├── openings.rs
        ├── joint_opening.rs
        ├── bridge.rs
        ├── artifacts.rs
        ├── evidence.rs
        ├── lane_commitment.rs
        ├── lane_commitment/transport.rs
        ├── soundness_accounting.rs
        ├── stage_terminal/
        ├── verify_common.rs
        ├── verify_transcript.rs
        └── verify_artifact.rs
```

## Ownership rules

### Generic crate root

| File | Owns | Does not own |
|---|---|---|
| `proof.rs` | generic session spine types | VM/frontend extension records |
| `opening.rs` | shared opening claim / summary types | VM-specific opening manifests |
| `step_build.rs` | frontend-produced step build + extension records | proving logic |
| `prover.rs` | generic shard prove path | VM semantics |
| `verifier.rs` | generic shard verify path | VM semantics |
| `run.rs` | session orchestration | protocol math |
| `finalize.rs` | final packaged proof/public statement boundary | VM-specific artifact logic |
| `time_opening.rs` | shared final opening reduction/unification | CHIP-8 kernel manifests |

### Transitional CHIP-8 compatibility layer

| File | Owns | Does not own |
|---|---|---|
| `spec.rs` | temporary machine-layer compatibility re-exports | decode/layout/CCS ownership |
| `trace.rs` | temporary runtime-builder compatibility re-exports | execution/lowering/build ownership |

### Current CHIP-8 machine layer

| File | Owns | Does not own |
|---|---|---|
| `layout.rs` | lane width, column layout, pad-row shape | opcode decode |
| `isa.rs` | opcode types, program/state, decode | CCS construction |
| `ccs.rs` | `Chip8VmSpec` and CCS structure | execution |
| `execute.rs` | concrete CHIP-8 step execution | proof-row lowering |
| `lower.rs` | execution step -> semantic/kernel row lowering | `StepBuild` packaging |
| `builder.rs` | row trace -> `StepBuild` packaging | execution semantics |
| `stage2/mod.rs` | Stage 2 orchestration | register-only or RAM-only Twist logic |
| `stage2/common.rs` | shared Stage 2 math and address machinery | proof orchestration |
| `stage2/reg.rs` | register-side Twist logic | RAM-side Twist logic |
| `stage2/ram.rs` | RAM-side Twist logic | register-side Twist logic |

### CHIP-8 kernel

| File | Owns | Does not own |
|---|---|---|
| `kernel.rs` | narrow public kernel API | re-export of every internal owner |
| `types.rs` | kernel proof/output surface types | construction logic |
| `public_meta.rs` | `meta_pub`, `root0`, public-input binding | release artifacts |
| `transcript.rs` | transcript event schedule | frame reconstruction |
| `openings.rs` | opening claims/manifests/refinements | bridge/export summaries |
| `joint_opening.rs` | joint-opening summaries and fold buckets | raw manifest construction |
| `bridge.rs` | row projection and prepared-step binding | frame reconstruction |
| `artifacts.rs` | exact frames, staged bundle, release artifacts | transcript scheduling |
| `evidence.rs` | semantic evidence and grouped digest surfaces | frame reconstruction |
| `lane_commitment.rs` | family-specific commitments/openings | generic commitment framework |
| `soundness_accounting.rs` | soundness/export accounting surface | transcript construction |
| `stage_terminal/` | terminal verifier closure per stage | full stage proving logic |
| `verify_*` | verifier-side replay helpers | proof construction |

## Public API rules

- `lib.rs` should expose only real top-level owners.
- `chip8/mod.rs` should expose a curated frontend/kernel surface, not star
  re-exports.
- `chip8/kernel` should expose only:
  - simple-kernel entrypoints,
  - simple-kernel public/proof/output types,
  - audit/release artifact types under `chip8-audit`.
- Tests and internal tooling should import submodule owners directly when they
  are intentionally testing internals.

## Refactor order

### Phase 1

1. make crate docs truthful and narrow the public API story,
2. consolidate CHIP-8 kernel owners so one invariant family has one obvious
   home,
3. split generic crate root into `proof.rs`, `opening.rs`, and `step_build.rs`.

### Phase 2

1. split `spec.rs` into layout / ISA / CCS owners,
2. split `trace.rs` into execute / lower / builder owners,
3. keep `spec.rs` and `trace.rs` as thin compatibility barrels only.

### Deferred

1. rename kernel files only when a real ownership mismatch remains,
2. reorganize tests around shared fixtures plus owner/topic files,
3. narrow additional public surfaces only where the stable boundary is already
   clear.

## Done condition

The structure is in good shape when a reviewer can explain the crate in this
order:

1. generic proving spine,
2. shared final opening/finalization path,
3. VM contract layer,
4. CHIP-8 machine frontend,
5. CHIP-8 simple kernel,
6. audit/release artifact path,

without needing stale docs, broad barrel exports, or Lean file names to infer
ownership.

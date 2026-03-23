# CHIP-8 Rust File Structure Plan

This document is the CHIP-8-specific slice of the broader crate plan in
[neo-fold-next-rust-structure-plan.md](./neo-fold-next-rust-structure-plan.md).
It should not be read as the full crate owner map.

## Purpose

This document records the target Rust file structure for the CHIP-8 kernel in
`neo-fold-next`.

It is an implementation ownership plan, not a theorem spec. Lean continues to
own the mathematical boundary. This document owns how Rust should be laid out
for human auditability while preserving the exact Rust↔Lean protocol boundary.

## Non-negotiable constraints

The following must remain unchanged by structural refactors:

- transcript event ordering and challenge derivation,
- `root0` commitment ordering and `meta_pub` absorption semantics,
- opening-manifest claim meanings and canonical ordering,
- prepared-step / bridge / staged-digest meanings,
- external release-artifact shape,
- generated-vector and imported-artifact parity results.

Rust does not need to mirror Lean files. It only needs to preserve these
exported protocol surfaces.

## File structure target

```text
crates/neo-fold-next/src/chip8/
├── mod.rs
├── poly.rs
├── layout.rs
├── isa.rs
├── ccs.rs
├── spec.rs
├── tables.rs
├── execute.rs
├── lower.rs
├── builder.rs
├── trace.rs
├── stage1/
│   ├── mod.rs
│   ├── proof.rs
│   ├── prove.rs
│   ├── verify.rs
│   └── transcript.rs
├── stage2/
│   ├── mod.rs
│   ├── common.rs
│   ├── proof.rs
│   ├── prove.rs
│   ├── verify.rs
│   ├── reg.rs
│   ├── ram.rs
│   └── transcript.rs
├── stage3/
│   ├── mod.rs
│   ├── proof.rs
│   ├── prove.rs
│   └── verify.rs
└── kernel/
    ├── mod.rs
    ├── types.rs
    ├── public_meta.rs
    ├── transcript.rs
    ├── openings.rs
    ├── joint_opening.rs
    ├── bridge.rs
    ├── artifacts.rs
    ├── evidence.rs
    ├── lane_commitment.rs
    ├── soundness_accounting.rs
    ├── stage_terminal.rs
    ├── verify_common.rs
    └── verify_artifact.rs
```

## Ownership rules

### Transitional compatibility files

| File | Owns | Does not own |
|---|---|---|
| `spec.rs` | temporary machine-layer compatibility re-exports | decode/layout/CCS ownership |
| `trace.rs` | temporary runtime-builder compatibility re-exports | execution/lowering/build ownership |

### Top-level CHIP-8 files

| File | Owns | Does not own |
|---|---|---|
| `layout.rs` | lane columns, memory bounds, pad-row shape | opcode decode |
| `isa.rs` | opcode/program/state/decode ownership | CCS construction |
| `ccs.rs` | `Chip8VmSpec`, `CommitmentId`, CCS construction | execution |
| `tables.rs` | ROM/decode/ALU/EQ4 tables | transcript or digest policy |
| `execute.rs` | concrete CHIP-8 execution | proof-row lowering |
| `lower.rs` | execution step -> semantic/kernel rows | `StepBuild` packaging |
| `builder.rs` | row trace -> `StepBuild` packaging | execution semantics |
| `poly.rs` | pure MLE / one-hot helpers | protocol policy |
| `stage1/mod.rs` | shared Stage 1 math, claims, and oracle machinery | Stage 1 proving or verifying entrypoints |
| `stage1/proof.rs` | Stage 1 proof surface and lane-opening contract | Stage 1 proving logic |
| `stage1/prove.rs` | Stage 1 proving entrypoint and prove-only channel builders | Stage 1 verification logic |
| `stage1/verify.rs` | Stage 1 verifier entrypoint | Stage 1 proving logic |
| `stage1/transcript.rs` | Stage 1 transcript replay | Stage 1 proving logic |
| `stage2/mod.rs` | Stage 2 module boundary and re-exported entrypoints | register-only or RAM-only Twist logic or proof surface ownership |
| `stage2/common.rs` | shared Stage 2 math and address/oracle machinery | final Stage 2 linkage batch |
| `stage2/proof.rs` | Stage 2 proof surface and lane-opening contract | Stage 2 proving logic |
| `stage2/prove.rs` | Stage 2 proving entrypoint and linkage batch construction | Stage 2 verification logic |
| `stage2/verify.rs` | Stage 2 verifier entrypoint | Stage 2 proving logic |
| `stage2/reg.rs` | register-side Twist logic | RAM-side logic |
| `stage2/ram.rs` | RAM-side Twist logic | register-side logic |
| `stage2/transcript.rs` | Stage 2 transcript replay | Stage 2 proving logic |
| `stage3/mod.rs` | shared Stage 3 math, shift helpers, and row-binding helpers | Stage 3 proving or verifying entrypoints |
| `stage3/proof.rs` | Stage 3 proof surface and lane-opening contract | Stage 3 proving logic |
| `stage3/prove.rs` | Stage 3 proving entrypoint | Stage 3 verification logic |
| `stage3/verify.rs` | Stage 3 verifier entrypoint | Stage 3 proving logic |
| `kernel/mod.rs` | simple-kernel orchestration and public entrypoints | large local type/helper bags |

### `chip8/kernel/` owners

| File | Owns | Does not own |
|---|---|---|
| `types.rs` | simple-kernel proof/output/witness surface types | stage-local proof surfaces or construction logic |
| `public_meta.rs` | `meta_pub`, `root0`, public-input binding helpers | joint openings or release artifacts |
| `transcript.rs` | transcript event surface and replay helpers | proof construction |
| `openings.rs` | opening claims, manifests, exact-opening refinements | bridge/export summaries |
| `joint_opening.rs` | joint-opening summaries, unification, fold buckets | raw manifest construction |
| `bridge.rs` | row projection and prepared-step bridge binding | frame reconstruction |
| `artifacts.rs` | exact frames, root context, staged bundle, release artifacts | transcript scheduling |
| `evidence.rs` | Stage 3 digest surfaces, semantic evidence, grouped execution digest | frame reconstruction |
| `lane_commitment.rs` | family-specific commitments and opening proofs | generic family frameworks |
| `soundness_accounting.rs` | exported error/accounting surfaces | transcript or artifact construction |
| `stage_terminal.rs` | terminal verifier closure per stage | full stage proving logic |
| `verify_common.rs` | cross-stage verifier utilities | stage-specific replay |
| `verify_artifact.rs` | artifact reconstruction/authentication | transcript event ownership |

## Structural rules

- Prefer one obvious owner per invariant family.
- Keep protocol-critical data flow explicit.
- Do not introduce generic commitment frameworks, planners, or stage traits.
- Do not move code only to satisfy line-count aesthetics if ownership gets
  worse.
- Split files by responsibility before they exceed the repo’s size limit.
- Keep the audit feature path narrow and out of the production hot path.

## Current direction

The current CHIP-8 refactor should continue in this order:

1. keep `kernel/mod.rs` shrinking toward orchestration only,
2. keep repeated commitment/opening wiring in one owned kernel object instead of
   re-spelling it several times,
3. keep `spec.rs` and `trace.rs` thin while callers migrate onto the narrower owners,
4. only split `stage_terminal.rs` if a stage-local ownership boundary becomes
   clearer than the current shared owner,
5. only split `lane_commitment.rs` if the split preserves explicit family
   meaning without introducing generic indirection.

## Done condition

The Rust structure is in good shape when a reviewer can understand the CHIP-8
kernel by reading, in order:

1. `chip8/kernel/mod.rs`
2. `chip8/kernel/types.rs`
3. `chip8/kernel/transcript.rs`
4. `chip8/kernel/openings.rs`
5. `chip8/kernel/bridge.rs`
6. `chip8/kernel/artifacts.rs`
7. `chip8/kernel/evidence.rs`

without needing to reconstruct ownership from Lean module names.

# CHIP-8 Rust File Structure Plan

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
├── spec.rs
├── tables.rs
├── trace.rs
├── stage1.rs
├── stage2.rs
├── stage2_reg.rs
├── stage2_ram.rs
├── stage3.rs
├── kernel.rs
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
    ├── soundness_accounting.rs
    ├── stage_terminal.rs
    ├── verify_common.rs
    ├── verify_transcript.rs
    └── verify_artifact.rs
```

## Ownership rules

### Top-level CHIP-8 files

| File | Owns | Does not own |
|---|---|---|
| `spec.rs` | opcode decode, lane columns, constants, machine layout | proving logic |
| `tables.rs` | ROM/decode/ALU/EQ4 tables | transcript or digest policy |
| `trace.rs` | witness generation from CHIP-8 execution | proof packaging |
| `poly.rs` | pure MLE / one-hot helpers | protocol policy |
| `stage1.rs` | Stage 1 proving and verification | bundle/export logic |
| `stage2.rs` | Stage 2 orchestration | all register and RAM internals inline |
| `stage2_reg.rs` | register-side Twist logic | RAM-side logic |
| `stage2_ram.rs` | RAM-side Twist logic | register-side logic |
| `stage3.rs` | Stage 3 proving and verification | release artifacts |
| `kernel.rs` | simple-kernel orchestration and public entrypoints | large local type/helper bags |

### `chip8/kernel/` owners

| File | Owns | Does not own |
|---|---|---|
| `types.rs` | proof/output surface types | construction logic |
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
| `verify_transcript.rs` | transcript replay checks | artifact reconstruction |
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

1. keep `kernel.rs` shrinking toward orchestration only,
2. keep repeated commitment/opening wiring in one owned kernel object instead of
   re-spelling it several times,
3. only split `stage_terminal.rs` if a stage-local ownership boundary becomes
   clearer than the current shared owner,
4. only split `lane_commitment.rs` if the split preserves explicit family
   meaning without introducing generic indirection.

## Done condition

The Rust structure is in good shape when a reviewer can understand the CHIP-8
kernel by reading, in order:

1. `chip8/kernel.rs`
2. `chip8/kernel/types.rs`
3. `chip8/kernel/transcript.rs`
4. `chip8/kernel/openings.rs`
5. `chip8/kernel/bridge.rs`
6. `chip8/kernel/artifacts.rs`
7. `chip8/kernel/evidence.rs`

without needing to reconstruct ownership from Lean module names.

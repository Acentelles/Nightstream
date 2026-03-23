# CHIP-8 Rust / Lean Boundary

## Purpose

This document defines:

- what **must match exactly** between Rust and Lean,
- what **must not** be forced into a 1:1 mirror,
- and the **north-star Rust structure** for a human-auditable CHIP-8 proving
  codebase.

This is an architecture and ownership document, not a theorem spec.

The formal CHIP-8 specs in
[../../../formal/nightstream-lean/specs/chip8](../../../formal/nightstream-lean/specs/chip8)
own the theorem surfaces. This document owns the implementation boundary:
how Rust should relate to those surfaces without reproducing Lean module
structure mechanically.

## Core rule

Lean owns the **mathematical contract**.

Rust owns the **runtime proof construction, verification, data flow, and
artifact production**.

Only the **final exported artifact boundary** must match Lean exactly.
Rust internals must be organized for ownership clarity, performance, and human
auditability, not for theorem-name parity.

## First principles

The following are necessities:

- there is one canonical CHIP-8 proof path,
- Lean defines the final staged digest and audit contract,
- Rust must emit an artifact that satisfies that contract,
- proof-binding semantics must be identical across Rust and Lean,
- human auditors must have one obvious place to look for each important
  invariant.

The following are conventions and must be rejected:

- one Rust file per Lean theorem surface,
- one Rust struct per Lean normalization lemma,
- reproducing Lean naming inside hot proving code when Rust ownership is
  different,
- building several parallel Rust reconstructions of the same proof because Lean
  exposes several projections of that proof.

## Exact-match boundary

The final Rust-to-Lean artifact is the only place where exact structural parity
is required.

The following must match exactly.

| Area | Exact-match requirement |
|---|---|
| Public input surface | Field set, meanings, canonical encodings, and digest/transcript binding semantics |
| `meta_pub` / public metadata | Field set, field meanings, ordering, and transcript absorption semantics |
| Commitment inventory | Which commitments are fixed in `root0`, which are kernel-owned, which are root-owned |
| Opening boundary | Which claims may appear, which are excluded, commitment ids, polynomial ids, points, and canonical ordering |
| Canonical root encoding | `RootEncode`, `PreparedStep`, and any digest or commitment derived from them |
| Exact frame / staged digest semantics | Meanings of `pre`, `post`, `dec`, `z`, prepared step, and row-level bridge objects |
| Transcript schedule | The challenge/event ordering that the exported artifact claims occurred |
| Stage boundary semantics | Stage-1, Stage-2, Stage-3 surface meanings and theorem-facing row/bridge semantics |
| Error/accounting surface | The exact accounting object exported for audit, if included in the Lean contract |
| Acceptance boundary | The conditions under which the Rust-produced artifact should be accepted or rejected by the Lean checker |

These are not "close enough" boundaries. Drift here is a soundness risk.

## Semantic-match boundary

Some things must match in meaning, but do not require Rust to mirror Lean's
internal decomposition.

| Area | Required parity | Rust freedom |
|---|---|---|
| Stage prover logic | Same accepted statements and same verifier consequences | Rust may organize helpers, loops, caches, and local contexts differently |
| Reconstruction logic | Same reconstructed semantic objects | Rust may reconstruct via one shared context rather than one function per theorem surface |
| Audit summaries | Same meaning and same final exported values | Rust may derive them from shared internal state instead of separate builders |
| Transcript emission | Same emitted sequence and same challenge derivation | Rust may implement this through one emitter/context rather than several projection files |
| Proof packaging | Same final proof-binding commitments/digests | Rust may package with different internal helper layout |

## What Rust must not mirror 1:1

The following do **not** need direct Lean-shaped ownership in Rust.

| Lean-side concept | Rust requirement |
|---|---|
| Individual theorem names | Do not create one Rust module per theorem unless it also matches runtime ownership |
| Normalization lemmas | Do not create one Rust builder per normalization result |
| Projection lemmas | Do not create separate reconstruction passes just because Lean has multiple projections |
| Interface granularity | Rust may use fewer, deeper modules if ownership is clearer |
| Typed proof of a relation | Rust may implement one concrete checker/constructor that realizes the relation |
| Formal proof decomposition | Rust may combine logically related steps if the runtime owner is one phase |

If Rust finds itself building:

- one execution digest builder,
- one staged digest builder,
- one stage-3 digest builder,
- one semantic evidence builder,

all from the same `(public, proof, output)` tuple by replaying overlapping
facts independently, the structure is wrong even if each builder matches a Lean
surface name.

## Rust north star

Rust should have **three layers** with one-way ownership.

### 1. Generic proving core

This layer owns only generic proving mechanics:

- `Π_CCS -> Π_RLC -> Π_DEC`
- step/session proving
- final proof packaging
- generic time-opening logic, only if it is truly VM-agnostic

This layer must not depend on CHIP-8 kernel internals.

In particular, generic proof files must not know about:

- `KernelStepAux`
- CHIP-8 row-local bridge objects
- CHIP-8-specific digest/export structs

### 2. CHIP-8 kernel/proving layer

This layer owns:

- trace construction,
- Stage 1 / Stage 2 / Stage 3 proof logic,
- opening/authentication/refinement logic,
- bridge construction,
- exact frame reconstruction,
- the kernel proof entrypoints.

This is the source of truth for the proof.

It should be organized by runtime ownership, not by Lean theorem names.

### 3. Audit/export adapter layer

This layer owns only:

- building the final Lean-facing artifact,
- serialization or export formatting,
- checker-facing projection of already-owned kernel facts.

This layer must be thin.

It must not independently rediscover the proof.

## One internal source of truth

Rust should build one internal artifact context from a verified kernel proof,
then project all export surfaces from that context.

Suggested shape:

```text
KernelArtifactContext
  public_surface
  meta_pub
  frames
  prepared_steps
  manifests
  row_projection_summary
  bridge_binding_summary
  transcript_events
  accounting
  stage3_row_surfaces
```

Rules:

- build it once at the end of kernel proof construction or immediately after a
  successful kernel verification,
- keep it immutable after construction,
- verify or reconstruct each owned fact once,
- make downstream digest/export code read from it,
- do not let multiple export modules replay the same proof independently.

This is the main structural requirement for auditability.

## Canonical Rust data flow

The intended Rust flow is:

```text
public input + witness
  -> trace construction
  -> Stage 1/2/3 proving
  -> opening/refinement/bridge checks
  -> exact frames
  -> KernelArtifactContext
  -> final Lean-facing staged digest
  -> Lean checker
```

Not:

```text
public + proof + output
  -> execution digest builder
  -> staged digest builder
  -> stage3 digest builder
  -> semantic evidence builder
```

where each builder reconstructs overlapping facts independently.

## Rust module structure target

The exact file names may change, but the ownership pattern should converge to:

```text
src/
  proof.rs
  prover.rs
  verifier.rs
  run.rs
  finalize.rs
  time_opening.rs        # only if truly generic

  chip8/
    trace.rs
    stage1/
      mod.rs
    stage2/
      mod.rs
      model.rs
      reg.rs
      ram.rs
      # or another ownership-based split
    stage3/
      mod.rs
    kernel/
      mod.rs
      types.rs
      prove.rs
      verify.rs
      openings.rs
      artifacts.rs
      export.rs
```

The important part is not the exact filenames. The important part is:

- generic proof code stays generic,
- CHIP-8 proof code stays CHIP-8-owned,
- export code stays thin and reads from one artifact context.

## Naming rules

Rust type and module names should describe what the code does or owns, not
which Lean theorem they correspond to.

Prefer names like:

- `KernelProofDigest`
- `StageDigests`
- `KernelArtifactContext`
- `TranscriptSchedule`
- `BridgeRows`

Avoid:

- names that only make sense if the reader already knows the Lean theorem tree,
- names that restate normalization or projection theorem labels,
- long "surface bundle summary digest" names that encode formal structure
  instead of runtime ownership.

Lean cross-references belong in comments and docs, not in every Rust type name.

## Required ownership moves

### `proof.rs`

`proof.rs` should own only generic proof/session types.

It should not own:

- CHIP-8-specific `kernel_aux`,
- CHIP-8-specific audit/export summaries,
- VM-specific extension data.

VM runtime data should live with the VM trace owner.

If generic step or session code must carry VM-owned data through the pipeline,
it should do so through an opaque frontend-owned attachment boundary, not by
importing concrete CHIP-8 kernel types into generic proof code.

### `kernel/mod.rs`

`kernel/mod.rs` should own:

- public proof types,
- the entrypoint orchestration,
- shared kernel-local types.

It should not remain a 1,300-line implementation sink that also manually
rewires the same artifact bundles in multiple places.

### stage files

Stage files should be split by responsibility when they become monolithic.

For example:

- replay/model logic,
- or by concrete subsystem when that is the real ownership split,
- should not stay interleaved in one giant file once that harms auditability.

Do not force a `prove.rs` / `verify.rs` split when both halves depend on one
shared reconstruction model and the split would just duplicate that model
knowledge.

### export files

Export files should be projections over `KernelArtifactContext`.

They should not each own an independent reconstruction pass.

### transcript schedule

The transcript schedule must match Lean exactly at the exported boundary.

Rust does not need a large event enum just because Lean reasons about an event
sequence.

Use an explicit Rust event type only if at least one of these is true:

- it is the canonical source used to emit the transcript,
- it is validated against a canonical schedule,
- it is the exact exported artifact consumed by the checker.

If an event enum is only documentary and the real source of truth is the
transcript emitter code, delete it and keep one canonical schedule owner.

## Final export rule

There should be one final auditor-facing export boundary:

- the Lean-defined staged execution digest and its checker input.

Other Rust-side digests or summaries are allowed only if they are clearly:

- internal debug views,
- non-authoritative,
- and not competing "real" boundaries.

If two exported Rust artifacts both look like the authoritative audit boundary,
the structure is wrong.

## Test structure

Tests should follow the same ownership boundary.

That means:

- test the generic proving core through generic proof and session behaviors,
- test CHIP-8 stage logic through CHIP-8 stage behaviors,
- test the final Lean-facing artifact through the one canonical export path.

Do not preserve one test file per Lean-shaped Rust helper if those helpers are
collapsed. Test files should follow the surviving Rust ownership boundaries, not
the deleted ceremony layers.

## Anti-patterns

The following are structural failures:

- generic core code depending on CHIP-8 kernel internals,
- one Rust module per Lean theorem surface,
- multiple artifact builders replaying the same proof independently,
- duplicated transcript schedule knowledge in several export modules,
- a monolithic proving stage combined with an over-fragmented export layer,
- debug/internal summaries becoming de facto public protocol boundaries.

## Review standard

A Rust change is aligned with this document if it moves the code toward:

- one canonical CHIP-8 proof path,
- one internal artifact context,
- one final Lean-facing export boundary,
- deeper modules with smaller public interfaces,
- and clearer ownership between generic proving code, CHIP-8 proof code, and
  export/audit code.

A Rust change is misaligned if it:

- adds a new Lean-shaped projection module without deleting an older Rust
  reconstruction path,
- moves CHIP-8 data into generic proof files,
- or makes the proof harder to trace from inputs to verified outputs.

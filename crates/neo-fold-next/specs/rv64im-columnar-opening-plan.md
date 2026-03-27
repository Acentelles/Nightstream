# RV64IM Columnar Opening Plan

## Purpose

Define the target architecture for moving the RV64IM proving kernel from:

- per-step root Ajtai commitments, and
- monolithic exact-stage opening surfaces

to:

- canonical committed column or family objects, and
- accumulated selected openings over those objects.

This is an implementation-owned improvement spec for `crates/neo-fold-next`.

## Problem

The current kernel reuses the root CCS **schema** but not the time-axis committed
object.

- The root main lane has fixed width `W = 38`.
- Each execution row is still turned into a separate `StepInput` with its own
  Ajtai commitment.
- Stage 1, Stage 2, and Stage 3 exact artifacts are flattened into large
  per-stage vectors and opened as monoliths.
- The compact selected-opening layer sits downstream of those exact monoliths.

This is structurally opposite to a columnar opening design. Time is encoded as
many committed instances instead of as opening points over a small set of
canonical committed objects.

## Hard Constraints

The redesign must preserve all of the following:

- same or stronger semantic statement as the current RV64IM kernel
- Ajtai commitments as the commitment primitive
- Poseidon2-only transcript and public-digest binding
- explicit verifier binding of all public selected-opening claims
- Rust-to-Lean boundary compatibility after the boundary is updated

The redesign must not rely on:

- verifier shortcuts that weaken the statement
- mixed hash families in protocol-binding paths
- aliasing openings across distinct commitments, selectors, or layouts

## Target Model

### 1. Root main lane is columnar

The root main lane owns one committed witness family over time:

- one fixed relation shape with width `W = 38`
- one time domain `T = 2^ell`
- one committed object family `C_lane`

The verifier opens `C_lane` at selected time points. It does not verify one
fresh Ajtai commitment per execution row.

### 2. Stage surfaces are canonical subobjects

Stage surfaces are committed as stable family-owned objects, not flattened
whole-stage vectors.

Minimum target split:

- Stage 1: semantic row family and stage-local auxiliary families
- Stage 2: read family, write family, RAM family, Twist family
- Stage 3: continuity family

Each family has:

- one ownership boundary
- one canonical layout
- one commitment identity

Packing into Ajtai blocks is allowed, but object identity remains at the family
or block level, never at the per-row proof-instance level.

### 3. Openings are identified canonically

Introduce a canonical `AjtaiOpeningId` with at least:

- committed object id
- family kind
- opening point kind
- opening point coordinates
- layout version

Two openings are aliasable iff all of the following are equal:

- underlying committed object
- opening point
- claimed value
- layout/version

### 4. Selected openings bind directly to committed objects

Selected-opening claims must bind directly to:

- committed object digest
- opening id set
- opened values
- semantic count or mix summaries required to prevent omission attacks

They must not depend on a digest of a monolithic exact-stage opening proof.

### 5. Exact full-stage openings are not on the production path

Exact full-stage openings may remain for:

- audit
- debug
- formal replay

They are not required on the production prover or verifier hot path.

## Soundness Invariants

### Opening alias safety

Alias reuse is allowed only for identical `(object, point, value, layout)`.
If the same object and point are requested with different values, proving must
fail.

### Transcript binding

The transcript must bind:

- the commitment root for all canonical families
- all selected opening ids
- all reduction coefficients
- all selected-opening value claims

### No silent family dropping

If a semantic obligation currently discharged through Stage 1, Stage 2, or Stage
3 remains required, the redesign must expose a selected-opening or reduction
claim that still binds it explicitly.

### Lean boundary rule

The theorem-facing Lean boundary must eventually target the new selected-opening
surface directly, not a legacy exact-stage flattened witness route.

## Migration Order

### Phase 1. Add canonical ids and accumulator

Add:

- canonical family ids
- `AjtaiOpeningId`
- prover and verifier opening accumulators

without deleting the current exact-stage path.

### Phase 2. Migrate Stage 2 first

Stage 2 is the first target because it already has natural grouped families:

- register reads
- register writes
- RAM events
- Twist payloads

This is the closest current analog to sparse, reusable opening requests.

### Phase 3. Rebind compact claims

Move compact selected-opening claims so they reference:

- canonical family commitments
- opening ids
- opened values

instead of exact-stage proof digests.

### Phase 4. Demote exact-stage monoliths

Once the compact path is complete and Lean is updated:

- remove exact-stage monoliths from the production hot path
- keep them only as optional audit or replay artifacts if still needed

## Acceptance Criteria

The redesign is acceptable only if all are true:

- root relation width remains fixed and time is represented as openings over
  committed families, not as one fresh committed step per row
- selected-opening proof work scales with selected opening count, not with
  whole-stage flattened witness size
- duplicate opening requests are measurably aliased by canonical id
- verifier checks remain explicit and sound
- Rust perf reporting shows exact-to-selected amplification collapsing
- Rust-to-Lean compatibility remains green after the boundary update

## Non-Goals

- changing the RV64IM semantics
- weakening the public proof boundary
- replacing Ajtai with another PCS
- introducing mixed-hash transcript binding
- preserving the current exact-stage artifact ownership if it blocks the
  columnar model

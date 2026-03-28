# CHIP-8 Auditor Summary

## Purpose

This page is the shortest ownership map for an external auditor reading the
Lean-facing CHIP-8 kernel bundle.

It does not introduce new theorem surfaces. It tells the reader which existing
owner is responsible for each soundness-carrying boundary.

## Core audit questions

| Audit question | Owning spec | What it owns |
|---|---|---|
| Which direct openings may appear, and which commitments are kernel-owned vs root-owned? | `Chip8OpeningBoundary.spec.md` | Kernel/root manifest schema for the simple boundary, canonical ordering, exact exclusions, the negative rule forbidding one global heterogeneous fold carrier, and the intentionally minimal positive admissibility rule for any optional family-local fold carrier |
| What is fixed in `root0`, and when are challenges sampled? | `Chip8TranscriptSchedule.spec.md` | Exact phase-0 commitment bundle, exact labeled `meta_pub` absorb order, exact transcript events, exact challenge-after-phase0 discipline, and exact row-binding event schedule |
| Which public inputs fix ROM layout, padding, initial state, and root parameters? | `Chip8RomScheduleBinding.spec.md` | Theorem-facing public-input binding surface for `meta_pub`, ROM shape, pad row, initial-state digests, and canonical root parameters |
| Which authenticated Stage 1 / Stage 2 / Stage 3 objects are sufficient for semantic extraction? | `Chip8EvidenceCoverage.spec.md` | Exact stage-local authenticated bundles, PCS refinement path, session closure, row projection, and semantic evidence coverage |
| How does one authenticated row bind to the exported prepared-step artifact? | `Chip8BridgeBinding.spec.md` | Exact row-local bridge/provenance surface tying authenticated row binding to the caller-supplied prepared-step artifact |
| How do exact authenticated rows close into one exact chunk trace? | `Chip8AuthenticatedTrace.spec.md` | Exact-trace closure, chunk-local execution closure, Stage-2 temporal context, Stage-3 `pc` adjacency, and authenticated temporal support |
| What is the top-level kernel theorem? | `Chip8KernelSoundness.spec.md` | Exact kernel conclusion bundle above authenticated trace closure, opening boundary, transcript schedule, and soundness accounting, together with the stronger direct corollary from raw exact boundary data to the same accepted-kernel theorem package |
| How is the theorem surface normalized for artifacts? | `Chip8KernelExecutionDigest.spec.md` | Lean-defined normalized kernel digest surface |
| How is the artifact checker tied back to the theorem surface? | `Chip8KernelArtifactAudit.spec.md` | Audit-checker acceptance theorem recovering the exact kernel conclusion bundle |

## Object classes

Use the following classification when reading opening-related objects:

- theorem / soundness-carrying:
  - direct opening claims
  - exact opening witnesses
  - refinements
  - authenticated stage-local checked objects
  - exact trace-closure theorems
- protocol-binding:
  - `root0`
  - manifest schemas
  - transcript schedule
  - public-input binding
- mandatory provenance:
  - row-projection witnesses
  - bridge-binding witnesses
- optional carrier / summary:
  - claim-space reductions
  - optional family-local fold carriers

## Simple-boundary root note

On the simple CHIP-8 kernel boundary:

- `RootOpeningManifest = ∅`
- root-side binding is carried by the exact `PreparedStep` export plus the
  row-local bridge-binding surface
- any later combined kernel-plus-root proof must add an explicit root-side
  commitment/opening schema instead of inferring one from the simple boundary

## Start-boundary note

On the simple CHIP-8 kernel boundary:

- the Stage-3 `j0_bits` opening is only the burst-start boundary and therefore
  contains `{IsMemOp, X_IDX}`
- `PC(0)` is not owned by that opening
- the first-row `pc` is owned by the simple-kernel chunk-input contract
  (`InitialStateMatches(init, first.pre)`) together with the authenticated
  first row and the exact trace-closure theorems

## Recommended reading order

1. `Chip8OpeningBoundary.spec.md`
2. `Chip8TranscriptSchedule.spec.md`
3. `Chip8RomScheduleBinding.spec.md`
4. `Chip8EvidenceCoverage.spec.md`
5. `Chip8BridgeBinding.spec.md`
6. `Chip8AuthenticatedTrace.spec.md`
7. `Chip8KernelSoundness.spec.md`
8. `Chip8KernelExecutionDigest.spec.md`
9. `Chip8KernelArtifactAudit.spec.md`

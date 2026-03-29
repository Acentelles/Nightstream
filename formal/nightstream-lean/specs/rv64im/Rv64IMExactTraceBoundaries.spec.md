# Rv64IMExactTraceBoundaries Spec

## Purpose

- **What it is**: The exact-boundary constructor surface for RV64IM authenticated trace closure.
- **What it is not**: It is not a new stage-local theorem owner and it does not re-prove Stage 1 / Stage 2 / Stage 3 semantics.
- **Protocol role**: It packages one exact family of accepted trace-local boundaries and lifts them into the canonical `AuthenticatedChunkTrace`. For proof-complete RV64IM kernel closure, the accepted execution theorem over those rows must still come from a separate root-execution-semantics owner above this module, not from summary equality and not from treating `StepComposition` as the accepted public boundary.

## Exact Boundary Package

`ExactTraceBoundaries` packages:

- `StepCompositionProofPackage`,
- `ChunkInput`,
- `MainLaneTraceBoundaryProofPackage`,
- `TraceLinkBoundaryProofPackage`,
- `TemporalConsistencyProofPackage`,
- `Stage2TemporalClosureProofPackage`,
- `Stage3RefinementPackage`,
- and the exact equality witnesses showing that they refer to one shared active semantic prefix.

The module also owns the minimal theorem-owned constructor contract
`MinimalExactTraceInputs`. This minimal contract carries the smallest
trace-local proof-bearing inputs needed to build `ExactTraceBoundaries`
without trusting Rust summaries. In this contract the `stage2Closure` field is
not a separate input; it is derived canonically as `temporal.stage2`.

## Canonical Constructor

The module must expose:

- `exactTraceBoundaries_of_minimalTraceInputs`
- `authenticatedChunkTrace_of_exactBoundaries`

which constructs the canonical `AuthenticatedChunkTrace` directly from one exact
trace-boundary package.

## Required Consequences

From exact trace boundaries one must be able to derive:

- `ExecutionCorrect` on the exact execution rows,
- `ExecutionCorrect` instantiated on the exact authenticated prefix,
- `TraceLinkBoundary` on that same prefix,
- `PreparedStepExportBound` on that same prefix,
- `AdjacentStateClosed`,
- `PcAdjacentBridge`,
- the exact canonical seven-proof opcode-class package carried by the exact authenticated trace boundary.
- the exact canonical seven-family semantic bundle carried by the exact
  authenticated trace boundary.
- the canonical exact native-ALU/word-shift/multiply word-arithmetic bundle
  carried by the exact authenticated trace boundary.
- the canonical exact native aligned-memory `LD` / `SD` opcode bundle carried
  by the exact authenticated trace boundary.
- the canonical exact narrow-memory helper-result bundle carried by the exact
  authenticated trace boundary.
- the canonical exact narrow-memory RAM-side payload bundle carried by the
  exact authenticated trace boundary.

For proof-complete kernel closure, the accepted execution theorem over the same
authenticated rows must be justified by a separate theorem owner that binds the
accepted chunk-scheduled root main-lane CCS package back to these rows.

## Ownership

This module owns only the passage from exact accepted trace boundaries to the
canonical authenticated trace theorem surface.

The theorem-facing exact-trace-boundary interface must re-export the
constructor that recovers the exact canonical seven-family semantic bundle from
exact trace boundaries.

The theorem-facing exact-trace-boundary interface must re-export the
constructor that recovers the exact word-arithmetic bundle from exact trace
boundaries.

The theorem-facing exact-trace-boundary interface must re-export the
constructor that recovers the exact native aligned-memory opcode bundle from
exact trace boundaries.

The theorem-facing exact-trace-boundary interface must re-export the
constructor that recovers the exact narrow-memory helper-result bundle from
exact trace boundaries.

The theorem-facing exact-trace-boundary interface must re-export the
constructor that recovers the exact narrow-memory RAM-side payload bundle from
exact trace boundaries.

# Rv64IM Accepted Artifact Local Trace

## Purpose

This component owns exact recomputation of the RV64IM trace-local theorem
packages that can be rebuilt directly from the accepted-artifact source case
and exported execution rows.

## Inputs

- Accepted-artifact source case.
- Accepted-artifact replayed execution rows.

## Required reconstruction

From those inputs, Lean must deterministically rebuild:

- the generated initial architectural state used by the chunk input,
- the exact chunk-input package,
- the exact main-lane trace-boundary package,
- the exact trace-link boundary package,
- the Stage 3 exported row-projection bindings.

If Rust exports higher-level summaries or digests for any of those objects,
Lean must recompute the object itself and require exact equality.

## Output contract

The component exposes:

- executable recomputation of the local trace view,
- exact equality checks for chunk input, main-lane boundary, trace-link
  boundary, and Stage 3 row bindings,
- a combined predicate stating that the exported local trace surface matches
  Lean recomputation exactly.

## Invariants

- Replay is driven only by the source case and execution rows.
- Prepared-step exports are derived from replayed execution rows, not trusted
  as imported summaries.
- Trace-local replay does not own root0 bindings, exact opening provenance, or
  the full `StepCompositionProofPackage`.

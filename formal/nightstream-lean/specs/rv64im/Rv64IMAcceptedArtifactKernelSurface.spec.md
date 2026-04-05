# Rv64IM Accepted Artifact Kernel Surface

## Purpose

This component owns the exact recomputation of the RV64IM kernel trace and
stage-witness projection bundles from the lowest practical accepted-artifact
inputs available to Lean.

## Inputs

- Accepted-artifact source manifest.
- Accepted-artifact derived execution rows.
- Accepted-artifact derived stage summaries.
- Accepted-artifact derived transcript summary.
- Accepted-artifact derived kernel summary digest fields.

## Required reconstruction

From those inputs, Lean must deterministically rebuild:

- the trace shape bundle,
- the trace projection bundle,
- the stage witness summary bundle,
- the stage witness projection bundle.

If Rust exports any higher-level digest or bundle for these objects, Lean must
recompute the higher-level object and require exact equality.

## Output contract

The component exposes:

- executable recomputation functions for the trace/stage witness bundles,
- exact equality checks against the exported kernel proof surface,
- a combined predicate stating that the exported kernel trace/stage witness
  surface matches Lean recomputation.

## Invariants

- Trace shape counts are derived only from the replayed execution rows.
- Trace projection binds the source manifest and the derived execution digest.
- Stage witness counts are derived only from the replayed stage summaries and
  transcript events.
- The theorem-facing acceptance lane may use the exported trace/stage bundles
  only as parity targets, never as authoritative inputs.
- Exact kernel-surface recomputation is not an execution proof and may not
  substitute for the root main-lane execution-semantics owner.
- Exact kernel-surface recomputation is not a bridge theorem and may not
  substitute for theorem-bearing authenticated selected-row, stage, or kernel
  opening objects.

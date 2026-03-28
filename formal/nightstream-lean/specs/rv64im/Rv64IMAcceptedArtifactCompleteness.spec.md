# Rv64IMAcceptedArtifactCompleteness Spec

## Purpose

- **What it is**: the Lean-owned completeness audit for the exported RV64IM accepted-artifact view.
- **What it is not**: it is not a digest-parity checker and it does not treat the current exported artifact view as theorem-complete by default.
- **Protocol role**: it enumerates the low-level exported fields required for Lean to reconstruct the exact RV64IM kernel boundary without trusting Rust-assembled higher-level summaries.

## Completeness Rule

An exported accepted artifact is theorem-complete only if it contains enough
low-level data for Lean to reconstruct:

- the source/program-binding inputs,
- the committed execution rows,
- the exact step-composition package,
- the exact trace chunk input,
- the exact main-lane trace boundary,
- the exact trace-link boundary,
- the exact temporal-consistency package,
- the exact Stage 2 temporal-closure package,
- the exact Stage 3 refinement package,
- the transcript event schedule inputs,
- the explicit soundness/accounting package or an equally explicit theorem-owned assumption surface,
- the full prepared-step export list,
- the full root-lane authentication rows,
- the full Stage 3 exported row bindings,
- the root0 commitment bindings,
- the kernel-opening witnesses,
- the exact opening provenance chains,
- the bridge witnesses linking provenance to exported rows.

Every required field must be present as exported data, not merely as a digest.
If a higher-level digest is exported for one of these objects, Lean must be able
to recompute it from the exported low-level field and compare it for exact
equality.

The completeness audit must be aligned with the actual theorem constructors,
especially `ExactKernelBoundaries` and `ExactTraceBoundaries`. If one of those
constructors requires an explicit package or assumption surface, the audit must
report that slot directly instead of hiding it behind a looser digest summary.

## Required Consequences

For each imported accepted-artifact case the completeness audit must report:

- which required theorem fields are present,
- which required theorem fields are absent,
- whether the artifact is theorem-complete as a whole.

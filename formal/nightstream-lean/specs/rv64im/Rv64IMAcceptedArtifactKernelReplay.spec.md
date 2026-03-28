# Rv64IM Accepted Artifact Kernel Replay

## Purpose

This component owns exact replay of the RV64IM kernel digest surface from the
lowest practical accepted-artifact source layer.

## Inputs

- Accepted-artifact source case.
- Exported accepted-artifact derived kernel/proof/claim surfaces used only as
  parity targets.

## Required reconstruction

From the source case alone, Lean must replay the RV64IM execution slice and
rebuild the imported derived kernel view. Lean must then require exact equality
between the replayed kernel bindings and every theorem-relevant exported
binding surface that is practical to compare directly.

At minimum this includes:

- the replayed derived kernel object itself,
- exported proof-statement bindings,
- exported kernel-claim bindings,
- exported kernel-proof summary bindings,
- exported stage digest bindings,
- exported terminal/root0/transcript bindings.

## Output contract

The component exposes:

- an executable replay function from accepted-artifact source to derived kernel
  replay view,
- exact equality predicates comparing replayed bindings against the exported
  artifact surfaces,
- a combined predicate stating that the exported accepted artifact matches the
  replayed kernel bindings exactly.

## Invariants

- Replay is driven only by the source case.
- Higher-level exported statement/claim/proof bundles are parity targets only.
- The completeness/audit lanes may not treat Rust-provided derived kernel
  digests as authoritative when the source replay can rebuild them.

# Rv64IMPublicProofProjection Spec

## Purpose

- **What it is**: the exact public-proof projection rebuilt from the accepted artifact boundary.
- **What it is not**: it is not an authoritative Rust-provided proof boundary.
- **Protocol role**: it turns the lowest practical RV64IM proof exports into the derived public shape `statement / claims / kernelProof`.

## Projection Rule

Lean must recompute the public-proof projection from the accepted artifact's
authoritative low layer.

The recomputation must cover:

- explicit fold cadence and derived chunk counts,
- protocol-binding digests,
- selected-opening identities and value digests,
- stage-claim and stage-package digests,
- kernel-opening bindings,
- root-lane/public-step surface,
- the final projected `statement / claims / kernelProof`.

The projection must derive chunk count from the carried `FoldSchedule` and the
active semantic row count, and it must reject any exported proof surface whose
chunk metadata does not match that derivation.

Normative consequences:

- `WholeTrace` projects exactly one root chunk over the active semantic rows,
- `RowsPerChunk(1)` projects the legacy per-row root chunking,
- changing the fold schedule changes the root theorem packaging, not the
  authenticated rows, stage obligations, or kernel-opening semantics.

Every projected object that Rust also exports must match exactly.

## Invariants

- Public-proof projection is a derived packaging owner only.
- Exact projection equality may not substitute for the separate root
  execution-semantics theorem owner.
- Exact projection equality may not substitute for the Nightstream bridge
  theorem binding authenticated selection, root execution, stage obligations,
  and kernel openings.

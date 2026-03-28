# Rv64IMAcceptedArtifactRootLane Spec

## Purpose

- **What it is**: the Lean-owned exact recomputation of the RV64IM root main-lane protocol-binding objects from exported execution rows.
- **What it is not**: it is not a PCS verifier, it does not verify Ajtai commitments, and it does not recover root0 commitment bindings.
- **Protocol role**: it rebuilds the semantic-row embedding and the row-authentication objects that bind execution rows into the public proof projection.

## Owned Recomputations

From the exported execution rows alone, this owner must deterministically
recompute:

- the exact 38-field semantic root row for each execution row,
- the root-lane row digests,
- the root-lane column digests,
- the root-lane family digest,
- the root-lane object id and selected opening refs for the first and last row,
- the full `RootLaneColumns` summary object,
- the derived main-lane surface object,
- the prepared-step binding digests and prepared-step binding summary digest.

All of these objects must follow the exact Rust transcript labels, field packing,
row layout, and digest domains used by the RV64IM public proof path.

## Required Consequences

This owner must expose executable recomputations strong enough for Lean to check:

- the recomputed `RootLaneColumns` object matches the exported kernel proof exactly,
- the recomputed main-lane surface digest matches the exported proof statement exactly,
- the recomputed prepared-step binding summary digest matches every exported location that binds it.

These checks are protocol-binding checks, not merely final-digest spot checks.

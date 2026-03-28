# Rv64IMAcceptedProofArtifact Spec

## Purpose

- **What it is**: the theorem-facing RV64IM accepted artifact boundary.
- **What it is not**: it is not the old summary-shaped public proof boundary and it does not treat Rust-computed `statement / claims / kernelProof` as authoritative inputs.
- **Protocol role**: it fixes the lowest practical Rust export layer from which Lean must recompute the protocol-binding projection consumed by the RV64IM soundness stack.

## Artifact Rule

The accepted artifact consists of the lowest practical proof-bearing RV64IM
export layer needed to reconstruct the theorem-owned kernel boundary. That
layer includes:

- the source case and derived execution rows,
- the transcript event stream and transcript-binding inputs,
- the full prepared-step export list,
- the full root-lane authentication rows and commitment inputs,
- the full Stage 1/2/3 row-binding and package inputs,
- the root0 commitment bindings,
- the program-binding public inputs,
- the explicit kernel-soundness accounting package or equally explicit theorem-owned assumption surface,
- the kernel-opening witnesses and exact opening provenance chains,
- the bridge-binding inputs tying exported rows to selected openings.

From that low layer Lean must reconstruct the protocol-binding objects and the
exact kernel boundary witness. Whenever both a source-layer input and a derived
execution object are exported, Lean must replay the source-layer input to the
derived object and require exact equality. The accepted artifact boundary is
only complete when those reconstructions are possible from exported data alone.

At the theorem boundary, the accepted artifact carries the recovered exact
kernel boundary witness itself. `AcceptedProofSoundness` is derived from that
exact boundary witness inside Lean; it is not stored as a primitive artifact
field.

It does not contain a preassembled `statement / claims / kernelProof` object.
Those public-proof objects exist only as recomputations of the artifact through
an explicit Lean-owned projection function.

The low-level exported layer is authoritative. Any higher-level exported digest,
summary, or claim object is only a projection target and must match Lean's
recomputation exactly.

## Required Consequences

From an accepted artifact one must recover:

- the exact public-proof schema projection,
- the corresponding public-proof boundary,
- the exact kernel boundary witness,
- accepted-proof soundness,
- the existing RV64IM execution/public-result consequences obtained from that soundness.

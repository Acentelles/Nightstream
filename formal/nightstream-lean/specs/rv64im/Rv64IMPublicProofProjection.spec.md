# Rv64IMPublicProofProjection Spec

## Purpose

- **What it is**: the exact public-proof projection rebuilt from the accepted artifact boundary.
- **What it is not**: it is not an authoritative Rust-provided proof boundary.
- **Protocol role**: it turns the lowest practical RV64IM proof exports into the derived public shape `statement / claims / kernelProof`.

## Projection Rule

Lean must recompute the public-proof projection from the accepted artifact's
authoritative low layer.

The recomputation must cover:

- protocol-binding digests,
- selected-opening identities and value digests,
- stage-claim and stage-package digests,
- kernel-opening bindings,
- root-lane/public-step surface,
- the final projected `statement / claims / kernelProof`.

Every projected object that Rust also exports must match exactly.

# Rv64IMAcceptedProofArtifactConsequences Spec

## Purpose

- **What it is**: the theorem-facing consequence layer for the RV64IM accepted artifact boundary.
- **Protocol role**: it is the explicit bridge from a low-level accepted artifact plus its separate theorem-owned boundary construction to accepted-proof soundness, exact public-proof projection, and the execution-facing corollaries used by the RV64IM soundness stack.

## Consequence Rule

From the accepted-artifact layer one must recover, by explicit theorem:

- the exact Rust-shaped public proof boundary projected by the low-level artifact,
- the accepted-proof soundness witness derived from the separate exact-kernel-boundary construction,
- execution correctness for the authenticated execution surface,
- the prepared-step export bound,
- the full halted-execution claim.

These are theorem consequences of the accepted artifact boundary layer. They
are not merely executable parity checks over imported vectors.

## Projection Rule

The accepted artifact must determine one exact public-proof projection. The
derived Rust-shaped public proof boundary must agree exactly with the artifact's
projected `statement`, `claims`, and `kernelProof`. Any accepted-proof witness
belongs to the accepted public proof wrapper, not to the public proof boundary
itself.

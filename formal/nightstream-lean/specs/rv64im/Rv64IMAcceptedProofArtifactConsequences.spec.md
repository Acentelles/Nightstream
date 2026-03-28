# Rv64IMAcceptedProofArtifactConsequences Spec

## Purpose

- **What it is**: the theorem-facing consequence layer for the RV64IM accepted artifact boundary.
- **Protocol role**: it is the explicit bridge from an accepted artifact to accepted-proof soundness, exact public-proof projection, and the execution-facing corollaries used by the RV64IM soundness stack.

## Consequence Rule

From an accepted artifact one must recover, by explicit theorem:

- the accepted-proof soundness witness carried by the artifact,
- the exact Rust-shaped public proof boundary projected by that artifact,
- execution correctness for the authenticated execution surface,
- the prepared-step export bound,
- the full halted-execution claim.

These are theorem consequences of the accepted artifact boundary itself. They are
not merely executable parity checks over imported vectors.

## Projection Rule

The accepted artifact must determine one exact public-proof projection. The
derived Rust-shaped public proof boundary must agree exactly with the artifact's
projected `statement`, `claims`, `kernelProof`, and accepted witness.


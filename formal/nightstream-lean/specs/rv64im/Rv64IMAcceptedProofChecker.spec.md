# Rv64IMAcceptedProofChecker Spec

## Purpose

- **What it is**: the theorem-facing RV64IM checker result surface above the accepted artifact boundary.
- **What it is not**: it is not a digest-only parity report and it does not own the generic RV64IM soundness theorems.
- **Protocol role**: it packages an accepted artifact together with the recovered exact kernel boundary, the recomputed public-proof projection, and the resulting execution/public-result consequences.

## Checker Contract

The checker must operate on the accepted artifact boundary, not on the old
summary-shaped public proof.

Acceptance means:

- the artifact is paired with an explicit Lean-owned projection function,
- the artifact carries the full low-level theorem inputs needed to reconstruct
  the exact kernel boundary, including the explicit fold schedule used by the
  root/public bridge,
- the checker uses that function to recompute the exact public-proof projection,
- the checker rejects any artifact that omits reconstructable theorem inputs,
- any remaining backend or accounting assumptions appear as explicit checker inputs or explicit theorem-owned side conditions, never as hidden ambient trust,
- the checker derives `AcceptedProofSoundness` from the reconstructed exact
  kernel boundary instead of treating it as a primitive artifact field,
- the execution/public-result consequences are available from the discharged projection.

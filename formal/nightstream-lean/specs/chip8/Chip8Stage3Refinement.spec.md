# Chip8Stage3Refinement Spec

## Purpose

- **What it is**: the explicit refinement from the low-level padded Stage-3
  check to the row-local `ContinuityRowBound` surface consumed downstream.
- **Key property**: `continuityRowBound_of_paddedCheck`.
- **Protocol role**: this owner prevents the low-level padded-domain Stage-3
  check from being silently conflated with the theorem-facing row-local
  continuity theorem.

## Target Formula

For one authenticated row `z`, if:

- `PaddedContinuityCheckBound` holds,
- the authenticated `currentRow` fields match `z`,
- the authenticated row-binding claim matches `z`,

then:

$$
\mathrm{ContinuityRowBound}(stepIdx,\dots,rowClaim,z).
$$

This is the exact bridge used by evidence, trace, digest, and audit owners.

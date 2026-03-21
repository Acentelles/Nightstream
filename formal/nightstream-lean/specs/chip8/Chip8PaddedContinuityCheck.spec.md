# Chip8PaddedContinuityCheck Spec

## Purpose

- **What it is**: the low-level Stage-3 padded-domain continuity owner beneath
  the theorem-facing row-local continuity surface.
- **Key property**: `continuityBound_of_paddedCheck`.
- **Protocol role**: this owner records the raw padded-domain shifted/current
  evaluations and the explicit excluded-tail correction terms required by the
  live Rust Stage-3 checker before the theorem-facing continuity relation is
  recovered.

## Target Formula

`PaddedContinuityCheckBound` packages:

- one theorem-facing `LaneShiftBound`,
- raw shifted values at `r_shift`,
- raw current-lane values at `r_shift`,
- one explicit excluded-tail correction bundle,
- equalities identifying the theorem-facing shifted/current values with the
  corrected active-prefix values,
- the corrected Stage-3 batched identity computed from those active-prefix
  values.

The theorem target is:

$$
\mathrm{PaddedContinuityCheckBound}
\Longrightarrow
\mathrm{Chip8ContinuityBridge.ContinuityBound}.
$$

This is the exact boundary where the padded-domain Rust check is made explicit
rather than silently identified with the row-local theorem surface.

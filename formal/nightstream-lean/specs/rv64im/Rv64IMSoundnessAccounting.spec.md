# Rv64IMSoundnessAccounting

## Purpose

Defines the theorem-facing soundness-error decomposition for the RV64IM kernel.

## Primitive terms

The accounting surface exposes negligible primitive error terms for:

- Stage 1 Shout channels,
- address-correctness families,
- Stage 2 Twist read/write and `Val` identities,
- RAM `raf`,
- Stage 1 and Stage 2 linkage batches,
- Stage 3 continuity,
- opening provenance,
- public program binding,
- PCS / Fiat-Shamir / outer composition.

## Aggregation

The kernel accounting defines:

- `epsStage1`,
- `epsStage2`,
- `epsStage3`,
- `epsKernelBinding`,
- `epsTotalUpper`.

The kernel proof package may expose any `epsTotal` as long as it is pointwise
bounded above by `epsTotalUpper`.

## Required theorem consequence

If every primitive term is negligible, then `epsTotalUpper` is negligible, and
any bounded `epsTotal` is negligible.

# Rv64IMFinalBoundaryClaim Spec

## Purpose

- **What it is**: The theorem-facing contract for the last active semantic row.
- **What it is not**: It is not the continuity proof and it does not define Stage-1 or Stage-2 correctness.
- **Protocol role**: It fixes the exact claim scope of this kernel version: acceptance proves a full halted execution ending in a terminating final row, not an arbitrary valid prefix.

## Target Formulas

Fix:

- `sequence : List Row`
- `terminatingRow : Row → Prop`

The final-boundary target is:

$$
\mathrm{FinalBoundaryClaim}(\mathrm{sequence},\ \mathrm{terminatingRow})
$$

meaning:

the last row of the committed active sequence is terminating.

The claim-scope target is:

$$
\mathrm{FullHaltedExecutionClaim}(\mathrm{sequence},\ \mathrm{terminatingRow}),
$$

which is definitionally equal to `FinalBoundaryClaim` for this kernel version.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/FinalBoundaryClaim.lean` | Final-boundary theorem surface |
| `Nightstream/Rv64IM/Execution/FinalBoundaryClaimInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Guarantee |
|---|---|---|---|
| Semantics | `FinalBoundaryClaim` | def | States that the last active row is terminating |
| Semantics | `FullHaltedExecutionClaim` | def | States that acceptance proves a full halted execution |
| Package | `FinalBoundaryClaimProofPackage` | structure | Packages the final-boundary theorem target |

## Proof Obligations

- The last active row is terminating.
- Valid-prefix claims are out of scope for this kernel version.

## Out of Scope

- which opcode classes may terminate
- row-local termination semantics

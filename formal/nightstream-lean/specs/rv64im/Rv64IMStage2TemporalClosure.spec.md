# Rv64IMStage2TemporalClosure Spec

## Purpose

- **What it is**: The theorem-facing Stage-2 owner for adjacent-state closure over register and RAM histories.
- **What it is not**: It is not the whole temporal-consistency theorem and it does not own PC continuity.
- **Protocol role**: It fixes the exact Stage-2 closure statement consumed by `TemporalConsistency` and `AuthenticatedTrace`.

## Target Formulas

Fix:

- `Stage2TemporalContext`
- `PreState : Nat → State`
- `PostState : Nat → State`
- `semanticRows : Nat`

The closure target is:

$$
\mathrm{AdjacentStateClosed}(\mathrm{PreState},\ \mathrm{PostState},\ \mathrm{semanticRows})
$$

meaning:

$$
\forall j,\ j + 1 < \mathrm{semanticRows}
\Longrightarrow
\mathrm{PostState}(j) = \mathrm{PreState}(j + 1).
$$

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/Stage2TemporalClosure.lean` | Stage-2 temporal-closure theorem surface |
| `Nightstream/Rv64IM/Execution/Stage2TemporalClosureInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Guarantee |
|---|---|---|---|
| Context | `Stage2TemporalContext` | structure | Packages register timeline, RAM timeline, and row-link evidence |
| Semantics | `AdjacentStateClosed` | def | States exact adjacent-state equality on the state projection |
| Package | `Stage2TemporalClosureProofPackage` | structure | Packages the context and closure theorem target |

## Proof Obligations

- The authenticated register and RAM histories induce one shared adjacent-state closure.
- The closure statement ranges over the exact active semantic prefix `[0, N)`.
- This package is the Stage-2 input to whole-state temporal consistency; it is not a standalone kernel theorem.

## Out of Scope

- PC continuity
- program binding
- bridge/export ownership

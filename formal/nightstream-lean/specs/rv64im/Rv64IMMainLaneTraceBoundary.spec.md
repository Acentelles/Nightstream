# Rv64IMMainLaneTraceBoundary Spec

## Purpose

- **What it is**: The theorem-facing boundary between authenticated semantic rows and exported prepared steps.
- **What it is not**: It is not the Stage-3 bridge proof and it does not own root-opening provenance.
- **Protocol role**: It fixes the exact row-count and index-alignment contract for semantic rows and prepared-step exports.

## Target Formula

`MainLaneTraceBoundary(rows, preparedSteps, semanticRows)` means:

- `rows.length = semanticRows`,
- `preparedSteps.length = semanticRows`,
- for every `idx < semanticRows`, both `rows[idx]` and `preparedSteps[idx]` exist.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/MainLaneTraceBoundary.lean` | Row/export count and index alignment |
| `Nightstream/Rv64IM/Trace/MainLaneTraceBoundaryInterface.lean` | Theorem-facing re-export surface |

## Proof Obligations

- Prepared-step export covers the exact active semantic prefix.
- Export shape is indexed, not multiset-based.

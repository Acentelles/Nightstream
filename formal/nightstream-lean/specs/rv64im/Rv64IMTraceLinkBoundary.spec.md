# Rv64IMTraceLinkBoundary Spec

## Purpose

- **What it is**: The theorem-facing row-to-row trace-link contract over the active semantic prefix.
- **What it is not**: It is not execution correctness and it does not own semantic state equality.
- **Protocol role**: It fixes the exact adjacency boundary that lets higher layers quantify over consecutive semantic rows.

## Target Formula

`TraceLinkBoundary(rows, semanticRows)` means:

- `rows.length = semanticRows`,
- for each `idx + 1 < semanticRows`, both `rows[idx]` and `rows[idx + 1]` exist.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/TraceLinkBoundary.lean` | Exact row-adjacency boundary |
| `Nightstream/Rv64IM/Trace/TraceLinkBoundaryInterface.lean` | Theorem-facing re-export surface |

## Proof Obligations

- Adjacency is defined on the exact active semantic prefix.
- The boundary is index-exact, not merely existential over unordered rows.

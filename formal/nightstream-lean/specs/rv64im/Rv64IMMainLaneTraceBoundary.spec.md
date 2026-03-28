# Rv64IMMainLaneTraceBoundary Spec

## Purpose

- **What it is**: The theorem-facing boundary between authenticated semantic rows and the chunked root main-lane theorem package.
- **What it is not**: It is not the Stage-3 bridge proof and it does not own root-opening provenance.
- **Protocol role**: It fixes the exact row-count, row order, and chunk partition contract for semantic rows and any optional prepared-step exports.

## Target Formula

`MainLaneTraceBoundary(rows, preparedSteps, chunks, semanticRows, schedule)` means:

- `rows.length = semanticRows`,
- `preparedSteps.length = semanticRows`,
- for every `idx < semanticRows`, both `rows[idx]` and `preparedSteps[idx]` exist,
- `chunks` is the ordered contiguous partition induced by `schedule`,
- the concatenation of `chunks` covers exactly `rows[0], …, rows[semanticRows - 1]` in order.

`schedule = WholeTrace` means `chunks.length = 1` when `semanticRows > 0`.

`schedule = RowsPerChunk(r)` means every non-final chunk has exactly `r` rows,
the final chunk has between `1` and `r` rows, and there are no skipped or
duplicated row indices.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/MainLaneTraceBoundary.lean` | Row/export count and index alignment |
| `Nightstream/Rv64IM/Trace/MainLaneTraceBoundaryInterface.lean` | Theorem-facing re-export surface |

## Proof Obligations

- Prepared-step export covers the exact active semantic prefix.
- Export shape is indexed, not multiset-based.
- Chunk boundaries preserve exact row order and exact row coverage.

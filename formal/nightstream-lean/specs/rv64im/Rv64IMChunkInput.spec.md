# Rv64IMChunkInput Spec

## Purpose

- **What it is**: The theorem-facing trace input boundary for one authenticated RV64IM chunk.
- **What it is not**: It is not execution correctness and it does not own temporal linking.
- **Protocol role**: It fixes the exact contiguous row interval consumed by one root main-lane fold round inside the proof-carried chunk schedule.

## Target Objects

`ChunkInput(State, Row)` packages:

- the chunk start index `startIndex`,
- the initial architectural state,
- the declared chunk row count,
- the ordered row list,
- a proof that the row list is exactly the active semantic interval
  `[startIndex, startIndex + chunkRows)`.

`FullHaltedChunkInput(chunk, terminatingRow)` means there exists a final index `idx` such that:

- `chunk.rows[idx]` exists,
- `idx + 1 = chunk.chunkRows`,
- `terminatingRow` holds on that final row.

The enclosing root theorem owns a `FoldSchedule ::= WholeTrace | RowsPerChunk(r)`.
That schedule induces an ordered contiguous partition of the active semantic
interval `[0, N)` into chunk inputs:

- `WholeTrace` means one chunk covering all active semantic rows,
- `RowsPerChunk(r)` means consecutive chunks of size at most `r`,
- there are no overlaps, no gaps, and no out-of-order rows.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/ChunkInput.lean` | Exact active-prefix chunk boundary |
| `Nightstream/Rv64IM/Trace/ChunkInputInterface.lean` | Theorem-facing re-export surface |

## Proof Obligations

- Every chunk covers exactly one contiguous active semantic interval.
- The ordered chunk list covers the full active semantic interval `[0, N)` exactly once.
- Full halted execution is a statement about the final active row, not an arbitrary prefix.

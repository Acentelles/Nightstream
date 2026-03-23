# Rv64IMChunkInput Spec

## Purpose

- **What it is**: The theorem-facing trace input boundary for one authenticated RV64IM chunk.
- **What it is not**: It is not execution correctness and it does not own temporal linking.
- **Protocol role**: It fixes the exact active semantic prefix length and the halted-boundary scope seen by the trace theorems.

## Target Objects

`ChunkInput(State, Row)` packages:

- the initial architectural state,
- the declared semantic row count,
- the row list,
- a proof that the active row list length is exactly the declared semantic count.

`FullHaltedChunkInput(chunk, terminatingRow)` means there exists a final index `idx` such that:

- `chunk.rows[idx]` exists,
- `idx + 1 = chunk.semanticRows`,
- `terminatingRow` holds on that final row.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/ChunkInput.lean` | Exact active-prefix chunk boundary |
| `Nightstream/Rv64IM/Trace/ChunkInputInterface.lean` | Theorem-facing re-export surface |

## Proof Obligations

- The semantic prefix is exact on `[0, N)`.
- Full halted execution is a statement about the final active row, not an arbitrary prefix.

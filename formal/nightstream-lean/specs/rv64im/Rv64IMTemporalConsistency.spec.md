# Rv64IMTemporalConsistency Spec

## Purpose

- **What it is**: The theorem-facing owner for whole-state temporal closure across registers, RAM, and PC adjacency.
- **What it is not**: It is not the Stage-2 or Stage-3 local owner by itself.
- **Protocol role**: It combines Stage-2 adjacent-state closure, PC adjacency, and register/RAM timelines into one semantic temporal statement.

## Target Formula

`TemporalConsistency(stage2, pcBridge, registers, ram)` means:

- `AdjacentStateClosed` holds for the Stage-2 semantic states,
- `PcAdjacentBridge` holds over the same active prefix,
- `RegisterTimelineBound` holds,
- `RamTimelineBound` holds,
- the register timeline, RAM timeline, and PC bridge all share the same semantic row count as Stage 2.
- for every `j < semanticRows`, `pcBridge.prePc(j)` equals the PC projection of `stage2.preState(j)`,
- for every `j < semanticRows`, `pcBridge.postPc(j)` equals the PC projection of `stage2.postState(j)`.

## Derived Consequences

From `TemporalConsistency` one must be able to extract:

- `AdjacentStateClosed(stage2.preState, stage2.postState)`,
- `PcAdjacentBridge(pcBridge.semanticRows, pcBridge.pcStates)`,
- `RegisterTimelineBound(registers.semanticRows, registers.registers)`,
- `RamTimelineBound(ram.semanticRows, ram.ram)`,
- exact semantic-row-count equalities tying the register timeline, RAM timeline, and PC bridge back to the Stage-2 semantic row count,
- exact pointwise equalities tying `pcBridge.prePc` to the Stage-2 pre-state PC projection,
- exact pointwise equalities tying `pcBridge.postPc` to the Stage-2 post-state PC projection.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/TemporalConsistency.lean` | Whole-state temporal closure |
| `Nightstream/Rv64IM/Trace/TemporalConsistencyInterface.lean` | Theorem-facing re-export surface |

## Proof Obligations

- Temporal closure is one shared semantic statement, not three unrelated lemmas.
- The same exact active prefix `[0, N)` is used everywhere.
- The PC bridge is the PC projection of the Stage-2 semantic states on that same exact prefix, not merely another array with the same row count.

# Rv64IMRegisterTimeline Spec

## Purpose

- **What it is**: The theorem-facing register timeline contract induced by authenticated Stage-2 register history.
- **What it is not**: It is not the register-history projection owner itself and it does not speak about RAM.
- **Protocol role**: It fixes how semantic pre/post states expose register values row-by-row across the active prefix.

## Target Formula

`RegisterTimelineBound(timeline, preState, postState, semanticRows)` means:

- for each `j < semanticRows`, `timeline j = preState(j).registers`,
- if `j + 1 < semanticRows`, then `timeline (j + 1) = postState(j).registers`.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/RegisterTimeline.lean` | Register timeline closure |
| `Nightstream/Rv64IM/Trace/RegisterTimelineInterface.lean` | Theorem-facing re-export surface |

## Proof Obligations

- The timeline is tied to the exact active semantic prefix.
- Register closure is expressed over semantic states, not only witness rows.

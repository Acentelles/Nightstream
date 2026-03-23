# Rv64IMRamTimeline Spec

## Purpose

- **What it is**: The theorem-facing RAM timeline contract induced by authenticated Stage-2 RAM history.
- **What it is not**: It is not the RAM-history projection owner and it does not define address virtualization.
- **Protocol role**: It fixes how semantic pre/post states expose RAM words row-by-row across the active prefix.

## Target Formula

`RamTimelineBound(timeline, preState, postState, semanticRows)` means:

- for each `j < semanticRows`, `timeline j = preState(j).ram`,
- if `j + 1 < semanticRows`, then `timeline (j + 1) = postState(j).ram`.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/RamTimeline.lean` | RAM timeline closure |
| `Nightstream/Rv64IM/Trace/RamTimelineInterface.lean` | Theorem-facing re-export surface |

## Proof Obligations

- RAM closure ranges over the exact active semantic prefix.
- RAM timeline facts are semantic-state facts, not only witness-carrying facts.

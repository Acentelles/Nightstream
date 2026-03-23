# Rv64IMNarrowMemoryPayloadTraceSemantics Spec

## Purpose

- **What it is**: The trace-level lifting owner for the canonical exact
  narrow-memory RAM-side payload bundle.
- **What it is not**: It is not the execution-level owner of those load/store
  consequences and it does not replace authenticated trace closure.
- **Protocol role**: It recovers the canonical exact narrow-memory payload
  bundle from an authenticated chunk trace or from exact trace boundaries.

## Required Constructors

The module must expose:

- `exactNarrowMemoryPayloadSemantics_of_authenticatedChunkTrace`
- `exactNarrowMemoryPayloadSemantics_of_exactBoundaries`

so consumers can move directly from the authenticated trace boundary to the
same canonical narrow-memory payload bundle.

## Proof Obligations

- The lifted bundle must range over the same `StepComposition` package carried
  by the authenticated trace.
- The exact-boundary constructor must factor only through
  `authenticatedChunkTrace_of_exactBoundaries`.
- The lifted bundle must preserve aligned-address decomposition, raw load-word,
  inactive helper-row, store-payload, and memory-writeback consequences.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/NarrowMemoryPayloadSemantics.lean` | Trace-level lifting of the canonical exact narrow-memory payload bundle |
| `Nightstream/Rv64IM/Trace/NarrowMemoryPayloadSemanticsInterface.lean` | Theorem-facing re-export surface |

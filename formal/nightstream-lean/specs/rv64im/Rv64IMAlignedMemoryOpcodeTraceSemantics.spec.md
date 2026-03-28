# Rv64IMAlignedMemoryOpcodeTraceSemantics Spec

## Purpose

- **What it is**: The trace-level lifting owner for the canonical exact native aligned-memory opcode bundle.
- **What it is not**: It is not the execution-level owner of `LD` / `SD` load/store consequences and it does not replace authenticated trace closure.
- **Protocol role**: It recovers the canonical exact aligned-memory opcode bundle from an authenticated chunk trace or from exact trace boundaries.

## Required Constructors

The module must expose:

- `exactAlignedMemoryOpcodeSemantics_of_authenticatedChunkTrace`
- `exactAlignedMemoryOpcodeSemantics_of_exactBoundaries`

so consumers can move directly from authenticated trace closure to the same canonical `LD` / `SD` opcode bundle.

## Proof Obligations

- The lifted bundle must range over the same `StepComposition` package carried by the authenticated trace.
- The exact-boundary constructor must factor only through `authenticatedChunkTrace_of_exactBoundaries`.
- The lifted bundle must preserve decoded-row / RAM-role agreement, `rd = x0` sink preservation, authenticated raw load-word equalities, authenticated load-writeback equalities, and authenticated store-payload equalities.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/AlignedMemoryOpcodeSemantics.lean` | Trace-level lifting of the exact aligned-memory opcode bundle |
| `Nightstream/Rv64IM/Trace/AlignedMemoryOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

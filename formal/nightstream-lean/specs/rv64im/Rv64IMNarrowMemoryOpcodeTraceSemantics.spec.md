# Rv64IMNarrowMemoryOpcodeTraceSemantics Spec

## Purpose

- **What it is**: The trace-level lift of exact narrow-memory opcode consequences.
- **What it is not**: It is not the execution opcode owner and not the kernel theorem owner.
- **Protocol role**: It lifts exact narrow-memory opcode contracts through `AuthenticatedChunkTrace` and `ExactTraceBoundaries`.

## Required Theorem Surface

The module must expose:

- `flags_of_authenticatedChunkTrace_narrowMemory`
- `x0WritePreserved_of_authenticatedChunkTrace_narrowMemory`
- `sequenceCorrect_of_narrowMemory_authenticatedChunkTrace`
- `flags_of_exactBoundaries_narrowMemory`
- `x0WritePreserved_of_exactBoundaries_narrowMemory`

## Proof Obligations

- The trace owner must preserve the same decoded-row opcode contract as the execution owner.
- The trace owner must preserve the exact narrow-memory committed-sequence correctness theorem at the authenticated-prefix level.
- The exact-boundary constructor path must reduce through `authenticatedChunkTrace_of_exactBoundaries`, not through an ad hoc duplicate object.
- The trace owner must preserve the kernel-spec `x0` sink/write-suppression rule.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/NarrowMemoryOpcodeSemantics.lean` | Trace lift of narrow-memory opcode semantics |
| `Nightstream/Rv64IM/Trace/NarrowMemoryOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

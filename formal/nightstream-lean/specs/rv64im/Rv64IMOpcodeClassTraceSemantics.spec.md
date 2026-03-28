# Rv64IMOpcodeClassTraceSemantics Spec

## Purpose

- **What it is**: The trace-level owner that lifts exact opcode-class semantic bundles through authenticated trace closure and exact trace boundaries.
- **What it is not**: It is not the execution owner for deriving the bundles themselves, and it is not the kernel theorem owner.
- **Protocol role**: It exposes exact opcode-class semantic consequences directly from authenticated Stage1/2/3 evidence.

## Required Constructors

The module must expose:

- `canonicalOpcodeClassSemantics_of_authenticatedChunkTrace`
- `canonicalOpcodeClassSemantics_of_exactBoundaries`
- direct per-class extractors from authenticated trace closure and exact trace boundaries for:
  - `nativeAlu`
  - `wordShift`
  - `controlFlow`
  - `narrowMemory`
  - `multiply`
  - `unsignedDivRem`
  - `signedDivRem`

Each constructor must recover the exact canonical opcode-class semantic bundle from:

- one `AuthenticatedChunkTrace`, or
- one `ExactTraceBoundaries` instance.

## Proof Obligations

- The lifted bundle must use the same authenticated active semantic prefix as the enclosing trace object.
- Trace-level lifting must not weaken the execution-level exact semantic bundle into a mere existence statement.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/OpcodeClassSemantics.lean` | Trace-level lifting of exact opcode-class semantic bundles |
| `Nightstream/Rv64IM/Trace/OpcodeClassSemanticsInterface.lean` | Theorem-facing re-export surface |

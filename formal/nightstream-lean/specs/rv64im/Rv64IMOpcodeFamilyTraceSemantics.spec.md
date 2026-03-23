# Rv64IMOpcodeFamilyTraceSemantics Spec

## Purpose

- **What it is**: The trace-level lifting owner for exact opcode-family semantic bundles.
- **What it is not**: It is not the execution-level owner of those facts, and it does not own kernel transcript or bridge logic.
- **Protocol role**: It lifts exact opcode-family semantics from authenticated trace evidence and exact trace boundaries.

## Required Constructors

The module must expose:

- `exactOpcodeFamilySemantics_of_authenticatedChunkTrace`
- `exactOpcodeFamilySemantics_of_exactBoundaries`

so consumers can recover one exact opcode-family semantic bundle from either:

- an authenticated RV64IM chunk trace, or
- one exact trace-boundary package.

## Proof Obligations

- The lifted bundle must range over the same `stepComposition` object carried by the authenticated trace.
- The exact-boundary constructor must factor only through the canonical authenticated-trace constructor path.
- The lifted bundle must preserve the same seven dedicated execution-level family bundles carried by `Rv64IMExactOpcodeFamilySemantics`.
- Unsigned DIV/REM determinism and the control-flow alignment discharge must remain visible at trace level.
- The lifted family bundle must remain strong enough to recover the canonical
  exact native-ALU/multiply word-arithmetic bundle without introducing new
  stage-local assumptions.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/OpcodeFamilySemantics.lean` | Trace-level lifting of exact opcode-family semantic bundles |
| `Nightstream/Rv64IM/Trace/OpcodeFamilySemanticsInterface.lean` | Theorem-facing re-export surface |

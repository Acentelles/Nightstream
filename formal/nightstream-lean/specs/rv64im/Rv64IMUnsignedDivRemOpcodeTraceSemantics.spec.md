# Rv64IMUnsignedDivRemOpcodeTraceSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner that lifts exact unsigned DIV/REM opcode consequences through the authenticated RV64IM trace boundary.
- **What it is not**: It is not the execution-level unsigned opcode owner and it does not replace `Rv64IMAuthenticatedTrace` or `Rv64IMExactTraceBoundaries`.
- **Protocol role**: It makes exact `DIVU` / `REMU` / `DIVUW` / `REMUW` consequences available directly from accepted trace evidence.

## Inputs

The module ranges over:

- one `AuthenticatedChunkTrace`, or
- one `ExactTraceBoundaries`.

It therefore inherits the same exact `StepComposition`, authenticated active-prefix trace, and exact unsigned opcode semantics for the same RV64IM execution object.

## Required Theorem Surface

The module must expose authenticated-trace lifts for:

- exact unsigned opcode bound,
- exact `DIVU` flag consequence,
- exact `REMU` flag consequence,
- exact `DIVUW` flag consequence,
- exact `REMUW` flag consequence,
- exact unsigned DIV semantic target,
- exact unsigned REM semantic target,
- exact unsigned semantic determinism.

It must also expose exact-boundary lifts for at least one exact unsigned opcode flag consequence and one exact unsigned semantic target consequence.

## Proof Obligations

- Every lifted theorem must remain indexed by the same `stepComposition.decodedRow` owned by the authenticated trace.
- No lifted theorem may weaken the unsigned opcode contract back to family-only closure.
- The exact semantic target remains `UnsignedDivRemSpec`; the trace layer only lifts the execution-level opcode facts through accepted trace evidence.
- Determinism must remain theorem-visible at the trace layer.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/UnsignedDivRemOpcodeSemantics.lean` | Authenticated-trace unsigned DIV/REM opcode lifts |
| `Nightstream/Rv64IM/Trace/UnsignedDivRemOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

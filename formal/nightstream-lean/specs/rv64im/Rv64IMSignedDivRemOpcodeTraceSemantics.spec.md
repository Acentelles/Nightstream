# Rv64IMSignedDivRemOpcodeTraceSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner that lifts exact signed DIV/REM opcode consequences through the authenticated RV64IM trace boundary.
- **What it is not**: It is not the execution-level signed opcode owner and it does not replace `Rv64IMAuthenticatedTrace` or `Rv64IMExactTraceBoundaries`.
- **Protocol role**: It makes exact `DIV` / `REM` / `DIVW` / `REMW` consequences available directly from accepted trace evidence.

## Inputs

The module ranges over:

- one `AuthenticatedChunkTrace`, or
- one `ExactTraceBoundaries`.

It therefore inherits the same exact `StepComposition`, authenticated active-prefix trace, and exact signed opcode semantics for the same RV64IM execution object.

## Required Theorem Surface

The module must expose authenticated-trace lifts for:

- exact signed opcode bound,
- exact `DIV` flag consequence,
- exact `REM` flag consequence,
- exact `DIVW` flag consequence,
- exact `REMW` flag consequence,
- exact signed DIV semantic target,
- exact signed REM semantic target.

It must also expose exact-boundary lifts for at least one exact signed opcode flag consequence and one exact signed semantic target consequence.

## Proof Obligations

- Every lifted theorem must remain indexed by the same `stepComposition.decodedRow` owned by the authenticated trace.
- No lifted theorem may weaken the signed opcode contract back to family-only closure.
- The exact semantic target remains `SignedDivRemSpec`; the trace layer only lifts the execution-level opcode facts through accepted trace evidence.
- The trace layer must preserve the signed execution-level connection to `ChangeDivisorCorrect` and dividend-sign remainder reconstruction indirectly through the execution-level opcode owner it depends on.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/SignedDivRemOpcodeSemantics.lean` | Authenticated-trace signed DIV/REM opcode lifts |
| `Nightstream/Rv64IM/Trace/SignedDivRemOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

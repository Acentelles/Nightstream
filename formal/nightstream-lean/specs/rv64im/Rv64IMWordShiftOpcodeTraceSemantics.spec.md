# Rv64IMWordShiftOpcodeTraceSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner that lifts exact word-shift opcode
  consequences through the authenticated RV64IM trace boundary.
- **What it is not**: It is not the execution-level word-shift opcode owner and
  it does not replace `Rv64IMAuthenticatedTrace` or `Rv64IMExactTraceBoundaries`.
- **Protocol role**: It makes exact word-shift opcode consequences available
  directly from accepted trace evidence.

## Inputs

The module ranges over:

- one `AuthenticatedChunkTrace`, or
- one `ExactTraceBoundaries`.

It therefore inherits the same exact `StepComposition`, authenticated
active-prefix trace, and exact word-shift opcode semantics for the same RV64IM
execution object.

## Required Theorem Surface

The module must expose authenticated-trace lifts for:

- the exact word-shift opcode bound,
- the generic exact word-shift opcode flags,
- exact `SRAW` flag consequences,
- exact `SRAIW` flag consequences,
- exact word-shift sequence correctness,
- exact word-shift sequence determinism.

It must also expose exact-boundary lifts for at least one corrected arithmetic
right-shift flag consequence and one preserved word-shift sequence theorem.

## Proof Obligations

- Every lifted theorem must remain indexed by the same `stepComposition.decodedRow`
  owned by the authenticated trace.
- No lifted theorem may weaken the word-shift opcode contract back to class-only
  or family-only closure.
- The corrected `SRAW` / `SRAIW` consequences must remain tied to the exact
  word-shift opcode carried by the authenticated trace, not to a consumer-side
  guess.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/WordShiftOpcodeSemantics.lean` | Authenticated-trace word-shift opcode lifts |
| `Nightstream/Rv64IM/Trace/WordShiftOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

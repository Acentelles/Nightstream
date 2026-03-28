# Rv64IMControlFlowOpcodeTraceSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner that lifts exact control-flow opcode consequences through the authenticated RV64IM trace boundary.
- **What it is not**: It is not the execution-level owner for control-flow opcodes and it does not replace `Rv64IMAuthenticatedTrace` or `Rv64IMExactTraceBoundaries`.
- **Protocol role**: It makes exact `JAL` / `JALR` / taken-branch consequences available directly from accepted trace evidence.

## Inputs

The module ranges over:

- one `AuthenticatedChunkTrace`, or
- one `ExactTraceBoundaries`.

It therefore inherits the exact stage composition, authenticated active-prefix trace, and exact opcode-family semantics for the same RV64IM execution object.

## Required Theorem Surface

The module must expose authenticated-trace lifts for:

- exact `JAL` lane consequence,
- exact `JALR` lane consequence,
- exact taken-branch lane consequence,
- exact decoded `branchOp` consequence,
- exact `JAL` target alignment,
- exact `JALR` target alignment,
- exact taken-branch mux consequence,
- exact taken-branch target alignment.

It must also expose at least one exact-boundary lift for the same opcode facts so downstream trace consumers do not need to manually reconstruct `AuthenticatedChunkTrace`.

## Proof Obligations

- Every lifted theorem must range over the same `stepComposition.decodedRow` owned by the authenticated trace.
- No lifted theorem may weaken the control-flow opcode contract back to class-only closure.
- The lifted target-alignment consequences must remain tied to the exact Stage-1 lane carried by the authenticated trace.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/ControlFlowOpcodeSemantics.lean` | Authenticated-trace control-flow opcode lifts |
| `Nightstream/Rv64IM/Trace/ControlFlowOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

# Rv64IMMultiplyOpcodeTraceSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner that lifts exact multiply opcode consequences through the authenticated RV64IM trace boundary.
- **What it is not**: It is not the execution-level multiply opcode owner and it does not replace `Rv64IMAuthenticatedTrace` or `Rv64IMExactTraceBoundaries`.
- **Protocol role**: It makes exact multiply decoded-row consequences available directly from accepted trace evidence.

## Inputs

The module ranges over:

- one `AuthenticatedChunkTrace`, or
- one `ExactTraceBoundaries`.

It therefore inherits the exact stage composition, authenticated active-prefix trace, and exact multiply opcode semantics for the same RV64IM execution object.

## Required Theorem Surface

The module must expose authenticated-trace lifts for:

- exact multiply decoded-row opcode binding,
- exact multiply decoded-row flag consequences,
- exact multiply `rd = x0` sink/write-suppression consequences,
- exact routed writeback equalities `rdNext = aluWritebackValue` and
  `wvReg = aluWritebackValue` when `rd ≠ x0`,
- exact encoded Stage-1 result equalities
  `wordToLimbPair(executionRow.lane.aluOut) = aluWritebackValue`,
  `wordToLimbPair(executionRow.results.aluResult) = aluWritebackValue`,
  `wvReg = wordToLimbPair(executionRow.lane.aluOut)`, and
  `wvReg = wordToLimbPair(executionRow.results.aluResult)` under the same
  active-write hypotheses,
- preserved committed-sequence correctness,
- preserved committed-sequence determinism.

It must also expose exact-boundary lifts for the same decoded-row flag
consequences, the `rd = x0` sink rule, and the same routed writeback and
encoded Stage-1 result equalities.

## Proof Obligations

- Every lifted theorem must range over the same `stepComposition.decodedRow` owned by the authenticated trace.
- No lifted theorem may weaken the multiply opcode contract back to family-only or class-only closure.
- The lifted `MULW` consequence must remain tied to the exact `isWOp = true` decoded-row fact.
- The lifted write-suppression theorem must preserve the kernel-spec `x0` sink
  convention instead of treating multiply writes as opcode-only facts.
- The routed writeback lifts must preserve the exact limb-level multiply result
  chosen by `Rv64IMStepComposition`, not only the weaker `wvReg = rdNext`
  equality.
- The lifted trace surface must keep the Stage-1 multiply `ALU_OUT` /
  `aluResult` representation theorem visible, not only the routed writeback
  equalities.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/MultiplyOpcodeSemantics.lean` | Authenticated-trace multiply opcode lifts |
| `Nightstream/Rv64IM/Trace/MultiplyOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

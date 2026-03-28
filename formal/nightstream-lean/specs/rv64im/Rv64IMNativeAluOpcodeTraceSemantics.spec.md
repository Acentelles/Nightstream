# Rv64IMNativeAluOpcodeTraceSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner that lifts exact native-ALU opcode consequences through the authenticated RV64IM trace boundary.
- **What it is not**: It is not the execution-level native-ALU opcode owner and it does not replace `Rv64IMAuthenticatedTrace` or `Rv64IMExactTraceBoundaries`.
- **Protocol role**: It makes exact native-ALU decoded-row and `ECALL` termination consequences available directly from accepted trace evidence.

## Inputs

The module ranges over:

- one `AuthenticatedChunkTrace`, or
- one `ExactTraceBoundaries`.

It therefore inherits the exact stage composition, authenticated active-prefix trace, and exact native-ALU opcode semantics for the same RV64IM execution object.

## Required Theorem Surface

The module must expose authenticated-trace lifts for:

- exact native-ALU decoded-row opcode binding,
- exact native-ALU decoded-row flag consequences,
- exact native-ALU `rd = x0` sink/write-suppression consequences,
- exact routed writeback equalities `rdNext = aluWritebackValue` and
  `wvReg = aluWritebackValue` when the opcode writes an architectural
  destination and `rd ≠ x0`,
- exact encoded Stage-1 result equalities
  `wordToLimbPair(executionRow.lane.aluOut) = aluWritebackValue`,
  `wordToLimbPair(executionRow.results.aluResult) = aluWritebackValue`,
  `wvReg = wordToLimbPair(executionRow.lane.aluOut)`, and
  `wvReg = wordToLimbPair(executionRow.results.aluResult)` under the same
  active-write hypotheses,
- exact `ECALL` terminating-row consequence,
- preserved committed-sequence correctness,
- preserved committed-sequence determinism.

It must also expose exact-boundary lifts for the exact decoded-row flag
consequences, the `rd = x0` sink rule, the same routed writeback and encoded
Stage-1 result equalities, and `ECALL` termination.

## Proof Obligations

- Every lifted theorem must range over the same `stepComposition.decodedRow` owned by the authenticated trace.
- No lifted theorem may weaken the native-ALU opcode contract back to family-only or class-only closure.
- The lifted `ECALL` termination consequence must remain tied to the exact native opcode carried by the authenticated trace.
- The lifted `rd = x0` theorem must preserve the kernel-spec sink convention
  rather than reintroducing opcode-only write assumptions.
- The routed writeback lifts must preserve the same limb-level
  `aluWritebackValue` owned by `Rv64IMStepComposition`; they may not collapse the
  theorem back to the weaker `wvReg = rdNext` surface alone.
- The lifted trace surface must keep the Stage-1 `ALU_OUT` / `aluResult`
  representation theorem visible, not hide it behind routing-only equalities.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/NativeAluOpcodeSemantics.lean` | Authenticated-trace native-ALU opcode lifts |
| `Nightstream/Rv64IM/Trace/NativeAluOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

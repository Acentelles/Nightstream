# Rv64IMNativeAluOpcodeKernelSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner that lifts exact native-ALU opcode consequences through RV64IM kernel soundness and exact kernel boundaries.
- **What it is not**: It is not the execution-level native-ALU opcode owner and it does not replace `Rv64IMKernelSoundness` or `Rv64IMExactKernelBoundaries`.
- **Protocol role**: It closes the path from accepted Nightstream kernel evidence to exact native-ALU decoded-row and `ECALL` termination facts.

## Inputs

The module ranges over:

- one `KernelSoundnessConclusion`, or
- one `ExactKernelBoundaries`.

It therefore inherits the authenticated trace, bridge/program/transcript closure, and exact native-ALU opcode semantics induced by the accepted kernel boundary.

## Required Theorem Surface

The module must expose kernel lifts for:

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

It must also expose exact-kernel-boundary lifts for the exact decoded-row flag
consequences, the `rd = x0` sink rule, the same routed writeback and encoded
Stage-1 result equalities, and `ECALL` termination.

## Proof Obligations

- Every lifted theorem must remain indexed by the kernel’s authenticated trace and same `decodedRow`.
- The exact-kernel-boundary lifts must be definitional consequences of the exact-boundary reduction, not restated assumptions.
- Theorems must preserve the native-ALU opcode consequences proved in the execution layer without re-owning them.
- The lifted theorem surface must preserve the same `rd = x0` sink rule
  required by `riscv-kernel.md`.
- The routed writeback lifts must keep the exact
  `authenticatedTrace.stepComposition.aluWritebackValue` visible at the kernel
  surface rather than weakening back to `wvReg = rdNext`.
- The kernel lift must preserve the Stage-1 `ALU_OUT` / `aluResult`
  representation theorem at the theorem-facing boundary instead of hiding it
  behind routing-only equalities.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/NativeAluOpcodeSemantics.lean` | Kernel-level native-ALU opcode lifts |
| `Nightstream/Rv64IM/Kernel/NativeAluOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

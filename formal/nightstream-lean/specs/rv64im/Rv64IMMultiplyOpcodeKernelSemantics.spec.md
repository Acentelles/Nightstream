# Rv64IMMultiplyOpcodeKernelSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner that lifts exact multiply opcode consequences through RV64IM kernel soundness and exact kernel boundaries.
- **What it is not**: It is not the execution-level multiply opcode owner and it does not replace `Rv64IMKernelSoundness` or `Rv64IMExactKernelBoundaries`.
- **Protocol role**: It closes the path from accepted Nightstream kernel evidence to exact multiply decoded-row facts.

## Inputs

The module ranges over:

- one `KernelSoundnessConclusion`, or
- one `ExactKernelBoundaries`.

It therefore inherits the authenticated trace, bridge/program/transcript closure, and exact multiply opcode semantics induced by the accepted kernel boundary.

## Required Theorem Surface

The module must expose kernel lifts for:

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

It must also expose exact-kernel-boundary lifts for the same decoded-row flag
consequences, the `rd = x0` sink rule, and the same routed writeback and
encoded Stage-1 result equalities.

## Proof Obligations

- Every lifted theorem must remain indexed by the kernel’s authenticated trace and same `decodedRow`.
- The exact-kernel-boundary lifts must be definitional consequences of the exact-boundary reduction, not restated assumptions.
- Theorems must preserve the multiply opcode consequences proved in the execution layer without re-owning them.
- The lifted theorem surface must stay consistent with the kernel-spec `x0`
  sink/write-suppression rule.
- The routed writeback lifts must keep the exact kernel-visible
  `aluWritebackValue` theorem-facing instead of weakening back to the coarser
  `wvReg = rdNext` statement alone.
- The kernel lift must keep the Stage-1 multiply `ALU_OUT` / `aluResult`
  representation theorem visible at the theorem-facing boundary.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/MultiplyOpcodeSemantics.lean` | Kernel-level multiply opcode lifts |
| `Nightstream/Rv64IM/Kernel/MultiplyOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

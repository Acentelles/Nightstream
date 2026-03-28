# Rv64IMWordShiftOpcodeKernelSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner that lifts exact word-shift opcode
  consequences through RV64IM kernel soundness and exact kernel boundaries.
- **What it is not**: It is not the execution-level word-shift opcode owner and
  it does not replace `Rv64IMKernelSoundness` or `Rv64IMExactKernelBoundaries`.
- **Protocol role**: It closes the path from accepted Nightstream kernel
  evidence to exact RV64IM word-shift opcode consequences.

## Inputs

The module ranges over:

- one `KernelSoundnessConclusion`, or
- one `ExactKernelBoundaries`.

It therefore inherits the authenticated trace, bridge/program/transcript
closure, and exact word-shift opcode semantics induced by the accepted kernel
boundary.

## Required Theorem Surface

The module must expose kernel lifts for:

- the exact word-shift opcode bound,
- the generic exact word-shift opcode flags,
- exact `SRAW` flag consequences,
- exact `SRAIW` flag consequences,
- exact word-shift sequence correctness,
- exact word-shift sequence determinism.

It must also expose exact-kernel-boundary lifts for at least one corrected
arithmetic-right-shift flag consequence and one preserved word-shift sequence
theorem.

## Proof Obligations

- Every lifted theorem must remain indexed by the kernel’s authenticated trace
  and same `decodedRow`.
- The exact-kernel-boundary lifts must be definitional consequences of the
  exact-boundary reduction, not restated assumptions.
- Theorems must preserve the word-shift opcode consequences proved in the
  execution layer without re-owning them.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/WordShiftOpcodeSemantics.lean` | Kernel-level word-shift opcode lifts |
| `Nightstream/Rv64IM/Kernel/WordShiftOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

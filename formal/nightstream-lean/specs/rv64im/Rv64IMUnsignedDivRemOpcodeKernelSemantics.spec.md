# Rv64IMUnsignedDivRemOpcodeKernelSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner that lifts exact unsigned DIV/REM opcode consequences through RV64IM kernel soundness and exact kernel boundaries.
- **What it is not**: It is not the execution-level unsigned opcode owner and it does not replace `Rv64IMKernelSoundness` or `Rv64IMExactKernelBoundaries`.
- **Protocol role**: It closes the path from accepted Nightstream kernel evidence to exact `DIVU` / `REMU` / `DIVUW` / `REMUW` consequences.

## Inputs

The module ranges over:

- one `KernelSoundnessConclusion`, or
- one `ExactKernelBoundaries`.

It therefore inherits the authenticated trace, bridge/program/transcript closure, and exact unsigned opcode semantics induced by the accepted kernel boundary.

## Required Theorem Surface

The module must expose kernel lifts for:

- exact unsigned opcode bound,
- exact `DIVU` flag consequence,
- exact `REMU` flag consequence,
- exact `DIVUW` flag consequence,
- exact `REMUW` flag consequence,
- exact unsigned DIV semantic target,
- exact unsigned REM semantic target,
- exact unsigned semantic determinism.

It must also expose exact-kernel-boundary lifts for at least one exact unsigned opcode flag consequence and one exact unsigned semantic target consequence.

## Proof Obligations

- Every lifted theorem must remain indexed by the kernel’s authenticated trace and same `decodedRow`.
- The exact-kernel-boundary lifts must be definitional consequences of the exact-boundary reduction, not restated assumptions.
- Theorems must preserve the unsigned opcode consequences proved in the execution layer without re-owning them.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/UnsignedDivRemOpcodeSemantics.lean` | Kernel-level unsigned DIV/REM opcode lifts |
| `Nightstream/Rv64IM/Kernel/UnsignedDivRemOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

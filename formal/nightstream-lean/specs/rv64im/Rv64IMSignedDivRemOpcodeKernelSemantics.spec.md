# Rv64IMSignedDivRemOpcodeKernelSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner that lifts exact signed DIV/REM opcode consequences through RV64IM kernel soundness and exact kernel boundaries.
- **What it is not**: It is not the execution-level signed opcode owner and it does not replace `Rv64IMKernelSoundness` or `Rv64IMExactKernelBoundaries`.
- **Protocol role**: It closes the path from accepted Nightstream kernel evidence to exact `DIV` / `REM` / `DIVW` / `REMW` consequences.

## Inputs

The module ranges over:

- one `KernelSoundnessConclusion`, or
- one `ExactKernelBoundaries`.

It therefore inherits the authenticated trace, bridge/program/transcript closure, and exact signed opcode semantics induced by the accepted kernel boundary.

## Required Theorem Surface

The module must expose kernel lifts for:

- exact signed opcode bound,
- exact `DIV` flag consequence,
- exact `REM` flag consequence,
- exact `DIVW` flag consequence,
- exact `REMW` flag consequence,
- exact signed DIV semantic target,
- exact signed REM semantic target.

It must also expose exact-kernel-boundary lifts for at least one exact signed opcode flag consequence and one exact signed semantic target consequence.

## Proof Obligations

- Every lifted theorem must remain indexed by the kernel’s authenticated trace and same `decodedRow`.
- The exact-kernel-boundary lifts must be definitional consequences of the exact-boundary reduction, not restated assumptions.
- Theorems must preserve the signed opcode consequences proved in the execution layer without re-owning them.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/SignedDivRemOpcodeSemantics.lean` | Kernel-level signed DIV/REM opcode lifts |
| `Nightstream/Rv64IM/Kernel/SignedDivRemOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

# Rv64IMControlFlowOpcodeKernelSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner that lifts exact control-flow opcode consequences through RV64IM kernel soundness and exact kernel boundaries.
- **What it is not**: It is not the execution-level control-flow opcode owner and it does not replace `Rv64IMKernelSoundness` or `Rv64IMExactKernelBoundaries`.
- **Protocol role**: It closes the path from accepted Nightstream kernel evidence to exact `JAL` / `JALR` target-alignment and lane facts.

## Inputs

The module ranges over:

- one `KernelSoundnessConclusion`, or
- one `ExactKernelBoundaries`.

It therefore inherits the authenticated trace, bridge/program/transcript closure, and the exact opcode-family semantics induced by the accepted kernel boundary.

## Required Theorem Surface

The module must expose kernel lifts for:

- exact `JAL` lane consequence,
- exact `JALR` lane consequence,
- exact `JAL` target alignment,
- exact `JALR` target alignment.

It must also expose exact-kernel-boundary lifts for the same consequences.

## Proof Obligations

- Every lifted theorem must remain indexed by the kernel’s authenticated trace and same `decodedRow`.
- The exact-kernel-boundary lifts must be definitional consequences of the exact-boundary reduction, not restated assumptions.
- Theorems must preserve the control-flow opcode consequences proved in the execution layer without re-owning them.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/ControlFlowOpcodeSemantics.lean` | Kernel-level control-flow opcode lifts |
| `Nightstream/Rv64IM/Kernel/ControlFlowOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

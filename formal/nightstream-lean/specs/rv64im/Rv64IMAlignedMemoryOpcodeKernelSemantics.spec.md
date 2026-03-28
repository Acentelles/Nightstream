# Rv64IMAlignedMemoryOpcodeKernelSemantics Spec

## Purpose

- **What it is**: The kernel-level lifting owner for the canonical exact native aligned-memory opcode bundle.
- **What it is not**: It is not the execution-level owner of `LD` / `SD` load/store consequences and it does not replace the main kernel soundness theorem.
- **Protocol role**: It recovers the canonical exact aligned-memory opcode bundle from the final RV64IM kernel conclusion or from exact kernel boundaries.

## Required Constructors

The module must expose:

- `exactAlignedMemoryOpcodeSemantics_of_kernelSoundness`
- `exactAlignedMemoryOpcodeSemantics_of_exactKernelBoundaries`

so consumers can move directly from kernel soundness or exact kernel boundaries to the same canonical `LD` / `SD` opcode bundle.

## Proof Obligations

- The lifted bundle must range over the same authenticated trace carried by the kernel conclusion.
- The exact-kernel-boundary constructor must factor only through `kernelSoundness_of_exactBoundaries`.
- The lifted bundle must preserve decoded-row / RAM-role agreement, `rd = x0` sink preservation, authenticated raw load-word equalities, authenticated load-writeback equalities, and authenticated store-payload equalities.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/AlignedMemoryOpcodeSemantics.lean` | Kernel-level lifting of the exact aligned-memory opcode bundle |
| `Nightstream/Rv64IM/Kernel/AlignedMemoryOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

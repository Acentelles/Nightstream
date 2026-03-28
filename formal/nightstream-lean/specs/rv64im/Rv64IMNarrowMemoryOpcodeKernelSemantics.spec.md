# Rv64IMNarrowMemoryOpcodeKernelSemantics Spec

## Purpose

- **What it is**: The kernel-level lift of exact narrow-memory opcode consequences.
- **What it is not**: It is not the execution opcode owner and not the general kernel soundness theorem itself.
- **Protocol role**: It lifts exact narrow-memory opcode contracts through `KernelSoundnessConclusion` and `ExactKernelBoundaries`.

## Required Theorem Surface

The module must expose:

- `flags_of_kernelSoundness_narrowMemory`
- `x0WritePreserved_of_kernelSoundness_narrowMemory`
- `sequenceCorrect_of_narrowMemory_of_kernelSoundness`
- `flags_of_exactKernelBoundaries_narrowMemory`
- `x0WritePreserved_of_exactKernelBoundaries_narrowMemory`

## Proof Obligations

- The kernel owner must preserve the exact decoded-row opcode contract from the execution owner.
- The kernel owner must preserve the exact narrow-memory committed-sequence correctness theorem from the authenticated trace.
- The exact-boundary constructor path must reduce through `kernelSoundness_of_exactBoundaries`.
- The kernel owner must preserve the kernel-spec `x0` sink/write-suppression rule.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/NarrowMemoryOpcodeSemantics.lean` | Kernel lift of narrow-memory opcode semantics |
| `Nightstream/Rv64IM/Kernel/NarrowMemoryOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

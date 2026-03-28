# Rv64IMOpcodeFamilyKernelSemantics Spec

## Purpose

- **What it is**: The kernel-level lifting owner for exact opcode-family semantic bundles.
- **What it is not**: It is not the execution-level owner of those facts and it does not replace the main kernel soundness theorem.
- **Protocol role**: It recovers one exact opcode-family semantic bundle from the final RV64IM kernel conclusion or from exact kernel boundaries.

## Required Constructors

The module must expose:

- `exactOpcodeFamilySemantics_of_kernelSoundness`
- `exactOpcodeFamilySemantics_of_exactKernelBoundaries`

so consumers can move directly from the final kernel theorem surface to the richer family-level semantic closure.

## Proof Obligations

- The lifted bundle must range over the same authenticated trace carried by the kernel conclusion.
- The exact-kernel-boundary constructor must factor only through the canonical `kernelSoundness_of_exactBoundaries` path.
- The lifted bundle must preserve the same seven dedicated execution-level family bundles carried by `Rv64IMExactOpcodeFamilySemantics`.
- Kernel-level family semantics must still expose control-flow alignment, temporary-register hygiene, unsigned DIV/REM determinism, and signed divisor/remainder facts.
- The lifted family bundle must remain strong enough to recover the canonical
  exact native-ALU/multiply word-arithmetic bundle directly from kernel
  soundness or exact kernel boundaries.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/OpcodeFamilySemantics.lean` | Kernel-level lifting of exact opcode-family semantic bundles |
| `Nightstream/Rv64IM/Kernel/OpcodeFamilySemanticsInterface.lean` | Theorem-facing re-export surface |

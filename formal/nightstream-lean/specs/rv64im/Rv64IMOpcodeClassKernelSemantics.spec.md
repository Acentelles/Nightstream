# Rv64IMOpcodeClassKernelSemantics Spec

## Purpose

- **What it is**: The kernel-level owner that lifts exact opcode-class semantic bundles through the final RV64IM kernel conclusion and exact kernel boundaries.
- **What it is not**: It is not the top-level kernel soundness theorem owner itself.
- **Protocol role**: It gives downstream consumers a direct exact opcode-class semantic surface at the final kernel boundary.

## Required Constructors

The module must expose:

- `canonicalOpcodeClassSemantics_of_kernelSoundness`
- `canonicalOpcodeClassSemantics_of_exactKernelBoundaries`
- direct per-class extractors from kernel soundness and exact kernel boundaries for:
  - `nativeAlu`
  - `wordShift`
  - `controlFlow`
  - `narrowMemory`
  - `multiply`
  - `unsignedDivRem`
  - `signedDivRem`

Each constructor must recover the exact canonical opcode-class semantic bundle from:

- one `KernelSoundnessConclusion`, or
- one `ExactKernelBoundaries` instance.

## Proof Obligations

- Kernel-level lifting must preserve the same authenticated trace carried by the kernel conclusion.
- Exact-boundary lifting must recover the exact canonical semantic bundle, not a weaker existential package.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/OpcodeClassSemantics.lean` | Kernel-level lifting of exact opcode-class semantic bundles |
| `Nightstream/Rv64IM/Kernel/OpcodeClassSemanticsInterface.lean` | Theorem-facing re-export surface |

# Rv64IMNarrowMemoryHelperResultKernelSemantics Spec

## Purpose

- **What it is**: The kernel-level owner that lifts exact narrow-memory
  helper-result consequences through RV64IM kernel soundness and exact
  kernel-boundary acceptance.
- **What it is not**: It is not the execution-level or trace-level owner of
  those helper-result formulas.
- **Protocol role**: It exposes the exact helper-result formulas directly from
  `KernelSoundnessConclusion` and `ExactKernelBoundaries`.

## Required Surface

- `exactNarrowMemoryHelperResultSemantics_of_kernelSoundness`
- `loadExtractHelperResult_of_kernelSoundness_narrowMemory`
- `storeBlendHelperResult_of_kernelSoundness_narrowMemory`
- `exactNarrowMemoryHelperResultSemantics_of_exactKernelBoundaries`
- `loadExtractHelperResult_of_exactKernelBoundaries_narrowMemory`
- `storeBlendHelperResult_of_exactKernelBoundaries_narrowMemory`

## Proof Obligations

- The kernel-facing surface must preserve the exact helper-result formulas
  without forcing downstream consumers back through lower execution owners.
- The exact-kernel-boundary entrypoint must recover the same formulas directly.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/NarrowMemoryHelperResultSemantics.lean` | Kernel lift for exact narrow-memory helper-result theorems |
| `Nightstream/Rv64IM/Kernel/NarrowMemoryHelperResultSemanticsInterface.lean` | Theorem-facing re-export surface |

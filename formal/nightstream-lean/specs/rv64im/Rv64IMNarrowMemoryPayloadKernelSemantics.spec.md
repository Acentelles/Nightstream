# Rv64IMNarrowMemoryPayloadKernelSemantics Spec

## Purpose

- **What it is**: The kernel-level lifting owner for the canonical exact
  narrow-memory RAM-side payload bundle.
- **What it is not**: It is not the execution-level owner of those load/store
  consequences and it does not replace the main kernel soundness theorem.
- **Protocol role**: It recovers the canonical exact narrow-memory payload
  bundle from the final RV64IM kernel conclusion or from exact kernel
  boundaries.

## Required Constructors

The module must expose:

- `exactNarrowMemoryPayloadSemantics_of_kernelSoundness`
- `exactNarrowMemoryPayloadSemantics_of_exactKernelBoundaries`

so consumers can move directly from kernel soundness or exact kernel boundaries
to the same canonical narrow-memory payload bundle.

## Proof Obligations

- The lifted bundle must range over the same authenticated trace carried by the
  kernel conclusion.
- The exact-kernel-boundary constructor must factor only through
  `kernelSoundness_of_exactBoundaries`.
- The lifted bundle must preserve aligned-address decomposition, raw load-word,
  inactive helper-row, store-payload, and memory-writeback consequences.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/NarrowMemoryPayloadSemantics.lean` | Kernel-level lifting of the canonical exact narrow-memory payload bundle |
| `Nightstream/Rv64IM/Kernel/NarrowMemoryPayloadSemanticsInterface.lean` | Theorem-facing re-export surface |

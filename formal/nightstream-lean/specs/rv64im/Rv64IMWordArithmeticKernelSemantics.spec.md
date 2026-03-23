# Rv64IMWordArithmeticKernelSemantics Spec

## Purpose

- **What it is**: The kernel-level lifting owner for the canonical exact
  native-ALU/word-shift/multiply word-arithmetic bundle.
- **What it is not**: It is not the execution-level owner of those arithmetic
  equalities and it does not replace the main kernel soundness theorem.
- **Protocol role**: It recovers the canonical exact word-arithmetic bundle
  from the final RV64IM kernel conclusion or from exact kernel boundaries.

## Required Constructors

The module must expose:

- `exactWordArithmeticSemantics_of_kernelSoundness`
- `exactWordArithmeticSemantics_of_exactKernelBoundaries`

so consumers can move directly from kernel soundness or exact kernel boundaries
to the same canonical exact word-arithmetic bundle.

## Proof Obligations

- The lifted bundle must range over the same authenticated trace carried by the
  kernel conclusion.
- The exact-kernel-boundary constructor must factor only through
  `kernelSoundness_of_exactBoundaries`.
- The lifted bundle must preserve both families of word-level consequences:
  exact Stage-1 `aluResult` equalities and authenticated non-`x0` writeback
  equalities.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/WordArithmeticSemantics.lean` | Kernel-level lifting of the canonical exact word-arithmetic bundle |
| `Nightstream/Rv64IM/Kernel/WordArithmeticSemanticsInterface.lean` | Theorem-facing re-export surface |

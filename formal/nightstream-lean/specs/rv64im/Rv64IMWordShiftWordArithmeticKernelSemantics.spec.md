# Rv64IMWordShiftWordArithmeticKernelSemantics Spec

## Purpose

- **What it is**: The kernel-level lifting owner for exact word/shift
  word-arithmetic theorems.
- **What it is not**: It is not the execution-level owner of those equalities,
  and it does not replace the main kernel soundness theorem.
- **Protocol role**: It lifts exact word/shift `aluResult` and authenticated
  non-`x0` writeback equalities through kernel soundness and exact kernel
  boundaries.

## Required Constructors

The module must expose:

- `wordArithmetic_of_kernelSoundness_wordShift`
- `authenticatedWordArithmetic_of_kernelSoundness_wordShift`
- `wordArithmetic_of_exactKernelBoundaries_wordShift`
- `authenticatedWordArithmetic_of_exactKernelBoundaries_wordShift`

## Proof Obligations

- The lifted theorems must range over the same authenticated trace carried by
  the kernel conclusion.
- The exact-kernel-boundary theorems must factor only through
  `kernelSoundness_of_exactBoundaries`.
- The corrected `SRAW` / `SRAIW` word-result equalities must remain
  theorem-facing at the kernel surface.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/WordShiftWordArithmetic.lean` | Kernel-level lifting of exact word/shift word arithmetic |
| `Nightstream/Rv64IM/Kernel/WordShiftWordArithmeticInterface.lean` | Theorem-facing re-export surface |

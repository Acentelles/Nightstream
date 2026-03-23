# Rv64IMWordShiftWordArithmeticTraceSemantics Spec

## Purpose

- **What it is**: The trace-level lifting owner for exact word/shift
  word-arithmetic theorems.
- **What it is not**: It is not the execution-level owner of those equalities,
  and it does not own kernel lifting.
- **Protocol role**: It lifts exact word/shift `aluResult` and authenticated
  non-`x0` writeback equalities through authenticated chunk traces and exact
  trace boundaries.

## Required Constructors

The module must expose:

- `wordArithmetic_of_authenticatedChunkTrace_wordShift`
- `authenticatedWordArithmetic_of_authenticatedChunkTrace_wordShift`
- `wordArithmetic_of_exactBoundaries_wordShift`
- `authenticatedWordArithmetic_of_exactBoundaries_wordShift`

## Proof Obligations

- The lifted theorems must range over the same `stepComposition` object carried
  by the authenticated trace.
- The exact-boundary theorems must factor only through
  `authenticatedChunkTrace_of_exactBoundaries`.
- The corrected `SRAW` / `SRAIW` word-result equalities must remain theorem-facing.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/WordShiftWordArithmetic.lean` | Trace-level lifting of exact word/shift word arithmetic |
| `Nightstream/Rv64IM/Trace/WordShiftWordArithmeticInterface.lean` | Theorem-facing re-export surface |

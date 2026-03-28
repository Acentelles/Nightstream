# Rv64IMWordArithmeticTraceSemantics Spec

## Purpose

- **What it is**: The trace-level lifting owner for the canonical exact
  native-ALU/word-shift/multiply word-arithmetic bundle.
- **What it is not**: It is not the execution-level owner of those arithmetic
  equalities and it does not own kernel lifting.
- **Protocol role**: It recovers the canonical exact word-arithmetic bundle
  from authenticated chunk traces and exact trace boundaries.

## Required Constructors

The module must expose:

- `exactWordArithmeticSemantics_of_authenticatedChunkTrace`
- `exactWordArithmeticSemantics_of_exactBoundaries`

so consumers can move from either authenticated trace evidence or exact
trace-boundary packages to the same canonical exact word-arithmetic bundle.

## Proof Obligations

- The lifted bundle must range over the same `stepComposition` object carried by
  the authenticated trace.
- The exact-boundary constructor must factor only through
  `authenticatedChunkTrace_of_exactBoundaries`.
- The lifted bundle must preserve both families of word-level consequences:
  exact Stage-1 `aluResult` equalities and authenticated non-`x0` writeback
  equalities.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/WordArithmeticSemantics.lean` | Trace-level lifting of the canonical exact word-arithmetic bundle |
| `Nightstream/Rv64IM/Trace/WordArithmeticSemanticsInterface.lean` | Theorem-facing re-export surface |

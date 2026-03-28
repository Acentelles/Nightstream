# Rv64IMMultiplyEncodedArithmeticTraceSemantics Spec

## Purpose

Lift the exact multiply encoded arithmetic equalities from the execution layer
to the authenticated trace and exact trace-boundary surfaces.

## Mathematical Target

For every accepted RV64IM authenticated chunk trace and every multiply opcode:

- the encoded Stage-1 `aluResult` is equal to the theorem-facing
  `MultiplyEncodedResult` computed from:
  - the authenticated register operands,
  - the exact multiply opcode,
- and, whenever `rd ≠ x0`, the authenticated register write value `wvReg` is
  equal to the same `MultiplyEncodedResult`.

The exact-boundary constructor path must imply the same statements.

## Ownership Boundary

This module owns only the trace-level lift. It does not own execution-level
multiply arithmetic or kernel soundness.

## Required Inputs

- authenticated chunk trace
- exact multiply family semantics
- exact multiply encoded arithmetic owner
- exact trace-boundary constructor

## Required Outputs

- trace theorem for encoded Stage-1 multiply result equality
- trace theorem for authenticated multiply writeback equality
- exact-boundary corollaries for both

## Files

| File | Role |
|---|---|
| `Nightstream/Rv64IM/Trace/MultiplyEncodedArithmetic.lean` | Trace owner |
| `Nightstream/Rv64IM/Trace/MultiplyEncodedArithmeticInterface.lean` | Theorem-facing re-export surface |

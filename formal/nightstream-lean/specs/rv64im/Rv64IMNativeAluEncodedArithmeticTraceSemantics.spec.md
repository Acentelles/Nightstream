# Rv64IMNativeAluEncodedArithmeticTraceSemantics Spec

## Purpose

Lift the exact native-ALU encoded arithmetic equalities from the execution layer
to the authenticated trace and exact trace-boundary surfaces.

## Mathematical Target

For every accepted RV64IM authenticated chunk trace and every native-ALU opcode:

- the encoded Stage-1 `aluResult` is equal to the theorem-facing
  `NativeAluEncodedResult` computed from:
  - the authenticated register operands,
  - the encoded immediate,
  - the encoded PC lane,
  - the exact native-ALU opcode,
- and, whenever the opcode writes architectural `rd` and `rd ≠ x0`, the
  authenticated register write value `wvReg` is equal to the same
  `NativeAluEncodedResult`.

The exact-boundary constructor path must imply the same statements.

## Ownership Boundary

This module owns only the trace-level lift. It does not own Stage-1 row
semantics, Stage-2 Twist binding, execution-level encoded arithmetic, or kernel
soundness.

## Required Inputs

- authenticated chunk trace
- exact native-ALU family semantics
- exact native-ALU encoded arithmetic owner
- exact trace-boundary constructor

## Required Outputs

- trace theorem for encoded Stage-1 native-ALU result equality
- trace theorem for authenticated native-ALU writeback equality
- exact-boundary corollaries for both

## Files

| File | Role |
|---|---|
| `Nightstream/Rv64IM/Trace/NativeAluEncodedArithmetic.lean` | Trace owner |
| `Nightstream/Rv64IM/Trace/NativeAluEncodedArithmeticInterface.lean` | Theorem-facing re-export surface |

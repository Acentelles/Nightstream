# Rv64IMNativeAluEncodedArithmeticKernelSemantics Spec

## Purpose

Lift the exact native-ALU encoded arithmetic equalities from the authenticated
trace surface to the RV64IM kernel soundness and exact kernel-boundary
surfaces.

## Mathematical Target

For every accepted RV64IM kernel soundness conclusion and every native-ALU
opcode:

- the encoded Stage-1 `aluResult` equals the theorem-facing
  `NativeAluEncodedResult`,
- and, whenever the opcode writes architectural `rd` and `rd ≠ x0`, the
  authenticated register write value `wvReg` equals the same
  `NativeAluEncodedResult`.

The exact-kernel-boundary constructor path must imply the same statements.

## Ownership Boundary

This module owns only the kernel-level lift. It does not own execution-level
encoded arithmetic or authenticated trace closure.

## Required Inputs

- kernel soundness conclusion
- exact native-ALU encoded arithmetic trace owner
- exact kernel-boundary constructor

## Required Outputs

- kernel theorem for encoded Stage-1 native-ALU result equality
- kernel theorem for authenticated native-ALU writeback equality
- exact-kernel-boundary corollaries for both

## Files

| File | Role |
|---|---|
| `Nightstream/Rv64IM/Kernel/NativeAluEncodedArithmetic.lean` | Kernel owner |
| `Nightstream/Rv64IM/Kernel/NativeAluEncodedArithmeticInterface.lean` | Theorem-facing re-export surface |

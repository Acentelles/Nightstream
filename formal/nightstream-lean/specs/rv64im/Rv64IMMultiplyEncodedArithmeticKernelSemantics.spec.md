# Rv64IMMultiplyEncodedArithmeticKernelSemantics Spec

## Purpose

Lift the exact multiply encoded arithmetic equalities from the authenticated
trace surface to the RV64IM kernel soundness and exact kernel-boundary
surfaces.

## Mathematical Target

For every accepted RV64IM kernel soundness conclusion and every multiply
opcode:

- the encoded Stage-1 `aluResult` equals the theorem-facing
  `MultiplyEncodedResult`,
- and, whenever `rd ≠ x0`, the authenticated register write value `wvReg`
  equals the same `MultiplyEncodedResult`.

The exact-kernel-boundary constructor path must imply the same statements.

## Ownership Boundary

This module owns only the kernel-level lift. It does not own execution-level
multiply arithmetic or authenticated trace closure.

## Required Inputs

- kernel soundness conclusion
- exact multiply encoded arithmetic trace owner
- exact kernel-boundary constructor

## Required Outputs

- kernel theorem for encoded Stage-1 multiply result equality
- kernel theorem for authenticated multiply writeback equality
- exact-kernel-boundary corollaries for both

## Files

| File | Role |
|---|---|
| `Nightstream/Rv64IM/Kernel/MultiplyEncodedArithmetic.lean` | Kernel owner |
| `Nightstream/Rv64IM/Kernel/MultiplyEncodedArithmeticInterface.lean` | Theorem-facing re-export surface |

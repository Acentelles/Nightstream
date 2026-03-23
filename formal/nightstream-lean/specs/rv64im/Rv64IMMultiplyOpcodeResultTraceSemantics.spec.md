# RV64IM Multiply Opcode Result Trace Semantics

## Purpose

This module owns the lift of exact multiply-opcode result facts from the
execution layer to the authenticated trace boundary.

## Theorem Surface

The module exposes trace-level theorems showing that, for any exact multiply
opcode with an active non-`x0` architectural write:

- the encoded Stage-1 `aluResult` equals the routed ALU writeback value,
- the authenticated register write value `wvReg` equals the encoded Stage-1
  `aluResult`,
- and the same conclusions are available from exact trace boundaries.

It also exposes the same encoded-result consequences as exact opcode-specialized
trace theorems for `MUL`, `MULH`, `MULHU`, `MULHSU`, and `MULW`.

## Non-Goals

This module does not re-own multiply decode classification, generic writeback
routing, or the missing arithmetic evaluator that determines the concrete
multiply result word from authenticated operands.

# RV64IM Multiply Opcode Result Kernel Semantics

## Purpose

This module owns the lift of exact multiply-opcode result facts from the
execution layer to RV64IM kernel soundness and exact kernel boundaries.

## Theorem Surface

The module exposes kernel-level theorems showing that, for any exact multiply
opcode with an active non-`x0` architectural write:

- the encoded Stage-1 `aluResult` equals the routed ALU writeback value at the
  authenticated kernel boundary,
- the authenticated register write value `wvReg` equals the encoded Stage-1
  `aluResult`,
- and the same consequences are derivable from exact kernel boundaries.

It also exposes the same encoded-result consequences as exact opcode-specialized
kernel theorems for `MUL`, `MULH`, `MULHU`, `MULHSU`, and `MULW`.

## Non-Goals

This module does not re-own trace construction, Nightstream bridge binding, or
opcode-specific arithmetic evaluation of the multiply result word.

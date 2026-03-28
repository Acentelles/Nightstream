# Rv64IM Native ALU Word Arithmetic Trace Semantics

## Purpose

This module owns the trace-level lifting of exact native-ALU word arithmetic.
It exposes those facts from authenticated chunk traces and from exact trace
boundaries.

## Required facts

From an authenticated chunk trace, and uniformly from exact trace boundaries:

- if the decoded native-ALU opcode is `opcode`, then the exact Stage-1
  `aluResult` word equals the opcode-specialized `NativeAluWordResult`
- if `opcode` writes the architectural destination register and `rd ≠ x0`, then
  the authenticated register writeback word equals the same
  opcode-specialized `NativeAluWordResult`

## Ownership boundary

- This module lifts execution-level word arithmetic to the authenticated trace
  boundary.
- It does not own new execution arithmetic lemmas.
- It does not own kernel-level lifting.

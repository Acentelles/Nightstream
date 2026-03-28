# Rv64IM Multiply Word Arithmetic Trace Semantics

## Purpose

This module owns the trace-level lifting of exact multiply word arithmetic. It
exposes those facts from authenticated chunk traces and from exact trace
boundaries.

## Required facts

From an authenticated chunk trace, and uniformly from exact trace boundaries:

- if the decoded multiply opcode is `opcode`, then the exact Stage-1
  `aluResult` word equals the opcode-specialized `MultiplyWordResult`
- if `rd ≠ x0`, the authenticated register writeback word equals the same
  opcode-specialized `MultiplyWordResult`

## Ownership boundary

- This module lifts execution-level word arithmetic to the authenticated trace
  boundary.
- It does not own new execution arithmetic lemmas.
- It does not own kernel-level lifting.

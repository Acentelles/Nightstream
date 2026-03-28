# Rv64IM Multiply Word Arithmetic Kernel Semantics

## Purpose

This module owns the kernel-level lifting of exact multiply word arithmetic. It
exposes those facts from `KernelSoundnessConclusion` and from exact kernel
boundaries.

## Required facts

From kernel soundness, and uniformly from exact kernel boundaries:

- if the decoded multiply opcode is `opcode`, then the exact Stage-1
  `aluResult` word equals the opcode-specialized `MultiplyWordResult`
- if `rd ≠ x0`, the authenticated register writeback word equals the same
  opcode-specialized `MultiplyWordResult`

## Ownership boundary

- This module lifts authenticated trace word arithmetic to the kernel boundary.
- It does not own new execution arithmetic lemmas.
- It does not own new trace arithmetic lemmas.

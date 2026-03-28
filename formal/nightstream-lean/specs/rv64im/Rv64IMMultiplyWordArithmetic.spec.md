# Rv64IM Multiply Word Arithmetic

## Purpose

This module owns the exact word-level arithmetic consequences for the RV64IM
multiply opcode family. It turns the authenticated encoded multiply surface and
the explicit word/limb representation bridge into exact Stage-1 word equalities
and exact authenticated word-level writeback equalities.

## Inputs

- the exact multiply family facts exported by `ExactOpcodeFamilySemantics`
- the representation bridge exported by `StepComposition`
  - `wordToLimbPair`
  - `limbPairToWord`
  - word/limb round-trip equalities
  - multiply word/encoded compatibility bounds

## Required facts

For each multiply opcode `MUL`, `MULH`, `MULHU`, `MULHSU`, and `MULW`:

- the exact Stage-1 `aluResult` word equals the opcode-specialized
  `MultiplyWordResult`
- if `rd ≠ x0`, the authenticated register writeback word equals the same
  opcode-specialized `MultiplyWordResult`

## Non-goals

- This module does not own trace lifting.
- This module does not own kernel lifting.
- This module does not introduce a multiply-specific arithmetic evaluator that
  bypasses the explicit Stage-1 result and representation bridge.

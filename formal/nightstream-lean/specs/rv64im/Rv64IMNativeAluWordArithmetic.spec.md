# Rv64IM Native ALU Word Arithmetic

## Purpose

This module owns the exact word-level arithmetic consequences for the RV64IM
native-ALU opcode family. It is the execution-level owner that turns the
authenticated encoded arithmetic surface and the explicit word/limb
representation bridge into exact Stage-1 word equalities.

## Inputs

- the exact native-ALU family facts exported by `ExactOpcodeFamilySemantics`
- the representation bridge exported by `StepComposition`
  - `wordToLimbPair`
  - `limbPairToWord`
  - word/limb round-trip equalities
  - native-ALU word/encoded compatibility bounds

## Required facts

For each native-ALU opcode:

- `ADD`, `ADDI`, `SUB`, `AND`, `ANDI`, `OR`, `ORI`, `XOR`, `XORI`,
  `SLT`, `SLTI`, `SLTU`, `SLTIU`, `LUI`, and `AUIPC`:
  - the exact Stage-1 `aluResult` word equals the opcode-specialized
    `NativeAluWordResult`
  - if `rd ≠ x0`, the authenticated register writeback word equals the same
    opcode-specialized `NativeAluWordResult`
- `FENCE` and `ECALL`:
  - the exact Stage-1 `aluResult` word equals the opcode-specialized
    `NativeAluWordResult`
  - no authenticated writeback theorem is claimed, because those opcodes do not
    write the architectural destination register

## Non-goals

- This module does not own trace lifting.
- This module does not own kernel lifting.
- This module does not own a new arithmetic evaluator separate from the
  Stage-1 result and the explicit word/limb bridge.

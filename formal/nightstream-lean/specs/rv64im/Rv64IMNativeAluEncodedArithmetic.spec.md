# Rv64IMNativeAluEncodedArithmetic Spec

## Purpose

- **What it is**: The exact theorem-facing owner for opcode-specialized encoded arithmetic consequences in the RV64IM native-ALU family.
- **What it is not**: It is not the generic native-ALU opcode owner, and it is not a concrete word-level evaluator for RV64 arithmetic.
- **Protocol role**: It sits above `Rv64IMNativeAluOpcodeSemantics` and `Rv64IMStepComposition`, and it binds the encoded Stage-1 `aluResult` to theorem-facing encoded operations on authenticated operands, immediates, and `pc`.

## Central Objects

- `NativeAluEncodedOps(Limb)` fixes the theorem-facing encoded arithmetic operators.
- `NativeAluEncodedResult(ops, wordToLimbPair, decodedRow, registerTwist, lane, opcode)` is the exact encoded target for the given native-ALU opcode.
- `NativeAluEncodedResultBound(...)` asserts that the routed encoded ALU writeback equals that exact encoded target.

## Required Theorem Surface

The module must expose:

- one exact opcode-specialized theorem proving
  `wordToLimbPair(executionRow.results.aluResult) = NativeAluEncodedResult(...)`
  for each of:
  - `ADD`
  - `ADDI`
  - `SUB`
  - `AND`
  - `ANDI`
  - `OR`
  - `ORI`
  - `XOR`
  - `XORI`
  - `SLT`
  - `SLTI`
  - `SLTU`
  - `SLTIU`
  - `LUI`
  - `AUIPC`
  - `FENCE`
  - `ECALL`
- one exact opcode-specialized theorem proving
  `wvReg = NativeAluEncodedResult(...)`
  for each write-active native-ALU opcode under the active non-`x0` conditions.

## Proof Obligations

- The owner must reuse the exact routed encoded-result bridge from `Rv64IMStepComposition`; it may not treat `aluWritebackValue` as an unrelated witness.
- Immediate opcodes must use `wordToLimbPair(decodedRow.imm)`, not an unconstrained auxiliary operand.
- `AUIPC` must use the encoded authenticated row `pc` together with the encoded immediate.
- `FENCE` and `ECALL` must remain theorem-visible as zero-result opcodes at the encoded-result layer.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/NativeAluEncodedArithmetic.lean` | Exact native-ALU encoded arithmetic owner |
| `Nightstream/Rv64IM/Execution/NativeAluEncodedArithmeticInterface.lean` | Theorem-facing re-export surface |

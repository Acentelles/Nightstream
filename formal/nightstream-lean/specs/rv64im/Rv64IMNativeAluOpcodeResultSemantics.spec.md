# Rv64IMNativeAluOpcodeResultSemantics Spec

## Purpose

- **What it is**: The exact theorem-facing owner for opcode-specialized encoded-result consequences in the RV64IM native-ALU family.
- **What it is not**: It is not the generic native-ALU opcode owner, and it is not the still-missing arithmetic evaluator tying authenticated operands to the concrete ALU computation.
- **Protocol role**: It sits above `Rv64IMNativeAluOpcodeSemantics` and exposes the strongest currently justified exact per-opcode consequence: the authenticated architectural writeback equals the encoded Stage-1 `aluResult` for active non-`x0` native-ALU writes.

## Required Theorem Surface

For each write-active native-ALU opcode:

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

the module must expose:

- one exact opcode-specialized theorem proving
  `wordToLimbPair(executionRow.results.aluResult) = aluWritebackValue`
- one exact opcode-specialized theorem proving
  `wvReg = wordToLimbPair(executionRow.results.aluResult)`

under the active non-`x0` write conditions already owned by the native-ALU opcode owner.

## Proof Obligations

- The module must not claim a stronger arithmetic equality than the current theorem surface justifies.
- The module must reuse the exact Stage-1/Stage-2 representation bridge rather than rephrasing the result only as `wvReg = rdNext`.
- Theorems must remain opcode-specialized, not merely family-specialized.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/NativeAluOpcodeResultSemantics.lean` | Exact native-ALU opcode encoded-result owner |
| `Nightstream/Rv64IM/Execution/NativeAluOpcodeResultSemanticsInterface.lean` | Theorem-facing re-export surface |

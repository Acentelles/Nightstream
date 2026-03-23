# Rv64IMMultiplyOpcodeResultSemantics Spec

## Purpose

- **What it is**: The exact theorem-facing owner for opcode-specialized encoded-result consequences in the RV64IM multiply family.
- **What it is not**: It is not the generic multiply opcode owner, and it is not the still-missing op-by-op multiplication arithmetic contract.
- **Protocol role**: It sits above `Rv64IMMultiplyOpcodeSemantics` and exposes the strongest currently justified exact per-opcode consequence: the authenticated architectural writeback equals the encoded Stage-1 `aluResult` for active non-`x0` multiply writes.

## Required Theorem Surface

For each multiply opcode:

- `MUL`
- `MULH`
- `MULHU`
- `MULHSU`
- `MULW`

the module must expose:

- one exact opcode-specialized theorem proving
  `wordToLimbPair(executionRow.results.aluResult) = aluWritebackValue`
- one exact opcode-specialized theorem proving
  `wvReg = wordToLimbPair(executionRow.results.aluResult)`

under the active non-`x0` write conditions already owned by the multiply opcode owner.

## Proof Obligations

- The module must not weaken multiply closure back to a family-only statement.
- The module must reuse the exact Stage-1/Stage-2 representation bridge rather than hiding the result behind `wvReg = rdNext`.
- `MULW` must remain theorem-visible as its own exact opcode specialization.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/MultiplyOpcodeResultSemantics.lean` | Exact multiply opcode encoded-result owner |
| `Nightstream/Rv64IM/Execution/MultiplyOpcodeResultSemanticsInterface.lean` | Theorem-facing re-export surface |

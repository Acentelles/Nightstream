# Rv64IMMultiplyEncodedArithmetic Spec

## Purpose

- **What it is**: The exact theorem-facing owner for opcode-specialized encoded arithmetic consequences in the RV64IM multiply family.
- **What it is not**: It is not the generic multiply opcode owner, and it is not a concrete word-level multiplication evaluator.
- **Protocol role**: It sits above `Rv64IMMultiplyOpcodeSemantics` and `Rv64IMStepComposition`, and it binds the encoded Stage-1 `aluResult` to theorem-facing encoded multiply operations on authenticated operands.

## Central Objects

- `MultiplyEncodedOps(Limb)` fixes the theorem-facing encoded multiply operators.
- `MultiplyEncodedResult(ops, decodedRow, registerTwist, opcode)` is the exact encoded target for the given multiply opcode.
- `MultiplyEncodedResultBound(...)` asserts that the routed encoded ALU writeback equals that exact encoded target.

## Required Theorem Surface

For each multiply opcode:

- `MUL`
- `MULH`
- `MULHU`
- `MULHSU`
- `MULW`

the module must expose:

- one exact opcode-specialized theorem proving
  `wordToLimbPair(executionRow.results.aluResult) = MultiplyEncodedResult(...)`
- one exact opcode-specialized theorem proving
  `wvReg = MultiplyEncodedResult(...)`
  under the active non-`x0` conditions.

## Proof Obligations

- The owner must reuse the exact routed encoded-result bridge from `Rv64IMStepComposition`; it may not hide the result behind `wvReg = rdNext`.
- All multiply opcodes must use the authenticated register operands from the concrete Twist binding.
- `MULW` must remain theorem-visible as its own exact opcode specialization.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/MultiplyEncodedArithmetic.lean` | Exact multiply encoded arithmetic owner |
| `Nightstream/Rv64IM/Execution/MultiplyEncodedArithmeticInterface.lean` | Theorem-facing re-export surface |

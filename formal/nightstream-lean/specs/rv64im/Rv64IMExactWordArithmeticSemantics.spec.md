# Rv64IMExactWordArithmeticSemantics Spec

## Purpose

- **What it is**: The canonical execution-level bundle for exact native-ALU,
  word/shift, and multiply word arithmetic above exact opcode-family closure.
- **What it is not**: It is not a stage-local arithmetic owner and it does not
  re-own authenticated trace or kernel lifting.
- **Protocol role**: It packages the theorem-facing word-level consequences that
  connect exact Stage-1 `aluResult` words, authenticated non-`x0` writeback
  words, and the opcode-specialized native-ALU / multiply word evaluators.

## Central Object

`ExactWordArithmeticSemantics(pkg, families)` packages:

- the exact native-ALU word-arithmetic consequences over `families`,
- the exact word/shift word-arithmetic consequences over `families`,
- the exact multiply word-arithmetic consequences over `families`,
- the exact Stage-1 `aluResult` word equalities for those opcode families,
- the exact authenticated non-`x0` writeback-word equalities for those opcode
  families.

Its theorem-facing fields are:

- `nativeAluWord`
- `nativeAluAuthenticatedWord`
- `wordShiftWord`
- `wordShiftAuthenticatedWord`
- `multiplyWord`
- `multiplyAuthenticatedWord`

## Required Constructors

The module must expose:

- `exactWordArithmeticSemantics_of_exactOpcodeFamilySemantics`
- `exactWordArithmeticSemantics_of_stepComposition`

so consumers can recover one canonical exact word-arithmetic bundle either from
exact family semantics or directly from the `StepComposition` proof package.

## Proof Obligations

- The bundle must factor through the dedicated native-ALU, word/shift, and
  multiply word-arithmetic owners rather than duplicating their proofs in a
  larger ad hoc record.
- `nativeAluAuthenticatedWord` may only claim authenticated writeback equality
  for opcodes whose `writesArchitecturalRd = true`, and it must require
  `rd ≠ x0`.
- `wordShiftAuthenticatedWord` must require `rd ≠ x0`.
- `multiplyAuthenticatedWord` must require `rd ≠ x0`.
- The bundle must not invent a new evaluator disconnected from the Stage-1
  `aluResult` word and the explicit word/limb representation bridge already
  carried by `StepComposition`.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/ExactWordArithmeticSemantics.lean` | Canonical execution-level exact word-arithmetic bundle |
| `Nightstream/Rv64IM/Execution/ExactWordArithmeticSemanticsInterface.lean` | Theorem-facing re-export surface |

# Rv64IMExactOpcodeFamilySemantics Spec

## Purpose

- **What it is**: The execution-level owner for exact opcode-family semantic consequences above exact opcode-class closure.
- **What it is not**: It is not a stage-local proof owner, not the authenticated trace owner, and not the kernel theorem owner.
- **Protocol role**: It aggregates the seven exact execution-level opcode-family semantic owners into one canonical family bundle above exact opcode-class closure.

## Central Object

`ExactOpcodeFamilySemantics(pkg)` packages:

- the canonical seven-class exact execution bundle from `ExactOpcodeClassSemantics`,
- the exact native-ALU semantic bundle,
- the exact word/arithmetic-shift semantic bundle,
- the exact control-flow semantic bundle,
- the exact narrow-memory semantic bundle,
- the exact multiply-family semantic bundle,
- the exact unsigned DIV/REM semantic bundle,
- the exact signed DIV/REM semantic bundle,
- the theorem-facing identification of the unsigned DIV/REM family soundness
  package with the `StepComposition`-owned unsigned DIV/REM soundness package,
- the theorem-facing identification of the signed DIV/REM family soundness
  package with the `StepComposition`-owned signed DIV/REM soundness package,
- the fixed committed-sequence proof packages for `nativeAlu`, `wordShift`,
  `controlFlow`, `narrowMemory`, and `multiply`,
- the fixed advice-sequence proof packages for `unsignedDivRem` and
  `signedDivRem`,
- the theorem-visible correctness consequence for each preserved family
  committed/advice sequence proof package,
- the theorem-visible determinism consequence for each preserved family
  committed/advice sequence proof package.

Each dedicated family bundle must keep its exact indexed row/frame/prepared-step
/successor extractors theorem-visible, so downstream trace and kernel owners do
not need to unpack nested class-level facts to recover them.

Native aligned 64-bit `LD` / `SD` rows are intentionally outside this
seven-family aggregate. They are recovered by the dedicated
`Rv64IMExactAlignedMemoryOpcodeSemantics` owner directly above
`Rv64IMStepComposition`.

## Required Constructor

The module must expose:

- `exactOpcodeFamilySemantics_of_stepComposition`
- `nativeAluSequenceCorrect_of_exactOpcodeFamilySemantics`
- `nativeAluSequenceDeterministic_of_exactOpcodeFamilySemantics`
- `wordShiftSequenceCorrect_of_exactOpcodeFamilySemantics`
- `wordShiftSequenceDeterministic_of_exactOpcodeFamilySemantics`
- `controlFlowSequenceCorrect_of_exactOpcodeFamilySemantics`
- `controlFlowSequenceDeterministic_of_exactOpcodeFamilySemantics`
- `narrowMemorySequenceCorrect_of_exactOpcodeFamilySemantics`
- `narrowMemorySequenceDeterministic_of_exactOpcodeFamilySemantics`
- `multiplySequenceCorrect_of_exactOpcodeFamilySemantics`
- `multiplySequenceDeterministic_of_exactOpcodeFamilySemantics`
- `unsignedDivRemSequenceCorrect_of_exactOpcodeFamilySemantics`
- `unsignedDivRemSequenceDeterministic_of_exactOpcodeFamilySemantics`
- `signedDivRemSequenceCorrect_of_exactOpcodeFamilySemantics`
- `signedDivRemSequenceDeterministic_of_exactOpcodeFamilySemantics`

which lifts one `StepCompositionProofPackage` into the full family-level semantic bundle by factoring through the dedicated execution-level family owners.

## Proof Obligations

- The canonical opcode-class bundle remains fixed and prover-independent.
- The aggregate family bundle does not replace the dedicated family owners with an ad hoc record of hand-picked consequences.
- The aggregate family bundle preserves the fixed family-level committed/advice
  sequence proof packages exported by `Rv64IMStepComposition`.
- The aggregate family bundle exposes those preserved packages through exact
  family-level correctness and determinism theorems, rather than forcing
  downstream owners to reason by raw field projection alone.
- Control-flow family semantics must carry the authenticated taken-target alignment discharge.
- Narrow-memory family semantics must factor through
  `Rv64IMNarrowMemoryHelpers`, while exact fixed lowered-sequence ownership
  remains visible through the preserved family committed-sequence proof package.
- Multiply family semantics must carry the exact low-half/high-half architectural meaning of `MUL`, `MULH`, `MULHU`, `MULHSU`, and `MULW`.
- Unsigned DIV/REM family semantics must carry both the Stage-1 support no-overflow fact and the theorem-level unsigned determinism fact.
- Signed DIV/REM family semantics must carry `CHANGE_DIVISOR`, dividend-sign remainder reconstruction, and the final signed semantic spec.
- The family layer must expose the exact equality between the family-owned
  unsigned/signed soundness packages and the corresponding `StepComposition`
  soundness owners, so exact opcode modules do not reason across disconnected
  proof carriers.
- Temporary-register hygiene remains a theorem-facing semantic fact and may not be left implicit.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/ExactOpcodeFamilySemantics.lean` | Exact opcode-family semantic consequence owner |
| `Nightstream/Rv64IM/Execution/ExactOpcodeFamilySemanticsInterface.lean` | Theorem-facing re-export surface |

## Downstream Family Owners

The exact bundle ranges over the seven dedicated execution-level family owners:

- `Nightstream/Rv64IM/Execution/NativeAluSemantics.lean`
- `Nightstream/Rv64IM/Execution/WordShiftSemantics.lean`
- `Nightstream/Rv64IM/Execution/ControlFlowSemantics.lean`
- `Nightstream/Rv64IM/Execution/NarrowMemorySemantics.lean`
- `Nightstream/Rv64IM/Execution/MultiplySemantics.lean`
- `Nightstream/Rv64IM/Execution/UnsignedDivRemSemantics.lean`
- `Nightstream/Rv64IM/Execution/SignedDivRemSemantics.lean`

The first downstream exact lowering owners are:

- `Nightstream/Rv64IM/Execution/NativeAluLoweringSemantics.lean`
- `Nightstream/Rv64IM/Execution/WordShiftLoweringSemantics.lean`
- `Nightstream/Rv64IM/Execution/ControlFlowLoweringSemantics.lean`
- `Nightstream/Rv64IM/Execution/NarrowMemoryLoweringSemantics.lean`
- `Nightstream/Rv64IM/Execution/MultiplyLoweringSemantics.lean`
- `Nightstream/Rv64IM/Execution/UnsignedDivRemLoweringSemantics.lean`
- `Nightstream/Rv64IM/Execution/SignedDivRemLoweringSemantics.lean`

The exact opcode owners above those lowering modules are:

- `Nightstream/Rv64IM/Execution/NativeAluOpcodeSemantics.lean`
- `Nightstream/Rv64IM/Execution/WordShiftOpcodeSemantics.lean`
- `Nightstream/Rv64IM/Execution/ControlFlowOpcodeSemantics.lean`
- `Nightstream/Rv64IM/Execution/NarrowMemoryOpcodeSemantics.lean`
- `Nightstream/Rv64IM/Execution/MultiplyOpcodeSemantics.lean`
- `Nightstream/Rv64IM/Execution/UnsignedDivRemOpcodeSemantics.lean`
- `Nightstream/Rv64IM/Execution/SignedDivRemOpcodeSemantics.lean`

The canonical exact word-arithmetic bundle above those opcode owners is:

- `Nightstream/Rv64IM/Execution/ExactWordArithmeticSemantics.lean`

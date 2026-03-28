# Rv64IMUnsignedDivRemLoweringSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner for unsigned DIV/REM lowering consequences above exact opcode-family semantics.
- **What it is not**: It is not the advice-generation owner, not the base unsigned soundness package, and not the kernel theorem owner.
- **Protocol role**: It exposes the fixed fetch/decode, exact indexed row/step/successor consequences, theorem-visible unsigned no-overflow/spec/determinism, and preserved advice-sequence closure that downstream consumers need for unsigned DIV/REM lowerings.

## Inputs

The module ranges over:

- one `StepCompositionProofPackage`,
- one `ExactOpcodeFamilySemantics(pkg)`.

It therefore inherits:

- the exact unsigned DIV/REM family execution facts,
- the preserved unsigned DIV/REM advice-sequence proof package,
- the fixed decoded Stage-1 row and fetch/decode bound from `Rv64IMStepComposition`.

## Required Theorem Surface

The module must expose:

- `fetchDecodeBound_of_unsignedDivRemLoweringSemantics`
- `decodedRow_valid_of_unsignedDivRemLoweringSemantics`
- `decodeHandoffBound_of_unsignedDivRemLoweringSemantics`
- `x0WritePreserved_of_unsignedDivRemLoweringSemantics`
- `nonFinalRdTarget_of_unsignedDivRemLoweringSemantics`
- `frame_row_eq_at_index_of_unsignedDivRemLoweringSemantics`
- `adjacentStates_of_unsignedDivRemLoweringSemantics`
- `preparedStep_matches_row_of_unsignedDivRemLoweringSemantics`
- `successor_matches_rows_of_unsignedDivRemLoweringSemantics`
- `row_has_opcodeClass_at_index_of_unsignedDivRemLoweringSemantics`
- `mulUNoOverflowBound_of_unsignedDivRemLoweringSemantics`
- `mulUNoOverflow_of_unsignedDivRemLoweringSemantics`
- `unsignedDivRemSpec_of_unsignedDivRemLoweringSemantics`
- `sequenceCorrect_of_unsignedDivRemLoweringSemantics`
- `sequenceDeterministic_of_unsignedDivRemLoweringSemantics`
- `unsignedDivRemDeterministic_of_unsignedDivRemLoweringSemantics`

## Proof Obligations

- The lowering owner must preserve the exact unsigned DIV/REM family row/frame/prepared-step/successor facts.
- The lowering owner must expose the fixed fetch/decode consequences for the same `pkg.decodedRow`.
- The lowering owner must keep the `MULU_NO_OVERFLOW` support relation theorem-visible.
- The lowering owner must expose the preserved unsigned advice-sequence correctness and determinism theorems without requiring downstream owners to unpack `ExactOpcodeFamilySemantics` fields manually.
- The theorem-visible unsigned quotient/remainder pair remains deterministic for `DIVU`, `REMU`, `DIVUW`, and `REMUW`.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/UnsignedDivRemLoweringSemantics.lean` | Unsigned DIV/REM lowering theorem owner |
| `Nightstream/Rv64IM/Execution/UnsignedDivRemLoweringSemanticsInterface.lean` | Theorem-facing re-export surface |

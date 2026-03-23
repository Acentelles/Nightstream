# Rv64IMSignedDivRemLoweringSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner for signed DIV/REM lowering consequences above exact opcode-family semantics.
- **What it is not**: It is not the advice-generation owner, not the base signed soundness package, and not the kernel theorem owner.
- **Protocol role**: It exposes the fixed fetch/decode, exact indexed row/step/successor consequences, theorem-visible signed divisor/remainder reconstruction facts, and preserved advice-sequence closure that downstream consumers need for signed DIV/REM lowerings.

## Inputs

The module ranges over:

- one `StepCompositionProofPackage`,
- one `ExactOpcodeFamilySemantics(pkg)`.

It therefore inherits:

- the exact signed DIV/REM family execution facts,
- the preserved signed DIV/REM advice-sequence proof package,
- the fixed decoded Stage-1 row and fetch/decode bound from `Rv64IMStepComposition`.

## Required Theorem Surface

The module must expose:

- `fetchDecodeBound_of_signedDivRemLoweringSemantics`
- `decodedRow_valid_of_signedDivRemLoweringSemantics`
- `decodeHandoffBound_of_signedDivRemLoweringSemantics`
- `x0WritePreserved_of_signedDivRemLoweringSemantics`
- `nonFinalRdTarget_of_signedDivRemLoweringSemantics`
- `frame_row_eq_at_index_of_signedDivRemLoweringSemantics`
- `adjacentStates_of_signedDivRemLoweringSemantics`
- `preparedStep_matches_row_of_signedDivRemLoweringSemantics`
- `successor_matches_rows_of_signedDivRemLoweringSemantics`
- `row_has_opcodeClass_at_index_of_signedDivRemLoweringSemantics`
- `changeDivisorCorrect_of_signedDivRemLoweringSemantics`
- `remainderFromDividendSign_of_signedDivRemLoweringSemantics`
- `signedDivRemSpec_of_signedDivRemLoweringSemantics`
- `sequenceCorrect_of_signedDivRemLoweringSemantics`
- `sequenceDeterministic_of_signedDivRemLoweringSemantics`

## Proof Obligations

- The lowering owner must preserve the exact signed DIV/REM family row/frame/prepared-step/successor facts.
- The lowering owner must expose the fixed fetch/decode consequences for the same `pkg.decodedRow`.
- The lowering owner must keep `CHANGE_DIVISOR`, dividend-sign remainder reconstruction, and the final signed semantic spec theorem-visible.
- The lowering owner must expose the preserved signed advice-sequence correctness and determinism theorems without requiring downstream owners to unpack `ExactOpcodeFamilySemantics` fields manually.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/SignedDivRemLoweringSemantics.lean` | Signed DIV/REM lowering theorem owner |
| `Nightstream/Rv64IM/Execution/SignedDivRemLoweringSemanticsInterface.lean` | Theorem-facing re-export surface |

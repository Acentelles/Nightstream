# Rv64IMNativeAluLoweringSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner for native-ALU lowering consequences above exact opcode-family semantics.
- **What it is not**: It is not a new semantic bundle type, not the Stage-1 fetch/decode owner, and not the kernel theorem owner.
- **Protocol role**: It exposes the fixed fetch/decode and preserved committed-sequence consequences that downstream consumers need when reasoning about native one-row RV64IM lowerings.

## Inputs

The module ranges over:

- one `StepCompositionProofPackage`,
- one `ExactOpcodeFamilySemantics(pkg)`.

It therefore inherits:

- the exact native-ALU family execution facts,
- the preserved native-ALU committed-sequence proof package,
- the fixed decoded Stage-1 row and fetch/decode bound from `Rv64IMStepComposition`.

## Required Theorem Surface

The module must expose:

- `fetchDecodeBound_of_nativeAluLoweringSemantics`
- `decodedRow_valid_of_nativeAluLoweringSemantics`
- `decodeHandoffBound_of_nativeAluLoweringSemantics`
- `x0WritePreserved_of_nativeAluLoweringSemantics`
- `nonFinalRdTarget_of_nativeAluLoweringSemantics`
- `frame_row_eq_at_index_of_nativeAluLoweringSemantics`
- `adjacentStates_of_nativeAluLoweringSemantics`
- `preparedStep_matches_row_of_nativeAluLoweringSemantics`
- `successor_matches_rows_of_nativeAluLoweringSemantics`
- `row_has_opcodeClass_at_index_of_nativeAluLoweringSemantics`
- `sequenceCorrect_of_nativeAluLoweringSemantics`
- `sequenceDeterministic_of_nativeAluLoweringSemantics`

## Proof Obligations

- The lowering owner must preserve the exact native-ALU family row/frame/prepared-step/successor facts.
- The lowering owner must expose the fixed fetch/decode consequences for the same `pkg.decodedRow`, not a freshly reconstructed surrogate row.
- The lowering owner must expose the preserved native-ALU committed-sequence correctness and determinism theorems without requiring downstream owners to unpack `ExactOpcodeFamilySemantics` fields manually.
- `x0`-preservation and non-final architectural-destination exclusion remain theorem-visible obligations at this lowering layer.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/NativeAluLoweringSemantics.lean` | Native-ALU lowering theorem owner |
| `Nightstream/Rv64IM/Execution/NativeAluLoweringSemanticsInterface.lean` | Theorem-facing re-export surface |

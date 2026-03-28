# Rv64IMMultiplyLoweringSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner for multiply-family lowering consequences above exact opcode-family semantics.
- **What it is not**: It is not the Stage-1 multiplication-slot owner, not the generic family bundle, and not the kernel theorem owner.
- **Protocol role**: It exposes the fixed fetch/decode, exact indexed row/step/successor consequences, and preserved committed-sequence closure that downstream consumers need for RV64IM multiply-family lowerings.

## Inputs

The module ranges over:

- one `StepCompositionProofPackage`,
- one `ExactOpcodeFamilySemantics(pkg)`.

It therefore inherits:

- the exact multiply-family execution facts,
- the preserved multiply committed-sequence proof package,
- the fixed decoded Stage-1 row and fetch/decode bound from `Rv64IMStepComposition`.

## Required Theorem Surface

The module must expose:

- `fetchDecodeBound_of_multiplyLoweringSemantics`
- `decodedRow_valid_of_multiplyLoweringSemantics`
- `decodeHandoffBound_of_multiplyLoweringSemantics`
- `x0WritePreserved_of_multiplyLoweringSemantics`
- `nonFinalRdTarget_of_multiplyLoweringSemantics`
- `frame_row_eq_at_index_of_multiplyLoweringSemantics`
- `adjacentStates_of_multiplyLoweringSemantics`
- `preparedStep_matches_row_of_multiplyLoweringSemantics`
- `successor_matches_rows_of_multiplyLoweringSemantics`
- `row_has_opcodeClass_at_index_of_multiplyLoweringSemantics`
- `sequenceCorrect_of_multiplyLoweringSemantics`
- `sequenceDeterministic_of_multiplyLoweringSemantics`

## Proof Obligations

- The lowering owner must preserve the exact multiply-family row/frame/prepared-step/successor facts.
- The lowering owner must expose the fixed fetch/decode consequences for the same `pkg.decodedRow`.
- The lowering owner must expose the preserved multiply committed-sequence correctness and determinism theorems without requiring downstream owners to unpack `ExactOpcodeFamilySemantics` manually.
- Exact high-half/low-half architectural multiply meaning remains owned by the family semantic owner; this lowering layer only re-exposes it through the preserved family facts and sequence closure.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/MultiplyLoweringSemantics.lean` | Multiply-family lowering theorem owner |
| `Nightstream/Rv64IM/Execution/MultiplyLoweringSemanticsInterface.lean` | Theorem-facing re-export surface |

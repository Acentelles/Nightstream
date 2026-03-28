# Rv64IMWordShiftLoweringSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner for word/shift lowering consequences above exact opcode-family semantics.
- **What it is not**: It is not a replacement for `Rv64IMWordShiftSemantics`, not the Stage-1 fetch/decode owner, and not the kernel theorem owner.
- **Protocol role**: It exposes the fixed fetch/decode and preserved committed-sequence consequences for the `wordShift` family so downstream consumers can reason at the lowering boundary directly.

## Inputs

The module ranges over:

- one `StepCompositionProofPackage`,
- one `ExactOpcodeFamilySemantics(pkg)`.

It therefore inherits:

- the exact word/shift family execution facts,
- the preserved word/shift committed-sequence proof package,
- the fixed decoded Stage-1 row and fetch/decode bound from `Rv64IMStepComposition`.

## Required Theorem Surface

The module must expose:

- `fetchDecodeBound_of_wordShiftLoweringSemantics`
- `decodedRow_valid_of_wordShiftLoweringSemantics`
- `decodeHandoffBound_of_wordShiftLoweringSemantics`
- `x0WritePreserved_of_wordShiftLoweringSemantics`
- `nonFinalRdTarget_of_wordShiftLoweringSemantics`
- `frame_row_eq_at_index_of_wordShiftLoweringSemantics`
- `adjacentStates_of_wordShiftLoweringSemantics`
- `preparedStep_matches_row_of_wordShiftLoweringSemantics`
- `successor_matches_rows_of_wordShiftLoweringSemantics`
- `row_has_opcodeClass_at_index_of_wordShiftLoweringSemantics`
- `sequenceCorrect_of_wordShiftLoweringSemantics`
- `sequenceDeterministic_of_wordShiftLoweringSemantics`

## Proof Obligations

- The lowering owner must preserve the exact word/shift family row/frame/prepared-step/successor facts.
- The lowering owner must expose the fixed fetch/decode consequences for the same `pkg.decodedRow`, not a widened or normalized surrogate row.
- The lowering owner must expose the preserved word/shift committed-sequence correctness and determinism theorems without requiring downstream owners to unpack `ExactOpcodeFamilySemantics` fields manually.
- Corrected `SRAW` / `SRAIW` semantics remain represented through the preserved word/shift sequence package and may not be weakened back to class-only closure.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/WordShiftLoweringSemantics.lean` | Word/shift lowering theorem owner |
| `Nightstream/Rv64IM/Execution/WordShiftLoweringSemanticsInterface.lean` | Theorem-facing re-export surface |

# Rv64IMNarrowMemoryLoweringSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner for narrow-memory lowering consequences above exact opcode-family semantics.
- **What it is not**: It is not the Stage-1 helper-arithmetic owner, not the aligned-word RAM authentication owner, and not the kernel theorem owner.
- **Protocol role**: It exposes the fixed fetch/decode, exact indexed row/step/successor consequences, and preserved committed-sequence closure that downstream consumers need for narrow load/store lowerings.

## Inputs

The module ranges over:

- one `StepCompositionProofPackage`,
- one `ExactOpcodeFamilySemantics(pkg)`.

It therefore inherits:

- the exact narrow-memory family execution facts,
- the preserved narrow-memory committed-sequence proof package,
- the fixed decoded Stage-1 row and fetch/decode bound from `Rv64IMStepComposition`.

## Required Theorem Surface

The module must expose:

- `fetchDecodeBound_of_narrowMemoryLoweringSemantics`
- `decodedRow_valid_of_narrowMemoryLoweringSemantics`
- `decodeHandoffBound_of_narrowMemoryLoweringSemantics`
- `x0WritePreserved_of_narrowMemoryLoweringSemantics`
- `nonFinalRdTarget_of_narrowMemoryLoweringSemantics`
- `frame_row_eq_at_index_of_narrowMemoryLoweringSemantics`
- `adjacentStates_of_narrowMemoryLoweringSemantics`
- `preparedStep_matches_row_of_narrowMemoryLoweringSemantics`
- `successor_matches_rows_of_narrowMemoryLoweringSemantics`
- `row_has_opcodeClass_at_index_of_narrowMemoryLoweringSemantics`
- `sequenceCorrect_of_narrowMemoryLoweringSemantics`
- `sequenceDeterministic_of_narrowMemoryLoweringSemantics`

## Proof Obligations

- The lowering owner must preserve the exact narrow-memory family row/frame/prepared-step/successor facts.
- The lowering owner must expose the fixed fetch/decode consequences for the same `pkg.decodedRow`, not a reconstructed surrogate.
- The lowering owner must expose the preserved narrow-memory committed-sequence correctness and determinism theorems without forcing downstream owners to unpack `ExactOpcodeFamilySemantics` fields manually.
- The lowering owner remains above `Rv64IMNarrowMemoryHelpers`; it does not replace the exact aligned-address, byte-offset, extract, or blend arithmetic owners.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/NarrowMemoryLoweringSemantics.lean` | Narrow-memory lowering theorem owner |
| `Nightstream/Rv64IM/Execution/NarrowMemoryLoweringSemanticsInterface.lean` | Theorem-facing re-export surface |

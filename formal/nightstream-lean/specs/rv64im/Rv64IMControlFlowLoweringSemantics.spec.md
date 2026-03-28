# Rv64IMControlFlowLoweringSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner for control-flow lowering consequences above exact opcode-family semantics.
- **What it is not**: It is not a replacement for `Rv64IMControlFlowSemantics`, not the Stage-1 fetch/decode owner, and not the kernel theorem owner.
- **Protocol role**: It exposes the fixed fetch/decode and preserved committed-sequence consequences for control-flow lowerings, together with the authenticated taken-target alignment discharge.

## Inputs

The module ranges over:

- one `StepCompositionProofPackage`,
- one `ExactOpcodeFamilySemantics(pkg)`.

It therefore inherits:

- the exact control-flow family execution facts,
- the preserved control-flow committed-sequence proof package,
- the fixed decoded Stage-1 row and fetch/decode bound from `Rv64IMStepComposition`,
- the authenticated taken-target alignment fact carried by the exact control-flow family bundle.

## Required Theorem Surface

The module must expose:

- `fetchDecodeBound_of_controlFlowLoweringSemantics`
- `decodedRow_valid_of_controlFlowLoweringSemantics`
- `decodeHandoffBound_of_controlFlowLoweringSemantics`
- `x0WritePreserved_of_controlFlowLoweringSemantics`
- `nonFinalRdTarget_of_controlFlowLoweringSemantics`
- `frame_row_eq_at_index_of_controlFlowLoweringSemantics`
- `adjacentStates_of_controlFlowLoweringSemantics`
- `preparedStep_matches_row_of_controlFlowLoweringSemantics`
- `successor_matches_rows_of_controlFlowLoweringSemantics`
- `row_has_opcodeClass_at_index_of_controlFlowLoweringSemantics`
- `takenTargetAlignment_of_controlFlowLoweringSemantics`
- `sequenceCorrect_of_controlFlowLoweringSemantics`
- `sequenceDeterministic_of_controlFlowLoweringSemantics`

## Proof Obligations

- The lowering owner must preserve the exact control-flow family row/frame/prepared-step/successor facts.
- The lowering owner must expose the fixed fetch/decode consequences for the same `pkg.decodedRow`, not a reconstructed branch/jump row.
- The lowering owner must expose the preserved control-flow committed-sequence correctness and determinism theorems without requiring downstream owners to unpack `ExactOpcodeFamilySemantics` fields manually.
- The authenticated taken-target alignment discharge must remain theorem-visible at this lowering layer.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/ControlFlowLoweringSemantics.lean` | Control-flow lowering theorem owner |
| `Nightstream/Rv64IM/Execution/ControlFlowLoweringSemanticsInterface.lean` | Theorem-facing re-export surface |

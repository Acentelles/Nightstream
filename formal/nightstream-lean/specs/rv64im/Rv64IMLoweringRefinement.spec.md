# Rv64IMLoweringRefinement Spec

## Purpose

- **What it is**: The theorem-facing owner that relates concrete committed lowered sequences to the reference lowering catalog fixed by the RV64IM kernel spec.
- **What it is not**: It is not the owner of opcode arithmetic semantics, not the Stage-1 fetch/decode owner, and not the final trace/kernel soundness owner.
- **Protocol role**: It is the admissibility bridge that lets a concrete Jolt-like lowering differ from the human-readable reference sequences while preserving the exact execution, trace, and kernel theorem surfaces.

## Inputs

The module ranges over:

- one `ExecutionSemanticsProofPackage`,
- one `StepCompositionProofPackage`,
- one theorem-facing reference-lowering description for the supported opcode family,
- one theorem-facing concrete-lowering description for the same family.

It therefore inherits:

- the exact expanded-row execution objects,
- the exact row/frame/successor/prepared-step surfaces,
- the exact opcode-family semantic target,
- the authenticated Stage-1 / Stage-2 / Stage-3 row metadata for the concrete sequence.

## Central Objects

The owner fixes:

- `ReferenceLowering`
- `ConcreteLowering`
- `EffectRowIndex`
- `CommitRowIndex`
- `ClosureSuffixRange`
- `ConcreteLoweringRefinesReference`

`ConcreteLoweringRefinesReference` means:

- the concrete lowering is deterministic from the authenticated architectural row and declared lowering version,
- the concrete lowering has one unique effect row,
- the concrete lowering has one unique commit row at or after the effect row,
- the concrete effect row realizes the same architectural write/RAM effect as the reference lowering,
- any rows between effect row and commit row are closure-suffix rows touching only scratch virtual registers,
- closure-suffix rows introduce no additional architectural or RAM effect,
- the concrete sequence preserves the exact row/frame/successor/prepared-step surfaces needed downstream.

## Required Theorem Surface

The module must expose:

- `effectRow_existsUnique_of_loweringRefinement`
- `commitRow_existsUnique_of_loweringRefinement`
- `effectRow_le_commitRow_of_loweringRefinement`
- `effectRow_correct_of_loweringRefinement`
- `commitRow_exports_boundary_of_loweringRefinement`
- `closureSuffix_scratchOnly_of_loweringRefinement`
- `closureSuffix_noArchitecturalWrite_of_loweringRefinement`
- `closureSuffix_noRamEffect_of_loweringRefinement`
- `closureSuffix_noFreshAdvice_of_loweringRefinement`
- `referenceAndConcrete_sameArchitecturalPostState_of_loweringRefinement`
- `referenceAndConcrete_sameRamEffect_of_loweringRefinement`
- `referenceAndConcrete_samePreparedStepBoundary_of_loweringRefinement`
- `referenceAndConcrete_sameSequenceCorrect_of_loweringRefinement`
- `referenceAndConcrete_sameSequenceDeterministic_of_loweringRefinement`

## Proof Obligations

- The refinement owner must make the effect-row / commit-row distinction theorem-visible.
- The refinement owner must prove closure-suffix inertness directly; downstream layers may not assume it.
- The refinement owner must preserve the exact execution-level theorem surface already exported by family lowering owners.
- The refinement owner must be strong enough for trace and kernel consumers to reason only about the concrete committed rows while still concluding the reference opcode semantics.
- The refinement owner must not hide determinism or correctness only behind transcript/kernel wrappers.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/LoweringRefinement.lean` | Reference-to-concrete lowering refinement owner |
| `Nightstream/Rv64IM/Execution/LoweringRefinementInterface.lean` | Theorem-facing re-export surface |

# Rv64IMRequiredRootExecutionSemanticsSurface Spec

## Purpose

- **What it is**: The theorem-facing owner of the exact exported row-local proof objects Lean requires to close the root-execution-semantics step.
- **What it is not**: It is not the root chunk-proof audit and it does not prove RV64IM execution correctness by itself.
- **Protocol role**: It fixes the irreducible row-local export boundary between authenticated root execution objects and the theorem that refines them back to RV64IM execution correctness on authenticated rows.

## Required Export Surface

- The accepted artifact exposes theorem-bearing row-local `RootEncode(z_j)` witness objects for authenticated rows.
- The accepted artifact exposes theorem-bearing row-local CCS acceptance objects for the chunk that owns each authenticated row under the carried fold schedule.
- The accepted artifact exposes theorem-bearing refinement objects from those accepted row-local root execution objects back to RV64IM `ExecutionCorrect`.
- Absence of any of those objects is a hard closure failure even if root execution digests remain coherent.

## Theorem and Check Targets

- `requiredRootExecutionSemanticsChecks`
- `requiredRootExecutionSemanticsSurfacePresent`
- `missingRequiredRootExecutionSemanticsFields`
- `requiredRootExecutionSemanticsRustExportBlockers`
- `uniqueRequiredRootExecutionSemanticsRustExportBlockers`
- `validGeneratedRv64imRequiredRootExecutionSemanticsCases`

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/Rv64IM/Generated/AcceptedProofArtifactTypes.lean`
  - `Nightstream/Rv64IM/Generated/PublicProofVectorTypes.lean`
- **Consumed by**:
  - `Nightstream/Rv64IM/AcceptedArtifactRootExecutionSemanticsClosure.lean`
  - `Nightstream/Rv64IM/ProofCompleteAudit.lean`

## Out of Scope

- proving the row-local root CCS theorem itself
- Rust-side payload generation
- the final selected-row/opening kernel-design bridge

# Rv64IMAcceptedArtifactBackendRefinement Spec

## Purpose

- **What it is**: The executable RV64IM audit that checks whether the exported accepted artifact contains enough backend payload structure to refine into the proved SuperNeo `Π_CCS / Π_RLC / Π_DEC` statements.
- **What it is not**: It is not a digest-parity check and it does not trust imported backend summaries as proof payloads.
- **Protocol role**: It closes the exact miss where a coherent RV64IM public summary could hide a dummy main-lane or fold payload.

## Target Conditions

- Exported fold schedule and chunk count agree across the public statement and main-lane proof bindings.
- Exported public-step counts agree across the public statement and main-lane proof bindings.
- Lean recomputes the chunk layout from the theorem-owned fold schedule and prepared-step count.
- Lean’s replayed prepared-step count exactly matches the exported public-step count.
- The accepted artifact exposes low-level chunk/backend proof payload surfaces rather than only summary digests.
- The exported main-lane, stage, and kernel-opening bundles expose theorem-bearing payloads rather than digest-only placeholders.
- The artifact carries theorem-bearing payloads sufficient to refine into:
  - `Π_CCS`
  - `Π_RLC`
  - `Π_DEC`
- Acceptance fails if any of those payloads or refinements are absent.

## Theorem and Check Targets

- `backendRefinementChecks`
- `backendRefinementAccepted`
- `missingBackendRefinementFields`
- `backendRefinementRustExportBlockers`
- `uniqueBackendRefinementRustExportBlockers`
- `validGeneratedRv64imAcceptedArtifactBackendRefinementCases`

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/ChunkLayout.lean`
  - `Nightstream/Rv64IM/Generated/AcceptedProofArtifactTypes.lean`
  - `Nightstream/Rv64IM/Checks.lean`
- **Consumed by**:
  - RV64IM proof-completeness audit
  - authoritative accepted-artifact gate

## Out of Scope

- proving the SuperNeo `Π_CCS / Π_RLC / Π_DEC` theorems themselves
- Rust-side payload generation
- stage-local RV64IM execution semantics

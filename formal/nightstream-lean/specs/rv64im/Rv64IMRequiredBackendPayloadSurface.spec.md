# Rv64IMRequiredBackendPayloadSurface Spec

## Purpose

- **What it is**: The theorem-facing owner of the exact low-level RV64IM backend payload objects Rust must export for Lean to refine into the proved SuperNeo `Π_CCS / Π_RLC / Π_DEC` statements.
- **What it is not**: It is not the backend-refinement proof itself and it does not accept digest-only public summaries as payloads.
- **Protocol role**: It fixes the backend theorem boundary by stating the irreducible exported proof objects required before any last-mile refinement theorem can close.

## Required Export Surface

- The accepted artifact exposes an explicit low-level chunk proof payload list aligned to the theorem-owned fold schedule and chunk layout.
- The main-lane bundle exposes a theorem-bearing payload sufficient to build the target `Π_CCS` context.
- The stage-claim bundle exposes a theorem-bearing payload sufficient to build the target `Π_RLC` claim context.
- The stage-package bundle exposes a theorem-bearing payload sufficient to build the target `Π_RLC` package / carry context.
- The kernel-opening bundle exposes a theorem-bearing payload sufficient to build the target `Π_DEC` context.
- Absence of any of those payload objects is a hard closure failure even if exported statement / claims / kernelProof digests remain self-consistent.

## Theorem and Check Targets

- `requiredBackendPayloadChecks`
- `requiredBackendPayloadSurfacePresent`
- `missingRequiredBackendPayloadFields`
- `requiredBackendPayloadRustExportBlockers`
- `uniqueRequiredBackendPayloadRustExportBlockers`
- `validGeneratedRv64imRequiredBackendPayloadCases`

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/Rv64IM/Generated/AcceptedProofArtifactTypes.lean`
  - `Nightstream/Rv64IM/Generated/PublicProofVectorTypes.lean`
- **Consumed by**:
  - `Nightstream/Rv64IM/AcceptedArtifactBackendRefinement.lean`
  - `Nightstream/Rv64IM/ProofCompleteAudit.lean`

## Out of Scope

- proving the SuperNeo backend theorems themselves
- reconstructing backend contexts from those payloads
- Rust-side payload generation

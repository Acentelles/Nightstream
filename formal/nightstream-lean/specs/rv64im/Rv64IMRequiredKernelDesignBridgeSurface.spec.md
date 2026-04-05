# Rv64IMRequiredKernelDesignBridgeSurface Spec

## Purpose

- **What it is**: The theorem-facing owner of the exact exported proof objects Lean requires to construct the full RV64IM kernel-design bridge.
- **What it is not**: It is not the bridge theorem itself and it does not treat transcript or digest coherence as a substitute for theorem-bearing bridge objects.
- **Protocol role**: It fixes the irreducible export boundary for authenticated selected-row payloads, schedule-owned routing, stage obligations, and opening provenance before the bridge theorem can close.

## Required Export Surface

- The accepted artifact exposes theorem-bearing authenticated Twist/Shout selected-row / opening payloads.
- The accepted artifact exposes theorem-bearing selected-row-to-prepared-step bindings.
- The accepted artifact exposes theorem-bearing selected-row-to-schedule-owned-root-chunk routing bindings.
- The accepted artifact exposes theorem-bearing Stage 1 / Stage 2 / Stage 3 obligation payloads.
- The accepted artifact exposes theorem-bearing kernel opening provenance chains.
- Absence of any of those objects is a hard closure failure even if exported stage and opening digests remain coherent.

## Theorem and Check Targets

- `requiredKernelDesignBridgeChecks`
- `requiredKernelDesignBridgeSurfacePresent`
- `missingRequiredKernelDesignBridgeFields`
- `requiredKernelDesignBridgeRustExportBlockers`
- `uniqueRequiredKernelDesignBridgeRustExportBlockers`
- `validGeneratedRv64imRequiredKernelDesignBridgeCases`

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/Rv64IM/Generated/AcceptedProofArtifactTypes.lean`
  - `Nightstream/Rv64IM/Generated/PublicProofVectorTypes.lean`
- **Consumed by**:
  - `Nightstream/Rv64IM/AcceptedArtifactKernelDesignBridgeClosure.lean`
  - `Nightstream/Rv64IM/ProofCompleteAudit.lean`

## Out of Scope

- proving the bridge theorem itself
- Rust-side payload generation
- backend refinement into `Π_CCS / Π_RLC / Π_DEC`

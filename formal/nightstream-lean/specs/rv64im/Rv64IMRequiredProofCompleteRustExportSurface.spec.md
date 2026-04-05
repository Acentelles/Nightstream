# Rv64IMRequiredProofCompleteRustExportSurface Spec

## Purpose

- **What it is**: The theorem-owned aggregate Rust export contract required for proof-complete RV64IM closure.
- **What it is not**: It is not a proof of backend refinement, root execution semantics, or the kernel bridge.
- **Protocol role**: It states the exact exported proof-object surfaces Lean must receive before accepted artifacts can close all theorem-facing obligations.

## Contract

The owner aggregates three required theorem-facing export surfaces:

- the backend payload surface required to refine RV64IM payloads into `Π_CCS / Π_RLC / Π_DEC`,
- the row-local root-execution-semantics surface required to refine accepted root-lane CCS objects back to RV64IM execution correctness,
- the kernel-design-bridge surface required to bind authenticated selected rows, root execution, stage obligations, and kernel openings into one theorem owner.

For every accepted-artifact case, the owner must expose:

- whether the backend payload surface is present,
- whether the root-execution-semantics surface is present,
- whether the kernel-design-bridge surface is present,
- whether the aggregate proof-complete Rust export surface is present,
- which aggregate export surfaces remain missing,
- which backend payload fields remain missing,
- which row-local root-execution-semantics fields remain missing,
- which kernel-design-bridge fields remain missing,
- the exact Rust export blockers induced by the missing surfaces,
- the exact backend-payload Rust export blockers induced by the missing backend fields,
- the exact root-execution-semantics Rust export blockers induced by the missing row-local fields,
- the exact kernel-design-bridge Rust export blockers induced by the missing bridge fields,
- the global union of missing backend payload fields across the accepted-artifact corpus,
- the global union of missing root-execution-semantics fields across the accepted-artifact corpus,
- the global union of missing kernel-design-bridge fields across the accepted-artifact corpus,
- and the global union of those blockers across the accepted-artifact corpus.

## Check Targets

- `requiredProofCompleteRustExportChecks`
- `requiredProofCompleteBackendSurfacePresent`
- `requiredProofCompleteRootExecutionSemanticsSurfacePresent`
- `requiredProofCompleteKernelDesignBridgeSurfacePresent`
- `requiredProofCompleteRustExportSurfacePresent`
- `missingRequiredProofCompleteRustExportFields`
- `requiredProofCompleteBackendMissingFields`
- `requiredProofCompleteRootExecutionSemanticsMissingFields`
- `requiredProofCompleteKernelDesignBridgeMissingFields`
- `requiredProofCompleteRustExportReport`
- `uniqueMissingRequiredProofCompleteRustExportFields`
- `uniqueRequiredProofCompleteBackendMissingFields`
- `uniqueRequiredProofCompleteRootExecutionSemanticsMissingFields`
- `uniqueRequiredProofCompleteKernelDesignBridgeMissingFields`
- `requiredProofCompleteBackendRustExportBlockers`
- `requiredProofCompleteRootExecutionSemanticsRustExportBlockers`
- `requiredProofCompleteKernelDesignBridgeRustExportBlockers`
- `requiredProofCompleteRustExportBlockers`
- `uniqueRequiredProofCompleteBackendRustExportBlockers`
- `uniqueRequiredProofCompleteRootExecutionSemanticsRustExportBlockers`
- `uniqueRequiredProofCompleteKernelDesignBridgeRustExportBlockers`
- `uniqueRequiredProofCompleteRustExportBlockers`
- `validGeneratedRv64imRequiredProofCompleteRustExportCases`
- `rv64imRequiredProofCompleteRustExportReports`
- `validGeneratedRv64imRequiredProofCompleteBackendSurfaceCases`
- `validGeneratedRv64imRequiredProofCompleteRootExecutionSemanticsSurfaceCases`
- `validGeneratedRv64imRequiredProofCompleteKernelDesignBridgeSurfaceCases`

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/Rv64IM/Kernel/RequiredBackendPayloadSurface.lean`
  - `Nightstream/Rv64IM/Kernel/RequiredRootExecutionSemanticsSurface.lean`
  - `Nightstream/Rv64IM/Kernel/RequiredKernelDesignBridgeSurface.lean`
- **Consumed by**:
  - `Nightstream/Rv64IM/ProofCompleteAudit.lean`
  - `CheckCli.lean`

## Out of Scope

- generating Rust payloads
- proving any of the three aggregated theorem owners

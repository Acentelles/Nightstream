# Rv64IMProofCompleteAudit Spec

## Purpose

- **What it is**: The executable top-level audit deciding whether RV64IM is proof-complete at the Lean boundary.
- **What it is not**: It is not another parity report and it does not treat hidden witnesses or backend interface imports as closure.
- **Protocol role**: It is the guardrail that prevents Lean from reporting success when the accepted artifact still relies on stored exact-boundary witnesses or lacks backend refinement into `Π_CCS / Π_RLC / Π_DEC`.

## Closure Conditions

RV64IM is proof-complete only if all of the following hold:

- theorem-owned chunk layout exists and is used as the chunk authority,
- theorem-owned chunked root execution proof owner exists,
- the main-lane trace boundary carries the explicit theorem-owned fold schedule and canonical chunk partition,
- the transcript schedule carries explicit fold-schedule absorption and ordered per-chunk `Π_CCS / Π_RLC / Π_DEC` protocol slots,
- a separate theorem-owned root-execution-semantics owner exists above exact trace closure and binds the accepted chunked root execution proof back to the same authenticated rows,
- a separate theorem-owned required backend payload surface owner states the exact exported low-level proof payloads Lean requires before backend refinement can close,
- a separate theorem-owned required root-execution-semantics export surface owner states the exact row-local proof objects Rust must export before root execution semantics can close,
- a separate theorem-owned required kernel-design-bridge export surface owner states the exact selected-row / stage / opening objects Rust must export before the bridge theorem can close,
- a separate theorem-owned aggregate proof-complete Rust export surface owner states the full theorem-bearing export contract across those three surfaces,
- the accepted artifact does not store an exact-kernel-boundary witness,
- accepted-proof soundness does not store an exact-kernel-boundary witness,
- the checker result does not store an exact-kernel-boundary witness,
- the public proof boundary does not store an accepted-proof witness,
- the accepted checker owns the theorem-facing exact-boundary constructor used to package checker results,
- the Nightstream bridge theorem binds authenticated selected-row obligations into the accepted surface,
- the Nightstream bridge theorem binds the root main-lane execution proof into the accepted surface,
- the Nightstream bridge theorem binds the stage obligation packages into the accepted surface,
- the Nightstream bridge theorem binds the kernel opening claims into the accepted surface,
- the backend payload surface is not summary-only,
- the required root-execution-semantics export surface is present across the accepted-artifact corpus,
- the required kernel-design-bridge export surface is present across the accepted-artifact corpus,
- the aggregate proof-complete Rust export contract is present across the accepted-artifact corpus,
- those three export-surface presence facts are decided from the aggregate owner’s missing required field sets, not from derived blocker names,
- the top-level proof-complete static export-surface checks are projected from the aggregate proof-complete Rust export owner rather than re-derived from duplicated local field logic,
- the accepted checker owns backend refinement into the SuperNeo statements,
- every accepted artifact passes parity checks,
- every accepted artifact is theorem-complete,
- every accepted artifact constructs exact trace and exact kernel boundaries,
- every per-case proof-complete report exposes backend-surface acceptance, root-execution-semantics-surface acceptance, kernel-design-bridge-surface acceptance, and the aggregate export-contract acceptance separately,
- every per-case proof-complete report projects those four acceptance booleans from the aggregate proof-complete Rust export report rather than recomputing them from local field subsets,
- the top-level proof-complete audit exposes those four export-surface acceptance facts as direct booleans as well as through the per-case reports,
- every failing static proof-complete field exposes its exact missing required fields and Rust export blockers, not just the field name,
- the top-level proof-complete audit exposes the union of missing required fields and the union of Rust export blockers across only the currently failing static proof-complete fields,
- every accepted artifact carries enough theorem-bearing data to justify the root-execution-semantics step that turns accepted row-local root CCS objects into RV64IM execution correctness on the authenticated rows,
- every accepted artifact carries enough theorem-bearing data to construct the
  full kernel-design bridge owner binding authenticated selection, root
  execution, stage obligations, and kernel openings,
- every accepted artifact carries backend payloads sufficient to refine into `Π_CCS / Π_RLC / Π_DEC`.

## Check Targets

- `proofCompleteStaticChecks`
- `proofCompleteStaticFailures`
- `proofCompleteStaticFieldMissingRequiredFields`
- `proofCompleteStaticFieldRustExportBlockers`
- `proofCompleteStaticFailureReports`
- `uniqueProofCompleteStaticFailureMissingRequiredFields`
- `uniqueProofCompleteStaticFailureRustExportBlockers`
- `proofCompleteCaseAccepted`
- `proofCompleteBackendRustExportBlockers`
- `proofCompleteRootExecutionSemanticsRustExportBlockers`
- `proofCompleteKernelDesignBridgeRustExportBlockers`
- `uniqueProofCompleteRequiredBackendPayloadFields`
- `uniqueProofCompleteRequiredRootExecutionSemanticsFields`
- `uniqueProofCompleteRequiredKernelDesignBridgeFields`
- `uniqueProofCompleteRequiredRustExportFields`
- `validProofCompleteRequiredBackendPayloadSurface`
- `validProofCompleteRequiredRootExecutionSemanticsSurface`
- `validProofCompleteRequiredKernelDesignBridgeSurface`
- `validProofCompleteRequiredRustExportSurface`
- `rv64imProofCompleteReports`
- `proofCompleteRustExportBlockers`
- `uniqueProofCompleteBackendRustExportBlockers`
- `uniqueProofCompleteRootExecutionSemanticsRustExportBlockers`
- `uniqueProofCompleteKernelDesignBridgeRustExportBlockers`
- `uniqueProofCompleteRustExportBlockers`
- `uniqueProofCompleteClosureBlockers`
- `validGeneratedRv64imProofCompleteCases`
- `validRv64imProofCompleteClosure`

## Dependency and Consumer Map

- **Depends on**:
- accepted-artifact parity checks
- accepted-artifact completeness audit
- exact constructor audit
- accepted-artifact root execution closure audit
- accepted-artifact root execution semantics closure audit
- accepted-artifact kernel-design bridge closure audit
- backend refinement audit
- required backend payload surface owner
- required root-execution-semantics export surface owner
- required kernel-design-bridge export surface owner
- required proof-complete Rust export surface owner
- **Consumed by**:
  - `CheckCli.lean`
  - `Main.lean`

## Out of Scope

- Rust payload generation
- generic non-RV64IM closure
- proof of the SuperNeo backend theorems themselves

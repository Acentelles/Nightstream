# Rv64IMAcceptedArtifactRootExecutionSemanticsClosure Spec

## Purpose

- **What it is**: The executable RV64IM audit that checks whether the exported accepted artifact carries enough theorem-bearing data for Lean to close the root execution semantics step of the kernel design.
- **What it is not**: It is not the root chunk-proof audit and it is not the kernel-design bridge audit.
- **Protocol role**: It targets the exact step required by the kernel spec where an authenticated selected semantic row `RootEncode(z_j)` must be accepted by the root main-lane CCS theorem package for the chunk that owns that row under the carried fold schedule and thereby justify RV64IM execution correctness.

## Target Conditions

- Lean can replay execution rows from the exported source case.
- Lean can recompute the semantic-row embedding and root-lane protocol bindings from those replayed rows and match them exactly against the artifact.
- Lean can recompute the schedule-owned owning-chunk routing for every replayed authenticated row under the carried fold schedule, including true multi-chunk schedules.
- A separate theorem-owned required root-execution-semantics export surface owner states the exact row-local proof objects Rust must export before this step can close.
- The artifact exposes a theorem-bearing row-local `RootEncode(z_j)` witness surface rather than only digests.
- The artifact exposes a theorem-bearing row-local CCS acceptance surface for the chunk determined by the carried `FoldSchedule` that owns the authenticated row.
- The artifact exposes a theorem-bearing refinement surface from that accepted row-local root execution object to RV64IM execution semantics on the authenticated rows.
- Acceptance fails if any of those fields are missing, malformed, or only summary-shaped.

## Check Targets

- `rootExecutionSemanticsClosureChecks`
- `rootExecutionSemanticsClosureAccepted`
- `missingRootExecutionSemanticsClosureFields`
- `rootExecutionSemanticsRustExportBlockers`
- `uniqueRootExecutionSemanticsRustExportBlockers`
- `validGeneratedRv64imAcceptedArtifactRootExecutionSemanticsClosureCases`

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/Rv64IM/AcceptedArtifactRootLane.lean`
  - `Nightstream/Rv64IM/AcceptedArtifactRootExecutionClosure.lean`
  - `Nightstream/Rv64IM/Kernel/RequiredRootExecutionSemanticsSurface.lean`
  - `Nightstream/Rv64IM/Checks.lean`
- **Consumed by**:
  - RV64IM proof-completeness audit
  - future exact-trace closure rewiring away from direct `StepComposition` acceptance

## Out of Scope

- proving the SuperNeo backend theorems themselves
- Rust-side payload generation
- the final selected-row/opening kernel-design bridge

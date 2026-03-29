# Rv64IMAcceptedArtifactRootExecutionClosure Spec

## Purpose

- **What it is**: The executable RV64IM audit that checks whether the exported accepted artifact carries enough low-level structure for Lean to instantiate the theorem-owned `ChunkedRootProofPackage`.
- **What it is not**: It is not a digest-parity check and it does not treat a summary-shaped main-lane bundle as a root execution proof.
- **Protocol role**: It closes only the first gap between the theorem-facing root execution owner and the Rust-exported artifact boundary: construction of the schedule-bearing chunk/root proof package itself. The later semantic step from accepted row-local root execution objects to RV64IM execution correctness is a separate closure surface.

## Target Conditions

- Lean can replay execution rows from the exported source case.
- Lean can recompute the root-lane protocol bindings from those replayed rows and match them exactly against the exported artifact.
- Fold schedule, public-step count, and chunk layout align across the exported root/main-lane surfaces.
- The artifact exposes theorem-bearing chunk and main-lane backend payload surfaces rather than digest-only summaries.
- The artifact carries enough structure to reconstruct the SuperNeo contexts and theorem statements required by `ChunkedRootProofPackage`.
- Acceptance fails if any of those fields are missing, malformed, or only summary-shaped.

## Theorem and Check Targets

- `rootExecutionClosureChecks`
- `rootExecutionClosureAccepted`
- `missingRootExecutionClosureFields`
- `validGeneratedRv64imAcceptedArtifactRootExecutionClosureCases`

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/Rv64IM/AcceptedArtifactRootLane.lean`
  - `Nightstream/Rv64IM/AcceptedArtifactBackendRefinement.lean`
  - `Nightstream/Rv64IM/Checks.lean`
- **Consumed by**:
  - RV64IM proof-completeness audit
  - future accepted-checker refinement into the theorem-owned root execution proof

## Out of Scope

- proving the SuperNeo backend theorems themselves
- Rust-side payload generation
- final Nightstream bridge closure

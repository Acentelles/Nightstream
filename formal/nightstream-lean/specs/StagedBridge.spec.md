# StagedBridge Spec

## Purpose

- **What it is**: The generic Nightstream staged bridge artifact above a canonical release shape and below VM-specific staged refinements.
- **What it is not**: It is not a VM execution theorem and it does not restate the final packaged-proof boundary.
- **Protocol role**: It fixes the exact staged artifact that the backend may consume: schedule-bearing public bridge view, exact prepared-step export, one exact prepared-trace witness, and one ordered typed payload per canonical stage.

## Target Formulas

Assume one fixed release shape `shape`.

Define the canonical typed stage-payload trace:

$$
\mathrm{CanonicalStagePayloads}(shape, P)
:=
\{
payloads\ |\ \mathrm{map}(\pi_1,\ payloads) = shape.\mathrm{stageOrder}
\}.
$$

Each entry carries one stage tag together with one stage-local payload:

$$
payloads_i = (s_i,\ p_i),\qquad p_i : P(s_i).
$$

Define the staged bridge artifact:

$$
\mathrm{StagedBridgeArtifact}(shape,\ B,\ P)
:=
(view,\ steps,\ trace,\ payloads),
$$

such that:

$$
\mathrm{ReleaseBridgePublicViewBound}(shape,\ view,\ |steps|)
$$

$$
\land\ B(trace,\ steps)
$$

$$
\land\ payloads \in \mathrm{CanonicalStagePayloads}(shape,\ P).
$$

The theorem-facing constructor target is:

$$
\mathrm{Valid}(schedule)
\land
B(trace,\ steps)
\land
payloads \in \mathrm{CanonicalStagePayloads}(shape,\ P)
\Longrightarrow
\mathrm{StagedBridgeArtifact}(shape,\ B,\ P).
$$

The artifact must preserve:

$$
view.\mathrm{preparedStepCount} = |steps|,
$$

$$
view.\mathrm{stages} = \mathrm{canonicalStageViews}(shape),
$$

$$
|payloads| = |shape.\mathrm{stageOrder}|.
$$

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Typed payload trace | `CanonicalStagePayloads` | def | Definitional | Packages one exact typed payload per canonical stage in canonical order |
| Length | `CanonicalStagePayloads.length` | def | Definitional | Reports typed stage-payload count |
| Theorem | `canonicalStagePayloads_length_eq` | theorem | Theorem-Target | Canonical payload traces stay aligned with the stage order |
| Artifact | `StagedBridgeArtifact` | structure | Definitional | Packages the exact public bridge view, prepared-step export, prepared-trace witness, and stage payload trace |
| Constructor | `stagedBridgeArtifact_of_parts` | def | Theorem-Target | Exact schedule, trace, and payload data yield the staged artifact |
| Theorem | `chunkCount_matches_schedule` | theorem | Theorem-Target | Public chunk count is derived from the public fold schedule |
| Theorem | `foldSchedule_valid` | theorem | Theorem-Target | Every staged artifact exposes an admissible fold schedule |
| Theorem | `preparedStepCount_matches_publicView` | theorem | Theorem-Target | The public bridge view reports the exact prepared-step count |
| Theorem | `publicStages_eq_canonical` | theorem | Theorem-Target | The public bridge view exposes the canonical stage view list |
| Theorem | `stagePayloadCount_matches_stageOrder` | theorem | Theorem-Target | Stage payload count matches the canonical stage order length |

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/ReleaseBridge.lean`
- **Consumed by**:
  - later VM-specific staged bridge refinements
  - later Rust refinement for `bridge/mod.rs` and `pipeline/mod.rs`

## Proof Obligations

- The backend may consume only typed payloads aligned to canonical stage order.
- The staged bridge must preserve exact prepared-step count and exact fold cadence; no compatibility-only view may weaken either.
- Any VM-specific staged bridge must refine this generic artifact rather than invent a new public view.

## Out of Scope

- VM-specific stage payload semantics
- prepared-step correctness theorems
- transcript / PCS instantiation
- final proof digest and opening artifact packaging

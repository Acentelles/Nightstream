# Rv64IMStagedBridge Spec

## Purpose

- **What it is**: The concrete VM-local staged-bridge artifact surface for RV64IM above the concrete release bridge and below later execution/trace/kernel closure.
- **What it is not**: It is not a proof of fetch/decode correctness, Twist temporal consistency, or kernel soundness.
- **Protocol role**: It fixes the exact RV64IM public bridge view shape, its explicit fold cadence, and the exact three-payload staged artifact boundary that later RV64IM theorems must populate.

## Target Formulas

Reuse the concrete release-stage inventory from `Rv64IMReleaseBridge`.

Define the VM-local stage-view list:

$$
\mathrm{canonicalStageViews}_{\mathrm{Rv64IM}}
=
\mathrm{map}
(\lambda s.\ (s,\ \mathrm{stageFamilies}(s)))
(\mathrm{releaseStageOrder}).
$$

Define the VM-local public bridge view:

$$
\mathrm{ReleaseBridgePublicView}_{\mathrm{Rv64IM}}
=
(\mathrm{foldSchedule},\ \mathrm{chunkCount},\ \mathrm{preparedStepCount},\ \mathrm{stages}),
$$

with exact realization predicate:

$$
\mathrm{ReleaseBridgePublicViewBound}_{\mathrm{Rv64IM}}(view, n)
\iff
\mathrm{Valid}(view.\mathrm{foldSchedule})
\land
view.\mathrm{chunkCount} =
\mathrm{chunkCount}(view.\mathrm{foldSchedule}, n)
\land
view.\mathrm{preparedStepCount} = n
\land
view.\mathrm{stages} = \mathrm{canonicalStageViews}_{\mathrm{Rv64IM}}.
$$

The schedule-parameterized public-view constructor is:

$$
\mathrm{releaseBridgePublicView\_of\_schedule}(schedule, n).
$$

The canonical no-argument helper is the whole-trace default:

$$
\mathrm{releaseBridgePublicView\_of\_preparedStepCount}(n)
=
\mathrm{releaseBridgePublicView\_of\_schedule}(\mathrm{WholeTrace}, n).
$$

Define the exact staged payload inventory indexed by the release stage:

$$
\mathrm{StagePayload}_{\mathrm{Rv64IM}}
:
\mathrm{ReleaseStage}_{\mathrm{Rv64IM}} \to \mathrm{Type},
$$

with one payload for `readonlyBatch`, one for `registerHistory`, and one for
`ramHistory`.

Define the staged artifact target:

$$
\mathrm{StagedBridgeArtifact}_{\mathrm{Rv64IM}}
=
(\mathrm{publicView},\ \mathrm{preparedSteps},\ \mathrm{preparedTrace},\ \mathrm{readonlyBatch},\ \mathrm{registerHistory},\ \mathrm{ramHistory}),
$$

together with:

- an exact prepared-trace bound over `preparedTrace` and `preparedSteps`, and
- an exact public-view bound tying `publicView` to `preparedSteps.length`.

The canonical constructor target is:

$$
\mathrm{ReleaseBridgePublicViewBound}_{\mathrm{Rv64IM}}
(\mathrm{releaseBridgePublicView\_of\_preparedStepCount}(n),\ n).
$$

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Stage view | `ReleaseStageView` | structure | Definitional | Packages one RV64IM stage and its exact family inventory |
| Canonical stage list | `canonicalStageViews` | def | Definitional | Fixes the ordered RV64IM stage-view list |
| Public view | `ReleaseBridgePublicView` | structure | Definitional | Packages chunk count, prepared-step count, and stage list |
| Predicate | `ReleaseBridgePublicViewBound` | def | Definitional | States the exact RV64IM public-view contract |
| Constructor | `releaseBridgePublicView_of_schedule` | def | Definitional | Canonical RV64IM public bridge view for one explicit fold schedule |
| Constructor | `releaseBridgePublicView_of_preparedStepCount` | def | Definitional | Canonical RV64IM public bridge view |
| Theorem | `releaseBridgePublicViewBound_of_schedule` | theorem | Theorem-Target | Any admissible explicit fold schedule yields the RV64IM public-view contract |
| Theorem | `releaseBridgePublicViewBound_of_preparedStepCount` | theorem | Theorem-Target | Canonical constructor satisfies the exact public-view contract |
| Theorem | `foldSchedule_eq_wholeTrace_of_preparedStepCount` | theorem | Theorem-Target | The canonical RV64IM helper is explicitly whole-trace folding |
| Theorem | `canonicalStageViews_stage_eq` | theorem | Theorem-Target | Every RV64IM release stage appears in the canonical stage-view list |
| Stage payload | `StagePayload` | inductive | Definitional | Fixes the exact per-stage payload inventory of the RV64IM staged bridge |
| Staged artifact | `StagedBridgeArtifact` | structure | Definitional | Packages prepared steps, prepared trace, and one payload per canonical stage |
| Constructor | `stagedBridgeArtifact_of_parts` | def | Definitional | Canonical constructor for the VM-local staged artifact |
| Theorem | `chunkCount_matches_schedule` | theorem | Theorem-Target | Every well-formed RV64IM staged artifact exposes the exact chunk count implied by its fold schedule |
| Theorem | `foldSchedule_valid` | theorem | Theorem-Target | Every well-formed RV64IM staged artifact exposes an admissible fold schedule |
| Theorem | `preparedStepCount_matches_publicView` | theorem | Theorem-Target | The public view exposes the exact prepared-step count |
| Theorem | `publicStages_eq_canonical` | theorem | Theorem-Target | The public view exposes the exact canonical stage list |

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/StagedBridge.lean`
  - `Nightstream/Rv64IM/ReleaseBridge.lean`
- **Consumed by**:
  - `Nightstream/Rv64IM/VmBridgeRefinement.lean`
  - later RV64IM execution / trace / kernel bridge owners

## Proof Obligations

- The VM-local RV64IM public bridge view must expose exactly the canonical stage inventory and an explicit fold schedule.
- The staged artifact must package exactly one readonly payload, one register-history payload, and one RAM-history payload.
- The canonical default is whole-trace folding; smaller chunk schedules are explicit alternates, not implicit conventions.
- No compatibility-mode bit or extra stage may appear at this layer.

## Out of Scope

- the semantics of any payload
- exact prepared-step rows
- trace closure
- kernel soundness

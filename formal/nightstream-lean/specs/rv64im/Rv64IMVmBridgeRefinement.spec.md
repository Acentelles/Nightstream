# Rv64IMVmBridgeRefinement Spec

## Purpose

- **What it is**: The concrete refinement surface showing that the RV64IM VM-local bridge is an exact instance of the generic Nightstream bridge.
- **What it is not**: It is not an RV64IM execution theorem and it does not prove stage-local payload correctness.
- **Protocol role**: It fixes the exact translation from RV64IM-local bridge views and staged artifacts into the canonical Nightstream `ReleaseBridge` and `StagedBridge` surfaces.

## Target Formulas

Let `releaseShape` be the concrete RV64IM release shape from
`Rv64IMReleaseBridge`.

Define the stage-view translation:

$$
\mathrm{toGenericReleaseStageView}
:
\mathrm{ReleaseStageView}_{\mathrm{Rv64IM}}
\to
\mathrm{ReleaseStageView}(\mathrm{releaseShape}).
$$

Define the public-view translation:

$$
\mathrm{toGenericPublicView}
:
\mathrm{ReleaseBridgePublicView}_{\mathrm{Rv64IM}}
\to
\mathrm{ReleaseBridgePublicView}(\mathrm{releaseShape}).
$$

The exact release-bridge refinement target is:

$$
\mathrm{RefinesReleaseBridge}
(\mathrm{releaseShape},\ \mathrm{toGenericReleaseStageView},\ \mathrm{canonicalStageViews}_{\mathrm{Rv64IM}},\ \mathrm{toGenericPublicView},\ \mathrm{ReleaseBridgePublicViewBound}_{\mathrm{Rv64IM}}).
$$

So the theorem-facing consequences are:

$$
\mathrm{map}(\mathrm{toGenericReleaseStageView},\ \mathrm{canonicalStageViews}_{\mathrm{Rv64IM}})
=
\mathrm{canonicalStageViews}(\mathrm{releaseShape}),
$$

and

$$
\mathrm{ReleaseBridgePublicViewBound}_{\mathrm{Rv64IM}}(view, n)
\Longrightarrow
\mathrm{ReleaseBridgePublicViewBound}(\mathrm{releaseShape},\ \mathrm{toGenericPublicView}(view),\ n).
$$

For staged artifacts, define the generic stage-payload translation target:

$$
\mathrm{canonicalStagePayloads\_of\_artifact}(artifact)
:
\mathrm{CanonicalStagePayloads}
(\mathrm{releaseShape.stageOrder},\ \mathrm{StagePayload}_{\mathrm{Rv64IM}}),
$$

and define the exact generic staged-artifact projection:

$$
\mathrm{toGenericStagedBridgeArtifact}(artifact)
:
\mathrm{StagedBridgeArtifact}
(\mathrm{releaseShape},\ \mathrm{PreparedTraceBound},\ \mathrm{StagePayload}_{\mathrm{Rv64IM}}).
$$

Its public view must satisfy:

$$
\mathrm{ReleaseBridgePublicViewBound}
(\mathrm{releaseShape},\ \mathrm{toGenericStagedBridgeArtifact}(artifact).\mathrm{publicView},\ artifact.\mathrm{preparedSteps.length}).
$$

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Translation | `toGenericReleaseStageView` | def | Definitional | Erases RV64IM-local stage views into the generic stage-view surface |
| Translation | `toGenericPublicView` | def | Definitional | Erases RV64IM-local public views into the generic public-view surface |
| Theorem | `canonicalStageViews_refine` | theorem | Theorem-Target | RV64IM canonical stage views equal the generic canonical stage views after translation |
| Theorem | `toGenericPublicView_of_schedule` | theorem | Theorem-Target | The RV64IM explicit schedule constructor matches the generic constructor exactly |
| Theorem | `toGenericPublicView_of_preparedStepCount` | theorem | Theorem-Target | The RV64IM canonical public-view constructor matches the generic constructor exactly |
| Theorem | `releaseBridge_refines_generic` | theorem | Theorem-Target | The concrete RV64IM release bridge exactly refines the generic Nightstream release bridge |
| Theorem | `publicViewBound_refines` | theorem | Theorem-Target | Every well-formed RV64IM public view satisfies the generic public-view contract |
| Constructor | `canonicalStagePayloads_of_artifact` | def | Definitional | Packages one generic canonical stage payload per RV64IM stage |
| Constructor | `toGenericStagedBridgeArtifact` | def | Definitional | Projects an RV64IM VM-local staged artifact into the generic staged bridge |
| Theorem | `toGenericStagedBridgeArtifact_publicViewBound` | theorem | Theorem-Target | The projected generic staged artifact exposes the exact generic public-view contract |

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/VmBridgeRefinement.lean`
  - `Nightstream/Rv64IM/StagedBridge.lean`
- **Consumed by**:
  - later RV64IM execution / trace / kernel bridge refinement theorems
  - later Rust refinement work for a generic staged bridge

## Proof Obligations

- RV64IM must refine the generic bridge by exact preservation of stage order, prepared-step count, and fold schedule.
- The RV64IM staged artifact may enter the generic staged bridge only by supplying exactly one payload for each canonical stage.
- The generic projection must be conservative: it may erase RV64IM-local names, but it may not alter the public bridge facts.

## Out of Scope

- execution-row semantics
- Stage-1 / Stage-2 / Stage-3 closure
- transcript / PCS instantiation
- final kernel theorem

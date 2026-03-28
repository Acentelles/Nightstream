# ReleaseBridge Spec

## Purpose

- **What it is**: The generic Nightstream release-path bridge surface above family classification and below any VM-specific staged bridge.
- **What it is not**: It is not a VM-specific theorem and it does not restate final proof packaging.
- **Protocol role**: It fixes the canonical stage order, the exact family inventory per stage, the theorem-owned fold cadence, and the public bridge view shape that the backend may consume.

## Target Formulas

Define the generic release shape:

$$
\mathrm{ReleaseShape}
:=
(\mathrm{stageOrder},\ \mathrm{familyStage},\ \mathrm{stageFamilies}).
$$

Define exact stage-inventory consistency:

$$
\mathrm{StageInventoryConsistent}(shape)
\iff
\forall f,s,\;
f \in shape.\mathrm{stageFamilies}(s)
\iff
shape.\mathrm{familyStage}(f) = s.
$$

Define the canonical view of one stage:

$$
\mathrm{ReleaseStageView}(shape, s)
:=
(s,\ shape.\mathrm{stageFamilies}(s)).
$$

Define the canonical bridge-stage list:

$$
\mathrm{canonicalStageViews}(shape)
:=
\mathrm{map}
(\lambda s.\ \mathrm{ReleaseStageView}(shape, s))
(shape.\mathrm{stageOrder}).
$$

Reuse the theorem-owned fold cadence object from `FoldSchedule`:

$$
\mathrm{FoldSchedule}
:=
\{
\mathrm{WholeTrace},
\mathrm{RowsPerChunk}(r)
\}.
$$

Define the generic public release-bridge view:

$$
\mathrm{ReleaseBridgePublicView}
=
(\mathrm{foldSchedule},\ \mathrm{chunkCount},\ \mathrm{preparedStepCount},\ \mathrm{stages}).
$$

Its exact realization predicate is:

$$
\mathrm{ReleaseBridgePublicViewBound}(shape, view, n)
\iff
 \mathrm{Valid}(view.\mathrm{foldSchedule})
\land
view.\mathrm{chunkCount} =
\mathrm{chunkCount}(view.\mathrm{foldSchedule}, n)
\land
view.\mathrm{preparedStepCount} = n
\land
view.\mathrm{stages} = \mathrm{canonicalStageViews}(shape).
$$

The schedule-parameterized constructor target is:

$$
\mathrm{Valid}(schedule)
\Longrightarrow
\mathrm{ReleaseBridgePublicViewBound}
(shape,\ \mathrm{releaseBridgePublicView\_of\_schedule}(shape, schedule, n),\ n).
$$

The canonical whole-trace constructor target is:

$$
\mathrm{ReleaseBridgePublicViewBound}
(shape,\ \mathrm{releaseBridgePublicView\_of\_preparedStepCount}(shape, n),\ n).
$$

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Release shape | `ReleaseShape` | structure | Definitional | Packages the exact stage order and exact `family -> stage` / `stage -> families` bridge data |
| Consistency | `StageInventoryConsistent` | def | Definitional | States exact agreement between `familyStage` and `stageFamilies` |
| Stage view | `ReleaseStageView` | structure | Definitional | Packages one stage together with its exact family inventory |
| Constructor | `releaseStageView` | def | Definitional | Canonical view for one stage |
| Canonical stages | `canonicalStageViews` | def | Definitional | Fixes the ordered stage view list used by the bridge |
| Theorem | `mem_stageFamilies_iff` | theorem | Theorem-Target | Under exact consistency, stage membership is equivalent to the family-stage map |
| Theorem | `canonicalStageViews_stage_eq` | theorem | Theorem-Target | Every staged element in `stageOrder` appears in the canonical stage-view list |
| Public view | `ReleaseBridgePublicView` | structure | Definitional | Packages the exact public bridge counts and stage inventory |
| Predicate | `ReleaseBridgePublicViewBound` | def | Definitional | States the exact public-view contract |
| Constructor | `releaseBridgePublicView_of_schedule` | def | Definitional | Canonical public bridge view for one explicit fold schedule |
| Constructor | `releaseBridgePublicView_of_preparedStepCount` | def | Definitional | Canonical public bridge view for one prepared-step count |
| Theorem | `releaseBridgePublicViewBound_of_schedule` | theorem | Theorem-Target | Any admissible explicit fold schedule yields the exact public-view contract |
| Theorem | `releaseBridgePublicViewBound_of_preparedStepCount` | theorem | Theorem-Target | The canonical constructor satisfies the exact public-view contract |
| Theorem | `foldSchedule_eq_wholeTrace_of_preparedStepCount` | theorem | Theorem-Target | The no-argument canonical helper is explicitly whole-trace folding |
| Theorem | `chunkCount_eq_one_of_preparedStepCount` | theorem | Theorem-Target | Whole-trace folding yields one public chunk |

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/BridgeTypes.lean`
  - `Nightstream/ShardComposition.lean`
- **Consumed by**:
  - `Nightstream/StagedBridge.lean`
  - later VM-specific release-bridge refinements
  - later Rust refinement for `bridge/mod.rs`

## Proof Obligations

- The public bridge view must carry an explicit theorem-owned fold schedule; cadence may not be inferred from an unexplained constant.
- The release shape must package exact stage order and exact family inventories, not existential coverage.
- Any VM-specific release bridge must refine this surface by instantiating one concrete `ReleaseShape`.

## Out of Scope

- VM-specific stage ids and family names
- prepared-step semantics
- transcript / PCS instantiation
- final proof packaging

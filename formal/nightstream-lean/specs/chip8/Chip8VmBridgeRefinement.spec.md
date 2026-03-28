# Chip8VmBridgeRefinement Spec

## Purpose

- **What it is**: The concrete CHIP-8 refinement owner from the CHIP-8 release/staged bridge surfaces into the generic Nightstream `ReleaseBridge` and `StagedBridge` surfaces.
- **What it is not**: It is not a new CHIP-8 soundness theorem and it does not replace the CHIP-8-local release or staged bridge owners.
- **Protocol role**: It proves that the current CHIP-8 bridge artifacts instantiate one exact generic release shape and one exact generic staged artifact, making CHIP-8 the first concrete witness of the VM-neutral boundary.

## Target Formulas

Define the CHIP-8 canonical stage order:

$$
\mathrm{releaseStageOrder}
=
[\mathrm{ReadonlyBatch},\ \mathrm{RegisterHistory},\ \mathrm{RamHistory}].
$$

Define the CHIP-8 generic release shape:

$$
\mathrm{releaseShape}
:=
(\mathrm{releaseStageOrder},\ \mathrm{familyStage},\ \mathrm{stageFamilies}).
$$

The exact stage-inventory target is:

$$
\mathrm{StageInventoryConsistent}(\mathrm{releaseShape}).
$$

Define the stage-view and public-view translations:

$$
\mathrm{toGenericReleaseStageView} : \mathrm{Chip8ReleaseStageView}
\to \mathrm{ReleaseStageView}(\mathrm{releaseShape}),
$$

$$
\mathrm{toGenericPublicView} : \mathrm{Chip8ReleaseBridgePublicView}
\to \mathrm{ReleaseBridgePublicView}(\mathrm{releaseShape}).
$$

The exact release-bridge refinement target is:

$$
\mathrm{RefinesReleaseBridge}
(
\mathrm{releaseShape},
\mathrm{toGenericReleaseStageView},
\mathrm{Chip8CanonicalStageViews},
\mathrm{toGenericPublicView},
\mathrm{Chip8ReleaseBridgePublicViewBound}
).
$$

For one exact staged artifact `artifact`, define the per-stage payload family:

$$
\mathrm{StagePayload}(artifact) :
\mathrm{ReleaseStage} \to \mathrm{Type},
$$

with one payload constructor for each canonical CHIP-8 release stage:

- `ReadonlyBatchTraceBundle`
- `RegisterHistoryBundle`
- `RamHistoryBundle`

Define the exact canonical stage payload list extracted from one CHIP-8 staged
artifact:

$$
\mathrm{canonicalStagePayloads\_of\_artifact}(artifact)
\in
\mathrm{CanonicalStagePayloads}
(\mathrm{releaseStageOrder},\ \mathrm{StagePayload}(artifact)).
$$

Define the generic staged artifact translation:

$$
\mathrm{toGenericStagedBridgeArtifact}(artifact)
:
\mathrm{StagedBridgeArtifact}
(\mathrm{releaseShape},\ \mathrm{PreparedStepTraceBound},\ \mathrm{StagePayload}(artifact)).
$$

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Stage order | `releaseStageOrder` | def | Definitional | Fixes the exact CHIP-8 stage order used to instantiate the generic release shape |
| Release shape | `releaseShape` | def | Definitional | Instantiates the generic Nightstream release shape with CHIP-8 stage/family data |
| Theorem | `releaseShape_stageInventoryConsistent` | theorem | Theorem-Target | The CHIP-8 release shape satisfies exact generic stage-inventory consistency |
| Translation | `toGenericReleaseStageView` | def | Definitional | Converts one CHIP-8 stage view into the generic release-stage view |
| Translation | `toGenericPublicView` | def | Definitional | Converts one CHIP-8 public bridge view into the generic public bridge view |
| Theorem | `canonicalStageViews_refine` | theorem | Theorem-Target | CHIP-8 canonical stage views equal the generic canonical stage views after translation |
| Theorem | `toGenericPublicView_of_schedule` | theorem | Theorem-Target | The CHIP-8 explicit schedule constructor matches the generic constructor exactly |
| Theorem | `releaseBridge_refines_generic` | theorem | Theorem-Target | The CHIP-8 release bridge refines the generic release bridge |
| Theorem | `publicViewBound_refines` | theorem | Theorem-Target | Any accepted CHIP-8 public bridge view satisfies the generic public-view bound after translation |
| Payload family | `StagePayload` | inductive | Definitional | Splits the CHIP-8 staged artifact into one typed payload per generic stage |
| Constructor | `canonicalStagePayloads_of_artifact` | def | Theorem-Target | One CHIP-8 staged artifact yields one canonical typed stage-payload trace |
| Constructor | `toGenericStagedBridgeArtifact` | def | Theorem-Target | One CHIP-8 staged artifact yields one generic Nightstream staged artifact |

## Dependency and Consumer Map

- **Upstream dependencies**:
  - `Nightstream/VmBridgeRefinement.lean`
  - `Nightstream/Chip8/ReleaseBridge.lean`
  - `Nightstream/Chip8/StagedBridge.lean`
- **Downstream consumers**:
  - later Rust refinement replacing the compatibility export path
  - later RV64 refinement once a second VM is added

## Proof Obligations

- The CHIP-8 refinement owner must preserve exact stage order, exact stage inventories, and exact fold schedule.
- The CHIP-8 refinement owner must split the staged artifact into exact per-stage payloads; the generic artifact may not consume a weaker history digest.
- The translation must remain canonical; no compatibility-only view bit may survive into the generic public bridge view.

## Out of Scope

- adding a second VM
- changing CHIP-8 execution semantics
- transcript / PCS instantiation changes
- final proof packaging

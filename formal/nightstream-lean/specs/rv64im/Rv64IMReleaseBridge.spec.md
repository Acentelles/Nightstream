# Rv64IMReleaseBridge Spec

## Purpose

- **What it is**: The concrete RV64IM instantiation of the generic Nightstream release bridge.
- **What it is not**: It is not the staged bridge artifact and it does not prove any RV64IM instruction semantics.
- **Protocol role**: It fixes the exact RV64IM release-stage order, exact `family -> stage` classification, and exact stage inventory used by later RV64IM staged artifacts.

## Target Formulas

Define the concrete release-stage type:

$$
\mathrm{ReleaseStage}_{\mathrm{Rv64IM}}
\in
\{\mathrm{readonlyBatch},\ \mathrm{registerHistory},\ \mathrm{ramHistory}\}.
$$

Define the exact stage order:

$$
\mathrm{releaseStageOrder}
=
[\mathrm{readonlyBatch},\ \mathrm{registerHistory},\ \mathrm{ramHistory}].
$$

Define the exact family classification:

$$
\mathrm{familyStage}(\mathrm{fetch}) = \mathrm{readonlyBatch},
$$

$$
\mathrm{familyStage}(\mathrm{executionRow}) = \mathrm{readonlyBatch},
$$

$$
\mathrm{familyStage}(\mathrm{aluSubtables}) = \mathrm{readonlyBatch},
$$

$$
\mathrm{familyStage}(\mathrm{branchCondition}) = \mathrm{readonlyBatch},
$$

$$
\mathrm{familyStage}(\mathrm{registerHistory}) = \mathrm{registerHistory},
$$

$$
\mathrm{familyStage}(\mathrm{ramHistory}) = \mathrm{ramHistory}.
$$

Define the exact stage-family inventory:

$$
\mathrm{stageFamilies}(\mathrm{readonlyBatch})
=
[\mathrm{fetch},\ \mathrm{executionRow},\ \mathrm{aluSubtables},\ \mathrm{branchCondition}],
$$

$$
\mathrm{stageFamilies}(\mathrm{registerHistory})
=
[\mathrm{registerHistory}],
$$

$$
\mathrm{stageFamilies}(\mathrm{ramHistory})
=
[\mathrm{ramHistory}].
$$

The release shape target is:

$$
\mathrm{releaseShape}_{\mathrm{Rv64IM}}
:=
(\mathrm{releaseStageOrder},\ \mathrm{familyStage},\ \mathrm{stageFamilies}),
$$

and it must satisfy exact stage-inventory consistency:

$$
\mathrm{StageInventoryConsistent}(\mathrm{releaseShape}_{\mathrm{Rv64IM}}).
$$

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Stage type | `ReleaseStage` | inductive | Definitional | Fixes the exact RV64IM release-stage ids |
| Stage order | `releaseStageOrder` | def | Definitional | Fixes the canonical RV64IM stage order |
| Classification | `familyStage` | def | Definitional | Fixes the exact family-to-stage map |
| Inventory | `stageFamilies` | def | Definitional | Fixes the exact per-stage family inventory |
| Theorem | `mem_stageFamilies_iff` | theorem | Theorem-Target | Stage membership agrees exactly with `familyStage` |
| Theorem | `family_mem_stageFamilies` | theorem | Theorem-Target | Every RV64IM family appears in its canonical stage |
| Release shape | `releaseShape` | def | Definitional | Packages the exact RV64IM release bridge for generic consumers |
| Theorem | `releaseShape_stageInventoryConsistent` | theorem | Theorem-Target | The concrete RV64IM release shape satisfies exact inventory consistency |

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/ReleaseBridge.lean`
  - `Nightstream/Rv64IM/ExtensionFamily.lean`
- **Consumed by**:
  - `Nightstream/Rv64IM/StagedBridge.lean`
  - `Nightstream/Rv64IM/VmBridgeRefinement.lean`
  - later RV64IM stage-local release owners

## Proof Obligations

- The readonly release stage must own only readonly Stage-1 proof families.
- Register and RAM temporal families must remain separated at the release boundary.
- The concrete RV64IM release shape must refine the generic Nightstream release-bridge surface by exact equality, not heuristic correspondence.

## Out of Scope

- readonly batch witness structure
- prepared-step trace semantics
- execution-row correctness
- transcript / PCS instantiation

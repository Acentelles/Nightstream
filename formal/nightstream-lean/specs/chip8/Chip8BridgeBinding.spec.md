# Chip8BridgeBinding Spec

## Purpose

- **What it is**: The exact per-row audit/provenance owner tying an
  authenticated Stage-3 row-binding claim to the exported prepared step for
  that row.
- **Key property**: `exists_bridgeBindingWitness_of_exactEvidence`: exact
  authenticated staged evidence determines an explicit bridge-binding witness
  for the row currently being exported.
- **Protocol role**: This is the theorem-facing owner for the audit objects
  called out by the CHIP-8 kernel spec between Stage 3 row claims and exported
  bridge payloads. Its leaves must point not only to the direct row-binding
  claim but also to the verified PCS refinement path for that claim. It does
  not re-own Stage-1 / Stage-2 / Stage-3 semantic closure.

## Target Formulas

### Row-projection witness

The kernel audit trail needs an explicit authenticated row-projection witness.
This owner must expose that witness from exact semantic evidence:

$$
\mathrm{ExactSemanticEvidenceCovered}(\dots)
\Longrightarrow
\exists \Gamma_1,\ row,\ ref,\
\mathrm{RowProjectionWitness}(\Gamma_1, ref, row).
$$

This is a provenance object. It is not a new semantic theorem.

### Bridge-binding witness

Define:

$$
\mathrm{BridgeBindingWitness}(stepIdx, z, rowClaim, ref, preparedStep)
$$

to mean the conjunction of:

- `rowClaim.rowIndex = stepIdx`
- `RowBound(rowClaim, z)`
- `ref` is the verified opening refinement for `rowClaim`
- `PreparedStepBound(z, preparedStep)`

This owner packages exactly the explicit per-row audit object connecting the
authenticated row-binding claim and its verified refinement path to the
exported prepared step.

### Existence from authenticated evidence

The main theorem target is:

$$
\mathrm{SemanticEvidenceCovered}(\dots)
\Longrightarrow
\exists rowClaim,\ ref,\
\mathrm{BridgeBindingWitness}(stepIdx, z, rowClaim, ref, \mathrm{mkPreparedStep}(z)).
$$

and likewise for `ExactSemanticEvidenceCovered`.

### Projection theorems

From one realized bridge-binding witness, downstream users must be able to
recover:

$$
\mathrm{BridgeBindingWitness}(\dots)
\Longrightarrow
\mathrm{RowBound}(rowClaim, z)
$$

and:

$$
\mathrm{BridgeBindingWitness}(\dots)
\Longrightarrow
\mathrm{PreparedStepBound}(z, preparedStep).
$$

## Paper Anchors

- **Sources**:
  - `./crates/neo-fold-next/specs/chip8-kernel.md`
  - `./docs/soundness-specs/twist-and-shout-requirements.md`
  - `./docs/assurance-strategy.md`
- Anchors:
  - Stage-3 row binding
  - exported prepared-step bridge payload
  - explicit row-projection / bridge-binding audit trail

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Chip8/BridgeBinding.lean` | Per-row projection and bridge-binding audit witnesses |
| `Nightstream/Chip8/BridgeBindingInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Witness | `BridgeBindingWitness` | structure | Definitional | Packages the exact row-claim, verified refinement, and prepared-step audit object |
| Theorem | `rowBound_of_bridgeBinding` | theorem | Theorem-Target | Recovers the authenticated row-binding theorem |
| Theorem | `preparedStepBound_of_bridgeBinding` | theorem | Theorem-Target | Recovers the exported prepared-step theorem |
| Theorem | `exists_rowProjection_of_semanticEvidence` | theorem | Theorem-Target | Authenticated semantic evidence exports the row-projection witness |
| Theorem | `exists_rowProjection_of_exactEvidence` | theorem | Theorem-Target | Exact authenticated evidence exports the row-projection witness |
| Theorem | `exists_bridgeBindingWitness_of_semanticEvidence` | theorem | Theorem-Target | Authenticated semantic evidence exports the bridge-binding witness |
| Theorem | `exists_bridgeBindingWitness_of_exactEvidence` | theorem | Theorem-Target | Exact authenticated evidence exports the bridge-binding witness |

## Proof Obligations

- Keep row projection and bridge binding separate; they are distinct audit
  objects in the kernel spec.
- Do not smuggle new semantic closure into this owner.
- The witness must tie directly to the authenticated `RowBound` and the
  exported `PreparedStepBound`.
- The witness must also carry the verified refinement path for the row-binding
  claim, not only the direct claim digest.
- This owner must remain row-local; it must not silently upgrade one witness
  into a whole-trace theorem.

## Assumption Ledger

- Lower-layer PCS opening refinement and semantic evidence extraction are
  imported.
- The concrete operational policy for when these audit objects are checked is
  outside this module.

## Dependency and Consumer Map

- **Upstream dependencies**:
  - `Nightstream/Chip8/EvidenceCoverage.lean`
  - `Nightstream/Chip8/ContinuityBridge.lean`
- **Downstream consumers**:
  - `Nightstream/Chip8/StagedExecutionDigest.lean`
  - `Nightstream/Chip8/ArtifactAudit.lean`
  - later Rust/Lean artifact refinement work

# Rv64IMOpeningProvenance Spec

## Purpose

- **What it is**: The theorem-facing contract for the opening-provenance chain from committed openings to prepared-step binding.
- **What it is not**: It is not the PCS protocol and it does not define execution semantics.
- **Protocol role**: It fixes the exact owner chain that carries one kernel opening claim into row projection, bridge binding, and prepared-step binding.

## Target Formulas

Fix:

- `OpeningClaim`
- `ExactOpeningWitness`
- `OpeningRefinement`
- `RowProjectionWitness`
- `BridgeBinding`
- `PreparedStep`

The provenance target is:

$$
\mathrm{OpeningProvenanceValid}
(\mathrm{exactOpening},\ \mathrm{refinesOpening},\ \mathrm{projectsRow},\ \mathrm{bindsBridge},\ \mathrm{bindsPreparedStep},\ \mathrm{chain})
$$

meaning:

each step in the opening-provenance chain is justified explicitly:

$$
\mathrm{OpeningClaim}
\to
\mathrm{ExactOpeningWitness}
\to
\mathrm{OpeningRefinement}
\to
\mathrm{RowProjectionWitness}
\to
\mathrm{BridgeBinding}
\to
\mathrm{PreparedStep}.
$$

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/OpeningProvenance.lean` | Opening-provenance theorem surface |
| `Nightstream/Rv64IM/Kernel/OpeningProvenanceInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Guarantee |
|---|---|---|---|
| Claim | `OpeningClaim` | structure | Packages one direct kernel opening claim |
| Metadata | `OpeningProvenanceChain` | structure | Packages the exact provenance chain |
| Semantics | `OpeningProvenanceValid` | def | States explicit validity of each provenance step |
| Package | `OpeningProvenanceProofPackage` | structure | Packages the accepted provenance theorem target |

## Proof Obligations

- Opening verification, row projection, bridge binding, and prepared-step binding remain explicit and non-collapsed.
- The provenance chain is a soundness-carrying owner boundary, not implementation detail.

## Out of Scope

- PCS soundness
- row-local CCS semantics

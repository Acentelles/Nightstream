# PCSOpeningSemantics Spec

## Purpose

- **What it is**: The theorem-facing refinement layer between lower-layer PCS
  opening witnesses and the raw scalar opening values consumed by Nightstream.
- **Key property**: `rawOpeningSeparation_of_refinement`: if a raw opened scalar
  is refined by a lower-layer opening witness, then the scalar value is
  extracted from that witness while the norm bound remains a property of the
  decomposed opening witness itself.
- **Protocol role**: This is the layer that rules out confusion between raw
  scalar evaluations and decomposed Ajtai opening/norm objects.

## Target Formulas

### Raw scalar claims

Define:

$$
\mathrm{RawScalarClaim}(family, point, value)
$$

to be the theorem-facing object consumed by higher-level Nightstream modules.
It contains:

- a polynomial/value family identifier
- an evaluation point
- the raw field scalar value used by the semantic theorem

### Lower-layer opening witness

Import the lower-layer Ajtai opening relation through:

$$
\mathrm{OpeningWitness}(params)
$$

containing:

- a commitment object
- an opening object
- a proof that the opening satisfies the lower-layer `opensTo` relation

### Extraction relation

Let:

$$
\mathrm{extract} : Commitment \to Opening \to Family \to Point \to F
$$

be the lower-layer evaluator used to recover one raw scalar from one committed
surface and one opening witness.

Define:

$$
\mathrm{extractsRawScalar}(\mathrm{extract}, witness, claim)
\iff
claim.value =
\mathrm{extract}(witness.commitment, witness.opening, claim.family, claim.point).
$$

### Refinement package

Define:

$$
\mathrm{OpeningRefinement}(params, \mathrm{extract}, claim)
$$

to package:

- one lower-layer opening witness
- one proof that the raw scalar claim is exactly extracted from that witness

### Separation theorem surface

Define:

$$
\mathrm{RawOpeningSeparation}(params, \mathrm{extract}, claim)
$$

to mean that there exists an `OpeningRefinement` for `claim` and:

- the raw scalar value equals the extractor result
- the lower-layer `Opening.NormSound` predicate holds for the decomposed
  opening witness

The key theorem is:

$$
\mathrm{OpeningRefinement}(params, \mathrm{extract}, claim)
\Longrightarrow
\mathrm{RawOpeningSeparation}(params, \mathrm{extract}, claim).
$$

This is the exact theorem-facing statement that the norm bound applies to the
decomposed opening witness, not to the raw scalar value itself.

## Paper Anchors

- **Sources**:
  - `./formal/superneo-lean/specs/SecurityModel.spec.md`
  - `./docs/soundness-specs/twist-and-shout-requirements.md`
- Anchors:
  - lower-layer Ajtai opening witness semantics
  - separation between authenticated opening objects and the raw scalar values
    consumed by higher-level kernel theorems

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/PCSOpeningSemantics.lean` | Raw-scalar to lower-layer opening refinement theorems |
| `Nightstream/PCSOpeningSemanticsInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Raw claims | `RawScalarClaim` | def | Definitional | Higher-level raw scalar opening object |
| Lower layer | `OpeningWitness` | def | Definitional | Lower-layer commitment/opening witness with `opensTo` proof |
| Refinement | `extractsRawScalar` | def | Definitional | Raw scalar equals the evaluator result of the lower-layer opening witness |
| Refinement | `OpeningRefinement` | def | Definitional | Packages one lower-layer witness with one exact extraction proof |
| Separation | `RawOpeningSeparation` | def | Definitional | States that extraction and opening-norm soundness are both available and remain distinct |
| Theorem | `commitmentWellFormed_of_refinement` | theorem | Theorem-Target | Refinement exposes lower-layer commitment well-formedness |
| Theorem | `openingWellFormed_of_refinement` | theorem | Theorem-Target | Refinement exposes lower-layer opening well-formedness |
| Theorem | `openingNormSound_of_refinement` | theorem | Theorem-Target | Refinement exposes lower-layer opening norm soundness |
| Theorem | `rawScalarMatches_of_refinement` | theorem | Theorem-Target | Refinement exposes the exact raw scalar value |
| Theorem | `rawOpeningSeparation_of_refinement` | theorem | Theorem-Target | Refinement yields the explicit raw-vs-decomposed separation statement |

## Proof Obligations

- The module must keep the raw scalar claim and the lower-layer opening witness
  as distinct theorem objects.
- `Opening.NormSound` must apply only to the decomposed opening witness, never
  directly to the raw scalar claim.
- The bridge from opening witness to raw scalar value must be explicit through
  `extractsRawScalar`; it may not be hidden behind prose or unchecked
  existential packaging.

## Assumption Ledger

- Lower-layer PCS soundness and Ajtai security are imported from
  `superneo-lean`.
- This module owns only the refinement boundary between those lower-layer
  opening objects and the raw scalars consumed by Nightstream.

## Dependency and Consumer Map

- **Upstream dependencies**:
  - `SuperNeo/PolynomialBridge.lean`
  - `SuperNeo/ProofSystem/Lattice.lean`
- **Downstream consumers**:
  - `Nightstream/Chip8/EvidenceCoverage.lean`
  - later bridge/refinement theorems that bind CHIP-8 claim objects to lower
    layer PCS witnesses

## Implementation Plan

1. Define the raw scalar claim object.
2. Define the lower-layer opening witness package.
3. Define the extraction/refinement relation.
4. Prove the explicit raw-vs-decomposed separation theorem.

## Quality Expectations

- Keep the module generic and lower-layer facing.
- Do not mix CHIP-8-specific semantics into this module.
- Keep the norm boundary mechanically obvious.

## Acceptance Criteria

1. `lake build Nightstream.PCSOpeningSemantics` succeeds.
2. The theorem surface makes raw scalar values and decomposed opening witnesses
   explicit and distinct.
3. No `sorry`.

## Out of Scope

- proving higher-level CHIP-8 row semantics
- proving ROM/schedule authentication
- proving PCS security or Fiat-Shamir security

# SamplingSet

## Purpose

- **What it is**: Norm-bound predicates for sampling set elements (`samplingNormBoundProp`), the expansion-factor property (`samplingExpansionProp`), and an executable bound check (`samplingSetBoundCheck`) with proved soundness and completeness.
- **Key property**: `samplingExpansionProp cset samples ↔ ∃ B, (∀ i, ‖cset[i]‖_∞ ≤ B) ∧ (∀ j, ‖samples[j]‖_∞ ≤ B)`; expansion factor T·(b−1) bounds the combined norm.
- **Protocol role**: ArithmeticBundle checks sampling properties. ProtocolTheorem depends on sampling set assumptions for reduction composition.

## Target Formulas

- `samplingNormBoundProp cset samples B ↔ (∀ i, normInfCoeffs cset[i] ≤ B) ∧ (∀ j, normInfCoeffs samples[j] ≤ B)`
- `samplingExpansionProp cset samples ↔ ∃ B, samplingNormBoundProp cset samples B`
- `samplingDiffSet C = {δ | ∃ c₁,c₂∈C, δ = c₁ - c₂}`
- `strongSamplingExpansionProp C T`: `∀ δ ∈ C-C, ∀ z, ‖δ * z‖∞ ≤ 4*T*B` whenever `‖z‖∞ ≤ B`
- `samplingSetBoundCheck cset samples = true ↔ samplingExpansionProp cset samples`
- `samplingExpansionProp_of_bounds` : bounds → `samplingExpansionProp`

## Paper Anchors

Source: ./formal/superneo-lean/SuperNeo.pdf.md

- Definition 17 (Strong sampling sets), Theorem 9 (Expansion factors), lines 379-383.

## Module Mapping

| Lean file | Paper section |
|---|---|
| `SuperNeo/SamplingSet.lean` | Definition 17, Theorem 9 |

## Contract Surface

| Group | Lean symbol | Kind | Status | Guarantee |
|---|---|---|---|---|
| Predicates | `samplingNormBoundProp` | def | Definitional | Per-entry norm bounds |
| Predicates | `samplingExpansionProp` | def | Definitional | ∃ B with bounds |
| Predicates | `samplingDiffSet` | def | Definitional | Difference-set surface `C-C` |
| Predicates | `strongSamplingExpansionProp` | def | Definitional | Theorem-9-style expansion contract |
| Check | `samplingSetBoundCheck` | def | Definitional | Executable bound check |
| Theorems | `samplingNormBoundProp_left/right` | theorem | Proved | Projection helpers for bound components |
| Theorems | `samplingNormBoundProp_mono` | theorem | Proved | Bound monotonicity in `B` |
| Theorems | `samplingExpansionProp_of_bounds` | theorem | Proved | Bounds → expansion prop |
| Theorems | `samplingExpansionProp_mono` | theorem | Proved | Lift monotone bounds into expansion prop |
| Theorems | `samplingExpansionProp_empty` | theorem | Proved | Empty sets satisfy expansion trivially |
| Theorems | `samplingSetBoundCheck_sound` | theorem | Proved | true → prop |
| Theorems | `samplingSetBoundCheck_complete` | theorem | Proved | prop → true |
| Theorems | `samplingSetBoundCheck_iff` | theorem | Proved | Boolean check iff proposition |
| Theorems | `strongSamplingExpansionProp_mono` | theorem | Proved | Expansion contract monotone in `T` |
| Theorems | `expansionFactor_of_strongSampling` | theorem | Proved | Direct extractor-facing expansion theorem from strong-sampling contract |

## Proof Obligations and Closure Plan

All obligations closed for the module contract, including monotonicity and boolean-prop equivalence (`samplingSetBoundCheck_iff`).

## Assumption Ledger

No open boundary assumptions in this module.

## Dependency and Consumer Map

Upstream dependencies:
- `SuperNeo/Norm.lean`: imports `normInfCoeffs` for bound predicates.

Downstream consumers:
- `SuperNeo/ArithmeticBundle.lean`: uses sampling properties for bound checks.
- `SuperNeo/ProtocolTheorem.lean`: depends on sampling set assumptions.

## Implementation Plan

No further work required for current scope.

## Quality Expectations

`samplingNormBoundProp` must align with Definition 17 (strong sampling sets) and Theorem 9 (expansion factor T·(b−1)).

## Acceptance Criteria

- `lake build` succeeds.
- No `sorry`.

## Out of Scope

- Probability semantics for sampling.
- Concrete expansion factor T for specific rings.

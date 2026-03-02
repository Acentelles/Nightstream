# SamplingSet

## Purpose

- **What it is**: Norm-bound predicates for sampling set elements (`samplingNormBoundProp`), the expansion-factor property (`samplingExpansionProp`), and an executable bound check (`samplingSetBoundCheck`) with proved soundness and completeness.
- **Key property**: `samplingExpansionProp cset samples ↔ ∃ B, (∀ i, ‖cset[i]‖_∞ ≤ B) ∧ (∀ j, ‖samples[j]‖_∞ ≤ B)`; expansion factor T·(b−1) bounds the combined norm.
- **Protocol role**: ArithmeticBundle checks sampling properties. ProtocolTheorem depends on sampling set assumptions for reduction composition.

## Target Formulas

- `samplingNormBoundProp cset samples B ↔ (∀ i, normInfCoeffs cset[i] ≤ B) ∧ (∀ j, normInfCoeffs samples[j] ≤ B)`
- `samplingExpansionProp cset samples ↔ ∃ B, samplingNormBoundProp cset samples B`
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
| Check | `samplingSetBoundCheck` | def | Definitional | Executable bound check |
| Theorems | `samplingExpansionProp_of_bounds` | theorem | Proved | Bounds → expansion prop |
| Theorems | `samplingSetBoundCheck_sound` | theorem | Proved | true → prop |
| Theorems | `samplingSetBoundCheck_complete` | theorem | Proved | prop → true |

## Proof Obligations and Closure Plan

All obligations closed. `samplingExpansionProp_of_bounds`, `samplingSetBoundCheck_sound`, and `samplingSetBoundCheck_complete` are proved.

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

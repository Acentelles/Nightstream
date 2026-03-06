# InteractiveReductions

## Purpose

- **What it is**: A compact structure `InteractiveReductionAssumptions` bundling protocol-relation assumptions (via `PiDECAssumptions`, now an alias of `ProtocolRelationsAssumptions`) and a sum-check transition witness, plus strong and weak composition statements for the reduction pipeline Π_RLC ∘ Π_CCS and Π_DEC ∘ Π_RLC ∘ Π_CCS.
- **Key property**: Under the assumption bundle, `strongCompositionStatement` (Π_RLC ∘ Π_CCS is strong) and `weakCompositionStatement` (Π_DEC ∘ Π_RLC ∘ Π_CCS is weak) hold; composition theorems are proved from the bundle.
- **Protocol role**: ProtocolTheorem uses composition statements. This is the composition capstone for all three reduction steps (CCS → RLC → DEC).

## Target Formulas

- `strongCompositionStatement ctx ↔ piDECKnowledgeStatement ctx`
- `weakCompositionStatement ctx ↔ ceRelaxedRelation ctx ∧ SumCheckClaimTrue (sumcheckInstanceOfContext ctx)`
- `InteractiveReductionAssumptions ctx → strongCompositionStatement ctx`
- `InteractiveReductionAssumptions ctx → weakCompositionStatement ctx`
- `InteractiveReductionAssumptions ctx + (∀ n, 0 ≤ eps n) → SoundnessFailureAdvantageBound(sumcheckInstanceOfContext ctx, witnessTranscript, eps)`

## Paper Anchors

Source: ./formal/superneo-lean/SuperNeo.pdf.md

- Theorem 6 (Strong-Weak Composition), Section 6, lines 438-447.
- Definition 9 (Weak Interactive Reductions), lines 404-416.
- Definition 10 (Strong Interactive Reductions), lines 418-436.

## Module Mapping

| Lean file | Paper section |
|---|---|
| `SuperNeo/InteractiveReductions.lean` | Theorem 6, Definitions 9–10 |

## Contract Surface

| Group | Lean symbol | Kind | Role | Guarantee |
|---|---|---|---|---|
| Assumptions | `InteractiveReductionAssumptions` | structure | Boundary | Bundles relation assumptions + SumCheck transition witness |
| Constructor | `InteractiveReductionAssumptions.ofProtocolRelations` | def | Theorem-Target | Canonical constructor from protocol-relations assumptions + witness |
| Statements | `strongCompositionStatement` | def | Definitional | Π_RLC ∘ Π_CCS strong |
| Statements | `weakCompositionStatement` | def | Definitional | Π_DEC ∘ Π_RLC ∘ Π_CCS weak |
| Theorems | `strongComposition_of_assumptions` | theorem | Theorem-Target | Assumptions → strong |
| Theorems | `weakComposition_of_assumptions` | theorem | Theorem-Target | Assumptions → weak |
| Theorems | `sumcheckFailureAdvantageBound_of_assumptions` | theorem | Theorem-Target | Witness-level SumCheck failure-advantage bound from reduction assumptions |
| Theorems | `sumcheckFailureAdvantageBound_of_native_assumptions` | theorem | Theorem-Target | Native-path witness-level SumCheck failure-advantage bound |

## Proof Obligations and Closure Plan

Closure target: Prove `InteractiveReductionAssumptions ctx` for concrete protocol contexts by instantiating protocol-relations assumptions and an accepted sum-check transition witness. The composition theorems are proved from the bundle; the bundle itself is the boundary.

## Assumption Ledger

- `InteractiveReductionAssumptions`: boundary assumption bundling relation assumptions and a transition witness.
- Closure target: instantiate via `InteractiveReductionAssumptions.ofProtocolRelations`.

## Dependency and Consumer Map

Upstream dependencies:
- `SuperNeo/PiDEC.lean`: imports `PiDECAssumptions`, `piDECKnowledgeStatement`, `ceRelaxedRelation`, `SumCheckClaimTrue`, `sumcheckInstanceOfContext`, `piDEC_of_assumptions`.

Downstream consumers:
- `SuperNeo/ProtocolTheorem.lean`: uses composition statements for the full protocol reduction.

## Implementation Plan

No further implementation work for current scope. Closure requires proving PiCCS, PiRLC, and PiDEC assumptions for the protocol.

## Quality Expectations

Composition statements must match Theorem 6 (Strong-Weak Composition). Strong/weak definitions must align with Definitions 9 and 10.

## Acceptance Criteria

- `lake build` succeeds.
- No `sorry`.

## Out of Scope

- Concrete instantiation of `InteractiveReductionAssumptions`.
- Proof of PiCCS/PiRLC/PiDEC assumptions from cryptographic primitives.

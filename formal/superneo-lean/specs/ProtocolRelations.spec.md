# ProtocolRelations

## Purpose

- **What it is**: The CCS and CE relation predicates on protocol-target context. Defines `ccsRelation` (protocol target holds), `ceRelation` (CCS plus accepted SumCheck transcript), and `ceRelaxedRelation` (CCS only). Builds `sumcheckInstanceOfContext` from context and `SumCheckTransitionWitness` carrying round-consistency facts.
- **Key property**: `ceRelation ctx ↔ ccsRelation ctx ∧ ∃ tr, SumCheckAccepted (sumcheckInstanceOfContext ctx) tr`; and `ceRelation ctx → ceRelaxedRelation ctx`.
- **Protocol role**: PiCCS, PiRLC, PiDEC, and FoldingProtocol depend on these relation predicates for the Section 7 folding reductions (Π_CCS, Π_RLC, Π_DEC).

## Target Formulas

- `ccsRelation(ctx) ↔ protocolTargetProp(ctx)` (CCS = protocol target)
- `ceRelation(ctx) ↔ ccsRelation(ctx) ∧ ∃ tr, SumCheckAccepted inst tr` where `inst = sumcheckInstanceOfContext ctx`
- `ceRelaxedRelation(ctx) ↔ ccsRelation(ctx)`
- `ceRelation_of_claimTrue`: `ProtocolRelationsAssumptions ctx → SumCheckClaimTrue inst → ceRelation ctx`
- `ceClaimTrue_of_ce`: `ProtocolRelationsAssumptions ctx → ceRelation ctx → SumCheckClaimTrue inst`
- `ceRelaxedRelation_of_ce`: `ceRelation ctx → ceRelaxedRelation ctx`

## Paper Anchors

Source: ./formal/superneo-lean/SuperNeo.pdf.md

- Definition 12 (Norm-bounded CCS), Section 7.1, lines 457-459.
- Definition 13 (Norm-bounded CCS Evaluation Relation), Section 7.1, lines 461-465.
- Section 7.1 (Relations), lines 449-465.

## Module Mapping

| Lean file | Paper section |
|---|---|
| `SuperNeo/ProtocolRelations.lean` | Section 7.1, Definitions 12–13 |

## Contract Surface

| Group | Lean symbol | Kind | Status | Guarantee |
|---|---|---|---|---|
| Instance | `sumcheckInstanceOfContext` | def | Definitional | Builds SumCheckInstance from ctx |
| Witness | `SumCheckTransitionWitness` | structure | Definitional | transcript, accepted, initialRound, roundSumStep |
| Relations | `ccsRelation` | def | Definitional | protocolTargetProp ctx |
| Relations | `ceRelation` | def | Definitional | ccsRelation ∧ ∃ tr, SumCheckAccepted |
| Relations | `ceRelaxedRelation` | def | Definitional | ccsRelation ctx |
| Assumptions | `ProtocolRelationsAssumptions` | structure | Boundary-Assumed | Bundles target, sumcheckSoundness, sumcheckCompleteness |
| Theorems | `ccsRelation_of_assumptions` | theorem | Proved | Assumptions → ccsRelation |
| Theorems | `ceRelation_of_assumptions` | theorem | Proved | Assumptions + witness → ceRelation |
| Theorems | `ceRelation_of_claimTrue` | theorem | Proved | Assumptions + claimTrue → ceRelation |
| Theorems | `ceClaimTrue_of_ce` | theorem | Proved | Assumptions + ceRelation → claimTrue |
| Theorems | `ceRelaxedRelation_of_ce` | theorem | Proved | ceRelation → ceRelaxedRelation |
| Witness | `SumCheckTransitionWitness.accepted_exists` | theorem | Proved | Witness → ∃ tr, accepted |

## Proof Obligations and Closure Plan

All relation-level theorems proved. `ProtocolRelationsAssumptions` bundles upstream boundaries (ProtocolTarget, SumCheck); closure targets live in those modules.

## Assumption Ledger

`ProtocolRelationsAssumptions` bundles upstream assumptions: `ProtocolTargetAssumptions`, `SumcheckSoundnessAssumption`, `SumcheckCompletenessAssumption`. Closure target: each upstream module (ProtocolTarget, SumCheck) has its own closure plan.

## Dependency and Consumer Map

Upstream dependencies:
- `SuperNeo/ProtocolTarget.lean`: imports `protocolTargetProp`, `ProtocolTargetAssumptions`, `ProtocolTargetContext`.
- `SuperNeo/SumCheck.lean`: imports `SumCheckInstance`, `SumCheckTranscript`, `SumCheckAccepted`, `SumCheckClaimTrue`, `SumcheckSoundnessAssumption`, `SumcheckCompletenessAssumption`.

Downstream consumers:
- `SuperNeo/PiCCS.lean`: uses `ceRelation`, `ceRelation_of_assumptions`, `ceClaimTrue_of_ce`, `SumCheckTransitionWitness`, `sumcheckInstanceOfContext`.
- `SuperNeo/PiRLC.lean`: uses `ceRelaxedRelation`, `ceRelaxedRelation_of_ce`, `piCCSStrongStatement`.
- `SuperNeo/PiDEC.lean`: uses `ceRelaxedRelation`, `piRLCWeakStatement`.
- `SuperNeo/FoldingProtocol.lean`: imports ProtocolRelations for folding relation predicates.
- `SuperNeo/ProtocolReduction.lean`: imports ProtocolRelations.

## Implementation Plan

Current scope complete. Relation predicates and theorems proved; assumption bundling is intentional for composition.

## Quality Expectations

Relation definitions must match paper CCS/CE semantics. Soundness/completeness bridges (`ceRelation_of_claimTrue`, `ceClaimTrue_of_ce`) must be proved.

## Acceptance Criteria

- `lake build` succeeds.
- No `sorry`.
- All relation theorems proved.

## Out of Scope

- Probabilistic soundness/completeness proofs (live in SumCheck boundary).

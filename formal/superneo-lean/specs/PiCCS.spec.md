# PiCCS

## Purpose

- **What it is**: The strong interactive-reduction step Π_CCS. Defines `piCCSStrongStatement` as the conjunction of `ceRelation ctx` and `SumCheckClaimTrue (sumcheckInstanceOfContext ctx)`.
- **Key property**: `piCCSStrong_of_assumptions`: given `PiCCSAssumptions ctx` and `SumCheckTransitionWitness ctx`, we have `piCCSStrongStatement ctx`.
- **Protocol role**: PiRLC depends on `piCCSStrongStatement` and `piCCSStrong_of_assumptions` for the strong→weak composition (Theorem 6). Section 7.3 (Π_CCS) reduces CCS instances to CE instances via sum-check.

## Target Formulas

- `piCCSStrongStatement(ctx) ↔ ceRelation(ctx) ∧ SumCheckClaimTrue(sumcheckInstanceOfContext ctx)`
- `piCCSStrong_of_assumptions`: `PiCCSAssumptions ctx → SumCheckTransitionWitness ctx → piCCSStrongStatement ctx`
- Strong reduction (Lemma 3): Π_CCS : CCS^K × CE^k → CE^{K+k} is strong for φ projecting commitments.

## Paper Anchors

Source: ./formal/superneo-lean/SuperNeo.pdf.md

- Section 7.3 (Π_CCS), lines 481-548.
- Lemma 3 (Π_CCS is strong), lines 545-546.

## Module Mapping

| Lean file | Paper section |
|---|---|
| `SuperNeo/PiCCS.lean` | Section 7.3, Lemma 3 |

## Contract Surface

| Group | Lean symbol | Kind | Status | Guarantee |
|---|---|---|---|---|
| Assumptions | `PiCCSAssumptions` | structure | Definitional | relations : ProtocolRelationsAssumptions ctx |
| Statement | `piCCSStrongStatement` | def | Definitional | ceRelation ∧ SumCheckClaimTrue |
| Theorem | `piCCSStrong_of_assumptions` | theorem | Proved | Assumptions + witness → strong statement |

## Proof Obligations and Closure Plan

All obligations closed. `piCCSStrong_of_assumptions` proved from `ceRelation_of_assumptions` and `ceClaimTrue_of_ce`.

## Assumption Ledger

No open boundary assumptions in this module. `PiCCSAssumptions` forwards `ProtocolRelationsAssumptions` from upstream.

## Dependency and Consumer Map

Upstream dependencies:
- `SuperNeo/ProtocolRelations.lean`: uses `ceRelation`, `ceRelation_of_assumptions`, `ceClaimTrue_of_ce`, `SumCheckTransitionWitness`, `sumcheckInstanceOfContext`, `ProtocolRelationsAssumptions`.

Downstream consumers:
- `SuperNeo/PiRLC.lean`: uses `piCCSStrongStatement`, `piCCSStrong_of_assumptions`, `PiCCSAssumptions`.
- `SuperNeo/ProofSystem/Folding/PiCCS.lean`: imports PiCCS for strong reduction step.

## Implementation Plan

Current scope complete. Strong statement and derivation theorem proved.

## Quality Expectations

`piCCSStrongStatement` must match Lemma 3: CE relation plus sum-check claim truth. Derivation must thread assumptions correctly.

## Acceptance Criteria

- `lake build` succeeds.
- No `sorry`.
- `piCCSStrong_of_assumptions` proved.

## Out of Scope

- Full protocol execution (ProofSystem layer).
- Probabilistic strong-reduction proof (Lemma 3 proof deferred to appendix).

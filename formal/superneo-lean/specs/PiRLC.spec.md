# PiRLC

## Purpose

- **What it is**: The weak interactive-reduction step Π_RLC. Defines `piRLCWeakStatement` as the conjunction of `ceRelaxedRelation ctx` and `SumCheckClaimTrue (sumcheckInstanceOfContext ctx)`.
- **Key property**: `piRLCWeak_of_assumptions`: given `PiRLCAssumptions ctx` and `SumCheckTransitionWitness ctx`, we have `piRLCWeakStatement ctx`. The weak statement relaxes CE to ceRelaxed (CCS only).
- **Protocol role**: PiDEC depends on `piRLCWeakStatement` and `piRLCWeak_of_assumptions` for the weak→knowledge composition. Section 7.4 (Π_RLC) performs random linear combination of CE claims.

## Target Formulas

- `piRLCWeakStatement(ctx) ↔ ceRelaxedRelation(ctx) ∧ SumCheckClaimTrue(sumcheckInstanceOfContext ctx)`
- `piRLCWeak_of_assumptions`: `PiRLCAssumptions ctx → SumCheckTransitionWitness ctx → piRLCWeakStatement ctx`
- Weak reduction (Lemma 4): Π_RLC : CE^{K+k} → CE(B) is weak for φ projecting commitments.

## Paper Anchors

Source: ./formal/superneo-lean/SuperNeo.pdf.md

- Section 7.4 (Π_RLC), lines 549-583.
- Lemma 4 (Π_RLC is weak), lines 582-583.

## Module Mapping

| Lean file | Paper section |
|---|---|
| `SuperNeo/PiRLC.lean` | Section 7.4, Lemma 4 |

## Contract Surface

| Group | Lean symbol | Kind | Status | Guarantee |
|---|---|---|---|---|
| Assumptions | `PiRLCAssumptions` | structure | Definitional | strong : PiCCSAssumptions ctx |
| Statement | `piRLCWeakStatement` | def | Definitional | ceRelaxedRelation ∧ SumCheckClaimTrue |
| Theorem | `piRLCWeak_of_assumptions` | theorem | Proved | Assumptions + witness → weak statement |

## Proof Obligations and Closure Plan

All obligations closed. `piRLCWeak_of_assumptions` proved from `piCCSStrong_of_assumptions` and `ceRelaxedRelation_of_ce`.

## Assumption Ledger

No open boundary assumptions in this module. `PiRLCAssumptions` forwards `PiCCSAssumptions` from upstream.

## Dependency and Consumer Map

Upstream dependencies:
- `SuperNeo/PiCCS.lean`: uses `piCCSStrongStatement`, `piCCSStrong_of_assumptions`, `PiCCSAssumptions`.
- `SuperNeo/ProtocolRelations.lean`: uses `ceRelaxedRelation`, `ceRelaxedRelation_of_ce`.

Downstream consumers:
- `SuperNeo/PiDEC.lean`: uses `piRLCWeakStatement`, `piRLCWeak_of_assumptions`, `PiRLCAssumptions`.
- `SuperNeo/ProofSystem/Folding/PiRLC.lean`: imports PiRLC for weak reduction step.

## Implementation Plan

Current scope complete. Weak statement and derivation theorem proved.

## Quality Expectations

`piRLCWeakStatement` must match Lemma 4: relaxed CE (CCS only) plus sum-check claim truth. Derivation must compose correctly from strong statement.

## Acceptance Criteria

- `lake build` succeeds.
- No `sorry`.
- `piRLCWeak_of_assumptions` proved.

## Out of Scope

- Full protocol execution (ProofSystem layer).
- Probabilistic weak-reduction proof (Lemma 4 proof deferred to appendix).

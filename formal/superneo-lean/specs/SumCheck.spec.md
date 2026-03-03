# SumCheck

## Purpose

- **What it is**: The interactive sum-check protocol formalization, defining `SumCheckInstance` (claimed value, rounds, max degree), `SumCheckTranscript` (challenges, round polynomials), and the verifier's acceptance predicate `sumcheckAccepted` combining round consistency, polynomial shapes, initial-round sum, fold consistency, and final-claim checks.
- **Key property**: `sumcheckAccepted inst tr` implies structural properties: `tr.roundPolys.size = inst.rounds`, `tr.challenges.size = tr.roundPolys.size`, and each round's `p(0) + p(1) = eval(p_{prev}, r_{prev})`.
- **Protocol role**: Sum-check is the interactive reduction backbone of SuperNeo. Section 7.3 (Π_CCS) and Section 7.4 (Π_RLC) both invoke sum-check to reduce multivariate polynomial claims to point-evaluation queries, which are then handled by MLE evaluation.

## Target Formulas

- `p_0(0) + p_0(1) = v` (initial round sum = claimed value)
- `p_{i+1}(0) + p_{i+1}(1) = p_i(r_i)` (round transition)
- `|p_i| = maxDegree + 1` (polynomial shape)
- `|challenges| = |roundPolys| = rounds` (transcript shape)

## Paper Anchors

Source: ./formal/superneo-lean/SuperNeo.pdf.md

- Definition 6 (Sum-check protocol), Section 4, lines 352-355.
- Section 7.3 (Π_CCS), lines 440-470: sum-check invocation in CCS folding.
- Section 7.4 (Π_RLC), lines 471-489: sum-check invocation in RLC.

## Module Mapping

| Lean file | Paper section |
|---|---|
| `SuperNeo/SumCheck.lean` | Definition 6 (sum-check) |

## Contract Surface

| Group | Lean symbol | Kind | Role | Guarantee |
|---|---|---|---|---|
| Structures | `SumCheckInstance` | structure | Definitional | `rounds`, `maxDegree`, `domainSize`, `claimedValue` |
| Structures | `SumCheckTranscript` | structure | Definitional | `challenges`, `roundPolys` |
| Evaluation | `sumcheckEvalPoly` | def | Definitional | Horner-form univariate eval |
| Predicates | `sumcheckRoundConsistent` | def | Definitional | Transcript shape check |
| Predicates | `sumcheckRoundPolyShape` | def | Definitional | Polynomial coefficient count |
| Predicates | `sumcheckRoundShapes` | def | Definitional | All round polys shaped |
| Predicates | `sumcheckFoldConsistent` | def | Definitional | Round-to-round transition |
| Predicates | `sumcheckInitialRoundConsistent` | def | Definitional | `p_0(0) + p_0(1) = v` |
| Predicates | `sumcheckFinalClaimConsistent` | def | Definitional | Final claim check |
| Acceptance | `sumcheckAccepted` | def | Definitional | Conjunction of all checks |
| Claim | `sumcheckClaimTrue` | def | Definitional | `maxDegree ≤ domainSize` |
| Extraction | `sumcheckAccepted_rounds_eq` | theorem | Theorem-Target | `|roundPolys| = rounds` |
| Extraction | `sumcheckAccepted_challenges_eq` | theorem | Theorem-Target | `|challenges| = |roundPolys|` |
| Extraction | `sumcheckAccepted_fold_step` | theorem | Theorem-Target | Fold-step identity |
| Extraction | `sumcheckAccepted_initial_round` | theorem | Theorem-Target | Initial round check |
| Extraction | `sumcheckAccepted_round_sum_step` | theorem | Theorem-Target | Round-sum transition |
| Rejection | `sumcheckAccepted_not_of_challenge_size_ne` | theorem | Theorem-Target | Reject bad challenge count |
| Rejection | `sumcheckAccepted_not_of_roundpoly_size_ne` | theorem | Theorem-Target | Reject bad poly count |
| Rejection | `sumcheckAccepted_not_of_bad_round_shape` | theorem | Theorem-Target | Reject bad poly shape |
| Rejection | `sumcheckAccepted_not_of_bad_final_claim` | theorem | Theorem-Target | Reject bad final claim |
| Rejection | `sumcheckAccepted_not_of_bad_initial_round` | theorem | Theorem-Target | Reject bad initial round |
| Boundary | `SumcheckSoundnessAssumption` | def | Boundary | `accepted → claimTrue` |
| Boundary | `SumcheckCompletenessAssumption` | def | Boundary | `claimTrue → ∃ tr, accepted` |
| Boundary | `SumCheckAssumptions` | structure | Boundary | Bundle of both |
| Bridge | `sumcheckClaimTrue_of_soundness` | theorem | Theorem-Target | Conditional soundness |

## Proof Obligations and Closure Plan

Structural extraction and rejection theorems: all closed.

Open obligations:
- `SumcheckSoundnessAssumption`: requires probabilistic argument (Schwartz-Zippel bound). Tracked as a boundary assumption for now.
- `SumcheckCompletenessAssumption`: requires honest-prover transcript construction. Tracked as a boundary assumption.

## Assumption Ledger

- `SumcheckSoundnessAssumption` [Boundary]: Standard sum-check soundness (Lund et al.). Closure target: prove via Schwartz-Zippel bound on degree-d polynomials over F.
- `SumcheckCompletenessAssumption` [Boundary]: Standard completeness. Closure target: constructive honest-prover transcript.

## Dependency and Consumer Map

Upstream dependencies:
- `SuperNeo/MLE.lean`: MLE evaluators for sum-check claims.
- `SuperNeo/EqPoly.lean`: `eqPoly` for sum-check polynomial construction.

Downstream consumers:
- `SuperNeo/PiCCS.lean`: uses `SumCheckInstance`, `sumcheckAccepted` for Π_CCS.
- `SuperNeo/PiRLC.lean`: uses sum-check for Π_RLC.
- `SuperNeo/ProofSystem.SumCheck`: uses `SumCheckAssumptions` for proof-system composition.

## Implementation Plan

Current scope complete. Soundness/completeness proofs are future-scope items requiring probabilistic reasoning infrastructure.

## Quality Expectations

Acceptance predicate must be a conjunction of independently testable components. Extraction theorems must provide one-step access to each component without pattern-matching on the conjunction.

## Acceptance Criteria

- `lake build` succeeds.
- No `sorry`.
- All 5 extraction and 5 rejection theorems proved.

## Out of Scope

- Probabilistic soundness proof (Schwartz-Zippel).
- Interactive oracle proof (IOP) formalization.
- Concrete sum-check examples (live in `Checks.lean`).

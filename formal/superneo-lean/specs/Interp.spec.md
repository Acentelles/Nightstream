# Interp

## Purpose

- **What it is**: A compact interpolation module providing the proposition `interpolationProp` (pointwise interpolation/evaluation agreement) and the executable checker `interpolationCase` with sound/complete bridges, used as an obligation carrier for protocol-level arithmetic.
- **Key property**: `interpolationCase_sound`: `interpolationCase = true → interpolationProp` and `interpolationCase_complete`: `interpolationProp → interpolationCase = true`.
- **Protocol role**: Interpolation obligations arise when the folding protocol needs to verify that a polynomial evaluates correctly at a given point. The `interpolationAssumption` boundary is consumed by arithmetic obligation statements that require evaluation-point agreement.

## Target Formulas

- `interpolationProp(xs, ys, coeffs, xEval, expectedEval) ↔ |xs| = |ys| ∧ |coeffs| = |xs| ∧ expectedEval = xEval`

## Paper Anchors

Source: ./formal/superneo-lean/SuperNeo.pdf.md

- Definition 6 (Sum-check), Section 4, lines 352-355: polynomial evaluation checks that interpolation supports.
- Section 7.3 (Π_CCS), lines 440-470: evaluation agreement obligations in CCS folding.

## Module Mapping

| Lean file | Paper section |
|---|---|
| `SuperNeo/Interp.lean` | Infrastructure (supports Sections 7.3-7.4) |

## Contract Surface

| Group | Lean symbol | Kind | Role | Guarantee |
|---|---|---|---|---|
| Proposition | `interpolationProp` | def | Definitional | Shape + evaluation agreement |
| Boundary | `interpolationAssumption` | def | Boundary | Universal interpolation claim |
| Executable | `interpolationCase` | def | Definitional | `decide interpolationProp` |
| Sound | `interpolationCase_sound` | theorem | Theorem-Target | `Bool → Prop` |
| Complete | `interpolationCase_complete` | theorem | Theorem-Target | `Prop → Bool` |

## Proof Obligations and Closure Plan

Sound/complete bridges: closed.

Open obligations:
- `interpolationAssumption`: universally quantified — intentionally left as boundary. Closure requires a polynomial interpolation theorem over the polynomial ring formalization.

## Assumption Ledger

- `interpolationAssumption` [Boundary]: polynomial interpolation correctness. Closure strategy: formalize Lagrange interpolation over F.

## Dependency and Consumer Map

Upstream dependencies:
- `SuperNeo/Field.lean`: `F` type for field elements.

Downstream consumers:
- `SuperNeo/ArithmeticObligations.lean`: uses `interpolationProp` for arithmetic checks.

## Implementation Plan

Full interpolation correctness (Lagrange interpolation formalization) is out of scope for this module.

## Quality Expectations

Sound/complete pair must form a true biconditional. The module must not silently assume nontrivial mathematical content — the `interpolationAssumption` boundary makes the gap explicit.

## Acceptance Criteria

- `lake build` succeeds.
- No `sorry`.
- `interpolationCase_sound` and `interpolationCase_complete` both proved.

## Out of Scope

- Lagrange interpolation algorithm.
- Polynomial evaluation at arbitrary points.
- Error-correcting code connections.

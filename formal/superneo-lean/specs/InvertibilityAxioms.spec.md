# InvertibilityAxioms

## Purpose

- **What it is**: The invertibility predicate `invertibleRq` on ring elements, the norm-window precondition `invertibilityWindowProp`, and the boundary assumption `lowNormInvertibilityAssumption` that low-norm elements are invertible in Rq.
- **Key property**: `invertibleRq a ↔ ∃ aInv, mulRq a aInv = oneRq`; under the assumption, `invertibilityWindowProp B a → invertibleRq a`.
- **Protocol role**: ProtocolTheorem uses `lowNormInvertibilityAssumption` for security reductions. ArithmeticBundle checks invertibility preconditions.

## Target Formulas

- `invertibleRq a ↔ ∃ aInv : Coeffs, mulRq a aInv = oneRq`
- `invertibilityWindowProp B a ↔ normInfCoeffs a ≤ B`
- `lowNormInvertibilityAssumption B → ∀ a, (normInfCoeffs a ≤ B → invertibleRq a)`
- `invertibilityPreconditionsProp = True` (trivial; reserved for protocol-level preconditions)

## Paper Anchors

Source: ./formal/superneo-lean/SuperNeo.pdf.md

- Theorem 8 (Low-norm invertibility), Section 5/6, lines 375-378.
- Definition 3 (Norm), Section 4, lines 290-291: norm bounds used for invertibility window preconditions.

## Module Mapping

| Lean file | Paper section |
|---|---|
| `SuperNeo/InvertibilityAxioms.lean` | Theorem 8 |

## Contract Surface

| Group | Lean symbol | Kind | Role | Guarantee |
|---|---|---|---|---|
| Predicates | `invertibleRq` | def | Definitional | ∃ inverse in Rq |
| Predicates | `invertibilityWindowProp` | def | Definitional | normInfCoeffs a ≤ B |
| Predicates | `invertibilityPreconditionsProp` | def | Definitional | Trivial (`True`); reserved for protocol-level preconditions |
| Boundary | `lowNormInvertibilityAssumption` | def | Boundary | ∀ a, window → invertible |
| Theorems | `invertibleRq_of_lowNormAssumption` | theorem | Boundary | Uses assumption to derive invertibility |
| Theorems | `invertibilityPreconditions_from_constants` | theorem | Theorem-Target | Preconditions hold |

## Proof Obligations and Closure Plan

Closure target: Prove `lowNormInvertibilityAssumption B` for concrete `B` from Theorem 8 (e.g., `b_inv` regime). The assumption is currently an axiom surface; instantiation requires number-theoretic analysis of the cyclotomic ring.

## Assumption Ledger

- `lowNormInvertibilityAssumption B`: boundary assumption that elements with ‖a‖_∞ ≤ B are invertible in Rq.
- Closure target: Prove from Theorem 8 (Low-norm invertibility) for concrete parameters (e.g., Goldilocks, Mersenne61).

## Dependency and Consumer Map

Upstream dependencies:
- `SuperNeo/Norm.lean`: imports `normInfCoeffs` for `invertibilityWindowProp`.

Downstream consumers:
- `SuperNeo/ProtocolTheorem.lean`: uses `lowNormInvertibilityAssumption`.
- `SuperNeo/ArithmeticBundle.lean`: depends on invertibility preconditions.

## Implementation Plan

No further implementation work for current scope. Closure requires external proof of Theorem 8 for instantiated parameters.

## Quality Expectations

`invertibleRq` must match the paper's invertibility notion (existence of inverse in Rq). `invertibilityWindowProp` must align with Definition 3 norm bounds.

## Acceptance Criteria

- `lake build` succeeds.
- No `sorry`.

## Out of Scope

- Concrete bound instantiation (e.g., `b_inv` for Goldilocks).
- Number-theoretic proof of Theorem 8.

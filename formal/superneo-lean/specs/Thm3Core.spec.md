# Thm3Core Spec

## Purpose

- **What it is**: The Theorem-3 inner-product transform module. It defines `innerProduct` (dot product with size guard) and the paper-faithful boundary `thm3CoreAssumption` stating that `ct(mulRq(bar(a), bar(b))) = ⟨a, b⟩` for d-sized blocks — the constant term of the ring product of bar-transformed blocks equals the field inner product. Also provides the P10 compatibility surface (`p10CoreProp`, `p10CoreCheck`) for executable checks.
- **Key property**: `∀ a b, a.size = d → b.size = d → ct(mulRq(bar(a), bar(b))) = innerProduct a b` — the ring multiplication encodes the field inner product via the bar transform.
- **Protocol role**: MatrixTransform uses `thm3CoreAssumption` to derive Theorem 4 (matrix-vector product transform). The chain feeds into EvalLink and EvalHom.

## Target Formulas (Paper → Lean)

- Paper formula: `ct(ā·b̄) = ⟨a, b⟩` (Theorem 3, Inner Product Transform)
- Lean mapping:
  - `innerProduct a b` : dot product with size guard
  - `thm3CoreAssumption bar` : `∀ a b, a.size = d → b.size = d → ct (mulRq (superneoBarBlock bar a) (superneoBarBlock bar b)) = innerProduct a b`
  - `p10CoreProp bar a b` : `a.size = d ∧ b.size = d ∧ ct (mulRq (superneoBarBlock bar a) (superneoBarBlock bar b)) = innerProduct a b`
  - `p10CoreCheck bar a b = true ↔ p10CoreProp bar a b`
- Target statement: Theorem-3 is a pure boundary. Closure requires constructing the cyclotomic-specific bar transform matrix and proving the inner-product encoding property.

## Paper Anchors

- Source: `./formal/superneo-lean/SuperNeo.pdf.md`
- Anchors:
  - Theorem 3 (Inner Product Transform), Section 5, lines 368-372: `ct(ā·b̄) = ⟨a, b⟩`

## Module Mapping

- Implementation: `SuperNeo.Thm3Core`
- Interface: `SuperNeo.Thm3CoreInterface`

## Contract Surface

| Contract group | Lean surface | Preconditions | Guarantee | Role | Used by |
|---|---|---|---|---|---|
| Inner product | `innerProduct a b` | None (size guard returns 0 if mismatch) | Dot product `Σ_i a[i]·b[i]` when `a.size = b.size` | Definitional | `MatrixTransform.lean` |
| Theorem-3 boundary | `thm3CoreAssumption bar` | None | `∀ a b, a.size = d → b.size = d → ct (mulRq (superneoBarBlock bar a) (superneoBarBlock bar b)) = innerProduct a b` | Boundary | `MatrixTransform.lean` |
| Shape predicates | `IsDVec`, `IsDBarMatrix` | None | `a.size = d`, `True` | Definitional | P10 wrappers |
| P10 proposition | `p10CoreProp bar a b` | None | `a.size = d ∧ b.size = d ∧ ct(mulRq(bar(a), bar(b))) = innerProduct a b` | Definitional | — |
| P10 check | `p10CoreCheck bar a b` | None | `p10CoreCheck bar a b = true ↔ p10CoreProp bar a b` | Theorem-Target | — |
| Sound/complete | `p10CoreCheck_sound`, `p10CoreCheck_complete` | Check true / Prop holds | Bidirectional bridge | Theorem-Target | — |
| From preconditions | `p10Core_of_preconditions`, `p10Core_of_preconditions_props`, `p10Core_of_assumption` | Shape + check / Thm3 | `p10CoreProp bar a b` | Theorem-Target | — |

## Proof Obligations and Closure Plan

Closed now:
- P10 sound/complete and `p10Core_of_*` theorems.
- `p10Core_of_assumption` derives P10 from `thm3CoreAssumption` + vector shapes.

Remaining for paper-faithful proof-complete closure:
- Construct the cyclotomic-specific bar transform matrix (for Φ(X) = X^d + X^{d/2} + 1).
- Prove `thm3CoreAssumption` for that specific bar transform, discharging the ct∘mulRq = innerProduct identity from ring algebra.

## Assumption Ledger

- Open boundary: `thm3CoreAssumption` — requires a bar transform satisfying `ct(mulRq(bar(a), bar(b))) = ⟨a, b⟩`.
  Closure strategy: construct the explicit bar matrix for the cyclotomic and prove the identity from ring arithmetic.

## Dependency and Consumer Map

- Upstream dependencies:
  - `SuperNeo/BarLift.lean`: imports `superneoBarBlock` for the bar-transform kernel.
  - `SuperNeo/Ring.lean` (transitive): uses `ct`, `mulRq` for ring-level operations.
- Downstream consumers:
  - `SuperNeo/MatrixTransform.lean`: uses `thm3CoreAssumption` and `innerProduct` to derive `matrixTransformAssumption` (Theorem 4).

## Implementation Plan

1. `innerProduct` defined with size guard; returns 0 on mismatch.
2. `thm3CoreAssumption` stated as paper-faithful boundary: `ct(mulRq(bar(a), bar(b))) = innerProduct a b` for d-sized blocks.
3. P10 check/prop bridges proved via `decide_eq_true` / `decide_eq_true_eq`.
4. `p10Core_of_assumption` derives from `thm3CoreAssumption` and shape predicates.

## Quality Expectations

- No `sorry` in any theorem.
- Theorem-3 boundary is a pure assumption; closure requires the actual bar transform implementation.

## Acceptance Criteria

1. `lake build` succeeds.
2. All P10 theorems exported through the interface.

## Out of Scope

- Constructing the cyclotomic-specific bar transform matrix.
- Proving ring-arithmetic identity for the specific cyclotomic polynomial.

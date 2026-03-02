# Thm3Core Spec

## Purpose

- **What it is**: The Theorem-3 inner-product transform scaffold. It defines `innerProduct` (dot product with size guard), the universal contract `thm3CoreAssumption` stating that inner products are preserved under bar-lift, and the P10 compatibility surface (`p10CoreProp`, `p10CoreCheck`) for executable checks.
- **Key property**: `∀ a b, innerProduct a b = innerProduct (barLift a) (barLift b)` when `a.size = b.size` — i.e. `ct(ā·b̄) = ⟨a,b⟩` in paper notation.
- **Protocol role**: BarLift uses Thm3Core to derive matrix-transform assumption. MatrixTransform uses `thm3CoreAssumption` to prove Theorem 4 (matrix-vector product transform).

## Target Formulas (Paper → Lean)

- Paper formula: `ct(ā·b̄) = ⟨a,b⟩` (Theorem 3, Inner Product Transform)
- Lean mapping:
  - `innerProduct a b` : dot product with size guard
  - `thm3CoreAssumption bar` : `∀ a b, a.size = b.size → innerProduct a b = innerProduct (barLiftVector bar a) (barLiftVector bar b)`
  - `p10CoreProp bar a b` : `a.size = b.size ∧ innerProduct a b = innerProduct (barLiftVector bar a) (barLiftVector bar b)`
  - `p10CoreCheck bar a b = true ↔ p10CoreProp bar a b`
- Target statement: All theorems proved natively (scaffold: `barLiftVector = id`).

## Paper Anchors

- Source: `./formal/superneo-lean/SuperNeo.pdf.md`
- Anchors:
  - Theorem 3 (Inner Product Transform), Section 5, lines 368-372: `ct(ā·b̄) = ⟨a,b⟩`

## Module Mapping

- Implementation: `SuperNeo.Thm3Core`
- Interface: `SuperNeo.Thm3CoreInterface`

## Contract Surface

| Contract group | Lean surface | Preconditions | Guarantee | Status | Used by |
|---|---|---|---|---|---|
| Inner product | `innerProduct a b` | None (size guard returns 0 if mismatch) | Dot product `Σ_i a[i]·b[i]` when `a.size = b.size` | Definitional | `MatrixTransform.lean` |
| Theorem-3 boundary | `thm3CoreAssumption bar` | None | `∀ a b, a.size = b.size → innerProduct a b = innerProduct (barLiftVector bar a) (barLiftVector bar b)` | Proved | `MatrixTransform.lean` |
| Native closure | `thm3CoreAssumption_native` | None | `thm3CoreAssumption bar` (barLift = id in scaffold) | Proved | — |
| Shape predicates | `IsDVec`, `IsDBarMatrix` | None | `a.size = d`, `True` | Definitional | P10 wrappers |
| P10 proposition | `p10CoreProp bar a b` | None | `a.size = b.size ∧ innerProduct a b = innerProduct (barLiftVector bar a) (barLiftVector bar b)` | Definitional | — |
| P10 check | `p10CoreCheck bar a b` | None | `p10CoreCheck bar a b = true ↔ p10CoreProp bar a b` | Proved | — |
| Sound/complete | `p10CoreCheck_sound`, `p10CoreCheck_complete` | Check true / Prop holds | Bidirectional bridge | Proved | — |
| From preconditions | `p10Core_of_preconditions`, `p10Core_of_preconditions_props`, `p10Core_of_assumption` | Shape + check / Thm3 | `p10CoreProp bar a b` | Proved | — |

## Proof Obligations and Closure Plan

All obligations closed. `thm3CoreAssumption_native` proves Theorem 3 in the scaffold (`barLiftVector = id`). P10 sound/complete and `p10Core_of_*` theorems are proved.

## Assumption Ledger

No open boundary assumptions in this module.

## Dependency and Consumer Map

- Upstream dependencies:
  - `SuperNeo/BarLift.lean`: imports `barLiftVector` for `thm3CoreAssumption` and P10 surfaces.
- Downstream consumers:
  - `SuperNeo/MatrixTransform.lean`: uses `thm3CoreAssumption` and `innerProduct` to derive `matrixTransformAssumption` (Theorem 4).

## Implementation Plan

1. `innerProduct` defined with size guard; returns 0 on mismatch.
2. `thm3CoreAssumption_native` proved via `simp` (barLiftVector = id).
3. P10 check/prop bridges proved via `decide_eq_true` / `decide_eq_true_eq`.
4. `p10Core_of_assumption` derives from `thm3CoreAssumption` and shape predicates.

## Quality Expectations

- No `sorry` in any theorem.
- Theorem-3 boundary is the single semantic surface; P10 is the executable compatibility layer.

## Acceptance Criteria

1. `lake build` succeeds.
2. `lake exe check` succeeds.
3. `thm3CoreAssumption_native` and all P10 theorems exported through the interface.

## Out of Scope

- Full bar-lift instantiation (non-identity); that belongs to a future embedding/bar-lift extension.

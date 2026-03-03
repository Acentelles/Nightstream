# Thm3Core Spec

## Purpose

- **What it is**: The Theorem-3 inner-product transform module. It defines `innerProduct` (dot product with size guard), the universal contract `thm3CoreAssumption` stating that inner products are preserved under bar-lift, a real-operator closure path via `barLiftChunkedIsometryAssumption`, and the P10 compatibility surface (`p10CoreProp`, `p10CoreCheck`) for executable checks.
- **Key property**: `∀ a b, innerProduct a b = innerProduct (barLift a) (barLift b)` when `a.size = b.size` — i.e. `ct(ā·b̄) = ⟨a,b⟩` in paper notation.
- **Protocol role**: BarLift uses Thm3Core to derive matrix-transform assumption. MatrixTransform uses `thm3CoreAssumption` to prove Theorem 4 (matrix-vector product transform).

## Target Formulas (Paper → Lean)

- Paper formula: `ct(ā·b̄) = ⟨a,b⟩` (Theorem 3, Inner Product Transform)
- Lean mapping:
  - `innerProduct a b` : dot product with size guard
  - `thm3CoreAssumption bar` : `∀ a b, a.size = b.size → innerProduct a b = innerProduct (barLiftVector bar a) (barLiftVector bar b)`
  - `barLiftChunkedIsometryAssumption bar` : chunked-branch closure (`a.size % d = 0`) for the real bar-lift operator
  - `thm3CoreAssumption_of_chunkedIsometry` : extends chunked closure to full `thm3CoreAssumption` using fallback-branch identity
  - `p10CoreProp bar a b` : `a.size = b.size ∧ innerProduct a b = innerProduct (barLiftVector bar a) (barLiftVector bar b)`
  - `p10CoreCheck bar a b = true ↔ p10CoreProp bar a b`
- Target statement: Theorem-3 closure is routed through the real bar-lift branch contract, not the global bar-block identity path.

## Paper Anchors

- Source: `./formal/superneo-lean/SuperNeo.pdf.md`
- Anchors:
  - Theorem 3 (Inner Product Transform), Section 5, lines 368-372: `ct(ā·b̄) = ⟨a,b⟩`

## Module Mapping

- Implementation: `SuperNeo.Thm3Core`
- Interface: `SuperNeo.Thm3CoreInterface`

## Contract Surface

| Contract group | Lean surface | Preconditions | Guarantee | Role | Used by |
|---|---|---|---|---|---|
| Inner product | `innerProduct a b` | None (size guard returns 0 if mismatch) | Dot product `Σ_i a[i]·b[i]` when `a.size = b.size` | Definitional | `MatrixTransform.lean` |
| Theorem-3 boundary | `thm3CoreAssumption bar` | None | `∀ a b, a.size = b.size → innerProduct a b = innerProduct (barLiftVector bar a) (barLiftVector bar b)` | Theorem-Target | `MatrixTransform.lean` |
| Real branch boundary | `barLiftChunkedIsometryAssumption bar` | Size equality + chunkability | Chunked branch preserves inner product | Boundary | `thm3CoreAssumption_of_chunkedIsometry` |
| Real closure | `thm3CoreAssumption_of_chunkedIsometry`, `thm3CoreAssumption_native` | `barLiftChunkedIsometryAssumption bar` | Full `thm3CoreAssumption bar` (chunked branch from boundary, non-chunked branch by definition) | Theorem-Target | `MatrixTransform.lean` |
| Compatibility closure | `thm3CoreAssumption_of_barBlockIdentity` | `barBlockIdentityAssumption bar` | Recovers old identity-specialized closure path | Theorem-Target | Legacy callers |
| Shape predicates | `IsDVec`, `IsDBarMatrix` | None | `a.size = d`, `True` | Definitional | P10 wrappers |
| P10 proposition | `p10CoreProp bar a b` | None | `a.size = b.size ∧ innerProduct a b = innerProduct (barLiftVector bar a) (barLiftVector bar b)` | Definitional | — |
| P10 check | `p10CoreCheck bar a b` | None | `p10CoreCheck bar a b = true ↔ p10CoreProp bar a b` | Theorem-Target | — |
| Sound/complete | `p10CoreCheck_sound`, `p10CoreCheck_complete` | Check true / Prop holds | Bidirectional bridge | Theorem-Target | — |
| From preconditions | `p10Core_of_preconditions`, `p10Core_of_preconditions_props`, `p10Core_of_assumption` | Shape + check / Thm3 | `p10CoreProp bar a b` | Theorem-Target | — |

## Proof Obligations and Closure Plan

Closed now:
- `thm3CoreAssumption_of_chunkedIsometry` (real-operator closure from chunked branch + fallback identity branch).
- `thm3CoreAssumption_of_barBlockIdentity` compatibility theorem.
- P10 sound/complete and `p10Core_of_*` theorems.

Remaining for paper-faithful proof-complete closure:
- discharge `barLiftChunkedIsometryAssumption` from lower algebraic embedding/ring lemmas (instead of carrying it as a boundary contract).

## Assumption Ledger

- Open boundary: `barLiftChunkedIsometryAssumption` (real bar-lift chunked branch inner-product preservation).
- Compatibility-only: `barBlockIdentityAssumption` path retained as non-primary closure bridge.

## Dependency and Consumer Map

- Upstream dependencies:
  - `SuperNeo/BarLift.lean`: imports `barLiftVector` for `thm3CoreAssumption` and P10 surfaces.
- Downstream consumers:
  - `SuperNeo/MatrixTransform.lean`: uses `thm3CoreAssumption` and `innerProduct` to derive `matrixTransformAssumption` (Theorem 4).

## Implementation Plan

1. `innerProduct` defined with size guard; returns 0 on mismatch.
2. Prove `thm3CoreAssumption_of_chunkedIsometry` by branch split on chunkability:
   - chunked branch from `barLiftChunkedIsometryAssumption`,
   - non-chunked branch from `barLiftVector = id` fallback.
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

- Discharging `barLiftChunkedIsometryAssumption` from the full embedding/ring theorem stack.

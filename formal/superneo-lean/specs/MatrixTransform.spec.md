# MatrixTransform Spec

## Purpose

- **What it is**: Theorem-4 matrix-vector product transform layer. Defines `matrixVecDirect` (direct Mz) and `matrixVecCtBar` (ct(M̄z) via bar-lift), the executable check `matrixTransformIdentity`, and the universal contract `matrixTransformAssumption`.
- **Key property**: `Mz = ct(M̄z)` — for shape-compatible `m`, `z`, the direct matrix-vector product equals the bar-lifted product under the coefficient transform.
- **Protocol role**: EvalLink depends on `matrixTransformAssumption`. ProtocolTarget uses matrix-transform for the evaluation homomorphism (Theorem 5) chain.

## Target Formulas (Paper → Lean)

- Paper formula: Theorem 4 (Matrix-Vector Product Transform): `Mz = ct(M̄z)`
- Lean mapping:
  - `dotVec a b` : dot product with size guard
  - `matrixVecDirect m z` : direct Mz (row-wise)
  - `matrixVecCtBar bar m z` : ct(M̄z) via `barLiftVector`
  - `dotVec a b = innerProduct a b` (equivalence)
  - `matrixTransformIdentity bar m z = true ↔ MatrixRowsCompatible m z ∧ matrixVecDirect m z = matrixVecCtBar bar m z`
  - `matrixTransformAssumption bar m` : `∀ z, MatrixRowsCompatible m z → matrixVecDirect m z = matrixVecCtBar bar m z`
- Target statement: All closures proved (native, Thm3, P10+P11, P9).

## Paper Anchors

- Source: `./formal/superneo-lean/SuperNeo.pdf.md`
- Anchors:
  - Theorem 4 (Matrix-Vector Product Transform), Section 5, lines 384-386: `Mz = ct(M̄z)`

## Module Mapping

- Implementation: `SuperNeo.MatrixTransform`
- Interface: `SuperNeo.MatrixTransformInterface`

## Contract Surface

| Contract group | Lean surface | Preconditions | Guarantee | Status | Used by |
|---|---|---|---|---|---|
| Dot product | `dotVec a b` | None (size guard) | `dotVec a b = innerProduct a b` | Proved | — |
| Direct product | `matrixVecDirect m z` | None | Row-wise `dotVec row z` | Definitional | — |
| Bar-lifted product | `matrixVecCtBar bar m z` | None | Row-wise `dotVec (barLiftVector bar row) (barLiftVector bar z)` | Definitional | — |
| Dot/inner equivalence | `dotVec_eq_innerProduct` | None | `dotVec a b = innerProduct a b` | Proved | — |
| Row compatibility | `MatrixRowsCompatible m z` | None | `∀ i, (m[i]).size = z.size` | Definitional | — |
| Check surface | `matrixTransformIdentity bar m z` | None | `true ↔ MatrixRowsCompatible m z ∧ matrixVecDirect m z = matrixVecCtBar bar m z` | Proved | — |
| Theorem-facing boundary | `matrixTransformAssumption bar m` | None | `∀ z, MatrixRowsCompatible m z → matrixVecDirect m z = matrixVecCtBar bar m z` | Proved | `EvalLink.lean` |
| Check-facing boundary | `matrixTransformCheckAssumption bar m` | None | `∀ z, MatrixRowsCompatible m z → matrixTransformIdentity bar m z = true` | Proved | — |
| Native closure | `matrixTransformEq_native`, `matrixTransformAssumption_native` | `MatrixRowsCompatible m z` | `matrixVecDirect m z = matrixVecCtBar bar m z` | Proved | — |
| Thm3 closure | `matrixTransformAssumption_of_thm3CoreAssumption` | `thm3CoreAssumption bar` | `matrixTransformAssumption bar m` | Proved | — |
| P10+P11 closure | `matrixTransformAssumption_of_p10_p11` | `thm3CoreAssumption bar`, `barLiftLinearityAssumption bar` | `matrixTransformAssumption bar m` | Proved | — |
| P9 closure | `matrixTransformAssumption_of_p9Embedding`, `matrixTransformAssumption_of_p9Embedding_closed` | P9 embedding | `matrixTransformAssumption bar m` | Proved | — |
| Check/prop bridges | `matrixTransformIdentity_sound`, `matrixTransformIdentity_complete`, `matrixTransformIdentity_iff_prop`, `_of_assumption`, `_of_checkAssumption`, `_iff_checkAssumption` | None | Theorem ↔ check equivalence | Proved | — |

## Proof Obligations and Closure Plan

All obligations closed. `matrixTransformEq_native` proves Theorem 4 in scaffold. `matrixTransformAssumption_of_thm3CoreAssumption` derives from Theorem 3 row-wise. P9-threaded closure reduces to native path. Sound/complete and check/prop bridges proved.

## Assumption Ledger

No open boundary assumptions in this module.

## Dependency and Consumer Map

- Upstream dependencies:
  - `SuperNeo/Thm3Core.lean`: uses `thm3CoreAssumption`, `innerProduct` for Theorem-3-based derivation.
  - `SuperNeo/BarLift.lean`: uses `barLiftVector`, `barLiftLinearityAssumption` for P10+P11 path.
- Downstream consumers:
  - `SuperNeo/EvalLink.lean`: depends on `matrixTransformAssumption` for evaluation homomorphism.
  - ProtocolTarget: uses matrix-transform in the protocol stack.

## Implementation Plan

1. `dotVec`, `matrixVecDirect`, `matrixVecCtBar` defined; `dotVec_eq_innerProduct` proved.
2. `matrixTransformEq_native` proved via `simp` (barLiftVector = id).
3. `matrixTransformEq_of_thm3CoreAssumption` applies Thm3 row-wise under `MatrixRowsCompatible`.
4. Sound/complete and check/prop bridges proved via `decide` reasoning.
5. P9 closure reduces to native path.

## Quality Expectations

- No `sorry` in any theorem.
- Theorem-facing boundary is the contract; check-facing is for executable compatibility.

## Acceptance Criteria

1. `lake build` succeeds.
2. `lake exe check` succeeds.
3. `matrixTransformAssumption_of_p9Embedding_closed` and all bridges exported through the interface.

## Out of Scope

- Non-identity bar-lift instantiation (future embedding extension).

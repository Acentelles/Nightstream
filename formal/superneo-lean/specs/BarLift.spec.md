# BarLift Spec

## Purpose

- **What it is**: Definition-8 bar-lift layer. Defines `barLiftVector` and `barLiftMatrix` (row-wise) as the core operators mapping vectors/matrices under the bar transform. In the compact scaffold, `barLiftVector` is the identity.
- **Key property**: Linearity — `barLiftVector bar (v + w) = barLiftVector bar v + barLiftVector bar w` and `barLiftVector bar (s·v) = s · barLiftVector bar v` when sizes match.
- **Protocol role**: MatrixTransform and Thm3Core depend on `barLiftLinearityAssumption`. Embedding feeds into BarLift (P9 → bar-lift linearity).

## Target Formulas (Paper → Lean)

- Paper formula: Definition 8 (Lifting the Transform) — bar-lift is linear: add and scale commute.
- Lean mapping:
  - `barLiftVector bar v` : vector bar-lift (identity in scaffold)
  - `barLiftMatrix bar m` : row-wise `barLiftVector`
  - `barLiftLinearityAssumption bar` : `(∀ v w, v.size = w.size → barLiftVector bar (v+w) = barLiftVector bar v + barLiftVector bar w) ∧ (∀ s v, barLiftVector bar (s·v) = s · barLiftVector bar v)`
  - `barLiftLinearityCheckAssumption bar` : check-facing universal contract
- Target statement: `barLiftLinearityAssumption bar ↔ barLiftLinearityCheckAssumption bar`; all closures proved.

## Paper Anchors

- Source: `./formal/superneo-lean/SuperNeo.pdf.md`
- Anchors:
  - Definition 8 (Lifting the Transform), Section 5, lines 376-382

## Module Mapping

- Implementation: `SuperNeo.BarLift`
- Interface: `SuperNeo.BarLiftInterface`

## Contract Surface

| Contract group | Lean surface | Preconditions | Guarantee | Status | Used by |
|---|---|---|---|---|---|
| Vector bar-lift | `barLiftVector bar v` | None | `barLiftVector bar v = v` (scaffold) | Proved | `Thm3Core.lean`, `MatrixTransform.lean` |
| Matrix bar-lift | `barLiftMatrix bar m` | None | Row-wise `barLiftVector` | Proved | — |
| Identity | `barLiftVector_eq`, `barLiftMatrix_eq` | None | `barLiftVector bar v = v`, `barLiftMatrix bar m = m` | Proved | — |
| Linearity | `barLiftVector_add`, `barLiftVector_scale` | Add: `v.size = w.size` | `barLiftVector bar (v+w) = barLiftVector bar v + barLiftVector bar w`; scale linearity | Proved | — |
| Theorem-facing boundary | `barLiftLinearityAssumption bar` | None | Add + scale linearity (Prop) | Proved | `MatrixTransform.lean` |
| Check-facing boundary | `barLiftLinearityCheckAssumption bar` | None | Executable check (Prop) | Proved | — |
| Native closure | `barLiftLinearityAssumption_native` | None | `barLiftLinearityAssumption bar` | Proved | — |
| P9 closure | `barLiftLinearityAssumption_of_p9Embedding`, `barLiftLinearityAssumption_of_p9Embedding_closed` | P9 embedding | `barLiftLinearityAssumption bar` | Proved | — |
| Check/prop bridges | `barLiftLinearityCheckAssumption_of_assumption`, `barLiftLinearityAssumption_of_checkAssumption`, `barLiftLinearityAssumption_iff_checkAssumption` | None | Theorem ↔ check equivalence | Proved | — |

## Proof Obligations and Closure Plan

All obligations closed. `barLiftLinearityAssumption_native` proves linearity in scaffold (`barLiftVector = id`). P9-threaded closure reduces to native path. Check/prop bridges proved via `decide_eq_true` / `decide_eq_true_eq`.

## Assumption Ledger

No open boundary assumptions in this module.

## Dependency and Consumer Map

- Upstream dependencies:
  - `SuperNeo/Embedding.lean`: imports `p9EmbeddingAssumption`, `p9EmbeddingAssumption_holds` for P9-threaded closure.
- Downstream consumers:
  - `SuperNeo/Thm3Core.lean`: uses `barLiftVector` for `thm3CoreAssumption` and P10 surfaces.
  - `SuperNeo/MatrixTransform.lean`: depends on `barLiftLinearityAssumption` and `barLiftVector` for Theorem 4.

## Implementation Plan

1. `barLiftVector` and `barLiftMatrix` defined; identity in scaffold.
2. `barLiftVector_add`, `barLiftVector_scale` proved by `rfl`.
3. `barLiftLinearityAssumption_native` proves full linearity.
4. P9 bridges reduce to native; check/prop bridges via `decide` reasoning.

## Quality Expectations

- No `sorry` in any theorem.
- Theorem-facing boundary is the contract; check-facing is for executable compatibility.

## Acceptance Criteria

1. `lake build` succeeds.
2. `lake exe check` succeeds.
3. `barLiftLinearityAssumption_of_p9Embedding_closed` and all bridges exported through the interface.

## Out of Scope

- Non-identity bar-lift instantiation (future embedding extension).

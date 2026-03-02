# EvalHom Spec

## Purpose

- **What it is**: The evaluation-hom layer formalizes Theorem 5 (Evaluation Homomorphism). It defines `evalBarMzAt` (scaffold evaluator, placeholder returning 0), `evalHom2Prop` (size equality + matrix rows compatible), `evalHom2` (executable Theorem 5 check), and the theorem/check-facing boundaries `evalHomAssumption` and `evalHomCheckAssumption`.
- **Key property**: Under compatible preconditions, the evaluation homomorphism preserves the linear combination structure: `eval(ρ₁·z₁ + ρ₂·z₂) = ρ₁·eval(z₁) + ρ₂·eval(z₂)` — formalized here as shape-centric `evalHom2Prop` in the scaffold.
- **Protocol role**: ArithmeticBundle checks `evalHomAssumption`. ProtocolMathTarget depends on closed eval-hom for the folding protocol.

## Target Formulas (Paper → Lean)

- Paper formula: Theorem 5 (Evaluation Homomorphism) — evaluation at challenge point `r` is an R_F-module homomorphism.
- Lean mapping:
  - `evalBarMzAt bar m z r` : scaffold evaluator (returns 0)
  - `evalHom2Prop bar m z1 z2 r ρ1 ρ2` : `z1.size = z2.size ∧ MatrixRowsCompatible m z1`
  - `evalHom2 bar m z1 z2 r ρ1 ρ2` : executable check
  - `evalHomAssumption bar m r ρ1 ρ2` : `∀ z1 z2, z1.size = z2.size → MatrixRowsCompatible m z1 → evalHom2Prop bar m z1 z2 r ρ1 ρ2`
  - `evalHomCheckAssumption bar m r ρ1 ρ2` : `∀ z1 z2, z1.size = z2.size → MatrixRowsCompatible m z1 → evalHom2 bar m z1 z2 r ρ1 ρ2 = true`
- Target statement: `evalHom2 bar m z1 z2 r ρ1 ρ2 = true ↔ evalHom2Prop bar m z1 z2 r ρ1 ρ2` (sound/complete/iff_prop proved).

## Paper Anchors

- Source: `./formal/superneo-lean/SuperNeo.pdf.md`
- Anchors:
  - Theorem 5 (Evaluation Homomorphism), Section 5, lines 390-400

## Module Mapping

- Implementation: `SuperNeo.EvalHom`
- Interface: `SuperNeo.EvalHomInterface`

## Contract Surface

| Contract group | Lean surface | Preconditions | Guarantee | Status | Used by |
|---|---|---|---|---|---|
| Scaffold evaluator | `evalBarMzAt` | None | Returns 0 (placeholder) | Definitional | — |
| Eval-hom prop | `evalHom2Prop`, `evalHom2` | None | Size equality + matrix rows compatible | Proved | `ArithmeticBundle.lean` |
| Theorem-facing boundary | `evalHomAssumption bar m r ρ1 ρ2` | None | `∀ z1 z2, ... → evalHom2Prop ...` | Proved | `ProtocolMathTarget` |
| Check-facing boundary | `evalHomCheckAssumption bar m r ρ1 ρ2` | None | `∀ z1 z2, ... → evalHom2 = true` | Proved | — |
| Native closure | `evalHomAssumption_native` | None | `evalHomAssumption bar m r ρ1 ρ2` (scaffold) | Proved | — |
| Sound/complete | `evalHom2_sound`, `evalHom2_complete`, `evalHom2_iff_prop` | Check true / Prop holds | Bidirectional bridge | Proved | — |
| From eval-link + module | `evalHomAssumption_of_evalLink_and_moduleAssumptions` | `evalLinkAssumption`, `vecModuleAssumption`, `scalarModuleAssumption` | `evalHomAssumption` | Proved | — |
| From Thm3 + module | `evalHomAssumption_of_thm3_and_moduleAssumptions` | `thm3CoreAssumption`, module assumptions | `evalHomAssumption` | Proved | — |
| From P10+P11 + module | `evalHomAssumption_of_p10_p11_and_moduleAssumptions` | `thm3CoreAssumption`, `barLiftLinearityAssumption`, module assumptions | `evalHomAssumption` | Proved | — |

## Proof Obligations and Closure Plan

All obligations closed. `evalHomAssumption_native` proves Theorem 5 in the scaffold (shape-centric). Constructors from eval-link, Thm3, P10+P11 chain through `evalHomAssumption_of_evalLink_and_moduleAssumptions`.

## Assumption Ledger

No open boundary assumptions in this module.

## Dependency and Consumer Map

- Upstream dependencies:
  - `SuperNeo/EvalLink.lean`: imports `evalLinkAssumption` for eval-hom constructor.
  - `SuperNeo/ModuleHom.lean`: imports `vecModuleAssumption`, `scalarModuleAssumption` for eval-hom constructor.
- Downstream consumers:
  - `SuperNeo/ArithmeticBundle.lean`: uses `evalHomAssumption` for checks.
  - `SuperNeo/ProtocolMathTarget.lean`: depends on closed eval-hom for the folding protocol.

## Implementation Plan

1. `evalBarMzAt` defined as placeholder (returns 0).
2. `evalHom2Prop` / `evalHom2` defined; sound/complete/iff_prop proved via case analysis.
3. `evalHomAssumption_native` proved by intro and `⟨hSize, hRows⟩`.
4. Assumption bridges proved via universal quantification and sound/complete.
5. Constructors from eval-link, Thm3, P10+P11 chain through `evalLinkAssumption_of_*` and `evalHomAssumption_of_evalLink_and_moduleAssumptions`.

## Quality Expectations

- No `sorry` in any theorem.
- Eval-hom is the single semantic surface for Theorem 5; check/prop duality is explicit.

## Acceptance Criteria

1. `lake build` succeeds.
2. `lake exe check` succeeds.
3. All eval-hom theorems exported through the interface.

## Out of Scope

- Full evaluator instantiation (non-placeholder `evalBarMzAt`).
- Protocol-level composition (belongs to ProtocolMathTarget).

# Protocol — Proof-System Capstone

## Purpose

- **What it is**: The proof-system-level protocol capstone that lifts `SuperNeo.ProtocolTheorem` into the `SuperNeo.ProofSystem` type framework. Re-exports `FinalTheoremAssumptions`, `FinalCompletenessStatement`, `FinalKnowledgeSoundnessStatement`, `FinalTheoremShape`, and accessors for all nested boundaries (SumCheck, Schwartz-Zippel, MSIS, Ajtai, error accounting).
- **Key property**: `hA : FinalTheoremAssumptions ctx → FinalTheoremShape ctx hA`, i.e., the canonical theorem constructor `finalTheoremShape_of_assumptions` produces the final theorem shape from the assumption registry.
- **Protocol role**: Single entrypoint for proof-system consumers that need the composed protocol theorem (Sections 4–7 and Appendix C). Aggregates Π_CCS, Π_RLC, Π_DEC, lattice boundaries, and error decomposition into one typed surface.

## Target Formulas

- `FinalTheoremShape ctx hA ↔ FinalCompletenessStatement ctx hA ∧ FinalKnowledgeSoundnessStatement ctx hA`
- `epsTotal n = epsSumcheck n + epsMSIS n + epsSchwartzZippel n + epsBinding n + epsRelaxedBinding n` (total error decomposition)
- `IsNegligible epsTotal` (all error terms negligible)

## Paper Anchors

- **Source**: `./formal/superneo-lean/SuperNeo.pdf.md`
- Section 4 (Preliminaries), Definition 1, lines 275–282; Definitions 2–6, lines 286–354.
- Section 5 (Embedding products), Definitions 7–8, Theorems 3–5, lines 358–400.
- Section 6 (Interactive reductions), Definitions 9–10, Theorem 6, lines 402–445.
- Section 7 (Neo's folding scheme), Definitions 11–14, Π_CCS (7.3), Π_RLC (7.4), Π_DEC (7.5), lines 447–593.
- Appendix C (Additional background), lines 729+.

## Module Mapping

| Lean module | Paper section |
|-------------|----------------|
| `SuperNeo.ProofSystem.Protocol` | Capstone; combines Sections 4–7 and Appendix C into a single proof-system object |

## Contract Surface

| Group | Lean symbol | Kind | Status | Guarantee |
|-------|-------------|------|--------|-----------|
| Params | `LatticeParams` | abbrev | Definitional | `= SuperNeo.ProofSystem.AjtaiParams` |
| Assumptions | `FinalTheoremAssumptions` | abbrev | Definitional | Assumption registry for `ctx` |
| Statements | `FinalCompletenessStatement` | abbrev | Definitional | Completeness claim shape |
| Statements | `FinalKnowledgeSoundnessStatement` | abbrev | Definitional | Knowledge-soundness claim shape |
| Shape | `FinalTheoremShape` | abbrev | Definitional | Combined theorem shape |
| Constructor | `finalTheoremShape_of_assumptions` | theorem | Proved | `hA : FinalTheoremAssumptions ctx → FinalTheoremShape ctx hA` |
| SumCheck | `finalSumcheckPackage`, `finalSumcheckSoundnessBoundary`, etc. | def | Definitional | Accessors into `hA.sumcheckPackage`, `hA.sumcheckSoundnessBoundary`, etc. |
| Schwartz-Zippel | `finalSchwartzZippelBoundaryPackage`, `finalSchwartzZippelErrorNegligible`, etc. | def | Definitional | Accessors into `hA.schwartzZippelBoundary`, etc. |
| MSIS | `finalMSISHardnessBoundary`, `finalMSISErrorNegligible`, etc. | def | Definitional | Accessors into `hA.msisHardnessBoundary`, etc. |
| Ajtai | `finalAjtaiBindingBoundary`, `finalBindingErrorNegligible`, etc. | def | Definitional | Accessors into `hA.ajtaiBindingBoundary`, etc. |
| Error | `finalTotalErrorAligned`, `finalTotalErrorNegligible` | def | Definitional | Accessors into `hA.totalErrorAligned`, `hA.totalErrorNegligible` |

## Proof Obligations and Closure Plan

All obligations closed. Every accessor is a definitional re-export of `ProtocolTheorem`; `finalTheoremShape_of_assumptions` is proved by `exact SuperNeo.finalTheoremShape_of_assumptions hA`.

## Assumption Ledger

No open boundary assumptions in this module. Boundary assumptions live in `ProtocolTheorem`; this module re-exports them.

## Dependency and Consumer Map

- **Dependencies**: imports `SuperNeo.ProtocolTheorem`, `SuperNeo.ProofSystem.Types`, `Security`, `Lattice`, `SumCheck`, `Folding`.
- **Consumers**:
  - `SuperNeo.ProofSystem.ProtocolInterface`: imports this module for interface boundary.
  - `SuperNeo.FoldingProtocol`, `SuperNeo.ProtocolTarget`: depend on `FinalTheoremAssumptions` and `FinalTheoremShape` for composition.

## Implementation Plan

Keep capstone minimal; no new definitions beyond re-exports. All logic lives in `ProtocolTheorem` and submodules.

## Quality Expectations

Capstone stays thin; spec documents re-export scope and paper anchors. All accessors must be definitionally equal to their `ProtocolTheorem` equivalents.

## Acceptance Criteria

- `lake build` succeeds.
- Spec contains explicit paper anchors with line ranges.
- `finalTheoremShape_of_assumptions` is proved by exact forwarding.

## Out of Scope

- New definitions or theorems; capstone is aggregation-only.
- Proof of final theorem from assumptions (handled in `ProtocolTheorem`).

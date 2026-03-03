# ProtocolTheorem Spec

## Purpose

- **What it is**: The canonical final theorem shape for the SuperNeo formalization. Provides an explicit assumption registry (`FinalTheoremAssumptions`), completeness and knowledge-soundness statement shapes, and a canonical theorem constructor from assumptions.
- **Key property**: `FinalTheoremAssumptions ctx → FinalTheoremShape ctx` (completeness + knowledge-soundness); all error boundaries (SumCheck, Schwartz-Zippel, MSIS, Ajtai binding) are aligned and negligible.
- **Protocol role**: CAPSTONE theorem. Combines all reductions from Sections 5–7 with lattice security from Appendix C.

## Target Formulas (Paper → Lean)

- `FinalTheoremShape ctx hA ↔ FinalCompletenessStatement ctx hA ∧ FinalKnowledgeSoundnessStatement ctx hA`
- `FinalTheoremAssumptions ctx → FinalTheoremShape ctx`
- `finalTheoremShape_of_assumptions hA` proves the above
- `SchwartzZippelAdvantageBound eps ↔ ∀ prob n, SchwartzZippelAdvantage prob n ≤ (eps n : Rat)`
- `msisHardnessAssumption params`, `ajtaiBindingAssumption params`, `ajtaiRelaxedBindingAssumption params C` (typed boundaries; relaxed binding is parameterized by sampling carrier `C`)
- `totalErrorAligned`: `epsTotal = epsSumcheck + epsMSIS + epsSchwartzZippel + epsBinding + epsRelaxedBinding`

## Paper Anchors

- Source: `./formal/superneo-lean/SuperNeo.pdf.md`
- Anchors:
  - Section 7.6 (implied final theorem): Composition of Π_CCS, Π_RLC, Π_DEC with knowledge-soundness
  - Section 7, lines 447–596: Neo's folding scheme for CCS
  - Appendix B/C/D: Assumption accounting, lattice security (MSIS, Ajtai binding)

## Module Mapping

- Implementation: `SuperNeo.ProtocolTheorem`
- Interface: `SuperNeo.ProtocolTheoremInterface`

## Contract Surface

| Contract group | Lean surface | Preconditions | Guarantee | Role | Used by |
|---|---|---|---|---|---|
| Schwartz-Zippel | `schwartzZippelFailureEvent`, `SchwartzZippelAdvantage`, `SchwartzZippelAdvantageBound`, `SchwartzZippelBoundary` | None | Theorem-facing SZ surfaces | Definitional | — |
| Lattice | `LatticeParams`, `msisHardnessAssumption`, `ajtaiBindingAssumption`, `ajtaiRelaxedBindingAssumption params C` | None | Typed boundaries for MSIS/Ajtai; relaxed binding parameterized by `C : SamplingCarrier` | Definitional | — |
| Reduction boundaries | `reductionSumcheckSoundnessBoundary`, `reductionSumcheckCompletenessBoundary` | `InteractiveReductionAssumptions` | Extracted SumCheck boundaries | Definitional | — |
| Final assumptions | `FinalTheoremAssumptions ctx` | None | Bundles reduction, sumcheck, SZ, error model, lattice, alignments | Definitional | — |
| Accessors | `FinalTheoremAssumptions.sumcheckSoundnessBoundary`, `schwartzZippelBoundaryAssumption`, `msisHardnessBoundary`, etc. | `FinalTheoremAssumptions` | Projected boundaries | Theorem-Target | — |
| Error negligibility | `sumcheckErrorNegligible`, `schwartzZippelErrorNegligible`, `msisErrorNegligible`, `bindingErrorNegligible`, `totalErrorNegligible` | `FinalTheoremAssumptions` | Aligned negligibility | Theorem-Target | — |
| Final theorem | `FinalTheoremShape`, `finalTheoremShape_of_assumptions` | `FinalTheoremAssumptions` | Completeness + knowledge-soundness | Theorem-Target | ProofSystem.Protocol |

## Proof Obligations and Closure Plan

All obligations closed. `finalTheoremShape_of_assumptions` proves completeness from `weakComposition_of_assumptions` and knowledge-soundness from `strongComposition_of_assumptions` plus all error-bound alignments. 40+ declarations, none with sorry.

## Assumption Ledger

No open boundary assumptions in this module. All declarations are proved or definitional. `FinalTheoremAssumptions` is the boundary surface that consumers must instantiate; the theorem constructor is proved once the bundle is instantiated.

## Dependency and Consumer Map

- Upstream dependencies:
  - `SuperNeo/InteractiveReductions.lean`: imports `InteractiveReductionAssumptions`, `strongComposition_of_assumptions`, `weakComposition_of_assumptions`
  - `SuperNeo/Interp.lean`: imports `interpolationAssumption`
  - `SuperNeo/ProofSystem.Lattice.lean`: imports `AjtaiParams`, MSIS/Ajtai boundaries
  - `SuperNeo/ProofSystem.LatticeReductions.lean`: imports MSIS-to-Ajtai reductions
  - `SuperNeo/ProofSystem.SumCheck.lean`: imports `SumcheckSoundnessAssumption`, `SumcheckCompletenessAssumption`, `TheoremPackage`
  - `SuperNeo/ProofSystem.Security.lean`: imports `ErrorModel`, `IsNegligible`
- Downstream consumers:
  - `SuperNeo/ProofSystem.Protocol.lean`: uses `FinalTheoremShape`, `finalTheoremShape_of_assumptions` for the protocol proof

## Implementation Plan

1. Schwartz-Zippel and lattice boundaries defined as typed surfaces.
2. `FinalTheoremAssumptions` bundles reduction, sumcheck, SZ, error model, lattice, alignments.
3. Accessors and error-negligibility proofs derive from aligned fields.
4. `finalTheoremShape_of_assumptions` proves completeness and knowledge-soundness from the bundle.

## Quality Expectations

- No `sorry` in any theorem.
- 40+ declarations, all proved or definitional.

## Acceptance Criteria

1. `lake build` succeeds.
2. `lake exe check` succeeds.
3. All surfaces exported through the interface.

## Out of Scope

- Concrete instantiation of `FinalTheoremAssumptions`; that belongs to protocol setup.
- Proof of cryptographic primitives (MSIS, Ajtai); those are in ProofSystem.Lattice.

# ProtocolTheorem Spec

## Purpose

- **What it is**: The canonical final theorem shape for the SuperNeo formalization. Provides an explicit assumption registry (`FinalTheoremAssumptions`), completeness and knowledge-soundness statement shapes, and a canonical theorem constructor from assumptions.
- **Key property**: `FinalTheoremAssumptions ctx → FinalTheoremShape ctx` (completeness + knowledge-soundness); the knowledge statement keeps the minimal paper-facing surfaces (strong composition, challenge assumptions, per-component advantage bounds, total-error decomposition, total negligibility).
- **Protocol role**: CAPSTONE theorem. Combines all reductions from Sections 5–7 with lattice security from Appendix C.

## Target Formulas (Paper → Lean)

- `FinalTheoremShape ctx hA ↔ FinalCompletenessStatement ctx hA ∧ FinalKnowledgeSoundnessStatement ctx hA`
- `FinalTheoremAssumptions ctx → FinalTheoremShape ctx`
- `finalTheoremShape_of_assumptions hA` proves the above
- `FinalKnowledgeSoundnessStatement ctx hA` contains:
  - `strongCompositionStatement ctx`
  - `schwartzZippelAssumption`
  - equality between the faithful SumCheck game transcript and the reduction witness transcript
  - faithful prefix-dependent SumCheck Lund bound for the protocol-facing game package
  - faithful game-level SumCheck advantage bound aligned to `epsSumcheck`
  - advantage bounds for Schwartz-Zippel / MSIS / Ajtai-binding / Ajtai-relaxed-binding
  - `totalErrorDecompFromModel`
  - `IsNegligible epsTotal`
- `SchwartzZippelAdvantageBound eps ↔ ∀ prob n, SchwartzZippelAdvantage prob n ≤ (eps n : Rat)`
- `FinalTheoremAssumptions.sumcheckAdvantageBound`:
  `SoundnessFailureAdvantageBound (sumcheckInstanceOfContext ctx) witnessTranscript epsSumcheck`
  as a convenience theorem about the concrete reduction witness transcript
- `FinalTheoremAssumptions.sumcheckWitnessTranscriptEq`:
  the faithful prefix-game transcript instantiated on the reduction witness
  challenges is definitionally the reduction witness transcript
- `FinalTheoremAssumptions.sumcheckPrefixLundBound`:
  `game.lundBoundHolds (fullFieldUniformCoinProbModel game.inst.rounds)` for the
  protocol-facing `SumcheckPrefixLundBoundary ctx`
- `FinalTheoremAssumptions.sumcheckPrefixAdvantageBound`:
  `game.advantage (fullFieldUniformCoinProbModel game.inst.rounds) ≤ epsSumcheck sumcheckErrorIndex`
- `msisHardnessAssumption params`, `ajtaiBindingAssumption params`, `ajtaiRelaxedBindingAssumption params C` (typed boundaries; relaxed binding is parameterized by sampling carrier `C`)
- `totalErrorDecompFromModel`: `epsTotal = epsSumcheck + epsMSIS + epsSchwartzZippel + epsBinding + epsRelaxedBinding`

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
| SumCheck prefix game | `SumcheckPrefixLundBoundary ctx` | `ProtocolTargetContext` | Concrete protocol-facing SumCheck game/alignment package for the faithful prefix-dependent Lund endpoint | Definitional | `FinalTheoremAssumptions` |
| Canonical error package | `FinalErrorPackage params` | None | Bundles SumCheck/SZ/MSIS/MSIS→Ajtai error surfaces plus one consolidated alignment witness against a shared `ErrorModel` | Definitional | `FinalTheoremAssumptions` |
| Final assumptions | `FinalTheoremAssumptions ctx` | None | Bundles reduction + protocol-facing SumCheck prefix game + lattice params + canonical error package; per-component alignments are derived accessors | Definitional | — |
| Accessors | `FinalTheoremAssumptions.sumcheckPrefixBoundary`, `schwartzZippelBoundaryAssumption`, `msisHardnessBoundary`, etc. | `FinalTheoremAssumptions` | Projected boundaries | Theorem-Target | — |
| SumCheck prefix endpoint | `FinalTheoremAssumptions.sumcheckPrefixLundBound` | `FinalTheoremAssumptions` | Faithful protocol-facing prefix-dependent Lund bound | Theorem-Target | — |
| SumCheck transcript link | `FinalTheoremAssumptions.sumcheckWitnessTranscriptEq` | `FinalTheoremAssumptions` | Identifies the faithful prefix-game transcript with the reduction witness transcript | Theorem-Target | — |
| SumCheck game advantage | `FinalTheoremAssumptions.sumcheckPrefixAdvantageBound` | `FinalTheoremAssumptions` | Faithful protocol-facing game-level SumCheck advantage bound aligned to `epsSumcheck` at the chosen final-theorem error index | Theorem-Target | — |
| SumCheck witness helper | `FinalTheoremAssumptions.sumcheckAdvantageBound` | `FinalTheoremAssumptions` | Convenience failure-event advantage bound for the witness transcript; not part of the primary final knowledge-soundness shape | Theorem-Target | — |
| Error negligibility | `sumcheckErrorNegligible`, `schwartzZippelErrorNegligible`, `msisErrorNegligible`, `bindingErrorNegligible`, `totalErrorNegligible` | `FinalTheoremAssumptions` | Aligned negligibility | Theorem-Target | — |
| Final theorem | `FinalTheoremShape`, `finalTheoremShape_of_assumptions` | `FinalTheoremAssumptions` | Completeness + knowledge-soundness | Theorem-Target | ProofSystem.Protocol |

## Proof Obligations and Closure Plan

All obligations closed. `finalTheoremShape_of_assumptions` proves completeness from `weakComposition_of_assumptions` and knowledge-soundness from `strongComposition_of_assumptions` plus the faithful protocol-facing SumCheck prefix-Lund endpoint, an explicit transcript link from the faithful game to the reduction witness, faithful game-level SumCheck advantage accounting aligned to `epsSumcheck` at one explicit final-theorem error index, Schwartz-Zippel/MSIS/Ajtai advantage-bound surfaces, and total-error accounting. Alignment equalities are derived from the canonical `FinalErrorPackage` witness. The witness-level SumCheck bound remains available as a helper accessor, but it is no longer part of the primary final knowledge-soundness statement.

## Assumption Ledger

No open boundary assumptions in this module. All declarations are proved or definitional. `FinalTheoremAssumptions` is the boundary surface that consumers must instantiate; the theorem constructor is proved once the bundle is instantiated.

## Dependency and Consumer Map

- Upstream dependencies:
  - `SuperNeo/InteractiveReductions.lean`: imports `InteractiveReductionAssumptions`, `strongComposition_of_assumptions`, `weakComposition_of_assumptions`
  - `SuperNeo/Interp.lean`: imports `interpolationAssumption`
  - `SuperNeo/ProofSystem.Lattice.lean`: imports `AjtaiParams`, MSIS/Ajtai boundaries
  - `SuperNeo/ProofSystem.LatticeReductions.lean`: imports MSIS-to-Ajtai reductions
  - `SuperNeo/ProofSystem.SumCheck.lean`: imports `SoundnessErrorBoundary`, `lundSoundnessAssumptionFullFieldAlignedPosRounds_prefix`
  - `SuperNeo/ProofSystem.Security.lean`: imports `ErrorModel`, `IsNegligible`
- Downstream consumers:
  - `SuperNeo/ProofSystem.Protocol.lean`: uses `FinalTheoremShape`, `finalTheoremShape_of_assumptions` for the protocol proof

## Implementation Plan

1. Schwartz-Zippel and lattice boundaries defined as typed surfaces.
2. `FinalTheoremAssumptions` bundles reduction, protocol-facing SumCheck prefix-Lund package, lattice parameters, and one canonical `FinalErrorPackage`.
3. Accessors and error-negligibility proofs derive from the package and its single alignment witness.
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

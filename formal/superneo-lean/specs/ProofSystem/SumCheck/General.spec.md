# General — Sum-Check Theorem Package and Facade

## Purpose

- **What it is**: Proof-system SumCheck facade with `SoundnessErrorBoundary`, `TheoremPackage` (soundness/completeness parameters, negligible soundness error), theorem forwarding from `SingleRound`, and top-level `soundness`/`completeness` surfaces.
- **Key property**: \(\text{TheoremPackage}(s, c)\) carries \(\varepsilon\) with \(\text{IsNegligible}(\varepsilon)\); \(\text{Accepted}(\text{inst}, \text{tr}) \to \text{ClaimTrue}(\text{inst})\) (soundness); \(\text{ClaimTrue}(\text{inst}) \to \exists \text{tr}, \text{Accepted}(\text{inst}, \text{tr})\) (completeness).
- **Protocol role**: Provides the typed boundary for sum-check soundness error and the theorem package used by folding reductions (Π_CCS, Π_RLC) in Sections 7.3–7.4.

## Target Formulas

- \(\text{SoundnessErrorBoundary} \equiv \{\varepsilon : \text{ErrorFn}, \text{IsNegligible}(\varepsilon)\}\).
- \(\text{TheoremPackage}(s, c) \to \text{IsNegligible}(\text{eps})\).
- \(\text{TheoremPackage}(s, c) \wedge \text{Accepted}(\text{inst}, \text{tr}) \to \text{ClaimTrue}(\text{inst})\) (soundness).
- \(\text{TheoremPackage}(s, c) \wedge \text{ClaimTrue}(\text{inst}) \to \exists \text{tr}, \text{Accepted}(\text{inst}, \text{tr})\) (completeness).
- \(\text{soundness}(h) \wedge \text{Accepted} \to \text{ClaimTrue}\); \(\text{completeness}(h) \wedge \text{ClaimTrue} \to \exists \text{tr}, \text{Accepted}\).

## Paper Anchors

- **Source**: `./formal/superneo-lean/SuperNeo.pdf.md`
- Definition 6 (The sum-check protocol), lines 352–355.
- Section 7.3 (Π_CCS), lines 481–548: sum-check soundness error \(\le \ell d / |\mathbb{K}|\).

## Module Mapping

| Paper concept | Lean symbol | Role |
|---------------|-------------|--------|
| Soundness error boundary | `SoundnessErrorBoundary` | Definitional |
| Theorem package | `TheoremPackage` | Definitional |
| eps projection | `TheoremPackage.eps` | Definitional |
| Negligible | `TheoremPackage.negligible` | Theorem-Target |
| Soundness | `TheoremPackage.soundness`, `soundness` | Boundary |
| Completeness | `TheoremPackage.completeness`, `completeness` | Boundary |
| Extraction | `accepted_rounds_eq`, etc. | Theorem-Target (forwarded) |

## Contract Surface

| Group | Symbol | Guarantee | Role |
|-------|--------|-----------|--------|
| Boundary | `SoundnessErrorBoundary` | `epsSoundness : ErrorFn`, `negligibleEpsSoundness` | Definitional |
| Package | `TheoremPackage` | Carries `soundnessError : SoundnessErrorBoundary` | Definitional |
| | `TheoremPackage.eps` | Projects soundness error function | Definitional |
| | `TheoremPackage.negligible` | \(\text{IsNegligible}(\text{eps})\) | Theorem-Target |
| | `TheoremPackage.soundness` | \(\text{Accepted} \to \text{ClaimTrue}\) | Boundary |
| | `TheoremPackage.completeness` | \(\text{ClaimTrue} \to \exists \text{tr}, \text{Accepted}\) | Boundary |
| Top-level | `soundness`, `completeness` | Assumption-instantiated surfaces | Boundary |

## Proof Obligations and Closure Plan

- `TheoremPackage.negligible`: closed.
- `TheoremPackage.soundness`, `TheoremPackage.completeness`, `soundness`, `completeness`: carried as typed assumptions (SoundnessAssumption, CompletenessAssumption); closure target: prove via Schwartz-Zippel and honest-prover construction in core SumCheck.

## Assumption Ledger

- `SoundnessAssumption` [Boundary]: \(\text{Accepted} \to \text{ClaimTrue}\). Closure target: prove via sum-check soundness (Definition 6).
- `CompletenessAssumption` [Boundary]: \(\text{ClaimTrue} \to \exists \text{tr}, \text{Accepted}\). Closure target: constructive honest-prover transcript.

## Dependency and Consumer Map

- **Dependencies**: imports `SuperNeo.ProofSystem.SumCheck.SingleRound`, `SuperNeo.ProofSystem.Types`, `SuperNeo.ProofSystem.Security`.
- **Consumers**:
  - `SuperNeo.ProofSystem.SumCheck`: imports General for barrel.
  - `SuperNeo.ProofSystem.Folding.PiCCS`, `PiRLC`: depend on sum-check acceptance/claim for Π_CCS and Π_RLC.

## Implementation Plan

Keep theorem package as typed boundary; soundness/completeness proofs are future-scope in core SumCheck.

## Quality Expectations

Theorem package exposes explicit soundness-error surface; assumptions are minimal and documented.

## Acceptance Criteria

- `lake build` succeeds.
- Spec contains explicit paper anchors with line ranges.
- Assumption ledger documents boundary assumptions.

## Out of Scope

- Probabilistic soundness proof; that lives in core `SuperNeo.SumCheck`.

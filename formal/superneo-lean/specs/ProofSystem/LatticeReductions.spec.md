# ProofSystem/LatticeReductions.spec.md

## Purpose

- **What it is**: MSIS-to-Ajtai binding reduction theorems that derive Ajtai commitment security from Module-SIS hardness.
- **Key property**: `ajtaiBoundaries_of_msis` bundles standard + relaxed binding reductions: MSIS hardness → ¬BindingCollision ∧ ¬RelaxedBindingCollision.
- **Protocol role**: Provides the lattice-security reduction consumed by `ProtocolTheorem` to close the protocol's security proof under MSIS hardness.

## Target Formulas

- `‖subVec n w₁ w₂‖∞ < msisNormBound` = norm transfer from binding collision witnesses.
- `MSISBreakEvent → ¬BindingCollision` = standard binding from MSIS.
- `MSISBreakEvent → ¬RelaxedBindingCollision` = relaxed binding from MSIS.
- `MSISHardnessAssumption → AjtaiBindingAssumption ∧ AjtaiRelaxedBindingAssumption` = `ajtaiBoundaries_of_msis`.

## Paper Anchors

Source: ./formal/superneo-lean/SuperNeo.pdf.md

- Theorem 2 (Ajtai Properties), lines 319-321.
- Definition 16 (MSIS), lines 743-744.
- Definition 18 (Ajtai commitment), lines 753-756.

## Module Mapping

| Paper concept | Lean symbol | Status |
|---------------|-------------|--------|
| Norm transfer | `bindingCollision_subWitness_norm_lt_msisNormBound` | Proved |
| Standard MSIS break | `msisBreakEvent_of_bindingCollision` | Proved |
| Relaxed MSIS break | `msisBreakEvent_of_relaxedBindingCollision` | Proved |
| No break under hardness | `no_msisBreakEvent_of_hardness` | Proved |
| Standard binding | `no_ajtaiBindingCollision_of_advantageBound` | Proved |
| Ajtai from MSIS (standard) | `ajtaiBinding_of_msis` | Proved |
| Ajtai from MSIS (relaxed) | `ajtaiRelaxedBinding_of_msis` | Proved |
| Combined bundle | `ajtaiBoundaries_of_msis` | Proved |
| Reduction bundle | `MSISToAjtaiReductions` (structure) | Definitional |
| Bundle constructor | `MSISToAjtaiReductions.mk` | Proved |

## Contract Surface

| Group | Symbol | Guarantee | Status |
|-------|--------|-----------|--------|
| Norm | `bindingCollision_subWitness_norm_lt_msisNormBound` | `‖w₁ - w₂‖∞ < msisNormBound` | Proved |
| Extraction | `msisBreakEvent_of_bindingCollision` | Collision → MSIS break | Proved |
| Extraction | `msisBreakEvent_of_relaxedBindingCollision` | Relaxed collision → MSIS break | Proved |
| Security | `no_msisBreakEvent_of_hardness` | Hardness → no break event | Proved |
| Binding | `ajtaiBinding_of_msis` | MSIS → standard binding | Proved |
| Binding | `ajtaiRelaxedBinding_of_msis` | MSIS → relaxed binding | Proved |
| Bundle | `ajtaiBoundaries_of_msis` | MSIS → both bindings | Proved |

## Proof Obligations and Closure Plan

- All theorems are proved (no sorry).
- Proofs depend on the 8 axioms from `Lattice.lean`; once those axioms are discharged, these proofs remain valid.

## Assumption Ledger

No open boundary assumptions in this module. (All assumptions are inherited from `Lattice.lean` and documented there.)

## Dependency and Consumer Map

- **Dependencies**: `SuperNeo.ProofSystem.Lattice` (uses structures, axioms, and vector operations).
- **Consumers**:
  - `SuperNeo.ProtocolTheorem`: imports `LatticeReductions` for `ajtaiBoundaries_of_msis` in the final theorem.
  - `SuperNeo.ProofSystem.Protocol`: uses reduction bundle in the proof-system capstone.

## Implementation Plan

- Stable. No changes expected until Lattice axioms are discharged.

## Quality Expectations

- All reduction theorems proved without sorry.
- Clear norm-transfer chain from collision to MSIS break.

## Acceptance Criteria

- `lake build` succeeds.
- All theorems type-check without sorry.
- Spec documents Theorem 2 with line ranges.

## Out of Scope

- Concrete MSIS advantage computation (abstracted via `MSISAdvantageBound`).
- Probabilistic game semantics for challenger/adversary.

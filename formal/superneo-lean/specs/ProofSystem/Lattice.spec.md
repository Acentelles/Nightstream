# Lattice.spec.md

## Purpose

- **What it is**: Ajtai commitment parameters, opening/collision structures, MSIS challenge/solution surfaces, and hardness/advantage boundaries for the Module-SIS and Ajtai commitment schemes.
- **Key property**: Theorem 2: Ajtai is \(B\)-binding (resp. \((B,\mathcal{C})\)-relaxed binding) assuming \(\text{MSIS}_{m,2B}^{\infty,\kappa,q}\) (resp. \(\text{MSIS}_{m,4TB}^{\infty,\kappa,q}\)) is hard.
- **Protocol role**: Provides the lattice-security surfaces consumed by `LatticeReductions` for MSIS-to-Ajtai binding reductions; protocol theorems assume MSIS hardness and derive Ajtai binding.

## Target Formulas

- \(\text{MSIS}_{m,B}^{\infty,\kappa,q}\): find \(z \neq 0\) with \(Mz = 0 \pmod q\), \(\|z\|_\infty < B\) ↔ `MSISBreakEvent`, `MSISSolution`.
- \(\text{Commit}(\text{pp}, z) = Mz\) ↔ `opensTo`: \(M \cdot z = c\) with \(\|z\|_\infty < B\).
- Relaxed: \(\Delta \cdot c = Mz\) ↔ `opensToRelaxed`.
- \(B\)-binding collision: \(z_1 \neq z_2\), \(Mz_1 = Mz_2 = c\), \(\|z_i\|_\infty < B\) ↔ `BindingCollision`.
- \((B,\mathcal{C})\)-relaxed: \(\Delta_1 z_2 \neq \Delta_2 z_1\), \(\Delta_i c = Mz_i\) ↔ `RelaxedBindingCollision`.
- \(\text{Adv}_{\text{MSIS}} \le \varepsilon(n)\), \(\text{IsNegligible}(\varepsilon)\) ↔ `MSISAdvantageBound`, `MSISHardnessAssumption`.

## Paper Anchors

- **Source**: `./formal/superneo-lean/SuperNeo.pdf.md`
- Definition 16 (MSIS), lines 743–744.
- Definition 18 (Ajtai commitment), lines 753–756.
- Theorem 2 (Properties), lines 319–321.
- Definition 4 (\(B\)-binding, \((B,\mathcal{C})\)-relaxed binding), lines 305–315.

## Module Mapping

| Paper concept | Lean symbol | Status |
|---------------|-------------|--------|
| Ajtai params | `AjtaiParams` | Definitional |
| Commitment / opening | `Commitment`, `Opening` | Definitional |
| opensTo | `opensTo` | Definitional |
| opensToRelaxed | `opensToRelaxed` | Definitional |
| Binding collision | `BindingCollision` | Definitional |
| Relaxed binding collision | `RelaxedBindingCollision` | Definitional |
| MSIS challenge/solution | `MSISChallenge`, `MSISSolution` | Definitional |
| MSIS break event | `MSISBreakEvent` | Definitional |
| MSIS hardness | `MSISHardnessAssumption`, `MSISHardnessBoundary` | Definitional |
| Ajtai binding assumptions | `AjtaiBindingAssumption`, `AjtaiRelaxedBindingAssumption` | Definitional |
| subVec, matVecMul, smulVec | `subVec`, `matVecMul`, `smulVec` | Definitional |
| subVec_self | `subVec_self` | Proved |
| Ring/norm axioms | `subRq`, `subRq_self`, `matVecMul_subVec`, etc. | Boundary-Assumed |

## Contract Surface

| Group | Symbol | Guarantee | Status |
|-------|--------|-----------|--------|
| Parameters | `AjtaiParams` | \(\kappa, m, B, T\) | Definitional |
| Commitment relations | `opensTo`, `opensToRelaxed` | \(Mz = c\), \(Mz = \Delta \cdot c\) | Definitional |
| Collisions | `BindingCollision`, `RelaxedBindingCollision` | Paper-faithful distinctness | Definitional |
| MSIS | `MSISBreakEvent`, `MSISSolution`, `MSISChallenge` | Homogeneous MSIS, \(Mz = 0\) | Definitional |
| Hardness | `MSISHardnessAssumption`, `MSISHardnessBoundary` | \(\exists \varepsilon, \text{IsNegligible}(\varepsilon) \wedge \text{Adv} \le \varepsilon\) | Definitional |
| Ajtai assumptions | `AjtaiBindingAssumption`, `AjtaiRelaxedBindingAssumption` | \(\neg \text{BindingCollision}\), \(\neg \text{RelaxedBindingCollision}\) | Definitional |
| Vector ops | `subVec_self` | \(\text{subVec}\,n\,v\,v = \text{zeroVec}\,n\) | Proved |
| Ring axioms | 8 axioms (see Assumption Ledger) | Ring arithmetic identities | Boundary-Assumed |

## Proof Obligations and Closure Plan

- **Proved**: `subVec_self`, size lemmas, `matrixFlatLen_le_payloadLen`, `commitmentLen_le_payloadLen`, `msisNormBound_pos`, `ppMatrixFlat_size_of_wf`, `valueVec_size_of_wf`, `NormSound_mono`, `smulVec_size`, `matVecMul_size`.
- **Pending**: Discharge 8 boundary axioms from Ring/Norm layers (see Assumption Ledger).

## Assumption Ledger

| Assumption | Closure target: |
|------------|----------------|
| `subRq` | Define ring subtraction in `SuperNeo.Ring` (or equivalent) and prove it matches `subRq` behavior. |
| `subRq_self` | Prove \(x - x = 0\) from ring axioms in `SuperNeo.Ring`. |
| `matVecMul_subVec` | Prove \(M(v_1 - v_2) = Mv_1 - Mv_2\) from linearity in `SuperNeo.Ring` / matrix module. |
| `matVecMul_smulVec` | Prove \(M(\delta \cdot v) = \delta \cdot (Mv)\) from module homomorphism. |
| `smulVec_comm` | Prove \(\delta_1 \cdot (\delta_2 \cdot v) = \delta_2 \cdot (\delta_1 \cdot v)\) from ring commutativity. |
| `subVec_ne_zero_of_ne` | Prove \(v_1 \neq v_2 \to \text{subVec}\,n\,v_1\,v_2 \neq \text{zeroVec}\,n\) when sizes match. |
| `normInfVec_subVec_le` | Prove \(\|\text{subVec}\,n\,v_1\,v_2\|_\infty \le \|v_1\|_\infty + \|v_2\|_\infty\) from `SuperNeo.Norm`. |
| `normInfVec_smulVec_le` | Prove \(\|\delta \cdot v\|_\infty \le \|\delta\|_\infty \cdot \|v\|_\infty\) from `SuperNeo.Norm`. |

## Dependency and Consumer Map

- **Dependencies**: `SuperNeo.Ring`, `SuperNeo.Norm`, `SuperNeo.ProofSystem.Negligible`, `SuperNeo.ProofSystem.Security`.
- **Consumers**:
  - `SuperNeo.ProofSystem.LatticeReductions`: uses `BindingCollision`, `RelaxedBindingCollision`, `MSISBreakEvent`, `MSISHardnessAssumption`, `AjtaiBindingAssumption`, `AjtaiRelaxedBindingAssumption`, `subVec`, `matVecMul`, `smulVec`, and the 8 axioms for extractor and reduction theorems.

## Implementation Plan

- Discharge each axiom in order: `subRq`/`subRq_self` first, then linearity (`matVecMul_subVec`, `matVecMul_smulVec`), then `smulVec_comm`, then `subVec_ne_zero_of_ne`, then norm lemmas from `Norm`.
- Keep boundary packages coherent; avoid constructor privacy changes that break reduction wiring.

## Quality Expectations

- All 8 axioms documented with explicit closure targets.
- Spec states Theorem 2 and Definitions 16, 18 with line ranges.
- Interface exposes core structures and boundary symbols.

## Acceptance Criteria

- `lake build` succeeds.
- Assumption Ledger lists all 8 axioms with closure targets.
- Paper anchors include Definition 16, 18, Theorem 2 and line ranges.

## Out of Scope

- Concrete probabilistic game semantics (challenger/adversary sampling); abstract `breakAt` shells suffice for theorem-facing layer.
- Advantage-to-probability translation for general negligible model; current eventually-zero model is sufficient for truth-valued `Pr`.

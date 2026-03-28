# NonZeroInitTwist Spec

## Purpose

- **What it is**: The bridge-layer theorem owner for the modified non-zero-init
  Twist `Val` identity used by instantiations that authenticate an initial
  memory surface instead of reducing to zero-init preload writes.
- **Key property**: `shiftedValEvaluationExpression_eq_timeTableMLE`: the
  verifier-facing value-evaluation expression for the shifted memory table is
  exactly the MLE of the table obtained by adding the authenticated initial
  surface to the reconstructed increment-prefix table.
- **Protocol role**: This module closes the gap between the paper's zero-init
  `Inc -> Val` theorem surface and an instantiation that chooses the modified
  non-zero-init route permitted by
  `docs/soundness-specs/twist-and-shout-requirements.md`.

## Target Formulas

Let:

- `init : Address -> K` be an authenticated initial memory surface,
- `Inc(k, j)` be the committed increment table,
- `Val0(k, j)` be the paper's zero-init reconstructed value table from
  `TwistValueEval`,
- `ValInit(k, j)` be the shifted non-zero-init value table.

Define:

$$
\mathrm{ShiftedTimeTable}(init, Inc)(k,j)
:=
init(k) + \mathrm{Val0}(k,j).
$$

Define the pointwise shifted virtual value:

$$
\mathrm{ShiftedVirtualValue}(init, Inc)(k, r_{cycle})
:=
init(k) + \widetilde{\mathrm{Val0}}(k, r_{cycle}).
$$

Define the verifier-facing shifted evaluation surface:

$$
\mathrm{ShiftedValEvaluationExpression}(init, Inc)(r_{addr}, r_{cycle})
:=
\widetilde{init}(r_{addr}) +
\mathrm{ValEval0}(Inc)(r_{addr}, r_{cycle}).
$$

The target theorems are:

$$
\mathrm{ShiftedVirtualValue}(init, Inc)(k, \mathbf{j})
=
\mathrm{ShiftedTimeTable}(init, Inc)(k, j)
$$

for Boolean cycle points `\mathbf{j}`,

$$
\mathrm{ShiftedValEvaluationExpression}(init, Inc)(\mathbf{a}, \mathbf{j})
=
\mathrm{ShiftedTimeTable}(init, Inc)(a, j)
$$

for Boolean address/cycle points,

and the bundled random-point identity:

$$
\widetilde{\mathrm{ShiftedTimeTable}(init, Inc)}(r_{addr}, r_{cycle})
=
\mathrm{ShiftedValEvaluationExpression}(init, Inc)(r_{addr}, r_{cycle}).
$$

This is the exact modified `Val` identity required when the instantiation uses
an authenticated non-zero initial memory surface directly.

## Paper Anchors

- `./docs/soundness-specs/twist-and-shout-requirements.md`
- `./docs/twist-and-shout-paper/5_the_twist_piop.md`
- `./docs/twist-and-shout-paper/B_details_of_the_widetilde_text_val_evaluation_sum_check_prover.md`

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/NonZeroInitTwist.lean` | Modified non-zero-init `init + Inc -> Val` bridge identities |
| `Nightstream/NonZeroInitTwistInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Definitions | `ShiftedTimeTable` | def | Definitional | Adds the authenticated initial surface to the zero-init reconstructed table |
| Definitions | `ShiftedVirtualValue` | def | Definitional | Shifted pointwise virtual-memory evaluator |
| Definitions | `ShiftedValEvaluationExpression` | def | Definitional | Shifted verifier-facing random-point evaluation target |
| Theorem | `shiftedVirtualValue_at_bitCycle` | theorem | Theorem-Target | Boolean cycle evaluation matches the shifted time table |
| Theorem | `shiftedValEvaluationExpression_at_bitPoint` | theorem | Theorem-Target | Boolean address/cycle evaluation matches the shifted time table |
| Theorem | `timeTableMLE_initialSurface` | theorem | Theorem-Target | A cycle-constant initial surface evaluates to its address MLE |
| Theorem | `shiftedValEvaluationExpression_eq_timeTableMLE` | theorem | Theorem-Target | The shifted evaluation surface equals the MLE of the shifted table |

## Proof Obligations

- The modified non-zero-init route must remain explicit and separate from the
  paper's zero-init theorem surface.
- The bridge must preserve the exact `Inc -> Val` dependency chain, with the
  initial surface added as an explicit authenticated base term.
- This module must not claim any new paper-level PIOP theorem; it only proves
  the mathematical identity needed by the allowed non-zero-init instantiation.

## Assumption Ledger

- This module assumes the zero-init Twist identities already proved in
  `twist-shout-lean`.
- Authentication of the initial memory surface is external to this module.
- Transcript ordering, PCS soundness, and batching analysis remain external.

## Dependency and Consumer Map

- **Upstream dependencies**:
  - `TwistShout/TwistCoreInterface.lean`
  - `TwistShout/TwistValueEvalInterface.lean`
  - `TwistShout/ShoutCoreInterface.lean`
  - `TwistShout/MLEInterface.lean`
- **Downstream consumers**:
  - CHIP-8 Stage-2 initialization and state-surface owners
  - later non-zero-init instantiation bridges in Nightstream

## Out of Scope

- proving authentication of the initial surface
- proving the paper's zero-init theorem statements
- chip8-specific register/RAM state extraction

# Rv64IMTemporaryRegisterHygiene Spec

## Purpose

- **What it is**: The theorem-facing contract for temporary virtual-register write-before-read discipline.
- **What it is not**: It is not a register allocator and it does not prove any specific opcode lowering.
- **Protocol role**: It fixes the exact hygiene obligation that a committed lowered sequence may not depend on stale temporary-register contents from earlier sequences.

## Target Formulas

Fix:

- `sequence : List Row`
- `isTempRegister : Register → Prop`
- `readsRegister : Row → Register → Prop`
- `writesRegister : Row → Register → Prop`

The hygiene target is:

$$
\mathrm{TemporaryRegisterHygiene}
(\mathrm{sequence},\ \mathrm{isTempRegister},\ \mathrm{readsRegister},\ \mathrm{writesRegister})
$$

meaning:

every read of a temporary virtual register in the committed sequence is preceded
by an earlier write to that same temporary virtual register in the same
committed sequence.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/TemporaryRegisterHygiene.lean` | Temporary-register hygiene theorem surface |
| `Nightstream/Rv64IM/Execution/TemporaryRegisterHygieneInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Guarantee |
|---|---|---|---|
| Semantics | `TemporaryRegisterHygiene` | def | States write-before-read for temporary registers |
| Package | `TemporaryRegisterHygieneProofPackage` | structure | Packages the hygiene theorem target |

## Proof Obligations

- Temporary registers `40..47` may not be read stale.
- Sequence correctness therefore ranges over arbitrary prior temporary-register state.

## Out of Scope

- architectural register semantics
- permanent virtual-register liveness

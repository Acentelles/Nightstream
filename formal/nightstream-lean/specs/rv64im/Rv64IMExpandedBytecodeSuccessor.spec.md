# Rv64IMExpandedBytecodeSuccessor Spec

## Purpose

- **What it is**: The theorem-facing contract for the expanded-bytecode start and successor law.
- **What it is not**: It is not the bytecode lowering algorithm and it does not prove row-local execution semantics.
- **Protocol role**: It fixes the exact semantic obligations that bind architectural `PC`, expanded-bytecode entrypoint, and expanded-bytecode successor movement across and within lowered sequences.

## Target Formulas

Fix:

- `Entrypoint : Pc → BytecodeAddr`
- `succExpanded : BytecodeAddr → BytecodeAddr`
- `ExpandedBytecodeRow`

The entrypoint target is:

$$
\mathrm{ExpandedBytecodeEntrypointValid}(\mathrm{Entrypoint},\ pc_0,\ row_0)
$$

meaning:

$$
row_0.\mathrm{isFirstInSequence} = \mathrm{true}
\land
row_0.\mathrm{unexpandedPc} = pc_0
\land
row_0.\mathrm{expandedPc} = \mathrm{Entrypoint}(pc_0).
$$

The successor target is:

$$
\mathrm{ExpandedBytecodeSuccessorValid}(\mathrm{Entrypoint},\ \mathrm{succExpanded},\ row,\ pcNext,\ nextExpandedPc)
$$

meaning:

$$
row.\mathrm{isLastInSequence} = \mathrm{true}
\Longrightarrow
nextExpandedPc = \mathrm{Entrypoint}(pcNext),
$$

and otherwise:

$$
nextExpandedPc = \mathrm{succExpanded}(row.\mathrm{expandedPc}).
$$

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/ExpandedBytecodeSuccessor.lean` | Expanded-bytecode start/successor theorem surface |
| `Nightstream/Rv64IM/Execution/ExpandedBytecodeSuccessorInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Guarantee |
|---|---|---|---|
| Metadata | `ExpandedBytecodeRow` | structure | Packages `unexpandedPc`, `expandedPc`, and sequence-boundary flags |
| Semantics | `ExpandedBytecodeEntrypointValid` | def | Fixes the entrypoint law |
| Semantics | `ExpandedBytecodeSuccessorValid` | def | Fixes the non-final and final successor law |

## Proof Obligations

- Entry to the expanded trace is bound to the lowered entrypoint for the public initial `PC`.
- Non-final rows advance only to the next expanded row.
- Final rows jump to the lowered entrypoint of the next architectural `PC`.

## Out of Scope

- bytecode-table commitment binding
- row-local opcode correctness
- continuity on the main lane

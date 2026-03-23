# Rv64IMProgramBinding Spec

## Purpose

- **What it is**: The theorem-facing contract binding the public program image and lowering version to the committed ROM and expanded-bytecode tables.
- **What it is not**: It is not the ROM parser, ELF loader, or PCS commitment algorithm.
- **Protocol role**: It fixes the exact theorem surface that prevents digest-only binding and makes the committed execution tables a function of public inputs.

## Target Formulas

Fix:

- `deriveRom : ProgramImage → RomTable`
- `deriveBytecode : RomTable → LoweringVersion → BytecodeTable`
- `commitRom : RomTable → RomCommit`
- `commitBytecode : BytecodeTable → BytecodeCommit`
- `ProgramBindingPublicInput`

The binding target is:

$$
\mathrm{ProgramBinding}
(\mathrm{deriveRom},\ \mathrm{deriveBytecode},\ \mathrm{commitRom},\ \mathrm{commitBytecode},\ \mathrm{publicInput})
$$

meaning:

$$
\mathrm{publicInput.romCommitment}
=
\mathrm{commitRom}(\mathrm{deriveRom}(\mathrm{publicInput.programImage}))
$$

and

$$
\mathrm{publicInput.bytecodeCommitment}
=
\mathrm{commitBytecode}(\mathrm{deriveBytecode}(\mathrm{deriveRom}(\mathrm{publicInput.programImage}),\ \mathrm{publicInput.loweringVersion})).
$$

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Kernel/ProgramBinding.lean` | Program-to-commitment binding theorem surface |
| `Nightstream/Rv64IM/Kernel/ProgramBindingInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Guarantee |
|---|---|---|---|
| Public input | `ProgramBindingPublicInput` | structure | Packages public program image, lowering version, and committed table identities |
| Semantics | `ProgramBinding` | def | States exact binding from public inputs to committed ROM and expanded-bytecode tables |
| Package | `ProgramBindingProofPackage` | structure | Packages the binding theorem target |

## Proof Obligations

- Public ROM and expanded-bytecode commitments are functions of the public program image and lowering version.
- Digest-only metadata does not substitute for the program-binding theorem surface.

## Out of Scope

- row-local bytecode evaluation
- Stage-1 successor law
- transcript ordering

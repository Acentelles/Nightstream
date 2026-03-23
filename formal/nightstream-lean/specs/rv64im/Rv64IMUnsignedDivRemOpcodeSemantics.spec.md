# Rv64IMUnsignedDivRemOpcodeSemantics Spec

## Purpose

- **What it is**: The exact opcode-level owner for unsigned DIV/REM semantics above unsigned DIV/REM lowering semantics.
- **What it is not**: It is not the base unsigned soundness package, not the generic family bundle, and not the kernel theorem owner.
- **Protocol role**: It closes the remaining exact-opcode gap for `DIVU`, `REMU`, `DIVUW`, and `REMUW` by tying the unsigned semantic opcode to the decoded-row flags and re-exposing the exact unsigned semantic target at opcode granularity.

## Inputs

The module ranges over:

- one `StepCompositionProofPackage`,
- one `ExactOpcodeFamilySemantics(pkg)`.

It therefore inherits:

- the unsigned DIV/REM lowering owner,
- the theorem-facing unsigned opcode tag from `UnsignedDivRemSoundnessProofPackage`,
- the theorem-facing decoded-row opcode binding from `Rv64IMStepComposition`,
- the theorem-facing equality between the family-owned unsigned soundness
  package and the `StepComposition` unsigned soundness owner.

## Required Theorem Surface

The module must expose:

- `opcodeBound_of_unsignedDivRemOpcodeSemantics`
- `divu_flags_of_unsignedDivRemOpcodeSemantics`
- `remu_flags_of_unsignedDivRemOpcodeSemantics`
- `divuw_flags_of_unsignedDivRemOpcodeSemantics`
- `remuw_flags_of_unsignedDivRemOpcodeSemantics`
- `spec_of_unsignedDivuOpcodeSemantics`
- `spec_of_unsignedRemuOpcodeSemantics`
- `deterministic_of_unsignedDivRemOpcodeSemantics`

## Proof Obligations

- The opcode layer must not invent a new unsigned opcode carrier; it must use the one fixed by `UnsignedDivRemSoundnessProofPackage`.
- The opcode layer must use the family-to-`StepComposition` soundness equality
  when specializing decoded-row flag facts to the concrete opcode cases.
- `DIVU`, `REMU`, `DIVUW`, and `REMUW` must be tied to the exact decoded-row flags through the theorem-facing opcode bound.
- The exact unsigned semantic target remains `UnsignedDivRemSpec`; the opcode layer only specializes it to the concrete opcode cases.
- Determinism remains theorem-visible at opcode granularity.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/UnsignedDivRemOpcodeSemantics.lean` | Unsigned DIV/REM exact opcode semantic owner |
| `Nightstream/Rv64IM/Execution/UnsignedDivRemOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

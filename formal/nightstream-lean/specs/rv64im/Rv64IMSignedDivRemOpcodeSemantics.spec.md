# Rv64IMSignedDivRemOpcodeSemantics Spec

## Purpose

- **What it is**: The exact opcode-level owner for signed DIV/REM semantics above signed DIV/REM lowering semantics.
- **What it is not**: It is not the base signed soundness package, not the generic family bundle, and not the kernel theorem owner.
- **Protocol role**: It closes the remaining exact-opcode gap for `DIV`, `REM`, `DIVW`, and `REMW` by tying the signed semantic opcode to the decoded-row flags and re-exposing the exact signed semantic target at opcode granularity.

## Inputs

The module ranges over:

- one `StepCompositionProofPackage`,
- one `ExactOpcodeFamilySemantics(pkg)`.

It therefore inherits:

- the signed DIV/REM lowering owner,
- the theorem-facing signed opcode tag from `SignedDivRemProofPackage`,
- the theorem-facing decoded-row opcode binding from `Rv64IMStepComposition`,
- the theorem-facing equality between the family-owned signed soundness
  package and the `StepComposition` signed soundness owner.

## Required Theorem Surface

The module must expose:

- `opcodeBound_of_signedDivRemOpcodeSemantics`
- `div_flags_of_signedDivRemOpcodeSemantics`
- `rem_flags_of_signedDivRemOpcodeSemantics`
- `divw_flags_of_signedDivRemOpcodeSemantics`
- `remw_flags_of_signedDivRemOpcodeSemantics`
- `spec_of_signedDivOpcodeSemantics`
- `spec_of_signedRemOpcodeSemantics`

## Proof Obligations

- The opcode layer must not invent a new signed opcode carrier; it must use the one fixed by `SignedDivRemProofPackage`.
- The opcode layer must use the family-to-`StepComposition` soundness equality
  when specializing decoded-row flag facts to the concrete opcode cases.
- `DIV`, `REM`, `DIVW`, and `REMW` must be tied to the exact decoded-row flags through the theorem-facing opcode bound.
- The exact signed semantic target remains `SignedDivRemSpec`; the opcode layer only specializes it to the concrete opcode cases.
- The signed opcode layer must preserve theorem-visible `ChangeDivisorCorrect` and dividend-sign remainder reconstruction through the lowering layer it depends on.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/SignedDivRemOpcodeSemantics.lean` | Signed DIV/REM exact opcode semantic owner |
| `Nightstream/Rv64IM/Execution/SignedDivRemOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

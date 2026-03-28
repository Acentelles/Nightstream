# Rv64IMWordShiftOpcodeSemantics Spec

## Purpose

- **What it is**: The exact opcode-level owner for RV64IM word-width arithmetic
  and shift semantics above word-shift lowering semantics.
- **What it is not**: It is not the class-level word-shift owner, not the
  Stage-1 shift-slot owner, and not the kernel theorem owner.
- **Protocol role**: It closes the exact-opcode gap for the W-width arithmetic
  and shift family by tying the decoded row to one committed word-shift opcode
  and re-exposing the preserved committed-sequence theorem at opcode
  granularity.

## Inputs

The module ranges over:

- one `StepCompositionProofPackage`,
- one `ExactOpcodeFamilySemantics(pkg)`.

It therefore inherits:

- the preserved word-shift committed-sequence proof package,
- the exact decoded Stage-1 row,
- the theorem-facing word-shift ALU-role descriptor
  `pkg.wordShiftAluOps`,
- the theorem-facing exact opcode `pkg.wordShiftOpcode`,
- the theorem-facing exact opcode bound
  `WordShiftOpcodeBound pkg.wordShiftAluOps pkg.decodedRow pkg.wordShiftOpcode`.

## Required Theorem Surface

The module must expose:

- `opcodeBound_of_wordShiftOpcodeSemantics`
- `flags_of_wordShiftOpcodeSemantics`
- opcode-specialized flag consequences for:
  - `ADDW`
  - `ADDIW`
  - `SUBW`
  - `SLLW`
  - `SLLIW`
  - `SRLW`
  - `SRLIW`
  - `SRAW`
  - `SRAIW`
- `sequenceCorrect_of_wordShiftOpcodeSemantics`
- `sequenceDeterministic_of_wordShiftOpcodeSemantics`
- `activeWrite_of_wordShiftOpcodeSemantics`
- `authenticatedWriteback_of_activeWordShiftOpcodeSemantics`
- `routedWriteback_of_activeWordShiftOpcodeSemantics`
- `authenticatedRoutedWriteback_of_activeWordShiftOpcodeSemantics`

## Proof Obligations

- The opcode owner must not invent a new word-shift opcode carrier; it must use
  the one fixed by `StepCompositionProofPackage`.
- The opcode owner must tie the decoded row to the exact opcode through the
  theorem-facing `WordShiftOpcodeBound`, not through an extra consumer-side
  assumption.
- `SRAW` and `SRAIW` must remain visibly tied to the `sra` ALU role and to the
  correct `usesRs2` bit, so the corrected sign-extension-before-shift lowering
  remains carried by the preserved committed-sequence theorem.
- For non-`x0` destinations, the opcode owner must expose the active ALU-write
  routing facts that feed the exact word-result owner above it.
- The opcode owner does not re-prove numeric bit-arithmetic directly; it
  specializes the already-owned word-shift sequence theorem to the exact opcode
  case.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/WordShiftOpcodeSemantics.lean` | Word-shift exact opcode semantic owner |
| `Nightstream/Rv64IM/Execution/WordShiftOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

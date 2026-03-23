# Rv64IMExactAlignedMemoryOpcodeSemantics Spec

## Purpose

- **What it is**: The canonical execution-level bundle for exact native aligned-memory opcode consequences for `LD` and `SD`.
- **What it is not**: It is not part of the seven-family opcode aggregate and it does not replace narrow-memory helper arithmetic or Stage-2 RAM authentication.
- **Protocol role**: It packages the theorem-facing aligned 64-bit RAM-row consequences already justified by `StepComposition`, directly above the accepted decoded row, RAM lane, and write-routing facts.

## Central Object

`ExactAlignedMemoryOpcodeSemantics(pkg)` packages:

- class exclusion facts showing the row is not a branch, jump, multiply, div/rem, or W-op row,
- exact decoded-row flag agreement with the aligned-memory opcode selector for `LD` / `SD`,
- exact RAM-lane load/store role agreement with the decoded row,
- the exact `rd = x0` sink preservation consequence,
- the exact active architectural write contract for `LD`,
- the exact passive architectural write contract for `SD`,
- exact authenticated register operand equalities,
- exact authenticated raw aligned load-word equalities for `LD`,
- exact authenticated load-writeback equalities for active non-`x0` `LD`,
- exact authenticated store-payload equalities for `SD`.

## Required Constructor

The module must expose:

- `exactAlignedMemoryOpcodeSemantics_of_stepComposition`

which recovers the canonical aligned-memory opcode bundle directly from one accepted `StepCompositionProofPackage`.

## Proof Obligations

- The owner ranges only over native aligned 64-bit RAM rows for `LD` and `SD`; it may not silently fold those rows into the seven-family narrow-memory owner.
- The decoded-row flag equalities must factor through the theorem-facing aligned-memory opcode boundary already owned by `Rv64IMStepComposition`.
- The RAM-lane load/store role equalities must factor through the theorem-facing decoded-row to RAM-role bridge already owned by `Rv64IMStepComposition`.
- `LD` writeback must factor through authenticated memory-to-`rd` routing, not an ad hoc direct claim.
- `SD` payload facts must factor through authenticated RAM payload linkage, not an unproved reconstruction of Stage-2 witnesses.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/ExactAlignedMemoryOpcodeSemantics.lean` | Canonical execution-level exact aligned-memory opcode bundle |
| `Nightstream/Rv64IM/Execution/ExactAlignedMemoryOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |

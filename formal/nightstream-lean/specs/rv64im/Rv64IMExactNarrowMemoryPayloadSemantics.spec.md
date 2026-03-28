# Rv64IMExactNarrowMemoryPayloadSemantics Spec

## Purpose

- **What it is**: The canonical execution-level bundle for exact narrow-memory
  RAM-side consequences above exact opcode-family closure.
- **What it is not**: It is not the owner of `extract_extend` / `blend`
  arithmetic definitions and it does not replace Stage-2 RAM authentication.
- **Protocol role**: It packages the theorem-facing consequences already
  justified by `StepComposition`: aligned-address decomposition from the
  authenticated `memAddr`, authenticated raw aligned load words, inactive
  helper-row RAM silence, authenticated aligned store payloads, and memory
  writeback routing.

## Central Object

`ExactNarrowMemoryPayloadSemantics(pkg, families)` packages:

- `alignedAddrDecomposition`
- `loadRawMemVal`
- `loadRawMemValWord`
- `inactiveRamMemValZero`
- `memWritebackWord`
- `storePayload`
- `storePayloadWord`

These consequences range over the exact `StepComposition` package and the exact
family bundle already accepted for the same authenticated row/sequence.

## Required Constructors

The module must expose:

- `exactNarrowMemoryPayloadSemantics_of_exactOpcodeFamilySemantics`
- `exactNarrowMemoryPayloadSemantics_of_stepComposition`

so consumers can recover the same canonical payload bundle either from exact
family semantics or directly from the accepted `StepComposition` package.

## Proof Obligations

- The bundle must use `alignDown8_add_byteOffset8` for address decomposition,
  not a prover-supplied surrogate.
- Raw aligned load-word and aligned store-payload consequences must factor
  through the authenticated RAM linkage already carried by `StepComposition`.
- Memory writeback routing must factor through the existing authenticated
  register writeback theorem rather than through an ad hoc direct claim.
- The bundle must remain RAM-side only: `extract_extend` and `blend` relations
  remain owned by Stage-1 helper arithmetic and are not silently re-attributed
  here.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/ExactNarrowMemoryPayloadSemantics.lean` | Canonical execution-level narrow-memory RAM-side payload bundle |
| `Nightstream/Rv64IM/Execution/ExactNarrowMemoryPayloadSemanticsInterface.lean` | Theorem-facing re-export surface |

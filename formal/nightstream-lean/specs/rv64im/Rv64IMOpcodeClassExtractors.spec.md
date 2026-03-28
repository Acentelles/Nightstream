# Rv64IMOpcodeClassExtractors Spec

## Purpose

- **What it is**: The exact opcode-class extraction owner above `Rv64IMStepComposition`.
- **What it is not**: It is not a new stage-local owner and it does not re-prove execution semantics.
- **Protocol role**: It packages the seven opcode-class proof objects in the fixed canonical order required by the RV64IM kernel spec.

## Canonical Package

`CanonicalOpcodeProofs(proofs)` packages:

- `nativeAlu`
- `wordShift`
- `controlFlow`
- `narrowMemory`
- `multiply`
- `unsignedDivRem`
- `signedDivRem`

together with:

- an exact equality showing `proofs` is exactly that seven-element list in canonical order,
- per-field theorems fixing each proof’s `opcodeClass`.

## Canonical Constructor

The module must expose:

- `canonicalOpcodeProofs_of_stepComposition`

which extracts the exact seven-proof package from one `StepCompositionProofPackage`.

## Required Consequences

From `CanonicalOpcodeProofs(proofs)` one must be able to extract:

- membership of each named proof in `proofs`,
- exact proof-list equality in canonical opcode order,
- the fixed class of each named proof.

Downstream owners must be able to reuse the resulting proof objects to recover:

- `ExecutionCorrect` for each opcode-class package,
- row-level opcode-class agreement for any row inside each extracted package.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/OpcodeClassExtractors.lean` | Canonical opcode-class proof extraction |
| `Nightstream/Rv64IM/Execution/OpcodeClassExtractorsInterface.lean` | Theorem-facing re-export surface |

## Proof Obligations

- The extracted proof order is fixed by the canonical opcode-class order, not prover-chosen.
- The extractor does not weaken existentially to an unordered bag of proofs.
- The extractor stays aligned with the opcode-class order required by `Rv64IMStepComposition`.

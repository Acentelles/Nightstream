# Rv64IMExactOpcodeClassSemantics Spec

## Purpose

- **What it is**: The execution-level owner for exact opcode-class semantic consequences above the canonical RV64IM opcode-class proof package.
- **What it is not**: It is not a stage-local proof owner, not the authenticated trace owner, and not the kernel theorem owner.
- **Protocol role**: It turns each canonical opcode-class proof object into an exact theorem-facing semantic fact bundle.

## Central Objects

`OpcodeClassExecutionFacts(opcodeClass, proof)` packages:

- the exact class equality for `proof`,
- `ExecutionCorrect` for that proof’s semantic rows,
- `ExecutionTraceCorrect` for that proof’s row-backed execution frames,
- exact frame-to-row alignment,
- exact adjacent-frame state linkage,
- exact initial/final execution-trace endpoint equalities,
- `ExpandedRowSequenceBound`,
- `PreparedStepExportBound`,
- `ExpandedBytecodeExecutionBound`,
- `FullSequenceTerminated`,
- boundary start/end PC consequences,
- the terminating / halted consequences,
- row-wise agreement that every row in the proof has the same `opcodeClass`.

`CanonicalOpcodeClassSemantics(canonical)` packages seven exact semantic fact bundles aligned with the fixed canonical opcode order:

1. `nativeAlu`
2. `wordShift`
3. `controlFlow`
4. `narrowMemory`
5. `multiply`
6. `unsignedDivRem`
7. `signedDivRem`

## Required Constructors

The module must expose:

- `opcodeClassExecutionFacts_of_opcodeClassProof`
- `canonicalOpcodeClassSemantics_of_canonicalOpcodeProofs`
- `canonicalOpcodeClassSemantics_of_stepComposition`
- direct per-class extractors from canonical proofs and from step composition for:
  - `nativeAlu`
  - `wordShift`
  - `controlFlow`
  - `narrowMemory`
  - `multiply`
  - `unsignedDivRem`
  - `signedDivRem`

So consumers can move directly from:

- one opcode-class proof object,
- one canonical opcode package,
- or one `StepCompositionProofPackage`

to exact opcode-class semantic consequences without unpacking the package manually.

The module must also expose exact indexed extractors from one `OpcodeClassExecutionFacts`
bundle for:

- frame/row equality at any shared index,
- adjacent-state equality for consecutive execution frames,
- prepared-step/semantic-row equality at any shared index,
- authenticated expanded-bytecode successor equality for any adjacent row pair,
- opcode-class agreement from an exact row-at-index witness.

## Proof Obligations

- The semantic fact bundle must be derived from `ExecutionCorrect`, not assumed separately.
- The row-backed execution-trace facts must be derived from `ExecutionTraceCorrect`, not assumed separately.
- Indexed frame/row, frame/frame, prepared-step/row, and successor/row consequences must factor through the generic execution-semantics extractors rather than being reproved ad hoc downstream.
- Row-class agreement must be exact for every row in the packaged proof.
- The canonical seven-class order remains fixed and prover-independent.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/ExactOpcodeClassSemantics.lean` | Exact opcode-class semantic consequence owner |
| `Nightstream/Rv64IM/Execution/ExactOpcodeClassSemanticsInterface.lean` | Theorem-facing re-export surface |

# Rv64IMAuthenticatedTrace Spec

## Purpose

- **What it is**: The top-level trace theorem owner for RV64IM kernel closure.
- **What it is not**: It is not a stage-local proof package and it does not own transcript scheduling or soundness accounting.
- **Protocol role**: It turns accepted Stage1/2/3 evidence into execution-correct semantic rows, exact active-prefix trace closure, and kernel-facing prepared-step export shape.

## Central Package

`AuthenticatedChunkTrace` packages:

- `StepCompositionProofPackage`,
- `ChunkInput`,
- `MainLaneTraceBoundaryProofPackage`,
- `TraceLinkBoundaryProofPackage`,
- `TemporalConsistencyProofPackage`,
- `Stage2TemporalClosureProofPackage`,
- `Stage3RefinementPackage`,
- equalities linking those packages to one shared active semantic prefix.

In particular it fixes:

- execution rows equal the chunk-input rows,
- execution row count equals the declared semantic row count,
- prepared-step export matches the main-lane boundary,
- main-lane semantic rows equal the chunk-input rows,
- trace-link rows equal the chunk-input rows,
- Stage-2 closure matches the temporal-consistency package.

## Exact-Boundary Entry Point

The exact-boundary constructor owner is
`Nightstream/Rv64IM/Trace/ExactTraceBoundaries.lean`. Its canonical theorem:

- `authenticatedChunkTrace_of_exactBoundaries`

must lift one exact family of accepted trace-local boundaries into the
canonical `AuthenticatedChunkTrace`.

## Derived Consequences

From `AuthenticatedChunkTrace` one can extract:

- `ExecutionCorrect` for the authenticated semantic rows,
- `ExecutionCorrect` instantiated directly on `chunkInput.rows`,
- `MainLaneTraceBoundary(chunkInput.rows, chunkInput.semanticRowCount, mainLane.preparedSteps)`,
- `TraceLinkBoundary(chunkInput.rows, stage2Temporal.stage2.preState, stage2Temporal.stage2.postState)`,
- `PreparedStepExportBound(chunkInput.rows, mainLane.preparedSteps)`,
- `ExpandedRowSequenceBound(chunkInput.rows)`,
- `ExpandedBytecodeExecutionBound(stepComposition.bytecode.entrypoint, stepComposition.bytecode.successors, chunkInput.rows)`,
- `FullSequenceTerminated(stepComposition.execution.boundary, chunkInput.rows)`,
- `AdjacentStateClosed` for the authenticated semantic states,
- `PcAdjacentBridge` over the authenticated semantic prefix,
- exact pointwise equalities tying the authenticated `pcBridge.prePc` and
  `pcBridge.postPc` functions back to the PC projection of the authenticated
  Stage-2 pre/post states,
- `RegisterTimelineBound` and `RamTimelineBound` over that same prefix,
- the exact concrete Twist binding package for the authenticated register/RAM lanes,
- the exact authenticated Stage-2 linkage batch,
- the authenticated register-only and RAM-only linkage consequences,
- the authenticated register write-value consequence on active register writes,
- the authenticated RAM load-value consequence on active loads,
- the authenticated RAM store-payload consequence on active stores,
- the authenticated zero-row RAM `memVal = 0` consequence on inactive RAM rows,
- the exact authenticated Stage-1 linkage batch for the execution row,
- the authenticated taken-target alignment discharge for that row,
- the authenticated Stage-1 unsigned no-overflow support relation,
- the exact canonical seven-proof opcode-class package extracted from the authenticated step composition,
- the exact canonical seven-family semantic bundle recovered from the
  authenticated trace,
- `TemporaryRegisterHygiene` for the authenticated committed sequence,
- `MulUNoOverflow`, `UnsignedDivRemSpec`, and unsigned DIV/REM determinism for the authenticated unsigned DIV/REM package,
- `ChangeDivisorCorrect`, `RemainderFromDividendSign`, and `SignedDivRemSpec` for the authenticated signed DIV/REM package.
- the canonical exact native-ALU/multiply word-arithmetic bundle recovered from
  the authenticated trace, including exact Stage-1 `aluResult` word equalities
  and authenticated non-`x0` writeback-word equalities for those opcode
  families.
- the canonical exact native aligned-memory `LD` / `SD` opcode bundle
  recovered directly from the authenticated trace, including decoded-row /
  RAM-role agreement, authenticated raw load-word equalities, authenticated
  `LD` writeback equalities, and authenticated `SD` payload equalities.
- the canonical exact narrow-memory helper-result bundle recovered directly
  from the authenticated trace, including exact `extractExtend` / `blend`
  formulas for `wordToNat(aluResult)`.
- the canonical exact narrow-memory RAM-side payload bundle recovered directly
  from the authenticated trace.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/AuthenticatedTrace.lean` | Authenticated trace closure |
| `Nightstream/Rv64IM/Trace/AuthenticatedTraceInterface.lean` | Theorem-facing re-export surface |
| `Nightstream/Rv64IM/Trace/ExactTraceBoundaries.lean` | Exact-boundary constructor into authenticated trace closure |
| `Nightstream/Rv64IM/Trace/OpcodeClassSemantics.lean` | Trace-level lifting of exact opcode-class semantic bundles |
| `Nightstream/Rv64IM/Trace/OpcodeFamilySemantics.lean` | Trace-level lifting of exact opcode-family semantic bundles |
| `Nightstream/Rv64IM/Trace/AlignedMemoryOpcodeSemantics.lean` | Trace-level lifting of the exact native aligned-memory opcode bundle |
| `Nightstream/Rv64IM/Trace/WordArithmeticSemantics.lean` | Trace-level lifting of the exact native-ALU/multiply word-arithmetic bundle |
| `Nightstream/Rv64IM/Trace/NarrowMemoryHelperResultSemantics.lean` | Trace-level lifting of the exact narrow-memory helper-result bundle |
| `Nightstream/Rv64IM/Trace/NarrowMemoryPayloadSemantics.lean` | Trace-level lifting of the exact narrow-memory RAM-side payload bundle |

## Proof Obligations

- One authenticated chunk trace closes execution semantics, temporal closure, and export shape over the same exact active prefix.
- The PC bridge inside authenticated trace closure is tied to the Stage-2 state projection pointwise, not only by row count.
- The authenticated trace sits above a Stage-2 concrete binding owner that fixes the non-zero-init register/RAM `Val` surfaces; it does not re-own those Stage-2 formulas.
- Authenticated trace closure is the input to kernel soundness; stage-local theorem packages do not bypass it.
- The theorem-facing authenticated-trace interface must re-export the
  constructor that recovers the exact canonical seven-family semantic bundle.
- The theorem-facing authenticated-trace interface must re-export the
  constructor that recovers the exact word-arithmetic bundle.
- The theorem-facing authenticated-trace interface must re-export the
  constructor that recovers the exact native aligned-memory opcode bundle.
- The theorem-facing authenticated-trace interface must re-export the
  constructor that recovers the exact narrow-memory helper-result bundle.
- The theorem-facing authenticated-trace interface must re-export the
  constructor that recovers the exact narrow-memory RAM-side payload bundle.

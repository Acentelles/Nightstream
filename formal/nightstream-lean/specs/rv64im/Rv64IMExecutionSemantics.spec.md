# Rv64IMExecutionSemantics Spec

## Purpose

- **What it is**: The concrete semantic owner for RV64IM expanded rows and the execution-correctness predicate over an active semantic prefix.
- **What it is not**: It is not a stage-local proof owner and it does not define transcript or PCS behavior.
- **Protocol role**: It fixes the theorem-facing semantic objects consumed by sequence-soundness, trace-closure, and kernel-closure theorems.

## Target Objects

The semantic state objects are:

- `RegisterState(RegIdx, Word)`
- `RamWordState(RamAddr, Word)`
- `ArchitecturalState(Pc, RegIdx, RamAddr, Word)`
- `SequenceBoundary(Pc)`

The canonical execution-row object is:

- `ExpandedRow(Pc, BytecodeAddr, RegIdx, StateLocation)`

carrying the authenticated expanded-bytecode row, opcode class, architectural write target, touched-state inventory, `AdvanceArchPc`, and termination flag.

The kernel-facing exported-row view is:

- `PreparedStepView(Pc)`

with `rowIndex`, `pc`, `advanceArchPc`, and `terminates`.

The row-backed execution-trace object is:

- `ExecutionFrame(Pc, BytecodeAddr, RegIdx, RamAddr, Word, StateLocation)`

carrying one semantic row together with its pre-state and post-state.

## Core Predicates

`PreparedStepExportBound(rows, preparedSteps)` means:

- `preparedSteps.length = rows.length`,
- each exported prepared step is aligned index-by-index with the corresponding semantic row,
- the exported `pc`, `advanceArchPc`, and `terminates` flags match the semantic row.

`ExpandedRowSequenceBound(rows)` means:

- the row list is nonempty,
- the first row is marked `isFirstInSequence`,
- `AdvanceArchPc` matches `isLastInSequence`,
- terminating rows occur only at the final index.

`ExpandedBytecodeExecutionBound(entrypoint, successors, rows)` means:

- row `0` matches the authenticated entrypoint row,
- the successor package has exactly one entry for each adjacent row pair,
- each successor proof links the current row’s authenticated bytecode row to the next row’s `expandedPc`.

`FullSequenceTerminated(boundary, rows)` means the sequence boundary is terminating and the final row in the active prefix is terminating.

`FrameRowsBound(frames, rows)` means the execution frames and semantic rows align index-by-index and each frame owns exactly the corresponding row.

`ExecutionLinked(frames)` means adjacent execution frames are state-linked:

- the post-state of frame `i` is the pre-state of frame `i + 1`.

`ExecutionTraceEndpoints(initialState, finalState, frames)` means:

- the first frame starts at `initialState`,
- the last frame ends at `finalState`.

`ExecutionTraceCorrect(initialState, finalState, rows, frames)` is the conjunction of:

- `FrameRowsBound(frames, rows)`,
- `ExecutionLinked(frames)`,
- `ExecutionTraceEndpoints(initialState, finalState, frames)`.

`ExecutionCorrect(initialState, finalState, rows, preparedSteps, boundary, entrypoint, successors)` is the conjunction of:

- `ExpandedRowSequenceBound(rows)`,
- `PreparedStepExportBound(rows, preparedSteps)`,
- `ExpandedBytecodeExecutionBound(entrypoint, successors, rows)`,
- `FullSequenceTerminated(boundary, rows)`,
- boundary start/end PCs equal the initial/final architectural PCs,
- the final halted flag equals the boundary termination bit.

## Derived Consequences

From `ExecutionCorrect` one must be able to extract:

- `ExpandedRowSequenceBound(rows)`,
- `PreparedStepExportBound(rows, preparedSteps)`,
- `preparedSteps.length = rows.length`,
- exact indexwise prepared-step/row agreement,
- `ExpandedBytecodeExecutionBound(entrypoint, successors, rows)`,
- the authenticated entrypoint row at index `0`,
- `successors.length + 1 = rows.length`,
- exact indexwise authenticated successor agreement for every adjacent row pair,
- `FullSequenceTerminated(boundary, rows)`,
- `boundary.startPc = initialState.pc`,
- `boundary.pcNext = finalState.pc`,
- `boundary.terminates = finalState.halted`.

From `ExecutionTraceCorrect` one must be able to extract:

- `FrameRowsBound(frames, rows)`,
- exact indexwise frame/row agreement,
- `ExecutionLinked(frames)`,
- exact adjacent-frame state equality on every valid consecutive index pair,
- `ExecutionTraceEndpoints(initialState, finalState, frames)`,
- the first-frame initial-state equality,
- the last-frame final-state equality,
- `frames.length = rows.length`.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/ExecutionSemantics.lean` | Semantic objects and `ExecutionCorrect` |
| `Nightstream/Rv64IM/Execution/ExecutionSemanticsInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

- `ArchitecturalState`
- `ExpandedRow`
- `PreparedStepView`
- `ExecutionFrame`
- `PreparedStepExportBound`
- `ExpandedRowSequenceBound`
- `ExpandedBytecodeExecutionBound`
- `FullSequenceTerminated`
- `FrameRowsBound`
- `ExecutionLinked`
- `ExecutionTraceEndpoints`
- `ExecutionTraceCorrect`
- `ExecutionCorrect`
- `ExecutionSemanticsProofPackage`

## Proof Obligations

- Expanded bytecode is the canonical execution object.
- The active semantic prefix is exact, not padded or approximate.
- Execution semantics owns row-backed pre/post-state linkage on the exact active prefix.
- Full halted execution means the final active row is terminating and the boundary is terminating.

## Out of Scope

- opcode-class lowering theorems
- Stage-2 history authentication
- transcript/opening binding

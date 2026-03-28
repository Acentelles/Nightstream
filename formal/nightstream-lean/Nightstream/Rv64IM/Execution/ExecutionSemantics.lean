import Mathlib
import Nightstream.Rv64IM.Execution.ExpandedBytecodeSuccessor
import Nightstream.Rv64IM.Execution.FinalBoundaryClaim

namespace Nightstream.Rv64IM

structure RegisterState (RegIdx Word : Type _) where
  read : RegIdx → Word

structure RamWordState (RamAddr Word : Type _) where
  read : RamAddr → Word

structure ArchitecturalState (Pc RegIdx RamAddr Word : Type _) where
  pc : Pc
  registers : RegisterState RegIdx Word
  ram : RamWordState RamAddr Word
  halted : Bool

structure SequenceBoundary (Pc : Type _) where
  startPc : Pc
  pcNext : Pc
  terminates : Bool
deriving Repr

inductive OpcodeClass where
  | nativeAlu
  | wordShift
  | controlFlow
  | narrowMemory
  | multiply
  | unsignedDivRem
  | signedDivRem
deriving DecidableEq, Repr

structure ExpandedRow (Pc BytecodeAddr RegIdx StateLocation : Type _) where
  bytecode : ExpandedBytecodeRow Pc BytecodeAddr
  opcodeClass : OpcodeClass
  architecturalWriteTarget : Option RegIdx
  touchedState : List StateLocation
  advanceArchPc : Bool
  terminates : Bool
deriving Repr

structure PreparedStepView (Pc : Type _) where
  rowIndex : Nat
  pc : Pc
  advanceArchPc : Bool
  terminates : Bool
deriving Repr

structure ExecutionFrame (Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _) where
  row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation
  preState : ArchitecturalState Pc RegIdx RamAddr Word
  postState : ArchitecturalState Pc RegIdx RamAddr Word

def PreparedStepExportBound
  {Pc BytecodeAddr RegIdx StateLocation : Type _}
  (rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation))
  (preparedSteps : List (PreparedStepView Pc)) : Prop :=
  preparedSteps.length = rows.length ∧
    ∀ idx
      (step : PreparedStepView Pc)
      (row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation),
      preparedSteps[idx]? = some step →
        rows[idx]? = some row →
          PreparedStepView.rowIndex step = idx ∧
            PreparedStepView.pc step = (ExpandedRow.bytecode row).unexpandedPc ∧
              PreparedStepView.advanceArchPc step = ExpandedRow.advanceArchPc row ∧
                PreparedStepView.terminates step = ExpandedRow.terminates row

def ExpandedRowSequenceBound
  {Pc BytecodeAddr RegIdx StateLocation : Type _}
  (rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)) : Prop :=
  rows ≠ [] ∧
    (∀ (idx : Nat) (row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation),
      rows[idx]? = some row →
        (idx = 0 → (ExpandedRow.bytecode row).isFirstInSequence = true)) ∧
    (∀ (idx : Nat) (row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation),
      rows[idx]? = some row →
        ExpandedRow.advanceArchPc row = (ExpandedRow.bytecode row).isLastInSequence) ∧
    ∀ (idx : Nat) (row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation),
      rows[idx]? = some row →
        ExpandedRow.terminates row = true →
          idx + 1 = rows.length

def ExpandedBytecodeExecutionBound
  {Pc BytecodeAddr RegIdx StateLocation : Type _}
  (entrypoint : ExpandedBytecodeEntrypointProofPackage Pc BytecodeAddr)
  (successors : List (ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr))
  (rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)) : Prop :=
  (∃ firstRow : ExpandedRow Pc BytecodeAddr RegIdx StateLocation,
    rows[0]? = some firstRow ∧
      ExpandedRow.bytecode firstRow = entrypoint.firstRow) ∧
    successors.length + 1 = rows.length ∧
    ∀ (idx : Nat)
      (successor : ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr)
      (row nextRow : ExpandedRow Pc BytecodeAddr RegIdx StateLocation),
      successors[idx]? = some successor →
        rows[idx]? = some row →
          rows[idx + 1]? = some nextRow →
            successor.row = ExpandedRow.bytecode row ∧
              successor.nextExpandedPc = (ExpandedRow.bytecode nextRow).expandedPc

def FullSequenceTerminated
  {Pc BytecodeAddr RegIdx StateLocation : Type _}
  (boundary : SequenceBoundary Pc)
  (rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)) : Prop :=
  boundary.terminates = true ∧
    ∃ idx row,
      rows[idx]? = some row ∧
        idx + 1 = rows.length ∧
        row.terminates = true

def FrameRowsBound
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  (frames : List (ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation))
  (rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)) : Prop :=
  List.Forall₂ (fun frame row => frame.row = row) frames rows

def ExecutionLinked
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  : List (ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation) → Prop
  | [] => True
  | [_] => True
  | a :: b :: rest => a.postState = b.preState ∧ ExecutionLinked (b :: rest)

def ExecutionTraceEndpoints
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  (initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word)
  (frames : List (ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation)) : Prop :=
  match frames with
  | [] => False
  | first :: _ =>
      first.preState = initialState ∧
        match frames.reverse with
        | [] => False
        | last :: _ => last.postState = finalState

def ExecutionTraceCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  (initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word)
  (rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation))
  (frames : List (ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation)) : Prop :=
  FrameRowsBound frames rows ∧
    ExecutionLinked frames ∧
    ExecutionTraceEndpoints initialState finalState frames

def ExecutionCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  (initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word)
  (rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation))
  (preparedSteps : List (PreparedStepView Pc))
  (boundary : SequenceBoundary Pc)
  (entrypoint : ExpandedBytecodeEntrypointProofPackage Pc BytecodeAddr)
  (successors : List (ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr)) : Prop :=
  ExpandedRowSequenceBound rows ∧
    PreparedStepExportBound rows preparedSteps ∧
    ExpandedBytecodeExecutionBound entrypoint successors rows ∧
    FullSequenceTerminated boundary rows ∧
    boundary.startPc = initialState.pc ∧
    boundary.pcNext = finalState.pc ∧
    finalState.halted = boundary.terminates

structure ExecutionSemanticsProofPackage
  (Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _) where
  initialState : ArchitecturalState Pc RegIdx RamAddr Word
  finalState : ArchitecturalState Pc RegIdx RamAddr Word
  rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
  frames : List (ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation)
  preparedSteps : List (PreparedStepView Pc)
  boundary : SequenceBoundary Pc
  entrypoint : ExpandedBytecodeEntrypointProofPackage Pc BytecodeAddr
  successors : List (ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr)
  traceCorrect :
    ExecutionTraceCorrect
      initialState
      finalState
      rows
      frames
  correct :
    ExecutionCorrect
      initialState
      finalState
      rows
      preparedSteps
      boundary
      entrypoint
      successors

theorem frameRowsBound_of_executionTraceCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {frames : List (ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (h :
    ExecutionTraceCorrect
      initialState
      finalState
      rows
      frames) :
  FrameRowsBound frames rows :=
  h.1

theorem executionLinked_of_executionTraceCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {frames : List (ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (h :
    ExecutionTraceCorrect
      initialState
      finalState
      rows
      frames) :
  ExecutionLinked frames :=
  h.2.1

theorem executionTraceEndpoints_of_executionTraceCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {frames : List (ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (h :
    ExecutionTraceCorrect
      initialState
      finalState
      rows
      frames) :
  ExecutionTraceEndpoints initialState finalState frames :=
  h.2.2

theorem initialState_matches_of_executionTraceCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {first : ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  {rest : List (ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (h :
    ExecutionTraceCorrect
      initialState
      finalState
      rows
      (first :: rest)) :
  first.preState = initialState :=
  h.2.2.1

theorem finalState_matches_of_executionTraceCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {frames : List (ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (h :
    ExecutionTraceCorrect
      initialState
      finalState
      rows
      frames) :
  ∃ last, frames.reverse.head? = some last ∧ last.postState = finalState := by
  cases hFrames : frames with
  | nil =>
      have hEndpoints := executionTraceEndpoints_of_executionTraceCorrect h
      simp [ExecutionTraceEndpoints, hFrames] at hEndpoints
  | cons first rest =>
      cases hRev : (first :: rest).reverse with
      | nil =>
          simp at hRev
      | cons last tail =>
          refine ⟨last, by simp, ?_⟩
          have hEndpoints := executionTraceEndpoints_of_executionTraceCorrect h
          simp [ExecutionTraceEndpoints, hFrames, hRev] at hEndpoints
          exact hEndpoints.2

theorem frames_length_eq_rows_length_of_executionTraceCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {frames : List (ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (h :
    ExecutionTraceCorrect
      initialState
      finalState
      rows
      frames) :
  frames.length = rows.length := by
  exact List.Forall₂.length_eq (frameRowsBound_of_executionTraceCorrect h)

theorem frameRowsBound_row_eq_at_index
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {frames : List (ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {idx : Nat}
  {frame : ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  {row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (h : FrameRowsBound frames rows)
  (hFrame : frames[idx]? = some frame)
  (hRow : rows[idx]? = some row) :
  frame.row = row := by
  induction h generalizing idx with
  | nil =>
      simp at hFrame
  | @cons frame' row' frames' rows' hEq hTail ih =>
      cases idx with
      | zero =>
          simp at hFrame hRow
          cases hFrame
          cases hRow
          simpa using hEq
      | succ idx =>
          simp at hFrame hRow
          exact ih hFrame hRow

theorem row_of_frameRowsBound_at_index
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {frames : List (ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {idx : Nat}
  {frame : ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (h : FrameRowsBound frames rows)
  (hFrame : frames[idx]? = some frame) :
  ∃ row, rows[idx]? = some row ∧ frame.row = row := by
  induction h generalizing idx with
  | nil =>
      simp at hFrame
  | @cons frame' row' frames' rows' hEq hTail ih =>
      cases idx with
      | zero =>
          simp at hFrame
          cases hFrame
          exact ⟨row', rfl, hEq⟩
      | succ idx =>
          simp at hFrame
          exact ih hFrame

theorem adjacentFrames_linked_of_executionLinked
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {frames : List (ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  {idx : Nat}
  {prev next : ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (h : ExecutionLinked frames)
  (hPrev : frames[idx]? = some prev)
  (hNext : frames[idx + 1]? = some next) :
  prev.postState = next.preState := by
  induction frames generalizing idx with
  | nil =>
      simp at hPrev
  | cons a rest ih =>
      cases rest with
      | nil =>
          cases idx <;> simp at hNext
      | cons b rest' =>
          simp [ExecutionLinked] at h
          cases idx with
          | zero =>
              simp at hPrev hNext
              cases hPrev
              cases hNext
              exact h.1
          | succ idx =>
              simp at hPrev hNext
              exact ih h.2 hPrev hNext

theorem adjacentStates_of_executionTraceCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {frames : List (ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  {idx : Nat}
  {prev next : ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (h :
    ExecutionTraceCorrect
      initialState
      finalState
      rows
      frames)
  (hPrev : frames[idx]? = some prev)
  (hNext : frames[idx + 1]? = some next) :
  prev.postState = next.preState :=
  adjacentFrames_linked_of_executionLinked
    (executionLinked_of_executionTraceCorrect h)
    hPrev
    hNext

theorem expandedRowSequenceBound_of_executionCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {preparedSteps : List (PreparedStepView Pc)}
  {boundary : SequenceBoundary Pc}
  {entrypoint : ExpandedBytecodeEntrypointProofPackage Pc BytecodeAddr}
  {successors : List (ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr)}
  (h :
    ExecutionCorrect
      initialState
      finalState
      rows
      preparedSteps
      boundary
      entrypoint
      successors) :
  ExpandedRowSequenceBound rows :=
  h.1

theorem preparedStepExportBound_of_executionCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {preparedSteps : List (PreparedStepView Pc)}
  {boundary : SequenceBoundary Pc}
  {entrypoint : ExpandedBytecodeEntrypointProofPackage Pc BytecodeAddr}
  {successors : List (ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr)}
  (h :
    ExecutionCorrect
      initialState
      finalState
      rows
      preparedSteps
      boundary
      entrypoint
      successors) :
  PreparedStepExportBound rows preparedSteps :=
  h.2.1

theorem preparedSteps_length_eq_rows_length_of_preparedStepExportBound
  {Pc BytecodeAddr RegIdx StateLocation : Type _}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {preparedSteps : List (PreparedStepView Pc)}
  (h : PreparedStepExportBound rows preparedSteps) :
  preparedSteps.length = rows.length :=
  h.1

theorem preparedStep_matches_row_of_preparedStepExportBound
  {Pc BytecodeAddr RegIdx StateLocation : Type _}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {preparedSteps : List (PreparedStepView Pc)}
  {idx : Nat}
  {step : PreparedStepView Pc}
  {row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (h : PreparedStepExportBound rows preparedSteps)
  (hStep : preparedSteps[idx]? = some step)
  (hRow : rows[idx]? = some row) :
  PreparedStepView.rowIndex step = idx ∧
    PreparedStepView.pc step = (ExpandedRow.bytecode row).unexpandedPc ∧
      PreparedStepView.advanceArchPc step = ExpandedRow.advanceArchPc row ∧
        PreparedStepView.terminates step = ExpandedRow.terminates row :=
  h.2 idx step row hStep hRow

theorem expandedBytecodeExecutionBound_of_executionCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {preparedSteps : List (PreparedStepView Pc)}
  {boundary : SequenceBoundary Pc}
  {entrypoint : ExpandedBytecodeEntrypointProofPackage Pc BytecodeAddr}
  {successors : List (ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr)}
  (h :
    ExecutionCorrect
      initialState
      finalState
      rows
      preparedSteps
      boundary
      entrypoint
      successors) :
  ExpandedBytecodeExecutionBound entrypoint successors rows :=
  h.2.2.1

theorem entrypoint_firstRow_of_expandedBytecodeExecutionBound
  {Pc BytecodeAddr RegIdx StateLocation : Type _}
  {entrypoint : ExpandedBytecodeEntrypointProofPackage Pc BytecodeAddr}
  {successors : List (ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr)}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  (h : ExpandedBytecodeExecutionBound entrypoint successors rows) :
  ∃ firstRow : ExpandedRow Pc BytecodeAddr RegIdx StateLocation,
    rows[0]? = some firstRow ∧
      ExpandedRow.bytecode firstRow = entrypoint.firstRow :=
  h.1

theorem successors_length_succ_eq_rows_length_of_expandedBytecodeExecutionBound
  {Pc BytecodeAddr RegIdx StateLocation : Type _}
  {entrypoint : ExpandedBytecodeEntrypointProofPackage Pc BytecodeAddr}
  {successors : List (ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr)}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  (h : ExpandedBytecodeExecutionBound entrypoint successors rows) :
  successors.length + 1 = rows.length :=
  h.2.1

theorem successor_matches_rows_of_expandedBytecodeExecutionBound
  {Pc BytecodeAddr RegIdx StateLocation : Type _}
  {entrypoint : ExpandedBytecodeEntrypointProofPackage Pc BytecodeAddr}
  {successors : List (ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr)}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {idx : Nat}
  {successor : ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr}
  {row nextRow : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (h : ExpandedBytecodeExecutionBound entrypoint successors rows)
  (hSucc : successors[idx]? = some successor)
  (hRow : rows[idx]? = some row)
  (hNext : rows[idx + 1]? = some nextRow) :
  successor.row = ExpandedRow.bytecode row ∧
    successor.nextExpandedPc = (ExpandedRow.bytecode nextRow).expandedPc :=
  h.2.2 idx successor row nextRow hSucc hRow hNext

theorem fullHaltedExecutionClaim_of_executionCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {preparedSteps : List (PreparedStepView Pc)}
  {boundary : SequenceBoundary Pc}
  {entrypoint : ExpandedBytecodeEntrypointProofPackage Pc BytecodeAddr}
  {successors : List (ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr)}
  (h :
    ExecutionCorrect
      initialState
      finalState
      rows
      preparedSteps
      boundary
      entrypoint
      successors) :
  FullHaltedExecutionClaim rows (fun row => ExpandedRow.terminates row = true) := by
  rcases h.2.2.2.1 with ⟨_, idx, row, hRow, hLast, hTerm⟩
  exact ⟨idx, row, hRow, hLast, hTerm⟩

theorem boundaryStartPc_of_executionCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {preparedSteps : List (PreparedStepView Pc)}
  {boundary : SequenceBoundary Pc}
  {entrypoint : ExpandedBytecodeEntrypointProofPackage Pc BytecodeAddr}
  {successors : List (ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr)}
  (h :
    ExecutionCorrect
      initialState
      finalState
      rows
      preparedSteps
      boundary
      entrypoint
      successors) :
  boundary.startPc = initialState.pc :=
  h.2.2.2.2.1

theorem boundaryPcNext_of_executionCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {preparedSteps : List (PreparedStepView Pc)}
  {boundary : SequenceBoundary Pc}
  {entrypoint : ExpandedBytecodeEntrypointProofPackage Pc BytecodeAddr}
  {successors : List (ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr)}
  (h :
    ExecutionCorrect
      initialState
      finalState
      rows
      preparedSteps
      boundary
      entrypoint
      successors) :
  boundary.pcNext = finalState.pc :=
  h.2.2.2.2.2.1

theorem boundaryTerminates_of_executionCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {preparedSteps : List (PreparedStepView Pc)}
  {boundary : SequenceBoundary Pc}
  {entrypoint : ExpandedBytecodeEntrypointProofPackage Pc BytecodeAddr}
  {successors : List (ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr)}
  (h :
    ExecutionCorrect
      initialState
      finalState
      rows
      preparedSteps
      boundary
      entrypoint
      successors) :
  boundary.terminates = true :=
  h.2.2.2.1.1

theorem finalState_halted_of_executionCorrect
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {initialState finalState : ArchitecturalState Pc RegIdx RamAddr Word}
  {rows : List (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)}
  {preparedSteps : List (PreparedStepView Pc)}
  {boundary : SequenceBoundary Pc}
  {entrypoint : ExpandedBytecodeEntrypointProofPackage Pc BytecodeAddr}
  {successors : List (ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr)}
  (h :
    ExecutionCorrect
      initialState
      finalState
      rows
      preparedSteps
      boundary
      entrypoint
      successors) :
  finalState.halted = true := by
  have hTerm : boundary.terminates = true := h.2.2.2.1.1
  calc
    finalState.halted = boundary.terminates := h.2.2.2.2.2.2
    _ = true := hTerm

end Nightstream.Rv64IM

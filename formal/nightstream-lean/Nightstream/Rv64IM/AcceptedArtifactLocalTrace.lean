import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes
import Nightstream.Rv64IM.Generated.ParityTypes
import Nightstream.Rv64IM.Trace.ChunkInput
import Nightstream.Rv64IM.Trace.MainLaneTraceBoundary
import Nightstream.Rv64IM.Trace.TraceLinkBoundary
import Nightstream.Rv64IM.Stage3.ImportedClosure
import Nightstream.Rv64IM.Stage3.ContinuityBridge
import Nightstream.Rv64IM.Execution.ExecutionSemantics

/-!
Owns concrete Lean replay of the RV64IM trace-local theorem packages that can
already be reconstructed from the accepted-artifact source and execution-row
exports alone. This owner covers chunk input, main-lane export, trace-link
boundary, and Stage 3 row-projection bindings; it does not own exact opening
provenance, root0 recovery, or the full `StepCompositionProofPackage`.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

structure GeneratedInitialStateView where
  pc : Nat
  registers : List Nat
  memory : List MemoryWordView
  halted : Bool
deriving DecidableEq, Repr

structure RecomputedLocalTraceView where
  chunkInput : ChunkInput GeneratedInitialStateView ExpandedRowView
  mainLane : MainLaneTraceBoundaryProofPackage ExpandedRowView (PreparedStepView Nat)
  traceLink : TraceLinkBoundaryProofPackage ExpandedRowView
  rowBindings : List (RowProjectionBinding ExpandedRowView (PreparedStepView Nat))

def generatedInitialStateOfSource (source : ParitySourceCase) : GeneratedInitialStateView :=
  { pc := source.startPc
  , registers := source.initialRegisters
  , memory := source.initialMemory
  , halted := false
  }

def preparedStepOfExecutionRow
    (rowIndex : Nat)
    (row : ExpandedRowView) : PreparedStepView Nat :=
  { rowIndex := rowIndex
  , pc := row.pc
  , advanceArchPc := row.isCommitRow
  , terminates := row.halted
  }

def preparedStepsOfExecutionRows
    (rows : List ExpandedRowView) : List (PreparedStepView Nat) :=
  List.ofFn fun i : Fin rows.length =>
    preparedStepOfExecutionRow i.1 (rows.get i)

private def preparedStepData
    (step : PreparedStepView Nat) : Nat × Nat × Bool × Bool :=
  (step.rowIndex, step.pc, step.advanceArchPc, step.terminates)

def rowBindingsOfRealExecutionRows
    (rows : List ExpandedRowView) :
    List (RowProjectionBinding ExpandedRowView (PreparedStepView Nat)) :=
  let realRows := realExecutionRows rows
  List.ofFn fun i : Fin realRows.length =>
    let row := realRows.get i
    { row := row
    , preparedStep := preparedStepOfExecutionRow i.1 row
    }

private theorem mainLaneTraceBoundary_of_executionRows
    (rows : List ExpandedRowView) :
    MainLaneTraceBoundary
      rows
      (preparedStepsOfExecutionRows rows)
      rows.length := by
  refine ⟨rfl, by simp [preparedStepsOfExecutionRows], ?_⟩
  intro idx hIdx
  refine ⟨rows.get ⟨idx, hIdx⟩, preparedStepOfExecutionRow idx (rows.get ⟨idx, hIdx⟩), ?_, ?_⟩
  · simp [hIdx]
  · simp [preparedStepsOfExecutionRows, hIdx, preparedStepOfExecutionRow]

private theorem traceLinkBoundary_of_executionRows
    (rows : List ExpandedRowView) :
    TraceLinkBoundary rows rows.length := by
  refine ⟨rfl, ?_⟩
  intro idx hIdx
  have hRow : idx < rows.length :=
    Nat.lt_trans (Nat.lt_succ_self idx) hIdx
  refine ⟨rows.get ⟨idx, hRow⟩, rows.get ⟨idx + 1, hIdx⟩, ?_, ?_⟩
  · simp [hRow]
  · simp [hIdx]

def recomputeLocalTraceView
    (artifact : AcceptedProofArtifactView) : RecomputedLocalTraceView :=
  let rows := artifact.derived.executionRows
  { chunkInput :=
      { initialState := generatedInitialStateOfSource artifact.source
      , semanticRows := rows.length
      , rows := rows
      , exactActivePrefix := rfl
      }
  , mainLane :=
      { semanticRows := rows.length
      , rows := rows
      , preparedSteps := preparedStepsOfExecutionRows rows
      , boundary := mainLaneTraceBoundary_of_executionRows rows
      }
  , traceLink :=
      { semanticRows := rows.length
      , rows := rows
      , bound := traceLinkBoundary_of_executionRows rows
      }
  , rowBindings := rowBindingsOfRealExecutionRows rows
  }

def recomputedChunkInputMatchesArtifact
    (recomputed : RecomputedLocalTraceView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  recomputed.chunkInput.initialState = generatedInitialStateOfSource artifact.source &&
    recomputed.chunkInput.rows = artifact.derived.executionRows &&
    recomputed.chunkInput.semanticRows = artifact.derived.executionRows.length

def recomputedMainLaneBoundaryMatchesArtifact
    (recomputed : RecomputedLocalTraceView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  let projectedSteps := recomputed.mainLane.preparedSteps.map preparedStepData
  let expectedSteps :=
    (preparedStepsOfExecutionRows artifact.derived.executionRows).map preparedStepData
  recomputed.mainLane.rows = artifact.derived.executionRows &&
    recomputed.mainLane.semanticRows = artifact.derived.executionRows.length &&
    decide (projectedSteps = expectedSteps)

def recomputedTraceLinkBoundaryMatchesArtifact
    (recomputed : RecomputedLocalTraceView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  recomputed.traceLink.rows = artifact.derived.executionRows &&
    recomputed.traceLink.semanticRows = artifact.derived.executionRows.length

def recomputedStage3RowBindingsMatchArtifact
    (recomputed : RecomputedLocalTraceView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  let realRows := realExecutionRows artifact.derived.executionRows
  let projectedRows := recomputed.rowBindings.map RowProjectionBinding.row
  let projectedSteps :=
    (recomputed.rowBindings.map RowProjectionBinding.preparedStep).map preparedStepData
  let expectedSteps :=
    (preparedStepsOfExecutionRows realRows).map preparedStepData
  decide (projectedRows = realRows) &&
    decide (projectedSteps = expectedSteps) &&
    recomputed.rowBindings.length = realRows.length

def recomputedLocalTraceMatchesArtifact
    (recomputed : RecomputedLocalTraceView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  recomputedChunkInputMatchesArtifact recomputed artifact &&
    recomputedMainLaneBoundaryMatchesArtifact recomputed artifact &&
    recomputedTraceLinkBoundaryMatchesArtifact recomputed artifact &&
    recomputedStage3RowBindingsMatchArtifact recomputed artifact

end Nightstream.Rv64IM

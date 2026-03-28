import Nightstream.Rv64IM.Execution.ImportedSequenceSemantics
import Nightstream.Rv64IM.Stage1.ImportedSemantics

/-!
Owns executable and theorem-facing imported Stage 1 local semantics above the
exact row-to-row projection. This packages the concrete sequence-local row flags
with the Stage 1 binding fields preserved at each row position.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

private theorem filter_projection_eq_map_filter
    (rows : List ExpandedRowView)
    (predExec : ExpandedRowView → Bool)
    (predStage : Stage1RowBindingView → Bool)
    (hPred : ∀ row, predStage (stage1RowBindingOfExecutionRow row) = predExec row) :
    (rows.map stage1RowBindingOfExecutionRow).filter predStage =
      (rows.filter predExec).map stage1RowBindingOfExecutionRow := by
  induction rows with
  | nil =>
      rfl
  | cons row rows ih =>
      cases hExec : predExec row <;> simp [hExec, hPred row, ih]

def stage1FirstInSequenceCount (stage1 : Stage1SummaryView) : Nat :=
  (stage1.rows.filter fun row => row.isFirstInSequence).length

def executionFirstInSequenceCount (rows : List ExpandedRowView) : Nat :=
  (rows.filter fun row => row.isFirstInSequence).length

def ImportedStage1RowLocalSemantics
    (row : ExpandedRowView)
    (stageRow : Stage1RowBindingView) : Prop :=
  stageRow = stage1RowBindingOfExecutionRow row

private def importedStage1RowsLocalCheck :
    List ExpandedRowView → List Stage1RowBindingView → Bool
  | [], [] => true
  | row :: rows, stageRow :: stageRows =>
      decide (stageRow = stage1RowBindingOfExecutionRow row) &&
        importedStage1RowsLocalCheck rows stageRows
  | _, _ => false

def importedStage1LocalSemanticsCheck
    (rows : List ExpandedRowView)
    (stage1 : Stage1SummaryView) : Bool :=
  importedExpandedRowSequenceSemanticsCheck rows &&
    importedStage1ProjectionSemanticsCheck rows stage1 &&
    decide (stage1FirstInSequenceCount stage1 = executionFirstInSequenceCount rows) &&
    importedStage1RowsLocalCheck rows stage1.rows

def ImportedStage1LocalSemantics
    (rows : List ExpandedRowView)
    (stage1 : Stage1SummaryView) : Prop :=
  importedStage1LocalSemanticsCheck rows stage1 = true

theorem stage1FirstInSequenceCount_eq_executionFirstInSequenceCount_of_importedStage1Closure
    {rows : List ExpandedRowView}
    {stage1 : Stage1SummaryView}
    (h : ImportedStage1Closure rows stage1) :
    stage1FirstInSequenceCount stage1 = executionFirstInSequenceCount rows := by
  cases h
  let hFilter :=
    filter_projection_eq_map_filter
      rows
      (fun row => row.isFirstInSequence)
      (fun row => row.isFirstInSequence)
      (by intro row; rfl)
  simpa [stage1FirstInSequenceCount, executionFirstInSequenceCount, stage1SummaryOfExecutionRows] using
    congrArg List.length hFilter

theorem importedStage1RowLocalSemantics_of_rowBinding
    (row : ExpandedRowView) :
    ImportedStage1RowLocalSemantics row (stage1RowBindingOfExecutionRow row) := rfl

private theorem importedStage1RowsLocalCheck_map_rowBinding
    (rows : List ExpandedRowView) :
    importedStage1RowsLocalCheck rows (rows.map stage1RowBindingOfExecutionRow) = true := by
  induction rows with
  | nil =>
      rfl
  | cons row rows ih =>
      simp [importedStage1RowsLocalCheck, ih]

theorem importedStage1LocalSemantics_of_importedStage1Closure_and_sequence
    {rows : List ExpandedRowView}
    {stage1 : Stage1SummaryView}
    (hSeq : ImportedExpandedRowSequenceSemantics rows)
    (hClosure : ImportedStage1Closure rows stage1) :
    ImportedStage1LocalSemantics rows stage1 := by
  cases hClosure
  have hProj :
      ImportedStage1ProjectionSemantics rows (stage1SummaryOfExecutionRows rows) :=
    importedStage1ProjectionSemantics_of_importedStage1Closure rfl
  have hFirst :
      stage1FirstInSequenceCount (stage1SummaryOfExecutionRows rows) =
        executionFirstInSequenceCount rows :=
    stage1FirstInSequenceCount_eq_executionFirstInSequenceCount_of_importedStage1Closure rfl
  have hSeqCheck :
      importedExpandedRowSequenceSemanticsCheck rows = true := by
    simpa [ImportedExpandedRowSequenceSemantics] using hSeq
  have hProjCheck :
      importedStage1ProjectionSemanticsCheck rows (stage1SummaryOfExecutionRows rows) = true := by
    simpa [importedStage1ProjectionSemanticsCheck] using hProj
  have hFirstCheck :
      decide
          (stage1FirstInSequenceCount (stage1SummaryOfExecutionRows rows) =
            executionFirstInSequenceCount rows) = true :=
    decide_eq_true_eq.mpr hFirst
  unfold ImportedStage1LocalSemantics importedStage1LocalSemanticsCheck
  simp [hSeqCheck, hProjCheck, hFirstCheck, importedStage1RowsLocalCheck_map_rowBinding]

end Nightstream.Rv64IM

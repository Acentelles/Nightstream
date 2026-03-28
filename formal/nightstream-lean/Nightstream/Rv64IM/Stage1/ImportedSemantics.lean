import Nightstream.Rv64IM.Stage1.ImportedClosure

/-!
Owns theorem-facing imported Stage 1 summary consequences derived from the exact
row-to-summary projection. This file packages what the imported Stage 1 summary
preserves from committed execution rows; it does not claim row-local fetch or
decode correctness beyond that imported closure.
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

def stage1EffectRowCount (stage1 : Stage1SummaryView) : Nat :=
  (stage1.rows.filter fun row => row.isEffectRow).length

def stage1CommitRowCount (stage1 : Stage1SummaryView) : Nat :=
  (stage1.rows.filter fun row => row.isCommitRow).length

def stage1RealRowCount (stage1 : Stage1SummaryView) : Nat :=
  (stage1.rows.filter fun row => row.isReal).length

def stage1PreservesX0Count (stage1 : Stage1SummaryView) : Nat :=
  (stage1.rows.filter fun row => row.preservesX0).length

def executionEffectRowCount (rows : List ExpandedRowView) : Nat :=
  (rows.filter fun row => row.isEffectRow).length

def executionCommitRowCount (rows : List ExpandedRowView) : Nat :=
  (rows.filter fun row => row.isCommitRow).length

def executionRealRowCount (rows : List ExpandedRowView) : Nat :=
  (rows.filter fun row => row.isReal).length

def executionPreservesX0Count (rows : List ExpandedRowView) : Nat :=
  (rows.filter fun row => row.rd = 0 || !row.writesRd).length

def ImportedStage1ProjectionSemantics
    (rows : List ExpandedRowView)
    (stage1 : Stage1SummaryView) : Prop :=
  ImportedStage1Closure rows stage1 ∧
    stage1EffectRowCount stage1 = executionEffectRowCount rows ∧
    stage1CommitRowCount stage1 = executionCommitRowCount rows ∧
    stage1RealRowCount stage1 = executionRealRowCount rows ∧
    stage1PreservesX0Count stage1 = executionPreservesX0Count rows

instance (rows : List ExpandedRowView) (stage1 : Stage1SummaryView) :
    Decidable (ImportedStage1ProjectionSemantics rows stage1) := by
  unfold ImportedStage1ProjectionSemantics
  infer_instance

def importedStage1ProjectionSemanticsCheck
    (rows : List ExpandedRowView)
    (stage1 : Stage1SummaryView) : Bool :=
  decide (ImportedStage1ProjectionSemantics rows stage1)

theorem stage1Row_at_index_of_importedStage1Closure
    {rows : List ExpandedRowView}
    {stage1 : Stage1SummaryView}
    {idx : Nat}
    {row : ExpandedRowView}
    (h : ImportedStage1Closure rows stage1)
    (hRow : rows[idx]? = some row) :
    stage1.rows[idx]? = some (stage1RowBindingOfExecutionRow row) := by
  cases h
  simpa [stage1SummaryOfExecutionRows] using
    congrArg (Option.map stage1RowBindingOfExecutionRow) hRow

theorem stage1EffectRowCount_eq_executionEffectRowCount_of_importedStage1Closure
    {rows : List ExpandedRowView}
    {stage1 : Stage1SummaryView}
    (h : ImportedStage1Closure rows stage1) :
    stage1EffectRowCount stage1 = executionEffectRowCount rows := by
  cases h
  let hFilter :=
    filter_projection_eq_map_filter
      rows
      (fun row => row.isEffectRow)
      (fun row => row.isEffectRow)
      (by intro row; simp)
  simpa [stage1EffectRowCount, executionEffectRowCount, stage1SummaryOfExecutionRows] using
    congrArg List.length hFilter

theorem stage1CommitRowCount_eq_executionCommitRowCount_of_importedStage1Closure
    {rows : List ExpandedRowView}
    {stage1 : Stage1SummaryView}
    (h : ImportedStage1Closure rows stage1) :
    stage1CommitRowCount stage1 = executionCommitRowCount rows := by
  cases h
  let hFilter :=
    filter_projection_eq_map_filter
      rows
      (fun row => row.isCommitRow)
      (fun row => row.isCommitRow)
      (by intro row; simp)
  simpa [stage1CommitRowCount, executionCommitRowCount, stage1SummaryOfExecutionRows] using
    congrArg List.length hFilter

theorem stage1RealRowCount_eq_executionRealRowCount_of_importedStage1Closure
    {rows : List ExpandedRowView}
    {stage1 : Stage1SummaryView}
    (h : ImportedStage1Closure rows stage1) :
    stage1RealRowCount stage1 = executionRealRowCount rows := by
  cases h
  let hFilter :=
    filter_projection_eq_map_filter
      rows
      (fun row => row.isReal)
      (fun row => row.isReal)
      (by intro row; simp)
  simpa [stage1RealRowCount, executionRealRowCount, stage1SummaryOfExecutionRows] using
    congrArg List.length hFilter

theorem stage1PreservesX0Count_eq_executionPreservesX0Count_of_importedStage1Closure
    {rows : List ExpandedRowView}
    {stage1 : Stage1SummaryView}
    (h : ImportedStage1Closure rows stage1) :
    stage1PreservesX0Count stage1 = executionPreservesX0Count rows := by
  cases h
  let hFilter :=
    filter_projection_eq_map_filter
      rows
      (fun row => row.rd = 0 || !row.writesRd)
      (fun row => row.preservesX0)
      (by intro row; simp)
  simpa [stage1PreservesX0Count, executionPreservesX0Count, stage1SummaryOfExecutionRows] using
    congrArg List.length hFilter

theorem importedStage1ProjectionSemantics_of_importedStage1Closure
    {rows : List ExpandedRowView}
    {stage1 : Stage1SummaryView}
    (h : ImportedStage1Closure rows stage1) :
    ImportedStage1ProjectionSemantics rows stage1 := by
  exact ⟨h,
    stage1EffectRowCount_eq_executionEffectRowCount_of_importedStage1Closure h,
    stage1CommitRowCount_eq_executionCommitRowCount_of_importedStage1Closure h,
    stage1RealRowCount_eq_executionRealRowCount_of_importedStage1Closure h,
    stage1PreservesX0Count_eq_executionPreservesX0Count_of_importedStage1Closure h⟩

end Nightstream.Rv64IM

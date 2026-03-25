import Nightstream.Rv64IM.Generated.ParityTypes

/-!
Owns the imported Stage 1 closure bridge from concrete committed execution rows
to the imported Stage 1 summary view used by RV64IM parity and higher theorem
interfaces.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

def stage1RowBindingOfExecutionRow (row : ExpandedRowView) : Stage1RowBindingView where
  traceIndex := row.traceIndex
  stepIndex := row.stepIndex
  sequenceIndex := row.sequenceIndex
  fetchPc := row.pc
  fetchedWord := row.word
  opcode := row.opcode
  traceOpcode := row.traceOpcode
  traceVirtualOpcode := row.traceVirtualOpcode
  family := row.family
  nextPc := row.nextPc
  aluResult := row.aluResult
  effectiveAddr := row.effectiveAddr
  writesRd := row.writesRd
  rd := row.rd
  rdAfter := row.rdAfter
  isFirstInSequence := row.isFirstInSequence
  virtualSequenceRemaining := row.virtualSequenceRemaining
  isEffectRow := row.isEffectRow
  isCommitRow := row.isCommitRow
  isReal := row.isReal
  preservesX0 := row.rd = 0 || !row.writesRd

def stage1SummaryOfExecutionRows (rows : List ExpandedRowView) : Stage1SummaryView where
  rows := rows.map stage1RowBindingOfExecutionRow

def ImportedStage1Closure (rows : List ExpandedRowView) (stage1 : Stage1SummaryView) : Prop :=
  stage1 = stage1SummaryOfExecutionRows rows

instance (rows : List ExpandedRowView) (stage1 : Stage1SummaryView) :
    Decidable (ImportedStage1Closure rows stage1) := by
  unfold ImportedStage1Closure
  infer_instance

def importedStage1ClosureCheck (rows : List ExpandedRowView) (stage1 : Stage1SummaryView) : Bool :=
  decide (ImportedStage1Closure rows stage1)

@[simp] theorem stage1RowBindingOfExecutionRow_isEffectRow (row : ExpandedRowView) :
    (stage1RowBindingOfExecutionRow row).isEffectRow = row.isEffectRow := rfl

@[simp] theorem stage1RowBindingOfExecutionRow_isCommitRow (row : ExpandedRowView) :
    (stage1RowBindingOfExecutionRow row).isCommitRow = row.isCommitRow := rfl

@[simp] theorem stage1RowBindingOfExecutionRow_isReal (row : ExpandedRowView) :
    (stage1RowBindingOfExecutionRow row).isReal = row.isReal := rfl

@[simp] theorem stage1RowBindingOfExecutionRow_preservesX0 (row : ExpandedRowView) :
    (stage1RowBindingOfExecutionRow row).preservesX0 = (row.rd = 0 || !row.writesRd) := rfl

@[simp] theorem stage1SummaryOfExecutionRows_rows (rows : List ExpandedRowView) :
    (stage1SummaryOfExecutionRows rows).rows = rows.map stage1RowBindingOfExecutionRow := rfl

theorem stage1Summary_eq_stage1SummaryOfExecutionRows_of_importedStage1Closure
    {rows : List ExpandedRowView}
    {stage1 : Stage1SummaryView}
    (h : ImportedStage1Closure rows stage1) :
    stage1 = stage1SummaryOfExecutionRows rows :=
  h

theorem stage1Rows_eq_map_of_importedStage1Closure
    {rows : List ExpandedRowView}
    {stage1 : Stage1SummaryView}
    (h : ImportedStage1Closure rows stage1) :
    stage1.rows = rows.map stage1RowBindingOfExecutionRow := by
  cases h
  rfl

theorem stage1Rows_length_eq_executionRows_length_of_importedStage1Closure
    {rows : List ExpandedRowView}
    {stage1 : Stage1SummaryView}
    (h : ImportedStage1Closure rows stage1) :
    stage1.rows.length = rows.length := by
  cases h
  simp [stage1SummaryOfExecutionRows]

theorem stage1RowBinding_mem_of_importedStage1Closure
    {rows : List ExpandedRowView}
    {stage1 : Stage1SummaryView}
    (h : ImportedStage1Closure rows stage1)
    {row : ExpandedRowView}
    (hRow : row ∈ rows) :
    stage1RowBindingOfExecutionRow row ∈ stage1.rows := by
  cases h
  simpa [stage1SummaryOfExecutionRows] using List.mem_map.mpr ⟨row, hRow, rfl⟩

end Nightstream.Rv64IM

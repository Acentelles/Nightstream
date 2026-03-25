import Nightstream.Rv64IM.Execution.ImportedSequenceSemantics
import Nightstream.Rv64IM.Stage3.ImportedContinuitySemantics

/-!
Owns theorem-facing imported Stage 3 export semantics above the exact
real-row-to-summary projection. This packages the imported continuity bridge
with the concrete continuity-count, final-step, and halted export facts carried
by the Stage 3 summary.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

def ImportedStage3ExportSemantics
    (rows : List ExpandedRowView)
    (stage3 : Stage3SummaryView) : Prop :=
  ImportedStage3LocalSemantics rows stage3 ∧
    ImportedStage3ContinuitySemantics rows stage3 ∧
    stage3ContinuityCount stage3 = executionContinuityCount rows ∧
    stage3FinalStepCount stage3 = executionFinalStepCount rows ∧
    stage3AllContinuityHold stage3 = executionAllContinuityHold rows ∧
    stage3.halted = executionHalted rows

instance (rows : List ExpandedRowView) (stage3 : Stage3SummaryView) :
    Decidable (ImportedStage3ExportSemantics rows stage3) := by
  unfold ImportedStage3ExportSemantics ImportedStage3LocalSemantics ImportedStage3ContinuitySemantics
  infer_instance

def importedStage3ExportSemanticsCheck
    (rows : List ExpandedRowView)
    (stage3 : Stage3SummaryView) : Bool :=
  decide (ImportedStage3ExportSemantics rows stage3)

theorem stage3ContinuityCount_eq_executionContinuityCount_of_importedStage3ExportSemantics
    {rows : List ExpandedRowView}
    {stage3 : Stage3SummaryView}
    (h : ImportedStage3ExportSemantics rows stage3) :
    stage3ContinuityCount stage3 = executionContinuityCount rows :=
  h.2.2.1

theorem stage3FinalStepCount_eq_executionFinalStepCount_of_importedStage3ExportSemantics
    {rows : List ExpandedRowView}
    {stage3 : Stage3SummaryView}
    (h : ImportedStage3ExportSemantics rows stage3) :
    stage3FinalStepCount stage3 = executionFinalStepCount rows :=
  h.2.2.2.1

theorem stage3AllContinuityHold_eq_executionAllContinuityHold_of_importedStage3ExportSemantics
    {rows : List ExpandedRowView}
    {stage3 : Stage3SummaryView}
    (h : ImportedStage3ExportSemantics rows stage3) :
    stage3AllContinuityHold stage3 = executionAllContinuityHold rows :=
  h.2.2.2.2.1

theorem stage3Halted_eq_executionHalted_of_importedStage3ExportSemantics
    {rows : List ExpandedRowView}
    {stage3 : Stage3SummaryView}
    (h : ImportedStage3ExportSemantics rows stage3) :
    stage3.halted = executionHalted rows :=
  h.2.2.2.2.2

theorem importedStage3ExportSemantics_of_importedStage3Closure_and_sequence
    {rows : List ExpandedRowView}
    {stage3 : Stage3SummaryView}
    (hSeq : ImportedExpandedRowSequenceSemantics rows)
    (hClosure : ImportedStage3Closure rows stage3) :
    ImportedStage3ExportSemantics rows stage3 := by
  exact
    ⟨ importedStage3LocalSemantics_of_importedStage3Closure_and_sequence hSeq hClosure
    , importedStage3ContinuitySemantics_of_importedStage3Closure_and_sequence hSeq hClosure
    , stage3ContinuityCount_eq_executionContinuityCount_of_importedStage3Closure hClosure
    , stage3FinalStepCount_eq_executionFinalStepCount_of_importedStage3Closure hClosure
    , stage3AllContinuityHold_eq_executionAllContinuityHold_of_importedStage3Closure hClosure
    , stage3Halted_eq_executionHalted_of_importedStage3Closure' hClosure
    ⟩

end Nightstream.Rv64IM

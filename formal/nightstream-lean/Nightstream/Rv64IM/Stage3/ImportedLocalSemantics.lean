import Nightstream.Rv64IM.Execution.ImportedSequenceSemantics
import Nightstream.Rv64IM.Stage3.ImportedClosure

/-!
Owns executable and theorem-facing imported Stage 3 local semantics above the
exact real-row-to-summary projection. This packages the concrete continuity and
halt facts preserved by the imported Stage 3 summary.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

def stage3ContinuityCount (stage3 : Stage3SummaryView) : Nat :=
  stage3.continuity.length

def stage3FinalStepCount (stage3 : Stage3SummaryView) : Nat :=
  (stage3.continuity.filter fun event => event.finalStep).length

def stage3AllContinuityHold (stage3 : Stage3SummaryView) : Bool :=
  (stage3.continuity.all fun event => event.continuityHolds)

def executionContinuityCount (rows : List ExpandedRowView) : Nat :=
  (stage3SummaryOfExecutionRows rows).continuity.length

def executionFinalStepCount (rows : List ExpandedRowView) : Nat :=
  ((stage3SummaryOfExecutionRows rows).continuity.filter fun event => event.finalStep).length

def executionAllContinuityHold (rows : List ExpandedRowView) : Bool :=
  ((stage3SummaryOfExecutionRows rows).continuity.all fun event => event.continuityHolds)

def executionHalted (rows : List ExpandedRowView) : Bool :=
  (stage3SummaryOfExecutionRows rows).halted

def importedStage3LocalSemanticsCheck
    (rows : List ExpandedRowView)
    (stage3 : Stage3SummaryView) : Bool :=
  importedExpandedRowSequenceSemanticsCheck rows &&
    importedStage3ClosureCheck rows stage3 &&
    decide (stage3ContinuityCount stage3 = executionContinuityCount rows) &&
    decide (stage3FinalStepCount stage3 = executionFinalStepCount rows) &&
    decide (stage3AllContinuityHold stage3 = executionAllContinuityHold rows) &&
    decide (stage3.halted = executionHalted rows)

def ImportedStage3LocalSemantics
    (rows : List ExpandedRowView)
    (stage3 : Stage3SummaryView) : Prop :=
  importedStage3LocalSemanticsCheck rows stage3 = true

theorem stage3ContinuityCount_eq_executionContinuityCount_of_importedStage3Closure
    {rows : List ExpandedRowView}
    {stage3 : Stage3SummaryView}
    (h : ImportedStage3Closure rows stage3) :
    stage3ContinuityCount stage3 = executionContinuityCount rows := by
  cases h
  rfl

theorem stage3FinalStepCount_eq_executionFinalStepCount_of_importedStage3Closure
    {rows : List ExpandedRowView}
    {stage3 : Stage3SummaryView}
    (h : ImportedStage3Closure rows stage3) :
    stage3FinalStepCount stage3 = executionFinalStepCount rows := by
  cases h
  rfl

theorem stage3AllContinuityHold_eq_executionAllContinuityHold_of_importedStage3Closure
    {rows : List ExpandedRowView}
    {stage3 : Stage3SummaryView}
    (h : ImportedStage3Closure rows stage3) :
    stage3AllContinuityHold stage3 = executionAllContinuityHold rows := by
  cases h
  rfl

theorem stage3Halted_eq_executionHalted_of_importedStage3Closure'
    {rows : List ExpandedRowView}
    {stage3 : Stage3SummaryView}
    (h : ImportedStage3Closure rows stage3) :
    stage3.halted = executionHalted rows := by
  cases h
  rfl

theorem importedStage3LocalSemantics_of_importedStage3Closure_and_sequence
    {rows : List ExpandedRowView}
    {stage3 : Stage3SummaryView}
    (hSeq : ImportedExpandedRowSequenceSemantics rows)
    (hClosure : ImportedStage3Closure rows stage3) :
    ImportedStage3LocalSemantics rows stage3 := by
  have hSeqCheck : importedExpandedRowSequenceSemanticsCheck rows = true := by
    simpa [ImportedExpandedRowSequenceSemantics] using hSeq
  have hClosureCheck : importedStage3ClosureCheck rows stage3 = true := by
    simpa [importedStage3ClosureCheck] using (decide_eq_true_eq.mpr hClosure)
  have hContinuity :
      stage3ContinuityCount stage3 = executionContinuityCount rows :=
    stage3ContinuityCount_eq_executionContinuityCount_of_importedStage3Closure hClosure
  have hFinal :
      stage3FinalStepCount stage3 = executionFinalStepCount rows :=
    stage3FinalStepCount_eq_executionFinalStepCount_of_importedStage3Closure hClosure
  have hAll :
      stage3AllContinuityHold stage3 = executionAllContinuityHold rows :=
    stage3AllContinuityHold_eq_executionAllContinuityHold_of_importedStage3Closure hClosure
  have hHalted :
      stage3.halted = executionHalted rows :=
    stage3Halted_eq_executionHalted_of_importedStage3Closure' hClosure
  unfold ImportedStage3LocalSemantics importedStage3LocalSemanticsCheck
  simp [hSeqCheck, hClosureCheck,
    decide_eq_true_eq.mpr hContinuity,
    decide_eq_true_eq.mpr hFinal,
    decide_eq_true_eq.mpr hAll,
    decide_eq_true_eq.mpr hHalted]

end Nightstream.Rv64IM

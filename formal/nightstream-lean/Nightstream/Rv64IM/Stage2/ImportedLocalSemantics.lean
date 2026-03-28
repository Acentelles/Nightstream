import Nightstream.Rv64IM.Execution.ImportedSequenceSemantics
import Nightstream.Rv64IM.Stage2.ImportedClosure

/-!
Owns executable and theorem-facing imported Stage 2 local semantics above the
exact row-to-summary projection. This packages the concrete read/write/RAM/twist
event counts preserved by the imported Stage 2 summary.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

def stage2RegisterReadCount (stage2 : Stage2SummaryView) : Nat :=
  stage2.registerReads.length

def stage2RegisterWriteCount (stage2 : Stage2SummaryView) : Nat :=
  stage2.registerWrites.length

def stage2RamEventCount (stage2 : Stage2SummaryView) : Nat :=
  stage2.ramEvents.length

def stage2TwistLinkCount (stage2 : Stage2SummaryView) : Nat :=
  stage2.twistLinks.length

def executionRegisterReadCount (rows : List ExpandedRowView) : Nat :=
  (stage2SummaryOfExecutionRows rows).registerReads.length

def executionRegisterWriteCount (rows : List ExpandedRowView) : Nat :=
  (stage2SummaryOfExecutionRows rows).registerWrites.length

def executionRamEventCount (rows : List ExpandedRowView) : Nat :=
  (stage2SummaryOfExecutionRows rows).ramEvents.length

def executionTwistLinkCount (rows : List ExpandedRowView) : Nat :=
  (stage2SummaryOfExecutionRows rows).twistLinks.length

def importedStage2LocalSemanticsCheck
    (rows : List ExpandedRowView)
    (stage2 : Stage2SummaryView) : Bool :=
  importedExpandedRowSequenceSemanticsCheck rows &&
    importedStage2ClosureCheck rows stage2 &&
    decide (stage2RegisterReadCount stage2 = executionRegisterReadCount rows) &&
    decide (stage2RegisterWriteCount stage2 = executionRegisterWriteCount rows) &&
    decide (stage2RamEventCount stage2 = executionRamEventCount rows) &&
    decide (stage2TwistLinkCount stage2 = executionTwistLinkCount rows)

def ImportedStage2LocalSemantics
    (rows : List ExpandedRowView)
    (stage2 : Stage2SummaryView) : Prop :=
  importedStage2LocalSemanticsCheck rows stage2 = true

theorem stage2RegisterReadCount_eq_executionRegisterReadCount_of_importedStage2Closure
    {rows : List ExpandedRowView}
    {stage2 : Stage2SummaryView}
    (h : ImportedStage2Closure rows stage2) :
    stage2RegisterReadCount stage2 = executionRegisterReadCount rows := by
  cases h
  rfl

theorem stage2RegisterWriteCount_eq_executionRegisterWriteCount_of_importedStage2Closure
    {rows : List ExpandedRowView}
    {stage2 : Stage2SummaryView}
    (h : ImportedStage2Closure rows stage2) :
    stage2RegisterWriteCount stage2 = executionRegisterWriteCount rows := by
  cases h
  rfl

theorem stage2RamEventCount_eq_executionRamEventCount_of_importedStage2Closure
    {rows : List ExpandedRowView}
    {stage2 : Stage2SummaryView}
    (h : ImportedStage2Closure rows stage2) :
    stage2RamEventCount stage2 = executionRamEventCount rows := by
  cases h
  rfl

theorem stage2TwistLinkCount_eq_executionTwistLinkCount_of_importedStage2Closure
    {rows : List ExpandedRowView}
    {stage2 : Stage2SummaryView}
    (h : ImportedStage2Closure rows stage2) :
    stage2TwistLinkCount stage2 = executionTwistLinkCount rows := by
  cases h
  simp [stage2TwistLinkCount, executionTwistLinkCount, stage2SummaryOfExecutionRows]

theorem importedStage2LocalSemantics_of_importedStage2Closure_and_sequence
    {rows : List ExpandedRowView}
    {stage2 : Stage2SummaryView}
    (hSeq : ImportedExpandedRowSequenceSemantics rows)
    (hClosure : ImportedStage2Closure rows stage2) :
    ImportedStage2LocalSemantics rows stage2 := by
  have hSeqCheck : importedExpandedRowSequenceSemanticsCheck rows = true := by
    simpa [ImportedExpandedRowSequenceSemantics] using hSeq
  have hClosureCheck : importedStage2ClosureCheck rows stage2 = true := by
    simpa [importedStage2ClosureCheck] using (decide_eq_true_eq.mpr hClosure)
  have hRead :
      stage2RegisterReadCount stage2 = executionRegisterReadCount rows :=
    stage2RegisterReadCount_eq_executionRegisterReadCount_of_importedStage2Closure hClosure
  have hWrite :
      stage2RegisterWriteCount stage2 = executionRegisterWriteCount rows :=
    stage2RegisterWriteCount_eq_executionRegisterWriteCount_of_importedStage2Closure hClosure
  have hRam :
      stage2RamEventCount stage2 = executionRamEventCount rows :=
    stage2RamEventCount_eq_executionRamEventCount_of_importedStage2Closure hClosure
  have hTwist :
      stage2TwistLinkCount stage2 = executionTwistLinkCount rows :=
    stage2TwistLinkCount_eq_executionTwistLinkCount_of_importedStage2Closure hClosure
  unfold ImportedStage2LocalSemantics importedStage2LocalSemanticsCheck
  simp [hSeqCheck, hClosureCheck,
    decide_eq_true_eq.mpr hRead,
    decide_eq_true_eq.mpr hWrite,
    decide_eq_true_eq.mpr hRam,
    decide_eq_true_eq.mpr hTwist]

end Nightstream.Rv64IM

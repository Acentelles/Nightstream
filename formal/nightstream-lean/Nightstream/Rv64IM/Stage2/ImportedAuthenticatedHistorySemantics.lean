import Nightstream.Rv64IM.Execution.ImportedSequenceSemantics
import Nightstream.Rv64IM.Stage2.ImportedHistorySemantics

/-!
Owns theorem-facing imported Stage 2 authenticated-history semantics above the
exact row-to-summary projection. This packages the imported history bridge with
the concrete read/write/RAM/twist count equalities preserved by the Stage 2
summary.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

def ImportedStage2AuthenticatedHistorySemantics
    (rows : List ExpandedRowView)
    (stage2 : Stage2SummaryView) : Prop :=
  ImportedStage2HistorySemantics rows stage2 ∧
    stage2RegisterReadCount stage2 = executionRegisterReadCount rows ∧
    stage2RegisterWriteCount stage2 = executionRegisterWriteCount rows ∧
    stage2RamEventCount stage2 = executionRamEventCount rows ∧
    stage2TwistLinkCount stage2 = executionTwistLinkCount rows

instance (rows : List ExpandedRowView) (stage2 : Stage2SummaryView) :
    Decidable (ImportedStage2AuthenticatedHistorySemantics rows stage2) := by
  unfold ImportedStage2AuthenticatedHistorySemantics
  infer_instance

def importedStage2AuthenticatedHistorySemanticsCheck
    (rows : List ExpandedRowView)
    (stage2 : Stage2SummaryView) : Bool :=
  decide (ImportedStage2AuthenticatedHistorySemantics rows stage2)

theorem stage2RegisterReadCount_eq_executionRegisterReadCount_of_importedStage2AuthenticatedHistorySemantics
    {rows : List ExpandedRowView}
    {stage2 : Stage2SummaryView}
    (h : ImportedStage2AuthenticatedHistorySemantics rows stage2) :
    stage2RegisterReadCount stage2 = executionRegisterReadCount rows :=
  h.2.1

theorem stage2RegisterWriteCount_eq_executionRegisterWriteCount_of_importedStage2AuthenticatedHistorySemantics
    {rows : List ExpandedRowView}
    {stage2 : Stage2SummaryView}
    (h : ImportedStage2AuthenticatedHistorySemantics rows stage2) :
    stage2RegisterWriteCount stage2 = executionRegisterWriteCount rows :=
  h.2.2.1

theorem stage2RamEventCount_eq_executionRamEventCount_of_importedStage2AuthenticatedHistorySemantics
    {rows : List ExpandedRowView}
    {stage2 : Stage2SummaryView}
    (h : ImportedStage2AuthenticatedHistorySemantics rows stage2) :
    stage2RamEventCount stage2 = executionRamEventCount rows :=
  h.2.2.2.1

theorem stage2TwistLinkCount_eq_executionTwistLinkCount_of_importedStage2AuthenticatedHistorySemantics
    {rows : List ExpandedRowView}
    {stage2 : Stage2SummaryView}
    (h : ImportedStage2AuthenticatedHistorySemantics rows stage2) :
    stage2TwistLinkCount stage2 = executionTwistLinkCount rows :=
  h.2.2.2.2

theorem stage2TwistLinks_length_eq_executionRows_length_of_importedStage2AuthenticatedHistorySemantics
    {rows : List ExpandedRowView}
    {stage2 : Stage2SummaryView}
    (h : ImportedStage2AuthenticatedHistorySemantics rows stage2) :
    stage2.twistLinks.length = rows.length :=
  h.1.2

theorem importedStage2AuthenticatedHistorySemantics_of_importedStage2Closure_and_sequence
    {rows : List ExpandedRowView}
    {stage2 : Stage2SummaryView}
    (hSeq : ImportedExpandedRowSequenceSemantics rows)
    (hClosure : ImportedStage2Closure rows stage2) :
    ImportedStage2AuthenticatedHistorySemantics rows stage2 := by
  exact
    ⟨ importedStage2HistorySemantics_of_importedStage2Closure_and_sequence hSeq hClosure
    , stage2RegisterReadCount_eq_executionRegisterReadCount_of_importedStage2Closure hClosure
    , stage2RegisterWriteCount_eq_executionRegisterWriteCount_of_importedStage2Closure hClosure
    , stage2RamEventCount_eq_executionRamEventCount_of_importedStage2Closure hClosure
    , stage2TwistLinkCount_eq_executionTwistLinkCount_of_importedStage2Closure hClosure
    ⟩

end Nightstream.Rv64IM

import Nightstream.Rv64IM.Execution.ImportedSequenceSemantics
import Nightstream.Rv64IM.Stage2.ImportedLocalSemantics

/-!
Owns theorem-facing imported Stage 2 history semantics above the exact
row-to-summary projection. This packages the concrete Stage 2 count preservation
with the per-row twist-link cardinality expected from committed execution rows.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

def ImportedStage2HistorySemantics
    (rows : List ExpandedRowView)
    (stage2 : Stage2SummaryView) : Prop :=
  ImportedStage2LocalSemantics rows stage2 ∧
    stage2.twistLinks.length = rows.length

instance (rows : List ExpandedRowView) (stage2 : Stage2SummaryView) :
    Decidable (ImportedStage2HistorySemantics rows stage2) := by
  unfold ImportedStage2HistorySemantics ImportedStage2LocalSemantics
  infer_instance

def importedStage2HistorySemanticsCheck
    (rows : List ExpandedRowView)
    (stage2 : Stage2SummaryView) : Bool :=
  importedStage2LocalSemanticsCheck rows stage2 &&
    decide (stage2.twistLinks.length = rows.length)

theorem stage2TwistLinks_length_eq_executionRows_length_of_importedStage2HistorySemantics
    {rows : List ExpandedRowView}
    {stage2 : Stage2SummaryView}
    (h : ImportedStage2HistorySemantics rows stage2) :
    stage2.twistLinks.length = rows.length :=
  h.2

theorem importedStage2HistorySemantics_of_importedStage2Closure_and_sequence
    {rows : List ExpandedRowView}
    {stage2 : Stage2SummaryView}
    (hSeq : ImportedExpandedRowSequenceSemantics rows)
    (hClosure : ImportedStage2Closure rows stage2) :
    ImportedStage2HistorySemantics rows stage2 := by
  refine ⟨importedStage2LocalSemantics_of_importedStage2Closure_and_sequence hSeq hClosure, ?_⟩
  exact stage2TwistLinks_length_eq_executionRows_length_of_importedStage2Closure hClosure

end Nightstream.Rv64IM

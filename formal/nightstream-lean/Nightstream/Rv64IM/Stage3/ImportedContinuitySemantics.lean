import Nightstream.Rv64IM.Execution.ImportedSequenceSemantics
import Nightstream.Rv64IM.Stage3.ImportedLocalSemantics

/-!
Owns theorem-facing imported Stage 3 continuity semantics above the exact
real-row summary projection. This packages the local continuity relation carried
by each imported continuity event.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

def continuityEventLocalSemantics (event : ContinuityEventView) : Prop :=
  event.continuityHolds =
    (event.successorPc.map (fun nextPc => event.nextPc == nextPc) |>.getD true)

instance (event : ContinuityEventView) : Decidable (continuityEventLocalSemantics event) := by
  unfold continuityEventLocalSemantics
  infer_instance

def continuityEventLocalSemanticsCheck (event : ContinuityEventView) : Bool :=
  decide (continuityEventLocalSemantics event)

def importedStage3ContinuitySemanticsCheck
    (rows : List ExpandedRowView)
    (stage3 : Stage3SummaryView) : Bool :=
  importedStage3LocalSemanticsCheck rows stage3 &&
    stage3.continuity.all continuityEventLocalSemanticsCheck

def ImportedStage3ContinuitySemantics
    (rows : List ExpandedRowView)
    (stage3 : Stage3SummaryView) : Prop :=
  importedStage3ContinuitySemanticsCheck rows stage3 = true

private theorem stage3SummaryOfExecutionRows_continuity_all_local
    (rows : List ExpandedRowView) :
    ((stage3SummaryOfExecutionRows rows).continuity.all continuityEventLocalSemanticsCheck) = true := by
  simp [stage3SummaryOfExecutionRows, continuityEventLocalSemanticsCheck, continuityEventLocalSemantics]

theorem continuityEventLocalSemantics_of_mem_of_importedStage3Closure
    {rows : List ExpandedRowView}
    {stage3 : Stage3SummaryView}
    (h : ImportedStage3Closure rows stage3)
    {event : ContinuityEventView}
    (hEvent : event ∈ stage3.continuity) :
    continuityEventLocalSemantics event := by
  cases h
  simp [stage3SummaryOfExecutionRows] at hEvent
  rcases hEvent with ⟨idx, row, _, rfl⟩
  simp [continuityEventLocalSemantics]

theorem importedStage3ContinuitySemantics_of_importedStage3Closure_and_sequence
    {rows : List ExpandedRowView}
    {stage3 : Stage3SummaryView}
    (hSeq : ImportedExpandedRowSequenceSemantics rows)
    (hClosure : ImportedStage3Closure rows stage3) :
    ImportedStage3ContinuitySemantics rows stage3 := by
  have hLocal :
      ImportedStage3LocalSemantics rows stage3 :=
    importedStage3LocalSemantics_of_importedStage3Closure_and_sequence hSeq hClosure
  have hLocalCheck :
      importedStage3LocalSemanticsCheck rows stage3 = true := by
    simpa [ImportedStage3LocalSemantics] using hLocal
  cases hClosure
  have hContinuityCheck :
      ((stage3SummaryOfExecutionRows rows).continuity.all continuityEventLocalSemanticsCheck) = true :=
    stage3SummaryOfExecutionRows_continuity_all_local rows
  unfold ImportedStage3ContinuitySemantics importedStage3ContinuitySemanticsCheck
  rw [hLocalCheck, hContinuityCheck]
  rfl

end Nightstream.Rv64IM

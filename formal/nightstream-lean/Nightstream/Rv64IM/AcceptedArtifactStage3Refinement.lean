import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes
import Nightstream.Rv64IM.AcceptedArtifactLocalTrace
import Nightstream.Rv64IM.Execution.ImportedSequenceSemantics
import Nightstream.Rv64IM.Execution.FinalBoundaryClaim
import Nightstream.Rv64IM.Stage3.ImportedClosure
import Nightstream.Rv64IM.Stage3.ImportedLocalSemantics
import Nightstream.Rv64IM.Stage3.Stage3Refinement
import Nightstream.Rv64IM.Stage3.ExportSemantics

/-!
Owns constructive recovery of the RV64IM Stage 3 refinement package from the
accepted-artifact execution rows. This owner rebuilds the Stage 3 continuity
bridge, row-projection bindings, and final halted boundary from the imported
real-row trace; it does not re-own full step composition or kernel bridge
provenance.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

private def listGet? : List α → Nat → Option α
  | [], _ => none
  | value :: _, 0 => some value
  | _ :: values, idx + 1 => listGet? values idx

private theorem listGet?_eq_get
    (values : List α)
    (idx : Nat)
    (hIdx : idx < values.length) :
    listGet? values idx = some (values.get ⟨idx, hIdx⟩) := by
  induction values generalizing idx with
  | nil =>
      cases hIdx
  | cons value values ih =>
      cases idx with
      | zero =>
          rfl
      | succ idx =>
          simp at hIdx
          simpa [listGet?] using ih idx hIdx

private def realRowsOfArtifact
    (artifact : AcceptedProofArtifactView) : List ExpandedRowView :=
  realExecutionRows artifact.derived.executionRows

private def stage3SemanticRowsOfRealRows
    (realRows : List ExpandedRowView) : Nat :=
  realRows.length

private def stage3PostPcOfRealRows
    (realRows : List ExpandedRowView) : Nat → Nat :=
  fun j => (listGet? realRows j).map ExpandedRowView.nextPc |>.getD 0

private def stage3PrePcOfRealRows
    (realRows : List ExpandedRowView) : Nat → Nat
  | 0 => (listGet? realRows 0).map ExpandedRowView.pc |>.getD 0
  | j + 1 => (listGet? realRows j).map ExpandedRowView.nextPc |>.getD 0

private def continuityRowOfRealRows
    (realRows : List ExpandedRowView)
    (idx : Fin realRows.length) : ContinuityRow Nat :=
  let row := realRows.get idx
  { rowIndex := idx.1
  , pairMask := PairMaskN (stage3SemanticRowsOfRealRows realRows) idx.1
  , pcNext := row.nextPc
  , shiftedPc := stage3PrePcOfRealRows realRows (idx.1 + 1)
  }

private def continuityRowsOfRealRows
    (realRows : List ExpandedRowView) : List (ContinuityRow Nat) :=
  List.ofFn fun idx : Fin realRows.length =>
    continuityRowOfRealRows realRows idx

private theorem continuityRowsBound_of_realRows
    (realRows : List ExpandedRowView) :
    ContinuityRowsBound
      (continuityRowsOfRealRows realRows)
      (stage3PostPcOfRealRows realRows)
      (stage3PrePcOfRealRows realRows)
      (stage3SemanticRowsOfRealRows realRows) := by
  intro j hLt
  have hRow : j < realRows.length :=
    Nat.lt_trans (Nat.lt_succ_self j) hLt
  let idx : Fin realRows.length := ⟨j, hRow⟩
  refine ⟨continuityRowOfRealRows realRows idx, ?_, ?_, ?_, ?_, ?_⟩
  · simpa [continuityRowsOfRealRows] using
      (List.getElem_mem (l := continuityRowsOfRealRows realRows) idx)
  · simp [continuityRowOfRealRows, idx]
  · rw [continuityRowOfRealRows, stage3PostPcOfRealRows, listGet?_eq_get realRows j hRow]
    simpa [idx]
  · rw [continuityRowOfRealRows, stage3PrePcOfRealRows, listGet?_eq_get realRows j hRow]
  · refine ⟨rfl, ?_⟩
    intro _hPair
    rw [continuityRowOfRealRows, stage3PrePcOfRealRows, listGet?_eq_get realRows j hRow]
    simpa [idx]

private theorem fullHaltedExecutionClaim_of_getLast
    : ∀ rows : List ExpandedRowView,
        ∀ last : ExpandedRowView,
          rows.getLast? = some last →
            last.halted = true →
              FullHaltedExecutionClaim rows (fun row => row.halted = true)
  | [], _, hLast, _ => by
      simp at hLast
  | row :: rows, last, hLast, hHalted => by
      cases rows with
      | nil =>
          simp at hLast
          cases hLast
          refine ⟨0, row, rfl, by simp, hHalted⟩
      | cons next rest =>
          have hTail : (next :: rest).getLast? = some last := by
            simpa using hLast
          rcases fullHaltedExecutionClaim_of_getLast (next :: rest) last hTail hHalted with
            ⟨idx, last, hMem, hLastIdx, hTerm⟩
          refine ⟨idx + 1, last, ?_, ?_, hTerm⟩
          · simpa [List.getElem?_cons, hMem]
          · simpa [hLastIdx, Nat.add_assoc]

def recoverStage3Refinement?
    (artifact : AcceptedProofArtifactView) :
    Option (Stage3RefinementPackage Nat ExpandedRowView (PreparedStepView Nat)) :=
  let realRows := realRowsOfArtifact artifact
  match hGetLast : realRows.getLast? with
  | none => none
  | some lastRow =>
      if hHalted : lastRow.halted = true then
        some
          { stage3 :=
              { semanticRows := stage3SemanticRowsOfRealRows realRows
              , postPc := stage3PostPcOfRealRows realRows
              , prePc := stage3PrePcOfRealRows realRows
              , continuityRows := continuityRowsOfRealRows realRows
              , rowBindings := rowBindingsOfRealExecutionRows artifact.derived.executionRows
              , continuityBound := continuityRowsBound_of_realRows realRows
              }
          , finalBoundary :=
              { sequence := realRows
              , terminatingRow := fun row => row.halted = true
              , claim := fullHaltedExecutionClaim_of_getLast realRows lastRow hGetLast hHalted
              }
          }
      else
        none

def recoveredStage3RefinementMatchesArtifact
    (pkg : Stage3RefinementPackage Nat ExpandedRowView (PreparedStepView Nat))
    (artifact : AcceptedProofArtifactView) : Bool :=
  let realRows := realRowsOfArtifact artifact
  importedExpandedRowSequenceSemanticsCheck artifact.derived.executionRows &&
    importedStage3ClosureCheck artifact.derived.executionRows artifact.derived.stage3 &&
    stage3AllContinuityHold artifact.derived.stage3 &&
    decide (pkg.stage3.semanticRows = realRows.length) &&
    decide (pkg.stage3.semanticRows = artifact.derived.stage3.continuity.length) &&
    decide (pkg.stage3.rowBindings.length = realRows.length) &&
    decide (pkg.stage3.continuityRows.length = artifact.derived.stage3.continuity.length) &&
    decide (pkg.finalBoundary.sequence = realRows) &&
    decide (pkg.finalBoundary.sequence.length = realRows.length) &&
    artifact.derived.stage3.halted

def recoveredStage3ContinuitySemantics
    (pkg : Stage3RefinementPackage Nat ExpandedRowView (PreparedStepView Nat)) :
    Stage3ContinuitySemantics pkg :=
  stage3ContinuitySemantics_of_stage3Refinement pkg

def recoveredStage3ExportSemantics
    (pkg : Stage3RefinementPackage Nat ExpandedRowView (PreparedStepView Nat)) :
    Stage3ExportSemantics pkg :=
  stage3ExportSemantics_of_stage3Refinement pkg

end Nightstream.Rv64IM

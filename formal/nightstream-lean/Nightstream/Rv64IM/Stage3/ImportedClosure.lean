import Nightstream.Rv64IM.Generated.ParityTypes

/-!
Owns the imported Stage 3 closure bridge from concrete committed execution rows
to the imported Stage 3 summary view used by RV64IM parity and higher theorem
interfaces.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

private def listGet? : List α → Nat → Option α
  | [], _ => none
  | x :: _, 0 => some x
  | _ :: xs, n + 1 => listGet? xs n

private def listEnumFrom : Nat → List α → List (Nat × α)
  | _, [] => []
  | idx, value :: rest => (idx, value) :: listEnumFrom (idx + 1) rest

private def listEnum (values : List α) : List (Nat × α) :=
  listEnumFrom 0 values

private theorem listEnumFrom_length (idx : Nat) (values : List α) :
    (listEnumFrom idx values).length = values.length := by
  induction values generalizing idx with
  | nil =>
      rfl
  | cons _ rest ih =>
      simp [listEnumFrom, ih]

def realExecutionRows (rows : List ExpandedRowView) : List ExpandedRowView :=
  rows.filter (·.isReal)

def stage3SummaryOfExecutionRows (rows : List ExpandedRowView) : Stage3SummaryView :=
  let realRows := realExecutionRows rows
  let continuity :=
    (listEnum realRows).map fun (idx, row) =>
      let successorPc := (listGet? realRows (idx + 1)).map fun next => next.pc
      { stepIndex := row.stepIndex
      , pc := row.pc
      , nextPc := row.nextPc
      , successorPc := successorPc
      , finalStep := idx + 1 = realRows.length
      , continuityHolds := successorPc.map (fun nextPc => row.nextPc == nextPc) |>.getD true }
  { continuity := continuity
  , halted := realRows.reverse.head?.map (fun row => row.halted) |>.getD false }

def ImportedStage3Closure (rows : List ExpandedRowView) (stage3 : Stage3SummaryView) : Prop :=
  stage3 = stage3SummaryOfExecutionRows rows

instance (rows : List ExpandedRowView) (stage3 : Stage3SummaryView) :
    Decidable (ImportedStage3Closure rows stage3) := by
  unfold ImportedStage3Closure
  infer_instance

def importedStage3ClosureCheck (rows : List ExpandedRowView) (stage3 : Stage3SummaryView) : Bool :=
  decide (ImportedStage3Closure rows stage3)

@[simp] theorem stage3SummaryOfExecutionRows_continuity (rows : List ExpandedRowView) :
    (stage3SummaryOfExecutionRows rows).continuity =
      (listEnum (realExecutionRows rows)).map fun (idx, row) =>
        let successorPc := (listGet? (realExecutionRows rows) (idx + 1)).map fun next => next.pc
        { stepIndex := row.stepIndex
        , pc := row.pc
        , nextPc := row.nextPc
        , successorPc := successorPc
        , finalStep := idx + 1 = (realExecutionRows rows).length
        , continuityHolds := successorPc.map (fun nextPc => row.nextPc == nextPc) |>.getD true } := rfl

theorem stage3Summary_eq_stage3SummaryOfExecutionRows_of_importedStage3Closure
    {rows : List ExpandedRowView}
    {stage3 : Stage3SummaryView}
    (h : ImportedStage3Closure rows stage3) :
    stage3 = stage3SummaryOfExecutionRows rows :=
  h

theorem stage3Continuity_length_eq_realExecutionRows_length_of_importedStage3Closure
    {rows : List ExpandedRowView}
    {stage3 : Stage3SummaryView}
    (h : ImportedStage3Closure rows stage3) :
    stage3.continuity.length = (realExecutionRows rows).length := by
  cases h
  simp [stage3SummaryOfExecutionRows, realExecutionRows, listEnum, listEnumFrom_length]

theorem stage3Halted_eq_executionHalted_of_importedStage3Closure
    {rows : List ExpandedRowView}
    {stage3 : Stage3SummaryView}
    (h : ImportedStage3Closure rows stage3) :
    stage3.halted = (stage3SummaryOfExecutionRows rows).halted :=
  by cases h <;> rfl

end Nightstream.Rv64IM

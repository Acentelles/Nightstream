import Nightstream.Rv64IM.Generated.ParityTypes

/-!
Owns the imported execution-row sequence checker used to expose concrete
sequence-local invariants above the Rust parity corpus.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

private def importedRowSequenceFlagsCheck (row : ExpandedRowView) : Bool :=
  decide (row.isFirstInSequence = (row.sequenceIndex = 0)) &&
    decide (row.isCommitRow =
      match row.virtualSequenceRemaining with
      | none => true
      | some remaining => remaining = 0) &&
    decide (row.isReal = row.isCommitRow) &&
    decide (row.halted = true → row.isCommitRow = true)

private def importedAdjacentSequenceCheck
    (current next : ExpandedRowView) : Bool :=
  if current.stepIndex = next.stepIndex then
    decide (next.sequenceIndex = current.sequenceIndex + 1) &&
      decide (current.isCommitRow = false) &&
      decide (current.virtualSequenceRemaining.isSome) &&
      decide (next.isFirstInSequence = false) &&
      decide (current.pc = next.pc) &&
      decide (current.word = next.word) &&
      decide (current.opcode = next.opcode) &&
      decide (current.virtualSequenceRemaining =
        Option.map Nat.succ next.virtualSequenceRemaining)
  else
    decide (next.stepIndex = current.stepIndex + 1) &&
      decide (next.sequenceIndex = 0) &&
      decide (current.isCommitRow = true)

private def importedExpandedRowSequenceSemanticsAux
    (totalLen : Nat) : Nat → List ExpandedRowView → Bool
  | _, [] => true
  | idx, [row] =>
      importedRowSequenceFlagsCheck row &&
        decide (row.isCommitRow = true) &&
        decide (row.halted = true → idx + 1 = totalLen)
  | idx, row :: next :: rest =>
      importedRowSequenceFlagsCheck row &&
        decide (row.halted = true → idx + 1 = totalLen) &&
        importedAdjacentSequenceCheck row next &&
        importedExpandedRowSequenceSemanticsAux totalLen (idx + 1) (next :: rest)

def importedExpandedRowSequenceSemanticsCheck
    (rows : List ExpandedRowView) : Bool :=
  match rows with
  | [] => false
  | _ => importedExpandedRowSequenceSemanticsAux rows.length 0 rows

def ImportedExpandedRowSequenceSemantics (rows : List ExpandedRowView) : Prop :=
  importedExpandedRowSequenceSemanticsCheck rows = true

end Nightstream.Rv64IM

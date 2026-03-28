/- Owns the theorem-facing fold cadence surface shared by generic release and staged bridges. -/

namespace Nightstream

inductive FoldSchedule where
  | wholeTrace
  | rowsPerChunk (rows : Nat)
deriving DecidableEq, Repr

namespace FoldSchedule

def Valid : FoldSchedule → Prop
  | FoldSchedule.wholeTrace => True
  | FoldSchedule.rowsPerChunk rows => 0 < rows

def chunkCount : FoldSchedule → Nat → Nat
  | FoldSchedule.wholeTrace, _ => 1
  | FoldSchedule.rowsPerChunk 0, _ => 0
  | FoldSchedule.rowsPerChunk (rows + 1), preparedStepCount =>
      match preparedStepCount with
      | 0 => 0
      | n + 1 => n / (rows + 1) + 1

theorem valid_wholeTrace : Valid FoldSchedule.wholeTrace := by
  trivial

theorem valid_rowsPerChunk_iff
  {rows : Nat} :
  Valid (FoldSchedule.rowsPerChunk rows) ↔ 0 < rows := by
  rfl

theorem chunkCount_wholeTrace
  (preparedStepCount : Nat) :
  chunkCount FoldSchedule.wholeTrace preparedStepCount = 1 := by
  rfl

theorem chunkCount_eq_of_valid_wholeTrace
  {preparedStepCount : Nat} :
  chunkCount FoldSchedule.wholeTrace preparedStepCount = 1 :=
  chunkCount_wholeTrace preparedStepCount

end FoldSchedule

end Nightstream

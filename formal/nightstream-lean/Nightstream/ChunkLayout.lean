import Nightstream.FoldSchedule

/- Owns the theorem-facing chunk partition induced by an explicit fold schedule. -/

namespace Nightstream

structure ChunkRange where
  start : Nat
  stop : Nat
deriving DecidableEq, Repr

namespace ChunkRange

def width (range : ChunkRange) : Nat :=
  range.stop - range.start

def BoundedBy (preparedStepCount : Nat) (range : ChunkRange) : Prop :=
  range.start ≤ range.stop ∧ range.stop ≤ preparedStepCount

end ChunkRange

namespace ChunkLayout

private def rangeOfIndex (preparedStepCount width index : Nat) : ChunkRange :=
  let start := index * width
  let stop := Nat.min preparedStepCount (start + width)
  { start := start, stop := stop }

def chunkIndexOf : FoldSchedule → Nat → Nat
  | .wholeTrace, _ => 0
  | .rowsPerChunk 0, _ => 0
  | .rowsPerChunk (rows + 1), rowIndex => rowIndex / (rows + 1)

def layout : FoldSchedule → Nat → List ChunkRange
  | .wholeTrace, preparedStepCount =>
      [{ start := 0, stop := preparedStepCount }]
  | .rowsPerChunk 0, _ =>
      []
  | .rowsPerChunk (rows + 1), preparedStepCount =>
      let count := FoldSchedule.chunkCount (.rowsPerChunk (rows + 1)) preparedStepCount
      (List.range count).map (rangeOfIndex preparedStepCount (rows + 1))

def coveredRows (ranges : List ChunkRange) : List Nat :=
  ranges.foldr (fun range acc => List.range' range.start range.width ++ acc) []

theorem layout_wholeTrace
  (preparedStepCount : Nat) :
  layout .wholeTrace preparedStepCount = [{ start := 0, stop := preparedStepCount }] := by
  rfl

theorem layout_length_eq_chunkCount
  (schedule : FoldSchedule)
  (preparedStepCount : Nat) :
  (layout schedule preparedStepCount).length =
    FoldSchedule.chunkCount schedule preparedStepCount := by
  cases schedule with
  | wholeTrace =>
      simp [layout, FoldSchedule.chunkCount]
  | rowsPerChunk rows =>
      cases rows with
      | zero =>
          simp [layout, FoldSchedule.chunkCount]
      | succ width =>
          simp [layout, FoldSchedule.chunkCount]

theorem coveredRows_wholeTrace
  (preparedStepCount : Nat) :
  coveredRows (layout .wholeTrace preparedStepCount) = List.range' 0 preparedStepCount := by
  simp [coveredRows, layout, ChunkRange.width]

theorem chunkIndexOf_wholeTrace
  (rowIndex : Nat) :
  chunkIndexOf .wholeTrace rowIndex = 0 := by
  rfl

theorem chunkIndexOf_lt_chunkCount_of_lt_preparedStepCount
  {schedule : FoldSchedule}
  {preparedStepCount rowIndex : Nat}
  (hValid : FoldSchedule.Valid schedule)
  (hRow : rowIndex < preparedStepCount) :
  chunkIndexOf schedule rowIndex < FoldSchedule.chunkCount schedule preparedStepCount := by
  cases schedule with
  | wholeTrace =>
      simp [chunkIndexOf, FoldSchedule.chunkCount]
  | rowsPerChunk rows =>
      cases rows with
      | zero =>
          cases hValid
      | succ width =>
          cases preparedStepCount with
          | zero =>
              cases Nat.not_lt_zero _ hRow
          | succ n =>
              have hPos : 0 < width + 1 := Nat.succ_pos _
              have hChunkBound :
                  n + 1 ≤ (n / (width + 1) + 1) * (width + 1) := by
                rw [Nat.add_mul, Nat.one_mul]
                exact Nat.succ_le_of_lt (Nat.lt_div_mul_add (a := n) hPos)
              have hMul :
                  rowIndex < (n / (width + 1) + 1) * (width + 1) :=
                Nat.lt_of_lt_of_le hRow hChunkBound
              exact (Nat.div_lt_iff_lt_mul hPos).2 (by
                simpa [chunkIndexOf, FoldSchedule.chunkCount] using hMul)

end ChunkLayout

end Nightstream

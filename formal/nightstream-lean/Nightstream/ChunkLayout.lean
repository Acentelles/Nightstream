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

end ChunkLayout

end Nightstream

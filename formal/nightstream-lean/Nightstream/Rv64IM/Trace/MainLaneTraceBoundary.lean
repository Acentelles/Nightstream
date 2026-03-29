import Nightstream.ChunkLayout

namespace Nightstream.Rv64IM

open Nightstream

def MainLaneTraceBoundary
  (rows : List Row)
  (preparedSteps : List PreparedStep)
  (chunks : List ChunkRange)
  (semanticRows : Nat)
  (schedule : FoldSchedule) : Prop :=
  FoldSchedule.Valid schedule ∧
    rows.length = semanticRows ∧
    preparedSteps.length = semanticRows ∧
    chunks = ChunkLayout.layout schedule semanticRows ∧
    ChunkLayout.coveredRows chunks = List.range' 0 semanticRows ∧
    ∀ idx,
      idx < semanticRows →
        ∃ row step,
          rows[idx]? = some row ∧
            preparedSteps[idx]? = some step

structure MainLaneTraceBoundaryProofPackage (Row PreparedStep : Type _) where
  schedule : FoldSchedule
  semanticRows : Nat
  chunks : List ChunkRange
  rows : List Row
  preparedSteps : List PreparedStep
  boundary : MainLaneTraceBoundary rows preparedSteps chunks semanticRows schedule

theorem mainLaneTraceBoundary_scheduleValid
  {Row PreparedStep : Type _}
  (pkg : MainLaneTraceBoundaryProofPackage Row PreparedStep) :
  FoldSchedule.Valid pkg.schedule :=
  pkg.boundary.1

theorem mainLaneTraceBoundary_rowsLength
  {Row PreparedStep : Type _}
  (pkg : MainLaneTraceBoundaryProofPackage Row PreparedStep) :
  pkg.rows.length = pkg.semanticRows :=
  pkg.boundary.2.1

theorem mainLaneTraceBoundary_preparedStepsLength
  {Row PreparedStep : Type _}
  (pkg : MainLaneTraceBoundaryProofPackage Row PreparedStep) :
  pkg.preparedSteps.length = pkg.semanticRows :=
  pkg.boundary.2.2.1

theorem mainLaneTraceBoundary_chunksLayout
  {Row PreparedStep : Type _}
  (pkg : MainLaneTraceBoundaryProofPackage Row PreparedStep) :
  pkg.chunks = ChunkLayout.layout pkg.schedule pkg.semanticRows :=
  pkg.boundary.2.2.2.1

theorem mainLaneTraceBoundary_chunksCoverRows
  {Row PreparedStep : Type _}
  (pkg : MainLaneTraceBoundaryProofPackage Row PreparedStep) :
  ChunkLayout.coveredRows pkg.chunks = List.range' 0 pkg.semanticRows :=
  pkg.boundary.2.2.2.2.1

theorem mainLaneTraceBoundary_chunksLength
  {Row PreparedStep : Type _}
  (pkg : MainLaneTraceBoundaryProofPackage Row PreparedStep) :
  pkg.chunks.length = FoldSchedule.chunkCount pkg.schedule pkg.semanticRows := by
  rw [mainLaneTraceBoundary_chunksLayout pkg]
  exact ChunkLayout.layout_length_eq_chunkCount pkg.schedule pkg.semanticRows

end Nightstream.Rv64IM

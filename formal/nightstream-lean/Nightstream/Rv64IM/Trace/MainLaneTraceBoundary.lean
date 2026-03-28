namespace Nightstream.Rv64IM

def MainLaneTraceBoundary
  (rows : List Row)
  (preparedSteps : List PreparedStep)
  (semanticRows : Nat) : Prop :=
  rows.length = semanticRows ∧
    preparedSteps.length = semanticRows ∧
    ∀ idx,
      idx < semanticRows →
        ∃ row step,
          rows[idx]? = some row ∧
            preparedSteps[idx]? = some step

structure MainLaneTraceBoundaryProofPackage (Row PreparedStep : Type _) where
  semanticRows : Nat
  rows : List Row
  preparedSteps : List PreparedStep
  boundary : MainLaneTraceBoundary rows preparedSteps semanticRows

theorem mainLaneTraceBoundary_rowsLength
  {Row PreparedStep : Type _}
  (pkg : MainLaneTraceBoundaryProofPackage Row PreparedStep) :
  pkg.rows.length = pkg.semanticRows :=
  pkg.boundary.1

theorem mainLaneTraceBoundary_preparedStepsLength
  {Row PreparedStep : Type _}
  (pkg : MainLaneTraceBoundaryProofPackage Row PreparedStep) :
  pkg.preparedSteps.length = pkg.semanticRows :=
  pkg.boundary.2.1

end Nightstream.Rv64IM

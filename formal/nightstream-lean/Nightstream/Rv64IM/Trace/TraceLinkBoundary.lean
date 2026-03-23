namespace Nightstream.Rv64IM

def TraceLinkBoundary
  (rows : List Row)
  (semanticRows : Nat) : Prop :=
  rows.length = semanticRows ∧
    ∀ idx,
      idx + 1 < semanticRows →
        ∃ row nextRow,
          rows[idx]? = some row ∧
            rows[idx + 1]? = some nextRow

structure TraceLinkBoundaryProofPackage (Row : Type _) where
  semanticRows : Nat
  rows : List Row
  bound : TraceLinkBoundary rows semanticRows

theorem traceLinkBoundary_rowsLength
  {Row : Type _}
  (pkg : TraceLinkBoundaryProofPackage Row) :
  pkg.rows.length = pkg.semanticRows :=
  pkg.bound.1

end Nightstream.Rv64IM

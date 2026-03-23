namespace Nightstream.Rv64IM

def FinalBoundaryClaim (sequence : List Row) (terminatingRow : Row → Prop) : Prop :=
  ∃ (idx : Nat), ∃ row,
    sequence[idx]? = some row ∧ idx + 1 = sequence.length ∧ terminatingRow row

def FullHaltedExecutionClaim (sequence : List Row) (terminatingRow : Row → Prop) : Prop :=
  FinalBoundaryClaim sequence terminatingRow

structure FinalBoundaryClaimProofPackage (Row : Type _) where
  sequence : List Row
  terminatingRow : Row → Prop
  claim : FullHaltedExecutionClaim sequence terminatingRow

end Nightstream.Rv64IM

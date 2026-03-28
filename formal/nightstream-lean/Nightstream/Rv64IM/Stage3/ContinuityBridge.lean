import Nightstream.Rv64IM.Execution.PcAdjacentBridge

namespace Nightstream.Rv64IM

def PairMaskN (N j : Nat) : Bool :=
  decide (j + 1 < N)

structure ContinuityRow (Pc : Type _) where
  rowIndex : Nat
  pairMask : Bool
  pcNext : Pc
  shiftedPc : Pc
deriving Repr

def ContinuityRowBound
  (semanticRows : Nat)
  (row : ContinuityRow Pc) : Prop :=
  row.pairMask = PairMaskN semanticRows row.rowIndex ∧
    (row.pairMask = true → row.shiftedPc = row.pcNext)

def ContinuityRowsBound
  (rows : List (ContinuityRow Pc))
  (postPc prePc : Nat → Pc)
  (semanticRows : Nat) : Prop :=
  ∀ j, j + 1 < semanticRows →
    ∃ row,
      row ∈ rows ∧
        row.rowIndex = j ∧
        row.pcNext = postPc j ∧
        row.shiftedPc = prePc (j + 1) ∧
        ContinuityRowBound semanticRows row

def ActivePrefixContinuity
  (postPc prePc : Nat → Pc)
  (semanticRows : Nat) : Prop :=
  ∀ j, j + 1 < semanticRows → postPc j = prePc (j + 1)

structure RowProjectionBinding (Row PreparedStep : Type _) where
  row : Row
  preparedStep : PreparedStep
deriving Repr

structure Stage3ProofPackage (Pc Row PreparedStep : Type _) where
  semanticRows : Nat
  postPc : Nat → Pc
  prePc : Nat → Pc
  continuityRows : List (ContinuityRow Pc)
  rowBindings : List (RowProjectionBinding Row PreparedStep)
  continuityBound : ContinuityRowsBound continuityRows postPc prePc semanticRows

theorem pcAdjacentBridge_of_continuityRowsBound
  {Pc : Type _}
  {rows : List (ContinuityRow Pc)}
  {postPc prePc : Nat → Pc}
  {semanticRows : Nat}
  (h : ContinuityRowsBound rows postPc prePc semanticRows) :
  PcAdjacentBridge Pc postPc prePc semanticRows := by
  intro j hLt
  rcases h j hLt with ⟨row, _, hRowIndex, hPcNext, hShifted, hBound⟩
  rcases hBound with ⟨hMask, hEq⟩
  have hPairTrue : row.pairMask = true := by
    rw [hMask, hRowIndex, PairMaskN]
    simp [hLt]
  calc
    postPc j = row.pcNext := hPcNext.symm
    _ = row.shiftedPc := (hEq hPairTrue).symm
    _ = prePc (j + 1) := hShifted

theorem activePrefixContinuity_of_continuityRowsBound
  {Pc : Type _}
  {rows : List (ContinuityRow Pc)}
  {postPc prePc : Nat → Pc}
  {semanticRows : Nat}
  (h : ContinuityRowsBound rows postPc prePc semanticRows) :
  ActivePrefixContinuity postPc prePc semanticRows :=
  pcAdjacentBridge_of_continuityRowsBound h

def pcAdjacentBridgeProofPackage_of_stage3
  {Pc Row PreparedStep : Type _}
  (pkg : Stage3ProofPackage Pc Row PreparedStep) :
  PcAdjacentBridgeProofPackage Pc :=
  { semanticRows := pkg.semanticRows
    postPc := pkg.postPc
    prePc := pkg.prePc
    bridge := pcAdjacentBridge_of_continuityRowsBound pkg.continuityBound }

end Nightstream.Rv64IM

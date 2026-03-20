import Mathlib
import Nightstream.Chip8.Stage1.Routing
import Nightstream.Chip8.Kernel.OpeningBoundary

namespace Nightstream.Chip8.ContinuityBridge

open Nightstream.Chip8

def PairMaskN (N j : Nat) : Nat :=
  if j + 1 < N then 1 else 0

def pairMaskValue {K : Type*} [OfNat K 0] [OfNat K 1] (N j : Nat) : K :=
  if j + 1 < N then 1 else 0

inductive ShiftedLaneColumn where
  | shiftPc
  | shiftXIdx
  | shiftIsMemOp
deriving DecidableEq, Repr

structure LaneShiftClaim (K : Type*) where
  sourceCommitment : ExactOpeningBoundary.CommitmentId
  sourcePoint : List Nat
  sourceColumns : List ExactOpeningBoundary.LaneColumn
  shiftedColumns : List ShiftedLaneColumn
  claimedShiftValues : K × K × K
deriving Repr

structure LaneShiftWitness (K Proof : Type*) where
  shiftPc : K
  shiftXIdx : K
  shiftIsMemOp : K
  reductionProof : Proof
deriving Repr

def LaneShiftBound {K Proof : Type*}
  (claim : LaneShiftClaim K)
  (proof : LaneShiftWitness K Proof) : Prop :=
  claim.sourceCommitment = .lane ∧
    claim.sourceColumns =
      [.pc, .xIdx, .isMemOp] ∧
    claim.shiftedColumns =
      [.shiftPc, .shiftXIdx, .shiftIsMemOp] ∧
    claim.claimedShiftValues = (proof.shiftPc, proof.shiftXIdx, proof.shiftIsMemOp)

structure ContinuityRow (K : Type*) where
  rowIndex : Nat
  pairMask : K
  pcNext : K
  xIdx : K
  isMemOp : K
  burstLast : K
deriving Repr

def deltaPc {K : Type*} [Ring K]
  (pairMask shiftPc pcNext : K) : K :=
  pairMask * (shiftPc - pcNext)

def deltaBurstStep {K : Type*} [Ring K]
  (pairMask isMemOp burstLast shiftXIdx xIdx : K) : K :=
  pairMask * isMemOp * (1 - burstLast) * (shiftXIdx - xIdx - 1)

def deltaBurstReset {K : Type*} [Ring K]
  (pairMask shiftIsMemOp isMemOp burstLast shiftXIdx : K) : K :=
  pairMask * shiftIsMemOp * (1 - isMemOp + burstLast) * shiftXIdx

def ContinuityBound {K Proof : Type*} [Ring K]
  (N : Nat)
  (β1 β2 : K)
  (claim : LaneShiftClaim K)
  (proof : LaneShiftWitness K Proof)
  (currentRow : ContinuityRow K) : Prop :=
  LaneShiftBound claim proof ∧
    currentRow.pairMask = pairMaskValue N currentRow.rowIndex ∧
    deltaPc currentRow.pairMask proof.shiftPc currentRow.pcNext +
        β1 * deltaBurstStep currentRow.pairMask currentRow.isMemOp
          currentRow.burstLast proof.shiftXIdx currentRow.xIdx +
        β2 * deltaBurstReset currentRow.pairMask proof.shiftIsMemOp
          currentRow.isMemOp currentRow.burstLast proof.shiftXIdx = 0

structure StartBoundaryRow (K : Type*) where
  isMemOp : K
  xIdx : K
deriving Repr

def StartBoundaryBound {K : Type*} [Ring K] (row : StartBoundaryRow K) : Prop :=
  row.isMemOp * row.xIdx = 0

def StartBoundaryMatches {K : Type*}
  (stepIdx : Nat)
  (row : StartBoundaryRow K)
  (z : Nightstream.Chip8.Witness K) : Prop :=
  stepIdx = 0 → row.isMemOp = z 19 ∧ row.xIdx = z 20

structure FinalBoundaryRow (K : Type*) where
  isMemOp : K
  burstLast : K
deriving Repr

def FinalBoundaryBound {K : Type*} [Ring K] (row : FinalBoundaryRow K) : Prop :=
  row.isMemOp * (1 - row.burstLast) = 0

def FinalBoundaryMatches {K : Type*}
  (stepIdx N : Nat)
  (row : FinalBoundaryRow K)
  (z : Nightstream.Chip8.Witness K) : Prop :=
  stepIdx + 1 = N → row.isMemOp = z 19 ∧ row.burstLast = z 22

def rowNonFixedValues {K : Type*} (z : Nightstream.Chip8.Witness K) : List K :=
  List.ofFn (fun i : Fin 23 => z ⟨i.1 + 1, by omega⟩)

structure RowBindingClaim (K Digest : Type*) where
  openingClaim : ExactOpeningBoundary.OpeningClaim K Digest
  rowIndex : Nat
  rowPointBits : List Nat
  openedLaneValues : List K
deriving Repr

def RowBound {K Digest : Type*} [OfNat K 1]
  (claim : RowBindingClaim K Digest)
  (z : Nightstream.Chip8.Witness K) : Prop :=
  claim.openingClaim.source = .kernel ∧
    claim.openingClaim.commitmentId = .lane ∧
    claim.rowPointBits = claim.openingClaim.point ∧
    claim.openingClaim.polynomialIds =
      ExactOpeningBoundary.laneRowBindingPolynomialIds ∧
    claim.openedLaneValues = rowNonFixedValues z ∧
    z 0 = 1

def RootEncode (W Z K : Type*) := Nightstream.Chip8.Witness K → W × Z

structure PreparedWitness (W Z : Type*) where
  w : W
  Z : Z
deriving Repr

structure PreparedMcs (Commitment K : Type*) where
  c : Commitment
  x : List K
  mIn : Nat
deriving Repr

structure PreparedStep (W Z Commitment K : Type*) where
  witness : PreparedWitness W Z
  mcs : PreparedMcs Commitment K
deriving Repr

def mkPreparedStep {W Z Commitment K : Type*} [OfNat K 1]
  (rootEncode : RootEncode W Z K)
  (ajtaiCommit : Z → Commitment)
  (z : Nightstream.Chip8.Witness K) : PreparedStep W Z Commitment K :=
  let encoded := rootEncode z
  {
    witness := { w := encoded.1, Z := encoded.2 }
    mcs := { c := ajtaiCommit encoded.2, x := [1], mIn := 1 }
  }

def PreparedStepBound {W Z Commitment K : Type*} [OfNat K 1]
  (rootEncode : RootEncode W Z K)
  (ajtaiCommit : Z → Commitment)
  (z : Nightstream.Chip8.Witness K)
  (step : PreparedStep W Z Commitment K) : Prop :=
  let encoded := rootEncode z
  step.witness.w = encoded.1 ∧
    step.witness.Z = encoded.2 ∧
    step.mcs.c = ajtaiCommit encoded.2 ∧
    step.mcs.x = [1] ∧
    step.mcs.mIn = 1

def Stage3Bound
  {K Proof Digest W Z Commitment : Type*} [Ring K]
  (N : Nat)
  (β1 β2 : K)
  (rootEncode : RootEncode W Z K)
  (ajtaiCommit : Z → Commitment)
  (shiftClaim : LaneShiftClaim K)
  (shiftProof : LaneShiftWitness K Proof)
  (currentRow : ContinuityRow K)
  (startRow : StartBoundaryRow K)
  (finalRow : FinalBoundaryRow K)
  (rowClaims : List (RowBindingClaim K Digest))
  (rows : List (Nightstream.Chip8.Witness K))
  (preparedSteps : List (PreparedStep W Z Commitment K)) : Prop :=
  ContinuityBound N β1 β2 shiftClaim shiftProof currentRow ∧
    StartBoundaryBound startRow ∧
    FinalBoundaryBound finalRow ∧
    List.Forall₂ RowBound rowClaims rows ∧
    List.Forall₂ (PreparedStepBound rootEncode ajtaiCommit) rows preparedSteps

theorem continuityBound_of_laneShift
  {K Proof : Type*} [Ring K]
  {N : Nat}
  {β1 β2 : K}
  {claim : LaneShiftClaim K}
  {proof : LaneShiftWitness K Proof}
  {currentRow : ContinuityRow K}
  (hShift : LaneShiftBound claim proof)
  (hMask : currentRow.pairMask = pairMaskValue N currentRow.rowIndex)
  (hEq :
    deltaPc currentRow.pairMask proof.shiftPc currentRow.pcNext +
        β1 * deltaBurstStep currentRow.pairMask currentRow.isMemOp
          currentRow.burstLast proof.shiftXIdx currentRow.xIdx +
        β2 * deltaBurstReset currentRow.pairMask proof.shiftIsMemOp
          currentRow.isMemOp currentRow.burstLast proof.shiftXIdx = 0) :
  ContinuityBound N β1 β2 claim proof currentRow := by
  exact ⟨hShift, hMask, hEq⟩

theorem preparedStepBound_of_rowBinding
  {K Digest W Z Commitment : Type*} [OfNat K 1]
  {claim : RowBindingClaim K Digest}
  {z : Nightstream.Chip8.Witness K}
  {rootEncode : RootEncode W Z K}
  {ajtaiCommit : Z → Commitment}
  (_hRow : RowBound claim z) :
  PreparedStepBound rootEncode ajtaiCommit z
    (mkPreparedStep rootEncode ajtaiCommit z) := by
  simp [PreparedStepBound, mkPreparedStep]

theorem startBoundaryBound_of_match
  {K : Type*} [Ring K]
  {stepIdx : Nat}
  {row : StartBoundaryRow K}
  {z : Nightstream.Chip8.Witness K}
  (hBoundary : StartBoundaryBound row)
  (hMatch : StartBoundaryMatches stepIdx row z)
  (hZero : stepIdx = 0) :
  StartBoundaryBound { isMemOp := z 19, xIdx := z 20 } := by
  rcases hMatch hZero with ⟨hIsMemOp, hXIdx⟩
  simpa [StartBoundaryBound, hIsMemOp, hXIdx] using hBoundary

theorem finalBoundaryBound_of_match
  {K : Type*} [Ring K]
  {stepIdx N : Nat}
  {row : FinalBoundaryRow K}
  {z : Nightstream.Chip8.Witness K}
  (hBoundary : FinalBoundaryBound row)
  (hMatch : FinalBoundaryMatches stepIdx N row z)
  (hLast : stepIdx + 1 = N) :
  FinalBoundaryBound { isMemOp := z 19, burstLast := z 22 } := by
  rcases hMatch hLast with ⟨hIsMemOp, hBurstLast⟩
  simpa [FinalBoundaryBound, hIsMemOp, hBurstLast] using hBoundary

theorem stage3Bound_exports_authenticatedRows
  {K Proof Digest W Z Commitment : Type*} [Ring K]
  {N : Nat}
  {β1 β2 : K}
  {rootEncode : RootEncode W Z K}
  {ajtaiCommit : Z → Commitment}
  {shiftClaim : LaneShiftClaim K}
  {shiftProof : LaneShiftWitness K Proof}
  {currentRow : ContinuityRow K}
  {startRow : StartBoundaryRow K}
  {finalRow : FinalBoundaryRow K}
  {rowClaims : List (RowBindingClaim K Digest)}
  {rows : List (Nightstream.Chip8.Witness K)}
  {preparedSteps : List (PreparedStep W Z Commitment K)}
  (h :
    Stage3Bound N β1 β2 rootEncode ajtaiCommit shiftClaim shiftProof currentRow
      startRow finalRow rowClaims rows preparedSteps) :
  List.Forall₂
    (fun claim step =>
      ∃ z,
        RowBound claim z ∧
          PreparedStepBound rootEncode ajtaiCommit z step)
    rowClaims preparedSteps := by
  rcases h with ⟨_, _, _, hRows, hSteps⟩
  revert preparedSteps
  induction hRows with
  | nil =>
      intro preparedSteps hSteps
      cases hSteps
      exact .nil
  | @cons claim z rowClaims rows hRow hRows ih =>
      intro preparedSteps hSteps
      cases hSteps with
      | cons hStep hStepsTail =>
          refine .cons ?_ (ih hStepsTail)
          exact ⟨z, hRow, hStep⟩

end Nightstream.Chip8.ContinuityBridge

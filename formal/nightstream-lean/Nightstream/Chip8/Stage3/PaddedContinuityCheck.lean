import Nightstream.Chip8.Stage3.ContinuityBridge

/-!
Owns the low-level Stage-3 padded-domain continuity surface beneath the
theorem-facing row-local continuity contract. This file records the raw
padded-domain values and explicit tail-correction terms needed to refine the
live Rust check to `ContinuityBridge.ContinuityBound`.
-/

namespace Nightstream.Chip8.PaddedContinuityCheck

open Nightstream.Chip8.ContinuityBridge

structure RawShiftValues (K : Type*) where
  shiftPc : K
  shiftXIdx : K
  shiftIsMemOp : K
deriving Repr

structure RawCurrentValues (K : Type*) where
  pcNext : K
  xIdx : K
  isMemOp : K
  burstLast : K
deriving Repr

structure TailCorrections (K : Type*) where
  shiftPc : K
  shiftXIdx : K
  shiftIsMemOp : K
  pcNext : K
  xIdx : K
  isMemOp : K
  burstLast : K
deriving Repr

def correctedShiftPc {K : Type*} [Sub K]
  (rawShift : RawShiftValues K) (tails : TailCorrections K) : K :=
  rawShift.shiftPc - tails.shiftPc

def correctedShiftXIdx {K : Type*} [Sub K]
  (rawShift : RawShiftValues K) (tails : TailCorrections K) : K :=
  rawShift.shiftXIdx - tails.shiftXIdx

def correctedShiftIsMemOp {K : Type*} [Sub K]
  (rawShift : RawShiftValues K) (tails : TailCorrections K) : K :=
  rawShift.shiftIsMemOp - tails.shiftIsMemOp

def correctedPcNext {K : Type*} [Sub K]
  (rawCurrent : RawCurrentValues K) (tails : TailCorrections K) : K :=
  rawCurrent.pcNext - tails.pcNext

def correctedXIdx {K : Type*} [Sub K]
  (rawCurrent : RawCurrentValues K) (tails : TailCorrections K) : K :=
  rawCurrent.xIdx - tails.xIdx

def correctedIsMemOp {K : Type*} [Sub K]
  (rawCurrent : RawCurrentValues K) (tails : TailCorrections K) : K :=
  rawCurrent.isMemOp - tails.isMemOp

def correctedBurstLast {K : Type*} [Sub K]
  (rawCurrent : RawCurrentValues K) (tails : TailCorrections K) : K :=
  rawCurrent.burstLast - tails.burstLast

def PaddedContinuityCheckBound
  {K Proof : Type*} [Ring K]
  (N : Nat)
  (β1 β2 : K)
  (claim : LaneShiftClaim K)
  (proof : LaneShiftWitness K Proof)
  (currentRow : ContinuityRow K)
  (rawShift : RawShiftValues K)
  (rawCurrent : RawCurrentValues K)
  (tails : TailCorrections K) : Prop :=
  LaneShiftBound claim proof ∧
    proof.shiftPc = correctedShiftPc rawShift tails ∧
    proof.shiftXIdx = correctedShiftXIdx rawShift tails ∧
    proof.shiftIsMemOp = correctedShiftIsMemOp rawShift tails ∧
    currentRow.pairMask = pairMaskValue N currentRow.rowIndex ∧
    currentRow.pcNext = correctedPcNext rawCurrent tails ∧
    currentRow.xIdx = correctedXIdx rawCurrent tails ∧
    currentRow.isMemOp = correctedIsMemOp rawCurrent tails ∧
    currentRow.burstLast = correctedBurstLast rawCurrent tails ∧
    deltaPc currentRow.pairMask
        (correctedShiftPc rawShift tails)
        (correctedPcNext rawCurrent tails) +
      β1 * deltaBurstStep currentRow.pairMask
        (correctedIsMemOp rawCurrent tails)
        (correctedBurstLast rawCurrent tails)
        (correctedShiftXIdx rawShift tails)
        (correctedXIdx rawCurrent tails) +
      β2 * deltaBurstReset currentRow.pairMask
        (correctedShiftIsMemOp rawShift tails)
        (correctedIsMemOp rawCurrent tails)
        (correctedBurstLast rawCurrent tails)
        (correctedShiftXIdx rawShift tails) = 0

theorem continuityBound_of_paddedCheck
  {K Proof : Type*} [Ring K]
  {N : Nat}
  {β1 β2 : K}
  {claim : LaneShiftClaim K}
  {proof : LaneShiftWitness K Proof}
  {currentRow : ContinuityRow K}
  {rawShift : RawShiftValues K}
  {rawCurrent : RawCurrentValues K}
  {tails : TailCorrections K}
  (h :
    PaddedContinuityCheckBound N β1 β2 claim proof currentRow rawShift
      rawCurrent tails) :
  ContinuityBound N β1 β2 claim proof currentRow := by
  rcases h with
    ⟨hShift, hShiftPc, hShiftXIdx, hShiftIsMemOp, hMask, hPcNext, hXIdx,
      hIsMemOp, hBurstLast, hEq⟩
  refine ⟨hShift, hMask, ?_⟩
  simpa [hShiftPc, hShiftXIdx, hShiftIsMemOp, hPcNext, hXIdx, hIsMemOp,
    hBurstLast] using hEq

end Nightstream.Chip8.PaddedContinuityCheck

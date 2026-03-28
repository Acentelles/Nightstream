import Nightstream.Chip8.Execution.ExecutionSemantics
import Nightstream.Chip8.Kernel.OpeningBoundary
import Nightstream.Chip8.Stage3.PaddedContinuityCheck

/-!
Owns the explicit refinement from the low-level padded-domain Stage-3 check to
the theorem-facing row-local continuity surface consumed downstream.
-/

namespace Nightstream.Chip8.Stage3Refinement

open Nightstream.Chip8
open Nightstream.Chip8.ContinuityBridge
open Nightstream.Chip8.ExecutionSemantics
open Nightstream.Chip8.ExactOpeningBoundary
open Nightstream.Chip8.PaddedContinuityCheck

abbrev F := ExecutionSemantics.F

structure ActivePrefixContinuityRefinement
  {stepIdx N : Nat}
  {β1 β2 : F}
  {claim : LaneShiftClaim F}
  {proof : LaneShiftWitness F Unit}
  {currentRow : ContinuityRow F}
  {rawShift : RawShiftValues F}
  {rawCurrent : RawCurrentValues F}
  {tails : TailCorrections F}
  {z : Nightstream.Chip8.Witness F} where
  padded :
    PaddedContinuityCheckBound N β1 β2 claim proof currentRow rawShift
      rawCurrent tails
  rowClaim : RowBindingClaim F Unit
  acceptedRowOpening : AcceptedDirectOpening F Unit
  acceptedRowOpeningClaim : acceptedRowOpening.claim = rowClaim.openingClaim
  rowClaimIndex : rowClaim.rowIndex = stepIdx
  rowBinding : RowBound rowClaim z
  currentRowIndex : currentRow.rowIndex = stepIdx
  currentPcNext : currentRow.pcNext = z 2
  currentXIdx : currentRow.xIdx = z 20
  currentIsMemOp : currentRow.isMemOp = z 19
  currentBurstLast : currentRow.burstLast = z 22

theorem continuityRowBound_of_paddedCheck
  {stepIdx N : Nat}
  {β1 β2 : F}
  {claim : LaneShiftClaim F}
  {proof : LaneShiftWitness F Unit}
  {currentRow : ContinuityRow F}
  {rowClaim : RowBindingClaim F Unit}
  {z : Nightstream.Chip8.Witness F}
  {rawShift : RawShiftValues F}
  {rawCurrent : RawCurrentValues F}
  {tails : TailCorrections F}
  (hPadded :
    PaddedContinuityCheckBound N β1 β2 claim proof currentRow rawShift
      rawCurrent tails)
  (hCurrentRowIndex : currentRow.rowIndex = stepIdx)
  (hCurrentPcNext : currentRow.pcNext = z 2)
  (hCurrentXIdx : currentRow.xIdx = z 20)
  (hCurrentIsMemOp : currentRow.isMemOp = z 19)
  (hCurrentBurstLast : currentRow.burstLast = z 22)
  (hRowClaimIndex : rowClaim.rowIndex = stepIdx)
  (hRowBinding : RowBound rowClaim z) :
  ContinuityRowBound stepIdx N β1 β2 claim proof currentRow rowClaim z := by
  exact ⟨continuityBound_of_paddedCheck hPadded, hCurrentRowIndex, hCurrentPcNext,
    hCurrentXIdx, hCurrentIsMemOp, hCurrentBurstLast, hRowClaimIndex,
    hRowBinding⟩

theorem continuityRowBound_of_activePrefixRefinement
  {stepIdx N : Nat}
  {β1 β2 : F}
  {claim : LaneShiftClaim F}
  {proof : LaneShiftWitness F Unit}
  {currentRow : ContinuityRow F}
  {rawShift : RawShiftValues F}
  {rawCurrent : RawCurrentValues F}
  {tails : TailCorrections F}
  {z : Nightstream.Chip8.Witness F}
  (h :
    ActivePrefixContinuityRefinement
      (stepIdx := stepIdx) (N := N) (β1 := β1) (β2 := β2)
      (claim := claim) (proof := proof) (currentRow := currentRow)
      (rawShift := rawShift) (rawCurrent := rawCurrent) (tails := tails)
      (z := z)) :
  ContinuityRowBound stepIdx N β1 β2 claim proof currentRow h.rowClaim z := by
  exact continuityRowBound_of_paddedCheck h.padded h.currentRowIndex
    h.currentPcNext h.currentXIdx h.currentIsMemOp h.currentBurstLast
    h.rowClaimIndex h.rowBinding

end Nightstream.Chip8.Stage3Refinement

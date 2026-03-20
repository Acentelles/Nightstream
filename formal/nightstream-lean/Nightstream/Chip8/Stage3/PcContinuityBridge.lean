import Nightstream.Chip8.Execution.StepComposition

/-!
Owns the theorem-facing Stage-3 bridge from checked lane-shift continuity data
to real adjacent-row `pc` continuity. This file does not authenticate the
shift proof itself; it makes explicit the exact semantic support facts that are
still needed to turn that authenticated Stage-3 surface into `PcTemporalBound`.
-/

namespace Nightstream.Chip8.PcContinuityBridge

open Nightstream.Chip8
open Nightstream.Chip8.FetchDecodeBinding
open Nightstream.Chip8.StepComposition
open Nightstream.Chip8.ContinuityBridge
open Nightstream.Chip8.WitnessMemoryBinding

abbrev F := StepComposition.F
abbrev Program := FetchDecodeBinding.Program
abbrev MachineState := StepComposition.MachineState
abbrev ExecutionFrame := StepComposition.ExecutionFrame

def PcTemporalBound
  {Addr : Type*} :
  List (ExecutionFrame Addr) → Prop
  | [] => True
  | [_] => True
  | current :: next :: rest =>
      current.post.pc = next.pre.pc ∧
        PcTemporalBound (next :: rest)

def ShiftPcMatchesCurrentPcNext
  (shiftProof : ContinuityBridge.LaneShiftWitness F Unit)
  (currentRow : ContinuityBridge.ContinuityRow F) : Prop :=
  shiftProof.shiftPc = currentRow.pcNext

def ShiftPcMatchesNextRow
  {Addr : Type*}
  (shiftProof : ContinuityBridge.LaneShiftWitness F Unit)
  (next : ExecutionFrame Addr) : Prop :=
  shiftProof.shiftPc = next.row 1

def PcAdjacentBridgeFrom
  {Addr : Type*} :
  Nat → List (ExecutionFrame Addr) → Prop
  | _, [] => True
  | _, [_] => True
  | stepIdx, current :: next :: rest =>
      (∃ N β1 β2 shiftClaim shiftProof currentRow rowClaim,
        StepComposition.ContinuityRowBound stepIdx N β1 β2 shiftClaim shiftProof
          currentRow rowClaim current.row ∧
          ShiftPcMatchesCurrentPcNext shiftProof currentRow ∧
          ShiftPcMatchesNextRow shiftProof next) ∧
        PcAdjacentBridgeFrom (stepIdx + 1) (next :: rest)

def PcAdjacentBridge
  {Addr : Type*}
  (trace : List (ExecutionFrame Addr)) : Prop :=
  PcAdjacentBridgeFrom 0 trace

theorem headPcTemporal_of_pcTemporalBound
  {Addr : Type*}
  {current next : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : PcTemporalBound (current :: next :: rest)) :
  current.post.pc = next.pre.pc := by
  exact h.1

theorem tailPcTemporal_of_pcTemporalBound
  {Addr : Type*}
  {current next : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : PcTemporalBound (current :: next :: rest)) :
  PcTemporalBound (next :: rest) := by
  exact h.2

theorem adjacentPc_of_bridge
  {Addr : Type*}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx N : Nat}
  {β1 β2 : F}
  {shiftClaim : ContinuityBridge.LaneShiftClaim F}
  {shiftProof : ContinuityBridge.LaneShiftWitness F Unit}
  {currentRow : ContinuityBridge.ContinuityRow F}
  {rowClaim : ContinuityBridge.RowBindingClaim F Unit}
  {current next : ExecutionFrame Addr}
  (hCont :
    StepComposition.ContinuityRowBound stepIdx N β1 β2 shiftClaim shiftProof
      currentRow rowClaim current.row)
  (hCurrentFrame : StepComposition.ExecutionFrameBound rom σ current)
  (hNextFrame : StepComposition.ExecutionFrameBound rom σ next)
  (hCurrentPost : StepComposition.StateWellFormed current.post)
  (hNextPre : StepComposition.StateWellFormed next.pre)
  (hShiftCurrent : ShiftPcMatchesCurrentPcNext shiftProof currentRow)
  (hShiftNext : ShiftPcMatchesNextRow shiftProof next) :
  current.post.pc = next.pre.pc := by
  have hCurrentWitness :
      WitnessMemoryBinding.WitnessBinds (K := F) current.pre current.post current.dec current.row :=
    StepComposition.executionFrameBound_witnessBinds hCurrentFrame
  have hNextWitness :
      WitnessMemoryBinding.WitnessBinds (K := F) next.pre next.post next.dec next.row :=
    StepComposition.executionFrameBound_witnessBinds hNextFrame
  have hPcNextRow : currentRow.pcNext = current.row 2 := hCont.2.2.1
  have hCurrentField : (current.post.pc : F) = shiftProof.shiftPc := by
    calc
      (current.post.pc : F) = current.row 2 := by
        symm
        exact witnessBinds_pcNext hCurrentWitness
      _ = currentRow.pcNext := by symm; exact hPcNextRow
      _ = shiftProof.shiftPc := by symm; exact hShiftCurrent
  have hNextField : (next.pre.pc : F) = shiftProof.shiftPc := by
    calc
      (next.pre.pc : F) = next.row 1 := by
        symm
        exact witnessBinds_pc hNextWitness
      _ = shiftProof.shiftPc := by symm; exact hShiftNext
  exact StepComposition.natEq_of_fieldEq
    (StepComposition.stateWellFormed_pc_lt_q hCurrentPost)
    (StepComposition.stateWellFormed_pc_lt_q hNextPre)
    (hCurrentField.trans hNextField.symm)

theorem pcTemporalBound_of_adjacentBridgeFrom
  {Addr : Type*}
  {rom : Program}
  {σ : ExternalSchedule}
  {trace : List (ExecutionFrame Addr)} :
  ∀ {stepIdx : Nat},
    List.Forall (StepComposition.ExecutionFrameBound rom σ) trace →
      List.Forall (fun frame => StepComposition.StateWellFormed frame.pre ∧
        StepComposition.StateWellFormed frame.post) trace →
      PcAdjacentBridgeFrom stepIdx trace →
      PcTemporalBound trace := by
  intro stepIdx hFrames hWf hBridge
  induction trace generalizing stepIdx with
  | nil =>
      simp [PcTemporalBound]
  | cons current rest ih =>
      cases rest with
      | nil =>
          simp [PcTemporalBound]
      | cons next tail =>
          rcases hBridge with ⟨hHead, hTail⟩
          rcases hHead with
            ⟨N, β1, β2, shiftClaim, shiftProof, currentRow, rowClaim,
              hCont, hShiftCurrent, hShiftNext⟩
          have hFramesHead :
              StepComposition.ExecutionFrameBound rom σ current ∧
                List.Forall (StepComposition.ExecutionFrameBound rom σ)
                  (next :: tail) := by
            simpa [List.Forall] using hFrames
          have hWfHead :
              (StepComposition.StateWellFormed current.pre ∧
                StepComposition.StateWellFormed current.post) ∧
                List.Forall
                  (fun frame =>
                    StepComposition.StateWellFormed frame.pre ∧
                      StepComposition.StateWellFormed frame.post)
                  (next :: tail) := by
            simpa [List.Forall] using hWf
          have hFramesNext :
              StepComposition.ExecutionFrameBound rom σ next ∧
                List.Forall (StepComposition.ExecutionFrameBound rom σ) tail := by
            simpa [List.Forall] using hFramesHead.2
          have hWfNext :
              (StepComposition.StateWellFormed next.pre ∧
                StepComposition.StateWellFormed next.post) ∧
                List.Forall
                  (fun frame =>
                    StepComposition.StateWellFormed frame.pre ∧
                      StepComposition.StateWellFormed frame.post)
                  tail := by
            simpa [List.Forall] using hWfHead.2
          refine ⟨?_, ?_⟩
          · exact adjacentPc_of_bridge hCont hFramesHead.1 hFramesNext.1
              hWfHead.1.2 hWfNext.1.1 hShiftCurrent hShiftNext
          · exact ih hFramesHead.2 hWfHead.2 hTail

theorem pcTemporalBound_of_adjacentBridge
  {Addr : Type*}
  {rom : Program}
  {σ : ExternalSchedule}
  {trace : List (ExecutionFrame Addr)}
  (hFrames : List.Forall (StepComposition.ExecutionFrameBound rom σ) trace)
  (hWf : List.Forall
    (fun frame => StepComposition.StateWellFormed frame.pre ∧
      StepComposition.StateWellFormed frame.post) trace)
  (hBridge : PcAdjacentBridge trace) :
  PcTemporalBound trace := by
  exact pcTemporalBound_of_adjacentBridgeFrom (stepIdx := 0) hFrames hWf hBridge

end Nightstream.Chip8.PcContinuityBridge

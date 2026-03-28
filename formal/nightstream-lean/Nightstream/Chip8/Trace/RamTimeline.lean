import Nightstream.Chip8.Execution.ExecutionSemantics

/-!
Owns the RAM component of adjacent-frame temporal consistency for one CHIP-8
execution trace. This file fixes the RAM timeline contract and its extensional
bridge to adjacent-frame equality, but does not re-own staged-evidence
extraction.
-/

namespace Nightstream.Chip8.RamTimeline

open Nightstream.Chip8
open Nightstream.Chip8.ExecutionSemantics

abbrev F := ExecutionSemantics.F
abbrev MachineState := ExecutionSemantics.MachineState
abbrev ExecutionFrame := ExecutionSemantics.ExecutionFrame
abbrev RamValueTimeline := Nat → Nat → Nat
abbrev RamAddressBound := ExecutionSemantics.RamAddressBound

def RamAdjacentBound
  {Addr : Type*}
  (current next : ExecutionFrame Addr) : Prop :=
  ∀ addr, RamAddressBound addr → current.post.ram addr = next.pre.ram addr

def RamAdjacentTraceBound
  {Addr : Type*}
  : List (ExecutionFrame Addr) → Prop
  | [] => True
  | [_] => True
  | current :: next :: rest =>
      RamAdjacentBound current next ∧
        RamAdjacentTraceBound (next :: rest)

def ramTimelineOfTraceFrom
  {Addr : Type*}
  (trace : List (ExecutionFrame Addr))
  (base : Nat) : RamValueTimeline :=
  fun addr step =>
    match (trace.drop (step - base)).head? with
    | some frame => frame.pre.ram addr
    | none => 0

def ramTimelineOfTrace
  {Addr : Type*}
  (trace : List (ExecutionFrame Addr)) : RamValueTimeline :=
  ramTimelineOfTraceFrom trace 0

def RamTemporalBoundFrom
  {Addr : Type*}
  (ramVal : RamValueTimeline) :
  Nat → List (ExecutionFrame Addr) → Prop
  | _, [] => True
  | stepIdx, [current] =>
      ∀ addr, RamAddressBound addr → current.pre.ram addr = ramVal addr stepIdx
  | stepIdx, current :: next :: rest =>
      (∀ addr, RamAddressBound addr → current.pre.ram addr = ramVal addr stepIdx) ∧
      (∀ addr, RamAddressBound addr → current.post.ram addr = ramVal addr (stepIdx + 1)) ∧
      RamTemporalBoundFrom ramVal (stepIdx + 1) (next :: rest)

def RamTemporalBound
  {Addr : Type*}
  (ramVal : RamValueTimeline)
  (trace : List (ExecutionFrame Addr)) : Prop :=
  RamTemporalBoundFrom ramVal 0 trace

theorem ramTimelineOfTraceFrom_tail
  {Addr : Type*}
  {current : ExecutionFrame Addr}
  {trace : List (ExecutionFrame Addr)}
  {stepIdx addr step : Nat}
  (hStep : stepIdx + 1 ≤ step) :
  ramTimelineOfTraceFrom (current :: trace) stepIdx addr step =
    ramTimelineOfTraceFrom trace (stepIdx + 1) addr step := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hStep
  have hSubHead : (stepIdx + 1 + k) - stepIdx = k + 1 := by
    omega
  have hSubTail : (stepIdx + 1 + k) - (stepIdx + 1) = k := by
    omega
  simp [ramTimelineOfTraceFrom, hSubHead, hSubTail]

theorem ramTemporalBoundFrom_congr
  {Addr : Type*}
  {ramVal₁ ramVal₂ : RamValueTimeline}
  {stepIdx : Nat}
  {trace : List (ExecutionFrame Addr)}
  (hEq : ∀ addr step, stepIdx ≤ step → ramVal₁ addr step = ramVal₂ addr step)
  (h : RamTemporalBoundFrom ramVal₁ stepIdx trace) :
  RamTemporalBoundFrom ramVal₂ stepIdx trace := by
  induction trace generalizing stepIdx with
  | nil =>
      simpa [RamTemporalBoundFrom] using h
  | cons current rest ih =>
      cases rest with
      | nil =>
          intro addr hAddr
          exact (h addr hAddr).trans (hEq addr stepIdx (Nat.le_refl _))
      | cons next tail =>
          refine ⟨?_, ?_, ?_⟩
          · intro addr hAddr
            exact (h.1 addr hAddr).trans (hEq addr stepIdx (Nat.le_refl _))
          · intro addr hAddr
            exact (h.2.1 addr hAddr).trans (hEq addr (stepIdx + 1) (Nat.le_succ _))
          · exact ih
              (stepIdx := stepIdx + 1)
              (fun addr step hStep =>
                hEq addr step (Nat.le_trans (Nat.le_succ _) hStep))
              h.2.2

theorem headRamPreBound_of_ramTemporalBoundFrom
  {Addr : Type*}
  {ramVal : RamValueTimeline}
  {stepIdx : Nat}
  {current : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : RamTemporalBoundFrom ramVal stepIdx (current :: rest)) :
  ∀ addr, RamAddressBound addr → current.pre.ram addr = ramVal addr stepIdx := by
  cases rest with
  | nil =>
      exact h
  | cons next tail =>
      exact h.1

theorem ramAdjacentBound_of_ramTemporalBoundFrom
  {Addr : Type*}
  {ramVal : RamValueTimeline}
  {stepIdx : Nat}
  {current next : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : RamTemporalBoundFrom ramVal stepIdx (current :: next :: rest)) :
  RamAdjacentBound current next := by
  have hPost :
      ∀ addr, RamAddressBound addr →
        current.post.ram addr = ramVal addr (stepIdx + 1) := h.2.1
  have hNextPre :
      ∀ addr, RamAddressBound addr →
        next.pre.ram addr = ramVal addr (stepIdx + 1) :=
    headRamPreBound_of_ramTemporalBoundFrom h.2.2
  intro addr hAddr
  exact (hPost addr hAddr).trans (hNextPre addr hAddr).symm

theorem tailRamTemporalBoundFrom_of_ramTemporalBoundFrom
  {Addr : Type*}
  {ramVal : RamValueTimeline}
  {stepIdx : Nat}
  {current next : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : RamTemporalBoundFrom ramVal stepIdx (current :: next :: rest)) :
  RamTemporalBoundFrom ramVal (stepIdx + 1) (next :: rest) := by
  exact h.2.2

theorem ramAdjacentBound_of_ramTemporalBound
  {Addr : Type*}
  {ramVal : RamValueTimeline}
  {current next : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : RamTemporalBound ramVal (current :: next :: rest)) :
  RamAdjacentBound current next := by
  exact ramAdjacentBound_of_ramTemporalBoundFrom h

theorem tailRamTemporalBound_of_ramTemporalBound
  {Addr : Type*}
  {ramVal : RamValueTimeline}
  {current next : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : RamTemporalBound ramVal (current :: next :: rest)) :
  RamTemporalBoundFrom ramVal 1 (next :: rest) := by
  exact tailRamTemporalBoundFrom_of_ramTemporalBoundFrom h

theorem ramTemporalBoundFrom_of_adjacentTraceBound
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)} :
  ∀ {stepIdx : Nat},
    RamAdjacentTraceBound trace →
      RamTemporalBoundFrom (ramTimelineOfTraceFrom trace stepIdx) stepIdx trace := by
  intro stepIdx hAdj
  induction trace generalizing stepIdx with
  | nil =>
      simp [RamTemporalBoundFrom]
  | cons current rest ih =>
      cases rest with
      | nil =>
          intro addr hAddr
          simp [ramTimelineOfTraceFrom]
      | cons next tail =>
          rcases hAdj with ⟨hHead, hTail⟩
          refine ⟨?_, ?_, ?_⟩
          · intro addr hAddr
            simp [ramTimelineOfTraceFrom]
          · intro addr hAddr
            simpa [ramTimelineOfTraceFrom] using hHead addr hAddr
          · exact
              ramTemporalBoundFrom_congr
                (stepIdx := stepIdx + 1)
                (trace := next :: tail)
                (ramVal₁ := ramTimelineOfTraceFrom (next :: tail) (stepIdx + 1))
                (ramVal₂ := ramTimelineOfTraceFrom (current :: next :: tail) stepIdx)
                (fun addr step hStep =>
                  (ramTimelineOfTraceFrom_tail
                    (current := current) (trace := next :: tail)
                    (stepIdx := stepIdx) (addr := addr) (step := step) hStep).symm)
                (ih (stepIdx := stepIdx + 1) hTail)

theorem ramTemporalBound_of_adjacentTraceBound
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)}
  (hAdj : RamAdjacentTraceBound trace) :
  RamTemporalBound (ramTimelineOfTrace trace) trace := by
  simpa [RamTemporalBound, ramTimelineOfTrace]
    using
      (ramTemporalBoundFrom_of_adjacentTraceBound
        (trace := trace) (stepIdx := 0) hAdj)

theorem ramAdjacentTraceBound_of_ramTemporalBoundFrom
  {Addr : Type*}
  {ramVal : RamValueTimeline}
  {stepIdx : Nat}
  {trace : List (ExecutionFrame Addr)}
  (h : RamTemporalBoundFrom ramVal stepIdx trace) :
  RamAdjacentTraceBound trace := by
  induction trace generalizing stepIdx with
  | nil =>
      simp [RamAdjacentTraceBound]
  | cons current rest ih =>
      cases rest with
      | nil =>
          simp [RamAdjacentTraceBound]
      | cons next tail =>
          exact
            ⟨ramAdjacentBound_of_ramTemporalBoundFrom h,
              ih (stepIdx := stepIdx + 1)
                (tailRamTemporalBoundFrom_of_ramTemporalBoundFrom h)⟩

theorem ramAdjacentTraceBound_of_ramTemporalBound
  {Addr : Type*}
  {ramVal : RamValueTimeline}
  {trace : List (ExecutionFrame Addr)}
  (h : RamTemporalBound ramVal trace) :
  RamAdjacentTraceBound trace := by
  exact ramAdjacentTraceBound_of_ramTemporalBoundFrom h

end Nightstream.Chip8.RamTimeline

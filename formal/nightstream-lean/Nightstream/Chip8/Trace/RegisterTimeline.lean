import Nightstream.Chip8.Execution.ExecutionSemantics

/-!
Owns the register/I component of adjacent-frame temporal consistency for one
CHIP-8 execution trace. This file fixes the timeline-level semantic contract
used by stronger trace linking, but does not re-own staged-evidence extraction.
-/

namespace Nightstream.Chip8.RegisterTimeline

open Nightstream.Chip8
open Nightstream.Chip8.ExecutionSemantics

abbrev F := ExecutionSemantics.F
abbrev MachineState := ExecutionSemantics.MachineState
abbrev ExecutionFrame := ExecutionSemantics.ExecutionFrame
abbrev RegisterValueTimeline := Nat → Nat → Nat
abbrev RegisterIndexBound := ExecutionSemantics.RegisterIndexBound

def RegisterAdjacentBound
  {Addr : Type*}
  (current next : ExecutionFrame Addr) : Prop :=
  current.post.i = next.pre.i ∧
    (∀ idx, RegisterIndexBound idx → current.post.v idx = next.pre.v idx)

def RegisterAdjacentTraceBound
  {Addr : Type*}
  : List (ExecutionFrame Addr) → Prop
  | [] => True
  | [_] => True
  | current :: next :: rest =>
      RegisterAdjacentBound current next ∧
        RegisterAdjacentTraceBound (next :: rest)

def registerTimelineOfTraceFrom
  {Addr : Type*}
  (trace : List (ExecutionFrame Addr))
  (base : Nat) : RegisterValueTimeline :=
  fun idx step =>
    match (trace.drop (step - base)).head? with
    | some frame => if idx = 16 then frame.pre.i else frame.pre.v idx
    | none => 0

def registerTimelineOfTrace
  {Addr : Type*}
  (trace : List (ExecutionFrame Addr)) : RegisterValueTimeline :=
  registerTimelineOfTraceFrom trace 0

def RegisterTemporalBoundFrom
  {Addr : Type*}
  (regVal : RegisterValueTimeline) :
  Nat → List (ExecutionFrame Addr) → Prop
  | _, [] => True
  | stepIdx, [current] =>
      current.pre.i = regVal 16 stepIdx ∧
        (∀ idx, RegisterIndexBound idx → current.pre.v idx = regVal idx stepIdx)
  | stepIdx, current :: next :: rest =>
      (current.pre.i = regVal 16 stepIdx ∧
        (∀ idx, RegisterIndexBound idx → current.pre.v idx = regVal idx stepIdx)) ∧
      (current.post.i = regVal 16 (stepIdx + 1) ∧
        (∀ idx, RegisterIndexBound idx → current.post.v idx = regVal idx (stepIdx + 1))) ∧
      RegisterTemporalBoundFrom regVal (stepIdx + 1) (next :: rest)

def RegisterTemporalBound
  {Addr : Type*}
  (regVal : RegisterValueTimeline)
  (trace : List (ExecutionFrame Addr)) : Prop :=
  RegisterTemporalBoundFrom regVal 0 trace

theorem registerTimelineOfTraceFrom_tail
  {Addr : Type*}
  {current : ExecutionFrame Addr}
  {trace : List (ExecutionFrame Addr)}
  {stepIdx idx step : Nat}
  (hStep : stepIdx + 1 ≤ step) :
  registerTimelineOfTraceFrom (current :: trace) stepIdx idx step =
    registerTimelineOfTraceFrom trace (stepIdx + 1) idx step := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hStep
  have hSubHead : (stepIdx + 1 + k) - stepIdx = k + 1 := by
    omega
  have hSubTail : (stepIdx + 1 + k) - (stepIdx + 1) = k := by
    omega
  simp [registerTimelineOfTraceFrom, hSubHead, hSubTail]

theorem registerTemporalBoundFrom_congr
  {Addr : Type*}
  {regVal₁ regVal₂ : RegisterValueTimeline}
  {stepIdx : Nat}
  {trace : List (ExecutionFrame Addr)}
  (hEq : ∀ idx step, stepIdx ≤ step → regVal₁ idx step = regVal₂ idx step)
  (h : RegisterTemporalBoundFrom regVal₁ stepIdx trace) :
  RegisterTemporalBoundFrom regVal₂ stepIdx trace := by
  induction trace generalizing stepIdx with
  | nil =>
      simpa [RegisterTemporalBoundFrom] using h
  | cons current rest ih =>
      cases rest with
      | nil =>
          refine ⟨?_, ?_⟩
          · exact h.1.trans (hEq 16 stepIdx (Nat.le_refl _))
          · intro idx hIdx
            exact (h.2 idx hIdx).trans (hEq idx stepIdx (Nat.le_refl _))
      | cons next tail =>
          refine ⟨?_, ?_, ?_⟩
          · refine ⟨?_, ?_⟩
            · exact h.1.1.trans (hEq 16 stepIdx (Nat.le_refl _))
            · intro idx hIdx
              exact (h.1.2 idx hIdx).trans (hEq idx stepIdx (Nat.le_refl _))
          · refine ⟨?_, ?_⟩
            · exact h.2.1.1.trans (hEq 16 (stepIdx + 1) (Nat.le_succ _))
            · intro idx hIdx
              exact (h.2.1.2 idx hIdx).trans (hEq idx (stepIdx + 1) (Nat.le_succ _))
          · exact ih
              (stepIdx := stepIdx + 1)
              (fun idx step hStep =>
                hEq idx step (Nat.le_trans (Nat.le_succ _) hStep))
              h.2.2

theorem headRegisterPreBound_of_registerTemporalBoundFrom
  {Addr : Type*}
  {regVal : RegisterValueTimeline}
  {stepIdx : Nat}
  {current : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : RegisterTemporalBoundFrom regVal stepIdx (current :: rest)) :
  current.pre.i = regVal 16 stepIdx ∧
    (∀ idx, RegisterIndexBound idx → current.pre.v idx = regVal idx stepIdx) := by
  cases rest with
  | nil =>
      exact h
  | cons next tail =>
      exact h.1

theorem registerAdjacentBound_of_registerTemporalBoundFrom
  {Addr : Type*}
  {regVal : RegisterValueTimeline}
  {stepIdx : Nat}
  {current next : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : RegisterTemporalBoundFrom regVal stepIdx (current :: next :: rest)) :
  RegisterAdjacentBound current next := by
  have hPost :
      current.post.i = regVal 16 (stepIdx + 1) ∧
        (∀ idx, RegisterIndexBound idx →
          current.post.v idx = regVal idx (stepIdx + 1)) := h.2.1
  have hNextPre :
      next.pre.i = regVal 16 (stepIdx + 1) ∧
        (∀ idx, RegisterIndexBound idx →
          next.pre.v idx = regVal idx (stepIdx + 1)) :=
    headRegisterPreBound_of_registerTemporalBoundFrom h.2.2
  refine ⟨hPost.1.trans hNextPre.1.symm, ?_⟩
  intro idx hIdx
  exact (hPost.2 idx hIdx).trans (hNextPre.2 idx hIdx).symm

theorem tailRegisterTemporalBoundFrom_of_registerTemporalBoundFrom
  {Addr : Type*}
  {regVal : RegisterValueTimeline}
  {stepIdx : Nat}
  {current next : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : RegisterTemporalBoundFrom regVal stepIdx (current :: next :: rest)) :
  RegisterTemporalBoundFrom regVal (stepIdx + 1) (next :: rest) := by
  exact h.2.2

theorem registerAdjacentBound_of_registerTemporalBound
  {Addr : Type*}
  {regVal : RegisterValueTimeline}
  {current next : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : RegisterTemporalBound regVal (current :: next :: rest)) :
  RegisterAdjacentBound current next := by
  exact registerAdjacentBound_of_registerTemporalBoundFrom h

theorem tailRegisterTemporalBound_of_registerTemporalBound
  {Addr : Type*}
  {regVal : RegisterValueTimeline}
  {current next : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : RegisterTemporalBound regVal (current :: next :: rest)) :
  RegisterTemporalBoundFrom regVal 1 (next :: rest) := by
  exact tailRegisterTemporalBoundFrom_of_registerTemporalBoundFrom h

theorem registerTemporalBoundFrom_of_adjacentTraceBound
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)} :
  ∀ {stepIdx : Nat},
    RegisterAdjacentTraceBound trace →
      RegisterTemporalBoundFrom (registerTimelineOfTraceFrom trace stepIdx)
        stepIdx trace := by
  intro stepIdx hAdj
  induction trace generalizing stepIdx with
  | nil =>
      simp [RegisterTemporalBoundFrom]
  | cons current rest ih =>
      cases rest with
      | nil =>
          refine ⟨?_, ?_⟩
          · simp [registerTimelineOfTraceFrom]
          · intro idx hIdx
            have hNe : idx ≠ 16 := Nat.ne_of_lt hIdx
            simp [registerTimelineOfTraceFrom, hNe]
      | cons next tail =>
          rcases hAdj with ⟨hHead, hTail⟩
          refine ⟨?_, ?_, ?_⟩
          · refine ⟨?_, ?_⟩
            · simp [registerTimelineOfTraceFrom]
            · intro idx hIdx
              have hNe : idx ≠ 16 := Nat.ne_of_lt hIdx
              simp [registerTimelineOfTraceFrom, hNe]
          · refine ⟨?_, ?_⟩
            · simpa [registerTimelineOfTraceFrom] using hHead.1
            · intro idx hIdx
              have hNe : idx ≠ 16 := Nat.ne_of_lt hIdx
              simpa [registerTimelineOfTraceFrom, hNe] using hHead.2 idx hIdx
          · exact
              registerTemporalBoundFrom_congr
                (stepIdx := stepIdx + 1)
                (trace := next :: tail)
                (regVal₁ := registerTimelineOfTraceFrom (next :: tail) (stepIdx + 1))
                (regVal₂ := registerTimelineOfTraceFrom (current :: next :: tail) stepIdx)
                (fun idx step hStep =>
                  (registerTimelineOfTraceFrom_tail
                    (current := current) (trace := next :: tail)
                    (stepIdx := stepIdx) (idx := idx) (step := step) hStep).symm)
                (ih (stepIdx := stepIdx + 1) hTail)

theorem registerTemporalBound_of_adjacentTraceBound
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)}
  (hAdj : RegisterAdjacentTraceBound trace) :
  RegisterTemporalBound (registerTimelineOfTrace trace) trace := by
  simpa [RegisterTemporalBound, registerTimelineOfTrace]
    using
      (registerTemporalBoundFrom_of_adjacentTraceBound
        (trace := trace) (stepIdx := 0) hAdj)

theorem registerAdjacentTraceBound_of_registerTemporalBoundFrom
  {Addr : Type*}
  {regVal : RegisterValueTimeline}
  {stepIdx : Nat}
  {trace : List (ExecutionFrame Addr)}
  (h : RegisterTemporalBoundFrom regVal stepIdx trace) :
  RegisterAdjacentTraceBound trace := by
  induction trace generalizing stepIdx with
  | nil =>
      simp [RegisterAdjacentTraceBound]
  | cons current rest ih =>
      cases rest with
      | nil =>
          simp [RegisterAdjacentTraceBound]
      | cons next tail =>
          exact
            ⟨registerAdjacentBound_of_registerTemporalBoundFrom h,
              ih (stepIdx := stepIdx + 1)
                (tailRegisterTemporalBoundFrom_of_registerTemporalBoundFrom h)⟩

theorem registerAdjacentTraceBound_of_registerTemporalBound
  {Addr : Type*}
  {regVal : RegisterValueTimeline}
  {trace : List (ExecutionFrame Addr)}
  (h : RegisterTemporalBound regVal trace) :
  RegisterAdjacentTraceBound trace := by
  exact registerAdjacentTraceBound_of_registerTemporalBoundFrom h

end Nightstream.Chip8.RegisterTimeline

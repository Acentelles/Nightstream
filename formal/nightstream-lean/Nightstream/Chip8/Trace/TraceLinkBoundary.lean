import Nightstream.Chip8.Execution.ExecutionSemantics

namespace Nightstream.Chip8.TraceLinkBoundary

open Nightstream.Chip8
open Nightstream.Chip8.ExecutionSemantics

abbrev F := ExecutionSemantics.F
abbrev MachineState := ExecutionSemantics.MachineState
abbrev ExecutionFrame := ExecutionSemantics.ExecutionFrame
abbrev StateEq := ExecutionSemantics.StateEq
abbrev RegisterIndexBound := ExecutionSemantics.RegisterIndexBound
abbrev RamAddressBound := ExecutionSemantics.RamAddressBound

def AdjacentStateLink
  {Addr : Type*}
  (current next : ExecutionFrame Addr) : Prop :=
  current.post.pc = next.pre.pc ∧
    current.post.i = next.pre.i ∧
    (∀ idx, RegisterIndexBound idx → current.post.v idx = next.pre.v idx) ∧
    (∀ addr, RamAddressBound addr → current.post.ram addr = next.pre.ram addr)

def TraceLinkBound
  {Addr : Type*}
  : List (ExecutionFrame Addr) → Prop
  | [] => True
  | [_] => True
  | current :: next :: rest =>
      AdjacentStateLink current next ∧
        TraceLinkBound (next :: rest)

theorem stateEq_of_adjacentStateLink
  {Addr : Type*}
  {current next : ExecutionFrame Addr}
  (h : AdjacentStateLink current next) :
  StateEq current.post next.pre := by
  exact h

theorem adjacentStateLink_of_stateEq
  {Addr : Type*}
  {current next : ExecutionFrame Addr}
  (h : StateEq current.post next.pre) :
  AdjacentStateLink current next := by
  exact h

theorem executionLinked_of_traceLinkBound
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)}
  (h : TraceLinkBound trace) :
  ExecutionLinked trace := by
  induction trace with
  | nil =>
      simp [ExecutionLinked]
  | cons current rest ih =>
      cases rest with
      | nil =>
          simp [ExecutionLinked]
      | cons next tail =>
          rcases h with ⟨hHead, hTail⟩
          exact ⟨stateEq_of_adjacentStateLink hHead, ih hTail⟩

theorem traceLinkBound_of_executionLinked
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)}
  (h : ExecutionLinked trace) :
  TraceLinkBound trace := by
  induction trace with
  | nil =>
      simp [TraceLinkBound]
  | cons current rest ih =>
      cases rest with
      | nil =>
          simp [TraceLinkBound]
      | cons next tail =>
          rcases h with ⟨hHead, hTail⟩
          exact ⟨adjacentStateLink_of_stateEq hHead, ih hTail⟩

theorem traceLinkBound_iff_executionLinked
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)} :
  TraceLinkBound trace ↔ ExecutionLinked trace := by
  constructor
  · exact executionLinked_of_traceLinkBound
  · exact traceLinkBound_of_executionLinked

theorem headAdjacentStateLink_of_traceLinkBound
  {Addr : Type*}
  {current next : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : TraceLinkBound (current :: next :: rest)) :
  AdjacentStateLink current next := by
  exact h.1

theorem tailTraceLinkBound_of_traceLinkBound
  {Addr : Type*}
  {current next : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : TraceLinkBound (current :: next :: rest)) :
  TraceLinkBound (next :: rest) := by
  exact h.2

end Nightstream.Chip8.TraceLinkBoundary

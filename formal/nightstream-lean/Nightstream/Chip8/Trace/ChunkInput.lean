import Nightstream.Chip8.Execution.ExecutionSemantics

namespace Nightstream.Chip8.ChunkInput

open Nightstream.Chip8
open Nightstream.Chip8.ExecutionSemantics

abbrev InitialState := ExecutionSemantics.InitialState
abbrev ExecutionFrame := ExecutionSemantics.ExecutionFrame

def SimpleKernelChunkInput
  {Addr : Type*}
  (init : InitialState)
  (semanticRows : Nat)
  (trace : List (ExecutionFrame Addr)) : Prop :=
  0 < semanticRows ∧
    trace.length = semanticRows ∧
    match trace with
    | [] => False
    | first :: _ => InitialStateMatches init first.pre

theorem semanticRows_pos_of_simpleKernelChunkInput
  {Addr : Type*}
  {init : InitialState}
  {semanticRows : Nat}
  {trace : List (ExecutionFrame Addr)}
  (h : SimpleKernelChunkInput init semanticRows trace) :
  0 < semanticRows := by
  exact h.1

theorem traceLength_of_simpleKernelChunkInput
  {Addr : Type*}
  {init : InitialState}
  {semanticRows : Nat}
  {trace : List (ExecutionFrame Addr)}
  (h : SimpleKernelChunkInput init semanticRows trace) :
  trace.length = semanticRows := by
  exact h.2.1

theorem trace_nonempty_of_simpleKernelChunkInput
  {Addr : Type*}
  {init : InitialState}
  {semanticRows : Nat}
  {trace : List (ExecutionFrame Addr)}
  (h : SimpleKernelChunkInput init semanticRows trace) :
  trace ≠ [] := by
  intro hNil
  have hLen : trace.length = semanticRows := h.2.1
  have hPos : 0 < semanticRows := h.1
  simp [hNil] at hLen
  omega

theorem headInitialStateMatches_of_simpleKernelChunkInput
  {Addr : Type*}
  {init : InitialState}
  {semanticRows : Nat}
  {first : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h :
    SimpleKernelChunkInput init semanticRows (first :: rest)) :
  InitialStateMatches init first.pre := by
  exact h.2.2

end Nightstream.Chip8.ChunkInput

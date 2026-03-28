import Nightstream.Chip8.Trace.TraceLinkBoundary

namespace Nightstream.Chip8.MainLaneTraceBoundary

open Nightstream.Chip8
open Nightstream.Chip8.ExecutionSemantics
open Nightstream.Chip8.TraceLinkBoundary

abbrev F := ExecutionSemantics.F
abbrev ExecutionFrame := ExecutionSemantics.ExecutionFrame

def FrameRoutingBound
  {Addr : Type*}
  (frame : ExecutionFrame Addr) : Prop :=
  Nightstream.Chip8.chip8RoutingSound frame.row

def TraceRoutingBound
  {Addr : Type*}
  (trace : List (ExecutionFrame Addr)) : Prop :=
  List.Forall FrameRoutingBound trace

def MainLaneTraceBound
  {Addr : Type*}
  (trace : List (ExecutionFrame Addr)) : Prop :=
  TraceRoutingBound trace ∧ TraceLinkBound trace

theorem traceRouting_of_mainLaneTrace
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)}
  (h : MainLaneTraceBound trace) :
  TraceRoutingBound trace := by
  exact h.1

theorem executionLinked_of_mainLaneTrace
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)}
  (h : MainLaneTraceBound trace) :
  ExecutionLinked trace := by
  exact executionLinked_of_traceLinkBound h.2

theorem headFrameRouting_of_traceRouting
  {Addr : Type*}
  {frame : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : TraceRoutingBound (frame :: rest)) :
  FrameRoutingBound frame := by
  cases rest with
  | nil =>
      simpa [TraceRoutingBound] using h
  | cons next tail =>
      simpa [TraceRoutingBound] using h.1

theorem tailTraceRouting_of_traceRouting
  {Addr : Type*}
  {frame : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : TraceRoutingBound (frame :: rest)) :
  TraceRoutingBound rest := by
  cases rest with
  | nil =>
      simp [TraceRoutingBound]
  | cons next tail =>
      simpa [TraceRoutingBound] using h.2

theorem frameRouting_of_traceRouting
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)}
  (h : TraceRoutingBound trace)
  {frame : ExecutionFrame Addr}
  (hMem : frame ∈ trace) :
  FrameRoutingBound frame := by
  exact (List.forall_iff_forall_mem.mp h) frame hMem

end Nightstream.Chip8.MainLaneTraceBoundary

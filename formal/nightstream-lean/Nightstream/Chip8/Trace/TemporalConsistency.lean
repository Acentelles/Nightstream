import Nightstream.Chip8.Trace.RegisterTimeline
import Nightstream.Chip8.Trace.RamTimeline
import Nightstream.Chip8.Stage3.PcContinuityBridge
import Nightstream.Chip8.Trace.TraceLinkBoundary

/-!
Owns the component-wise temporal consistency surface for one CHIP-8 execution
trace and the extensional bridge from that surface to the named whole-trace
link contract.
-/

namespace Nightstream.Chip8.TemporalConsistency

open Nightstream.Chip8
open Nightstream.Chip8.ExecutionSemantics
open Nightstream.Chip8.RegisterTimeline
open Nightstream.Chip8.RamTimeline
open Nightstream.Chip8.PcContinuityBridge
open Nightstream.Chip8.TraceLinkBoundary

abbrev F := ExecutionSemantics.F
abbrev MachineState := ExecutionSemantics.MachineState
abbrev ExecutionFrame := ExecutionSemantics.ExecutionFrame
abbrev RegisterValueTimeline := RegisterTimeline.RegisterValueTimeline
abbrev RamValueTimeline := RamTimeline.RamValueTimeline

structure TemporalTraceBoundFrom
  {Addr : Type*}
  (regVal : RegisterValueTimeline)
  (ramVal : RamValueTimeline)
  (stepIdx : Nat)
  (trace : List (ExecutionFrame Addr)) where
  registers : RegisterTemporalBoundFrom regVal stepIdx trace
  ram : RamTemporalBoundFrom ramVal stepIdx trace
  pc : PcTemporalBound trace

abbrev TemporalTraceBound
  {Addr : Type*}
  (regVal : RegisterValueTimeline)
  (ramVal : RamValueTimeline)
  (trace : List (ExecutionFrame Addr)) : Prop :=
  TemporalTraceBoundFrom regVal ramVal 0 trace

structure TemporalInstantiation
  {Addr : Type*}
  (trace : List (ExecutionFrame Addr)) where
  regVal : RegisterValueTimeline
  ramVal : RamValueTimeline
  registers : RegisterTemporalBound regVal trace
  ram : RamTemporalBound ramVal trace
  pc : PcTemporalBound trace

abbrev TemporalInstantiationBound
  {Addr : Type*}
  (trace : List (ExecutionFrame Addr)) : Prop :=
  Nonempty (TemporalInstantiation trace)

theorem temporalTraceBound_of_instantiation
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)}
  (h : TemporalInstantiation trace) :
  TemporalTraceBound h.regVal h.ramVal trace := by
  exact
    { registers := h.registers
      ram := h.ram
      pc := h.pc }

theorem adjacentStateLink_of_temporalTraceBound
  {Addr : Type*}
  {regVal : RegisterValueTimeline}
  {ramVal : RamValueTimeline}
  {stepIdx : Nat}
  {current next : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : TemporalTraceBoundFrom regVal ramVal stepIdx (current :: next :: rest)) :
  AdjacentStateLink current next := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · exact headPcTemporal_of_pcTemporalBound h.pc
  · exact (registerAdjacentBound_of_registerTemporalBoundFrom h.registers).1
  · exact (registerAdjacentBound_of_registerTemporalBoundFrom h.registers).2
  · exact ramAdjacentBound_of_ramTemporalBoundFrom h.ram

theorem tailTemporalTraceBound_of_temporalTraceBound
  {Addr : Type*}
  {regVal : RegisterValueTimeline}
  {ramVal : RamValueTimeline}
  {stepIdx : Nat}
  {current next : ExecutionFrame Addr}
  {rest : List (ExecutionFrame Addr)}
  (h : TemporalTraceBoundFrom regVal ramVal stepIdx (current :: next :: rest)) :
  TemporalTraceBoundFrom regVal ramVal (stepIdx + 1) (next :: rest) := by
  exact
    { registers := tailRegisterTemporalBoundFrom_of_registerTemporalBoundFrom h.registers
      ram := tailRamTemporalBoundFrom_of_ramTemporalBoundFrom h.ram
      pc := tailPcTemporal_of_pcTemporalBound h.pc }

theorem traceLinkBound_of_temporalTraceBound
  {Addr : Type*}
  {regVal : RegisterValueTimeline}
  {ramVal : RamValueTimeline}
  {stepIdx : Nat}
  {trace : List (ExecutionFrame Addr)}
  (h : TemporalTraceBoundFrom regVal ramVal stepIdx trace) :
  TraceLinkBound trace := by
  induction trace generalizing stepIdx with
  | nil =>
      simp [TraceLinkBound]
  | cons current rest ih =>
      cases rest with
      | nil =>
          simp [TraceLinkBound]
      | cons next tail =>
          exact
            ⟨adjacentStateLink_of_temporalTraceBound h,
              ih (tailTemporalTraceBound_of_temporalTraceBound h)⟩

theorem traceLinkBound_of_temporalInstantiation
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)}
  (h : TemporalInstantiationBound trace) :
  TraceLinkBound trace := by
  rcases h with ⟨inst⟩
  exact traceLinkBound_of_temporalTraceBound
    (temporalTraceBound_of_instantiation inst)

end Nightstream.Chip8.TemporalConsistency

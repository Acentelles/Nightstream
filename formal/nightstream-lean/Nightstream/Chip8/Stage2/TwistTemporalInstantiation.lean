import Nightstream.Chip8.Trace.TemporalConsistency

/-!
Owns the Stage-2 temporal support bundle for one CHIP-8 execution trace. This
file names the chunk-global Stage-2 temporal context, derives the concrete
register/I and RAM timeline witness bundle from that context, and proves that,
once the explicit Stage-3 `pc` bridge is supplied, they yield the generic
temporal instantiation used by whole-trace linking. It does not derive the
Stage-2 context from authenticated evidence.
-/

namespace Nightstream.Chip8.TwistTemporalInstantiation

open Nightstream.Chip8
open Nightstream.Chip8.ExecutionSemantics
open Nightstream.Chip8.RegisterTimeline
open Nightstream.Chip8.RamTimeline
open Nightstream.Chip8.PcContinuityBridge
open Nightstream.Chip8.TemporalConsistency

abbrev F := ExecutionSemantics.F
abbrev MachineState := ExecutionSemantics.MachineState
abbrev ExecutionFrame := ExecutionSemantics.ExecutionFrame
abbrev RegisterValueTimeline := RegisterTimeline.RegisterValueTimeline
abbrev RamValueTimeline := RamTimeline.RamValueTimeline
abbrev RegisterAdjacentTraceBound
  {Addr : Type*} :=
  RegisterTimeline.RegisterAdjacentTraceBound (Addr := Addr)
abbrev RamAdjacentTraceBound
  {Addr : Type*} :=
  RamTimeline.RamAdjacentTraceBound (Addr := Addr)

structure Stage2TemporalContext
  {Addr : Type*}
  (trace : List (ExecutionFrame Addr)) where
  regVal : RegisterValueTimeline
  ramVal : RamValueTimeline
  registers : RegisterTemporalBound regVal trace
  ram : RamTemporalBound ramVal trace

abbrev Stage2TemporalContextBound
  {Addr : Type*}
  (trace : List (ExecutionFrame Addr)) : Prop :=
  Nonempty (Stage2TemporalContext trace)

abbrev Stage2TemporalInstantiation
  {Addr : Type*}
  (trace : List (ExecutionFrame Addr)) :=
  Stage2TemporalContext trace

abbrev Stage2TemporalInstantiationBound
  {Addr : Type*}
  (trace : List (ExecutionFrame Addr)) : Prop :=
  Stage2TemporalContextBound trace

def stage2TemporalInstantiation_of_context
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)}
  (hCtx : Stage2TemporalContext trace) :
  Stage2TemporalInstantiation trace :=
  hCtx

theorem stage2TemporalInstantiationBound_of_context
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)}
  (hCtx : Stage2TemporalContextBound trace) :
  Stage2TemporalInstantiationBound trace := by
  exact hCtx

theorem stage2TemporalContextBound_of_adjacentTraceBounds
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)}
  (hRegisters : RegisterAdjacentTraceBound trace)
  (hRam : RamAdjacentTraceBound trace) :
  Stage2TemporalContextBound trace := by
  refine
    ⟨{ regVal := registerTimelineOfTrace trace
       ramVal := ramTimelineOfTrace trace
       registers := registerTemporalBound_of_adjacentTraceBound hRegisters
       ram := ramTemporalBound_of_adjacentTraceBound hRam }⟩

theorem adjacentTraceBounds_of_stage2TemporalContextBound
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)}
  (hCtx : Stage2TemporalContextBound trace) :
  RegisterAdjacentTraceBound trace ∧ RamAdjacentTraceBound trace := by
  rcases hCtx with ⟨ctx⟩
  exact
    ⟨registerAdjacentTraceBound_of_registerTemporalBound ctx.registers,
      ramAdjacentTraceBound_of_ramTemporalBound ctx.ram⟩

def temporalInstantiation_of_stage2_and_pc
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)}
  (hStage2 : Stage2TemporalInstantiation trace)
  (hPc : PcTemporalBound trace) :
  TemporalInstantiation trace := by
  exact
    { regVal := hStage2.regVal
      ramVal := hStage2.ramVal
      registers := hStage2.registers
      ram := hStage2.ram
      pc := hPc }

theorem temporalInstantiationBound_of_stage2_and_pc
  {Addr : Type*}
  {trace : List (ExecutionFrame Addr)}
  (hStage2 : Stage2TemporalInstantiationBound trace)
  (hPc : PcTemporalBound trace) :
  TemporalInstantiationBound trace := by
  rcases hStage2 with ⟨stage2⟩
  exact ⟨temporalInstantiation_of_stage2_and_pc stage2 hPc⟩

theorem temporalInstantiationBound_of_stage2_and_bridge
  {Addr : Type*}
  {rom : Program}
  {σ : ExternalSchedule}
  {trace : List (ExecutionFrame Addr)}
  (hFrames : List.Forall (StepComposition.ExecutionFrameBound rom σ) trace)
  (hWf :
    List.Forall
      (fun frame =>
        StepComposition.StateWellFormed frame.pre ∧
          StepComposition.StateWellFormed frame.post)
      trace)
  (hStage2 : Stage2TemporalInstantiationBound trace)
  (hBridge : PcAdjacentBridge trace) :
  TemporalInstantiationBound trace := by
  exact temporalInstantiationBound_of_stage2_and_pc hStage2
    (pcTemporalBound_of_adjacentBridge hFrames hWf hBridge)

end Nightstream.Chip8.TwistTemporalInstantiation

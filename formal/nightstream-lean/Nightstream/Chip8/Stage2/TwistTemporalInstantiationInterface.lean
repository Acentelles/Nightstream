import Nightstream.Chip8.Stage2.TwistTemporalInstantiation

namespace Nightstream.Chip8

namespace TwistTemporalInstantiationInterface

-- ── Types ──

abbrev F := Nightstream.Chip8.TwistTemporalInstantiation.F
abbrev MachineState := Nightstream.Chip8.TwistTemporalInstantiation.MachineState
abbrev ExecutionFrame := Nightstream.Chip8.TwistTemporalInstantiation.ExecutionFrame
abbrev RegisterValueTimeline :=
  Nightstream.Chip8.TwistTemporalInstantiation.RegisterValueTimeline
abbrev RamValueTimeline :=
  Nightstream.Chip8.TwistTemporalInstantiation.RamValueTimeline

-- ── Structures ──

abbrev Stage2TemporalContext :=
  @Nightstream.Chip8.TwistTemporalInstantiation.Stage2TemporalContext
abbrev Stage2TemporalContextBound :=
  @Nightstream.Chip8.TwistTemporalInstantiation.Stage2TemporalContextBound
abbrev Stage2TemporalInstantiation :=
  @Nightstream.Chip8.TwistTemporalInstantiation.Stage2TemporalInstantiation
abbrev Stage2TemporalInstantiationBound :=
  @Nightstream.Chip8.TwistTemporalInstantiation.Stage2TemporalInstantiationBound

-- ── Theorems: Instantiation from Context ──

abbrev stage2TemporalInstantiation_of_context :=
  @Nightstream.Chip8.TwistTemporalInstantiation.stage2TemporalInstantiation_of_context
abbrev stage2TemporalInstantiationBound_of_context :=
  @Nightstream.Chip8.TwistTemporalInstantiation.stage2TemporalInstantiationBound_of_context

-- ── Theorems: Trace Bound Bridges ──

abbrev stage2TemporalContextBound_of_adjacentTraceBounds :=
  @Nightstream.Chip8.TwistTemporalInstantiation.stage2TemporalContextBound_of_adjacentTraceBounds
abbrev adjacentTraceBounds_of_stage2TemporalContextBound :=
  @Nightstream.Chip8.TwistTemporalInstantiation.adjacentTraceBounds_of_stage2TemporalContextBound
abbrev temporalInstantiation_of_stage2_and_pc :=
  @Nightstream.Chip8.TwistTemporalInstantiation.temporalInstantiation_of_stage2_and_pc
abbrev temporalInstantiationBound_of_stage2_and_pc :=
  @Nightstream.Chip8.TwistTemporalInstantiation.temporalInstantiationBound_of_stage2_and_pc
abbrev temporalInstantiationBound_of_stage2_and_bridge :=
  @Nightstream.Chip8.TwistTemporalInstantiation.temporalInstantiationBound_of_stage2_and_bridge

end TwistTemporalInstantiationInterface

end Nightstream.Chip8

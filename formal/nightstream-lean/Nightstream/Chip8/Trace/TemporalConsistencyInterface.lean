import Nightstream.Chip8.Trace.TemporalConsistency

namespace Nightstream.Chip8

namespace TemporalConsistencyInterface

abbrev F := Nightstream.Chip8.TemporalConsistency.F
abbrev MachineState := Nightstream.Chip8.TemporalConsistency.MachineState
abbrev ExecutionFrame := Nightstream.Chip8.TemporalConsistency.ExecutionFrame
abbrev RegisterValueTimeline := Nightstream.Chip8.TemporalConsistency.RegisterValueTimeline
abbrev RamValueTimeline := Nightstream.Chip8.TemporalConsistency.RamValueTimeline
abbrev PcTemporalBound := @Nightstream.Chip8.PcContinuityBridge.PcTemporalBound
abbrev TemporalTraceBound := @Nightstream.Chip8.TemporalConsistency.TemporalTraceBound
abbrev TemporalInstantiation :=
  @Nightstream.Chip8.TemporalConsistency.TemporalInstantiation
abbrev TemporalInstantiationBound :=
  @Nightstream.Chip8.TemporalConsistency.TemporalInstantiationBound
abbrev temporalTraceBound_of_instantiation :=
  @Nightstream.Chip8.TemporalConsistency.temporalTraceBound_of_instantiation
abbrev headPcTemporal_of_pcTemporalBound :=
  @Nightstream.Chip8.PcContinuityBridge.headPcTemporal_of_pcTemporalBound
abbrev tailPcTemporal_of_pcTemporalBound :=
  @Nightstream.Chip8.PcContinuityBridge.tailPcTemporal_of_pcTemporalBound
abbrev adjacentStateLink_of_temporalTraceBound :=
  @Nightstream.Chip8.TemporalConsistency.adjacentStateLink_of_temporalTraceBound
abbrev tailTemporalTraceBound_of_temporalTraceBound :=
  @Nightstream.Chip8.TemporalConsistency.tailTemporalTraceBound_of_temporalTraceBound
abbrev traceLinkBound_of_temporalTraceBound :=
  @Nightstream.Chip8.TemporalConsistency.traceLinkBound_of_temporalTraceBound
abbrev traceLinkBound_of_temporalInstantiation :=
  @Nightstream.Chip8.TemporalConsistency.traceLinkBound_of_temporalInstantiation

end TemporalConsistencyInterface

end Nightstream.Chip8

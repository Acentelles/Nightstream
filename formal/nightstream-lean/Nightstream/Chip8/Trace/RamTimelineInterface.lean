import Nightstream.Chip8.Trace.RamTimeline

namespace Nightstream.Chip8

namespace RamTimelineInterface

abbrev F := Nightstream.Chip8.RamTimeline.F
abbrev MachineState := Nightstream.Chip8.RamTimeline.MachineState
abbrev ExecutionFrame := Nightstream.Chip8.RamTimeline.ExecutionFrame
abbrev RamValueTimeline := Nightstream.Chip8.RamTimeline.RamValueTimeline
abbrev RamAddressBound := Nightstream.Chip8.RamTimeline.RamAddressBound
abbrev RamAdjacentTraceBound := @Nightstream.Chip8.RamTimeline.RamAdjacentTraceBound
abbrev ramTimelineOfTraceFrom := @Nightstream.Chip8.RamTimeline.ramTimelineOfTraceFrom
abbrev ramTimelineOfTrace := @Nightstream.Chip8.RamTimeline.ramTimelineOfTrace
abbrev RamAdjacentBound := @Nightstream.Chip8.RamTimeline.RamAdjacentBound
abbrev RamTemporalBoundFrom := @Nightstream.Chip8.RamTimeline.RamTemporalBoundFrom
abbrev RamTemporalBound := @Nightstream.Chip8.RamTimeline.RamTemporalBound
abbrev headRamPreBound_of_ramTemporalBoundFrom :=
  @Nightstream.Chip8.RamTimeline.headRamPreBound_of_ramTemporalBoundFrom
abbrev ramAdjacentBound_of_ramTemporalBoundFrom :=
  @Nightstream.Chip8.RamTimeline.ramAdjacentBound_of_ramTemporalBoundFrom
abbrev tailRamTemporalBoundFrom_of_ramTemporalBoundFrom :=
  @Nightstream.Chip8.RamTimeline.tailRamTemporalBoundFrom_of_ramTemporalBoundFrom
abbrev ramAdjacentBound_of_ramTemporalBound :=
  @Nightstream.Chip8.RamTimeline.ramAdjacentBound_of_ramTemporalBound
abbrev tailRamTemporalBound_of_ramTemporalBound :=
  @Nightstream.Chip8.RamTimeline.tailRamTemporalBound_of_ramTemporalBound
abbrev ramTemporalBoundFrom_of_adjacentTraceBound :=
  @Nightstream.Chip8.RamTimeline.ramTemporalBoundFrom_of_adjacentTraceBound
abbrev ramTemporalBound_of_adjacentTraceBound :=
  @Nightstream.Chip8.RamTimeline.ramTemporalBound_of_adjacentTraceBound
abbrev ramAdjacentTraceBound_of_ramTemporalBoundFrom :=
  @Nightstream.Chip8.RamTimeline.ramAdjacentTraceBound_of_ramTemporalBoundFrom
abbrev ramAdjacentTraceBound_of_ramTemporalBound :=
  @Nightstream.Chip8.RamTimeline.ramAdjacentTraceBound_of_ramTemporalBound

end RamTimelineInterface

end Nightstream.Chip8

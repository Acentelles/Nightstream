import Nightstream.Chip8.Trace.TraceLinkBoundary

namespace Nightstream.Chip8

namespace TraceLinkBoundaryInterface

-- ── Types ──

abbrev F := Nightstream.Chip8.TraceLinkBoundary.F
abbrev MachineState := Nightstream.Chip8.TraceLinkBoundary.MachineState
abbrev ExecutionFrame := Nightstream.Chip8.TraceLinkBoundary.ExecutionFrame

-- ── Definitions ──

abbrev StateEq := Nightstream.Chip8.TraceLinkBoundary.StateEq
abbrev RegisterIndexBound := Nightstream.Chip8.TraceLinkBoundary.RegisterIndexBound
abbrev RamAddressBound := Nightstream.Chip8.TraceLinkBoundary.RamAddressBound

-- ── Bounds ──

abbrev AdjacentStateLink := @Nightstream.Chip8.TraceLinkBoundary.AdjacentStateLink
abbrev TraceLinkBound := @Nightstream.Chip8.TraceLinkBoundary.TraceLinkBound

-- ── Theorems ──

abbrev stateEq_of_adjacentStateLink :=
  @Nightstream.Chip8.TraceLinkBoundary.stateEq_of_adjacentStateLink
abbrev adjacentStateLink_of_stateEq :=
  @Nightstream.Chip8.TraceLinkBoundary.adjacentStateLink_of_stateEq
abbrev executionLinked_of_traceLinkBound :=
  @Nightstream.Chip8.TraceLinkBoundary.executionLinked_of_traceLinkBound
abbrev traceLinkBound_of_executionLinked :=
  @Nightstream.Chip8.TraceLinkBoundary.traceLinkBound_of_executionLinked
abbrev traceLinkBound_iff_executionLinked :=
  @Nightstream.Chip8.TraceLinkBoundary.traceLinkBound_iff_executionLinked
abbrev headAdjacentStateLink_of_traceLinkBound :=
  @Nightstream.Chip8.TraceLinkBoundary.headAdjacentStateLink_of_traceLinkBound
abbrev tailTraceLinkBound_of_traceLinkBound :=
  @Nightstream.Chip8.TraceLinkBoundary.tailTraceLinkBound_of_traceLinkBound

end TraceLinkBoundaryInterface

end Nightstream.Chip8

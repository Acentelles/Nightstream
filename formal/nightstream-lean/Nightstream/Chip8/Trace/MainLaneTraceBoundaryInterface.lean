import Nightstream.Chip8.Trace.MainLaneTraceBoundary

namespace Nightstream.Chip8

namespace MainLaneTraceBoundaryInterface

abbrev F := Nightstream.Chip8.MainLaneTraceBoundary.F
abbrev ExecutionFrame := Nightstream.Chip8.MainLaneTraceBoundary.ExecutionFrame
abbrev FrameRoutingBound := @Nightstream.Chip8.MainLaneTraceBoundary.FrameRoutingBound
abbrev TraceRoutingBound := @Nightstream.Chip8.MainLaneTraceBoundary.TraceRoutingBound
abbrev MainLaneTraceBound := @Nightstream.Chip8.MainLaneTraceBoundary.MainLaneTraceBound
abbrev traceRouting_of_mainLaneTrace :=
  @Nightstream.Chip8.MainLaneTraceBoundary.traceRouting_of_mainLaneTrace
abbrev executionLinked_of_mainLaneTrace :=
  @Nightstream.Chip8.MainLaneTraceBoundary.executionLinked_of_mainLaneTrace
abbrev headFrameRouting_of_traceRouting :=
  @Nightstream.Chip8.MainLaneTraceBoundary.headFrameRouting_of_traceRouting
abbrev tailTraceRouting_of_traceRouting :=
  @Nightstream.Chip8.MainLaneTraceBoundary.tailTraceRouting_of_traceRouting
abbrev frameRouting_of_traceRouting :=
  @Nightstream.Chip8.MainLaneTraceBoundary.frameRouting_of_traceRouting

end MainLaneTraceBoundaryInterface

end Nightstream.Chip8

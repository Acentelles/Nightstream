import Nightstream.Chip8.Trace.ChunkInput

namespace Nightstream.Chip8

namespace ChunkInputInterface

abbrev InitialState := Nightstream.Chip8.ChunkInput.InitialState
abbrev ExecutionFrame := Nightstream.Chip8.ChunkInput.ExecutionFrame
abbrev SimpleKernelChunkInput := @Nightstream.Chip8.ChunkInput.SimpleKernelChunkInput
abbrev semanticRows_pos_of_simpleKernelChunkInput :=
  @Nightstream.Chip8.ChunkInput.semanticRows_pos_of_simpleKernelChunkInput
abbrev traceLength_of_simpleKernelChunkInput :=
  @Nightstream.Chip8.ChunkInput.traceLength_of_simpleKernelChunkInput
abbrev trace_nonempty_of_simpleKernelChunkInput :=
  @Nightstream.Chip8.ChunkInput.trace_nonempty_of_simpleKernelChunkInput
abbrev headInitialStateMatches_of_simpleKernelChunkInput :=
  @Nightstream.Chip8.ChunkInput.headInitialStateMatches_of_simpleKernelChunkInput

end ChunkInputInterface

end Nightstream.Chip8

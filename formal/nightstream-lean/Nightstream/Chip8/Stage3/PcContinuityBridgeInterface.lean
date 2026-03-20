import Nightstream.Chip8.Stage3.PcContinuityBridge

namespace Nightstream.Chip8

namespace PcContinuityBridgeInterface

abbrev F := Nightstream.Chip8.PcContinuityBridge.F
abbrev MachineState := Nightstream.Chip8.PcContinuityBridge.MachineState
abbrev ExecutionFrame := Nightstream.Chip8.PcContinuityBridge.ExecutionFrame
abbrev PcTemporalBound := @Nightstream.Chip8.PcContinuityBridge.PcTemporalBound
abbrev ShiftPcMatchesCurrentPcNext :=
  @Nightstream.Chip8.PcContinuityBridge.ShiftPcMatchesCurrentPcNext
abbrev ShiftPcMatchesNextRow :=
  @Nightstream.Chip8.PcContinuityBridge.ShiftPcMatchesNextRow
abbrev PcAdjacentBridgeFrom :=
  @Nightstream.Chip8.PcContinuityBridge.PcAdjacentBridgeFrom
abbrev PcAdjacentBridge := @Nightstream.Chip8.PcContinuityBridge.PcAdjacentBridge
abbrev headPcTemporal_of_pcTemporalBound :=
  @Nightstream.Chip8.PcContinuityBridge.headPcTemporal_of_pcTemporalBound
abbrev tailPcTemporal_of_pcTemporalBound :=
  @Nightstream.Chip8.PcContinuityBridge.tailPcTemporal_of_pcTemporalBound
abbrev adjacentPc_of_bridge :=
  @Nightstream.Chip8.PcContinuityBridge.adjacentPc_of_bridge
abbrev pcTemporalBound_of_adjacentBridgeFrom :=
  @Nightstream.Chip8.PcContinuityBridge.pcTemporalBound_of_adjacentBridgeFrom
abbrev pcTemporalBound_of_adjacentBridge :=
  @Nightstream.Chip8.PcContinuityBridge.pcTemporalBound_of_adjacentBridge

end PcContinuityBridgeInterface

end Nightstream.Chip8

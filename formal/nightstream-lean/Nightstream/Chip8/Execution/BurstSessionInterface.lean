import Nightstream.Chip8.Execution.BurstSession

namespace Nightstream.Chip8

namespace BurstSessionInterface

abbrev MachineState := Nightstream.Chip8.BurstSession.MachineState
abbrev ExternalSchedule := Nightstream.Chip8.BurstSession.ExternalSchedule
abbrev ExecutionFrame := Nightstream.Chip8.BurstSession.ExecutionFrame
abbrev RamPreservedExcept := @Nightstream.Chip8.BurstSession.RamPreservedExcept
abbrev BurstMicrostepCorrect := @Nightstream.Chip8.BurstSession.BurstMicrostepCorrect
abbrev BurstSession := @Nightstream.Chip8.BurstSession.BurstSession
abbrev BurstAnchored := @Nightstream.Chip8.BurstSession.BurstAnchored
abbrev BurstChained := @Nightstream.Chip8.BurstSession.BurstChained
abbrev BurstStepDerivedFrom := @Nightstream.Chip8.BurstSession.BurstStepDerivedFrom
abbrev BurstDerivedFrom := @Nightstream.Chip8.BurstSession.BurstDerivedFrom
abbrev BurstCoversPrefix := @Nightstream.Chip8.BurstSession.BurstCoversPrefix
abbrev BurstCursorMonotone := @Nightstream.Chip8.BurstSession.BurstCursorMonotone
abbrev BurstFrameCorrect := @Nightstream.Chip8.BurstSession.BurstFrameCorrect
abbrev BurstPcStable := @Nightstream.Chip8.BurstSession.BurstPcStable
abbrev BurstFramesBound := @Nightstream.Chip8.BurstSession.BurstFramesBound
abbrev BurstContinuityBound := @Nightstream.Chip8.BurstSession.BurstContinuityBound
abbrev BurstScheduleCorrect := @Nightstream.Chip8.BurstSession.BurstScheduleCorrect

abbrev instructionCorrect_of_burstSession :=
  @Nightstream.Chip8.BurstSession.instructionCorrect_of_burstSession

end BurstSessionInterface

end Nightstream.Chip8

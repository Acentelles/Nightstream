import Nightstream.Chip8.Execution.ExecutionSemantics

namespace Nightstream.Chip8

namespace ExecutionSemanticsInterface

abbrev F := Nightstream.Chip8.ExecutionSemantics.F
abbrev MachineState := Nightstream.Chip8.ExecutionSemantics.MachineState
abbrev InitialState := Nightstream.Chip8.ExecutionSemantics.InitialState
abbrev ExternalSchedule := Nightstream.Chip8.ExecutionSemantics.ExternalSchedule
abbrev RegisterIndexBound := @Nightstream.Chip8.ExecutionSemantics.RegisterIndexBound
abbrev RamAddressBound := @Nightstream.Chip8.ExecutionSemantics.RamAddressBound
abbrev StateEq := @Nightstream.Chip8.ExecutionSemantics.StateEq
abbrev byteAdd := @Nightstream.Chip8.ExecutionSemantics.byteAdd
abbrev skipEqBit := @Nightstream.Chip8.ExecutionSemantics.skipEqBit
abbrev RegistersPreserved := @Nightstream.Chip8.ExecutionSemantics.RegistersPreserved
abbrev RegistersPreservedExcept := @Nightstream.Chip8.ExecutionSemantics.RegistersPreservedExcept
abbrev RegistersPreservedAbove := @Nightstream.Chip8.ExecutionSemantics.RegistersPreservedAbove
abbrev RamPreserved := @Nightstream.Chip8.ExecutionSemantics.RamPreserved
abbrev RamPrefixStored := @Nightstream.Chip8.ExecutionSemantics.RamPrefixStored
abbrev RamPreservedOutsidePrefix := @Nightstream.Chip8.ExecutionSemantics.RamPreservedOutsidePrefix
abbrev RegistersLoadedPrefix := @Nightstream.Chip8.ExecutionSemantics.RegistersLoadedPrefix
abbrev ContinuityRowBound := @Nightstream.Chip8.ExecutionSemantics.ContinuityRowBound
abbrev MicrostepCorrect := @Nightstream.Chip8.ExecutionSemantics.MicrostepCorrect
abbrev InstructionCorrect := @Nightstream.Chip8.ExecutionSemantics.InstructionCorrect
abbrev ExecutionFrame := Nightstream.Chip8.ExecutionSemantics.ExecutionFrame
abbrev ExecutionLinked := @Nightstream.Chip8.ExecutionSemantics.ExecutionLinked
abbrev InitialStateMatches := @Nightstream.Chip8.ExecutionSemantics.InitialStateMatches
abbrev StartBoundaryFrame := @Nightstream.Chip8.ExecutionSemantics.StartBoundaryFrame
abbrev FinalBoundaryFrame := @Nightstream.Chip8.ExecutionSemantics.FinalBoundaryFrame
abbrev BoundaryTraceBound := @Nightstream.Chip8.ExecutionSemantics.BoundaryTraceBound
abbrev ExecutionFrameBound := @Nightstream.Chip8.ExecutionSemantics.ExecutionFrameBound
abbrev ContinuityTraceBound := @Nightstream.Chip8.ExecutionSemantics.ContinuityTraceBound
abbrev PreparedStepTraceBound := @Nightstream.Chip8.ExecutionSemantics.PreparedStepTraceBound
abbrev ExecutionCorrect := @Nightstream.Chip8.ExecutionSemantics.ExecutionCorrect
abbrev FinalState := @Nightstream.Chip8.ExecutionSemantics.FinalState
abbrev GoalPredicate := Nightstream.Chip8.ExecutionSemantics.GoalPredicate

abbrev executionFrameBound_witnessBinds :=
  @Nightstream.Chip8.ExecutionSemantics.executionFrameBound_witnessBinds
abbrev executionFrameBound_microstepCorrect :=
  @Nightstream.Chip8.ExecutionSemantics.executionFrameBound_microstepCorrect
abbrev instructionCorrect_of_nonBurstMicrostep :=
  @Nightstream.Chip8.ExecutionSemantics.instructionCorrect_of_nonBurstMicrostep
abbrev executionCorrect_of_trace :=
  @Nightstream.Chip8.ExecutionSemantics.executionCorrect_of_trace
abbrev preparedStepTraceBound_of_continuity :=
  @Nightstream.Chip8.ExecutionSemantics.preparedStepTraceBound_of_continuity
abbrev preparedStepTraceBound_of_execution :=
  @Nightstream.Chip8.ExecutionSemantics.preparedStepTraceBound_of_execution
abbrev goalPredicate_of_execution :=
  @Nightstream.Chip8.ExecutionSemantics.goalPredicate_of_execution

end ExecutionSemanticsInterface

end Nightstream.Chip8

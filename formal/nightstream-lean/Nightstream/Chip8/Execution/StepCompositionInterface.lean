import Nightstream.Chip8.Execution.StepComposition

namespace Nightstream.Chip8

namespace StepCompositionInterface

abbrev F := Nightstream.Chip8.StepComposition.F
abbrev MachineState := Nightstream.Chip8.StepComposition.MachineState
abbrev ExternalSchedule := Nightstream.Chip8.StepComposition.ExternalSchedule
abbrev StateWellFormed := Nightstream.Chip8.StepComposition.StateWellFormed
abbrev FetchDecodeBound := @Nightstream.Chip8.StepComposition.FetchDecodeBound
abbrev byteAdd := @Nightstream.Chip8.StepComposition.byteAdd
abbrev skipEqBit := @Nightstream.Chip8.StepComposition.skipEqBit
abbrev lookupValueOf := @Nightstream.Chip8.StepComposition.lookupValueOf
abbrev LookupBound := @Nightstream.Chip8.StepComposition.LookupBound
abbrev FramebufferBound := @Nightstream.Chip8.StepComposition.FramebufferBound
abbrev ScheduleBound := @Nightstream.Chip8.StepComposition.ScheduleBound
abbrev RegistersPreserved := @Nightstream.Chip8.StepComposition.RegistersPreserved
abbrev RegistersPreservedExcept := @Nightstream.Chip8.StepComposition.RegistersPreservedExcept
abbrev RegistersPreservedAbove := @Nightstream.Chip8.StepComposition.RegistersPreservedAbove
abbrev RamPreserved := @Nightstream.Chip8.StepComposition.RamPreserved
abbrev RamPrefixStored := @Nightstream.Chip8.StepComposition.RamPrefixStored
abbrev RamPreservedOutsidePrefix := @Nightstream.Chip8.StepComposition.RamPreservedOutsidePrefix
abbrev RegistersLoadedPrefix := @Nightstream.Chip8.StepComposition.RegistersLoadedPrefix
abbrev MemoryBound := @Nightstream.Chip8.StepComposition.MemoryBound
abbrev ContinuityRowBound := @Nightstream.Chip8.StepComposition.ContinuityRowBound
abbrev MicrostepCorrect := @Nightstream.Chip8.StepComposition.MicrostepCorrect
abbrev InstructionCorrect := @Nightstream.Chip8.StepComposition.InstructionCorrect
abbrev BurstScheduleCorrect := @Nightstream.Chip8.StepComposition.BurstScheduleCorrect
abbrev ExecutionFrame := Nightstream.Chip8.StepComposition.ExecutionFrame
abbrev ExecutionLinked := @Nightstream.Chip8.StepComposition.ExecutionLinked
abbrev InitialStateMatches := @Nightstream.Chip8.StepComposition.InitialStateMatches
abbrev StartBoundaryFrame := @Nightstream.Chip8.StepComposition.StartBoundaryFrame
abbrev FinalBoundaryFrame := @Nightstream.Chip8.StepComposition.FinalBoundaryFrame
abbrev BoundaryTraceBound := @Nightstream.Chip8.StepComposition.BoundaryTraceBound
abbrev ExecutionFrameBound := @Nightstream.Chip8.StepComposition.ExecutionFrameBound
abbrev ContinuityTraceBound := @Nightstream.Chip8.StepComposition.ContinuityTraceBound
abbrev PreparedStepTraceBound := @Nightstream.Chip8.StepComposition.PreparedStepTraceBound
abbrev ExecutionCorrect := @Nightstream.Chip8.StepComposition.ExecutionCorrect
abbrev FinalState := @Nightstream.Chip8.StepComposition.FinalState
abbrev GoalPredicate := Nightstream.Chip8.StepComposition.GoalPredicate

abbrev goldilocks_q_gt_256 := Nightstream.Chip8.StepComposition.goldilocks_q_gt_256
abbrev goldilocks_q_gt_4096 := Nightstream.Chip8.StepComposition.goldilocks_q_gt_4096
abbrev goldilocks_q_gt_4098 := Nightstream.Chip8.StepComposition.goldilocks_q_gt_4098
abbrev natEq_of_fieldEq := @Nightstream.Chip8.StepComposition.natEq_of_fieldEq
abbrev stateWellFormed_pc_lt_q := @Nightstream.Chip8.StepComposition.stateWellFormed_pc_lt_q
abbrev stateWellFormed_i_lt_q := @Nightstream.Chip8.StepComposition.stateWellFormed_i_lt_q
abbrev stateWellFormed_v_lt_q := @Nightstream.Chip8.StepComposition.stateWellFormed_v_lt_q
abbrev fetchDecodeBound_wellFormed := @Nightstream.Chip8.StepComposition.fetchDecodeBound_wellFormed
abbrev byteAdd_lt_256 := @Nightstream.Chip8.StepComposition.byteAdd_lt_256
abbrev lookupValueOf_lt_256 := @Nightstream.Chip8.StepComposition.lookupValueOf_lt_256
abbrev lookupValueOf_lt_q := @Nightstream.Chip8.StepComposition.lookupValueOf_lt_q
abbrev executionFrameBound_witnessBinds :=
  @Nightstream.Chip8.StepComposition.executionFrameBound_witnessBinds
abbrev executionFrameBound_microstepCorrect :=
  @Nightstream.Chip8.StepComposition.executionFrameBound_microstepCorrect
abbrev microstepCorrect_of_bounds := @Nightstream.Chip8.StepComposition.microstepCorrect_of_bounds
abbrev microstepCorrect_ldImm := @Nightstream.Chip8.StepComposition.microstepCorrect_ldImm
abbrev microstepCorrect_addImm := @Nightstream.Chip8.StepComposition.microstepCorrect_addImm
abbrev microstepCorrect_mov := @Nightstream.Chip8.StepComposition.microstepCorrect_mov
abbrev microstepCorrect_addReg := @Nightstream.Chip8.StepComposition.microstepCorrect_addReg
abbrev microstepCorrect_skipEqImm :=
  @Nightstream.Chip8.StepComposition.microstepCorrect_skipEqImm
abbrev microstepCorrect_jump := @Nightstream.Chip8.StepComposition.microstepCorrect_jump
abbrev microstepCorrect_ldI := @Nightstream.Chip8.StepComposition.microstepCorrect_ldI
abbrev microstepCorrect_storeRegs :=
  @Nightstream.Chip8.StepComposition.microstepCorrect_storeRegs
abbrev microstepCorrect_loadRegs :=
  @Nightstream.Chip8.StepComposition.microstepCorrect_loadRegs
abbrev instructionCorrect_of_nonBurstMicrostep :=
  @Nightstream.Chip8.StepComposition.instructionCorrect_of_nonBurstMicrostep
abbrev instructionCorrect_of_burst :=
  @Nightstream.Chip8.StepComposition.instructionCorrect_of_burst
abbrev executionCorrect_of_trace := @Nightstream.Chip8.StepComposition.executionCorrect_of_trace
abbrev preparedStepTraceBound_of_execution :=
  @Nightstream.Chip8.StepComposition.preparedStepTraceBound_of_execution
abbrev goalPredicate_of_execution := @Nightstream.Chip8.StepComposition.goalPredicate_of_execution

end StepCompositionInterface

end Nightstream.Chip8

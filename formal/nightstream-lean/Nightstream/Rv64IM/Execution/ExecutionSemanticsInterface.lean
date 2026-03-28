import Nightstream.Rv64IM.Execution.ExecutionSemantics

namespace Nightstream.Rv64IM

namespace ExecutionSemanticsInterface

abbrev RegisterState := Nightstream.Rv64IM.RegisterState
abbrev RamWordState := Nightstream.Rv64IM.RamWordState
abbrev ArchitecturalState := Nightstream.Rv64IM.ArchitecturalState
abbrev SequenceBoundary := Nightstream.Rv64IM.SequenceBoundary
abbrev OpcodeClass := Nightstream.Rv64IM.OpcodeClass
abbrev ExpandedRow := Nightstream.Rv64IM.ExpandedRow
abbrev PreparedStepView := Nightstream.Rv64IM.PreparedStepView
abbrev ExecutionFrame := @Nightstream.Rv64IM.ExecutionFrame
abbrev PreparedStepExportBound := @Nightstream.Rv64IM.PreparedStepExportBound
abbrev ExpandedRowSequenceBound := @Nightstream.Rv64IM.ExpandedRowSequenceBound
abbrev ExpandedBytecodeExecutionBound := @Nightstream.Rv64IM.ExpandedBytecodeExecutionBound
abbrev FullSequenceTerminated := @Nightstream.Rv64IM.FullSequenceTerminated
abbrev FrameRowsBound := @Nightstream.Rv64IM.FrameRowsBound
abbrev ExecutionLinked := @Nightstream.Rv64IM.ExecutionLinked
abbrev ExecutionTraceEndpoints := @Nightstream.Rv64IM.ExecutionTraceEndpoints
abbrev ExecutionTraceCorrect := @Nightstream.Rv64IM.ExecutionTraceCorrect
abbrev ExecutionCorrect := @Nightstream.Rv64IM.ExecutionCorrect
abbrev ExecutionSemanticsProofPackage := @Nightstream.Rv64IM.ExecutionSemanticsProofPackage
abbrev frameRowsBound_of_executionTraceCorrect :=
  @Nightstream.Rv64IM.frameRowsBound_of_executionTraceCorrect
abbrev executionLinked_of_executionTraceCorrect :=
  @Nightstream.Rv64IM.executionLinked_of_executionTraceCorrect
abbrev executionTraceEndpoints_of_executionTraceCorrect :=
  @Nightstream.Rv64IM.executionTraceEndpoints_of_executionTraceCorrect
abbrev initialState_matches_of_executionTraceCorrect :=
  @Nightstream.Rv64IM.initialState_matches_of_executionTraceCorrect
abbrev finalState_matches_of_executionTraceCorrect :=
  @Nightstream.Rv64IM.finalState_matches_of_executionTraceCorrect
abbrev frames_length_eq_rows_length_of_executionTraceCorrect :=
  @Nightstream.Rv64IM.frames_length_eq_rows_length_of_executionTraceCorrect
abbrev frameRowsBound_row_eq_at_index :=
  @Nightstream.Rv64IM.frameRowsBound_row_eq_at_index
abbrev row_of_frameRowsBound_at_index :=
  @Nightstream.Rv64IM.row_of_frameRowsBound_at_index
abbrev adjacentFrames_linked_of_executionLinked :=
  @Nightstream.Rv64IM.adjacentFrames_linked_of_executionLinked
abbrev adjacentStates_of_executionTraceCorrect :=
  @Nightstream.Rv64IM.adjacentStates_of_executionTraceCorrect
abbrev expandedRowSequenceBound_of_executionCorrect :=
  @Nightstream.Rv64IM.expandedRowSequenceBound_of_executionCorrect
abbrev preparedStepExportBound_of_executionCorrect :=
  @Nightstream.Rv64IM.preparedStepExportBound_of_executionCorrect
abbrev preparedSteps_length_eq_rows_length_of_preparedStepExportBound :=
  @Nightstream.Rv64IM.preparedSteps_length_eq_rows_length_of_preparedStepExportBound
abbrev preparedStep_matches_row_of_preparedStepExportBound :=
  @Nightstream.Rv64IM.preparedStep_matches_row_of_preparedStepExportBound
abbrev expandedBytecodeExecutionBound_of_executionCorrect :=
  @Nightstream.Rv64IM.expandedBytecodeExecutionBound_of_executionCorrect
abbrev entrypoint_firstRow_of_expandedBytecodeExecutionBound :=
  @Nightstream.Rv64IM.entrypoint_firstRow_of_expandedBytecodeExecutionBound
abbrev successors_length_succ_eq_rows_length_of_expandedBytecodeExecutionBound :=
  @Nightstream.Rv64IM.successors_length_succ_eq_rows_length_of_expandedBytecodeExecutionBound
abbrev successor_matches_rows_of_expandedBytecodeExecutionBound :=
  @Nightstream.Rv64IM.successor_matches_rows_of_expandedBytecodeExecutionBound
abbrev fullHaltedExecutionClaim_of_executionCorrect :=
  @Nightstream.Rv64IM.fullHaltedExecutionClaim_of_executionCorrect
abbrev boundaryStartPc_of_executionCorrect :=
  @Nightstream.Rv64IM.boundaryStartPc_of_executionCorrect
abbrev boundaryPcNext_of_executionCorrect :=
  @Nightstream.Rv64IM.boundaryPcNext_of_executionCorrect
abbrev boundaryTerminates_of_executionCorrect :=
  @Nightstream.Rv64IM.boundaryTerminates_of_executionCorrect
abbrev finalState_halted_of_executionCorrect :=
  @Nightstream.Rv64IM.finalState_halted_of_executionCorrect

end ExecutionSemanticsInterface

end Nightstream.Rv64IM

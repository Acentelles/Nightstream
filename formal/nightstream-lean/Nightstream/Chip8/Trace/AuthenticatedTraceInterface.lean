import Nightstream.Chip8.Trace.AuthenticatedTrace

namespace Nightstream.Chip8

namespace AuthenticatedTraceInterface

-- ── Types ──

abbrev F := Nightstream.Chip8.AuthenticatedTrace.F
abbrev Program := Nightstream.Chip8.AuthenticatedTrace.Program
abbrev MachineState := Nightstream.Chip8.AuthenticatedTrace.MachineState
abbrev InitialState := Nightstream.Chip8.AuthenticatedTrace.InitialState
abbrev ExternalSchedule := Nightstream.Chip8.AuthenticatedTrace.ExternalSchedule
abbrev ExecutionFrame := Nightstream.Chip8.AuthenticatedTrace.ExecutionFrame

-- ── Structures ──

abbrev ExactFrameEvidence := @Nightstream.Chip8.AuthenticatedTrace.ExactFrameEvidence
abbrev ExactStage2AdjacentSupport :=
  @Nightstream.Chip8.AuthenticatedTrace.ExactStage2AdjacentSupport
abbrev ExactPcAdjacentSupport :=
  @Nightstream.Chip8.AuthenticatedTrace.ExactPcAdjacentSupport
abbrev ExactAdjacentSupport :=
  @Nightstream.Chip8.AuthenticatedTrace.ExactAdjacentSupport
abbrev traceOf := @Nightstream.Chip8.AuthenticatedTrace.traceOf
abbrev ExactTraceEvidenceFrom :=
  @Nightstream.Chip8.AuthenticatedTrace.ExactTraceEvidenceFrom
abbrev ExactTraceEvidence := @Nightstream.Chip8.AuthenticatedTrace.ExactTraceEvidence

-- ── Trace Evidence Destructors ──

abbrev headStepIdx_of_exactTraceEvidenceFrom_cons :=
  @Nightstream.Chip8.AuthenticatedTrace.headStepIdx_of_exactTraceEvidenceFrom_cons
abbrev adjacentSupport_of_exactTraceEvidenceFrom_cons_cons :=
  @Nightstream.Chip8.AuthenticatedTrace.adjacentSupport_of_exactTraceEvidenceFrom_cons_cons
abbrev tailExactTraceEvidenceFrom_of_exactTraceEvidenceFrom_cons :=
  @Nightstream.Chip8.AuthenticatedTrace.tailExactTraceEvidenceFrom_of_exactTraceEvidenceFrom_cons
abbrev tailExactTraceEvidenceFrom_of_exactTraceEvidenceFrom_cons_cons :=
  @Nightstream.Chip8.AuthenticatedTrace.tailExactTraceEvidenceFrom_of_exactTraceEvidenceFrom_cons_cons

-- ── Temporal Seed Summaries ──

abbrev Stage2TemporalSeedSummaryEntry :=
  @Nightstream.Chip8.AuthenticatedTrace.Stage2TemporalSeedSummaryEntry
abbrev RegisterTemporalSeedSummaryEntry :=
  @Nightstream.Chip8.AuthenticatedTrace.RegisterTemporalSeedSummaryEntry
abbrev RamTemporalSeedSummaryEntry :=
  @Nightstream.Chip8.AuthenticatedTrace.RamTemporalSeedSummaryEntry

-- ── Bounds ──

abbrev AuthenticatedChunkTraceBound :=
  @Nightstream.Chip8.AuthenticatedTrace.AuthenticatedChunkTraceBound
abbrev AuthenticatedTemporalSupportBound :=
  @Nightstream.Chip8.AuthenticatedTrace.AuthenticatedTemporalSupportBound
abbrev AuthenticatedExecutionTraceBound :=
  @Nightstream.Chip8.AuthenticatedTrace.AuthenticatedExecutionTraceBound

-- ── Temporal Seed Derivations ──

abbrev stage2TemporalSeedSummaryEntry_of_exactFrameEvidence :=
  @Nightstream.Chip8.AuthenticatedTrace.stage2TemporalSeedSummaryEntry_of_exactFrameEvidence
abbrev registerTemporalSeedSummaryEntry_of_stage2TemporalSeedSummaryEntry :=
  @Nightstream.Chip8.AuthenticatedTrace.registerTemporalSeedSummaryEntry_of_stage2TemporalSeedSummaryEntry
abbrev ramTemporalSeedSummaryEntry_of_stage2TemporalSeedSummaryEntry :=
  @Nightstream.Chip8.AuthenticatedTrace.ramTemporalSeedSummaryEntry_of_stage2TemporalSeedSummaryEntry
abbrev registerTemporalSeedSummaryEntry_of_exactFrameEvidence :=
  @Nightstream.Chip8.AuthenticatedTrace.registerTemporalSeedSummaryEntry_of_exactFrameEvidence
abbrev ramTemporalSeedSummaryEntry_of_exactFrameEvidence :=
  @Nightstream.Chip8.AuthenticatedTrace.ramTemporalSeedSummaryEntry_of_exactFrameEvidence
abbrev stage2TemporalSeedSummary_of_frames :=
  @Nightstream.Chip8.AuthenticatedTrace.stage2TemporalSeedSummary_of_frames
abbrev registerTemporalSeedSummary_of_frames :=
  @Nightstream.Chip8.AuthenticatedTrace.registerTemporalSeedSummary_of_frames
abbrev ramTemporalSeedSummary_of_frames :=
  @Nightstream.Chip8.AuthenticatedTrace.ramTemporalSeedSummary_of_frames
abbrev registerTemporalSeeds_of_authenticatedExecutionTraceBound :=
  @Nightstream.Chip8.AuthenticatedTrace.registerTemporalSeeds_of_authenticatedExecutionTraceBound
abbrev ramTemporalSeeds_of_authenticatedExecutionTraceBound :=
  @Nightstream.Chip8.AuthenticatedTrace.ramTemporalSeeds_of_authenticatedExecutionTraceBound

-- ── Well-Formedness ──

abbrev wf_of_exactFrameEvidence :=
  @Nightstream.Chip8.AuthenticatedTrace.wf_of_exactFrameEvidence
abbrev stateWellFormedFrames_of_frames :=
  @Nightstream.Chip8.AuthenticatedTrace.stateWellFormedFrames_of_frames
abbrev headInitialStateMatch_of_chunkInput :=
  @Nightstream.Chip8.AuthenticatedTrace.headInitialStateMatch_of_chunkInput
abbrev traceLength_eq_semanticRows_of_chunkInput :=
  @Nightstream.Chip8.AuthenticatedTrace.traceLength_eq_semanticRows_of_chunkInput

-- ── Execution and Continuity Theorems ──

abbrev executionFrameBound_of_exactFrameEvidence :=
  @Nightstream.Chip8.AuthenticatedTrace.executionFrameBound_of_exactFrameEvidence
abbrev executionFramesBound_of_exactTrace :=
  @Nightstream.Chip8.AuthenticatedTrace.executionFramesBound_of_exactTrace
abbrev continuityTraceBound_of_exactTrace :=
  @Nightstream.Chip8.AuthenticatedTrace.continuityTraceBound_of_exactTrace
abbrev startBoundaryFrame_of_exactHead :=
  @Nightstream.Chip8.AuthenticatedTrace.startBoundaryFrame_of_exactHead
abbrev lastStepIdx_of_exactTraceFrom_appendLast :=
  @Nightstream.Chip8.AuthenticatedTrace.lastStepIdx_of_exactTraceFrom_appendLast
abbrev finalBoundaryFrame_of_exactTail :=
  @Nightstream.Chip8.AuthenticatedTrace.finalBoundaryFrame_of_exactTail
abbrev traceLength_le_publishedLength_of_exactTrace :=
  @Nightstream.Chip8.AuthenticatedTrace.traceLength_le_publishedLength_of_exactTrace

-- ── Authenticated Bound Assembly Theorems ──

abbrev authenticatedChunkTraceBound_of_exactTrace :=
  @Nightstream.Chip8.AuthenticatedTrace.authenticatedChunkTraceBound_of_exactTrace
abbrev registerAdjacentTraceBound_of_exactTrace :=
  @Nightstream.Chip8.AuthenticatedTrace.registerAdjacentTraceBound_of_exactTrace
abbrev ramAdjacentTraceBound_of_exactTrace :=
  @Nightstream.Chip8.AuthenticatedTrace.ramAdjacentTraceBound_of_exactTrace
abbrev pcAdjacentBridge_of_exactTrace :=
  @Nightstream.Chip8.AuthenticatedTrace.pcAdjacentBridge_of_exactTrace
abbrev stage2TemporalContextBound_of_exactTrace :=
  @Nightstream.Chip8.AuthenticatedTrace.stage2TemporalContextBound_of_exactTrace
abbrev authenticatedTemporalSupportBound_of_exactTrace :=
  @Nightstream.Chip8.AuthenticatedTrace.authenticatedTemporalSupportBound_of_exactTrace
abbrev temporalInstantiationBound_of_authenticatedTemporalSupport :=
  @Nightstream.Chip8.AuthenticatedTrace.temporalInstantiationBound_of_authenticatedTemporalSupport
abbrev authenticatedExecutionTraceBound_of_exactTrace :=
  @Nightstream.Chip8.AuthenticatedTrace.authenticatedExecutionTraceBound_of_exactTrace
abbrev authenticatedExecutionTraceBound_of_exactTrace_and_support :=
  @Nightstream.Chip8.AuthenticatedTrace.authenticatedExecutionTraceBound_of_exactTrace_and_support
abbrev authenticatedExecutionTraceBound_of_exactTrace_and_temporal :=
  @Nightstream.Chip8.AuthenticatedTrace.authenticatedExecutionTraceBound_of_exactTrace_and_temporal

-- ── Trace Link and Execution Correctness Theorems ──

abbrev traceLinkBound_of_authenticatedExecutionTraceBound :=
  @Nightstream.Chip8.AuthenticatedTrace.traceLinkBound_of_authenticatedExecutionTraceBound
abbrev executionCorrect_of_authenticatedExecutionTraceBound :=
  @Nightstream.Chip8.AuthenticatedTrace.executionCorrect_of_authenticatedExecutionTraceBound
abbrev traceLinkBound_of_exactTrace_and_support :=
  @Nightstream.Chip8.AuthenticatedTrace.traceLinkBound_of_exactTrace_and_support
abbrev traceLinkBound_of_exactTrace_and_chunkInput :=
  @Nightstream.Chip8.AuthenticatedTrace.traceLinkBound_of_exactTrace_and_chunkInput
abbrev traceLinkBound_of_exactTrace_and_temporal :=
  @Nightstream.Chip8.AuthenticatedTrace.traceLinkBound_of_exactTrace_and_temporal
abbrev executionCorrect_of_authenticatedChunkTraceBound_and_support :=
  @Nightstream.Chip8.AuthenticatedTrace.executionCorrect_of_authenticatedChunkTraceBound_and_support
abbrev executionCorrect_of_authenticatedChunkTraceBound :=
  @Nightstream.Chip8.AuthenticatedTrace.executionCorrect_of_authenticatedChunkTraceBound
abbrev executionCorrect_of_exactTrace_and_support :=
  @Nightstream.Chip8.AuthenticatedTrace.executionCorrect_of_exactTrace_and_support
abbrev executionCorrect_of_exactTrace_and_chunkInput :=
  @Nightstream.Chip8.AuthenticatedTrace.executionCorrect_of_exactTrace_and_chunkInput
abbrev executionCorrect_of_exactTrace :=
  @Nightstream.Chip8.AuthenticatedTrace.executionCorrect_of_exactTrace

-- ── Prepared Step Export ──

abbrev preparedStepTraceBound_of_exactTrace :=
  @Nightstream.Chip8.AuthenticatedTrace.preparedStepTraceBound_of_exactTrace
abbrev preparedStepExport_of_exactTrace :=
  @Nightstream.Chip8.AuthenticatedTrace.preparedStepExport_of_exactTrace

end AuthenticatedTraceInterface

end Nightstream.Chip8

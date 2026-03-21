import Nightstream.Chip8.Kernel.KernelExecutionDigest

namespace Nightstream.Chip8

namespace KernelExecutionDigestInterface

-- ── Types ──

abbrev F := Nightstream.Chip8.KernelExecutionDigest.F
abbrev Program := Nightstream.Chip8.KernelExecutionDigest.Program
abbrev MachineState := Nightstream.Chip8.KernelExecutionDigest.MachineState
abbrev InitialState := Nightstream.Chip8.KernelExecutionDigest.InitialState
abbrev ExternalSchedule := Nightstream.Chip8.KernelExecutionDigest.ExternalSchedule
abbrev ExecutionFrame := Nightstream.Chip8.KernelExecutionDigest.ExecutionFrame
abbrev RootEncode := @Nightstream.Chip8.KernelExecutionDigest.RootEncode

-- ── Structures ──

abbrev KernelTraceSurface := @Nightstream.Chip8.KernelExecutionDigest.KernelTraceSurface
abbrev RowProjectionSummaryEntry :=
  @Nightstream.Chip8.KernelExecutionDigest.RowProjectionSummaryEntry
abbrev BridgeBindingSummaryEntry :=
  @Nightstream.Chip8.KernelExecutionDigest.BridgeBindingSummaryEntry
abbrev KernelAuditSurface := @Nightstream.Chip8.KernelExecutionDigest.KernelAuditSurface
abbrev KernelExportSurface := @Nightstream.Chip8.KernelExecutionDigest.KernelExportSurface
abbrev KernelManifestSurface := @Nightstream.Chip8.KernelExecutionDigest.KernelManifestSurface
abbrev KernelTranscriptSurface := @Nightstream.Chip8.KernelExecutionDigest.KernelTranscriptSurface
abbrev KernelErrorSurface := @Nightstream.Chip8.KernelExecutionDigest.KernelErrorSurface

-- ── Constraints ──

abbrev KernelExecutionDigest := @Nightstream.Chip8.KernelExecutionDigest.KernelExecutionDigest
abbrev KernelExecutionDigestBound := @Nightstream.Chip8.KernelExecutionDigest.KernelExecutionDigestBound

-- ── Theorems (digest construction) ──

abbrev kernelExecutionDigest_of_conclusion :=
  @Nightstream.Chip8.KernelExecutionDigest.kernelExecutionDigest_of_conclusion
abbrev kernelExecutionDigest_of_acceptance :=
  @Nightstream.Chip8.KernelExecutionDigest.kernelExecutionDigest_of_acceptance

-- ── Theorems (bound extraction) ──

abbrev authenticatedChunkTraceBound_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.authenticatedChunkTraceBound_of_digest
abbrev stage2TemporalSeeds_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.stage2TemporalSeeds_of_digest
abbrev temporalSupport_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.temporalSupport_of_digest
abbrev authenticatedExecutionTraceBound_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.authenticatedExecutionTraceBound_of_digest
abbrev kernelClaimsFixedInRoot0_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.kernelClaimsFixedInRoot0_of_digest
abbrev kernelRootCommitmentsDisjoint_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.kernelRootCommitmentsDisjoint_of_digest
abbrev challengeAfterPhase0_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.challengeAfterPhase0_of_digest
abbrev stage1TerminalAfterPhase0_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.stage1TerminalAfterPhase0_of_digest
abbrev stage2TerminalAfterPhase0_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.stage2TerminalAfterPhase0_of_digest
abbrev rowBindingCoverage_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.rowBindingCoverage_of_digest
abbrev emitKernelOpeningClaimsLast_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.emitKernelOpeningClaimsLast_of_digest
abbrev traceLinkBound_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.traceLinkBound_of_digest
abbrev executionLinked_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.executionLinked_of_digest
abbrev executionCorrect_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.executionCorrect_of_digest
abbrev preparedStepExport_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.preparedStepExport_of_digest
abbrev rowProjectionSummary_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.rowProjectionSummary_of_digest
abbrev bridgeBindingSummary_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.bridgeBindingSummary_of_digest
abbrev negligibleTotal_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.negligibleTotal_of_digest
abbrev kernelSoundnessConclusion_of_digest :=
  @Nightstream.Chip8.KernelExecutionDigest.kernelSoundnessConclusion_of_digest

end KernelExecutionDigestInterface

end Nightstream.Chip8

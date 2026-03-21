import Nightstream.Chip8.Kernel.KernelSoundness

namespace Nightstream.Chip8

namespace KernelSoundnessInterface

-- ── Types ──

abbrev F := Nightstream.Chip8.KernelSoundness.F
abbrev Program := Nightstream.Chip8.KernelSoundness.Program
abbrev MachineState := Nightstream.Chip8.KernelSoundness.MachineState
abbrev InitialState := Nightstream.Chip8.KernelSoundness.InitialState
abbrev ExternalSchedule := Nightstream.Chip8.KernelSoundness.ExternalSchedule
abbrev ExecutionFrame := Nightstream.Chip8.KernelSoundness.ExecutionFrame
abbrev RootEncode := @Nightstream.Chip8.KernelSoundness.RootEncode

-- ── Definitions ──

abbrev kernelPreparedSteps := @Nightstream.Chip8.KernelSoundness.kernelPreparedSteps

-- ── Constraints ──

abbrev KernelSoundnessConclusion :=
  @Nightstream.Chip8.KernelSoundness.KernelSoundnessConclusion
abbrev KernelSoundnessAccepted :=
  @Nightstream.Chip8.KernelSoundness.KernelSoundnessAccepted

-- ── Theorems (soundness from boundaries) ──

abbrev kernelSoundness_of_boundaries :=
  @Nightstream.Chip8.KernelSoundness.kernelSoundness_of_boundaries
abbrev kernelSoundnessAccepted_of_exactBoundaries :=
  @Nightstream.Chip8.KernelSoundness.kernelSoundnessAccepted_of_exactBoundaries
abbrev kernelSoundness_of_exactBoundaries :=
  @Nightstream.Chip8.KernelSoundness.kernelSoundness_of_exactBoundaries
abbrev kernelSoundness_of_acceptance :=
  @Nightstream.Chip8.KernelSoundness.kernelSoundness_of_acceptance

-- ── Theorems (acceptance implications) ──

abbrev kernelAcceptanceImpliesAuthenticatedChunkTrace :=
  @Nightstream.Chip8.KernelSoundness.kernelAcceptanceImpliesAuthenticatedChunkTrace
abbrev kernelAcceptanceImpliesAuthenticatedExecutionTrace :=
  @Nightstream.Chip8.KernelSoundness.kernelAcceptanceImpliesAuthenticatedExecutionTrace
abbrev kernelAcceptanceImpliesStage2TemporalSeeds :=
  @Nightstream.Chip8.KernelSoundness.kernelAcceptanceImpliesStage2TemporalSeeds
abbrev kernelAcceptanceImpliesTemporalSupport :=
  @Nightstream.Chip8.KernelSoundness.kernelAcceptanceImpliesTemporalSupport
abbrev kernelAcceptanceImpliesTraceLinkBound :=
  @Nightstream.Chip8.KernelSoundness.kernelAcceptanceImpliesTraceLinkBound
abbrev kernelAcceptanceImpliesExecutionLinked :=
  @Nightstream.Chip8.KernelSoundness.kernelAcceptanceImpliesExecutionLinked
abbrev kernelAcceptanceImpliesExecutionCorrect :=
  @Nightstream.Chip8.KernelSoundness.kernelAcceptanceImpliesExecutionCorrect
abbrev kernelAcceptanceImpliesPreparedStepExport :=
  @Nightstream.Chip8.KernelSoundness.kernelAcceptanceImpliesPreparedStepExport
abbrev kernelAcceptanceImpliesNegligibleTotal :=
  @Nightstream.Chip8.KernelSoundness.kernelAcceptanceImpliesNegligibleTotal

end KernelSoundnessInterface

end Nightstream.Chip8

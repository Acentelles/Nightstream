import Nightstream.Chip8.Kernel.ReleaseArtifactAudit

namespace Nightstream.Chip8

namespace ReleaseArtifactAuditInterface

abbrev F := Nightstream.Chip8.ReleaseArtifactAudit.F
abbrev Program := Nightstream.Chip8.ReleaseArtifactAudit.Program
abbrev MachineState := Nightstream.Chip8.ReleaseArtifactAudit.MachineState
abbrev InitialState := Nightstream.Chip8.ReleaseArtifactAudit.InitialState
abbrev ExternalSchedule := Nightstream.Chip8.ReleaseArtifactAudit.ExternalSchedule

abbrev checkKernelDigestSurface :=
  @Nightstream.Chip8.ReleaseArtifactAudit.checkKernelDigestSurface
abbrev checkStagedBundleSurface :=
  @Nightstream.Chip8.ReleaseArtifactAudit.checkStagedBundleSurface
abbrev checkChunkInputSurface :=
  @Nightstream.Chip8.ReleaseArtifactAudit.checkChunkInputSurface
abbrev checkReleaseArtifact :=
  @Nightstream.Chip8.ReleaseArtifactAudit.checkReleaseArtifact
abbrev ReleaseArtifactAuditAccepted :=
  @Nightstream.Chip8.ReleaseArtifactAudit.ReleaseArtifactAuditAccepted

abbrev checkKernelDigestSurface_of_bound :=
  @Nightstream.Chip8.ReleaseArtifactAudit.checkKernelDigestSurface_of_bound
abbrev checkStagedBundleSurface_of_bound :=
  @Nightstream.Chip8.ReleaseArtifactAudit.checkStagedBundleSurface_of_bound
abbrev checkChunkInputSurface_of_bound :=
  @Nightstream.Chip8.ReleaseArtifactAudit.checkChunkInputSurface_of_bound
abbrev releaseArtifactAuditAccepted_of_bound :=
  @Nightstream.Chip8.ReleaseArtifactAudit.releaseArtifactAuditAccepted_of_bound
abbrev releaseArtifactAuditSound :=
  @Nightstream.Chip8.ReleaseArtifactAudit.releaseArtifactAuditSound
abbrev releaseArtifactAuditImpliesKernelSoundnessConclusion :=
  @Nightstream.Chip8.ReleaseArtifactAudit.releaseArtifactAuditImpliesKernelSoundnessConclusion
abbrev releaseArtifactAuditImpliesEntryBound :=
  @Nightstream.Chip8.ReleaseArtifactAudit.releaseArtifactAuditImpliesEntryBound
abbrev releaseArtifactAuditImpliesBundleLength_eq_semanticRows :=
  @Nightstream.Chip8.ReleaseArtifactAudit.releaseArtifactAuditImpliesBundleLength_eq_semanticRows
abbrev releaseArtifactAuditImpliesPreparedStepCount_eq_bundleLength :=
  @Nightstream.Chip8.ReleaseArtifactAudit.releaseArtifactAuditImpliesPreparedStepCount_eq_bundleLength

end ReleaseArtifactAuditInterface

end Nightstream.Chip8

import Nightstream.Chip8.Kernel.ArtifactAudit

namespace Nightstream.Chip8

namespace ArtifactAuditInterface

abbrev F := Nightstream.Chip8.ArtifactAudit.F
abbrev Program := Nightstream.Chip8.ArtifactAudit.Program
abbrev MachineState := Nightstream.Chip8.ArtifactAudit.MachineState
abbrev InitialState := Nightstream.Chip8.ArtifactAudit.InitialState
abbrev ExternalSchedule := Nightstream.Chip8.ArtifactAudit.ExternalSchedule
abbrev checkDigestPublicSurface := @Nightstream.Chip8.ArtifactAudit.checkDigestPublicSurface
abbrev checkStage1Surface := @Nightstream.Chip8.ArtifactAudit.checkStage1Surface
abbrev checkStage2Surface := @Nightstream.Chip8.ArtifactAudit.checkStage2Surface
abbrev checkStage3Surface := @Nightstream.Chip8.ArtifactAudit.checkStage3Surface
abbrev checkExecutionResultSurface :=
  @Nightstream.Chip8.ArtifactAudit.checkExecutionResultSurface
abbrev checkStagedExecutionDigest :=
  @Nightstream.Chip8.ArtifactAudit.checkStagedExecutionDigest
abbrev ArtifactAuditAccepted := @Nightstream.Chip8.ArtifactAudit.ArtifactAuditAccepted
abbrev artifactAuditSound := @Nightstream.Chip8.ArtifactAudit.artifactAuditSound
abbrev artifactAuditImpliesBridgeBinding :=
  @Nightstream.Chip8.ArtifactAudit.artifactAuditImpliesBridgeBinding
abbrev artifactAuditImpliesExecutionResultSurface :=
  @Nightstream.Chip8.ArtifactAudit.artifactAuditImpliesExecutionResultSurface
abbrev artifactAuditImpliesExecutionFrameBound :=
  @Nightstream.Chip8.ArtifactAudit.artifactAuditImpliesExecutionFrameBound
abbrev artifactAuditImpliesMicrostepCorrect :=
  @Nightstream.Chip8.ArtifactAudit.artifactAuditImpliesMicrostepCorrect

end ArtifactAuditInterface

end Nightstream.Chip8

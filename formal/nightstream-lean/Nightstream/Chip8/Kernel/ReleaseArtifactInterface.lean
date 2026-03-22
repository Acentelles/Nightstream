import Nightstream.Chip8.Kernel.ReleaseArtifact

namespace Nightstream.Chip8

namespace ReleaseArtifactInterface

abbrev F := Nightstream.Chip8.ReleaseArtifact.F
abbrev Program := Nightstream.Chip8.ReleaseArtifact.Program
abbrev MachineState := Nightstream.Chip8.ReleaseArtifact.MachineState
abbrev InitialState := Nightstream.Chip8.ReleaseArtifact.InitialState
abbrev ExternalSchedule := Nightstream.Chip8.ReleaseArtifact.ExternalSchedule

abbrev ReleaseArtifact := @Nightstream.Chip8.ReleaseArtifact.Artifact
abbrev ReleaseArtifactBound := @Nightstream.Chip8.ReleaseArtifact.ReleaseArtifactBound

abbrev kernelDigestBound_of_releaseArtifactBound :=
  @Nightstream.Chip8.ReleaseArtifact.kernelDigestBound_of_releaseArtifactBound
abbrev stagedBundleAuditAccepted_of_releaseArtifactBound :=
  @Nightstream.Chip8.ReleaseArtifact.stagedBundleAuditAccepted_of_releaseArtifactBound
abbrev chunkInput_of_releaseArtifactBound :=
  @Nightstream.Chip8.ReleaseArtifact.chunkInput_of_releaseArtifactBound
abbrev releaseArtifactBound_of_fields :=
  @Nightstream.Chip8.ReleaseArtifact.releaseArtifactBound_of_fields
abbrev releaseArtifact_of_conclusion :=
  @Nightstream.Chip8.ReleaseArtifact.releaseArtifact_of_conclusion
abbrev releaseArtifact_of_acceptance :=
  @Nightstream.Chip8.ReleaseArtifact.releaseArtifact_of_acceptance

end ReleaseArtifactInterface

end Nightstream.Chip8

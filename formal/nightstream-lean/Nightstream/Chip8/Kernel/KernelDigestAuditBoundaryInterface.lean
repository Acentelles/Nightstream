import Nightstream.Chip8.Kernel.KernelDigestAuditBoundary

namespace Nightstream.Chip8

namespace KernelDigestAuditBoundaryInterface

-- ── Types ──

abbrev F := Nightstream.Chip8.KernelDigestAuditBoundary.F
abbrev Program := Nightstream.Chip8.KernelDigestAuditBoundary.Program
abbrev MachineState := Nightstream.Chip8.KernelDigestAuditBoundary.MachineState
abbrev InitialState := Nightstream.Chip8.KernelDigestAuditBoundary.InitialState
abbrev ExternalSchedule := Nightstream.Chip8.KernelDigestAuditBoundary.ExternalSchedule
abbrev ExecutionFrame := Nightstream.Chip8.KernelDigestAuditBoundary.ExecutionFrame
abbrev ExecutionInputContext := Nightstream.Chip8.KernelDigestAuditBoundary.ExecutionInputContext
abbrev RootEncode := @Nightstream.Chip8.KernelDigestAuditBoundary.RootEncode
abbrev KernelPoints := Nightstream.Chip8.KernelDigestAuditBoundary.KernelPoints

-- ── Structures ──

abbrev KernelOpeningManifest :=
  Nightstream.Chip8.KernelDigestAuditBoundary.KernelOpeningManifest
abbrev RootOpeningManifest :=
  Nightstream.Chip8.KernelDigestAuditBoundary.RootOpeningManifest
abbrev KernelSoundnessAccounting :=
  Nightstream.Chip8.KernelDigestAuditBoundary.KernelSoundnessAccounting

-- ── Theorems (surface extraction) ──

abbrev kernelTraceSurface_of_digest :=
  @Nightstream.Chip8.KernelDigestAuditBoundary.kernelTraceSurface_of_digest
abbrev kernelExportSurface_of_digest :=
  @Nightstream.Chip8.KernelDigestAuditBoundary.kernelExportSurface_of_digest
abbrev kernelAuditSurface_of_digest :=
  @Nightstream.Chip8.KernelDigestAuditBoundary.kernelAuditSurface_of_digest
abbrev kernelManifestSurface_of_digest :=
  @Nightstream.Chip8.KernelDigestAuditBoundary.kernelManifestSurface_of_digest
abbrev kernelTranscriptSurface_of_digest :=
  @Nightstream.Chip8.KernelDigestAuditBoundary.kernelTranscriptSurface_of_digest
abbrev kernelErrorSurface_of_digest :=
  @Nightstream.Chip8.KernelDigestAuditBoundary.kernelErrorSurface_of_digest
abbrev kernelExecutionDigestBound_of_digest :=
  @Nightstream.Chip8.KernelDigestAuditBoundary.kernelExecutionDigestBound_of_digest

-- ── Theorems (surface checkers) ──

abbrev checkKernelTraceSurface_of_digest :=
  @Nightstream.Chip8.KernelDigestAuditBoundary.checkKernelTraceSurface_of_digest
abbrev checkKernelExportSurface_of_digest :=
  @Nightstream.Chip8.KernelDigestAuditBoundary.checkKernelExportSurface_of_digest
abbrev checkKernelAuditSurface_of_digest :=
  @Nightstream.Chip8.KernelDigestAuditBoundary.checkKernelAuditSurface_of_digest
abbrev checkKernelManifestSurface_of_digest :=
  @Nightstream.Chip8.KernelDigestAuditBoundary.checkKernelManifestSurface_of_digest
abbrev checkKernelTranscriptSurface_of_digest :=
  @Nightstream.Chip8.KernelDigestAuditBoundary.checkKernelTranscriptSurface_of_digest
abbrev checkKernelErrorSurface_of_digest :=
  @Nightstream.Chip8.KernelDigestAuditBoundary.checkKernelErrorSurface_of_digest

-- ── Theorems (audit acceptance) ──

abbrev kernelArtifactAuditAccepted_of_digest :=
  @Nightstream.Chip8.KernelDigestAuditBoundary.kernelArtifactAuditAccepted_of_digest

end KernelDigestAuditBoundaryInterface

end Nightstream.Chip8

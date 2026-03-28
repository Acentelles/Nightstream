import Nightstream.Chip8.Kernel.StagedExecutionBundleAudit

namespace Nightstream.Chip8

namespace StagedExecutionBundleAuditInterface

abbrev F := Nightstream.Chip8.StagedExecutionBundleAudit.F
abbrev Program := Nightstream.Chip8.StagedExecutionBundleAudit.Program
abbrev MachineState := Nightstream.Chip8.StagedExecutionBundleAudit.MachineState
abbrev InitialState := Nightstream.Chip8.StagedExecutionBundleAudit.InitialState
abbrev ExternalSchedule := Nightstream.Chip8.StagedExecutionBundleAudit.ExternalSchedule

abbrev EntryAuditAccepted :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.EntryAuditAccepted
abbrev checkBundlePublicSurface :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.checkBundlePublicSurface
abbrev checkBundleEntries :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.checkBundleEntries
abbrev checkBundleOrder :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.checkBundleOrder
abbrev checkStagedExecutionDigestBundle :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.checkStagedExecutionDigestBundle
abbrev StagedExecutionBundleAuditAccepted :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.StagedExecutionBundleAuditAccepted

abbrev entryAuditAccepted_of_entry :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.entryAuditAccepted_of_entry
abbrev stagedExecutionBundleAuditAccepted_of_bundle :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.stagedExecutionBundleAuditAccepted_of_bundle
abbrev stagedExecutionBundleAuditAccepted_of_frames :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.stagedExecutionBundleAuditAccepted_of_frames
abbrev bundleAuditImpliesKernelPublicInputsBound :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.bundleAuditImpliesKernelPublicInputsBound
abbrev bundleAuditImpliesEntryAccepted :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.bundleAuditImpliesEntryAccepted
abbrev bundleAuditImpliesOrderedFrames :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.bundleAuditImpliesOrderedFrames
abbrev bundleAuditImpliesEntryBound :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.bundleAuditImpliesEntryBound
abbrev bundleAuditImpliesEntryExecutionFrameBound :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.bundleAuditImpliesEntryExecutionFrameBound
abbrev bundleAuditImpliesEntryMicrostepCorrect :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.bundleAuditImpliesEntryMicrostepCorrect
abbrev bundleAuditLength_eq :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.bundleAuditLength_eq
abbrev bundleAuditLength_eq_semanticRows :=
  @Nightstream.Chip8.StagedExecutionBundleAudit.bundleAuditLength_eq_semanticRows

end StagedExecutionBundleAuditInterface

end Nightstream.Chip8

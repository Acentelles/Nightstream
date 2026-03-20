import Nightstream.Chip8.Execution.RomScheduleBindingStepComposition

namespace Nightstream.Chip8

namespace RomScheduleBindingInterface

abbrev Program := Nightstream.Chip8.RomScheduleBinding.Program
abbrev InitialState := Nightstream.Chip8.RomScheduleBinding.InitialState
abbrev ExternalSchedule := Nightstream.Chip8.RomScheduleBinding.ExternalSchedule
abbrev PublicDigest := Nightstream.Chip8.RomScheduleBinding.PublicDigest
abbrev KernelMeta := @Nightstream.Chip8.RomScheduleBinding.KernelMeta
abbrev KernelPublicInput := @Nightstream.Chip8.RomScheduleBinding.KernelPublicInput
abbrev RomHashBound := @Nightstream.Chip8.RomScheduleBinding.RomHashBound
abbrev ScheduleDigestBound := @Nightstream.Chip8.RomScheduleBinding.ScheduleDigestBound
abbrev ScheduleLengthBound := @Nightstream.Chip8.RomScheduleBinding.ScheduleLengthBound
abbrev ScheduleStepBound := @Nightstream.Chip8.RomScheduleBinding.ScheduleStepBound
abbrev ProgramDigestBound := @Nightstream.Chip8.RomScheduleBinding.ProgramDigestBound
abbrev ProgramShapeBound := @Nightstream.Chip8.RomScheduleBinding.ProgramShapeBound
abbrev PadRowMetadataBound := @Nightstream.Chip8.RomScheduleBinding.PadRowMetadataBound
abbrev InitialStateDigestBound :=
  @Nightstream.Chip8.RomScheduleBinding.InitialStateDigestBound
abbrev RootParamsBound := @Nightstream.Chip8.RomScheduleBinding.RootParamsBound
abbrev AuthenticatedRom := @Nightstream.Chip8.RomScheduleBinding.AuthenticatedRom
abbrev AuthenticatedSchedule := @Nightstream.Chip8.RomScheduleBinding.AuthenticatedSchedule
abbrev AuthenticatedStepSchedule := @Nightstream.Chip8.RomScheduleBinding.AuthenticatedStepSchedule
abbrev AuthenticatedProgramImage :=
  @Nightstream.Chip8.RomScheduleBinding.AuthenticatedProgramImage
abbrev AuthenticatedInitialState :=
  @Nightstream.Chip8.RomScheduleBinding.AuthenticatedInitialState
abbrev AuthenticatedKernelMeta :=
  @Nightstream.Chip8.RomScheduleBinding.AuthenticatedKernelMeta
abbrev ExecutionInputsBound := @Nightstream.Chip8.RomScheduleBinding.ExecutionInputsBound
abbrev KernelPublicInputsBound :=
  @Nightstream.Chip8.RomScheduleBinding.KernelPublicInputsBound

abbrev romHashBound_of_authenticatedRom :=
  @Nightstream.Chip8.RomScheduleBinding.romHashBound_of_authenticatedRom
abbrev scheduleDigestBound_of_authenticatedSchedule :=
  @Nightstream.Chip8.RomScheduleBinding.scheduleDigestBound_of_authenticatedSchedule
abbrev scheduleLengthBound_of_authenticatedSchedule :=
  @Nightstream.Chip8.RomScheduleBinding.scheduleLengthBound_of_authenticatedSchedule
abbrev scheduleStepBound_of_authenticatedStepSchedule :=
  @Nightstream.Chip8.RomScheduleBinding.scheduleStepBound_of_authenticatedStepSchedule
abbrev executionInputsBound_of_authenticatedInputs :=
  @Nightstream.Chip8.RomScheduleBinding.executionInputsBound_of_authenticatedInputs
abbrev padRowMetadataBound_semanticRows_pos :=
  @Nightstream.Chip8.RomScheduleBinding.padRowMetadataBound_semanticRows_pos
abbrev padRowMetadataBound_semanticRows_le_padded :=
  @Nightstream.Chip8.RomScheduleBinding.padRowMetadataBound_semanticRows_le_padded
abbrev padRowMetadataBound_paddedTraceLength :=
  @Nightstream.Chip8.RomScheduleBinding.padRowMetadataBound_paddedTraceLength
abbrev padRowMetadataBound_padPcWord :=
  @Nightstream.Chip8.RomScheduleBinding.padRowMetadataBound_padPcWord
abbrev padRowMetadataBound_powerOfTwo :=
  @Nightstream.Chip8.RomScheduleBinding.padRowMetadataBound_powerOfTwo
abbrev kernelPublicInputsBound_of_authenticatedInputs :=
  @Nightstream.Chip8.RomScheduleBinding.kernelPublicInputsBound_of_authenticatedInputs
abbrev rom_eq_of_sharedDigest :=
  @Nightstream.Chip8.RomScheduleBinding.rom_eq_of_sharedDigest
abbrev romTable_eq_of_sharedMeta :=
  @Nightstream.Chip8.RomScheduleBinding.romTable_eq_of_sharedMeta
abbrev schedule_eq_of_sharedDigest :=
  @Nightstream.Chip8.RomScheduleBinding.schedule_eq_of_sharedDigest
abbrev initialState_eq_of_sharedMeta :=
  @Nightstream.Chip8.RomScheduleBinding.initialState_eq_of_sharedMeta
abbrev fetchDecodeBound_of_sharedDigest :=
  @Nightstream.Chip8.RomScheduleBinding.fetchDecodeBound_of_sharedDigest
abbrev stepCompositionScheduleBound_of_authenticatedStepSchedule :=
  @Nightstream.Chip8.RomScheduleBinding.stepCompositionScheduleBound_of_authenticatedStepSchedule

end RomScheduleBindingInterface

end Nightstream.Chip8

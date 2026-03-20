import Nightstream.Chip8.Kernel.SoundnessAccounting

namespace Nightstream.Chip8

namespace SoundnessAccountingInterface

abbrev Stage1ShoutChannel :=
  Nightstream.Chip8.SoundnessAccounting.Stage1ShoutChannel
abbrev stage1ShoutChannels :=
  Nightstream.Chip8.SoundnessAccounting.stage1ShoutChannels
abbrev AddressFamily := Nightstream.Chip8.SoundnessAccounting.AddressFamily
abbrev stage1AddressFamily :=
  Nightstream.Chip8.SoundnessAccounting.stage1AddressFamily
abbrev regAddressFamilies :=
  Nightstream.Chip8.SoundnessAccounting.regAddressFamilies
abbrev ramAddressFamilies :=
  Nightstream.Chip8.SoundnessAccounting.ramAddressFamilies
abbrev TwistReadFamily := Nightstream.Chip8.SoundnessAccounting.TwistReadFamily
abbrev regReadFamilies := Nightstream.Chip8.SoundnessAccounting.regReadFamilies
abbrev TwistMemoryFamily :=
  Nightstream.Chip8.SoundnessAccounting.TwistMemoryFamily
abbrev KernelSoundnessTerms :=
  Nightstream.Chip8.SoundnessAccounting.KernelSoundnessTerms
abbrev PrimitiveNegligibility :=
  Nightstream.Chip8.SoundnessAccounting.PrimitiveNegligibility
abbrev sumErrorFns := Nightstream.Chip8.SoundnessAccounting.sumErrorFns
abbrev epsStage1 := Nightstream.Chip8.SoundnessAccounting.epsStage1
abbrev epsStage2 := Nightstream.Chip8.SoundnessAccounting.epsStage2
abbrev epsStage3 := Nightstream.Chip8.SoundnessAccounting.epsStage3
abbrev epsBatch := Nightstream.Chip8.SoundnessAccounting.epsBatch
abbrev epsTotalUpper := Nightstream.Chip8.SoundnessAccounting.epsTotalUpper
abbrev KernelSoundnessAccounting :=
  Nightstream.Chip8.SoundnessAccounting.KernelSoundnessAccounting
abbrev stage1ShoutChannels_nodup :=
  Nightstream.Chip8.SoundnessAccounting.stage1ShoutChannels_nodup
abbrev regReadFamilies_nodup :=
  Nightstream.Chip8.SoundnessAccounting.regReadFamilies_nodup
abbrev regAddressFamilies_nodup :=
  Nightstream.Chip8.SoundnessAccounting.regAddressFamilies_nodup
abbrev ramAddressFamilies_nodup :=
  Nightstream.Chip8.SoundnessAccounting.ramAddressFamilies_nodup
abbrev isNegligible_of_le :=
  @Nightstream.Chip8.SoundnessAccounting.isNegligible_of_le
abbrev isNegligible_sumErrorFns :=
  @Nightstream.Chip8.SoundnessAccounting.isNegligible_sumErrorFns
abbrev isNegligible_sumErrorFns_map :=
  @Nightstream.Chip8.SoundnessAccounting.isNegligible_sumErrorFns_map
abbrev negligible_epsStage1 :=
  @Nightstream.Chip8.SoundnessAccounting.negligible_epsStage1
abbrev negligible_epsStage2 :=
  @Nightstream.Chip8.SoundnessAccounting.negligible_epsStage2
abbrev negligible_epsStage3 :=
  @Nightstream.Chip8.SoundnessAccounting.negligible_epsStage3
abbrev negligible_epsBatch :=
  @Nightstream.Chip8.SoundnessAccounting.negligible_epsBatch
abbrev negligible_epsTotalUpper :=
  @Nightstream.Chip8.SoundnessAccounting.negligible_epsTotalUpper
abbrev KernelSoundnessAccounting.negligible_epsTotal :=
  Nightstream.Chip8.SoundnessAccounting.KernelSoundnessAccounting.negligible_epsTotal

end SoundnessAccountingInterface

end Nightstream.Chip8

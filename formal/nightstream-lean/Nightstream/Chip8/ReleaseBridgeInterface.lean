import Nightstream.Chip8.ReleaseBridge

namespace Nightstream.Chip8

namespace ReleaseBridgeInterface

abbrev ReleaseStage := Nightstream.Chip8.ReleaseStage
abbrev familyStage := Nightstream.Chip8.familyStage
abbrev stageFamilies := Nightstream.Chip8.stageFamilies

abbrev familyStage_bytecodeFetch := Nightstream.Chip8.familyStage_bytecodeFetch
abbrev familyStage_instructionSemanticsLookup :=
  Nightstream.Chip8.familyStage_instructionSemanticsLookup
abbrev familyStage_registerHistory := Nightstream.Chip8.familyStage_registerHistory
abbrev familyStage_ramHistory := Nightstream.Chip8.familyStage_ramHistory
abbrev mem_stageFamilies_iff := @Nightstream.Chip8.mem_stageFamilies_iff
abbrev family_mem_stageFamilies := Nightstream.Chip8.family_mem_stageFamilies

abbrev ReadonlyBatchBundle := Nightstream.Chip8.ReadonlyBatchBundle
abbrev ReadonlyBatchBundleBound := Nightstream.Chip8.ReadonlyBatchBundleBound
noncomputable abbrev readonlyBatchBundle_of_fetchDecodeBound :=
  @Nightstream.Chip8.readonlyBatchBundle_of_fetchDecodeBound
abbrev readonlyBatchBundleBound_of_fetchDecodeBound :=
  @Nightstream.Chip8.readonlyBatchBundleBound_of_fetchDecodeBound
abbrev readonlyBatchBundle_opcodeAt := @Nightstream.Chip8.readonlyBatchBundle_opcodeAt
abbrev readonlyBatchBundle_lookup_zero_of_noLookup :=
  @Nightstream.Chip8.readonlyBatchBundle_lookup_zero_of_noLookup
abbrev readonlyBatchBundle_burst_zero_of_nonMem :=
  @Nightstream.Chip8.readonlyBatchBundle_burst_zero_of_nonMem

abbrev HistoryBundle := @Nightstream.Chip8.HistoryBundle
abbrev HistoryBundleBound := @Nightstream.Chip8.HistoryBundleBound
noncomputable abbrev historyBundle_of_exactTrace :=
  @Nightstream.Chip8.historyBundle_of_exactTrace
abbrev historyBundleBound_of_exactTrace :=
  @Nightstream.Chip8.historyBundleBound_of_exactTrace

end ReleaseBridgeInterface

end Nightstream.Chip8

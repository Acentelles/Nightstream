import Nightstream.Chip8.Stage2.RamHistoryProjection

namespace Nightstream.Chip8

namespace RamHistoryProjectionInterface

abbrev ramHistoryFamily := Nightstream.Chip8.ramHistoryFamily
abbrev RamHistoryBundle := @Nightstream.Chip8.RamHistoryBundle
abbrev RamHistoryBundleBound := @Nightstream.Chip8.RamHistoryBundleBound
noncomputable abbrev ramHistoryBundle_of_exactTrace :=
  @Nightstream.Chip8.ramHistoryBundle_of_exactTrace
abbrev ramHistoryBundleBound_of_exactTrace :=
  @Nightstream.Chip8.ramHistoryBundleBound_of_exactTrace
abbrev ramHistoryBundle_initialRamValue :=
  @Nightstream.Chip8.ramHistoryBundle_initialRamValue
abbrev ramHistoryBundle_initialRamSinkValue :=
  @Nightstream.Chip8.ramHistoryBundle_initialRamSinkValue
abbrev loadRamReads_eq_roleValues_tracewise :=
  @Nightstream.Chip8.loadRamReads_eq_roleValues_tracewise
abbrev storeRamWrites_eq_roleValues_tracewise :=
  @Nightstream.Chip8.storeRamWrites_eq_roleValues_tracewise
abbrev loadRamReadMemValue_eq_preRam_tracewise :=
  @Nightstream.Chip8.loadRamReadMemValue_eq_preRam_tracewise
abbrev storeRamWriteMemValue_eq_postRam_tracewise :=
  @Nightstream.Chip8.storeRamWriteMemValue_eq_postRam_tracewise
abbrev ramHistoryProjection := @Nightstream.Chip8.ramHistoryProjection
abbrev ramHistoryProjection_is_projectionFamily :=
  @Nightstream.Chip8.ramHistoryProjection_is_projectionFamily
abbrev ramHistoryProjection_not_mainLane :=
  @Nightstream.Chip8.ramHistoryProjection_not_mainLane
abbrev ramHistoryProjection_decide_eq_foldSeparate_of_supported :=
  @Nightstream.Chip8.ramHistoryProjection_decide_eq_foldSeparate_of_supported
abbrev ramHistoryProjection_decide_eq_exportFinal_of_unsupported :=
  @Nightstream.Chip8.ramHistoryProjection_decide_eq_exportFinal_of_unsupported

end RamHistoryProjectionInterface

end Nightstream.Chip8

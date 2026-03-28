import Nightstream.Rv64IM.Stage2.RamHistoryProjection

namespace Nightstream.Rv64IM

namespace RamHistoryProjectionInterface

abbrev ramHistoryFamily := Nightstream.Rv64IM.ramHistoryFamily
abbrev flattenRamAddr := Nightstream.Rv64IM.flattenRamAddr
abbrev RamAddressVirtualizationBound := Nightstream.Rv64IM.RamAddressVirtualizationBound
abbrev RamHistoryRow := Nightstream.Rv64IM.RamHistoryRow
abbrev RamHistoryRowBound := @Nightstream.Rv64IM.RamHistoryRowBound
abbrev RamHistoryBundle := Nightstream.Rv64IM.RamHistoryBundle
abbrev flattenRamAddr_nil := @Nightstream.Rv64IM.flattenRamAddr_nil
abbrev flattenRamAddr_cons := @Nightstream.Rv64IM.flattenRamAddr_cons
abbrev ramHistoryRowBound_memVal_of_load := @Nightstream.Rv64IM.ramHistoryRowBound_memVal_of_load
abbrev ramHistoryRowBound_storePayload := @Nightstream.Rv64IM.ramHistoryRowBound_storePayload
abbrev ramHistoryRowBound_zeroDelta_of_not_store :=
  @Nightstream.Rv64IM.ramHistoryRowBound_zeroDelta_of_not_store
abbrev ramHistoryProjection := @Nightstream.Rv64IM.ramHistoryProjection
abbrev ramHistoryProjection_is_projectionFamily :=
  @Nightstream.Rv64IM.ramHistoryProjection_is_projectionFamily
abbrev ramHistoryProjection_not_mainLane :=
  @Nightstream.Rv64IM.ramHistoryProjection_not_mainLane
abbrev ramHistoryProjection_decide_eq_foldSeparate_of_supported :=
  @Nightstream.Rv64IM.ramHistoryProjection_decide_eq_foldSeparate_of_supported
abbrev ramHistoryProjection_decide_eq_exportFinal_of_unsupported :=
  @Nightstream.Rv64IM.ramHistoryProjection_decide_eq_exportFinal_of_unsupported

end RamHistoryProjectionInterface

end Nightstream.Rv64IM

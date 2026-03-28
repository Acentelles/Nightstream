import Nightstream.Rv64IM.ReleaseBridge

namespace Nightstream.Rv64IM

namespace ReleaseBridgeInterface

abbrev ReleaseStage := Nightstream.Rv64IM.ReleaseStage
abbrev releaseStageOrder := Nightstream.Rv64IM.releaseStageOrder
abbrev familyStage := Nightstream.Rv64IM.familyStage
abbrev stageFamilies := Nightstream.Rv64IM.stageFamilies

abbrev familyStage_fetch := Nightstream.Rv64IM.familyStage_fetch
abbrev familyStage_executionRow := Nightstream.Rv64IM.familyStage_executionRow
abbrev familyStage_aluSubtables := Nightstream.Rv64IM.familyStage_aluSubtables
abbrev familyStage_branchCondition := Nightstream.Rv64IM.familyStage_branchCondition
abbrev familyStage_registerHistory := Nightstream.Rv64IM.familyStage_registerHistory
abbrev familyStage_ramHistory := Nightstream.Rv64IM.familyStage_ramHistory
abbrev mem_stageFamilies_iff := @Nightstream.Rv64IM.mem_stageFamilies_iff
abbrev family_mem_stageFamilies := Nightstream.Rv64IM.family_mem_stageFamilies

abbrev releaseShape := Nightstream.Rv64IM.releaseShape
abbrev releaseShape_stageInventoryConsistent :=
  Nightstream.Rv64IM.releaseShape_stageInventoryConsistent

end ReleaseBridgeInterface

end Nightstream.Rv64IM

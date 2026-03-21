import Nightstream.Rv64IM.StagedBridge

namespace Nightstream.Rv64IM

namespace StagedBridgeInterface

abbrev ReleaseStageView := Nightstream.Rv64IM.ReleaseStageView
abbrev releaseStageView := Nightstream.Rv64IM.releaseStageView
abbrev canonicalStageViews := Nightstream.Rv64IM.canonicalStageViews
abbrev ReleaseBridgePublicView := Nightstream.Rv64IM.ReleaseBridgePublicView
abbrev ReleaseBridgePublicViewBound := Nightstream.Rv64IM.ReleaseBridgePublicViewBound
abbrev releaseBridgePublicView_of_preparedStepCount :=
  Nightstream.Rv64IM.releaseBridgePublicView_of_preparedStepCount
abbrev releaseBridgePublicViewBound_of_preparedStepCount :=
  Nightstream.Rv64IM.releaseBridgePublicViewBound_of_preparedStepCount
abbrev canonicalStageViews_stage_eq := Nightstream.Rv64IM.canonicalStageViews_stage_eq

abbrev StagePayload := @Nightstream.Rv64IM.StagePayload
abbrev StagedBridgeArtifact := @Nightstream.Rv64IM.StagedBridgeArtifact
abbrev stagedBridgeArtifact_of_parts := @Nightstream.Rv64IM.stagedBridgeArtifact_of_parts
abbrev chunkCount_eq_one := @Nightstream.Rv64IM.chunkCount_eq_one
abbrev preparedStepCount_matches_publicView :=
  @Nightstream.Rv64IM.preparedStepCount_matches_publicView
abbrev publicStages_eq_canonical := @Nightstream.Rv64IM.publicStages_eq_canonical

end StagedBridgeInterface

end Nightstream.Rv64IM

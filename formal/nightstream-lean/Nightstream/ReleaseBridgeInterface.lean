import Nightstream.ReleaseBridge

namespace Nightstream

namespace ReleaseBridgeInterface

abbrev ReleaseShape := Nightstream.ReleaseShape
abbrev StageInventoryConsistent := @Nightstream.StageInventoryConsistent

abbrev ReleaseStageView := Nightstream.ReleaseStageView
abbrev releaseStageView := @Nightstream.releaseStageView
abbrev canonicalStageViews := @Nightstream.canonicalStageViews
abbrev mem_stageFamilies_iff := @Nightstream.mem_stageFamilies_iff
abbrev canonicalStageViews_stage_eq := @Nightstream.canonicalStageViews_stage_eq

abbrev ReleaseBridgePublicView := Nightstream.ReleaseBridgePublicView
abbrev ReleaseBridgePublicViewBound := @Nightstream.ReleaseBridgePublicViewBound
abbrev releaseBridgePublicView_of_preparedStepCount :=
  @Nightstream.releaseBridgePublicView_of_preparedStepCount
abbrev releaseBridgePublicViewBound_of_preparedStepCount :=
  @Nightstream.releaseBridgePublicViewBound_of_preparedStepCount

end ReleaseBridgeInterface

end Nightstream

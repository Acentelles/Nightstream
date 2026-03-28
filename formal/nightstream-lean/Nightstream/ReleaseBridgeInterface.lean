import Nightstream.ReleaseBridge

namespace Nightstream

namespace ReleaseBridgeInterface

abbrev FoldSchedule := Nightstream.FoldSchedule

abbrev ReleaseShape := Nightstream.ReleaseShape
abbrev StageInventoryConsistent := @Nightstream.StageInventoryConsistent

abbrev ReleaseStageView := Nightstream.ReleaseStageView
abbrev releaseStageView := @Nightstream.releaseStageView
abbrev canonicalStageViews := @Nightstream.canonicalStageViews
abbrev mem_stageFamilies_iff := @Nightstream.mem_stageFamilies_iff
abbrev canonicalStageViews_stage_eq := @Nightstream.canonicalStageViews_stage_eq

abbrev ReleaseBridgePublicView := Nightstream.ReleaseBridgePublicView
abbrev ReleaseBridgePublicViewBound := @Nightstream.ReleaseBridgePublicViewBound
abbrev releaseBridgePublicView_of_schedule :=
  @Nightstream.releaseBridgePublicView_of_schedule
abbrev releaseBridgePublicView_of_preparedStepCount :=
  @Nightstream.releaseBridgePublicView_of_preparedStepCount
abbrev releaseBridgePublicViewBound_of_schedule :=
  @Nightstream.releaseBridgePublicViewBound_of_schedule
abbrev releaseBridgePublicViewBound_of_preparedStepCount :=
  @Nightstream.releaseBridgePublicViewBound_of_preparedStepCount
abbrev foldSchedule_eq_wholeTrace_of_preparedStepCount :=
  @Nightstream.foldSchedule_eq_wholeTrace_of_preparedStepCount
abbrev chunkCount_eq_one_of_preparedStepCount :=
  @Nightstream.chunkCount_eq_one_of_preparedStepCount

end ReleaseBridgeInterface

end Nightstream

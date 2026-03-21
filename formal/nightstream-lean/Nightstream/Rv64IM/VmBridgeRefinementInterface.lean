import Nightstream.Rv64IM.VmBridgeRefinement

namespace Nightstream.Rv64IM

namespace VmBridgeRefinementInterface

abbrev toGenericReleaseStageView := Nightstream.Rv64IM.toGenericReleaseStageView
abbrev toGenericPublicView := Nightstream.Rv64IM.toGenericPublicView
abbrev canonicalStageViews_refine := Nightstream.Rv64IM.canonicalStageViews_refine
abbrev toGenericPublicView_of_preparedStepCount :=
  Nightstream.Rv64IM.toGenericPublicView_of_preparedStepCount
abbrev releaseBridge_refines_generic := Nightstream.Rv64IM.releaseBridge_refines_generic
abbrev publicViewBound_refines := @Nightstream.Rv64IM.publicViewBound_refines

noncomputable abbrev canonicalStagePayloads_of_artifact :=
  @Nightstream.Rv64IM.canonicalStagePayloads_of_artifact
noncomputable abbrev toGenericStagedBridgeArtifact :=
  @Nightstream.Rv64IM.toGenericStagedBridgeArtifact
abbrev toGenericStagedBridgeArtifact_publicViewBound :=
  @Nightstream.Rv64IM.toGenericStagedBridgeArtifact_publicViewBound

end VmBridgeRefinementInterface

end Nightstream.Rv64IM

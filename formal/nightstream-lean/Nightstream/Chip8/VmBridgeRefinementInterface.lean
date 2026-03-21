import Nightstream.Chip8.VmBridgeRefinement

namespace Nightstream.Chip8

namespace VmBridgeRefinementInterface

abbrev releaseStageOrder := Nightstream.Chip8.releaseStageOrder
abbrev releaseShape := Nightstream.Chip8.releaseShape
abbrev releaseShape_stageInventoryConsistent :=
  Nightstream.Chip8.releaseShape_stageInventoryConsistent

abbrev toGenericReleaseStageView := Nightstream.Chip8.toGenericReleaseStageView
abbrev toGenericPublicView := Nightstream.Chip8.toGenericPublicView
abbrev canonicalStageViews_refine := Nightstream.Chip8.canonicalStageViews_refine
abbrev toGenericPublicView_of_preparedStepCount :=
  Nightstream.Chip8.toGenericPublicView_of_preparedStepCount
abbrev releaseBridge_refines_generic := Nightstream.Chip8.releaseBridge_refines_generic
abbrev publicViewBound_refines := @Nightstream.Chip8.publicViewBound_refines

abbrev StagePayload := @Nightstream.Chip8.StagePayload
noncomputable abbrev canonicalStagePayloads_of_artifact :=
  @Nightstream.Chip8.canonicalStagePayloads_of_artifact
noncomputable abbrev toGenericStagedBridgeArtifact :=
  @Nightstream.Chip8.toGenericStagedBridgeArtifact
abbrev toGenericStagedBridgeArtifact_publicViewBound :=
  @Nightstream.Chip8.toGenericStagedBridgeArtifact_publicViewBound

end VmBridgeRefinementInterface

end Nightstream.Chip8

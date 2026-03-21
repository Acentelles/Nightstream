import Nightstream.Chip8.StagedBridge

namespace Nightstream.Chip8

namespace StagedBridgeInterface

abbrev ReleaseStageView := Nightstream.Chip8.ReleaseStageView
abbrev releaseStageView := Nightstream.Chip8.releaseStageView
abbrev canonicalStageViews := Nightstream.Chip8.canonicalStageViews
abbrev ReleaseBridgePublicView := Nightstream.Chip8.ReleaseBridgePublicView
abbrev ReleaseBridgePublicViewBound := Nightstream.Chip8.ReleaseBridgePublicViewBound
abbrev releaseBridgePublicView_of_preparedStepCount :=
  Nightstream.Chip8.releaseBridgePublicView_of_preparedStepCount
abbrev releaseBridgePublicViewBound_of_preparedStepCount :=
  Nightstream.Chip8.releaseBridgePublicViewBound_of_preparedStepCount
abbrev canonicalStageViews_stage_eq := Nightstream.Chip8.canonicalStageViews_stage_eq

abbrev bridgePreparedSteps := @Nightstream.Chip8.bridgePreparedSteps
abbrev ReadonlyBatchTraceBundle := @Nightstream.Chip8.ReadonlyBatchTraceBundle
abbrev readonlyBatchTraceBundle_length_eq := @Nightstream.Chip8.readonlyBatchTraceBundle_length_eq
noncomputable abbrev readonlyBatchFrameBundle_of_exactFrame :=
  @Nightstream.Chip8.readonlyBatchFrameBundle_of_exactFrame
noncomputable abbrev readonlyBatchTraceBundle_of_frames :=
  @Nightstream.Chip8.readonlyBatchTraceBundle_of_frames
abbrev preparedStepTrace_of_exactTrace := @Nightstream.Chip8.preparedStepTrace_of_exactTrace
abbrev preparedStepCount_of_exactTrace := @Nightstream.Chip8.preparedStepCount_of_exactTrace

abbrev StagedBridgeArtifact := @Nightstream.Chip8.StagedBridgeArtifact
noncomputable abbrev stagedBridgeArtifact_of_exactTrace :=
  @Nightstream.Chip8.stagedBridgeArtifact_of_exactTrace
abbrev readonlyBatchLength_of_artifact := @Nightstream.Chip8.readonlyBatchLength_of_artifact
abbrev preparedStepCount_matches_publicView :=
  @Nightstream.Chip8.preparedStepCount_matches_publicView

end StagedBridgeInterface

end Nightstream.Chip8

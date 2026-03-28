import Nightstream.ReleaseBridge

namespace Nightstream

def CanonicalStagePayloads
  {Stage : Type*}
  (stageOrder : List Stage)
  (StagePayload : Stage → Type*) : Type _ :=
  { payloads : List (Sigma StagePayload) // payloads.map Sigma.fst = stageOrder }

namespace CanonicalStagePayloads

def length
  {Stage : Type*}
  {stageOrder : List Stage}
  {StagePayload : Stage → Type*}
  (payloads : CanonicalStagePayloads stageOrder StagePayload) : Nat :=
  payloads.1.length

end CanonicalStagePayloads

theorem canonicalStagePayloads_length_eq
  {Stage : Type*}
  {stageOrder : List Stage}
  {StagePayload : Stage → Type*}
  (payloads : CanonicalStagePayloads stageOrder StagePayload) :
  payloads.length = stageOrder.length := by
  have hLen := congrArg List.length payloads.2
  simpa [CanonicalStagePayloads.length] using hLen

structure StagedBridgeArtifact
  {Stage Family PreparedStep PreparedTrace : Type*}
  (shape : ReleaseShape Stage Family)
  (PreparedTraceBound : PreparedTrace → List PreparedStep → Prop)
  (StagePayload : Stage → Type*) where
  publicView : ReleaseBridgePublicView Stage Family
  preparedSteps : List PreparedStep
  preparedTrace : PreparedTrace
  preparedTraceBound : PreparedTraceBound preparedTrace preparedSteps
  stagePayloads : CanonicalStagePayloads shape.stageOrder StagePayload
  publicViewBound : ReleaseBridgePublicViewBound shape publicView preparedSteps.length

def stagedBridgeArtifact_of_parts
  {Stage Family PreparedStep PreparedTrace : Type*}
  (shape : ReleaseShape Stage Family)
  (PreparedTraceBound : PreparedTrace → List PreparedStep → Prop)
  (StagePayload : Stage → Type*)
  (schedule : FoldSchedule)
  (hSchedule : FoldSchedule.Valid schedule)
  (preparedSteps : List PreparedStep)
  (preparedTrace : PreparedTrace)
  (hTrace : PreparedTraceBound preparedTrace preparedSteps)
  (stagePayloads : CanonicalStagePayloads shape.stageOrder StagePayload) :
  StagedBridgeArtifact shape PreparedTraceBound StagePayload :=
  { publicView := releaseBridgePublicView_of_schedule shape schedule preparedSteps.length
    preparedSteps := preparedSteps
    preparedTrace := preparedTrace
    preparedTraceBound := hTrace
    stagePayloads := stagePayloads
    publicViewBound := releaseBridgePublicViewBound_of_schedule shape
      (preparedStepCount := preparedSteps.length)
      (schedule := schedule)
      hSchedule }

theorem chunkCount_matches_schedule
  {Stage Family PreparedStep PreparedTrace : Type*}
  {shape : ReleaseShape Stage Family}
  {PreparedTraceBound : PreparedTrace → List PreparedStep → Prop}
  {StagePayload : Stage → Type*}
  (artifact : StagedBridgeArtifact shape PreparedTraceBound StagePayload) :
  artifact.publicView.chunkCount =
    FoldSchedule.chunkCount artifact.publicView.foldSchedule artifact.preparedSteps.length :=
  artifact.publicViewBound.2.1

theorem foldSchedule_valid
  {Stage Family PreparedStep PreparedTrace : Type*}
  {shape : ReleaseShape Stage Family}
  {PreparedTraceBound : PreparedTrace → List PreparedStep → Prop}
  {StagePayload : Stage → Type*}
  (artifact : StagedBridgeArtifact shape PreparedTraceBound StagePayload) :
  FoldSchedule.Valid artifact.publicView.foldSchedule :=
  artifact.publicViewBound.1

theorem preparedStepCount_matches_publicView
  {Stage Family PreparedStep PreparedTrace : Type*}
  {shape : ReleaseShape Stage Family}
  {PreparedTraceBound : PreparedTrace → List PreparedStep → Prop}
  {StagePayload : Stage → Type*}
  (artifact : StagedBridgeArtifact shape PreparedTraceBound StagePayload) :
  artifact.publicView.preparedStepCount = artifact.preparedSteps.length :=
  artifact.publicViewBound.2.2.1

theorem publicStages_eq_canonical
  {Stage Family PreparedStep PreparedTrace : Type*}
  {shape : ReleaseShape Stage Family}
  {PreparedTraceBound : PreparedTrace → List PreparedStep → Prop}
  {StagePayload : Stage → Type*}
  (artifact : StagedBridgeArtifact shape PreparedTraceBound StagePayload) :
  artifact.publicView.stages = canonicalStageViews shape :=
  artifact.publicViewBound.2.2.2

theorem stagePayloadCount_matches_stageOrder
  {Stage Family PreparedStep PreparedTrace : Type*}
  {shape : ReleaseShape Stage Family}
  {PreparedTraceBound : PreparedTrace → List PreparedStep → Prop}
  {StagePayload : Stage → Type*}
  (artifact : StagedBridgeArtifact shape PreparedTraceBound StagePayload) :
  artifact.stagePayloads.length = shape.stageOrder.length :=
  canonicalStagePayloads_length_eq artifact.stagePayloads

end Nightstream

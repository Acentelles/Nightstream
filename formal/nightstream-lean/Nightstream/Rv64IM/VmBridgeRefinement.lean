import Nightstream.VmBridgeRefinement
import Nightstream.Rv64IM.StagedBridge

namespace Nightstream.Rv64IM

def toGenericReleaseStageView
  (view : ReleaseStageView) :
  Nightstream.ReleaseStageView ReleaseStage ExtensionFamily :=
  { stage := view.stage
    families := view.families }

def toGenericPublicView
  (view : ReleaseBridgePublicView) :
  Nightstream.ReleaseBridgePublicView ReleaseStage ExtensionFamily :=
  { foldSchedule := view.foldSchedule
    chunkCount := view.chunkCount
    preparedStepCount := view.preparedStepCount
    stages := view.stages.map toGenericReleaseStageView }

theorem canonicalStageViews_refine :
  canonicalStageViews.map toGenericReleaseStageView =
    Nightstream.canonicalStageViews releaseShape := by
  simp [canonicalStageViews, Nightstream.canonicalStageViews, releaseShape,
    releaseStageOrder, toGenericReleaseStageView, releaseStageView,
    Nightstream.releaseStageView, stageFamilies]

theorem toGenericPublicView_of_schedule
  (schedule : Nightstream.FoldSchedule)
  (preparedStepCount : Nat) :
  toGenericPublicView (releaseBridgePublicView_of_schedule schedule preparedStepCount) =
    Nightstream.releaseBridgePublicView_of_schedule
      releaseShape
      schedule
      preparedStepCount := by
  simp [toGenericPublicView, releaseBridgePublicView_of_schedule,
    Nightstream.releaseBridgePublicView_of_schedule,
    canonicalStageViews_refine]

theorem toGenericPublicView_of_preparedStepCount
  (preparedStepCount : Nat) :
  toGenericPublicView (releaseBridgePublicView_of_preparedStepCount preparedStepCount) =
    Nightstream.releaseBridgePublicView_of_preparedStepCount
      releaseShape
      preparedStepCount := by
  simp [releaseBridgePublicView_of_preparedStepCount,
    Nightstream.releaseBridgePublicView_of_preparedStepCount,
    toGenericPublicView_of_schedule]

theorem releaseBridge_refines_generic :
  Nightstream.RefinesReleaseBridge
    releaseShape
    toGenericReleaseStageView
    canonicalStageViews
    toGenericPublicView
    ReleaseBridgePublicViewBound := by
  constructor
  · exact canonicalStageViews_refine
  · intro view preparedStepCount hView
    rcases hView with ⟨hValid, hChunk, hPrepared, hStages⟩
    refine ⟨hValid, hChunk, hPrepared, ?_⟩
    calc
      (toGenericPublicView view).stages = view.stages.map toGenericReleaseStageView := rfl
      _ = canonicalStageViews.map toGenericReleaseStageView := by
        simp [hStages]
      _ = Nightstream.canonicalStageViews releaseShape := canonicalStageViews_refine

theorem publicViewBound_refines
  {view : ReleaseBridgePublicView}
  {preparedStepCount : Nat}
  (hView : ReleaseBridgePublicViewBound view preparedStepCount) :
  Nightstream.ReleaseBridgePublicViewBound
    releaseShape
    (toGenericPublicView view)
    preparedStepCount := by
  exact
    Nightstream.releaseBridgePublicViewBound_of_refines
      releaseBridge_refines_generic
      hView

section Bridge

variable
  {PreparedStep PreparedTrace ReadonlyBatchPayload RegisterHistoryPayload RamHistoryPayload : Type*}
  {PreparedTraceBound : PreparedTrace → List PreparedStep → Prop}

noncomputable def canonicalStagePayloads_of_artifact
  (artifact :
    StagedBridgeArtifact
      PreparedStep
      PreparedTrace
      ReadonlyBatchPayload
      RegisterHistoryPayload
      RamHistoryPayload
      PreparedTraceBound) :
  Nightstream.CanonicalStagePayloads
    releaseShape.stageOrder
    (StagePayload ReadonlyBatchPayload RegisterHistoryPayload RamHistoryPayload) := by
  refine ⟨[⟨.readonlyBatch, StagePayload.readonlyBatch artifact.readonlyBatch⟩,
      ⟨.registerHistory, StagePayload.registerHistory artifact.registerHistory⟩,
      ⟨.ramHistory, StagePayload.ramHistory artifact.ramHistory⟩], ?_⟩
  simp [releaseShape, releaseStageOrder]

noncomputable def toGenericStagedBridgeArtifact
  (artifact :
    StagedBridgeArtifact
      PreparedStep
      PreparedTrace
      ReadonlyBatchPayload
      RegisterHistoryPayload
      RamHistoryPayload
      PreparedTraceBound) :=
    Nightstream.stagedBridgeArtifact_of_parts
      releaseShape
      PreparedTraceBound
      (StagePayload ReadonlyBatchPayload RegisterHistoryPayload RamHistoryPayload)
      artifact.publicView.foldSchedule
      (foldSchedule_valid artifact)
      artifact.preparedSteps
      artifact.preparedTrace
      artifact.preparedTraceBound
      (canonicalStagePayloads_of_artifact artifact)

theorem toGenericStagedBridgeArtifact_publicViewBound
  (artifact :
    StagedBridgeArtifact
      PreparedStep
      PreparedTrace
      ReadonlyBatchPayload
      RegisterHistoryPayload
      RamHistoryPayload
      PreparedTraceBound) :
  Nightstream.ReleaseBridgePublicViewBound
    releaseShape
    (toGenericStagedBridgeArtifact artifact).publicView
    artifact.preparedSteps.length :=
  (toGenericStagedBridgeArtifact artifact).publicViewBound

end Bridge

end Nightstream.Rv64IM

import Nightstream.StagedBridge
import Nightstream.Rv64IM.ReleaseBridge

namespace Nightstream.Rv64IM

structure ReleaseStageView where
  stage : ReleaseStage
  families : List ExtensionFamily
deriving DecidableEq, Repr

def releaseStageView (stage : ReleaseStage) : ReleaseStageView :=
  ⟨stage, stageFamilies stage⟩

def canonicalStageViews : List ReleaseStageView :=
  releaseStageOrder.map releaseStageView

structure ReleaseBridgePublicView where
  foldSchedule : Nightstream.FoldSchedule
  chunkCount : Nat
  preparedStepCount : Nat
  stages : List ReleaseStageView
deriving DecidableEq, Repr

def ReleaseBridgePublicViewBound
  (view : ReleaseBridgePublicView)
  (preparedStepCount : Nat) : Prop :=
  Nightstream.FoldSchedule.Valid view.foldSchedule ∧
    view.chunkCount =
      Nightstream.FoldSchedule.chunkCount view.foldSchedule preparedStepCount ∧
    view.preparedStepCount = preparedStepCount ∧
    view.stages = canonicalStageViews

def releaseBridgePublicView_of_schedule
  (schedule : Nightstream.FoldSchedule)
  (preparedStepCount : Nat) : ReleaseBridgePublicView :=
  { foldSchedule := schedule
    chunkCount := Nightstream.FoldSchedule.chunkCount schedule preparedStepCount
    preparedStepCount := preparedStepCount
    stages := canonicalStageViews }

def releaseBridgePublicView_of_preparedStepCount
  (preparedStepCount : Nat) : ReleaseBridgePublicView :=
  releaseBridgePublicView_of_schedule .wholeTrace preparedStepCount

theorem releaseBridgePublicViewBound_of_schedule
  {schedule : Nightstream.FoldSchedule}
  (hValid : Nightstream.FoldSchedule.Valid schedule)
  (preparedStepCount : Nat) :
  ReleaseBridgePublicViewBound
    (releaseBridgePublicView_of_schedule schedule preparedStepCount)
    preparedStepCount := by
  simp [ReleaseBridgePublicViewBound, releaseBridgePublicView_of_schedule, hValid,
    canonicalStageViews, releaseStageOrder, releaseStageView]

theorem releaseBridgePublicViewBound_of_preparedStepCount
  (preparedStepCount : Nat) :
  ReleaseBridgePublicViewBound
    (releaseBridgePublicView_of_preparedStepCount preparedStepCount)
    preparedStepCount := by
  simpa [releaseBridgePublicView_of_preparedStepCount] using
    releaseBridgePublicViewBound_of_schedule
      Nightstream.FoldSchedule.valid_wholeTrace
      preparedStepCount

theorem foldSchedule_eq_wholeTrace_of_preparedStepCount
  (preparedStepCount : Nat) :
  (releaseBridgePublicView_of_preparedStepCount preparedStepCount).foldSchedule = .wholeTrace := by
  rfl

theorem canonicalStageViews_stage_eq
  (stage : ReleaseStage) :
  releaseStageView stage ∈ canonicalStageViews := by
  cases stage <;> simp [canonicalStageViews, releaseStageOrder, releaseStageView]

inductive StagePayload
  (ReadonlyBatchPayload RegisterHistoryPayload RamHistoryPayload : Type*)
  : ReleaseStage → Type _ where
  | readonlyBatch :
      ReadonlyBatchPayload →
        StagePayload ReadonlyBatchPayload RegisterHistoryPayload RamHistoryPayload .readonlyBatch
  | registerHistory :
      RegisterHistoryPayload →
        StagePayload ReadonlyBatchPayload RegisterHistoryPayload RamHistoryPayload .registerHistory
  | ramHistory :
      RamHistoryPayload →
        StagePayload ReadonlyBatchPayload RegisterHistoryPayload RamHistoryPayload .ramHistory

structure StagedBridgeArtifact
  (PreparedStep PreparedTrace ReadonlyBatchPayload RegisterHistoryPayload RamHistoryPayload : Type*)
  (PreparedTraceBound : PreparedTrace → List PreparedStep → Prop) where
  publicView : ReleaseBridgePublicView
  preparedSteps : List PreparedStep
  preparedTrace : PreparedTrace
  preparedTraceBound : PreparedTraceBound preparedTrace preparedSteps
  readonlyBatch : ReadonlyBatchPayload
  registerHistory : RegisterHistoryPayload
  ramHistory : RamHistoryPayload
  publicViewBound : ReleaseBridgePublicViewBound publicView preparedSteps.length

def stagedBridgeArtifact_of_parts
  {PreparedStep PreparedTrace ReadonlyBatchPayload RegisterHistoryPayload RamHistoryPayload : Type*}
  (PreparedTraceBound : PreparedTrace → List PreparedStep → Prop)
  (schedule : Nightstream.FoldSchedule)
  (hSchedule : Nightstream.FoldSchedule.Valid schedule)
  (preparedSteps : List PreparedStep)
  (preparedTrace : PreparedTrace)
  (hTrace : PreparedTraceBound preparedTrace preparedSteps)
  (readonlyBatch : ReadonlyBatchPayload)
  (registerHistory : RegisterHistoryPayload)
  (ramHistory : RamHistoryPayload) :
  StagedBridgeArtifact
    PreparedStep
    PreparedTrace
    ReadonlyBatchPayload
    RegisterHistoryPayload
    RamHistoryPayload
    PreparedTraceBound :=
  { publicView := releaseBridgePublicView_of_schedule schedule preparedSteps.length
    preparedSteps := preparedSteps
    preparedTrace := preparedTrace
    preparedTraceBound := hTrace
    readonlyBatch := readonlyBatch
    registerHistory := registerHistory
    ramHistory := ramHistory
    publicViewBound := releaseBridgePublicViewBound_of_schedule hSchedule preparedSteps.length }

theorem chunkCount_matches_schedule
  {PreparedStep PreparedTrace ReadonlyBatchPayload RegisterHistoryPayload RamHistoryPayload : Type*}
  {PreparedTraceBound : PreparedTrace → List PreparedStep → Prop}
  (artifact :
    StagedBridgeArtifact
      PreparedStep
      PreparedTrace
      ReadonlyBatchPayload
      RegisterHistoryPayload
      RamHistoryPayload
      PreparedTraceBound) :
  artifact.publicView.chunkCount =
    Nightstream.FoldSchedule.chunkCount artifact.publicView.foldSchedule artifact.preparedSteps.length :=
  artifact.publicViewBound.2.1

theorem foldSchedule_valid
  {PreparedStep PreparedTrace ReadonlyBatchPayload RegisterHistoryPayload RamHistoryPayload : Type*}
  {PreparedTraceBound : PreparedTrace → List PreparedStep → Prop}
  (artifact :
    StagedBridgeArtifact
      PreparedStep
      PreparedTrace
      ReadonlyBatchPayload
      RegisterHistoryPayload
      RamHistoryPayload
      PreparedTraceBound) :
  Nightstream.FoldSchedule.Valid artifact.publicView.foldSchedule :=
  artifact.publicViewBound.1

theorem preparedStepCount_matches_publicView
  {PreparedStep PreparedTrace ReadonlyBatchPayload RegisterHistoryPayload RamHistoryPayload : Type*}
  {PreparedTraceBound : PreparedTrace → List PreparedStep → Prop}
  (artifact :
    StagedBridgeArtifact
      PreparedStep
      PreparedTrace
      ReadonlyBatchPayload
      RegisterHistoryPayload
      RamHistoryPayload
      PreparedTraceBound) :
  artifact.publicView.preparedStepCount = artifact.preparedSteps.length :=
  artifact.publicViewBound.2.2.1

theorem publicStages_eq_canonical
  {PreparedStep PreparedTrace ReadonlyBatchPayload RegisterHistoryPayload RamHistoryPayload : Type*}
  {PreparedTraceBound : PreparedTrace → List PreparedStep → Prop}
  (artifact :
    StagedBridgeArtifact
      PreparedStep
      PreparedTrace
      ReadonlyBatchPayload
      RegisterHistoryPayload
      RamHistoryPayload
      PreparedTraceBound) :
  artifact.publicView.stages = canonicalStageViews :=
  artifact.publicViewBound.2.2.2

end Nightstream.Rv64IM

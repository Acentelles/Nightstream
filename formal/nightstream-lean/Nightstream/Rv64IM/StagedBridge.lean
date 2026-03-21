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
  chunkCount : Nat
  preparedStepCount : Nat
  stages : List ReleaseStageView
deriving DecidableEq, Repr

def ReleaseBridgePublicViewBound
  (view : ReleaseBridgePublicView)
  (preparedStepCount : Nat) : Prop :=
  view.chunkCount = 1 ∧
    view.preparedStepCount = preparedStepCount ∧
    view.stages = canonicalStageViews

def releaseBridgePublicView_of_preparedStepCount
  (preparedStepCount : Nat) : ReleaseBridgePublicView :=
  { chunkCount := 1
    preparedStepCount := preparedStepCount
    stages := canonicalStageViews }

theorem releaseBridgePublicViewBound_of_preparedStepCount
  (preparedStepCount : Nat) :
  ReleaseBridgePublicViewBound
    (releaseBridgePublicView_of_preparedStepCount preparedStepCount)
    preparedStepCount := by
  simp [ReleaseBridgePublicViewBound, releaseBridgePublicView_of_preparedStepCount,
    canonicalStageViews, releaseStageOrder, releaseStageView]

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
  { publicView := releaseBridgePublicView_of_preparedStepCount preparedSteps.length
    preparedSteps := preparedSteps
    preparedTrace := preparedTrace
    preparedTraceBound := hTrace
    readonlyBatch := readonlyBatch
    registerHistory := registerHistory
    ramHistory := ramHistory
    publicViewBound := releaseBridgePublicViewBound_of_preparedStepCount preparedSteps.length }

theorem chunkCount_eq_one
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
  artifact.publicView.chunkCount = 1 :=
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
  artifact.publicViewBound.2.1

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
  artifact.publicViewBound.2.2

end Nightstream.Rv64IM

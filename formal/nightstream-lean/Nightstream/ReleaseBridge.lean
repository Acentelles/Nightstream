import Nightstream.ShardComposition

namespace Nightstream

structure ReleaseShape (Stage Family : Type*) where
  stageOrder : List Stage
  familyStage : Family → Stage
  stageFamilies : Stage → List Family

def StageInventoryConsistent
  {Stage Family : Type*}
  (shape : ReleaseShape Stage Family) : Prop :=
  ∀ family stage, family ∈ shape.stageFamilies stage ↔ shape.familyStage family = stage

structure ReleaseStageView (Stage Family : Type*) where
  stage : Stage
  families : List Family
deriving DecidableEq, Repr

def releaseStageView
  {Stage Family : Type*}
  (stageFamilies : Stage → List Family)
  (stage : Stage) : ReleaseStageView Stage Family :=
  ⟨stage, stageFamilies stage⟩

def canonicalStageViews
  {Stage Family : Type*}
  (shape : ReleaseShape Stage Family) : List (ReleaseStageView Stage Family) :=
  shape.stageOrder.map (releaseStageView shape.stageFamilies)

theorem mem_stageFamilies_iff
  {Stage Family : Type*}
  {shape : ReleaseShape Stage Family}
  (hConsistent : StageInventoryConsistent shape)
  {family : Family}
  {stage : Stage} :
  family ∈ shape.stageFamilies stage ↔ shape.familyStage family = stage :=
  hConsistent family stage

theorem canonicalStageViews_stage_eq
  {Stage Family : Type*}
  [DecidableEq Stage]
  {shape : ReleaseShape Stage Family}
  {stage : Stage}
  (hStage : stage ∈ shape.stageOrder) :
  releaseStageView shape.stageFamilies stage ∈ canonicalStageViews shape := by
  unfold canonicalStageViews
  exact List.mem_map.mpr ⟨stage, hStage, rfl⟩

structure ReleaseBridgePublicView (Stage Family : Type*) where
  chunkCount : Nat
  preparedStepCount : Nat
  stages : List (ReleaseStageView Stage Family)
deriving DecidableEq, Repr

def ReleaseBridgePublicViewBound
  {Stage Family : Type*}
  (shape : ReleaseShape Stage Family)
  (view : ReleaseBridgePublicView Stage Family)
  (preparedStepCount : Nat) : Prop :=
  view.chunkCount = 1 ∧
    view.preparedStepCount = preparedStepCount ∧
    view.stages = canonicalStageViews shape

def releaseBridgePublicView_of_preparedStepCount
  {Stage Family : Type*}
  (shape : ReleaseShape Stage Family)
  (preparedStepCount : Nat) : ReleaseBridgePublicView Stage Family :=
  { chunkCount := 1
    preparedStepCount := preparedStepCount
    stages := canonicalStageViews shape }

theorem releaseBridgePublicViewBound_of_preparedStepCount
  {Stage Family : Type*}
  (shape : ReleaseShape Stage Family)
  (preparedStepCount : Nat) :
  ReleaseBridgePublicViewBound
    shape
    (releaseBridgePublicView_of_preparedStepCount shape preparedStepCount)
    preparedStepCount := by
  simp [ReleaseBridgePublicViewBound, releaseBridgePublicView_of_preparedStepCount]

end Nightstream

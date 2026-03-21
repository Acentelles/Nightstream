import Nightstream.StagedBridge
import Nightstream.VmBridgeRefinement
import Nightstream.Chip8.StagedBridge

namespace Nightstream.Chip8

def releaseStageOrder : List ReleaseStage :=
  [.readonlyBatch, .registerHistory, .ramHistory]

def releaseShape : Nightstream.ReleaseShape ReleaseStage ExtensionFamily :=
  { stageOrder := releaseStageOrder
    familyStage := familyStage
    stageFamilies := stageFamilies }

theorem releaseShape_stageInventoryConsistent :
  Nightstream.StageInventoryConsistent releaseShape := by
  intro family stage
  exact mem_stageFamilies_iff

def toGenericReleaseStageView
  (view : ReleaseStageView) :
  Nightstream.ReleaseStageView ReleaseStage ExtensionFamily :=
  { stage := view.stage
    families := view.families }

def toGenericPublicView
  (view : ReleaseBridgePublicView) :
  Nightstream.ReleaseBridgePublicView ReleaseStage ExtensionFamily :=
  { chunkCount := view.chunkCount
    preparedStepCount := view.preparedStepCount
    stages := view.stages.map toGenericReleaseStageView }

theorem canonicalStageViews_refine :
  canonicalStageViews.map toGenericReleaseStageView =
    Nightstream.canonicalStageViews releaseShape := by
  simp [canonicalStageViews, Nightstream.canonicalStageViews, releaseShape,
    releaseStageOrder, toGenericReleaseStageView, releaseStageView,
    Nightstream.releaseStageView, stageFamilies]

theorem toGenericPublicView_of_preparedStepCount
  (preparedStepCount : Nat) :
  toGenericPublicView (releaseBridgePublicView_of_preparedStepCount preparedStepCount) =
    Nightstream.releaseBridgePublicView_of_preparedStepCount
      releaseShape
      preparedStepCount := by
  simp [toGenericPublicView, releaseBridgePublicView_of_preparedStepCount,
    Nightstream.releaseBridgePublicView_of_preparedStepCount,
    canonicalStageViews_refine]

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
    rcases hView with ⟨hChunk, hPrepared, hStages⟩
    refine ⟨hChunk, hPrepared, ?_⟩
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
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr Table ValSurface
    Increment SessionKey : Type*}
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    EvidenceCoverage.ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {evalBase : BaseFamily Nat AuxIndex → EvalPoint → F}
  {B : Set (BaseFamily Nat AuxIndex)}
  {publicTable : Table → Prop}
  {tableBackedBy : Table → BaseFamily Nat AuxIndex → Prop}
  {readSessionKey : EvalPoint → SessionKey}
  {pairedSessionKey : AddressPoint → CyclePoint → SessionKey}
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {readCheckExpression : AddressColumns → Table → EvalPoint → F}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  {W Z Commitment : Type*}
  {rootEncode : ContinuityBridge.RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}

inductive StagePayload
  (frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :
  ReleaseStage → Type _ where
  | readonlyBatch :
      ReadonlyBatchTraceBundle frames →
        StagePayload frames .readonlyBatch
  | registerHistory :
      RegisterHistoryBundle frames →
        StagePayload frames .registerHistory
  | ramHistory :
      RamHistoryBundle frames →
        StagePayload frames .ramHistory

noncomputable def canonicalStagePayloads_of_artifact
  {frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (artifact : StagedBridgeArtifact (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit) frames) :
  Nightstream.CanonicalStagePayloads releaseShape.stageOrder (StagePayload frames) := by
  refine ⟨[⟨.readonlyBatch, StagePayload.readonlyBatch artifact.readonlyBatch⟩,
      ⟨.registerHistory, StagePayload.registerHistory artifact.history.register⟩,
      ⟨.ramHistory, StagePayload.ramHistory artifact.history.ram⟩], ?_⟩
  simp [releaseShape, releaseStageOrder]

noncomputable def toGenericStagedBridgeArtifact
  {frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (artifact : StagedBridgeArtifact (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit) frames) :=
    Nightstream.stagedBridgeArtifact_of_parts
      releaseShape
      (fun trace steps => StepComposition.PreparedStepTraceBound rootEncode ajtaiCommit trace steps)
      (StagePayload frames)
      (bridgePreparedSteps (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit) frames)
      (AuthenticatedTrace.traceOf frames)
      artifact.preparedStepTrace
      (canonicalStagePayloads_of_artifact artifact)

theorem toGenericStagedBridgeArtifact_publicViewBound
  {frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (artifact : StagedBridgeArtifact (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit) frames) :
  Nightstream.ReleaseBridgePublicViewBound
    releaseShape
    (toGenericStagedBridgeArtifact artifact).publicView
    (bridgePreparedSteps (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit) frames).length :=
  (toGenericStagedBridgeArtifact artifact).publicViewBound

end Bridge

end Nightstream.Chip8

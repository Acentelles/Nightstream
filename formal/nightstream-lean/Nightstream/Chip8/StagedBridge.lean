import Nightstream.Chip8.ReleaseBridge
import Nightstream.Chip8.Trace.AuthenticatedTrace
import Nightstream.Chip8.Stage2.EvidenceCoverageBounds

namespace Nightstream.Chip8

open Nightstream.Chip8.AuthenticatedTrace
open Nightstream.Chip8.EvidenceCoverage
open Nightstream.Chip8.WitnessMemoryBinding
open Nightstream.Chip8.ChunkInput
open Nightstream.Chip8.ContinuityBridge

structure ReleaseStageView where
  stage : ReleaseStage
  families : List ExtensionFamily
deriving DecidableEq, Repr

def releaseStageView (stage : ReleaseStage) : ReleaseStageView :=
  ⟨stage, stageFamilies stage⟩

def canonicalStageViews : List ReleaseStageView :=
  [releaseStageView .readonlyBatch,
    releaseStageView .registerHistory,
    releaseStageView .ramHistory]

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
    canonicalStageViews]

theorem canonicalStageViews_stage_eq
  (stage : ReleaseStage) :
  releaseStageView stage ∈ canonicalStageViews := by
  cases stage <;> simp [canonicalStageViews, releaseStageView]

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
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}

private abbrev execFrameOf
  (frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :=
  AuthenticatedTrace.ExactFrameEvidence.frame
    (pcs := pcs) (inputs := inputs) (evalBase := evalBase) (B := B)
    (publicTable := publicTable) (tableBackedBy := tableBackedBy)
    (readSessionKey := readSessionKey) (pairedSessionKey := pairedSessionKey)
    (validAddressColumns := validAddressColumns)
    (kernelAddressBound := kernelAddressBound)
    (readCheckExpression := readCheckExpression)
    (rwReadCheckExpression := rwReadCheckExpression)
    (writeCheckExpression := writeCheckExpression)
    (valEvaluationExpression := valEvaluationExpression)
    (readOnlyMemoryRelation := readOnlyMemoryRelation)
    (readWriteMemoryRelation := readWriteMemoryRelation)
    (incrementRelation := incrementRelation)
    (rom := rom) (σ := σ) (init := init) frame

private abbrev exactEvidenceOf
  (frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :=
  AuthenticatedTrace.ExactFrameEvidence.exactEvidence
    (pcs := pcs) (inputs := inputs) (evalBase := evalBase) (B := B)
    (publicTable := publicTable) (tableBackedBy := tableBackedBy)
    (readSessionKey := readSessionKey) (pairedSessionKey := pairedSessionKey)
    (validAddressColumns := validAddressColumns)
    (kernelAddressBound := kernelAddressBound)
    (readCheckExpression := readCheckExpression)
    (rwReadCheckExpression := rwReadCheckExpression)
    (writeCheckExpression := writeCheckExpression)
    (valEvaluationExpression := valEvaluationExpression)
    (readOnlyMemoryRelation := readOnlyMemoryRelation)
    (readWriteMemoryRelation := readWriteMemoryRelation)
    (incrementRelation := incrementRelation)
    (rom := rom) (σ := σ) (init := init) frame

def bridgePreparedSteps
  (frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :
  List (PreparedStep W Z Commitment F) :=
  (traceOf frames).map
    (fun frame =>
      mkPreparedStep rootEncode ajtaiCommit frame.row)

abbrev FrameReadonlyBundle
  (frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :=
  let execFrame := execFrameOf frame
  ReadonlyBatchBundle rom execFrame.pre.pc execFrame.dec.toDecodedCore
    (execFrame.pre.v execFrame.dec.x)
    (execFrame.pre.v execFrame.dec.y)
    (WitnessMemoryBinding.primaryIndex execFrame.dec)

abbrev ReadonlyBatchEntry : Type _ :=
  Sigma
    (fun frame :
      AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init =>
      FrameReadonlyBundle frame)

def ReadonlyBatchTraceBundle
  (frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) : Type _ :=
  { bundles : List ReadonlyBatchEntry // bundles.map (fun entry => entry.1) = frames }

def ReadonlyBatchTraceBundle.length
  {frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (bundle : ReadonlyBatchTraceBundle frames) : Nat :=
  bundle.1.length

theorem readonlyBatchTraceBundle_length_eq
  {frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (bundle : ReadonlyBatchTraceBundle frames) :
  bundle.length = frames.length := by
  have hLen := congrArg List.length bundle.2
  simpa [ReadonlyBatchTraceBundle.length] using hLen

noncomputable def readonlyBatchFrameBundle_of_exactFrame
  (frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :
  FrameReadonlyBundle frame := by
  let execFrame := execFrameOf frame
  have hBounds := semanticBounds_of_exactAuthenticatedEvidence (exactEvidenceOf frame)
  exact
    readonlyBatchBundle_of_fetchDecodeBound
      (rom := rom)
      (pc := execFrame.pre.pc)
      (dec := execFrame.dec.toDecodedCore)
      (regX := execFrame.pre.v execFrame.dec.x)
      (regY := execFrame.pre.v execFrame.dec.y)
      (xIdx := WitnessMemoryBinding.primaryIndex execFrame.dec)
      hBounds.2.2.2.1

noncomputable def readonlyBatchTraceBundle_of_frames :
  (frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) → ReadonlyBatchTraceBundle frames
  | [] => ⟨[], by simp⟩
  | frame :: frames =>
      let tail := readonlyBatchTraceBundle_of_frames frames
      ⟨⟨frame, readonlyBatchFrameBundle_of_exactFrame frame⟩ :: tail.1, by
        simpa [tail.2]⟩

theorem preparedStepTrace_of_exactTrace
  {frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hExact : AuthenticatedTrace.ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)) :
  StepComposition.PreparedStepTraceBound rootEncode ajtaiCommit (traceOf frames)
    (bridgePreparedSteps (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit) frames) := by
  simpa [bridgePreparedSteps] using
    (AuthenticatedTrace.preparedStepTraceBound_of_exactTrace
      (inputs := inputs) (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit)
      hExact hChunk)

theorem preparedStepCount_of_exactTrace
  {frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hExact : AuthenticatedTrace.ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)) :
  (bridgePreparedSteps (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit) frames).length =
    inputs.pubMeta.semanticRows := by
  simpa [bridgePreparedSteps] using
    (AuthenticatedTrace.preparedStepExport_of_exactTrace
      (inputs := inputs) (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit)
      hExact hChunk).1

structure StagedBridgeArtifact
  (frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) where
  publicView : ReleaseBridgePublicView
  publicViewBound :
    ReleaseBridgePublicViewBound publicView inputs.pubMeta.semanticRows
  preparedStepCount :
    (bridgePreparedSteps (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit) frames).length =
      inputs.pubMeta.semanticRows
  preparedStepTrace :
    StepComposition.PreparedStepTraceBound rootEncode ajtaiCommit (traceOf frames)
      (bridgePreparedSteps (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit) frames)
  readonlyBatch : ReadonlyBatchTraceBundle frames
  history : HistoryBundle frames

noncomputable def stagedBridgeArtifact_of_exactTrace
  {frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hExact : AuthenticatedTrace.ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)) :
  StagedBridgeArtifact (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit) frames := by
  exact
    { publicView :=
        releaseBridgePublicView_of_preparedStepCount inputs.pubMeta.semanticRows
      publicViewBound :=
        releaseBridgePublicViewBound_of_preparedStepCount inputs.pubMeta.semanticRows
      preparedStepCount :=
        preparedStepCount_of_exactTrace hExact hChunk
      preparedStepTrace :=
        preparedStepTrace_of_exactTrace hExact hChunk
      readonlyBatch := readonlyBatchTraceBundle_of_frames frames
      history := historyBundle_of_exactTrace hExact }

theorem readonlyBatchLength_of_artifact
  {frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (artifact : StagedBridgeArtifact (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit) frames) :
  artifact.readonlyBatch.length = (traceOf frames).length := by
  calc
    artifact.readonlyBatch.length = frames.length :=
      readonlyBatchTraceBundle_length_eq artifact.readonlyBatch
    _ = (traceOf frames).length := by simp [traceOf]

theorem preparedStepCount_matches_publicView
  {frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (artifact : StagedBridgeArtifact (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit) frames) :
  artifact.publicView.preparedStepCount =
    (bridgePreparedSteps (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit) frames).length := by
  have hCount := artifact.preparedStepCount
  rcases artifact.publicViewBound with ⟨_, hPrepared, _⟩
  exact hPrepared.trans hCount.symm

end Bridge

end Nightstream.Chip8

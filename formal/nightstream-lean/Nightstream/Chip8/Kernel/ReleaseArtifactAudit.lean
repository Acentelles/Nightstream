import Nightstream.Chip8.Kernel.KernelDigestAuditBoundary
import Nightstream.Chip8.Kernel.ReleaseArtifact

/-!
Owns the Lean-defined audit checker over the combined CHIP-8 release artifact.
This file checks that the packaged kernel digest and staged chunk bundle both
meet their existing theorem-facing audit contracts and that the shared chunk
input contract is present; it does not own external serialization/import.
-/

namespace Nightstream.Chip8.ReleaseArtifactAudit

open Nightstream.Chip8
open Nightstream.Chip8.AuthenticatedTrace
open Nightstream.Chip8.ChunkInput
open Nightstream.Chip8.KernelArtifactAudit
open Nightstream.Chip8.KernelDigestAuditBoundary
open Nightstream.Chip8.KernelExecutionDigest
open Nightstream.Chip8.KernelSoundness
open Nightstream.Chip8.ReleaseArtifact
open Nightstream.Chip8.RootHandoffContext
open Nightstream.Chip8.StagedExecutionBundleAudit

abbrev F := ReleaseArtifact.F
abbrev Program := ReleaseArtifact.Program
abbrev MachineState := ReleaseArtifact.MachineState
abbrev InitialState := ReleaseArtifact.InitialState
abbrev ExternalSchedule := ReleaseArtifact.ExternalSchedule

section Audit

variable
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr Table ValSurface
    Increment SessionKey : Type*}
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    EvidenceCoverage.ExecutionInputContext DigestRom DigestSchedule RootParamsId
      VmSpec TranscriptSeed}
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
  {W Z Commitment Value Digest : Type*}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}

local notation "ExactFramesT" =>
  StagedExecutionDigestBundle.ExactFrames (pcs := pcs) (inputs := inputs)
    (evalBase := evalBase) (B := B) (publicTable := publicTable)
    (tableBackedBy := tableBackedBy) (readSessionKey := readSessionKey)
    (pairedSessionKey := pairedSessionKey)
    (validAddressColumns := validAddressColumns)
    (kernelAddressBound := kernelAddressBound)
    (readCheckExpression := readCheckExpression)
    (rwReadCheckExpression := rwReadCheckExpression)
    (writeCheckExpression := writeCheckExpression)
    (valEvaluationExpression := valEvaluationExpression)
    (readOnlyMemoryRelation := readOnlyMemoryRelation)
    (readWriteMemoryRelation := readWriteMemoryRelation)
    (incrementRelation := incrementRelation) (rom := rom) (σ := σ)
    (init := init)

abbrev ArtifactFor
  (frames : ExactFramesT)
  (pts : ExactOpeningBoundary.KernelPoints)
  (kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest)
  (rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest)
  (events : List TranscriptSchedule.TranscriptEvent)
  (accounting : SoundnessAccounting.KernelSoundnessAccounting) :=
  ReleaseArtifact.Artifact (pcs := pcs) (inputs := inputs)
    (evalBase := evalBase) (B := B) (publicTable := publicTable)
    (tableBackedBy := tableBackedBy) (readSessionKey := readSessionKey)
    (pairedSessionKey := pairedSessionKey)
    (validAddressColumns := validAddressColumns)
    (kernelAddressBound := kernelAddressBound)
    (readCheckExpression := readCheckExpression)
    (rwReadCheckExpression := rwReadCheckExpression)
    (writeCheckExpression := writeCheckExpression)
    (valEvaluationExpression := valEvaluationExpression)
    (readOnlyMemoryRelation := readOnlyMemoryRelation)
    (readWriteMemoryRelation := readWriteMemoryRelation)
    (incrementRelation := incrementRelation) (W := W) (Z := Z)
    (Commitment := Commitment) (Value := Value) (Digest := Digest)
    (rootCtx := rootCtx) (rom := rom) (σ := σ) (init := init)
    frames pts kernelManifest rootManifest events accounting

local notation "ArtifactCtx" =>
  ArtifactFor (pcs := pcs) (inputs := inputs) (evalBase := evalBase) (B := B)
    (publicTable := publicTable) (tableBackedBy := tableBackedBy)
    (readSessionKey := readSessionKey)
    (pairedSessionKey := pairedSessionKey)
    (validAddressColumns := validAddressColumns)
    (kernelAddressBound := kernelAddressBound)
    (readCheckExpression := readCheckExpression)
    (rwReadCheckExpression := rwReadCheckExpression)
    (writeCheckExpression := writeCheckExpression)
    (valEvaluationExpression := valEvaluationExpression)
    (readOnlyMemoryRelation := readOnlyMemoryRelation)
    (readWriteMemoryRelation := readWriteMemoryRelation)
    (incrementRelation := incrementRelation) (W := W) (Z := Z)
    (Commitment := Commitment) (Value := Value) (Digest := Digest)
    (rootCtx := rootCtx) (rom := rom) (σ := σ) (init := init)

def checkKernelDigestSurface
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  (artifact : ArtifactCtx frames pts kernelManifest rootManifest events accounting) :
  Prop :=
  KernelArtifactAuditAccepted rootCtx frames pts kernelManifest rootManifest
    events accounting artifact.kernelDigest

def checkStagedBundleSurface
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  (artifact : ArtifactCtx frames pts kernelManifest rootManifest events accounting) :
  Prop :=
  StagedExecutionBundleAuditAccepted artifact.stagedBundle

def checkChunkInputSurface
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  (_artifact : ArtifactCtx frames pts kernelManifest rootManifest events accounting) :
  Prop :=
  ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
    (AuthenticatedTrace.traceOf frames)

def checkReleaseArtifact
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  (artifact : ArtifactCtx frames pts kernelManifest rootManifest events accounting) :
  Prop :=
  checkKernelDigestSurface artifact ∧
    checkStagedBundleSurface artifact ∧
    checkChunkInputSurface artifact

def ReleaseArtifactAuditAccepted
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  (artifact : ArtifactCtx frames pts kernelManifest rootManifest events accounting) :
  Prop :=
  checkReleaseArtifact artifact

theorem checkKernelDigestSurface_of_bound
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  {artifact : ArtifactCtx frames pts kernelManifest rootManifest events accounting}
  (_h : ReleaseArtifactBound artifact) :
  checkKernelDigestSurface artifact := by
  exact KernelDigestAuditBoundary.kernelArtifactAuditAccepted_of_digest
    (inputs := inputs) (d := artifact.kernelDigest)

theorem checkStagedBundleSurface_of_bound
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  {artifact : ArtifactCtx frames pts kernelManifest rootManifest events accounting}
  (h : ReleaseArtifactBound artifact) :
  checkStagedBundleSurface artifact :=
  ReleaseArtifact.stagedBundleAuditAccepted_of_releaseArtifactBound h

theorem checkChunkInputSurface_of_bound
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  {artifact : ArtifactCtx frames pts kernelManifest rootManifest events accounting}
  (h : ReleaseArtifactBound artifact) :
  checkChunkInputSurface artifact :=
  ReleaseArtifact.chunkInput_of_releaseArtifactBound h

theorem releaseArtifactAuditAccepted_of_bound
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  {artifact : ArtifactCtx frames pts kernelManifest rootManifest events accounting}
  (h : ReleaseArtifactBound artifact) :
  ReleaseArtifactAuditAccepted artifact := by
  exact ⟨checkKernelDigestSurface_of_bound h,
    checkStagedBundleSurface_of_bound h,
    checkChunkInputSurface_of_bound h⟩

theorem releaseArtifactAuditSound
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  {artifact : ArtifactCtx frames pts kernelManifest rootManifest events accounting}
  (h : ReleaseArtifactAuditAccepted artifact) :
  ReleaseArtifactBound artifact := by
  exact ⟨KernelArtifactAudit.kernelArtifactAuditSound h.1, h.2.1, h.2.2⟩

def releaseArtifactAuditImpliesKernelSoundnessConclusion
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  {artifact : ArtifactCtx frames pts kernelManifest rootManifest events accounting}
  (h : ReleaseArtifactAuditAccepted artifact) :
  KernelSoundnessConclusion rootCtx frames pts kernelManifest
    rootManifest events accounting :=
  KernelArtifactAudit.kernelArtifactAuditImpliesKernelSoundnessConclusion h.1

theorem releaseArtifactAuditImpliesEntryBound
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  {artifact : ArtifactCtx frames pts kernelManifest rootManifest events accounting}
  {entry :
    StagedExecutionDigestBundle.FrameDigestEntry (pcs := pcs) (inputs := inputs)
      (evalBase := evalBase) (B := B) (publicTable := publicTable)
      (tableBackedBy := tableBackedBy)
      (readSessionKey := readSessionKey)
      (pairedSessionKey := pairedSessionKey)
      (validAddressColumns := validAddressColumns)
      (kernelAddressBound := kernelAddressBound)
      (readCheckExpression := readCheckExpression)
      (rwReadCheckExpression := rwReadCheckExpression)
      (writeCheckExpression := writeCheckExpression)
      (valEvaluationExpression := valEvaluationExpression)
      (readOnlyMemoryRelation := readOnlyMemoryRelation)
      (readWriteMemoryRelation := readWriteMemoryRelation)
      (incrementRelation := incrementRelation) (W := W) (Z := Z)
      (Commitment := Commitment) (rootCtx := rootCtx) (rom := rom) (σ := σ)
      (init := init)}
  (h : ReleaseArtifactAuditAccepted artifact)
  (hMem : entry ∈ artifact.stagedBundle.digests) :
  StagedExecutionDigest.StagedExecutionDigestBound inputs rootCtx rom σ
    entry.frame.stepIdx init entry.frame.frame.pre entry.frame.frame.post
    entry.frame.frame.dec entry.frame.frame.row entry.digest :=
  StagedExecutionBundleAudit.bundleAuditImpliesEntryBound h.2.1 hMem

theorem releaseArtifactAuditImpliesBundleLength_eq_semanticRows
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  {artifact : ArtifactCtx frames pts kernelManifest rootManifest events accounting}
  (h : ReleaseArtifactAuditAccepted artifact) :
  artifact.stagedBundle.length = inputs.pubMeta.semanticRows :=
  StagedExecutionBundleAudit.bundleAuditLength_eq_semanticRows h.2.1 h.2.2

theorem releaseArtifactAuditImpliesPreparedStepCount_eq_bundleLength
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  {artifact : ArtifactCtx frames pts kernelManifest rootManifest events accounting}
  (h : ReleaseArtifactAuditAccepted artifact) :
  (KernelSoundness.kernelPreparedSteps rootCtx frames).length =
    artifact.stagedBundle.length := by
  have hPrepared :=
    KernelArtifactAudit.kernelArtifactAuditImpliesPreparedStepExport h.1
  have hBundle := releaseArtifactAuditImpliesBundleLength_eq_semanticRows h
  calc
    (KernelSoundness.kernelPreparedSteps rootCtx frames).length =
        inputs.pubMeta.semanticRows := hPrepared.1
    _ = artifact.stagedBundle.length := by simpa using hBundle.symm

end Audit

end Nightstream.Chip8.ReleaseArtifactAudit

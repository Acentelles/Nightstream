import Nightstream.Chip8.Kernel.KernelExecutionDigest
import Nightstream.Chip8.Kernel.StagedExecutionBundleAudit

/-!
Owns the Lean-defined final CHIP-8 release artifact above the normalized
kernel digest and the chunk staged-digest bundle. This file packages those
existing surfaces under one shared chunk context; it does not own external
serialization/import.
-/

namespace Nightstream.Chip8.ReleaseArtifact

open Nightstream.Chip8
open Nightstream.Chip8.AuthenticatedTrace
open Nightstream.Chip8.ChunkInput
open Nightstream.Chip8.KernelExecutionDigest
open Nightstream.Chip8.KernelSoundness
open Nightstream.Chip8.RootHandoffContext
open Nightstream.Chip8.StagedExecutionDigestBundle
open Nightstream.Chip8.StagedExecutionBundleAudit

abbrev F := KernelExecutionDigest.F
abbrev Program := KernelExecutionDigest.Program
abbrev MachineState := KernelExecutionDigest.MachineState
abbrev InitialState := KernelExecutionDigest.InitialState
abbrev ExternalSchedule := KernelExecutionDigest.ExternalSchedule

section Artifact

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

local notation "BundleT" frames =>
  StagedExecutionDigestBundle.DigestBundle (pcs := pcs) (inputs := inputs)
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
    (Commitment := Commitment) (rootCtx := rootCtx) (rom := rom) (σ := σ)
    (init := init) frames

structure Artifact
  (frames : ExactFramesT)
  (pts : ExactOpeningBoundary.KernelPoints)
  (kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest)
  (rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest)
  (events : List TranscriptSchedule.TranscriptEvent)
  (accounting : SoundnessAccounting.KernelSoundnessAccounting) where
  kernelDigest :
    KernelExecutionDigest rootCtx frames pts kernelManifest rootManifest
      events accounting
  stagedBundle : BundleT frames

def ReleaseArtifactBound
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  (artifact :
    Artifact (pcs := pcs) (inputs := inputs) (evalBase := evalBase) (B := B)
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
      frames pts kernelManifest rootManifest events accounting) :
  Prop :=
  KernelExecutionDigestBound rootCtx frames pts kernelManifest rootManifest
      events accounting artifact.kernelDigest ∧
    StagedExecutionBundleAuditAccepted artifact.stagedBundle ∧
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (AuthenticatedTrace.traceOf frames)

theorem kernelDigestBound_of_releaseArtifactBound
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  {artifact :
    Artifact (pcs := pcs) (inputs := inputs) (evalBase := evalBase) (B := B)
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
      frames pts kernelManifest rootManifest events accounting}
  (h : ReleaseArtifactBound artifact) :
  KernelExecutionDigestBound rootCtx frames pts kernelManifest rootManifest
    events accounting artifact.kernelDigest :=
  h.1

theorem stagedBundleAuditAccepted_of_releaseArtifactBound
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  {artifact :
    Artifact (pcs := pcs) (inputs := inputs) (evalBase := evalBase) (B := B)
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
      frames pts kernelManifest rootManifest events accounting}
  (h : ReleaseArtifactBound artifact) :
  StagedExecutionBundleAuditAccepted artifact.stagedBundle :=
  h.2.1

theorem chunkInput_of_releaseArtifactBound
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  {artifact :
    Artifact (pcs := pcs) (inputs := inputs) (evalBase := evalBase) (B := B)
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
      frames pts kernelManifest rootManifest events accounting}
  (h : ReleaseArtifactBound artifact) :
  ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
    (AuthenticatedTrace.traceOf frames) :=
  h.2.2

theorem releaseArtifactBound_of_fields
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  (kernelDigest :
    KernelExecutionDigest rootCtx frames pts kernelManifest rootManifest
      events accounting)
  (stagedBundle : BundleT frames)
  (hKernel :
    KernelExecutionDigestBound rootCtx frames pts kernelManifest rootManifest
      events accounting kernelDigest)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (AuthenticatedTrace.traceOf frames)) :
  ReleaseArtifactBound
    ({ kernelDigest := kernelDigest, stagedBundle := stagedBundle } :
      Artifact (pcs := pcs) (inputs := inputs) (evalBase := evalBase) (B := B)
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
        frames pts kernelManifest rootManifest events accounting) := by
  exact ⟨hKernel, stagedExecutionBundleAuditAccepted_of_bundle stagedBundle, hChunk⟩

theorem releaseArtifact_of_conclusion
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  (hKernel :
    KernelSoundnessConclusion rootCtx frames pts kernelManifest
      rootManifest events accounting)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (AuthenticatedTrace.traceOf frames)) :
  ∃ artifact :
      Artifact (pcs := pcs) (inputs := inputs) (evalBase := evalBase) (B := B)
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
        frames pts kernelManifest rootManifest events accounting,
    ReleaseArtifactBound artifact := by
  obtain ⟨kernelDigest, hDigest⟩ :=
    KernelExecutionDigest.kernelExecutionDigest_of_conclusion
      (inputs := inputs) (rootCtx := rootCtx) (hKernel := hKernel)
  let stagedBundle :=
    StagedExecutionDigestBundle.stagedExecutionDigestBundle_of_frames
      (pcs := pcs) (inputs := inputs) (evalBase := evalBase) (B := B)
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
      (Commitment := Commitment) (rootCtx := rootCtx) (rom := rom) (σ := σ)
      (init := init) hChunk
  exact ⟨{ kernelDigest := kernelDigest, stagedBundle := stagedBundle },
    ⟨hDigest, stagedExecutionBundleAuditAccepted_of_bundle stagedBundle, hChunk⟩⟩

theorem releaseArtifact_of_acceptance
  {frames : ExactFramesT}
  {pts : ExactOpeningBoundary.KernelPoints}
  {kernelManifest : ExactOpeningBoundary.KernelOpeningManifest Value Digest}
  {rootManifest : ExactOpeningBoundary.RootOpeningManifest Value Digest}
  {events : List TranscriptSchedule.TranscriptEvent}
  {accounting : SoundnessAccounting.KernelSoundnessAccounting}
  (hAccepted :
    KernelSoundnessAccepted (inputs := inputs) rootCtx frames pts
      kernelManifest rootManifest events) :
  ∃ artifact :
      Artifact (pcs := pcs) (inputs := inputs) (evalBase := evalBase) (B := B)
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
        frames pts kernelManifest rootManifest events accounting,
    ReleaseArtifactBound artifact := by
  obtain ⟨kernelDigest, hDigest⟩ :=
    KernelExecutionDigest.kernelExecutionDigest_of_acceptance
      (inputs := inputs) (rootCtx := rootCtx) (accounting := accounting)
      hAccepted
  let stagedBundle :=
    StagedExecutionDigestBundle.stagedExecutionDigestBundle_of_frames
      (pcs := pcs) (inputs := inputs) (evalBase := evalBase) (B := B)
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
      (Commitment := Commitment) (rootCtx := rootCtx) (rom := rom) (σ := σ)
      (init := init) hAccepted.chunk
  exact ⟨{ kernelDigest := kernelDigest, stagedBundle := stagedBundle },
    ⟨hDigest, stagedExecutionBundleAuditAccepted_of_bundle stagedBundle,
      hAccepted.chunk⟩⟩

end Artifact

end Nightstream.Chip8.ReleaseArtifact

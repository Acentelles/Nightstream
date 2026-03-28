import Nightstream.Chip8.Kernel.ArtifactAudit
import Nightstream.Chip8.Kernel.StagedExecutionDigestBundle

/-!
Owns the chunk-level audit acceptance layer over one Lean-owned staged
execution digest bundle. This file does not own external serialization/import;
it only states what acceptance means for the canonical chunk bundle and how
that acceptance recovers exact per-entry theorem surfaces.
-/

namespace Nightstream.Chip8.StagedExecutionBundleAudit

open Nightstream.Chip8
open Nightstream.Chip8.ArtifactAudit
open Nightstream.Chip8.AuthenticatedTrace
open Nightstream.Chip8.ChunkInput
open Nightstream.Chip8.RootHandoffContext
open Nightstream.Chip8.StagedExecutionDigest
open Nightstream.Chip8.StagedExecutionDigestBundle

abbrev F := StagedExecutionDigestBundle.F
abbrev Program := StagedExecutionDigestBundle.Program
abbrev MachineState := StagedExecutionDigestBundle.MachineState
abbrev InitialState := StagedExecutionDigestBundle.InitialState
abbrev ExternalSchedule := StagedExecutionDigestBundle.ExternalSchedule

section Audit

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
  {W Z Commitment : Type*}
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
    (incrementRelation := incrementRelation) (rom := rom) (σ := σ) (init := init)

local notation "EntryT" =>
  StagedExecutionDigestBundle.FrameDigestEntry (pcs := pcs) (inputs := inputs)
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

def EntryAuditAccepted (entry : EntryT) : Prop :=
  ArtifactAuditAccepted inputs rootCtx rom σ entry.frame.stepIdx init
    entry.frame.frame.pre entry.frame.frame.post entry.frame.frame.dec
    entry.frame.frame.row entry.digest

def checkBundlePublicSurface
  {frames : ExactFramesT}
  (_bundle : BundleT frames) : Prop :=
  RomScheduleBinding.KernelPublicInputsBound inputs.hashProgram
    inputs.hashInitialState inputs.programWordCountOf inputs.programBaseAddrOf
    inputs.padPcWordOf inputs.paddedTraceLengthOf inputs.twoPow
    inputs.rootParamsOf inputs.publicInput inputs.pubMeta rom init

def checkBundleEntries
  {frames : ExactFramesT}
  (bundle : BundleT frames) : Prop :=
  ∀ entry, entry ∈ bundle.digests → EntryAuditAccepted entry

def checkBundleOrder
  {frames : ExactFramesT}
  (bundle : BundleT frames) : Prop :=
  bundle.digests.map FrameDigestEntry.frame = frames

def checkStagedExecutionDigestBundle
  {frames : ExactFramesT}
  (bundle : BundleT frames) : Prop :=
  checkBundlePublicSurface bundle ∧
    checkBundleEntries bundle ∧
    checkBundleOrder bundle

def StagedExecutionBundleAuditAccepted
  {frames : ExactFramesT}
  (bundle : BundleT frames) : Prop :=
  checkStagedExecutionDigestBundle bundle

theorem entryAuditAccepted_of_entry
  (entry : EntryT) :
  EntryAuditAccepted entry := by
  exact ArtifactAudit.artifactAuditAccepted_of_bound entry.bound

theorem checkBundlePublicSurface_of_bundle
  {frames : ExactFramesT}
  (bundle : BundleT frames) :
  checkBundlePublicSurface bundle :=
  StagedExecutionDigestBundle.kernelPublicInputsBound_of_bundle bundle

theorem checkBundleEntries_of_bundle
  {frames : ExactFramesT}
  (bundle : BundleT frames) :
  checkBundleEntries bundle := by
  intro entry _hMem
  exact entryAuditAccepted_of_entry entry

theorem checkBundleOrder_of_bundle
  {frames : ExactFramesT}
  (bundle : BundleT frames) :
  checkBundleOrder bundle :=
  bundle.ordered

theorem stagedExecutionBundleAuditAccepted_of_bundle
  {frames : ExactFramesT}
  (bundle : BundleT frames) :
  StagedExecutionBundleAuditAccepted bundle := by
  exact ⟨checkBundlePublicSurface_of_bundle bundle,
    checkBundleEntries_of_bundle bundle, checkBundleOrder_of_bundle bundle⟩

theorem stagedExecutionBundleAuditAccepted_of_frames
  {frames : ExactFramesT}
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (AuthenticatedTrace.traceOf frames)) :
  StagedExecutionBundleAuditAccepted
    (StagedExecutionDigestBundle.stagedExecutionDigestBundle_of_frames
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
      (init := init) hChunk) := by
  exact stagedExecutionBundleAuditAccepted_of_bundle _

theorem bundleAuditImpliesKernelPublicInputsBound
  {frames : ExactFramesT}
  {bundle : BundleT frames}
  (h : StagedExecutionBundleAuditAccepted bundle) :
  RomScheduleBinding.KernelPublicInputsBound inputs.hashProgram
    inputs.hashInitialState inputs.programWordCountOf inputs.programBaseAddrOf
    inputs.padPcWordOf inputs.paddedTraceLengthOf inputs.twoPow
    inputs.rootParamsOf inputs.publicInput inputs.pubMeta rom init :=
  h.1

theorem bundleAuditImpliesEntryAccepted
  {frames : ExactFramesT}
  {bundle : BundleT frames}
  {entry : EntryT}
  (h : StagedExecutionBundleAuditAccepted bundle)
  (hMem : entry ∈ bundle.digests) :
  EntryAuditAccepted entry :=
  h.2.1 entry hMem

theorem bundleAuditImpliesOrderedFrames
  {frames : ExactFramesT}
  {bundle : BundleT frames}
  (h : StagedExecutionBundleAuditAccepted bundle) :
  bundle.digests.map FrameDigestEntry.frame = frames :=
  h.2.2

theorem bundleAuditImpliesEntryBound
  {frames : ExactFramesT}
  {bundle : BundleT frames}
  {entry : EntryT}
  (h : StagedExecutionBundleAuditAccepted bundle)
  (hMem : entry ∈ bundle.digests) :
  StagedExecutionDigest.StagedExecutionDigestBound inputs rootCtx rom σ
    entry.frame.stepIdx init entry.frame.frame.pre entry.frame.frame.post
    entry.frame.frame.dec entry.frame.frame.row entry.digest := by
  exact ArtifactAudit.artifactAuditSound
    (bundleAuditImpliesEntryAccepted h hMem)

theorem bundleAuditImpliesEntryExecutionFrameBound
  {frames : ExactFramesT}
  {bundle : BundleT frames}
  {entry : EntryT}
  (h : StagedExecutionBundleAuditAccepted bundle)
  (hMem : entry ∈ bundle.digests) :
  StepComposition.ExecutionFrameBound rom σ entry.frame.frame := by
  simpa using ArtifactAudit.artifactAuditImpliesExecutionFrameBound
    (bundleAuditImpliesEntryAccepted h hMem)

theorem bundleAuditImpliesEntryMicrostepCorrect
  {frames : ExactFramesT}
  {bundle : BundleT frames}
  {entry : EntryT}
  (h : StagedExecutionBundleAuditAccepted bundle)
  (hMem : entry ∈ bundle.digests) :
  StepComposition.MicrostepCorrect rom σ entry.frame.frame.dec
    entry.frame.frame.pre entry.frame.frame.post := by
  exact ArtifactAudit.artifactAuditImpliesMicrostepCorrect
    (bundleAuditImpliesEntryAccepted h hMem)

theorem bundleAuditLength_eq
  {frames : ExactFramesT}
  {bundle : BundleT frames}
  (h : StagedExecutionBundleAuditAccepted bundle) :
  bundle.length = frames.length := by
  have hLen := congrArg List.length (bundleAuditImpliesOrderedFrames h)
  simpa [DigestBundle.length] using hLen

theorem bundleAuditLength_eq_semanticRows
  {frames : ExactFramesT}
  {bundle : BundleT frames}
  (h : StagedExecutionBundleAuditAccepted bundle)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (AuthenticatedTrace.traceOf frames)) :
  bundle.length = inputs.pubMeta.semanticRows := by
  calc
    bundle.length = frames.length := bundleAuditLength_eq h
    _ = (AuthenticatedTrace.traceOf frames).length := by
      simp [AuthenticatedTrace.traceOf]
    _ = inputs.pubMeta.semanticRows := by
      exact ChunkInput.traceLength_of_simpleKernelChunkInput hChunk

end Audit

end Nightstream.Chip8.StagedExecutionBundleAudit

import Nightstream.Chip8.Trace.AuthenticatedTrace
import Nightstream.Chip8.Trace.TemporalConsistency
import Nightstream.Chip8.Kernel.RootHandoffContext
import Nightstream.Chip8.Kernel.TranscriptSchedule
import Nightstream.Chip8.Kernel.SoundnessAccounting

/-!
Owns the top-level theorem-facing CHIP-8 kernel soundness conclusion. This file
composes already-owned semantic, transcript, opening-boundary, and accounting
surfaces; it does not re-own any stage-local theorem.
-/

namespace Nightstream.Chip8.KernelSoundness

open Nightstream.Chip8
open Nightstream.Chip8.AuthenticatedTrace
open Nightstream.Chip8.TemporalConsistency
open Nightstream.Chip8.TranscriptSchedule
open Nightstream.Chip8.SoundnessAccounting
open Nightstream.Chip8.ExactOpeningBoundary
open Nightstream.Chip8.RootHandoffContext

abbrev F := AuthenticatedTrace.F
abbrev Program := AuthenticatedTrace.Program
abbrev MachineState := AuthenticatedTrace.MachineState
abbrev InitialState := AuthenticatedTrace.InitialState
abbrev ExternalSchedule := AuthenticatedTrace.ExternalSchedule
abbrev ExecutionFrame := AuthenticatedTrace.ExecutionFrame
abbrev RegisterValueTimeline := TemporalConsistency.RegisterValueTimeline
abbrev RamValueTimeline := TemporalConsistency.RamValueTimeline
abbrev RootEncode := ContinuityBridge.RootEncode

section Kernel

variable
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr Table ValSurface
    Increment SessionKey : Type*}
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}
  {W Z Commitment Value Digest : Type*}

abbrev KernelFrameEvidence
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState} :=
  ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
    readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
    readCheckExpression rwReadCheckExpression writeCheckExpression
    valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
    incrementRelation rom σ init

abbrev KernelFrames
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState} :=
  List
    (KernelFrameEvidence (pcs := pcs) (inputs := inputs) (evalBase := evalBase)
      (B := B) (publicTable := publicTable) (tableBackedBy := tableBackedBy)
      (readSessionKey := readSessionKey) (pairedSessionKey := pairedSessionKey)
      (validAddressColumns := validAddressColumns)
      (kernelAddressBound := kernelAddressBound)
      (readCheckExpression := readCheckExpression)
      (rwReadCheckExpression := rwReadCheckExpression)
      (writeCheckExpression := writeCheckExpression)
      (valEvaluationExpression := valEvaluationExpression)
      (readOnlyMemoryRelation := readOnlyMemoryRelation)
      (readWriteMemoryRelation := readWriteMemoryRelation)
      (incrementRelation := incrementRelation) (rom := rom) (σ := σ)
      (init := init))

def kernelPreparedSteps
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
  (frames :
    KernelFrames (pcs := pcs) (inputs := inputs) (evalBase := evalBase)
      (B := B) (publicTable := publicTable) (tableBackedBy := tableBackedBy)
      (readSessionKey := readSessionKey) (pairedSessionKey := pairedSessionKey)
      (validAddressColumns := validAddressColumns)
      (kernelAddressBound := kernelAddressBound)
      (readCheckExpression := readCheckExpression)
      (rwReadCheckExpression := rwReadCheckExpression)
      (writeCheckExpression := writeCheckExpression)
      (valEvaluationExpression := valEvaluationExpression)
      (readOnlyMemoryRelation := readOnlyMemoryRelation)
      (readWriteMemoryRelation := readWriteMemoryRelation)
      (incrementRelation := incrementRelation) (rom := rom) (σ := σ)
      (init := init)) :
  List (ContinuityBridge.PreparedStep W Z Commitment F) :=
  (traceOf frames).map (fun frame =>
    ContinuityBridge.mkPreparedStep rootCtx.rootEncode rootCtx.ajtaiCommit frame.row)

structure KernelSoundnessConclusion
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
  (frames :
    KernelFrames (pcs := pcs) (inputs := inputs) (evalBase := evalBase)
      (B := B) (publicTable := publicTable) (tableBackedBy := tableBackedBy)
      (readSessionKey := readSessionKey) (pairedSessionKey := pairedSessionKey)
      (validAddressColumns := validAddressColumns)
      (kernelAddressBound := kernelAddressBound)
      (readCheckExpression := readCheckExpression)
      (rwReadCheckExpression := rwReadCheckExpression)
      (writeCheckExpression := writeCheckExpression)
      (valEvaluationExpression := valEvaluationExpression)
      (readOnlyMemoryRelation := readOnlyMemoryRelation)
      (readWriteMemoryRelation := readWriteMemoryRelation)
      (incrementRelation := incrementRelation) (rom := rom) (σ := σ)
      (init := init))
  (pts : KernelPoints)
  (kernelManifest : KernelOpeningManifest Value Digest)
  (rootManifest : RootOpeningManifest Value Digest)
  (events : List TranscriptEvent)
  (accounting : KernelSoundnessAccounting) where
  chunkTrace :
    AuthenticatedTrace.AuthenticatedChunkTraceBound (inputs := inputs) frames
  stage2TemporalSeeds :
    List.Forall
      (AuthenticatedTrace.Stage2TemporalSeedSummaryEntry (inputs := inputs)
        (evalBase := evalBase) (B := B)) frames
  temporalSupport :
    AuthenticatedTrace.AuthenticatedTemporalSupportBound (inputs := inputs)
      frames
  rootCtxBound :
    RootHandoffContextBound inputs rootCtx
  preparedStepCount :
    (kernelPreparedSteps rootCtx frames).length =
      inputs.pubMeta.semanticRows
  preparedStepTrace :
    StepComposition.PreparedStepTraceBound rootCtx.rootEncode rootCtx.ajtaiCommit (traceOf frames)
      (kernelPreparedSteps rootCtx frames)
  root0Bindings : List Root0CommitmentBinding
  root0BindingsConform :
    root0CommitmentBindingsConform root0Bindings
  kernelClaimsFixedInRoot0 :
    ∀ claim, claim ∈ kernelManifest → claim.commitmentId ∈ root0CommitmentIds
  kernelRootCommitmentsDisjoint :
    ∀ {kernelClaim rootClaim},
      kernelClaim ∈ kernelManifest →
        rootClaim ∈ rootManifest →
        kernelClaim.commitmentId ≠ rootClaim.commitmentId
  challengeAfterPhase0 :
    ∀ {e : TranscriptEvent},
      ChallengeEvent e →
        ∃ rest, events = phase0Events root0Bindings ++ rest ∧ e ∈ rest
  stage1TerminalAfterPhase0 :
    ∀ {e : TranscriptEvent},
      Stage1TerminalPointEvent e →
        ∃ rest, events = phase0Events root0Bindings ++ rest ∧ e ∈ rest
  stage2TerminalAfterPhase0 :
    ∀ {e : TranscriptEvent},
      Stage2TerminalPointEvent e →
        ∃ rest, events = phase0Events root0Bindings ++ rest ∧ e ∈ rest
  rowBindingCoverage :
    ∀ j : Nat,
      TranscriptEvent.rowBinding j ∈ events ↔ j < inputs.pubMeta.semanticRows
  emitKernelOpeningClaimsLast :
    ∃ pre, events = pre ++ [.emitKernelOpeningClaims]
  negligibleTotal :
    SuperNeo.ProofSystem.IsNegligible accounting.epsTotal

structure KernelSoundnessAccepted
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
  (frames :
    KernelFrames (pcs := pcs) (inputs := inputs) (evalBase := evalBase)
      (B := B) (publicTable := publicTable) (tableBackedBy := tableBackedBy)
      (readSessionKey := readSessionKey) (pairedSessionKey := pairedSessionKey)
      (validAddressColumns := validAddressColumns)
      (kernelAddressBound := kernelAddressBound)
      (readCheckExpression := readCheckExpression)
      (rwReadCheckExpression := rwReadCheckExpression)
      (writeCheckExpression := writeCheckExpression)
      (valEvaluationExpression := valEvaluationExpression)
      (readOnlyMemoryRelation := readOnlyMemoryRelation)
      (readWriteMemoryRelation := readWriteMemoryRelation)
      (incrementRelation := incrementRelation) (rom := rom) (σ := σ)
      (init := init))
  (pts : KernelPoints)
  (kernelManifest : KernelOpeningManifest Value Digest)
  (rootManifest : RootOpeningManifest Value Digest)
  (events : List TranscriptEvent) where
  trace : ExactTraceEvidence frames
  chunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)
  boundary :
    ExactKernelOpeningBoundary pts kernelManifest rootManifest
  root0Bindings : List Root0CommitmentBinding
  schedule :
    KernelTranscriptSchedule root0Bindings inputs.pubMeta.semanticRows events
  rootCtxBound :
    RootHandoffContextBound inputs rootCtx
  support :
    AuthenticatedTrace.AuthenticatedTemporalSupportBound (inputs := inputs)
      frames

def kernelSoundness_of_boundaries
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {frames :
    KernelFrames (pcs := pcs) (inputs := inputs) (evalBase := evalBase)
      (B := B) (publicTable := publicTable) (tableBackedBy := tableBackedBy)
      (readSessionKey := readSessionKey) (pairedSessionKey := pairedSessionKey)
      (validAddressColumns := validAddressColumns)
      (kernelAddressBound := kernelAddressBound)
      (readCheckExpression := readCheckExpression)
      (rwReadCheckExpression := rwReadCheckExpression)
      (writeCheckExpression := writeCheckExpression)
      (valEvaluationExpression := valEvaluationExpression)
      (readOnlyMemoryRelation := readOnlyMemoryRelation)
      (readWriteMemoryRelation := readWriteMemoryRelation)
      (incrementRelation := incrementRelation) (rom := rom) (σ := σ)
      (init := init)}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  {root0Bindings : List Root0CommitmentBinding}
  {events : List TranscriptEvent}
  {accounting : KernelSoundnessAccounting}
  (hTrace : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames))
  (hBoundary : ExactKernelOpeningBoundary pts kernelManifest rootManifest)
  (hSchedule :
    KernelTranscriptSchedule root0Bindings inputs.pubMeta.semanticRows events)
  (hRootCtx :
    RootHandoffContextBound inputs rootCtx)
  (hSupport :
    AuthenticatedTrace.AuthenticatedTemporalSupportBound (inputs := inputs)
      frames) :
  KernelSoundnessConclusion rootCtx frames pts kernelManifest
    rootManifest events accounting := by
  refine
    { chunkTrace :=
        authenticatedChunkTraceBound_of_exactTrace (inputs := inputs) hTrace hChunk
      stage2TemporalSeeds :=
        AuthenticatedTrace.stage2TemporalSeedSummary_of_frames (inputs := inputs)
          (evalBase := evalBase) (B := B) frames
      temporalSupport := hSupport
      rootCtxBound := hRootCtx
      preparedStepCount := ?_
      preparedStepTrace := ?_
      root0Bindings := root0Bindings
      root0BindingsConform := hSchedule.1
      kernelClaimsFixedInRoot0 := ?_
      kernelRootCommitmentsDisjoint := ?_
      challengeAfterPhase0 := ?_
      stage1TerminalAfterPhase0 := ?_
      stage2TerminalAfterPhase0 := ?_
      rowBindingCoverage := ?_
      emitKernelOpeningClaimsLast := ?_
      negligibleTotal := accounting.negligible_epsTotal }
  · simpa [kernelPreparedSteps] using
      (preparedStepExport_of_exactTrace
        (inputs := inputs)
        (rootEncode := rootCtx.rootEncode)
        (ajtaiCommit := rootCtx.ajtaiCommit)
        hTrace hChunk).1
  · simpa [kernelPreparedSteps] using
      (preparedStepExport_of_exactTrace
        (inputs := inputs)
        (rootEncode := rootCtx.rootEncode)
        (ajtaiCommit := rootCtx.ajtaiCommit)
        hTrace hChunk).2
  · intro claim hMem
    exact kernelClaim_commitment_fixed_in_root0 hBoundary hMem
  · intro kernelClaim rootClaim hKernelMem hRootMem
    exact exact_kernel_root_commitments_disjoint hBoundary hKernelMem hRootMem
  · intro e hChallenge
    exact challenge_after_phase0 hSchedule hChallenge
  · intro e hTerminal
    exact stage1TerminalPoint_after_phase0 hSchedule hTerminal
  · intro e hTerminal
    exact stage2TerminalPoint_after_phase0 hSchedule hTerminal
  · intro j
    exact rowBinding_event_in_schedule_iff (j := j) hSchedule
  · exact emitKernelOpeningClaims_last hSchedule

def kernelSoundnessAccepted_of_exactBoundaries
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  {root0Bindings : List Root0CommitmentBinding}
  {events : List TranscriptEvent}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  (hTrace : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames))
  (hBoundary : ExactKernelOpeningBoundary pts kernelManifest rootManifest)
  (hSchedule :
    KernelTranscriptSchedule root0Bindings inputs.pubMeta.semanticRows events)
  (hRootCtx :
    RootHandoffContextBound inputs rootCtx) :
  KernelSoundnessAccepted (inputs := inputs) rootCtx frames pts kernelManifest
    rootManifest events := by
  exact
    { trace := hTrace
      chunk := hChunk
      boundary := hBoundary
      root0Bindings := root0Bindings
      schedule := hSchedule
      rootCtxBound := hRootCtx
      support :=
        AuthenticatedTrace.authenticatedTemporalSupportBound_of_exactTrace
          (inputs := inputs) hTrace }

def kernelSoundness_of_exactBoundaries
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  {root0Bindings : List Root0CommitmentBinding}
  {events : List TranscriptEvent}
  {accounting : KernelSoundnessAccounting}
  (hTrace : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames))
  (hBoundary : ExactKernelOpeningBoundary pts kernelManifest rootManifest)
  (hSchedule :
    KernelTranscriptSchedule root0Bindings inputs.pubMeta.semanticRows events)
  (hRootCtx :
    RootHandoffContextBound inputs rootCtx) :
  KernelSoundnessConclusion rootCtx frames pts kernelManifest
    rootManifest events accounting := by
  exact kernelSoundness_of_boundaries
    (inputs := inputs)
    (rootCtx := rootCtx)
    (accounting := accounting)
    hTrace hChunk hBoundary hSchedule hRootCtx
    (AuthenticatedTrace.authenticatedTemporalSupportBound_of_exactTrace
      (inputs := inputs) hTrace)

def kernelSoundness_of_acceptance
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  {events : List TranscriptEvent}
  {accounting : KernelSoundnessAccounting}
  (hAccepted :
    KernelSoundnessAccepted (inputs := inputs) rootCtx frames pts kernelManifest
      rootManifest events) :
  KernelSoundnessConclusion rootCtx frames pts kernelManifest
    rootManifest events accounting := by
  exact kernelSoundness_of_boundaries
    (rootCtx := rootCtx)
    (accounting := accounting)
    (root0Bindings := hAccepted.root0Bindings)
    hAccepted.trace hAccepted.chunk hAccepted.boundary hAccepted.schedule
    hAccepted.rootCtxBound hAccepted.support

theorem kernelAcceptanceImpliesAuthenticatedChunkTrace
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  {events : List TranscriptEvent}
  {accounting : KernelSoundnessAccounting}
  (hAccepted :
    KernelSoundnessAccepted (inputs := inputs) rootCtx frames pts kernelManifest
      rootManifest events) :
  AuthenticatedTrace.AuthenticatedChunkTraceBound (inputs := inputs) frames := by
  exact
    (kernelSoundness_of_acceptance
      (inputs := inputs)
      (rootCtx := rootCtx)
      (accounting := accounting)
      hAccepted).chunkTrace

theorem kernelAcceptanceImpliesAuthenticatedExecutionTrace
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  {events : List TranscriptEvent}
  (hAccepted :
    KernelSoundnessAccepted (inputs := inputs) rootCtx frames pts kernelManifest
      rootManifest events) :
  AuthenticatedTrace.AuthenticatedExecutionTraceBound (inputs := inputs) frames := by
  exact authenticatedExecutionTraceBound_of_exactTrace_and_support
    (inputs := inputs) hAccepted.trace hAccepted.chunk hAccepted.support

theorem kernelAcceptanceImpliesStage2TemporalSeeds
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  {events : List TranscriptEvent}
  {accounting : KernelSoundnessAccounting}
  (hAccepted :
    KernelSoundnessAccepted (inputs := inputs) rootCtx frames pts kernelManifest
      rootManifest events) :
  List.Forall
    (AuthenticatedTrace.Stage2TemporalSeedSummaryEntry (inputs := inputs)
      (evalBase := evalBase) (B := B)) frames := by
  exact
    (kernelSoundness_of_acceptance
      (inputs := inputs)
      (rootCtx := rootCtx)
      (accounting := accounting)
      hAccepted).stage2TemporalSeeds

theorem kernelAcceptanceImpliesTemporalSupport
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  {events : List TranscriptEvent}
  {accounting : KernelSoundnessAccounting}
  (hAccepted :
    KernelSoundnessAccepted (inputs := inputs) rootCtx frames pts kernelManifest
      rootManifest events) :
  AuthenticatedTrace.AuthenticatedTemporalSupportBound (inputs := inputs)
    frames := by
  exact
    (kernelSoundness_of_acceptance
      (inputs := inputs)
      (rootCtx := rootCtx)
      (accounting := accounting)
      hAccepted).temporalSupport

theorem kernelAcceptanceImpliesExecutionCorrect
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  {events : List TranscriptEvent}
  (hAccepted :
    KernelSoundnessAccepted (inputs := inputs) rootCtx frames pts kernelManifest
      rootManifest events) :
  StepComposition.ExecutionCorrect rom σ init (traceOf frames) := by
  exact executionCorrect_of_authenticatedExecutionTraceBound
    (kernelAcceptanceImpliesAuthenticatedExecutionTrace
      (inputs := inputs) hAccepted)

theorem kernelAcceptanceImpliesTraceLinkBound
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  {events : List TranscriptEvent}
  (hAccepted :
    KernelSoundnessAccepted (inputs := inputs) rootCtx frames pts kernelManifest
      rootManifest events) :
  TraceLinkBoundary.TraceLinkBound (traceOf frames) := by
  exact AuthenticatedTrace.traceLinkBound_of_authenticatedExecutionTraceBound
    (kernelAcceptanceImpliesAuthenticatedExecutionTrace
      (inputs := inputs) hAccepted)

theorem kernelAcceptanceImpliesExecutionLinked
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  {events : List TranscriptEvent}
  (hAccepted :
    KernelSoundnessAccepted (inputs := inputs) rootCtx frames pts kernelManifest
      rootManifest events) :
  StepComposition.ExecutionLinked (traceOf frames) := by
  exact TraceLinkBoundary.executionLinked_of_traceLinkBound
    (kernelAcceptanceImpliesTraceLinkBound
      (inputs := inputs) hAccepted)

theorem kernelAcceptanceImpliesPreparedStepExport
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  {events : List TranscriptEvent}
  {accounting : KernelSoundnessAccounting}
  (hAccepted :
    KernelSoundnessAccepted (inputs := inputs) rootCtx frames pts kernelManifest
      rootManifest events) :
  (kernelPreparedSteps rootCtx frames).length =
      inputs.pubMeta.semanticRows ∧
    StepComposition.PreparedStepTraceBound rootCtx.rootEncode rootCtx.ajtaiCommit (traceOf frames)
      (kernelPreparedSteps rootCtx frames) := by
  exact
    ⟨(kernelSoundness_of_acceptance
        (inputs := inputs)
        (rootCtx := rootCtx)
        (accounting := accounting)
        hAccepted).preparedStepCount,
      (kernelSoundness_of_acceptance
        (inputs := inputs)
        (rootCtx := rootCtx)
        (accounting := accounting)
        hAccepted).preparedStepTrace⟩

theorem kernelAcceptanceImpliesNegligibleTotal
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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  {events : List TranscriptEvent}
  {accounting : KernelSoundnessAccounting}
  (hAccepted :
    KernelSoundnessAccepted (inputs := inputs) rootCtx frames pts kernelManifest
      rootManifest events) :
  SuperNeo.ProofSystem.IsNegligible accounting.epsTotal := by
  exact
    (kernelSoundness_of_acceptance
      (inputs := inputs)
      (rootCtx := rootCtx)
      (accounting := accounting)
      hAccepted).negligibleTotal

end Kernel

end Nightstream.Chip8.KernelSoundness

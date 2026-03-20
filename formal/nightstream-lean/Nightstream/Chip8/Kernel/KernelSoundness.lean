import Nightstream.Chip8.Trace.AuthenticatedTrace
import Nightstream.Chip8.Trace.TemporalConsistency
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
  (rootEncode : RootEncode W Z F)
  (ajtaiCommit : Z → Commitment)
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) :
  List (ContinuityBridge.PreparedStep W Z Commitment F) :=
  (traceOf frames).map (fun frame =>
    ContinuityBridge.mkPreparedStep rootEncode ajtaiCommit frame.row)

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
  (rootEncode : RootEncode W Z F)
  (ajtaiCommit : Z → Commitment)
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init))
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
  preparedStepCount :
    (kernelPreparedSteps rootEncode ajtaiCommit frames).length =
      inputs.pubMeta.semanticRows
  preparedStepTrace :
    StepComposition.PreparedStepTraceBound rootEncode ajtaiCommit (traceOf frames)
      (kernelPreparedSteps rootEncode ajtaiCommit frames)
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
        ∃ rest, events = phase0Events ++ rest ∧ e ∈ rest
  stage1TerminalAfterPhase0 :
    ∀ {e : TranscriptEvent},
      Stage1TerminalPointEvent e →
        ∃ rest, events = phase0Events ++ rest ∧ e ∈ rest
  stage2TerminalAfterPhase0 :
    ∀ {e : TranscriptEvent},
      Stage2TerminalPointEvent e →
        ∃ rest, events = phase0Events ++ rest ∧ e ∈ rest
  rowBindingCoverage :
    ∀ j : Nat,
      TranscriptEvent.rowBinding j ∈ events ↔ j < inputs.pubMeta.semanticRows
  emitKernelOpeningClaimsLast :
    ∃ pre, events = pre ++ [.emitKernelOpeningClaims]
  negligibleTotal :
    SuperNeo.ProofSystem.IsNegligible accounting.epsTotal

def KernelSoundnessAccepted
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
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init))
  (pts : KernelPoints)
  (kernelManifest : KernelOpeningManifest Value Digest)
  (rootManifest : RootOpeningManifest Value Digest)
  (events : List TranscriptEvent) : Prop :=
  ExactTraceEvidence frames ∧
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames) ∧
    ExactKernelOpeningBoundary pts kernelManifest rootManifest ∧
    KernelTranscriptSchedule inputs.pubMeta.semanticRows events ∧
    AuthenticatedTrace.AuthenticatedTemporalSupportBound (inputs := inputs)
      frames

theorem kernelSoundness_of_boundaries
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
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
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
  (hTrace : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames))
  (hBoundary : ExactKernelOpeningBoundary pts kernelManifest rootManifest)
  (hSchedule :
    KernelTranscriptSchedule inputs.pubMeta.semanticRows events)
  (hSupport :
    AuthenticatedTrace.AuthenticatedTemporalSupportBound (inputs := inputs)
      frames) :
  KernelSoundnessConclusion rootEncode ajtaiCommit frames pts kernelManifest
    rootManifest events accounting := by
  refine
    { chunkTrace :=
        authenticatedChunkTraceBound_of_exactTrace (inputs := inputs) hTrace hChunk
      stage2TemporalSeeds :=
        AuthenticatedTrace.stage2TemporalSeedSummary_of_frames (inputs := inputs)
          (evalBase := evalBase) (B := B) frames
      temporalSupport := hSupport
      preparedStepCount := ?_
      preparedStepTrace := ?_
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
        (rootEncode := rootEncode)
        (ajtaiCommit := ajtaiCommit)
        hTrace hChunk).1
  · simpa [kernelPreparedSteps] using
      (preparedStepExport_of_exactTrace
        (inputs := inputs)
        (rootEncode := rootEncode)
        (ajtaiCommit := ajtaiCommit)
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

theorem kernelSoundness_of_acceptance
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
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
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
    KernelSoundnessAccepted (inputs := inputs) frames pts kernelManifest
      rootManifest events) :
  KernelSoundnessConclusion rootEncode ajtaiCommit frames pts kernelManifest
    rootManifest events accounting := by
  rcases hAccepted with ⟨hTrace, hChunk, hBoundary, hSchedule, hSupport⟩
  exact kernelSoundness_of_boundaries
    (rootEncode := rootEncode)
    (ajtaiCommit := ajtaiCommit)
    (accounting := accounting)
    hTrace hChunk hBoundary hSchedule hSupport

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
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
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
    KernelSoundnessAccepted (inputs := inputs) frames pts kernelManifest
      rootManifest events) :
  AuthenticatedTrace.AuthenticatedChunkTraceBound (inputs := inputs) frames := by
  exact
    (kernelSoundness_of_acceptance
      (inputs := inputs)
      (rootEncode := rootEncode)
      (ajtaiCommit := ajtaiCommit)
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
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
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
    KernelSoundnessAccepted (inputs := inputs) frames pts kernelManifest
      rootManifest events) :
  AuthenticatedTrace.AuthenticatedExecutionTraceBound (inputs := inputs) frames := by
  rcases hAccepted with ⟨hExact, hChunk, _, _, hSupport⟩
  exact authenticatedExecutionTraceBound_of_exactTrace_and_support
    (inputs := inputs) hExact hChunk hSupport

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
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
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
    KernelSoundnessAccepted (inputs := inputs) frames pts kernelManifest
      rootManifest events) :
  List.Forall
    (AuthenticatedTrace.Stage2TemporalSeedSummaryEntry (inputs := inputs)
      (evalBase := evalBase) (B := B)) frames := by
  exact
    (kernelSoundness_of_acceptance
      (inputs := inputs)
      (rootEncode := rootEncode)
      (ajtaiCommit := ajtaiCommit)
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
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
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
    KernelSoundnessAccepted (inputs := inputs) frames pts kernelManifest
      rootManifest events) :
  AuthenticatedTrace.AuthenticatedTemporalSupportBound (inputs := inputs)
    frames := by
  exact
    (kernelSoundness_of_acceptance
      (inputs := inputs)
      (rootEncode := rootEncode)
      (ajtaiCommit := ajtaiCommit)
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
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
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
    KernelSoundnessAccepted (inputs := inputs) frames pts kernelManifest
      rootManifest events) :
  StepComposition.ExecutionCorrect rom σ init (traceOf frames) := by
  exact executionCorrect_of_authenticatedExecutionTraceBound
    (kernelAcceptanceImpliesAuthenticatedExecutionTrace
      (inputs := inputs)
      (rootEncode := rootEncode)
      (ajtaiCommit := ajtaiCommit)
      (accounting := accounting)
      hAccepted)

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
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
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
    KernelSoundnessAccepted (inputs := inputs) frames pts kernelManifest
      rootManifest events) :
  TraceLinkBoundary.TraceLinkBound (traceOf frames) := by
  exact AuthenticatedTrace.traceLinkBound_of_authenticatedExecutionTraceBound
    (kernelAcceptanceImpliesAuthenticatedExecutionTrace
      (inputs := inputs)
      (rootEncode := rootEncode)
      (ajtaiCommit := ajtaiCommit)
      (accounting := accounting)
      hAccepted)

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
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
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
    KernelSoundnessAccepted (inputs := inputs) frames pts kernelManifest
      rootManifest events) :
  StepComposition.ExecutionLinked (traceOf frames) := by
  exact TraceLinkBoundary.executionLinked_of_traceLinkBound
    (kernelAcceptanceImpliesTraceLinkBound
      (inputs := inputs)
      (rootEncode := rootEncode)
      (ajtaiCommit := ajtaiCommit)
      (accounting := accounting)
      hAccepted)

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
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
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
    KernelSoundnessAccepted (inputs := inputs) frames pts kernelManifest
      rootManifest events) :
  (kernelPreparedSteps rootEncode ajtaiCommit frames).length =
      inputs.pubMeta.semanticRows ∧
    StepComposition.PreparedStepTraceBound rootEncode ajtaiCommit (traceOf frames)
      (kernelPreparedSteps rootEncode ajtaiCommit frames) := by
  exact
    ⟨(kernelSoundness_of_acceptance
        (inputs := inputs)
        (rootEncode := rootEncode)
        (ajtaiCommit := ajtaiCommit)
        (accounting := accounting)
        hAccepted).preparedStepCount,
      (kernelSoundness_of_acceptance
        (inputs := inputs)
        (rootEncode := rootEncode)
        (ajtaiCommit := ajtaiCommit)
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
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
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
    KernelSoundnessAccepted (inputs := inputs) frames pts kernelManifest
      rootManifest events) :
  SuperNeo.ProofSystem.IsNegligible accounting.epsTotal := by
  exact
    (kernelSoundness_of_acceptance
      (inputs := inputs)
      (rootEncode := rootEncode)
      (ajtaiCommit := ajtaiCommit)
      (accounting := accounting)
      hAccepted).negligibleTotal

end Kernel

end Nightstream.Chip8.KernelSoundness

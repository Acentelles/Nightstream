import Nightstream.Chip8.Kernel.BridgeBinding
import Nightstream.Chip8.Kernel.KernelSoundness

/-!
Owns the normalized digest contract for one authenticated CHIP-8 kernel chunk.
This file repackages the exact top-level kernel theorem surface for comparison
and audit; it does not re-own any stage-local or trace-local theorem.
-/

namespace Nightstream.Chip8.KernelExecutionDigest

open Nightstream.Chip8
open Nightstream.Chip8.AuthenticatedTrace
open Nightstream.Chip8.BridgeBinding
open Nightstream.Chip8.KernelSoundness
open Nightstream.Chip8.TranscriptSchedule
open Nightstream.Chip8.SoundnessAccounting
open Nightstream.Chip8.ExactOpeningBoundary

abbrev F := KernelSoundness.F
abbrev Program := KernelSoundness.Program
abbrev MachineState := KernelSoundness.MachineState
abbrev InitialState := KernelSoundness.InitialState
abbrev ExternalSchedule := KernelSoundness.ExternalSchedule
abbrev ExecutionFrame := KernelSoundness.ExecutionFrame
abbrev RootEncode := @KernelSoundness.RootEncode

section Digest

variable
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr Table ValSurface
    Increment SessionKey : Type*}
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}
  {W Z Commitment Value Digest : Type*}

structure KernelTraceSurface
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
        incrementRelation rom σ init)) where
  chunkTrace :
    AuthenticatedChunkTraceBound (inputs := inputs) frames
  stage2TemporalSeeds :
    List.Forall
      (AuthenticatedTrace.Stage2TemporalSeedSummaryEntry (inputs := inputs)
        (evalBase := evalBase) (B := B)) frames
  temporalSupport :
    AuthenticatedTrace.AuthenticatedTemporalSupportBound (inputs := inputs)
      frames

def RowProjectionSummaryEntry
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
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) : Prop :=
  ∃ Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F),
    ∃ row : EvidenceCoverage.RowView,
      EvidenceCoverage.ExactSemanticEvidenceCovered pcs inputs evalBase B
        publicTable tableBackedBy readSessionKey pairedSessionKey
        validAddressColumns kernelAddressBound readCheckExpression
        rwReadCheckExpression writeCheckExpression valEvaluationExpression
        readOnlyMemoryRelation readWriteMemoryRelation incrementRelation rom σ
        frame.stepIdx init frame.frame.pre frame.frame.post frame.frame.dec
        frame.frame.row ∧
      EvidenceCoverage.RowProjectionWitness pcs evalBase B Γ₁ row

def BridgeBindingSummaryEntry
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
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) : Prop :=
  ∃ rowClaim,
    BridgeBindingWitness rootEncode ajtaiCommit frame.stepIdx frame.frame.row
      rowClaim
      (ContinuityBridge.mkPreparedStep rootEncode ajtaiCommit frame.frame.row)

theorem rowProjectionSummary_of_frames
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
        incrementRelation rom σ init)) :
  List.Forall (RowProjectionSummaryEntry (inputs := inputs) (evalBase := evalBase)
    (B := B)) frames := by
  rw [List.forall_iff_forall_mem]
  intro frame _hMem
  rcases exists_rowProjection_of_exactEvidence frame.exactEvidence with
    ⟨Γ₁, row, hProjection⟩
  exact ⟨Γ₁, row, frame.exactEvidence, hProjection⟩

theorem bridgeBindingSummary_of_frames
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
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) :
  List.Forall
    (BridgeBindingSummaryEntry (inputs := inputs) (evalBase := evalBase)
      (B := B) rootEncode ajtaiCommit) frames := by
  rw [List.forall_iff_forall_mem]
  intro frame _hMem
  exact exists_bridgeBindingWitness_of_exactEvidence
    (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit)
    frame.exactEvidence

structure KernelAuditSurface
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
        incrementRelation rom σ init)) where
  rowProjectionSummary :
    List.Forall (RowProjectionSummaryEntry (inputs := inputs)
      (evalBase := evalBase) (B := B)) frames
  bridgeBindingSummary :
    List.Forall
      (BridgeBindingSummaryEntry (inputs := inputs) (evalBase := evalBase)
        (B := B) rootEncode ajtaiCommit) frames

structure KernelExportSurface
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
        incrementRelation rom σ init)) where
  preparedStepCount :
    (kernelPreparedSteps rootEncode ajtaiCommit frames).length =
      inputs.pubMeta.semanticRows
  preparedStepTrace :
    StepComposition.PreparedStepTraceBound rootEncode ajtaiCommit (traceOf frames)
      (kernelPreparedSteps rootEncode ajtaiCommit frames)

structure KernelManifestSurface
  (kernelManifest : KernelOpeningManifest Value Digest)
  (rootManifest : RootOpeningManifest Value Digest) where
  kernelClaimsFixedInRoot0 :
    ∀ claim, claim ∈ kernelManifest → claim.commitmentId ∈ root0CommitmentIds
  kernelRootCommitmentsDisjoint :
    ∀ {kernelClaim rootClaim},
      kernelClaim ∈ kernelManifest →
        rootClaim ∈ rootManifest →
        kernelClaim.commitmentId ≠ rootClaim.commitmentId

structure KernelTranscriptSurface
  (semanticRows : Nat)
  (events : List TranscriptEvent) where
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
      TranscriptEvent.rowBinding j ∈ events ↔ j < semanticRows
  emitKernelOpeningClaimsLast :
    ∃ pre, events = pre ++ [.emitKernelOpeningClaims]

structure KernelErrorSurface
  (accounting : KernelSoundnessAccounting) where
  negligibleTotal :
    SuperNeo.ProofSystem.IsNegligible accounting.epsTotal

structure ExecutionDigest
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
  trace : KernelTraceSurface frames
  exported : KernelExportSurface rootEncode ajtaiCommit frames
  audit : KernelAuditSurface rootEncode ajtaiCommit frames
  manifest : KernelManifestSurface kernelManifest rootManifest
  transcript : KernelTranscriptSurface inputs.pubMeta.semanticRows events
  error : KernelErrorSurface accounting

set_option linter.dupNamespace false in
abbrev KernelExecutionDigest := @ExecutionDigest

def KernelExecutionDigestBound
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
  (accounting : KernelSoundnessAccounting)
  (_d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) : Prop :=
  AuthenticatedChunkTraceBound (inputs := inputs) frames ∧
    List.Forall
      (AuthenticatedTrace.Stage2TemporalSeedSummaryEntry (inputs := inputs)
        (evalBase := evalBase) (B := B)) frames ∧
    (kernelPreparedSteps rootEncode ajtaiCommit frames).length =
      inputs.pubMeta.semanticRows ∧
    StepComposition.PreparedStepTraceBound rootEncode ajtaiCommit (traceOf frames)
      (kernelPreparedSteps rootEncode ajtaiCommit frames) ∧
    List.Forall (RowProjectionSummaryEntry (inputs := inputs)
      (evalBase := evalBase) (B := B)) frames ∧
    List.Forall
      (BridgeBindingSummaryEntry (inputs := inputs) (evalBase := evalBase)
        (B := B) rootEncode ajtaiCommit) frames ∧
    (∀ claim, claim ∈ kernelManifest → claim.commitmentId ∈ root0CommitmentIds) ∧
    (∀ {kernelClaim rootClaim},
      kernelClaim ∈ kernelManifest →
        rootClaim ∈ rootManifest →
        kernelClaim.commitmentId ≠ rootClaim.commitmentId) ∧
    (∀ {e : TranscriptEvent},
      ChallengeEvent e →
        ∃ rest, events = phase0Events ++ rest ∧ e ∈ rest) ∧
    (∀ {e : TranscriptEvent},
      Stage1TerminalPointEvent e →
        ∃ rest, events = phase0Events ++ rest ∧ e ∈ rest) ∧
    (∀ {e : TranscriptEvent},
      Stage2TerminalPointEvent e →
        ∃ rest, events = phase0Events ++ rest ∧ e ∈ rest) ∧
    (∀ j : Nat,
      TranscriptEvent.rowBinding j ∈ events ↔ j < inputs.pubMeta.semanticRows) ∧
    (∃ pre, events = pre ++ [.emitKernelOpeningClaims]) ∧
    SuperNeo.ProofSystem.IsNegligible accounting.epsTotal ∧
    AuthenticatedTrace.AuthenticatedTemporalSupportBound (inputs := inputs)
      frames

theorem kernelExecutionDigest_of_conclusion
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
  (hKernel :
    KernelSoundnessConclusion rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting) :
  ∃ d :
      ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest
        rootManifest events accounting,
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d := by
  refine ⟨{
      trace := {
        chunkTrace := hKernel.chunkTrace
        stage2TemporalSeeds := hKernel.stage2TemporalSeeds
        temporalSupport := hKernel.temporalSupport
      }
      exported := {
        preparedStepCount := hKernel.preparedStepCount
        preparedStepTrace := hKernel.preparedStepTrace
      }
      audit := {
        rowProjectionSummary := rowProjectionSummary_of_frames (inputs := inputs)
          (evalBase := evalBase) (B := B) frames
        bridgeBindingSummary := bridgeBindingSummary_of_frames
          (inputs := inputs) (evalBase := evalBase) (B := B)
          (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit) frames
      }
      manifest := {
        kernelClaimsFixedInRoot0 := hKernel.kernelClaimsFixedInRoot0
        kernelRootCommitmentsDisjoint := hKernel.kernelRootCommitmentsDisjoint
      }
      transcript := {
        challengeAfterPhase0 := hKernel.challengeAfterPhase0
        stage1TerminalAfterPhase0 := hKernel.stage1TerminalAfterPhase0
        stage2TerminalAfterPhase0 := hKernel.stage2TerminalAfterPhase0
        rowBindingCoverage := hKernel.rowBindingCoverage
        emitKernelOpeningClaimsLast := hKernel.emitKernelOpeningClaimsLast
      }
      error := { negligibleTotal := hKernel.negligibleTotal }
    }, ?_⟩
  exact ⟨hKernel.chunkTrace, hKernel.stage2TemporalSeeds,
    hKernel.preparedStepCount, hKernel.preparedStepTrace,
    rowProjectionSummary_of_frames (inputs := inputs) (evalBase := evalBase)
      (B := B) frames,
    bridgeBindingSummary_of_frames (inputs := inputs) (evalBase := evalBase)
      (B := B) (rootEncode := rootEncode) (ajtaiCommit := ajtaiCommit) frames,
    hKernel.kernelClaimsFixedInRoot0, hKernel.kernelRootCommitmentsDisjoint,
    hKernel.challengeAfterPhase0, hKernel.stage1TerminalAfterPhase0,
    hKernel.stage2TerminalAfterPhase0, hKernel.rowBindingCoverage,
    hKernel.emitKernelOpeningClaimsLast, hKernel.negligibleTotal,
    hKernel.temporalSupport⟩

theorem kernelExecutionDigest_of_acceptance
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
  ∃ d :
      ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest
        rootManifest events accounting,
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d := by
  exact kernelExecutionDigest_of_conclusion
    (KernelSoundness.kernelSoundness_of_acceptance
      (inputs := inputs)
      (rootEncode := rootEncode)
      (ajtaiCommit := ajtaiCommit)
      (accounting := accounting)
      hAccepted)

theorem authenticatedChunkTraceBound_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  AuthenticatedChunkTraceBound (inputs := inputs) frames := h.1

theorem preparedStepExport_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  (kernelPreparedSteps rootEncode ajtaiCommit frames).length =
      inputs.pubMeta.semanticRows ∧
    StepComposition.PreparedStepTraceBound rootEncode ajtaiCommit (traceOf frames)
      (kernelPreparedSteps rootEncode ajtaiCommit frames) := by
  exact ⟨h.2.2.1, h.2.2.2.1⟩

theorem stage2TemporalSeeds_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  List.Forall
    (AuthenticatedTrace.Stage2TemporalSeedSummaryEntry (inputs := inputs)
      (evalBase := evalBase) (B := B)) frames := by
  exact h.2.1

theorem temporalSupport_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  AuthenticatedTrace.AuthenticatedTemporalSupportBound (inputs := inputs)
    frames := by
  rcases h with
    ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, hTail⟩
  exact hTail.2

theorem authenticatedExecutionTraceBound_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  AuthenticatedTrace.AuthenticatedExecutionTraceBound (inputs := inputs)
    frames := by
  have hChunkTrace := authenticatedChunkTraceBound_of_digest
    (inputs := inputs) (evalBase := evalBase) (B := B) h
  have hStage2Seeds := stage2TemporalSeeds_of_digest
    (inputs := inputs) (evalBase := evalBase) (B := B) h
  have hSupport := temporalSupport_of_digest (inputs := inputs) h
  have hTemporal :=
    AuthenticatedTrace.temporalInstantiationBound_of_authenticatedTemporalSupport
      hChunkTrace.framesBound hSupport
  exact
    { chunkTrace := hChunkTrace
      stage2TemporalSeeds := hStage2Seeds
      temporalSupport := hSupport
      temporal := hTemporal }

theorem rowProjectionSummary_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  List.Forall (RowProjectionSummaryEntry (inputs := inputs)
    (evalBase := evalBase) (B := B)) frames := by
  exact h.2.2.2.2.1

theorem bridgeBindingSummary_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  List.Forall
    (BridgeBindingSummaryEntry (inputs := inputs) (evalBase := evalBase)
      (B := B) rootEncode ajtaiCommit) frames := by
  exact h.2.2.2.2.2.1

theorem kernelClaimsFixedInRoot0_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  ∀ claim, claim ∈ kernelManifest → claim.commitmentId ∈ root0CommitmentIds := by
  exact h.2.2.2.2.2.2.1

theorem kernelRootCommitmentsDisjoint_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  ∀ {kernelClaim rootClaim},
    kernelClaim ∈ kernelManifest →
      rootClaim ∈ rootManifest →
      kernelClaim.commitmentId ≠ rootClaim.commitmentId := by
  exact h.2.2.2.2.2.2.2.1

theorem challengeAfterPhase0_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  ∀ {e : TranscriptEvent},
    ChallengeEvent e →
      ∃ rest, events = phase0Events ++ rest ∧ e ∈ rest := by
  exact h.2.2.2.2.2.2.2.2.1

theorem stage1TerminalAfterPhase0_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  ∀ {e : TranscriptEvent},
    Stage1TerminalPointEvent e →
      ∃ rest, events = phase0Events ++ rest ∧ e ∈ rest := by
  exact h.2.2.2.2.2.2.2.2.2.1

theorem stage2TerminalAfterPhase0_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  ∀ {e : TranscriptEvent},
    Stage2TerminalPointEvent e →
      ∃ rest, events = phase0Events ++ rest ∧ e ∈ rest := by
  exact h.2.2.2.2.2.2.2.2.2.2.1

theorem rowBindingCoverage_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  ∀ j : Nat,
    TranscriptEvent.rowBinding j ∈ events ↔ j < inputs.pubMeta.semanticRows := by
  exact h.2.2.2.2.2.2.2.2.2.2.2.1

theorem emitKernelOpeningClaimsLast_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  ∃ pre, events = pre ++ [.emitKernelOpeningClaims] := by
  exact h.2.2.2.2.2.2.2.2.2.2.2.2.1

theorem negligibleTotal_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  SuperNeo.ProofSystem.IsNegligible accounting.epsTotal := by
  rcases h with
    ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, hTail⟩
  exact hTail.1

theorem kernelSoundnessConclusion_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  KernelSoundnessConclusion rootEncode ajtaiCommit frames pts kernelManifest
    rootManifest events accounting := by
  rcases h with
    ⟨hChunkTrace, hStage2Seeds, hPreparedCount, hPreparedTrace, _hRowProjection,
      _hBridgeBinding, hRoot0, hDisjoint,
      hChallenge, hStage1Terminal, hStage2Terminal, hRowBinding, hEmit, hTail⟩
  let hNeg := hTail.1
  let hSupport := hTail.2
  exact
    { chunkTrace := hChunkTrace
      stage2TemporalSeeds := hStage2Seeds
      temporalSupport := hSupport
      preparedStepCount := hPreparedCount
      preparedStepTrace := hPreparedTrace
      kernelClaimsFixedInRoot0 := hRoot0
      kernelRootCommitmentsDisjoint := hDisjoint
      challengeAfterPhase0 := hChallenge
      stage1TerminalAfterPhase0 := hStage1Terminal
      stage2TerminalAfterPhase0 := hStage2Terminal
      rowBindingCoverage := hRowBinding
      emitKernelOpeningClaimsLast := hEmit
      negligibleTotal := hNeg }

theorem executionCorrect_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  StepComposition.ExecutionCorrect rom σ init (traceOf frames) := by
  have hExecTrace := authenticatedExecutionTraceBound_of_digest
    (inputs := inputs) (evalBase := evalBase) (B := B) h
  exact AuthenticatedTrace.executionCorrect_of_authenticatedExecutionTraceBound
    hExecTrace

theorem traceLinkBound_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  TraceLinkBoundary.TraceLinkBound (traceOf frames) := by
  have hExecTrace := authenticatedExecutionTraceBound_of_digest
    (inputs := inputs) (evalBase := evalBase) (B := B) h
  exact AuthenticatedTrace.traceLinkBound_of_authenticatedExecutionTraceBound
    hExecTrace

theorem executionLinked_of_digest
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
  {d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting}
  (h :
    KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  StepComposition.ExecutionLinked (traceOf frames) := by
  exact TraceLinkBoundary.executionLinked_of_traceLinkBound
    (traceLinkBound_of_digest h)

end Digest

end Nightstream.Chip8.KernelExecutionDigest

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
open Nightstream.Chip8.RootHandoffContext

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
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) : Prop :=
  ∃ preparedStep,
    ∃ Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F),
      Nonempty (
        BridgeBindingBundle (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
          (AddressPoint := AddressPoint) (CyclePoint := CyclePoint) pcs evalBase
          B Γ₁ frame.stepIdx frame.frame.pre frame.frame.post frame.frame.dec
          frame.frame.row rootCtx preparedStep)

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
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) :
  List.Forall
    (BridgeBindingSummaryEntry (inputs := inputs) (evalBase := evalBase)
      (B := B) rootCtx) frames := by
  rw [List.forall_iff_forall_mem]
  intro frame _hMem
  let preparedStep :=
    ContinuityBridge.mkPreparedStep rootCtx.rootEncode rootCtx.ajtaiCommit frame.frame.row
  have hPrepared :
      ContinuityBridge.PreparedStepBound rootCtx.rootEncode rootCtx.ajtaiCommit
        frame.frame.row preparedStep := by
    simp [ContinuityBridge.PreparedStepBound, ContinuityBridge.mkPreparedStep,
      preparedStep]
  rcases exists_bridgeBindingBundle_of_exactEvidence
      (rootCtx := rootCtx) (preparedStep := preparedStep)
      frame.exactEvidence hPrepared with
    ⟨Γ₁, hBundle⟩
  exact ⟨preparedStep, Γ₁, hBundle⟩

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
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
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
        (B := B) rootCtx) frames

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
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) where
  rootCtxBound :
    RootHandoffContextBound inputs rootCtx
  preparedStepCount :
    (kernelPreparedSteps rootCtx frames).length =
      inputs.pubMeta.semanticRows
  preparedStepTrace :
    StepComposition.PreparedStepTraceBound rootCtx.rootEncode rootCtx.ajtaiCommit (traceOf frames)
      (kernelPreparedSteps rootCtx frames)

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
  root0Bindings : List Root0CommitmentBinding
  root0BindingsConform :
    root0CommitmentBindingsConform root0Bindings
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
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
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
  exported : KernelExportSurface rootCtx frames
  audit : KernelAuditSurface rootCtx frames
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
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
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
  (d :
    ExecutionDigest rootCtx frames pts kernelManifest rootManifest
      events accounting) : Prop :=
  AuthenticatedChunkTraceBound (inputs := inputs) frames ∧
    List.Forall
      (AuthenticatedTrace.Stage2TemporalSeedSummaryEntry (inputs := inputs)
        (evalBase := evalBase) (B := B)) frames ∧
    (kernelPreparedSteps rootCtx frames).length =
      inputs.pubMeta.semanticRows ∧
    StepComposition.PreparedStepTraceBound rootCtx.rootEncode rootCtx.ajtaiCommit (traceOf frames)
      (kernelPreparedSteps rootCtx frames) ∧
    List.Forall (RowProjectionSummaryEntry (inputs := inputs)
      (evalBase := evalBase) (B := B)) frames ∧
    List.Forall
      (BridgeBindingSummaryEntry (inputs := inputs) (evalBase := evalBase)
        (B := B) rootCtx) frames ∧
    RootHandoffContextBound inputs rootCtx ∧
    root0CommitmentBindingsConform d.transcript.root0Bindings ∧
    (∀ claim, claim ∈ kernelManifest → claim.commitmentId ∈ root0CommitmentIds) ∧
    (∀ {kernelClaim rootClaim},
      kernelClaim ∈ kernelManifest →
        rootClaim ∈ rootManifest →
        kernelClaim.commitmentId ≠ rootClaim.commitmentId) ∧
    (∀ {e : TranscriptEvent},
      ChallengeEvent e →
        ∃ rest, events = phase0Events d.transcript.root0Bindings ++ rest ∧ e ∈ rest) ∧
    (∀ {e : TranscriptEvent},
      Stage1TerminalPointEvent e →
        ∃ rest, events = phase0Events d.transcript.root0Bindings ++ rest ∧ e ∈ rest) ∧
    (∀ {e : TranscriptEvent},
      Stage2TerminalPointEvent e →
        ∃ rest, events = phase0Events d.transcript.root0Bindings ++ rest ∧ e ∈ rest) ∧
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
  (hKernel :
    KernelSoundnessConclusion rootCtx frames pts kernelManifest
      rootManifest events accounting) :
  ∃ d :
      ExecutionDigest rootCtx frames pts kernelManifest
        rootManifest events accounting,
    KernelExecutionDigestBound rootCtx frames pts kernelManifest
      rootManifest events accounting d := by
  refine ⟨{
      trace := {
        chunkTrace := hKernel.chunkTrace
        stage2TemporalSeeds := hKernel.stage2TemporalSeeds
        temporalSupport := hKernel.temporalSupport
      }
      exported := {
        rootCtxBound := hKernel.rootCtxBound
        preparedStepCount := hKernel.preparedStepCount
        preparedStepTrace := hKernel.preparedStepTrace
      }
      audit := {
        rowProjectionSummary := rowProjectionSummary_of_frames (inputs := inputs)
          (evalBase := evalBase) (B := B) frames
        bridgeBindingSummary := bridgeBindingSummary_of_frames
          (inputs := inputs) (evalBase := evalBase) (B := B) (rootCtx := rootCtx)
          frames
      }
      manifest := {
        kernelClaimsFixedInRoot0 := hKernel.kernelClaimsFixedInRoot0
        kernelRootCommitmentsDisjoint := hKernel.kernelRootCommitmentsDisjoint
      }
      transcript := {
        root0Bindings := hKernel.root0Bindings
        root0BindingsConform := hKernel.root0BindingsConform
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
      (B := B) (rootCtx := rootCtx) frames,
    hKernel.rootCtxBound, hKernel.root0BindingsConform, hKernel.kernelClaimsFixedInRoot0,
    hKernel.kernelRootCommitmentsDisjoint,
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
  ∃ d :
      ExecutionDigest rootCtx frames pts kernelManifest
        rootManifest events accounting,
    KernelExecutionDigestBound rootCtx frames pts kernelManifest
      rootManifest events accounting d := by
  exact kernelExecutionDigest_of_conclusion
    (KernelSoundness.kernelSoundness_of_acceptance
      (inputs := inputs)
      (rootCtx := rootCtx)
      (accounting := accounting)
      hAccepted)


end Digest

end Nightstream.Chip8.KernelExecutionDigest

import Nightstream.Chip8.Kernel.KernelExecutionDigest

/-!
Owns the audit-checker contract over one authenticated CHIP-8 kernel chunk
digest. This file checks the kernel-level digest boundary; it does not re-own
cryptographic verification or any stage-local theorem.
-/

namespace Nightstream.Chip8.KernelArtifactAudit

open Nightstream.Chip8
open Nightstream.Chip8.AuthenticatedTrace
open Nightstream.Chip8.TraceLinkBoundary
open Nightstream.Chip8.TemporalConsistency
open Nightstream.Chip8.KernelExecutionDigest
open Nightstream.Chip8.KernelSoundness
open Nightstream.Chip8.SoundnessAccounting
open Nightstream.Chip8.ExactOpeningBoundary
open Nightstream.Chip8.TranscriptSchedule

abbrev F := KernelExecutionDigest.F
abbrev Program := KernelExecutionDigest.Program
abbrev MachineState := KernelExecutionDigest.MachineState
abbrev InitialState := KernelExecutionDigest.InitialState
abbrev ExternalSchedule := KernelExecutionDigest.ExternalSchedule
abbrev ExecutionFrame := KernelExecutionDigest.ExecutionFrame
abbrev ExecutionInputContext := EvidenceCoverage.ExecutionInputContext
abbrev RootEncode := KernelExecutionDigest.RootEncode
abbrev KernelPoints := ExactOpeningBoundary.KernelPoints
abbrev KernelOpeningManifest := ExactOpeningBoundary.KernelOpeningManifest
abbrev RootOpeningManifest := ExactOpeningBoundary.RootOpeningManifest
abbrev KernelSoundnessAccounting := SoundnessAccounting.KernelSoundnessAccounting

section Audit

variable
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr Table ValSurface
    Increment SessionKey : Type*}
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}
  {W Z Commitment Value Digest : Type*}

def checkKernelTraceSurface
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    AuthenticatedTrace.AuthenticatedTemporalSupportBound (inputs := inputs)
      frames

def checkKernelExportSurface
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
  (KernelSoundness.kernelPreparedSteps rootEncode ajtaiCommit frames).length =
      inputs.pubMeta.semanticRows ∧
    StepComposition.PreparedStepTraceBound rootEncode ajtaiCommit (traceOf frames)
      (KernelSoundness.kernelPreparedSteps rootEncode ajtaiCommit frames)

def checkKernelAuditSurface
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
  List.Forall
      (RowProjectionSummaryEntry (inputs := inputs) (evalBase := evalBase)
        (B := B)) frames ∧
    List.Forall
      (BridgeBindingSummaryEntry (inputs := inputs) (evalBase := evalBase)
        (B := B) rootEncode ajtaiCommit) frames

def checkKernelManifestSurface'
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
  (∀ claim, claim ∈ kernelManifest → claim.commitmentId ∈ root0CommitmentIds) ∧
    (∀ {kernelClaim rootClaim},
      kernelClaim ∈ kernelManifest →
        rootClaim ∈ rootManifest →
        kernelClaim.commitmentId ≠ rootClaim.commitmentId)

def checkKernelTranscriptSurface
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    (∃ pre, events = pre ++ [.emitKernelOpeningClaims])

def checkKernelErrorSurface
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
  SuperNeo.ProofSystem.IsNegligible accounting.epsTotal

def checkKernelExecutionDigest
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) : Prop :=
  checkKernelTraceSurface rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d ∧
    checkKernelExportSurface rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d ∧
    checkKernelAuditSurface rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d ∧
    checkKernelManifestSurface' rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d ∧
    checkKernelTranscriptSurface rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d ∧
    checkKernelErrorSurface rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d

def KernelArtifactAuditAccepted
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) : Prop :=
  checkKernelExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest
    rootManifest events accounting d

theorem kernelArtifactAuditSound
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
    rootManifest events accounting d := by
  rcases h with ⟨hTrace, hExport, hAudit, hManifest, hTranscript, hErr⟩
  rcases hTrace with ⟨hChunkTrace, hStage2Seeds, hSupport⟩
  rcases hExport with ⟨hPreparedCount, hPreparedTrace⟩
  rcases hAudit with ⟨hRowProjection, hBridgeBinding⟩
  rcases hManifest with ⟨hRoot0, hDisjoint⟩
  rcases hTranscript with
    ⟨hChallenge, hStage1Terminal, hStage2Terminal, hRowBinding, hEmit⟩
  exact ⟨hChunkTrace, hStage2Seeds, hPreparedCount, hPreparedTrace, hRowProjection,
    hBridgeBinding, hRoot0, hDisjoint, hChallenge, hStage1Terminal,
    hStage2Terminal, hRowBinding, hEmit, hErr, hSupport⟩

theorem kernelArtifactAuditImpliesKernelSoundnessConclusion
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  KernelSoundness.KernelSoundnessConclusion rootEncode ajtaiCommit frames pts
    kernelManifest rootManifest events accounting := by
  exact kernelSoundnessConclusion_of_digest (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesAuthenticatedChunkTrace
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  AuthenticatedChunkTraceBound (inputs := inputs) frames := by
  exact authenticatedChunkTraceBound_of_digest (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesStage2TemporalSeeds
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  List.Forall
    (AuthenticatedTrace.Stage2TemporalSeedSummaryEntry (inputs := inputs)
      (evalBase := evalBase) (B := B)) frames := by
  exact KernelExecutionDigest.stage2TemporalSeeds_of_digest
    (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesTemporalSupport
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  AuthenticatedTrace.AuthenticatedTemporalSupportBound (inputs := inputs)
    frames := by
  exact KernelExecutionDigest.temporalSupport_of_digest
    (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesAuthenticatedExecutionTrace
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  AuthenticatedTrace.AuthenticatedExecutionTraceBound (inputs := inputs)
    frames := by
  exact KernelExecutionDigest.authenticatedExecutionTraceBound_of_digest
    (inputs := inputs) (evalBase := evalBase) (B := B)
    (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesPreparedStepExport
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  (KernelSoundness.kernelPreparedSteps rootEncode ajtaiCommit frames).length =
      inputs.pubMeta.semanticRows ∧
    StepComposition.PreparedStepTraceBound rootEncode ajtaiCommit (traceOf frames)
      (KernelSoundness.kernelPreparedSteps rootEncode ajtaiCommit frames) := by
  exact preparedStepExport_of_digest (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesRowProjectionSummary
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  List.Forall
      (RowProjectionSummaryEntry (inputs := inputs) (evalBase := evalBase)
        (B := B)) frames := by
  exact KernelExecutionDigest.rowProjectionSummary_of_digest
    (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesBridgeBindingSummary
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  List.Forall
      (BridgeBindingSummaryEntry (inputs := inputs) (evalBase := evalBase)
        (B := B) rootEncode ajtaiCommit) frames := by
  exact KernelExecutionDigest.bridgeBindingSummary_of_digest
    (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesKernelClaimsFixedInRoot0
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  ∀ claim, claim ∈ kernelManifest → claim.commitmentId ∈ root0CommitmentIds := by
  exact KernelExecutionDigest.kernelClaimsFixedInRoot0_of_digest
    (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesKernelRootCommitmentsDisjoint
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  ∀ {kernelClaim rootClaim},
    kernelClaim ∈ kernelManifest →
      rootClaim ∈ rootManifest →
      kernelClaim.commitmentId ≠ rootClaim.commitmentId := by
  exact KernelExecutionDigest.kernelRootCommitmentsDisjoint_of_digest
    (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesChallengeAfterPhase0
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  ∀ {e : TranscriptEvent},
    ChallengeEvent e →
      ∃ rest, events = phase0Events ++ rest ∧ e ∈ rest := by
  exact KernelExecutionDigest.challengeAfterPhase0_of_digest
    (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesStage1TerminalAfterPhase0
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  ∀ {e : TranscriptEvent},
    Stage1TerminalPointEvent e →
      ∃ rest, events = phase0Events ++ rest ∧ e ∈ rest := by
  exact KernelExecutionDigest.stage1TerminalAfterPhase0_of_digest
    (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesStage2TerminalAfterPhase0
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  ∀ {e : TranscriptEvent},
    Stage2TerminalPointEvent e →
      ∃ rest, events = phase0Events ++ rest ∧ e ∈ rest := by
  exact KernelExecutionDigest.stage2TerminalAfterPhase0_of_digest
    (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesRowBindingCoverage
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  ∀ j : Nat,
    TranscriptEvent.rowBinding j ∈ events ↔ j < inputs.pubMeta.semanticRows := by
  exact KernelExecutionDigest.rowBindingCoverage_of_digest
    (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesEmitKernelOpeningClaimsLast
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  ∃ pre, events = pre ++ [.emitKernelOpeningClaims] := by
  exact KernelExecutionDigest.emitKernelOpeningClaimsLast_of_digest
    (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesNegligibleTotal
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  SuperNeo.ProofSystem.IsNegligible accounting.epsTotal := by
  exact negligibleTotal_of_digest (kernelArtifactAuditSound h)

theorem kernelArtifactAuditImpliesExecutionCorrect
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  StepComposition.ExecutionCorrect rom σ init (traceOf frames) := by
  exact AuthenticatedTrace.executionCorrect_of_authenticatedExecutionTraceBound
    (kernelArtifactAuditImpliesAuthenticatedExecutionTrace
      (inputs := inputs) (evalBase := evalBase) (B := B) h)

theorem kernelArtifactAuditImpliesTraceLinkBound
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  TraceLinkBoundary.TraceLinkBound (traceOf frames) := by
  have hExecTrace :=
    kernelArtifactAuditImpliesAuthenticatedExecutionTrace
      (inputs := inputs) (evalBase := evalBase) (B := B) h
  exact AuthenticatedTrace.traceLinkBound_of_authenticatedExecutionTraceBound
    hExecTrace

theorem kernelArtifactAuditImpliesExecutionLinked
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
    KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
      rootManifest events accounting d) :
  StepComposition.ExecutionLinked (traceOf frames) := by
  exact TraceLinkBoundary.executionLinked_of_traceLinkBound
    (kernelArtifactAuditImpliesTraceLinkBound h)

end Audit

end Nightstream.Chip8.KernelArtifactAudit

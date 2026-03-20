import Nightstream.Chip8.Kernel.KernelArtifactAudit

/-!
Owns grouped-surface projections from the Lean-defined kernel digest and the
matching checker-side decomposition lemmas. This file does not define new
kernel facts; it only makes the digest/audit boundary mechanically explicit.
-/

namespace Nightstream.Chip8.KernelDigestAuditBoundary

open Nightstream.Chip8
open Nightstream.Chip8.AuthenticatedTrace
open Nightstream.Chip8.EvidenceCoverage
open Nightstream.Chip8.KernelExecutionDigest
open Nightstream.Chip8.KernelArtifactAudit
open Nightstream.Chip8.TranscriptSchedule

abbrev F := KernelExecutionDigest.F
abbrev Program := KernelExecutionDigest.Program
abbrev MachineState := KernelExecutionDigest.MachineState
abbrev InitialState := KernelExecutionDigest.InitialState
abbrev ExternalSchedule := KernelExecutionDigest.ExternalSchedule
abbrev ExecutionFrame := KernelExecutionDigest.ExecutionFrame
abbrev ExecutionInputContext := KernelArtifactAudit.ExecutionInputContext
abbrev RootEncode := KernelExecutionDigest.RootEncode
abbrev ExactFrameEvidence := @AuthenticatedTrace.ExactFrameEvidence
abbrev ExecutionDigest := @KernelExecutionDigest.KernelExecutionDigest
abbrev TranscriptEvent := TranscriptSchedule.TranscriptEvent
abbrev KernelPoints := KernelArtifactAudit.KernelPoints
abbrev KernelOpeningManifest := KernelArtifactAudit.KernelOpeningManifest
abbrev RootOpeningManifest := KernelArtifactAudit.RootOpeningManifest
abbrev KernelSoundnessAccounting := KernelArtifactAudit.KernelSoundnessAccounting

section Boundary

variable
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr Table ValSurface
    Increment SessionKey : Type*}
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}
  {W Z Commitment Value Digest : Type*}

theorem kernelTraceSurface_of_digest
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) :
  KernelTraceSurface frames :=
  d.trace

theorem kernelExportSurface_of_digest
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) :
  KernelExportSurface rootEncode ajtaiCommit frames :=
  d.exported

theorem kernelAuditSurface_of_digest
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) :
  KernelAuditSurface rootEncode ajtaiCommit frames :=
  d.audit

theorem kernelManifestSurface_of_digest
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) :
  KernelManifestSurface kernelManifest rootManifest :=
  d.manifest

theorem kernelTranscriptSurface_of_digest
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) :
  KernelTranscriptSurface inputs.pubMeta.semanticRows events :=
  d.transcript

theorem kernelErrorSurface_of_digest
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) :
  KernelErrorSurface accounting :=
  d.error

theorem kernelExecutionDigestBound_of_digest
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) :
  KernelExecutionDigestBound rootEncode ajtaiCommit frames pts kernelManifest
    rootManifest events accounting d := by
  exact
    ⟨d.trace.chunkTrace, d.trace.stage2TemporalSeeds,
      d.exported.preparedStepCount, d.exported.preparedStepTrace,
      d.audit.rowProjectionSummary, d.audit.bridgeBindingSummary,
      d.manifest.kernelClaimsFixedInRoot0,
      d.manifest.kernelRootCommitmentsDisjoint,
      d.transcript.challengeAfterPhase0,
      d.transcript.stage1TerminalAfterPhase0,
      d.transcript.stage2TerminalAfterPhase0,
      d.transcript.rowBindingCoverage,
      d.transcript.emitKernelOpeningClaimsLast,
      d.error.negligibleTotal,
      d.trace.temporalSupport⟩

theorem checkKernelTraceSurface_of_digest
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) :
  checkKernelTraceSurface rootEncode ajtaiCommit frames pts kernelManifest
    rootManifest events accounting d := by
  exact ⟨d.trace.chunkTrace, d.trace.stage2TemporalSeeds,
    d.trace.temporalSupport⟩

theorem checkKernelExportSurface_of_digest
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) :
  checkKernelExportSurface rootEncode ajtaiCommit frames pts kernelManifest
    rootManifest events accounting d := by
  exact ⟨d.exported.preparedStepCount, d.exported.preparedStepTrace⟩

theorem checkKernelAuditSurface_of_digest
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) :
  checkKernelAuditSurface rootEncode ajtaiCommit frames pts kernelManifest
    rootManifest events accounting d := by
  exact ⟨d.audit.rowProjectionSummary, d.audit.bridgeBindingSummary⟩

theorem checkKernelManifestSurface_of_digest
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) :
  checkKernelManifestSurface' rootEncode ajtaiCommit frames pts kernelManifest
    rootManifest events accounting d := by
  exact ⟨d.manifest.kernelClaimsFixedInRoot0,
    d.manifest.kernelRootCommitmentsDisjoint⟩

theorem checkKernelTranscriptSurface_of_digest
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) :
  checkKernelTranscriptSurface rootEncode ajtaiCommit frames pts kernelManifest
    rootManifest events accounting d := by
  exact ⟨d.transcript.challengeAfterPhase0,
    d.transcript.stage1TerminalAfterPhase0,
    d.transcript.stage2TerminalAfterPhase0,
    d.transcript.rowBindingCoverage,
    d.transcript.emitKernelOpeningClaimsLast⟩

theorem checkKernelErrorSurface_of_digest
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) :
  checkKernelErrorSurface rootEncode ajtaiCommit frames pts kernelManifest
    rootManifest events accounting d := by
  exact d.error.negligibleTotal

theorem kernelArtifactAuditAccepted_of_digest
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
  (d :
    ExecutionDigest rootEncode ajtaiCommit frames pts kernelManifest rootManifest
      events accounting) :
  KernelArtifactAuditAccepted rootEncode ajtaiCommit frames pts kernelManifest
    rootManifest events accounting d := by
  exact ⟨checkKernelTraceSurface_of_digest (inputs := inputs) (d := d),
    checkKernelExportSurface_of_digest (inputs := inputs) (d := d),
    checkKernelAuditSurface_of_digest (inputs := inputs) (d := d),
    checkKernelManifestSurface_of_digest (inputs := inputs) (d := d),
    checkKernelTranscriptSurface_of_digest (inputs := inputs) (d := d),
    checkKernelErrorSurface_of_digest (inputs := inputs) (d := d)⟩

end Boundary

end Nightstream.Chip8.KernelDigestAuditBoundary

import Nightstream.Chip8.Stage2.EvidenceCoverageBounds
import Nightstream.Chip8.Trace.ChunkInput
import Nightstream.Chip8.Trace.TraceLinkBoundary
import Nightstream.Chip8.Trace.TemporalConsistency
import Nightstream.Chip8.Stage2.TwistTemporalInstantiation

/-!
Owns the chunk-level closure surface above exact per-row CHIP-8 evidence. This
file closes row-local authenticated extraction to the authenticated chunk-trace
bundle, packages the protocol-shaped temporal closure bundle
(`Stage2TemporalContextBound` plus `PcAdjacentBridge`), and derives
`TraceLinkBound` / `ExecutionCorrect` from that bundle. It does not itself
reconstruct the Stage-2 temporal context or the Stage-3 `pc` bridge from exact
evidence.
-/

namespace Nightstream.Chip8.AuthenticatedTrace

open Nightstream.Chip8
open Nightstream.Chip8.StepComposition
open Nightstream.Chip8.EvidenceCoverage
open Nightstream.Chip8.ChunkInput
open Nightstream.Chip8.TraceLinkBoundary
open Nightstream.Chip8.TemporalConsistency
open Nightstream.Chip8.PcContinuityBridge
open Nightstream.Chip8.TwistTemporalInstantiation

abbrev F := StepComposition.F
abbrev Program := EvidenceCoverage.Program
abbrev MachineState := StepComposition.MachineState
abbrev InitialState := StepComposition.InitialState
abbrev ExternalSchedule := StepComposition.ExternalSchedule
abbrev ExecutionFrame := StepComposition.ExecutionFrame
abbrev RegisterValueTimeline := TemporalConsistency.RegisterValueTimeline
abbrev RamValueTimeline := TemporalConsistency.RamValueTimeline

section Trace

variable
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr Table ValSurface
    Increment SessionKey : Type*}
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}

structure ExactFrameEvidence
  (pcs : PCSContext AuxIndex EvalPoint)
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (evalBase : BaseFamily Nat AuxIndex → EvalPoint → F)
  (B : Set (BaseFamily Nat AuxIndex))
  (publicTable : Table → Prop)
  (tableBackedBy : Table → BaseFamily Nat AuxIndex → Prop)
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (readCheckExpression : AddressColumns → Table → EvalPoint → F)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readOnlyMemoryRelation : Table → Addr → Nat → Prop)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  (rom : Program)
  (σ : ExternalSchedule)
  (init : InitialState)
  where
  stepIdx : Nat
  frame : ExecutionFrame Addr
  exactEvidence :
    ExactSemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ stepIdx init frame.pre frame.post frame.dec
      frame.row
  preWellFormed : StepComposition.StateWellFormed frame.pre
  postWellFormed : StepComposition.StateWellFormed frame.post

def traceOf
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) :
  List (ExecutionFrame Addr) :=
  frames.map ExactFrameEvidence.frame

def ExactTraceEvidenceFrom
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {init : InitialState} :
  Nat →
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init) →
    Prop
  | _, [] => True
  | stepIdx, frame :: rest =>
      frame.stepIdx = stepIdx ∧ ExactTraceEvidenceFrom (stepIdx + 1) rest

abbrev ExactTraceEvidence
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) : Prop :=
  ExactTraceEvidenceFrom 0 frames

def HeadInitialStateMatch
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) : Prop :=
  match frames with
  | [] => True
  | first :: _ => StepComposition.InitialStateMatches init first.frame.pre

structure AuthenticatedChunkTraceBound
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) where
  framesBound :
    List.Forall (StepComposition.ExecutionFrameBound rom σ) (traceOf frames)
  continuity :
    StepComposition.ContinuityTraceBound 0 (traceOf frames)
  boundary :
    StepComposition.BoundaryTraceBound init (traceOf frames)

structure AuthenticatedTemporalSupportBound
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) where
  stage2 :
    Stage2TemporalContextBound (traceOf frames)
  pcBridge :
    PcAdjacentBridge (traceOf frames)

def Stage2TemporalSeedSummaryEntry
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) : Prop :=
  Nonempty <| Σ' Γ₃,
    EvidenceCoverage.Stage2TemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ frame.stepIdx frame.frame.pre
      frame.frame.post frame.frame.dec frame.frame.row

def RegisterTemporalSeedSummaryEntry
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) : Prop :=
  Nonempty <| Σ' Γ₃,
    EvidenceCoverage.RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ frame.stepIdx frame.frame.pre
      frame.frame.post frame.frame.dec frame.frame.row

def RamTemporalSeedSummaryEntry
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) : Prop :=
  Nonempty <| Σ' Γ₃,
    EvidenceCoverage.RamTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ frame.stepIdx frame.frame.pre
      frame.frame.post frame.frame.dec frame.frame.row

structure AuthenticatedExecutionTraceBound
  {pcs : PCSContext AuxIndex EvalPoint}
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
      (Stage2TemporalSeedSummaryEntry (inputs := inputs) (evalBase := evalBase)
        (B := B)) frames
  temporalSupport :
    AuthenticatedTemporalSupportBound (inputs := inputs) frames
  temporal :
    TemporalInstantiationBound (traceOf frames)

theorem stage2TemporalSeedSummaryEntry_of_exactFrameEvidence
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :
  Stage2TemporalSeedSummaryEntry (inputs := inputs) (evalBase := evalBase)
    (B := B) frame := by
  rcases
      stage2TemporalSeedBound_of_exactAuthenticatedEvidence frame.exactEvidence with
    ⟨Γ₃, hSeed⟩
  exact ⟨⟨Γ₃, hSeed⟩⟩

theorem registerTemporalSeedSummaryEntry_of_stage2TemporalSeedSummaryEntry
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hStage2 :
    Stage2TemporalSeedSummaryEntry (inputs := inputs) (evalBase := evalBase)
      (B := B) frame) :
  RegisterTemporalSeedSummaryEntry
      (inputs := inputs) (evalBase := evalBase) (B := B) frame := by
  rcases hStage2 with ⟨⟨Γ₃, hSeed⟩⟩
  exact ⟨⟨Γ₃, registerTemporalSeedBound_of_stage2TemporalSeedBound hSeed⟩⟩

theorem ramTemporalSeedSummaryEntry_of_stage2TemporalSeedSummaryEntry
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hStage2 :
    Stage2TemporalSeedSummaryEntry (inputs := inputs) (evalBase := evalBase)
      (B := B) frame) :
  RamTemporalSeedSummaryEntry
      (inputs := inputs) (evalBase := evalBase) (B := B) frame := by
  rcases hStage2 with ⟨⟨Γ₃, hSeed⟩⟩
  exact ⟨⟨Γ₃, ramTemporalSeedBound_of_stage2TemporalSeedBound hSeed⟩⟩

theorem registerTemporalSeedSummaryEntry_of_exactFrameEvidence
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :
  RegisterTemporalSeedSummaryEntry
      (inputs := inputs) (evalBase := evalBase) (B := B) frame := by
  exact
    registerTemporalSeedSummaryEntry_of_stage2TemporalSeedSummaryEntry
      (stage2TemporalSeedSummaryEntry_of_exactFrameEvidence frame)

theorem ramTemporalSeedSummaryEntry_of_exactFrameEvidence
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :
  RamTemporalSeedSummaryEntry
      (inputs := inputs) (evalBase := evalBase) (B := B) frame := by
  exact
    ramTemporalSeedSummaryEntry_of_stage2TemporalSeedSummaryEntry
      (stage2TemporalSeedSummaryEntry_of_exactFrameEvidence frame)

theorem stage2TemporalSeedSummary_of_frames
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) :
  List.Forall
    (Stage2TemporalSeedSummaryEntry (inputs := inputs) (evalBase := evalBase)
      (B := B)) frames := by
  rw [List.forall_iff_forall_mem]
  intro frame _hMem
  exact stage2TemporalSeedSummaryEntry_of_exactFrameEvidence frame

theorem registerTemporalSeedSummary_of_frames
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) :
  List.Forall
    (RegisterTemporalSeedSummaryEntry (inputs := inputs) (evalBase := evalBase)
      (B := B)) frames := by
  rw [List.forall_iff_forall_mem]
  intro frame _hMem
  exact registerTemporalSeedSummaryEntry_of_exactFrameEvidence frame

theorem ramTemporalSeedSummary_of_frames
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) :
  List.Forall
    (RamTemporalSeedSummaryEntry (inputs := inputs) (evalBase := evalBase)
      (B := B)) frames := by
  rw [List.forall_iff_forall_mem]
  intro frame _hMem
  exact ramTemporalSeedSummaryEntry_of_exactFrameEvidence frame

theorem registerTemporalSeeds_of_authenticatedExecutionTraceBound
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hTrace :
    AuthenticatedExecutionTraceBound (inputs := inputs) (evalBase := evalBase)
      (B := B) frames) :
  List.Forall
    (RegisterTemporalSeedSummaryEntry (inputs := inputs) (evalBase := evalBase)
      (B := B)) frames := by
  rw [List.forall_iff_forall_mem]
  intro frame hMem
  exact
    registerTemporalSeedSummaryEntry_of_stage2TemporalSeedSummaryEntry
      ((List.forall_iff_forall_mem.mp hTrace.stage2TemporalSeeds) frame hMem)

theorem ramTemporalSeeds_of_authenticatedExecutionTraceBound
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hTrace :
    AuthenticatedExecutionTraceBound (inputs := inputs) (evalBase := evalBase)
      (B := B) frames) :
  List.Forall
    (RamTemporalSeedSummaryEntry (inputs := inputs) (evalBase := evalBase)
      (B := B)) frames := by
  rw [List.forall_iff_forall_mem]
  intro frame hMem
  exact
    ramTemporalSeedSummaryEntry_of_stage2TemporalSeedSummaryEntry
      ((List.forall_iff_forall_mem.mp hTrace.stage2TemporalSeeds) frame hMem)

theorem wf_of_exactFrameEvidence
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :
  Nightstream.Chip8.wf frame.frame.row := by
  rcases semanticBounds_of_exactAuthenticatedEvidence frame.exactEvidence with
    ⟨_, _, _, _, _, _, hCont, _, _⟩
  rcases hCont with ⟨_, _, _, _, _, _, rowClaim, hRow⟩
  let _ := rowClaim
  rcases hRow with ⟨_, _, _, _, _, _, _, hRowBound⟩
  simpa [Nightstream.Chip8.wf] using hRowBound.2.2.2.2.2

theorem stateWellFormedFrames_of_frames
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) :
  List.Forall
    (fun frame =>
      StepComposition.StateWellFormed frame.pre ∧
        StepComposition.StateWellFormed frame.post)
    (traceOf frames) := by
  induction frames with
  | nil =>
      simp [traceOf, List.Forall]
  | cons frame rest ih =>
      simpa [traceOf, List.Forall] using
        And.intro ⟨frame.preWellFormed, frame.postWellFormed⟩ ih

theorem executionFrameBound_of_exactFrameEvidence
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :
  StepComposition.ExecutionFrameBound rom σ frame.frame := by
  have hWf : Nightstream.Chip8.wf frame.frame.row := wf_of_exactFrameEvidence frame
  rcases semanticBounds_of_exactAuthenticatedEvidence frame.exactEvidence with
    ⟨_, _, hWitness, hFetch, hLookup, hMem, _, hFramebuffer, hSchedule⟩
  rcases semanticEvidenceCovered_of_exactEvidence frame.exactEvidence with
    ⟨Γ₁, Γ₂, Γ₃, hSem⟩
  have hRouting : Nightstream.Chip8.chip8RoutingSound frame.frame.row :=
    routingSound_of_evidence hSem
  refine ⟨hWf, hWitness, ?_⟩
  exact StepComposition.microstepCorrect_of_bounds
    frame.preWellFormed frame.postWellFormed hWf hWitness hFetch hLookup
    hMem hFramebuffer hSchedule hRouting

theorem stepIdx_lt_publishedLength_of_exactFrameEvidence
  {pcs : PCSContext AuxIndex EvalPoint}
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
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :
  frame.stepIdx < inputs.publishedLength := by
  rcases semanticBounds_of_exactAuthenticatedEvidence frame.exactEvidence with
    ⟨_, hExecInputs, _, _, _, _, _, _, _⟩
  have hLen : inputs.publishedLength = inputs.scheduleLength σ := hExecInputs.2.2.1
  have hLive : frame.stepIdx < inputs.scheduleLength σ := hExecInputs.2.2.2
  simpa [hLen] using hLive

theorem executionFramesBound_of_exactTraceFrom
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)} :
  ∀ {stepIdx : Nat},
    ExactTraceEvidenceFrom stepIdx frames →
      List.Forall (StepComposition.ExecutionFrameBound rom σ) (traceOf frames) := by
  induction frames with
  | nil =>
      intro stepIdx hTrace
      simp [traceOf, List.Forall]
  | cons frame rest ih =>
      intro stepIdx hTrace
      rcases hTrace with ⟨_, hTail⟩
      simpa [traceOf, List.Forall] using
        And.intro
          (executionFrameBound_of_exactFrameEvidence frame)
          (ih hTail)

theorem executionFramesBound_of_exactTrace
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hTrace : ExactTraceEvidence frames) :
  List.Forall (StepComposition.ExecutionFrameBound rom σ) (traceOf frames) :=
  executionFramesBound_of_exactTraceFrom hTrace

theorem continuityTraceBound_of_exactTrace
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)} :
  ∀ {stepIdx : Nat},
    ExactTraceEvidenceFrom stepIdx frames →
      StepComposition.ContinuityTraceBound stepIdx (traceOf frames) := by
  induction frames with
  | nil =>
      intro stepIdx hTrace
      simp [traceOf, ExecutionSemantics.ContinuityTraceBound]
  | cons frame rest ih =>
      intro stepIdx hTrace
      rcases hTrace with ⟨hStep, hTail⟩
      rcases semanticBounds_of_exactAuthenticatedEvidence frame.exactEvidence with
        ⟨_, _, _, _, _, _, hCont, _, _⟩
      have hHead :
          ∃ N β1 β2 shiftClaim shiftProof currentRow rowClaim,
            StepComposition.ContinuityRowBound stepIdx N β1 β2 shiftClaim
              shiftProof currentRow rowClaim frame.frame.row := by
        simpa [hStep] using hCont
      exact ⟨hHead, ih hTail⟩

theorem startBoundaryFrame_of_exactHead
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  {rest :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hTrace : ExactTraceEvidence (frame :: rest)) :
  StepComposition.StartBoundaryFrame frame.frame := by
  rcases hTrace with ⟨hStep, _⟩
  rcases semanticEvidenceCovered_of_exactEvidence frame.exactEvidence with
    ⟨Γ₁, Γ₂, Γ₃, hSem⟩
  exact startBoundaryFrame_of_evidence hSem hStep

theorem lastStepIdx_of_exactTraceFrom_appendLast
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {stepIdx : Nat}
  {framesPrefix :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {lastFrame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hTrace : ExactTraceEvidenceFrom stepIdx (framesPrefix ++ [lastFrame])) :
  lastFrame.stepIdx = stepIdx + framesPrefix.length := by
  induction framesPrefix generalizing stepIdx with
  | nil =>
      simpa [ExactTraceEvidenceFrom] using hTrace.1
  | cons frame framesPrefix ih =>
      rcases hTrace with ⟨hFrame, hTail⟩
      have hLast : lastFrame.stepIdx = stepIdx + 1 + framesPrefix.length := ih hTail
      calc
        lastFrame.stepIdx = stepIdx + 1 + framesPrefix.length := hLast
        _ = stepIdx + (framesPrefix.length + 1) := by omega
        _ = stepIdx + (frame :: framesPrefix).length := by simp

theorem finalBoundaryFrame_of_exactTail
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {framesPrefix :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {lastFrame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hTrace : ExactTraceEvidence (framesPrefix ++ [lastFrame]))
  (hLen : (framesPrefix ++ [lastFrame]).length = inputs.pubMeta.semanticRows) :
  StepComposition.FinalBoundaryFrame lastFrame.frame := by
  have hStep : lastFrame.stepIdx = framesPrefix.length := by
    simpa using lastStepIdx_of_exactTraceFrom_appendLast hTrace
  have hLast :
      lastFrame.stepIdx + 1 = inputs.pubMeta.semanticRows := by
    simpa [hStep] using hLen
  rcases semanticEvidenceCovered_of_exactEvidence lastFrame.exactEvidence with
    ⟨Γ₁, Γ₂, Γ₃, hSem⟩
  exact finalBoundaryFrame_of_evidence hSem hLast

theorem traceLength_le_publishedLength_of_exactTrace
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hTrace : ExactTraceEvidence frames) :
  frames.length ≤ inputs.publishedLength := by
  cases frames using List.reverseRecOn with
  | nil =>
      simp
  | @append_singleton framesPrefix last =>
      have hLastStep : last.stepIdx = framesPrefix.length := by
        simpa using
          (lastStepIdx_of_exactTraceFrom_appendLast
            (framesPrefix := framesPrefix) (lastFrame := last) hTrace)
      have hLive : last.stepIdx < inputs.publishedLength :=
        stepIdx_lt_publishedLength_of_exactFrameEvidence (inputs := inputs) last
      have hBound : framesPrefix.length + 1 ≤ inputs.publishedLength := by
        omega
      simpa using hBound

theorem headInitialStateMatch_of_chunkInput
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)) :
  HeadInitialStateMatch (init := init) frames := by
  cases frames with
  | nil =>
      have hNe :
          (traceOf
              ([] :
                List
                  (ExactFrameEvidence pcs inputs evalBase B publicTable
                    tableBackedBy readSessionKey pairedSessionKey
                    validAddressColumns kernelAddressBound readCheckExpression
                    rwReadCheckExpression writeCheckExpression
                    valEvaluationExpression readOnlyMemoryRelation
                    readWriteMemoryRelation incrementRelation rom σ init))) ≠ [] :=
        ChunkInput.trace_nonempty_of_simpleKernelChunkInput hChunk
      simp [traceOf] at hNe
  | cons first rest =>
      simpa [HeadInitialStateMatch, traceOf] using
        (ChunkInput.headInitialStateMatches_of_simpleKernelChunkInput hChunk)

theorem traceLength_eq_semanticRows_of_chunkInput
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)) :
  frames.length = inputs.pubMeta.semanticRows := by
  simpa [traceOf] using
    (ChunkInput.traceLength_of_simpleKernelChunkInput hChunk)

theorem boundaryTraceBound_of_exactTrace
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)) :
  StepComposition.BoundaryTraceBound init (traceOf frames) := by
  have hInitHead : HeadInitialStateMatch (init := init) frames :=
    headInitialStateMatch_of_chunkInput (inputs := inputs) hChunk
  have hLen : frames.length = inputs.pubMeta.semanticRows :=
    traceLength_eq_semanticRows_of_chunkInput (inputs := inputs) hChunk
  cases frames with
  | nil =>
      simpa [HeadInitialStateMatch, traceOf, StepComposition.BoundaryTraceBound] using hInitHead
  | cons first rest =>
      have hInitFirst : StepComposition.InitialStateMatches init first.frame.pre := hInitHead
      have hStart : StepComposition.StartBoundaryFrame first.frame :=
        startBoundaryFrame_of_exactHead hExact
      cases rest using List.reverseRecOn with
      | nil =>
          have hFinal : StepComposition.FinalBoundaryFrame first.frame := by
            simpa using
              (finalBoundaryFrame_of_exactTail
                (inputs := inputs)
                (framesPrefix := [])
                (lastFrame := first)
                hExact hLen)
          simpa [traceOf, StepComposition.BoundaryTraceBound] using
            And.intro hInitFirst (And.intro hStart hFinal)
      | @append_singleton middle last =>
          have hExactTail :
              ExactTraceEvidence ((first :: middle) ++ [last]) := by
            simpa [List.cons_append] using hExact
          have hLenTail :
              ((first :: middle) ++ [last]).length = inputs.pubMeta.semanticRows := by
            simpa [List.cons_append] using hLen
          have hFinal : StepComposition.FinalBoundaryFrame last.frame := by
            exact finalBoundaryFrame_of_exactTail
              (inputs := inputs)
              (framesPrefix := first :: middle)
              (lastFrame := last)
              hExactTail hLenTail
          refine And.intro hInitFirst (And.intro hStart ?_)
          have hRev :
              (traceOf (first :: (middle ++ [last]))).reverse =
                last.frame ::
                  (List.map ExactFrameEvidence.frame middle).reverse ++ [first.frame] := by
            simp [traceOf, List.reverse_append]
          rw [hRev]
          simpa using hFinal

theorem authenticatedChunkTraceBound_of_exactTrace
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)) :
  AuthenticatedChunkTraceBound (inputs := inputs) frames := by
  exact
    { framesBound := executionFramesBound_of_exactTrace hExact
      continuity := continuityTraceBound_of_exactTrace hExact
      boundary := boundaryTraceBound_of_exactTrace (inputs := inputs) hExact hChunk }

theorem authenticatedExecutionTraceBound_of_exactTrace_and_temporal
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames))
  (hSupport :
    AuthenticatedTemporalSupportBound (inputs := inputs) frames)
  (hTemporal :
    TemporalInstantiationBound (traceOf frames)) :
  AuthenticatedExecutionTraceBound (inputs := inputs) frames := by
  exact
    { chunkTrace :=
        authenticatedChunkTraceBound_of_exactTrace (inputs := inputs) hExact hChunk
      stage2TemporalSeeds :=
        stage2TemporalSeedSummary_of_frames (inputs := inputs)
          (evalBase := evalBase) (B := B) frames
      temporalSupport := hSupport
      temporal := hTemporal }

theorem temporalInstantiationBound_of_authenticatedTemporalSupport
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hFrames : List.Forall (StepComposition.ExecutionFrameBound rom σ) (traceOf frames))
  (hSupport :
    AuthenticatedTemporalSupportBound (inputs := inputs) frames) :
  TemporalInstantiationBound (traceOf frames) := by
  exact temporalInstantiationBound_of_stage2_and_bridge hFrames
    (stateWellFormedFrames_of_frames frames)
    (stage2TemporalInstantiationBound_of_context hSupport.stage2)
    hSupport.pcBridge

theorem authenticatedExecutionTraceBound_of_exactTrace_and_support
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames))
  (hSupport :
    AuthenticatedTemporalSupportBound (inputs := inputs) frames) :
  AuthenticatedExecutionTraceBound (inputs := inputs) frames := by
  exact
    authenticatedExecutionTraceBound_of_exactTrace_and_temporal
      (inputs := inputs) hExact hChunk
      hSupport
      (temporalInstantiationBound_of_authenticatedTemporalSupport
        (executionFramesBound_of_exactTrace hExact) hSupport)

theorem traceLinkBound_of_authenticatedExecutionTraceBound
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (h :
    AuthenticatedExecutionTraceBound (inputs := inputs) frames) :
  TraceLinkBound (traceOf frames) := by
  exact traceLinkBound_of_temporalInstantiation h.temporal

theorem executionCorrect_of_authenticatedExecutionTraceBound
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (h :
    AuthenticatedExecutionTraceBound (inputs := inputs) frames) :
  StepComposition.ExecutionCorrect rom σ init (traceOf frames) := by
  exact StepComposition.executionCorrect_of_trace
    (executionLinked_of_traceLinkBound
      (traceLinkBound_of_temporalInstantiation h.temporal))
    h.chunkTrace.framesBound h.chunkTrace.continuity h.chunkTrace.boundary

theorem traceLinkBound_of_exactTrace_and_temporal
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames))
  (hTemporal :
    TemporalInstantiationBound (traceOf frames)) :
  TraceLinkBound (traceOf frames) := by
  let _ := hExact
  let _ := hChunk
  exact traceLinkBound_of_temporalInstantiation hTemporal

theorem traceLinkBound_of_exactTrace_and_support
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames))
  (hSupport :
    AuthenticatedTemporalSupportBound (inputs := inputs) frames) :
  TraceLinkBound (traceOf frames) := by
  exact traceLinkBound_of_authenticatedExecutionTraceBound
    (authenticatedExecutionTraceBound_of_exactTrace_and_support
      (inputs := inputs) hExact hChunk hSupport)

theorem executionCorrect_of_authenticatedChunkTraceBound_and_temporal
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hChunkTrace : AuthenticatedChunkTraceBound (inputs := inputs) frames)
  (hTemporal :
    TemporalInstantiationBound (traceOf frames)) :
  StepComposition.ExecutionCorrect rom σ init (traceOf frames) := by
  exact StepComposition.executionCorrect_of_trace
    (executionLinked_of_traceLinkBound
      (traceLinkBound_of_temporalInstantiation hTemporal))
    hChunkTrace.framesBound hChunkTrace.continuity hChunkTrace.boundary

theorem executionCorrect_of_authenticatedChunkTraceBound_and_support
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hChunkTrace : AuthenticatedChunkTraceBound (inputs := inputs) frames)
  (hSupport :
    AuthenticatedTemporalSupportBound (inputs := inputs) frames) :
  StepComposition.ExecutionCorrect rom σ init (traceOf frames) := by
  exact executionCorrect_of_authenticatedChunkTraceBound_and_temporal hChunkTrace
    (temporalInstantiationBound_of_authenticatedTemporalSupport
      hChunkTrace.framesBound hSupport)

theorem executionCorrect_of_authenticatedChunkTraceBound
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hChunkTrace : AuthenticatedChunkTraceBound (inputs := inputs) frames)
  (hTraceLink : TraceLinkBound (traceOf frames)) :
  StepComposition.ExecutionCorrect rom σ init (traceOf frames) := by
  exact StepComposition.executionCorrect_of_trace
    (executionLinked_of_traceLinkBound hTraceLink)
    hChunkTrace.framesBound hChunkTrace.continuity hChunkTrace.boundary

theorem executionCorrect_of_exactTrace_and_temporal
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames))
  (hTemporal :
    TemporalInstantiationBound (traceOf frames)) :
  StepComposition.ExecutionCorrect rom σ init (traceOf frames) := by
  exact executionCorrect_of_authenticatedChunkTraceBound_and_temporal
    (authenticatedChunkTraceBound_of_exactTrace (inputs := inputs) hExact hChunk)
    hTemporal

theorem executionCorrect_of_exactTrace_and_support
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames))
  (hSupport :
    AuthenticatedTemporalSupportBound (inputs := inputs) frames) :
  StepComposition.ExecutionCorrect rom σ init (traceOf frames) := by
  exact executionCorrect_of_authenticatedChunkTraceBound_and_support
    (authenticatedChunkTraceBound_of_exactTrace (inputs := inputs) hExact hChunk)
    hSupport

theorem executionCorrect_of_exactTrace
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames)
  (hTraceLink : TraceLinkBound (traceOf frames))
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)) :
  StepComposition.ExecutionCorrect rom σ init (traceOf frames) := by
  exact executionCorrect_of_authenticatedChunkTraceBound
    (authenticatedChunkTraceBound_of_exactTrace (inputs := inputs) hExact hChunk)
    hTraceLink

theorem preparedStepTraceBound_of_exactTrace
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {rootEncode : ContinuityBridge.RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  (hExact : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)) :
  StepComposition.PreparedStepTraceBound rootEncode ajtaiCommit (traceOf frames)
    ((traceOf frames).map
      (fun frame =>
        ContinuityBridge.mkPreparedStep rootEncode ajtaiCommit frame.row)) := by
  exact ExecutionSemantics.preparedStepTraceBound_of_continuity
    (authenticatedChunkTraceBound_of_exactTrace (inputs := inputs) hExact hChunk).continuity

theorem preparedStepExport_of_exactTrace
  {pcs : PCSContext AuxIndex EvalPoint}
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {rootEncode : ContinuityBridge.RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  (hExact : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)) :
  let preparedSteps :=
    (traceOf frames).map
      (fun frame =>
        ContinuityBridge.mkPreparedStep rootEncode ajtaiCommit frame.row)
  preparedSteps.length = inputs.pubMeta.semanticRows ∧
    StepComposition.PreparedStepTraceBound rootEncode ajtaiCommit
      (traceOf frames) preparedSteps := by
  dsimp
  refine ⟨?_, preparedStepTraceBound_of_exactTrace
    (inputs := inputs) hExact hChunk⟩
  have hLen : frames.length = inputs.pubMeta.semanticRows :=
    traceLength_eq_semanticRows_of_chunkInput (inputs := inputs) hChunk
  simpa [traceOf]


end Trace

end Nightstream.Chip8.AuthenticatedTrace

import Nightstream.Chip8.Stage2.EvidenceCoverage

/-!
Owns the theorem-facing extraction bundle on top of `EvidenceCoverage`'s
evidence objects. This file exposes the semantic bounds consumed by trace,
digest, and audit modules; it does not own the evidence structures or the
stage-local provenance objects themselves.
-/

namespace Nightstream.Chip8.EvidenceCoverage

open Nightstream.Chip8
open Nightstream.Chip8.FetchDecodeBinding
open Nightstream.Chip8.DecodeAddressBinding
open Nightstream.Chip8.WitnessMemoryBinding
open Nightstream.Chip8.StepComposition
open Nightstream.Chip8.ContinuityBridge
open Nightstream.Chip8.RomScheduleBinding
open Nightstream.PCSOpeningSemantics
open SuperNeo.ProofSystem

section Evidence

variable
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr Table ValSurface
    Increment SessionKey : Type*}
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}

theorem startBoundaryBound_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z) :
  ∃ startRow : ContinuityBridge.StartBoundaryRow F,
    ContinuityBridge.StartBoundaryBound startRow := by
  rcases h with ⟨ev⟩
  exact ⟨ev.continuity.startRow, ev.continuity.startBoundary⟩

theorem startBoundaryFrame_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z)
  (hZero : stepIdx = 0) :
  StepComposition.StartBoundaryFrame
    ({ dec := dec, pre := pre, post := post, row := z } :
      StepComposition.ExecutionFrame Addr) := by
  rcases h with ⟨ev⟩
  exact ContinuityBridge.startBoundaryBound_of_match
    ev.continuity.startBoundary ev.continuity.startMatches hZero

theorem finalBoundaryBound_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z) :
  ∃ finalRow : ContinuityBridge.FinalBoundaryRow F,
    ContinuityBridge.FinalBoundaryBound finalRow := by
  rcases h with ⟨ev⟩
  exact ⟨ev.continuity.finalRow, ev.continuity.finalBoundary⟩

theorem finalBoundaryFrame_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z)
  (hLast : stepIdx + 1 = inputs.pubMeta.semanticRows) :
  StepComposition.FinalBoundaryFrame
    ({ dec := dec, pre := pre, post := post, row := z } :
      StepComposition.ExecutionFrame Addr) := by
  rcases h with ⟨ev⟩
  have hLastN : stepIdx + 1 = ev.continuity.N := by
    simpa [ev.continuity.semanticRowsEq] using hLast
  exact ContinuityBridge.finalBoundaryBound_of_match
    ev.continuity.finalBoundary ev.continuity.finalMatches hLastN

theorem framebufferBound_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (_h :
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z) :
  StepComposition.FramebufferBound pre post dec := by
  trivial

theorem kernelPublicInputsBound_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z) :
  @KernelPublicInputsBound DigestRom RootParamsId VmSpec TranscriptSeed
    inputs.hashProgram inputs.hashInitialState inputs.programWordCountOf
    inputs.programBaseAddrOf inputs.padPcWordOf inputs.paddedTraceLengthOf
    inputs.twoPow inputs.rootParamsOf inputs.publicInput inputs.pubMeta rom
    init := by
  rcases h with ⟨ev⟩
  rcases ev.kernelInputs with ⟨hProgram, hInit, hMeta⟩
  exact
    RomScheduleBinding.kernelPublicInputsBound_of_authenticatedInputs
      hProgram hInit hMeta

theorem executionInputsBound_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z) :
  ExecutionInputsBound inputs.hashProgram inputs.hashSchedule inputs.scheduleLength
    inputs.romHash inputs.scheduleHash inputs.publishedLength rom σ stepIdx := by
  rcases h with ⟨ev⟩
  exact executionInputsBound_of_authenticatedInputs ev.romBinding ev.schedule

theorem scheduleBound_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z) :
  StepComposition.ScheduleBound σ stepIdx pre post dec := by
  rcases h with ⟨ev⟩
  exact stepCompositionScheduleBound_of_authenticatedStepSchedule ev.schedule

structure Stage2TemporalSeedBound
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  (Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (stepIdx : Nat)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F) where
  trace : WitnessMemoryBinding.StepMemoryTrace
  traceMatches : WitnessMemoryBinding.TraceMatches pre post dec trace
  frame : MemoryFrameEvidence pre post dec
  registerPorts : WitnessMemoryBinding.RegisterPortsBound pre post dec
  ramPorts : WitnessMemoryBinding.RamPortsBound pre post dec
  ramRaf : WitnessMemoryBinding.RamRafBound (K := F) pre dec z
  registerRegistry :
    RegisterTwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
  readXAddressCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaX session.read.addr
  readXValueCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaX session.read.addr ∧
        session.read.rv = WitnessMemoryBinding.registerReadXValue pre dec
  readYAddressCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaY session.read.addr
  readYValueCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaY session.read.addr ∧
        session.read.rv = WitnessMemoryBinding.registerReadYValue pre dec
  readIAddressCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaI session.read.addr
  readIValueCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaI session.read.addr ∧
        session.read.rv = WitnessMemoryBinding.registerReadIValue pre dec
  writeRegAddressCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regWa session.write.addr
  writeRegValueCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regWa session.write.addr ∧
        session.write.wv = WitnessMemoryBinding.registerWriteClaimValue post dec
  ramRegistry :
    RamTwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
  registerTwistClosed :
    RegisterTwistSessionClosed (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey
      validAddressColumns kernelAddressBound rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readWriteMemoryRelation
      incrementRelation Γ₃ registerRegistry
  ramTwistClosed :
    RamTwistSessionClosed (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation Γ₃
      ramRegistry
  loadReadAddressCovered :
    dec.opcodeId = .loadRegs →
      ∃ session ∈ ramRegistry.sessions,
        AddressProvenanceAt dec stepIdx .readMem session.read.addr
  loadReadValueCovered :
    dec.opcodeId = .loadRegs →
      ∃ session ∈ ramRegistry.sessions,
        AddressProvenanceAt dec stepIdx .readMem session.read.addr ∧
          session.read.rv = WitnessMemoryBinding.ramReadClaimValue pre post dec
  storeWriteAddressCovered :
    dec.opcodeId = .storeRegs →
      ∃ session ∈ ramRegistry.sessions,
        AddressProvenanceAt dec stepIdx .writeMem session.write.addr
  storeWriteValueCovered :
    dec.opcodeId = .storeRegs →
      ∃ session ∈ ramRegistry.sessions,
        AddressProvenanceAt dec stepIdx .writeMem session.write.addr ∧
          session.write.wv = WitnessMemoryBinding.ramWriteClaimValue pre post dec

structure RegisterTemporalSeedBound
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  (Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (stepIdx : Nat)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F) where
  trace : WitnessMemoryBinding.StepMemoryTrace
  traceMatches : WitnessMemoryBinding.TraceMatches pre post dec trace
  frame : MemoryFrameEvidence pre post dec
  registerPorts : WitnessMemoryBinding.RegisterPortsBound pre post dec
  registerRegistry :
    RegisterTwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
  registerTwistClosed :
    RegisterTwistSessionClosed (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey
      validAddressColumns kernelAddressBound rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readWriteMemoryRelation
      incrementRelation Γ₃ registerRegistry
  readXAddressCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaX session.read.addr
  readXValueCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaX session.read.addr ∧
        session.read.rv = WitnessMemoryBinding.registerReadXValue pre dec
  readYAddressCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaY session.read.addr
  readYValueCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaY session.read.addr ∧
        session.read.rv = WitnessMemoryBinding.registerReadYValue pre dec
  readIAddressCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaI session.read.addr
  readIValueCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaI session.read.addr ∧
        session.read.rv = WitnessMemoryBinding.registerReadIValue pre dec
  writeRegAddressCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regWa session.write.addr
  writeRegValueCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regWa session.write.addr ∧
        session.write.wv = WitnessMemoryBinding.registerWriteClaimValue post dec

structure RamTemporalSeedBound
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  (Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (stepIdx : Nat)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F) where
  trace : WitnessMemoryBinding.StepMemoryTrace
  traceMatches : WitnessMemoryBinding.TraceMatches pre post dec trace
  frame : MemoryFrameEvidence pre post dec
  ramPorts : WitnessMemoryBinding.RamPortsBound pre post dec
  ramRaf : WitnessMemoryBinding.RamRafBound (K := F) pre dec z
  ramRegistry :
    RamTwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
  ramTwistClosed :
    RamTwistSessionClosed (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation Γ₃
      ramRegistry
  loadReadAddressCovered :
    dec.opcodeId = .loadRegs →
      ∃ session ∈ ramRegistry.sessions,
        AddressProvenanceAt dec stepIdx .readMem session.read.addr
  loadReadValueCovered :
    dec.opcodeId = .loadRegs →
      ∃ session ∈ ramRegistry.sessions,
        AddressProvenanceAt dec stepIdx .readMem session.read.addr ∧
          session.read.rv = WitnessMemoryBinding.ramReadClaimValue pre post dec
  storeWriteAddressCovered :
    dec.opcodeId = .storeRegs →
      ∃ session ∈ ramRegistry.sessions,
        AddressProvenanceAt dec stepIdx .writeMem session.write.addr
  storeWriteValueCovered :
    dec.opcodeId = .storeRegs →
      ∃ session ∈ ramRegistry.sessions,
        AddressProvenanceAt dec stepIdx .writeMem session.write.addr ∧
          session.write.wv = WitnessMemoryBinding.ramWriteClaimValue pre post dec

def registerTemporalSeedBound_of_stage2TemporalSeedBound
  {readSessionKey : EvalPoint → SessionKey}
  {pairedSessionKey : AddressPoint → CyclePoint → SessionKey}
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    Stage2TemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z) :
  RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z :=
  { trace := seed.trace
    traceMatches := seed.traceMatches
    frame := seed.frame
    registerPorts := seed.registerPorts
    registerRegistry := seed.registerRegistry
    registerTwistClosed := seed.registerTwistClosed
    readXAddressCovered := seed.readXAddressCovered
    readXValueCovered := seed.readXValueCovered
    readYAddressCovered := seed.readYAddressCovered
    readYValueCovered := seed.readYValueCovered
    readIAddressCovered := seed.readIAddressCovered
    readIValueCovered := seed.readIValueCovered
    writeRegAddressCovered := seed.writeRegAddressCovered
    writeRegValueCovered := seed.writeRegValueCovered }

def ramTemporalSeedBound_of_stage2TemporalSeedBound
  {readSessionKey : EvalPoint → SessionKey}
  {pairedSessionKey : AddressPoint → CyclePoint → SessionKey}
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (seed :
    Stage2TemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z) :
  RamTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ stepIdx pre post dec z :=
  { trace := seed.trace
    traceMatches := seed.traceMatches
    frame := seed.frame
    ramPorts := seed.ramPorts
    ramRaf := seed.ramRaf
    ramRegistry := seed.ramRegistry
    ramTwistClosed := seed.ramTwistClosed
    loadReadAddressCovered := seed.loadReadAddressCovered
    loadReadValueCovered := seed.loadReadValueCovered
    storeWriteAddressCovered := seed.storeWriteAddressCovered
    storeWriteValueCovered := seed.storeWriteValueCovered }

noncomputable def stage2TemporalSeedBound_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z) :
  Stage2TemporalSeedBound readSessionKey pairedSessionKey validAddressColumns
    kernelAddressBound rwReadCheckExpression writeCheckExpression
    valEvaluationExpression readWriteMemoryRelation incrementRelation Γ₃ stepIdx
    pre post dec z := by
  classical
  let ev := Classical.choice h
  exact
    { trace := ev.memory.trace
      traceMatches := ev.memory.traceMatches
      frame := ev.memory.frame
      registerPorts := ev.memory.registerPorts
      ramPorts := ev.memory.ramPorts
      ramRaf := ev.memory.ramRaf
      registerRegistry := ev.memory.registerRegistry
      readXAddressCovered := ev.memory.readXAddressCovered
      readXValueCovered := ev.memory.readXValueCovered
      readYAddressCovered := ev.memory.readYAddressCovered
      readYValueCovered := ev.memory.readYValueCovered
      readIAddressCovered := ev.memory.readIAddressCovered
      readIValueCovered := ev.memory.readIValueCovered
      writeRegAddressCovered := ev.memory.writeRegAddressCovered
      writeRegValueCovered := ev.memory.writeRegValueCovered
      ramRegistry := ev.memory.ramRegistry
      registerTwistClosed := ev.registerTwistClosed
      ramTwistClosed := ev.ramTwistClosed
      loadReadAddressCovered := ev.memory.loadReadAddressCovered
      loadReadValueCovered := ev.memory.loadReadValueCovered
      storeWriteAddressCovered := ev.memory.storeWriteAddressCovered
      storeWriteValueCovered := ev.memory.storeWriteValueCovered }

noncomputable def stage2TemporalSeedBound_of_exactAuthenticatedEvidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    ExactSemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ stepIdx init pre post dec z) :
  Σ' Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F),
    Stage2TemporalSeedBound readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation Γ₃
      stepIdx pre post dec z := by
  classical
  let Γ₁ := Classical.choose h
  let hΓ₂ : ∃ Γ₂ Γ₃,
      SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z :=
    Classical.choose_spec h
  let Γ₂ := Classical.choose hΓ₂
  let hΓ₃ :
      ∃ Γ₃,
        SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
          readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
          readCheckExpression rwReadCheckExpression writeCheckExpression
          valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
          incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z :=
    Classical.choose_spec hΓ₂
  let Γ₃ := Classical.choose hΓ₃
  let hSem :
      SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z :=
    Classical.choose_spec hΓ₃
  exact ⟨Γ₃, stage2TemporalSeedBound_of_evidence hSem⟩

theorem semanticBounds_of_authenticatedEvidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z) :
  @KernelPublicInputsBound DigestRom RootParamsId VmSpec TranscriptSeed
    inputs.hashProgram inputs.hashInitialState inputs.programWordCountOf
    inputs.programBaseAddrOf inputs.padPcWordOf inputs.paddedTraceLengthOf
    inputs.twoPow inputs.rootParamsOf inputs.publicInput inputs.pubMeta rom
    init ∧
    WitnessMemoryBinding.WitnessBinds (K := F) pre post dec z ∧
    StepComposition.FetchDecodeBound rom pre.pc dec ∧
    StepComposition.LookupBound dec pre z ∧
    StepComposition.MemoryBound pre post init dec z ∧
    (∃ N β1 β2 shiftClaim shiftProof currentRow rowClaim,
      StepComposition.ContinuityRowBound stepIdx N β1 β2 shiftClaim
        shiftProof currentRow rowClaim z) ∧
    StepComposition.FramebufferBound pre post dec ∧
    StepComposition.ScheduleBound σ stepIdx pre post dec := by
  exact ⟨kernelPublicInputsBound_of_evidence h, witnessBinds_of_evidence h,
    fetchDecodeBound_of_evidence h,
    lookupBound_of_evidence h, memoryBound_of_evidence h,
    continuityRowBound_of_evidence h,
    framebufferBound_of_evidence h, scheduleBound_of_evidence h⟩

theorem semanticEvidenceCovered_of_exactEvidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    ExactSemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ stepIdx init pre post dec z) :
  ∃ Γ₁ Γ₂ Γ₃,
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z := h

theorem semanticBounds_of_exactAuthenticatedEvidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    ExactSemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ stepIdx init pre post dec z) :
  @KernelPublicInputsBound DigestRom RootParamsId VmSpec TranscriptSeed
    inputs.hashProgram inputs.hashInitialState inputs.programWordCountOf
    inputs.programBaseAddrOf inputs.padPcWordOf inputs.paddedTraceLengthOf
    inputs.twoPow inputs.rootParamsOf inputs.publicInput inputs.pubMeta rom
    init ∧
    ExecutionInputsBound inputs.hashProgram inputs.hashSchedule inputs.scheduleLength
      inputs.romHash inputs.scheduleHash inputs.publishedLength rom σ stepIdx ∧
    WitnessMemoryBinding.WitnessBinds (K := F) pre post dec z ∧
    StepComposition.FetchDecodeBound rom pre.pc dec ∧
    StepComposition.LookupBound dec pre z ∧
    StepComposition.MemoryBound pre post init dec z ∧
    (∃ N β1 β2 shiftClaim shiftProof currentRow rowClaim,
      StepComposition.ContinuityRowBound stepIdx N β1 β2 shiftClaim
        shiftProof currentRow rowClaim z) ∧
    StepComposition.FramebufferBound pre post dec ∧
    StepComposition.ScheduleBound σ stepIdx pre post dec := by
  rcases semanticEvidenceCovered_of_exactEvidence h with ⟨Γ₁, Γ₂, Γ₃, hSem⟩
  exact ⟨kernelPublicInputsBound_of_evidence hSem,
    executionInputsBound_of_evidence hSem, witnessBinds_of_evidence hSem,
    fetchDecodeBound_of_evidence hSem, lookupBound_of_evidence hSem,
    memoryBound_of_evidence hSem, continuityRowBound_of_evidence hSem,
    framebufferBound_of_evidence hSem, scheduleBound_of_evidence hSem⟩

theorem laneShiftSourceOpeningAppears_of_authenticatedEvidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z) :
  ∃ openingPoints : ExactOpeningBoundary.KernelPoints,
    ∃ kernelManifest : ExactOpeningBoundary.KernelOpeningManifest F Unit,
      ∃ _rootManifest : ExactOpeningBoundary.RootOpeningManifest F Unit,
        ExactOpeningBoundary.LaneShiftSourceOpeningAppearsInManifest
          openingPoints kernelManifest := by
  rcases h with ⟨ev⟩
  exact ⟨ev.openingPoints, ev.kernelManifest, ev.rootManifest,
    ExactOpeningBoundary.laneShiftSourceOpeningAppears_of_exactKernelOpeningBoundary
      ev.boundary⟩

theorem laneShiftSourceOpeningAppears_of_exactAuthenticatedEvidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    ExactSemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ stepIdx init pre post dec z) :
  ∃ openingPoints : ExactOpeningBoundary.KernelPoints,
    ∃ kernelManifest : ExactOpeningBoundary.KernelOpeningManifest F Unit,
      ∃ _rootManifest : ExactOpeningBoundary.RootOpeningManifest F Unit,
        ExactOpeningBoundary.LaneShiftSourceOpeningAppearsInManifest
          openingPoints kernelManifest := by
  rcases semanticEvidenceCovered_of_exactEvidence h with ⟨Γ₁, Γ₂, Γ₃, hSem⟩
  exact laneShiftSourceOpeningAppears_of_authenticatedEvidence hSem

end Evidence

end Nightstream.Chip8.EvidenceCoverage

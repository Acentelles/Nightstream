import Nightstream.Chip8.Trace.AuthenticatedTrace
import Nightstream.Chip8.Stage2.TwistRoleSessions

/-!
Owns extraction of explicit Stage-2 Twist role-session witnesses from exact
CHIP-8 frame evidence across one authenticated trace. This file does not
reconstruct chunk-global register/RAM timelines; it exposes the concrete
row-indexed authenticated sessions that a later temporal-reconstruction owner
must compose.
-/

namespace Nightstream.Chip8.TwistTraceRoleSessions

open Nightstream.Chip8
open Nightstream.Chip8.AuthenticatedTrace
open Nightstream.Chip8.EvidenceCoverage
open Nightstream.Chip8.TwistRoleSessions

abbrev F := AuthenticatedTrace.F
abbrev Program := AuthenticatedTrace.Program
abbrev MachineState := AuthenticatedTrace.MachineState
abbrev InitialState := AuthenticatedTrace.InitialState
abbrev ExternalSchedule := AuthenticatedTrace.ExternalSchedule

section Evidence

variable
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr Table ValSurface
    Increment SessionKey : Type*}
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}

structure ExactFrameRoleSessions
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
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) where
  Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)
  registerSeed :
    RegisterTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ frame.stepIdx frame.frame.pre
      frame.frame.post frame.frame.dec frame.frame.row
  ramSeed :
    RamTemporalSeedBound
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation Γ₃ frame.stepIdx frame.frame.pre
      frame.frame.post frame.frame.dec frame.frame.row
  registers :
    RegisterRoleSessions
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation registerSeed
  loadRam :
    frame.frame.dec.opcodeId = .loadRegs →
      LoadRamRoleSession
        (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
        (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
        (AddressColumns := AddressColumns) (Addr := Addr)
        (ValSurface := ValSurface) (Increment := Increment)
        (SessionKey := SessionKey)
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        rwReadCheckExpression writeCheckExpression valEvaluationExpression
        readWriteMemoryRelation incrementRelation ramSeed
  storeRam :
    frame.frame.dec.opcodeId = .storeRegs →
      StoreRamRoleSession
        (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
        (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
        (AddressColumns := AddressColumns) (Addr := Addr)
        (ValSurface := ValSurface) (Increment := Increment)
        (SessionKey := SessionKey)
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        rwReadCheckExpression writeCheckExpression valEvaluationExpression
        readWriteMemoryRelation incrementRelation ramSeed

abbrev ExactFrameRoleSessionsBound
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
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) : Prop :=
  Nonempty (ExactFrameRoleSessions frame)

structure ExactTraceRoleSessionsBundle
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) where
  lookup :
    ∀ {frame}, frame ∈ frames → ExactFrameRoleSessions frame

abbrev ExactTraceRoleSessionsBundleBound
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) : Prop :=
  Nonempty (ExactTraceRoleSessionsBundle frames)

noncomputable def exactFrameRoleSessions_of_exactFrameEvidence
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
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :
  ExactFrameRoleSessions frame := by
  classical
  rcases
      stage2TemporalSeedBound_of_exactAuthenticatedEvidence frame.exactEvidence with
    ⟨Γ₃, hSeed⟩
  let hRegisterSeed := registerTemporalSeedBound_of_stage2TemporalSeedBound hSeed
  let hRamSeed := ramTemporalSeedBound_of_stage2TemporalSeedBound hSeed
  refine
    { Γ₃ := Γ₃
      registerSeed := hRegisterSeed
      ramSeed := hRamSeed
      registers :=
        registerRoleSessions_of_seed readSessionKey pairedSessionKey
          validAddressColumns kernelAddressBound rwReadCheckExpression
          writeCheckExpression valEvaluationExpression readWriteMemoryRelation
          incrementRelation hRegisterSeed
      loadRam := ?_
      storeRam := ?_ }
  · intro hLoad
    exact
      loadRamRoleSession_of_seed readSessionKey pairedSessionKey
        validAddressColumns kernelAddressBound rwReadCheckExpression
        writeCheckExpression valEvaluationExpression readWriteMemoryRelation
        incrementRelation hRamSeed hLoad
  · intro hStore
    exact
      storeRamRoleSession_of_seed readSessionKey pairedSessionKey
        validAddressColumns kernelAddressBound rwReadCheckExpression
        writeCheckExpression valEvaluationExpression readWriteMemoryRelation
        incrementRelation hRamSeed hStore

theorem exactFrameRoleSessionsBound_of_exactFrameEvidence
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
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :
  ExactFrameRoleSessionsBound frame := by
  exact ⟨exactFrameRoleSessions_of_exactFrameEvidence frame⟩

theorem exactTraceRoleSessionsBound_of_frames
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)) :
  List.Forall ExactFrameRoleSessionsBound frames := by
  rw [List.forall_iff_forall_mem]
  intro frame _hMem
  exact exactFrameRoleSessionsBound_of_exactFrameEvidence frame

noncomputable def exactTraceRoleSessionsBundle_of_frames
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)) :
  ExactTraceRoleSessionsBundle frames := by
  refine ⟨?_⟩
  intro frame _hMem
  exact exactFrameRoleSessions_of_exactFrameEvidence frame

theorem exactTraceRoleSessionsBundleBound_of_frames
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)) :
  ExactTraceRoleSessionsBundleBound frames := by
  exact ⟨exactTraceRoleSessionsBundle_of_frames frames⟩

theorem registerReadXValue_eq_primaryValue_of_traceBundle
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)}
  (bundle : ExactTraceRoleSessionsBundle frames)
  {frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hMem : frame ∈ frames) :
  (bundle.lookup hMem).registers.readX.read.rv =
    WitnessMemoryBinding.primaryValue frame.frame.pre frame.frame.dec := by
  exact
    registerRoleSessions_readXValue_eq_primaryValue
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
      (bundle.lookup hMem).registers

theorem registerReadYValue_eq_secondaryValue_of_traceBundle
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)}
  (bundle : ExactTraceRoleSessionsBundle frames)
  {frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hMem : frame ∈ frames) :
  (bundle.lookup hMem).registers.readY.read.rv =
    WitnessMemoryBinding.secondaryValue frame.frame.pre frame.frame.dec := by
  exact
    registerRoleSessions_readYValue_eq_secondaryValue
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
      (bundle.lookup hMem).registers

theorem registerReadIValue_eq_preI_of_traceBundle
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)}
  (bundle : ExactTraceRoleSessionsBundle frames)
  {frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hMem : frame ∈ frames) :
  (bundle.lookup hMem).registers.readI.read.rv = frame.frame.pre.i := by
  exact
    registerRoleSessions_readIValue_eq_preI
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
      (bundle.lookup hMem).registers

theorem registerWriteRegValue_eq_postValue_of_traceBundle
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)}
  (bundle : ExactTraceRoleSessionsBundle frames)
  {frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hMem : frame ∈ frames) :
  (bundle.lookup hMem).registers.writeReg.write.wv =
    WitnessMemoryBinding.registerWriteValue frame.frame.post frame.frame.dec := by
  exact
    registerRoleSessions_writeRegValue_eq_registerWriteValue
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
      (bundle.lookup hMem).registers

theorem registerReadsExpected_of_traceBundle
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)}
  (bundle : ExactTraceRoleSessionsBundle frames)
  {frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hMem : frame ∈ frames) :
  (bundle.lookup hMem).registerSeed.trace.registerReads =
    WitnessMemoryBinding.registerReadsExpected
      frame.frame.pre frame.frame.post frame.frame.dec := by
  exact
    WitnessMemoryBinding.traceMatches_registerReads
      (h := (bundle.lookup hMem).registerSeed.traceMatches)

theorem registerWritesExpected_of_traceBundle
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)}
  (bundle : ExactTraceRoleSessionsBundle frames)
  {frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hMem : frame ∈ frames) :
  (bundle.lookup hMem).registerSeed.trace.registerWrites =
    WitnessMemoryBinding.registerWritesExpected
      frame.frame.pre frame.frame.post frame.frame.dec := by
  exact
    WitnessMemoryBinding.traceMatches_registerWrites
      (h := (bundle.lookup hMem).registerSeed.traceMatches)

theorem ramReadsExpected_of_traceBundle
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)}
  (bundle : ExactTraceRoleSessionsBundle frames)
  {frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hMem : frame ∈ frames) :
  (bundle.lookup hMem).ramSeed.trace.ramReads =
    WitnessMemoryBinding.ramReadsExpected
      frame.frame.pre frame.frame.post frame.frame.dec := by
  exact
    WitnessMemoryBinding.traceMatches_ramReads
      (h := (bundle.lookup hMem).ramSeed.traceMatches)

theorem ramWritesExpected_of_traceBundle
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)}
  (bundle : ExactTraceRoleSessionsBundle frames)
  {frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hMem : frame ∈ frames) :
  (bundle.lookup hMem).ramSeed.trace.ramWrites =
    WitnessMemoryBinding.ramWritesExpected
      frame.frame.pre frame.frame.post frame.frame.dec := by
  exact
    WitnessMemoryBinding.traceMatches_ramWrites
      (h := (bundle.lookup hMem).ramSeed.traceMatches)

theorem registerReads_eq_roleValues_of_traceBundle
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)}
  (bundle : ExactTraceRoleSessionsBundle frames)
  {frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hMem : frame ∈ frames) :
  (bundle.lookup hMem).registerSeed.trace.registerReads =
    [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regRaX,
        (bundle.lookup hMem).registers.readX.read.rv⟩,
      ⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regRaY,
        (bundle.lookup hMem).registers.readY.read.rv⟩,
      ⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regRaI,
        (bundle.lookup hMem).registers.readI.read.rv⟩] := by
  have hPorts := (bundle.lookup hMem).registerSeed.registerPorts
  calc
    (bundle.lookup hMem).registerSeed.trace.registerReads
      = WitnessMemoryBinding.registerReadsExpected
          frame.frame.pre frame.frame.post frame.frame.dec := by
            exact registerReadsExpected_of_traceBundle bundle hMem
    _ =
        [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regRaX,
            WitnessMemoryBinding.registerReadXValue frame.frame.pre frame.frame.dec⟩,
          ⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regRaY,
            WitnessMemoryBinding.registerReadYValue frame.frame.pre frame.frame.dec⟩,
          ⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regRaI,
            WitnessMemoryBinding.registerReadIValue frame.frame.pre frame.frame.dec⟩] := by
          rfl
    _ =
        [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regRaX,
            (bundle.lookup hMem).registers.readX.read.rv⟩,
          ⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regRaY,
            (bundle.lookup hMem).registers.readY.read.rv⟩,
          ⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regRaI,
            (bundle.lookup hMem).registers.readI.read.rv⟩] := by
          simp [hPorts.1, hPorts.2.1, hPorts.2.2.1,
            registerRoleSessions_readXValue_eq_primaryValue,
            registerRoleSessions_readYValue_eq_secondaryValue,
            registerRoleSessions_readIValue_eq_preI]

theorem registerWrites_eq_roleValues_of_traceBundle
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)}
  (bundle : ExactTraceRoleSessionsBundle frames)
  {frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hMem : frame ∈ frames) :
  (bundle.lookup hMem).registerSeed.trace.registerWrites =
    [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regWa,
        (bundle.lookup hMem).registers.writeReg.write.wv⟩] := by
  have hPorts := (bundle.lookup hMem).registerSeed.registerPorts
  calc
    (bundle.lookup hMem).registerSeed.trace.registerWrites
      = WitnessMemoryBinding.registerWritesExpected
          frame.frame.pre frame.frame.post frame.frame.dec := by
            exact registerWritesExpected_of_traceBundle bundle hMem
    _ =
        [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regWa,
            WitnessMemoryBinding.registerWriteValue frame.frame.post frame.frame.dec⟩] := by
          rfl
    _ =
        [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regWa,
            (bundle.lookup hMem).registers.writeReg.write.wv⟩] := by
          simp [hPorts.2.2.2, registerRoleSessions_writeRegValue_eq_registerWriteValue]

theorem loadRamReads_eq_roleValues_of_traceBundle
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)}
  (bundle : ExactTraceRoleSessionsBundle frames)
  {frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hMem : frame ∈ frames)
  (hLoad : frame.frame.dec.opcodeId = .loadRegs) :
  (bundle.lookup hMem).ramSeed.trace.ramReads =
    [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .ramRa,
        ((bundle.lookup hMem).loadRam hLoad).readMem.read.rv⟩] := by
  have hPorts := (bundle.lookup hMem).ramSeed.ramPorts
  calc
    (bundle.lookup hMem).ramSeed.trace.ramReads
      = WitnessMemoryBinding.ramReadsExpected
          frame.frame.pre frame.frame.post frame.frame.dec := by
            exact ramReadsExpected_of_traceBundle bundle hMem
    _ =
        [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .ramRa,
            WitnessMemoryBinding.ramReadValue frame.frame.pre frame.frame.dec⟩] := by
          rfl
    _ =
        [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .ramRa,
            ((bundle.lookup hMem).loadRam hLoad).readMem.read.rv⟩] := by
          simp [hPorts.1, loadRamRoleSession_readMemValue_eq_ramReadValue]

theorem storeRamWrites_eq_roleValues_of_traceBundle
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)}
  (bundle : ExactTraceRoleSessionsBundle frames)
  {frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hMem : frame ∈ frames)
  (hStore : frame.frame.dec.opcodeId = .storeRegs) :
  (bundle.lookup hMem).ramSeed.trace.ramWrites =
    [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .ramWa,
        ((bundle.lookup hMem).storeRam hStore).writeMem.write.wv⟩] := by
  have hPorts := (bundle.lookup hMem).ramSeed.ramPorts
  calc
    (bundle.lookup hMem).ramSeed.trace.ramWrites
      = WitnessMemoryBinding.ramWritesExpected
          frame.frame.pre frame.frame.post frame.frame.dec := by
            exact ramWritesExpected_of_traceBundle bundle hMem
    _ =
        [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .ramWa,
            WitnessMemoryBinding.ramWriteValue frame.frame.post frame.frame.dec⟩] := by
          rfl
    _ =
        [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .ramWa,
            ((bundle.lookup hMem).storeRam hStore).writeMem.write.wv⟩] := by
          simp [hPorts.2, storeRamRoleSession_writeMemValue_eq_ramWriteValue]

theorem loadRamReadMemValue_eq_preRam_of_traceBundle
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)}
  (bundle : ExactTraceRoleSessionsBundle frames)
  {frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hMem : frame ∈ frames)
  (hLoad : frame.frame.dec.opcodeId = .loadRegs) :
  ((bundle.lookup hMem).loadRam hLoad).readMem.read.rv =
    WitnessMemoryBinding.ramReadValue frame.frame.pre frame.frame.dec := by
  exact
    loadRamRoleSession_readMemValue_eq_ramReadValue
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
      ((bundle.lookup hMem).loadRam hLoad)

theorem storeRamWriteMemValue_eq_postRam_of_traceBundle
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)}
  (bundle : ExactTraceRoleSessionsBundle frames)
  {frame :
    AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hMem : frame ∈ frames)
  (hStore : frame.frame.dec.opcodeId = .storeRegs) :
  ((bundle.lookup hMem).storeRam hStore).writeMem.write.wv =
    WitnessMemoryBinding.ramWriteValue frame.frame.post frame.frame.dec := by
  exact
    storeRamRoleSession_writeMemValue_eq_ramWriteValue
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
      ((bundle.lookup hMem).storeRam hStore)

theorem registerReads_eq_roleValues_tracewise
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)) :
  List.Forall
    (fun frame =>
      let roles := exactFrameRoleSessions_of_exactFrameEvidence frame
      roles.registerSeed.trace.registerReads =
        [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regRaX,
            roles.registers.readX.read.rv⟩,
          ⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regRaY,
            roles.registers.readY.read.rv⟩,
          ⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regRaI,
            roles.registers.readI.read.rv⟩]) frames := by
  rw [List.forall_iff_forall_mem]
  intro frame hMem
  let bundle := exactTraceRoleSessionsBundle_of_frames frames
  simpa [bundle, exactTraceRoleSessionsBundle_of_frames] using
    (registerReads_eq_roleValues_of_traceBundle (frames := frames) bundle hMem)

theorem registerWrites_eq_roleValues_tracewise
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)) :
  List.Forall
    (fun frame =>
      let roles := exactFrameRoleSessions_of_exactFrameEvidence frame
      roles.registerSeed.trace.registerWrites =
        [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regWa,
            roles.registers.writeReg.write.wv⟩]) frames := by
  rw [List.forall_iff_forall_mem]
  intro frame hMem
  let bundle := exactTraceRoleSessionsBundle_of_frames frames
  simpa [bundle, exactTraceRoleSessionsBundle_of_frames] using
    (registerWrites_eq_roleValues_of_traceBundle (frames := frames) bundle hMem)

theorem loadRamReads_eq_roleValues_tracewise
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)) :
  List.Forall
    (fun frame =>
      ∀ hLoad : frame.frame.dec.opcodeId = .loadRegs,
        let roles := exactFrameRoleSessions_of_exactFrameEvidence frame
        roles.ramSeed.trace.ramReads =
          [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .ramRa,
              (roles.loadRam hLoad).readMem.read.rv⟩]) frames := by
  rw [List.forall_iff_forall_mem]
  intro frame hMem hLoad
  let bundle := exactTraceRoleSessionsBundle_of_frames frames
  simpa [bundle, exactTraceRoleSessionsBundle_of_frames] using
    (loadRamReads_eq_roleValues_of_traceBundle
      (frames := frames) bundle hMem hLoad)

theorem storeRamWrites_eq_roleValues_tracewise
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)) :
  List.Forall
    (fun frame =>
      ∀ hStore : frame.frame.dec.opcodeId = .storeRegs,
        let roles := exactFrameRoleSessions_of_exactFrameEvidence frame
        roles.ramSeed.trace.ramWrites =
          [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .ramWa,
              (roles.storeRam hStore).writeMem.write.wv⟩]) frames := by
  rw [List.forall_iff_forall_mem]
  intro frame hMem hStore
  let bundle := exactTraceRoleSessionsBundle_of_frames frames
  simpa [bundle, exactTraceRoleSessionsBundle_of_frames] using
    (storeRamWrites_eq_roleValues_of_traceBundle
      (frames := frames) bundle hMem hStore)

theorem loadRamReadMemValue_eq_preRam_tracewise
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)) :
  List.Forall
    (fun frame =>
      ∀ hLoad : frame.frame.dec.opcodeId = .loadRegs,
        let roles := exactFrameRoleSessions_of_exactFrameEvidence frame
        (roles.loadRam hLoad).readMem.read.rv =
          WitnessMemoryBinding.ramReadValue frame.frame.pre frame.frame.dec) frames := by
  rw [List.forall_iff_forall_mem]
  intro frame hMem hLoad
  let bundle := exactTraceRoleSessionsBundle_of_frames frames
  simpa [bundle, exactTraceRoleSessionsBundle_of_frames] using
    (loadRamReadMemValue_eq_preRam_of_traceBundle
      (frames := frames) bundle hMem hLoad)

theorem storeRamWriteMemValue_eq_postRam_tracewise
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
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation
        readWriteMemoryRelation incrementRelation rom σ init)) :
  List.Forall
    (fun frame =>
      ∀ hStore : frame.frame.dec.opcodeId = .storeRegs,
        let roles := exactFrameRoleSessions_of_exactFrameEvidence frame
        (roles.storeRam hStore).writeMem.write.wv =
          WitnessMemoryBinding.ramWriteValue frame.frame.post frame.frame.dec) frames := by
  rw [List.forall_iff_forall_mem]
  intro frame hMem hStore
  let bundle := exactTraceRoleSessionsBundle_of_frames frames
  simpa [bundle, exactTraceRoleSessionsBundle_of_frames] using
    (storeRamWriteMemValue_eq_postRam_of_traceBundle
      (frames := frames) bundle hMem hStore)

end Evidence

end Nightstream.Chip8.TwistTraceRoleSessions

import Nightstream.Chip8.Stage1.BytecodeFetchProjection
import Nightstream.Chip8.Stage1.InstructionSemanticsLookupProjection
import Nightstream.Chip8.Stage2.RegisterHistoryProjection
import Nightstream.Chip8.Stage2.RamHistoryProjection

namespace Nightstream.Chip8

open Nightstream.Chip8.FetchDecodeBinding
open Nightstream.Chip8.AuthenticatedTrace

abbrev F := AuthenticatedTrace.F
abbrev Program := AuthenticatedTrace.Program
abbrev InitialState := AuthenticatedTrace.InitialState
abbrev ExternalSchedule := AuthenticatedTrace.ExternalSchedule

inductive ReleaseStage where
  | readonlyBatch
  | registerHistory
  | ramHistory
deriving DecidableEq, Repr

def familyStage : ExtensionFamily → ReleaseStage
  | .bytecodeFetch => .readonlyBatch
  | .instructionSemanticsLookup => .readonlyBatch
  | .registerHistory => .registerHistory
  | .ramHistory => .ramHistory

def stageFamilies : ReleaseStage → List ExtensionFamily
  | .readonlyBatch => [.bytecodeFetch, .instructionSemanticsLookup]
  | .registerHistory => [.registerHistory]
  | .ramHistory => [.ramHistory]

theorem familyStage_bytecodeFetch :
  familyStage .bytecodeFetch = .readonlyBatch := rfl

theorem familyStage_instructionSemanticsLookup :
  familyStage .instructionSemanticsLookup = .readonlyBatch := rfl

theorem familyStage_registerHistory :
  familyStage .registerHistory = .registerHistory := rfl

theorem familyStage_ramHistory :
  familyStage .ramHistory = .ramHistory := rfl

theorem mem_stageFamilies_iff
  {stage : ReleaseStage}
  {family : ExtensionFamily} :
  family ∈ stageFamilies stage ↔ familyStage family = stage := by
  cases stage <;> cases family <;> simp [stageFamilies, familyStage]

theorem family_mem_stageFamilies (family : ExtensionFamily) :
  family ∈ stageFamilies (familyStage family) := by
  exact (mem_stageFamilies_iff).2 rfl

structure ReadonlyBatchBundle
  (rom : Program)
  (pc : Nat)
  (dec : DecodedCore)
  (regX regY xIdx : Nat) where
  fetchOpcode : Nat
  fetch : BytecodeFetchRecordBound rom pc fetchOpcode
  lookupRecord : InstructionSemanticsLookupRecord
  lookup : InstructionSemanticsLookupRecordBound dec regX regY xIdx lookupRecord

abbrev ReadonlyBatchBundleBound
  (rom : Program)
  (pc : Nat)
  (dec : DecodedCore)
  (regX regY xIdx : Nat) : Prop :=
  Nonempty (ReadonlyBatchBundle rom pc dec regX regY xIdx)

noncomputable def readonlyBatchBundle_of_fetchDecodeBound
  {rom : Program}
  {pc : Nat}
  {dec : DecodedCore}
  {regX regY xIdx : Nat}
  (hFetchDecode : FetchDecodeBound rom pc dec) :
  ReadonlyBatchBundle rom pc dec regX regY xIdx := by
  classical
  let hFetch := bytecodeFetchRecordBound_of_fetchDecodeBound hFetchDecode
  let hLookup :=
    instructionSemanticsLookupRecord_existsUnique_of_fetchDecodeBound
      hFetchDecode regX regY xIdx
  exact
    { fetchOpcode := Classical.choose hFetch
      fetch := Classical.choose_spec hFetch
      lookupRecord := Classical.choose hLookup
      lookup := (Classical.choose_spec hLookup).1 }

theorem readonlyBatchBundleBound_of_fetchDecodeBound
  {rom : Program}
  {pc : Nat}
  {dec : DecodedCore}
  {regX regY xIdx : Nat}
  (hFetchDecode : FetchDecodeBound rom pc dec) :
  ReadonlyBatchBundleBound rom pc dec regX regY xIdx := by
  exact ⟨readonlyBatchBundle_of_fetchDecodeBound hFetchDecode⟩

theorem readonlyBatchBundle_opcodeAt
  {rom : Program}
  {pc : Nat}
  {dec : DecodedCore}
  {regX regY xIdx : Nat}
  (bundle : ReadonlyBatchBundle rom pc dec regX regY xIdx) :
  opcodeAt rom pc = some bundle.fetchOpcode := by
  exact bundle.fetch

theorem readonlyBatchBundle_lookup_zero_of_noLookup
  {rom : Program}
  {pc : Nat}
  {dec : DecodedCore}
  {regX regY xIdx : Nat}
  (bundle : ReadonlyBatchBundle rom pc dec regX regY xIdx)
  (hNoLookup : dec.lookupKind = .noLookup) :
  bundle.lookupRecord.lookupOut = 0 := by
  exact instructionSemanticsLookupRecord_lookup_zero_of_noLookup hNoLookup bundle.lookup

theorem readonlyBatchBundle_burst_zero_of_nonMem
  {rom : Program}
  {pc : Nat}
  {dec : DecodedCore}
  {regX regY xIdx : Nat}
  (bundle : ReadonlyBatchBundle rom pc dec regX regY xIdx)
  (hNonMem : dec.isMemOp = 0) :
  bundle.lookupRecord.burstLast = 0 := by
  exact instructionSemanticsLookupRecord_burst_zero_of_nonMem hNonMem bundle.lookup

section History

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
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}

abbrev ExactFrames
  (pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint)
  (inputs :
    EvidenceCoverage.ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
  (init : InitialState) :=
  List
    (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
      publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init)

structure HistoryBundle
  (frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) where
  register : RegisterHistoryBundle frames
  ram : RamHistoryBundle frames

abbrev HistoryBundleBound
  (frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) : Prop :=
  Nonempty (HistoryBundle frames)

noncomputable def historyBundle_of_exactTrace
  {frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hExact : AuthenticatedTrace.ExactTraceEvidence frames) :
  HistoryBundle frames := by
  exact
    { register := registerHistoryBundle_of_exactTrace hExact
      ram := ramHistoryBundle_of_exactTrace hExact }

theorem historyBundleBound_of_exactTrace
  {frames :
    ExactFrames pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hExact : AuthenticatedTrace.ExactTraceEvidence frames) :
  HistoryBundleBound frames := by
  exact ⟨historyBundle_of_exactTrace hExact⟩

end History

end Nightstream.Chip8

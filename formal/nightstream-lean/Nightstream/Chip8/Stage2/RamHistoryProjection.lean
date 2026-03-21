import Nightstream.ShardComposition
import Nightstream.Chip8.ExtensionFamily
import Nightstream.Chip8.Stage2.TwistTraceRoleSessions

namespace Nightstream.Chip8

open Nightstream
open Nightstream.Chip8.AuthenticatedTrace
open Nightstream.Chip8.TwistTraceRoleSessions
open Nightstream.Chip8.RamTimeline
open Nightstream.Chip8.WitnessMemoryBinding

private abbrev F := AuthenticatedTrace.F
private abbrev Program := AuthenticatedTrace.Program
private abbrev InitialState := AuthenticatedTrace.InitialState
private abbrev ExternalSchedule := AuthenticatedTrace.ExternalSchedule

abbrev ramHistoryFamily : ExtensionFamily := .ramHistory

section Evidence

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

structure RamHistoryBundle
  (frames :
    List
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) where
  initial : InitialStateBound init
  roleSessions : TwistTraceRoleSessions.ExactTraceRoleSessionsBundle frames
  temporal :
    RamTemporalBound
      (ramTimelineOfTrace (AuthenticatedTrace.traceOf frames))
      (AuthenticatedTrace.traceOf frames)

abbrev RamHistoryBundleBound
  (frames :
    List
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) : Prop :=
  Nonempty (RamHistoryBundle frames)

noncomputable def ramHistoryBundle_of_exactTrace
  {frames :
    List
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : AuthenticatedTrace.ExactTraceEvidence frames) :
  RamHistoryBundle frames := by
  refine
    { initial := initialStateBound_exact init
      roleSessions := TwistTraceRoleSessions.exactTraceRoleSessionsBundle_of_frames frames
      temporal := ?_ }
  exact ramTemporalBound_of_adjacentTraceBound
    (AuthenticatedTrace.ramAdjacentTraceBound_of_exactTrace hExact)

theorem ramHistoryBundleBound_of_exactTrace
  {frames :
    List
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : AuthenticatedTrace.ExactTraceEvidence frames) :
  RamHistoryBundleBound frames := by
  exact ⟨ramHistoryBundle_of_exactTrace hExact⟩

theorem ramHistoryBundle_initialRamValue
  {frames :
    List
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (bundle : RamHistoryBundle frames)
  {addr : Nat}
  (hAddr : addr < DecodeAddressBinding.ramSinkAddr) :
  initialRamValue init addr = init.ram addr := by
  exact initialStateBound_ram bundle.initial hAddr

theorem ramHistoryBundle_initialRamSinkValue
  {frames :
    List
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (bundle : RamHistoryBundle frames) :
  initialRamValue init DecodeAddressBinding.ramSinkAddr = 0 := by
  exact initialStateBound_ramSink bundle.initial

theorem loadRamReads_eq_roleValues_tracewise
  (frames :
    List
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) :
  List.Forall
    (fun frame =>
      ∀ hLoad : frame.frame.dec.opcodeId = .loadRegs,
        let roles := exactFrameRoleSessions_of_exactFrameEvidence frame
        roles.ramSeed.trace.ramReads =
          [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .ramRa,
              (roles.loadRam hLoad).readMem.read.rv⟩]) frames := by
  exact TwistTraceRoleSessions.loadRamReads_eq_roleValues_tracewise frames

theorem storeRamWrites_eq_roleValues_tracewise
  (frames :
    List
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) :
  List.Forall
    (fun frame =>
      ∀ hStore : frame.frame.dec.opcodeId = .storeRegs,
        let roles := exactFrameRoleSessions_of_exactFrameEvidence frame
        roles.ramSeed.trace.ramWrites =
          [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .ramWa,
              (roles.storeRam hStore).writeMem.write.wv⟩]) frames := by
  exact TwistTraceRoleSessions.storeRamWrites_eq_roleValues_tracewise frames

theorem loadRamReadMemValue_eq_preRam_tracewise
  (frames :
    List
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) :
  List.Forall
    (fun frame =>
      ∀ hLoad : frame.frame.dec.opcodeId = .loadRegs,
        let roles := exactFrameRoleSessions_of_exactFrameEvidence frame
        (roles.loadRam hLoad).readMem.read.rv =
          WitnessMemoryBinding.ramReadValue frame.frame.pre frame.frame.dec) frames := by
  exact TwistTraceRoleSessions.loadRamReadMemValue_eq_preRam_tracewise frames

theorem storeRamWriteMemValue_eq_postRam_tracewise
  (frames :
    List
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) :
  List.Forall
    (fun frame =>
      ∀ hStore : frame.frame.dec.opcodeId = .storeRegs,
        let roles := exactFrameRoleSessions_of_exactFrameEvidence frame
        (roles.storeRam hStore).writeMem.write.wv =
          WitnessMemoryBinding.ramWriteValue frame.frame.post frame.frame.dec) frames := by
  exact TwistTraceRoleSessions.storeRamWriteMemValue_eq_postRam_tracewise frames

end Evidence

def ramHistoryProjection
  {K : Type*} [Field K]
  (point : Nightstream.TwistValPoint K) :
  List (Nightstream.Obligation ExtensionFamily (Nightstream.TwistValPoint K)) :=
  Nightstream.twistValProjection ramHistoryFamily point

theorem ramHistoryProjection_is_projectionFamily
  {K : Type*} [Field K]
  {point : Nightstream.TwistValPoint K} :
  Nightstream.ProjectionFamilyAt
      ramHistoryFamily
      .twistValEval
      point
      (ramHistoryProjection point) := by
  exact Nightstream.twistValProjection_is_projectionFamily

theorem ramHistoryProjection_not_mainLane
  {K : Type*} [Field K]
  {mainFamily : ExtensionFamily}
  {mainPoint : Nightstream.TwistValPoint K}
  {point : Nightstream.TwistValPoint K} :
  ¬ Nightstream.MainLaneAdmissible
      mainFamily
      mainPoint
      (ramHistoryProjection point) := by
  exact Nightstream.twistValProjection_not_mainLane

theorem ramHistoryProjection_decide_eq_foldSeparate_of_supported
  {K : Type*} [Field K]
  {policy : Nightstream.FamilyPolicy ExtensionFamily (Nightstream.TwistValPoint K)}
  {point : Nightstream.TwistValPoint K}
  (hSupport : policy.supportsSeparate ramHistoryFamily .twistValEval point) :
  Nightstream.decideFamily policy (ramHistoryProjection point) = .foldSeparate := by
  exact Nightstream.twistValProjection_decide_eq_foldSeparate_of_supported hSupport

theorem ramHistoryProjection_decide_eq_exportFinal_of_unsupported
  {K : Type*} [Field K]
  {policy : Nightstream.FamilyPolicy ExtensionFamily (Nightstream.TwistValPoint K)}
  {point : Nightstream.TwistValPoint K}
  (hUnsupported : ¬ policy.supportsSeparate ramHistoryFamily .twistValEval point) :
  Nightstream.decideFamily policy (ramHistoryProjection point) = .exportFinal := by
  exact Nightstream.twistValProjection_decide_eq_exportFinal_of_unsupported hUnsupported

end Nightstream.Chip8

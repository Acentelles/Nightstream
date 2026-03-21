import Nightstream.ShardComposition
import Nightstream.Chip8.ExtensionFamily
import Nightstream.Chip8.Stage2.TwistTraceRoleSessions

namespace Nightstream.Chip8

open Nightstream
open Nightstream.Chip8.AuthenticatedTrace
open Nightstream.Chip8.TwistTraceRoleSessions
open Nightstream.Chip8.RegisterTimeline
open Nightstream.Chip8.WitnessMemoryBinding

private abbrev F := AuthenticatedTrace.F
private abbrev Program := AuthenticatedTrace.Program
private abbrev InitialState := AuthenticatedTrace.InitialState
private abbrev ExternalSchedule := AuthenticatedTrace.ExternalSchedule

abbrev registerHistoryFamily : ExtensionFamily := .registerHistory

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

structure RegisterHistoryBundle
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
    RegisterTemporalBound
      (registerTimelineOfTrace (AuthenticatedTrace.traceOf frames))
      (AuthenticatedTrace.traceOf frames)

abbrev RegisterHistoryBundleBound
  (frames :
    List
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) : Prop :=
  Nonempty (RegisterHistoryBundle frames)

noncomputable def registerHistoryBundle_of_exactTrace
  {frames :
    List
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : AuthenticatedTrace.ExactTraceEvidence frames) :
  RegisterHistoryBundle frames := by
  refine
    { initial := initialStateBound_exact init
      roleSessions := TwistTraceRoleSessions.exactTraceRoleSessionsBundle_of_frames frames
      temporal := ?_ }
  exact registerTemporalBound_of_adjacentTraceBound
    (AuthenticatedTrace.registerAdjacentTraceBound_of_exactTrace hExact)

theorem registerHistoryBundleBound_of_exactTrace
  {frames :
    List
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : AuthenticatedTrace.ExactTraceEvidence frames) :
  RegisterHistoryBundleBound frames := by
  exact ⟨registerHistoryBundle_of_exactTrace hExact⟩

theorem registerHistoryBundle_initialRegisterValue
  {frames :
    List
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (bundle : RegisterHistoryBundle frames)
  {addr : Nat}
  (hAddr : addr < 16) :
  initialRegisterValue init addr = init.v addr := by
  exact initialStateBound_register bundle.initial hAddr

theorem registerHistoryBundle_initialIValue
  {frames :
    List
      (AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B
        publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (bundle : RegisterHistoryBundle frames) :
  initialRegisterValue init 16 = init.i := by
  exact initialStateBound_i bundle.initial

theorem registerHistoryReads_eq_roleValues_tracewise
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
      let roles := exactFrameRoleSessions_of_exactFrameEvidence frame
      roles.registerSeed.trace.registerReads =
        [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regRaX,
            roles.registers.readX.read.rv⟩,
          ⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regRaY,
            roles.registers.readY.read.rv⟩,
          ⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regRaI,
            roles.registers.readI.read.rv⟩]) frames := by
  exact TwistTraceRoleSessions.registerReads_eq_roleValues_tracewise frames

theorem registerHistoryWrites_eq_roleValues_tracewise
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
      let roles := exactFrameRoleSessions_of_exactFrameEvidence frame
      roles.registerSeed.trace.registerWrites =
        [⟨DecodeAddressBinding.projectedNatAddressAt frame.frame.dec .regWa,
            roles.registers.writeReg.write.wv⟩]) frames := by
  exact TwistTraceRoleSessions.registerWrites_eq_roleValues_tracewise frames

end Evidence

def registerHistoryProjection
  {K : Type*} [Field K]
  (point : Nightstream.TwistValPoint K) :
  List (Nightstream.Obligation ExtensionFamily (Nightstream.TwistValPoint K)) :=
  Nightstream.twistValProjection registerHistoryFamily point

theorem registerHistoryProjection_is_projectionFamily
  {K : Type*} [Field K]
  {point : Nightstream.TwistValPoint K} :
  Nightstream.ProjectionFamilyAt
      registerHistoryFamily
      .twistValEval
      point
      (registerHistoryProjection point) := by
  exact Nightstream.twistValProjection_is_projectionFamily

theorem registerHistoryProjection_not_mainLane
  {K : Type*} [Field K]
  {mainFamily : ExtensionFamily}
  {mainPoint : Nightstream.TwistValPoint K}
  {point : Nightstream.TwistValPoint K} :
  ¬ Nightstream.MainLaneAdmissible
      mainFamily
      mainPoint
      (registerHistoryProjection point) := by
  exact Nightstream.twistValProjection_not_mainLane

theorem registerHistoryProjection_decide_eq_foldSeparate_of_supported
  {K : Type*} [Field K]
  {policy : Nightstream.FamilyPolicy ExtensionFamily (Nightstream.TwistValPoint K)}
  {point : Nightstream.TwistValPoint K}
  (hSupport : policy.supportsSeparate registerHistoryFamily .twistValEval point) :
  Nightstream.decideFamily policy (registerHistoryProjection point) = .foldSeparate := by
  exact Nightstream.twistValProjection_decide_eq_foldSeparate_of_supported hSupport

theorem registerHistoryProjection_decide_eq_exportFinal_of_unsupported
  {K : Type*} [Field K]
  {policy : Nightstream.FamilyPolicy ExtensionFamily (Nightstream.TwistValPoint K)}
  {point : Nightstream.TwistValPoint K}
  (hUnsupported : ¬ policy.supportsSeparate registerHistoryFamily .twistValEval point) :
  Nightstream.decideFamily policy (registerHistoryProjection point) = .exportFinal := by
  exact Nightstream.twistValProjection_decide_eq_exportFinal_of_unsupported hUnsupported

end Nightstream.Chip8

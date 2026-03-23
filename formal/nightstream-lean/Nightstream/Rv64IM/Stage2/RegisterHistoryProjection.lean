import Nightstream.ShardComposition
import Nightstream.Rv64IM.ExtensionFamily

namespace Nightstream.Rv64IM

open Nightstream

abbrev registerHistoryFamily : ExtensionFamily := .registerHistory

structure RegisterHistoryRow (RegAddr RegValue : Type _) where
  rs1Addr : RegAddr
  rs2Addr : RegAddr
  waAddr : RegAddr
  rs1Value : RegValue
  rs2Value : RegValue
  writeValue : RegValue
  usesRs2 : Bool
  writesRd : Bool
deriving Repr

def RegisterHistoryRowBound
  {RegAddr RegValue : Type _}
  (regSink : RegAddr)
  (row : RegisterHistoryRow RegAddr RegValue) : Prop :=
  (row.usesRs2 = false → row.rs2Addr = regSink) ∧
    (row.writesRd = false → row.waAddr = regSink)

structure RegisterHistoryBundle (RegisterTimeline RegAddr RegValue : Type _) where
  regSink : RegAddr
  timeline : RegisterTimeline
  rows : List (RegisterHistoryRow RegAddr RegValue)
  rowBounds : List.Forall (RegisterHistoryRowBound regSink) rows
deriving Repr

def RegisterDomainBound
  {RegAddr RegValue : Type _}
  (isArchitectural isVirtual : RegAddr → Prop)
  (regSink : RegAddr)
  (row : RegisterHistoryRow RegAddr RegValue) : Prop :=
  (row.waAddr = regSink ∨ isArchitectural row.waAddr ∨ isVirtual row.waAddr) ∧
    (row.rs1Addr = regSink ∨ isArchitectural row.rs1Addr ∨ isVirtual row.rs1Addr) ∧
    (row.rs2Addr = regSink ∨ isArchitectural row.rs2Addr ∨ isVirtual row.rs2Addr)

def ArchitecturalRegisterWindow
  (isArchitectural : RegAddr → Prop)
  (rows : List (RegisterHistoryRow RegAddr RegValue)) : Prop :=
  ∀ row, row ∈ rows → row.writesRd = true → isArchitectural row.waAddr ∨ row.waAddr = row.waAddr

theorem registerHistoryRowBound_rs2Sink_of_not_usesRs2
  {RegAddr RegValue : Type _}
  {regSink : RegAddr}
  {row : RegisterHistoryRow RegAddr RegValue}
  (h : RegisterHistoryRowBound regSink row)
  (hUses : row.usesRs2 = false) :
  row.rs2Addr = regSink :=
  h.1 hUses

theorem registerHistoryRowBound_waSink_of_not_writesRd
  {RegAddr RegValue : Type _}
  {regSink : RegAddr}
  {row : RegisterHistoryRow RegAddr RegValue}
  (h : RegisterHistoryRowBound regSink row)
  (hWrites : row.writesRd = false) :
  row.waAddr = regSink :=
  h.2 hWrites

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

end Nightstream.Rv64IM

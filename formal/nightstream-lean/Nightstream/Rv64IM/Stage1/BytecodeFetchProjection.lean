import Nightstream.ShardComposition
import Nightstream.Rv64IM.ExtensionFamily
import Nightstream.Rv64IM.Stage1.FetchDecodeBinding

namespace Nightstream.Rv64IM

open Nightstream

abbrev bytecodeFetchFamily : ExtensionFamily := .fetch

def BytecodeFetchRecordBound
  {BytecodeAddr Row : Type _}
  (bytecodeTable : BytecodeAddr → Option Row)
  (expandedPc : BytecodeAddr)
  (row : Row) : Prop :=
  bytecodeTable expandedPc = some row

def bytecodeFetchProjection
  {K : Type*} [Field K]
  (point : Nightstream.ShoutReadPoint K) :
  List (Nightstream.Obligation ExtensionFamily (Nightstream.ShoutReadPoint K)) :=
  Nightstream.shoutReadProjection bytecodeFetchFamily point

theorem bytecodeFetchRecordBound_of_fetchDecodeBound
  {BytecodeAddr Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {bytecodeTable :
    BytecodeAddr →
      Option (DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)}
  {expandedPc : BytecodeAddr}
  {x0 : RegIdx}
  {isArchitectural : RegIdx → Prop}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  (h : FetchDecodeBound bytecodeTable expandedPc x0 isArchitectural row) :
  BytecodeFetchRecordBound bytecodeTable expandedPc row := by
  exact fetchDecodeBound_bytecodeRow h

theorem bytecodeFetchProjection_is_projectionFamily
  {K : Type*} [Field K]
  {point : Nightstream.ShoutReadPoint K} :
  Nightstream.ProjectionFamilyAt
      bytecodeFetchFamily
      .shoutReadEval
      point
      (bytecodeFetchProjection point) := by
  exact Nightstream.shoutReadProjection_is_projectionFamily

theorem bytecodeFetchProjection_not_mainLane
  {K : Type*} [Field K]
  {mainFamily : ExtensionFamily}
  {mainPoint : Nightstream.ShoutReadPoint K}
  {point : Nightstream.ShoutReadPoint K} :
  ¬ Nightstream.MainLaneAdmissible
      mainFamily
      mainPoint
      (bytecodeFetchProjection point) := by
  exact Nightstream.shoutReadProjection_not_mainLane

theorem bytecodeFetchProjection_decide_eq_foldSeparate_of_supported
  {K : Type*} [Field K]
  {policy : Nightstream.FamilyPolicy ExtensionFamily (Nightstream.ShoutReadPoint K)}
  {point : Nightstream.ShoutReadPoint K}
  (hSupport : policy.supportsSeparate bytecodeFetchFamily .shoutReadEval point) :
  Nightstream.decideFamily policy (bytecodeFetchProjection point) = .foldSeparate := by
  exact Nightstream.shoutReadProjection_decide_eq_foldSeparate_of_supported hSupport

theorem bytecodeFetchProjection_decide_eq_exportFinal_of_unsupported
  {K : Type*} [Field K]
  {policy : Nightstream.FamilyPolicy ExtensionFamily (Nightstream.ShoutReadPoint K)}
  {point : Nightstream.ShoutReadPoint K}
  (hUnsupported : ¬ policy.supportsSeparate bytecodeFetchFamily .shoutReadEval point) :
  Nightstream.decideFamily policy (bytecodeFetchProjection point) = .exportFinal := by
  exact Nightstream.shoutReadProjection_decide_eq_exportFinal_of_unsupported hUnsupported

end Nightstream.Rv64IM

import Nightstream.ShardComposition
import Nightstream.Chip8.ExtensionFamily
import Nightstream.Chip8.Stage1.FetchDecodeBinding

namespace Nightstream.Chip8

open Nightstream
open Nightstream.Chip8.FetchDecodeBinding

abbrev bytecodeFetchFamily : ExtensionFamily := .bytecodeFetch

def BytecodeFetchRecordBound (rom : Program) (pc opcode : Nat) : Prop :=
  opcodeAt rom pc = some opcode

def bytecodeFetchProjection
  {K : Type*} [Field K]
  (point : Nightstream.ShoutReadPoint K) :
  List (Nightstream.Obligation ExtensionFamily (Nightstream.ShoutReadPoint K)) :=
  Nightstream.shoutReadProjection bytecodeFetchFamily point

theorem bytecodeFetchRecordBound_of_fetchDecodeBound
  {rom : Program}
  {pc : Nat}
  {dec : DecodedCore}
  (h : FetchDecodeBound rom pc dec) :
  ∃ opcode, BytecodeFetchRecordBound rom pc opcode := by
  exact fetchDecodeBound_opcodeAt h

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

end Nightstream.Chip8

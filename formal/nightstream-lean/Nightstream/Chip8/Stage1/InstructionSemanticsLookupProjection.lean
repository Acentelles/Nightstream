import Nightstream.ShardComposition
import Nightstream.Chip8.ExtensionFamily
import Nightstream.Chip8.Stage1.FetchDecodeBinding

namespace Nightstream.Chip8

open Nightstream
open Nightstream.Chip8.FetchDecodeBinding

abbrev instructionSemanticsLookupFamily : ExtensionFamily := .instructionSemanticsLookup

structure InstructionSemanticsLookupRecord where
  lookupOut : Nat
  burstLast : Nat
deriving DecidableEq, Repr

def InstructionSemanticsLookupRecordBound
  (dec : DecodedCore)
  (regX regY xIdx : Nat)
  (record : InstructionSemanticsLookupRecord) : Prop :=
  AluLookupBound dec regX regY record.lookupOut ∧
    BurstEqBound dec xIdx record.burstLast

def instructionSemanticsLookupProjection
  {K : Type*} [Field K]
  (point : Nightstream.ShoutReadPoint K) :
  List (Nightstream.Obligation ExtensionFamily (Nightstream.ShoutReadPoint K)) :=
  Nightstream.shoutReadProjection instructionSemanticsLookupFamily point

theorem instructionSemanticsLookupRecord_existsUnique_of_fetchDecodeBound
  {rom : Program}
  {pc : Nat}
  {dec : DecodedCore}
  (_h : FetchDecodeBound rom pc dec)
  (regX regY xIdx : Nat) :
  ∃! record, InstructionSemanticsLookupRecordBound dec regX regY xIdx record := by
  refine ⟨{
      lookupOut := evalLookup dec.lookupKind
        (selectOperand dec.lhsSelector regX regY dec.kk)
        (selectOperand dec.rhsSelector regX regY dec.kk)
      burstLast := dec.isMemOp * eq4Eval xIdx dec.xBound
    }, ?_, ?_⟩
  · constructor
    · simp [AluLookupBound]
    · simp [BurstEqBound]
  · intro record hRecord
    rcases record with ⟨lookupOut, burstLast⟩
    rcases hRecord with ⟨hLookup, hBurst⟩
    simp [AluLookupBound, BurstEqBound] at hLookup hBurst
    subst hLookup
    subst hBurst
    rfl

theorem instructionSemanticsLookupRecord_lookup_zero_of_noLookup
  {dec : DecodedCore}
  {regX regY xIdx : Nat}
  {record : InstructionSemanticsLookupRecord}
  (hNoLookup : dec.lookupKind = .noLookup)
  (hRecord : InstructionSemanticsLookupRecordBound dec regX regY xIdx record) :
  record.lookupOut = 0 := by
  exact aluLookupBound_noLookup_zero hNoLookup hRecord.1

theorem instructionSemanticsLookupRecord_burst_zero_of_nonMem
  {dec : DecodedCore}
  {regX regY xIdx : Nat}
  {record : InstructionSemanticsLookupRecord}
  (hNonMem : dec.isMemOp = 0)
  (hRecord : InstructionSemanticsLookupRecordBound dec regX regY xIdx record) :
  record.burstLast = 0 := by
  exact burstEqBound_nonMem_zero hNonMem hRecord.2

theorem instructionSemanticsLookupProjection_is_projectionFamily
  {K : Type*} [Field K]
  {point : Nightstream.ShoutReadPoint K} :
  Nightstream.ProjectionFamilyAt
      instructionSemanticsLookupFamily
      .shoutReadEval
      point
      (instructionSemanticsLookupProjection point) := by
  exact Nightstream.shoutReadProjection_is_projectionFamily

theorem instructionSemanticsLookupProjection_not_mainLane
  {K : Type*} [Field K]
  {mainFamily : ExtensionFamily}
  {mainPoint : Nightstream.ShoutReadPoint K}
  {point : Nightstream.ShoutReadPoint K} :
  ¬ Nightstream.MainLaneAdmissible
      mainFamily
      mainPoint
      (instructionSemanticsLookupProjection point) := by
  exact Nightstream.shoutReadProjection_not_mainLane

theorem instructionSemanticsLookupProjection_decide_eq_foldSeparate_of_supported
  {K : Type*} [Field K]
  {policy : Nightstream.FamilyPolicy ExtensionFamily (Nightstream.ShoutReadPoint K)}
  {point : Nightstream.ShoutReadPoint K}
  (hSupport : policy.supportsSeparate instructionSemanticsLookupFamily .shoutReadEval point) :
  Nightstream.decideFamily policy (instructionSemanticsLookupProjection point) = .foldSeparate := by
  exact Nightstream.shoutReadProjection_decide_eq_foldSeparate_of_supported hSupport

theorem instructionSemanticsLookupProjection_decide_eq_exportFinal_of_unsupported
  {K : Type*} [Field K]
  {policy : Nightstream.FamilyPolicy ExtensionFamily (Nightstream.ShoutReadPoint K)}
  {point : Nightstream.ShoutReadPoint K}
  (hUnsupported : ¬ policy.supportsSeparate instructionSemanticsLookupFamily .shoutReadEval point) :
  Nightstream.decideFamily policy (instructionSemanticsLookupProjection point) = .exportFinal := by
  exact Nightstream.shoutReadProjection_decide_eq_exportFinal_of_unsupported hUnsupported

end Nightstream.Chip8

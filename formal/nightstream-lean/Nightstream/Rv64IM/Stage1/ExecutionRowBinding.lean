import Mathlib
import Nightstream.ShardComposition
import Nightstream.Rv64IM.ExtensionFamily
import Nightstream.Rv64IM.Stage1.FetchDecodeBinding
import Nightstream.Rv64IM.Stage1.TrivialPredicateArithmetic

namespace Nightstream.Rv64IM

open Nightstream

abbrev executionRowFamily : ExtensionFamily := .executionRow
abbrev aluSubtableFamily : ExtensionFamily := .aluSubtables
abbrev branchConditionFamily : ExtensionFamily := .branchCondition

def maxAluQuerySlots : Nat := 64
def maxBranchQuerySlots : Nat := 16

def byteParallelSlotIndex (byteIndex : Nat) : Nat :=
  byteIndex

def mulGridSlotIndex (lhsByteIndex rhsByteIndex : Nat) : Nat :=
  8 * lhsByteIndex + rhsByteIndex

theorem byteParallelSlotIndex_lt_maxAluQuerySlots
  {byteIndex : Nat}
  (hByteIndex : byteIndex < 8) :
  byteParallelSlotIndex byteIndex < maxAluQuerySlots := by
  exact lt_trans hByteIndex (by decide)

theorem mulGridSlotIndex_lt_maxAluQuerySlots
  {lhsByteIndex rhsByteIndex : Nat}
  (hLhs : lhsByteIndex < 8)
  (hRhs : rhsByteIndex < 8) :
  mulGridSlotIndex lhsByteIndex rhsByteIndex < maxAluQuerySlots := by
  unfold mulGridSlotIndex maxAluQuerySlots
  omega

structure ExecutionResults (Word : Type _) where
  aluResult : Word
  stepPc : Word
  jumpTarget : Word
  memAddr : Word
  branchTaken : Bool
deriving Repr

structure Stage1LaneView (Word RegIdx : Type _) where
  pc : Word
  rd : RegIdx
  rs1 : RegIdx
  rs2 : RegIdx
  imm : Word
  writesAluToRd : Bool
  writesMemToRd : Bool
  preservesRd : Bool
  isJal : Bool
  isJalr : Bool
  isBranch : Bool
  isLoad : Bool
  isStore : Bool
  usesRs2 : Bool
  advanceArchPc : Bool
  aluOut : Word
  stepPc : Word
  jumpTarget : Word
  memAddr : Word
  branchTaken : Bool
  branchTakenMux : Bool
deriving Repr

structure ExecutionSlotUsage where
  slotUsedAlu : Nat → Bool
  slotUsedBranch : Nat → Bool

def DenseAluSlotUsageBound (slotUsedAlu : Nat → Bool) : Prop :=
  ∀ slot, maxAluQuerySlots ≤ slot → slotUsedAlu slot = false

def DenseBranchSlotUsageBound (slotUsedBranch : Nat → Bool) : Prop :=
  ∀ slot, maxBranchQuerySlots ≤ slot → slotUsedBranch slot = false

def DenseSlotManifestBound (usage : ExecutionSlotUsage) : Prop :=
  DenseAluSlotUsageBound usage.slotUsedAlu ∧
    DenseBranchSlotUsageBound usage.slotUsedBranch

def branchTakenMux (isBranch branchTaken : Bool) : Bool :=
  isBranch && branchTaken

def TakenTargetAlignmentBound
  {Word RegIdx : Type _}
  (wordToNat : Word → Nat)
  (lane : Stage1LaneView Word RegIdx) : Prop :=
  (lane.isJal = true ∨ lane.isJalr = true ∨ lane.branchTakenMux = true) →
    NaturalAlignment .word (wordToNat lane.jumpTarget)

def MulUNoOverflowBound
  {Word : Type _}
  (mulHigh : Word → Word → Word)
  (zeroWord lhs rhs : Word) : Prop :=
  mulHigh lhs rhs = zeroWord

def Stage1SupportBound
  {Word RegIdx : Type _}
  (wordToNat : Word → Nat)
  (lane : Stage1LaneView Word RegIdx)
  (mulHigh : Word → Word → Word)
  (zeroWord divRemQuotient divRemDivisor : Word) : Prop :=
  TakenTargetAlignmentBound wordToNat lane ∧
    MulUNoOverflowBound mulHigh zeroWord divRemQuotient divRemDivisor

def Stage1LinkageBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (lane : Stage1LaneView Word RegIdx)
  (handoff : DecodeHandoff MemWidth)
  (results : ExecutionResults Word) : Prop :=
  lane.pc = row.unexpandedPc ∧
    lane.rd = row.rd ∧
    lane.rs1 = row.rs1 ∧
    lane.rs2 = row.rs2 ∧
    lane.imm = row.imm ∧
    lane.writesAluToRd = row.writesAluToRd ∧
    lane.writesMemToRd = row.writesMemToRd ∧
    lane.preservesRd = row.preservesRd ∧
    lane.isJal = row.isJal ∧
    lane.isJalr = row.isJalr ∧
    lane.isBranch = row.isBranch ∧
    lane.isLoad = row.isLoad ∧
    lane.isStore = row.isStore ∧
    lane.usesRs2 = row.usesRs2 ∧
    lane.advanceArchPc = row.advanceArchPc ∧
    lane.aluOut = results.aluResult ∧
    lane.stepPc = results.stepPc ∧
    lane.jumpTarget = results.jumpTarget ∧
    lane.memAddr = results.memAddr ∧
    lane.branchTaken = results.branchTaken ∧
    lane.branchTakenMux = branchTakenMux row.isBranch results.branchTaken ∧
    DecodeHandoffBound row handoff

structure ExecutionRowProofPackage
  (Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _) where
  row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
  handoff : DecodeHandoff MemWidth
  lane : Stage1LaneView Word RegIdx
  results : ExecutionResults Word
  slotUsage : ExecutionSlotUsage
  slotManifestBound : DenseSlotManifestBound slotUsage
  wordToNat : Word → Nat
  mulHigh : Word → Word → Word
  zeroWord : Word
  divRemQuotient : Word
  divRemDivisor : Word
  supportBound :
    Stage1SupportBound
      wordToNat
      lane
      mulHigh
      zeroWord
      divRemQuotient
      divRemDivisor
  linkageBound : Stage1LinkageBound row lane handoff results

theorem branchTakenMux_eq_true_of_branch
  (isBranch branchTaken : Bool)
  (hBranch : isBranch = true)
  (hTaken : branchTaken = true) :
  branchTakenMux isBranch branchTaken = true := by
  simp [branchTakenMux, hBranch, hTaken]

theorem takenTargetAlignmentBound_of_stage1Support
  {Word RegIdx : Type _}
  {wordToNat : Word → Nat}
  {lane : Stage1LaneView Word RegIdx}
  {mulHigh : Word → Word → Word}
  {zeroWord divRemQuotient divRemDivisor : Word}
  (h :
    Stage1SupportBound
      wordToNat
      lane
      mulHigh
      zeroWord
      divRemQuotient
      divRemDivisor) :
  TakenTargetAlignmentBound wordToNat lane :=
  h.1

theorem mulUNoOverflowBound_of_stage1Support
  {Word RegIdx : Type _}
  {wordToNat : Word → Nat}
  {lane : Stage1LaneView Word RegIdx}
  {mulHigh : Word → Word → Word}
  {zeroWord divRemQuotient divRemDivisor : Word}
  (h :
    Stage1SupportBound
      wordToNat
      lane
      mulHigh
      zeroWord
      divRemQuotient
      divRemDivisor) :
  MulUNoOverflowBound mulHigh zeroWord divRemQuotient divRemDivisor :=
  h.2

theorem stage1LinkageBound_of_executionRow
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (pkg : ExecutionRowProofPackage Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind) :
  Stage1LinkageBound pkg.row pkg.lane pkg.handoff pkg.results :=
  pkg.linkageBound

theorem laneAluOut_eq_resultsAluResult_of_stage1LinkageBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {lane : Stage1LaneView Word RegIdx}
  {handoff : DecodeHandoff MemWidth}
  {results : ExecutionResults Word}
  (h : Stage1LinkageBound row lane handoff results) :
  lane.aluOut = results.aluResult := by
  rcases h with
    ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, hAluOut, _, _, _, _, _, _⟩
  exact hAluOut

theorem laneAluOut_eq_resultsAluResult_of_executionRow
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (pkg : ExecutionRowProofPackage Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind) :
  pkg.lane.aluOut = pkg.results.aluResult :=
  laneAluOut_eq_resultsAluResult_of_stage1LinkageBound pkg.linkageBound

theorem takenTargetAlignmentBound_of_executionRow
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (pkg : ExecutionRowProofPackage Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind) :
  TakenTargetAlignmentBound pkg.wordToNat pkg.lane :=
  takenTargetAlignmentBound_of_stage1Support pkg.supportBound

theorem mulUNoOverflowBound_of_executionRow
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (pkg : ExecutionRowProofPackage Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind) :
  MulUNoOverflowBound
    pkg.mulHigh
    pkg.zeroWord
    pkg.divRemQuotient
    pkg.divRemDivisor :=
  mulUNoOverflowBound_of_stage1Support pkg.supportBound

def executionRowProjection
  {Point : Type _}
  (point : Point) :
  List (Nightstream.Obligation ExtensionFamily Point) :=
  Nightstream.ceProjection executionRowFamily point

def aluSubtableProjection
  {K : Type*} [Field K]
  (point : Nightstream.ShoutReadPoint K) :
  List (Nightstream.Obligation ExtensionFamily (Nightstream.ShoutReadPoint K)) :=
  Nightstream.shoutReadProjection aluSubtableFamily point

def branchConditionProjection
  {K : Type*} [Field K]
  (point : Nightstream.ShoutReadPoint K) :
  List (Nightstream.Obligation ExtensionFamily (Nightstream.ShoutReadPoint K)) :=
  Nightstream.shoutReadProjection branchConditionFamily point

theorem executionRowProjection_is_projectionFamily
  {Point : Type _}
  {point : Point} :
  Nightstream.ProjectionFamilyAt
      executionRowFamily
      .ce
      point
      (executionRowProjection point) := by
  exact Nightstream.ceProjection_is_projectionFamily

theorem executionRowProjection_decide_eq_mergeMain_iff
  {Point : Type _}
  {policy : Nightstream.FamilyPolicy ExtensionFamily Point}
  {point : Point} :
  Nightstream.decideFamily policy (executionRowProjection point) = .mergeMain ↔
    executionRowFamily = policy.mainFamily ∧ point = policy.mainPoint := by
  exact Nightstream.ceProjectionSingleton_decide_eq_mergeMain_iff

theorem executionRowProjection_decide_eq_foldSeparate_of_supported_not_main
  {Point : Type _}
  {policy : Nightstream.FamilyPolicy ExtensionFamily Point}
  {point : Point}
  (hNotMain : ¬ (executionRowFamily = policy.mainFamily ∧ point = policy.mainPoint))
  (hSupport : policy.supportsSeparate executionRowFamily .ce point) :
  Nightstream.decideFamily policy (executionRowProjection point) = .foldSeparate := by
  exact Nightstream.ceProjectionSingleton_decide_eq_foldSeparate_of_supported_not_main
    hNotMain
    hSupport

theorem executionRowProjection_decide_eq_exportFinal_of_unsupported_not_main
  {Point : Type _}
  {policy : Nightstream.FamilyPolicy ExtensionFamily Point}
  {point : Point}
  (hNotMain : ¬ (executionRowFamily = policy.mainFamily ∧ point = policy.mainPoint))
  (hUnsupported : ¬ policy.supportsSeparate executionRowFamily .ce point) :
  Nightstream.decideFamily policy (executionRowProjection point) = .exportFinal := by
  exact Nightstream.ceProjectionSingleton_decide_eq_exportFinal_of_unsupported_not_main
    hNotMain
    hUnsupported

theorem aluSubtableProjection_is_projectionFamily
  {K : Type*} [Field K]
  {point : Nightstream.ShoutReadPoint K} :
  Nightstream.ProjectionFamilyAt
      aluSubtableFamily
      .shoutReadEval
      point
      (aluSubtableProjection point) := by
  exact Nightstream.shoutReadProjection_is_projectionFamily

theorem aluSubtableProjection_not_mainLane
  {K : Type*} [Field K]
  {mainFamily : ExtensionFamily}
  {mainPoint : Nightstream.ShoutReadPoint K}
  {point : Nightstream.ShoutReadPoint K} :
  ¬ Nightstream.MainLaneAdmissible
      mainFamily
      mainPoint
      (aluSubtableProjection point) := by
  exact Nightstream.shoutReadProjection_not_mainLane

theorem aluSubtableProjection_decide_eq_foldSeparate_of_supported
  {K : Type*} [Field K]
  {policy : Nightstream.FamilyPolicy ExtensionFamily (Nightstream.ShoutReadPoint K)}
  {point : Nightstream.ShoutReadPoint K}
  (hSupport : policy.supportsSeparate aluSubtableFamily .shoutReadEval point) :
  Nightstream.decideFamily policy (aluSubtableProjection point) = .foldSeparate := by
  exact Nightstream.shoutReadProjection_decide_eq_foldSeparate_of_supported hSupport

theorem aluSubtableProjection_decide_eq_exportFinal_of_unsupported
  {K : Type*} [Field K]
  {policy : Nightstream.FamilyPolicy ExtensionFamily (Nightstream.ShoutReadPoint K)}
  {point : Nightstream.ShoutReadPoint K}
  (hUnsupported : ¬ policy.supportsSeparate aluSubtableFamily .shoutReadEval point) :
  Nightstream.decideFamily policy (aluSubtableProjection point) = .exportFinal := by
  exact Nightstream.shoutReadProjection_decide_eq_exportFinal_of_unsupported hUnsupported

theorem branchConditionProjection_is_projectionFamily
  {K : Type*} [Field K]
  {point : Nightstream.ShoutReadPoint K} :
  Nightstream.ProjectionFamilyAt
      branchConditionFamily
      .shoutReadEval
      point
      (branchConditionProjection point) := by
  exact Nightstream.shoutReadProjection_is_projectionFamily

theorem branchConditionProjection_not_mainLane
  {K : Type*} [Field K]
  {mainFamily : ExtensionFamily}
  {mainPoint : Nightstream.ShoutReadPoint K}
  {point : Nightstream.ShoutReadPoint K} :
  ¬ Nightstream.MainLaneAdmissible
      mainFamily
      mainPoint
      (branchConditionProjection point) := by
  exact Nightstream.shoutReadProjection_not_mainLane

theorem branchConditionProjection_decide_eq_foldSeparate_of_supported
  {K : Type*} [Field K]
  {policy : Nightstream.FamilyPolicy ExtensionFamily (Nightstream.ShoutReadPoint K)}
  {point : Nightstream.ShoutReadPoint K}
  (hSupport : policy.supportsSeparate branchConditionFamily .shoutReadEval point) :
  Nightstream.decideFamily policy (branchConditionProjection point) = .foldSeparate := by
  exact Nightstream.shoutReadProjection_decide_eq_foldSeparate_of_supported hSupport

theorem branchConditionProjection_decide_eq_exportFinal_of_unsupported
  {K : Type*} [Field K]
  {policy : Nightstream.FamilyPolicy ExtensionFamily (Nightstream.ShoutReadPoint K)}
  {point : Nightstream.ShoutReadPoint K}
  (hUnsupported : ¬ policy.supportsSeparate branchConditionFamily .shoutReadEval point) :
  Nightstream.decideFamily policy (branchConditionProjection point) = .exportFinal := by
  exact Nightstream.shoutReadProjection_decide_eq_exportFinal_of_unsupported hUnsupported

end Nightstream.Rv64IM

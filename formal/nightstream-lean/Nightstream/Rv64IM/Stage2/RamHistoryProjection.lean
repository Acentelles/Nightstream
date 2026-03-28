import Nightstream.ShardComposition
import Nightstream.Rv64IM.ExtensionFamily

namespace Nightstream.Rv64IM

open Nightstream

abbrev ramHistoryFamily : ExtensionFamily := .ramHistory

def flattenRamAddr : List (Nat × Nat) → Nat
  | [] => 0
  | (_bits, addr) :: rest =>
      addr * 2 ^ (rest.foldl (fun acc entry => acc + entry.1) 0) + flattenRamAddr rest

def RamAddressVirtualizationBound
  (chunkedAddr : List (Nat × Nat))
  (flatAddr : Nat) : Prop :=
  flatAddr = flattenRamAddr chunkedAddr

structure RamHistoryRow (RamWord : Type _) where
  activeMem : Bool
  isLoad : Bool
  isStore : Bool
  addrChunks : List (Nat × Nat)
  readWord : RamWord
  writeWord : RamWord
  memVal : RamWord
  rs2Val : RamWord
  deltaWord : RamWord
deriving Repr

def RamHistoryRowBound
  {RamWord : Type _}
  (zeroWord : RamWord)
  (combine : RamWord → RamWord → RamWord)
  (row : RamHistoryRow RamWord) : Prop :=
  (row.activeMem = false → row.deltaWord = zeroWord) ∧
    (row.isLoad = true → row.memVal = row.readWord) ∧
    (row.isStore = true →
      row.memVal = row.rs2Val ∧
        row.writeWord = row.memVal ∧
        row.writeWord = combine row.readWord row.deltaWord) ∧
    (row.isStore = false → row.deltaWord = zeroWord)

def RamZeroRowBound
  {RamWord : Type _}
  (zeroWord : RamWord)
  (row : RamHistoryRow RamWord) : Prop :=
  row.activeMem = false →
    row.deltaWord = zeroWord

structure RamHistoryBundle (RamTimeline RamWord : Type _) where
  zeroWord : RamWord
  combine : RamWord → RamWord → RamWord
  timeline : RamTimeline
  rows : List (RamHistoryRow RamWord)
  rowBounds : List.Forall (RamHistoryRowBound zeroWord combine) rows

theorem flattenRamAddr_nil :
  flattenRamAddr [] = 0 := by
  rfl

theorem flattenRamAddr_cons
  (bits addr : Nat)
  (rest : List (Nat × Nat)) :
  flattenRamAddr ((bits, addr) :: rest) =
    addr * 2 ^ (rest.foldl (fun acc entry => acc + entry.1) 0) + flattenRamAddr rest := by
  rfl

theorem ramHistoryRowBound_memVal_of_load
  {RamWord : Type _}
  {zeroWord : RamWord}
  {combine : RamWord → RamWord → RamWord}
  {row : RamHistoryRow RamWord}
  (h : RamHistoryRowBound zeroWord combine row)
  (hLoad : row.isLoad = true) :
  row.memVal = row.readWord :=
  h.2.1 hLoad

theorem ramHistoryRowBound_storePayload
  {RamWord : Type _}
  {zeroWord : RamWord}
  {combine : RamWord → RamWord → RamWord}
  {row : RamHistoryRow RamWord}
  (h : RamHistoryRowBound zeroWord combine row)
  (hStore : row.isStore = true) :
  row.memVal = row.rs2Val ∧
    row.writeWord = row.memVal ∧
    row.writeWord = combine row.readWord row.deltaWord :=
  h.2.2.1 hStore

theorem ramHistoryRowBound_zeroDelta_of_not_store
  {RamWord : Type _}
  {zeroWord : RamWord}
  {combine : RamWord → RamWord → RamWord}
  {row : RamHistoryRow RamWord}
  (h : RamHistoryRowBound zeroWord combine row)
  (hStore : row.isStore = false) :
  row.deltaWord = zeroWord :=
  h.2.2.2 hStore

theorem ramZeroRowBound_of_ramHistoryRowBound
  {RamWord : Type _}
  {zeroWord : RamWord}
  {combine : RamWord → RamWord → RamWord}
  {row : RamHistoryRow RamWord}
  (h : RamHistoryRowBound zeroWord combine row) :
  RamZeroRowBound zeroWord row := by
  intro hInactive
  exact h.1 hInactive

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

end Nightstream.Rv64IM

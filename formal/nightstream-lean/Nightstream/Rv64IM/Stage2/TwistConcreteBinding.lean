import Nightstream.NonZeroInitTwist
import Nightstream.Rv64IM.Stage2.RegisterHistoryProjection
import Nightstream.Rv64IM.Stage2.RamHistoryProjection
import TwistShout.TwistCoreInterface

namespace Nightstream.Rv64IM

open Nightstream.NonZeroInitTwist
open TwistShout

structure LimbPair (Limb : Type _) where
  lo : Limb
  hi : Limb
deriving Repr

def zeroLimbPair {Limb : Type _} [OfNat Limb 0] : LimbPair Limb :=
  { lo := 0, hi := 0 }

structure RegisterLaneClaims (Limb : Type _) where
  rs1 : LimbPair Limb
  rs2 : LimbPair Limb
  rdNext : LimbPair Limb
  writesRd : Bool
deriving Repr

structure RegisterTwistClaims (Limb : Type _) where
  rvRs1 : LimbPair Limb
  rvRs2 : LimbPair Limb
  wvReg : LimbPair Limb
deriving Repr

def RegisterLinkageBound
  {Limb : Type _}
  (lane : RegisterLaneClaims Limb)
  (twist : RegisterTwistClaims Limb) : Prop :=
  twist.rvRs1 = lane.rs1 ∧
    twist.rvRs2 = lane.rs2 ∧
    (lane.writesRd = true → twist.wvReg = lane.rdNext)

structure RamLaneClaims (Limb : Type _) where
  memVal : LimbPair Limb
  rs2 : LimbPair Limb
  isLoad : Bool
  isStore : Bool
deriving Repr

structure RamTwistClaims (Limb : Type _) where
  rvRamWord : LimbPair Limb
  wvRamWord : LimbPair Limb
deriving Repr

def RamLinkageBound
  {Limb : Type _} [OfNat Limb 0]
  (lane : RamLaneClaims Limb)
  (twist : RamTwistClaims Limb) : Prop :=
  (lane.isLoad = true → lane.memVal = twist.rvRamWord) ∧
    (lane.isStore = true →
      lane.memVal = lane.rs2 ∧
        twist.wvRamWord = lane.memVal) ∧
    (lane.isLoad = false → lane.isStore = false → lane.memVal = zeroLimbPair)

def RamWriteValueVirtualized
  {Limb : Type _}
  (readWord deltaWord writeWord : LimbPair Limb)
  (combine : LimbPair Limb → LimbPair Limb → LimbPair Limb) : Prop :=
  writeWord = combine readWord deltaWord

def RegisterShiftedTimeTable
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t) :
  TwistShout.TimeTable (K := K) d m t :=
  ShiftedTimeTable (K := K) init inc

def RegisterShiftedVirtualValue
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (a : TwistShout.Address d m)
  (rCycle : TwistShout.Point (K := K) t) : K :=
  ShiftedVirtualValue (K := K) init inc a rCycle

def RegisterShiftedValEvaluationExpression
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (rAddress : Fin d → TwistShout.Point (K := K) m)
  (rCycle : TwistShout.Point (K := K) t) : K :=
  ShiftedValEvaluationExpression (K := K) init inc rAddress rCycle

def RamShiftedTimeTable
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t) :
  TwistShout.TimeTable (K := K) d m t :=
  ShiftedTimeTable (K := K) init inc

def RamShiftedVirtualValue
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (a : TwistShout.Address d m)
  (rCycle : TwistShout.Point (K := K) t) : K :=
  ShiftedVirtualValue (K := K) init inc a rCycle

def RamShiftedValEvaluationExpression
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (rAddress : Fin d → TwistShout.Point (K := K) m)
  (rCycle : TwistShout.Point (K := K) t) : K :=
  ShiftedValEvaluationExpression (K := K) init inc rAddress rCycle

def Stage2LinkageBound
  {Limb : Type _} [OfNat Limb 0]
  (registers : RegisterLaneClaims Limb)
  (registerTwist : RegisterTwistClaims Limb)
  (ram : RamLaneClaims Limb)
  (ramTwist : RamTwistClaims Limb) : Prop :=
  RegisterLinkageBound registers registerTwist ∧
    RamLinkageBound ram ramTwist

structure TwistConcreteBindingProofPackage (Limb : Type _) [OfNat Limb 0] where
  registerLane : RegisterLaneClaims Limb
  registerTwist : RegisterTwistClaims Limb
  ramLane : RamLaneClaims Limb
  ramTwist : RamTwistClaims Limb
  linkageBound : Stage2LinkageBound registerLane registerTwist ramLane ramTwist

theorem registerReadCheckAtBitCycle_of_relation
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : TwistShout.TimeTable (K := K) d m t}
  {addr : TwistShout.CycleCube t → TwistShout.Address d m}
  {rv : TwistShout.CycleCube t → K}
  {ra : TwistShout.AddressColumns (K := K) d m t}
  (hRel : TwistShout.ReadWriteMemoryRelation (K := K) val addr rv)
  (hValid : TwistShout.ValidAddressColumns (K := K) ra addr)
  (j : TwistShout.CycleCube t) :
  rv j = TwistShout.rwReadCheckExpression (K := K) ra val
    (TwistShout.bitVec (K := K) j) := by
  exact hRel.readCheckAtBitCycle hValid j

theorem registerWriteCheckAtBitPoint_of_incrementRelation
  {K : Type*} [Field K]
  {d m t : Nat}
  {val inc : TwistShout.TimeTable (K := K) d m t}
  {wa : TwistShout.AddressColumns (K := K) d m t}
  {wv : TwistShout.CycleCube t → K}
  (hRel : TwistShout.IncrementRelation (K := K) val wa wv inc)
  (a : TwistShout.Address d m)
  (j : TwistShout.CycleCube t) :
  inc a j =
    TwistShout.writeCheckExpression (K := K)
      (TwistShout.bitAddress (K := K) a)
      (TwistShout.bitVec (K := K) j)
      wa wv val := by
  exact hRel.writeCheckAtBitPoint a j

theorem registerShiftedVirtualValue_at_bitCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (a : TwistShout.Address d m)
  (j : TwistShout.CycleCube t) :
  RegisterShiftedVirtualValue init inc a (TwistShout.bitVec (K := K) j) =
    RegisterShiftedTimeTable init inc a j := by
  exact shiftedVirtualValue_at_bitCycle (K := K) init inc a j

theorem registerShiftedValEvaluationExpression_eq_timeTableMLE
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (rAddress : Fin d → TwistShout.Point (K := K) m)
  (rCycle : TwistShout.Point (K := K) t) :
  TwistShout.timeTableMLE (K := K) (RegisterShiftedTimeTable init inc) rAddress rCycle =
    RegisterShiftedValEvaluationExpression init inc rAddress rCycle := by
  exact shiftedValEvaluationExpression_eq_timeTableMLE (K := K) init inc rAddress rCycle

theorem registerTimeTableMLE_shifted_at_bitAddress
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (a : TwistShout.Address d m)
  (rCycle : TwistShout.Point (K := K) t) :
  TwistShout.timeTableMLE (K := K) (RegisterShiftedTimeTable init inc)
      (TwistShout.bitAddress (K := K) a) rCycle =
    RegisterShiftedVirtualValue init inc a rCycle := by
  exact timeTableMLE_shiftedTimeTable_at_bitAddress (K := K) init inc a rCycle

theorem registerShiftedValEvaluationExpression_at_bitPoint
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (a : TwistShout.Address d m)
  (j : TwistShout.CycleCube t) :
  RegisterShiftedValEvaluationExpression init inc
      (TwistShout.bitAddress (K := K) a)
      (TwistShout.bitVec (K := K) j) =
    RegisterShiftedTimeTable init inc a j := by
  exact shiftedValEvaluationExpression_at_bitPoint (K := K) init inc a j

theorem registerShiftedReadCheckAtBitCycle_of_relation
  {K : Type*} [Field K]
  {d m t : Nat}
  {init : TwistShout.PublicTable (K := K) d m}
  {addr : TwistShout.CycleCube t → TwistShout.Address d m}
  {rv : TwistShout.CycleCube t → K}
  {ra : TwistShout.AddressColumns (K := K) d m t}
  {inc : TwistShout.TimeTable (K := K) d m t}
  (hRel :
    TwistShout.ReadWriteMemoryRelation (K := K)
      (RegisterShiftedTimeTable init inc) addr rv)
  (hValid : TwistShout.ValidAddressColumns (K := K) ra addr)
  (j : TwistShout.CycleCube t) :
  rv j = TwistShout.rwReadCheckExpression (K := K) ra
    (RegisterShiftedTimeTable init inc)
    (TwistShout.bitVec (K := K) j) := by
  exact registerReadCheckAtBitCycle_of_relation hRel hValid j

theorem registerShiftedWriteCheckAtBitPoint_of_incrementRelation
  {K : Type*} [Field K]
  {d m t : Nat}
  {init : TwistShout.PublicTable (K := K) d m}
  {val : TwistShout.TimeTable (K := K) d m t}
  {wa : TwistShout.AddressColumns (K := K) d m t}
  {wv : TwistShout.CycleCube t → K}
  {inc : TwistShout.TimeTable (K := K) d m t}
  (hRel :
    TwistShout.IncrementRelation (K := K)
      (RegisterShiftedTimeTable init val) wa wv inc)
  (a : TwistShout.Address d m)
  (j : TwistShout.CycleCube t) :
  inc a j =
    TwistShout.writeCheckExpression (K := K)
      (TwistShout.bitAddress (K := K) a)
      (TwistShout.bitVec (K := K) j)
      wa wv (RegisterShiftedTimeTable init val) := by
  exact registerWriteCheckAtBitPoint_of_incrementRelation hRel a j

theorem ramReadCheckAtBitCycle_of_relation
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : TwistShout.TimeTable (K := K) d m t}
  {addr : TwistShout.CycleCube t → TwistShout.Address d m}
  {rv : TwistShout.CycleCube t → K}
  {ra : TwistShout.AddressColumns (K := K) d m t}
  (hRel : TwistShout.ReadWriteMemoryRelation (K := K) val addr rv)
  (hValid : TwistShout.ValidAddressColumns (K := K) ra addr)
  (j : TwistShout.CycleCube t) :
  rv j = TwistShout.rwReadCheckExpression (K := K) ra val
    (TwistShout.bitVec (K := K) j) := by
  exact hRel.readCheckAtBitCycle hValid j

theorem ramWriteCheckAtBitPoint_of_incrementRelation
  {K : Type*} [Field K]
  {d m t : Nat}
  {val inc : TwistShout.TimeTable (K := K) d m t}
  {wa : TwistShout.AddressColumns (K := K) d m t}
  {wv : TwistShout.CycleCube t → K}
  (hRel : TwistShout.IncrementRelation (K := K) val wa wv inc)
  (a : TwistShout.Address d m)
  (j : TwistShout.CycleCube t) :
  inc a j =
    TwistShout.writeCheckExpression (K := K)
      (TwistShout.bitAddress (K := K) a)
      (TwistShout.bitVec (K := K) j)
      wa wv val := by
  exact hRel.writeCheckAtBitPoint a j

theorem ramShiftedVirtualValue_at_bitCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (a : TwistShout.Address d m)
  (j : TwistShout.CycleCube t) :
  RamShiftedVirtualValue init inc a (TwistShout.bitVec (K := K) j) =
    RamShiftedTimeTable init inc a j := by
  exact shiftedVirtualValue_at_bitCycle (K := K) init inc a j

theorem ramShiftedValEvaluationExpression_eq_timeTableMLE
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (rAddress : Fin d → TwistShout.Point (K := K) m)
  (rCycle : TwistShout.Point (K := K) t) :
  TwistShout.timeTableMLE (K := K) (RamShiftedTimeTable init inc) rAddress rCycle =
    RamShiftedValEvaluationExpression init inc rAddress rCycle := by
  exact shiftedValEvaluationExpression_eq_timeTableMLE (K := K) init inc rAddress rCycle

theorem ramTimeTableMLE_shifted_at_bitAddress
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (a : TwistShout.Address d m)
  (rCycle : TwistShout.Point (K := K) t) :
  TwistShout.timeTableMLE (K := K) (RamShiftedTimeTable init inc)
      (TwistShout.bitAddress (K := K) a) rCycle =
    RamShiftedVirtualValue init inc a rCycle := by
  exact timeTableMLE_shiftedTimeTable_at_bitAddress (K := K) init inc a rCycle

theorem ramShiftedValEvaluationExpression_at_bitPoint
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (a : TwistShout.Address d m)
  (j : TwistShout.CycleCube t) :
  RamShiftedValEvaluationExpression init inc
      (TwistShout.bitAddress (K := K) a)
      (TwistShout.bitVec (K := K) j) =
    RamShiftedTimeTable init inc a j := by
  exact shiftedValEvaluationExpression_at_bitPoint (K := K) init inc a j

theorem ramShiftedReadCheckAtBitCycle_of_relation
  {K : Type*} [Field K]
  {d m t : Nat}
  {init : TwistShout.PublicTable (K := K) d m}
  {addr : TwistShout.CycleCube t → TwistShout.Address d m}
  {rv : TwistShout.CycleCube t → K}
  {ra : TwistShout.AddressColumns (K := K) d m t}
  {inc : TwistShout.TimeTable (K := K) d m t}
  (hRel :
    TwistShout.ReadWriteMemoryRelation (K := K)
      (RamShiftedTimeTable init inc) addr rv)
  (hValid : TwistShout.ValidAddressColumns (K := K) ra addr)
  (j : TwistShout.CycleCube t) :
  rv j = TwistShout.rwReadCheckExpression (K := K) ra
    (RamShiftedTimeTable init inc)
    (TwistShout.bitVec (K := K) j) := by
  exact ramReadCheckAtBitCycle_of_relation hRel hValid j

theorem ramShiftedWriteCheckAtBitPoint_of_incrementRelation
  {K : Type*} [Field K]
  {d m t : Nat}
  {init : TwistShout.PublicTable (K := K) d m}
  {val : TwistShout.TimeTable (K := K) d m t}
  {wa : TwistShout.AddressColumns (K := K) d m t}
  {wv : TwistShout.CycleCube t → K}
  {inc : TwistShout.TimeTable (K := K) d m t}
  (hRel :
    TwistShout.IncrementRelation (K := K)
      (RamShiftedTimeTable init val) wa wv inc)
  (a : TwistShout.Address d m)
  (j : TwistShout.CycleCube t) :
  inc a j =
    TwistShout.writeCheckExpression (K := K)
      (TwistShout.bitAddress (K := K) a)
      (TwistShout.bitVec (K := K) j)
      wa wv (RamShiftedTimeTable init val) := by
  exact ramWriteCheckAtBitPoint_of_incrementRelation hRel a j

theorem registerLinkageBound_writeValue_of_activeWrite
  {Limb : Type _}
  {lane : RegisterLaneClaims Limb}
  {twist : RegisterTwistClaims Limb}
  (h : RegisterLinkageBound lane twist)
  (hWrite : lane.writesRd = true) :
  twist.wvReg = lane.rdNext :=
  h.2.2 hWrite

theorem ramLinkageBound_memVal_of_load
  {Limb : Type _} [OfNat Limb 0]
  {lane : RamLaneClaims Limb}
  {twist : RamTwistClaims Limb}
  (h : RamLinkageBound lane twist)
  (hLoad : lane.isLoad = true) :
  lane.memVal = twist.rvRamWord :=
  h.1 hLoad

theorem ramLinkageBound_storePayload
  {Limb : Type _} [OfNat Limb 0]
  {lane : RamLaneClaims Limb}
  {twist : RamTwistClaims Limb}
  (h : RamLinkageBound lane twist)
  (hStore : lane.isStore = true) :
  lane.memVal = lane.rs2 ∧ twist.wvRamWord = lane.memVal :=
  h.2.1 hStore

theorem ramWriteValueVirtualized_of_storePayload
  {Limb : Type _}
  {readWord deltaWord writeWord : LimbPair Limb}
  {combine : LimbPair Limb → LimbPair Limb → LimbPair Limb}
  (h : writeWord = combine readWord deltaWord) :
  RamWriteValueVirtualized readWord deltaWord writeWord combine :=
  h

theorem ramLinkageBound_memVal_zero_of_inactive
  {Limb : Type _} [OfNat Limb 0]
  {lane : RamLaneClaims Limb}
  {twist : RamTwistClaims Limb}
  (h : RamLinkageBound lane twist)
  (hLoad : lane.isLoad = false)
  (hStore : lane.isStore = false) :
  lane.memVal = zeroLimbPair :=
  h.2.2 hLoad hStore

end Nightstream.Rv64IM

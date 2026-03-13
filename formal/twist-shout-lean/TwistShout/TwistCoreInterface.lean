import TwistShout.TwistCore

/-!
# TwistCoreInterface

Thin theorem-facing boundary for the core Twist read-write memory protocol.
-/

namespace TwistShout

namespace TwistCoreInterface

abbrev DigitCube := @TwistShout.DigitCube
abbrev CycleCube := @TwistShout.CycleCube
abbrev Address := @TwistShout.Address
abbrev AddressColumns := @TwistShout.AddressColumns
abbrev ValidAddressColumns := @TwistShout.ValidAddressColumns
abbrev Point := @TwistShout.Point
abbrev PublicTable := @TwistShout.PublicTable
abbrev bitVec := @TwistShout.bitVec
abbrev bitAddress := @TwistShout.bitAddress
abbrev chiWeight := @TwistShout.chiWeight
abbrev mle := @TwistShout.mle
abbrev tableMLE := @TwistShout.tableMLE
abbrev addressWeight := @TwistShout.addressWeight
abbrev addressSelector := @TwistShout.addressSelector
abbrev TimeTable := @TwistShout.TimeTable
abbrev timeTableMLE := @TwistShout.timeTableMLE
abbrev readWriteOracleTable := @TwistShout.readWriteOracleTable
abbrev ReadWriteMemoryRelation := @TwistShout.ReadWriteMemoryRelation
abbrev rwReadValueAtCycle := @TwistShout.rwReadValueAtCycle
abbrev rwReadCheckExpression := @TwistShout.rwReadCheckExpression
abbrev IncrementRelation := @TwistShout.IncrementRelation
abbrev addressEqWeight := @TwistShout.addressEqWeight
abbrev writeCheckValueAtCycle := @TwistShout.writeCheckValueAtCycle
abbrev writeCheckExpression := @TwistShout.writeCheckExpression
abbrev twistReadCheckFinalRoundTarget := @TwistShout.twistReadCheckFinalRoundTarget
abbrev writeCheckFinalRoundTarget := @TwistShout.writeCheckFinalRoundTarget

theorem timeTableMLE_at_bitCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  (val : TimeTable (K := K) d m t)
  (rAddress : Fin d → Point (K := K) m)
  (j : CycleCube t) :
  timeTableMLE (K := K) val rAddress (bitVec (K := K) j) =
    tableMLE (K := K) (fun k => val k j) rAddress :=
  TwistShout.timeTableMLE_at_bitCycle (K := K) val rAddress j

theorem timeTableMLE_at_bitPoint
  {K : Type*} [Field K]
  {d m t : Nat}
  (val : TimeTable (K := K) d m t)
  (a : Address d m)
  (j : CycleCube t) :
  timeTableMLE (K := K) val (bitAddress (K := K) a) (bitVec (K := K) j) =
    val a j :=
  TwistShout.timeTableMLE_at_bitPoint (K := K) val a j

theorem addressEqWeight_at_bitAddress
  {K : Type*} [Field K]
  {d m : Nat}
  (queryAddress : Fin d → Point (K := K) m)
  (a : Address d m) :
  addressEqWeight (K := K) queryAddress (bitAddress (K := K) a) =
    addressWeight (K := K) queryAddress a :=
  TwistShout.addressEqWeight_at_bitAddress (K := K) queryAddress a

theorem ReadWriteMemoryRelation.readWriteOracleTable_eq
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : TimeTable (K := K) d m t}
  {addr : CycleCube t → Address d m}
  {rv : CycleCube t → K}
  (hRel : ReadWriteMemoryRelation (K := K) val addr rv) :
  rv = readWriteOracleTable (K := K) val addr :=
  TwistShout.ReadWriteMemoryRelation.readWriteOracleTable_eq (K := K) hRel

theorem ReadWriteMemoryRelation.mle_eq_readWriteOracleTable
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : TimeTable (K := K) d m t}
  {addr : CycleCube t → Address d m}
  {rv : CycleCube t → K}
  (hRel : ReadWriteMemoryRelation (K := K) val addr rv)
  (rCycle : Point (K := K) t) :
  mle (K := K) rv rCycle = mle (K := K) (readWriteOracleTable (K := K) val addr) rCycle :=
  TwistShout.ReadWriteMemoryRelation.mle_eq_readWriteOracleTable (K := K) hRel rCycle

theorem ValidAddressColumns.rwReadValueAtCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (val : TimeTable (K := K) d m t)
  (j : CycleCube t) :
  rwReadValueAtCycle (K := K) ra val j = val (addr j) j :=
  TwistShout.ValidAddressColumns.rwReadValueAtCycle (K := K) hvalid val j

theorem ValidAddressColumns.rwReadCheckExpression
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (val : TimeTable (K := K) d m t)
  (rCycle : Point (K := K) t) :
  mle (K := K) (readWriteOracleTable (K := K) val addr) rCycle =
    rwReadCheckExpression (K := K) ra val rCycle :=
  TwistShout.ValidAddressColumns.rwReadCheckExpression (K := K) hvalid val rCycle

theorem ReadWriteMemoryRelation.readCheckIdentity
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : TimeTable (K := K) d m t}
  {addr : CycleCube t → Address d m}
  {rv : CycleCube t → K}
  {ra : AddressColumns (K := K) d m t}
  (hRel : ReadWriteMemoryRelation (K := K) val addr rv)
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (rCycle : Point (K := K) t) :
  mle (K := K) rv rCycle = rwReadCheckExpression (K := K) ra val rCycle :=
  TwistShout.ReadWriteMemoryRelation.readCheckIdentity (K := K) hRel hvalid rCycle

theorem ReadWriteMemoryRelation.readCheckAtBitCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : TimeTable (K := K) d m t}
  {addr : CycleCube t → Address d m}
  {rv : CycleCube t → K}
  {ra : AddressColumns (K := K) d m t}
  (hRel : ReadWriteMemoryRelation (K := K) val addr rv)
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (j : CycleCube t) :
  rv j = rwReadCheckExpression (K := K) ra val (bitVec (K := K) j) :=
  TwistShout.ReadWriteMemoryRelation.readCheckAtBitCycle (K := K) hRel hvalid j

theorem IncrementRelation.writeCheckIdentity
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : TimeTable (K := K) d m t}
  {wa : AddressColumns (K := K) d m t}
  {wv : CycleCube t → K}
  {inc : TimeTable (K := K) d m t}
  (hRel : IncrementRelation (K := K) val wa wv inc)
  (queryAddress : Fin d → Point (K := K) m)
  (queryCycle : Point (K := K) t) :
  timeTableMLE (K := K) inc queryAddress queryCycle =
    writeCheckExpression (K := K) queryAddress queryCycle wa wv val :=
  TwistShout.IncrementRelation.writeCheckIdentity (K := K) hRel queryAddress queryCycle

theorem IncrementRelation.writeCheckAtBitPoint
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : TimeTable (K := K) d m t}
  {wa : AddressColumns (K := K) d m t}
  {wv : CycleCube t → K}
  {inc : TimeTable (K := K) d m t}
  (hRel : IncrementRelation (K := K) val wa wv inc)
  (a : Address d m)
  (j : CycleCube t) :
  inc a j =
    writeCheckExpression (K := K) (bitAddress (K := K) a) (bitVec (K := K) j) wa wv val :=
  TwistShout.IncrementRelation.writeCheckAtBitPoint (K := K) hRel a j

theorem ValidAddressColumns.writeCheckValueAtCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  {wa : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) wa addr)
  (queryAddress : Fin d → Point (K := K) m)
  (wv : CycleCube t → K)
  (val : TimeTable (K := K) d m t)
  (j : CycleCube t) :
  writeCheckValueAtCycle (K := K) queryAddress wa wv val j =
    (wv j - val (addr j) j) * addressWeight (K := K) queryAddress (addr j) :=
  TwistShout.ValidAddressColumns.writeCheckValueAtCycle (K := K) hvalid queryAddress wv val j

theorem ValidAddressColumns.writeCheckExpression
  {K : Type*} [Field K]
  {d m t : Nat}
  {wa : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) wa addr)
  (queryAddress : Fin d → Point (K := K) m)
  (queryCycle : Point (K := K) t)
  (wv : CycleCube t → K)
  (val : TimeTable (K := K) d m t) :
  writeCheckExpression (K := K) queryAddress queryCycle wa wv val =
    ∑ j : CycleCube t,
      ((wv j - val (addr j) j) * addressWeight (K := K) queryAddress (addr j)) *
        chiWeight (K := K) queryCycle j :=
  TwistShout.ValidAddressColumns.writeCheckExpression
    (K := K) hvalid queryAddress queryCycle wv val

theorem ValidAddressColumns.incrementEquationAtCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  {wa : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  {val : TimeTable (K := K) d m t}
  {wv : CycleCube t → K}
  {inc : TimeTable (K := K) d m t}
  (hvalid : ValidAddressColumns (K := K) wa addr)
  (hRel : IncrementRelation (K := K) val wa wv inc)
  (k : Address d m)
  (j : CycleCube t) :
  inc k j = if k = addr j then wv j - val k j else 0 :=
  TwistShout.ValidAddressColumns.incrementEquationAtCycle (K := K) hvalid hRel k j

theorem ValidAddressColumns.incrementAtWrittenAddress
  {K : Type*} [Field K]
  {d m t : Nat}
  {wa : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  {val : TimeTable (K := K) d m t}
  {wv : CycleCube t → K}
  {inc : TimeTable (K := K) d m t}
  (hvalid : ValidAddressColumns (K := K) wa addr)
  (hRel : IncrementRelation (K := K) val wa wv inc)
  (j : CycleCube t) :
  inc (addr j) j = wv j - val (addr j) j :=
  TwistShout.ValidAddressColumns.incrementAtWrittenAddress (K := K) hvalid hRel j

theorem ValidAddressColumns.incrementAtOtherAddress
  {K : Type*} [Field K]
  {d m t : Nat}
  {wa : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  {val : TimeTable (K := K) d m t}
  {wv : CycleCube t → K}
  {inc : TimeTable (K := K) d m t}
  (hvalid : ValidAddressColumns (K := K) wa addr)
  (hRel : IncrementRelation (K := K) val wa wv inc)
  (k : Address d m)
  (j : CycleCube t)
  (hk : k ≠ addr j) :
  inc k j = 0 :=
  TwistShout.ValidAddressColumns.incrementAtOtherAddress (K := K) hvalid hRel k j hk

theorem ValidAddressColumns.twistReadCheckFinalRoundTarget_atBooleanPoint
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (val : TimeTable (K := K) d m t)
  (queryCycle : Point (K := K) t)
  (j : CycleCube t) :
  twistReadCheckFinalRoundTarget (K := K) queryCycle ra val
    (bitAddress (K := K) (addr j)) (bitVec (K := K) j) =
    chiWeight (K := K) queryCycle j * val (addr j) j :=
  TwistShout.ValidAddressColumns.twistReadCheckFinalRoundTarget_atBooleanPoint
    (K := K) hvalid val queryCycle j

theorem ValidAddressColumns.writeCheckFinalRoundTarget_atBooleanPoint
  {K : Type*} [Field K]
  {d m t : Nat}
  {wa : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) wa addr)
  (wv : CycleCube t → K)
  (val : TimeTable (K := K) d m t)
  (queryAddress : Fin d → Point (K := K) m)
  (queryCycle : Point (K := K) t)
  (j : CycleCube t) :
  writeCheckFinalRoundTarget (K := K) queryAddress queryCycle wa wv val
    (bitAddress (K := K) (addr j)) (bitVec (K := K) j) =
    addressWeight (K := K) queryAddress (addr j) *
      chiWeight (K := K) queryCycle j *
      (wv j - val (addr j) j) :=
  TwistShout.ValidAddressColumns.writeCheckFinalRoundTarget_atBooleanPoint
    (K := K) hvalid wv val queryAddress queryCycle j

end TwistCoreInterface

end TwistShout

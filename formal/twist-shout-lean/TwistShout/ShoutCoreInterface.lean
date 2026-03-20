import TwistShout.ShoutCore

/-!
# ShoutCoreInterface

Thin theorem-facing boundary for the Shout read-only memory-checking protocol.
-/

namespace TwistShout

namespace ShoutCoreInterface

abbrev DigitCube := @TwistShout.DigitCube
abbrev CycleCube := @TwistShout.CycleCube
abbrev Point := @TwistShout.Point
abbrev Address := @TwistShout.Address
abbrev AddressColumns := @TwistShout.AddressColumns
abbrev ValidAddressColumns := @TwistShout.ValidAddressColumns
abbrev PublicTable := @TwistShout.PublicTable
abbrev mle := @TwistShout.mle
abbrev bitAddress := @TwistShout.bitAddress
abbrev addressWeight := @TwistShout.addressWeight
abbrev tableMLE := @TwistShout.tableMLE
abbrev readOracleTable := @TwistShout.readOracleTable
abbrev ReadOnlyMemoryRelation := @TwistShout.ReadOnlyMemoryRelation
abbrev columnMLEAtCycle := @TwistShout.columnMLEAtCycle
abbrev columnMLE := @TwistShout.columnMLE
abbrev readValueAtCycle := @TwistShout.readValueAtCycle
abbrev readCheckExpression := @TwistShout.readCheckExpression
abbrev readCheckFinalRoundTarget := @TwistShout.readCheckFinalRoundTarget

theorem ReadOnlyMemoryRelation.readOracleTable_eq
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : PublicTable (K := K) d m}
  {addr : CycleCube t → Address d m}
  {rv : CycleCube t → K}
  (hRel : ReadOnlyMemoryRelation (K := K) val addr rv) :
  rv = readOracleTable (K := K) val addr :=
  TwistShout.ReadOnlyMemoryRelation.readOracleTable_eq (K := K) hRel

theorem ReadOnlyMemoryRelation.mle_eq_readOracleTable
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : PublicTable (K := K) d m}
  {addr : CycleCube t → Address d m}
  {rv : CycleCube t → K}
  (hRel : ReadOnlyMemoryRelation (K := K) val addr rv)
  (rCycle : Point (K := K) t) :
  mle (K := K) rv rCycle = mle (K := K) (readOracleTable (K := K) val addr) rCycle :=
  TwistShout.ReadOnlyMemoryRelation.mle_eq_readOracleTable (K := K) hRel rCycle

open Classical in
theorem addressWeight_eq_delta_at_bitAddress
  {K : Type*} [Field K]
  {d m : Nat}
  (a k : Address d m) :
  addressWeight (K := K) (bitAddress (K := K) a) k = (if k = a then 1 else 0) :=
  TwistShout.addressWeight_eq_delta_at_bitAddress (K := K) a k

open Classical in
theorem tableMLE_at_bitAddress
  {K : Type*} [Field K]
  {d m : Nat}
  (val : PublicTable (K := K) d m)
  (a : Address d m) :
  tableMLE (K := K) val (bitAddress (K := K) a) = val a :=
  TwistShout.tableMLE_at_bitAddress (K := K) val a

theorem ValidAddressColumns.columnMLEAtCycle_eq_chiWeight
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (i : Fin d)
  (rAddress : Point (K := K) m)
  (j : CycleCube t) :
  columnMLEAtCycle (K := K) ra i rAddress j = chiWeight (K := K) rAddress (addr j i) :=
  TwistShout.ValidAddressColumns.columnMLEAtCycle_eq_chiWeight (K := K) hvalid i rAddress j

theorem ValidAddressColumns.columnMLE_at_bitCycle_eq_chiWeight
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (i : Fin d)
  (rAddress : Point (K := K) m)
  (j : CycleCube t) :
  columnMLE (K := K) ra i rAddress (bitVec (K := K) j) =
    chiWeight (K := K) rAddress (addr j i) :=
  TwistShout.ValidAddressColumns.columnMLE_at_bitCycle_eq_chiWeight (K := K) hvalid i rAddress j

theorem ValidAddressColumns.columnMLE_bitAddress_bitCycle_eq_one
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (i : Fin d)
  (j : CycleCube t) :
  columnMLE (K := K) ra i (bitVec (K := K) (addr j i)) (bitVec (K := K) j) = 1 :=
  TwistShout.ValidAddressColumns.columnMLE_bitAddress_bitCycle_eq_one (K := K) hvalid i j

theorem ValidAddressColumns.readValueAtCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (val : PublicTable (K := K) d m)
  (j : CycleCube t) :
  readValueAtCycle (K := K) ra val j = val (addr j) :=
  TwistShout.ValidAddressColumns.readValueAtCycle (K := K) hvalid val j

theorem ValidAddressColumns.readCheckExpression
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (val : PublicTable (K := K) d m)
  (rCycle : Point (K := K) t) :
  mle (K := K) (readOracleTable (K := K) val addr) rCycle =
    readCheckExpression (K := K) ra val rCycle :=
  TwistShout.ValidAddressColumns.readCheckExpression (K := K) hvalid val rCycle

theorem ReadOnlyMemoryRelation.readCheckIdentity
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : PublicTable (K := K) d m}
  {addr : CycleCube t → Address d m}
  {rv : CycleCube t → K}
  {ra : AddressColumns (K := K) d m t}
  (hRel : ReadOnlyMemoryRelation (K := K) val addr rv)
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (rCycle : Point (K := K) t) :
  mle (K := K) rv rCycle = readCheckExpression (K := K) ra val rCycle :=
  TwistShout.ReadOnlyMemoryRelation.readCheckIdentity (K := K) hRel hvalid rCycle

theorem ReadOnlyMemoryRelation.readCheckAtBitCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : PublicTable (K := K) d m}
  {addr : CycleCube t → Address d m}
  {rv : CycleCube t → K}
  {ra : AddressColumns (K := K) d m t}
  (hRel : ReadOnlyMemoryRelation (K := K) val addr rv)
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (j : CycleCube t) :
  rv j = readCheckExpression (K := K) ra val (bitVec (K := K) j) :=
  TwistShout.ReadOnlyMemoryRelation.readCheckAtBitCycle (K := K) hRel hvalid j

theorem ValidAddressColumns.readCheckFinalRoundTarget_atBooleanPoint
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (val : PublicTable (K := K) d m)
  (queryCycle : Point (K := K) t)
  (j : CycleCube t) :
  readCheckFinalRoundTarget (K := K) queryCycle ra val
    (bitAddress (K := K) (addr j)) (bitVec (K := K) j) =
    chiWeight (K := K) queryCycle j * val (addr j) :=
  TwistShout.ValidAddressColumns.readCheckFinalRoundTarget_atBooleanPoint (K := K) hvalid val queryCycle j

end ShoutCoreInterface

end TwistShout

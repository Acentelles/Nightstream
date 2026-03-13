import TwistShout.FastShoutSmallMemory

/-!
# FastShoutSmallMemoryInterface

Thin theorem-facing boundary for the Section 6 fast Shout prover on small memories.
-/

namespace TwistShout

namespace FastShoutSmallMemoryInterface

abbrev DigitCube := @TwistShout.DigitCube
abbrev CycleCube := @TwistShout.CycleCube
abbrev Address := @TwistShout.Address
abbrev AddressColumns := @TwistShout.AddressColumns
abbrev ValidAddressColumns := @TwistShout.ValidAddressColumns
abbrev PublicTable := @TwistShout.PublicTable
abbrev ReadOnlyMemoryRelation := @TwistShout.ReadOnlyMemoryRelation
abbrev readOracleTable := @TwistShout.readOracleTable
abbrev readCheckExpression := @TwistShout.readCheckExpression
abbrev addressOracleTable := @TwistShout.addressOracleTable
abbrev addressValueExpression := @TwistShout.addressValueExpression
abbrev addressSpaceSize := @TwistShout.addressSpaceSize
abbrev digitSpaceSize := @TwistShout.digitSpaceSize
abbrev cycleSpaceSize := @TwistShout.cycleSpaceSize
abbrev aggregatedCycleWeight := @TwistShout.aggregatedCycleWeight
abbrev aggregatedReadCheck := @TwistShout.aggregatedReadCheck
abbrev batchedTable := @TwistShout.batchedTable
abbrev coreShoutD1Cost := @TwistShout.coreShoutD1Cost
abbrev coreShoutGeneralCost := @TwistShout.coreShoutGeneralCost
abbrev coreShoutGeneralImprovedCost := @TwistShout.coreShoutGeneralImprovedCost
abbrev coreShoutLeadingCost := @TwistShout.coreShoutLeadingCost
abbrev booleanityFirstRoundsCost := @TwistShout.booleanityFirstRoundsCost
abbrev booleanityUnoptimizedLeadingCost := @TwistShout.booleanityUnoptimizedLeadingCost
abbrev booleanityOptimizedLeadingCost := @TwistShout.booleanityOptimizedLeadingCost
abbrev batchedRafAdditionalCost := @TwistShout.batchedRafAdditionalCost
abbrev combinedShoutLeadingCost := @TwistShout.combinedShoutLeadingCost

theorem tableMLE_batchedTable
  {K : Type*} [Field K]
  {d m : Nat}
  (z : K)
  (val : PublicTable (K := K) d m)
  (rAddress : Fin d → Point (K := K) m) :
  tableMLE (K := K) (batchedTable (K := K) z val) rAddress =
    tableMLE (K := K) val rAddress +
      z * tableMLE (K := K) (addressValue (K := K)) rAddress :=
  TwistShout.tableMLE_batchedTable (K := K) z val rAddress

theorem ValidAddressColumns.aggregatedCycleWeight_eq_selectorSum
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (rCycle : Point (K := K) t)
  (k : Address d m) :
  aggregatedCycleWeight (K := K) addr rCycle k =
    ∑ j : CycleCube t, chiWeight (K := K) rCycle j * addressSelector (K := K) ra k j :=
  TwistShout.ValidAddressColumns.aggregatedCycleWeight_eq_selectorSum (K := K) hvalid rCycle k

theorem aggregatedReadCheck_eq_mle_readOracleTable
  {K : Type*} [Field K]
  {d m t : Nat}
  (val : PublicTable (K := K) d m)
  (addr : CycleCube t → Address d m)
  (rCycle : Point (K := K) t) :
  aggregatedReadCheck (K := K) val addr rCycle =
    mle (K := K) (readOracleTable (K := K) val addr) rCycle :=
  TwistShout.aggregatedReadCheck_eq_mle_readOracleTable (K := K) val addr rCycle

theorem ValidAddressColumns.aggregatedReadCheck_eq_readCheckExpression
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (val : PublicTable (K := K) d m)
  (rCycle : Point (K := K) t) :
  aggregatedReadCheck (K := K) val addr rCycle =
    readCheckExpression (K := K) ra val rCycle :=
  TwistShout.ValidAddressColumns.aggregatedReadCheck_eq_readCheckExpression
    (K := K) hvalid val rCycle

theorem ReadOnlyMemoryRelation.aggregatedReadCheckIdentity
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : PublicTable (K := K) d m}
  {addr : CycleCube t → Address d m}
  {rv : CycleCube t → K}
  (hRel : ReadOnlyMemoryRelation (K := K) val addr rv)
  (rCycle : Point (K := K) t) :
  mle (K := K) rv rCycle =
    aggregatedReadCheck (K := K) val addr rCycle :=
  TwistShout.ReadOnlyMemoryRelation.aggregatedReadCheckIdentity (K := K) hRel rCycle

theorem ReadOnlyMemoryRelation.aggregatedReadCheck_eq_readCheckExpression
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
  TwistShout.ReadOnlyMemoryRelation.aggregatedReadCheck_eq_readCheckExpression
    (K := K) hRel hvalid rCycle

theorem readOracleTable_batchedTable
  {K : Type*} [Field K]
  {d m t : Nat}
  (z : K)
  (val : PublicTable (K := K) d m)
  (addr : CycleCube t → Address d m) :
  readOracleTable (K := K) (batchedTable (K := K) z val) addr =
    fun j => readOracleTable (K := K) val addr j + z * addressOracleTable (K := K) addr j :=
  TwistShout.readOracleTable_batchedTable (K := K) z val addr

theorem aggregatedReadCheck_batchedTable
  {K : Type*} [Field K]
  {d m t : Nat}
  (z : K)
  (val : PublicTable (K := K) d m)
  (addr : CycleCube t → Address d m)
  (rCycle : Point (K := K) t) :
  aggregatedReadCheck (K := K) (batchedTable (K := K) z val) addr rCycle =
    aggregatedReadCheck (K := K) val addr rCycle +
      z * mle (K := K) (addressOracleTable (K := K) addr) rCycle :=
  TwistShout.aggregatedReadCheck_batchedTable (K := K) z val addr rCycle

theorem ValidAddressColumns.aggregatedReadCheck_batchedTable
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (z : K)
  (val : PublicTable (K := K) d m)
  (rCycle : Point (K := K) t) :
  aggregatedReadCheck (K := K) (batchedTable (K := K) z val) addr rCycle =
    aggregatedReadCheck (K := K) val addr rCycle +
      z * addressValueExpression (K := K) ra rCycle :=
  TwistShout.ValidAddressColumns.aggregatedReadCheck_batchedTable (K := K) hvalid z val rCycle

theorem ValidAddressColumns.readCheckExpression_batchedTable
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (z : K)
  (val : PublicTable (K := K) d m)
  (rCycle : Point (K := K) t) :
  readCheckExpression (K := K) ra (batchedTable (K := K) z val) rCycle =
    readCheckExpression (K := K) ra val rCycle +
      z * addressValueExpression (K := K) ra rCycle :=
  TwistShout.ValidAddressColumns.readCheckExpression_batchedTable (K := K) hvalid z val rCycle

theorem addressSpaceSize_eq_digitSpaceSize_pow
  (d m : Nat) :
  addressSpaceSize d m = digitSpaceSize m ^ d :=
  TwistShout.addressSpaceSize_eq_digitSpaceSize_pow d m

@[simp] theorem addressSpaceSize_one
  (m : Nat) :
  addressSpaceSize 1 m = digitSpaceSize m :=
  TwistShout.addressSpaceSize_one m

theorem combinedShoutLeadingCost_eq_sum
  (d t : Nat) :
  combinedShoutLeadingCost d t =
    coreShoutLeadingCost d t + booleanityOptimizedLeadingCost d t :=
  TwistShout.combinedShoutLeadingCost_eq_sum d t

end FastShoutSmallMemoryInterface

end TwistShout

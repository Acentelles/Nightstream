import TwistShout.FastTwistProver

/-!
# FastTwistProverInterface

Thin theorem-facing boundary for the Section 8 fast Twist prover.
-/

namespace TwistShout

namespace FastTwistProverInterface

abbrev DigitCube := @TwistShout.DigitCube
abbrev CycleCube := @TwistShout.CycleCube
abbrev Address := @TwistShout.Address
abbrev AddressColumns := @TwistShout.AddressColumns
abbrev ValidAddressColumns := @TwistShout.ValidAddressColumns
abbrev Point := @TwistShout.Point
abbrev bitVec := @TwistShout.bitVec
abbrev bitAddress := @TwistShout.bitAddress
abbrev mle := @TwistShout.mle
abbrev addressWeight := @TwistShout.addressWeight
abbrev addressSelector := @TwistShout.addressSelector
abbrev TimeTable := @TwistShout.TimeTable
abbrev reconstructedTimeTable := @TwistShout.reconstructedTimeTable
abbrev writeCheckExpression := @TwistShout.writeCheckExpression
abbrev twistAddressSpaceSize := @TwistShout.twistAddressSpaceSize
abbrev twistCycleSpaceSize := @TwistShout.twistCycleSpaceSize
abbrev valEvaluationIncTableCost := @TwistShout.valEvaluationIncTableCost
abbrev valEvaluationOptimizedLeadingCost := @TwistShout.valEvaluationOptimizedLeadingCost
abbrev valEvaluationOptimizedTotalCost := @TwistShout.valEvaluationOptimizedTotalCost
abbrev writeValueAtCycle := @TwistShout.writeValueAtCycle
abbrev writeValueExpression := @TwistShout.writeValueExpression
abbrev writeWvAtCycle := @TwistShout.writeWvAtCycle
abbrev writeWvExpression := @TwistShout.writeWvExpression
abbrev weightedWriteOracleTable := @TwistShout.weightedWriteOracleTable
abbrev weightedVirtualOracleTable := @TwistShout.weightedVirtualOracleTable
abbrev localD1ReadCheckLeadingCost := @TwistShout.localD1ReadCheckLeadingCost
abbrev localD1WriteCheckLeadingCost := @TwistShout.localD1WriteCheckLeadingCost
abbrev localD1TwistLeadingCost := @TwistShout.localD1TwistLeadingCost
abbrev localD1TwistTotalCost := @TwistShout.localD1TwistTotalCost
abbrev localWriteAccessCost := @TwistShout.localWriteAccessCost
abbrev localReadAccessCost := @TwistShout.localReadAccessCost
abbrev localWorstWriteAccessCost := @TwistShout.localWorstWriteAccessCost
abbrev localWorstReadAccessCost := @TwistShout.localWorstReadAccessCost
abbrev alternativeReadCheckLeadingCost := @TwistShout.alternativeReadCheckLeadingCost
abbrev alternativeWriteCheckLeadingCost := @TwistShout.alternativeWriteCheckLeadingCost
abbrev alternativeTwistLeadingCost := @TwistShout.alternativeTwistLeadingCost
abbrev alternativeTwistComponentLeadingCost := @TwistShout.alternativeTwistComponentLeadingCost
abbrev alternativeTwistTotalCost := @TwistShout.alternativeTwistTotalCost

theorem writeCheckValueAtCycle_eq_writeWvAtCycle_sub_writeValueAtCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  (queryAddress : Fin d → Point (K := K) m)
  (wa : AddressColumns (K := K) d m t)
  (wv : CycleCube t → K)
  (val : TimeTable (K := K) d m t)
  (j : CycleCube t) :
  TwistShout.writeCheckValueAtCycle (K := K) queryAddress wa wv val j =
    writeWvAtCycle (K := K) queryAddress wa wv j -
      writeValueAtCycle (K := K) queryAddress wa val j :=
  TwistShout.writeCheckValueAtCycle_eq_writeWvAtCycle_sub_writeValueAtCycle
    (K := K) queryAddress wa wv val j

theorem writeCheckExpression_eq_writeWvExpression_sub_writeValueExpression
  {K : Type*} [Field K]
  {d m t : Nat}
  (queryAddress : Fin d → Point (K := K) m)
  (queryCycle : Point (K := K) t)
  (wa : AddressColumns (K := K) d m t)
  (wv : CycleCube t → K)
  (val : TimeTable (K := K) d m t) :
  writeCheckExpression (K := K) queryAddress queryCycle wa wv val =
    writeWvExpression (K := K) queryAddress queryCycle wa wv -
      writeValueExpression (K := K) queryAddress queryCycle wa val :=
  TwistShout.writeCheckExpression_eq_writeWvExpression_sub_writeValueExpression
    (K := K) queryAddress queryCycle wa wv val

theorem ValidAddressColumns.writeWvAtCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  {wa : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) wa addr)
  (queryAddress : Fin d → Point (K := K) m)
  (wv : CycleCube t → K)
  (j : CycleCube t) :
  writeWvAtCycle (K := K) queryAddress wa wv j =
    weightedWriteOracleTable (K := K) queryAddress wv addr j :=
  TwistShout.ValidAddressColumns.writeWvAtCycle (K := K) hvalid queryAddress wv j

theorem ValidAddressColumns.writeValueAtCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  {wa : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) wa addr)
  (queryAddress : Fin d → Point (K := K) m)
  (val : TimeTable (K := K) d m t)
  (j : CycleCube t) :
  writeValueAtCycle (K := K) queryAddress wa val j =
    weightedVirtualOracleTable (K := K) queryAddress val addr j :=
  TwistShout.ValidAddressColumns.writeValueAtCycle (K := K) hvalid queryAddress val j

theorem ValidAddressColumns.writeWvExpression
  {K : Type*} [Field K]
  {d m t : Nat}
  {wa : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) wa addr)
  (queryAddress : Fin d → Point (K := K) m)
  (queryCycle : Point (K := K) t)
  (wv : CycleCube t → K) :
  writeWvExpression (K := K) queryAddress queryCycle wa wv =
    mle (K := K) (weightedWriteOracleTable (K := K) queryAddress wv addr) queryCycle :=
  TwistShout.ValidAddressColumns.writeWvExpression
    (K := K) hvalid queryAddress queryCycle wv

theorem ValidAddressColumns.writeValueExpression
  {K : Type*} [Field K]
  {d m t : Nat}
  {wa : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) wa addr)
  (queryAddress : Fin d → Point (K := K) m)
  (queryCycle : Point (K := K) t)
  (val : TimeTable (K := K) d m t) :
  writeValueExpression (K := K) queryAddress queryCycle wa val =
    mle (K := K) (weightedVirtualOracleTable (K := K) queryAddress val addr) queryCycle :=
  TwistShout.ValidAddressColumns.writeValueExpression
    (K := K) hvalid queryAddress queryCycle val

theorem ValidAddressColumns.writeCheckExpression_eq_mle_sub_mle
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
    mle (K := K) (weightedWriteOracleTable (K := K) queryAddress wv addr) queryCycle -
      mle (K := K) (weightedVirtualOracleTable (K := K) queryAddress val addr) queryCycle :=
  TwistShout.ValidAddressColumns.writeCheckExpression_eq_mle_sub_mle
    (K := K) hvalid queryAddress queryCycle wv val

theorem localD1TwistLeadingCost_eq_sum
  (m t : Nat) :
  localD1TwistLeadingCost m t =
    valEvaluationOptimizedLeadingCost t +
      localD1ReadCheckLeadingCost m t +
      localD1WriteCheckLeadingCost m t :=
  TwistShout.localD1TwistLeadingCost_eq_sum m t

theorem localD1TwistTotalCost_eq_sum
  (m t : Nat) :
  localD1TwistTotalCost m t =
    valEvaluationIncTableCost 1 m +
      valEvaluationOptimizedLeadingCost t +
      localD1ReadCheckLeadingCost m t +
      localD1WriteCheckLeadingCost m t :=
  TwistShout.localD1TwistTotalCost_eq_sum m t

theorem localWriteAccessCost_le_worstCase
  {i m : Nat}
  (h : i ≤ m) :
  localWriteAccessCost i ≤ localWorstWriteAccessCost m :=
  TwistShout.localWriteAccessCost_le_worstCase h

theorem localReadAccessCost_le_worstCase
  {i m : Nat}
  (h : i ≤ m) :
  localReadAccessCost i ≤ localWorstReadAccessCost m :=
  TwistShout.localReadAccessCost_le_worstCase h

theorem alternativeTwistLeadingComponentSum_eq_paperPlusGap
  (d m t : Nat) :
  valEvaluationOptimizedLeadingCost t +
      alternativeReadCheckLeadingCost d m t +
      alternativeWriteCheckLeadingCost d m t =
    alternativeTwistLeadingCost d m t + 3 * twistCycleSpaceSize t :=
  TwistShout.alternativeTwistLeadingComponentSum_eq_paperPlusGap d m t

theorem alternativeTwistComponentLeadingCost_eq_sum
  (d m t : Nat) :
  alternativeTwistComponentLeadingCost d m t =
    valEvaluationOptimizedLeadingCost t +
      alternativeReadCheckLeadingCost d m t +
      alternativeWriteCheckLeadingCost d m t :=
  TwistShout.alternativeTwistComponentLeadingCost_eq_sum d m t

theorem alternativeTwistComponentLeadingCost_eq_paperPlusGap
  (d m t : Nat) :
  alternativeTwistComponentLeadingCost d m t =
    alternativeTwistLeadingCost d m t + 3 * twistCycleSpaceSize t :=
  TwistShout.alternativeTwistComponentLeadingCost_eq_paperPlusGap d m t

theorem alternativeTwistTotalCost_eq_inc_plus_componentLeading
  (d m t : Nat) :
  alternativeTwistTotalCost d m t =
    valEvaluationIncTableCost d m + alternativeTwistComponentLeadingCost d m t :=
  TwistShout.alternativeTwistTotalCost_eq_inc_plus_componentLeading d m t

theorem alternativeTwistTotalCost_eq_paperPlusGapAndSetup
  (d m t : Nat) :
  alternativeTwistTotalCost d m t =
    valEvaluationIncTableCost d m +
      alternativeTwistLeadingCost d m t +
      3 * twistCycleSpaceSize t :=
  TwistShout.alternativeTwistTotalCost_eq_paperPlusGapAndSetup d m t

theorem alternativeTwistLeadingCost_d1
  (m t : Nat) :
  alternativeTwistLeadingCost 1 m t =
    (5 * m + 10) * twistCycleSpaceSize t :=
  TwistShout.alternativeTwistLeadingCost_d1 m t

end FastTwistProverInterface

end TwistShout

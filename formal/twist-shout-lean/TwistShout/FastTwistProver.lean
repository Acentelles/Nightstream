import TwistShout.TwistValueEval

/-!
# FastTwistProver

Section 8 prover-specialization identities and cost summaries for Twist.
-/

open scoped BigOperators

namespace TwistShout

section

variable {K : Type*} [Field K]

/-- Boolean-cube memory size `K = 2^(d * m)`. -/
def twistAddressSpaceSize (d m : Nat) : Nat :=
  2 ^ (d * m)

/-- Cycle count `T = 2^t`. -/
def twistCycleSpaceSize (t : Nat) : Nat :=
  2 ^ t

/-- Section 8.1 setup cost for evaluating `Inc~(r_address, j')` over all cycles. -/
def valEvaluationIncTableCost (d m : Nat) : Nat :=
  2 * twistAddressSpaceSize d m

/-- Section 8.1 optimized leading term for the `Val~`-evaluation sum-check. -/
def valEvaluationOptimizedLeadingCost (t : Nat) : Nat :=
  4 * twistCycleSpaceSize t

/-- Section 8.1 optimized total cost `2K + 4T`. -/
def valEvaluationOptimizedTotalCost (d m t : Nat) : Nat :=
  valEvaluationIncTableCost d m + valEvaluationOptimizedLeadingCost t

/-- Cycle-local `Val` contribution in the write-checking sum-check. -/
def writeValueAtCycle {d m t : Nat}
    (queryAddress : Fin d → Point (K := K) m)
    (wa : AddressColumns (K := K) d m t)
    (val : TimeTable (K := K) d m t)
    (j : CycleCube t) : K :=
  ∑ k : Address d m, val k j * addressWeight (K := K) queryAddress k *
    addressSelector (K := K) wa k j

/-- Write-checking sum-check contribution involving only `Val(k, j)`. -/
def writeValueExpression {d m t : Nat}
    (queryAddress : Fin d → Point (K := K) m)
    (queryCycle : Point (K := K) t)
    (wa : AddressColumns (K := K) d m t)
    (val : TimeTable (K := K) d m t) : K :=
  ∑ j : CycleCube t, writeValueAtCycle (K := K) queryAddress wa val j *
    chiWeight (K := K) queryCycle j

/-- Cycle-local `wv(j)` contribution in the write-checking sum-check. -/
def writeWvAtCycle {d m t : Nat}
    (queryAddress : Fin d → Point (K := K) m)
    (wa : AddressColumns (K := K) d m t)
    (wv : CycleCube t → K)
    (j : CycleCube t) : K :=
  ∑ k : Address d m, wv j * addressWeight (K := K) queryAddress k *
    addressSelector (K := K) wa k j

/-- Write-checking sum-check contribution involving only `wv(j)`. -/
def writeWvExpression {d m t : Nat}
    (queryAddress : Fin d → Point (K := K) m)
    (queryCycle : Point (K := K) t)
    (wa : AddressColumns (K := K) d m t)
    (wv : CycleCube t → K) : K :=
  ∑ j : CycleCube t, writeWvAtCycle (K := K) queryAddress wa wv j *
    chiWeight (K := K) queryCycle j

/-- The write-address-weighted write-value oracle appearing in Expression (77)/(78). -/
def weightedWriteOracleTable {d m t : Nat}
    (queryAddress : Fin d → Point (K := K) m)
    (wv : CycleCube t → K)
    (addr : CycleCube t → Address d m) :
    CycleCube t → K :=
  fun j => wv j * addressWeight (K := K) queryAddress (addr j)

/-- The write-address-weighted virtual-value oracle appearing in Expression (78). -/
def weightedVirtualOracleTable {d m t : Nat}
    (queryAddress : Fin d → Point (K := K) m)
    (val : TimeTable (K := K) d m t)
    (addr : CycleCube t → Address d m) :
    CycleCube t → K :=
  fun j => val (addr j) j * addressWeight (K := K) queryAddress (addr j)

/-- Section 8.2.2 local-algorithm read-check cost for `d = 1`. -/
def localD1ReadCheckLeadingCost (m t : Nat) : Nat :=
  (4 * m + 6) * twistCycleSpaceSize t

/-- Section 8.2.4 additional write-check cost for the local `d = 1` algorithm. -/
def localD1WriteCheckLeadingCost (m t : Nat) : Nat :=
  (3 * m + 5) * twistCycleSpaceSize t

/-- Section 8.3 leading-term summary for the local `d = 1` Twist prover. -/
def localD1TwistLeadingCost (m t : Nat) : Nat :=
  (7 * m + 15) * twistCycleSpaceSize t

/-- Total local `d = 1` cost including the `2K` setup term for `Val~` evaluation. -/
def localD1TwistTotalCost (m t : Nat) : Nat :=
  valEvaluationOptimizedTotalCost 1 m t + localD1ReadCheckLeadingCost m t +
    localD1WriteCheckLeadingCost m t

/-- Refined Section 8.2.3 per-write cost for a `2^i`-local write. -/
def localWriteAccessCost (i : Nat) : Nat :=
  4 * i

/-- Refined Section 8.2.3 per-read cost for a `2^i`-local read. -/
def localReadAccessCost (i : Nat) : Nat :=
  3 * i

/-- Worst-case per-write local-algorithm cost when `log K = m`. -/
def localWorstWriteAccessCost (m : Nat) : Nat :=
  4 * m

/-- Worst-case per-read local-algorithm cost when `log K = m`. -/
def localWorstReadAccessCost (m : Nat) : Nat :=
  3 * m

/-- Section 8.2.5 leading cost for the alternative read-check algorithm. -/
def alternativeReadCheckLeadingCost (d m t : Nat) : Nat :=
  (3 * d * m + d * d + 2 * d + 1) * twistCycleSpaceSize t

/-- Section 8.2.5 additional write-check cost for the alternative algorithm. -/
def alternativeWriteCheckLeadingCost (d m t : Nat) : Nat :=
  (2 * d * m + d * d + 2 * d + 2) * twistCycleSpaceSize t

/-- Published Section 8.3 leading-term summary for the alternative Twist prover. -/
def alternativeTwistLeadingCost (d m t : Nat) : Nat :=
  (5 * d * m + 2 * d * d + 4 * d + 4) * twistCycleSpaceSize t

/-- Leading cost obtained by summing the Section 8.1 and 8.2.5 component bounds. -/
def alternativeTwistComponentLeadingCost (d m t : Nat) : Nat :=
  valEvaluationOptimizedLeadingCost t + alternativeReadCheckLeadingCost d m t +
    alternativeWriteCheckLeadingCost d m t

/-- Total alternative-algorithm cost including the `2K` setup term for `Val~` evaluation. -/
def alternativeTwistTotalCost (d m t : Nat) : Nat :=
  valEvaluationIncTableCost d m + alternativeTwistComponentLeadingCost d m t

theorem writeCheckValueAtCycle_eq_writeWvAtCycle_sub_writeValueAtCycle
    {d m t : Nat}
    (queryAddress : Fin d → Point (K := K) m)
    (wa : AddressColumns (K := K) d m t)
    (wv : CycleCube t → K)
    (val : TimeTable (K := K) d m t)
    (j : CycleCube t) :
    writeCheckValueAtCycle (K := K) queryAddress wa wv val j =
      writeWvAtCycle (K := K) queryAddress wa wv j -
        writeValueAtCycle (K := K) queryAddress wa val j := by
  unfold writeCheckValueAtCycle writeWvAtCycle writeValueAtCycle
  calc
    ∑ k : Address d m,
        (wv j - val k j) * addressWeight (K := K) queryAddress k *
          addressSelector (K := K) wa k j
      = ∑ k : Address d m,
          (wv j * addressWeight (K := K) queryAddress k * addressSelector (K := K) wa k j -
            val k j * addressWeight (K := K) queryAddress k *
              addressSelector (K := K) wa k j) := by
            apply Finset.sum_congr rfl
            intro k _
            ring
    _ = (∑ k : Address d m,
          wv j * addressWeight (K := K) queryAddress k * addressSelector (K := K) wa k j) -
          ∑ k : Address d m,
            val k j * addressWeight (K := K) queryAddress k *
              addressSelector (K := K) wa k j := by
            rw [Finset.sum_sub_distrib]
    _ = writeWvAtCycle (K := K) queryAddress wa wv j -
          writeValueAtCycle (K := K) queryAddress wa val j := by
            rfl

theorem writeCheckExpression_eq_writeWvExpression_sub_writeValueExpression
    {d m t : Nat}
    (queryAddress : Fin d → Point (K := K) m)
    (queryCycle : Point (K := K) t)
    (wa : AddressColumns (K := K) d m t)
    (wv : CycleCube t → K)
    (val : TimeTable (K := K) d m t) :
    writeCheckExpression (K := K) queryAddress queryCycle wa wv val =
      writeWvExpression (K := K) queryAddress queryCycle wa wv -
        writeValueExpression (K := K) queryAddress queryCycle wa val := by
  unfold writeCheckExpression writeWvExpression writeValueExpression
  calc
    ∑ j : CycleCube t,
        writeCheckValueAtCycle (K := K) queryAddress wa wv val j *
          chiWeight (K := K) queryCycle j
      = ∑ j : CycleCube t,
          ((writeWvAtCycle (K := K) queryAddress wa wv j -
              writeValueAtCycle (K := K) queryAddress wa val j) *
            chiWeight (K := K) queryCycle j) := by
            apply Finset.sum_congr rfl
            intro j _
            rw [writeCheckValueAtCycle_eq_writeWvAtCycle_sub_writeValueAtCycle
              (K := K) queryAddress wa wv val j]
    _ = ∑ j : CycleCube t,
          (writeWvAtCycle (K := K) queryAddress wa wv j * chiWeight (K := K) queryCycle j -
            writeValueAtCycle (K := K) queryAddress wa val j *
              chiWeight (K := K) queryCycle j) := by
            apply Finset.sum_congr rfl
            intro j _
            ring
    _ = (∑ j : CycleCube t,
          writeWvAtCycle (K := K) queryAddress wa wv j * chiWeight (K := K) queryCycle j) -
          ∑ j : CycleCube t,
            writeValueAtCycle (K := K) queryAddress wa val j *
              chiWeight (K := K) queryCycle j := by
            rw [Finset.sum_sub_distrib]
    _ = writeWvExpression (K := K) queryAddress queryCycle wa wv -
          writeValueExpression (K := K) queryAddress queryCycle wa val := by
            rfl

theorem ValidAddressColumns.writeWvAtCycle
    {d m t : Nat}
    {wa : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) wa addr)
  (queryAddress : Fin d → Point (K := K) m)
  (wv : CycleCube t → K)
  (j : CycleCube t) :
    writeWvAtCycle (K := K) queryAddress wa wv j =
      weightedWriteOracleTable (K := K) queryAddress wv addr j := by
  unfold TwistShout.writeWvAtCycle weightedWriteOracleTable
  exact hvalid.selectorWeightedSumAtCycle
    (w := fun k => wv j * addressWeight (K := K) queryAddress k)
    j

theorem ValidAddressColumns.writeValueAtCycle
    {d m t : Nat}
    {wa : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) wa addr)
  (queryAddress : Fin d → Point (K := K) m)
  (val : TimeTable (K := K) d m t)
  (j : CycleCube t) :
    writeValueAtCycle (K := K) queryAddress wa val j =
      weightedVirtualOracleTable (K := K) queryAddress val addr j := by
  unfold TwistShout.writeValueAtCycle weightedVirtualOracleTable
  exact hvalid.selectorWeightedSumAtCycle
    (w := fun k => val k j * addressWeight (K := K) queryAddress k)
    j

theorem ValidAddressColumns.writeWvExpression
    {d m t : Nat}
    {wa : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) wa addr)
  (queryAddress : Fin d → Point (K := K) m)
  (queryCycle : Point (K := K) t)
  (wv : CycleCube t → K) :
    writeWvExpression (K := K) queryAddress queryCycle wa wv =
      mle (K := K) (weightedWriteOracleTable (K := K) queryAddress wv addr) queryCycle := by
  unfold TwistShout.writeWvExpression mle
  apply Finset.sum_congr rfl
  intro j _
  rw [hvalid.writeWvAtCycle (queryAddress := queryAddress) (wv := wv) (j := j)]

theorem ValidAddressColumns.writeValueExpression
    {d m t : Nat}
    {wa : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) wa addr)
  (queryAddress : Fin d → Point (K := K) m)
  (queryCycle : Point (K := K) t)
  (val : TimeTable (K := K) d m t) :
    writeValueExpression (K := K) queryAddress queryCycle wa val =
      mle (K := K) (weightedVirtualOracleTable (K := K) queryAddress val addr) queryCycle := by
  unfold TwistShout.writeValueExpression mle
  apply Finset.sum_congr rfl
  intro j _
  rw [hvalid.writeValueAtCycle (queryAddress := queryAddress) (val := val) (j := j)]

theorem ValidAddressColumns.writeCheckExpression_eq_mle_sub_mle
    {d m t : Nat}
    {wa : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) wa addr)
    (queryAddress : Fin d → Point (K := K) m)
    (queryCycle : Point (K := K) t)
    (wv : CycleCube t → K)
    (val : TimeTable (K := K) d m t) :
    TwistShout.writeCheckExpression (K := K) queryAddress queryCycle wa wv val =
      mle (K := K) (weightedWriteOracleTable (K := K) queryAddress wv addr) queryCycle -
        mle (K := K) (weightedVirtualOracleTable (K := K) queryAddress val addr) queryCycle := by
  rw [writeCheckExpression_eq_writeWvExpression_sub_writeValueExpression
    (K := K) queryAddress queryCycle wa wv val]
  rw [hvalid.writeWvExpression
    (queryAddress := queryAddress) (queryCycle := queryCycle) (wv := wv)]
  rw [hvalid.writeValueExpression
    (queryAddress := queryAddress) (queryCycle := queryCycle) (val := val)]

theorem localD1TwistLeadingCost_eq_sum
    (m t : Nat) :
    localD1TwistLeadingCost m t =
      valEvaluationOptimizedLeadingCost t +
        localD1ReadCheckLeadingCost m t +
        localD1WriteCheckLeadingCost m t := by
  unfold localD1TwistLeadingCost valEvaluationOptimizedLeadingCost
  unfold localD1ReadCheckLeadingCost localD1WriteCheckLeadingCost
  unfold twistCycleSpaceSize
  ring

theorem localD1TwistTotalCost_eq_sum
    (m t : Nat) :
    localD1TwistTotalCost m t =
      valEvaluationIncTableCost 1 m +
        valEvaluationOptimizedLeadingCost t +
        localD1ReadCheckLeadingCost m t +
        localD1WriteCheckLeadingCost m t := by
  unfold localD1TwistTotalCost valEvaluationOptimizedTotalCost
  ring

theorem localWriteAccessCost_le_worstCase
    {i m : Nat}
    (h : i ≤ m) :
    localWriteAccessCost i ≤ localWorstWriteAccessCost m := by
  unfold localWriteAccessCost localWorstWriteAccessCost
  omega

theorem localReadAccessCost_le_worstCase
    {i m : Nat}
    (h : i ≤ m) :
    localReadAccessCost i ≤ localWorstReadAccessCost m := by
  unfold localReadAccessCost localWorstReadAccessCost
  omega

theorem alternativeTwistLeadingComponentSum_eq_paperPlusGap
    (d m t : Nat) :
    valEvaluationOptimizedLeadingCost t +
        alternativeReadCheckLeadingCost d m t +
        alternativeWriteCheckLeadingCost d m t =
      alternativeTwistLeadingCost d m t + 3 * twistCycleSpaceSize t := by
  unfold alternativeTwistLeadingCost valEvaluationOptimizedLeadingCost
  unfold alternativeReadCheckLeadingCost alternativeWriteCheckLeadingCost
  unfold twistCycleSpaceSize
  ring_nf

theorem alternativeTwistComponentLeadingCost_eq_sum
    (d m t : Nat) :
    alternativeTwistComponentLeadingCost d m t =
      valEvaluationOptimizedLeadingCost t +
        alternativeReadCheckLeadingCost d m t +
        alternativeWriteCheckLeadingCost d m t := by
  unfold alternativeTwistComponentLeadingCost
  rfl

theorem alternativeTwistComponentLeadingCost_eq_paperPlusGap
    (d m t : Nat) :
    alternativeTwistComponentLeadingCost d m t =
      alternativeTwistLeadingCost d m t + 3 * twistCycleSpaceSize t := by
  rw [alternativeTwistComponentLeadingCost_eq_sum]
  exact alternativeTwistLeadingComponentSum_eq_paperPlusGap d m t

theorem alternativeTwistTotalCost_eq_inc_plus_componentLeading
    (d m t : Nat) :
    alternativeTwistTotalCost d m t =
      valEvaluationIncTableCost d m + alternativeTwistComponentLeadingCost d m t := by
  unfold alternativeTwistTotalCost
  rfl

theorem alternativeTwistTotalCost_eq_paperPlusGapAndSetup
    (d m t : Nat) :
    alternativeTwistTotalCost d m t =
      valEvaluationIncTableCost d m +
        alternativeTwistLeadingCost d m t +
        3 * twistCycleSpaceSize t := by
  rw [alternativeTwistTotalCost_eq_inc_plus_componentLeading]
  rw [alternativeTwistComponentLeadingCost_eq_paperPlusGap]
  ring

theorem alternativeTwistLeadingCost_d1
    (m t : Nat) :
    alternativeTwistLeadingCost 1 m t =
      (5 * m + 10) * twistCycleSpaceSize t := by
  unfold alternativeTwistLeadingCost
  ring

end

end TwistShout

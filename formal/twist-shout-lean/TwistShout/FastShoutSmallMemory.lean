import TwistShout.ShoutCore

/-!
# FastShoutSmallMemory

Section 6 small-memory prover identities for Shout.
-/

open scoped BigOperators

namespace TwistShout

section

variable {K : Type*} [Field K]

/-- Boolean-cube address space size `K = 2^(d * m)`. -/
def addressSpaceSize (d m : Nat) : Nat :=
  2 ^ (d * m)

/-- Per-digit address width `K^(1/d) = 2^m`. -/
def digitSpaceSize (m : Nat) : Nat :=
  2 ^ m

/-- Cycle space size `T = 2^t`. -/
def cycleSpaceSize (t : Nat) : Nat :=
  2 ^ t

/-- Section 6's aggregated cycle-weight array `C[k]`. -/
def aggregatedCycleWeight {d m t : Nat}
    (addr : CycleCube t → Address d m)
    (rCycle : Point (K := K) t)
    (k : Address d m) : K :=
  ∑ j : CycleCube t, chiWeight (K := K) rCycle j * tupleCubeOneHot (K := K) (addr j) k

/-- Section 6's grouped read-check expression `Σ_k A[k] * C[k]`. -/
def aggregatedReadCheck {d m t : Nat}
    (val : PublicTable (K := K) d m)
    (addr : CycleCube t → Address d m)
    (rCycle : Point (K := K) t) : K :=
  ∑ k : Address d m, val k * aggregatedCycleWeight (K := K) addr rCycle k

/-- Batched table used to combine the core read-check with `\tilde{raf}` evaluation. -/
def batchedTable {d m : Nat}
    (z : K)
    (val : PublicTable (K := K) d m) :
    PublicTable (K := K) d m :=
  fun k => val k + z * addressValue (K := K) k

/-- Theorem 5 cost `3K + T`, expressed with the package's `m`/`t` parameters. -/
def coreShoutD1Cost (m t : Nat) : Nat :=
  3 * addressSpaceSize 1 m + cycleSpaceSize t

/-- Theorem 6 cost `(d^2 + d + 1)T + 5K`. -/
def coreShoutGeneralCost (d m t : Nat) : Nat :=
  (d * d + d + 1) * cycleSpaceSize t + 5 * addressSpaceSize d m

/-- Theorem 6 improved cost `(d^2 + 1)T + 5K` when `K^(1/d) = o(T)`. -/
def coreShoutGeneralImprovedCost (d m t : Nat) : Nat :=
  (d * d + 1) * cycleSpaceSize t + 5 * addressSpaceSize d m

/-- Section 6.4 leading-term summary for the core Shout prover. -/
def coreShoutLeadingCost (d t : Nat) : Nat :=
  (d * d + 2) * cycleSpaceSize t

/-- Section 6.3 first-round Booleanity cost `T + (2 log K + 4) K^(1/d)`. -/
def booleanityFirstRoundsCost (d m t : Nat) : Nat :=
  cycleSpaceSize t + (2 * (d * m) + 4) * digitSpaceSize m

/-- Section 6.3 leading term before the further optimizations. -/
def booleanityUnoptimizedLeadingCost (d t : Nat) : Nat :=
  (5 * d + 2) * cycleSpaceSize t

/-- Section 6.3 optimized leading term `3dT`. -/
def booleanityOptimizedLeadingCost (d t : Nat) : Nat :=
  (3 * d) * cycleSpaceSize t

/-- Additional work for batching `\tilde{raf}` with the core read-check. -/
def batchedRafAdditionalCost (d m : Nat) : Nat :=
  addressSpaceSize d m

/-- Section 6.4 combined leading-term summary `(d^2 + 3d + 2)T`. -/
def combinedShoutLeadingCost (d t : Nat) : Nat :=
  (d * d + 3 * d + 2) * cycleSpaceSize t

theorem tableMLE_batchedTable
    {d m : Nat}
    (z : K)
    (val : PublicTable (K := K) d m)
    (rAddress : Fin d → Point (K := K) m) :
    tableMLE (K := K) (batchedTable (K := K) z val) rAddress =
      tableMLE (K := K) val rAddress +
        z * tableMLE (K := K) (addressValue (K := K)) rAddress := by
  unfold tableMLE batchedTable
  calc
    ∑ k : Address d m,
        (val k + z * addressValue (K := K) k) * addressWeight (K := K) rAddress k
      = ∑ k : Address d m,
          (val k * addressWeight (K := K) rAddress k +
            z * (addressValue (K := K) k * addressWeight (K := K) rAddress k)) := by
            apply Finset.sum_congr rfl
            intro k _
            ring
    _ = (∑ k : Address d m, val k * addressWeight (K := K) rAddress k) +
          ∑ k : Address d m,
            z * (addressValue (K := K) k * addressWeight (K := K) rAddress k) := by
            rw [Finset.sum_add_distrib]
    _ = (∑ k : Address d m, val k * addressWeight (K := K) rAddress k) +
          z * ∑ k : Address d m,
            addressValue (K := K) k * addressWeight (K := K) rAddress k := by
            simp [Finset.mul_sum]
    _ = tableMLE (K := K) val rAddress +
          z * ∑ k : Address d m,
            addressValue (K := K) k * addressWeight (K := K) rAddress k := by
            rfl
    _ = tableMLE (K := K) val rAddress +
          z * tableMLE (K := K) (addressValue (K := K)) rAddress := by
            rfl

theorem ValidAddressColumns.aggregatedCycleWeight_eq_selectorSum
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (rCycle : Point (K := K) t)
    (k : Address d m) :
    aggregatedCycleWeight (K := K) addr rCycle k =
      ∑ j : CycleCube t, chiWeight (K := K) rCycle j * addressSelector (K := K) ra k j := by
  unfold aggregatedCycleWeight
  apply Finset.sum_congr rfl
  intro j _
  rw [hvalid.addressSelector_eq_tupleCubeOneHot (k := k) (j := j)]

open Classical in
theorem aggregatedReadCheck_eq_mle_readOracleTable
    {d m t : Nat}
    (val : PublicTable (K := K) d m)
    (addr : CycleCube t → Address d m)
    (rCycle : Point (K := K) t) :
    aggregatedReadCheck (K := K) val addr rCycle =
      mle (K := K) (readOracleTable (K := K) val addr) rCycle := by
  unfold aggregatedReadCheck aggregatedCycleWeight mle readOracleTable
  calc
    ∑ k : Address d m, val k *
        ∑ j : CycleCube t, chiWeight (K := K) rCycle j * tupleCubeOneHot (K := K) (addr j) k
      = ∑ k : Address d m, ∑ j : CycleCube t,
          val k * (chiWeight (K := K) rCycle j * tupleCubeOneHot (K := K) (addr j) k) := by
            apply Finset.sum_congr rfl
            intro k _
            rw [Finset.mul_sum]
    _ = ∑ j : CycleCube t, ∑ k : Address d m,
          val k * (chiWeight (K := K) rCycle j * tupleCubeOneHot (K := K) (addr j) k) := by
            rw [Finset.sum_comm]
    _ = ∑ j : CycleCube t, chiWeight (K := K) rCycle j *
          ∑ k : Address d m, val k * tupleCubeOneHot (K := K) (addr j) k := by
            apply Finset.sum_congr rfl
            intro j _
            calc
              ∑ k : Address d m,
                  val k * (chiWeight (K := K) rCycle j * tupleCubeOneHot (K := K) (addr j) k)
                = ∑ k : Address d m,
                    chiWeight (K := K) rCycle j *
                      (val k * tupleCubeOneHot (K := K) (addr j) k) := by
                        apply Finset.sum_congr rfl
                        intro k _
                        ring
              _ = chiWeight (K := K) rCycle j *
                    ∑ k : Address d m, val k * tupleCubeOneHot (K := K) (addr j) k := by
                      rw [Finset.mul_sum]
    _ = ∑ j : CycleCube t, chiWeight (K := K) rCycle j * val (addr j) := by
            apply Finset.sum_congr rfl
            intro j _
            rw [weightedSum_tupleCubeOneHot (K := K) (w := val) (z := addr j)]
    _ = ∑ j : CycleCube t, readOracleTable (K := K) val addr j * chiWeight (K := K) rCycle j := by
            apply Finset.sum_congr rfl
            intro j _
            simp [readOracleTable, mul_comm]
    _ = mle (K := K) (readOracleTable (K := K) val addr) rCycle := by
            rfl

theorem ValidAddressColumns.aggregatedReadCheck_eq_readCheckExpression
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (val : PublicTable (K := K) d m)
    (rCycle : Point (K := K) t) :
    aggregatedReadCheck (K := K) val addr rCycle =
      TwistShout.readCheckExpression (K := K) ra val rCycle := by
  calc
    aggregatedReadCheck (K := K) val addr rCycle
      = mle (K := K) (readOracleTable (K := K) val addr) rCycle :=
          aggregatedReadCheck_eq_mle_readOracleTable (K := K) val addr rCycle
    _ = TwistShout.readCheckExpression (K := K) ra val rCycle :=
          hvalid.readCheckExpression val rCycle

theorem ReadOnlyMemoryRelation.aggregatedReadCheckIdentity
    {d m t : Nat}
    {val : PublicTable (K := K) d m}
    {addr : CycleCube t → Address d m}
    {rv : CycleCube t → K}
    (hRel : ReadOnlyMemoryRelation (K := K) val addr rv)
    (rCycle : Point (K := K) t) :
    mle (K := K) rv rCycle =
      aggregatedReadCheck (K := K) val addr rCycle := by
  calc
    mle (K := K) rv rCycle
      = mle (K := K) (readOracleTable (K := K) val addr) rCycle :=
          hRel.mle_eq_readOracleTable rCycle
    _ = aggregatedReadCheck (K := K) val addr rCycle := by
          symm
          exact aggregatedReadCheck_eq_mle_readOracleTable (K := K) val addr rCycle

theorem ReadOnlyMemoryRelation.aggregatedReadCheck_eq_readCheckExpression
    {d m t : Nat}
    {val : PublicTable (K := K) d m}
    {addr : CycleCube t → Address d m}
    {rv : CycleCube t → K}
    {ra : AddressColumns (K := K) d m t}
    (hRel : ReadOnlyMemoryRelation (K := K) val addr rv)
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (rCycle : Point (K := K) t) :
    mle (K := K) rv rCycle = TwistShout.readCheckExpression (K := K) ra val rCycle := by
  calc
    mle (K := K) rv rCycle
      = aggregatedReadCheck (K := K) val addr rCycle :=
          hRel.aggregatedReadCheckIdentity rCycle
    _ = TwistShout.readCheckExpression (K := K) ra val rCycle :=
          hvalid.aggregatedReadCheck_eq_readCheckExpression val rCycle

theorem readOracleTable_batchedTable
    {d m t : Nat}
    (z : K)
    (val : PublicTable (K := K) d m)
    (addr : CycleCube t → Address d m) :
    readOracleTable (K := K) (batchedTable (K := K) z val) addr =
      fun j => readOracleTable (K := K) val addr j + z * addressOracleTable (K := K) addr j := by
  funext j
  rfl

theorem aggregatedReadCheck_batchedTable
    {d m t : Nat}
    (z : K)
    (val : PublicTable (K := K) d m)
    (addr : CycleCube t → Address d m)
    (rCycle : Point (K := K) t) :
    aggregatedReadCheck (K := K) (batchedTable (K := K) z val) addr rCycle =
      aggregatedReadCheck (K := K) val addr rCycle +
        z * mle (K := K) (addressOracleTable (K := K) addr) rCycle := by
  unfold aggregatedReadCheck batchedTable
  calc
    ∑ k : Address d m,
        (val k + z * addressValue (K := K) k) * aggregatedCycleWeight (K := K) addr rCycle k
      = ∑ k : Address d m,
          (val k * aggregatedCycleWeight (K := K) addr rCycle k +
            z * (addressValue (K := K) k * aggregatedCycleWeight (K := K) addr rCycle k)) := by
            apply Finset.sum_congr rfl
            intro k _
            ring
    _ = (∑ k : Address d m, val k * aggregatedCycleWeight (K := K) addr rCycle k) +
          ∑ k : Address d m,
            z * (addressValue (K := K) k * aggregatedCycleWeight (K := K) addr rCycle k) := by
            rw [Finset.sum_add_distrib]
    _ = (∑ k : Address d m, val k * aggregatedCycleWeight (K := K) addr rCycle k) +
          z * ∑ k : Address d m,
            addressValue (K := K) k * aggregatedCycleWeight (K := K) addr rCycle k := by
            simp [Finset.mul_sum]
    _ = aggregatedReadCheck (K := K) val addr rCycle +
          z * ∑ k : Address d m,
            addressValue (K := K) k * aggregatedCycleWeight (K := K) addr rCycle k := by
            rfl
    _ = aggregatedReadCheck (K := K) val addr rCycle +
          z * aggregatedReadCheck (K := K) (val := addressValue (K := K)) addr rCycle := by
            rfl
    _ = aggregatedReadCheck (K := K) val addr rCycle +
          z * mle (K := K) (readOracleTable (K := K) (addressValue (K := K)) addr) rCycle := by
            rw [aggregatedReadCheck_eq_mle_readOracleTable
              (K := K) (val := addressValue (K := K)) (addr := addr) (rCycle := rCycle)]
    _ = aggregatedReadCheck (K := K) val addr rCycle +
          z * mle (K := K) (addressOracleTable (K := K) addr) rCycle := by
            rfl

theorem ValidAddressColumns.aggregatedReadCheck_batchedTable
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (z : K)
    (val : PublicTable (K := K) d m)
    (rCycle : Point (K := K) t) :
    aggregatedReadCheck (K := K) (batchedTable (K := K) z val) addr rCycle =
      aggregatedReadCheck (K := K) val addr rCycle +
        z * TwistShout.addressValueExpression (K := K) ra rCycle := by
  calc
    aggregatedReadCheck (K := K) (batchedTable (K := K) z val) addr rCycle
      = aggregatedReadCheck (K := K) val addr rCycle +
          z * mle (K := K) (addressOracleTable (K := K) addr) rCycle :=
          TwistShout.aggregatedReadCheck_batchedTable (K := K) z val addr rCycle
    _ = aggregatedReadCheck (K := K) val addr rCycle +
          z * TwistShout.addressValueExpression (K := K) ra rCycle := by
          rw [hvalid.addressValueExpression rCycle]

theorem ValidAddressColumns.readCheckExpression_batchedTable
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (z : K)
    (val : PublicTable (K := K) d m)
    (rCycle : Point (K := K) t) :
    TwistShout.readCheckExpression (K := K) ra (batchedTable (K := K) z val) rCycle =
      TwistShout.readCheckExpression (K := K) ra val rCycle +
        z * TwistShout.addressValueExpression (K := K) ra rCycle := by
  calc
    TwistShout.readCheckExpression (K := K) ra (batchedTable (K := K) z val) rCycle
      = aggregatedReadCheck (K := K) (batchedTable (K := K) z val) addr rCycle := by
          symm
          exact hvalid.aggregatedReadCheck_eq_readCheckExpression
            (val := batchedTable (K := K) z val) (rCycle := rCycle)
    _ = aggregatedReadCheck (K := K) val addr rCycle +
          z * TwistShout.addressValueExpression (K := K) ra rCycle :=
          hvalid.aggregatedReadCheck_batchedTable z val rCycle
    _ = TwistShout.readCheckExpression (K := K) ra val rCycle +
          z * TwistShout.addressValueExpression (K := K) ra rCycle := by
          rw [hvalid.aggregatedReadCheck_eq_readCheckExpression (val := val) (rCycle := rCycle)]

theorem addressSpaceSize_eq_digitSpaceSize_pow
    (d m : Nat) :
    addressSpaceSize d m = digitSpaceSize m ^ d := by
  unfold addressSpaceSize digitSpaceSize
  rw [Nat.mul_comm, ← pow_mul]

@[simp] theorem addressSpaceSize_one
    (m : Nat) :
    addressSpaceSize 1 m = digitSpaceSize m := by
  unfold addressSpaceSize digitSpaceSize
  simp

theorem combinedShoutLeadingCost_eq_sum
    (d t : Nat) :
    combinedShoutLeadingCost d t =
      coreShoutLeadingCost d t + booleanityOptimizedLeadingCost d t := by
  unfold combinedShoutLeadingCost coreShoutLeadingCost booleanityOptimizedLeadingCost cycleSpaceSize
  ring

end

end TwistShout

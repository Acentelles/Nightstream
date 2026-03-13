import TwistShout.ShoutCore

/-!
# TwistCore

Paper-faithful core read-write memory identities for Twist.
-/

open scoped BigOperators

namespace TwistShout

section

variable {K : Type*} [Field K]

/-- Time-indexed memory table `Val(k, j)`. -/
abbrev TimeTable (d m t : Nat) := Address d m → CycleCube t → K

/-- Fix a cycle and view the time-indexed memory table as a public address table. -/
def timeTableAtCycle {d m t : Nat}
    (val : TimeTable (K := K) d m t)
    (j : CycleCube t) : PublicTable (K := K) d m :=
  fun k => val k j

/-- Nested multilinear extension of a time-indexed memory table. -/
def timeTableMLE {d m t : Nat}
    (val : TimeTable (K := K) d m t)
    (rAddress : Fin d → Point (K := K) m)
    (rCycle : Point (K := K) t) : K :=
  mle (K := K)
    (fun j : CycleCube t => tableMLE (K := K) (timeTableAtCycle (K := K) val j) rAddress)
    rCycle

/-- The honest read-value oracle `rv(j) = Val(addr(j), j)`. -/
def readWriteOracleTable {d m t : Nat}
    (val : TimeTable (K := K) d m t)
    (addr : CycleCube t → Address d m) :
    CycleCube t → K :=
  fun j => val (addr j) j

/-- Pointwise read-write memory relation for read values. -/
def ReadWriteMemoryRelation {d m t : Nat}
    (val : TimeTable (K := K) d m t)
    (addr : CycleCube t → Address d m)
    (rv : CycleCube t → K) : Prop :=
  ∀ j, rv j = val (addr j) j

/-- Cycle-local read relation `Σ_k ra(k,j) * Val(k,j)`. -/
def rwReadValueAtCycle {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (val : TimeTable (K := K) d m t)
    (j : CycleCube t) : K :=
  ∑ k : Address d m, val k j * addressSelector (K := K) ra k j

/-- Twist read-checking sum-check target (Equation (8)/(33)). -/
def rwReadCheckExpression {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (val : TimeTable (K := K) d m t)
    (rCycle : Point (K := K) t) : K :=
  ∑ j : CycleCube t, rwReadValueAtCycle (K := K) ra val j * chiWeight (K := K) rCycle j

/-- Pointwise increment relation from Equation (9)/(34). -/
def IncrementRelation {d m t : Nat}
    (val : TimeTable (K := K) d m t)
    (wa : AddressColumns (K := K) d m t)
    (wv : CycleCube t → K)
    (inc : TimeTable (K := K) d m t) : Prop :=
  ∀ k j, inc k j = addressSelector (K := K) wa k j * (wv j - val k j)

/-- Address-equality weight `eq(queryAddress, boundAddress)` across all address digits. -/
def addressEqWeight {d m : Nat}
    (queryAddress boundAddress : Fin d → Point (K := K) m) : K :=
  ∏ i, eqPoly (queryAddress i) (boundAddress i)

/-- Cycle-local write relation `Σ_k eq(queryAddress,k) * wa(k,j) * (wv(j)-Val(k,j))`. -/
def writeCheckValueAtCycle {d m t : Nat}
    (queryAddress : Fin d → Point (K := K) m)
    (wa : AddressColumns (K := K) d m t)
    (wv : CycleCube t → K)
    (val : TimeTable (K := K) d m t)
    (j : CycleCube t) : K :=
  ∑ k : Address d m, (wv j - val k j) * addressWeight (K := K) queryAddress k *
    addressSelector (K := K) wa k j

/-- Twist write-checking sum-check target (Equation (12)/(34)). -/
def writeCheckExpression {d m t : Nat}
    (queryAddress : Fin d → Point (K := K) m)
    (queryCycle : Point (K := K) t)
    (wa : AddressColumns (K := K) d m t)
    (wv : CycleCube t → K)
    (val : TimeTable (K := K) d m t) : K :=
  ∑ j : CycleCube t, writeCheckValueAtCycle (K := K) queryAddress wa wv val j *
    chiWeight (K := K) queryCycle j

/-- Honest last-round verifier target for the Twist read-checking sum-check. -/
def twistReadCheckFinalRoundTarget {d m t : Nat}
    (queryCycle : Point (K := K) t)
    (ra : AddressColumns (K := K) d m t)
    (val : TimeTable (K := K) d m t)
    (rAddress : Fin d → Point (K := K) m)
    (boundCycle : Point (K := K) t) : K :=
  eqPoly queryCycle boundCycle *
    (∏ i, columnMLE (K := K) ra i (rAddress i) boundCycle) *
    timeTableMLE (K := K) val rAddress boundCycle

/-- Honest last-round verifier target for the Twist write-checking sum-check. -/
def writeCheckFinalRoundTarget {d m t : Nat}
    (queryAddress : Fin d → Point (K := K) m)
    (queryCycle : Point (K := K) t)
    (wa : AddressColumns (K := K) d m t)
    (wv : CycleCube t → K)
    (val : TimeTable (K := K) d m t)
    (boundAddress : Fin d → Point (K := K) m)
    (boundCycle : Point (K := K) t) : K :=
  addressEqWeight (K := K) queryAddress boundAddress *
    eqPoly queryCycle boundCycle *
    (∏ i, columnMLE (K := K) wa i (boundAddress i) boundCycle) *
    (mle (K := K) wv boundCycle - timeTableMLE (K := K) val boundAddress boundCycle)

theorem timeTableMLE_at_bitCycle
    {d m t : Nat}
    (val : TimeTable (K := K) d m t)
    (rAddress : Fin d → Point (K := K) m)
    (j : CycleCube t) :
    timeTableMLE (K := K) val rAddress (bitVec (K := K) j) =
      tableMLE (K := K) (timeTableAtCycle (K := K) val j) rAddress := by
  unfold timeTableMLE
  exact mle_at_bitVec (K := K)
    (f := fun j' : CycleCube t =>
      tableMLE (K := K) (timeTableAtCycle (K := K) val j') rAddress)
    j

theorem timeTableMLE_at_bitPoint
    {d m t : Nat}
    (val : TimeTable (K := K) d m t)
    (a : Address d m)
    (j : CycleCube t) :
    timeTableMLE (K := K) val (bitAddress (K := K) a) (bitVec (K := K) j) =
      val a j := by
  rw [timeTableMLE_at_bitCycle (K := K) (val := val) (rAddress := bitAddress (K := K) a) (j := j)]
  exact tableMLE_at_bitAddress (K := K) (val := timeTableAtCycle (K := K) val j) a

theorem addressEqWeight_at_bitAddress
    {d m : Nat}
    (queryAddress : Fin d → Point (K := K) m)
    (a : Address d m) :
    addressEqWeight (K := K) queryAddress (bitAddress (K := K) a) =
      addressWeight (K := K) queryAddress a := by
  unfold addressEqWeight addressWeight bitAddress chiWeight
  rfl

omit [Field K] in
theorem ReadWriteMemoryRelation.readWriteOracleTable_eq
    {d m t : Nat}
    {val : TimeTable (K := K) d m t}
    {addr : CycleCube t → Address d m}
    {rv : CycleCube t → K}
    (hRel : ReadWriteMemoryRelation (K := K) val addr rv) :
    rv = readWriteOracleTable (K := K) val addr := by
  funext j
  exact hRel j

theorem ReadWriteMemoryRelation.mle_eq_readWriteOracleTable
    {d m t : Nat}
    {val : TimeTable (K := K) d m t}
    {addr : CycleCube t → Address d m}
    {rv : CycleCube t → K}
    (hRel : ReadWriteMemoryRelation (K := K) val addr rv)
    (rCycle : Point (K := K) t) :
    mle (K := K) rv rCycle = mle (K := K) (readWriteOracleTable (K := K) val addr) rCycle := by
  rw [hRel.readWriteOracleTable_eq]

theorem ValidAddressColumns.rwReadValueAtCycle
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (val : TimeTable (K := K) d m t)
    (j : CycleCube t) :
    rwReadValueAtCycle (K := K) ra val j = val (addr j) j := by
  exact hvalid.selectorWeightedSumAtCycle (w := fun k => val k j) j

theorem ValidAddressColumns.rwReadCheckExpression
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (val : TimeTable (K := K) d m t)
    (rCycle : Point (K := K) t) :
    mle (K := K) (readWriteOracleTable (K := K) val addr) rCycle =
      rwReadCheckExpression (K := K) ra val rCycle := by
  unfold mle readWriteOracleTable TwistShout.rwReadCheckExpression
  apply Finset.sum_congr rfl
  intro j _
  rw [hvalid.rwReadValueAtCycle (val := val) (j := j)]

theorem ReadWriteMemoryRelation.readCheckIdentity
    {d m t : Nat}
    {val : TimeTable (K := K) d m t}
    {addr : CycleCube t → Address d m}
    {rv : CycleCube t → K}
    {ra : AddressColumns (K := K) d m t}
    (hRel : ReadWriteMemoryRelation (K := K) val addr rv)
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (rCycle : Point (K := K) t) :
    mle (K := K) rv rCycle = rwReadCheckExpression (K := K) ra val rCycle := by
  rw [hRel.mle_eq_readWriteOracleTable rCycle]
  exact hvalid.rwReadCheckExpression val rCycle

theorem ReadWriteMemoryRelation.readCheckAtBitCycle
    {d m t : Nat}
    {val : TimeTable (K := K) d m t}
    {addr : CycleCube t → Address d m}
    {rv : CycleCube t → K}
    {ra : AddressColumns (K := K) d m t}
    (hRel : ReadWriteMemoryRelation (K := K) val addr rv)
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (j : CycleCube t) :
    rv j = rwReadCheckExpression (K := K) ra val (bitVec (K := K) j) := by
  calc
    rv j = mle (K := K) rv (bitVec (K := K) j) := by
      symm
      exact mle_at_bitVec (K := K) rv j
    _ = rwReadCheckExpression (K := K) ra val (bitVec (K := K) j) := by
      exact hRel.readCheckIdentity hvalid (bitVec (K := K) j)

theorem IncrementRelation.writeCheckIdentity
    {d m t : Nat}
    {val : TimeTable (K := K) d m t}
    {wa : AddressColumns (K := K) d m t}
    {wv : CycleCube t → K}
    {inc : TimeTable (K := K) d m t}
    (hRel : IncrementRelation (K := K) val wa wv inc)
    (queryAddress : Fin d → Point (K := K) m)
    (queryCycle : Point (K := K) t) :
    timeTableMLE (K := K) inc queryAddress queryCycle =
      writeCheckExpression (K := K) queryAddress queryCycle wa wv val := by
  unfold timeTableMLE writeCheckExpression writeCheckValueAtCycle mle tableMLE timeTableAtCycle
  apply Finset.sum_congr rfl
  intro j _
  congr 1
  apply Finset.sum_congr rfl
  intro k _
  rw [hRel k j]
  ring

theorem IncrementRelation.writeCheckAtBitPoint
    {d m t : Nat}
    {val : TimeTable (K := K) d m t}
    {wa : AddressColumns (K := K) d m t}
    {wv : CycleCube t → K}
    {inc : TimeTable (K := K) d m t}
    (hRel : IncrementRelation (K := K) val wa wv inc)
    (a : Address d m)
    (j : CycleCube t) :
    inc a j =
      writeCheckExpression (K := K) (bitAddress (K := K) a) (bitVec (K := K) j) wa wv val := by
  calc
    inc a j = timeTableMLE (K := K) inc (bitAddress (K := K) a) (bitVec (K := K) j) := by
      symm
      exact timeTableMLE_at_bitPoint (K := K) inc a j
    _ = writeCheckExpression (K := K) (bitAddress (K := K) a) (bitVec (K := K) j) wa wv val := by
      exact hRel.writeCheckIdentity (bitAddress (K := K) a) (bitVec (K := K) j)

theorem ValidAddressColumns.writeCheckValueAtCycle
    {d m t : Nat}
    {wa : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) wa addr)
    (queryAddress : Fin d → Point (K := K) m)
    (wv : CycleCube t → K)
    (val : TimeTable (K := K) d m t)
    (j : CycleCube t) :
    writeCheckValueAtCycle (K := K) queryAddress wa wv val j =
      (wv j - val (addr j) j) * addressWeight (K := K) queryAddress (addr j) := by
  unfold TwistShout.writeCheckValueAtCycle
  exact hvalid.selectorWeightedSumAtCycle
    (w := fun k => (wv j - val k j) * addressWeight (K := K) queryAddress k)
    j

theorem ValidAddressColumns.writeCheckExpression
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
          chiWeight (K := K) queryCycle j := by
  unfold TwistShout.writeCheckExpression
  apply Finset.sum_congr rfl
  intro j _
  rw [hvalid.writeCheckValueAtCycle
    (queryAddress := queryAddress) (wv := wv) (val := val) (j := j)]

theorem ValidAddressColumns.incrementEquationAtCycle
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
    inc k j = if k = addr j then wv j - val k j else 0 := by
  rw [hRel k j, hvalid.addressSelector_eq_tupleCubeOneHot (k := k) (j := j)]
  by_cases hk : k = addr j
  · simp [tupleCubeOneHot, hk]
  · simp [tupleCubeOneHot, hk]

theorem ValidAddressColumns.incrementAtWrittenAddress
    {d m t : Nat}
    {wa : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    {val : TimeTable (K := K) d m t}
    {wv : CycleCube t → K}
    {inc : TimeTable (K := K) d m t}
    (hvalid : ValidAddressColumns (K := K) wa addr)
    (hRel : IncrementRelation (K := K) val wa wv inc)
    (j : CycleCube t) :
    inc (addr j) j = wv j - val (addr j) j := by
  simpa using hvalid.incrementEquationAtCycle hRel (k := addr j) (j := j)

theorem ValidAddressColumns.incrementAtOtherAddress
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
    inc k j = 0 := by
  simpa [hk] using hvalid.incrementEquationAtCycle hRel (k := k) (j := j)

theorem ValidAddressColumns.twistReadCheckFinalRoundTarget_atBooleanPoint
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (val : TimeTable (K := K) d m t)
    (queryCycle : Point (K := K) t)
    (j : CycleCube t) :
    twistReadCheckFinalRoundTarget (K := K) queryCycle ra val
      (bitAddress (K := K) (addr j)) (bitVec (K := K) j) =
      chiWeight (K := K) queryCycle j * val (addr j) j := by
  unfold twistReadCheckFinalRoundTarget
  rw [timeTableMLE_at_bitPoint (K := K) (val := val) (a := addr j) (j := j)]
  have hProd :
      ∏ i : Fin d,
        columnMLE (K := K) ra i ((bitAddress (K := K) (addr j)) i) (bitVec (K := K) j) = 1 := by
    apply Finset.prod_eq_one
    intro i _
    simpa using hvalid.columnMLE_bitAddress_bitCycle_eq_one (i := i) (j := j)
  rw [hProd]
  simp [chiWeight]

theorem ValidAddressColumns.writeCheckFinalRoundTarget_atBooleanPoint
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
        (wv j - val (addr j) j) := by
  unfold writeCheckFinalRoundTarget
  rw [addressEqWeight_at_bitAddress (K := K) (queryAddress := queryAddress) (a := addr j)]
  rw [timeTableMLE_at_bitPoint (K := K) (val := val) (a := addr j) (j := j)]
  rw [mle_at_bitVec (K := K) (f := wv) (a := j)]
  have hProd :
      ∏ i : Fin d,
        columnMLE (K := K) wa i ((bitAddress (K := K) (addr j)) i) (bitVec (K := K) j) = 1 := by
    apply Finset.prod_eq_one
    intro i _
    simpa using hvalid.columnMLE_bitAddress_bitCycle_eq_one (i := i) (j := j)
  rw [hProd]
  simp [chiWeight]

end

end TwistShout

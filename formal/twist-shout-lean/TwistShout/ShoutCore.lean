import TwistShout.ShoutOneHot

/-!
# ShoutCore

Paper-faithful read-check identities for the Shout protocol.
-/

open scoped BigOperators

namespace TwistShout

section

variable {K : Type*} [Field K]

/-- Public read-only lookup table indexed by `d` Boolean-cube address digits. -/
abbrev PublicTable (d m : Nat) := Address d m → K

/-- Embed an address on the Boolean cube as a tuple of field-valued points. -/
def bitAddress {d m : Nat} (a : Address d m) : Fin d → Point (K := K) m :=
  fun i => bitVec (K := K) (a i)

/-- Product of address-selector basis weights for the `d` address digits. -/
def addressWeight {d m : Nat}
    (rAddress : Fin d → Point (K := K) m)
    (k : Address d m) : K :=
  ∏ i, chiWeight (K := K) (rAddress i) (k i)

/-- Tail of a `(d + 1)`-digit address query point. -/
def tailAddressPoint {d m : Nat}
    (rAddress : Fin (d + 1) → Point (K := K) m) :
    Fin d → Point (K := K) m :=
  fun i => rAddress i.succ

/-- Decompose a `(d + 1)`-digit address into its head digit and tail address. -/
def addressSuccEquiv (d m : Nat) : Address (d + 1) m ≃ DigitCube m × Address d m where
  toFun a := (a 0, fun i => a i.succ)
  invFun p := Fin.cons p.1 p.2
  left_inv a := by
    funext i
    refine Fin.cases ?_ ?_ i
    · rfl
    · intro j
      rfl
  right_inv p := by
    cases p
    rfl

/-- The paper's `\tilde{Val}`: multilinear extension of the public table over address digits. -/
def tableMLE {d m : Nat}
    (val : PublicTable (K := K) d m)
    (rAddress : Fin d → Point (K := K) m) : K :=
  ∑ k : Address d m, val k * addressWeight (K := K) rAddress k

/-- The honest cycle-indexed read-value table `rv(j) = Val(addr(j))`. -/
def readOracleTable {d m t : Nat}
    (val : PublicTable (K := K) d m)
    (addr : CycleCube t → Address d m) :
    CycleCube t → K :=
  fun j => val (addr j)

/-- Pointwise read-only memory relation from the paper. -/
def ReadOnlyMemoryRelation {d m t : Nat}
    (val : PublicTable (K := K) d m)
    (addr : CycleCube t → Address d m)
    (rv : CycleCube t → K) : Prop :=
  ∀ j, rv j = val (addr j)

/-- Evaluation of the `i`-th committed address column at a fixed cycle. -/
def columnMLEAtCycle {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (i : Fin d)
    (rAddress : Point (K := K) m)
    (j : CycleCube t) : K :=
  mle (K := K) (fun k : DigitCube m => ra i k j) rAddress

/-- Full multilinear extension `\tilde{ra}_i(r_address, r_cycle)`. -/
def columnMLE {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (i : Fin d)
    (rAddress : Point (K := K) m)
    (rCycle : Point (K := K) t) : K :=
  mle (K := K) (fun j : CycleCube t => columnMLEAtCycle (K := K) ra i rAddress j) rCycle

/-- The cycle-local read relation `Σ_k (∏ᵢ raᵢ(kᵢ, j)) · Val(k)`. -/
def readValueAtCycle {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (val : PublicTable (K := K) d m)
    (j : CycleCube t) : K :=
  ∑ k : Address d m, val k * addressSelector (K := K) ra k j

/-- Equation (31)/(66), written as a random-point read-check expression. -/
def readCheckExpression {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (val : PublicTable (K := K) d m)
    (rCycle : Point (K := K) t) : K :=
  ∑ j : CycleCube t, readValueAtCycle (K := K) ra val j * chiWeight (K := K) rCycle j

/-- Honest last-round verifier target after the Shout sum-check binds all variables. -/
def readCheckFinalRoundTarget {d m t : Nat}
    (queryCycle : Point (K := K) t)
    (ra : AddressColumns (K := K) d m t)
    (val : PublicTable (K := K) d m)
    (rAddress : Fin d → Point (K := K) m)
    (boundCycle : Point (K := K) t) : K :=
  eqPoly queryCycle boundCycle *
    (∏ i, columnMLE (K := K) ra i (rAddress i) boundCycle) *
    tableMLE (K := K) val rAddress

omit [Field K] in
theorem ReadOnlyMemoryRelation.readOracleTable_eq
    {d m t : Nat}
    {val : PublicTable (K := K) d m}
    {addr : CycleCube t → Address d m}
    {rv : CycleCube t → K}
    (hRel : ReadOnlyMemoryRelation (K := K) val addr rv) :
    rv = readOracleTable (K := K) val addr := by
  funext j
  exact hRel j

theorem ReadOnlyMemoryRelation.mle_eq_readOracleTable
    {d m t : Nat}
    {val : PublicTable (K := K) d m}
    {addr : CycleCube t → Address d m}
    {rv : CycleCube t → K}
    (hRel : ReadOnlyMemoryRelation (K := K) val addr rv)
    (rCycle : Point (K := K) t) :
    mle (K := K) rv rCycle = mle (K := K) (readOracleTable (K := K) val addr) rCycle := by
  rw [hRel.readOracleTable_eq]

open Classical in
theorem addressWeight_eq_delta_at_bitAddress
    {d m : Nat}
    (a k : Address d m) :
    addressWeight (K := K) (bitAddress (K := K) a) k = (if k = a then 1 else 0) := by
  by_cases hk : k = a
  · subst hk
    have hprod : addressWeight (K := K) (bitAddress (K := K) k) k = 1 := by
      unfold addressWeight bitAddress
      apply Finset.prod_eq_one
      intro i _
      simpa using (chiWeight_at_bitVec (K := K) (k i) (k i))
    simpa using hprod
  · have hcoord : ∃ i : Fin d, k i ≠ a i := by
      by_contra hNo
      apply hk
      funext i
      by_contra hi
      exact hNo ⟨i, hi⟩
    rcases hcoord with ⟨i, hi⟩
    have hprod : addressWeight (K := K) (bitAddress (K := K) a) k = 0 := by
      unfold addressWeight bitAddress
      exact Finset.prod_eq_zero (s := Finset.univ)
        (i := i)
        (f := fun i' => chiWeight (K := K) (bitVec (K := K) (a i')) (k i'))
        (by simp)
        (by
          have hai : a i ≠ k i := fun hEq => hi hEq.symm
          simpa [hai] using (chiWeight_at_bitVec (K := K) (a i) (k i)))
    simpa [hk] using hprod

open Classical in
theorem tableMLE_at_bitAddress
    {d m : Nat}
    (val : PublicTable (K := K) d m)
    (a : Address d m) :
    tableMLE (K := K) val (bitAddress (K := K) a) = val a := by
  unfold tableMLE
  rw [Finset.sum_eq_single a]
  · simp [addressWeight_eq_delta_at_bitAddress]
  · intro k _ hk
    simp [addressWeight_eq_delta_at_bitAddress, hk]
  · simp [addressWeight_eq_delta_at_bitAddress]

theorem addressWeight_succ
    {d m : Nat}
    (rAddress : Fin (d + 1) → Point (K := K) m)
    (head : DigitCube m)
    (tail : Address d m) :
    addressWeight (K := K) rAddress (Fin.cons head tail) =
      chiWeight (K := K) (rAddress 0) head *
        addressWeight (K := K) (tailAddressPoint (K := K) rAddress) tail := by
  simp [addressWeight, tailAddressPoint, Fin.prod_univ_succ]

theorem tableMLE_addressWeight
    {d m : Nat}
    (q x : Fin d → Point (K := K) m) :
    tableMLE (K := K) (fun a : Address d m => addressWeight (K := K) q a) x =
      ∏ i, eqPoly (x i) (q i) := by
  induction d with
  | zero =>
      simp [tableMLE, addressWeight]
  | succ d ih =>
      unfold tableMLE
      let g : DigitCube m × Address d m → K :=
        fun p =>
          addressWeight (K := K) q (Fin.cons p.1 p.2) *
            addressWeight (K := K) x (Fin.cons p.1 p.2)
      have hSplit :
          (∑ a : Address (d + 1) m,
              addressWeight (K := K) q a * addressWeight (K := K) x a) =
            ∑ p : DigitCube m × Address d m, g p := by
        refine Fintype.sum_equiv (addressSuccEquiv d m)
          (fun a : Address (d + 1) m =>
            addressWeight (K := K) q a * addressWeight (K := K) x a) g ?_
        intro a
        have ha : Fin.cons (a 0) (fun i => a i.succ) = a :=
          (addressSuccEquiv d m).left_inv a
        change
          addressWeight (K := K) q a * addressWeight (K := K) x a =
            addressWeight (K := K) q (Fin.cons (a 0) (fun i => a i.succ)) *
              addressWeight (K := K) x (Fin.cons (a 0) (fun i => a i.succ))
        simp [ha]
      rw [hSplit]
      rw [show (∑ p : DigitCube m × Address d m, g p) =
          ∑ tail : Address d m, ∑ head : DigitCube m, g (head, tail) by
            simpa using
              (Fintype.sum_prod_type_right'
                (fun head : DigitCube m => fun tail : Address d m => g (head, tail)))]
      have hHead :
          ∑ head : DigitCube m,
              chiWeight (K := K) (q 0) head * chiWeight (K := K) (x 0) head =
            eqPoly (x 0) (q 0) := by
        simpa [mle] using
          (mle_chiWeight (K := K) (q := q 0) (x := x 0))
      calc
        ∑ tail : Address d m, ∑ head : DigitCube m, g (head, tail)
          = ∑ tail : Address d m,
              (∑ head : DigitCube m,
                  chiWeight (K := K) (q 0) head * chiWeight (K := K) (x 0) head) *
                (addressWeight (K := K) (tailAddressPoint (K := K) q) tail *
                  addressWeight (K := K) (tailAddressPoint (K := K) x) tail) := by
                  apply Finset.sum_congr rfl
                  intro tail _
                  calc
                    ∑ head : DigitCube m, g (head, tail)
                      = ∑ head : DigitCube m,
                          (chiWeight (K := K) (q 0) head * chiWeight (K := K) (x 0) head) *
                            (addressWeight (K := K) (tailAddressPoint (K := K) q) tail *
                              addressWeight (K := K) (tailAddressPoint (K := K) x) tail) := by
                                apply Finset.sum_congr rfl
                                intro head _
                                unfold g
                                rw [addressWeight_succ, addressWeight_succ]
                                ring
                    _ = (∑ head : DigitCube m,
                            chiWeight (K := K) (q 0) head * chiWeight (K := K) (x 0) head) *
                          (addressWeight (K := K) (tailAddressPoint (K := K) q) tail *
                            addressWeight (K := K) (tailAddressPoint (K := K) x) tail) := by
                              rw [Finset.sum_mul]
        _ = eqPoly (x 0) (q 0) *
              ∑ tail : Address d m,
                addressWeight (K := K) (tailAddressPoint (K := K) q) tail *
                  addressWeight (K := K) (tailAddressPoint (K := K) x) tail := by
              rw [hHead, Finset.mul_sum]
        _ = eqPoly (x 0) (q 0) *
              tableMLE (K := K)
                (fun tail : Address d m =>
                  addressWeight (K := K) (tailAddressPoint (K := K) q) tail)
                (tailAddressPoint (K := K) x) := by
              rfl
        _ = eqPoly (x 0) (q 0) *
              ∏ i, eqPoly ((tailAddressPoint (K := K) x) i)
                ((tailAddressPoint (K := K) q) i) := by
              rw [ih (tailAddressPoint (K := K) q) (tailAddressPoint (K := K) x)]
        _ = ∏ i, eqPoly (x i) (q i) := by
              simp [tailAddressPoint, Fin.prod_univ_succ]

theorem ValidAddressColumns.columnMLEAtCycle_eq_chiWeight
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (i : Fin d)
    (rAddress : Point (K := K) m)
    (j : CycleCube t) :
    columnMLEAtCycle (K := K) ra i rAddress j = chiWeight (K := K) rAddress (addr j i) := by
  unfold columnMLEAtCycle
  rw [hvalid.coord_eq_cubeOneHot (j := j) (i := i)]
  exact mle_cubeOneHot (K := K) (addr j i) rAddress

theorem ValidAddressColumns.columnMLE_at_bitCycle_eq_chiWeight
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (i : Fin d)
    (rAddress : Point (K := K) m)
    (j : CycleCube t) :
    columnMLE (K := K) ra i rAddress (bitVec (K := K) j) =
      chiWeight (K := K) rAddress (addr j i) := by
  unfold columnMLE
  rw [mle_at_bitVec (K := K)
    (f := fun j' : CycleCube t => columnMLEAtCycle (K := K) ra i rAddress j')
    (a := j)]
  exact hvalid.columnMLEAtCycle_eq_chiWeight i rAddress j

theorem ValidAddressColumns.columnMLE_bitAddress_bitCycle_eq_one
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (i : Fin d)
    (j : CycleCube t) :
    columnMLE (K := K) ra i (bitVec (K := K) (addr j i)) (bitVec (K := K) j) = 1 := by
  rw [hvalid.columnMLE_at_bitCycle_eq_chiWeight
    (i := i) (rAddress := bitVec (K := K) (addr j i)) (j := j)]
  simpa using (chiWeight_at_bitVec (K := K) (addr j i) (addr j i))

theorem ValidAddressColumns.readValueAtCycle
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (val : PublicTable (K := K) d m)
    (j : CycleCube t) :
    readValueAtCycle (K := K) ra val j = val (addr j) := by
  exact hvalid.selectorWeightedSumAtCycle (w := val) j

theorem ValidAddressColumns.readCheckExpression
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (val : PublicTable (K := K) d m)
    (rCycle : Point (K := K) t) :
    mle (K := K) (readOracleTable (K := K) val addr) rCycle =
      readCheckExpression (K := K) ra val rCycle := by
  unfold mle readOracleTable TwistShout.readCheckExpression
  apply Finset.sum_congr rfl
  intro j _
  rw [hvalid.readValueAtCycle (val := val) (j := j)]

theorem ReadOnlyMemoryRelation.readCheckIdentity
    {d m t : Nat}
    {val : PublicTable (K := K) d m}
    {addr : CycleCube t → Address d m}
    {rv : CycleCube t → K}
    {ra : AddressColumns (K := K) d m t}
    (hRel : ReadOnlyMemoryRelation (K := K) val addr rv)
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (rCycle : Point (K := K) t) :
    mle (K := K) rv rCycle = readCheckExpression (K := K) ra val rCycle := by
  rw [hRel.mle_eq_readOracleTable rCycle]
  exact hvalid.readCheckExpression val rCycle

theorem ReadOnlyMemoryRelation.readCheckAtBitCycle
    {d m t : Nat}
    {val : PublicTable (K := K) d m}
    {addr : CycleCube t → Address d m}
    {rv : CycleCube t → K}
    {ra : AddressColumns (K := K) d m t}
    (hRel : ReadOnlyMemoryRelation (K := K) val addr rv)
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (j : CycleCube t) :
    rv j = readCheckExpression (K := K) ra val (bitVec (K := K) j) := by
  calc
    rv j = mle (K := K) rv (bitVec (K := K) j) := by
      symm
      exact mle_at_bitVec (K := K) rv j
    _ = readCheckExpression (K := K) ra val (bitVec (K := K) j) := by
      exact hRel.readCheckIdentity hvalid (bitVec (K := K) j)

theorem ValidAddressColumns.readCheckFinalRoundTarget_atBooleanPoint
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (val : PublicTable (K := K) d m)
    (queryCycle : Point (K := K) t)
    (j : CycleCube t) :
    readCheckFinalRoundTarget (K := K) queryCycle ra val
      (bitAddress (K := K) (addr j)) (bitVec (K := K) j) =
      chiWeight (K := K) queryCycle j * val (addr j) := by
  unfold readCheckFinalRoundTarget
  rw [tableMLE_at_bitAddress (K := K) (val := val) (a := addr j)]
  have hProd :
      ∏ i, columnMLE (K := K) ra i ((bitAddress (K := K) (addr j)) i) (bitVec (K := K) j) = 1 := by
    unfold bitAddress
    apply Finset.prod_eq_one
    intro i _
    simpa using hvalid.columnMLE_bitAddress_bitCycle_eq_one (i := i) (j := j)
  rw [hProd]
  simp [chiWeight]

end

end TwistShout

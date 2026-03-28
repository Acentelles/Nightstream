import TwistShout.ShoutCore

/-!
# ShoutLinearVariant

Appendix C variation of Shout with linear prover dependence on `d`.
-/

open scoped BigOperators

namespace TwistShout

section

variable {K : Type*} [Field K]

/-- `d` independent cycle indices used in Appendix C's variant of the Shout read-check. -/
abbrev CycleTuple (d t : Nat) := Fin d → CycleCube t

/-- Diagonal tuple `(j, …, j)` used by the appendix equality gadget. -/
def diagonalCycleTuple {d t : Nat} (j : CycleCube t) : CycleTuple d t :=
  fun _ => j

/-- MLE of the predicate "all cycle tuples equal the same Boolean-cube point". -/
def diagonalEqWeight {d t : Nat}
    (rCycle : Point (K := K) t)
    (js : CycleTuple d t) : K :=
  ∑ j : CycleCube t,
    chiWeight (K := K) rCycle j *
      tupleCubeOneHot (K := K) (diagonalCycleTuple (d := d) j) js

/-- Appendix C's tuple-indexed read value before the diagonal-equality collapse. -/
def linearReadValueAtTuple {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (val : PublicTable (K := K) d m)
    (js : CycleTuple d t) : K :=
  ∑ k : Address d m, val k * ∏ i, ra i (k i) (js i)

/-- Appendix C random-point read-check expression (Equation (95)). -/
def linearReadCheckExpression {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (val : PublicTable (K := K) d m)
    (rCycle : Point (K := K) t) : K :=
  ∑ js : CycleTuple d t,
    diagonalEqWeight (K := K) rCycle js * linearReadValueAtTuple (K := K) ra val js

theorem linearReadValueAtTuple_diagonal
    {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (val : PublicTable (K := K) d m)
    (j : CycleCube t) :
    linearReadValueAtTuple (K := K) ra val (diagonalCycleTuple (d := d) j) =
      readValueAtCycle (K := K) ra val j := by
  unfold linearReadValueAtTuple readValueAtCycle addressSelector diagonalCycleTuple
  simp

theorem collapse_linearReadValueAtTuple_diagonal
    {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (val : PublicTable (K := K) d m)
    (j : CycleCube t) :
    ∑ js : CycleTuple d t,
        linearReadValueAtTuple (K := K) ra val js *
          tupleCubeOneHot (K := K) (diagonalCycleTuple (d := d) j) js =
      linearReadValueAtTuple (K := K) ra val (diagonalCycleTuple (d := d) j) := by
  simpa using
    weightedSum_tupleCubeOneHot
      (K := K)
      (w := linearReadValueAtTuple (K := K) ra val)
      (z := diagonalCycleTuple (d := d) j)

theorem diagonalCycleTuple_injective
    {d t : Nat} [NeZero d] :
    Function.Injective (@diagonalCycleTuple d t) := by
  intro j j' h
  have h0 := congrFun h (0 : Fin d)
  simpa [diagonalCycleTuple] using h0

open Classical in
theorem diagonalEqWeight_at_diagonalCycleTuple
    {d t : Nat} [NeZero d]
    (rCycle : Point (K := K) t)
    (j : CycleCube t) :
    diagonalEqWeight (K := K) rCycle (diagonalCycleTuple (d := d) j) =
      chiWeight (K := K) rCycle j := by
  unfold diagonalEqWeight
  rw [Finset.sum_eq_single j]
  · simp [tupleCubeOneHot]
  · intro j' _ hj'
    have hdiag : diagonalCycleTuple (d := d) j' ≠ diagonalCycleTuple (d := d) j := by
      intro hEq
      apply hj'
      exact diagonalCycleTuple_injective hEq
    have hdiag' : diagonalCycleTuple (d := d) j ≠ diagonalCycleTuple (d := d) j' := by
      intro hEq
      exact hdiag hEq.symm
    simp [tupleCubeOneHot, hdiag']
  · simp

open Classical in
theorem linearReadCheckExpression_eq_readCheckExpression
    {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (val : PublicTable (K := K) d m)
    (rCycle : Point (K := K) t) :
    linearReadCheckExpression (K := K) ra val rCycle =
      readCheckExpression (K := K) ra val rCycle := by
  unfold linearReadCheckExpression diagonalEqWeight
  calc
    ∑ js : CycleTuple d t,
        (∑ j : CycleCube t,
            chiWeight (K := K) rCycle j *
              tupleCubeOneHot (K := K) (diagonalCycleTuple (d := d) j) js) *
          linearReadValueAtTuple (K := K) ra val js
      = ∑ js : CycleTuple d t,
          ∑ j : CycleCube t,
            (chiWeight (K := K) rCycle j *
              tupleCubeOneHot (K := K) (diagonalCycleTuple (d := d) j) js) *
              linearReadValueAtTuple (K := K) ra val js := by
            apply Finset.sum_congr rfl
            intro js _
            rw [Finset.sum_mul]
    _ = ∑ j : CycleCube t,
          ∑ js : CycleTuple d t,
            (chiWeight (K := K) rCycle j *
              tupleCubeOneHot (K := K) (diagonalCycleTuple (d := d) j) js) *
              linearReadValueAtTuple (K := K) ra val js := by
            rw [Finset.sum_comm]
    _ = ∑ j : CycleCube t,
          chiWeight (K := K) rCycle j *
            ∑ js : CycleTuple d t,
              linearReadValueAtTuple (K := K) ra val js *
                tupleCubeOneHot (K := K) (diagonalCycleTuple (d := d) j) js := by
            apply Finset.sum_congr rfl
            intro j _
            calc
              ∑ js : CycleTuple d t,
                  (chiWeight (K := K) rCycle j *
                    tupleCubeOneHot (K := K) (diagonalCycleTuple (d := d) j) js) *
                    linearReadValueAtTuple (K := K) ra val js
                = ∑ js : CycleTuple d t,
                    chiWeight (K := K) rCycle j *
                      (linearReadValueAtTuple (K := K) ra val js *
                        tupleCubeOneHot (K := K) (diagonalCycleTuple (d := d) j) js) := by
                      apply Finset.sum_congr rfl
                      intro js _
                      ring
              _ = chiWeight (K := K) rCycle j *
                    ∑ js : CycleTuple d t,
                      linearReadValueAtTuple (K := K) ra val js *
                        tupleCubeOneHot (K := K) (diagonalCycleTuple (d := d) j) js := by
                      rw [Finset.mul_sum]
    _ = ∑ j : CycleCube t,
          chiWeight (K := K) rCycle j *
            linearReadValueAtTuple (K := K) ra val (diagonalCycleTuple (d := d) j) := by
            apply Finset.sum_congr rfl
            intro j _
            rw [collapse_linearReadValueAtTuple_diagonal (K := K) ra val j]
    _ = ∑ j : CycleCube t,
          chiWeight (K := K) rCycle j * readValueAtCycle (K := K) ra val j := by
            apply Finset.sum_congr rfl
            intro j _
            rw [linearReadValueAtTuple_diagonal (K := K) ra val j]
    _ = readCheckExpression (K := K) ra val rCycle := by
            simp [TwistShout.readCheckExpression, mul_comm]

theorem ValidAddressColumns.linearReadCheckExpression
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (val : PublicTable (K := K) d m)
    (rCycle : Point (K := K) t) :
    TwistShout.linearReadCheckExpression (K := K) ra val rCycle =
      mle (K := K) (readOracleTable (K := K) val addr) rCycle := by
  calc
    TwistShout.linearReadCheckExpression (K := K) ra val rCycle
      = TwistShout.readCheckExpression (K := K) ra val rCycle :=
          linearReadCheckExpression_eq_readCheckExpression (K := K) ra val rCycle
    _ = mle (K := K) (readOracleTable (K := K) val addr) rCycle := by
          symm
          exact hvalid.readCheckExpression val rCycle

theorem ReadOnlyMemoryRelation.linearReadCheckIdentity
    {d m t : Nat}
    {val : PublicTable (K := K) d m}
    {addr : CycleCube t → Address d m}
    {rv : CycleCube t → K}
    {ra : AddressColumns (K := K) d m t}
    (hRel : ReadOnlyMemoryRelation (K := K) val addr rv)
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (rCycle : Point (K := K) t) :
    mle (K := K) rv rCycle = linearReadCheckExpression (K := K) ra val rCycle := by
  calc
    mle (K := K) rv rCycle
      = readCheckExpression (K := K) ra val rCycle :=
          hRel.readCheckIdentity hvalid rCycle
    _ = linearReadCheckExpression (K := K) ra val rCycle := by
          symm
          exact linearReadCheckExpression_eq_readCheckExpression (K := K) ra val rCycle

theorem ReadOnlyMemoryRelation.linearReadCheckAtBitCycle
    {d m t : Nat}
    {val : PublicTable (K := K) d m}
    {addr : CycleCube t → Address d m}
    {rv : CycleCube t → K}
    {ra : AddressColumns (K := K) d m t}
    (hRel : ReadOnlyMemoryRelation (K := K) val addr rv)
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (j : CycleCube t) :
    rv j = linearReadCheckExpression (K := K) ra val (bitVec (K := K) j) := by
  calc
    rv j = mle (K := K) rv (bitVec (K := K) j) := by
      symm
      exact mle_at_bitVec (K := K) rv j
    _ = linearReadCheckExpression (K := K) ra val (bitVec (K := K) j) := by
      exact hRel.linearReadCheckIdentity hvalid (bitVec (K := K) j)

/-- Appendix C's multilinear equality weight after all `j_i` variables are bound. -/
def diagonalEqPointWeight {d t : Nat}
    (queryCycle : Point (K := K) t)
    (boundCycles : Fin d → Point (K := K) t) : K :=
  ∑ j : CycleCube t, chiWeight (K := K) queryCycle j * ∏ i, chiWeight (K := K) (boundCycles i) j

/-- Appendix C's final-round verifier target after all variables are bound. -/
def linearReadCheckFinalRoundTarget {d m t : Nat}
    (queryCycle : Point (K := K) t)
    (ra : AddressColumns (K := K) d m t)
    (val : PublicTable (K := K) d m)
    (rAddress : Fin d → Point (K := K) m)
    (boundCycles : Fin d → Point (K := K) t) : K :=
  diagonalEqPointWeight (K := K) queryCycle boundCycles *
    (∏ i, columnMLE (K := K) ra i (rAddress i) (boundCycles i)) *
    tableMLE (K := K) val rAddress

open Classical in
theorem diagonalEqPointWeight_at_diagonalBitVec
    {d t : Nat} [NeZero d]
    (queryCycle : Point (K := K) t)
    (j : CycleCube t) :
    diagonalEqPointWeight (K := K) queryCycle (fun _ : Fin d => bitVec (K := K) j) =
      chiWeight (K := K) queryCycle j := by
  unfold diagonalEqPointWeight
  rw [Finset.sum_eq_single j]
  · have hprod :
        ∏ i : Fin d, chiWeight (K := K) (bitVec (K := K) j) j = 1 := by
        apply Finset.prod_eq_one
        intro i _
        simp [chiWeight_at_bitVec]
    simp [hprod]
  · intro j' _ hj'
    have hjne : j ≠ j' := by
      intro hEq
      exact hj' hEq.symm
    have hprod :
        ∏ i : Fin d, chiWeight (K := K) (bitVec (K := K) j) j' = 0 := by
      exact Finset.prod_eq_zero (s := Finset.univ)
        (i := (0 : Fin d))
        (f := fun i' => chiWeight (K := K) (bitVec (K := K) j) j')
        (by simp)
        (by simp [chiWeight_at_bitVec, hjne])
    simp [hprod]
  · simp

theorem ValidAddressColumns.linearReadCheckFinalRoundTarget_atDiagonalBooleanPoint
    {d m t : Nat} [NeZero d]
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (val : PublicTable (K := K) d m)
    (queryCycle : Point (K := K) t)
    (j : CycleCube t) :
    linearReadCheckFinalRoundTarget (K := K) queryCycle ra val
      (bitAddress (K := K) (addr j))
      (fun _ : Fin d => bitVec (K := K) j) =
      chiWeight (K := K) queryCycle j * val (addr j) := by
  unfold linearReadCheckFinalRoundTarget
  rw [diagonalEqPointWeight_at_diagonalBitVec (K := K) (d := d) queryCycle j]
  rw [tableMLE_at_bitAddress (K := K) val (addr j)]
  have hprod :
      ∏ i : Fin d,
        columnMLE (K := K) ra i ((bitAddress (K := K) (addr j)) i) ((fun _ : Fin d => bitVec (K := K) j) i) = 1 := by
    apply Finset.prod_eq_one
    intro i _
    simpa using hvalid.columnMLE_bitAddress_bitCycle_eq_one (i := i) (j := j)
  rw [hprod]
  ring

/-- Standard Shout uses `log K + log T = d * m + t` rounds. -/
def standardShoutRoundCount (d m t : Nat) : Nat :=
  d * m + t

/-- Appendix C uses `log K + d log T = d * m + d * t` rounds. -/
def linearVariantRoundCount (d m t : Nat) : Nat :=
  d * m + d * t

theorem linearVariantRoundCount_eq_mul
    (d m t : Nat) :
    linearVariantRoundCount d m t = d * (m + t) := by
  simpa [linearVariantRoundCount] using (Nat.mul_add d m t).symm

theorem linearVariantRoundCount_eq_standardPlus
    {d m t : Nat} [NeZero d] :
    linearVariantRoundCount d m t =
      standardShoutRoundCount d m t + (d - 1) * t := by
  cases d with
  | zero =>
      cases (NeZero.ne (n := 0) rfl)
  | succ d' =>
      calc
        linearVariantRoundCount (Nat.succ d') m t
          = (d' * m + m) + (d' * t + t) := by
              simp [linearVariantRoundCount, Nat.succ_mul]
        _ = (d' * m + m + t) + d' * t := by
              ac_rfl
        _ = standardShoutRoundCount (Nat.succ d') m t + ((Nat.succ d') - 1) * t := by
              simp [standardShoutRoundCount, Nat.succ_mul]

/-- Appendix C precomputation cost for the `E_i` arrays. -/
def linearVariantEqArrayCost (t : Nat) : Rat :=
  ((2 ^ t : Nat) : Rat) / 2

/-- Appendix C product precomputation cost for Expressions (109) and (110). -/
def linearVariantProductCost (d t : Nat) : Rat :=
  (2 * d - 4 : Rat) * ((2 ^ t : Nat) : Rat)

/-- Appendix C message-evaluation cost for the first `d - 1` rounds of each stage. -/
def linearVariantPrefixRoundCost (d t : Nat) : Rat :=
  (6 * d - 6 : Rat) * ((2 ^ t : Nat) : Rat)

/-- Appendix C message-evaluation cost for the last round of each stage before Gruen's optimization. -/
def linearVariantLastRoundCost (t : Nat) : Rat :=
  (4 : Rat) * ((2 ^ t : Nat) : Rat)

/-- Appendix C total final-round prover cost `(8d - 5.5)T`. -/
def linearVariantBaseCost (d t : Nat) : Rat :=
  ((8 : Rat) * d - (11 : Rat) / 2) * ((2 ^ t : Nat) : Rat)

theorem linearVariantBaseCost_eq_sum
    (d t : Nat) :
    linearVariantBaseCost d t =
      linearVariantEqArrayCost t +
        linearVariantProductCost d t +
        linearVariantPrefixRoundCost d t +
        linearVariantLastRoundCost t := by
  unfold linearVariantBaseCost linearVariantEqArrayCost linearVariantProductCost
  unfold linearVariantPrefixRoundCost linearVariantLastRoundCost
  ring

/-- Gruen's optimization saves `2T` from the final round of each stage. -/
def linearVariantGruenSaving (t : Nat) : Rat :=
  (2 : Rat) * ((2 ^ t : Nat) : Rat)

/-- Appendix C total final-round prover cost after Gruen's optimization: `(8d - 7.5)T`. -/
def linearVariantGruenCost (d t : Nat) : Rat :=
  ((8 : Rat) * d - (15 : Rat) / 2) * ((2 ^ t : Nat) : Rat)

theorem linearVariantGruenCost_eq_base_minus_saving
    (d t : Nat) :
    linearVariantGruenCost d t =
      linearVariantBaseCost d t - linearVariantGruenSaving t := by
  unfold linearVariantGruenCost linearVariantBaseCost linearVariantGruenSaving
  ring

/-- Standard Shout's final `log T` rounds contribute the quadratic `d^2 T` term. -/
def standardShoutFinalRoundsQuadraticCost (d t : Nat) : Rat :=
  (d * d : Rat) * ((2 ^ t : Nat) : Rat)

theorem linearVariantGruenCost_le_standardQuadratic
    {d t : Nat}
    (hd : 8 ≤ d) :
    linearVariantGruenCost d t ≤ standardShoutFinalRoundsQuadraticCost d t := by
  unfold linearVariantGruenCost standardShoutFinalRoundsQuadraticCost
  have hdRat : (8 : Rat) ≤ d := by
    exact_mod_cast hd
  have hcoef : (8 : Rat) * d - (15 : Rat) / 2 ≤ d * d := by
    nlinarith
  have hT : (0 : Rat) ≤ ((2 ^ t : Nat) : Rat) := by
    positivity
  exact mul_le_mul_of_nonneg_right hcoef hT

end

end TwistShout

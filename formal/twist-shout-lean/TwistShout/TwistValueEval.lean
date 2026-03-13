import TwistShout.TwistCore
import TwistShout.LessThanPoly

/-!
# TwistValueEval

Paper-faithful reconstruction of the virtual memory polynomial `Val~` from committed increments.
-/

open scoped BigOperators

namespace TwistShout

section

variable {K : Type*} [Field K]

/-- The cycle-indexed increment table for a fixed address. -/
def addressIncrementTable {d m t : Nat}
    (inc : TimeTable (K := K) d m t)
    (k : Address d m) :
    CycleCube t → K :=
  fun j => inc k j

/-- The paper's virtual memory value `Val~(k, r_cycle)` reconstructed from `Inc`. -/
def virtualValue {d m t : Nat}
    (inc : TimeTable (K := K) d m t)
    (k : Address d m)
    (rCycle : Point (K := K) t) : K :=
  prefixExpression (K := K) (addressIncrementTable (K := K) inc k) rCycle

/-- Boolean-cube table of reconstructed memory values `Val(k, j)`. -/
def reconstructedTimeTable {d m t : Nat}
    (inc : TimeTable (K := K) d m t) :
    TimeTable (K := K) d m t :=
  fun k j => prefixTable (K := K) (addressIncrementTable (K := K) inc k) j

/-- For a random address point, view `Inc~(r_address, j)` as a table over cycles. -/
def incEvaluationTable {d m t : Nat}
    (inc : TimeTable (K := K) d m t)
    (rAddress : Fin d → Point (K := K) m) :
    CycleCube t → K :=
  fun j => tableMLE (K := K) (timeTableAtCycle (K := K) inc j) rAddress

/-- Twist's verifier-facing `Val~(r_address, r_cycle)` expression from Equation (36). -/
def valEvaluationExpression {d m t : Nat}
    (inc : TimeTable (K := K) d m t)
    (rAddress : Fin d → Point (K := K) m)
    (rCycle : Point (K := K) t) : K :=
  prefixExpression (K := K) (incEvaluationTable (K := K) inc rAddress) rCycle

/-- Final-round verifier target for the `Val~`-evaluation sum-check. -/
def valEvaluationFinalRoundTarget {d m t : Nat}
    (inc : TimeTable (K := K) d m t)
    (queryAddress : Fin d → Point (K := K) m)
    (queryCycle : Point (K := K) t)
    (boundCycle : Point (K := K) t) : K :=
  timeTableMLE (K := K) inc queryAddress boundCycle *
    ltWeight (K := K) boundCycle queryCycle

theorem virtualValue_at_bitCycle
    {d m t : Nat}
    (inc : TimeTable (K := K) d m t)
    (k : Address d m)
    (j : CycleCube t) :
    virtualValue (K := K) inc k (bitVec (K := K) j) =
      reconstructedTimeTable (K := K) inc k j := by
  unfold virtualValue reconstructedTimeTable addressIncrementTable
  exact prefixExpression_at_bitVec (K := K) (f := fun j' => inc k j') j

theorem incEvaluationTable_at_bitAddress
    {d m t : Nat}
    (inc : TimeTable (K := K) d m t)
    (a : Address d m)
    (j : CycleCube t) :
    incEvaluationTable (K := K) inc (bitAddress (K := K) a) j = inc a j := by
  unfold incEvaluationTable timeTableAtCycle
  exact tableMLE_at_bitAddress (K := K) (val := fun k => inc k j) a

theorem valEvaluationExpression_at_bitPoint
    {d m t : Nat}
    (inc : TimeTable (K := K) d m t)
    (a : Address d m)
    (j : CycleCube t) :
    valEvaluationExpression (K := K) inc (bitAddress (K := K) a) (bitVec (K := K) j) =
      reconstructedTimeTable (K := K) inc a j := by
  unfold valEvaluationExpression reconstructedTimeTable addressIncrementTable
  rw [prefixExpression_at_bitVec
    (K := K)
    (f := incEvaluationTable (K := K) inc (bitAddress (K := K) a))
    (y := j)]
  unfold prefixTable incEvaluationTable timeTableAtCycle
  apply Finset.sum_congr rfl
  intro j' _
  by_cases hlt : ltCube j' j
  · rw [tableMLE_at_bitAddress (K := K) (val := fun k => inc k j') a]
  · rw [tableMLE_at_bitAddress (K := K) (val := fun k => inc k j') a]

theorem tableMLE_reconstructedTimeTableAtCycle
    {d m t : Nat}
    (inc : TimeTable (K := K) d m t)
    (rAddress : Fin d → Point (K := K) m)
    (j : CycleCube t) :
    tableMLE (K := K)
      (timeTableAtCycle (K := K) (reconstructedTimeTable (K := K) inc) j)
      rAddress =
      prefixTable (K := K) (incEvaluationTable (K := K) inc rAddress) j := by
  unfold tableMLE timeTableAtCycle reconstructedTimeTable prefixTable
    addressIncrementTable incEvaluationTable
  calc
    ∑ k : Address d m,
        (∑ j' : CycleCube t, if ltCube j' j then inc k j' else 0) *
          addressWeight (K := K) rAddress k
      =
        ∑ k : Address d m,
          ∑ j' : CycleCube t,
            (if ltCube j' j then inc k j' else 0) * addressWeight (K := K) rAddress k := by
          apply Finset.sum_congr rfl
          intro k _
          rw [Finset.sum_mul]
    _ =
        ∑ j' : CycleCube t,
          ∑ k : Address d m,
            (if ltCube j' j then inc k j' else 0) * addressWeight (K := K) rAddress k := by
          rw [Finset.sum_comm]
    _ =
        ∑ j' : CycleCube t,
          if ltCube j' j then
            ∑ k : Address d m, inc k j' * addressWeight (K := K) rAddress k
          else 0 := by
          apply Finset.sum_congr rfl
          intro j' _
          by_cases hlt : ltCube j' j
          · simp [hlt]
          · simp [hlt]
    _ = prefixTable (K := K) (fun j' : CycleCube t =>
          ∑ k : Address d m, inc k j' * addressWeight (K := K) rAddress k) j := by
          rfl

theorem timeTableMLE_reconstructedTimeTable
    {d m t : Nat}
    (inc : TimeTable (K := K) d m t)
    (rAddress : Fin d → Point (K := K) m)
    (rCycle : Point (K := K) t) :
    timeTableMLE (K := K) (reconstructedTimeTable (K := K) inc) rAddress rCycle =
      valEvaluationExpression (K := K) inc rAddress rCycle := by
  unfold timeTableMLE valEvaluationExpression
  rw [show
      (fun j : CycleCube t =>
        tableMLE (K := K)
          (timeTableAtCycle (K := K) (reconstructedTimeTable (K := K) inc) j)
          rAddress) =
        prefixTable (K := K) (incEvaluationTable (K := K) inc rAddress) by
        funext j
        exact tableMLE_reconstructedTimeTableAtCycle (K := K) inc rAddress j]
  exact mle_prefixTable (K := K) (f := incEvaluationTable (K := K) inc rAddress) rCycle

theorem timeTableMLE_reconstructedTimeTable_at_bitAddress
    {d m t : Nat}
    (inc : TimeTable (K := K) d m t)
    (a : Address d m)
    (rCycle : Point (K := K) t) :
    timeTableMLE (K := K) (reconstructedTimeTable (K := K) inc)
      (bitAddress (K := K) a) rCycle =
      virtualValue (K := K) inc a rCycle := by
  rw [timeTableMLE_reconstructedTimeTable (K := K) inc (bitAddress (K := K) a) rCycle]
  unfold valEvaluationExpression virtualValue addressIncrementTable
  apply Finset.sum_congr rfl
  intro j _
  rw [incEvaluationTable_at_bitAddress (K := K) inc a j]

theorem valEvaluationFinalRoundTarget_at_bitCycle
    {d m t : Nat}
    (inc : TimeTable (K := K) d m t)
    (queryAddress : Fin d → Point (K := K) m)
    (queryCycle : Point (K := K) t)
    (j : CycleCube t) :
    valEvaluationFinalRoundTarget (K := K) inc queryAddress queryCycle (bitVec (K := K) j) =
      timeTableMLE (K := K) inc queryAddress (bitVec (K := K) j) *
        ltPoly (K := K) j queryCycle := by
  unfold valEvaluationFinalRoundTarget
  rw [ltWeight_at_bitVec_left (K := K) j queryCycle]

theorem valEvaluationFinalRoundTarget_at_bitPoint
    {d m t : Nat}
    (inc : TimeTable (K := K) d m t)
    (a : Address d m)
    (queryCycle : Point (K := K) t)
    (j : CycleCube t) :
    valEvaluationFinalRoundTarget (K := K) inc
      (bitAddress (K := K) a) queryCycle (bitVec (K := K) j) =
      inc a j * ltPoly (K := K) j queryCycle := by
  rw [valEvaluationFinalRoundTarget_at_bitCycle
    (K := K)
    (inc := inc)
    (queryAddress := bitAddress (K := K) a)
    (queryCycle := queryCycle)
    (j := j)]
  rw [timeTableMLE_at_bitPoint (K := K) (val := inc) (a := a) (j := j)]

end

end TwistShout

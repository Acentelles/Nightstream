import TwistShout.TwistValueEval

/-!
# TwistValueEvalInterface

Thin theorem-facing boundary for the `Val`-reconstruction layer in Twist.
-/

namespace TwistShout

namespace TwistValueEvalInterface

abbrev DigitCube := @TwistShout.DigitCube
abbrev Cube := @TwistShout.Cube
abbrev CycleCube := @TwistShout.CycleCube
abbrev Address := @TwistShout.Address
abbrev AddressColumns := @TwistShout.AddressColumns
abbrev Point := @TwistShout.Point
abbrev bitVec := @TwistShout.bitVec
abbrev bitAddress := @TwistShout.bitAddress
abbrev mle := @TwistShout.mle
abbrev tableMLE := @TwistShout.tableMLE
abbrev timeTableMLE := @TwistShout.timeTableMLE
abbrev addressSelector := @TwistShout.addressSelector
abbrev TimeTable := @TwistShout.TimeTable
abbrev ltPoly := @TwistShout.ltPoly
abbrev ltWeight := @TwistShout.ltWeight
abbrev addressIncrementTable := @TwistShout.addressIncrementTable
abbrev virtualValue := @TwistShout.virtualValue
abbrev reconstructedTimeTable := @TwistShout.reconstructedTimeTable
abbrev incEvaluationTable := @TwistShout.incEvaluationTable
abbrev valEvaluationExpression := @TwistShout.valEvaluationExpression
abbrev valEvaluationFinalRoundTarget := @TwistShout.valEvaluationFinalRoundTarget

theorem virtualValue_at_bitCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  (inc : TimeTable (K := K) d m t)
  (k : Address d m)
  (j : CycleCube t) :
  virtualValue (K := K) inc k (bitVec (K := K) j) =
    reconstructedTimeTable (K := K) inc k j :=
  TwistShout.virtualValue_at_bitCycle (K := K) inc k j

theorem incEvaluationTable_at_bitAddress
  {K : Type*} [Field K]
  {d m t : Nat}
  (inc : TimeTable (K := K) d m t)
  (a : Address d m)
  (j : CycleCube t) :
  incEvaluationTable (K := K) inc (bitAddress (K := K) a) j = inc a j :=
  TwistShout.incEvaluationTable_at_bitAddress (K := K) inc a j

theorem valEvaluationExpression_at_bitPoint
  {K : Type*} [Field K]
  {d m t : Nat}
  (inc : TimeTable (K := K) d m t)
  (a : Address d m)
  (j : CycleCube t) :
  valEvaluationExpression (K := K) inc (bitAddress (K := K) a) (bitVec (K := K) j) =
    reconstructedTimeTable (K := K) inc a j :=
  TwistShout.valEvaluationExpression_at_bitPoint (K := K) inc a j

theorem tableMLE_reconstructedTimeTableAtCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  (inc : TimeTable (K := K) d m t)
  (rAddress : Fin d → Point (K := K) m)
  (j : CycleCube t) :
  tableMLE (K := K)
    (TwistShout.timeTableAtCycle (K := K) (reconstructedTimeTable (K := K) inc) j)
    rAddress =
    TwistShout.prefixTable (K := K) (incEvaluationTable (K := K) inc rAddress) j :=
  TwistShout.tableMLE_reconstructedTimeTableAtCycle (K := K) inc rAddress j

theorem timeTableMLE_reconstructedTimeTable
  {K : Type*} [Field K]
  {d m t : Nat}
  (inc : TimeTable (K := K) d m t)
  (rAddress : Fin d → Point (K := K) m)
  (rCycle : Point (K := K) t) :
  timeTableMLE (K := K) (reconstructedTimeTable (K := K) inc) rAddress rCycle =
    valEvaluationExpression (K := K) inc rAddress rCycle :=
  TwistShout.timeTableMLE_reconstructedTimeTable (K := K) inc rAddress rCycle

theorem timeTableMLE_reconstructedTimeTable_at_bitAddress
  {K : Type*} [Field K]
  {d m t : Nat}
  (inc : TimeTable (K := K) d m t)
  (a : Address d m)
  (rCycle : Point (K := K) t) :
  timeTableMLE (K := K) (reconstructedTimeTable (K := K) inc)
    (bitAddress (K := K) a) rCycle =
    virtualValue (K := K) inc a rCycle :=
  TwistShout.timeTableMLE_reconstructedTimeTable_at_bitAddress (K := K) inc a rCycle

theorem valEvaluationFinalRoundTarget_at_bitCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  (inc : TimeTable (K := K) d m t)
  (queryAddress : Fin d → Point (K := K) m)
  (queryCycle : Point (K := K) t)
  (j : CycleCube t) :
  valEvaluationFinalRoundTarget (K := K) inc queryAddress queryCycle (bitVec (K := K) j) =
    timeTableMLE (K := K) inc queryAddress (bitVec (K := K) j) *
      ltPoly (K := K) j queryCycle :=
  TwistShout.valEvaluationFinalRoundTarget_at_bitCycle
    (K := K) inc queryAddress queryCycle j

theorem valEvaluationFinalRoundTarget_at_bitPoint
  {K : Type*} [Field K]
  {d m t : Nat}
  (inc : TimeTable (K := K) d m t)
  (a : Address d m)
  (queryCycle : Point (K := K) t)
  (j : CycleCube t) :
  valEvaluationFinalRoundTarget (K := K) inc
    (bitAddress (K := K) a) queryCycle (bitVec (K := K) j) =
    inc a j * ltPoly (K := K) j queryCycle :=
  TwistShout.valEvaluationFinalRoundTarget_at_bitPoint (K := K) inc a queryCycle j

end TwistValueEvalInterface

end TwistShout

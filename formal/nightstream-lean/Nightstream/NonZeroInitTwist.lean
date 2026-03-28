import TwistShout.TwistValueEval

namespace Nightstream.NonZeroInitTwist

def ShiftedTimeTable
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t) :
  TwistShout.TimeTable (K := K) d m t :=
  fun a j => init a + TwistShout.reconstructedTimeTable (K := K) inc a j

def ShiftedVirtualValue
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (a : TwistShout.Address d m)
  (rCycle : TwistShout.Point (K := K) t) : K :=
  init a + TwistShout.virtualValue (K := K) inc a rCycle

def ShiftedValEvaluationExpression
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (rAddress : Fin d → TwistShout.Point (K := K) m)
  (rCycle : TwistShout.Point (K := K) t) : K :=
  TwistShout.tableMLE (K := K) init rAddress +
    TwistShout.valEvaluationExpression (K := K) inc rAddress rCycle

theorem shiftedVirtualValue_at_bitCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (a : TwistShout.Address d m)
  (j : TwistShout.CycleCube t) :
  ShiftedVirtualValue init inc a (TwistShout.bitVec (K := K) j) =
    ShiftedTimeTable init inc a j := by
  simp [ShiftedVirtualValue, ShiftedTimeTable,
    TwistShout.virtualValue_at_bitCycle]

private theorem mle_add
  {K : Type*} [Field K]
  {n : Nat}
  (f g : TwistShout.Cube n → K)
  (r : TwistShout.Point (K := K) n) :
  TwistShout.mle (K := K) (fun b => f b + g b) r =
    TwistShout.mle (K := K) f r + TwistShout.mle (K := K) g r := by
  unfold TwistShout.mle
  calc
    ∑ b, (f b + g b) * TwistShout.chiWeight (K := K) r b
      = ∑ b, (f b * TwistShout.chiWeight (K := K) r b +
          g b * TwistShout.chiWeight (K := K) r b) := by
          apply Finset.sum_congr rfl
          intro b _
          ring
    _ = (∑ b, f b * TwistShout.chiWeight (K := K) r b) +
          ∑ b, g b * TwistShout.chiWeight (K := K) r b := by
          rw [Finset.sum_add_distrib]
    _ = TwistShout.mle (K := K) f r + TwistShout.mle (K := K) g r := by
          simp [TwistShout.mle]

private theorem tableMLE_add
  {K : Type*} [Field K]
  {d m : Nat}
  (f g : TwistShout.PublicTable (K := K) d m)
  (rAddress : Fin d → TwistShout.Point (K := K) m) :
  TwistShout.tableMLE (K := K) (fun a => f a + g a) rAddress =
    TwistShout.tableMLE (K := K) f rAddress +
      TwistShout.tableMLE (K := K) g rAddress := by
  unfold TwistShout.tableMLE
  calc
    ∑ a, (f a + g a) * TwistShout.addressWeight (K := K) rAddress a
      = ∑ a,
          (f a * TwistShout.addressWeight (K := K) rAddress a +
            g a * TwistShout.addressWeight (K := K) rAddress a) := by
              apply Finset.sum_congr rfl
              intro a _
              ring
    _ = (∑ a, f a * TwistShout.addressWeight (K := K) rAddress a) +
          ∑ a, g a * TwistShout.addressWeight (K := K) rAddress a := by
            rw [Finset.sum_add_distrib]
    _ = TwistShout.tableMLE (K := K) f rAddress +
          TwistShout.tableMLE (K := K) g rAddress := by
            simp [TwistShout.tableMLE]

private theorem timeTableMLE_add
  {K : Type*} [Field K]
  {d m t : Nat}
  (f g : TwistShout.TimeTable (K := K) d m t)
  (rAddress : Fin d → TwistShout.Point (K := K) m)
  (rCycle : TwistShout.Point (K := K) t) :
  TwistShout.timeTableMLE (K := K) (fun a j => f a j + g a j) rAddress rCycle =
    TwistShout.timeTableMLE (K := K) f rAddress rCycle +
      TwistShout.timeTableMLE (K := K) g rAddress rCycle := by
  unfold TwistShout.timeTableMLE
  have hCycle :
      (fun j : TwistShout.CycleCube t =>
        TwistShout.tableMLE (K := K)
          (TwistShout.timeTableAtCycle (K := K) (fun a j => f a j + g a j) j)
          rAddress) =
      (fun j : TwistShout.CycleCube t =>
        TwistShout.tableMLE (K := K)
          (TwistShout.timeTableAtCycle (K := K) f j)
          rAddress +
        TwistShout.tableMLE (K := K)
          (TwistShout.timeTableAtCycle (K := K) g j)
          rAddress) := by
    funext j
    unfold TwistShout.timeTableAtCycle
    exact tableMLE_add (fun a => f a j) (fun a => g a j) rAddress
  rw [hCycle]
  simpa using mle_add
    (K := K)
    (f := fun j : TwistShout.CycleCube t =>
      TwistShout.tableMLE (K := K)
        (TwistShout.timeTableAtCycle (K := K) f j)
        rAddress)
    (g := fun j : TwistShout.CycleCube t =>
      TwistShout.tableMLE (K := K)
        (TwistShout.timeTableAtCycle (K := K) g j)
        rAddress)
    rCycle

theorem timeTableMLE_initialSurface
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (rAddress : Fin d → TwistShout.Point (K := K) m)
  (rCycle : TwistShout.Point (K := K) t) :
  TwistShout.timeTableMLE (K := K) (fun a _j => init a) rAddress rCycle =
    TwistShout.tableMLE (K := K) init rAddress := by
  unfold TwistShout.timeTableMLE TwistShout.timeTableAtCycle
  change TwistShout.mle (K := K)
      (fun _ : TwistShout.CycleCube t => TwistShout.tableMLE (K := K) init rAddress)
      rCycle = TwistShout.tableMLE (K := K) init rAddress
  exact TwistShout.mle_const (K := K)
    (TwistShout.tableMLE (K := K) init rAddress) rCycle

theorem shiftedValEvaluationExpression_eq_timeTableMLE
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (rAddress : Fin d → TwistShout.Point (K := K) m)
  (rCycle : TwistShout.Point (K := K) t) :
  TwistShout.timeTableMLE (K := K) (ShiftedTimeTable init inc) rAddress rCycle =
    ShiftedValEvaluationExpression init inc rAddress rCycle := by
  calc
    TwistShout.timeTableMLE (K := K) (ShiftedTimeTable init inc) rAddress rCycle
      = TwistShout.timeTableMLE (K := K)
          (fun a j => init a + TwistShout.reconstructedTimeTable (K := K) inc a j)
          rAddress rCycle := by
            rfl
    _ = TwistShout.timeTableMLE (K := K) (fun a _j => init a) rAddress rCycle +
          TwistShout.timeTableMLE (K := K)
            (TwistShout.reconstructedTimeTable (K := K) inc)
            rAddress rCycle := by
              exact timeTableMLE_add (fun a _j => init a)
                (TwistShout.reconstructedTimeTable (K := K) inc) rAddress rCycle
    _ = TwistShout.tableMLE (K := K) init rAddress +
          TwistShout.timeTableMLE (K := K)
            (TwistShout.reconstructedTimeTable (K := K) inc)
            rAddress rCycle := by
              rw [timeTableMLE_initialSurface]
    _ = TwistShout.tableMLE (K := K) init rAddress +
          TwistShout.valEvaluationExpression (K := K) inc rAddress rCycle := by
              rw [TwistShout.timeTableMLE_reconstructedTimeTable]
    _ = ShiftedValEvaluationExpression init inc rAddress rCycle := by
          rfl

theorem shiftedValEvaluationExpression_at_bitPoint
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (a : TwistShout.Address d m)
  (j : TwistShout.CycleCube t) :
  ShiftedValEvaluationExpression init inc
      (TwistShout.bitAddress (K := K) a) (TwistShout.bitVec (K := K) j) =
    ShiftedTimeTable init inc a j := by
  simp [ShiftedValEvaluationExpression, ShiftedTimeTable,
    TwistShout.tableMLE_at_bitAddress,
    TwistShout.valEvaluationExpression_at_bitPoint]

theorem timeTableMLE_shiftedTimeTable_at_bitAddress
  {K : Type*} [Field K]
  {d m t : Nat}
  (init : TwistShout.PublicTable (K := K) d m)
  (inc : TwistShout.TimeTable (K := K) d m t)
  (a : TwistShout.Address d m)
  (rCycle : TwistShout.Point (K := K) t) :
  TwistShout.timeTableMLE (K := K) (ShiftedTimeTable init inc)
      (TwistShout.bitAddress (K := K) a) rCycle =
    ShiftedVirtualValue init inc a rCycle := by
  calc
    TwistShout.timeTableMLE (K := K) (ShiftedTimeTable init inc)
        (TwistShout.bitAddress (K := K) a) rCycle
      = ShiftedValEvaluationExpression init inc
          (TwistShout.bitAddress (K := K) a) rCycle := by
            exact shiftedValEvaluationExpression_eq_timeTableMLE init inc
              (TwistShout.bitAddress (K := K) a) rCycle
    _ = ShiftedVirtualValue init inc a rCycle := by
          unfold ShiftedValEvaluationExpression ShiftedVirtualValue
          rw [TwistShout.tableMLE_at_bitAddress]
          unfold TwistShout.valEvaluationExpression TwistShout.virtualValue
            TwistShout.addressIncrementTable
          apply congrArg (init a + ·)
          apply Finset.sum_congr rfl
          intro j _
          rw [TwistShout.incEvaluationTable_at_bitAddress (K := K) inc a j]

end Nightstream.NonZeroInitTwist

import SuperNeo.BarLift

/-!
Theorem-3 inner-product transform scaffold.

This file defines a compact inner-product identity boundary and provides the
native proof for the current bar-lift scaffold (`barLiftVector = id`).
-/

namespace SuperNeo

open F

/-- Dot/inner product with an explicit size guard. -/
def innerProduct (a b : Array F) : F :=
  if _h : a.size = b.size then
    (List.range a.size).foldl (fun acc i => acc + a[i]! * b[i]!) 0
  else
    0

/-- Theorem-facing Theorem-3 statement for bar-lifted inner products. -/
def thm3CoreAssumption (bar : Array (Array F)) : Prop :=
  ∀ a b : Array F,
    a.size = b.size →
    innerProduct a b = innerProduct (barLiftVector bar a) (barLiftVector bar b)

/-- Native Theorem-3 proof for the compact scaffold (`barLiftVector = id`). -/
theorem thm3CoreAssumption_native (bar : Array (Array F)) :
  thm3CoreAssumption bar := by
  intro a b hSize
  rw [barLiftVector_eq bar a, barLiftVector_eq bar b]

/-! ### P10 Compatibility Surface -/

/-- Dimension-shape predicate for vectors used by P10 compatibility wrappers. -/
def IsDVec (a : Array F) : Prop :=
  a.size = d

/-- Shape predicate for bar matrices used by P10 compatibility wrappers. -/
def IsDBarMatrix (_bar : Array (Array F)) : Prop :=
  True

/-- Compact P10 proposition surface on concrete vectors. -/
def p10CoreProp (bar : Array (Array F)) (a b : Array F) : Prop :=
  a.size = b.size ∧
    innerProduct a b = innerProduct (barLiftVector bar a) (barLiftVector bar b)

instance p10CoreProp_decidable (bar : Array (Array F)) (a b : Array F) :
    Decidable (p10CoreProp bar a b) := by
  unfold p10CoreProp
  infer_instance

/-- Executable P10 check surface on concrete vectors. -/
def p10CoreCheck (bar : Array (Array F)) (a b : Array F) : Bool :=
  decide (p10CoreProp bar a b)

theorem p10CoreCheck_sound
  {bar : Array (Array F)} {a b : Array F}
  (hOk : p10CoreCheck bar a b = true) :
  p10CoreProp bar a b := by
  unfold p10CoreCheck at hOk
  exact decide_eq_true_eq.mp hOk

theorem p10CoreCheck_complete
  {bar : Array (Array F)} {a b : Array F}
  (hProp : p10CoreProp bar a b) :
  p10CoreCheck bar a b = true := by
  unfold p10CoreCheck
  exact decide_eq_true hProp

/-- Build P10 proposition from shape preconditions and passing P10 check. -/
theorem p10Core_of_preconditions
  {bar : Array (Array F)} {a b : Array F}
  (_hBar : IsDBarMatrix bar)
  (_hA : IsDVec a)
  (_hB : IsDVec b)
  (hCheck : p10CoreCheck bar a b = true) :
  p10CoreProp bar a b := by
  exact p10CoreCheck_sound hCheck

/-- Build P10 proposition directly from Theorem-3 assumption plus shape preconditions. -/
theorem p10Core_of_preconditions_props
  {bar : Array (Array F)} {a b : Array F}
  (_hBar : IsDBarMatrix bar)
  (hA : IsDVec a)
  (hB : IsDVec b)
  (hThm3 : thm3CoreAssumption bar) :
  p10CoreProp bar a b := by
  have hSize : a.size = b.size := by
    simpa [IsDVec] using hA.trans hB.symm
  exact ⟨hSize, hThm3 a b hSize⟩

/-- Build P10 proposition from Theorem-3 assumption and vector shape assumptions. -/
theorem p10Core_of_assumption
  {bar : Array (Array F)} {a b : Array F}
  (hThm3 : thm3CoreAssumption bar)
  (hA : IsDVec a)
  (hB : IsDVec b) :
  p10CoreProp bar a b := by
  exact p10Core_of_preconditions_props (bar := bar) (a := a) (b := b) trivial hA hB hThm3


end SuperNeo

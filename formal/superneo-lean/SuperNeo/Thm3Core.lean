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

/--
Chunked branch closure contract for the real bar-lift operator.

This only assumes the `size % d = 0` branch preserves inner products. The
non-chunk branch is handled directly from `barLiftVector` definition.
-/
def barLiftChunkedIsometryAssumption (bar : Array (Array F)) : Prop :=
  ∀ a b : Array F, a.size = b.size → barLiftChunkableVec a →
    innerProduct a b = innerProduct (barLiftVector bar a) (barLiftVector bar b)

private theorem barLiftChunkable_of_size_eq
    {a b : Array F}
    (hSize : a.size = b.size)
    (hChunk : barLiftChunkableVec a) :
    barLiftChunkableVec b := by
  unfold barLiftChunkableVec at hChunk ⊢
  simpa [hSize] using hChunk

/--
Theorem-3 closure from the real bar-lift branch contract.

This discharges the non-chunk branch (`barLiftVector = id`) by definition and
uses the supplied chunked isometry only where the real bar-lift path is active.
-/
theorem thm3CoreAssumption_of_chunkedIsometry
    (bar : Array (Array F))
    (hChunkIso : barLiftChunkedIsometryAssumption bar) :
    thm3CoreAssumption bar := by
  intro a b hSize
  by_cases hChunk : barLiftChunkableVec a
  · exact hChunkIso a b hSize hChunk
  · have hChunkB : ¬ barLiftChunkableVec b := by
      intro hB
      exact hChunk (barLiftChunkable_of_size_eq hSize.symm hB)
    simp [barLiftVector, hChunk, hChunkB]

/--
Compatibility closure from identity-specialized bar blocks.

This theorem is kept as a compatibility bridge while Theorem-3 is now threaded
through the real bar-lift branch contract above.
-/
theorem thm3CoreAssumption_of_barBlockIdentity
    (bar : Array (Array F))
    (hId : barBlockIdentityAssumption bar) :
    thm3CoreAssumption bar := by
  intro a b hSize
  rw [barLiftVector_eq bar a hId, barLiftVector_eq bar b hId]

/-- Compatibility bridge: identity-specialized blocks imply chunked isometry. -/
theorem barLiftChunkedIsometryAssumption_of_barBlockIdentity
    (bar : Array (Array F))
    (hId : barBlockIdentityAssumption bar) :
    barLiftChunkedIsometryAssumption bar := by
  intro a b hSize _hChunk
  rw [barLiftVector_eq bar a hId, barLiftVector_eq bar b hId]

/--
Native Theorem-3 closure surface.

`thm3CoreAssumption_native` is now routed through the real bar-lift branch
contract instead of the bar-block identity assumption.
-/
theorem thm3CoreAssumption_native
    (bar : Array (Array F))
    (hChunkIso : barLiftChunkedIsometryAssumption bar) :
    thm3CoreAssumption bar := by
  exact thm3CoreAssumption_of_chunkedIsometry bar hChunkIso

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

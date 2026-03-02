import SuperNeo.BarLift

/-!
Contract interface for `SuperNeo.BarLift`.

Spec: `specs/BarLift.spec.md`

Paper anchors:
- Definition 8 (Lifting the Transform), Section 5, lines 376-382.
-/

namespace SuperNeo

namespace BarLiftInterface

/-! ## Core Surfaces -/

/-- [Status: Proved] Curated re-export of `barLiftVector`. -/
abbrev barLiftVector := SuperNeo.barLiftVector

/-- [Status: Proved] Curated re-export of `barLiftMatrix`. -/
abbrev barLiftMatrix := SuperNeo.barLiftMatrix

/-! ## Key Theorems -/

/-- [Status: Proved] Curated theorem surface `barLiftVector_eq`. -/
abbrev barLiftVector_eq := SuperNeo.barLiftVector_eq

/-- [Status: Proved] Curated theorem surface `barLiftMatrix_eq`. -/
abbrev barLiftMatrix_eq := SuperNeo.barLiftMatrix_eq

/-- [Status: Proved] Curated theorem surface `barLiftVector_add`. -/
abbrev barLiftVector_add := SuperNeo.barLiftVector_add

/-- [Status: Proved] Curated theorem surface `barLiftVector_scale`. -/
abbrev barLiftVector_scale := SuperNeo.barLiftVector_scale

/-! ## Boundary Surfaces -/

/-- [Status: Proved] Theorem-facing linearity boundary surface. -/
abbrev barLiftLinearityAssumption := SuperNeo.barLiftLinearityAssumption

/-- [Status: Proved] Check-facing linearity boundary surface. -/
abbrev barLiftLinearityCheckAssumption := SuperNeo.barLiftLinearityCheckAssumption

/-- [Status: Proved] Native closure of the theorem-facing linearity boundary. -/
theorem barLiftLinearityAssumption_native
  (bar : Array (Array F)) :
  barLiftLinearityAssumption bar :=
  SuperNeo.barLiftLinearityAssumption_native bar

/-- [Status: Proved] P9-threaded closure of the theorem-facing linearity boundary. -/
theorem barLiftLinearityAssumption_of_p9Embedding
  (bar : Array (Array F))
  (hP9 : p9EmbeddingAssumption) :
  barLiftLinearityAssumption bar :=
  SuperNeo.barLiftLinearityAssumption_of_p9Embedding bar hP9

/-- [Status: Proved] Closed P9 theorem-native linearity boundary. -/
theorem barLiftLinearityAssumption_of_p9Embedding_closed
  (bar : Array (Array F)) :
  barLiftLinearityAssumption bar :=
  SuperNeo.barLiftLinearityAssumption_of_p9Embedding_closed bar

/-- [Status: Proved] Conversion from theorem-facing to check-facing boundary. -/
theorem barLiftLinearityCheckAssumption_of_assumption
  {bar : Array (Array F)}
  (hAssm : barLiftLinearityAssumption bar) :
  barLiftLinearityCheckAssumption bar :=
  SuperNeo.barLiftLinearityCheckAssumption_of_assumption hAssm

/-- [Status: Proved] Conversion from check-facing to theorem-facing boundary. -/
theorem barLiftLinearityAssumption_of_checkAssumption
  {bar : Array (Array F)}
  (hCheck : barLiftLinearityCheckAssumption bar) :
  barLiftLinearityAssumption bar :=
  SuperNeo.barLiftLinearityAssumption_of_checkAssumption hCheck

/-- [Status: Proved] Equivalence between theorem and check boundaries. -/
theorem barLiftLinearityAssumption_iff_checkAssumption
  {bar : Array (Array F)} :
  barLiftLinearityAssumption bar ↔ barLiftLinearityCheckAssumption bar :=
  SuperNeo.barLiftLinearityAssumption_iff_checkAssumption

end BarLiftInterface

end SuperNeo

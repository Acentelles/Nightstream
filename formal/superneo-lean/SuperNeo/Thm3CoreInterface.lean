import SuperNeo.Thm3Core

/-!
Contract interface for `SuperNeo.Thm3Core`.

Spec: `specs/Thm3Core.spec.md`

Paper anchors:
- Theorem 3 (Inner Product Transform), Section 5, lines 368-372.
-/

namespace SuperNeo

namespace Thm3CoreInterface

/-! ## Core Surfaces -/

/-- [Role: Definitional] Curated re-export of `innerProduct`. -/
abbrev innerProduct := SuperNeo.innerProduct

/-- [Role: Definitional] Curated re-export of `IsDVec`. -/
abbrev IsDVec := SuperNeo.IsDVec

/-- [Role: Definitional] Curated re-export of `IsDBarMatrix`. -/
abbrev IsDBarMatrix := SuperNeo.IsDBarMatrix

/-- [Role: Definitional] Curated re-export of `p10CoreProp`. -/
abbrev p10CoreProp := SuperNeo.p10CoreProp

/-- [Role: Definitional] Curated re-export of `p10CoreCheck`. -/
abbrev p10CoreCheck := SuperNeo.p10CoreCheck

/-! ## Key Theorems -/

/-- [Role: Theorem-Target] Curated theorem surface `p10CoreCheck_sound`. -/
theorem p10CoreCheck_sound
    {bar : Array (Array F)} {a b : Array F}
    (hOk : p10CoreCheck bar a b = true) :
    p10CoreProp bar a b :=
  SuperNeo.p10CoreCheck_sound hOk

/-- [Role: Theorem-Target] Curated theorem surface `p10CoreCheck_complete`. -/
theorem p10CoreCheck_complete
    {bar : Array (Array F)} {a b : Array F}
    (hProp : p10CoreProp bar a b) :
    p10CoreCheck bar a b = true :=
  SuperNeo.p10CoreCheck_complete hProp

/-- [Role: Theorem-Target] Curated theorem surface `p10Core_of_preconditions`. -/
theorem p10Core_of_preconditions
    {bar : Array (Array F)} {a b : Array F}
    (hBar : IsDBarMatrix bar)
    (hA : IsDVec a)
    (hB : IsDVec b)
    (hCheck : p10CoreCheck bar a b = true) :
    p10CoreProp bar a b :=
  SuperNeo.p10Core_of_preconditions hBar hA hB hCheck

/-- [Role: Theorem-Target] Curated theorem surface `p10Core_of_preconditions_props`. -/
theorem p10Core_of_preconditions_props
    {bar : Array (Array F)} {a b : Array F}
    (hBar : IsDBarMatrix bar)
    (hA : IsDVec a)
    (hB : IsDVec b)
    (hThm3 : thm3CoreAssumption bar) :
    p10CoreProp bar a b :=
  SuperNeo.p10Core_of_preconditions_props hBar hA hB hThm3

/-! ## Boundary Surfaces -/

/-- [Role: Boundary] Theorem-3 boundary: ct(mulRq(bar(a), bar(b))) = ⟨a, b⟩ for d-sized blocks. -/
abbrev thm3CoreAssumption := SuperNeo.thm3CoreAssumption

/-- [Role: Theorem-Target] Derive P10 from Theorem-3 boundary and vector shape. -/
theorem p10Core_of_assumption
    {bar : Array (Array F)} {a b : Array F}
    (hThm3 : thm3CoreAssumption bar)
    (hA : IsDVec a)
    (hB : IsDVec b) :
    p10CoreProp bar a b :=
  SuperNeo.p10Core_of_assumption hThm3 hA hB

end Thm3CoreInterface

end SuperNeo

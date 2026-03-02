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

/-- [Status: Proved] Curated re-export of `innerProduct`. -/
abbrev innerProduct := SuperNeo.innerProduct

/-- [Status: Proved] Curated re-export of `IsDVec`. -/
abbrev IsDVec := SuperNeo.IsDVec

/-- [Status: Proved] Curated re-export of `IsDBarMatrix`. -/
abbrev IsDBarMatrix := SuperNeo.IsDBarMatrix

/-- [Status: Proved] Curated re-export of `p10CoreProp`. -/
abbrev p10CoreProp := SuperNeo.p10CoreProp

/-- [Status: Proved] Curated re-export of `p10CoreCheck`. -/
abbrev p10CoreCheck := SuperNeo.p10CoreCheck

/-! ## Key Theorems -/

/-- [Status: Proved] Curated theorem surface `p10CoreCheck_sound`. -/
abbrev p10CoreCheck_sound := SuperNeo.p10CoreCheck_sound

/-- [Status: Proved] Curated theorem surface `p10CoreCheck_complete`. -/
abbrev p10CoreCheck_complete := SuperNeo.p10CoreCheck_complete

/-- [Status: Proved] Curated theorem surface `p10Core_of_preconditions`. -/
abbrev p10Core_of_preconditions := SuperNeo.p10Core_of_preconditions

/-- [Status: Proved] Curated theorem surface `p10Core_of_preconditions_props`. -/
abbrev p10Core_of_preconditions_props := SuperNeo.p10Core_of_preconditions_props

/-! ## Boundary Surfaces -/

/-- [Status: Boundary-Assumed] Boundary surface `thm3CoreAssumption` requiring closure. -/
abbrev thm3CoreAssumption := SuperNeo.thm3CoreAssumption

/-- [Status: Boundary-Assumed] Boundary surface `thm3CoreAssumption_native` requiring closure. -/
abbrev thm3CoreAssumption_native := SuperNeo.thm3CoreAssumption_native

/-- [Status: Boundary-Assumed] Boundary surface `p10Core_of_assumption` requiring closure. -/
abbrev p10Core_of_assumption := SuperNeo.p10Core_of_assumption

end Thm3CoreInterface

end SuperNeo

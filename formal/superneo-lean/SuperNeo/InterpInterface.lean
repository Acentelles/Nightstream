import SuperNeo.Interp

/-!
Contract interface for `SuperNeo.Interp`.

Spec: `specs/Interp.spec.md`

Paper anchors:
- Infrastructure module supporting evaluation checks in Sections 7.3-7.4.
-/

namespace SuperNeo

namespace InterpInterface

/-! ## Core Surfaces -/

/-- [Status: Proved] Curated re-export of `interpolationProp`. -/
abbrev interpolationProp := SuperNeo.interpolationProp

/-- [Status: Proved] Curated re-export of `interpolationCase`. -/
abbrev interpolationCase := SuperNeo.interpolationCase

/-! ## Key Theorems -/

/-- [Status: Proved] Curated theorem surface `interpolationCase_sound`. -/
abbrev interpolationCase_sound := SuperNeo.interpolationCase_sound

/-- [Status: Proved] Curated theorem surface `interpolationCase_complete`. -/
abbrev interpolationCase_complete := SuperNeo.interpolationCase_complete

/-! ## Boundary Surfaces -/

/-- [Status: Boundary-Assumed] Boundary surface `interpolationAssumption` requiring closure. -/
abbrev interpolationAssumption := SuperNeo.interpolationAssumption

end InterpInterface

end SuperNeo

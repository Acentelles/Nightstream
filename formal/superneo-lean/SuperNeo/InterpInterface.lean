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

/-- [Role: Theorem-Target] Curated re-export of `interpolationProp`. -/
abbrev interpolationProp := SuperNeo.interpolationProp

/-- [Role: Theorem-Target] Curated re-export of `interpolationCase`. -/
abbrev interpolationCase := SuperNeo.interpolationCase

/-! ## Key Theorems -/

/-- [Role: Theorem-Target] Curated theorem surface `interpolationCase_sound`. -/
abbrev interpolationCase_sound := SuperNeo.interpolationCase_sound

/-- [Role: Theorem-Target] Curated theorem surface `interpolationCase_complete`. -/
abbrev interpolationCase_complete := SuperNeo.interpolationCase_complete

/-! ## Boundary Surfaces -/

/-- [Role: Boundary] Boundary surface `interpolationAssumption` requiring closure. -/
abbrev interpolationAssumption := SuperNeo.interpolationAssumption

end InterpInterface

end SuperNeo

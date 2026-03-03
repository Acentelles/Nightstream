import SuperNeo.InvertibilityAxioms

/-!
Contract interface for `SuperNeo.InvertibilityAxioms`.

Spec: `specs/InvertibilityAxioms.spec.md`

Paper anchors:
- Theorem 8 (Low-norm invertibility), Section 5/6, lines 375-378.
-/

namespace SuperNeo

namespace InvertibilityAxiomsInterface

/-! ## Core Surfaces -/

/-- [Role: Theorem-Target] Curated re-export of `invertibleRq`. -/
abbrev invertibleRq := SuperNeo.invertibleRq

/-- [Role: Theorem-Target] Curated re-export of `invertibilityWindowProp`. -/
abbrev invertibilityWindowProp := SuperNeo.invertibilityWindowProp

/-- [Role: Theorem-Target] Curated re-export of `invertibilityPreconditionsProp`. -/
abbrev invertibilityPreconditionsProp := SuperNeo.invertibilityPreconditionsProp

/-! ## Key Theorems -/

/-- [Role: Theorem-Target] Curated theorem surface `invertibilityPreconditions_from_constants`. -/
abbrev invertibilityPreconditions_from_constants := SuperNeo.invertibilityPreconditions_from_constants

/-! ## Boundary Surfaces -/

/-- [Role: Boundary] Boundary surface `lowNormInvertibilityAssumption` requiring closure. -/
abbrev lowNormInvertibilityAssumption := SuperNeo.lowNormInvertibilityAssumption

/-- [Role: Boundary] Boundary surface `invertibleRq_of_lowNormAssumption` requiring closure. -/
abbrev invertibleRq_of_lowNormAssumption := SuperNeo.invertibleRq_of_lowNormAssumption

end InvertibilityAxiomsInterface

end SuperNeo

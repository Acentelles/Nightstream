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

/-- [Status: Proved] Curated re-export of `invertibleRq`. -/
abbrev invertibleRq := SuperNeo.invertibleRq

/-- [Status: Proved] Curated re-export of `invertibilityWindowProp`. -/
abbrev invertibilityWindowProp := SuperNeo.invertibilityWindowProp

/-- [Status: Proved] Curated re-export of `invertibilityPreconditionsProp`. -/
abbrev invertibilityPreconditionsProp := SuperNeo.invertibilityPreconditionsProp

/-! ## Key Theorems -/

/-- [Status: Proved] Curated theorem surface `invertibilityPreconditions_from_constants`. -/
abbrev invertibilityPreconditions_from_constants := SuperNeo.invertibilityPreconditions_from_constants

/-! ## Boundary Surfaces -/

/-- [Status: Boundary-Assumed] Boundary surface `lowNormInvertibilityAssumption` requiring closure. -/
abbrev lowNormInvertibilityAssumption := SuperNeo.lowNormInvertibilityAssumption

/-- [Status: Boundary-Assumed] Boundary surface `invertibleRq_of_lowNormAssumption` requiring closure. -/
abbrev invertibleRq_of_lowNormAssumption := SuperNeo.invertibleRq_of_lowNormAssumption

end InvertibilityAxiomsInterface

end SuperNeo

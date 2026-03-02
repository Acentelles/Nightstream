import SuperNeo.SamplingSet

/-!
Contract interface for `SuperNeo.SamplingSet`.

Spec: `specs/SamplingSet.spec.md`

Paper anchors:
- Definition 17 (Strong sampling sets), Theorem 9 (Expansion factors), lines 379-383.
-/

namespace SuperNeo

namespace SamplingSetInterface

/-! ## Core Surfaces -/

/-- [Status: Proved] Curated re-export of `samplingNormBoundProp`. -/
abbrev samplingNormBoundProp := SuperNeo.samplingNormBoundProp

/-- [Status: Proved] Curated re-export of `samplingExpansionProp`. -/
abbrev samplingExpansionProp := SuperNeo.samplingExpansionProp

/-! ## Key Theorems -/

/-- [Status: Proved] Curated theorem surface `samplingExpansionProp_of_bounds`. -/
abbrev samplingExpansionProp_of_bounds := SuperNeo.samplingExpansionProp_of_bounds

/-- [Status: Proved] Curated theorem surface `samplingSetBoundCheck_sound`. -/
abbrev samplingSetBoundCheck_sound := SuperNeo.samplingSetBoundCheck_sound

/-- [Status: Proved] Curated theorem surface `samplingSetBoundCheck_complete`. -/
abbrev samplingSetBoundCheck_complete := SuperNeo.samplingSetBoundCheck_complete

end SamplingSetInterface

end SuperNeo

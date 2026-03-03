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

/-- [Status: Proved] Curated re-export of `SamplingCarrier`. -/
abbrev SamplingCarrier := SuperNeo.SamplingCarrier

/-- [Status: Proved] Curated re-export of `samplingDiffSet`. -/
abbrev samplingDiffSet := SuperNeo.samplingDiffSet

/-- [Status: Proved] Curated re-export of `strongSamplingExpansionProp`. -/
abbrev strongSamplingExpansionProp := SuperNeo.strongSamplingExpansionProp

/-- [Status: Proved] Curated re-export of `ringNormCarrier`. -/
abbrev ringNormCarrier := SuperNeo.ringNormCarrier

/-- [Status: Proved] Curated re-export of `paperCarrier`. -/
abbrev paperCarrier := SuperNeo.paperCarrier

/-! ## Key Theorems -/

/-- [Status: Proved] Curated theorem surface `samplingExpansionProp_of_bounds`. -/
theorem samplingExpansionProp_of_bounds
  {cset samples : Array Coeffs}
  {B : Nat}
  (hCset : ∀ i : Fin cset.size, normInfCoeffs cset[i] ≤ B)
  (hSamples : ∀ j : Fin samples.size, normInfCoeffs samples[j] ≤ B) :
  samplingExpansionProp cset samples :=
  SuperNeo.samplingExpansionProp_of_bounds hCset hSamples

/-- [Status: Proved] Curated theorem surface `samplingNormBoundProp_left`. -/
theorem samplingNormBoundProp_left
  {cset samples : Array Coeffs}
  {B : Nat}
  (h : samplingNormBoundProp cset samples B) :
  ∀ i : Fin cset.size, normInfCoeffs cset[i] ≤ B :=
  SuperNeo.samplingNormBoundProp_left h

/-- [Status: Proved] Curated theorem surface `samplingNormBoundProp_right`. -/
theorem samplingNormBoundProp_right
  {cset samples : Array Coeffs}
  {B : Nat}
  (h : samplingNormBoundProp cset samples B) :
  ∀ j : Fin samples.size, normInfCoeffs samples[j] ≤ B :=
  SuperNeo.samplingNormBoundProp_right h

/-- [Status: Proved] Curated theorem surface `samplingNormBoundProp_mono`. -/
theorem samplingNormBoundProp_mono
  {cset samples : Array Coeffs}
  {B B' : Nat}
  (h : samplingNormBoundProp cset samples B)
  (hBB' : B ≤ B') :
  samplingNormBoundProp cset samples B' :=
  SuperNeo.samplingNormBoundProp_mono h hBB'

/-- [Status: Proved] Curated theorem surface `samplingExpansionProp_mono`. -/
theorem samplingExpansionProp_mono
  {cset samples : Array Coeffs}
  {B B' : Nat}
  (h : samplingNormBoundProp cset samples B)
  (hBB' : B ≤ B') :
  samplingExpansionProp cset samples :=
  SuperNeo.samplingExpansionProp_mono h hBB'

/-- [Status: Proved] Curated theorem surface `samplingExpansionProp_empty`. -/
theorem samplingExpansionProp_empty :
  samplingExpansionProp (#[] : Array Coeffs) (#[] : Array Coeffs) :=
  SuperNeo.samplingExpansionProp_empty

/-- [Status: Proved] Curated theorem surface `samplingSetBoundCheck_sound`. -/
theorem samplingSetBoundCheck_sound
  {cset samples : Array Coeffs}
  (hOk : SuperNeo.samplingSetBoundCheck cset samples = true) :
  samplingExpansionProp cset samples :=
  SuperNeo.samplingSetBoundCheck_sound hOk

/-- [Status: Proved] Curated theorem surface `samplingSetBoundCheck_complete`. -/
theorem samplingSetBoundCheck_complete
  {cset samples : Array Coeffs}
  (hProp : samplingExpansionProp cset samples) :
  SuperNeo.samplingSetBoundCheck cset samples = true :=
  SuperNeo.samplingSetBoundCheck_complete hProp

/-- [Status: Proved] Curated theorem surface `samplingSetBoundCheck_iff`. -/
theorem samplingSetBoundCheck_iff
  {cset samples : Array Coeffs} :
  SuperNeo.samplingSetBoundCheck cset samples = true ↔ samplingExpansionProp cset samples :=
  SuperNeo.samplingSetBoundCheck_iff

/-- [Status: Proved] Curated theorem surface `strongSamplingExpansionProp_mono`. -/
theorem strongSamplingExpansionProp_mono
  {C : SamplingCarrier}
  {T T' : Nat}
  (h : strongSamplingExpansionProp C T)
  (hTT' : T ≤ T') :
  strongSamplingExpansionProp C T' :=
  SuperNeo.strongSamplingExpansionProp_mono h hTT'

/-- [Status: Proved] Curated theorem surface `expansionFactor_of_strongSampling`. -/
theorem expansionFactor_of_strongSampling
  {C : SamplingCarrier}
  {T : Nat}
  (h : strongSamplingExpansionProp C T)
  {δ z : Coeffs}
  (hδ : samplingDiffSet C δ)
  {B : Nat}
  (hB : normInfCoeffs z ≤ B) :
  normInfCoeffs (mulRq δ z) ≤ 4 * T * B :=
  SuperNeo.expansionFactor_of_strongSampling h hδ hB

/-- [Status: Proved] Curated theorem surface `strongSamplingExpansionProp_of_ringNormCarrier`. -/
theorem strongSamplingExpansionProp_of_ringNormCarrier
  {K T D : Nat}
  (hSub : coeffSubNormBoundFromOperands K K D)
  (hMul : ∀ B : Nat, mulRqNormBoundFromOperands D B (4 * T * B)) :
  strongSamplingExpansionProp (ringNormCarrier K) T :=
  SuperNeo.strongSamplingExpansionProp_of_ringNormCarrier hSub hMul

/-- [Status: Proved] Curated theorem surface `strongSamplingExpansionProp_of_paperCarrier`. -/
theorem strongSamplingExpansionProp_of_paperCarrier
  {T D : Nat}
  (hSub : coeffSubNormBoundFromOperands 2 2 D)
  (hMul : ∀ B : Nat, mulRqNormBoundFromOperands D B (4 * T * B)) :
  strongSamplingExpansionProp paperCarrier T :=
  SuperNeo.strongSamplingExpansionProp_of_paperCarrier hSub hMul

end SamplingSetInterface

end SuperNeo

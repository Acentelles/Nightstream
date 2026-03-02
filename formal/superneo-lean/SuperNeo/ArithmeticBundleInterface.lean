import SuperNeo.ArithmeticBundle

/-!
Contract interface for `SuperNeo.ArithmeticBundle`.

Spec: ./formal/superneo-lean/specs/ArithmeticBundle.spec.md

Paper anchors (Source: ./formal/superneo-lean/SuperNeo.pdf.md):
- Section 4 (Preliminaries): decomposition, matrix transform, evaluation homomorphism.
- Section 5 (Embedding products): Theorem 4 (Mz = ct(M̄z)), Theorem 5 (Evaluation homomorphism).
- Section 7 (Folding scheme): arithmetic obligations composed for protocol context, lines 449-596.
-/

namespace SuperNeo

namespace ArithmeticBundleInterface

/-! ## Core Surfaces -/

/-- [Status: Proved] Curated re-export of `arithmeticEvalHomProp`. -/
abbrev arithmeticEvalHomProp := SuperNeo.arithmeticEvalHomProp

/-- [Status: Proved] Curated re-export of `arithmeticVecModuleProp`. -/
abbrev arithmeticVecModuleProp := SuperNeo.arithmeticVecModuleProp

/-- [Status: Proved] Curated re-export of `arithmeticScalarModuleProp`. -/
abbrev arithmeticScalarModuleProp := SuperNeo.arithmeticScalarModuleProp

/-- [Status: Proved] Curated re-export of `arithmeticSamplingProp`. -/
abbrev arithmeticSamplingProp := SuperNeo.arithmeticSamplingProp

/-- [Status: Proved] Curated re-export of `arithmeticPolyProp`. -/
abbrev arithmeticPolyProp := SuperNeo.arithmeticPolyProp

/-- [Status: Proved] Curated re-export of `arithmeticDecompProp`. -/
abbrev arithmeticDecompProp := SuperNeo.arithmeticDecompProp

/-- [Status: Proved] Curated re-export of `arithmeticInterpProp`. -/
abbrev arithmeticInterpProp := SuperNeo.arithmeticInterpProp

/-- [Status: Proved] Curated re-export of `arithmeticBundleProp`. -/
abbrev arithmeticBundleProp := SuperNeo.arithmeticBundleProp

/-! ## Key Theorems -/

/-- [Status: Proved] Curated theorem surface `arithmeticDecompProp_iff_splitRoundTrip_true`. -/
abbrev arithmeticDecompProp_iff_splitRoundTrip_true := @SuperNeo.arithmeticDecompProp_iff_splitRoundTrip_true

/-- [Status: Proved] Curated theorem surface `arithmeticBundleProp_of_props`. -/
abbrev arithmeticBundleProp_of_props := @SuperNeo.arithmeticBundleProp_of_props

/-- [Status: Proved] Theorem-native constructor threading `(P10 + P11)` into P20 obligations. -/
abbrev arithmeticBundleProp_of_theorem_stack := @SuperNeo.arithmeticBundleProp_of_theorem_stack

/-- [Status: Proved] Curated theorem surface `arithmeticBundleProp_checks_imply_props`. -/
abbrev arithmeticBundleProp_checks_imply_props := @SuperNeo.arithmeticBundleProp_checks_imply_props

/-- [Status: Proved] Curated theorem surface `arithmeticBundleProp_props_imply_check_subset`. -/
abbrev arithmeticBundleProp_props_imply_check_subset := @SuperNeo.arithmeticBundleProp_props_imply_check_subset

/-- [Status: Proved] Curated theorem surface `arithmeticBundleProp_props_imply_module_checks`. -/
abbrev arithmeticBundleProp_props_imply_module_checks := @SuperNeo.arithmeticBundleProp_props_imply_module_checks

/-- [Status: Proved] Curated theorem surface `arithmeticBundleProp_of_checks`. -/
abbrev arithmeticBundleProp_of_checks := @SuperNeo.arithmeticBundleProp_of_checks

end ArithmeticBundleInterface

end SuperNeo

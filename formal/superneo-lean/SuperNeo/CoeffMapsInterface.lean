import SuperNeo.CoeffMaps

/-!
Contract interface for `SuperNeo.CoeffMaps`.

Spec: `specs/CoeffMaps.spec.md`

Paper anchors:
- Definition 2, Section 4, lines 284-288: `cf : R_q → F_q^d` and `cf⁻¹ : F_q^d → R_q`.
-/

namespace SuperNeo

namespace CoeffMapsInterface

/-! ## Core Surfaces -/

/-- [Status: Proved] Curated re-export of `cf`. -/
abbrev cf := SuperNeo.cf

/-- [Status: Proved] Curated re-export of `cfInv`. -/
abbrev cfInv := SuperNeo.cfInv

/-- [Status: Proved] Curated re-export of `coeffMapRoundTripProp`. -/
abbrev coeffMapRoundTripProp := SuperNeo.coeffMapRoundTripProp

/-- [Status: Proved] Curated re-export of `coeffMapRoundTrip`. -/
abbrev coeffMapRoundTrip := SuperNeo.coeffMapRoundTrip

/-! ## Key Theorems -/

/-- [Status: Proved] Curated theorem surface `cfInv_cf`. -/
abbrev cfInv_cf := SuperNeo.cfInv_cf

/-- [Status: Proved] Curated theorem surface `cf_cfInv`. -/
abbrev cf_cfInv := SuperNeo.cf_cfInv

/-- [Status: Proved] Curated theorem surface `cf_size`. -/
abbrev cf_size := SuperNeo.cf_size

/-- [Status: Proved] Curated theorem surface `cfInv_size`. -/
abbrev cfInv_size := SuperNeo.cfInv_size

/-- [Status: Proved] Curated theorem surface `ct_cf`. -/
abbrev ct_cf := SuperNeo.ct_cf

/-- [Status: Proved] Curated theorem surface `ct_cfInv`. -/
abbrev ct_cfInv := SuperNeo.ct_cfInv

end CoeffMapsInterface

end SuperNeo

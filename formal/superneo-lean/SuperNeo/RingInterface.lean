import SuperNeo.Ring

/-!
Contract interface for `SuperNeo.Ring`.

Spec: `specs/Ring.spec.md`

Paper anchors:
- Definition 1, Section 4, lines 275-282: `R_F = F[X]/Φ(X)`, degree `d`.
- Section 7.3, lines 440-470: folding linear combination `z' = ρ₁·z₁ + ρ₂·z₂`.
-/

namespace SuperNeo

namespace RingInterface

/-! ## Core Surfaces -/

/-- [Status: Proved] Curated re-export of `d`. -/
abbrev d := SuperNeo.d

/-- [Status: Proved] Curated re-export of `Coeffs`. -/
abbrev Coeffs := SuperNeo.Coeffs

/-- [Status: Proved] Curated re-export of `vecAdd`. -/
abbrev vecAdd := SuperNeo.vecAdd

/-- [Status: Proved] Curated re-export of `vecScale`. -/
abbrev vecScale := SuperNeo.vecScale

/-- [Status: Proved] Curated re-export of `linComb2Vec`. -/
abbrev linComb2Vec := SuperNeo.linComb2Vec

/-- [Status: Proved] Curated re-export of `ct`. -/
abbrev ct := SuperNeo.ct

/-- [Status: Proved] Curated re-export of `coeffAt`. -/
abbrev coeffAt := SuperNeo.coeffAt

/-- [Status: Proved] Curated re-export of `mulRq`. -/
abbrev mulRq := SuperNeo.mulRq

/-! ## Key Theorems -/

/-- [Status: Proved] Curated theorem surface `d_pos`. -/
abbrev d_pos := SuperNeo.d_pos

/-- [Status: Proved] Curated theorem surface `vecScale_size`. -/
abbrev vecScale_size := SuperNeo.vecScale_size

/-- [Status: Proved] Curated theorem surface `vecAdd_size_of_eq`. -/
abbrev vecAdd_size_of_eq := SuperNeo.vecAdd_size_of_eq

/-- [Status: Proved] Curated theorem surface `vecAdd_size_of_ne`. -/
abbrev vecAdd_size_of_ne := SuperNeo.vecAdd_size_of_ne

/-- [Status: Proved] Curated theorem surface `linComb2Vec_size_of_eq`. -/
abbrev linComb2Vec_size_of_eq := SuperNeo.linComb2Vec_size_of_eq

/-- [Status: Proved] Curated theorem surface `mulRq_size`. -/
abbrev mulRq_size := SuperNeo.mulRq_size

end RingInterface

end SuperNeo

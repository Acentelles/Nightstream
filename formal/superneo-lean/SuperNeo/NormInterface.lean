import SuperNeo.Norm

/-!
Contract interface for `SuperNeo.Norm`.

Spec: `specs/Norm.spec.md`

Paper anchors:
- Definition 3, Section 4, lines 290-291: `‖·‖_∞` on ring elements via coefficients.
- Theorem 8, Section 6, lines 375-378: norm bounds enter security parameter.
-/

namespace SuperNeo

namespace NormInterface

/-! ## Core Surfaces -/

/-- [Status: Proved] Curated re-export of `normInfF`. -/
abbrev normInfF := SuperNeo.normInfF

/-- [Status: Proved] Curated re-export of `normInfCoeffs`. -/
abbrev normInfCoeffs := SuperNeo.normInfCoeffs

/-- [Status: Proved] Curated re-export of `maxRhoNorm`. -/
abbrev maxRhoNorm := SuperNeo.maxRhoNorm

/-- [Status: Proved] Curated re-export of `vecAddNormBoundFromOperands`. -/
abbrev vecAddNormBoundFromOperands := SuperNeo.vecAddNormBoundFromOperands

/-- [Status: Proved] Curated re-export of `vecScaleNormBoundFromOperands`. -/
abbrev vecScaleNormBoundFromOperands := SuperNeo.vecScaleNormBoundFromOperands

/-- [Status: Proved] Curated re-export of `mulRqNormBoundFromOperands`. -/
abbrev mulRqNormBoundFromOperands := SuperNeo.mulRqNormBoundFromOperands

/-- [Status: Proved] Curated re-export of `coeffSubNormBoundFromOperands`. -/
abbrev coeffSubNormBoundFromOperands := SuperNeo.coeffSubNormBoundFromOperands

/-- [Status: Proved] Curated re-export of `AllChallengeCoeffs`. -/
abbrev AllChallengeCoeffs := SuperNeo.AllChallengeCoeffs

/-! ## Key Theorems -/

/-- [Status: Proved] Curated theorem surface `normInfF_zero`. -/
abbrev normInfF_zero := SuperNeo.normInfF_zero

/-- [Status: Proved] Curated theorem surface `normInfCoeffs_empty`. -/
abbrev normInfCoeffs_empty := SuperNeo.normInfCoeffs_empty

/-- [Status: Proved] Curated theorem surface `normInfCoeffs_nonneg`. -/
abbrev normInfCoeffs_nonneg := SuperNeo.normInfCoeffs_nonneg

/-- [Status: Proved] Curated theorem surface `maxRhoNorm_nonneg`. -/
abbrev maxRhoNorm_nonneg := SuperNeo.maxRhoNorm_nonneg

/-- [Status: Proved] Curated theorem surface `allChallengeCoeffs_empty`. -/
abbrev allChallengeCoeffs_empty := SuperNeo.allChallengeCoeffs_empty

end NormInterface

end SuperNeo

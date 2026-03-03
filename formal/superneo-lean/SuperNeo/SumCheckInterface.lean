import SuperNeo.SumCheck

/-!
Contract interface for `SuperNeo.SumCheck`.

Spec: `specs/SumCheck.spec.md`

Paper anchors:
- Definition 6, Section 4, lines 352-355: sum-check protocol.
- Section 7.3 (Π_CCS), lines 440-470: sum-check invocation in CCS folding.
- Section 7.4 (Π_RLC), lines 471-489: sum-check invocation in RLC.
-/

namespace SuperNeo

namespace SumCheckInterface

/-! ## Core Surfaces -/

/-- [Role: Theorem-Target] Curated re-export of `SumCheckInstance`. -/
abbrev SumCheckInstance := SuperNeo.SumCheckInstance

/-- [Role: Theorem-Target] Curated re-export of `SumCheckTranscript`. -/
abbrev SumCheckTranscript := SuperNeo.SumCheckTranscript

/-- [Role: Theorem-Target] Curated re-export of `sumcheckEvalPoly`. -/
abbrev sumcheckEvalPoly := SuperNeo.sumcheckEvalPoly

/-- [Role: Theorem-Target] Curated re-export of `sumcheckRoundConsistent`. -/
abbrev sumcheckRoundConsistent := SuperNeo.sumcheckRoundConsistent

/-- [Role: Theorem-Target] Curated re-export of `sumcheckRoundPolyShape`. -/
abbrev sumcheckRoundPolyShape := SuperNeo.sumcheckRoundPolyShape

/-- [Role: Theorem-Target] Curated re-export of `sumcheckRoundShapes`. -/
abbrev sumcheckRoundShapes := SuperNeo.sumcheckRoundShapes

/-- [Role: Theorem-Target] Curated re-export of `sumcheckFoldConsistent`. -/
abbrev sumcheckFoldConsistent := SuperNeo.sumcheckFoldConsistent

/-- [Role: Theorem-Target] Curated re-export of `sumcheckInitialRoundConsistent`. -/
abbrev sumcheckInitialRoundConsistent := SuperNeo.sumcheckInitialRoundConsistent

/-! ## Key Theorems -/

/-- [Role: Theorem-Target] Curated theorem surface `sumcheckAccepted_rounds_eq`. -/
abbrev sumcheckAccepted_rounds_eq := SuperNeo.sumcheckAccepted_rounds_eq

/-- [Role: Theorem-Target] Curated theorem surface `sumcheckAccepted_challenges_eq`. -/
abbrev sumcheckAccepted_challenges_eq := SuperNeo.sumcheckAccepted_challenges_eq

/-- [Role: Theorem-Target] Curated theorem surface `sumcheckAccepted_fold_step`. -/
abbrev sumcheckAccepted_fold_step := SuperNeo.sumcheckAccepted_fold_step

/-- [Role: Theorem-Target] Curated theorem surface `sumcheckAccepted_initial_round`. -/
abbrev sumcheckAccepted_initial_round := SuperNeo.sumcheckAccepted_initial_round

/-- [Role: Theorem-Target] Curated theorem surface `sumcheckAccepted_round_sum_step`. -/
abbrev sumcheckAccepted_round_sum_step := SuperNeo.sumcheckAccepted_round_sum_step

/-- [Role: Theorem-Target] Curated theorem surface `sumcheckAccepted_not_of_challenge_size_ne`. -/
abbrev sumcheckAccepted_not_of_challenge_size_ne := SuperNeo.sumcheckAccepted_not_of_challenge_size_ne

/-! ## Boundary Surfaces -/

/-- [Role: Boundary] Boundary surface `SumcheckSoundnessAssumption` requiring closure. -/
abbrev SumcheckSoundnessAssumption := SuperNeo.SumcheckSoundnessAssumption

/-- [Role: Boundary] Boundary surface `SumcheckCompletenessAssumption` requiring closure. -/
abbrev SumcheckCompletenessAssumption := SuperNeo.SumcheckCompletenessAssumption

/-- [Role: Boundary] Boundary surface `SumCheckAssumptions` requiring closure. -/
abbrev SumCheckAssumptions := SuperNeo.SumCheckAssumptions

/-- [Role: Boundary] Boundary surface `sumcheckClaimTrue_of_soundness` requiring closure. -/
abbrev sumcheckClaimTrue_of_soundness := SuperNeo.sumcheckClaimTrue_of_soundness

end SumCheckInterface

end SuperNeo

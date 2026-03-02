import SuperNeo.ProtocolRelations

/-!
Contract interface for `SuperNeo.ProtocolRelations`.

Spec: ./formal/superneo-lean/specs/ProtocolRelations.spec.md

Paper anchors (Source: ./formal/superneo-lean/SuperNeo.pdf.md):
- Definition 12 (Norm-bounded CCS), Section 7.1, lines 457-459.
- Definition 13 (Norm-bounded CCS Evaluation Relation), Section 7.1, lines 461-465.
- Section 7.1 (Relations), lines 449-465.
-/

namespace SuperNeo

namespace ProtocolRelationsInterface

/-! ## Core Surfaces -/

/-- [Status: Proved] Curated re-export of `sumcheckInstanceOfContext`. -/
abbrev sumcheckInstanceOfContext := SuperNeo.sumcheckInstanceOfContext

/-- [Status: Proved] Curated re-export of `ccsRelation`. -/
abbrev ccsRelation := SuperNeo.ccsRelation

/-- [Status: Proved] Curated re-export of `ceRelation`. -/
abbrev ceRelation := SuperNeo.ceRelation

/-- [Status: Proved] Curated re-export of `ceRelaxedRelation`. -/
abbrev ceRelaxedRelation := SuperNeo.ceRelaxedRelation

/-! ## Key Theorems -/

/-- [Status: Proved] Curated theorem surface `ceRelation_of_claimTrue`. -/
abbrev ceRelation_of_claimTrue := SuperNeo.ceRelation_of_claimTrue

/-- [Status: Proved] Curated theorem surface `ceClaimTrue_of_ce`. -/
abbrev ceClaimTrue_of_ce := SuperNeo.ceClaimTrue_of_ce

/-- [Status: Proved] Curated theorem surface `ceRelaxedRelation_of_ce`. -/
abbrev ceRelaxedRelation_of_ce := SuperNeo.ceRelaxedRelation_of_ce

/-! ## Boundary Surfaces -/

/-- [Status: Boundary-Assumed] Boundary surface `SumCheckTransitionWitness` requiring closure. -/
abbrev SumCheckTransitionWitness := SuperNeo.SumCheckTransitionWitness

/-- [Status: Boundary-Assumed] Boundary surface `SumCheckTransitionWitness.accepted_exists` requiring closure. -/
abbrev SumCheckTransitionWitness_accepted_exists := SuperNeo.SumCheckTransitionWitness.accepted_exists

/-- [Status: Boundary-Assumed] Boundary surface `ProtocolRelationsAssumptions` requiring closure. -/
abbrev ProtocolRelationsAssumptions := SuperNeo.ProtocolRelationsAssumptions

/-- [Status: Boundary-Assumed] Boundary surface `ccsRelation_of_assumptions` requiring closure. -/
abbrev ccsRelation_of_assumptions := SuperNeo.ccsRelation_of_assumptions

/-- [Status: Boundary-Assumed] Boundary surface `ceRelation_of_assumptions` requiring closure. -/
abbrev ceRelation_of_assumptions := SuperNeo.ceRelation_of_assumptions

end ProtocolRelationsInterface

end SuperNeo

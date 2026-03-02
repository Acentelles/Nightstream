import SuperNeo.PiDEC

/-!
Contract interface for `SuperNeo.PiDEC`.

Spec: ./formal/superneo-lean/specs/PiDEC.spec.md

Paper anchors (Source: ./formal/superneo-lean/SuperNeo.pdf.md):
- Section 7.5 (Π_DEC), lines 585-593.
- Theorem 7 (Π_DEC is reduction of knowledge), lines 594-596.
-/

namespace SuperNeo

namespace PiDECInterface

/-! ## Core Surfaces -/

/-- [Status: Proved] Curated re-export of `piDECKnowledgeStatement`. -/
abbrev piDECKnowledgeStatement := SuperNeo.piDECKnowledgeStatement

/-! ## Boundary Surfaces -/

/-- [Status: Boundary-Assumed] Boundary surface `PiDECAssumptions` requiring closure. -/
abbrev PiDECAssumptions := SuperNeo.PiDECAssumptions

/-- [Status: Boundary-Assumed] Boundary surface `piDEC_of_assumptions` requiring closure. -/
abbrev piDEC_of_assumptions := SuperNeo.piDEC_of_assumptions

end PiDECInterface

end SuperNeo

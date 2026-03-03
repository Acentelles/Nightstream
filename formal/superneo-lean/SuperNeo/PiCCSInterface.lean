import SuperNeo.PiCCS

/-!
Contract interface for `SuperNeo.PiCCS`.

Spec: ./formal/superneo-lean/specs/PiCCS.spec.md

Paper anchors (Source: ./formal/superneo-lean/SuperNeo.pdf.md):
- Section 7.3 (Π_CCS), lines 481-548.
- Lemma 3 (Π_CCS is strong), lines 545-546.
-/

namespace SuperNeo

namespace PiCCSInterface

/-! ## Core Surfaces -/

/-- [Role: Theorem-Target] Curated re-export of `piCCSStrongStatement`. -/
abbrev piCCSStrongStatement := SuperNeo.piCCSStrongStatement

/-! ## Boundary Surfaces -/

/-- [Role: Boundary] Boundary surface `PiCCSAssumptions` requiring closure. -/
abbrev PiCCSAssumptions := SuperNeo.PiCCSAssumptions

/-- [Role: Boundary] Boundary surface `piCCSStrong_of_assumptions` requiring closure. -/
abbrev piCCSStrong_of_assumptions := SuperNeo.piCCSStrong_of_assumptions

end PiCCSInterface

end SuperNeo

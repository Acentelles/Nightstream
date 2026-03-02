import SuperNeo.ProtocolTarget

/-!
Contract interface for `SuperNeo.ProtocolTarget`.

Spec: `./formal/superneo-lean/specs/ProtocolTarget.spec.md`

Paper anchors (Source: `./formal/superneo-lean/SuperNeo.pdf.md`):
- Section 7 (Neo's folding scheme for CCS), lines 447–481: Relations (Definitions 11–13), Global Reduction Parameters (Definition 14)
- Section 7.3 (Π_CCS), lines 481–547: Interactive reduction for CCS
-/

namespace SuperNeo

namespace ProtocolTargetInterface

/-! ## Core Surfaces -/

/-- [Status: Proved] Curated re-export of `ProtocolTargetContext`. -/
abbrev ProtocolTargetContext := SuperNeo.ProtocolTargetContext

/-- [Status: Proved] Curated re-export of `protocolTargetProp`. -/
abbrev protocolTargetProp := SuperNeo.protocolTargetProp

/-! ## Boundary Surfaces -/

/-- [Status: Boundary-Assumed] Boundary surface `ProtocolTargetAssumptions` requiring closure. -/
abbrev ProtocolTargetAssumptions := SuperNeo.ProtocolTargetAssumptions

/-- [Status: Boundary-Assumed] Boundary surface `matrixTransformAssumption_of_thm3CoreAssumption` requiring closure. -/
abbrev matrixTransformAssumption_of_thm3CoreAssumption := SuperNeo.matrixTransformAssumption_of_thm3CoreAssumption

/-- [Status: Boundary-Assumed] Boundary surface `protocolTargetProp_of_assumptions` requiring closure. -/
abbrev protocolTargetProp_of_assumptions := SuperNeo.protocolTargetProp_of_assumptions

end ProtocolTargetInterface

end SuperNeo

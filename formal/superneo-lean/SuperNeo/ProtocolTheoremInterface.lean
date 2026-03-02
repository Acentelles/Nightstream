import SuperNeo.ProtocolTheorem

/-!
Contract interface for `SuperNeo.ProtocolTheorem`.

Spec: `./formal/superneo-lean/specs/ProtocolTheorem.spec.md`

Paper anchors (Source: `./formal/superneo-lean/SuperNeo.pdf.md`):
- Section 7.6 (implied final theorem): Composition of Π_CCS, Π_RLC, Π_DEC with knowledge-soundness
- Section 7, lines 447–596: Neo's folding scheme for CCS
- Appendix B/C/D: Assumption accounting, lattice security (MSIS, Ajtai binding)
-/

namespace SuperNeo

namespace ProtocolTheoremInterface

/-! ## Core Surfaces -/

/-- [Status: Proved] Curated re-export of `schwartzZippelFailureEvent`. -/
abbrev schwartzZippelFailureEvent := SuperNeo.schwartzZippelFailureEvent

/-- [Status: Proved] Curated re-export of `SchwartzZippelAdvantage`. -/
abbrev SchwartzZippelAdvantage := SuperNeo.SchwartzZippelAdvantage

/-- [Status: Proved] Curated re-export of `SchwartzZippelAdvantageBound`. -/
abbrev SchwartzZippelAdvantageBound := SuperNeo.SchwartzZippelAdvantageBound

/-- [Status: Proved] Curated re-export of `LatticeParams`. -/
abbrev LatticeParams := SuperNeo.LatticeParams

/-- [Status: Proved] Curated re-export of `FinalTheoremShape`. -/
abbrev FinalTheoremShape := SuperNeo.FinalTheoremShape

/-! ## Boundary Surfaces -/

/-- [Status: Boundary-Assumed] Boundary surface `schwartzZippelAssumption` requiring closure. -/
abbrev schwartzZippelAssumption := SuperNeo.schwartzZippelAssumption

/-- [Status: Boundary-Assumed] Boundary surface `SchwartzZippelBoundary` requiring closure. -/
abbrev SchwartzZippelBoundary := SuperNeo.SchwartzZippelBoundary

/-- [Status: Boundary-Assumed] Boundary surface `msisHardnessAssumption` requiring closure. -/
abbrev msisHardnessAssumption := SuperNeo.msisHardnessAssumption

/-- [Status: Boundary-Assumed] Boundary surface `ajtaiBindingAssumption` requiring closure. -/
abbrev ajtaiBindingAssumption := SuperNeo.ajtaiBindingAssumption

/-- [Status: Boundary-Assumed] Boundary surface `ajtaiRelaxedBindingAssumption` requiring closure. -/
abbrev ajtaiRelaxedBindingAssumption := SuperNeo.ajtaiRelaxedBindingAssumption

/-- [Status: Boundary-Assumed] Boundary surface `reductionSumcheckSoundnessBoundary` requiring closure. -/
abbrev reductionSumcheckSoundnessBoundary := SuperNeo.reductionSumcheckSoundnessBoundary

/-- [Status: Boundary-Assumed] Boundary surface `reductionSumcheckCompletenessBoundary` requiring closure. -/
abbrev reductionSumcheckCompletenessBoundary := SuperNeo.reductionSumcheckCompletenessBoundary

/-- [Status: Boundary-Assumed] Boundary surface `FinalTheoremAssumptions` requiring closure. -/
abbrev FinalTheoremAssumptions := SuperNeo.FinalTheoremAssumptions

end ProtocolTheoremInterface

end SuperNeo

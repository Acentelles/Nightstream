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

/-- [Role: Theorem-Target] Curated re-export of `schwartzZippelFailureEvent`. -/
abbrev schwartzZippelFailureEvent := SuperNeo.schwartzZippelFailureEvent

/-- [Role: Theorem-Target] Curated re-export of `SchwartzZippelAdvantage`. -/
abbrev SchwartzZippelAdvantage := SuperNeo.SchwartzZippelAdvantage

/-- [Role: Theorem-Target] Curated re-export of `SchwartzZippelAdvantageBound`. -/
abbrev SchwartzZippelAdvantageBound := SuperNeo.SchwartzZippelAdvantageBound

/-- [Role: Theorem-Target] Curated re-export of `LatticeParams`. -/
abbrev LatticeParams := SuperNeo.LatticeParams

/-- [Role: Theorem-Target] Curated re-export of `FinalTheoremShape`. -/
abbrev FinalTheoremShape := SuperNeo.FinalTheoremShape

/-! ## Boundary Surfaces -/

/-- [Role: Boundary] Boundary surface `schwartzZippelAssumption` requiring closure. -/
abbrev schwartzZippelAssumption := SuperNeo.schwartzZippelAssumption

/-- [Role: Boundary] Boundary surface `SchwartzZippelBoundary` requiring closure. -/
abbrev SchwartzZippelBoundary := SuperNeo.SchwartzZippelBoundary

/-- [Role: Boundary] Boundary surface `msisHardnessAssumption` requiring closure. -/
abbrev msisHardnessAssumption := SuperNeo.msisHardnessAssumption

/-- [Role: Boundary] Boundary surface `ajtaiBindingAssumption` requiring closure. -/
abbrev ajtaiBindingAssumption := SuperNeo.ajtaiBindingAssumption

/-- [Role: Boundary] Boundary surface `ajtaiRelaxedBindingAssumption` requiring closure. -/
abbrev ajtaiRelaxedBindingAssumption := SuperNeo.ajtaiRelaxedBindingAssumption

/-- [Role: Boundary] Faithful prefix-dependent SumCheck Lund package for protocols. -/
abbrev SumcheckPrefixLundBoundary := SuperNeo.SumcheckPrefixLundBoundary

/-- [Role: Boundary] Witness-level SumCheck failure-advantage bound surface. -/
abbrev sumcheckFailureAdvantageBound :=
  SuperNeo.ProofSystem.Sumcheck.SoundnessFailureAdvantageBound

/-- [Role: Boundary] Canonical final error package surface. -/
abbrev FinalErrorPackage := SuperNeo.FinalErrorPackage

/-- [Role: Boundary] Boundary surface `FinalTheoremAssumptions` requiring closure. -/
abbrev FinalTheoremAssumptions := SuperNeo.FinalTheoremAssumptions

end ProtocolTheoremInterface

end SuperNeo

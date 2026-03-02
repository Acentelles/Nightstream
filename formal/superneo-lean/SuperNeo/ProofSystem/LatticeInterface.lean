import SuperNeo.ProofSystem.Lattice

/-!
Interface for `SuperNeo.ProofSystem.Lattice` and `LatticeReductions`.

Spec: `specs/ProofSystem/Lattice.spec.md`, `specs/ProofSystem/LatticeReductions.spec.md`
Paper: `./formal/superneo-lean/SuperNeo.pdf.md`
Anchors: Definition 16 (MSIS), lines 743–744; Definition 18 (Ajtai commitment), lines 753–756; Theorem 2 (Properties), lines 319–321.
MSIS-to-Ajtai binding reduction (LatticeReductions).
-/

namespace SuperNeo

namespace ProofSystem.LatticeInterface

/-- Canonical implementation module name for this interface. -/
def implementationModule : String := "SuperNeo.ProofSystem.Lattice"

/-- Canonical paper source used for this module-level interface/spec pair. -/
def paperSource : String := "/Users/nicolasarqueros/starstream/SuperNeo.pdf.md"

/-- Paper sections used to ground this module boundary. -/
def paperAnchors : List String := ["§1.2 Ajtai commitments and embedding challenges", "§6 security composition context", "Appendix B parameter context"]

/-- Public symbol inventory extracted from the implementation module. -/
def exportedSymbolNames : List String := ["AjtaiParams", "AjtaiParams.kappa", "AjtaiParams.msgLen", "AjtaiParams.matrixFlatLen", "AjtaiParams.commitmentLen", "AjtaiParams.payloadLen", "AjtaiParams.msisNormBound", "AjtaiParams.SideConditions", "Commitment", "Opening", "normInfVec", "dotRq", "matRow", "matVecMul", "smulVec", "zeroVec", "subVec_self", "Commitment.WellFormed", "Commitment.ppMatrixFlat", "Commitment.valueVec", "Opening.WellFormed", "Opening.NormSound", "opensTo", "opensToRelaxed", "BindingCollision", "RelaxedBindingCollision", "MSISChallenge", "MSISChallenge.WellFormed", "MSISSolution", "MSISBreakEvent", "MSISGame", "canonicalMSISGame", "MSISAdvantage", "MSISAdvantageBound", "MSISHardnessAssumption", "MSISHardnessBoundary", "MSISHardnessBoundary.hardness", "MSISHardnessBoundary.hardnessFromFields", "matrixFlatLen_le_payloadLen", "commitmentLen_le_payloadLen", "Nontrivial", "msisNormBound_pos", "ppMatrixFlat_size", "valueVec_size", "ppMatrixFlat_size_of_wf", "valueVec_size_of_wf", "NormSound_mono", "CommitmentWF", "OpeningWF", "MSISChallengeWF", "ppMatrixFlat", "valueVec", "ofFields", "normalize", "normalize_hardnessFromFields", "smulVec_size", "matVecMul_size", "AjtaiBindingAssumption", "AjtaiRelaxedBindingAssumption", "AjtaiBindingGame", "canonicalAjtaiBindingGame", "AjtaiBindingAdvantage", "AjtaiBindingAdvantageBound", "AjtaiRelaxedBindingGame", "canonicalAjtaiRelaxedBindingGame", "AjtaiRelaxedBindingAdvantage", "AjtaiRelaxedBindingAdvantageBound", "AjtaiBindingBoundary", "AjtaiRelaxedBindingBoundary", "bindingCollision_subWitness_norm_lt_msisNormBound", "relaxedBindingCollision_subWitness_norm_lt_msisNormBound", "msisBreakEvent_of_bindingCollision", "msisBreakEvent_of_relaxedBindingCollision", "no_msisBreakEvent_of_hardness", "no_ajtaiBindingCollision_of_advantageBound", "no_ajtaiRelaxedBindingCollision_of_advantageBound", "hardness", "hardnessFromFields", "MSISToAjtaiReductions", "toBinding", "toRelaxedBinding", "ajtaiBinding_of_msis", "ajtaiRelaxedBinding_of_msis", "ajtaiBoundaries_of_msis", "ajtaiBindingBoundary_of_msis", "ajtaiRelaxedBindingBoundary_of_msis"]

/-- Assumption/boundary-oriented symbols extracted by naming convention. -/
def boundarySymbolNames : List String := ["MSISHardnessAssumption", "MSISHardnessBoundary", "MSISHardnessBoundary.hardness", "MSISHardnessBoundary.hardnessFromFields", "AjtaiBindingAssumption", "AjtaiRelaxedBindingAssumption", "AjtaiBindingBoundary", "AjtaiRelaxedBindingBoundary", "ajtaiBindingBoundary_of_msis", "ajtaiRelaxedBindingBoundary_of_msis"]

/-- Interface scaffold marker; replace with concrete typed wrappers as closure progresses. -/
def interfaceScaffoldReady : Prop := True

theorem interfaceScaffoldReady_true : interfaceScaffoldReady := by
  trivial

end ProofSystem.LatticeInterface

end SuperNeo

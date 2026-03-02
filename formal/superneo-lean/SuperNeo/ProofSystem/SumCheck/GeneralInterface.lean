import SuperNeo.ProofSystem.SumCheck.General

/-!
Interface for `SuperNeo.ProofSystem.SumCheck.General`.

Spec: `specs/ProofSystem/SumCheck/General.spec.md`
Paper: `./formal/superneo-lean/SuperNeo.pdf.md`
- Definition 6 (The sum-check protocol), lines 352–355
- Section 7.3 (Π_CCS), lines 481–548

This interface file is the typed boundary companion for the implementation.
-/

namespace SuperNeo

namespace ProofSystem.SumCheck.GeneralInterface

/-- Canonical implementation module name for this interface. -/
def implementationModule : String := "SuperNeo.ProofSystem.SumCheck.General"

/-- Canonical paper source used for this module-level interface/spec pair. -/
def paperSource : String := "/Users/nicolasarqueros/starstream/SuperNeo.pdf.md"

/-- Paper sections used to ground this module boundary. -/
def paperAnchors : List String := ["§2.1 Sum-check reduction role", "§7.3 Interactive reduction for CCS"]

/-- Public symbol inventory extracted from the implementation module. -/
def exportedSymbolNames : List String := ["Instance", "Transcript", "RoundConsistent", "InitialRoundConsistent", "Accepted", "ClaimTrue", "SoundnessAssumption", "CompletenessAssumption", "Assumptions", "SoundnessErrorBoundary", "TheoremPackage", "TheoremPackage.eps", "TheoremPackage.negligible", "TheoremPackage.soundness", "TheoremPackage.completeness", "accepted_rounds_eq", "accepted_challenges_eq", "accepted_fold_step", "accepted_initial_round", "accepted_round_sum_step", "soundness", "completeness"]

/-- Assumption/boundary-oriented symbols extracted by naming convention. -/
def boundarySymbolNames : List String := ["SoundnessAssumption", "CompletenessAssumption", "Assumptions", "SoundnessErrorBoundary", "TheoremPackage.negligible", "TheoremPackage.soundness", "TheoremPackage.completeness", "soundness", "completeness"]

/-- Interface scaffold marker; replace with concrete typed wrappers as closure progresses. -/
def interfaceScaffoldReady : Prop := True

theorem interfaceScaffoldReady_true : interfaceScaffoldReady := by
  trivial

end ProofSystem.SumCheck.GeneralInterface

end SuperNeo

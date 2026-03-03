import SuperNeo.InteractiveReductions
import SuperNeo.Interp
import SuperNeo.ProofSystem.Lattice
import SuperNeo.ProofSystem.LatticeReductions
import SuperNeo.ProofSystem.SumCheck
import SuperNeo.ProofSystem.Security

/-!
Canonical final theorem shape for the SuperNeo scaffold.

This file provides:
- one explicit assumption registry,
- completeness and knowledge-soundness statement shapes,
- one canonical theorem constructor from assumptions.
-/

namespace SuperNeo

/-- Canonical Schwartz-Zippel failure event surface (theorem-facing alias). -/
def schwartzZippelFailureEvent : Prop :=
  interpolationAssumption

/-- Backward-compatible alias for the Schwartz-Zippel failure event surface. -/
def schwartzZippelAssumption : Prop :=
  schwartzZippelFailureEvent

/-- Advantage of the Schwartz-Zippel failure event under a probability model. -/
def SchwartzZippelAdvantage
  (prob : SuperNeo.ProofSystem.ProbModel)
  (_n : Nat) : Rat :=
  prob.Pr schwartzZippelFailureEvent

/-- Theorem-facing Schwartz-Zippel advantage bound shape against an error function. -/
def SchwartzZippelAdvantageBound
  (eps : SuperNeo.ProofSystem.ErrorFn) : Prop :=
  ∀ prob : SuperNeo.ProofSystem.ProbModel, ∀ n : Nat,
    SchwartzZippelAdvantage prob n ≤ (eps n : Rat)

/-- Theorem-facing boundary package for Schwartz-Zippel with explicit error term. -/
structure SchwartzZippelBoundary where
  assumption : schwartzZippelAssumption
  epsSchwartzZippel : SuperNeo.ProofSystem.ErrorFn
  negligibleEpsSchwartzZippel :
    SuperNeo.ProofSystem.IsNegligible epsSchwartzZippel
  advantageBound :
    SchwartzZippelAdvantageBound epsSchwartzZippel

/-- Paper-facing alias for lattice-parameter bundle. -/
abbrev LatticeParams := SuperNeo.ProofSystem.AjtaiParams

/-- Typed boundary for Module-SIS hardness. -/
def msisHardnessAssumption (params : LatticeParams) : Prop :=
  SuperNeo.ProofSystem.MSISHardnessAssumption params

/-- Typed boundary for Ajtai commitment binding. -/
def ajtaiBindingAssumption (params : LatticeParams) : Prop :=
  SuperNeo.ProofSystem.AjtaiBindingAssumption params

/-- Typed boundary for Ajtai relaxed binding. -/
def ajtaiRelaxedBindingAssumption
  (params : LatticeParams)
  (C : SuperNeo.SamplingCarrier) : Prop :=
  SuperNeo.ProofSystem.AjtaiRelaxedBindingAssumption params C

/-- Canonical nested SumCheck soundness boundary extracted from reductions. -/
def reductionSumcheckSoundnessBoundary
  {ctx : ProtocolTargetContext}
  (hR : InteractiveReductionAssumptions ctx) : SumcheckSoundnessAssumption :=
  hR.reduction.weak.strong.relations.sumcheckSoundness

/-- Canonical nested SumCheck completeness boundary extracted from reductions. -/
def reductionSumcheckCompletenessBoundary
  {ctx : ProtocolTargetContext}
  (hR : InteractiveReductionAssumptions ctx) : SumcheckCompletenessAssumption :=
  hR.reduction.weak.strong.relations.sumcheckCompleteness

/-- Canonical final assumption registry. -/
structure FinalTheoremAssumptions (ctx : ProtocolTargetContext) where
  reduction : InteractiveReductionAssumptions ctx
  sumcheckPackage :
    SuperNeo.ProofSystem.Sumcheck.TheoremPackage
      (reductionSumcheckSoundnessBoundary reduction)
      (reductionSumcheckCompletenessBoundary reduction)
  schwartzZippelBoundary : SchwartzZippelBoundary
  errorModel : SuperNeo.ProofSystem.ErrorModel
  sumcheckErrorAligned :
    errorModel.epsSumcheck = sumcheckPackage.soundnessError.epsSoundness
  schwartzZippelErrorAligned :
    errorModel.epsSchwartzZippel = schwartzZippelBoundary.epsSchwartzZippel
  latticeParams : LatticeParams
  msisBoundary : SuperNeo.ProofSystem.MSISHardnessBoundary latticeParams
  msisToAjtai : SuperNeo.ProofSystem.MSISToAjtaiReductions latticeParams
  msisErrorAligned :
    errorModel.epsMSIS = msisBoundary.epsMSIS
  bindingErrorAligned :
    errorModel.epsBinding = msisToAjtai.epsBinding
  relaxedBindingErrorAligned :
    errorModel.epsRelaxedBinding = msisToAjtai.epsRelaxedBinding
  totalErrorAligned :
    ∀ n,
      errorModel.epsTotal n =
        sumcheckPackage.soundnessError.epsSoundness n +
          msisBoundary.epsMSIS n +
            schwartzZippelBoundary.epsSchwartzZippel n +
              msisToAjtai.epsBinding n +
                msisToAjtai.epsRelaxedBinding n

/-- Canonical SumCheck soundness boundary extracted from nested reduction assumptions. -/
def FinalTheoremAssumptions.sumcheckSoundnessBoundary
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) : SumcheckSoundnessAssumption :=
  reductionSumcheckSoundnessBoundary hA.reduction

/-- Canonical SumCheck completeness boundary extracted from nested reduction assumptions. -/
def FinalTheoremAssumptions.sumcheckCompletenessBoundary
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) : SumcheckCompletenessAssumption :=
  reductionSumcheckCompletenessBoundary hA.reduction

/-- Canonical SumCheck error boundary carried by final assumptions. -/
def FinalTheoremAssumptions.sumcheckErrorBoundary
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.Sumcheck.SoundnessErrorBoundary :=
  hA.sumcheckPackage.soundnessError

/-- Canonical SumCheck error negligibility aligned to final error accounting. -/
def FinalTheoremAssumptions.sumcheckErrorNegligible
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsSumcheck := by
  have hNegPkg :
      SuperNeo.ProofSystem.IsNegligible
        hA.sumcheckPackage.soundnessError.epsSoundness :=
    hA.sumcheckPackage.soundnessError.negligibleEpsSoundness
  simpa [hA.sumcheckErrorAligned] using hNegPkg

/-- Access Schwartz-Zippel boundary assumption from final assumptions. -/
def FinalTheoremAssumptions.schwartzZippelBoundaryAssumption
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) : schwartzZippelAssumption :=
  hA.schwartzZippelBoundary.assumption

/-- Backward-compatible accessor for the Schwartz-Zippel assumption surface. -/
def FinalTheoremAssumptions.schwartzZippel
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) : schwartzZippelAssumption :=
  hA.schwartzZippelBoundaryAssumption

/-- Canonical Schwartz-Zippel error negligibility aligned to final error accounting. -/
def FinalTheoremAssumptions.schwartzZippelErrorNegligible
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsSchwartzZippel := by
  have hNeg :
      SuperNeo.ProofSystem.IsNegligible hA.schwartzZippelBoundary.epsSchwartzZippel :=
    hA.schwartzZippelBoundary.negligibleEpsSchwartzZippel
  simpa [hA.schwartzZippelErrorAligned] using hNeg

/-- Canonical Schwartz-Zippel advantage bound aligned to final error accounting. -/
def FinalTheoremAssumptions.schwartzZippelAdvantageBound
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SchwartzZippelAdvantageBound hA.errorModel.epsSchwartzZippel := by
  have hBound :
      SchwartzZippelAdvantageBound hA.schwartzZippelBoundary.epsSchwartzZippel :=
    hA.schwartzZippelBoundary.advantageBound
  intro prob n
  have hLe :
      SchwartzZippelAdvantage prob n ≤
        (hA.schwartzZippelBoundary.epsSchwartzZippel n : Rat) :=
    hBound prob n
  simpa [hA.schwartzZippelErrorAligned] using hLe

/-- Canonical low-norm invertibility boundary extracted from nested reduction assumptions. -/
def FinalTheoremAssumptions.lowNormInvertibilityBoundary
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) : lowNormInvertibilityAssumption Goldilocks.halfQ :=
  hA.reduction.reduction.lowNormInvertibilityBoundary

/-- Canonical MSIS hardness boundary extracted from the final lattice package. -/
def FinalTheoremAssumptions.msisHardnessBoundary
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) : msisHardnessAssumption hA.latticeParams :=
  SuperNeo.ProofSystem.MSISHardnessBoundary.hardnessFromFields hA.msisBoundary

/-- Canonical MSIS error negligibility aligned to final error accounting. -/
def FinalTheoremAssumptions.msisErrorNegligible
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsMSIS := by
  have hNeg :
      SuperNeo.ProofSystem.IsNegligible hA.msisBoundary.epsMSIS :=
    hA.msisBoundary.negligibleEpsMSIS
  simpa [hA.msisErrorAligned] using hNeg

/-- Canonical MSIS advantage bound aligned to final error accounting. -/
def FinalTheoremAssumptions.msisAdvantageBound
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.MSISAdvantageBound hA.latticeParams hA.errorModel.epsMSIS := by
  have hB :
      SuperNeo.ProofSystem.MSISAdvantageBound hA.latticeParams hA.msisBoundary.epsMSIS :=
    hA.msisBoundary.advantageBound
  intro prob n
  have hLe : SuperNeo.ProofSystem.MSISAdvantage prob
      (SuperNeo.ProofSystem.canonicalMSISGame hA.latticeParams) n ≤
      (hA.msisBoundary.epsMSIS n : Rat) :=
    hB prob n
  simpa [hA.msisErrorAligned] using hLe

/-- Canonical Ajtai binding boundary derived from MSIS hardness via reductions. -/
def FinalTheoremAssumptions.ajtaiBindingBoundaryPackage
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.AjtaiBindingBoundary hA.latticeParams :=
  SuperNeo.ProofSystem.ajtaiBindingBoundary_of_msis hA.msisToAjtai hA.msisHardnessBoundary

/-- Canonical Ajtai binding boundary derived from MSIS hardness via reductions. -/
def FinalTheoremAssumptions.ajtaiBindingBoundary
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) : ajtaiBindingAssumption hA.latticeParams :=
  SuperNeo.ProofSystem.AjtaiBindingBoundary.hardnessFromFields hA.ajtaiBindingBoundaryPackage

/-- Canonical Ajtai relaxed-binding boundary derived from MSIS hardness via reductions. -/
def FinalTheoremAssumptions.ajtaiRelaxedBindingBoundaryPackage
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.AjtaiRelaxedBindingBoundary
    hA.latticeParams hA.msisToAjtai.laws.samplingCarrier :=
  SuperNeo.ProofSystem.ajtaiRelaxedBindingBoundary_of_msis hA.msisToAjtai hA.msisHardnessBoundary

/-- Canonical Ajtai relaxed-binding boundary derived from MSIS hardness via reductions. -/
def FinalTheoremAssumptions.ajtaiRelaxedBindingBoundary
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  ajtaiRelaxedBindingAssumption hA.latticeParams hA.msisToAjtai.laws.samplingCarrier :=
  SuperNeo.ProofSystem.AjtaiRelaxedBindingBoundary.hardnessFromFields hA.ajtaiRelaxedBindingBoundaryPackage

/-- Canonical Ajtai binding-error negligibility aligned to final error accounting. -/
def FinalTheoremAssumptions.bindingErrorNegligible
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsBinding := by
  have hNeg :
      SuperNeo.ProofSystem.IsNegligible hA.ajtaiBindingBoundaryPackage.epsBinding :=
    hA.ajtaiBindingBoundaryPackage.negligibleEpsBinding
  simpa [hA.bindingErrorAligned] using hNeg

/-- Canonical Ajtai binding advantage bound aligned to final error accounting. -/
def FinalTheoremAssumptions.bindingAdvantageBound
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.AjtaiBindingAdvantageBound hA.latticeParams hA.errorModel.epsBinding := by
  have hB :
      SuperNeo.ProofSystem.AjtaiBindingAdvantageBound
          hA.latticeParams hA.ajtaiBindingBoundaryPackage.epsBinding :=
    hA.ajtaiBindingBoundaryPackage.advantageBound
  intro prob n
  have hLe :
      SuperNeo.ProofSystem.AjtaiBindingAdvantage prob
          (SuperNeo.ProofSystem.canonicalAjtaiBindingGame hA.latticeParams) n ≤
        (hA.ajtaiBindingBoundaryPackage.epsBinding n : Rat) :=
    hB prob n
  simpa [hA.bindingErrorAligned] using hLe

/-- Canonical Ajtai relaxed-binding-error negligibility aligned to final error accounting. -/
def FinalTheoremAssumptions.relaxedBindingErrorNegligible
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsRelaxedBinding := by
  have hNeg :
      SuperNeo.ProofSystem.IsNegligible hA.ajtaiRelaxedBindingBoundaryPackage.epsRelaxedBinding :=
    hA.ajtaiRelaxedBindingBoundaryPackage.negligibleEpsRelaxedBinding
  simpa [hA.relaxedBindingErrorAligned] using hNeg

/-- Canonical Ajtai relaxed-binding advantage bound aligned to final error accounting. -/
def FinalTheoremAssumptions.relaxedBindingAdvantageBound
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.AjtaiRelaxedBindingAdvantageBound
      hA.latticeParams hA.msisToAjtai.laws.samplingCarrier hA.errorModel.epsRelaxedBinding := by
  have hB :
      SuperNeo.ProofSystem.AjtaiRelaxedBindingAdvantageBound
          hA.latticeParams hA.msisToAjtai.laws.samplingCarrier
            hA.ajtaiRelaxedBindingBoundaryPackage.epsRelaxedBinding :=
    hA.ajtaiRelaxedBindingBoundaryPackage.advantageBound
  intro prob n
  have hLe :
      SuperNeo.ProofSystem.AjtaiRelaxedBindingAdvantage prob
          (SuperNeo.ProofSystem.canonicalAjtaiRelaxedBindingGame
            hA.latticeParams hA.msisToAjtai.laws.samplingCarrier) n ≤
        (hA.ajtaiRelaxedBindingBoundaryPackage.epsRelaxedBinding n : Rat) :=
    hB prob n
  simpa [hA.relaxedBindingErrorAligned] using hLe

/-- Canonical total-error decomposition derived from the error model plus alignments. -/
def FinalTheoremAssumptions.totalErrorDecompFromModel
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  ∀ n,
    hA.errorModel.epsTotal n =
      hA.sumcheckPackage.soundnessError.epsSoundness n +
        hA.msisBoundary.epsMSIS n +
          hA.schwartzZippelBoundary.epsSchwartzZippel n +
            hA.msisToAjtai.epsBinding n +
              hA.msisToAjtai.epsRelaxedBinding n := by
  intro n
  have hDecomp : hA.errorModel.epsTotal n =
      hA.errorModel.epsSumcheck n + hA.errorModel.epsMSIS n +
        hA.errorModel.epsSchwartzZippel n + hA.errorModel.epsBinding n +
          hA.errorModel.epsRelaxedBinding n :=
    hA.errorModel.epsTotal_decomp n
  simpa [hA.sumcheckErrorAligned, hA.msisErrorAligned, hA.schwartzZippelErrorAligned,
    hA.bindingErrorAligned, hA.relaxedBindingErrorAligned] using hDecomp

/-- Canonical total-error negligibility from final error accounting. -/
def FinalTheoremAssumptions.totalErrorNegligible
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsTotal :=
  hA.errorModel.negligibleTotal

/-- Final completeness statement shape. -/
def FinalCompletenessStatement
  (ctx : ProtocolTargetContext)
  (_hA : FinalTheoremAssumptions ctx) : Prop :=
  ceRelaxedRelation ctx

/-- Final knowledge-soundness statement shape. -/
def FinalKnowledgeSoundnessStatement
  (ctx : ProtocolTargetContext)
  (hA : FinalTheoremAssumptions ctx) : Prop :=
  strongCompositionStatement ctx ∧
  schwartzZippelAssumption ∧
  hA.errorModel.epsSchwartzZippel = hA.schwartzZippelBoundary.epsSchwartzZippel ∧
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsSchwartzZippel ∧
  SchwartzZippelAdvantageBound hA.errorModel.epsSchwartzZippel ∧
  hA.errorModel.epsSumcheck = hA.sumcheckPackage.soundnessError.epsSoundness ∧
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsSumcheck ∧
  hA.errorModel.epsMSIS = hA.msisBoundary.epsMSIS ∧
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsMSIS ∧
  SuperNeo.ProofSystem.MSISAdvantageBound hA.latticeParams hA.errorModel.epsMSIS ∧
  hA.errorModel.epsBinding = hA.msisToAjtai.epsBinding ∧
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsBinding ∧
  SuperNeo.ProofSystem.AjtaiBindingAdvantageBound hA.latticeParams hA.errorModel.epsBinding ∧
  hA.errorModel.epsRelaxedBinding = hA.msisToAjtai.epsRelaxedBinding ∧
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsRelaxedBinding ∧
  SuperNeo.ProofSystem.AjtaiRelaxedBindingAdvantageBound
      hA.latticeParams hA.msisToAjtai.laws.samplingCarrier hA.errorModel.epsRelaxedBinding ∧
  (∀ n,
    hA.errorModel.epsTotal n =
      hA.sumcheckPackage.soundnessError.epsSoundness n +
        hA.msisBoundary.epsMSIS n +
          hA.schwartzZippelBoundary.epsSchwartzZippel n +
            hA.msisToAjtai.epsBinding n +
              hA.msisToAjtai.epsRelaxedBinding n) ∧
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsTotal ∧
  msisHardnessAssumption hA.latticeParams ∧
  ajtaiBindingAssumption hA.latticeParams ∧
  ajtaiRelaxedBindingAssumption hA.latticeParams hA.msisToAjtai.laws.samplingCarrier

/-- Canonical final theorem container. -/
structure FinalTheoremShape
  (ctx : ProtocolTargetContext)
  (hA : FinalTheoremAssumptions ctx) : Prop where
  completeness : FinalCompletenessStatement ctx hA
  knowledgeSoundness : FinalKnowledgeSoundnessStatement ctx hA

/-- Canonical final theorem constructor. -/
theorem finalTheoremShape_of_assumptions
  {ctx : ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  FinalTheoremShape ctx hA := by
  refine ⟨?_, ?_⟩
  · exact (weakComposition_of_assumptions hA.reduction).1
  · exact ⟨strongComposition_of_assumptions hA.reduction,
      hA.schwartzZippelBoundary.assumption,
      hA.schwartzZippelErrorAligned,
      hA.schwartzZippelErrorNegligible,
      hA.schwartzZippelAdvantageBound,
      hA.sumcheckErrorAligned,
      hA.sumcheckErrorNegligible,
      hA.msisErrorAligned,
      hA.msisErrorNegligible,
      hA.msisAdvantageBound,
      hA.bindingErrorAligned,
      hA.bindingErrorNegligible,
      hA.bindingAdvantageBound,
      hA.relaxedBindingErrorAligned,
      hA.relaxedBindingErrorNegligible,
      hA.relaxedBindingAdvantageBound,
      hA.totalErrorAligned,
      hA.totalErrorNegligible,
      hA.msisHardnessBoundary,
      hA.ajtaiBindingBoundary,
      hA.ajtaiRelaxedBindingBoundary⟩

end SuperNeo

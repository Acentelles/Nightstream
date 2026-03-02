import SuperNeo.ProtocolTheorem
import SuperNeo.ProofSystem.Types
import SuperNeo.ProofSystem.Security
import SuperNeo.ProofSystem.Lattice
import SuperNeo.ProofSystem.SumCheck
import SuperNeo.ProofSystem.Folding

namespace SuperNeo.ProofSystem

abbrev LatticeParams := SuperNeo.ProofSystem.AjtaiParams

abbrev FinalTheoremAssumptions (ctx : SuperNeo.ProtocolTargetContext) :=
  SuperNeo.FinalTheoremAssumptions ctx

abbrev FinalCompletenessStatement
  (ctx : SuperNeo.ProtocolTargetContext)
  (hA : FinalTheoremAssumptions ctx) :=
  SuperNeo.FinalCompletenessStatement ctx hA

abbrev FinalKnowledgeSoundnessStatement
  (ctx : SuperNeo.ProtocolTargetContext)
  (hA : FinalTheoremAssumptions ctx) :=
  SuperNeo.FinalKnowledgeSoundnessStatement ctx hA

abbrev FinalTheoremShape
  (ctx : SuperNeo.ProtocolTargetContext)
  (hA : FinalTheoremAssumptions ctx) :=
  SuperNeo.FinalTheoremShape ctx hA

/-- Access final SumCheck theorem package from final assumptions. -/
def finalSumcheckPackage
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.Sumcheck.TheoremPackage
    (SuperNeo.reductionSumcheckSoundnessBoundary hA.reduction)
    (SuperNeo.reductionSumcheckCompletenessBoundary hA.reduction) :=
  hA.sumcheckPackage

/-- Access canonical nested SumCheck soundness boundary from final assumptions. -/
def finalSumcheckSoundnessBoundary
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.SumcheckSoundnessAssumption :=
  hA.sumcheckSoundnessBoundary

/-- Access canonical nested SumCheck completeness boundary from final assumptions. -/
def finalSumcheckCompletenessBoundary
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.SumcheckCompletenessAssumption :=
  hA.sumcheckCompletenessBoundary

/-- Access canonical SumCheck soundness-error boundary from final assumptions. -/
def finalSumcheckErrorBoundary
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.Sumcheck.SoundnessErrorBoundary :=
  hA.sumcheckErrorBoundary

/-- Access canonical final error-accounting model from final assumptions. -/
def finalErrorModel
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.ErrorModel :=
  hA.errorModel

/-- Access explicit Schwartz-Zippel boundary package from final assumptions. -/
def finalSchwartzZippelBoundaryPackage
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.SchwartzZippelBoundary :=
  hA.schwartzZippelBoundary

/-- Access explicit Schwartz-Zippel assumption boundary from final assumptions. -/
def finalSchwartzZippelBoundary
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.schwartzZippelAssumption :=
  hA.schwartzZippelBoundary.assumption

/-- Access explicit alignment between error model and Schwartz-Zippel error term. -/
def finalSchwartzZippelErrorAligned
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  hA.errorModel.epsSchwartzZippel = hA.schwartzZippelBoundary.epsSchwartzZippel :=
  hA.schwartzZippelErrorAligned

/-- Access canonical Schwartz-Zippel error negligibility from final assumptions. -/
def finalSchwartzZippelErrorNegligible
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsSchwartzZippel :=
  hA.schwartzZippelErrorNegligible

/-- Access canonical Schwartz-Zippel advantage bound aligned to final error accounting. -/
def finalSchwartzZippelAdvantageBound
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.SchwartzZippelAdvantageBound hA.errorModel.epsSchwartzZippel :=
  hA.schwartzZippelAdvantageBound

/-- Access explicit alignment between error model and SumCheck soundness error. -/
def finalSumcheckErrorAligned
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  hA.errorModel.epsSumcheck = hA.sumcheckPackage.soundnessError.epsSoundness :=
  hA.sumcheckErrorAligned

/-- Access canonical SumCheck soundness-error negligibility from final assumptions. -/
def finalSumcheckErrorNegligible
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsSumcheck :=
  hA.sumcheckErrorNegligible

/-- Access canonical nested low-norm invertibility boundary from final assumptions. -/
def finalLowNormInvertibilityBoundary
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.lowNormInvertibilityAssumption SuperNeo.Goldilocks.halfQ :=
  hA.lowNormInvertibilityBoundary

/-- Access explicit lattice MSIS hardness boundary from final assumptions. -/
def finalMSISHardnessBoundary
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.MSISHardnessAssumption hA.latticeParams :=
  hA.msisHardnessBoundary

/-- Access explicit lattice MSIS hardness package from final assumptions. -/
def finalMSISHardnessPackage
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.MSISHardnessBoundary hA.latticeParams :=
  hA.msisBoundary

/-- Access explicit reduction surface linking MSIS hardness to Ajtai boundaries. -/
def finalMSISToAjtaiReductions
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.MSISToAjtaiReductions hA.latticeParams :=
  hA.msisToAjtai

/-- Access explicit alignment between error model and MSIS hardness error term. -/
def finalMSISErrorAligned
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  hA.errorModel.epsMSIS = hA.msisBoundary.epsMSIS :=
  hA.msisErrorAligned

/-- Access canonical MSIS hardness-error negligibility from final assumptions. -/
def finalMSISErrorNegligible
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsMSIS :=
  hA.msisErrorNegligible

/-- Access canonical MSIS advantage bound aligned to final error accounting. -/
def finalMSISAdvantageBound
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.MSISAdvantageBound hA.latticeParams hA.errorModel.epsMSIS :=
  hA.msisAdvantageBound

/-- Access explicit alignment between error model and Ajtai binding error term. -/
def finalBindingErrorAligned
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  hA.errorModel.epsBinding = hA.msisToAjtai.epsBinding :=
  hA.bindingErrorAligned

/-- Access canonical Ajtai binding-error negligibility from final assumptions. -/
def finalBindingErrorNegligible
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsBinding :=
  hA.bindingErrorNegligible

/-- Access canonical Ajtai binding advantage bound aligned to final error accounting. -/
def finalBindingAdvantageBound
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.AjtaiBindingAdvantageBound hA.latticeParams hA.errorModel.epsBinding :=
  hA.bindingAdvantageBound

/-- Access explicit alignment between error model and Ajtai relaxed-binding error term. -/
def finalRelaxedBindingErrorAligned
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  hA.errorModel.epsRelaxedBinding = hA.msisToAjtai.epsRelaxedBinding :=
  hA.relaxedBindingErrorAligned

/-- Access canonical Ajtai relaxed-binding-error negligibility from final assumptions. -/
def finalRelaxedBindingErrorNegligible
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsRelaxedBinding :=
  hA.relaxedBindingErrorNegligible

/-- Access canonical Ajtai relaxed-binding advantage bound aligned to final error accounting. -/
def finalRelaxedBindingAdvantageBound
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.AjtaiRelaxedBindingAdvantageBound
      hA.latticeParams hA.errorModel.epsRelaxedBinding :=
  hA.relaxedBindingAdvantageBound

/-- Access explicit alignment for aggregated total error accounting at final theorem level. -/
def finalTotalErrorAligned
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  ∀ n,
    hA.errorModel.epsTotal n =
      hA.sumcheckPackage.soundnessError.epsSoundness n +
        hA.msisBoundary.epsMSIS n +
          hA.schwartzZippelBoundary.epsSchwartzZippel n +
            hA.msisToAjtai.epsBinding n +
              hA.msisToAjtai.epsRelaxedBinding n :=
  hA.totalErrorAligned

/-- Access canonical total-error decomposition derived from model decomposition plus alignments. -/
def finalErrorTotalDecomp
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  ∀ n,
    hA.errorModel.epsTotal n =
      hA.sumcheckPackage.soundnessError.epsSoundness n +
        hA.msisBoundary.epsMSIS n +
          hA.schwartzZippelBoundary.epsSchwartzZippel n +
            hA.msisToAjtai.epsBinding n +
              hA.msisToAjtai.epsRelaxedBinding n :=
  hA.totalErrorDecompFromModel

/-- Access canonical total-error negligibility from final error accounting. -/
def finalTotalErrorNegligible
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.IsNegligible hA.errorModel.epsTotal :=
  hA.totalErrorNegligible

/-- Access canonical Ajtai binding boundary package derived from MSIS+reductions. -/
def finalAjtaiBindingBoundaryPackage
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.AjtaiBindingBoundary hA.latticeParams :=
  hA.ajtaiBindingBoundaryPackage

/-- Access canonical Ajtai relaxed-binding boundary package derived from MSIS+reductions. -/
def finalAjtaiRelaxedBindingBoundaryPackage
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.AjtaiRelaxedBindingBoundary hA.latticeParams :=
  hA.ajtaiRelaxedBindingBoundaryPackage

/-- Access explicit lattice Ajtai binding boundary from final assumptions. -/
def finalAjtaiBindingBoundary
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.AjtaiBindingAssumption hA.latticeParams :=
  hA.ajtaiBindingBoundary

/-- Access explicit lattice Ajtai relaxed-binding boundary from final assumptions. -/
def finalAjtaiRelaxedBindingBoundary
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  SuperNeo.ProofSystem.AjtaiRelaxedBindingAssumption hA.latticeParams :=
  hA.ajtaiRelaxedBindingBoundary

/-- Canonical proof-system final theorem shape constructor. -/
theorem finalTheoremShape_of_assumptions
  {ctx : SuperNeo.ProtocolTargetContext}
  (hA : FinalTheoremAssumptions ctx) :
  FinalTheoremShape ctx hA := by
  exact SuperNeo.finalTheoremShape_of_assumptions hA

end SuperNeo.ProofSystem

import SuperNeo.PiDEC

/-!
Composition of reduction steps (`Π_CCS`, `Π_RLC`, `Π_DEC`).
-/

namespace SuperNeo

/-- Assumptions for composed interactive reductions. -/
structure InteractiveReductionAssumptions (ctx : ProtocolTargetContext) where
  reduction : PiDECAssumptions ctx
  sumcheckTransitionWitness : SumCheckTransitionWitness ctx

/-- Native assumptions for composed interactive reductions. -/
structure InteractiveReductionNativeAssumptions (ctx : ProtocolTargetContext) where
  reduction : PiDECNativeAssumptions ctx
  sumcheckTransitionWitness : SumCheckTransitionWitness ctx

/-- Strong composition statement (knowledge-style). -/
def strongCompositionStatement (ctx : ProtocolTargetContext) : Prop :=
  piDECKnowledgeStatement ctx

/-- Weak composition statement (relaxed CE + claim truth). -/
def weakCompositionStatement (ctx : ProtocolTargetContext) : Prop :=
  ceRelaxedRelation ctx ∧
  SumCheckClaimTrue (sumcheckInstanceOfContext ctx)

/-- Strong composed reduction theorem. -/
theorem strongComposition_of_assumptions
  {ctx : ProtocolTargetContext}
  (h : InteractiveReductionAssumptions ctx) :
  strongCompositionStatement ctx := by
  exact piDEC_of_assumptions h.reduction h.sumcheckTransitionWitness

/-- Weak composed reduction theorem. -/
theorem weakComposition_of_assumptions
  {ctx : ProtocolTargetContext}
  (h : InteractiveReductionAssumptions ctx) :
  weakCompositionStatement ctx := by
  rcases strongComposition_of_assumptions h with ⟨_deltaInv, _hMul, hWeak, hClaim⟩
  exact ⟨hWeak, hClaim⟩

/-- Strong composed reduction theorem (native assumption path). -/
theorem strongComposition_of_native_assumptions
  {ctx : ProtocolTargetContext}
  (h : InteractiveReductionNativeAssumptions ctx) :
  strongCompositionStatement ctx := by
  exact piDEC_of_native_assumptions h.reduction h.sumcheckTransitionWitness

/-- Weak composed reduction theorem (native assumption path). -/
theorem weakComposition_of_native_assumptions
  {ctx : ProtocolTargetContext}
  (h : InteractiveReductionNativeAssumptions ctx) :
  weakCompositionStatement ctx := by
  rcases strongComposition_of_native_assumptions h with ⟨_deltaInv, _hMul, hWeak, hClaim⟩
  exact ⟨hWeak, hClaim⟩

end SuperNeo

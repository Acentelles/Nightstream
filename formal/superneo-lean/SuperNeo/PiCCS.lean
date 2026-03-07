import SuperNeo.ProtocolRelations

/-!
Strong interactive-reduction step `Π_CCS`.
-/

namespace SuperNeo

/-- Assumptions consumed by the `Π_CCS` reduction step. -/
abbrev PiCCSAssumptions (ctx : ProtocolTargetContext) :=
  ProtocolTargetAssumptions ctx

/-- Native assumptions consumed by the `Π_CCS` reduction step. -/
abbrev PiCCSNativeAssumptions (ctx : ProtocolTargetContext) :=
  ProtocolTargetNativeAssumptions ctx

/-- Strong `Π_CCS` target statement. -/
def piCCSStrongStatement (ctx : ProtocolTargetContext) : Prop :=
  ceRelation ctx ∧
  SumCheckClaimTrue (sumcheckInstanceOfContext ctx)

/-- Derive strong `Π_CCS` statement from relation assumptions and transcript witness. -/
theorem piCCSStrong_of_assumptions
  {ctx : ProtocolTargetContext}
  (h : PiCCSAssumptions ctx)
  (hWitness : SumCheckTransitionWitness ctx) :
  piCCSStrongStatement ctx := by
  have hCE : ceRelation ctx :=
    ⟨protocolTargetProp_of_assumptions h, hWitness.accepted_exists⟩
  exact ⟨hCE, sumcheckSoundness_constructive _ _ hWitness.accepted⟩

/-- Derive strong `Π_CCS` statement from native relation assumptions. -/
theorem piCCSStrong_of_native_assumptions
  {ctx : ProtocolTargetContext}
  (h : PiCCSNativeAssumptions ctx)
  (hWitness : SumCheckTransitionWitness ctx) :
  piCCSStrongStatement ctx := by
  have hCE : ceRelation ctx :=
    ⟨protocolTargetProp_of_native_assumptions h, hWitness.accepted_exists⟩
  exact ⟨hCE, sumcheckSoundness_constructive _ _ hWitness.accepted⟩

end SuperNeo

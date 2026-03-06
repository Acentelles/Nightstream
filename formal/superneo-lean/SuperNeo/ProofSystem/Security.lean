import SuperNeo.ProofSystem.Negligible

namespace SuperNeo.ProofSystem

/-- Abstract probability model surface used by protocol theorem statements. -/
structure ProbModel where
  Pr : Prop → Rat
  prNonneg : ∀ P : Prop, 0 ≤ Pr P
  prLeOne : ∀ P : Prop, Pr P ≤ 1
  prFalse : Pr False = 0
  prMonotone : ∀ {P Q : Prop}, (P → Q) → Pr P ≤ Pr Q
  prUnionLeAdd : ∀ P Q : Prop, Pr (P ∨ Q) ≤ Pr P + Pr Q

private def zeroError : ErrorFn := fun _ => 0

private theorem negligible_zeroError : IsNegligible zeroError := by
  simpa [zeroError] using (isNegligible_zero : IsNegligible (fun _ => 0))

/-- Error accounting model with explicit source terms and total term. -/
structure ErrorModel where
  epsSumcheck : ErrorFn
  epsMSIS : ErrorFn
  epsSchwartzZippel : ErrorFn
  epsBinding : ErrorFn
  epsRelaxedBinding : ErrorFn
  epsTotal : ErrorFn
  epsTotal_decomp :
    ∀ n,
      epsTotal n =
        epsSumcheck n + epsMSIS n + epsSchwartzZippel n + epsBinding n + epsRelaxedBinding n
  negligibleSumcheck : IsNegligible epsSumcheck
  negligibleMSIS : IsNegligible epsMSIS
  negligibleSchwartzZippel : IsNegligible epsSchwartzZippel
  negligibleBinding : IsNegligible epsBinding
  negligibleRelaxedBinding : IsNegligible epsRelaxedBinding
  negligibleTotal : IsNegligible epsTotal

/-- A canonical zero-error model used as a default scaffold value. -/
def zeroErrorModel : ErrorModel where
  epsSumcheck := zeroError
  epsMSIS := zeroError
  epsSchwartzZippel := zeroError
  epsBinding := zeroError
  epsRelaxedBinding := zeroError
  epsTotal := zeroError
  epsTotal_decomp := by
    intro n
    simp [zeroError, Rat.add_zero]
  negligibleSumcheck := negligible_zeroError
  negligibleMSIS := negligible_zeroError
  negligibleSchwartzZippel := negligible_zeroError
  negligibleBinding := negligible_zeroError
  negligibleRelaxedBinding := negligible_zeroError
  negligibleTotal := negligible_zeroError

end SuperNeo.ProofSystem

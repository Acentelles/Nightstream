namespace Nightstream.Rv64IM

structure SequenceResult (Output StateEffect : Type _) where
  output : Output
  stateEffect : StateEffect
deriving DecidableEq, Repr

def AdviceSequenceCorrect
  (ArchitecturalInputs AuthenticatedReads AdviceAssignment Output StateEffect : Type _)
  (rowAssertions : ArchitecturalInputs → AuthenticatedReads → AdviceAssignment → Prop)
  (committedResult :
    ArchitecturalInputs → AuthenticatedReads → AdviceAssignment →
      SequenceResult Output StateEffect)
  (isaResult :
    ArchitecturalInputs → AuthenticatedReads → SequenceResult Output StateEffect) :
  Prop :=
  ∀ inputs reads advice,
    rowAssertions inputs reads advice →
      committedResult inputs reads advice = isaResult inputs reads

def AdviceSequenceDeterministic
  (ArchitecturalInputs AuthenticatedReads AdviceAssignment Output StateEffect : Type _)
  (rowAssertions : ArchitecturalInputs → AuthenticatedReads → AdviceAssignment → Prop)
  (committedResult :
    ArchitecturalInputs → AuthenticatedReads → AdviceAssignment →
      SequenceResult Output StateEffect) :
  Prop :=
  ∀ inputs reads advice₁ advice₂,
    rowAssertions inputs reads advice₁ →
      rowAssertions inputs reads advice₂ →
      committedResult inputs reads advice₁ = committedResult inputs reads advice₂

structure AdviceSequenceProofPackage
  (ArchitecturalInputs AuthenticatedReads AdviceAssignment Output StateEffect : Type _)
  (rowAssertions : ArchitecturalInputs → AuthenticatedReads → AdviceAssignment → Prop)
  (committedResult :
    ArchitecturalInputs → AuthenticatedReads → AdviceAssignment →
      SequenceResult Output StateEffect)
  (isaResult :
    ArchitecturalInputs → AuthenticatedReads → SequenceResult Output StateEffect) where
  correct :
    AdviceSequenceCorrect
      ArchitecturalInputs
      AuthenticatedReads
      AdviceAssignment
      Output
      StateEffect
      rowAssertions
      committedResult
      isaResult
  deterministic :
    AdviceSequenceDeterministic
      ArchitecturalInputs
      AuthenticatedReads
      AdviceAssignment
      Output
      StateEffect
      rowAssertions
      committedResult

theorem adviceSequenceDeterministic_of_correct
  {ArchitecturalInputs AuthenticatedReads AdviceAssignment Output StateEffect : Type _}
  {rowAssertions : ArchitecturalInputs → AuthenticatedReads → AdviceAssignment → Prop}
  {committedResult :
    ArchitecturalInputs → AuthenticatedReads → AdviceAssignment →
      SequenceResult Output StateEffect}
  {isaResult :
    ArchitecturalInputs → AuthenticatedReads → SequenceResult Output StateEffect}
  (hCorrect :
    AdviceSequenceCorrect
      ArchitecturalInputs
      AuthenticatedReads
      AdviceAssignment
      Output
      StateEffect
      rowAssertions
      committedResult
      isaResult) :
  AdviceSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    AdviceAssignment
    Output
    StateEffect
    rowAssertions
    committedResult := by
  intro inputs reads advice₁ advice₂ h₁ h₂
  calc
    committedResult inputs reads advice₁ = isaResult inputs reads := hCorrect _ _ _ h₁
    _ = committedResult inputs reads advice₂ := (hCorrect _ _ _ h₂).symm

def adviceSequenceProofPackage_of_correct
  {ArchitecturalInputs AuthenticatedReads AdviceAssignment Output StateEffect : Type _}
  {rowAssertions : ArchitecturalInputs → AuthenticatedReads → AdviceAssignment → Prop}
  {committedResult :
    ArchitecturalInputs → AuthenticatedReads → AdviceAssignment →
      SequenceResult Output StateEffect}
  {isaResult :
    ArchitecturalInputs → AuthenticatedReads → SequenceResult Output StateEffect}
  (hCorrect :
    AdviceSequenceCorrect
      ArchitecturalInputs
      AuthenticatedReads
      AdviceAssignment
      Output
      StateEffect
      rowAssertions
      committedResult
      isaResult) :
  AdviceSequenceProofPackage
    ArchitecturalInputs
    AuthenticatedReads
    AdviceAssignment
    Output
    StateEffect
    rowAssertions
    committedResult
    isaResult :=
  { correct := hCorrect
    deterministic := adviceSequenceDeterministic_of_correct hCorrect }

end Nightstream.Rv64IM

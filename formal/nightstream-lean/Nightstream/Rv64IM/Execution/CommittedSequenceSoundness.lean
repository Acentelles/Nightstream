namespace Nightstream.Rv64IM

structure SequenceResult (Output StateEffect : Type _) where
  output : Output
  stateEffect : StateEffect
deriving DecidableEq, Repr

structure CommittedSequence (Row : Type _) where
  rows : List Row
  resultRowIndex : Nat
  resultRowIndex_lt_length : resultRowIndex < rows.length

structure TouchedStateSet (StateLocation : Type _) where
  touches : StateLocation → Prop

abbrev PreservedStatePredicate
  (Row ArchitecturalInputs AuthenticatedReads Output StateEffect StateLocation : Type _) :=
  CommittedSequence Row →
    TouchedStateSet StateLocation →
    ArchitecturalInputs →
    AuthenticatedReads →
    SequenceResult Output StateEffect →
    Prop

def CommittedSequenceCorrect
  (ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect Row StateLocation :
    Type _)
  (sequence : CommittedSequence Row)
  (touchedState : TouchedStateSet StateLocation)
  (rowAssertions :
    CommittedSequence Row → ArchitecturalInputs → AuthenticatedReads → WitnessAssignment → Prop)
  (committedResult :
    CommittedSequence Row → ArchitecturalInputs → AuthenticatedReads → WitnessAssignment →
      SequenceResult Output StateEffect)
  (isaResult :
    ArchitecturalInputs → AuthenticatedReads → SequenceResult Output StateEffect)
  (preservedState :
    PreservedStatePredicate
      Row
      ArchitecturalInputs
      AuthenticatedReads
      Output
      StateEffect
      StateLocation) :
  Prop :=
  ∀ inputs reads witness,
    rowAssertions sequence inputs reads witness →
      committedResult sequence inputs reads witness = isaResult inputs reads ∧
        preservedState
          sequence
          touchedState
          inputs
          reads
          (committedResult sequence inputs reads witness)

def CommittedSequenceDeterministic
  (ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect Row StateLocation :
    Type _)
  (sequence : CommittedSequence Row)
  (_touchedState : TouchedStateSet StateLocation)
  (rowAssertions :
    CommittedSequence Row → ArchitecturalInputs → AuthenticatedReads → WitnessAssignment → Prop)
  (committedResult :
    CommittedSequence Row → ArchitecturalInputs → AuthenticatedReads → WitnessAssignment →
      SequenceResult Output StateEffect) :
  Prop :=
  ∀ inputs reads witness₁ witness₂,
    rowAssertions sequence inputs reads witness₁ →
      rowAssertions sequence inputs reads witness₂ →
      committedResult sequence inputs reads witness₁ =
        committedResult sequence inputs reads witness₂

structure CommittedSequenceProofPackage
  (ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect Row StateLocation :
    Type _)
  (rowAssertions :
    CommittedSequence Row → ArchitecturalInputs → AuthenticatedReads → WitnessAssignment → Prop)
  (committedResult :
    CommittedSequence Row → ArchitecturalInputs → AuthenticatedReads → WitnessAssignment →
      SequenceResult Output StateEffect)
  (isaResult :
    ArchitecturalInputs → AuthenticatedReads → SequenceResult Output StateEffect)
  (preservedState :
    PreservedStatePredicate
      Row
      ArchitecturalInputs
      AuthenticatedReads
      Output
      StateEffect
      StateLocation) where
  sequence : CommittedSequence Row
  touchedState : TouchedStateSet StateLocation
  correct :
    CommittedSequenceCorrect
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      Row
      StateLocation
      sequence
      touchedState
      rowAssertions
      committedResult
      isaResult
      preservedState
  deterministic :
    CommittedSequenceDeterministic
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      Row
      StateLocation
      sequence
      touchedState
      rowAssertions
      committedResult

theorem committedSequenceDeterministic_of_correct
  {ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect Row StateLocation :
    Type _}
  {sequence : CommittedSequence Row}
  {touchedState : TouchedStateSet StateLocation}
  {rowAssertions :
    CommittedSequence Row → ArchitecturalInputs → AuthenticatedReads → WitnessAssignment → Prop}
  {committedResult :
    CommittedSequence Row → ArchitecturalInputs → AuthenticatedReads → WitnessAssignment →
      SequenceResult Output StateEffect}
  {isaResult :
    ArchitecturalInputs → AuthenticatedReads → SequenceResult Output StateEffect}
  {preservedState :
    PreservedStatePredicate
      Row
      ArchitecturalInputs
      AuthenticatedReads
      Output
      StateEffect
      StateLocation}
  (hCorrect :
    CommittedSequenceCorrect
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      Row
      StateLocation
      sequence
      touchedState
      rowAssertions
      committedResult
      isaResult
      preservedState) :
  CommittedSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    Row
    StateLocation
    sequence
    touchedState
    rowAssertions
    committedResult := by
  intro inputs reads witness₁ witness₂ h₁ h₂
  calc
    committedResult sequence inputs reads witness₁ = isaResult inputs reads :=
      (hCorrect _ _ _ h₁).1
    _ = committedResult sequence inputs reads witness₂ :=
      ((hCorrect _ _ _ h₂).1).symm

def committedSequenceProofPackage_of_correct
  {ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect Row StateLocation :
    Type _}
  (sequence : CommittedSequence Row)
  (touchedState : TouchedStateSet StateLocation)
  {rowAssertions :
    CommittedSequence Row → ArchitecturalInputs → AuthenticatedReads → WitnessAssignment → Prop}
  {committedResult :
    CommittedSequence Row → ArchitecturalInputs → AuthenticatedReads → WitnessAssignment →
      SequenceResult Output StateEffect}
  {isaResult :
    ArchitecturalInputs → AuthenticatedReads → SequenceResult Output StateEffect}
  {preservedState :
    PreservedStatePredicate
      Row
      ArchitecturalInputs
      AuthenticatedReads
      Output
      StateEffect
      StateLocation}
  (hCorrect :
    CommittedSequenceCorrect
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      Row
      StateLocation
      sequence
      touchedState
      rowAssertions
      committedResult
      isaResult
      preservedState) :
  CommittedSequenceProofPackage
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    Row
    StateLocation
    rowAssertions
    committedResult
    isaResult
    preservedState :=
  { sequence := sequence
    touchedState := touchedState
    correct := hCorrect
    deterministic := committedSequenceDeterministic_of_correct hCorrect }

end Nightstream.Rv64IM

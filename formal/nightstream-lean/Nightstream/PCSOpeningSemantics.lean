import SuperNeo.PolynomialBridge
import SuperNeo.ProofSystem.Lattice

namespace Nightstream.PCSOpeningSemantics

open SuperNeo
open SuperNeo.ProofSystem

abbrev F := SuperNeo.Fq

structure RawScalarClaim (Family Point : Type*) where
  family : Family
  point : Point
  value : F
deriving DecidableEq, Repr

structure OpeningWitness (params : AjtaiParams) where
  commitment : Commitment
  opening : Opening
  opens : opensTo params commitment opening

def extractsRawScalar
  (extract : Commitment → Opening → Family → Point → F)
  {params : AjtaiParams}
  (w : OpeningWitness params)
  (claim : RawScalarClaim Family Point) : Prop :=
  claim.value = extract w.commitment w.opening claim.family claim.point

structure OpeningRefinement
  (params : AjtaiParams)
  (extract : Commitment → Opening → Family → Point → F)
  (claim : RawScalarClaim Family Point) where
  witness : OpeningWitness params
  extracts : extractsRawScalar extract witness claim

def RawOpeningSeparation
  (params : AjtaiParams)
  (extract : Commitment → Opening → Family → Point → F)
  (claim : RawScalarClaim Family Point) : Prop :=
  ∃ refinement : OpeningRefinement params extract claim,
    claim.value =
        extract refinement.witness.commitment refinement.witness.opening
          claim.family claim.point ∧
      Opening.NormSound refinement.witness.opening

theorem opensTo_of_refinement
  {params : AjtaiParams}
  {extract : Commitment → Opening → Family → Point → F}
  {claim : RawScalarClaim Family Point}
  (h : OpeningRefinement params extract claim) :
  opensTo params h.witness.commitment h.witness.opening := by
  exact h.witness.opens

theorem commitmentWellFormed_of_refinement
  {params : AjtaiParams}
  {extract : Commitment → Opening → Family → Point → F}
  {claim : RawScalarClaim Family Point}
  (h : OpeningRefinement params extract claim) :
  Commitment.WellFormed params h.witness.commitment := by
  exact (opensTo_of_refinement h).1

theorem openingWellFormed_of_refinement
  {params : AjtaiParams}
  {extract : Commitment → Opening → Family → Point → F}
  {claim : RawScalarClaim Family Point}
  (h : OpeningRefinement params extract claim) :
  Opening.WellFormed params h.witness.opening := by
  exact (opensTo_of_refinement h).2.1

theorem openingNormSound_of_refinement
  {params : AjtaiParams}
  {extract : Commitment → Opening → Family → Point → F}
  {claim : RawScalarClaim Family Point}
  (h : OpeningRefinement params extract claim) :
  Opening.NormSound h.witness.opening := by
  exact (opensTo_of_refinement h).2.2.1

theorem rawScalarMatches_of_refinement
  {params : AjtaiParams}
  {extract : Commitment → Opening → Family → Point → F}
  {claim : RawScalarClaim Family Point}
  (h : OpeningRefinement params extract claim) :
  claim.value =
    extract h.witness.commitment h.witness.opening claim.family claim.point := by
  exact h.extracts

theorem rawOpeningSeparation_of_refinement
  {params : AjtaiParams}
  {extract : Commitment → Opening → Family → Point → F}
  {claim : RawScalarClaim Family Point}
  (h : OpeningRefinement params extract claim) :
  RawOpeningSeparation params extract claim := by
  refine ⟨h, rawScalarMatches_of_refinement h, openingNormSound_of_refinement h⟩

end Nightstream.PCSOpeningSemantics

namespace Nightstream.Rv64IM

structure OpeningClaim (Source CommitmentId Point PolynomialId Value Digest : Type _) where
  source : Source
  commitmentId : CommitmentId
  point : Point
  polynomialIds : List PolynomialId
  claimedValues : List Value
  digest : Digest
deriving Repr

structure OpeningProvenanceChain
  (Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding PreparedStep : Type _) where
  claim : OpeningClaim Source CommitmentId Point PolynomialId Value Digest
  exactOpeningWitness : ExactOpeningWitness
  openingRefinement : OpeningRefinement
  rowProjectionWitness : RowProjectionWitness
  bridgeBinding : BridgeBinding
  preparedStep : PreparedStep
deriving Repr

def OpeningProvenanceValid
  (exactOpening :
    OpeningClaim Source CommitmentId Point PolynomialId Value Digest →
      ExactOpeningWitness → Prop)
  (refinesOpening : ExactOpeningWitness → OpeningRefinement → Prop)
  (projectsRow : OpeningRefinement → RowProjectionWitness → Prop)
  (bindsBridge : RowProjectionWitness → BridgeBinding → Prop)
  (bindsPreparedStep : BridgeBinding → PreparedStep → Prop)
  (chain :
    OpeningProvenanceChain
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding
      PreparedStep) :
  Prop :=
  exactOpening chain.claim chain.exactOpeningWitness ∧
    refinesOpening chain.exactOpeningWitness chain.openingRefinement ∧
    projectsRow chain.openingRefinement chain.rowProjectionWitness ∧
    bindsBridge chain.rowProjectionWitness chain.bridgeBinding ∧
    bindsPreparedStep chain.bridgeBinding chain.preparedStep

structure OpeningProvenanceProofPackage
  (Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding PreparedStep : Type _) where
  chain :
    OpeningProvenanceChain
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding
      PreparedStep
  valid :
    ∃ exactOpening refinesOpening projectsRow bindsBridge bindsPreparedStep,
      OpeningProvenanceValid
        exactOpening
        refinesOpening
        projectsRow
        bindsBridge
        bindsPreparedStep
        chain

end Nightstream.Rv64IM

import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes
import Nightstream.Rv64IM.Generated.ImportedParityCorpus
import Nightstream.Rv64IM.Generated.PublicProofVectors.Corpus

/-!
Lean-owned corpus assembly for RV64IM accepted-proof artifact checks. The proof
artifact view is paired with the imported parity-derived case by case name so
that the executable checker can treat the source case as the authoritative low
layer, require exact `source -> derived` replay parity, and treat the public
proof shape only as a derived projection.
-/

namespace Nightstream.Rv64IM.Generated

namespace AcceptedProofArtifacts

private def sourceAndDerivedCaseByName? (name : String) : Option (ParitySourceCase × ParityDerivedCase) :=
  parityCases.findSome? fun (source, derived) =>
    if source.manifest.name = name then
      some (source, derived)
    else
      none

private def caseOfPublicProofVector? (proofCase : PublicProofVectorCase) : Option AcceptedProofArtifactView :=
  match sourceAndDerivedCaseByName? proofCase.name with
  | none => none
  | some (source, derived) =>
      some
        { name := proofCase.name
        , source := source
        , derived := derived
        , kernelProof := proofCase.proof.kernel
        , exportedProof := proofCase.proof
        , exportedStatement := proofCase.statement
        , exportedClaims := proofCase.claims
        , exportedKernelProof := proofCase.kernelProof
        }

def cases : List AcceptedProofArtifactView :=
  PublicProofVectors.cases.filterMap caseOfPublicProofVector?

def caseByName? (name : String) : Option AcceptedProofArtifactView :=
  cases.find? fun artifact => artifact.name = name

end AcceptedProofArtifacts

end Nightstream.Rv64IM.Generated

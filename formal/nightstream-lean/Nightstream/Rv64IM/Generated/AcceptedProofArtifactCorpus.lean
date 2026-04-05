import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes
import Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.Corpus

/-!
Lean-owned corpus assembly for RV64IM accepted-proof artifact checks. The Rust
vector generator materializes one accepted-artifact case per parity program,
including the exported source/derived replay target, the projected public proof
shape, and the accepted-only stage/root payloads.
-/

namespace Nightstream.Rv64IM.Generated

namespace AcceptedProofArtifacts

def cases : List AcceptedProofArtifactView :=
  Nightstream.Rv64IM.Generated.AcceptedProofArtifactVectors.cases

def caseByName? (name : String) : Option AcceptedProofArtifactView :=
  cases.find? fun artifact => artifact.name = name

end AcceptedProofArtifacts

end Nightstream.Rv64IM.Generated

import Nightstream.Rv64IM.ProofBoundaryChecks

/-!
Interface for the executable RV64IM public proof-boundary parity checks.
-/

namespace Nightstream.Rv64IM

namespace ProofBoundaryChecksInterface

def implementationModule : String := "Nightstream.Rv64IM.ProofBoundaryChecks"

def exportedModuleNames : List String :=
  [ "Nightstream.Rv64IM.Generated.PublicProofVectors.Corpus"
  , "Nightstream.Rv64IM.ProofBoundaryChecks"
  ]

def entrypointContract : Prop := True

theorem entrypointContract_true : entrypointContract := by
  trivial

end ProofBoundaryChecksInterface

end Nightstream.Rv64IM

import Nightstream.Rv64IM.AcceptedArtifactChecks

/-!
Interface for the executable RV64IM accepted-artifact parity checks.
-/

namespace Nightstream.Rv64IM

namespace AcceptedArtifactChecksInterface

def implementationModule : String := "Nightstream.Rv64IM.AcceptedArtifactChecks"

def exportedModuleNames : List String :=
  [ "Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus"
  , "Nightstream.Rv64IM.AcceptedArtifactChecks"
  ]

def entrypointContract : Prop := True

theorem entrypointContract_true : entrypointContract := by
  trivial

end AcceptedArtifactChecksInterface

end Nightstream.Rv64IM
